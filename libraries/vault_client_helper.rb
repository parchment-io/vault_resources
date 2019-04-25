# frozen_string_literal: true

module VaultResources
  # Class to help with sharing a ruby Vault client across multiple resources
  class ClientFactory
    @client = nil
    def self.vault_client(options: nil)
      require 'vault'
      return @client if !@client.nil? && options.nil?

      @client = Vault::Client.new(options || {})
      @client
    end
  end
end
