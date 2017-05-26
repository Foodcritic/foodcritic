require "spec_helper"

describe "FC073" do
  context "with an empty cookbook" do
    metadata_file
    it { is_expected.to_not violate_rule }
  end

  context "with only attributes/default.rb" do
    metadata_file
    attributes_file
    it { is_expected.to_not violate_rule }
  end

  context "with only attributes.rb" do
    metadata_file
    file "attributes.rb"
    it { is_expected.to_not violate_rule }
  end

  context "with both attributes.rb and attributes/default.rb" do
    metadata_file
    file "attributes.rb"
    attributes_file
    it { is_expected.to violate_rule.in("attributes/default.rb") }
  end

  context "with only recipes/default.rb" do
    metadata_file
    recipe_file
    it { is_expected.to_not violate_rule }
  end

  context "with only recipe.rb" do
    metadata_file
    file "recipe.rb"
    it { is_expected.to_not violate_rule }
  end

  context "with both recipe.rb and recipes/default.rb" do
    metadata_file
    file "recipe.rb"
    recipe_file
    it { is_expected.to violate_rule.in("recipes/default.rb") }
  end

  context "with all four" do
    metadata_file
    file "attributes.rb"
    file "recipe.rb"
    attributes_file
    recipe_file
    it { is_expected.to violate_rule.in("attributes/default.rb") }
    it { is_expected.to violate_rule.in("recipes/default.rb") }
  end
end
