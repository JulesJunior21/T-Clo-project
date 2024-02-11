# Nous  devons ajouter le provider que nous allons utiliser
terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "2.46.0"
    }
  }
}

# Initialiser le provider
provider "azurerm" {
  features {}

  client_id         = "f946b43c-8f8b-4d31-befb-8c856b3d8a1d"
  client_secret     = "ExG8Q~NjJUtlRvjNwrnKt9D5Q2Jy7SfIPNowobMF"
  tenant_id         = "901cb4ca-b862-4029-9306-e5cd0f6d9f86"
  subscription_id   = "7cd79c70-2a30-40ff-b7d1-db3737a5fe68"
  }

# Création d'un groupe de ressources
resource "azurerm_resource_group" "example" {
  name     = "example-resource-group"
  location = "West Europe"
}

# Création d'un réseau virtuel
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Création d'un sous-réseau
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Création d'une interface réseau
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "example-ip-config"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Création d'une machine virtuelle
resource "azurerm_virtual_machine" "example" {
  name                  = "example-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "example-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "example-vm"
    admin_username = "azureuser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
