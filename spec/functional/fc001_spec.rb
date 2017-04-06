require "spec_helper"

describe "FC001" do
  context "with a cookbook with a single recipe that reads node attributes via symbols" do
    recipe_file "log node[:foo]\n"
    it { is_expected.to violate_rule("FC001") }
  end

  context "with a cookbook with a single recipe that accesses multiple node attributes via symbols" do
    recipe_file "node[:foo] = 'bar'\nnode[:testing] = 'bar'\n"
    it { is_expected.to violate_rule("FC001") }
  end
end
