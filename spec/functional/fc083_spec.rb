require "spec_helper"

describe "FC083" do
  context "with a cookbook with a recipe that includes a execute resource specifying path" do
    recipe_file <<-EOF
      execute 'food' do
        path '/some/path'
        command 'build.sh'
      end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that includes a execute resource not specifying path" do
    recipe_file <<-EOF
      execute 'food' do
        command 'build.sh'
      end
    EOF
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with a recipe that doesn't include an execute resource" do
    recipe_file <<-EOF
      directory '/tmp/something' do
        owner 'root'
        group 'root'
        mode '0755'
        action :create
      end
    EOF
    it { is_expected.not_to violate_rule }
  end
end
