require 'spec_helper'

describe 'FC050' do
  context 'with a role' do
    foodcritic_command('--no-progress', '-R', 'roles')
    let(:role_name) { '' }
    file('roles/webserver.rb') { "name '#{role_name}'\nrun_list ['recipe[apache]']" }

    context 'with name webserver' do
      let(:role_name) { 'webserver' }
      it { is_expected.to_not violate_rule }
    end

    context 'with name web_server' do
      let(:role_name) { 'web_server' }
      it { is_expected.to_not violate_rule }
    end

    context 'with name web-server' do
      let(:role_name) { 'web-server' }
      it { is_expected.to_not violate_rule }
    end

    context 'with name webserver123' do
      let(:role_name) { 'webserver123' }
      it { is_expected.to_not violate_rule }
    end

    context 'with name Webserver' do
      let(:role_name) { 'Webserver' }
      it { is_expected.to_not violate_rule }
    end

    context 'with name web server' do
      let(:role_name) { 'web server' }
      it { is_expected.to violate_rule }
    end

    context 'with name webserver%' do
      let(:role_name) { 'webserver%' }
      it { is_expected.to violate_rule }
    end
  end

  context 'with an environment' do
    foodcritic_command('--no-progress', '-E', 'environments')
    let(:environment_name) { '' }
    file('environments/production.rb') { "name '#{environment_name}'\ncookbook 'apache2'" }

    context 'with name production' do
      let(:environment_name) { 'production' }
      it { is_expected.to_not violate_rule }
    end

    context 'with name pre_production' do
      let(:environment_name) { 'pre_production' }
      it { is_expected.to_not violate_rule }
    end

    context 'with name production-eu' do
      let(:environment_name) { 'production-eu' }
      it { is_expected.to_not violate_rule }
    end

    context 'with name production2' do
      let(:environment_name) { 'production2' }
      it { is_expected.to_not violate_rule }
    end

    context 'with name Production' do
      let(:environment_name) { 'Production' }
      it { is_expected.to_not violate_rule }
    end

    context 'with name EU West' do
      let(:environment_name) { 'EU West' }
      it { is_expected.to violate_rule }
    end

    context 'with name production (eu-west)' do
      let(:environment_name) { 'production (eu-west)' }
      it { is_expected.to violate_rule }
    end
  end
end
