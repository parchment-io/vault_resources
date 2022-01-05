# frozen_string_literal: true

#
# Cookbook:: vault_resources
# Resource:: vault_authentication_approle
#
# See LICENSE file
#

resource_name :vault_authentication_approle
provides :vault_authentication_approle
unified_mode true

property :approles, Hash, default: {}

default_action :configure

load_current_value do
  require 'vault'
  # Check current approles in vault.  There are some settings we don't specify, but are set on each approle
  # Ignore bind_secret_id, bound_cidr_list and period
  vault = VaultResources::ClientFactory.vault_client
  current_approles = vault.logical.list('auth/approle/role').map do |approle_name|
    data = vault.logical.read("auth/approle/role/#{approle_name}").data.map do |key, value|
      # We need to convert the keys from symbols to strings
      if %i(bind_secret_id bound_cidr_list period).include? key
        {}
      else
        { key.to_s => value }
      end
    end.reduce({}, :merge)
    { approle_name => data }
  end.reduce({}, :merge)
  approles current_approles
end

action :configure do
  vault = VaultResources::ClientFactory.vault_client
  # Make sure the Vault client is configured prior to loading this resource
  vault.sys.enable_auth('approle', 'approle') unless vault.sys.auths.key?(:approle)
  converge_if_changed :approles do
    new_resource.approles.each do |role, config|
      vault.logical.write("auth/approle/role/#{role}", config, 'force' => true)
    end
  end
end

# Will have to handle action :prune at some point, but this one is complicated
