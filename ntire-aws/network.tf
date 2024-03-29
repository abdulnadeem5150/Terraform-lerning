resource "aws_vpc" "primary_network" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "ntier"
  }
}

resource "aws_subnet" "subnets" {
  count      = length(var.subnet_names)
  vpc_id     = aws_vpc.primary_network.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  tags = {
    Name = var.subnet_names[count.index]
  }
}
module "web_security_group" {
  source = "./modules/my_security_group"
  security_group_info = {
    name        = "web"
    description = "this is web security group"
    vpc_id      = aws_vpc.primary_network.id
    rules = [{
      from_port   = "22"
      to_port     = "22"
      type        = local.ingress
      protocol    = local.tcp
      cidr_blocks = [local.anyware]
      },
      {
        from_port   = "80"
        to_port     = "80"
        type        = local.ingress
        protocol    = local.tcp
        cidr_blocks = [local.anyware]
      },
      {
        from_port   = "443"
        to_port     = "443"
        type        = local.ingress
        protocol    = local.tcp
        cidr_blocks = [local.anyware]
      }
    ]
  }

  depends_on = [aws_vpc.primary_network, aws_subnet.subnets]

}

module "business_security_group" {
  source = "./modules/my_security_group"
  security_group_info = {
    name        = "business"
    description = "this is business security group"
    vpc_id      = aws_vpc.primary_network.id
    rules = [{
      from_port   = "0"
      to_port     = "65535"
      type        = local.ingress
      protocol    = local.tcp
      cidr_blocks = [var.vpc_cidr]
    

    }]
  }
}

module "data_security_group" {
  source = "./modules/my_security_group"
  security_group_info = {
    name        = "data"
    description = "this is data security group"
    vpc_id      = aws_vpc.primary_network.id
    rules = [{
      from_port   = "0"
      to_port     = "65535"
      type        = local.ingress
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
      type        = "ingress"
    }]
  }
}