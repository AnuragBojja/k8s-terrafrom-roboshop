resource "aws_vpc_peering_connection" "roboshop-to-default" {
  vpc_id        = local.roboshop_vpc_id
  peer_vpc_id   = local.default_vpc_id
  auto_accept   = true

  tags = {
    Name = "roboshop-to-default"
  }
}

resource "aws_route" "requester_to_accepter" {
  route_table_id            = local.roboshop_vpc_rt_id
  destination_cidr_block    = local.default_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.roboshop-to-default.id
}

resource "aws_route" "accepter_to_requester" {
  route_table_id            = local.default_vpc_rt_id
  destination_cidr_block    = local.roboshop_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.roboshop-to-default.id
}

