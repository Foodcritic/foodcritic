require "spec_helper"

describe "FC009" do
  context "on chef 15.0.293 with a cookbook that uses windows_task start_when_available property introduced in 15.0" do
    foodcritic_command("--chef-version", "15.0.293", "--no-progress", ".")
    recipe_file <<-EOH
      windows_task 'my_task' do
        start_when_available true
      end
    EOH
    it { is_expected.not_to violate_rule }
  end

  context "on chef 14.12.9 with a cookbook that uses windows_task start_when_available property introduced in 15.0" do
    foodcritic_command("--chef-version", "14.14.29", "--no-progress", ".")
    recipe_file <<-EOH
      windows_task 'my_task' do
        start_when_available true
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
