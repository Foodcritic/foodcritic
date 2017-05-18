require "spec_helper"

describe "FC088" do
  context "with a cookbook with a library that uses Chef::Mixin::Command" do
    library_file 'include Chef::Mixin::Command'
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a resource that uses Chef::Mixin::Command" do
    resource_file 'include Chef::Mixin::Command'
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a resource that uses Bob::Mixin::Command" do
    resource_file 'include Bob::Mixin::Command'
    it { is_expected.not_to violate_rule }
  end
end
