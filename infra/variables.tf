variable "use_spot" {
  type    = bool
  default = false #if use spot instances make true from command: terraform apply -var use_spot=true
}
