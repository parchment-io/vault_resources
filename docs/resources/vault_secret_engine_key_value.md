# Chef resource: vault_secret_engine_key_value
### Overview
This resource will connect to a running Hashicorp Vault instance and manage [secret engines](https://www.vaultproject.io/docs/secrets/index.html) for [key values](https://www.vaultproject.io/docs/secrets/kv/index.html)

### Properties
`property :mount_path, String, default: 'secret', desired_state: false`
The path to mount this secret engine on

`property :key_value_options, Hash, default: {}`
The hash is uploaded to [sys/mounts/#{mount_path}/tune](https://www.vaultproject.io/api/system/mounts.html#tune-mount-configuration) and tunes the mount

`property :key_value_config, Hash, default: {}`
This hash is uploaded to [#{mount_path}/config](https://www.vaultproject.io/api/secret/kv/kv-v2.html#configure-the-kv-engine) and will configure the kv store

NOTE: The key_value_config paramater is only valid for [KV version 2](https://www.vaultproject.io/docs/secrets/kv/kv-v2.html).  It will be ignored for KV version 1 secret engines.  Unless specified in key_value_options, the KV version will default to version 2.

### Actions

#### configure
##### Description
Calling the `configure` action will enable the KV backend on `mount_path` if it is not already enabled.  It will then push the `key_value_options` to [sys/mounts/#{mount_path}/tune](https://www.vaultproject.io/api/system/mounts.html#tune-mount-configuration).  Finally it will upload `key_value_config` to [#{mount_path}/config](https://www.vaultproject.io/api/secret/kv/kv-v2.html#configure-the-kv-engine)

##### Example
```
node['vault_resources']['kv_stores']&.each_pair do |kv_name, kv_data|
  vault_secret_engine_key_value "#{kv_name} kv secret store" do
    key_value_options kv_data['options'] if kv_data&.key?('options')
    key_value_config kv_data['config'] if kv_data&.key?('config')
    action kv_data['action'].to_sym if kv_data&.key?('action')
    mount_path kv_name
    action :configure
    only_if { vault_leader? }
  end
end
```

#### destroy
##### Description
The `destroy` action will unmount the key value store on `mount_point` and destroy all secrets

##### Example
```
node['vault_resources']['kv_stores']&.each_pair do |kv_name, kv_data|
  vault_secret_engine_key_value "#{kv_name} kv secret store" do
    mount_path kv_name
    action :destroy
    only_if { vault_leader? }
  end
end
```
