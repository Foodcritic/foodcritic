require "spec_helper"

describe "FC071" do
  context "with a cookbook with a LICENSE file" do
    metadata_file "name 'mycookbook'"
    file("LICENSE")
    it { is_expected.not_to violate_rule("FC071") }
  end

  context "with a cookbook without a LICENSE file" do
    metadata_file "name 'mycookbook'"
    it { is_expected.to violate_rule("FC071") }
  end
end
