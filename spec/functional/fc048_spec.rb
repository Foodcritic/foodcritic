require "spec_helper"

describe "FC048" do
  context "with a recipe that uses simple backticks" do
    recipe_file "`ls`"
    it { is_expected.to violate_rule }
  end

  context "with a recipe that uses %x and  containing a variable" do
    recipe_file '`#{cmd}`'
    it { is_expected.to violate_rule }
  end

  context "with a recipe that uses %x and curly brackets" do
    recipe_file "%x{ls}"
    it { is_expected.to violate_rule }
  end

  context "with a recipe that uses %x and square brackets" do
    recipe_file "%x[ls]"
    it { is_expected.to violate_rule }
  end

  context "with a recipe that uses %x and curly brackets containing a variable" do
    recipe_file '%x{#{cmd} some_dir}'
    it { is_expected.to violate_rule }
  end

  context "with a recipe that uses system without parantheses" do
    recipe_file 'system "ls"'
    it { is_expected.to violate_rule }
  end

  context "with a recipe that uses system without parantheses and a variable" do
    recipe_file "system cmd"
    it { is_expected.to violate_rule }
  end

  context "with a recipe that uses system with parantheses" do
    recipe_file 'system("ls")'
    it { is_expected.to violate_rule }
  end

  context "with a recipe that uses system with parantheses and a variable" do
    recipe_file "system(cmd)"
    it { is_expected.to violate_rule }
  end

  context "with a recipe that uses Mixlib::ShellOut" do
    recipe_file "Mixlib::ShellOut.new('ls').run_command"
    it { is_expected.to_not violate_rule }
  end

  context "with a recipe that uses shell_out" do
    recipe_file "shell_out('ls')"
    it { is_expected.to_not violate_rule }
  end
end
