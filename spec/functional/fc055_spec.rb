require "spec_helper"

describe "FC055" do
  context "with a cookbook with a metadata file that does not specify a maintainer" do
    metadata_file "name 'my_cookbook'"
    it { is_expected.to violate_rule("FC055") }
  end

  context "with a cookbook with a metadata file that specifies a maintainer" do
    metadata_file "maintainer 'Some Person'"
    it { is_expected.to_not violate_rule("FC055") }
  end

  context "with a cookbook with a metadata file that specifies a maintainer as an expression" do
    metadata_file("maintainer an(expression)")
    it { is_expected.to_not violate_rule("FC055") }
  end
end
