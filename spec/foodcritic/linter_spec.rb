require_relative '../spec_helper'

describe FoodCritic::Linter do
  let(:linter) { FoodCritic::Linter.new }

  describe "#initialize" do
    it "is instantiable" do
      linter.wont_be_nil
    end
  end

  describe "chef version" do
    it "should be the latest stable version of Chef" do
      FoodCritic::Linter::DEFAULT_CHEF_VERSION.must_equal "11.10.4"
    end
  end

  describe "#check" do

    it "requires a cookbook_path, role_path or environment_path to be specified" do
      lambda{ linter.check({}) }.must_raise ArgumentError
    end

    [:cookbook, :role, :environment].each do |path_type|
      key = "#{path_type}_paths".to_sym
      it "requires a #{path_type}_path by itself not to be nil" do
        lambda{ linter.check(key => nil) }.must_raise ArgumentError
      end
      it "requires a #{path_type}_path by itself not to be empty" do
        lambda{ linter.check(key => []) }.must_raise ArgumentError
      end
      it "accepts a scalar with a single #{path_type} path" do
        linter.check(key => '.')
      end
      it "accepts an array of #{path_type} paths" do
        linter.check(key => ['.'])
      end
      it "returns a review when a #{path_type} path is provided" do
        linter.check(key => ['.']).must_respond_to(:warnings)
      end
    end

  end

  describe "#load_files!" do
    let(:default_rules_file) do
      File.expand_path(File.join(File.dirname(__FILE__), '../../lib/foodcritic/rules.rb'))
    end

    let(:rule_dsl_load_mock) { MiniTest::Mock.new }

    it "should add the default rule file" do
      rule_dsl_load_mock.expect(:call, nil, [[default_rules_file], nil])
      verify_loaded
    end

    it "should include rules found in gems if the :search_gems option is true" do
      gem_rules = ['/path/to/rules1.rb', '/path/to/rules2.rb']
      expected_rules = [default_rules_file, gem_rules].flatten
      rule_dsl_load_mock.expect(:call, nil, [expected_rules, nil])

      metaclass = class << linter; self; end
      metaclass.send(:define_method, :rule_files_in_gems) do
        gem_rules
      end

      verify_loaded :search_gems => true
    end

    it "should include files found in :include_rules option" do
      include_rules = ['/path/to/rules1.rb', '/path/to/rules2.rb']
      expected_rules = [default_rules_file, include_rules].flatten
      rule_dsl_load_mock.expect(:call, nil, [expected_rules, nil])

      verify_loaded :include_rules => include_rules
    end

    def verify_loaded(options = {})
      FoodCritic::RuleDsl.stub :load, rule_dsl_load_mock do
        linter.load_rules! options
      end

      rule_dsl_load_mock.verify
    end

  end

end
