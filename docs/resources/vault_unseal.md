# Chef resource: vault_unseal
### Overview
This resource will connect to a running Hashicorp Vault instance and unseal the Vault instances using the unseal keys found in the resource array property `unseal_keys`.  It is recommended that this only be done during initial Vault instance creation, and for testing purposes.

### Properties
`property :unseal_keys, Array, default: [], desired_state: false, sensitive: true`
This is an array of keys that will be used to unseal vault.

### Actions

#### unseal
##### Description
The unseal action will iterate over every key in the array `unseal_keys`.  This can result in either a total unseal or a partial unseal.
##### Example
```
vault_unseal 'unseal vault' do
  unseal_keys (lazy { node.run_state['vault_init_secrets']&.fetch('keys') || [] })
end
```
