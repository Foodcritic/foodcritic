Feature: Check for missing platforms

  In order to maximise the portability of my cookbooks
  As a developer
  I want to identify when a recipe misses a popular flavour from a platform family

  Scenario Outline: Platform flavour missing
    Given a cookbook recipe with a '<type>' condition for flavours <flavours>
      And the cookbook metadata declares support for <supports>
     When I check the cookbook
     Then the consider adding platform warning 024 <warning>

    Examples:
      | type      | supports                    | flavours                                      | warning             |
      | case      |                             | chalk,cheese                                  | should not be shown |
      | case      |                             | debian,ubuntu                                 | should not be shown |
      | case      |                             | amazon,centos,redhat,scientific               | should not be shown |
      | case      |                             | centos,redhat,amazon,scientific               | should not be shown |
      | case      |                             | centos,debian,fedora,redhat,amazon,scientific | should not be shown |
      | case      |                             | redhat                                        | should not be shown |
      | case      |                             | centos,redhat                                 | should be shown     |
      | case      | centos,redhat               | centos,redhat                                 | should not be shown |
      | case      |                             | centos,redhat,scientific                      | should be shown     |
      | case      | centos,redhat,scientific    | centos,redhat,scientific                      | should not be shown |
      | case      | centos,debian,scientific    | centos,scientific                             | should not be shown |
      | case      | centos,redhat,scientific    | redhat,scientific                             | should be shown     |
      | case      | debian,redhat,centos,fedora | redhat,centos,fedora                          | should not be shown |
      | platform? |                             | centos,redhat,amazon,scientific               | should not be shown |
      | platform? |                             | redhat                                        | should not be shown |
      | platform? |                             | redhat,scientific                             | should be shown     |
      | platform? | redhat,scientific           | redhat,scientific                             | should not be shown |
      | platform? | centos,redhat,scientific    | centos,scientific                             | should be shown     |

  Scenario: Supported platforms specifies versions
    Given a cookbook recipe with a 'case' condition for flavours 'redhat,scientific'
      And the cookbook metadata declares support with versions specified
     When I check the cookbook
     Then the consider adding platform warning 024 should not be shown

  Scenario: Unrelated case statement
    Given a cookbook recipe with a case condition unrelated to platform
     When I check the cookbook
     Then the consider adding platform warning 024 should not be shown
