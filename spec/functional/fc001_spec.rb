require "spec_helper"

describe "FC001" do
  context "with a cookbook with a single recipe that reads node attributes via symbols" do
    recipe_file "log node[:foo]\n"
    it { is_expected.to violate_rule("FC001") }
  end

  context "with a cookbook with a single recipe that references the node run_state" do
    recipe_file "node.run_state[:foo]\n"
    it { is_expected.not_to violate_rule("FC001") }
  end

  context "with a cookbook with a single recipe that accesses multiple node attributes via symbols" do
    recipe_file "node[:foo] = 'bar'\nnode[:testing] = 'bar'\n"
    it { is_expected.to violate_rule("FC001") }
  end

  context "with a cookbook with a single recipe that assigns node attributes accessed via symbols to a local variable" do
    recipe_file "baz = node[:foo]\n"
    it { is_expected.to violate_rule("FC001") }
  end

  context "with a cookbook with a single recipe that accesses nested node attributes via symbols" do
    recipe_file "node[:foo][:foo2] = 'bar'\n"
    it { is_expected.to violate_rule("FC001") }
  end

  context "with a cookbook with a single recipe that reads node attributes via strings" do
    recipe_file "log node['foo']\n"
    it { is_expected.to_not violate_rule("FC001") }
  end

  context "with a cookbook with a single recipe that searches based on a node attribute accessed via strings" do
    recipe_file %Q{remote = search(:node, "name:\#{node['drbd']['remote_host']}")[0]\n}
    it { is_expected.to_not violate_rule("FC001") }
  end

  context "with a cookbook with a single recipe that passes node attributes accessed via symbols to a template" do
    recipe_file <<-EOH
      template "/etc/foo" do
        source "foo.erb"
        variables({
          :port => node[:foo][:port],
          :user => node[:foo][:user]
        })
      end
    EOH
    it { is_expected.to violate_rule("FC001").in("recipes/default.rb:4") }
    it { is_expected.to violate_rule("FC001").in("recipes/default.rb:5") }
  end

  context "with a cookbook that declares default attributes via symbols" do
    attributes_file "default[:apache][:dir] = '/etc/apache2'\n"
    it { is_expected.to violate_rule("FC001") }
  end

  context "with a cookbook that declares override attributes via symbols" do
    attributes_file "override[:apache][:dir] = '/etc/apache2'\n"
    it { is_expected.to violate_rule("FC001") }
  end

  context "with a cookbook that declares set attributes via symbols" do
    attributes_file "set[:apache][:dir] = '/etc/apache2'\n"
    it { is_expected.to violate_rule("FC001") }
  end

  context "with a cookbook that declares normal attributes via symbols" do
    attributes_file "normal[:apache][:dir] = '/etc/apache2'\n"
    it { is_expected.to violate_rule("FC001") }
  end
end
