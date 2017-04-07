require "spec_helper"

describe "regression test" do
  let(:cookbooks_txt) do
    path = File.expand_path("../cookbooks.txt", __FILE__)
    IO.readlines(path).map do |line|
      name, ref = line.strip.split(":")
      { :name => name, :ref => ref }
    end
  end

  let(:expected_output) do
    path = File.expand_path("../expected-output.txt", __FILE__)
    IO.readlines(path)
  end

  command("#{File.expand_path("../../../bin/foodcritic", __FILE__)} .", allow_error: true)

  before do
    cookbooks_txt.each do |cbk|
      command("git clone -q https://github.com/chef-cookbooks/#{cbk[:name]}.git")
      command("git checkout -q #{cbk[:ref]}", cwd: "#{temp_path}/#{cbk[:name]}")
    end
  end

  it do
    expected_output.each do |line|
      expect(subject.stdout).to include line
    end
  end
end
