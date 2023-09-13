resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name       = "vpc-smruti"
    Created_By = "smruti-upgrad"
  }
}

resource "aws_subnet" "public_subnet" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.${1 + count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name       = "public-subnet-smruti-${1 + count.index}"
    Created_By = "smruti-upgrad"
    "kubernetes.io/cluster/my-eks-201" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.${5 + count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name       = "private-subnet-smruti-${1 + count.index}"
    Created_By = "smruti-upgrad"
    "kubernetes.io/cluster/my-eks-201" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet.0.id

  tags = {
    Name       = "nat-gw-smruti"
    Created_By = "smruti-upgrad"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name       = "igw-smruti"
    Created_By = "smruti-upgrad"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name       = "public-rt-smruti"
    Created_By = "smruti-upgrad"
  }
}

resource "aws_route_table_association" "public_rta" {
  count          = 2
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name       = "private-rt-smruti"
    Created_By = "smruti-upgrad"
  }
}

resource "aws_route_table_association" "private_rta" {
  count          = 2
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}