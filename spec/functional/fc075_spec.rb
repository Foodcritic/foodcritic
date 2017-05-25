require "spec_helper"

describe "FC075" do

  context "with a cookbook with recipe that uses node.save" do
    recipe_file "node.save"
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with recipe that doesn't use node.save" do
    recipe_file
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with recipe that includes node['save']" do
    recipe_file("node['save']")
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with a library that uses node.save" do
    library_file <<-EOH
      module CookbookHelper
        def some_method
          node.save
        end
      end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a custom resource that uses node.save" do
    resource_file <<-EOH
      property :name, String, name_property: true

      action :create do
        node.save
      end
    EOH
    it { is_expected.to violate_rule }
  end
end
