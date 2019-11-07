module FoodCritic
  # This module contains the logic for the parsing of
  # [Chef Notifications]
  # (http://docs.chef.io/resource_common.html#notifications).
  module Notifications
    # Extracts notification details from the provided AST, returning an
    # array of notification hashes.
    #
    #     template "/etc/www/configures-apache.conf" do
    #       notifies :restart, "service[apache]"
    #     end
    #
    #     => [{:resource_name=>"apache",
    #       :resource_type=>:service,
    #       :type=>:notifies,
    #       :style=>:new,
    #       :action=>:restart,
    #       :timing=>:delayed}]
    #
    def notifications(ast)
      # Sanity check the AST provided.
      return [] unless ast.respond_to?(:xpath)

      # We are mapping each `notifies` or `subscribes` line in the provided
      # AST to a Hash with the extracted details.
      notification_nodes(ast).map do |notify|

        # Chef supports two styles of notification.
        notified_resource = if new_style_notification?(notify)
                              # `notifies :restart, "service[foo]"`
                              new_style_notification(notify)
                            else
                              # `notifies :restart, resources(service: "foo")`
                              old_style_notification(notify)
                            end

        # Ignore if the notification was not parsed
        next unless notified_resource

        # Now merge the extract notification details with the attributes
        # that are common to both styles of notification.
        notified_resource.merge(
          {
            # The `:type` of notification: `:subscribes` or `:notifies`.
            type: notification_type(notify),

            # The `:style` of notification: `:new` or `:old`.
            style: new_style_notification?(notify) ? :new : :old,

            # The target resource action.
            action: notification_action(notify),

            # The notification timing: `:before`, `:immediate` or `:delayed`.
            timing: notification_timing(notify),
          }
        )
      end.compact
    end

    private

    # Extract the `:resource_name` and `:resource_type` from a new-style
    # notification.
    def new_style_notification(notify)
      # Given `notifies :restart, "service[foo]"` the target is the
      # `"service[foo]"` string portion.
      target_path = 'args_add_block/args_add/descendant::
        tstring_content[count(ancestor::dyna_symbol) = 0]/@value'
      target = notify.xpath("arg_paren/#{target_path} | #{target_path}").to_s

      # Test the target string against the standard syntax for a new-style
      # notification: `resource_type[resource_name]`.
      match = target.match(/^([^\[]+)\[(.*)\]$/)
      return nil unless match

      # Convert the captured resource type and name to symbols.
      resource_type, resource_name =
        match.captures.tap { |m| m[0] = m[0].to_sym }

      # Normally the `resource_name` will be a simple string. However in the
      # case where it has an embedded sub-expression then we will return the
      # AST to the caller to handle.
      if notify.xpath("descendant::string_embexpr").empty?
        return nil if resource_name.empty?
      else
        resource_name =
          notify.xpath("args_add_block/args_add/string_literal")
      end
      { resource_name: resource_name, resource_type: resource_type }
    end

    # Extract the `:resource_name` and `:resource_type` from an old-style
    # notification.
    def old_style_notification(notify)
      resources = resource_hash_references(notify)
      resource_type = resources.xpath("symbol[1]/ident/@value").to_s.to_sym
      if resource_type.empty?
        resource_type = resources.xpath("label/@value").to_s.chop.to_sym
      end
      resource_name = resources.xpath('string_add[1][count(../
        descendant::string_add) = 1]/tstring_content/@value').to_s
      resource_name = resources if resource_name.empty?
      { resource_name: resource_name, resource_type: resource_type }
    end

    def notification_timing(notify)
      # The notification timing should be the last symbol
      # on the notifies element.
      timing = notify.xpath('args_add_block/args_add/symbol_literal[last()]/
        symbol/ident[1]/@value')
      if timing.empty?
        # "By default, notifications are :delayed"
        :delayed
      else
        case timing.first.to_s.to_sym
        # Both forms are valid, but we return `:immediate` for both to avoid
        # the caller having to recognise both.
        when :immediately, :immediate then :immediate
        # Pass the timing through unmodified if we don't recognise it.
        else timing.first.to_s.to_sym
        end
      end
    end

    def new_style_notification?(notify)
      resource_hash_references(notify).empty?
    end

    # return the notification action as either a symbol or string or nil if it's a variable.
    # Yes you can notify an action as a string but it's wrong and we want to return it as
    # a string so we can tell people not to do that.
    def notification_action(notify)
      is_variable = true unless notify.xpath("args_add_block/args_add//args_add[aref or vcall or call or var_ref]").empty?
      string_val = notify.xpath("descendant::args_add/string_literal/string_add/tstring_content/@value").first
      symbol_val = notify.xpath('descendant::args_add/args_add//symbol/ident/@value |
        descendant::dyna_symbol[1]/xstring_add/tstring_content/@value |
        descendant::args_add/args_add//dyna_symbol/string_add/tstring_content/@value').first

      # 1) return a nil if the action is a variable like node['foo']['bar']
      # 2) return the symbol if it exists
      # 3) return the string since we're positive that we're not a symbol or variable
      return nil if is_variable
      return symbol_val.value.to_sym unless symbol_val.nil?

      string_val.value
    end

    def notification_nodes(ast, &block)
      type_path = '[ident/@value="notifies" or ident/@value="subscribes"]'
      ast.xpath("descendant::command#{type_path} |
        descendant::method_add_arg[fcall#{type_path}]")
    end

    def notification_type(notify)
      notify.xpath("ident/@value[1] | fcall/ident/@value[1]").to_s.to_sym
    end

    def resource_hash_references(ast)
      ast.xpath('descendant::method_add_arg[fcall/ident/
        @value="resources"]/descendant::assoc_new')
    end
  end
end
