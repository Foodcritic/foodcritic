require "spec_helper"

describe "FC085" do
  context "with a cookbook with a custom resource that converges with new_resource.updated_by_last_action" do
    resource_file <<-EOF
    action :create do
      template "/etc/something.conf" do
        notifies :restart, "service[something]"
      end

      new_resource.updated_by_last_action(true)
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a LWRP that converges with @new_resource.updated_by_last_action" do
    resource_file <<-EOF
    use_inline_resources

    action :create do
      template "/etc/something.conf" do
        notifies :restart, "service[something]"
      end

      @new_resource.updated_by_last_action(true)
    end
    EOF
    it { is_expected.to violate_rule }
  end

  context "with a cookbook with a custom resource that relies on resources for convergence" do
    resource_file <<-EOF
    action :create do
      file "the_file" do
        template "/etc/something.conf" do
          notifies :restart, "service[something]"
        end
      end
    EOF
    it { is_expected.to_not violate_rule }
  end

  context "with a cookbook with a LWRP that relies on resources for convergence" do
    resource_file <<-EOF
    use_inline_resources

    action :create do
      file "the_file" do
        template "/etc/something.conf" do
          notifies :restart, "service[something]"
        end
      end
    EOF
    it { is_expected.to_not violate_rule }
  end

  context "with a cookbook with a LWRP that calls foo.updated_by_last_action" do
    resource_file <<-EOF
    use_inline_resources

    action :create do
      foo.updated_by_last_action(true)
    EOF
    it { is_expected.to_not violate_rule }
  end

end
