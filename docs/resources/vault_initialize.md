# Chef resource: vault_initialize 
### Overview
This resource will connect to a running Hashicorp Vault instance and initialize it via the [init endpoint](https://www.vaultproject.io/api/system/init.html).  This will do nothing if Vault is already initialized.

### Properties
`property :secret_shares, Integer, required: true, desired_state: false`

`property :secret_threshold, Integer, required: true, desired_state: false`

Details about these properties can be found in the [Vault initialize documentation](https://www.vaultproject.io/api/system/init.html#start-initialization)

### Actions

#### configure
##### Description
This will initialize a Vault server, unless it has already been initialized.  It will store the data in the chef runstate under `node.run_state['vault_init_secrets']`.  This can later be used by vault_secrets_storage to save/load those secrets at a later time
##### Example
```
vault_initialize 'initialize vault' do
  secret_shares node['vault_resources']['secret_shares']
  secret_threshold node['vault_resources']['secret_threshold']
  print_sensitive node['vault_resources']['print_sensitive']
  only_if { vault_leader? }
end
```

### TODO
* Remove properties secret_shares and secret_threshold, and replace with vault_init_data.  This is to expose all init options as opposed to just these 2.