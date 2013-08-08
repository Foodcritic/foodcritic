Feature: Check for use of backquotes rather than Mixlib::ShellOut

  In order to work more easily with spawned processes
  As a developer
  I want to use the Mixlib::ShellOut library rather than basic ruby constructs

  Scenario Outline: Spawning a sub-process
    Given a cookbook recipe that spawns a sub-process with <command>
     When I check the cookbook
     Then the prefer mixlib shellout warning 048 <show_warning> be displayed
  Examples:
    | command                                | show_warning |
    | `ls`                                   | should       |
    | `#{cmd}`                               | should       |
    | %x{ls}                                 | should       |
    | %x[ls]                                 | should       |
    | %x{#{cmd} some_dir}                    | should       |
    | Mixlib::ShellOut.new('ls').run_command | should not   |

  Scenario: Execute resource
    Given a cookbook recipe that executes 'ls' with an execute resource
     When I check the cookbook
     Then the prefer mixlib shellout warning 048 should not be displayed
