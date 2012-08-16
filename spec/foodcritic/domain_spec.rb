require_relative '../spec_helper'

describe FoodCritic::Review do
  it "is instantiable with no warnings" do
    FoodCritic::Review.new('example', [], false)
  end
  describe "#cookbook_path" do
    it "returns the cookbook path provided" do
      FoodCritic::Review.new('example', [], false).cookbook_path.must_equal 'example'
    end
    it "returns a scalar cookbook path even if provided as an array" do
      FoodCritic::Review.new(['example'], [], false).cookbook_path.must_equal 'example'
    end
    it "returns the first cookbook path if multiple have been provided" do
      FoodCritic::Review.new(['example', 'example2'], [], false).cookbook_path.must_equal 'example'
    end
  end
  describe "#cookbook_paths" do
    it "returns the cookbook paths provided" do
      FoodCritic::Review.new(['example'], [], false).cookbook_paths.must_equal ['example']
    end
    it "returns the cookbook paths provided when there are multiple" do
      FoodCritic::Review.new(['example', 'example2'], [], false).cookbook_paths.must_equal ['example', 'example2']
    end
  end
  describe "#warnings" do
    it "returns empty when there are no warnings" do
      FoodCritic::Review.new('example', [], false).warnings.must_be_empty
    end
    it "makes the warnings available" do
      warning = 'Danger Will Robinson'
      FoodCritic::Review.new('example', [warning], false).warnings.must_equal [warning]
    end
  end
  describe "#quieter_warnings" do
    it "returns empty when there are no warnings" do
      ignore_file = ""
      FoodCritic::Review.new('example', [], false, ignore_file).quieter_warnings.must_be_empty
    end
  end
end
