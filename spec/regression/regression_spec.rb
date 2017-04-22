require "spec_helper"

describe "regression test" do
  command("#{File.expand_path("../../../bin/foodcritic", __FILE__)} --no-progress --tags any .", allow_error: true)

  IO.readlines(File.expand_path("../cookbooks.txt", __FILE__)).each do |line|
    name, ref = line.strip.split(":")

    context "with cookbook #{name}", "regression_#{name}": true do
      before do
        command("git clone -q https://github.com/chef-cookbooks/#{name}.git .")
        command("git checkout -q #{ref}")
      end

      it "should match expected output" do
        expected_output = IO.readlines(File.expand_path("../expected/#{name}.txt", __FILE__))
        expected_output.each do |expected_line|
          expect(subject.stdout).to include expected_line
        end
      end
    end
  end
end
