# Library data_helper

## Static Methods
`VaultResources::ClientFactory.vault_client(options: nil)`

The vault_client factory method will fetch a [ruby vault client](https://github.com/hashicorp/vault-ruby#vault-ruby-client-).  Options passed in to `VaultResources::ClientFactory.vault_client` will be passed along to the [ruby vault client class](https://github.com/hashicorp/vault-ruby/blob/master/lib/vault/client.rb#L71) initialize method.

Calling `VaultResources::ClientFactory.vault_client` and specifing options will create a new client object.  Subsequent method calls with no options specified will always return the last created client object.  This allows for a one time configuration with the ability to retrieve it at a later time with the same static method call.
