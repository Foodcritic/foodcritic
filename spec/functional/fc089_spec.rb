require "spec_helper"

describe "FC089" do
  context "with a cookbook with a library that uses Chef::ShellOut" do
    library_file "include Chef::ShellOut"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a resource that uses Chef::ShellOut" do
    resource_file "include Chef::ShellOut"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a resource that uses Miblib::Shellout" do
    resource_file "include Mixlib::Shellout"
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with a resource that uses Chef::Mixin::ShellOut" do
    resource_file "include Chef::Mixin::ShellOut"
    it { is_expected.not_to violate_rule }
  end
end
