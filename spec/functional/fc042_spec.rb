require "spec_helper"

describe "FC042" do
  context "with a cookbook with a single recipe that uses require_recipe" do
    recipe_file "require_recipe 'my_recipe::default'"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a single recipe that uses include_recipe" do
    recipe_file "include_recipe 'my_recipe::default'"
    it { is_expected.not_to violate_rule }
  end
end
