require "spec_helper"

describe "FC120" do
  context "with a resource that sets the name property" do
    recipe_file <<-EOF
    foo 'bar' do
      name 'Administrator'
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a resource that does not set the name property" do
    recipe_file <<-EOF
    foo 'bar' do
      foo_name 'Administrator'
    end
    EOF
    it { is_expected.not_to violate_rule }
  end
end
