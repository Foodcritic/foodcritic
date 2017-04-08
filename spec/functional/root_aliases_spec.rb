require "spec_helper"

fdescribe "root aliases" do
  context "with a recipe root alias" do
    file "recipe.rb", "log node[:foo]\n"
    it { is_expected.to violate_rule("FC001") }
  end

  context "with an attributes root alias" do
    file "attributes.rb", "default[:foo] = 1\n"
    it { is_expected.to violate_rule("FC001") }
  end
end
