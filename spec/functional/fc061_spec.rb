require "spec_helper"

describe "FC061" do
  context "with a cookbook with metadata that includes the version keyword and a valid version string" do
    metadata_file("version '1.2.3'")
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with metadata that includes the version keyword and a valid version string with double quotes" do
    metadata_file('version "1.2.3"')
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with metadata that includes the version keyword and a valid x.y version string" do
    metadata_file("version '1.2'")
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with metadata that does not include a version keyword" do
    metadata_file("name 'something'")
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with metadata that includes the version keyword and an invalid version string" do
    metadata_file("version 'one'")
    it { is_expected.to violate_rule }
  end

  context "with a cookbook metadata that includes the version keyword and an invalid single digit version string" do
    metadata_file("version '1'")
    it { is_expected.to violate_rule }
  end

  context "with a cookbook metadata that includes the version keyword and an invalid four digit version string" do
    metadata_file("version '1.2.3.4'")
    it { is_expected.to violate_rule }
  end

  context "with a cookbook metadata that includes the version keyword that uses string interpolation" do
    metadata_file('patch = 3\nversion "1.2.#{patch}"')
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook metadata that includes the version keyword that is not a string literal" do
    metadata_file('v = "1.2.3"\nversion v')
    it { is_expected.not_to violate_rule }
  end
end
