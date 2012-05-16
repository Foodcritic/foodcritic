require_relative '../spec_helper'

describe FoodCritic::CommandLine do
  it "is instantiable" do
    FoodCritic::CommandLine.new([]).wont_be_nil
  end

  describe "#cookbook_paths" do
    it "retuns an empty array if no paths are specified" do
      FoodCritic::CommandLine.new([]).cookbook_paths.must_be_empty
    end

    it "returns a single item array for a specified directory" do
      FoodCritic::CommandLine.new(["example"]).cookbook_paths.must_equal ["example"]
    end

    it "returns multiple items for multiple specified directories" do
      FoodCritic::CommandLine.new(["example", "another_example"]).cookbook_paths.must_equal ["example", "another_example"]
    end

    it "ignores known arguments" do
      FoodCritic::CommandLine.new(["example", "--context"]).cookbook_paths.must_equal ["example"]
    end
  end

  describe "#valid_paths?" do
    it "returns false if no paths are specified" do
      refute FoodCritic::CommandLine.new([]).valid_paths?
    end

    it "returns true if the specified directory exists" do
      assert FoodCritic::CommandLine.new(["lib"]).valid_paths?
    end

    it "returns false if the specified directory does not exist" do
      refute FoodCritic::CommandLine.new(["lib2"]).valid_paths?
    end

    it "returns true if the specified file exists" do
      assert FoodCritic::CommandLine.new(["lib/foodcritic.rb"]).valid_paths?
    end

    it "returns true if both specified paths exist" do
      assert FoodCritic::CommandLine.new(["lib", "lib/foodcritic.rb"]).valid_paths?
    end

    it "returns false if any on the specified paths do not exist" do
      refute FoodCritic::CommandLine.new(["lib", "lib2"]).valid_paths?
    end
  end
end
