# Chef resource:  vault_unseal_secrets_storage
### Overview
This resource will store the unseal keys that were generated as part of Vault initialization.

### Properties
`property :local_file, String, default: '/tmp/secrets/vault-init-secrets.json'`
This file is used as a temporary storage location for uploading the Vault init secrets to S3 in the :s3_upload action.  It is removed after successful upload to S3.  It is also used as part of the :save action.  Save will store the file locally so an admin can pick up the secrets.  The admin should make sure this file is removed after the secrets are stored off in a secure location.

`property :local_file_owner, String, default: node['hashicorp-vault']['service_user']`
User to assign ownership of the `local_file`.

`property :delete_local_file_after_upload, [true, false], default: true`
Whether to remove the `local_file` after being uploaded to s3 with a `:s3_upload` action.
 
`property :s3_bucket, String`
This is the S3 bucket that the secrest file is uploaded to as part of the :s3_upload action.  This option is ignored in the :load and :save actions.

`property :s3_file, String`
This is the S3 remote file under the S3 bucket that the secrest file is uploaded to as part of the :s3_upload action.  This option is ignored in the :load and :save actions.

`property :aws_cli_env, Hash, default: {}`
AWS Command line environmental variables are passed in this hash.  Example environmental variables that most users will be interested in can be found on the [AWS cli config page](https://docs.aws.amazon.com/cli/latest/topic/config-vars.html#).

### Actions

#### s3_upload
##### Description
This task will upload the secrets generated during Vault initialization to Amazon S3.  It will call the aws cli tool.  Variables in the property hash `aws_cli_env` are provided to the cli command.  This allows for an easy method for providing credentials.  The properties `s3_bucket`, `s3_file`, and `aws_cli_env` are required.  The property `local_file` is only used during the upload to S3.  Once the upload is completed, the file is removed.
##### Example
```
vault_initialize_secrets_storage 'save secrets' do
  s3_bucket node['vault_resources']['s3_secrets_upload_bucket']
  s3_file "#{node['vault_resources']['s3_secrets_upload_dir']}/#{node['vault_resources']['cluster_name']}_#{Time.now.utc.iso8601}.json"
  aws_cli_env node['vault_resources']['aws_cli_env']
  action :s3_upload
end
```

#### save
##### Description
This will save the file to local disk at the path specified by `local_file`.  It is recommended that once this file generated, that a Vault administrator gather the file contents, and then delete it.  It is a security risk to leave the unseal keys on the local disk of live Vault systems.  The `save` action is also useful for local kitchen runs and other testing efforts when paired with the `load` action where you do want it stored locally for convenience.
##### Example
```
vault_initialize_secrets_storage 'save secrets' do
  action :save
end
```

#### load
##### Description
This will load the unseal secret data from local disk at the path specified by `local_file`.  This should only be used for test kitchen runs. You should never leave your unseal keys on the local disk.
##### Example
```
vault_initialize_secrets_storage 'save secrets' do
  action :load
end
```
