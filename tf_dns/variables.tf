variable "region" {
  default = "us-west-1"
}

variable "zone_name" {
  default = "mt5225.com"
}

variable "ttl" {
  default = "300"
}

# sub domain records
variable "sub_domains" {
  default = [
    {
      name   = "app11"
      ipaddr = "10.0.10.1"
    },
    {
      name   = "app22"
      ipaddr = "10.0.20.2"
    },
    {
      name   = "app33"
      ipaddr = "10.0.30.3"
    },
  ]
}

#CNAME reocord for each sub domain
variable "cnames" {
  default = ["www1", "api2", "mail3"]
}