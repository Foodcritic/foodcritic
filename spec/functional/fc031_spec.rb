require "spec_helper"

describe "FC031" do
  context "with a cookbook with a metadata file" do
    metadata_file
    recipe_file
    it { is_expected.to_not violate_rule("FC031") }
  end

  context "with a cookbook without a metadata file" do
    recipe_file
    it { is_expected.to violate_rule("FC031") }
  end
end
