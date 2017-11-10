require "spec_helper"

describe "FC106" do
  context "with a cookbook with a recipe that uses hash in a launchd resource" do
    recipe_file <<-EOF
    launchd 'foo' do
      hash {}
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that uses plist_hash in a launchd  resource" do
    library_file <<-EOF
    launchd 'foo' do
      plist_hash {}
    end
    EOF
    it { is_expected.to_not violate_rule }
  end
end
