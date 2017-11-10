require "spec_helper"

describe "FC107" do
  context "with a cookbook with a recipe that uses uses epic_fail in a resource" do
    recipe_file <<-EOF
    chocolatey_package 'name' do
      epic_fail true
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that uses uses ignore_failure in a resource" do
    library_file <<-EOF
    chocolatey_package 'name' do
      action :install
      ignore_failure true
    end
    EOF
    it { is_expected.to_not violate_rule }
  end
end
