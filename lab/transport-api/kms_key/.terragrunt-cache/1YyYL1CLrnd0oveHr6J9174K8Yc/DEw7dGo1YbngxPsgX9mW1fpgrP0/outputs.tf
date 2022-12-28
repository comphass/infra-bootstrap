output "alias" {
  value = var.name
}

output "id" {
  value = concat(aws_kms_key.this.*.id, [""])[0]
}