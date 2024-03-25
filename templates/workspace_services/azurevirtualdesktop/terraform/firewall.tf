data "azurerm_firewall_policy" "fw_policy" {
  name                = "fw-policy-${var.tre_id}"
  resource_group_name = "rg-${var.tre_id}"
}

/*
data "azurerm_client_config" "current" {}
resource "null_resource" "az_login_sp" {

  count = var.arm_use_msi == true ? 0 : 1
  provisioner "local-exec" {
    command = "az login --service-principal --username ${var.arm_client_id} --password ${var.arm_client_secret} --tenant ${var.arm_tenant_id}"
  }

  triggers = {
    timestamp = timestamp()
  }

}

resource "null_resource" "az_login_msi" {

  count = var.arm_use_msi == true ? 1 : 0
  provisioner "local-exec" {
    command = "az login --identity -u '${data.azurerm_client_config.current.client_id}'"
  }

  triggers = {
    timestamp = timestamp()
  }
}

data "external" "rule_priorities" {
  program = ["bash", "-c", "./get_firewall_priorities.sh"]

  query = {
    firewall_name          = data.azurerm_firewall.fw.name
    resource_group_name    = data.azurerm_firewall.fw.resource_group_name
    collection_name_suffix = "${local.service_resource_name_suffix}-aml"
  }
  depends_on = [
    null_resource.az_login_sp,
    null_resource.az_login_msi
  ]
}
*/

resource "azurerm_firewall_policy_rule_collection_group" "avdrulecollectiongroup" {
  name               = "avdrulecollectiongroup"
  firewall_policy_id = data.azurerm_firewall_policy.fw_policy.id
  priority           = 530
  network_rule_collection {
    name     = "avd_network_rule_collection"
    priority = 531
    action   = "Allow"

    rule {
      name = "Service traffic"
      source_addresses = [
        data.azurerm_subnet.services.address_prefix
      ]
      destination_ports = [
        "443",
      ]
      destination_addresses = [
        "WindowsVirtualDesktop"
      ]
      protocols = [
        "TCP"
      ]
    }

    rule {
      name = "Agent traffic diagnostic output"
      source_addresses = [
        data.azurerm_subnet.services.address_prefix
      ]
      destination_ports = [
        "443",
      ]
      destination_addresses = [
        "AzureMonitor"
      ]
      protocols = [
        "TCP"
      ]
    }

    rule {
      name = "Azure Marketplace"
      source_addresses = [
        data.azurerm_subnet.services.address_prefix
      ]
      destination_ports = [
        "443",
      ]
      destination_addresses = [
        "AzureFrontDoor.Frontend"
      ]
      protocols = [
        "TCP"
      ]
    }

    rule {
      name = "Azure Instance Metadata service endpoint"
      source_addresses = [
        data.azurerm_subnet.services.address_prefix
      ]
      destination_ports = [
        "80",
      ]
      destination_addresses = [
        "169.254.169.254"
      ]
      protocols = [
        "TCP"
      ]
    }

    rule {
      name = "Session host health monitoring"
      source_addresses = [
        data.azurerm_subnet.services.address_prefix
      ]
      destination_ports = [
        "80",
      ]
      destination_addresses = [
        "168.63.129.16"
      ]
      protocols = [
        "TCP"
      ]
    }

  }

  application_rule_collection {
    name     = "avd_application_rule_collection"
    priority = 532
    action   = "Allow"




    rule {
      name = "Agent traffic"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = [
        data.azurerm_subnet.services.address_prefix
      ]
      destination_fqdns = [
        "gcs.prod.monitoring.core.windows.net"
      ]
    }


    rule {
      name = "Agent and side-by-side (SXS) stack updates"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = [
        data.azurerm_subnet.services.address_prefix
      ]
      destination_fqdns = [
        "mrsglobalsteus2prod.blob.core.windows.net"
      ]
    }

    rule {
      name = "Azure portal support"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = [
        data.azurerm_subnet.services.address_prefix
      ]
      destination_fqdns = [
        "wvdportalstorageblob.blob.core.windows.net"
      ]
    }


    rule {
      name = "Windows activation"
      protocols {
        type = "Http"
        port = 1688
      }
      source_addresses = [
        data.azurerm_subnet.services.address_prefix
      ]
      destination_fqdns = [
        "kms.core.windows.net"
      ]
    }

    rule {
      name = "Azure Windows activation"
      protocols {
        type = "Http"
        port = 1688
      }
      source_addresses = [
        data.azurerm_subnet.services.address_prefix
      ]
      destination_fqdns = [
        "azkms.core.windows.net"
      ]
    }

    rule {
      name = "Certificate CRL OneOCSP"
      protocols {
        type = "Http"
        port = 80
      }
      source_addresses = [
        data.azurerm_subnet.services.address_prefix
      ]
      destination_fqdns = [
        "oneocsp.microsoft.com"
      ]
    }

    rule {
      name = "Certificate CRL MicrosoftDotCom"
      protocols {
        type = "Http"
        port = 80
      }
      source_addresses = [
        data.azurerm_subnet.services.address_prefix
      ]
      destination_fqdns = [
        "www.microsoft.com"
      ]
    }

    rule {
      name = "Entra ID"
      protocols {
        type = "Http"
        port = 80 
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = [
        data.azurerm_subnet.services.address_prefix
      ]
      destination_fqdns     = ["*.auth.microsoft.com", "*.msftidentity.com", "*.msidentity.com", "account.activedirectory.windowsazure.com", "accounts.accesscontrol.windows.net", "adminwebservice.microsoftonline.com", "api.passwordreset.microsoftonline.com", "autologon.microsoftazuread-sso.com", "becws.microsoftonline.com", "ccs.login.microsoftonline.com", "clientconfig.microsoftonline-p.net", "companymanager.microsoftonline.com", "device.login.microsoftonline.com", "graph.microsoft.com", "graph.windows.net", "login-us.microsoftonline.com", "login.microsoft.com", "login.microsoftonline-p.com", "login.microsoftonline.com", "login.windows.net", "logincert.microsoftonline.com", "loginex.microsoftonline.com", "nexus.microsoftonline-p.com", "passwordreset.microsoftonline.com", "provisioningapi.microsoftonline.com", "*.hip.live.com", "*.microsoftonline-p.com", "*.microsoftonline.com", "*.msauth.net", "*.msauthimages.net", "*.msecnd.net", "*.msftauth.net", "*.msftauthimages.net", "*.phonefactor.net", "enterpriseregistration.windows.net", "policykeyservice.dc.ad.msft.net", "pas.windows.net"]
      destination_addresses = ["20.20.32.0/19", "20.190.128.0/18", "20.231.128.0/19", "40.126.0.0/18", "2603:1006:2000::/48", "2603:1007:200::/48", "2603:1016:1400::/48", "2603:1017::/48", "2603:1026:3000::/48", "2603:1027:1::/48", "2603:1036:3000::/48", "2603:1037:1::/48", "2603:1046:2000::/48", "2603:1047:1::/48", "2603:1056:2000::/48", "2603:1057:2::/48"]
    }

    rule {
      name = "Certificate CRL"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = [
        data.azurerm_subnet.services.address_prefix
      ]
      destination_fqdns = ["*.entrust.net", "*.geotrust.com", "*.omniroot.com", "*.public-trust.com", "*.symcb.com", "*.symcd.com", "*.verisign.com", "*.verisign.net", "apps.identrust.com", "cacerts.digicert.com", "cert.int-x3.letsencrypt.org", "crl.globalsign.com", "crl.globalsign.net", "crl.identrust.com", "crl3.digicert.com", "crl4.digicert.com", "isrg.trustid.ocsp.identrust.com", "mscrl.microsoft.com", "ocsp.digicert.com", "ocsp.globalsign.com", "ocsp.msocsp.com", "ocsp2.globalsign.com", "ocspx.digicert.com", "secure.globalsign.com", "www.digicert.com", "www.microsoft.com"]
    }

    rule {
      name = "Authentication to Microsoft Online Services"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = [
        data.azurerm_subnet.services.address_prefix
      ]
      destination_fqdns = [
        "login.microsoftonline.com"
      ]
    }

  }
}
