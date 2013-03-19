require_relative '../spec_helper'

describe FoodCritic::Linter do
  let(:linter) { FoodCritic::Linter.new }

  describe "#initialize" do
    it "is instantiable" do
      linter.wont_be_nil
    end

    it "raises if a cookbook path is not provided" do
      lambda {linter.check(nil, {})}.must_raise(ArgumentError)
    end
  end

  describe "chef version" do
    it "should be the latest stable version of Chef" do
      FoodCritic::Linter::DEFAULT_CHEF_VERSION.must_equal "0.10.10"
    end
  end

  describe "#check" do
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

  describe "#line_is_ignored_from?" do
    it "does not ignore normal line" do
      linter.send(:line_is_ignored_from?, "X", "X").must_equal false
    end

    it "does not ignore nil" do
      linter.send(:line_is_ignored_from?, nil, "X").must_equal false
    end

    it "does not ignore empty comment" do
      linter.send(:line_is_ignored_from?, "#", "X").must_equal false
    end

    it "ignores single" do
      linter.send(:line_is_ignored_from?, "# ~X", "X").must_equal true
    end

    it "ignores with spacing single" do
      linter.send(:line_is_ignored_from?, "#   ~X", "X").must_equal true
    end

    it "does not ignore invalid" do
      linter.send(:line_is_ignored_from?, "# X", "X").must_equal false
    end

    it "does not ignore unfound in multiple" do
      linter.send(:line_is_ignored_from?, "# ~X,Y", "Z").must_equal false
    end

    it "ignores multiple" do
      linter.send(:line_is_ignored_from?, "# ~X,Y", "Y").must_equal true
    end

    it "ignores multiple with spacing" do
      linter.send(:line_is_ignored_from?, "# ~X, Y", "Y").must_equal true
    end

    it "ignores multiple with repeated ~" do
      linter.send(:line_is_ignored_from?, "# ~X, ~Y", "Y").must_equal true
    end
  end
end
