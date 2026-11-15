# GitHub Actions gets short-lived AWS credentials through OIDC. No access key is stored anywhere.

# GitHub IDs never change, even if a name is renamed or reused by someone else.
# Get them with:
#   gh api users/nsatge1 --jq .id
#   gh api repos/nsatge1/aws-guardrails-lab --jq .id
locals {
  github_owner    = "nsatge1"
  github_owner_id = "147401996" # check it with the first command above
  github_repo     = "aws-guardrails-lab"
  github_repo_id  = "1457758852"

  # Repositories created after 15 July 2026 put these IDs in the OIDC "sub" claim:
  # repo:OWNER@OWNER_ID/REPO@REPO_ID:<context>
  github_sub_prefix = "repo:${local.github_owner}@${local.github_owner_id}/${local.github_repo}@${local.github_repo_id}"
}

# 1. AWS trusts the tokens that GitHub Actions signs.
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # No thumbprint: for GitHub, AWS checks the certificate with its own list of trusted authorities.
}

# 2. Who can use the plan role: only this repository, only for pull requests and the main branch.
data "aws_iam_policy_document" "github_plan_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    # The token must be made for AWS STS.
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Exact match, no wildcard (*): no other repository and no other branch can use this role.
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "${local.github_sub_prefix}:pull_request",
        "${local.github_sub_prefix}:ref:refs/heads/main",
      ]
    }
  }
}

# 3. The role that GitHub Actions uses to run "terraform plan".
resource "aws_iam_role" "github_plan" {
  name                 = "github-actions-terraform-plan"
  description          = "Read-only role for terraform plan in GitHub Actions (OIDC, no access keys)"
  assume_role_policy   = data.aws_iam_policy_document.github_plan_trust.json
  max_session_duration = 3600 # the credentials expire after 1 hour
}

# "terraform plan" only reads AWS. It never creates, changes or deletes anything.
resource "aws_iam_role_policy_attachment" "github_plan_readonly" {
  role       = aws_iam_role.github_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# The only write that plan needs: the lock file (*.tflock) next to the state, in the state bucket.
data "aws_iam_policy_document" "github_plan_lock" {
  statement {
    sid       = "TerraformStateLock"
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::nsatge1-aws-guardrails-lab-tfstate/*.tflock"]
  }
}

resource "aws_iam_role_policy" "github_plan_lock" {
  name   = "terraform-state-lock"
  role   = aws_iam_role.github_plan.id
  policy = data.aws_iam_policy_document.github_plan_lock.json
}
