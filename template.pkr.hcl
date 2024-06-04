packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  my_ami_name   = "jh-golden-image-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  aws_region    = "us-east-2"
  instance_type = "t3.micro"
  ssh_username  = "ec2-user"
  vpc_id        = "vpc-82b6d4e9"
  subnet_id     = "subnet-062dc396d5ae3a671"
}

source "amazon-ebs" "aml3" {
  ami_name      = local.my_ami_name
  instance_type = local.instance_type
  region        = local.aws_region
  source_ami    = "ami-0ca2e925753ca2fb4"
  ssh_pty       = true
  ssh_username  = local.ssh_username
  ssh_interface = "public_ip"

  subnet_filter {
    filter {
      name  = "subnet-id"
      value = local.subnet_id
    }
  }
}

build {
  name = "tfe_workshop_packer_1"
  sources = [
    "source.amazon-ebs.aml3"
  ]

  provisioner "shell" {
    inline = [
      "sudo wget --no-check-certificate --no-proxy 'https://terraformworkshop-jh.s3.ap-northeast-2.amazonaws.com/shell-script/security_script.sh'",
      "sudo chmod 777 security_script.sh",
      "./security_script.sh",
      "sudo rm security_script.sh",
    ]
  }
}

