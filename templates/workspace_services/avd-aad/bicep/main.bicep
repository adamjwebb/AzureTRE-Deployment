targetScope = 'subscription'

param id string
param workspaceId string
param treId string
param tags object = {}
param localAdminName string = 'adminuser'
param vmSize string = 'Standard_D2as_v4'

param vmCount int = 1
param deploymentTime string = utcNow()
@secure()
param passwordSeed string = newGuid()

var shortWorkspaceId = substring(workspaceId, length(workspaceId) - 4, 4)
var shortServiceId = substring(id, length(id) - 4, 4)
var workspaceResourceNameSuffix = '${treId}-ws-${shortWorkspaceId}'
var serviceResourceNameSuffix = '${workspaceResourceNameSuffix}-svc-${shortServiceId}'

var deploymentNamePrefix = '${serviceResourceNameSuffix}-{rtype}-${deploymentTime}'

resource workspaceResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'rg-${workspaceResourceNameSuffix}'
}

resource coreResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'rg-${treId}'
}

resource workspaceKeyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: 'kv-${workspaceResourceNameSuffix}'
  scope: workspaceResourceGroup
}

// Doubling up the unique string with the same seed does not increase password entropy,
// but it guarantees that there will be at least three character classes present in the password
// to meet operating system password complexity requirements
// This could be enhanced by specifying a second, different seed GUID
var localAdminPasswordGenerated = '${uniqueString(passwordSeed)}_${toUpper(uniqueString(passwordSeed))}'

var secrets = [
  {
    secretValue: passwordSeed
    secretName: '${shortServiceId}-${deploymentTime}-localadminpwdseed'
  }
  {
    // Generate a new password for the required local VM admin
    secretValue: localAdminPasswordGenerated
    secretName: '${shortServiceId}-${deploymentTime}-localadminpwd'
  }
]

// Persist the new password in the workspace's Key Vault
module keyVaultSecrets 'modules/keyVaultSecret.bicep' = [for (secret, i) in secrets: {
  scope: workspaceResourceGroup
  name: '${replace(deploymentNamePrefix, '{rtype}', 'Secret')}-${i}'
  params: {
    workspaceKeyVaultName: workspaceKeyVault.name
    secretValue: secrets[i].secretValue
    secretName: secrets[i].secretName
  }
}]

resource workspaceVirtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  scope: workspaceResourceGroup
  name: 'vnet-${workspaceResourceNameSuffix}'
}

var workspaceAvdSubnet = workspaceVirtualNetwork.properties.subnets[1].properties.addressPrefix

module ruleCollectionGroup 'modules/firewallRuleCollectionGroup.bicep' = {
  name: 'avdFirewallRuleCollectionGroup'
  scope: coreResourceGroup
  params: {
    firewallPolicyName: 'fw-policy-${treId}'
    name: 'rcg-avd-${workspaceResourceNameSuffix}'
    priority: 700
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        name: 'nrc-avd-${workspaceResourceNameSuffix}'
        priority: 701
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Service Traffic'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              workspaceAvdSubnet
            ]
            sourceIpGroups: []
            destinationAddresses: [
              'WindowsVirtualDesktop'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '443'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Agent Traffic (1)'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              workspaceAvdSubnet
            ]
            sourceIpGroups: []
            destinationAddresses: [
              'AzureMonitor'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '443'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Azure Marketplace'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              workspaceAvdSubnet
            ]
            sourceIpGroups: []
            destinationAddresses: [
              'AzureFrontDoor.Frontend'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '443'
            ]
          }

          {
            ruleType: 'NetworkRule'
            name: 'Azure Instance Metadata Service Endpoint'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              workspaceAvdSubnet
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '169.254.169.254'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '80'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Session Host Health Monitoring'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              workspaceAvdSubnet
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '168.63.129.16'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '80'
            ]
          }

        ]
      }
      {
        ruleCollectionType: 'firewallpolicyfilterrulecollection'
        action: {
          type: 'Allow'
        }
        name: 'arc-avd-${workspaceResourceNameSuffix}'
        priority: 702
        rules: [
          {
            ruleType: 'applicationRule'
            name: 'avd_wvd'
            sourceAddresses: [
              workspaceAvdSubnet
            ]
            fqdnTags: [
              'WindowsVirtualDesktop'
            ]
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
          }
          {
            ruleType: 'applicationRule'
            name: 'Agent Traffic (2)'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            sourceAddresses: [
              workspaceAvdSubnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            targetFqdns: [
              'gcs.prod.monitoring.core.windows.net'
            ]
          }
          {
            ruleType: 'applicationRule'
            name: 'Windows activation'
            protocols: [
              {
                protocolType: 'Https'
                port: 1688
              }
            ]
            sourceAddresses: [
              workspaceAvdSubnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            targetFqdns: [
              'kms.core.windows.net'
            ]
          }
          {
            ruleType: 'applicationRule'
            name: 'Azure Windows activation'
            protocols: [
              {
                protocolType: 'Https'
                port: 1688
              }
            ]
            sourceAddresses: [
              workspaceAvdSubnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            targetFqdns: [
              'azkms.core.windows.net'
            ]

          }
          {
            ruleType: 'applicationRule'
            name: 'Agent and SXS Stack Updates'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            sourceAddresses: [
              workspaceAvdSubnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            targetFqdns: [
              'mrsglobalsteus2prod.blob.core.windows.net'
            ]
          }
          {
            ruleType: 'applicationRule'
            name: 'Azure Portal Support'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            sourceAddresses: [
              workspaceAvdSubnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            targetFqdns: [
              'wvdportalstorageblob.blob.core.windows.net'
            ]
          }
          {
            ruleType: 'applicationRule'
            name: 'Certificate CRL OneOCSP'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
            ]
            sourceAddresses: [
              workspaceAvdSubnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            targetFqdns: [
              'oneocsp.microsoft.com'
            ]
          }
          {
            ruleType: 'applicationRule'
            name: 'Certificate CRL MicrosoftDotCom'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
            ]
            sourceAddresses: [
              workspaceAvdSubnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            targetFqdns: [
              'www.microsoft.com'
            ]
          }
          {
            ruleType: 'applicationRule'
            name: 'Entra ID & Microsoft Online Services'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
              {
                protocolType: 'Http'
                port: 80
              }
            ]
            sourceAddresses: [
              workspaceAvdSubnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            targetFqdns: [
              '*.auth.microsoft.com'
              '*.msftidentity.com'
              '*.msidentity.com'
              'account.activedirectory.windowsazure.com'
              'accounts.accesscontrol.windows.net'
              'adminwebservice.microsoftonline.com'
              'api.passwordreset.microsoftonline.com'
              'autologon.microsoftazuread-sso.com'
              'becws.microsoftonline.com'
              'ccs.login.microsoftonline.com'
              'clientconfig.microsoftonline-p.net'
              'companymanager.microsoftonline.com'
              'device.login.microsoftonline.com'
              'graph.microsoft.com'
              'graph.windows.net'
              'login.live.com'
              'login.microsoft.com'
              'login.microsoftonline.com'
              'login.microsoftonline-p.com'
              'login.windows.net'
              'logincert.microsoftonline.com'
              'loginex.microsoftonline.com'
              'login-us.microsoftonline.com'
              'nexus.microsoftonline-p.com'
              'passwordreset.microsoftonline.com'
              'provisioningapi.microsoftonline.com'
              '*.hip.live.com'
              '*.microsoftonline.com'
              '*.microsoftonline-p.com'
              '*.msauth.net'
              '*.msauthimages.net'
              '*.msecnd.net'
              '*.msftauth.net'
              '*.msftauthimages.net'
              '*.phonefactor.net'
              'enterpriseregistration.windows.net'
              'policykeyservice.dc.ad.msft.net'
              '*.windowsupdate.com'
              '*.update.microsoft.com'
              'client.wns.windows.com'
              'fs.microsoft.com'
              'unitedstates.cp.wd.microsoft.com'
              'www.msftconnecttest.com'
              'events.data.microsoft.com'
              'winatp-gw-cus3.microsoft.com'
            ]
          }
          {
            ruleType: 'applicationRule'
            name: 'Certificate Services'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
              {
                protocolType: 'Http'
                port: 80
              }
            ]
            sourceAddresses: [
              workspaceAvdSubnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            targetFqdns: [
              '*.entrust.net'
              '*.geotrust.com'
              '*.omniroot.com'
              '*.public-trust.com'
              '*.symcb.com'
              '*.symcd.com'
              '*.verisign.com'
              '*.verisign.net'
              'apps.identrust.com'
              'cacerts.digicert.com'
              'cert.int-x3.letsencrypt.org'
              'crl.globalsign.com'
              'crl.globalsign.net'
              'crl.identrust.com'
              'crl3.digicert.com'
              'crl4.digicert.com'
              'isrg.trustid.ocsp.identrust.com'
              'mscrl.microsoft.com'
              'ocsp.digicert.com'
              'ocsp.globalsign.com'
              'ocsp.msocsp.com'
              'ocsp2.globalsign.com'
              'ocspx.digicert.com'
              'secure.globalsign.com'
              'www.digicert.com'
              'www.microsoft.com'
            ]
          }
        ]
      }
    ]
  }
}

module hostPool 'modules/hostPools.bicep' = {
  scope: workspaceResourceGroup
  name: replace(deploymentNamePrefix, '{rtype}', 'AVD-HostPool')
  params: {
    name: serviceResourceNameSuffix
    tags: tags
    location: workspaceResourceGroup.location
    hostPoolType: 'Pooled'
  }
}

module applicationGroup 'modules/applicationGroup.bicep' = {
  scope: workspaceResourceGroup
  name: replace(deploymentNamePrefix, '{rtype}', 'AVD-ApplicationGroup')
  params: {
    name: serviceResourceNameSuffix
    tags: tags
    location: workspaceResourceGroup.location
    hostPoolId: hostPool.outputs.id
  }
}

module workspace 'modules/workspace.bicep' = {
  scope: workspaceResourceGroup
  name: replace(deploymentNamePrefix, '{rtype}', 'AVD-Workspace')
  params: {
    name: serviceResourceNameSuffix
    tags: tags
    location: workspaceResourceGroup.location
    applicationGroupId: applicationGroup.outputs.id
  }
}

module sessionHost 'modules/sessionHost.bicep' = {
  scope: workspaceResourceGroup
  name: replace(deploymentNamePrefix, '{rtype}', 'AVD-SessionHosts')
  params: {
    name: 'vm-avd-${shortWorkspaceId}'
    tags: tags
    location: workspaceResourceGroup.location
    localAdminName: localAdminName
    localAdminPassword: localAdminPasswordGenerated
    subnetName: 'ServicesSubnet'
    vmSize: vmSize
    vmCount: vmCount
    vnetId: workspaceVirtualNetwork.id
    hostPoolName: hostPool.outputs.name
    hostPoolRegToken: hostPool.outputs.hostpoolToken
    deploymentNameStructure: deploymentNamePrefix
  }
}

output connection_uri string = 'https://aka.ms/wvdarmweb'
