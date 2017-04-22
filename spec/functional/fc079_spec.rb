require "spec_helper"

describe "FC079" do
  context "with a cookbook with a recipe that includes an easy_install_package resource" do
    recipe_file <<-EOF
      easy_install_package "foo" do
        action :install
      end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that doesn't include an easy_install_package resource" do
    recipe_file <<-EOF
      package "foo" do
        action :install
      end
    EOF
    it { is_expected.not_to violate_rule }
  end
end
