require "spec_helper"

describe "FC041" do
  context "with a recipe that contains an execute resource to run curl" do
    recipe_file <<-EOH
  execute 'curl "http://www.chef.io/"' do
    action :run
  end
  EOH
    it { is_expected.to_not violate_rule }
  end

  context "with a recipe that contains an execute resource to run which curl" do
    recipe_file <<-EOH
  execute 'which curl' do
    action :run
  end
  EOH
    it { is_expected.to_not violate_rule }
  end

  context "with a recipe that contains an execute resource to run wget" do
    recipe_file <<-EOH
  execute 'wget "http://www.chef.io/"' do
    action :run
  end
  EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource to run sudo wget" do
    recipe_file <<-EOH
  execute 'sudo wget "http://www.chef.io/"' do
    action :run
  end
  EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource to curl with -o" do
    recipe_file <<-EOH
  execute "curl 'http://example.org/' -o foo" do
    action :run
  end
  EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource to curl with a post request" do
    recipe_file <<-EOH
  execute "curl -X POST 'http://example.org/'" do
    action :run
  end
  EOH
    it { is_expected.to_not violate_rule }
  end

  context "with a recipe that contains an execute resource to curl with --output" do
    recipe_file <<-EOH
  execute "curl 'http://example.org/' --output foo" do
    action :run
  end
  EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource to curl with --output" do
    recipe_file <<-EOH
  execute "curl 'http://example.org/' --output foo" do
    action :run
  end
  EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource to curl then redirect stdout" do
    recipe_file <<-EOH
  execute "curl 'http://example.org/' > foo" do
    action :run
  end
  EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource to curl then redirect stdout/stderr" do
    recipe_file <<-EOH
  execute "curl 'http://example.org/' &> foo" do
    action :run
  end
  EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource to run something & wget" do
    recipe_file <<-EOH
  execute "mkdir bob && wget 'http://example.org/'" do
    action :run
  end
  EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource with command run sudo wget" do
    recipe_file <<-EOH
  execute 'my command' do
    command 'sudo wget "http://www.chef.io/"'
    action :run
  end
  EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource with command run which curl" do
    recipe_file <<-EOH
  execute 'my command' do
    command 'which curl'
  end
  EOH
    it { is_expected.to_not violate_rule }
  end
end
