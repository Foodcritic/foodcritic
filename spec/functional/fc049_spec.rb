require 'spec_helper'

describe 'FC049' do
  foodcritic_command('--no-progress', '-R', 'roles')

  context 'with webserver.rb' do
    context 'with name webserver' do
      file 'roles/webserver.rb', 'name "webserver"'
      it { is_expected.to_not violate_rule }
    end

    context 'with name apache' do
      file 'roles/webserver.rb', 'name "apache"'
      it { is_expected.to violate_rule }
    end

    context 'with a string expression in the name' do
      file 'roles/webserver.rb', 'name "ap#{ache}"'
      it { is_expected.to_not violate_rule }
    end

    context 'with multiple names' do
      file 'roles/webserver.rb', "name 'apache'\nname 'webserver'"
      it { is_expected.to_not violate_rule }
    end

    context 'with multiple mismatched names' do
      file 'roles/webserver.rb', "name 'webserver'\nname 'apache'"
      it { is_expected.to violate_rule }
    end
  end

  context 'with webserver.json' do
    context 'with name webserver' do
      file 'roles/webserver.json', '{"name": "webserver"}'
      it { is_expected.to_not violate_rule }
    end

    context 'with name apache' do
      file 'roles/webserver.json', '{"name": "apache"}'
      it { is_expected.to_not violate_rule }
    end
  end

  context 'in -B mode' do
    foodcritic_command('--no-progress', '-B', 'roles')
    file 'roles/webserver.rb', 'name "apache"'
    it { is_expected.to_not violate_rule }
  end

  context 'in normal mode' do
    foodcritic_command('--no-progress', 'roles')
    file 'roles/webserver.rb', 'name "apache"'
    it { is_expected.to_not violate_rule }
  end
end

