Given /^I have installed the lint tool$/ do

end

When /^I run it on the command line with no arguments$/ do
  run_simple('foodcritic', false)
end

When /^I run it on the command line with too many arguments$/ do
  run_simple('foodcritic example example', false)
end

When /^I run it on the command line specifying a cookbook that does not exist$/ do
  run_simple('foodcritic no-such-cookbook', false)
end

When /^I run it on the command line with the help option$/ do
  run_simple('foodcritic --help', false)
end

Then /^the simple usage text should be displayed along with a (non-)?zero exit code$/ do |non_zero|
  assert_partial_output 'foodcritic [cookbook_path]', all_output
  assert_matching_output('( )+-t, --tags TAGS( )+Only check against rules with the specified tags.', all_output)
  if non_zero.nil?
    assert_exit_status 0
  else
    assert_not_exit_status 0
  end
end