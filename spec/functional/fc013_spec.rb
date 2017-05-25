require "spec_helper"

describe "FC013" do
  context "with a cookbook that downloads a file to /tmp" do
    recipe_file <<-EOH
      remote_file "/tmp/large-file.tar.gz" do
        source "http://www.example.org/large-file.tar.gz"
      end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a cookbook that downloads a file to /tmp with an expression" do
    recipe_file <<-'EOH'
      remote_file "/tmp/#{the_file}" do
        source "http://www.example.org/large-file.tar.gz"
      end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a cookbook that downloads a file to a users home directory" do
    recipe_file <<-EOH
      remote_file "/home/ernie/large-file.tar.gz" do
        source "http://www.example.org/large-file.tar.gz"
      end
    EOH
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook that downloads a file to the Chef file cache" do
    recipe_file <<-'EOH'
      remote_file '#{Chef::Config[:file_cache_path]}/large-file.tar.gz' do
        source "http://www.example.org/large-file.tar.gz"
      end
    EOH
    it { is_expected.not_to violate_rule }
  end
end
