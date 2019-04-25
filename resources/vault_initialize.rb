# frozen_string_literal: true

#
# Cookbook Name:: vault_resources
# Resource:: vault_initialize
#
# See LICENSE file
#

resource_name :vault_initialize

property :secret_shares, Integer, required: true, desired_state: false
property :secret_threshold, Integer, required: true, desired_state: false
property :print_sensitive, [true, false], default: false, desired_state: false

default_action :configure

load_current_value do
  # Make sure the Vault client is configured prior to loading this resource
  # Wait until vault has started
  vault = VaultResources::ClientFactory.vault_client
  begin
    vault.with_retries(Vault::HTTPConnectionError, max_wait: 1, attempts: 10) do |attempt, e|
      Chef::Log.warn("Received exception #{e} from Vault - attempt #{attempt}") unless e.nil?
      vault.logical.read('sys/health')
    end
  rescue Vault::HTTPServerError => e_init
    Chef::Log.warn("Response Code: #{e_init.code}")
    # Response codes of 501 and 503 are ok, they represent uninitialized and sealed respectively
    raise unless e_init.code == 501 || e_init.code == 503

    current_value_does_not_exist! unless vault.sys.init_status.initialized?
  rescue Vault::HTTPClientError => e_init
    Chef::Log.warn("Response Code: #{e_init.code}")
    # Response code(s) of 429 is ok, it represents a server in standby mode
    raise unless e_init.code == 429
  end
end

action :configure do
  # Return if already initialized
  vault = VaultResources::ClientFactory.vault_client
  return if vault.sys.init_status.initialized?

  Chef::Log.warn('Detected uninitialized Vault, running initialize now')
  vault_init_response = vault.sys.init(secret_shares: new_resource.secret_shares, \
                                       secret_threshold: new_resource.secret_threshold)
  init_data = {
    'keys' => vault_init_response.keys_base64,
    'token' => vault_init_response.root_token
  }
  node.run_state['vault_init_secrets'] = init_data

  # Print to screen if it is a local run, since db item saves don't persist
  # Only enable print_sensitive on local workstations
  Chef::Log.warn("\n#{JSON.pretty_generate(init_data)}\n") \
    if new_resource.print_sensitive
end
