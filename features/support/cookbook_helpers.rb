module FoodCritic

  # Helper cookbook methods for use in your steps.
  module CookbookHelpers

    include FoodCritic::Chef::Search # Needed to load Lucene grammar

    # Create an attributes file that references attributes with symbols
    #
    # @param [String] type The type of node attribute to write
    def attributes_with_symbols(type)
      write_attributes %Q{#{type}[:apache][:dir] = "/etc/apache2"}
    end

    # Create a cookbook that declares dependencies on external recipes.
    #
    # @param [Symbol] declaration_type The type of declaration - :brace or :bracket
    def cookbook_declares_dependencies(declaration_type)
      write_recipe %q{
        include_recipe "foo::default"
        include_recipe "bar::default"
        include_recipe "baz::default"
      }
      if declaration_type == :brace
        write_metadata %q{
          %w{foo bar baz}.each{|cookbook| depends cookbook}
        }
      else
        write_metadata %q{
          %w{foo bar baz}.each do |cb|
            depends cb
          end
        }
      end
    end

    # Create a cookbook that will match the specified rules.
    #
    # @param [Array] codes The codes to match. Only FC002, FC003 and FC004 are supported.
    def cookbook_that_matches_rules(codes)
      recipe = ''
      codes.each do |code|
        if code == 'FC002'
          recipe += %q{
            directory "#{node['base_dir']}" do
              action :create
            end
          }
        elsif code == 'FC003'
          recipe += %Q{nodes = search(:node, "hostname:[* TO *]")\n}
        elsif code == 'FC004'
          recipe += %q{
            execute "stop-jetty" do
              command "/etc/init.d/jetty6 stop"
              action :run
            end
          }
        end
      end
      write_recipe(recipe)
    end

    # Create a cookbook with a LRWP
    #
    # @param [Hash] lwrp The options to use for the created LWRP
    # @option lwrp [Symbol] :default_action One of :no_default_action, :ruby_default_action
    # @option lwrp [Symbol] :notifies One of :does_not_notify, :does_notify, :deprecated_syntax, :class_variable
    def cookbook_with_lwrp(lwrp)
      lwrp = {:default_action => false, :notifies => :does_not_notify}.merge!(lwrp)
      default_action = %q{
        def initialize(*args)
          super
          @action = :create
        end
      }.strip
      write_resource("site", %Q{
        actions :create
        attribute :name, :kind_of => String, :name_attribute => true
        #{default_action if lwrp[:default_action] == :ruby_default_action}
      })
      notifications = {:does_notify => 'new_resource.updated_by_last_action(true)',
                       :deprecated_syntax => 'new_resource.updated = true',
                       :class_variable => '@updated = true'}
      write_provider("site", %Q{
        action :create do
          log "Here is where I would create a site"
          #{notifications[lwrp[:notifies]]}
        end
      })
    end

    # Create an cookbook with the maintainer specified in the metadata
    #
    # @param [String] name The maintainer name
    # @param [String] email The maintainer email address
    def cookbook_with_maintainer(name, email)
      write_recipe %q{
        #
        # Cookbook Name:: example
        # Recipe:: default
        #
        # Copyright 2011, YOUR_COMPANY_NAME
        #
        # All rights reserved - Do Not Redistribute
        #
      }

      fields = {}
      fields['maintainer'] = name unless name.nil?
      fields['maintainer_email'] = email unless email.nil?
      write_metadata %Q{
        #{fields.map{|field,value| %Q{#{field}\t"#{value}"}}.join("\n")}
        license          "All rights reserved"
        description      "Installs/Configures example"
        long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
        version          "0.0.1"
      }
    end

    # Create a recipe that downloads a file
    #
    # @param [Symbol] path_type The type of path, one of: :tmp_dir, :chef_file_cache_dir, :home_dir
    def recipe_downloads_file(path_type)
      download_path = {:tmp_dir => '/tmp/large-file.tar.gz', :home_dir => '/home/ernie/large-file.tar.gz',
                       :chef_file_cache_dir => '#{Chef::Config[:file_cache_path]}/large-file.tar.gz'}[path_type]
      write_recipe %Q{
        remote_file "#{download_path}" do
          source "http://www.example.org/large-file.tar.gz"
        end
      }
    end

    # Create a recipe that declares a resource with the specified file mode.
    #
    # @param [String] type The type of resource (file, template)
    # @param [String] mode The file mode as a string
    def recipe_resource_with_mode(type, mode)
      source_att = type == 'template' ? 'source "foo.erb"' : ''
      write_recipe %Q{
        #{type} "/tmp/something" do
          #{source_att}
          owner "root"
          group "root"
          mode #{mode}
          action :create
        end
      }
    end

    # Create a recipe that starts a service using the specified method.
    #
    # @param [Symbol] method How to start the service, one of: :init_d, :invoke_rc_d, :upstart, :service, :service_full_path.
    # @param [Boolean] do_sleep Whether to prefix the service cmd with a bash sleep
    def recipe_starts_service(method = :service, do_sleep = false)
      cmds = {:init_d => '/etc/init.d/foo start', :invoke_rc_d => 'invoke-rc.d foo start', :upstart => 'start foo',
              :service => 'service foo start', :service_full_path => '/sbin/service foo start'}
      write_recipe %Q{
        execute "start-foo-service" do
          command "#{do_sleep ? 'sleep 5; ' : ''}#{cmds[method]}"
          action :run
        end
      }
    end

    # Create a recipe with an external dependency on another cookbook.
    #
    # @param [Hash] dep The options to use for dependency
    # @option dep [Boolean] :is_declared True if this dependency has been declared in the cookbook metadata
    # @option dep [Boolean] :is_scoped True if the include_recipe references a specific recipe or the cookbook
    def recipe_with_dependency(dep)
      dep = {:is_scoped => true, :is_declared => true}.merge!(dep)
      write_recipe %Q{
        include_recipe 'foo#{dep[:is_scoped] ? '::default' : ''}'
      }
      write_metadata %Q{
        version "1.9.0"
        depends "#{dep[:is_declared] ? 'foo' : 'dogs'}"
      }
    end

    # Create a recipe with a directory resource
    #
    # @param [Symbol] path_expr_type The type of path expression, one of: :compound_symbols, :interpolated_string,
    #   :interpolated_symbol, :interpolated_symbol_and_literal, :literal_and_interpolated_symbol, :string_literal.
    def recipe_with_dir_path(path_expr_type)
      path = {:compound_symbols => '#{node[:base_dir]}#{node[:sub_dir]}', :interpolated_string => %q{#{node['base_dir']}},
              :interpolated_symbol => '#{node[:base_dir]}', :interpolated_symbol_and_literal => '#{node[:base_dir]}/sub_dir',
              :literal_and_interpolated_symbol => 'base_dir/#{node[:sub_dir]}', :string_literal => '/var/lib/foo' }[path_expr_type]
      write_recipe %Q{
        directory "#{path}" do
          owner "root"
          group "root"
          mode "0755"
          action :create
        end
      }
    end

    # Create a recipe with the specified resource type and attribute names.
    #
    # @param [String] type The type of resource
    # @param [Array] attribute_names The attributes to declare on this resource
    def recipe_with_resource(type, attribute_names)
      write_recipe %Q{
        #{type} "resource-name" do
          #{attribute_names.join(" 'foo'\n")} 'bar'
        end
      }
    end

    # Create a recipe with a ruby_block resource.
    #
    # @param [Boolean] is_short Is this a short block?
    def recipe_with_ruby_block(is_short)
      if is_short
        write_recipe %q{
          ruby_block "reload_client_config" do
            block do
              Chef::Config.from_file("/etc/chef/client.rb")
            end
            action :create
          end
        }
      else
        write_recipe %q{
          ruby_block "too_long" do
            block do
              begin
                do_something('with argument')
                do_something_else('with another argument')
                foo = Foo.new('bar')
                foo.activate_turbo_boost
                foo.each do |thing|
                  case thing
                  when "fee"
                    puts 'Fee'
                  when "fi"
                    puts 'Fi'
                  when "fo"
                    puts 'Fo'
                  else
                    puts "Fum"
                  end
                end
              rescue Some::Exception
                Chef::Log.warn "Problem activating the turbo boost"
              end
            end
            action :create
          end
        }
      end
    end

    # Create a recipe that performs a search of the specified type.
    #
    # @param [Symbol] type The type of search. One of: :invalid_syntax, :valid_syntax, :with_subexpression.
    def recipe_with_search(type)
      search = {:invalid_syntax => 'run_list:recipe[foo::bar]', :valid_syntax => 'run_list:recipe\[foo\:\:bar\]',
                :with_subexpression => %q{roles:#{node['foo']['role']}}}[type]
      write_recipe %Q{
        search(:node, "#{search}") do |matching_node|
          puts matching_node.to_s
        end
      }
    end

    # Return the provided string or nil if 'unspecified'
    #
    # @param [String] str The string
    # @return [String] The string or nil if 'unspecified'
    def nil_if_unspecified(str)
      str == 'unspecified' ? nil : str
    end

    # Create a recipe with the provided content.
    #
    # @param [String] content The recipe content.
    # @param [String] cookbook_name Optional name of the cookbook.
    def write_recipe(content, cookbook_name = 'example')
      write_file "cookbooks/#{cookbook_name}/recipes/default.rb", content.strip
    end

    # Create attributes with the provided content.
    #
    # @param [String] content The attributes content.
    def write_attributes(content)
      write_file 'cookbooks/example/attributes/default.rb', content.strip
    end

    # Create a definition with the provided content.
    #
    # @param [String] name The definition name.
    # @param [String] content The definition content.
    def write_definition(name, content)
      write_file "cookbooks/example/definitions/#{name}.rb", content.strip
    end

    # Create a library with the provided content.
    #
    # @param [String] name The library name.
    # @param [String] content The library content.
    def write_library(name, content)
      write_file "cookbooks/example/libraries/#{name}.rb", content.strip
    end

    # Create metdata with the provided content.
    #
    # @param [String] content The metadata content.
    def write_metadata(content)
      write_file 'cookbooks/example/metadata.rb', content.strip
    end

    # Create a resource with the provided content.
    #
    # @param [String] name The resource name.
    # @param [String] content The resource content.
    def write_resource(name, content)
      write_file "cookbooks/example/resources/#{name}.rb", content.strip
    end

    # Create a provider with the provided content.
    #
    # @param [String] name The resource name.
    # @param [String] content The resource content.
    def write_provider(name, content)
      write_file "cookbooks/example/providers/#{name}.rb", content.strip
    end

  end

end

World(FoodCritic::CookbookHelpers)
