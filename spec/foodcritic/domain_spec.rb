require_relative '../spec_helper'

describe FoodCritic::Review do
  it "is instantiable with no warnings" do
    FoodCritic::Review.new('example', [])
  end
  describe "#cookbook_paths" do
    it "returns the cookbook paths provided" do
      FoodCritic::Review.new(['example'], []).cookbook_paths.must_equal ['example']
    end
    it "returns the cookbook paths provided when there are multiple" do
      FoodCritic::Review.new(['example', 'example2'], []).cookbook_paths.must_equal ['example', 'example2']
    end
  end
  describe "#warnings" do
    it "returns empty when there are no warnings" do
      FoodCritic::Review.new('example', []).warnings.must_be_empty
    end
    it "makes the warnings available" do
      warning = 'Danger Will Robinson'
      FoodCritic::Review.new('example', [warning]).warnings.must_equal [warning]
    end
  end
end

describe FoodCritic::Rule do
  let(:rule) { FoodCritic::Rule.new('FCTEST001', 'Test rule') }

  describe '#matches_tags?' do
    it "matches the rule's code" do
      rule.matches_tags?(['FCTEST001']).must_equal true
    end

    it "doesn't match an unrelated code" do
      rule.matches_tags?(['FCTEST999']).must_equal false
    end
  end

  describe '#tags' do
    it "returns any + the rule's code" do
      rule.tags.must_equal ['any', 'FCTEST001']
    end
  end
end

describe FoodCritic::Warning do
  let(:rule) { FoodCritic::Rule.new('FCTEST001', 'Test rule') }
  let(:match_opts) { {:filename => 'foo/recipes.default.rb', :line => 5, :column=> 40} }

  describe "failure indication" do
    it 'is false if no fail_tags match' do
      FoodCritic::Warning.new(rule, match_opts, {:fail_tags => []}).failed?.must_equal false
    end

    it 'is true if fail_tags do match' do
      FoodCritic::Warning.new(rule, match_opts, {:fail_tags => ['any']}).failed?.must_equal true
    end
  end
end
