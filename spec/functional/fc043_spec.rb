require "spec_helper"

describe "FC043" do
  context "with a cookbook that has no notifications" do
    recipe_file <<-EOH
      cookbook_file "something"
    EOH
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with a resource that notifies a service to restart" do
    recipe_file <<-EOH
    template "/etc/apache.conf" do
      notifies :start, "service[apache]"
    end
    EOH
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with a resource that uses the old notification syntax" do
    recipe_file <<-EOH
    template "/etc/www/configures-apache.conf" do
      notifies :restart, resources(:service => "apache")
    end
    EOH
    it { is_expected.to violate_rule }
  end
end
