require "spec_helper"

describe "FC040" do
  context "with a recipe that contains an execute resource named 'git pull'" do
    recipe_file <<-EOH
  execute 'git pull' do
    action :run
  end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource named 'git clone'" do
    recipe_file <<-EOH
  execute 'git clone' do
    action :run
  end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource named 'git fetch'" do
    recipe_file <<-EOH
  execute 'git fetch' do
    action :run
  end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource named 'git checkout'" do
    recipe_file <<-EOH
  execute 'git checkout' do
    action :run
  end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource named 'git reset --hard'" do
    recipe_file <<-EOH
  execute 'git reset --hard' do
    action :run
  end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource named 'git show'" do
    recipe_file <<-EOH
  execute 'git show' do
    action :run
  end
    EOH
    it { is_expected.to_not violate_rule }
  end

  context "with a recipe that contains an execute resource named 'echo 'bob' && git show'" do
    recipe_file <<-EOH
  execute "echo 'bob' && git show" do
    action :run
  end
    EOH
    it { is_expected.to_not violate_rule }
  end

  context "with a recipe that contains an execute resource to run 'git clone https://github.com/git/git.git'" do
    recipe_file <<-EOH
  execute "a git command" do
    command 'git clone https://github.com/git/git.git'
    action :run
  end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource to run 'git clone --depth 10 https://github.com/git/git.git'" do
    recipe_file <<-EOH
  execute "a git command" do
    command 'git clone --depth 10 https://github.com/git/git.git'
    action :run
  end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource to run 'get checkout master'" do
    recipe_file <<-EOH
  execute "a git command" do
    command 'git checkout master'
    action :run
  end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource to run 'git reset --hard'" do
    recipe_file <<-EOH
  execute "a git command" do
    command 'git reset hard'
    action :run
  end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource to run 'git pull" do
    recipe_file <<-EOH
  execute "a git command" do
    command 'git pull'
    action :run
  end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource to run 'git fetch origin'" do
    recipe_file <<-EOH
  execute "a git command" do
    command 'git fetch origin'
    action :run
  end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource to run 'git status && git pull   '" do
    recipe_file <<-EOH
  execute "a git command" do
    command 'git status && git pull'
    action :run
  end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a recipe that contains an execute resource to run 'git show'" do
    recipe_file <<-EOH
  execute "a git command" do
    command 'git show'
    action :run
  end
    EOH
    it { is_expected.to_not violate_rule }
  end

  context "with a recipe that contains an execute resource to run 'curl http://github.com/  '" do
    recipe_file <<-EOH
  execute "a git command" do
    command 'curl http://github.com/  '
    action :run
  end
    EOH
    it { is_expected.to_not violate_rule }
  end
end
