locals {
  profiles = var.profiles != "" ? var.profiles : "${path.module}/profiles.yaml"
  acquis   = var.acquis != "" ? var.acquis : "${path.module}/acquis.yaml"
  config   = var.config != "" ? var.config : "${path.module}/config.yaml"

}