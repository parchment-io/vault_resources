# frozen_string_literal: true

#
# Cookbook Name:: vault_resources
# Resource:: vault_unseal
#
# See LICENSE file
#

resource_name :vault_unseal

property :unseal_keys, Array, default: [], desired_state: false, sensitive: true

default_action :unseal

load_current_value do
  begin
    vault = VaultResources::ClientFactory.vault_client
    vault.with_retries(Vault::HTTPConnectionError, max_wait: 1, attempts: 10) do |attempt, e|
      Chef::Log.warn("Received exception #{e} from Vault - attempt #{attempt}") unless e.nil?
      vault.logical.read('sys/health')
    end
  rescue Vault::HTTPServerError => e_unseal
    # Response code 503 is ok, it represents a sealed vault
    # Response code 501 is standby and sealed, but it could just be waiting for election
    raise unless [501, 503].include?(e_unseal.code)

    current_value_does_not_exist!
  rescue Vault::HTTPClientError => e_unseal
    # Response code 429 is ok, it represents an unsealed vault, but it is a standby instance
    raise unless e_unseal.code == 429
  end
end

action :unseal do
  # Return unless the vault is currently sealed
  converge_if_changed do
    vault = VaultResources::ClientFactory.vault_client
    return unless vault.sys.seal_status.sealed?

    Chef::Log.warn('Sealed vault detected, attempting to unseal')
    new_resource.unseal_keys.each do |seal_key|
      break unless vault.sys.seal_status.sealed?

      vault.sys.unseal(seal_key)
    end
  end
end
