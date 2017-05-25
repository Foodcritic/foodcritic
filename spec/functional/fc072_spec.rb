require "spec_helper"

describe "FC072" do
  context "with a cookbook with a metadata file that contains an attribute keyword" do
    metadata_file "attribute 'something/something',\n    display_name: 'something tuneable',\n    description: 'This tunes something',\n    default: 'none'"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a metadata file that doesn't contain an attribute keyword" do
    metadata_file
    it { is_expected.not_to violate_rule }
  end
end
