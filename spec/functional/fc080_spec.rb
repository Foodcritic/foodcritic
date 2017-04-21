require "spec_helper"

describe "FC080" do
  context "with a cookbook with a recipe that includes a user resource using supports" do
    recipe_file <<-EOF
      user "betty" do
        action :create
        supports({
          manage_home: true,
          non_unique: true
        })
      end
    EOF
    it { is_expected.to violate_rule("FC080") }
  end

  context "with a cookbook with a recipe that includes a user resource not using supports" do
    recipe_file <<-EOF
      user "betty" do
        action :create
        manage_home: true,
      end
    EOF
    it { is_expected.not_to violate_rule("FC080") }
  end

  context "with a cookbook with a recipe that includes a resource with supports" do
    recipe_file <<-EOF
      service "foo" do
        action :start
        supports :restart
      end
    EOF
    it { is_expected.not_to violate_rule("FC080") }
  end
end
