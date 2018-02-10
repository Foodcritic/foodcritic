require "spec_helper"

describe "FC118" do
  context "with a property that sets the name_attribute value" do
    resource_file <<-EOF
    property :url, String, name_attribute: true
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a property that sets the name_property value" do
    resource_file <<-EOF
    property :url, String, name_property: true
    EOF
    it { is_expected.not_to violate_rule }
  end
end
