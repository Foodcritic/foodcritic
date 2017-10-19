require "spec_helper"

describe "FC101" do
  context "with a cookbook with a recipe that includes an deploy resource" do
    recipe_file <<-EOF
      deploy 'private_repo' do
        repo 'git@github.com:acctname/private-repo.git'
        user 'ubuntu'
        deploy_to '/tmp/private_code'
        ssh_wrapper '/tmp/private_code/wrap-ssh4git.sh'
        action :deploy
      end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that doesn't include an deploy resource" do
    recipe_file <<-EOF
      package "foo"
    EOF
    it { is_expected.not_to violate_rule }
  end
end
