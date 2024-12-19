variable "cidr" {
    default = "10.0.0.0/16"
}


variable "sub1_cidr" {
    description = "CIDR Blocks for demo-sub1 "
  
}

variable "sub2_cidr" {
    description = "CIDR Blocks for demo-sub1 "
  
}


variable "availabality_zone1" {
    description = "Avaliabality Zones"
}

variable "availabality_zone2" {
    description = "Avaliabality Zones 2 "
}

variable "cidr_route_table" {
    description = "Route table vale of cidr "
  
}