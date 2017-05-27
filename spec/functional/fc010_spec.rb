require "spec_helper"

describe "FC010" do
  context "with a cookbook with a recipe that attempts to perform a search with invalid syntax" do
    recipe_file <<-EOH
    search(:node, 'run_list:recipe[foo::bar]') do |matching_node|
      puts matching_node.to_s
    end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that attempts to perform a search with valid syntax" do
    recipe_file <<-EOH
    search(:node, 'run_list:recipe\\[foo\\:\\:bar\\]') do |matching_node|
      puts matching_node.to_s
    end
    EOH

    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with a recipe that attempts to perform a search with a subexpression" do
    recipe_file <<-EOH
    search(:node, "roles:\#{node['foo']['role']}") do |matching_node|
      puts matching_node.to_s
    end
    EOH

    it { is_expected.not_to violate_rule }
  end
end
