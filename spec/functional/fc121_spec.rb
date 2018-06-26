require "spec_helper"

describe "FC121" do
  context "with metadata depending on build-essential" do
    metadata_file "name 'test'\ndepends 'build-essential'"
    it { is_expected.to violate_rule }
  end

  context "with metadata depending on swap" do
    metadata_file "name 'test'\ndepends 'swap'"
    it { is_expected.to violate_rule }
  end

  context "with metadata depending on dmg" do
    metadata_file "name 'test'\ndepends 'dmg'"
    it { is_expected.to violate_rule }
  end

  context "with metadata depending on mac_os_x" do
    metadata_file "name 'test'\ndepends 'mac_os_x'"
    it { is_expected.to violate_rule }
  end

  context "with metadata depending on chef_handler" do
    metadata_file "name 'test'\ndepends 'chef_handler'"
    it { is_expected.to violate_rule }
  end

  context "with metadata depending on chef_hostname" do
    metadata_file "name 'test'\ndepends 'chef_hostname'"
    it { is_expected.to violate_rule }
  end

  context "with metadata depending on foo" do
    metadata_file "name 'test'\ndepends 'foo'"
    it { is_expected.to_not violate_rule }
  end

  context "with metadata depending on nothing" do
    metadata_file "name 'test'"
    it { is_expected.to_not violate_rule }
  end
end
