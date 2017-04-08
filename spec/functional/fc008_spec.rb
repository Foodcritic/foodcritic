require "spec_helper"

describe "FC008" do
  context "with a cookbook with a metadata file containing boilerplate maintainer from knife CLI" do
    metadata_file "maintainer 'YOUR_COMPANY_NAME'"
    it { is_expected.to violate_rule("FC008") }
  end

  context "with a cookbook with a metadata file containing boilerplate maintainer from chef CLI" do
    metadata_file "maintainer 'The Authors'"
    it { is_expected.to violate_rule("FC008") }
  end

  context "with a cookbook with a metadata file containing boilerplate maintainer_email from knife CLI" do
    metadata_file "maintainer_email 'YOUR_EMAIL'"
    it { is_expected.to violate_rule("FC008") }
  end

  context "with a cookbook with a metadata file containing boilerplate maintainer_email from chef CLI" do
    metadata_file "maintainer_email 'you@example.com'"
    it { is_expected.to violate_rule("FC008") }
  end

  context "with a cookbook with a metadata file containing non-boilerplate maintainer and maintainer_email" do
    metadata_file "maintainer 'John Smith'\nmaintainer_email 'john@smith.com'"
    it { is_expected.not_to violate_rule("FC008") }
  end

  context "with a cookbook with a metadata file not containing maintainer or maintainer_email" do
    metadata_file
    it { is_expected.not_to violate_rule("FC008") }
  end
end
