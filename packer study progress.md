# hcp terraform 과제_2405

# packer

### packer 설치

### 설치 환경

|  |  |
| --- | --- |
| OS | Amazon Linux 2023 |
| Instance Type | t3.micro |
| packer version | 1.10.3 |
| Base Image | Amazon Linux 2 |

※  AML2023은 User-data 미지원으로 인해 AML2 사용

```
$ sudo yum install -y yum-utils
$ sudo yum-config-manager --add-repo <https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo>
$ sudo yum -y install packer

```

### packer 템플릿 작성

```
<template.pck.hcl>

packer {
  required_plugins {
    amazon = {
      version   = ">= 1.2.8"
      source    = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  my_ami_name   = "jh-golden-image${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  aws_region    = "us-east-2"
  instance_type = "t3.micro"
  ssh_username  = "ec2-user"
  vpc_id        = "vpc-82b6d4e9"
  subnet_id     = "subnet-062dc396d5ae3a671"
}

data "amazon-ami" "amazon-linux-2" {
  region = "us-east-2"
  filters = {
    name                = "aws/service/ami-amazon-linux-latest/amzn2-ami*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["137112412989"]
}

source "amazon-ebs" "aml2" {
  ami_name      = local.my_ami_name
  instance_type = local.instance_type
  region        = local.aws_region
  #source_ami    = "ami-0c9921088121ad00b"
  source_ami    = data.amazon-ami.amazon-linux-2.id
  ssh_pty       = true
  ssh_username  = local.ssh_username
  ssh_interface = "public_ip"

  subnet_filter {
    filter {
      name = "subnet-id"
      value = local.subnet_id
    }
  }
}

build {
  name    = "tfe_workshop_packer_1"
  sources = [
    "source.amazon-ebs.aml3"
  ]

  provisioner "shell" {
    inline = [
      "sudo yum install -y wget",
	  "sudo wget --no-check-certificate --no-proxy '<https://terraformworkshop-jh.s3.ap-northeast-2.amazonaws.com/shell-script/security_script.sh>'",
	  "sudo chmod 777 security_script.sh",
	  "./security_script.sh",
      "sudo rm security_script.sh"
    ]
  }
}

```

> packer 템플릿 코드 : https://github.com/bananawooyu/hashicorp-packer
> 

---

### 보안 스크립트

```
<security_script.sh>

sudo yum update -y
sudo yum install -y aws-cli
sudo sed -i 's/^PASS_MAX_DAYS\\\\s\\\\+[0-9]\\\\+/PASS_MAX_DAYS   90/g' /etc/login.defs
sudo sed -i 's/^PASS_MIN_LEN\\\\s\\\\+[0-9]\\\\+/PASS_MIN_LEN   8/g' /etc/login.defs
sudo sed -i 's/#\\\\s\\\\+minlen\\\\s\\\\+=\\\\s\\\\+[0-9]\\\\+/minlen = 8/g' /etc/security/pwquality.conf
sudo chmod 4750 /bin/su
sudo chown root:wheel /bin/su
sudo sh -c 'echo \\"\\" > /etc/motd'
sudo sed -i 's/^#Banner\\\\s\\\\+none/Banner none/g' /etc/ssh/sshd_config
sudo service sshd restart

sleep 5

echo "###################################"

echo "###  compelete Security Script  ###"

echo "###################################"

echo "### Result of Security Script" > result.txt

```

![Untitled](hcp%20terraform%20%E1%84%80%E1%85%AA%E1%84%8C%E1%85%A6_2405%202028a33bd760404a8cd8858286826298/Untitled.jpeg)

![Untitled](hcp%20terraform%20%E1%84%80%E1%85%AA%E1%84%8C%E1%85%A6_2405%202028a33bd760404a8cd8858286826298/Untitled.png)