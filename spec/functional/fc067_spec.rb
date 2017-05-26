require "spec_helper"

describe "FC067" do
  context "with a cookbook with a metadata file that does not specify supports" do
    metadata_file "name 'my_cookbook'"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a metadata file that specifies a supported platform (anything)" do
    metadata_file "supports 'some_os'"
    it { is_expected.to_not violate_rule }
  end
end
