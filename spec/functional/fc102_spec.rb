require "spec_helper"

describe "FC102" do
  context "with a cookbook with a custom resource that includes Chef::DSL::Recipe::FullDSL" do
    resource_file "include Chef::DSL::Recipe::FullDSL"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that includes Chef::DSL::Recipe::FullDSL" do
    recipe_file "include Chef::DSL::Recipe::FullDSL"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a library that includes Chef::DSL::Recipe::FullDSL" do
    library_file "include Chef::DSL::Recipe::FullDSL"
    it { is_expected.to violate_rule }
  end
end
