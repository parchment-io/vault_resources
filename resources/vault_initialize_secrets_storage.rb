# frozen_string_literal: true

#
# Cookbook Name:: vault_resources
# Resource:: vault_initialize_secrets_storage
#
# See LICENSE file
#

resource_name :vault_initialize_secrets_storage

property :local_file, String, default: '/tmp/secrets/vault-init-secrets.json'
property :local_file_owner, [String, nil], default: lazy { node['hashicorp-vault']&.fetch('service_user', nil) }
property :delete_local_file_after_upload, [true, false], default: true
property :s3_bucket, String
property :s3_file, String
property :aws_cli_env, Hash, default: {}
default_action :s3_upload

action :s3_upload do
  file new_resource.local_file do
    content "#{JSON.pretty_generate(node.run_state['vault_init_secrets'])}\n"
    sensitive true
    mode '0600'
    owner new_resource.local_file_owner
  end

  execute 's3 secrets upload' do
    command "aws s3 cp #{new_resource.local_file} s3://#{new_resource.s3_bucket}/#{new_resource.s3_file} " \
            ' --acl private --sse AES256'
    environment new_resource.aws_cli_env
  end

  file new_resource.local_file do
    action :delete
    only_if { new_resource.delete_local_file_after_upload }
  end
end

action :save do
  require 'fileutils'
  FileUtils.mkdir_p(::File.dirname(new_resource.local_file))
  file new_resource.local_file do
    owner new_resource.local_file_owner
    content "#{JSON.pretty_generate(node.run_state['vault_init_secrets'])}\n"
    sensitive true
    mode '0600'
  end
end

action :load do
  return unless ::File.file?(new_resource.local_file)

  node.run_state['vault_init_secrets'] = JSON.parse(::File.read(new_resource.local_file))
end
