# AWS Guardrails Lab

[![Terraform](https://github.com/nsatge1/aws-guardrails-lab/actions/workflows/terraform.yml/badge.svg)](https://github.com/nsatge1/aws-guardrails-lab/actions/workflows/terraform.yml)

> **Work in progress.** Version 1 is being built.

I build a small AWS environment with Terraform, audit it, attack it, and fix it.
For each attack, this repository shows if it was **blocked**, **detected** and **fixed**, with proof.

**Stack:** AWS Organizations · Terraform · GitHub Actions (OIDC) · CloudTrail · GuardDuty · Security Hub · Prowler · Stratus Red Team · Sigma · Python

## What this lab shows

| Step | What I do | Proof in this repository |
|---|---|---|
| 1. Build | The lab account is built with Terraform. GitHub Actions gets short-lived AWS credentials through OIDC, so there are no access keys. | Terraform code, CI checks on every pull request |
| 2. Audit | A Prowler scan with the CIS AWS Foundations Benchmark, before and after my fixes. | Before / after table of the controls |
| 3. Attack, detect, fix | Real attack techniques with Stratus Red Team. Guardrails (SCPs) block some of them. My Sigma rules from [detection-as-code-lab](https://github.com/nsatge1/detection-as-code-lab) detect others in the CloudTrail logs. A Lambda closes an open SSH port automatically. | Results table: attack, blocked, detected, fixed, time to fix |

## Roadmap (version 1)

### Week 1: foundations
- [X] AWS Organizations with a separate `lab` account (SCPs do not apply to the management account)
- [X] Budget alerts, and MFA for every human user
- [X] Terraform state in S3 (versioning, encryption, native locking)
- [ ] GitHub Actions with OIDC: `terraform fmt`, `validate`, `plan` and Checkov on every pull request

### Week 2: audit before and after
- [ ] CloudTrail, GuardDuty and Security Hub
- [ ] Prowler scan (CIS AWS Foundations Benchmark): "before" result
- [ ] Fixes in Terraform, then a second scan: "after" result

### Week 3: attack, detect, fix
- [ ] Service Control Policies: deny stopping CloudTrail, allow only approved regions
- [ ] 3 Stratus Red Team attacks, with cleanup after each one
- [ ] Hunt over the real CloudTrail logs with my Sigma rules
- [ ] Auto-remediation: EventBridge + Lambda remove SSH access open to the internet

## License

[MIT](LICENSE)
