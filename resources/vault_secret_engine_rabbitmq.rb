# frozen_string_literal: true

#
# Cookbook Name:: vault_resources
# Resource:: vault_secret_engine_rabbitmq
#
# See LICENSE file
#

resource_name :vault_secret_engine_rabbitmq
provides :vault_secret_engine_rabbitmq

property :rabbitmq_config_connection, Hash, default: {}
property :rabbitmq_config_lease, Hash, default: {}
property :rabbitmq_roles, Hash, default: {}
property :remove_rabbitmq_roles, Array, default: []

default_action :configure

action :configure do
  config = new_resource.rabbitmq_config_connection.to_hash

  # Make sure the Vault client is configured prior to loading this resource
  vault = VaultResources::ClientFactory.vault_client
  vault.sys.mount('rabbitmq', 'rabbitmq', 'Rabbitmq account secret engine') unless vault.sys.mounts.key?(:rabbitmq)
  if new_resource.rabbitmq_config_connection.key?('connection_uri')
    # Configure dynamic rabbitmq token creation
    vault.logical.write('rabbitmq/config/connection', config, 'force' => true)
  end
  unless new_resource.rabbitmq_config_lease.empty?
    converge_if_changed :rabbitmq_config_lease do
      vault.logical.write('rabbitmq/config/lease', new_resource.rabbitmq_config_lease, 'force' => true)
    end

    converge_if_changed :rabbitmq_roles do
      # Configure rabbitmq roles
      reduced_roles = new_resource.rabbitmq_roles.map do |role, role_config|
        reduced_config = {}.deep_merge(role_config)
        reduced_config['vhosts'] = JSON.generate(reduced_config['vhosts'])
        { role => reduced_config }
      end.reduce({}, :merge)
      reduced_roles.each do |role, role_config|
        vault.logical.write("rabbitmq/roles/#{role}", role_config, 'force' => true)
      end
    end
  end
end

action :prune do
  converge_if_changed :remove_rabbitmq_roles do
    vault = VaultResources::ClientFactory.vault_client
    new_resource.remove_rabbitmq_roles.each do |role|
      Chef::Log.warn("Removing se rabbitmq role definition: #{role}")
      vault.logical.delete("rabbitmq/roles/#{role}")
    end
  end
end
