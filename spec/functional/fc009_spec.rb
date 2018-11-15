require "spec_helper"

describe "FC009" do
  context "on chef 14.2.0 with a cookbook that uses ifconfig attributes introduced in 14.0" do
    foodcritic_command("--chef-version", "14.2.0", "--no-progress", ".")
    recipe_file <<-EOH
      ifconfig 'foo' do
        family 'inet'
      end
    EOH
    it { is_expected.not_to violate_rule }
  end

  context "on chef 13.12.3 with a cookbook that uses ifconfig attributes introduced in 14.0" do
    foodcritic_command("--chef-version", "13.12.3", "--no-progress", ".")
    recipe_file <<-EOH
      ifconfig 'foo' do
        family 'inet'
      end
    EOH
    it { is_expected.to violate_rule }
  end

  context "when the resource attribute is actually a raise" do
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
