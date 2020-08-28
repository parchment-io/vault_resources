# frozen_string_literal: true

#
# Cookbook Name:: vault_resources
# Resource:: vault_secret_engine_consul
#
# See LICENSE file
#

resource_name :vault_secret_engine_consul

property :consul_config, Hash, default: {}
property :consul_roles, Hash, default: {}
property :remove_consul_roles, Array, default: []

default_action :configure

action :configure do
  require 'base64'
  vault = VaultResources::ClientFactory.vault_client
  vault.sys.mount('consul', 'consul', 'Consul token secret engine') unless vault.sys.mounts.key?(:consul)

  # Make sure the Vault client is configured prior to loading this resource
  unless new_resource.consul_config.empty?
    converge_if_changed :consul_config do
      # Configure dynamic consul token creation
      vault.logical.write('consul/config/access', new_resource.consul_config, 'force' => true)
    end

    converge_if_changed :consul_roles do
      # Configure consul roles
      new_resource.consul_roles.each do |role, config|
        # New Consul ACL system
        # https://www.consul.io/docs/acl/acl-system
        vault.logical.write("consul/roles/#{role}",
                            lease: config['lease'],
                            policies: config['policies'], 'force' => true) unless config['policies'].nil?
        # Legacy Consul ACL system
        # https://www.consul.io/docs/acl/acl-legacy
        vault.logical.write("consul/roles/#{role}",
                            lease: config['lease'],
                            policy: Base64.encode64(config['policy'].join("\n")) unless config['policy'].nil?
      end
    end
  end
end

action :prune do
  converge_if_changed :remove_consul_roles do
    vault = VaultResources::ClientFactory.vault_client
    new_resource.remove_consul_roles.each do |role|
      Chef::Log.warn("Removing se consul role definition: #{role}")
      vault.logical.delete("consul/roles/#{role}")
    end
  end
end
