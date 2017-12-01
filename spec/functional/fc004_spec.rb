require "spec_helper"

describe "FC004" do
  context "using a execute to run a service init script" do
    recipe_file <<-EOH
      execute 'service stuff' do
        command '/etc/init.d/foo start'
        action :run
      end
    EOH
    it { is_expected.to violate_rule }
  end

  context "using a execute to run a invoke-rc.d" do
    recipe_file <<-EOH
      execute 'service stuff' do
        command 'invoke-rc.d foo restart'
        action :run
      end
    EOH
    it { is_expected.to violate_rule }
  end

  %w{reload start stop restart}.each do |command|
    context "using a execute to run an upstart #{command} command" do
      recipe_file <<-EOH
        execute 'service stuff' do
          command "#{command} foo"
          action :run
        end
      EOH
      it { is_expected.to violate_rule }
    end

    context "using a execute to run the upstart service command to #{command}" do
      recipe_file <<-EOH
        execute 'service stuff' do
          command "service foo #{command}"
          action :run
        end
      EOH
      it { is_expected.to violate_rule }
    end

    context "using a execute to run systemcl to #{command}" do
      recipe_file <<-EOH
        execute 'service stuff' do
          command "systemctl #{command} foo"
          action :run
        end
      EOH
      it { is_expected.to violate_rule }
    end
  end

  context "using a execute to run a windows start command" do
    recipe_file <<-EOH
      execute 'Run setup' do
        command 'start /wait my_setup.exe --silent'
      end
    EOH
    it { is_expected.not_to violate_rule }
  end

  context "using a execute to run systemctl daemon-reload" do
    recipe_file <<-EOH
      execute 'Run setup' do
        command 'systemctl daemon-reload'
      end
    EOH
    it { is_expected.not_to violate_rule }
  end

  context "using a execute to run check the contents of an init script" do
    recipe_file <<-EOH
      execute "Configure the scheduler" do
          user "root"
          command 'sed -i "s/\([^/]\)ondemand/\1performace/g" /etc/init.d/ondemand'
          notifies :start, "service[ondemand]"
      end
    EOH
    it { is_expected.not_to violate_rule }
  end
end
