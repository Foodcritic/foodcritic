require "spec_helper"

describe "FC016" do

  context "with a cookbook with a LWRP that includes a default_action" do
    resource_file <<-EOH
      actions :create, :remove
      default_action :create

      attribute :name, String, name_attribute: true
    EOH
    it { is_expected.to_not violate_rule("FC016") }
  end

  context "with a cookbook with a LWRP that includes a non-DSL default_action" do
    resource_file <<-EOH
      actions :create, :remove,

      def initialize(*args)
        super
        @action = :create
      end

      attribute :name, String, name_attribute: true
    EOH
    it { is_expected.to_not violate_rule("FC016") }
  end

  context "with a cookbook with a LWRP that does not include a default_action" do
    resource_file <<-EOH
      actions :create, :remove,

      attribute :name, String, name_attribute: true
    EOH
    it { is_expected.to violate_rule("FC016") }
  end

  context "with a custom resource" do
    resource_file <<-EOH
      property :name, String, name_property: true

      action :create do
        cookbook_file "/etc/something"
      end
    EOH
    it { is_expected.to_not violate_rule("FC016") }
  end
end
