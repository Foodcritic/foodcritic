require "spec_helper"

describe "FC064" do
  context "with a cookbook with a metadata file that does not specify issues_url" do
    metadata_file
    it { is_expected.to violate_rule("FC064") }
  end

  context "with a cookbook with a metadata file that specifies a issues_url" do
    metadata_file "issues_url 'http://wwww.something.com/'"
    it { is_expected.to_not violate_rule("FC064") }
  end
end
