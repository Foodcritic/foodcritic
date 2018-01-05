require "spec_helper"

describe "FC114" do
  context "with a cookbook that uses the legacy Ohai config" do
    library_file <<-EOF
    Ohai::Config[:something]
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook that sets the legacy Ohai config value" do
    library_file <<-EOF
    Ohai::Config[:something] = 'something'
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook that uses the new full form Ohai config" do
    library_file <<-EOF
    Ohai::Config.ohai[:something] = 'something'
    EOF
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook that uses the new short form Ohai config" do
    library_file <<-EOF
    Ohai.config[:something] = 'something'
    EOF
    it { is_expected.not_to violate_rule }
  end
end
