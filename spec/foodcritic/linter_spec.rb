require_relative '../spec_helper'

describe FoodCritic::Linter do

  it "should be instantiable" do
    FoodCritic::Linter.new.wont_be_nil
  end

  it "should raise if a cookbook path is not provided" do
    linter = FoodCritic::Linter.new
    lambda {linter.check(nil, {})}.must_raise(ArgumentError)
  end

end
