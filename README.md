# vault_resources
A Chef cookbook to manage Hashicorp Vault post install configuration

## Cookbook Inspiration
When it came time to setup and configure Vault as a POC, many Chef supermarket cookbooks were examined.  They all focused on installing the binary in some fashion and then setting up the initial [vault configuration file](https://www.vaultproject.io/docs/configuration/index.html).  As we all know, this is actually a very small part of setting up Vault instances.  This cookbook's intention is to automate and bring under configuration management the authentication, secret backends, audit and other resources.  What this cookbook does not do is install Vault.  There are many good options out there for installation (cookbooks, docker images, etc... ) and there is no use in re-inventing the wheel.

## High level tasks
The resources in this cookbook do a wide variety of tasks.  There is a resource to participate in the unseal process.  There is a resource to initialize your Vault instances and then store you secret init data (keys and root token).  There are resources to configure and manage Consul, Database, RabbitMQ and KV secret backends.  This cookbook includes a [test reference cookbook implementation](https://github.com/parchment-io/vault_resources/tree/master/test/cookbooks/reference_implementation).  This is a great place to start, just run `kitchen converge`.  It does the following steps:
- Creates a vagrant kitchen test instance (vagrant and chef test kitchen required)
- Starts a Vault docker container
- Initializes Vault to generate unseal keys and root token if not already initialized
- Loads previous unseal keys and root token if already initialized
- Configures ruby Vault client with appropriate access
- Creates policies
- Sets up LDAP authentication
- Sets up OIDC authentication
- Creates approles
- Enables syslog auditing
- Creates multiple kv store backends
- Generates an end of run report

The reference implementation is driven by a [chef recipe](https://github.com/parchment-io/vault_resources/blob/master/test/cookbooks/reference_implementation/recipes/default.rb) that works off of node attributes found in the [reference implementation kitchen yaml file](https://github.com/parchment-io/vault_resources/blob/master/test/cookbooks/reference_implementation/.kitchen.yml).  There are other resources as well.  Those were not put in the reference implementation, as it would require setting up too many external services.

## Chef Resources
At the initial implementation, there are a decent number of [Cookbook Chef Resources](https://github.com/parchment-io/vault_resources/tree/master/resources) created to manage various Vault components.  There may be others added in the future.  Pull requests and Issues are always welcome.  Issues requesting new resources will be examined and implemented based on general community need, and of course developer availability.
