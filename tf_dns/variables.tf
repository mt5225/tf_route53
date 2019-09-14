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
      name   = "app1"
      ipaddr = "10.0.0.1"
    },
    {
      name   = "app2"
      ipaddr = "10.0.0.2"
    },
    {
      name   = "app3"
      ipaddr = "10.0.0.3"
    },
  ]
}

#CNAME reocord for each sub domain
variable "cnames" {
  default = ["www", "api", "mail"]
}