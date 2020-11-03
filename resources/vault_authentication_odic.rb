# frozen_string_literal: true

#
# Cookbook Name:: vault_resources
# Resource:: vault_authentication_oidc
#
# See LICENSE file
#

resource_name :vault_authentication_oidc

property :oidc_config, Hash, default: {}
property :oidc_roles, Hash, default: {}
property :remove_oidc_roles, Array, default: []

default_action :configure

action :configure do
  # Make sure the Vault client is configured prior to loading this resource
  unless new_resource.oidc_config.empty?
    converge_if_changed :oidc_config do
      vault = VaultResources::ClientFactory.vault_client
      # Configure oidc authentication
      vault.sys.enable_auth('oidc', 'oidc') unless vault.sys.auths.key?(:oidc)
      vault.logical.write('auth/oidc/config', new_resource.oidc_config, 'force' => true)
    end

    converge_if_changed :oidc_roles do
      # Configure oidc roles
      vault = VaultResources::ClientFactory.vault_client
      new_resource.oidc_roles.each do |role, config|
        vault.logical.write("auth/oidc/role/#{role}", config, 'force' => true)
      end
    end
  end
end

action :prune do
  converge_if_changed :remove_oidc_roles do
    vault = VaultResources::ClientFactory.vault_client
    new_resource.remove_oidc_roles.each do |role|
      Chef::Log.warn("Removing OIDC role definition: #{role}")
      vault.logical.delete("auth/oidc/role/#{role}")
    end
  end
end
