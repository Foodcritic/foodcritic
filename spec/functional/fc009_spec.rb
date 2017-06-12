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
end
