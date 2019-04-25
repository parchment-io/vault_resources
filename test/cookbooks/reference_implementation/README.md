# Vault Resources Reference Implementation
## Description
This test cookbook is used to show working examples of resources from the [vault_resources cookbook](https://github.com/parchment-io/vault_resources)

## Running the example
Run `kitchen converge`.  This will require vagrant and chefdk to be installed on your local workstation.  Vault will then be accessible in your browser at http://localhost:8200/ui/vault/access.  To login you will need to use the root token which can be found on the running kitchen instance.
```
kitchen converge
kitchen login
cat /tmp/vault/secrets/vault-init-secrets.json
```
