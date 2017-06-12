require "spec_helper"

describe "FC015" do
  context "with a cookbook that contains a definition" do
    definition_file <<-EOH
    define :apache_site, :enable => true do
      log "I am a definition"
    end
    EOH
    it { is_expected.to violate_rule }
  end

  context "with a cookbook that does not contain a definition" do
    recipe_file <<-EOH
      cookbook_file "/etc/foo"
    EOH
    it { is_expected.not_to violate_rule }
  end
end
