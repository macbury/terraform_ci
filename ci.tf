variable "access_key" {}
variable "secret_key" {}
variable "ami_id" {}
variable "ssh_key_private" {}

variable "region" {
  default = "eu-west-1"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_key_pair" "main" {
  key_name   = "ci.main"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_security_group" "main" {
  name        = "ci.test"
  description = "Allow SSH and http access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "ci" {
  vpc = true

  instance = "${aws_instance.ci.id}"
}

output "server-ip" {
  value = "${aws_eip.ci.public_ip}"
}

resource "aws_ebs_volume" "storage" {
  availability_zone = "${aws_instance.ci.availability_zone}"
  type              = "gp2"
  size              = 20
}

resource "aws_volume_attachment" "storage-volume-attachment" {
  device_name = "/dev/sdh"
  instance_id = "${aws_instance.ci.id}"
  volume_id   = "${aws_ebs_volume.storage.id}"
}

resource "aws_instance" "ci" {
  ami = "${var.ami_id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.main.key_name}"
  security_groups = [
    "${aws_security_group.main.name}"
  ]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install python"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.ssh_key_private)}"
    }
  }

  provisioner "local-exec" {
    command = "echo '[aws]\n${self.public_ip} ansible_user=ubuntu' > inventory.ini"
  }
}

output "provision cmd" {
  value = "ansible-playbook -i inventory.ini --private-key ${var.ssh_key_private} provisioning/playbook.yml"
}
