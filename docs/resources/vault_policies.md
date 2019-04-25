# Chef resource: vault_policies
### Overview
This resource will connect to a running Hashicorp Vault instance and manage Vault polices via the [policy endpoint](https://www.vaultproject.io/api/system/policies.html)

### Properties
`property :policies, Hash, default: {}`
Map of policy_name => policy_config

This is a hash of policies and their configurations.

`property :remove_policies, Array, default: []`

Array of policies to remove.  This will auto-populate based on the `policies` property  passed in.  Policies defined in Vault, but not in the `polices` property will be pruned.

### Actions

#### configure
##### Description
The configure action will POST the policy_config to the Vault policy endpoint [/sys/policies/acl/#{policy_name}](https://www.vaultproject.io/api/system/policies.html#create-update-acl-policy) the policy_config configuration.  The data structure for policy configuration can be found in the [Vault documentation]((https://www.vaultproject.io/api/system/policies.html)
##### Example
```
vault_policies 'configure policies' do
  policies node['vault_resources']['policies']
  only_if { vault_leader? }
  action :configure
end
```

#### prune
##### Description
This will loop over the keys in `remove_policies` and remove them from Vault with an http DELETE to the endpoint `auth/ldap/groups/#{policy_name}`

##### Example
```
vault_policies 'configure policies' do
  policies node['vault_resources']['policies']
  only_if { vault_leader? }
  action :configure
end
```
