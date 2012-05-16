require_relative '../spec_helper'

describe FoodCritic::CommandLine do
  it "is instantiable" do
    FoodCritic::CommandLine.new([]).wont_be_nil
  end

  describe "#valid_paths?" do
    it "returns true if the specified directory exists" do
      assert FoodCritic::CommandLine.new(["lib"]).valid_paths?
    end

    it "returns false if the specified directory does not exist" do
      refute FoodCritic::CommandLine.new(["lib2"]).valid_paths?
    end

    it "returns true if the specified file exists" do
      assert FoodCritic::CommandLine.new(["lib/foodcritic.rb"]).valid_paths?
    end
  end
end
