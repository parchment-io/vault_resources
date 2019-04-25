# Chef resource: vault_secret_engine_consul
### Overview
This resource will connect to a running Hashicorp Vault instance and manage [secret engines](https://www.vaultproject.io/docs/secrets/index.html) for [consul](https://www.vaultproject.io/docs/secrets/consul/index.html)

### Properties
`property :consul_config, Hash, default: {}`
Hash of configuration options to configure Vault with a Consul Secret Engine

`property :consul_roles, Hash, default: {}`
Map of consul_role_name => consul_role_config

`property :remove_consul_roles, Array, default: []`
Array of consul roles to remove

### Actions

#### configure
##### Description
Calling the `configure` action will enable the consul secret backend.  It will then push the `consul_config` property data to the endpoint [/consul/config/access](https://www.vaultproject.io/api/secret/consul/index.html#consul-secrets-engine-api-).  The resource then iterates over the consul_roles property and uploads each of the configurations to [/consul/roles/#{consul_role_name}](https://www.vaultproject.io/api/secret/consul/index.html#create-update-role)

##### Example
```
vault_secret_engine_consul 'configure consul secret engine' do
  consul_config node['vault_resources']['consul']['config'].merge('token' => node.run_state['vault_consul_token'])
  consul_roles node['vault_resources']['consul']['roles']
  only_if { vault_leader? && !node.run_state['vault_consul_token'].nil? }
  action :configure
  sensitive true
end
```

#### prune
##### Description
The `prune` action will iterate over the `remove_consul_roles` property and delete those roles by calling the endpoint [/consul/roles/#{consul_role}](https://www.vaultproject.io/api/secret/consul/index.html#delete-role)
##### Example
```
vault_secret_engine_consul 'configure consul secret engine' do
  consul_config node['vault_resources']['consul']['config'].merge('token' => node.run_state['vault_consul_token'])
  consul_roles node['vault_resources']['consul']['roles']
  only_if { vault_leader? && !node.run_state['vault_consul_token'].nil? }
  action :prune
  sensitive true
end
```
