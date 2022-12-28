resource "aws_kms_key" "this" {
    description = var.description
    deletion_window_in_days = var.deletion_window_in_days
}

resource "aws_kms_alias" "this" {
  name = var.name
  target_key_id = aws_kms_key.this.key_id
}