provider "azurerm" {
  features {
    
  }
}

resource "azurerm_resource_group" "rg1" {
    name = "training_session_01"
    location = "eastus"
  
}

resource "azurerm_virtual_network" "vm1" {
  name = "windowsvnet01"
  location = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  address_space = ["10.0.0.0/16"]

}

resource "azurerm_subnet" "subnet1" {
  name = "virtualsubnet01"
  resource_group_name = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vm1.name
  address_prefixes = [ "10.0.0.0/24" ]
  
}

resource "azurerm_public_ip" "public_ip_address_01" {
  name = "windowsip01"
  resource_group_name = azurerm_resource_group.rg1.name
  location = azurerm_resource_group.rg1.location
  allocation_method = "Dynamic"
  
}

resource "azurerm_network_security_group" "nsg1" {
  name = "nsg1"
  resource_group_name = azurerm_resource_group.rg1.name
  location = azurerm_resource_group.rg1.location
  
}

resource "azurerm_network_interface" "network_interface_01" {
  name = "interface_01"
  location = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip_address_01.id
  }
  
}

resource "azurerm_windows_virtual_machine" "windowsvm01" {
  name = "samplewvm01"
  resource_group_name = azurerm_resource_group.rg1.name
  location = azurerm_resource_group.rg1.location
  size = "Standard_F2"
  admin_username = "Pasupathikumar"
  admin_password =  "pasupathikumar@819"

  network_interface_ids = [ 
    azurerm_network_interface.network_interface_01.id,
   ]

   os_disk {
     caching = "ReadWrite"
     storage_account_type = "Standard_LRS"
   }

   source_image_reference {
     publisher = "MicrosoftWindowsServer"
     offer = "WindowsServer"
     sku = "2016-Datacenter"
     version = "latest"
   }
}
/*
resource "azurerm_role_assignment" "role1" {
  scope = "/subscriptions/7275205d-c6ea-4e18-b0a9-4d92e37ae210/resourceGroups/${azurerm_resource_group.rg1.name}/providers/Microsoft.Compute/virtualMachines/${azurerm_windows_virtual_machine.windowsvm01.name}"
  role_definition_id = data.azurerm_role_definition.role_name.id
  principal_id = "679bf607-d0e5-4ed2-8d84-6d2092e6d944"
}

data "azurerm_role_definition" "role_name" {
  name = "Reader"
}*/

resource "azurerm_dev_test_lab" "dev_test_lab_01" {
  name = "linux_vm_test_01"
  resource_group_name = azurerm_resource_group.rg1.name
  location = azurerm_resource_group.rg1.location

  
}

resource "azurerm_dev_test_virtual_network" "test_vn_01" {
  name = "linux_vn01"
  resource_group_name = azurerm_resource_group.rg1.name
  lab_name = azurerm_dev_test_lab.dev_test_lab_01.name

  subnet {
    use_public_ip_address = "Allow"
    use_in_virtual_machine_creation = "Allow"
  }
}

resource "azurerm_dev_test_linux_virtual_machine" "test_vm_01" {
  name = "linuxtestlab01"
  lab_name = azurerm_dev_test_lab.dev_test_lab_01.name
  resource_group_name = azurerm_resource_group.rg1.name
  location = azurerm_resource_group.rg1.location
  size = "Standard_DS2"
  username = "Pasupathikumar"
  password = "Pasupathikumar@819"
  lab_virtual_network_id = azurerm_dev_test_virtual_network.test_vn_01.id
  lab_subnet_name = azurerm_dev_test_virtual_network.test_vn_01.subnet[0].name
  storage_type = "Premium"

 
  allow_claim = true
  #ssh_key = file("~/.ssh/id_rsa.pub")

  gallery_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
}
}

resource "azurerm_storage_account" "sa01" {
  name = "containera01"
  resource_group_name = azurerm_resource_group.rg1.name
  location = azurerm_resource_group.rg1.location
  account_tier = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
}

resource "azurerm_app_service_plan" "app_service_plan_01" {
  name = "app_service_plan_01"
  resource_group_name = azurerm_resource_group.rg1.name
  location = azurerm_resource_group.rg1.location
  kind = "Linux"
  reserved = true

  sku {
    tier = "Basic"
    size = "B1"
  }
  
}

resource "azurerm_app_service" "web_app_01" {
  name = "python01"
  resource_group_name = azurerm_resource_group.rg1.name
  location = azurerm_resource_group.rg1.location
  app_service_plan_id = azurerm_app_service_plan.app_service_plan_01.id
  site_config {
    linux_fx_version = "PYTHON|3.10"
  }

  
}