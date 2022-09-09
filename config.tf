terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "2.20.2"
    }
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.77.0"
    }
  }
}

variable "yc_token" {
  type        = string
}  
variable "yc_cloud_id" {
  type        = string
}  
variable "yc_folder_id" {
  type        = string
}  

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id 
  zone      = "ru-central1-b"
}

resource "yandex_compute_instance" "build" {
  name        = "t-build"
  hostname    = "t-build"
  platform_id = "standard-v1"
  zone        = "ru-central1-b"
  scheduling_policy {
    preemptible = true
  }
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 4
    core_fraction = 20  
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kdq6d0p8sij7h5qe3"
      size = "10"
    }
  }
network_interface {
    subnet_id = "e2lbocl9ri9asmv0hq7i"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
# provisioner "remote-exec" {
#     inline = [
#       "sudo apt-get update -y && sudo apt-get install -y maven git && sudo apt-get install -y s3fs",
#       "sudo echo YCAJECaxhWcm6rHMYeehDO2kH:YCPxhl-X6BvNYbA6cSF5Wpr8TlRHxBhkV6lhHz5S > ~/.passwd-s3fs && sudo chmod 600  ~/.passwd-s3fs",
#       "sudo mkdir /mnt/ycb",
#       "sudo s3fs a1dc8aa6f31a45f83 /mnt/ycb -o passwd_file=$HOME/.passwd-s3fs -o url=http://storage.yandexcloud.net -o use_path_request_style",
#       "sudo git clone https://github.com/tovmayor/myboxfuse.git",
#       "sudo mvn -f ./myboxfuse package", 
#       "sudo cp /home/ubuntu/myboxfuse/target/hello-1.0.war /mnt/ycb/"
#     ]
#     connection {
#       type = "ssh"
#       user = "ubuntu"
#       private_key = file("~/.ssh/id_rsa")
#       host = self.network_interface[0].nat_ip_address
#     }
#   }
}
output "build_ip" {
  value = yandex_compute_instance.build.network_interface[0].nat_ip_address
}


#echo -e "[build]\n"$(terraform output -raw build_ip)" ansible_user=ubuntu\n"

