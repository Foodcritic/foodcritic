require_relative 'spec_helper'
require 'fileutils'
require 'pathname'

def lint_regression_cookbooks
  working_dir = Pathname.new('tmp/regression')
  FileUtils.mkdir_p(working_dir)

  pinned_cookbooks('spec/regression/cookbooks.txt').each do |cbk|
    clone_cookbook(working_dir, cbk)
  end

  lint_cookbooks(working_dir)
end

def pinned_cookbooks(path)
  File.read(path).lines.map do |line|
    name, ref = line.strip.split(':')
    {:name => name, :ref => ref}
  end
end

def clone_cookbook(clone_path, cbk)
  target_path = clone_path + cbk[:name]
  unless Dir.exists?(target_path)
    %x{git clone -q https://github.com/opscode-cookbooks/#{cbk[:name]}.git #{target_path}}
    raise 'Unable to clone cookbook' unless $?.success?
  end
  %x{cd #{target_path} && git checkout -q #{cbk[:ref]}}
  raise 'Unable to checkout revision' unless $?.success?
end

def lint_cookbooks(cookbook_path)
  result = %x{cd #{cookbook_path} && foodcritic .}
  raise 'Unable to lint' unless $?.success?
  result
end
