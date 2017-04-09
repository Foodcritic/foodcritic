require "spec_helper"

describe "FC029" do
  context "with a cookbook with a metadata file that doesn't contain the recipe keyword" do
    metadata_file("name 'example'")
    it { is_expected.not_to violate_rule("FC029") }
  end

  context "with a cookbook with a metadata file that contains contain the recipe keyword with the cookbook name only" do
    metadata_file("name 'example'\nrecipe 'example', 'Installs Example'")
    it { is_expected.not_to violate_rule("FC029") }
  end

  context "with a cookbook with a metadata file that contains the recipe keyword with the cookbook::recipe format name" do
    metadata_file("name 'example'\nrecipe 'example::default', 'Installs Example'")
    it { is_expected.not_to violate_rule("FC029") }
  end

  context "with a cookbook with a metadata file that contains the recipe keyword and lacks the cookbook name" do
    metadata_file("name 'example'\nrecipe 'default', 'Installs Example'")
    it { is_expected.to violate_rule("FC029") }
  end

  context "with a cookbook with a metadata file that contains the recipe keyword and stores full recipe name as a var" do
    metadata_file("name 'example'\nvar = 'example::default'\nrecipe my_var, 'Installs Example'")
    it { is_expected.not_to violate_rule("FC029") }
  end

  context "with a cookbook with a metadata file that contains the recipe keyword and stores part of the recipe name as a var" do
    metadata_file('name "example"\nvar = "example"\nrecipe "#{my_var}::default", "Installs Example"')
    it { is_expected.not_to violate_rule("FC029") }
  end
end
