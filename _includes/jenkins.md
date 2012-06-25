To manually add a new job to [Jenkins](http://jenkins-ci.org/) to check your
cookbooks with foodcritic do the following:

1. Ensure you have Ruby 1.9.2+ and the foodcritic gem installed on the box
   running Jenkins.
1. You'll probably need to install the Git plugin. In Jenkins select "Manage
   Jenkins" -> "Manage Plugins". Select the "Available" tab. Check the checkbox
   next to the Git Plugin and click the "Install without restart" button.
1. In Jenkins select "New Job". Enter a name for the job "my-cookbook", select
   "Build a free-style software project" and click "OK".
1. On the resulting page select "Git" under "Source Code Management" and enter
   the URL for your repo.
1. Check the checkbox "Poll SCM" under "Build Triggers".
1. Click "Add Build Step" -> "Execute shell" under "Build". This is where we
   will call foodcritic.
1. Assuming you are using rvm enter the following as the command:

       #!/usr/bin/env rvm-shell 1.9.3
       foodcritic .

1. Click "Save".

1. Cool, we've created your new job. Now lets see if it works. Click "Build Now" on
the left-hand side.
1. You can click the build progress bar to be taken directly to the console output.
1. After a moment you should see that the build has been successful and foodcritic
warnings (if any) are shown in your console output.

Yes, for maximum goodness you should be
[automating all this with Chef](https://github.com/fnichol/chef-jenkins). :-)

For more information refer to the instructions for building a "free-style
software project" here:

* [https://wiki.jenkins-ci.org/display/JENKINS/Building+a+software+project](https://wiki.jenkins-ci.org/display/JENKINS/Building+a+software+project)

See also this blog post about rvm-shell which ensures you have the right version
of Ruby loaded when trying to build with foodcritic:

* [http://blog.ninjahideout.com/posts/rvm-improved-support-for-hudson](http://blog.ninjahideout.com/posts/rvm-improved-support-for-hudson)

## Failing the build

The above is a start, but we'd also like to fail the build if there are any
warnings that might stop the cookbook from working.

CI is only useful if people will act on it. Lets start by only failing the build
when there is a `correctness` problem that would likely break our Chef run.
We'll continue to have the other warnings available for reference in the console
log but only correctness issues will fail the build.

1. Select the "my-cookbook" job in Jenkins and click "Configure".
1. Scroll down to our "Execute shell" command and change it to look like the
following:

       #!/usr/bin/env rvm-shell 1.9.3
       foodcritic -f correctness .

1. Click "Save" and then "Build Now".

## More complex expressions

Foodcritic supports more complex expressions with the standard Cucumber tag
syntax. For example:

    #!/usr/bin/env rvm-shell 1.9.3
    foodcritic -f any -f ~FC014 .

Here we use `any` to fail the build on any warning, but then use the tilde `~`
to exclude FC014. The build will fail on any warning raised, except FC014.

You can find more detail on Cucumber tag expressions at the Cucumber wiki:

* [https://github.com/cucumber/cucumber/wiki/Tags](https://github.com/cucumber/cucumber/wiki/Tags)

## Tracking warnings over time
The
[Jenkins Warnings plugin](https://wiki.jenkins-ci.org/display/JENKINS/Warnings+Plugin)
can be configured to understand foodcritic output and track your cookbook
warnings over time.

1. You'll need to install the Warnings plugin. In Jenkins select "Manage
   Jenkins" -> "Manage Plugins". Select the "Available" tab. Check the checkbox
   next to the Warnings Plugin and click the "Install without restart" button.
1. From "Manage Jenkins" select "Configure System". Scroll down to the "Compiler
   Warnings" section and click the "Add" button next to "Parsers".
1. Enter "Foodcritic" in the Name field.
1. Enter the following regex in the "Regular Expression" field:

       ^(FC[0-9]+): (.*): ([^:]+):([0-9]+)$

1. Enter the following Groovy script into the "Mapping Script" field:

       import hudson.plugins.warnings.parser.Warning

       String fileName = matcher.group(3)
       String lineNumber = matcher.group(4)
       String category = matcher.group(1)
       String message = matcher.group(2)

       return new Warning(fileName, Integer.parseInt(lineNumber), "Chef Lint Warning", category, message);

1. To test the match, enter the following example message in the "Example Log Message" field:

       FC001: Use strings in preference to symbols to access node attributes: ./recipes/innostore.rb:30

1. Click in the "Mapping Script" field and you should see the following appear below the Example Log Message:

       One warning found
       file name: ./recipes/innostore.rb
       line number: 30
       priority: Normal Priority
       category:  FC001
       type: Chef Lint Warning
       message: Use strings in prefe[...]ols to access node attributes

1. Cool, it's parsed our example message successfully. Click "Save" to save the
   parser.
1. Select the "my-cookbook" job in Jenkins and click "Configure".
1. Check the checkbox next to "Scan for compiler warnings" underneath
   "Post-build Actions".
1. Click the "Add" button next to "Scan console log" and select our "Foodcritic"
   parser from the drop-down list.
1. Click the "Advanced..." button and check the "Run always" checkbox.
1. Click "Save" and then "Build Now".
1. Add the bottom of the console log you should see something similar to this:

       [WARNINGS] Parsing warnings in console log with parsers [Foodcritic]
       [WARNINGS] Foodcritic : Found 48 warnings.

1. Click "Back to Project". Once you have built the project a couple of times
   the warnings trend will appear here.
