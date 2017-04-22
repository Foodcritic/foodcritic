require "spec_helper"

describe "FC082" do
  context "with a cookbook with a recipe that sets an attribute with node.set" do
    recipe_file "node.set['foo']['bar'] = baz"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that sets an attribute with node.set_unless" do
    recipe_file "node.set_unless['foo']['bar'] = baz"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that sets an attribute with node.normal" do
    recipe_file "node.normal['foo']['bar'] = baz"
    it { is_expected.to_not violate_rule }
  end
end
