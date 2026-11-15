# The CI needs this value. We store it as a GitHub variable, so the account ID is not in the code.
output "github_plan_role_arn" {
  description = "ARN of the role that GitHub Actions uses for terraform plan"
  value       = aws_iam_role.github_plan.arn
}
