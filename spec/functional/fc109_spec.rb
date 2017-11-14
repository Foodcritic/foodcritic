require "spec_helper"

describe "FC109" do
  context "with a cookbook with a package resource that defines a provider" do
    resource_file <<-EOF
    package 'foo' do
      provider Chef::Provider::Package::Rpm
      action :install
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a package resource that doesn't define a provider" do
    resource_file <<-EOF
    package 'foo' do
      action :install
    end
    EOF
    it { is_expected.to_not violate_rule }
  end
end
