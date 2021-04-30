# frozen_string_literal: true

chef_gem 'vault' do
  compile_time true
end

chef_gem 'hashdiff' do
  compile_time true
end

# Configure vault client for resources
ruby_block 'configure vault client' do
  block do
    vault_options = {
      address: 'http://localhost:8200',
    }
    VaultResources::ClientFactory.vault_client(options: vault_options)
  end
end

directory '/etc/vault' do
  mode '0777'
end

directory '/tmp/vault/data' do
  mode '0777'
  recursive true
end

cookbook_file '/etc/vault/vault_config.json' do
  mode '0644'
  source 'vault_config.json'
  notifies :restart, 'docker_container[vault-server]', :delayed
end

docker_service 'default' do
  action %i[create start]
end

docker_image 'vault' do
  tag '1.5.3'
  action :pull
end

docker_container 'vault-server' do
  command 'server'
  tag '1.5.3'
  repo 'vault'
  port '8200:8200'
  volumes ['/etc/vault:/vault/config', '/tmp/vault:/tmp/vault', '/dev/log:/dev/log']
end

execute 'wait for vault' do
  command 'curl -s --output /dev/null localhost:8200/v1/sys/health'
  retries 12
  retry_delay 5
  timeout 10
end

vault_initialize_secrets_storage 'load secrets' do
  local_file '/tmp/vault/secrets/vault-init-secrets.json'
  only_if { node['vault_resources']['secrets_persist_local'] }
  action :load
end

vault_initialize 'initialize vault' do
  secret_shares 3
  secret_threshold 2
  print_sensitive true
end

vault_initialize_secrets_storage 'save secrets' do
  local_file '/tmp/vault/secrets/vault-init-secrets.json'
  only_if { node['vault_resources']['secrets_persist_local'] }
  action :save
end

# Re-configure vault client with token
ruby_block 'configure vault client' do
  block do
    vault_options = {
      address: 'http://localhost:8200',
      token: node.run_state['vault_init_secrets']&.fetch('token', nil)
    }
    VaultResources::ClientFactory.vault_client(options: vault_options)
  end
end

vault_unseal 'unseal vault' do
  unseal_keys (lazy { node.run_state['vault_init_secrets']&.fetch('keys') || [] })
end

vault_policies 'configure policies' do
  policies node['reference_implementation']['policies']
  action %i[configure prune]
end

vault_authentication_ldap 'configure ldap' do
  ldap_config node['reference_implementation']['ldap']['config']
  ldap_groups node['reference_implementation']['ldap']['groups']
  action %i[configure prune]
  sensitive true
end

vault_authentication_oidc 'configure oidc' do
  oidc_config node['reference_implementation']['oidc']['config']
  oidc_roles node['reference_implementation']['oidc']['roles']
  oidc_groups node['reference_implementation']['oidc']['groups']
  oidc_group_aliases node['reference_implementation']['oidc']['group_aliases']
  remove_oidc_groups node['reference_implementation']['oidc']['remove_groups']
  action %i[prune configure]
  sensitive true
end

vault_authentication_approle 'configure approle' do
  approles node['reference_implementation']['approles']
  action :configure
end

vault_audit_syslog 'vault audit in syslog' do
  action :configure
end

# KV storage is no longer mounted by default
node['reference_implementation']['kv_stores']&.each_pair do |kv_name, kv_data|
  vault_secret_engine_key_value "#{kv_name} kv secret store" do
    key_value_options kv_data['options'] if kv_data&.key?('options')
    key_value_config kv_data['config'] if kv_data&.key?('config')
    action kv_data['action'].to_sym if kv_data&.key?('action')
    mount_path kv_name
  end
end

include_recipe 'reference_implementation::end_of_run_report'
