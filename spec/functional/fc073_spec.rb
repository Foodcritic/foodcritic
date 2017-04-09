require "spec_helper"

describe "FC073" do
  context "with an empty cookbook" do
    metadata_file
    fit { is_expected.to_not violate_rule }
  end
end
