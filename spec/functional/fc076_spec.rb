require "spec_helper"

describe "FC076" do
  context "with a cookbook with a metadata file that does contain the conflicts keyword" do
    metadata_file "conflicts 'runit'"
    it { is_expected.to violate_rule("FC076") }
  end

  context "with a cookbook with a metadata file that does not contain the conflicts keyword" do
    metadata_file
    it { is_expected.to_not violate_rule("FC076") }
  end
end
