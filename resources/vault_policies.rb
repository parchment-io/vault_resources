# frozen_string_literal: true

#
# Cookbook Name:: vault_resources
# Resource:: vault_policies
#
# See LICENSE file
#

resource_name :vault_policies

property :policies, Hash, default: {}
property :remove_policies, Array, default: []

default_action :configure

load_current_value do |policies_resource|
  require 'hashdiff'
  # Query Vault for current policies
  # Don't include default or root policies
  vault = VaultResources::ClientFactory.vault_client
  current_policies = vault.sys.policies.reject { |e| %w[default root].include? e }.map do |policy|
    policy_data = vault.logical.read("sys/policy/#{policy}").data
    { policy_data[:name] => JSON.parse(policy_data[:rules]) }
  end.reduce({}, :merge)

  # Find differences between passed in policies and policies already configure in vault
  policy_diff = begin
                  Hashdiff.diff(current_policies, policies_resource.policies, array_path: true)
                rescue NameError
                  HashDiff.diff(current_policies, policies_resource.policies, array_path: true)
                end
  subtractions = policy_diff.map { |a| a[1][0] if ['-'].include? a[0] }.compact.uniq
  # We don't want the removed policies to show in configure action
  # Let remove stale logic deal with them
  subtractions.each do |policy|
    current_policies.delete(policy)
  end
  # Force removal of missing policies, don't worry about the previous/current values
  policies_resource.remove_policies = subtractions
  # Set current policies to match what is in vault
  policies current_policies
end

action :configure do
  # Make sure the Vault client is configured prior to loading this resource
  converge_if_changed :policies do
    # Configure vault policies
    vault = VaultResources::ClientFactory.vault_client
    new_resource.policies.each do |policy, config|
      Chef::Log.info("Updating policy: #{policy}")
      vault.sys.put_policy(policy, JSON.generate(config))
    end
  end
end

action :prune do
  converge_if_changed :remove_policies do
    # Remove stale policies that are no longer defined
    vault = VaultResources::ClientFactory.vault_client
    new_resource.remove_policies.each do |policy|
      Chef::Log.warn("Removing policy: #{policy}")
      vault.sys.delete_policy(policy)
    end
  end
end
