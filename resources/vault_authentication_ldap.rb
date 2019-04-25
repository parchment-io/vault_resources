# frozen_string_literal: true

#
# Cookbook Name:: vault_resources
# Resource:: vault_authentication_ldap
#
# See LICENSE file
#

resource_name :vault_authentication_ldap

property :ldap_config, Hash, default: {}
property :ldap_groups, Hash, default: {}
property :remove_ldap_groups, Array, default: []

default_action :configure

action :configure do
  # Make sure the Vault client is configured prior to loading this resource
  unless new_resource.ldap_config.empty?
    converge_if_changed :ldap_config do
      vault = VaultResources::ClientFactory.vault_client
      # Configure ldap authentication
      vault.sys.enable_auth('ldap', 'ldap') unless vault.sys.auths.key?(:ldap)
      vault.logical.write('auth/ldap/config', new_resource.ldap_config, 'force' => true)
    end

    converge_if_changed :ldap_groups do
      # Configure ldap groups
      vault = VaultResources::ClientFactory.vault_client
      new_resource.ldap_groups.each do |group, config|
        vault.logical.write("auth/ldap/groups/#{group}", config, 'force' => true)
      end
    end
  end
end

action :prune do
  converge_if_changed :remove_ldap_groups do
    vault = VaultResources::ClientFactory.vault_client
    new_resource.remove_ldap_groups.each do |group|
      Chef::Log.warn("Removing ldap group definition: #{group}")
      vault.logical.delete("auth/ldap/groups/#{group}")
    end
  end
end
