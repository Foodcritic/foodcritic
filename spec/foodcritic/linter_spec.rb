require_relative '../spec_helper'

describe FoodCritic::Linter do

  it "is instantiable" do
    FoodCritic::Linter.new.wont_be_nil
  end

  it "raises if a cookbook path is not provided" do
    linter = FoodCritic::Linter.new
    lambda {linter.check(nil, {})}.must_raise(ArgumentError)
  end

end
