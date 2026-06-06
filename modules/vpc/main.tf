resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc"
  }
  
}


# =============== public subnets     ===============
data "aws_availability_zones" "azs" {
  state = "available"
}


resource "aws_subnet" "public_subnet_1" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = cidrsubnet(var.cidr_block, 8, 0)
    availability_zone = data.aws_availability_zones.azs.names[0]

    tags = {
        Name = "${var.name}-public-subnet-1"
    }
}

# =============== private subnets   application layer  ===============
resource "aws_subnet" "private_app_subnet_1" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = cidrsubnet(var.cidr_block, 4, 5)
    availability_zone = data.aws_availability_zones.azs.names[0]

    tags = {
        Name = "${var.name}-private-app-subnet-1"
    }
}


# =============== private subnets   database layer  ===============

resource "aws_subnet" "private_db_subnet_1" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = cidrsubnet(var.cidr_block, 4, 2)
    availability_zone = data.aws_availability_zones.azs.names[0]

    tags = {
        Name = "${var.name}-private-db-subnet-1"
    }
}

resource "aws_subnet" "private_db_subnet_2" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = cidrsubnet(var.cidr_block, 4, 3)
    availability_zone = data.aws_availability_zones.azs.names[1]

    tags = {
        Name = "${var.name}-private-db-subnet-2"
    }
}



# =============== DB subnet group for RDS instance  ===============

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = [aws_subnet.private_db_subnet_1.id, aws_subnet.private_db_subnet_2.id] # 

  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}

# =============== internet gateway  ===============
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-igw"
  }
}


# =============== Public route table     ===============

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

    tags = {
        Name = "${var.name}-public-rt"
    }
}


# =============== route table associations     ===============

resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}



# =============== private route tables       ===============
resource "aws_route_table" "private_app_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-private-app-rt"
  }
}

resource "aws_route_table" "private_db_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-private-db-rt"
  }
}

resource "aws_route_table" "private_db_rt_2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-private-db-rt_2"
  }
  
}

resource "aws_route_table_association" "private_app_subnet_1_assoc" {
  subnet_id      = aws_subnet.private_app_subnet_1.id
  route_table_id = aws_route_table.private_app_rt.id
}



resource "aws_route_table_association" "private_db_subnet_1_assoc" {
  subnet_id      = aws_subnet.private_db_subnet_1.id
  route_table_id = aws_route_table.private_db_rt.id
}

resource "aws_route_table_association" "private_db_subnet_2_assoc" {
  subnet_id      = aws_subnet.private_db_subnet_2.id
  route_table_id = aws_route_table.private_db_rt_2.id
}

