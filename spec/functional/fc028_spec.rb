require "spec_helper"

describe "FC028" do
  context "with a cookbook with a single recipe that calls platform? without parentheses for a single platform" do
    recipe_file "platform? 'ubuntu'"
    it { is_expected.not_to violate_rule("FC028") }
  end

  context "with a cookbook with a single recipe that calls platform? without parentheses for two platforms" do
    recipe_file "platform?('ubuntu','windows')"
    it { is_expected.not_to violate_rule("FC028") }
  end

  context "with a cookbook with a single recipe that calls platform? with parentheses for a single platform" do
    recipe_file "platform?('ubuntu')"
    it { is_expected.not_to violate_rule("FC028") }
  end

  context "with a cookbook with a single recipe that calls platform? with parentheses for two platforms" do
    recipe_file "platform?('ubuntu', 'windows')"
    it { is_expected.not_to violate_rule("FC028") }
  end

  context "with a cookbook with a single recipe that compares a value against node.platform" do
    recipe_file "node.platform == 'ubuntu'"
    it { is_expected.not_to violate_rule("FC028") }
  end

  context "with a cookbook with a single recipe that uses checks a value against node.platform" do
    recipe_file "node.platform == 'ubuntu'"
    it { is_expected.not_to violate_rule("FC028") }
  end

  context "with a cookbook with a single recipe that calls node.platform? without a parentheses" do
    recipe_file "node.platform? 'ubuntu'"
    it { is_expected.to violate_rule("FC028") }
  end

  context "with a cookbook with a single recipe that calls node.platform? with a parentheses" do
    recipe_file "node.platform?('ubuntu')"
    it { is_expected.to violate_rule("FC028") }
  end

  context "with a cookbook with a single recipe that calls node.platform? with a parentheses for 2 platforms" do
    recipe_file "node.platform?('ubuntu', 'windows')"
    it { is_expected.to violate_rule("FC028") }
  end

  context "with a cookbook with a single recipe that calls platform_family? without parentheses for a single platform family" do
    recipe_file "platform_family? 'debian'"
    it { is_expected.not_to violate_rule("FC028") }
  end

  context "with a cookbook with a single recipe that calls platform_family? without parentheses for two plaform families" do
    recipe_file "platform_family?('debian','windows')"
    it { is_expected.not_to violate_rule("FC028") }
  end

  context "with a cookbook with a single recipe that calls platform_family? with parentheses for a single plaform family" do
    recipe_file "platform_family?('debian')"
    it { is_expected.not_to violate_rule("FC028") }
  end

  context "with a cookbook with a single recipe that calls platform_family? with parentheses for two plaform families" do
    recipe_file "platform_family?('debian', 'windows')"
    it { is_expected.not_to violate_rule("FC028") }
  end

  context "with a cookbook with a single recipe that compares a value against node.platform_family" do
    recipe_file "node.platform_family == 'debian'"
    it { is_expected.not_to violate_rule("FC028") }
  end

  context "with a cookbook with a single recipe that uses checks a value against node.platform_family" do
    recipe_file "node.platform_family == 'debian'"
    it { is_expected.not_to violate_rule("FC028") }
  end

  context "with a cookbook with a single recipe that calls node.platform_family? without a parentheses" do
    recipe_file "node.platform_family? 'debian'"
    it { is_expected.to violate_rule("FC028") }
  end

  context "with a cookbook with a single recipe that calls node.platform_family? with a parentheses" do
    recipe_file "node.platform_family?('debian')"
    it { is_expected.to violate_rule("FC028") }
  end

  context "with a cookbook with a single recipe that calls node.platform_family? with a parentheses for 2 plaform families" do
    recipe_file "node.platform_family?('debian', 'windows')"
    it { is_expected.to violate_rule("FC028") }
  end
end
