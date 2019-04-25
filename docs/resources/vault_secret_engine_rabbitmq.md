# Chef resource: vault_secret_engine_rabbitmq
### Overview
This resource will connect to a running Hashicorp Vault instance and manage [secret engines](https://www.vaultproject.io/docs/secrets/index.html) for [rabbitmq](https://www.vaultproject.io/api/secret/rabbitmq/index.html)

### Properties
`property :rabbitmq_config_connection, Hash, default: {}`
This property hash is written to the vault path ['rabbitmq/config/connection'](https://www.vaultproject.io/api/secret/rabbitmq/index.html#configure-connection)

`property :rabbitmq_config_lease, Hash, default: {}`
This property hash is written to the vault path ['rabbitmq/config/connection'](https://www.vaultproject.io/api/secret/rabbitmq/index.html#configure-lease)

`property :rabbitmq_roles, Hash, default: {}`
This has is iterated over as role_name => role_config.  The role_config values are written to the vault path ['rabbitmq/roles/#{role_name}'](https://www.vaultproject.io/api/secret/rabbitmq/index.html#create-role)

`property :remove_rabbitmq_roles, Array, default: []`
An array of roles to remove.  The array is iterated over as role_name.  The deletes are sent to vault path ['rabbitmq/roles/#{role_name}'](https://www.vaultproject.io/api/secret/rabbitmq/index.html#delete-role)

### Actions

#### configure
##### Description
Calling the `configure` action will enable the rabbitmq secret engine on `mount_path` if it is not already enabled.
##### Example
```
vault_secret_engine_rabbitmq 'configure rabbitmq secret engine' do
  rabbitmq_config_connection node['vault_resources']['rabbitmq']['config']['connection']
  rabbitmq_config_lease node['vault_resources']['rabbitmq']['config']['lease']
  rabbitmq_roles node['vault_resources']['rabbitmq']['roles']
  only_if { vault_leader? && !node['vault_resources']['rabbitmq'].nil? }
  action :configure
  sensitive true
end
```

#### destroy
The `destroy` action will unmount the key value store on `mount_point` and destroy all secrets

#### destroy example
```
vault_secret_engine_rabbitmq 'configure rabbitmq secret engine' do
  only_if { vault_leader? && !node['vault_resources']['rabbitmq'].nil? }
  action :destroy
end
```
