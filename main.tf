provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "myRG" {
  name     = "myRG-resources"
  location = "West Europe"
}

resource "azurerm_availability_set" "myRG" {
  name                = "myRG-aset"
  location            = azurerm_resource_group.myRG.location
  resource_group_name = azurerm_resource_group.myRG.name

  tags = {
    environment = "Stage"
  }
}

resource "azurerm_virtual_network" "myRG" {
  name                = "myRG-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myRG.location
  resource_group_name = azurerm_resource_group.myRG.name
}

resource "azurerm_subnet" "myRG" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.myRG.name
  virtual_network_name = azurerm_virtual_network.myRG.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "myRG" {
  name                = "myRG-nic"
  location            = azurerm_resource_group.myRG.location
  resource_group_name = azurerm_resource_group.myRG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.myRG.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "myRG" {
  name                = "myRG-machine"
  resource_group_name = azurerm_resource_group.myRG.name
  location            = azurerm_resource_group.myRG.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.myRG.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}