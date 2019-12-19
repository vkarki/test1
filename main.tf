resource "azurerm_resource_group" "rg" {
    name = "bookRg"
    location = "West Europe"
}

resource "azurerm_virtual_network" "vnet" {
   name = "book-vnet"
   location = "West Europe"
   address_space = ["10.0.0.0/16"]
   resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
   name = "book-subnet"
   virtual_network_name = azurerm_virtual_network.vnet.name
   resource_group_name = azurerm_resource_group.rg.name
   address_prefix = "10.0.10.0/24"
}

resource "azurerm_network_interface" "nic" {
     name = "book-nic"
     location = "West Europe"
     resource_group_name = azurerm_resource_group.rg.name

     ip_configuration {
         name = "bookipconfig"
         subnet_id = azurerm_subnet.subnet.id
         private_ip_address_allocation = "Dynamic"
         public_ip_address_id = azurerm_public_ip.pip.id
    }
}

resource "azurerm_public_ip" "pip" {
  name = "testterraipvishbng"
  location = "West Europe"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method = "Dynamic"
}

resource "azurerm_storage_account" "stor" {
  name = "testterrastor"
  location = "West Europe"
  resource_group_name = azurerm_resource_group.rg.name
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_machine" "vm" {
  name = "testterravm"
  location = "West Europe"
  resource_group_name = azurerm_resource_group.rg.name
  vm_size = "Standard_DS1_v2"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]

 storage_image_reference {
     publisher = "Canonical"
     offer = "UbuntuServer"
     sku = "16.04-LTS"
     version = "latest"
 }
storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}
