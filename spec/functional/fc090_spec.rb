require "spec_helper"

describe "FC090" do

  context "with a cookbook with a metadata file specifying a single invalid supports statement with eq symbol" do
    metadata_file "supports 'centos', '= 7'"
    it { is_expected.to violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying a single invalid supports statement with gt symbol" do
    metadata_file "supports 'centos', '=> 7'"
    it { is_expected.to violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying a single invalid supports statement with gt eq symbol" do
    metadata_file "supports 'centos', '> 7'"
    it { is_expected.to violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying a single invalid supports statement with approx symbol" do
    metadata_file "supports 'centos', '~> 7'"
    it { is_expected.to violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying a single invalid supports statement with lt symbol" do
    metadata_file "supports 'centos', '< 7'"
    it { is_expected.to violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying a single invalid supports statement with lt eq symbol" do
    metadata_file "supports 'centos', '<= 7'"
    it { is_expected.to violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying a single valid supports statement with eq symbol" do
    metadata_file "supports 'centos', '= 7.3'"
    it { is_expected.to_not violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying a single valid supports statement with gt symbol" do
    metadata_file "supports 'centos', '=> 7.3'"
    it { is_expected.to_not violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying a single valid supports statement with gt eq symbol" do
    metadata_file "supports 'centos', '> 7.3'"
    it { is_expected.to_not violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying a single valid supports statement with approx symbol" do
    metadata_file "supports 'centos', '~> 7.3'"
    it { is_expected.to_not violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying a single valid supports statement with lt symbol" do
    metadata_file "supports 'centos', '< 7.3'"
    it { is_expected.to_not violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying a single valid supports statement with lt eq symbol" do
    metadata_file "supports 'centos', '<= 7.3'"
    it { is_expected.to_not violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying a single valid supports statement" do
    metadata_file "supports 'centos', '>= 7.3'"
    it { is_expected.to_not violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying a single valid supports statement" do
    metadata_file "supports 'centos', '>= 7.3'"
    it { is_expected.to_not violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying a single valid supports statement" do
    metadata_file "supports 'centos', '>= 7.3.0'"
    it { is_expected.to_not violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying multiple valid supports statements as an array" do
    metadata_file "%w(ubuntu debian fedora).each do |plat|\nsupports plat\nend"
    it { is_expected.to_not violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying a multiple valid supports statement with os versions" do
    metadata_file "supports 'ubuntu', '>= 16.04'\nsupports 'centos', '>= 7.3'"
    it { is_expected.to_not violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying a single invalid supports statement" do
    metadata_file "supports 'centos', '>= 7'"
    it { is_expected.to violate_rule("FC090") }
  end

  context "with a cookbook with a metadata file specifying a multiple invalid supports statement" do
    metadata_file "supports 'ubuntu', '>= 16.04'\nsupports 'centos', '>= 7'"
    it { is_expected.to violate_rule("FC090") }
  end

end
