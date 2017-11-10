require "spec_helper"

describe "FC106" do
  context "with a cookbook with a recipe that specifies the group in a user resource" do
    recipe_file <<-EOF
    user 'bob' do
      group '1234'
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that specifies the gid in a user resource" do
    library_file <<-EOF
    user 'bob' do
      gid '1234'
    end
    EOF
    it { is_expected.to_not violate_rule }
  end
end
