require "spec_helper"

describe "FC110" do
  context "with a cookbook with a script resource that uses command" do
    resource_file <<-EOF
    bash 'foo' do
      command 'cat /etc/passwd'
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a script resource that uses code" do
    resource_file <<-EOF
    bash 'foo' do
      code 'cat /etc/passwd'
    end
    EOF
    it { is_expected.not_to violate_rule }
  end
end
