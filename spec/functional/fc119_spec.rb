require "spec_helper"

describe "FC119" do
  context "with a windows_task resource that uses the :change action" do
    recipe_file <<-EOF
    windows_task 'chef-client' do
      user 'Administrator'
      password 'N3wPassW0Rd'
      command 'chef-client'
      action :change
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a windows_task resource that uses the :create action" do
    recipe_file <<-EOF
    windows_task 'chef-client' do
      user 'Administrator'
      password 'N3wPassW0Rd'
      command 'chef-client'
      action :create
    end
    EOF
    it { is_expected.not_to violate_rule }
  end
end
