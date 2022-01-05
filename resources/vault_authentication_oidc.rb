# frozen_string_literal: true

#
# Cookbook:: vault_resources
# Resource:: vault_authentication_oidc
#
# See LICENSE file
#

resource_name :vault_authentication_oidc
provides :vault_authentication_oidc
unified_mode true

property :oidc_config, Hash, default: {}
property :oidc_roles, Hash, default: {}
property :oidc_groups, Hash, default: {}
property :oidc_group_aliases, Hash, default: {}
property :remove_oidc_roles, Array, default: []
property :remove_oidc_groups, Array, default: []
property :remove_oidc_group_aliases, Array, default: []

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

    converge_if_changed :oidc_groups do
      # Configure oidc groups
      vault = VaultResources::ClientFactory.vault_client
      new_resource.oidc_groups.each do |group, config|
        vault.logical.write("identity/group/name/#{group}", config, 'force' => true)
      end
    end

    converge_if_changed :oidc_group_aliases do
      # Configure oidc group aliases
      vault = VaultResources::ClientFactory.vault_client
      new_resource.oidc_group_aliases.each do |_group_alias, config|
        group_data = vault.logical.read("identity/group/name/#{config['group']}")
        canonical_id = group_data.data[:id]
        if canonical_id.nil?
          Chef::Log.warn("Failed to find Vault canonical_id (group): #{config['group']}")
          break
        end
        # Use logical read as sys/auths does not return accessor
        # https://github.com/hashicorp/vault-ruby/pull/238
        auth_data = vault.logical.read('sys/auth')
        accessor = auth_data.data[:"oidc/"][:accessor]
        alias_config = { "name": config['name'], "mount_accessor": accessor, "canonical_id": canonical_id }
        # Matching existing group aliases throw a client error
        # Silently iterate if no changes, update or create otherwise
        vault.logical.list('identity/group-alias/id').map do |current_alias|
          alias_data = vault.logical.read("identity/group-alias/id/#{current_alias}")
          if alias_data.data[:name] == config['name'] && alias_data.data[:canonical_id] == canonical_id
            next
          elsif alias_data.data[:name] == config['name']
            Chef::Log.warn("Detected change to group-alias, updating existing name: #{config['name']}")
            vault.logical.write("identity/group-alias/id/#{alias_data.data[:id]}", alias_config, 'force' => true)
          end
        end
        vault.logical.write('identity/group-alias', alias_config, 'force' => true)
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

  converge_if_changed :remove_oidc_groups do
    vault = VaultResources::ClientFactory.vault_client
    new_resource.remove_oidc_groups.each do |group|
      Chef::Log.warn("Removing OIDC group definition: #{group}")
      vault.logical.delete("identity/group/name/#{group}")
    end
  end
end
