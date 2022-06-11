# create RBAC in Azure and fill output values:
# az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"
$env:ARM_CLIENT_ID="..."
$env:ARM_SUBSCRIPTION_ID="..."
$env:ARM_TENANT_ID="..."
$env:ARM_CLIENT_SECRET="..."