require "spec_helper"

describe "FC115" do
  context "with a resource that requires a name property" do
    resource_file <<-EOF
    property :url, String, name_property: true, required: true
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a resource that explicitly doesn't required a name property" do
    resource_file <<-EOF
    property :url, String, name_property: true, required: false
    EOF
    it { is_expected.not_to violate_rule }
  end

  context "with a resource that requires a name property with the name of 'name'" do
    resource_file <<-EOF
    property :name, String, name_property: true, required: true
    EOF
    it { is_expected.not_to violate_rule }
  end
end
