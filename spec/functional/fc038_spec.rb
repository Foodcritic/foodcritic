require "spec_helper"

describe "FC038" do
  context "on chef 12.16.42 with a cookbook that locks an apt_package" do
    foodcritic_command("--chef-version", "12.16.42", "--no-progress", ".")
    recipe_file <<-EOH
    apt_package 'foo' do
      action :lock
    end
    EOH
    it { is_expected.not_to violate_rule }
  end

  context "on chef 12.15.19 with a cookbook that locks an apt_package" do
    foodcritic_command("--chef-version", "12.15.19", "--no-progress", ".")
    recipe_file <<-EOH
    apt_package 'foo' do
      action :lock
    end
    EOH
    it { is_expected.to violate_rule }
  end
end
