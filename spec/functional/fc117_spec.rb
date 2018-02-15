require "spec_helper"

describe "FC117" do
  context "with a custom resource that includes kind_of in the property definition" do
    resource_file <<-EOF
    property :name, kind_of: String, name_property: true

        action :create do
        end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a custom resource that does not include kind_of in the property definition" do
    resource_file <<-EOF
    property :name, String, name_property: true

        action :create do
        end
    EOF
    it { is_expected.not_to violate_rule }
  end
end
