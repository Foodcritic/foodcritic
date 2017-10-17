require "spec_helper"

describe "FC099" do
  context "with a cookbook with a custom resource that includes Chef::Mixin::LanguageIncludeRecipe" do
    resource_file "include Chef::Mixin::LanguageIncludeRecipe"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that includes Chef::Mixin::LanguageIncludeRecipe" do
    recipe_file "include Chef::Mixin::LanguageIncludeRecipe"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a library that includes Chef::Mixin::LanguageIncludeRecipe" do
    library_file "include Chef::Mixin::LanguageIncludeRecipe"
    it { is_expected.to violate_rule }
  end
end
