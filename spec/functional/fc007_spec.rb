require "spec_helper"

describe "FC007" do
  metadata_file "name 'test'\ndepends 'dep'"
  context "with an undeclared dependency" do
    recipe_file 'include_recipe "foo"'

    it { is_expected.to violate_rule }

    context "with parens" do
      recipe_file 'include_recipe("foo")'
      it { is_expected.to violate_rule }
    end

    context "with ::default" do
      recipe_file 'include_recipe "foo::default"'
      it { is_expected.to violate_rule }
    end

    context "with parens and ::default" do
      recipe_file 'include_recipe("foo::default")'
      it { is_expected.to violate_rule }
    end

    # context 'with a partial expression' do
    #   recipe_file 'include_recipe "foo::#{something}"'
    #   it { pending; is_expected.to violate_rule }
    # end
  end

  context "with a declared dependency" do
    recipe_file 'include_recipe "dep"'

    it { is_expected.to_not violate_rule }

    context "with parens" do
      recipe_file 'include_recipe("dep")'
      it { is_expected.to_not violate_rule }
    end

    context "with ::default" do
      recipe_file 'include_recipe "dep::default"'
      it { is_expected.to_not violate_rule }
    end

    context "with parens and ::default" do
      recipe_file 'include_recipe("dep::default")'
      it { is_expected.to_not violate_rule }
    end

    # context 'with a partial expression' do
    #   recipe_file 'include_recipe "dep::#{something}"'
    #   it { pending; is_expected.to_not violate_rule }
    # end
  end
  context "with an unknowable include_recipe" do
    context "with a node attribute" do
      recipe_file 'include_recipe node["foo"]'
      it { is_expected.to_not violate_rule }
    end

    context "with a variable" do
      recipe_file "include_recipe something"
      it { is_expected.to_not violate_rule }
    end

    context "with a string expression" do
      recipe_file 'include_recipe "#{something}"'
      it { is_expected.to_not violate_rule }
    end

    context "with a parial string expression" do
      recipe_file 'include_recipe "#{something}::default"'
      it { is_expected.to_not violate_rule }
    end
  end

  context "with an include from the same cookbook" do
    recipe_file 'include_recipe "test::other"'
    it { is_expected.to_not violate_rule }

    context "with the shorthand syntax" do
      recipe_file 'include_recipe "::other"'
      it { is_expected.to_not violate_rule }
    end
  end

  context "with multiple includes" do
    recipe_file "include_recipe 'test::other'\ninclude_recipe 'foo'"
    it { is_expected.to violate_rule.in("recipes/default.rb:2") }
  end

  context "with multiple dependencies" do
    shared_examples "multiple includes" do
      context "with declared includes" do
        recipe_file %Q{include_recipe 'one'\ninclude_recipe "two"\ninclude_recipe 'three::default'}
        it { is_expected.to_not violate_rule }
      end

      context "with undeclared includes" do
        recipe_file %Q{include_recipe 'one'\ninclude_recipe "other"\ninclude_recipe 'foo::default'}
        it { is_expected.to violate_rule.in("recipes/default.rb:2") }
        it { is_expected.to violate_rule.in("recipes/default.rb:2") }
      end
    end

    context "using multiple depends" do
      metadata_file "name 'test'\ndepends 'one'\ndepends 'two'\ndepends 'three'"
      it_behaves_like "multiple includes"
    end

    context "using a word array and a one-line block" do
      metadata_file "name 'test'\n%w{one two three}.each {|d| depends d }"
      it_behaves_like "multiple includes"
    end

    context "using a word array and a multi-line block" do
      metadata_file "name 'test'\n%w{one two three}.each do |d|\n  depends d\nend"
      it_behaves_like "multiple includes"
    end

    context "using a non-standard word array" do
      metadata_file "name 'test'\n%w|one two three|.each {|d| depends d }"
      it_behaves_like "multiple includes"
    end
  end
end
