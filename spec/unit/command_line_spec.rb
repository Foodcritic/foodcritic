require "spec_helper"

describe FoodCritic::CommandLine do
  it "is instantiable" do
    expect(FoodCritic::CommandLine.new([])).to_not be_nil
  end

  describe "#cookbook_paths" do
    it "returns an empty array if no paths are specified" do
      expect(FoodCritic::CommandLine.new([]).cookbook_paths).to be_empty
    end

    it "returns a single item array for a specified directory" do
      expect(FoodCritic::CommandLine.new(["example"]).cookbook_paths).to eq ["example"]
    end

    it "returns multiple items for multiple specified directories" do
      expect(FoodCritic::CommandLine.new(%w{example another_example}).cookbook_paths).to eq %w{example another_example}
    end

    it "ignores known arguments" do
      expect(FoodCritic::CommandLine.new(["example", "--context"]).cookbook_paths).to eq ["example"]
    end
  end

  describe "#role_paths" do
    it "returns an empty if no role paths are specified" do
      expect(FoodCritic::CommandLine.new([]).role_paths).to be_empty
    end
    it "returns the provided role path" do
      expect(FoodCritic::CommandLine.new(["-R", "roles"]).role_paths).to eq %w{roles}
    end
    it "returns the provided role paths when there are multiple" do
      expect(FoodCritic::CommandLine.new(["-R", "roles1",
        "-R", "roles2"]).role_paths).to eq %w{roles1 roles2}
    end
  end

  describe "#valid_paths?" do
    it "returns false if no paths are specified" do
      expect(FoodCritic::CommandLine.new([]).valid_paths?).to be_falsey
    end

    it "returns true if the specified directory exists" do
      expect(FoodCritic::CommandLine.new(["lib"]).valid_paths?).to be_truthy
    end

    it "returns false if the specified directory does not exist" do
      expect(FoodCritic::CommandLine.new(["lib2"]).valid_paths?).to be_falsey
    end

    it "returns true if the specified file exists" do
      expect(FoodCritic::CommandLine.new(["lib/foodcritic.rb"]).valid_paths?).to be_truthy
    end

    it "returns true if both specified paths exist" do
      expect(FoodCritic::CommandLine.new(["lib", "lib/foodcritic.rb"]).valid_paths?).to be_truthy
    end

    it "returns false if any on the specified paths do not exist" do
      expect(FoodCritic::CommandLine.new(%w{lib lib2}).valid_paths?).to be_falsey
    end
  end

  describe "#list_rules?" do
    it "returns false if ---list is not specified" do
      expect(FoodCritic::CommandLine.new([]).list_rules?).to be_falsey
    end

    it "returns true if --list is specified" do
      expect(FoodCritic::CommandLine.new(["--list"]).list_rules?).to be_truthy
    end
  end

  describe ":progress" do
    it "is true by default" do
      expect(FoodCritic::CommandLine.new(["."]).options[:progress]).to be_truthy
    end

    it "is true if -P is specified" do
      expect(FoodCritic::CommandLine.new(["-P", "."]).options[:progress]).to be_truthy
    end

    it "is true if --progres is specified" do
      expect(FoodCritic::CommandLine.new(["--progress", "."]).options[:progress]).to be_truthy
    end

    it "is false if --no-progress is specified" do
      expect(FoodCritic::CommandLine.new(["--no-progress", "."]).options[:progress]).to be_falsey
    end
  end

  describe ":search_gems" do
    it "is unset if -G/--search-gems is not specified" do
      expect(FoodCritic::CommandLine.new(["."]).options[:search_gems].nil?).to be_truthy
    end

    it "is true if -G is specified" do
      expect(FoodCritic::CommandLine.new(["-G", "."]).options[:search_gems]).to be_truthy
    end

    it "is true if --search-gems is specified" do
      expect(FoodCritic::CommandLine.new(["--search-gems", "."]).options[:search_gems]).to be_truthy
    end
  end

  describe "#show_context?" do
    it "is unset by default" do
      expect(FoodCritic::CommandLine.new(["."]).show_context?).to be_falsey
    end

    it "is true if -C is specified" do
      expect(FoodCritic::CommandLine.new(["-C", "."]).show_context?).to be_truthy
    end
    it "is true if --context is specified" do
      expect(FoodCritic::CommandLine.new(["--context", "."]).show_context?).to be_truthy
    end
    it "is false if --no-context is specified" do
      expect(FoodCritic::CommandLine.new(["--no-context", "."]).show_context?).to be_falsey
    end
  end

  describe ":rule_file" do
    it "is unset if -r/--rule-file is not specified" do
      expect(FoodCritic::CommandLine.new(["."]).options[:rule_file].nil?).to be_truthy
    end

    it "is equal to the provided path if -r is set and path is specified" do
      expect(FoodCritic::CommandLine.new(["-r", "example", "."]).options[:rule_file]).to eq "example"
    end

    it "is equal to the provided path if --rule-file is set and path is specified" do
      expect(FoodCritic::CommandLine.new(["--rule-file", "example", "."]).options[:rule_file]).to eq "example"
    end
  end
end
