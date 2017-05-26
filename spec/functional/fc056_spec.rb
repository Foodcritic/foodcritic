require "spec_helper"

describe "FC056" do
  context "with a cookbook with a metadata file that does not specify a maintainer_email" do
    metadata_file
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a metadata file that specifies a maintainer_email" do
    metadata_file "maintainer_email 'foo@example.com'"
    it { is_expected.to_not violate_rule }
  end

  context "with a cookbook with a metadata file that specifies a maintainer_email as an expression" do
    metadata_file("maintainer_email an(expression)")
    it { is_expected.to_not violate_rule }
  end
end
