data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "key_policy" {
    statement {
      sid = "TrustAccountRootForIAM"
      effect = "Allow"
      principals {
        type = "AWS"
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      }
      actions = ["kms:*"]
      resources = ["*"]
    }
}

resource "aws_kms_key" "this" {
    description = "ClinicFlow ${var.env_name} environment key"
    deletion_window_in_days = var.deletion_window_in_days
    enable_key_rotation = true
    policy = data.aws_iam_policy_document.key_policy.json
}

resource "aws_kms_alias" "this" {
    name = "alias/clinicflow-${var.env_name}"
    target_key_id = aws_kms_key.this.key_id
}