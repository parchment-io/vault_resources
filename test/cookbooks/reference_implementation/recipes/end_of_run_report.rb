# frozen_string_literal: true

ruby_block 'vault end of run report' do
  block do
    vault = VaultResources::ClientFactory.vault_client
    Chef::Log.warn("\n")
    Chef::Log.warn("Initialized?: #{vault.sys.init_status.initialized?}")
    Chef::Log.warn("Vault sealed?: #{vault.sys.seal_status.sealed?}")
    ha_enabled = vault.sys.leader.ha_enabled?
    Chef::Log.warn("Vault HA Enabled?: #{ha_enabled}")
    Chef::Log.warn("Vault leader?: #{vault.sys.leader.leader?}") if ha_enabled
  end
end
