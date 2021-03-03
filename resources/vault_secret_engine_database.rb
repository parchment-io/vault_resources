# frozen_string_literal: true

#
# Cookbook Name:: vault_resources
# Resource:: vault_secret_engine_database
#
# See LICENSE file
#

resource_name :vault_secret_engine_database
provides :vault_secret_engine_database

property :mount_path, String, default: 'database', desired_state: false
property :database_name, String, desired_state: false
property :database_config, Hash, default: {}
property :database_roles, Hash, default: {}

default_action :configure

load_current_value do |database_resource|
  require 'json'
  vault = VaultResources::ClientFactory.vault_client
  if vault.sys.mounts.key?(mount_path.to_sym)
    role_data = database_resource.database_roles.each_key.map do |role_name|
      role_data = VaultResources.convert_symbols(vault.logical.read("#{mount_path}/roles/#{role_name}")&.data) || {}
      role_data['db_name'] = database_name
      role_data.delete('renew_statements') if role_data['renew_statements']&.empty?
      role_data.delete('revocation_statements') if role_data['revocation_statements']&.empty?
      role_data.delete('rollback_statements') if role_data['rollback_statements']&.empty?
      { role_name => role_data }
    end.reduce({}, :merge)
    database_roles role_data
  end
end

action :configure do
  # Make sure the Vault client is configured prior to loading this resource
  vault = VaultResources::ClientFactory.vault_client
  unless vault.sys.mounts.key?(new_resource.mount_path.to_sym)
    vault.sys.mount(new_resource.mount_path, 'database', 'Database secret engine')
  end

  unless new_resource.database_config.empty?
    converge_if_changed :database_config do
      vault.logical.write("#{new_resource.mount_path}/config/#{new_resource.database_name}",
                          new_resource.database_config,
                          'force' => true)
    end
  end

  unless new_resource.database_roles.empty?
    converge_if_changed :database_roles do
      new_resource.database_roles.each_pair do |role_name, role_config|
        vault.logical.write("#{new_resource.mount_path}/roles/#{role_name}",
                            role_config.merge('db_name' => new_resource.database_name),
                            'force' => true)
      end
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
