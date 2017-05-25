require "spec_helper"

describe "FC062" do
  context "with a cookbook with metadata that includes the version keyword and a valid version string" do
    metadata_file("version '1.2.3'")
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with metadata that does not include a version keyword" do
    metadata_file
    it { is_expected.to violate_rule }
  end
end
