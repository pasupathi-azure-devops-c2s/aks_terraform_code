

resource "azurerm_resource_group" "rg" {
    name="azuredevops_training_022"
    location = "eastus"
  
}

resource "random_pet" "aks_cluster_name" {
    prefix = "aks_cluster_01"
}

resource "random_pet" "aks_cluster_dns" {
    prefix = "dns"
}

resource "azurerm_kubernetes_cluster" "k8s" {
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    name=random_pet.aks_cluster_name.id
    dns_prefix = random_pet.aks_cluster_dns.id

    identity {
      type = "SystemAssigned"
    }

    default_node_pool {
      name ="agentpool"
      vm_size="Standard_D2_v2"
      node_count = var.node_count
    }  
    linux_profile {
      admin_username = "Pasupathikumar"

      ssh_key {
        key_data = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
      }
    }
    network_profile {
      network_plugin = "kubenet"
      load_balancer_sku = "standard"
    }
}