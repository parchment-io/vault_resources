# frozen_string_literal: true

require 'json'

# Helper functions for the Vault Resources cookbook
module VaultResources
  def self.convert_symbols(data)
    # Converting to json and then back to a Mash is a quick and dirty fix to convert all symbols to strings
    JSON.parse(JSON.generate(data))
  end
end
