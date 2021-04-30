# Chef resource: vault_authentication_oidc
### Overview
This resource will connect to a running Hashicorp Vault instance and manage [authentication](https://www.vaultproject.io/docs/auth/index.html) for [oidc](https://www.vaultproject.io/api-docs/auth/jwt)

### Properties
#### oidc_config
`property :oidc_config, Hash, default: {}`
Hash of configuration options to configure Vault OIDC.

Valid configuration values are found in [Vault oidc documentation](https://www.vaultproject.io/api-docs/auth/jwt#configure)

#### oidc_roles
`property :oidc_roles, Hash, default: {}`
Hash of role_name => role_config

This will map oidc roles to Vault policies.

See reference implementation .kitchen.yml for data structure examples.

#### oidc_groups
`property :oidc_groups, Hash, default: {}`
Hash of group_name => group_config

This will map vault groups to Vault policies for oidc group aliases referencing external group object IDs.

See reference implementation .kitchen.yml for data structure examples and [identity groups](https://www.vaultproject.io/api-docs/secret/identity/group) for API documentation.

#### oidc_group_aliases
`property :oidc_group_aliases, Hash, default: {}`
Hash of group_alias => group_alias_config

This will map vault group aliases to Vault groups.  Used to associate a group ID from an auth provider to a group with policies.

See reference implementation .kitchen.yml for data structure examples and [identity group aliases](https://www.vaultproject.io/api-docs/secret/identity/group-alias) for API documentation

### Actions

#### configure
##### Description
Calling the `configure` action will enable the oidc authentication method if it is not already enabled.  It will then send the values in `oidc_config` to the Vault endpoint [/auth/jwt/config](https://www.vaultproject.io/api-docs/auth/jwt#configure).

- Each role_config in `oidc_roles` is sent via http POST to Vault endpoint [auth/oidc/role/#{role_name}](https://www.vaultproject.io/api-docs/auth/jwt#create-role)
- Each group_config in `oidc_groups` is sent via http POST to Vault endpoint [identity/group/name/#{group_name}](https://www.vaultproject.io/api-docs/secret/identity/group)
- Each group_alias_config in `oidc_group_aliases` is sent via http POST to Vault endpoint [identity/group-alias](https://www.vaultproject.io/api-docs/secret/identity/group-alias). The defined `group` in each `group_alias_config` must exist for the alias to be created.  Group aliases can only be defined once per name, per mount.

##### Example
```
vault_authentication_oidc 'configure oidc' do
  oidc_config  node['vault_resources']['oidc']['config']
  oidc_roles  node['vault_resources']['oidc']['roles']
  oidc_groups  node['vault_resources']['oidc']['groups']
  oidc_group_aliases  node['vault_resources']['oidc']['group_aliases']
  only_if { vault_leader? }
  action %i[configure prune]
  sensitive true
end
```

#### prune
##### Description
This will loop over the keys in `remove_oidc_roles` and `remove_oidc_groups` and remove them from Vault with an http DELETE to the endpoint `auth/oidc/role/#{role_name}`, `identity/group/name/#{group_name}` respectively.

##### Example
```
vault_authentication_oidc 'configure oidc' do
  remove_oidc_roles node['vault_resources']['oidc']['roles']['remove_oidc_roles']
  remove_oidc_groups node['vault_resources']['oidc']['groups']['remove_oidc_groups']
  only_if { vault_leader? }
  action %i[prune]
  sensitive true
end
```
