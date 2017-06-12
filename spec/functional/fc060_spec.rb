require "spec_helper"

describe "FC060" do
  context "with a cookbook with LWRP with use_inline_resources and with bad action_create" do
    provider_file <<-EOF
    use_inline_resources

    def action_create
      cookbook_file "/etc/something.conf"
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with LWRP without use_inline_resources and with bad action_create" do
    provider_file <<-EOF
    def action_create
      cookbook_file "/etc/something.conf"
    end
    EOF
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with LWRP without use_inline_resources" do
    provider_file <<-EOF
    action :create do
      cookbook_file "/etc/something.conf"
    end
    EOF
    it { is_expected.not_to violate_rule }
  end

  context "with a cookbook with LWRP using use_inline_resources" do
    provider_file <<-EOF
    use_inline_resources

    action :create do
      template "/etc/something.conf" do
        notifies :restart, "service[something]"
      end
    end
    EOF
    it { is_expected.not_to violate_rule }
  end
end
