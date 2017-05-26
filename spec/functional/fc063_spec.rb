require "spec_helper"

describe "FC063" do
  context "with a cookbook with a metadata file that depends on itself" do
    metadata_file "name 'something'\ndepends 'something'"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a metadata file that depends on a cookbook, but not itself" do
    metadata_file "name 'something'\ndepends 'another_thing'"
    it { is_expected.to_not violate_rule }
  end

  context "with a cookbook with a metadata file that doesn't depend on any cookbooks" do
    metadata_file "name 'something'"
    it { is_expected.to_not violate_rule }
  end
end
