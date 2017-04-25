require "spec_helper"

describe "FC086" do
  context "with a cookbook with a recipe that uses Chef::EncryptedDataBagItem.load_secret" do
    recipe_file 'Chef::EncryptedDataBagItem.load("users", "tsmith", key)'
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that uses Chef::DataBagItem.load" do
    recipe_file 'Chef::DataBagItem.load("users", "tsmith")'
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a resource that uses Chef::EncryptedDataBagItem.load_secret" do
    resource_file <<-EOF
      action :create do
        data = Chef::EncryptedDataBagItem.load("users", "tsmith", key)
      end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a resource that uses Chef::EncryptedDataBagItem.load_secret" do
    resource_file <<-EOF
      action :create do
        data = Chef::DataBagItem.load("users", "tsmith")
      end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a resource that uses data_bag_item" do
    recipe_file "data_bag_item('bag', 'item', IO.read('secret_file'))"
    it { is_expected.not_to violate_rule }
  end
end
