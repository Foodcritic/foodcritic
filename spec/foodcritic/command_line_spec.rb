require_relative '../spec_helper'

describe FoodCritic::CommandLine do
  it "is instantiable" do
    FoodCritic::CommandLine.new([]).wont_be_nil
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
