require "spec_helper"

describe "FC094" do
  context "with a cookbook with a custom resource that includes node['filesystem2']" do
    resource_file "node['filesystem2']"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that includes node['filesystem2']" do
    recipe_file "node['filesystem2']"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a library that includes node['filesystem2']" do
    library_file "node['filesystem2']"
    it { is_expected.to violate_rule }
  end
end
