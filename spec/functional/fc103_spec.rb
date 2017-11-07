require "spec_helper"

describe "FC103" do
  context "with a cookbook with a custom resource that uses the :uninstall resource in chocolatey_package" do
    resource_file <<-EOF
    chocolatey_package 'name' do
      action :uninstall
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that uses the :uninstall resource in chocolatey_package" do
    recipe_file <<-EOF
    chocolatey_package 'name' do
      action :uninstall
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a library that uses the :uninstall resource in chocolatey_package" do
    library_file <<-EOF
    chocolatey_package 'name' do
      action :uninstall
    end
    EOF
    it { is_expected.to violate_rule }
  end
end
