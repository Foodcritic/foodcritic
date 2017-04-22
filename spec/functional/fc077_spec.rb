require "spec_helper"

describe "FC077" do
  context "with a cookbook with a metadata file that does contain the replaces keyword" do
    metadata_file "replaces 'runit'"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a metadata file that does not contain the replaces keyword" do
    metadata_file
    it { is_expected.to_not violate_rule }
  end
end
