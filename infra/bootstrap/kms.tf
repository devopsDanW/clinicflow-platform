data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "shared_key_policy" {
  statement {
    sid    = "TrustAccountRootForIAM"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_kms_key" "shared" {
  description             = "ClinicFlow shared key for ECR and Terraform state"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.shared_key_policy.json
}

resource "aws_kms_alias" "shared" {
  name          = "alias/clinicflow-shared"
  target_key_id = aws_kms_key.shared.key_id
}