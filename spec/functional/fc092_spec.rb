require "spec_helper"

describe "FC092" do
  context "with a cookbook with a custom resource that defines actions" do
    resource_file <<-EOF
    actions :create

    action :create do
      puts "something"
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a custom resource that doesn't define actions" do
    resource_file <<-EOF
    action :create do
      puts "something"
    end
    EOF
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with a LWRP that defines actions" do
    resource_file <<-EOF
    actions :create
    default_action :create
    EOF
    it { is_expected.not_to violate_rule }
  end
end
