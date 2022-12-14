
packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

variable "green_ami_prefix" {
  type    = string
  default ="green_ami"
}

variable "blue_ami_prefix" {
  type    = string
  default ="blue_ami"
}



source "amazon-ebs" "ubuntu_blue" {
  ami_name      = "${var.blue_ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "ap-northeast-3"
  vpc_id        = "vpc-078aa8aac8e9cde42"
  #subnet_id     = "subnet-054a52ac215ff7cca"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}
source "amazon-ebs" "ubuntu-focal" {
  ami_name      = "${var.green_ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "ap-northeast-3"
  vpc_id        = "vpc-078aa8aac8e9cde42"
  #subnet_id     = "subnet-0e51decd8a7efceb2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}
 

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu_blue",
    "source.amazon-ebs.ubuntu-focal"
  ]
  provisioner "ansible" {
    playbook_file = "/Users/ashwini.borkar/src/Talent-Academy/Terraform_Labs/ec2-lab/playbooks/playbooks.yml"
  }
}