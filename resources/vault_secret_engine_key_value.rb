# frozen_string_literal: true

#
# Cookbook Name:: vault_resources
# Resource:: vault_secret_engine_key_value
#
# See LICENSE file
#

resource_name :vault_secret_engine_key_value

property :mount_path, String, default: 'secret', desired_state: false
property :key_value_options, Hash, default: {}
property :key_value_config, Hash, default: {}

default_action :configure

load_current_value do
  require 'json'
  vault = VaultResources::ClientFactory.vault_client
  if vault.sys.mounts.key?(mount_path.to_sym)
    key_value_options VaultResources.convert_symbols(vault.logical.read("sys/mounts/#{mount_path}/tune").data[:options])
    key_value_config VaultResources.convert_symbols(vault.logical.read("#{mount_path}/config")&.data)
  end
end

action :configure do
  # Make sure the Vault client is configured prior to loading this resource
  vault = VaultResources::ClientFactory.vault_client
  unless vault.sys.mounts.key?(new_resource.mount_path.to_sym)
    vault.sys.mount(new_resource.mount_path, 'kv', 'KV Secrets')
  end

  # Set mount options
  unless new_resource.key_value_options.empty?
    converge_if_changed :key_value_options do
      vault.logical.write("sys/mounts/#{new_resource.mount_path}/tune",
                          { 'options' => new_resource.key_value_options },
                          'force' => true)
    end
  end

  # Set mount config, this config endpoint is not valid for kv version 1
  unless new_resource.key_value_config.empty? || new_resource.key_value_options['version'] == '1'
    converge_if_changed :key_value_config do
      vault.logical.write("#{new_resource.mount_path}/config",
                          new_resource.key_value_config,
                          'force' => true)
    end
  end
end

action :destroy do
  vault = VaultResources::ClientFactory.vault_client
  if vault.sys.mounts.key?(new_resource.mount_path.to_sym)
    log "unmounting path \"#{new_resource.mount_path}\""
    vault.sys.unmount(new_resource.mount_path)
  end
end
