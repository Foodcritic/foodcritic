require "spec_helper"

describe "FC011" do
  context "with a cookbook with a README.md file" do
    metadata_file "name 'mycookbook'"
    file("README.md")
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook without a README.md file" do
    metadata_file "name 'mycookbook'"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a README.rdoc file" do
    metadata_file "name 'mycookbook'"
    file("README.rdoc")
    it { is_expected.to violate_rule }
  end
end
