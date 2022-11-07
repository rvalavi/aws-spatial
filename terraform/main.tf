terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "..."
    key    = "terraform-state"
    region = "ap-southeast-2"
  }
}


# configure the AWS Provider
# region code for Sydney Australia
provider "aws" {
  region = var.region
  # profile = var.profile
  # shared_credentials_file = "~/.aws/credentials"
}


# add a Ubuntu 20.4 instance on a EC2
resource "aws_instance" "webserver" {
  ami               = "ami-0567f647e75c7bc05"
  instance_type     = "t2.medium" # maybe change to t4.medium?
  availability_zone = var.zone
  key_name          = var.ssh_key

  # setup the EBS volume
  root_block_device {
    delete_on_termination = true # if false the hard drive wont be deleted, but it cost unattached
    volume_size = 30
  }

  # depend of the docker images to be built first
  depends_on = [null_resource.local_geoshiny_build]

  # assign the plicies to this ec2
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  # connect instance to a defined network
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.net_interface.id
  }

  # server configuration with ansible
  # check if ssh to server works then continue (i.e. server is ready)
  provisioner "remote-exec" {
    inline = ["echo 'SSH connection is now ready!'"]

    connection {
      type        = "ssh"
      user        = var.remote_user
      private_key = file(var.ssh_key_path)
      host        = var.static_ip
    }
  }

  # remove the old ssh key from known-hosts to make ansible work
  provisioner "local-exec" {
    command = "ssh-keygen -f '/home/rvalavi/.ssh/known_hosts' -R ${var.static_ip}"
    on_failure = continue
  }

  # run ansible palybook to configure the server
  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.static_ip}, --private-key ${var.ssh_key_path} ../ansible/server-config.yml"
  }

  tags = {
    Name = "my server"
  }
}

