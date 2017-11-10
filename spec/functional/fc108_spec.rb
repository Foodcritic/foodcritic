require "spec_helper"

describe "FC108" do
  context "with a cookbook with a custom resource that defines a name property" do
    resource_file <<-EOF
    property :name, String, name_property: true

        action :create do
        end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a custom resource that does not defines a name property" do
    recipe_file <<-EOF
    property :not_name, String, name_property: true

    action :create do
    end
    EOF
    it { is_expected.to_not violate_rule }
  end
end
