Feature: Check for attributes using assign unless nil

  In order to avoid attributes being assigned unexpected values
  As a developer
  I want to identify attributes that attempt to use assign unless nil (||=)

  Scenario Outline: Attribute assignments
    Given a cookbook attributes file with assignment <assignment>
     When I check the cookbook
     Then the attribute assignment uses assign unless nil warning 046 <show_warning> be displayed against the attributes file
  Examples:
    | assignment                          | show_warning |
    | default['somevalue'] = []           | should not   |
    | default['somevalue'] = foo \|\| bar | should not   |
    | default['somevalue'] \|\|= []       | should       |
    | default[:somevalue] = []            | should not   |
    | default[:somevalue] = foo \|\| bar  | should not   |
    | default[:somevalue] \|\|= []        | should       |
    | default.somevalue = []              | should not   |
    | default.somevalue = foo \|\| bar    | should not   |
    | default.somevalue \|\|= []          | should       |
