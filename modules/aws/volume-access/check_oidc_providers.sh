#/bin/bash
set -e
eval "$(jq -r '@sh "ACCOUNT_ID=\(.account_id) OIDC_PROVIDERS_STR=\(.oidc_providers_str)"')"

my_array=($OIDC_PROVIDERS_STR)
result=""
for each in "${my_array[@]}"
do
    value=$(aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[?Arn == 'arn:aws:iam::${ACCOUNT_ID}:oidc-provider/$each']" --output text)
    if [ -z "$value" ]; then
        result="$result $each"
    fi
done
jq -n --arg result "$result" '{"oidc_providers":$result}'