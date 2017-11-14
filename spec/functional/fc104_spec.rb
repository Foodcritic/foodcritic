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

  context "with a cookbook with a recipe that notifies :create on a ruby_block" do
    library_file <<-EOF
    file 'foo' do
      notifies :create, 'ruby_block[bar]', :delayed
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that notifies :run on a ruby_block" do
    library_file <<-EOF
    file 'foo' do
      notifies :run, 'ruby_block[bar]', :delayed
    end
    EOF
    it { is_expected.to_not violate_rule }
  end
end
