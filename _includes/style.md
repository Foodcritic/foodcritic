Because Chef cookbooks are simply Ruby, you don't need a Chef-specific style
tool to check your style.  As such, some foodcritic users use
[tailor](http://rubygems.org/gems/tailor) for assessing the style of their
cookbooks.
You can check [the docs](http://rdoc.info/gems/tailor/frames) for more details,
but here's a quick getting-started guide.

1. Install tailor:

       $ gem install tailor

1. Create a `.tailor` configuration file in the root of your project.  What you
   consider to be the "root" is really up to you; if you intend to use the same
   style rules for all of your cookbooks, put it at the root of your cookbooks.
   Use tailor to create a default config file for you:

       $ tailor --create-config

1. View the `.tailor` file with your favorite text editor, and you'll see
   something like (minus documentation at the top):

       Tailor.config do |config|
         config.formatters "text"
         config.file_set 'lib/**/*.rb' do |style|
           style.allow_camel_case_methods false, level: :error
           style.allow_hard_tabs false, level: :error
           style.allow_screaming_snake_case_classes false, level: :error
           style.allow_trailing_line_spaces false, level: :error
           style.allow_invalid_ruby false, level: :warn
           style.indentation_spaces 2, level: :error
           style.max_code_lines_in_class 300, level: :error
           style.max_code_lines_in_method 30, level: :error
           style.max_line_length 80, level: :error
           style.spaces_after_comma 1, level: :error
           style.spaces_after_lbrace 1, level: :error
           style.spaces_after_lbracket 0, level: :error
           style.spaces_after_lparen 0, level: :error
           style.spaces_before_comma 0, level: :error
           style.spaces_before_lbrace 1, level: :error
           style.spaces_before_rbrace 1, level: :error
           style.spaces_before_rbracket 0, level: :error
           style.spaces_before_rparen 0, level: :error
           style.spaces_in_empty_braces 0, level: :error
           style.trailing_newlines 1, level: :error
         end
       end

   Since most Ruby project stick their code in a `lib` directory, the default
   "file set" is set to apply that default list of style rulers to all files
   ending in .rb under that directory--change `'lib/**/*.rb'` to `'**/*.rb'` 
   instead to capture all cookbook files.

1. Take a look at the list of files tailor will measure when you run it:

       $ tailor --show-config

1. Measure!

       $ tailor

Take a look at the documentation in the config file or at
[https://github.com/turboladen/tailor](https://github.com/turboladen/tailor) for
more explanation on the options.  To disable any option, simply set
`level: :off`.

Also, tailor will only return an exit status of 1 if errors are encountered.  If
you still want to know about the problems, but don't want your builds failing,
you can set `level: :warn`.
