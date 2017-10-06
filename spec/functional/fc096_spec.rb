require "spec_helper"

describe "FC096" do
  context "with a cookbook with a custom resource that includes node['virtualization']['uri']" do
    resource_file "node['virtualization']['uri']"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that includes node['virtualization']['uri']" do
    recipe_file "node['virtualization']['uri']"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a library that includes node['virtualization']['uri']" do
    library_file "node['virtualization']['uri']"
    it { is_expected.to violate_rule }
  end
end
