require "spec_helper"

describe "FC104" do
  context "with a cookbook with a recipe where ruby_block specifies a create action" do
    recipe_file <<-EOF
    ruby_block 'puts' do
      block do
        puts "test test test"
      end
      action :create
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe where ruby_block specifies a run action" do
    library_file <<-EOF
    ruby_block 'puts' do
      block do
        puts "test test test"
      end
      action :run
    end
    EOF
    it { is_expected.to_not violate_rule }
  end
end
