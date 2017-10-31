require "spec_helper"

describe "FC087" do
  context "with a cookbook with a library that maps platforms with Chef::Platform.set" do
    library_file <<-EOF
    Chef::Platform.set platform: :amazon, resource: :mysql_chef_gem, provider: Chef::Provider::MysqlChefGem::Mysql
    Chef::Platform.set platform: :centos, version: '< 7.0', resource: :mysql_chef_gem, provider: Chef::Provider::MysqlChefGem::Mysql
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a library that maps providers with Chef::Platform.provider_for_resource" do
    library_file <<-EOF
      provider = Chef::Platform.provider_for_resource(resource, :create)
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a library that maps providers with Chef::Platform.provider_for_resource" do
    library_file <<-EOF
      provider = Chef::Platform.find_provider("ubuntu", "16.04", resource)
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a library that includes Chef::Platform.foo" do
    library_file <<-EOF
    module AuditD
      module Helper
        def auditd_package_name_for(platform_family)
          case platform_family
          when 'rhel', 'fedora'
            'audit'
          else
            'auditd'
          end
        end
      end
    end
    EOF
    it { is_expected.to_not violate_rule }
  end
end
