require "spec_helper"

describe FoodCritic::Chef do

  let(:api) { Object.new.extend(FoodCritic::Api) }

  describe "#chef_dsl_methods" do
    it "returns an enumerable" do
      api.chef_dsl_methods.each { |m| m }
    end
    it "does not return an empty" do
      expect(api.chef_dsl_methods).to_not be_empty
    end
    it "returns dsl methods as symbols" do
      expect(api.chef_dsl_methods.all? { |m| m == m.to_sym }).to be_truthy
    end
  end

  describe "#resource_attribute?" do
    it "raises if the resource_type is nil" do
      expect { api.resource_attribute?(nil, :name) }.to raise_error ArgumentError
    end
    it "raises if the resource_type is empty" do
      expect { api.resource_attribute?("", :name) }.to raise_error ArgumentError
    end
    it "raises if the attribute_name is nil" do
      expect { api.resource_attribute?(:file, nil) }.to raise_error ArgumentError
    end
    it "raises if the attribute_name is empty" do
      expect { api.resource_attribute?(:file, "") }.to raise_error ArgumentError
    end
    it "returns true if the resource attribute is known" do
      expect(api.resource_attribute?(:file, :name)).to be_truthy
    end
    it "returns false if the resource attribute is not known" do
      expect(api.resource_attribute?(:file, :size)).to be_falsey
    end
    it "returns true for unrecognised resources" do
      expect(api.resource_attribute?(:cluster_file, :size)).to be_truthy
    end
    it "allows the resource type to be passed as a string" do
      expect(api.resource_attribute?("file", :size)).to be_falsey
    end
    it "allows the attribute_name to be passed as a string" do
      expect(api.resource_attribute?(:file, "mode")).to be_truthy
    end
  end

  describe "#valid_query?" do
    it "raises if the query is nil" do
      expect { api.valid_query?(nil) }.to raise_error ArgumentError
    end
    it "raises if the query is empty" do
      expect { api.valid_query?("") }.to raise_error ArgumentError
    end
    it "coerces the provided object to a string" do
      query = Class.new do
        def to_s
          "*:*"
        end
      end.new
      expect(api.valid_query?(query)).to be_truthy
    end
  end

end
