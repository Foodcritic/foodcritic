Feature: Check for missing platforms

  In order to maximise the portability of my cookbooks
  As a developer
  I want to identify when a recipe misses a popular flavour from a platform family

  Scenario Outline: Platform flavour missing
    Given a cookbook recipe with a '<type>' condition for flavours <flavours>
     When I check the cookbook
     Then the consider adding platform warning 024 <warning>

    Examples:
      | type      | flavours                                      | warning             |
      | case      | chalk,cheese                                  | should not be shown |
      | case      | debian,ubuntu                                 | should not be shown |
      | case      | amazon,centos,redhat,scientific               | should not be shown |
      | case      | centos,redhat,amazon,scientific               | should not be shown |
      | case      | centos,debian,fedora,redhat,amazon,scientific | should not be shown |
      | case      | redhat                                        | should not be shown |
      | case      | centos,redhat                                 | should be shown     |
      | case      | centos,redhat,scientific                      | should be shown     |
      | platform? | centos,redhat,amazon,scientific               | should not be shown |
      | platform? | redhat                                        | should not be shown |
      | platform? | redhat,scientific                             | should be shown     |

  Scenario: Unrelated case statement
    Given a cookbook recipe with a case condition unrelated to platform
     When I check the cookbook
     Then the consider adding platform warning 024 should not be shown
