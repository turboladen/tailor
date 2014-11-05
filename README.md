tailor
======

* http://github.com/turboladen/tailor


[<img src="https://secure.travis-ci.org/turboladen/tailor.png?branch=master"
alt="Build Status" />](http://travis-ci.org/turboladen/tailor) [![Code Climate](https://codeclimate.com/github/turboladen/tailor.png)](https://codeclimate.com/github/turboladen/tailor)

DESCRIPTION:
------------

tailor parses Ruby files and measures them with some style and static analysis
"rulers".  Default values for the Rulers are based on a number of style guides
in the Ruby community as well as what seems to be common.  More on this here
http://wiki.github.com/turboladen/tailor.

tailor's goal is to help you be consistent with your style, throughout your
project, whatever style that may be.

FEATURES/PROBLEMS:
------------------

* Checks for bad style in Ruby files
    * Recursively in a directory, or...
    * A given file, or...
    * A glob ('lib/***/**.rb')
* Checks for:
    * Horizontal spacing
        * Indentation
        * Use of hard-tabs
        * Line length
        * Trailing spaces at the end of lines
        * Spacing after commas
        * Spacing before commas
        * Spacing around { and before }
        * Spacing after [ and before ]
        * Spacing after ( and before )
        * Spacing after a conditional
    * Vertical spacing
        * Trailing newlines (at the end of the file)
        * Max code lines in a class/module
        * Max code lines in a method
    * Name cases
        * Snake case class & module names
        * Camel case method names
    * Common syntax
        * Conditionals wrapped in parentheses
        * Unnecessary interpolation in strings
        * Unnecessary use of double-quotes for strings
    * Valid Ruby (warns by default)
* Configurable
    * Specify style in
        * ~./tailorrc
        * PROJECT_ROOT + .tailor
        * as CLI options
    * "File sets" allow for applying different styles to different groups of
      files
    * Set problems to :warn or :off instead of :fail
* Define custom "Rulers"
* CI/Build Integration
    * (Well, this may be stretching things a bit, but...) Exit 1 on failures


SYNOPSIS:
---------

### Why style check? ###

If you're reading this, there's a good chance you already have your own
reasons for doing so.  If you're not familiar with static analysis, give
tailor a go for a few days and see if you think it improves your code's
readability.

### What's it do? ###

At tailor's inception, there were some other static analysis tools for Ruby,
but none which checked style stuff; tailor started off as a means to fill this
gap.  Since then, a number of those tools have dropped by the wayside due to
various Ruby 1.9 incompatibilities, and left a bigger tool gap for Rubyists.
Right now it's mostly a style-checker, but might into a tool for analyzing
other aspects of your Ruby code.

### Since 0.x... ###

tailor 1.x is a marked improvement over 0.x.  While 0.x provided a few (pretty
inconsistent) style checks, its design made the code get all spaghetti-like,
with lots of really gnarly regular expression matching, making it a really bear
to add new features and fix bugs.  tailor 1.x is completely redesigned to make
that whole process much easier.

### Measure Stuff ###

Check *all* files in a directory:

```bash
$ tailor path/to/check/
```

Check a single file:

```bash
$ tailor file_to_check.rb
```

Check only files ending in .rb under the 'test' directory:

```bash
$ tailor test/**/*.rb
```

Check defaults (lib/***/**.rb):

```bash
$ tailor
```

Printing the results in a output file (if using a formatter that accepts
output files, like 'yaml'):

```bash
$ tailor path/to/check --output-file=my-results.yaml
$ tailor --output-file=my-results-from-defaults.yaml
```

Use defaults via a Rake task (if you have a .tailor file, it'll use those
settings):

```ruby
require 'tailor/rake_task'

Tailor::RakeTask.new
```

#### On style... ####

The features list, above, shows some aspects of style that should be fairly
straightforward (as to their meaning and reason), however, others make some
big assumptions--particularly the indentation checking "ruler".  There are a
number of popular indenting conventions...  In the case of multi-line
parameters to a method, some like do this:

```ruby
def a_really_freakin_long_method_name(my_really_long_first_parameter,
  my_next_param)
  # ...
end
```

...while others prefer:

```ruby
def a_really_freakin_long_method_name(my_really_long_first_parameter,
    my_next_param)
  # ...
end
```

...and yet some others prefer:

```ruby
def a_really_freakin_long_method_name(my_really_long_first_parameter,
                                      my_next_param)
  # ...
end
```

At this point, tailor only supports the style used in the first example.  If
this style isn't to your liking, then definitely take a look at the
Configurable section here to see how to turn this off.  Other styles will
probably be supported in the future.

All that to say, though, that this isn't the only case where tailor makes
style assumptions.  Another discrepancy in popular styles is with regard to
aligning operators in different lines.  Some like:

```ruby
my_hash[:first][:thing] = 1
my_hash[:eleventy][:thing] = 2
```

...while others prefer:

```ruby
my_hash[:first][:thing]    = 1
my_hash[:eleventy][:thing] = 2
```

...and yet some others prefer:

```ruby
my_hash[:first][:thing] =    1
my_hash[:eleventy][:thing] = 2
```

Again, tailor only supports the first example here.

The goal is certainly not to force you to use the style that tailor currently
uses; it just might not support your style yet.  If tailor doesn't support
your style, please feel free to take a look at the issues list and make a
request. ...or fork away!

### Configurable: ###

Not everyone prefers the same style of, well, anything really.  tailor is
configurable to allow you to check your code against the style measurements
that you want.

It has default values for each of the "rulers" it uses, but if you want to
customize these, there are a number of ways you can do so.

#### CLI ####

At any time, you can tell tailor to show you the configuration that it's going
to use by doing:

```bash
$ tailor --show-config
```

To see, amongst other options, the style options that you can pass in, do

```bash
$ tailor --help
```

If, for example, you want to tell tailor to warn you if any of your code lines
are > 100 chars (instead of the default of 80):

```bash
$ tailor --max-line-length 100 lib/
```

If you want to simply disable a ruler, just pass `off` to the option:

```bash
$ tailor --max-line-length off lib/
```

#### Configuration File ####

While you can drive most tailor options from the command line, configuration
files allow for some more flexibility with style rulers, file lists, and
(eventually) report formatters.  To create one with default settings, do:

```bash
$ tailor --create-config
```

With the documentation that's provided in the file, the settings should be
straightforward (if they're not, please let me know!).  You don't have to
specify all of those settings in your config file--those are just rendered so
you have a starting ground to tweak with.  If you only want to override a
single value, you can delete the rest of the code from your config.  This
would accomplish the same as the `--max-line-length` example above:

```ruby
# .tailor
Tailor.config do |config|
  config.file_set 'lib/**/*.rb' do |style|
    style.max_line_length 100
  end
end
```

This brings us to the concept of "file sets"...

##### File Sets #####

File sets allow you to use different style rulers against different groups of
files.  You may, for example, want your Rails app code to allow for longer
lines, or fewer code lines in methods... You may want your RSpec code to be
more lenient with curly-brace usage... You may just want to specify a few file
globs to use the default set of rulers...  File sets allow for those sorts of
things.

In the default config file, you see a single parameter being passed to
`config.file_set`--this is the glob that defines the list of files for that
file set.  While you don't see it, `config.file_set` takes a second optional
parameter that allows you to *label* your style properties, and thus use
different sets of style properties for different sets of files.  The label is
simply just a name to refer to that file set by; it will show in your report
(in the case that problems were found, of course) so you know what set of
rulers caused the problem to be found.

```ruby
# .tailor
Tailor.config do |config|

  # All defaults; implies "default" label
  config.file_set 'lib/**/*.rb'

  config.file_set 'app/**/*.rb', :rails_app do |style|
    style.max_line_length 100
    # All other rulers will use default values
  end

  # Uses default style, but labelled in the report with "features"
  config.file_set 'features/**/*.rb', :features

  config.file_set 'spec/**/*.rb', :rspec do |style|
    style.spaces_after_lbrace false
    style.spaces_before_lbrace false
    style.spaces_before_rbrace false
    # All other rulers will use default values
  end
end
```

If it suits you better, use "recursive file sets" to get all matching files in
your current path.  If you wanted to critique all .rb files:

```ruby
# .tailor
Tailor.config do |config|

  # All defaults; implies "default" label
  config.recursive_file_set '*.rb'
end
```

Similarly to the CLI, if you want to turn off a default Ruler, set its problem
level to `:off`:

```ruby
# .tailor
Tailor.config do |config|
  config.file_set 'lib/**/*.rb' do |style|
    style.indentation_spaces 2, level: :off
  end
end
```

##### Formatters #####

By default Tailor uses the text formatter, printing the results on console.
Tailor also provides a YAML formatter, that accepts an output file if using
the option --output-file=*.yaml

```ruby
# .tailor
Tailor.config do |config|
  config.formatters 'text', 'yaml'

  # just one
  config.formatters 'text'
end
```

### Define A Custom Ruler ###

While tailor provides a number of Rulers for checking style, it also provides
a way for you to add your own rulers without having to delve into its innards.
 To do this, you need to do the following.

#### Create the Ruler ####

Before jumping in to this, take a look at {Tailor::Ruler} and any of the
existing Rulers in `lib/tailor/rulers/`.  There are some key things a new
Ruler must have:

* the class name ends with "Ruler"
* it inherits {Tailor::Ruler}
* it's defined within the {Tailor::Rulers} module
* `#initialize` defines two parameters:
    1.`config` sets `@config` to the "golden rule" value for what you're
      measuring
    2.`options` is a Hash, that should at least be passed the `:level =>` you
      want the problem to be logged as

* `#add_lexer_observers` gets passed a list of {Tailor::Lexer} event types
  that the ruler should get notified on
* it defines call-back methods for {Tailor::Lexer} to call when it comes
  across an event of interest
* it calls `#measure` to assess if the criteria it's checking has been met
* it adds a {Tailor::Problem} to +@problems+ when one is found in `#measure`


#### Add the Ruler to the list of Styles ####

Internally, this all happens in `lib/tailor/configuration/style.rb`, but you
can add information about your ruler to your config file.  If you created a
Ruler:

```ruby
# max_lines_in_block.rb
class Tailor
  module Rulers
    class MaxLinesInBlockRuler < Tailor::Ruler
      def initialize(config, options)
        super(config, options)
        add_lexer_observers :ignored_nl, :kw
      end

      def ignored_nl_update(lexed_line, lineno, column)
        # ...
      end

      def kw_update(token, lexed_line, lineno, column)
        # ...
      end

      def measure
        # ...
      end

      # ...
    end
  end
end
```

...then require this and add it to the Style list of properties:

```ruby
# .tailor
require 'tailor/configuration/style'
require 'max_lines_in_block'

Tailor::Configuration::Style.define_property :max_lines_in_block

Tailor.config do |config|
  config.file_set 'lib/**/*.rb' do |style|
    style.max_lines_in_block 10, level: :error
  end
end
```

Next time you run tailor, your Ruler will get initialized and used.

### Using the lib ###

Sometimes you could use tailor as a lib, getting the results as a hash and
manipulate them according your domain.

```ruby
require 'tailor/cli'

# only results from a specific path
tailor = Tailor::CLI.new %w(app/controllers)
tailor.result # result should be a hash {"filename" => [problems]}

# using other file config (hiding path, it'll use from default config)
Tailor::CLI.new %w(--config-file=.other-config)
Tailor::CLI.new [] # uses file set from .tailor file config

# printing the results in a output file
tailor = Tailor::CLI.new %w(--output-file=results.yaml)
tailor.execute!
```

REQUIREMENTS:
-------------

* Rubies (tested)
    * ruby-2.0.0
    * ruby-2.1.4
* Gems
    * log_switch
    * nokogiri
    * term-ansicolor
    * text-table


INSTALL:
--------

    $ (sudo) gem install tailor


RELATED PROJECTS:
-----------------

* [rubocop](https://github.com/bbatsov/rubocop). *A robust Ruby code analyzer, based on the community Ruby style guide.*
* [cane](https://github.com/square/cane). *Code quality threshold checking as part of your build*
* [roodi](https://github.com/roodi/roodi).  *Ruby Object Oriented Design Inferometer*
* [reek](https://github.com/troessner/reek/wiki). *Code smell detector for Ruby*
* [flog](http://ruby.sadi.st/Ruby_Sadist.html). *Flog shows you the most torturous code you wrote. The more painful the code, the higher the score.*
* [foodcritic](http://www.foodcritic.io).  *Foodcritic is a helpful lint tool you can use to check your Chef cookbooks for common problems.*
* [metric_fu](https://github.com/metricfu/metric_fu).  *A fist full of code metrics*

LICENSE:
--------

(The MIT License)

Copyright (c) 2010-2014 Steve Loveless

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
