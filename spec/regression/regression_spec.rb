require "spec_helper"
require "fileutils"
require "pathname"

describe "regression test" do

  def lint_regression_cookbooks
    working_dir = Pathname.new("tmp/regression")
    FileUtils.mkdir_p(working_dir)

    pinned_cookbooks("spec/regression/cookbooks.txt").each do |cbk|
      clone_cookbook(working_dir, cbk)
    end

    lint_cookbooks(working_dir)
  end

  def pinned_cookbooks(path)
    File.read(path).lines.map do |line|
      name, ref = line.strip.split(":")
      { :name => name, :ref => ref }
    end
  end

  def clone_cookbook(clone_path, cbk)
    target_path = clone_path + cbk[:name]
    unless Dir.exist?(target_path)
      `git clone -q git://github.com/chef-cookbooks/#{cbk[:name]}.git #{target_path}`
      raise "Unable to clone git://github.com/chef-cookbooks/#{cbk[:name]}.git" unless $?.success?
    end
    `cd #{target_path} && git checkout -q #{cbk[:ref]}`
    raise "Unable to checkout revision for #{cbk[:name]}" unless $?.success?
  end

  def lint_cookbooks(cookbook_path)
    result = `cd #{cookbook_path} && foodcritic .`
    raise "Unable to lint #{cookbook_path}" unless $?.success?
    result
  end


  let(:expected_lint_output) do
    File.read("spec/regression/expected-output.txt")
  end

  let(:actual_lint_output) do
    lint_regression_cookbooks
  end

  it "should result in the expected matches against a pinned set of cookbooks" do
    actual_lint_output.must_equal expected_lint_output
  end

end
