require "spec_helper"

describe "FC095" do
  context "with a cookbook with a custom resource that includes node['cloud_v2']" do
    resource_file "node['cloud_v2']"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that includes node['cloud_v2']" do
    recipe_file "node['cloud_v2']"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a library that includes node['cloud_v2']" do
    library_file "node['cloud_v2']"
    it { is_expected.to violate_rule }
  end
end
