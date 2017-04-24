require "spec_helper"

describe "FC084" do
  context "with a cookbook with a recipe that includes Chef::REST" do
    recipe_file 'Chef::REST::RESTRequest.new(:GET, "http://foo.com", nil).call'
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a library that includes Chef::REST" do
    recipe_file <<-EOF
      def response
        response = Chef::REST::RESTRequest.new(:GET, 'http://foo.com', nil).call
      end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a LWRP that includes Chef::REST" do
    recipe_file <<-EOF
      action :doit do
        Chef::REST::RESTRequest.new(:GET, 'http://foo.com', nil).call
      end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a recipe that includes Chef::ServerAPI" do
    recipe_file "server_conn = Chef::ServerAPI.new"
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with a library that includes Chef::ServerAPI" do
    recipe_file <<-EOF
      def server_conn
        server_conn = Chef::ServerAPI.new
      end
    EOF
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with a LWRP that includes Chef::ServerAPI" do
    recipe_file <<-EOF
      action :doit do
        Chef::ServerAPI.new
      end
    EOF
    it { is_expected.not_to violate_rule }
  end
end
