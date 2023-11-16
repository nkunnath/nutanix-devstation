terraform {
  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = "1.7.1"
    }
  }
}

data "nutanix_cluster" "cluster" {
  name = var.cluster_name
}

data "nutanix_subnet" "subnet" {
  subnet_name = var.subnet_name
}




provider "nutanix" {
  username     = var.user
  password     = var.password
  endpoint     = var.endpoint
  insecure     = true
  wait_timeout = 60
}

resource "nutanix_image" "dcos" {
  name        = "Ubuntu image"
  image_type  = "DISK_IMAGE"
  source_uri  = var.source_uri
}


resource "nutanix_virtual_machine" "Ubuntu" {
  name                 = var.vm_name
  cluster_uuid         = data.nutanix_cluster.cluster.id
  num_vcpus_per_socket = "2"
  num_sockets          = "1"
  memory_size_mib      = "4096"
  boot_device_order_list = ["DISK", "CDROM"]

  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = nutanix_image.dcos.id
    }
  }

  disk_list {
    disk_size_bytes = 50 * 1024 * 1024 * 1024
    device_properties {
      device_type = "DISK"
      disk_address = {
        "adapter_type" = "SCSI"
        "device_index" = "1"
      }
    }
  }
  nic_list {
    subnet_uuid = data.nutanix_subnet.subnet.id
  }
   guest_customization_cloud_init_user_data = base64encode(templatefile("${path.module}/ubuntu.tpl", { hostname = var.vm_name }))
}

