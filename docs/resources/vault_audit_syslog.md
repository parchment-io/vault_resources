# Chef resource: vault_audit_syslog 
### Overview
This resource will connect to a running Hashicorp Vault instance and enable [auditing](https://www.vaultproject.io/docs/audit/index.html) events to [syslog](https://www.vaultproject.io/docs/audit/syslog.html).

### Properties
No properties for this resource

### Actions

#### configure
##### Description
This action enables the syslog auditing
##### Example
```
vault_audit_syslog 'vault audit in syslog' do
  action :configure
  only_if { vault_leader? }
end
```
