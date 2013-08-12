module FoodCritic

  # Helper cookbook methods for use in your steps.
  module CookbookHelpers

    # Create an attributes file that references attributes with symbols
    #
    # @param [String] type The type of node attribute to write
    def attributes_with_symbols(type)
      write_attributes %Q{#{type}[:apache][:dir] = "/etc/apache2"}
    end

    # Create a Gemfile for a cookbook
    def buildable_gemfile
      write_file 'cookbooks/example/Gemfile', %q{
        source 'https://rubygems.org/'
        gem 'rake'
        gem 'foodcritic', :path => '../../../..'
      }
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
        elsif code == 'FC006'
          recipe += %q{
            directory "/var/lib/foo" do
              mode 644
              action :create
            end
          }
        end
      end
      write_recipe(recipe)
      write_file('cookbooks/example/recipes/server.rb', '')
      write_readme('Hello World') # Don't trigger FC011
      write_metadata('name "example"') # Don't trigger FC031
    end

    # Create a cookbook with a LRWP
    #
    # @param [Hash] lwrp The options to use for the created LWRP
    # @option lwrp [Symbol] :default_action One of :no_default_action, :ruby_default_action, :dsl_default_action
    # @option lwrp [Symbol] :notifies One of :does_not_notify, :does_notify, :does_notify_without_parens, :deprecated_syntax, :class_variable
    # @option lwrp [Symbol] :use_inline_resources Defaults to false
    def cookbook_with_lwrp(lwrp)
      lwrp = {:default_action => false, :notifies => :does_not_notify,
              :use_inline_resources => false}.merge!(lwrp)
      ruby_default_action = %q{
        def initialize(*args)
          super
          @action = :create
        end
      }.strip
      write_resource("site", %Q{
        actions :create
        attribute :name, :kind_of => String, :name_attribute => true
        #{ruby_default_action if lwrp[:default_action] == :ruby_default_action}
        #{'default_action :create' if lwrp[:default_action] == :dsl_default_action}
      })
      notifications = {:does_notify => 'new_resource.updated_by_last_action(true)',
                       :does_notify_without_parens => 'new_resource.updated_by_last_action true',
                       :deprecated_syntax => 'new_resource.updated = true',
                       :class_variable => '@updated = true'}
      write_provider("site", %Q{
        #{'use_inline_resources' if lwrp[:use_inline_resources]}
        action :create do
          log "Here is where I would create a site"
          #{notifications[lwrp[:notifies]]}
        end
      })
    end

    def cookbook_with_lwrp_actions(actions)
      write_resource("site", %Q{
        actions #{actions.map{|a| a[:name].inspect}.join(', ')}
        attribute :name, :kind_of => String, :name_attribute => true
      })
      write_provider("site", actions.map{|a| provider_action(a)}.join("\n"))
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

    # Create an environment file
    #
    # @param [Hash] options The options to use for the environment
    # @option options [String] :dir The relative directory to write to
    # @option options [String] :environment_name The name of the environment declared in the file
    # @option options [String] :file_name The containing file relative to the environments directory
    def environment(options={})
      options = {:dir => 'environments'}.merge(options)
      write_file "#{options[:dir]}/#{options[:file_name]}", %Q{
        #{Array(options[:environment_name]).map{|r| "name #{r}"}.join("\n")}
        cookbook "apache2"
      }.strip
    end

    # Create a placeholder minitest spec that would be linted due to its path
    # unless an exclusion is specified.
    def minitest_spec_attributes
      write_file 'cookbooks/example/test/attributes/default_spec.rb', %q{
        describe 'Example::Attributes::Default' do
        end
      }
    end

    def provider_action(action)
      case action[:notify_type]
      when :none then %Q{
        action #{action[:name].inspect} do
          log "Would take action here"
        end
      }
      when :updated_by_last_action then %Q{
        action #{action[:name].inspect} do
          log "Would take action here"
          # Explicitly update
          new_resource.updated_by_last_action(true)
        end
      }
      when :converge_by then %Q{
        action #{action[:name].inspect} do
          converge_by "#{action[:name]} site" do
            log "Would take action here"
          end
        end
      }
      end
    end

    # Create a Rakefile that uses the linter rake task
    #
    # @param [Symbol] task Type of task
    # @param [Hash] options Task options
    # @option options [String] :name Task name
    # @option options [String] :files Files to process
    # @option options [String] :options The options to set on the rake task
    def rakefile(task, options)
      rakefile_content = 'task :default => []'
      task_def = case task
        when :no_block then 'FoodCritic::Rake::LintTask.new'
        else %Q{
          FoodCritic::Rake::LintTask.new do |t|
            #{"t.name = '#{options[:name]}'" if options[:name]}
            #{"t.files = #{options[:files]}" if options[:files]}
            #{"t.options = #{options[:options]}" if options[:options]}
          end
        }
      end
      if task_def
        rakefile_content = %Q{
          require 'foodcritic'
          task :default => [:#{options[:name] ? options[:name] : 'foodcritic'}]
          #{task_def}
        }
      end
      write_file 'cookbooks/example/Rakefile', rakefile_content
    end

    # Create a recipe that downloads a file
    #
    # @param [Symbol] path_type The type of path, one of: :tmp_dir, :chef_file_cache_dir, :home_dir
    def recipe_downloads_file(path_type)
      download_path = {:tmp_dir => '/tmp/large-file.tar.gz',
        :tmp_dir_expr => '/tmp/#{file}',
        :home_dir => '/home/ernie/large-file.tar.gz',
        :chef_file_cache_dir => '#{Chef::Config[:file_cache_path]}/large-file.tar.gz'}[path_type]
      write_recipe %Q{
        remote_file "#{download_path}" do
          source "http://www.example.org/large-file.tar.gz"
        end
      }
    end

    # Install a gem using the specified approach.
    #
    # @param [Symbol] type The type of approach, one of :simple, :compile_time,
    #   :compile_time_from_array, :compile_time_from_word_list
    # @param [Symbol] action Either :install or :upgrade
    def recipe_installs_gem(type, action = :install)
      case type
        when :simple
          write_recipe %Q{
            gem_package "bluepill" do
              action :#{action}
             end
          }.strip
        when :compile_time
          write_recipe %Q{
            r = gem_package "mysql" do
              action :nothing
            end

            r.run_action(:#{action})
            Gem.clear_paths
          }.strip
        when :compile_time_from_array
          write_recipe %Q{
            ['foo', 'bar', 'baz'].each do |pkg|
              r = gem_package pkg do
                action :nothing
              end
              r.run_action(:#{action})
            end
          }.strip
        when :compile_time_from_word_list
          write_recipe %Q{
            %w{foo bar baz}.each do |pkg|
              r = gem_package pkg do
                action :nothing
              end
              r.run_action(:#{action})
            end
          }.strip
        else
          fail "Unrecognised type: #{type}"
      end
    end

    # Create a recipe that declares a resource with the specified file mode.
    #
    # @param [String] type The type of resource (file, template)
    # @param [String] mode The file mode as a string
    # @param [String] comment Comment that may specify to exclude a match
    def recipe_resource_with_mode(type, mode, comment='')
      source_att = type == 'template' ? 'source "foo.erb"' : ''
      write_recipe %Q{
        #{type} "/tmp/something" do #{comment}
          #{source_att}
          owner "root"
          group "root"
          mode #{mode}
          action :create
        end
      }
    end

    # Create a recipe that controls a service using the specified method.
    #
    # @param [Symbol] method How to start the service, one of: :init_d, :invoke_rc_d, :upstart, :service, :service_full_path.
    # @param [Boolean] do_sleep Whether to prefix the service cmd with a bash sleep
    # @param [Symbol] action The action to take (start, stop, reload, restart)
    def recipe_controls_service(method = :service, do_sleep = false, action = :start)
      cmds = {:init_d => "/etc/init.d/foo #{action}", :invoke_rc_d => "invoke-rc.d foo #{action}", :upstart => "#{action} foo",
              :service => "service foo #{action}", :service_full_path => "/sbin/service foo #{action}"}
      write_recipe %Q{
        execute "#{action}-foo-service" do
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
    # @option dep [Boolean] :parentheses True if the include_recipe is called with parentheses
    def recipe_with_dependency(dep)
      dep = {:is_scoped => true, :is_declared => true,
             :parentheses => false}.merge!(dep)
      recipe = "foo#{dep[:is_scoped] ? '::default' : ''}"
      write_recipe(if dep[:parentheses]
        "include_recipe('#{recipe}')"
      else
        "include_recipe '#{recipe}'"
      end)
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
    # @param [Symbol] length A :short or :long block, or :both
    def recipe_with_ruby_block(length)
      recipe = ''
      if length == :short || length == :both
        recipe << %q{
          ruby_block "subexpressions" do
	    block do
	      rc = Chef::Util::FileEdit.new("/foo/bar.conf")
              rc.search_file_replace_line(/^search/, "search #{node["foo"]["bar"]} compute-1.internal")
              rc.search_file_replace_line(/^domain/, "domain #{node["foo"]["bar"]}")
              rc.write_file
            end
            action :create
          end
        }
      end
      if length == :long || length == :both
        recipe << %q{
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
      write_recipe(recipe)
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

    # Create a role file
    #
    # @param [Hash] options The options to use for the role
    # @option options [String] :role_name The name of the role declared in the role file
    # @option options [String] :file_name The containing file relative to the roles directory
    # @option options [Symbol] :format Either :ruby or :json. Default is :ruby
    def role(options={})
      options = {:format => :ruby, :dir => 'roles'}.merge(options)
      content = if options[:format] == :json
        %Q{
          {
            "chef_type": "role",
            "json_class": "Chef::Role",
            #{Array(options[:role_name]).map{|r| "name: #{r},"}.join("\n")}
            "run_list": [
              "recipe[apache2]",
            ]
          }
        }
      else
        %Q{
          #{Array(options[:role_name]).map{|r| "name #{r}"}.join("\n")}
          run_list "recipe[apache2]"
        }
      end
      write_file "#{options[:dir]}/#{options[:file_name]}", content.strip
    end

    # Create a rule with the specified Chef version constraints
    #
    # @param [String] from_version The from version
    # @param [String] to_version The to version
    def rule_with_version_constraint(from_version, to_version)
      constraint = if from_version && to_version
        %Q{
          applies_to do |version|
            version >= gem_version("#{from_version}") && version <= gem_version("#{to_version}")
          end
        }
      elsif from_version
        %Q{
          applies_to do |version|
            version >= gem_version("#{from_version}")
          end
        }
      elsif to_version
        %Q{
          applies_to do |version|
            version <= gem_version("#{to_version}")
          end
        }
      end
      write_rule %Q{
        rule "FCTEST001", "Test Rule" do
          #{constraint}
          recipe do |ast, filename|
            [file_match(filename)]
          end
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

    # Create a README with the provided content.
    #
    # @param [String] content The recipe content.
    # @param [String] cookbook_name Optional name of the cookbook.
    def write_readme(content, cookbook_name = 'example')
      write_file "cookbooks/#{cookbook_name}/README.md", content.strip
    end

    # Create a recipe with the provided content.
    #
    # @param [String] content The recipe content.
    # @param [String] cookbook_name Optional name of the cookbook.
    def write_recipe(content, cookbook_name = 'example')
      write_file "cookbooks/#{cookbook_name}/recipes/default.rb", content.strip
    end

    # Create a rule with the provided content.
    #
    # @param [String] content The rule content.
    def write_rule(content)
      write_file "rules/test.rb", content.strip
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
