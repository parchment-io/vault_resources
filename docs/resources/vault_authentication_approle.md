# Chef resource: vault_authentication_approle
### Overview
This resource will connect to a running Hashicorp Vault instance and manage [authentication](https://www.vaultproject.io/docs/auth/index.html) for [approles](https://www.vaultproject.io/docs/auth/approle.html)

### Properties

#### approles
`property :approles, Hash, default: {}` 
Hash of approle_name => configuration

This property is a hash of approle_names mapped to configurations

See reference implementation .kitchen.yml for example of approles data structure

### Actions 

#### configure
##### Description
Calling the `configure` action of the resources will iterate over a hash of approles and then create/update those approles by issuing a http `POST` to the [Vault api](https://www.vaultproject.io/api/auth/approle/index.html#create-update-approle).  It will also enable the approle method if it is not already enabled.  The configuration is transformed into json and sent directly to the Vault api.  There are no special updates/transformations done in this chef resource for the configuration, so valid values all come from the Vault approle page.
##### Example
```
vault_authentication_approle 'configure approles' do
  approles node['vault_resources']['approles']
  only_if { vault_leader? }
  action :configure
end
```
