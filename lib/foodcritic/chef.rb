module FoodCritic

  # Encapsulates functions that previously were calls to the Chef gem.
  module Chef

    # The set of methods in the Chef DSL
    #
    # @return [Array] Array of method symbols
    def dsl_methods
      [:attribute, :attribute=, :attribute?, :chef_environment, :default, :default_unless, :each, :each_attribute,
       :each_key, :each_value, :enum_for, :eql?, :equal?, :has_key?, :hash, :include_attribute, :inspect, :instance_of?,
       :is_a?, :key?, :keys, :kind_of?, :name, :normal, :normal_attrs, :normal_attrs=, :normal_unless, :override,
       :override_attrs, :override_attrs=, :override_unless, :platform?, :recipe?, :recipe_list, :recipe_list=, :respond_to?,
       :respond_to_missing?, :role?, :run_list, :run_list=, :run_list?, :run_state, :run_state=, :search, :set, :set_if_args,
       :set_or_return, :set_unless, :to_hash, :to_json, :to_s, :value_for_platform]
    end

    RESOURCE_ATTRIBUTES = {
        :apt_package => [:action, :name, :ignore_failure, :not_if, :notifies, :only_if, :options, :package_name, :provider, :response_file, :retries, :retries=, :retry_delay, :retry_delay=, :source, :subscribes, :supports, :version],
        :bash => [:action, :code, :command, :creates, :cwd, :environment, :flags, :group, :ignore_failure, :interpreter, :name, :not_if, :notifies, :only_if, :path, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :returns, :subscribes, :supports, :timeout, :umask, :user],
        :cookbook_file => [:action, :backup, :checksum, :content, :cookbook, :group, :ignore_failure, :mode, :name, :not_if, :notifies, :only_if, :owner, :path, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :source, :subscribes, :supports],
        :cron => [:action, :command, :day, :home, :hour, :ignore_failure, :mailto, :minute, :month, :name, :not_if, :notifies, :only_if, :path, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :shell, :subscribes, :supports, :user, :weekday],
        :csh => [:action, :code, :command, :creates, :cwd, :environment, :flags, :group, :ignore_failure, :interpreter, :name, :not_if, :notifies, :only_if, :path, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :returns, :subscribes, :supports, :timeout, :umask, :user],
        :deploy => [:action, :additional_remotes, :after_restart, :before_migrate, :before_restart, :before_symlink, :branch, :copy_exclude, :create_dirs_before_symlink, :current_path, :deploy_to, :depth, :destination, :enable_submodules, :environment, :git_ssh_wrapper, :group, :ignore_failure, :migrate, :migration_command, :name, :not_if, :notifies, :only_if, :provider, :purge_before_symlink, :remote, :repo, :repository, :repository_cache, :restart, :restart_command, :retries, :retries=, :retry_delay, :retry_delay=, :revision, :role, :rollback_on_error, :scm_provider, :shallow_clone, :shared_path, :ssh_wrapper, :subscribes, :supports, :svn_arguments, :svn_force_export, :svn_info_args, :svn_password, :svn_username, :symlink_before_migrate, :symlinks, :user],
        :deploy_branch => [:action, :additional_remotes, :after_restart, :before_migrate, :before_restart, :before_symlink, :branch, :copy_exclude, :create_dirs_before_symlink, :current_path, :deploy_to, :depth, :destination, :enable_submodules, :environment, :git_ssh_wrapper, :group, :ignore_failure, :migrate, :migration_command, :name, :not_if, :notifies, :only_if, :provider, :purge_before_symlink, :remote, :repo, :repository, :repository_cache, :restart, :restart_command, :retries, :retries=, :retry_delay, :retry_delay=, :revision, :role, :rollback_on_error, :scm_provider, :shallow_clone, :shared_path, :ssh_wrapper, :subscribes, :supports, :svn_arguments, :svn_force_export, :svn_info_args, :svn_password, :svn_username, :symlink_before_migrate, :symlinks, :user],
        :deploy_revision => [:action, :additional_remotes, :after_restart, :before_migrate, :before_restart, :before_symlink, :branch, :copy_exclude, :create_dirs_before_symlink, :current_path, :deploy_to, :depth, :destination, :enable_submodules, :environment, :git_ssh_wrapper, :group, :ignore_failure, :migrate, :migration_command, :name, :not_if, :notifies, :only_if, :provider, :purge_before_symlink, :remote, :repo, :repository, :repository_cache, :restart, :restart_command, :retries, :retries=, :retry_delay, :retry_delay=, :revision, :role, :rollback_on_error, :scm_provider, :shallow_clone, :shared_path, :ssh_wrapper, :subscribes, :supports, :svn_arguments, :svn_force_export, :svn_info_args, :svn_password, :svn_username, :symlink_before_migrate, :symlinks, :user],
        :directory => [:action, :group, :ignore_failure, :mode, :name, :not_if, :notifies, :only_if, :owner, :path, :provider, :recursive, :retries, :retries=, :retry_delay, :retry_delay=, :subscribes, :supports],
        :dpkg_package => [:action, :ignore_failure, :name, :not_if, :notifies, :only_if, :options, :package_name, :provider, :response_file, :retries, :retries=, :retry_delay, :retry_delay=, :source, :subscribes, :supports, :version],
        :easy_install_package => [:action, :easy_install_binary, :ignore_failure, :module_name, :name, :not_if, :notifies, :only_if, :options, :package_name, :provider, :python_binary, :response_file, :retries, :retries=, :retry_delay, :retry_delay=, :source, :subscribes, :supports, :version],
        :env => [:action, :delim, :ignore_failure, :key_name, :name, :not_if, :notifies, :only_if, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :subscribes, :supports, :value],
        :erl_call => [:action, :code, :cookie, :distributed, :ignore_failure, :name, :name_type, :node_name, :not_if, :notifies, :only_if, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :subscribes, :supports],
        :execute => [:action, :command, :creates, :cwd, :environment, :group, :ignore_failure, :name, :not_if, :notifies, :only_if, :path, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :returns, :subscribes, :supports, :timeout, :umask, :user],
        :file => [:action, :backup, :checksum, :content, :group, :ignore_failure, :mode, :name, :not_if, :notifies, :only_if, :owner, :path, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :subscribes, :supports],
        :freebsd_package => [:action, :ignore_failure, :name, :not_if, :notifies, :only_if, :options, :package_name, :provider, :response_file, :retries, :retries=, :retry_delay, :retry_delay=, :source, :subscribes, :supports, :version],
        :gem_package => [:action, :gem_binary, :ignore_failure, :name, :not_if, :notifies, :only_if, :options, :package_name, :provider, :response_file, :retries, :retries=, :retry_delay, :retry_delay=, :source, :subscribes, :supports, :version],
        :git => [:action, :additional_remotes, :branch, :depth, :destination, :enable_submodules, :group, :ignore_failure, :name, :not_if, :notifies, :only_if, :provider, :reference, :remote, :repo, :repository, :retries, :retries=, :retry_delay, :retry_delay=, :revision, :ssh_wrapper, :subscribes, :supports, :svn_arguments, :svn_info_args, :svn_password, :svn_username, :user],
        :group => [:action, :append, :gid, :group_name, :ignore_failure, :members, :name, :not_if, :notifies, :only_if, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :subscribes, :supports, :system, :users],
        :http_request => [:action, :headers, :ignore_failure, :message, :name, :not_if, :notifies, :only_if, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :subscribes, :supports, :url],
        :ifconfig => [:action, :bcast, :bootproto, :device, :hwaddr, :ignore_failure, :inet_addr, :mask, :metric, :mtu, :name, :network, :not_if, :notifies, :onboot, :only_if, :onparent, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :subscribes, :supports, :target],
        :link => [:action, :group, :ignore_failure, :link_type, :name, :not_if, :notifies, :only_if, :owner, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :subscribes, :supports, :target_file, :to],
        :log => [:action, :ignore_failure, :level, :name, :not_if, :notifies, :only_if, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :subscribes, :supports],
        :macports_package => [:action, :ignore_failure, :name, :not_if, :notifies, :only_if, :options, :package_name, :provider, :response_file, :retries, :retries=, :retry_delay, :retry_delay=, :source, :subscribes, :supports, :version],
        :mdadm => [:action, :chunk, :devices, :exists, :ignore_failure, :level, :name, :not_if, :notifies, :only_if, :provider, :raid_device, :retries, :retries=, :retry_delay, :retry_delay=, :subscribes, :supports],
        :mount => [:action, :device, :device_type, :dump, :enabled, :fstype, :ignore_failure, :mount_point, :mounted, :name, :not_if, :notifies, :only_if, :options, :pass, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :subscribes, :supports],
        :ohai => [:action, :ignore_failure, :name, :not_if, :notifies, :only_if, :plugin, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :subscribes, :supports],
        :package => [:action, :ignore_failure, :name, :not_if, :notifies, :only_if, :options, :package_name, :provider, :response_file, :retries, :retries=, :retry_delay, :retry_delay=, :source, :subscribes, :supports, :version],
        :pacman_package => [:action, :ignore_failure, :name, :not_if, :notifies, :only_if, :options, :package_name, :provider, :response_file, :retries, :retries=, :retry_delay, :retry_delay=, :source, :subscribes, :supports, :version],
        :perl => [:action, :code, :command, :creates, :cwd, :environment, :flags, :group, :ignore_failure, :interpreter, :name, :not_if, :notifies, :only_if, :path, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :returns, :subscribes, :supports, :timeout, :umask, :user],
        :portage_package => [:action, :ignore_failure, :name, :not_if, :notifies, :only_if, :options, :package_name, :provider, :response_file, :retries, :retries=, :retry_delay, :retry_delay=, :source, :subscribes, :supports, :version],
        :python => [:action, :code, :command, :creates, :cwd, :environment, :flags, :group, :ignore_failure, :interpreter, :name, :not_if, :notifies, :only_if, :path, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :returns, :subscribes, :supports, :timeout, :umask, :user],
        :remote_directory => [:action, :cookbook, :files_backup, :files_group, :files_mode, :files_owner, :group, :ignore_failure, :mode, :name, :not_if, :notifies, :only_if, :overwrite, :owner, :path, :purge, :provider, :recursive, :retries, :retries=, :retry_delay, :retry_delay=, :source, :subscribes, :supports],
        :remote_file => [:action, :backup, :checksum, :content, :cookbook, :group, :ignore_failure, :mode, :name, :not_if, :notifies, :only_if, :owner, :path, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :source, :subscribes, :supports],
        :route => [:action, :device, :domain, :domainname, :gateway, :hostname, :ignore_failure, :metric, :name, :netmask, :networking, :networking_ipv6, :not_if, :notifies, :only_if, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :route_type, :subscribes, :supports, :target],
        :rpm_package => [:action, :ignore_failure, :name, :not_if, :notifies, :only_if, :options, :package_name, :provider, :response_file, :retries, :retries=, :retry_delay, :retry_delay=, :source, :subscribes, :supports, :version],
        :ruby => [:action, :code, :command, :creates, :cwd, :environment, :flags, :group, :ignore_failure, :interpreter, :name, :not_if, :notifies, :only_if, :path, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :returns, :subscribes, :supports, :timeout, :umask, :user],
        :ruby_block => [:action, :block, :ignore_failure, :name, :not_if, :notifies, :only_if, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :subscribes, :supports],
        :scm => [:action, :depth, :destination, :enable_submodules, :group, :ignore_failure, :name, :not_if, :notifies, :only_if, :provider, :remote, :repository, :retries, :retries=, :retry_delay, :retry_delay=, :revision, :ssh_wrapper, :subscribes, :supports, :svn_arguments, :svn_info_args, :svn_password, :svn_username, :user],
        :script => [:action, :code, :command, :creates, :cwd, :environment, :flags, :group, :ignore_failure, :interpreter, :name, :not_if, :notifies, :only_if, :path, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :returns, :subscribes, :supports, :timeout, :umask, :user],
        :service => [:action, :enabled, :ignore_failure, :name, :not_if, :notifies, :only_if, :pattern, :priority, :provider, :reload_command, :restart_command, :retries, :retries=, :retry_delay, :retry_delay=, :running, :service_name, :start_command, :status_command, :stop_command, :subscribes, :supports],
        :subversion => [:action, :depth, :destination, :enable_submodules, :group, :ignore_failure, :name, :not_if, :notifies, :only_if, :provider, :remote, :repository, :retries, :retries=, :retry_delay, :retry_delay=, :revision, :ssh_wrapper, :subscribes, :supports, :svn_arguments, :svn_info_args, :svn_password, :svn_username, :user],
        :template => [:action, :backup, :checksum, :content, :cookbook, :group, :ignore_failure, :local, :mode, :name, :not_if, :notifies, :only_if, :owner, :path, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :source, :subscribes, :supports, :variables],
        :timestamped_deploy => [:action, :additional_remotes, :after_restart, :before_migrate, :before_restart, :before_symlink, :branch, :copy_exclude, :create_dirs_before_symlink, :current_path, :deploy_to, :depth, :destination, :enable_submodules, :environment, :git_ssh_wrapper, :group, :ignore_failure, :migrate, :migration_command, :name, :not_if, :notifies, :only_if, :provider, :purge_before_symlink, :remote, :repo, :repository, :repository_cache, :restart, :restart_command, :retries, :retries=, :retry_delay, :retry_delay=, :revision, :role, :rollback_on_error, :scm_provider, :shallow_clone, :shared_path, :ssh_wrapper, :subscribes, :supports, :svn_arguments, :svn_force_export, :svn_info_args, :svn_password, :svn_username, :symlink_before_migrate, :symlinks, :user],
        :user => [:action, :comment, :gid, :group, :home, :ignore_failure, :manage_home, :name, :non_unique, :not_if, :notifies, :only_if, :password, :provider, :retries, :retries=, :retry_delay, :retry_delay=, :shell, :subscribes, :supports, :system, :uid, :username],
        :yum_package => [:action, :allow_downgrade, :arch, :flush_cache, :ignore_failure, :name, :not_if, :notifies, :only_if, :options, :package_name, :provider, :response_file, :retries, :retries=, :retry_delay, :retry_delay=, :source, :subscribes, :supports, :version]
    }

    # Is the specified attribute valid for the type of resource?
    #
    # @param [Symbol] resource_type The type of Chef resource
    # @param [Symbol] attribute_name The attribute name
    def attribute?(resource_type, attribute_name)
      return true unless RESOURCE_ATTRIBUTES.include?(resource_type)
      RESOURCE_ATTRIBUTES[resource_type].include?(attribute_name)
    end

    module Search

      # The search grammars that ship with any Chef gems installed locally.
      # These are returned in descending version order (a newer Chef version
      #   could break our ability to load the grammar).
      #
      # @return [Array] File paths of Chef search grammars installed locally.
      def chef_search_grammars
        Gem.path.map do |gem_path|
          Dir["#{gem_path}/gems/chef-*/**/lucene.treetop"]
        end.flatten.sort.reverse
      end

      # Create the search parser from the first loadable grammar.
      #
      # @param [Array] grammar_paths Full paths to candidate treetop grammars
      def load_search_parser(grammar_paths)
        @search_parser ||= grammar_paths.inject(nil) do |parser,lucene_grammar|
            begin
              break parser unless parser.nil?
              # don't instantiate custom nodes
              Treetop.load_from_string(IO.read(lucene_grammar).gsub(/<[^>]+>/, ''))
              LuceneParser.new
            rescue
              # silently swallow and try the next grammar
            end
        end
      end

      # Has the search parser been loaded?
      #
      # @return [Boolean] True if the search parser has been loaded.
      def search_parser_loaded?
        ! @search_parser.nil?
      end

      # Is this a valid Lucene query?
      #
      # @param [String] query The query to check for syntax errors
      # @return [Boolean] True if the query is well-formed
      def valid_query?(query)
       load_search_parser(chef_search_grammars)
       search_parser_loaded? ? (! @search_parser.parse(query).nil?) : true
      end
    end
  end

end
