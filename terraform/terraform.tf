variable "do_token" {}
variable "ssh_fingerprint" {}

provider "digitalocean" {
  token = var.do_token
}


// Create droplet
resource "digitalocean_droplet" "clara" {
    name = "clara"
    image = "ubuntu-20-04-x64"
    region = "sgp1"
    size = "s-1vcpu-1gb"
    ssh_keys = [var.ssh_fingerprint]
}


// Configure Domain
resource "digitalocean_domain" "clara-domain" {
  name = "clara-app.tech"
  ip_address = digitalocean_droplet.clara.ipv4_address
}


// Add records for www and api
resource "digitalocean_record" "www" {
    domain = digitalocean_domain.clara-domain.name
    type = "A"
    name = "www"
    value = digitalocean_domain.clara-domain.ip_address
}

resource "digitalocean_record" "api" {
    domain = digitalocean_domain.clara-domain.name
    type = "A"
    name = "api"
    value = digitalocean_domain.clara-domain.ip_address
}


// Configure firewall
resource "digitalocean_firewall" "clara-firewall" {
  name = "clara-firewall"
  droplet_ids = [digitalocean_droplet.clara.id]

  inbound_rule {
    protocol = "tcp"
    port_range = "22"
    source_addresses = ["0.0.0.0/0"]
  }

  inbound_rule {
    protocol = "tcp"
    port_range = "80"
    source_addresses = ["0.0.0.0/0"]
  }

  inbound_rule {
    protocol = "tcp"
    port_range = "443"
    source_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0"]
  }
}


# Create Ansible inventory file
resource "null_resource" "ansible-provision" {
  depends_on = [digitalocean_droplet.clara]

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.clara.name} ansible_host=${digitalocean_droplet.clara.ipv4_address} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3' > ../ansible/inventory"
  }
}


// Display output after droplet created
output "ip" {
  value = digitalocean_droplet.clara.ipv4_address
}
