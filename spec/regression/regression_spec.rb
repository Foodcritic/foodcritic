require_relative '../regression_helpers'

describe 'regression test' do

  let(:expected_lint_output) do
    File.read('spec/regression/expected-output.txt')
  end

  let(:actual_lint_output) do
    lint_regression_cookbooks
  end

  it "should result in the expected matches against a pinned set of cookbooks" do
    actual_lint_output.must_equal expected_lint_output
  end

end
