provider "google" {
  project     = "unilever-poc"
  region      = "us-central1"
  zone = "us-east4-a"
}
terraform {
  backend "gcs" {
    bucket  = "ul-poc-terraform"
    prefix  = "terraform/states"
  }
}

# output "aws_instance1_id" {
#  value = aws_instance.mohi-vm.id
# }
# output "aws_instance_cpu_count" {
#  value =  aws_instance.mohi-vm.cpu_core_count
# }

resource "google_compute_instance" "mohivm" {
  name         = "mohi-vm-demo"
  machine_type = "f1-micro"
  zone         = "us-east4-a"
  metadata_startup_script = <<-EOT
    sudo apt-get update
    sudo apt-get remove docker docker-engine docker.io containerd runc -y
    sudo apt-get install \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg-agent \
      software-properties-common -y
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    sudo add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/debian \
      $(lsb_release -cs) \
      stable"
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io -y
    sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
  EOT
  labels = {
    env = "prod",
    creator = "mohi"
    capability = "terraform"
  }
  tags = ["env", "terraform"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  network_interface {
   subnetwork = "sbnt-ul-poc-01"

    access_config {
      // Ephemeral IP
    }
  }
}

output "output_vm" {
  value = google_compute_instance.mohivm.network_interface[0].access_config
}

