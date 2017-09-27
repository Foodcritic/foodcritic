require "spec_helper"

describe "FC093" do
  context "with a README.md file containing generated TODO item" do
    readme_file <<-EOF
    # cookbook

    TODO: Enter the cookbook description here.
    EOF
    metadata_file <<-META
    name 'cookbook'
    META
    it { is_expected.to violate_rule }
  end

  context "with a README.md without generated TODO item" do
    readme_file <<-EOF
    # cookbook

    Some description.
    EOF
    metadata_file <<-META
    name 'cookbook'
    META
    it { is_expected.not_to violate_rule }
  end
end
