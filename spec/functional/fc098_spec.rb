require "spec_helper"

describe "FC098" do
  context "with a cookbook with a custom resource that includes Chef::Mixin::RecipeDefinitionDSLCore" do
    resource_file "include Chef::Mixin::RecipeDefinitionDSLCore"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that includes Chef::Mixin::RecipeDefinitionDSLCore" do
    recipe_file "include Chef::Mixin::RecipeDefinitionDSLCore"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a library that includes Chef::Mixin::RecipeDefinitionDSLCore" do
    library_file "include Chef::Mixin::RecipeDefinitionDSLCore"
    it { is_expected.to violate_rule }
  end
end
