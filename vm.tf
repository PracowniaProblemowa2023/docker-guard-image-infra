resource "azurerm_public_ip" "vm_pip" {
  for_each            = var.vms

  name                = "vm-pip-${each.value.name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "vm_nic" {
  for_each            = var.vms

  name                = "vm-nic-${each.value.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each            = var.vms 

  name                = "vm-${each.value.name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = each.value.size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.vm_nic[each.key].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("${path.module}/ssh_keys/id_rsa.pub")
  }

  custom_data = base64encode(file("${path.module}/customdata.sh"))

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "null_resource" "upload_cert" {
  connection {
    type = "ssh"
    user = "adminuser"
    host = azurerm_public_ip.vm_pip["docker_guard"].ip_address
    private_key = file("/Users/michalczarnik/.ssh/id_rsa")
  }
  provisioner "file" {
    source = "./files/cert.pem"
    destination = "/home/adminuser/cert.pem"
  }
  lifecycle {
    replace_triggered_by = [ azurerm_linux_virtual_machine.vm ]
  }
  depends_on = [ azurerm_linux_virtual_machine.vm ]
}

resource "null_resource" "upload_key" {
  connection {
    type = "ssh"
    user = "adminuser"
    host = azurerm_public_ip.vm_pip["docker_guard"].ip_address
    private_key = file("/Users/michalczarnik/.ssh/id_rsa")
  }
  provisioner "file" {
    source = "./files/key.pem"
    destination = "/home/adminuser/key.pem"
  }
  lifecycle {
    replace_triggered_by = [ azurerm_linux_virtual_machine.vm ]
  }
  depends_on = [ azurerm_linux_virtual_machine.vm ]
}

resource "null_resource" "upload_docker_compose" {
  connection {
    type = "ssh"
    user = "adminuser"
    host = azurerm_public_ip.vm_pip["docker_guard"].ip_address
    private_key = file("/Users/michalczarnik/.ssh/id_rsa")
  }
  provisioner "file" {
    source = "./files/docker-compose.yml"
    destination = "/home/adminuser/docker-compose.yml"
  }
  lifecycle {
    replace_triggered_by = [ azurerm_linux_virtual_machine.vm ]
  }
  depends_on = [ azurerm_linux_virtual_machine.vm ]
}