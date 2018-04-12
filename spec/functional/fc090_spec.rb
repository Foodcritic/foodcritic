require "spec_helper"

describe "FC090" do
  context "with a recipe that installs package with ignore_failure set true" do
    recipe_file <<-EOF
        package 'foo' do
          ignore_failure true
        end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a recipe that installs package with ignore_failure set false" do
    recipe_file <<-EOF
        package 'foo' do
          ignore_failure false
        end
    EOF
    it { is_expected.not_to violate_rule }
  end

  context "with a recipe that installs package without defining ignore_failure" do
    recipe_file "package 'foo'"
    it { is_expected.not_to violate_rule }
  end
end
