locals {
  host_list_ssm_name = "/${local.name_prefix}/host-list"
  site_name_ssm_name = "/${local.name_prefix}/site-name"
}

resource "aws_ssm_parameter" "host_list" {
  name  = local.host_list_ssm_name
  type  = "StringList"
  value = join(",", aws_instance.main.*.private_dns)


}

resource "aws_ssm_parameter" "site_name" {
  name  = local.site_name_ssm_name
  type  = "String"
  value = "${local.name_prefix}-taco-wagon"


}

data "aws_iam_policy_document" "instance_profile" {
  statement {
    actions = ["ssm:GetParameter"]

    resources = [
      aws_ssm_parameter.host_list.arn,
      aws_ssm_parameter.site_name.arn,
    ]
  }
}

resource "aws_iam_policy" "ssm_access" {
  name        = "${local.name_prefix}-ssm-access"
  description = "IAM policy for SSM access to parameters"
  policy      = data.aws_iam_policy_document.instance_profile.json
}

resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = var.ec2_role_name
  policy_arn = aws_iam_policy.ssm_access.arn
}