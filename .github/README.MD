# Terraflops Terraform Module
 
### AWS SQS Queue

This module can be used to create an SQS queue

#### Example usage

```hcl-terraform
module "application_queue" {
  source = "git::https://github.com/TerraFlops/aws-sqs-queue?ref=v1.0"
  name = "example"
  policy_document = data.aws_iam_policy_document.application_queue_policy.json
}
```
