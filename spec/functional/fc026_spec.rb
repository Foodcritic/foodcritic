require "spec_helper"

describe "FC026" do
  context "with a recipe that has a bracketed conditional that shouldn't be in a block" do
    recipe_file <<-EOH
      file 'foo' do
        not_if { "ls foo" }
      end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that has a conditional that shouldn't be in a block" do
    recipe_file <<-EOH
      file 'foo' do
        not_if do "ls foo" end
      end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that has a conditional with a variable that shouldn't be in a block" do
    recipe_file <<-EOH
      file 'foo' do
        only_if { "ls \#{node['foo']['path']}" }
      end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that has a conditional with a method that shouldn't be in a block" do
    recipe_file <<-EOH
      file 'foo' do
        not_if { "ls \#{foo.method()}" }
      end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that has a conditional of foo.bar" do
    recipe_file <<-EOH
      file 'foo' do
        only_if { foo.bar }
      end
    EOH
    it { is_expected.not_to violate_rule }
  end

  context "with a recipe that has a conditional of foo.to_s" do
    recipe_file <<-EOH
      file 'foo' do
        not_if { foo.to_s }
      end
    EOH
    it { is_expected.not_to violate_rule }
  end

  context "with a recipe that has a conditional of File.exists?('/etc/foo')" do
    recipe_file <<-EOH
      file 'foo' do
        not_if { File.exists?("/etc/foo") }
      end
    EOH
    it { is_expected.not_to violate_rule }
  end
end
