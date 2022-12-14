terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.77.0"
    }
  }
}

provider "yandex" {
  token     = "y0_AgAAAAAKYyQGAATuwQAAAADNneRzsw53q7T1Q2qTJPmxqfz87uq9uBk"
  cloud_id  = "b1g2mjplbcl08o830ovt"
  folder_id = "b1gqgtdu7assr55vqtf2"
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
    cores  = 2
    memory = 2
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
    ssh-keys = "ubuntu:${file("/var/lib/jenkins/.ssh/id_rsa.pub")}"
  }

  provisioner "remote-exec" { #wait for startup
    inline = [
      "echo 'Ready to connect!'"
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("/var/lib/jenkins/.ssh/id_rsa")
      host = self.network_interface[0].nat_ip_address
    }
  } 
}  
resource "yandex_compute_instance" "prod" {
  name        = "t-prod"
  hostname    = "t-prod"
  platform_id = "standard-v1"
  zone        = "ru-central1-b"
  scheduling_policy {
    preemptible = true
  }
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
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
    ssh-keys = "ubuntu:${file("/var/lib/jenkins/.ssh/id_rsa.pub")}"
  }

  provisioner "remote-exec" { #wait for startup
    inline = [
      "echo 'Ready to connect!'"
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("/var/lib/jenkins/.ssh/id_rsa")
      host = self.network_interface[0].nat_ip_address
    }
  } 
}  

output "build_ip" {
  value = yandex_compute_instance.build.network_interface[0].nat_ip_address
}
output "prod_ip" {
  value = yandex_compute_instance.prod.network_interface[0].nat_ip_address
}

