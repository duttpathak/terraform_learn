# variable "server_port" {
#   description = "The port the server will use for HTTP requests"
#   type        = number
# }


variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}


variable "server_port_in" {
  description = "The port for incoming HTTP requests"
  type        = number
  default     = 22
}


variable "server_port_out" {
  description = "The port for outgoing HTTP requests"
  type        = number
  default     = 65535
}