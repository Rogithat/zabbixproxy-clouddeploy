resource "google_compute_instance" "default" {
  project      = "fluted-gantry-291716"
  name         = "test-packer"
  machine_type = "e2-small"
  zone         = "us-east1-b"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "zabbix-proxy-97834234289342897"
    }
  }

  // Local SSD disk
 # scratch_disk {
   # interface = "SCSI"
 # }

  network_interface {
    network = "default"

   # access_config {
      // Ephemeral IP
   # }
  }

  metadata = {
    foo = "bar"
  }

  #metadata_startup_script = "echo hi > /test.txt"

 # service_account {
#  #  scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  #}
}