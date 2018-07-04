resource "aws_vpc" "met-vpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name              = "met-vpc-${var.met_instance_name}"
    MET_instance_name = "${var.met_instance_name}"
    MET_user_name     = "${var.met_user_name}"
    MET_company_name  = "${var.met_company_name}"
  }
}

resource "aws_subnet" "met-subnet" {
  vpc_id            = "${aws_vpc.met-vpc.id}"
  cidr_block        = "${var.vpc_cidr_block}"
  availability_zone = "${var.availability_zone}"

  tags {
    Name              = "met-subnet-${var.met_instance_name}"
    MET_instance_name = "${var.met_instance_name}"
    MET_user_name     = "${var.met_user_name}"
    MET_company_name  = "${var.met_company_name}"
  }
}

resource "aws_security_group" "met-default-security-group" {
  name        = "MET_default"
  description = "Allow inbound ssh and all outbound traffic"
  vpc_id      = "${aws_vpc.met-vpc.id}"

  tags {
    Name              = "met-default-security-group-${var.met_instance_name}"
    MET_instance_name = "${var.met_instance_name}"
    MET_user_name     = "${var.met_user_name}"
    MET_company_name  = "${var.met_company_name}"
  }
}

resource "aws_security_group" "met-master-security-group" {
  name        = "MET_master"
  description = "Allow inbound traffic to Puppet master required ports"
  vpc_id      = "${aws_vpc.met-vpc.id}"

  tags {
    Name              = "met-master-security-group-${var.met_instance_name}"
    MET_instance_name = "${var.met_instance_name}"
    MET_user_name     = "${var.met_user_name}"
    MET_company_name  = "${var.met_company_name}"
  }
}

resource "aws_security_group_rule" "met-allow-inbound-ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.met-default-security-group.id}"
}

resource "aws_security_group_rule" "met-allow-outbound-all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.met-default-security-group.id}"
}

resource "aws_security_group_rule" "met-allow-inbound-https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.met-master-security-group.id}"
}

resource "aws_security_group_rule" "met-allow-inbound-puppet-server" {
  type              = "ingress"
  from_port         = 8140
  to_port           = 8140
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.met-master-security-group.id}"
}

resource "aws_security_group_rule" "met-allow-inbound-puppet-orchestrator" {
  type              = "ingress"
  from_port         = 8142
  to_port           = 8142
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.met-master-security-group.id}"
}
