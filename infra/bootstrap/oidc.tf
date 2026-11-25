data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

locals {
  github_repo = "devopsDanW/clinicflow-platform"
}

data "aws_iam_policy_document" "deploy_trust" {
  for_each = toset(["dev", "staging", "prod"])

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.github_repo}:environment:${each.key}"]
    }
  }
}

resource "aws_iam_role" "deploy" {
  for_each           = toset(["dev", "staging", "prod"])
  name               = "clinicflow-${each.key}-deploy"
  assume_role_policy = data.aws_iam_policy_document.deploy_trust[each.key].json
}

data "aws_iam_policy_document" "plan_readonly_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.github_repo}:pull_request"]
    }
  }
}

resource "aws_iam_role" "plan_readonly" {
  name               = "clinicflow-plan-readonly"
  assume_role_policy = data.aws_iam_policy_document.plan_readonly_trust.json
}