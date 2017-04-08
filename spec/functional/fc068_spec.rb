require "spec_helper"

describe "FC068" do
  context "with a cookbook with a metadata file that does not specify the license" do
    metadata_file "name 'my_cookbook'"
    it { is_expected.to violate_rule("FC068") }
  end

  context "with a cookbook with a metadata file that specifies a license (anything)" do
    metadata_file "license 'My Super Cool License'"
    it { is_expected.to_not violate_rule("FC068") }
  end
end
