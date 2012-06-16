module FoodCritic
  module Notifications

    # Decode resource notifications.
    #
    # @param [Nokogiri::XML::Node] ast The AST to check for notifications.
    # @return [Array] A flat array of notifications. The resource_name may be
    #   a string or a Node if the resource name is an expression.
    def notifications(ast)
      return [] unless ast.respond_to?(:xpath)
      notification_nodes(ast).map do |notify|
        notified_resource = if new_style_notification?(notify)
          new_style_notification(notify)
        else
          old_style_notification(notify)
        end
        next unless notified_resource
        notified_resource.merge({
          :type => notification_type(notify),
          :style => new_style_notification?(notify) ? :new : :old,
          :action => notification_action(notify),
          :timing => notification_timing(notify)
        })
      end.compact
    end

    private

    def new_style_notification(notify)
      target = notify.xpath('args_add_block/args_add/
        descendant::tstring_content/@value').to_s
      match = target.match(/^([^\[]+)\[(.*)\]$/)
      return nil unless match
      resource_type, resource_name =
        match.captures.tap{|m| m[0] = m[0].to_sym}
      if notify.xpath('descendant::string_embexpr').empty?
        return nil if resource_name.empty?
      else
        resource_name =
          notify.xpath('args_add_block/args_add/string_literal')
      end
      {:resource_name => resource_name, :resource_type => resource_type}
    end

    def new_style_notification?(notify)
      resource_hash_references(notify).empty?
    end

    def notification_action(notify)
      notify.xpath('descendant::symbol[1]/ident/@value').to_s.to_sym
    end

    def notification_nodes(ast, &block)
      ast.xpath('descendant::command[ident/@value="notifies" or
        ident/@value="subscribes"]')
    end

    def notification_timing(notify)
      timing = notify.xpath('args_add_block/args_add/symbol_literal[last()]/
        symbol/ident[1]/@value')
      if timing.empty?
        :delayed
      else
        case timing.first.to_s.to_sym
          when :immediately, :immediate then :immediate
          else timing.first.to_s.to_sym
        end
      end
    end

    def notification_type(notify)
      notify.xpath('ident/@value[1]').to_s.to_sym
    end

    def old_style_notification(notify)
      resources = resource_hash_references(notify)
      resource_type = resources.xpath('symbol[1]/ident/@value').to_s.to_sym
      resource_name = resources.xpath('string_add[1][count(../
        descendant::string_add) = 1]/tstring_content/@value').to_s
      resource_name = resources if resource_name.empty?
      {:resource_name => resource_name, :resource_type => resource_type}
    end

    def resource_hash_references(ast)
      ast.xpath('descendant::method_add_arg[fcall/ident/
        @value="resources"]/descendant::assoc_new')
    end

  end
end
