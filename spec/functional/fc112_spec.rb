require "spec_helper"

describe "FC112" do
  context "with a cookbook with a resource that uses dsl_name" do
    library_file <<-EOF
    my_resource = MyResource.dsl_name
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a resource that uses resource_name" do
    library_file <<-EOF
    my_resource = MyResource.resource_name
    EOF
    it { is_expected.not_to violate_rule }
  end
end
