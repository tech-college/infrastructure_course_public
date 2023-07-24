# Customer Mater Key
resource "aws_kms_key" "example" {
  description             = "Customer Master Key"
  enable_key_rotation     = true
  is_enabled              = true
  deletion_window_in_days = 30
}

# Alias
resource "aws_kms_alias" "example" {
  name          = "alias/YOUR-KEY-NAME"
  target_key_id = aws_kms_key.example.key_id
}
