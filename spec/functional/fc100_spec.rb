require "spec_helper"

describe "FC100" do
  context "with a cookbook with a custom resource that includes Chef::Mixin::Language" do
    resource_file "include Chef::Mixin::Language"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that includes Chef::Mixin::Languagee" do
    recipe_file "include Chef::Mixin::Language"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a library that includes Chef::Mixin::Language" do
    library_file "include Chef::Mixin::Language"
    it { is_expected.to violate_rule }
  end
end
