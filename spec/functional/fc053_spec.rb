require "spec_helper"

describe "FC053" do
  context "with a cookbook with a metadata file that does contain the recommends keyword" do
    metadata_file "recommends 'runit'"
    it { is_expected.to violate_rule("FC053") }
  end

  context "with a cookbook with a metadata file that does not contain the recommends keyword" do
    metadata_file
    it { is_expected.to_not violate_rule("FC053") }
  end
end
