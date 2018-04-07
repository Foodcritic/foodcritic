require "spec_helper"

describe "FC122" do
  context "with a recipe that includes build-essential" do
    recipe_file "include_recipe 'build-essential'"
    it { is_expected.to violate_rule }
  end

  context "with a recipe that includes build-essential::default" do
    recipe_file "include_recipe 'build-essential::default'"
    it { is_expected.to violate_rule }
  end

  context "with a recipe that includes build-essential-mycorp" do
    recipe_file "include_recipe 'build-essential-mycorp'"
    it { is_expected.to_not violate_rule }
  end
end
