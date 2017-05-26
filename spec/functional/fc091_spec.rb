require "spec_helper"

describe "FC091" do
  context "with a cookbook with a custom resource that uses attributes" do
    resource_file <<-EOF
    attribute :source,                String, name_attribute: true
    attribute :headers,               Hash,   default: {}

    action :create do
      puts "something"
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a custom resource that uses properties" do
    resource_file <<-EOF
    property :source,                String, name_property: true
    property :headers,               Hash,   default: {}

    action :create do
      puts "something"
    end
    EOF
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with a LWRP that uses attributes" do
    resource_file <<-EOF
    attribute :source,                String, name_attribute: true
    attribute :headers,               Hash,   default: {}

    actions :create
    default_action :create
    EOF
    it { is_expected.not_to violate_rule }
  end
end
