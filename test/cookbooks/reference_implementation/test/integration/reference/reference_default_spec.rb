# frozen_string_literal: true

describe docker_container('vault-server') do
  it { should exist }
  it { should be_running }
  its('id') { should_not eq '' }
  its('image') { should eq 'vault:1.1.1' }
  its('repo') { should eq 'vault' }
  its('tag') { should eq '1.1.1' }
  its('ports') { should eq '0.0.0.0:8200->8200/tcp' }
  its('command') { should eq 'docker-entrypoint.sh server' }
end

describe http('http://127.0.0.1:8200/v1/sys/health') do
  its('status') { should eq 200 }
  its('body') { should match(/{"initialized":true,"sealed":false,"standby":false,"performance_standby":false,"replication_performance_mode":"disabled","replication_dr_mode":"disabled"/) }
end
