require_relative '../spec_helper'

describe FoodCritic::Helpers do

  let(:api) { Object.new.extend(FoodCritic::Helpers) }

  describe "#match" do
    it "raises if the provided node is nil" do
      lambda{api.match(nil)}.must_raise(ArgumentError)
    end
    it "raises if the provided node does not support XPath" do
      lambda{api.match(Object.new)}.must_raise(ArgumentError)
    end
    it "returns nil if there is no nested position node" do
      node = MiniTest::Mock.new
      node.expect :xpath, [], ['descendant::pos']
      api.match(node).must_be_nil
    end
    it "uses the position of the first position node if there are multiple" do
      node = MiniTest::Mock.new
      node.expect(:xpath,
        [{'name' => 'pos', 'line' => '1', 'column' => '10'},
         {'name' => 'pos', 'line' => '3', 'column' => '16'}], ['descendant::pos'])
      match = api.match(node)
      match[:line].must_equal(1)
      match[:column].must_equal(10)
    end
    describe :matched_node_name do
      let(:node) do
        node = MiniTest::Mock.new
        node.expect :xpath, [{'name' => 'pos', 'line' => '1', 'column' => '10'}],
          ['descendant::pos']
        node
      end
      it "includes the name of the node in the match" do
        node.expect :name, 'command'
        api.match(node).must_equal({:matched => 'command', :line => 1,
                                    :column => 10})
      end
      it "sets the matched name to empty if the element does not have a name" do
        api.match(node).must_equal({:matched => '', :line => 1, :column => 10})
      end
    end
  end

  describe :file_match do
    it "includes the provided filename in the match" do
      api.file_match("foo.rb")[:filename].must_equal "foo.rb"
    end
    it "retains the full provided filename path in the match" do
      api.file_match("foo/bar/foo.rb")[:filename].must_equal "foo/bar/foo.rb"
    end
    it "raises an error if the provided filename is nil" do
      lambda{api.file_match(nil)}.must_raise(ArgumentError)
    end
    it "sets the line and column to the beginning of the file" do
      match = api.file_match("bar.rb")
      match[:line].must_equal 1
      match[:column].must_equal 1
    end
  end

  describe "#checks_for_chef_solo?" do
    let(:ast) { ast = MiniTest::Mock.new }
    it "returns false if there is no reference to chef solo" do
      ast.expect :xpath, [], [String]
      refute api.checks_for_chef_solo?(ast)
    end
    it "returns true if there is one reference to chef solo" do
      ast.expect :xpath, ['aref'], [String]
      assert api.checks_for_chef_solo?(ast)
    end
    it "returns true if there are multiple references to chef solo" do
      ast.expect :xpath, ['aref', 'aref'], [String]
      assert api.checks_for_chef_solo?(ast)
    end
  end
  describe "#chef_solo_search_supported?" do
    it "returns false if the recipe path is nil" do
      refute api.chef_solo_search_supported?(nil)
    end
    it "returns false if the recipe path does not exist" do
      refute api.chef_solo_search_supported?('/tmp/non-existent-path')
    end
  end
  describe "#searches" do
    let(:ast) { ast = MiniTest::Mock.new }
    it "returns empty if the AST does not support XPath expressions" do
      api.searches('not-an-ast').must_be_empty
    end
    it "returns empty if the AST has no elements" do
      ast.expect :xpath, [], [String]
      api.searches(ast).must_be_empty
    end
    it "returns the AST elements for each use of search" do
      ast.expect :xpath, ['ident'], [String]
      api.searches(ast).must_equal ['ident']
    end
  end
  describe "#literal_searches" do
    let(:ast) { ast = MiniTest::Mock.new }
    it "returns empty if the AST does not support XPath expressions" do
      api.literal_searches(nil).must_be_empty
    end
    it "returns empty if the AST has no elements" do
      ast.expect :xpath, [], [String]
      api.literal_searches(ast).must_be_empty
    end
    it "returns the AST elements for each literal search" do
      ast.expect :xpath, ['tstring_content'], [String]
      api.literal_searches(ast).must_equal ['tstring_content']
    end
  end
  describe :AttFilter do
    describe "#is_att_type" do
      let(:filter) { FoodCritic::Helpers::AttFilter.new }
      it "returns empty if the argument is not enumerable" do
        filter.is_att_type(nil).must_be_empty
      end
      it "filters out values that are not Chef node attribute types" do
        nodes = %w{node node badger default override ostrich set normal}
        filter.is_att_type(nodes).uniq.size.must_equal 5
      end
      it "returns all filtered nodes" do
        nodes = %w{node node override default normal set set override}
        filter.is_att_type(nodes).must_equal nodes
      end
      it "returns empty if there are no Chef node attribute types" do
        nodes = %w{squirrel badger pooh tigger}
        filter.is_att_type(nodes).must_be_empty
      end
    end
  end
  describe "#attribute_access" do
    let(:ast) { ast = MiniTest::Mock.new }
    it "returns empty if the provided ast does not support XPath" do
      api.attribute_access(nil, :vivified, false).must_be_empty
    end
    it "returns empty if the provided ast has no matches" do
      ast.expect :xpath, [], [String]
      [:vivified, :string, :symbol].each do |access_type|
        api.attribute_access([], :vivified, false).must_be_empty
      end
    end
    it "raises if the specified node type is not recognised" do
      ast.expect :xpath, [], [String]
      lambda do
        api.attribute_access(ast, :cymbals, false)
      end.must_raise(ArgumentError)
    end
    it "does not raise if the specified node type is valid" do
      ast.expect :xpath, [], [String, FoodCritic::Helpers::AttFilter]
      [:vivified, :symbol, :string].each do |access_type|
        api.attribute_access(ast, access_type, false)
      end
    end
  end
  describe "#find_resources" do
    let(:ast) { MiniTest::Mock.new }
    it "returns empty unless the ast supports XPath" do
      api.find_resources(nil, nil).must_be_empty
    end
    it "restricts by resource type when provided" do
      ast.expect :xpath, ['method_add_block'],
        ["//method_add_block[command/ident[@value='file']]"]
      api.find_resources(ast, 'file')
      ast.verify
    end
    it "does not restrict by resource type when not provided" do
      ast.expect :xpath, ['method_add_block'],
                         ["//method_add_block[command/ident]"]
      api.find_resources(ast, nil)
      ast.verify
    end
    it "returns any matches" do
      ast.expect :xpath, ['method_add_block'], [String]
      api.find_resources(ast, nil).must_equal ['method_add_block']
    end
  end
  describe "#resource_type" do
    it "raises if the resource does not support XPath" do
      lambda {api.resource_type(nil)}.must_raise ArgumentError
    end
    it "raises if the resource type cannot be determined" do
      ast = MiniTest::Mock.new
      ast.expect :xpath, '', [String]
      lambda {api.resource_type(ast)}.must_raise ArgumentError
    end
    it "returns the resource type for a resource" do
      ast = MiniTest::Mock.new
      ast.expect :xpath, 'directory', [String]
      api.resource_type(ast).must_equal 'directory'
    end
  end
  describe "#resource_name" do
    it "raises if the resource does not support XPath" do
      lambda {api.resource_name('foo')}.must_raise ArgumentError
    end
    it "returns the resource name for a resource" do
      ast = MiniTest::Mock.new
      ast.expect :xpath, 'bob', [String]
      api.resource_name(ast).must_equal 'bob'
    end
  end
  describe "#resource_attributes" do
    it "raises if the resource does not support XPath" do
      lambda{api.resource_attributes(nil)}.must_raise ArgumentError
    end
  end
  describe "#resources_by_type" do
    it "raises if the ast does not support XPath" do
      lambda{api.resources_by_type(nil)}.must_raise ArgumentError
    end
    it "returns an empty hash if there are no resources" do
      ast = MiniTest::Mock.new.expect :xpath, [], [String]
      api.resources_by_type(ast).keys.must_be_empty
    end
  end
  describe "#resource_attributes_by_type" do
    it "raises if the ast does not support XPath" do
      lambda{api.resource_attributes_by_type(nil)}.must_raise ArgumentError
    end
    it "returns an empty hash if there are no resources" do
      ast = MiniTest::Mock.new.expect :xpath, [], [String]
      api.resource_attributes_by_type(ast).keys.must_be_empty
    end
  end
end
