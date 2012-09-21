require_relative '../spec_helper'

describe FoodCritic::Linter do

  describe "#initialize" do
    it "is instantiable" do
      FoodCritic::Linter.new.wont_be_nil
    end
    it "raises if a cookbook path is not provided" do
      linter = FoodCritic::Linter.new
      lambda {linter.check(nil, {})}.must_raise(ArgumentError)
    end
  end

  describe "chef version" do
    it "should be the latest stable version of Chef" do
      FoodCritic::Linter::DEFAULT_CHEF_VERSION.must_equal "0.10.10"
    end
  end

  describe "#check" do
    let(:linter) { FoodCritic::Linter.new }
    it "requires a cookbook_path to be provided" do
      lambda{ linter.check(nil, {}) }.must_raise ArgumentError
    end
    it "requires an array of cookbook paths not to be empty" do
      lambda{ linter.check([], {}) }.must_raise ArgumentError
    end
    it "accepts a scalar with a single cookbook path for backwards compatibility" do
      linter.check('.', {})
    end
    it "accepts an array of cookbook paths" do
      linter.check(['.'], {})
    end
    it "returns a review" do
      linter.check(['.'], {}).must_respond_to(:warnings)
    end
    it "does not require an empty hash of options" do
      linter.check(['.'])
    end
  end

end
