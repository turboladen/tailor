### 1.3.0 2013-09-27

* Features
    * [gh-91](https://github.com/turboladen/tailor/issues/91) (partial fix)
        * @acrmp added the spaces_after_conditional ruler, which checks for
          conditional keywords that aren't followed with a space.

* Bug fixes
    * [gh-116](https://github.com/turboladen/tailor/issues/116) and
      [gh-135](https://github.com/turboladen/tailor/issues/135)
        * Recursive file sets now accept style properly.  Thanks, @acrmp!
    * [gh-117](https://github.com/turboladen/tailor/issues/117) and
      [gh-118](https://github.com/turboladen/tailor/issues/118)
        * Command line options can now be turned off using `false` and `off`.
          Thanks, @acrmp!



### 1.2.1 2013-03-12

* [gh-134](https://github.com/turboladen/tailor/issues/134)
    * Turned logging off by default when using bin/tailor.  This was a
      regression introduced in 1.2.0.



### 1.2.0 2013-03-06

* [gh-119](https://github.com/turboladen/tailor/issues/119)
    * AllowInvalidRubyRuler now uses Gem.ruby to use the ruby that tailor
      was run with.

* [gh-130](https://github.com/turboladen/tailor/issues/130)
    * AllowInvalidRubyRuler now handles file names with spaces in them.

* [gh-131](https://github.com/turboladen/tailor/issues/131)
    * Added YAML output formatter.  Thanks @leandronsp!

* [gh-133](https://github.com/turboladen/tailor/issues/133)
    * Added support for Ruby 2.0.0-p0.  ...which is actually just accounting
      for a [fix to Ripper](https://bugs.ruby-lang.org/issues/6211) that
      finally got merged in to a Ruby release.


### 1.1.5 2013-01-30

* [gh-127](https://github.com/turboladen/tailor/issues/127)
    * The last fix had SystemExit being displayed to the user at all times
      (since it should've been getting rescued from when the program exits).
       Properly rescuing this now for Rake tasks, so it now behaves just
      like bin/tailor in this respect.

### 1.1.4 2013-01-29

* [gh-127](https://github.com/turboladen/tailor/issues/127)
    * RakeTask now actually does something (works).

* tailor should now abort (and let you know) when it can't find the config
  file that you told it to use.  Previously, it would just fall back to
  default settings.


### 1.1.3 2013-01-28

* [gh-121](https://github.com/turboladen/tailor/issues/121)
    * Camel case methods are now detected properly when used inside of a
      class. Thanks @jasonku!



### 1.1.2 2012-06-01

* [gh-101](https://github.com/turboladen/tailor/issues/101)
    * Tailor now handles code that uses backslashes to break up statements
      to multiple lines.  Note that this is somewhat of a hack, since Ripper
      does not tokenize these backslashes--it actually just treats what we
      see as 2 lines of code as a single line of code.  In order to preserve
      line numbering and indentation tracking, tailor replaces the backslash
      with a special comment that it can detect and handle accordingly.
      While this isn't ideal, given the current design, it seemed like the
      way to deal with this.

* [gh-103](https://github.com/turboladen/tailor/issues/103)
    * Tailor now properly handles string interpolation inside string
      interpolation.



### 1.1.1 2012-05-31

* [gh-110](https://github.com/turboladen/tailor/issues/110)
    * Tailor now exits with 0 if non-error problems are found.



### 1.1.0 2012-05-07

* [gh-89](https://github.com/turboladen/tailor/issues/89)
    * You can now use {Tailor::RakeTask} to create a Rake task.

* [gh-100](https://github.com/turboladen/tailor/issues/100)
    * Added {Tailor::Configuration#recursive_file_set}.  This lets you do
      the following in your config file, which will recursively match all
      files in your current path that end with '_spec.rb':

        ```ruby
        Tailor.config do |config|
          config.recursive_file_set '*_spec.rb', :unit_tests do |style|
            style.max_line_length 90, level: :warn
          end
        end
        ```

        ...which is equivalent to:

        ```ruby
        Tailor.config do |config|
          config.file_set '*/**/*_spec.rb', :unit_tests do |style|
            style.max_line_length 90, level: :warn
          end
        end
        ```


* [gh-107](https://github.com/turboladen/tailor/issues/107)
    * Fixed --no-color option.

* [gh-108](https://github.com/turboladen/tailor/issues/108)
    * Fixed --create-config, which created style level options with a
      missing ':' for the Hash value.

* Configuration files now don't force you to use the :default file set.  If
  you don't specify any file sets, then the default is used; if you specify
  file sets, it uses what you specify.
* CLI options now override config file options for all file sets
  (previously, only the :default file set's option would get overridden by
  the CLI option).


### 1.0.1 2012-04-23

* [gh-104](https://github.com/turboladen/tailor/issues/104):
    * Fixed incorrect rendering of config file when using `tailor
        --create-config`.



### 1.0.0 2012-04-17

* Big update to config file.
* Fix for indentation checking on nested Hashes.
* Fix for overriding default style in config files.
* Fix to exit after --show-config.
* [gh-99](https://github.com/turboladen/tailor/issues/99)
    * Now warns by default if `ruby -c [file]` fails.

* [gh-93](https://github.com/turboladen/tailor/issues/93)
    * 2 'end's on the same line don't cause an indentation error.

* [gh-92](https://github.com/turboladen/tailor/issues/92)
    * Users can now turn off a ruler...
        * CLI: `--my-option off`
        * Config file: `my_option 1, level: :off`


* [gh-86](https://github.com/turboladen/tailor/issues/86)
    * Indentation checking implemented.

* [gh-68](https://github.com/turboladen/tailor/issues/68)
    * Spaces aren't improperly detected after a token when the line ends
      with a backslash.



### 1.0.0.alpha2 2012-04-09

* Fix for when not using a config file.


### 1.0.0.alpha 2012-04-09

* Complete rewrite.
* New style checks:
    * Indentation.
    * LOC count in a class.
    * LOC count in a method.
    * Trailing newlines at EOF.

* Other new features:
    * Configuration file use--both .tailor and ~/.tailorrc--lets you specify
      groups of files.
    * Turn checks off via CLI options.



### 0.1.5 2011-09-27

* Fixed post install message to use heredoc instead of %w (<-wth was I
  thinking?)


### 0.1.4 2011-09-27

* gh-81: Return exit status of 1 if problems were found.
* Fixed Rakefile and .gemspec. [sergio-fry]
* Removed dependency on hoe for gem building.
* Added -v/--version to bin/tailor.
* Fixed documentation indentation.


### 0.1.3 2010-12-14

* Added check for .erb files.


### 0.1.2 2010-09-01

* Added ability to check a single file.


### 0.1.0 2010-05-21

* Added checks for spacing around { and }.
* Added check for spacing around ternary ':'.
* Colorized error messages to be red.
* Problem message are now grouped by file line (when multiple problems per
  line).
* Temporarily removed reporting of # of trailing whitespaces.


### 0.0.3 2010-04-26

* Added checks for spacing around commas.
* Added checks for spacing around open/closed parenthesis/brackets.


### 0.0.2 2010-04-23

* Renamed project from ruby_style_checker to Tailor.
* Added check for lines > 80 characters.


### 0.0.1 2010-04-22

* Initial release!
* Command-line executable takes a directory and checks all files,
  recursively.
* Checks for:
    * Indentation
        * Hard-tabs in indentation
    * Name cases
        * Snake case class & module names
        * Camel case method names
    * Extra whitespace
        * At the end of lines
        * On empty lines
        * After commas
