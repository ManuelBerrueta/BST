### Example Terraform execution
```Shell
terraform init
terraform plan
terraform apply -var name="resource_group_name" -var users='["admin", "users1"]' -var owner="owner_name" -var location="WestUS"
```