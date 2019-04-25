# Chef resource: vault_authentication_ldap
### Overview
This resource will connect to a running Hashicorp Vault instance and manage [authentication](https://www.vaultproject.io/docs/auth/index.html) for [ldap](https://www.vaultproject.io/docs/auth/ldap.html)

### Properties
#### ldap_config
`property :ldap_config, Hash, default: {}`
Hash of configuration options to configure Vault ldap.

Valid configuration values are found in [Vault ldap documentation](https://www.vaultproject.io/api/auth/ldap/index.html#configure-ldap)

#### ldap_groups
`property :ldap_groups, Hash, default: {}`
Hash of group_name => group_config

This will map ldap group memebership to Vault polices.

See reference implementation .kitchen.yml for data structure examples

### Actions

#### configure
##### Description
Calling the `configure` action will enable the ldap authentication method if it is not already enabled.  It will then send the values in `ldap_config` to the Vault endpoint [auth/ldap/config](https://www.vaultproject.io/api/auth/ldap/index.html#configure-ldap).

Each group_config in `ldap_groups` is sent via http POST to Vault endpoint [auth/ldap/groups/#{group_name}](https://www.vaultproject.io/api/auth/ldap/index.html#create-update-ldap-group) 

##### Example
```
vault_authentication_ldap 'configure ldap' do
  ldap_config node['vault_resources']['ldap']['config']
  ldap_groups node['vault_resources']['ldap']['groups']
  only_if { vault_leader? }
  action configure
  sensitive true
end
```

#### prune 
##### Description
This will loop over the keys in `remove_ldap_groups` and remove them from Vault with an http DELETE to the endpoint `auth/ldap/groups/#{group_name}`

##### Example
```
vault_authentication_ldap 'configure ldap' do
  ldap_groups node['vault_resources']['ldap']['groups']
  only_if { vault_leader? }
  action %i[prune]
  sensitive true
end
```