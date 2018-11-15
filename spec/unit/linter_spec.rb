require "spec_helper"

describe FoodCritic::Linter do
  let(:linter) { FoodCritic::Linter.new }

  describe "#initialize" do
    it "is instantiable" do
      # Check for errors from .new
      linter
    end
  end

  describe "chef version" do
    it "should be the latest stable version of Chef" do
      expect(FoodCritic::Linter::DEFAULT_CHEF_VERSION).to eq "14.7.17"
    end
  end

  describe "#cookbook_dir" do
    it "given a root alias file the cookbook is correctly detected" do
      expect(linter.send(:cookbook_dir, "./cookbook/recipe.rb").to_s).to eq "cookbook"
    end

    it "given the metadata.rb file the cookbook is correctly detected" do
      expect(linter.send(:cookbook_dir, "./cookbook/metadata.rb").to_s).to eq "cookbook"
    end

    it "given a template nested multiple levels deep the cookbook is correctly detected" do
      expect(linter.send(:cookbook_dir, "./cookbook/templates/foo/bar/file.erb").to_s).to eq "./cookbook"
    end

    it "given a template directly in the templates directory the cookbook is correctly detected" do
      expect(linter.send(:cookbook_dir, "./cookbook/templates/file.erb").to_s).to eq "./cookbook"
    end

    it "given a standard recipe file the cookbook is correctly detected" do
      expect(linter.send(:cookbook_dir, "./cookbook/recipes/default.rb").to_s).to eq "cookbook"
    end
  end

  describe "#check" do
    it "requires a cookbook_path, role_path or environment_path to be specified" do
      expect { linter.check({}) }.to raise_error ArgumentError
    end

    [:cookbook, :role, :environment].each do |path_type|
      key = "#{path_type}_paths".to_sym
      it "requires a #{path_type}_path by itself not to be nil" do
        expect { linter.check(key => nil) }.to raise_error ArgumentError
      end
      it "requires a #{path_type}_path by itself not to be empty" do
        expect { linter.check(key => []) }.to raise_error ArgumentError
      end
      it "accepts a scalar with a single #{path_type} path" do
        linter.check(key => ".")
      end
      it "accepts an array of #{path_type} paths" do
        linter.check(key => ["."])
      end
      it "returns a review when a #{path_type} path is provided" do
        expect(linter.check(key => ["."])).to respond_to :warnings
      end
    end
  end

  describe "#list_rules" do
    it "runs when --list is specified on the command line" do
      cli = FoodCritic::CommandLine.new %w{--list -t FC001 --search-gems}
      FoodCritic::Linter.run(cli)
    end

    it "does not require cookbook_path, role_path or environment_path to be specified" do
      linter.list(:list => true)
    end

    it "returns a rule listing" do
      expect(linter.list(:list => true)).to respond_to :rules
    end
  end

  describe "#load_files!" do
    let(:default_rule_files) do
      # an array of each of the absolute paths to the default rules
      Dir.glob(File.expand_path(File.join(File.dirname(__FILE__), "../../lib/foodcritic/rules/*")))
    end

    it "should add the default rule file" do
      expect(FoodCritic::RuleDsl).to receive(:load).with(default_rule_files, nil)
      linter.load_rules!({})
    end

    it "should include rules found in gems if the :search_gems option is true" do
      gem_rules = ["/path/to/rules1.rb", "/path/to/rules2.rb"]
      expected_rules = [*default_rule_files, *gem_rules]
      expect(FoodCritic::RuleDsl).to receive(:load).with(expected_rules, nil)
      expect(linter).to receive(:rule_files_in_gems).and_return(gem_rules)
      linter.load_rules!(:search_gems => true)
    end

    it "should include files found in :include_rules option" do
      include_rules = ["/path/to/rules1.rb", "/path/to/rules2.rb"]
      expected_rules = [*default_rule_files, *include_rules]
      expect(FoodCritic::RuleDsl).to receive(:load).with(expected_rules, nil)
      linter.load_rules!(:include_rules => include_rules)
    end
  end
end
