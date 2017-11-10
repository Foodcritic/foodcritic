require "spec_helper"

describe "FC105" do
  context "with a cookbook with a custom resource that includes an erl_call resource" do
    resource_file <<-EOF
    erl_call 'list names' do
      code 'net_adm:names().'
      distributed true
      node_name 'chef@latte'
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that includes an erl_call resource" do
    recipe_file <<-EOF
    erl_call 'list names' do
      code 'net_adm:names().'
      distributed true
      node_name 'chef@latte'
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a library that includes an erl_call resource" do
    library_file <<-EOF
    erl_call 'list names' do
      code 'net_adm:names().'
      distributed true
      node_name 'chef@latte'
    end
    EOF
    it { is_expected.to violate_rule }
  end
end
