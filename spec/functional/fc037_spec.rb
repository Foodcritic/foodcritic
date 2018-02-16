require "spec_helper"

describe "FC037" do
  context "with a resource that notifies using an action that is a string" do
    recipe_file <<-EOF
    file '/tmp/b.txt' do
      content 'content'
      notifies 'restart', 'service[httpd]', :delayed
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a resource that notifies using an action as a symbol" do
    recipe_file <<-EOF
    file '/tmp/a.txt' do
      content 'content'
      notifies :restart, 'service[httpd]', :delayed
    end
    EOF
    it { is_expected.not_to violate_rule }
  end

  context "with a resource that notifies using an action that is an attribute" do
    recipe_file <<-EOF
    file '/tmp/a.txt' do
      content 'content'
      notifies node['foo']['bar'], 'service[httpd]', :delayed
    end
    EOF
    it { is_expected.not_to violate_rule }
  end

  context "with a resource that notifies using an action that is a resource property" do
    recipe_file <<-EOF
    file '/tmp/a.txt' do
      content 'content'
      notifies new_resource.bob, 'service[httpd]', :delayed
    end
    EOF
    it { is_expected.not_to violate_rule }
  end

  context "with a resource that notifies using an action that is a variable" do
    recipe_file <<-EOF
      file '/tmp/a.txt' do
        content 'content'
        notifies foo, 'service[httpd]', :delayed
      end
      EOF
    it { is_expected.not_to violate_rule }
  end

  context "with a resource that notifies with a variable in a loop" do
    recipe_file <<-EOF
      file '/tmp/a.txt' do
        content 'content'
        Array(node['foo']['bar']).each do |action|
          notifies action, 'service[httpd]', :delayed
        end
      end
      EOF
    it { is_expected.not_to violate_rule }
  end
end
