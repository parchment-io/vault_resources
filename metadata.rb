# frozen_string_literal: true

name             'vault_resources'
maintainer       'Parchment Inc.'
maintainer_email 'chef@parchment.com'
license          'MIT License, see LICENSE file'
description      'Configures Vault resources'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.0'

supports      'ubuntu'
chef_version  '>= 12'

issues_url 'https://github.com/parchment-io/vault_resources/issues'
source_url 'https://github.com/parchment-io/vault_resources'
