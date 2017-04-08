require "spec_helper"

describe "FC066" do
  context "with a cookbook with a metadata file that does not specify chef_version" do
    metadata_file "name 'my_cookbook'"
    it { is_expected.to violate_rule("FC066") }
  end

  context "with a cookbook with a metadata file that specifies a chef_version" do
    metadata_file "chef_version '>= 12.1'"
    it { is_expected.to_not violate_rule("FC066") }
  end
end
