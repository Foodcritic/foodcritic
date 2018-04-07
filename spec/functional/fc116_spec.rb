require "spec_helper"

describe "FC116" do
  context "with metadata depending on compat_resource" do
    metadata_file "name 'test'\ndepends 'compat_resource'"
    it { is_expected.to violate_rule }
  end

  context "with metadata depending on foo" do
    metadata_file "name 'test'\ndepends 'foo'"
    it { is_expected.to_not violate_rule }
  end

  context "with metadata depending on nothing" do
    metadata_file "name 'test'"
    it { is_expected.to_not violate_rule }
  end
end
