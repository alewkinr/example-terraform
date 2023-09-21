# Note: the password of the var.pgadmin_user
# are stored in the environment variable PGPASSWORD that you must setted before the terraform plan or apply.

variable "dbhost" {
  description = "The hostname of the database server"
}

variable "dbport" {
  description = "The port of the database server"
}

variable "dbroot_user" {
  description = "The root user of the database server"
}

variable "sslmode" {
  description = "The sslmode of the database server"
}

variable "ssl_cert" {
  description = "Path to the client certificate of the database server"
}
variable "ssl_key" {
  description = "Path to the client certificate key of the database server"
}

variable "superuser" {
  description = "The superuser of the database server"
  default     = true
}

variable "db_names" {
  description = "The users of the database server to be created"
  type        = list(string)
  default = [
    "db1", "db2"
  ]
}
