require "spec_helper"

describe "FC025" do
  context "with a recipe that does a blockless gem_package install" do
    recipe_file <<-EOH
      gem_package 'foo'
    EOH
    it { is_expected.not_to violate_rule }
  end

  context "with a recipe that does a gem_package install" do
    recipe_file <<-EOH
      gem_package 'foo' do
        action :install
    EOH
    it { is_expected.not_to violate_rule }
  end

  context "with a recipe that does a gem_package install with a nothing action" do
    recipe_file <<-EOH
      gem_package 'foo' do
        action :nothing
    EOH
    it { is_expected.not_to violate_rule }
  end

  context "with a recipe that does a compile_time gem install from an array" do
    recipe_file <<-EOH
    %w{bencode i18n transmission-simple}.each do |pkg|
      r = gem_package pkg do
        action :nothing
      end
      r.run_action(:install)
    end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that does a compile_time gem install" do
    recipe_file <<-EOH
    r = gem_package "activesupport" do
      version '2.3.11'
      action :nothing
    end
    r.run_action(:install)
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that does a compile_time gem upgrade" do
    recipe_file <<-EOH
    r = gem_package "activesupport" do
      version '2.3.11'
      action :nothing
    end
    r.run_action(:upgrade)
    EOH
    it { is_expected.to violate_rule }
  end
end
