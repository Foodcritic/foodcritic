require "spec_helper"

describe "FC111" do
  context "with a cookbook with a search that uses the deprecated sort flag" do
    resource_file <<-EOF
    search(:node, 'role:web', :sort => true)
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a search that does not use sort" do
    resource_file <<-EOF
    search(:node, 'role:web')
    EOF
    it { is_expected.not_to violate_rule }
  end
end
