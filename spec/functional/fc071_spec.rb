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

  context "with a cookbook without a LICENSE file but with license of 'All Rights Reserved'" do
    metadata_file "license 'All Rights Reserved'"
    it { is_expected.not_to violate_rule("FC071") }
  end

  context "with a cookbook without a LICENSE file but with license of 'all rights reserved'" do
    metadata_file "license 'all rights reserved'"
    it { is_expected.not_to violate_rule("FC071") }
  end

  context "with a cookbook without a LICENSE file, using a sub folder" do
    subject { foodcritic_command("--no-progress", "mycookbook/") }
    file "mycookbook/metadata.rb"
    it { is_expected.to violate_rule("FC071") }
  end

  context "with a cookbook without a LICENSE file but with license of 'All Rights Reserved', using a sub folder" do
    subject { foodcritic_command("--no-progress", "mycookbook/") }
    file "mycookbook/metadata.rb", "license 'All Rights Reserved'"
    it { is_expected.not_to violate_rule("FC071") }
  end
end
