require "spec_helper"

describe "FC045" do
  context "with a cookbook with a metadata file that includes the name keyword" do
    metadata_file "name 'food'"
    it { is_expected.to_not violate_rule("45") }
  end

  context "with a cookbook with a metadata file that doesn't include the name keyword" do
    metadata_file
    it { is_expected.to violate_rule("FC045") }
  end

  context "with a cookbook without a metadata file" do
    recipe_file
    it { is_expected.to violate_rule("FC045") }
  end
end
