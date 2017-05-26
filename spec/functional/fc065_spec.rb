require "spec_helper"

describe "FC065" do
  context "with a cookbook with a metadata file that does not specify source_url" do
    metadata_file
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a metadata file that specifies a source_url" do
    metadata_file "source_url 'http://wwww.something.com/'"
    it { is_expected.to_not violate_rule }
  end
end
