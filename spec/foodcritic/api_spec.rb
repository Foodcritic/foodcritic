require_relative '../spec_helper'

describe FoodCritic::Api do

  let(:api) { Object.new.extend(FoodCritic::Api) }

  describe "#attribute_access" do
    let(:ast) { MiniTest::Mock.new }
    it "returns empty if the provided ast does not support XPath" do
      api.attribute_access(nil, :type => :vivified).must_be_empty
    end
    it "returns empty if the provided ast has no matches" do
      ast.expect :xpath, [], [String]
      [:vivified, :string, :symbol].each do |access_type|
        api.attribute_access([], :type => :vivified).must_be_empty
      end
    end
    it "raises if the specified node type is not recognised" do
      ast.expect :xpath, [], [String]
      lambda do
        api.attribute_access(ast, :type => :cymbals)
      end.must_raise(ArgumentError)
    end
    it "does not raise if the specified node type is valid" do
      ast.expect :xpath, [], [String, FoodCritic::Api::AttFilter]
      [:vivified, :symbol, :string].each do |access_type|
        api.attribute_access(ast, :type => access_type)
      end
    end
    it "returns vivified attributes access" do
      call = MiniTest::Mock.new
      call.expect :xpath, [], [/args_add_block/]
      call.expect :xpath, ["node", "bar"], [/ident/]
      ast.expect :xpath, [call], [String, FoodCritic::Api::AttFilter]
      api.attribute_access(ast, :type => :vivified).must_equal([call])
      ast.verify
      call.verify
    end
  end

  describe "#checks_for_chef_solo?" do
    let(:ast) { ast = MiniTest::Mock.new }
    it "raises if the provided ast does not support XPath" do
      lambda{api.checks_for_chef_solo?(nil)}.must_raise(ArgumentError)
    end
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

  describe "#cookbook_name" do
    it "raises if passed a nil" do
      lambda{api.cookbook_name(nil)}.must_raise ArgumentError
    end
    it "raises if passed an empty string" do
      lambda{api.cookbook_name('')}.must_raise ArgumentError
    end
    it "returns the cookbook name when passed a recipe" do
      recipe_path = 'cookbooks/apache2/recipes/default.rb'
      api.cookbook_name(recipe_path).must_equal 'apache2'
    end
    it "returns the cookbook name when passed the cookbook metadata" do
      api.cookbook_name('cookbooks/apache2/metadata.rb').must_equal 'apache2'
    end
    it "returns the cookbook name when passed a template" do
      erb_path = 'cookbooks/apache2/templates/default/a2ensite.erb'
      api.cookbook_name(erb_path).must_equal 'apache2'
    end
  end

  describe "#declared_dependencies" do
    it "raises if the ast does not support XPath" do
      lambda{api.declared_dependencies(nil)}.must_raise ArgumentError
    end
    it "returns an empty if there are no declared dependencies" do
      ast = MiniTest::Mock.new.expect :xpath, [], [String]
      api.declared_dependencies(ast).must_be_empty
    end
    it "includes only cookbook names in the returned array" do
      ast = Nokogiri::XML(%q{
            <command>
              <ident value="depends">
                <pos line="14" column="0"/>
              </ident>
              <args_add_block value="false">
                <args_add>
                  <args_add>
                    <args_new/>
                    <string_literal>
                      <string_add>
                        <string_content/>
                        <tstring_content value="mysql">
                          <pos line="14" column="9"/>
                        </tstring_content>
                      </string_add>
                    </string_literal>
                  </args_add>
                  <string_literal>
                    <string_add>
                      <string_content/>
                      <tstring_content value="&gt;= 1.2.0">
                        <pos line="14" column="18"/>
                      </tstring_content>
                    </string_add>
                  </string_literal>
                </args_add>
              </args_add_block>
            </command>
      })
      api.declared_dependencies(ast).must_equal ['mysql']
    end
  end

  describe "#file_match" do
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

  describe "#find_resources" do
    let(:ast) { MiniTest::Mock.new }
    it "returns empty unless the ast supports XPath" do
      api.find_resources(nil).must_be_empty
    end
    it "restricts by resource type when provided" do
      ast.expect :xpath, ['method_add_block'],
        ["//method_add_block[command/ident[@value='file']]" +
         "[command/ident/@value != 'action']"]
      api.find_resources(ast, :type => 'file')
      ast.verify
    end
    it "does not restrict by resource type when not provided" do
      ast.expect :xpath, ['method_add_block'],
                         ["//method_add_block[command/ident]" +
                          "[command/ident/@value != 'action']"]
      api.find_resources(ast)
      ast.verify
    end
    it "allows resource type to be specified as :any" do
      ast.expect :xpath, ['method_add_block'],
                         ["//method_add_block[command/ident]" +
                          "[command/ident/@value != 'action']"]
      api.find_resources(ast, :type => :any)
      ast.verify
    end
    it "returns any matches" do
      ast.expect :xpath, ['method_add_block'], [String]
      api.find_resources(ast).must_equal ['method_add_block']
    end
  end

  describe "#included_recipes" do
    it "raises if the ast does not support XPath" do
      lambda{api.included_recipes(nil)}.must_raise ArgumentError
    end
    it "returns an empty hash if there are no included recipes" do
      ast = MiniTest::Mock.new.expect :xpath, [], [String]
      api.included_recipes(ast).keys.must_be_empty
    end
    it "returns a hash keyed by recipe name" do
      ast = MiniTest::Mock.new.expect :xpath, [{'value' => 'foo::bar'}],
        [String]
      api.included_recipes(ast).keys.must_equal ['foo::bar']
    end
    it "returns a hash where the values are the matching nodes" do
      ast = MiniTest::Mock.new.expect :xpath, [{'value' => 'foo::bar'}],
        [String]
      api.included_recipes(ast).values.must_equal [[{'value' => 'foo::bar'}]]
    end
  end

  describe :AttFilter do
    describe "#is_att_type" do
      let(:filter) { FoodCritic::Api::AttFilter.new }
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
         {'name' => 'pos', 'line' => '3', 'column' => '16'}],
           ['descendant::pos'])
      match = api.match(node)
      match[:line].must_equal(1)
      match[:column].must_equal(10)
    end
    describe :matched_node_name do
      let(:node) do
        node = MiniTest::Mock.new
        node.expect :xpath, [{'name' => 'pos', 'line' => '1',
                              'column' => '10'}], ['descendant::pos']
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

  describe "#notifications" do
    def parse_ast(str)
      ast = api.send(:build_xml, Ripper::SexpBuilder.new(str).parse)
    end
    it "returns empty if the provided AST does not support XPath" do
      api.notifications(nil).must_be_empty
    end
    it "returns empty if there are no notifications" do
      api.notifications(parse_ast(%q{
          template "/etc/nscd.conf" do
            source "nscd.conf"
            owner "root"
            group "root"
          end
      })).must_be_empty
    end
    describe "malformed syntax" do
      it "returns empty if no notifies value is provided" do
        api.notifications(parse_ast(%q{
          template "/etc/nscd.conf" do
            source "nscd.conf"
            owner "root"
            group "root"
            notifies
          end
        })).must_be_empty
      end
      it "returns empty if only the action is provided" do
        api.notifications(parse_ast(%q{
          template "/etc/nscd.conf" do
            source "nscd.conf"
            owner "root"
            group "root"
            notifies :restart
          end
        })).must_be_empty
      end
      describe "returns empty if the service name is missing" do
        it "old-style notifications" do
          api.notifications(parse_ast(%q{
            template "/etc/nscd.conf" do
              source "nscd.conf"
              owner "root"
              group "root"
              notifies :restart, resources(:service)
            end
          })).must_be_empty
        end
        it "new-style notifications" do
          api.notifications(parse_ast(%q{
            template "/etc/nscd.conf" do
              source "nscd.conf"
              owner "root"
              group "root"
              notifies :restart, "service"
            end
          })).must_be_empty
        end
      end
      describe "returns empty if the resource type is missing" do
        it "old-style notifications" do
          api.notifications(parse_ast(%q{
            template "/etc/nscd.conf" do
              source "nscd.conf"
              owner "root"
              group "root"
              notifies :restart, resources("nscd")
            end
          })).must_be_empty
        end
        it "new-style notifications" do
          api.notifications(parse_ast(%q{
            template "/etc/nscd.conf" do
              source "nscd.conf"
              owner "root"
              group "root"
              notifies :restart, "nscd"
            end
          })).must_be_empty
        end
      end
    end
    it "understands the old-style notifications" do
      api.notifications(parse_ast(%q{
        template "/etc/nscd.conf" do
          source "nscd.conf"
          owner "root"
          group "root"
          notifies :restart, resources(:service => "nscd")
        end
      })).must_equal(
        [{
          :type => :notifies,
          :action => :restart,
          :resource_type => :service,
          :resource_name => 'nscd',
          :notification_timing => :delayed
        }]
      )
    end
    it "understands the new-style notifications" do
      api.notifications(parse_ast(%q{
        template "/etc/nscd.conf" do
          source "nscd.conf"
          owner "root"
          group "root"
          notifies :restart, "service[nscd]"
        end
      })).must_equal(
        [{
          :type => :notifies,
          :action => :restart,
          :resource_type => :service,
          :resource_name => 'nscd',
          :notification_timing => :delayed
        }]
      )
    end
    it "understands the old-style notifications with timing" do
      api.notifications(parse_ast(%q{
        template "/etc/nscd.conf" do
          source "nscd.conf"
          owner "root"
          group "root"
          notifies :restart, resources(:service => "nscd"), :immediately
        end
      })).must_equal(
        [{
          :type => :notifies,
          :action => :restart,
          :resource_type => :service,
          :resource_name => 'nscd',
          :notification_timing => :immediately
        }]
      )
    end
    it "understands the new-style notifications with timing" do
      api.notifications(parse_ast(%q{
        template "/etc/nscd.conf" do
          source "nscd.conf"
          owner "root"
          group "root"
          notifies :restart, "service[nscd]", :immediately
        end
      })).must_equal(
        [{
          :type => :notifies,
          :action => :restart,
          :resource_type => :service,
          :resource_name => 'nscd',
          :notification_timing => :immediately
        }]
      )
    end
    describe "can be passed an individual resource" do
      it "old-style notifications" do
        api.notifications(api.find_resources(parse_ast(%q{
          service "nscd" do
            action :start
          end
          template "/etc/nscd.conf" do
            source "nscd.conf"
            owner "root"
            group "root"
            notifies :restart, resources(:service => "nscd")
          end
        }), :type => :template).first).must_equal([
          {:type => :notifies, :action => :restart, :resource_type => :service,
           :resource_name => 'nscd', :notification_timing => :delayed}
        ])
      end
      it "new-style notifications" do
        api.notifications(api.find_resources(parse_ast(%q{
          service "nscd" do
            action :start
          end
          template "/etc/nscd.conf" do
            source "nscd.conf"
            owner "root"
            group "root"
            notifies :restart, "service[nscd]"
          end
        }), :type => :template).first).must_equal([
          {:type => :notifies, :action => :restart, :resource_type => :service,
           :resource_name => 'nscd', :notification_timing => :delayed}
        ])
      end
    end
    describe "supports multiple notifications on a single resource" do
      it "old-style notifications" do
        api.notifications(parse_ast(%q{
          template "/etc/nscd.conf" do
            source "nscd.conf"
            owner "root"
            group "root"
            notifies :stop, resources(:service => "nscd")
            notifies :start, resources(:service => "nscd")
          end
        })).must_equal(
          [
            {:type => :notifies, :action => :stop, :resource_type => :service,
             :resource_name => 'nscd', :notification_timing => :delayed},
            {:type => :notifies, :action => :start, :resource_type => :service,
             :resource_name => 'nscd', :notification_timing => :delayed}
          ]
        )
      end
      it "new-style notifications" do
        api.notifications(parse_ast(%q{
          template "/etc/nscd.conf" do
            source "nscd.conf"
            owner "root"
            group "root"
            notifies :stop, "service[nscd]"
            notifies :start, "service[nscd]"
          end
        })).must_equal(
          [
            {:type => :notifies, :action => :stop, :resource_type => :service,
             :resource_name => 'nscd', :notification_timing => :delayed},
            {:type => :notifies, :action => :start, :resource_type => :service,
             :resource_name => 'nscd', :notification_timing => :delayed}
          ]
        )
      end
    end
    describe "understands style notifications for an execute resource" do
      it "old-style notifications" do
        api.notifications(parse_ast(%q{
          template "/tmp/foo.bar" do
            source "foo.bar.erb"
            notifies :run, resources(:execute => "foo")
          end
        })).must_equal(
          [{:type => :notifies, :action => :run, :resource_type => :execute,
           :resource_name => 'foo', :notification_timing => :delayed}]
        )
      end
      it "old-style notifications" do
        api.notifications(parse_ast(%q{
          template "/tmp/foo.bar" do
            source "foo.bar.erb"
            notifies :run, "execute[foo]"
          end
        })).must_equal(
          [{:type => :notifies, :action => :run, :resource_type => :execute,
           :resource_name => 'foo', :notification_timing => :delayed}]
        )
      end
    end
    describe "sets the notification timing to delayed if specified" do
      it "old-style notifications" do
        api.notifications(parse_ast(%q{
          template "/etc/foo.conf" do
            notifies :run, resources(execute => "robespierre"), :delayed
          end
        })).first[:notification_timing].must_equal(:delayed)
      end
      it "new-style notifications" do
        api.notifications(parse_ast(%q{
          template "/etc/foo.conf" do
            notifies :run, "execute[robespierre]", :delayed
          end
        })).first[:notification_timing].must_equal(:delayed)
      end
    end
    describe "sets the notification timing to immediately if specified" do
      it "old-style notifications" do
        api.notifications(parse_ast(%q{
          template "/etc/foo.conf" do
            notifies :run, resources(execute => "robespierre"), :immediately
          end
        })).first[:notification_timing].must_equal(:immediately)
      end
      it "new-style notifications" do
        api.notifications(parse_ast(%q{
          template "/etc/foo.conf" do
            notifies :run, "execute[robespierre]", :immediately
          end
        })).first[:notification_timing].must_equal(:immediately)
      end
    end
  end

  describe "#os_command?" do
    it "identifies grep as an os command" do
      assert api.os_command?('grep pattern file')
    end
    it "identifies which as an os command" do
      assert api.os_command?('which ls')
    end
    it "assumes any pipe is a unix pipe" do
      assert api.os_command?('ls | grep foo')
    end
    it "assumes a single word is an os command" do
      assert api.os_command?('ls')
    end
    it "identifies a single character flag as an os command" do
      assert api.os_command?('ls -l')
    end
    it "identifies a long flag as an os command" do
      assert api.os_command?('curl --basic')
    end
  end

  describe "#read_ast" do
    it "raises if the file cannot be read" do
      lambda {api.read_ast(nil)}.must_raise(TypeError)
    end
  end

  describe "#resource_attribute" do
    let(:resource) do
      Class.new do
        def xpath(str)
          raise "Not expected"
        end
      end.new
    end
    it "raises if the resource does not support XPath" do
      lambda{api.resource_attribute(nil, "mode")}.must_raise ArgumentError
    end
    it "raises if the attribute name is empty" do
      lambda{api.resource_attribute(resource, "")}.must_raise ArgumentError
    end
  end

  describe "#resource_attributes" do
    def str_to_atts(str)
      ast = api.send(:build_xml, Ripper::SexpBuilder.new(str).parse)
      api.resource_attributes(api.find_resources(ast).first)
    end
    it "raises if the resource does not support XPath" do
      lambda{api.resource_attributes(nil)}.must_raise ArgumentError
    end
    it "returns an empty if the resource has no attributes" do
      resource = MiniTest::Mock.new.expect :xpath, [], [String]
      api.resource_attributes(resource).must_equal({})
    end
    it "returns a string value for a literal string" do
      atts = str_to_atts(%q{
        directory "/foo/bar" do
          owner "root"
        end
      })
      atts['owner'].wont_be_nil
      atts['owner'].must_equal 'root'
    end
    it "returns a truthy value for a literal true" do
      atts = str_to_atts(%q{
        directory "/foo/bar" do
          recursive true
        end
      })
      atts['recursive'].wont_be_nil
      atts['recursive'].must_equal true
    end
    it "returns a truthy value for a literal false" do
      atts = str_to_atts(%q{
        directory "/foo/bar" do
          recursive false
        end
      })
      atts['recursive'].wont_be_nil
      atts['recursive'].must_equal false
    end
    describe "block attributes" do
      it "includes attributes with brace block values in the result" do
        atts = str_to_atts(%q{
          file "/etc/foo" do
            mode "0600"
            action :create
            only_if { File.exists?("/etc/bar") }
          end
        })
        atts['only_if'].wont_be_nil
        atts['only_if'].must_respond_to :xpath
        atts['only_if'].name.must_equal 'brace_block'
      end
      it "includes attributes with do block values in the result" do
        atts = str_to_atts(%q{
          file "/etc/foo" do
            mode "0600"
            action :create
            only_if do
              !File.exists?(foo) || (File.exists?(bar) &&
                File.mtime(baz) < last_changedate)
            end
          end
        })
        atts['only_if'].wont_be_nil
        atts['only_if'].must_respond_to :xpath
        atts['only_if'].name.must_equal 'do_block'
      end
      it "supports multiple block attributes" do
        atts = str_to_atts(%q{
          file "/etc/foo" do
            mode "0600"
            action :create
            only_if { false }
            not_if { true }
          end
        })
        atts['only_if'].wont_be_nil
        atts['only_if'].must_respond_to :xpath
        atts['only_if'].name.must_equal 'brace_block'
        atts['not_if'].wont_be_nil
        atts['not_if'].must_respond_to :xpath
        atts['not_if'].name.must_equal 'brace_block'
      end
      it "includes top-level blocks only" do
        atts = str_to_atts(%q{
          ruby_block "example" do
            block do
              foo do |bar|
                Chef::Log.info(bar)
              end
            end
            only_if { true }
            not_if { false }
          end
        })
        atts.keys.wont_include 'foo'
        atts['block'].wont_be_nil
        atts['block'].must_respond_to :xpath
        atts['block'].name.must_equal 'do_block'
        atts['only_if'].wont_be_nil
        atts['only_if'].must_respond_to :xpath
        atts['only_if'].name.must_equal 'brace_block'
        atts['not_if'].wont_be_nil
        atts['not_if'].must_respond_to :xpath
        atts['not_if'].name.must_equal 'brace_block'
      end
      it "includes notifications in the result" do
        atts = str_to_atts(%q{
          template "/etc/httpd.conf" do
            notifies :restart, "service[apache]"
          end
        })
        atts['notifies'].wont_be_nil
        atts['notifies'].must_respond_to :xpath
        atts['notifies'].name.must_equal 'args_add_block'
      end
      it "includes old-style notifications in the result" do
        atts = str_to_atts(%q{
          template "/etc/httpd.conf" do
            notifies :restart, resources(:service => "apache")
          end
        })
        atts['notifies'].wont_be_nil
        atts['notifies'].must_respond_to :xpath
        atts['notifies'].name.must_equal 'args_add_block'
      end
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

  describe "#resources_by_type" do
    it "raises if the ast does not support XPath" do
      lambda{api.resources_by_type(nil)}.must_raise ArgumentError
    end
    it "returns an empty hash if there are no resources" do
      ast = MiniTest::Mock.new.expect :xpath, [], [String]
      api.resources_by_type(ast).keys.must_be_empty
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

  describe "#ruby_code?" do
    it "says a nil is not ruby code" do
      refute api.ruby_code?(nil)
    end
    it "says an empty string is not ruby code" do
      refute api.ruby_code?('')
    end
    it "coerces arguments to a string" do
      assert api.ruby_code?(%w{foo bar})
    end
    it "returns true for a snippet of ruby code" do
      assert api.ruby_code?("assert api.ruby_code?(nil)")
    end
    it "returns false for a unix command" do
      refute api.ruby_code?("find -type f -print")
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

  describe "#standard_cookbook_subdirs" do
    it "is enumerable" do
      api.standard_cookbook_subdirs.each{|s| s}
    end
    it "is sorted in alphabetical order" do
      api.standard_cookbook_subdirs.must_equal(
        api.standard_cookbook_subdirs.sort)
    end
    it "includes the directories generated by knife create cookbook" do
      %w{attributes definitions files libraries providers recipes resources
         templates}.each do |dir|
         api.standard_cookbook_subdirs.must_include dir
      end
    end
    it "does not include the spec directory" do
      api.standard_cookbook_subdirs.wont_include 'spec'
    end
    it "does not include a subdirectory of a subdirectory" do
      api.standard_cookbook_subdirs.wont_include 'default'
    end
  end

end
