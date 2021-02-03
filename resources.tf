# provider "google" {
#   project     = "unilever-poc"
#   region      = "us-central1"
#   credentials = file ("gcp-ulpoc.json")
#   zone = "us-east4-a"
# }
# terraform {
#   backend "gcs" {
#     bucket  = "ul-poc-terraform"
#     prefix  = "terraform/states"
#   }
# }
# resource "aws_instance" "mohi-vm" {
#   ami = "ami-0885b1f6bd170450c"
#   instance_type = "t2.micro"
#   tags = {
#   Name = "Mohi-instance"
#  }
# }

# output "aws_instance1_id" {
#  value = aws_instance.mohi-vm.id
# }
# output "aws_instance_cpu_count" {
#  value =  aws_instance.mohi-vm.cpu_core_count
# }

# resource "google_compute_instance" "linuxvm" {
#   name         = "linux-mohi-vm"
#   machine_type = "f1-micro"
#   zone         = "us-east4-a"
#   labels = {
#     env = "prod",
#     creator = "mohi"
#   }
#   tags = ["env", "terraform"]

#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-9"
#     }
#   }


#   network_interface {
#    subnetwork = "sbnt-ul-poc-01"

#     access_config {
#       // Ephemeral IP
#     }
#   }
# }

resource "google_compute_instance" "windows" {
  name         = "windows-instance-mohi"
  machine_type = "e2-medium"
  zone         = "us-east4-a"

  boot_disk {
    initialize_params {
      image = "gce-uefi-images/windows-2019"
    }
  }

  network_interface {
    subnetwork = "sbnt-ul-poc-01"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    serial-port-logging-enable = "TRUE"
    // Derived from https://cloud.google.com/compute/docs/instances/windows/automate-pw-generation
    windows-keys = jsonencode(
      {
        email    = "hajamohideenm@hcl.com"
        expireOn = "2020-04-14T01:37:19Z"
        exponent = "AQAB"
        modulus  = "wgsquN4IBNPqIUnu+h/5Za1kujb2YRhX1vCQVQAkBwnWigcCqOBVfRa5JoZfx6KIvEXjWqa77jPvlsxM4WPqnDIM2qiK36up3SKkYwFjff6F2ni/ry8vrwXCX3sGZ1hbIHlK0O012HpA3ISeEswVZmX2X67naOvJXfY5v0hGPWqCADao+xVxrmxsZD4IWnKl1UaZzI5lhAzr8fw6utHwx1EZ/MSgsEki6tujcZfN+GUDRnmJGQSnPTXmsf7Q4DKreTZk49cuyB3prV91S0x3DYjCUpSXrkVy1Ha5XicGD/q+ystuFsJnrrhbNXJbpSjM6sjo/aduAkZJl4FmOt0R7Q=="
        userName = "mohideen"
      }
    )
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

data "google_compute_instance_serial_port" "serial" {
  instance = google_compute_instance.windows.name
  zone     = google_compute_instance.windows.zone
  port     = 4
}

output "serial_out" {
  value = data.google_compute_instance_serial_port.serial.contents
}

# output "linuxvm" {
#   value = google_compute_instance.linuxvm.network_interface[0].access_config
# }

