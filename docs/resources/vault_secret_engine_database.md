# Chef resource: vault_secret_engine_database
### Overview
This resource will connect to a running Hashicorp Vault instance and manage [secret engines](https://www.vaultproject.io/docs/secrets/index.html) for [databases](https://www.vaultproject.io/api/secret/databases/index.html)

### Properties
`property :mount_path, String, default: 'database', desired_state: false`

`property :database_name, String, desired_state: false`
The database name to configure.  It creates a pre-configured connection to a database at [#{mount_path}/config/#{database_name}](https://www.vaultproject.io/api/secret/databases/index.html#configure-connection)

`property :database_config, Hash, default: {}`
The configuration to upload to [#{mount_path}/config/#{database_name}](https://www.vaultproject.io/api/secret/databases/index.html#configure-connection)

`property :database_roles, Hash, default: {}`
Map of role_name => role_config

The resource will itereate over this hash and upload the role_configs to [#{mount_path/roles/#{role_name}](https://www.vaultproject.io/api/secret/databases/index.html#create-role)

### Actions

#### configure
##### Description
Calling the `configure` action will enable the database backend on `mount_path` if it is not already enabled.  It will then push the `database_config` to [#{mount_path}/config/#{database_name}](https://www.vaultproject.io/api/secret/databases/index.html#configure-connection).  Then it will iterate over each of the database_roles and create them at [/consul/roles/#{consul_role_name}](https://www.vaultproject.io/api/secret/consul/index.html#create-update-role)

##### Example
```
node['vault_resources']['databases']&.each_pair do |name, data|
  vault_secret_engine_database "#{name} database secret engine" do
    database_name name
    database_config data['config'] if data&.key?('config')
    database_roles data['roles'] if data&.key?('roles')
    mount_path name
    sensitive true
    only_if { vault_leader? }
  end
end
```

#### destroy
##### Description
The `destroy` action will unmount the database on `mount_point` and destroy all roles and configuration.

##### Example
```
node['vault_resources']['databases']&.each_pair do |name, data|
  vault_secret_engine_database "#{name} database secret engine" do
    database_name name
    database_config data['config'] if data&.key?('config')
    database_roles data['roles'] if data&.key?('roles')
    mount_path name
    sensitive true
    only_if { vault_leader? }
  end
end
```
