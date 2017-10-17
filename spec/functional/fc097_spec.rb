require "spec_helper"

describe "FC097" do
  context "with a cookbook with a custom resource that includes Chef::Mixin::LanguageIncludeAttribute" do
    resource_file "include Chef::Mixin::LanguageIncludeAttribute"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that includes Chef::Mixin::LanguageIncludeAttribute" do
    recipe_file "include Chef::Mixin::LanguageIncludeAttribute"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a library that includes Chef::Mixin::LanguageIncludeAttribute" do
    library_file "include Chef::Mixin::LanguageIncludeAttribute"
    it { is_expected.to violate_rule }
  end
end
