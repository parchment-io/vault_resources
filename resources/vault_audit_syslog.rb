# frozen_string_literal: true

#
# Cookbook Name:: vault_resources
# Resource:: vault_audit_syslog
#
# See LICENSE file
#

resource_name :vault_audit_syslog

default_action :configure

load_current_value do
  current_value_does_not_exist!
end

action :configure do
  # Make sure the Vault client is configured prior to loading this resource
  converge_if_changed do
    vault = VaultResources::ClientFactory.vault_client
    vault.sys.enable_audit('syslog', 'syslog', 'Syslog auditing') unless vault.sys.audits.key?(:syslog)
  end
end

action :disable do
  # Make sure the Vault client is configured prior to loading this resource
  converge_if_changed do
    vault = VaultResources::ClientFactory.vault_client
    vault.sys.disable_audit('syslog') if vault.sys.audits.key?(:syslog)
  end
end
