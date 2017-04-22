require "spec_helper"

describe "FC081" do
  context "with a cookbook with a metadata file that depends on partial_search cookbook" do
    metadata_file <<-META
     name 'my_cookbook'
     depends 'partial_search'
     META
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a metadata file that depends on partial_search cookbook and others" do
    metadata_file <<-META
     name 'my_cookbook'
     depends 'partial_search'
     depends 'windows'
     META
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a metadata file that depends on no cookbooks" do
    metadata_file "name 'my_cookbook'"
    it { is_expected.not_to violate_rule }
  end
end
