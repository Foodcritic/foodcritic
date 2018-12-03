require "spec_helper"

describe FoodCritic::Review do
  it "is instantiable with no warnings" do
    FoodCritic::Review.new("example", [])
  end
  describe "#cookbook_paths" do
    it "returns the cookbook paths provided" do
      expect(FoodCritic::Review.new(["example"], []).cookbook_paths).to eq ["example"]
    end
    it "returns the cookbook paths provided when there are multiple" do
      expect(FoodCritic::Review.new(%w{example example2}, []).cookbook_paths).to eq %w{example example2}
    end
  end
  describe "#warnings" do
    it "returns empty when there are no warnings" do
      expect(FoodCritic::Review.new("example", []).warnings).to be_empty
    end
    it "makes the warnings available" do
      warning = "Danger Will Robinson"
      expect(FoodCritic::Review.new("example", [warning]).warnings).to eq [warning]
    end
  end
end

describe FoodCritic::RuleList do
  it "is instantiable with no warnings" do
    FoodCritic::RuleList.new([])
  end

  let(:rule) { FoodCritic::Rule.new("FCTEST001", "Test rule") }

  describe "#rules" do

    it "is empty when instantiated with an empty rule list" do
      expect(FoodCritic::RuleList.new([]).rules).to be_empty
    end

    it "contains the given rule" do
      expect(FoodCritic::RuleList.new([rule]).rules).to include rule
    end
  end
end

describe FoodCritic::Rule do
  let(:rule) { FoodCritic::Rule.new("FCTEST001", "Test rule") }

  describe "#matches_tags?" do
    it "matches the rule's code" do
      expect(rule.matches_tags?(["FCTEST001"])).to be_truthy
    end

    it "doesn't match an unrelated code" do
      expect(rule.matches_tags?(["FCTEST999"])).to be_falsey
    end
  end

  describe "#tags" do
    it "returns any + the rule's code" do
      expect(rule.tags).to eq %w{any FCTEST001}
    end
  end
end

describe FoodCritic::Warning do
  let(:rule) { FoodCritic::Rule.new("FCTEST001", "Test rule") }
  let(:match_opts) { { filename: "foo/recipes.default.rb", line: 5, column: 40 } }

  describe "failure indication" do
    it "is false if no fail_tags match" do
      expect(FoodCritic::Warning.new(rule, match_opts, { fail_tags: [] })).to_not be_failed
    end

    it "is true if fail_tags do match" do
      expect(FoodCritic::Warning.new(rule, match_opts, { fail_tags: ["any"] })).to be_failed
    end
  end
end
