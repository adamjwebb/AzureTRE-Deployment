@description('The name of the Azure Firewall Policy that will be created.')
param firewallPolicies_AVD_DefaultPolicy_name string

@description('Azure region where the policy object will be created.')
param location string = resourceGroup().location

@description('Type of the Azure Policy that will be created.')
@allowed([
  'premium'
  'standard'
])
param firewall_policy_tier string

@description('Primary DNS used by AVD Host Pool (recommended to add a secondary DNS later).')
param dns_server string

@description('The subnet of the AVD Host Pool that will get the Azure Firewall Policy applied.')
param avd_hostpool_subnet string

var avd_core_base_priority = 10000
var NetworkRules_WindowsVirtualDesktop_priority = (avd_core_base_priority + 1000)
var avd_optional_base_priority = 20000
var NetworkRules_AVD_Optional_priority = (avd_optional_base_priority + 1000)
var ApplicationRules_AVD_Optional_priority = (avd_optional_base_priority + 2000)

resource firewallPolicies_AVD_DefaultPolicy_name_resource 'Microsoft.Network/firewallPolicies@2020-11-01' = {
  name: firewallPolicies_AVD_DefaultPolicy_name
  location: location
  properties: {
    sku: {
      tier: firewall_policy_tier
    }
    threatIntelMode: 'Alert'
    dnsSettings: {
      servers: [
        dns_server
      ]
      enableProxy: true
    }
  }
}

resource firewallPolicies_AVD_DefaultPolicy_name_AVD_Core 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-11-01' = {
  parent: firewallPolicies_AVD_DefaultPolicy_name_resource
  name: 'AVD-Core'
  location: location
  properties: {
    priority: avd_core_base_priority
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Service Traffic'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
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
              avd_hostpool_subnet
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
            name: 'Agent Traffic (2)'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'gcs.prod.monitoring.core.windows.net'
            ]
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
              avd_hostpool_subnet
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
            name: 'Windows activation'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'kms.core.windows.net'
            ]
            destinationPorts: [
              '1688'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Azure Windows activation'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'azkms.core.windows.net'
            ]
            destinationPorts: [
              '1688'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Agent and SXS Stack Updates'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'mrsglobalsteus2prod.blob.core.windows.net'
            ]
            destinationPorts: [
              '443'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Azure Portal Support'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'wvdportalstorageblob.blob.core.windows.net'
            ]
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
              avd_hostpool_subnet
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
              avd_hostpool_subnet
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
          {
            ruleType: 'NetworkRule'
            name: 'Certificate CRL OneOCSP'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'oneocsp.microsoft.com'
            ]
            destinationPorts: [
              '80'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Certificate CRL MicrosoftDotCom'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'www.microsoft.com'
            ]
            destinationPorts: [
              '80'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Authentication to Microsoft Online Services'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'login.microsoftonline.com'
            ]
            destinationPorts: [
              '443'
            ]
          }
        ]
        name: 'NetworkRules_WindowsVirtualDesktop'
        priority: NetworkRules_WindowsVirtualDesktop_priority
      }
    ]
  }
}

resource firewallPolicies_AVD_DefaultPolicy_name_AVD_Optional 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-11-01' = {
  parent: firewallPolicies_AVD_DefaultPolicy_name_resource
  name: 'AVD-Optional'
  location: location
  properties: {
    priority: avd_optional_base_priority
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'NTP'
            ipProtocols: [
              'TCP'
              'UDP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'time.windows.com'
            ]
            destinationPorts: [
              '123'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'SigninToMSOL365'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'login.windows.net'
            ]
            destinationPorts: [
              '443'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'DetectOSconnectedToInternet'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'www.msftconnecttest.com'
            ]
            destinationPorts: [
              '443'
            ]
          }
        ]
        name: 'NetworkRules_AVD-Optional'
        priority: NetworkRules_AVD_Optional_priority
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'TelemetryService'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              '*.events.data.microsoft.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'WindowsUpdate'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: [
              'WindowsUpdate'
            ]
            webCategories: []
            targetFqdns: []
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'UpdatesForOneDrive'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              '*.sfx.ms'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'DigitcertCRL'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              '*.digicert.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'AzureDNSresolution1'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              '*.azure-dns.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'AzureDNSresolution2'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              '*.azure-dns.net'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
        ]
        name: 'ApplicationRules_AVD-Optional'
        priority: ApplicationRules_AVD_Optional_priority
      }
    ]
  }
}