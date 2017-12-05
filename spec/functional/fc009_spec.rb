require "spec_helper"

describe "FC009" do
  context "on chef 13.0.133 with a cookbook that new dsc_resource attributes" do
    foodcritic_command("--chef-version", "13.0.133", "--no-progress", ".")
    recipe_file <<-EOH
      dsc_resource 'foo' do
        resource :something
        module_name 'foo'
        module_version '1.0.0.0'
      end
    EOH
    it { is_expected.not_to violate_rule }
  end

  context "on chef 12.18.31 with a cookbook that new dsc_resource attributes" do
    foodcritic_command("--chef-version", "12.18.31", "--no-progress", ".")
    recipe_file <<-EOH
      dsc_resource 'foo' do
        resource :something
        module_name 'foo'
        module_version '1.0.0.0'
      end
    EOH
    it { is_expected.to violate_rule }
  end

  context "when the resource attribute is actually a raise" do
    foodcritic_command("--chef-version", "12.18.31", "--no-progress", ".")
    recipe_file <<-EOH
      package package_name do
        provider case node["platform_family"]
                 when "debian"; Chef::Provider::Package::Dpkg
                 when "rhel"; Chef::Provider::Package::Rpm
                 else
                  raise RuntimeError("I don't know how to install chef-server packages for this platform family")
                 end
      end
    EOH
    it { is_expected.not_to violate_rule }
  end
end
