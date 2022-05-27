#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#  args: haritest-terraform-state
#
#  Author: Hari Sekhon
#  Date: 2022-05-27 18:03:32 +0100 (Fri, 27 May 2022)
#
#  https://github.com/HariSekhon/DevOps-Bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
. "$srcdir/lib/aws.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Creates an S3 bucket for storing Terraform state with the following optimizations:

- Enables Versioning
- Enables Encryption
- Locks out Power Users
- Optionally locks out any additional given user/group/role arns

Idempotent: skips bucket creation is already exists, applies versioning and encryption, applies bucket policy is none exists of if \$OVERWRITE_BUCKET_POLICY is set to any value

Region: will create the bucket in your configured region, to override locally set \$AWS_DEFAULT_REGION


$usage_aws_cli_required
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<bucket_name> [<disallowed_users>]"

help_usage "$@"

min_args 1 "$@"

timestamp "Checking for Power User role"
power_user_arn="$(aws iam list-roles | jq -r '.Roles[].Arn' | grep -i AWSPowerUserAccess || :)"
if [ -n "$power_user_arn" ]; then
    timestamp "Power User role ARN found:  $power_user_arn"
fi
echo >&2

"$srcdir/aws_s3_bucket.sh" "$@" ${power_user_arn:+"$power_user_arn"}