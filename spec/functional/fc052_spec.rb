require "spec_helper"

describe "FC052" do
  context "with a cookbook with a metadata file that does contain the suggests keyword" do
    metadata_file "suggests 'runit'"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a metadata file that does not contain the suggests keyword" do
    metadata_file
    it { is_expected.to_not violate_rule }
  end
end
