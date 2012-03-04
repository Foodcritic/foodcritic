require_relative '../spec_helper'

describe FoodCritic::Chef do

  let(:api) { Object.new.extend(FoodCritic::Api) }

  describe "#chef_dsl_methods" do
    it "returns an enumerable" do
      api.chef_dsl_methods.each{|m| m}
    end
    it "does not return an empty" do
      api.chef_dsl_methods.wont_be_empty
    end
    it "returns dsl methods as symbols" do
      assert api.chef_dsl_methods.all?{|m| m == m.to_sym}
    end
  end

  describe "#resource_attribute?" do
    it "raises if the resource_type is nil" do
      lambda{api.resource_attribute?(nil, :name)}.must_raise(ArgumentError)
    end
    it "raises if the resource_type is empty" do
      lambda{api.resource_attribute?('', :name)}.must_raise(ArgumentError)
    end
    it "raises if the attribute_name is nil" do
      lambda{api.resource_attribute?(:file, nil)}.must_raise(ArgumentError)
    end
    it "raises if the attribute_name is empty" do
      lambda{api.resource_attribute?(:file, '')}.must_raise(ArgumentError)
    end
    it "returns true if the resource attribute is known" do
      assert api.resource_attribute?(:file, :name)
    end
    it "returns false if the resource attribute is not known" do
      refute api.resource_attribute?(:file, :size)
    end
    it "returns true for unrecognised resources" do
      assert api.resource_attribute?(:cluster_file, :size)
    end
    it "allows the resource type to be passed as a string" do
      refute api.resource_attribute?("file", :size)
    end
    it "allows the attribute_name to be passed as a string" do
      assert api.resource_attribute?(:file, 'mode')
    end
  end

  describe "#valid_query?" do
    it "raises if the query is nil" do
      lambda{api.valid_query?(nil)}.must_raise(ArgumentError)
    end
    it "raises if the query is empty" do
      lambda{api.valid_query?('')}.must_raise(ArgumentError)
    end
    it "coerces the provided object to a string" do
      query = Class.new do
        def to_s
          '*:*'
        end
      end.new
      assert api.valid_query?(query)
    end
  end

end
