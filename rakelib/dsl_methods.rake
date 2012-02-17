require 'chef'
require 'chef/mixin/convert_to_class_name'
require 'yajl'

include Chef::Mixin::ConvertToClassName
METADATA_FILE = 'chef_dsl_metadata.json'

file METADATA_FILE do
  chef_dsl_metadata = {:dsl_methods => chef_dsl_methods,
                       :attributes => chef_resource_attributes}
  json = Yajl::Encoder.encode(chef_dsl_metadata, :pretty => true)
  File.open(METADATA_FILE, 'w'){|f| f.write(json)}
end

def chef_dsl_methods
  (Chef::Node.public_instance_methods +
   Chef::Mixin::RecipeDefinitionDSLCore.included_modules.map do |mixin|
     mixin.public_instance_methods
   end).flatten.sort.uniq
end

def chef_resource_attributes
  resources = Chef::Resource.constants.sort.map do |resource_klazz|
    resource = Chef::Resource.const_get(resource_klazz)
    if resource.respond_to?(:public_instance_methods) and
       resource.ancestors.include?(Chef::Resource)
      [convert_to_snake_case(resource_klazz.to_s),
       resource.public_instance_methods(true).sort]
    end
  end
  Hash[resources]
end
