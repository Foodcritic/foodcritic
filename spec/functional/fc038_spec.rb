require "spec_helper"

describe "FC038" do

  context "on chef 12.6.4 with a cookbook that locks an apt_package" do
    foodcritic_command("--chef-version", "13.6.4 ", "--no-progress", ".")
    recipe_file <<-EOH
    apt_package 'foo' do
      action :lock
    end
    EOH
    it { is_expected.not_to violate_rule }
  end

  # todo: update this when we introduce a new action
  # we can't actually test this since we haven't introduced any new actions
  # in the chef 13 cycle

  # context "on chef 12.15.19 with a cookbook that locks an apt_package" do
  #   foodcritic_command("--chef-version", "12.15.19", "--no-progress", ".")
  #   recipe_file <<-EOH
  #   apt_package 'foo' do
  #     action :lock
  #   end
  #   EOH
  #   it { is_expected.to violate_rule }
  # end
end
