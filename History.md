### 1.4.1 2014-10-31 ###

* Improvements
    * Updated specs to follow RSpec 3 conventions.
    * [gh-156](https://github.com/turboladen/tailor/issues/156)
      Added Code Climate badges to README.  Thanks @jhmartin !
* Bug Fixes
    * [gh-157](https://github.com/turboladen/tailor/issues/157)
      Don't require a formatter if one has already been given.
      Thanks @inferiorhumanorgans !
    * [gh-160](https://github.com/turboladen/tailor/issues/160),
      [gh-161](https://github.com/turboladen/tailor/pull/161)
      Locked down version of log_switch to ~>0.3.0.  Thanks
      @tempredirect !

### 1.4.0 2014-01-23 ###

* Features
    * Added Ruby 2.1.0 to the list of tested Rubies.
    * Overall better indentation checking.
    * [gh-143](https://github.com/turboladen/tailor/issues/143) and
      [gh-102](https://github.com/turboladen/tailor/issues/102)
      The indentation ruler can now be told, using the
      `:line_continuations` option, that when a statement spans
      multiple lines, second and subsequent lines are/are not
      indented. See
      [these tests](https://github.com/turboladen/tailor/blob/aca324e449d3814c4473db3c28a7f719c0023750/spec/functional/indentation_spacing/line_continuations_spec.rb)
      for more info.
    * [gh-144](https://github.com/turboladen/tailor/issues/143) and
      [gh-94](https://github.com/turboladen/tailor/issues/94)
      Added the `:argument_alignment` option to the indentation
      ruler, which tells tailor to expect method declarations
      and calls that span multiple lines to have their params be
      indented to the same spot as the first param of the first
      line.  See [these tests](https://github.com/acrmp/tailor/blob/f8f3cb3c69bd4704cf8548d2c119a8d196a92043/spec/functional/indentation_spacing/argument_alignment_spec.rb)
      for more info.
    * [gh-148](https://github.com/turboladen/tailor/issues/148)
      Added new ruler: `allow_conditional_parentheses`.  This
      lets you tell tailor to expect parentheses around
      statements that conditionals check.  Defaults to true.
    * [gh-149](https://github.com/turboladen/tailor/issues/149)
      Added new ruler: `allow_unnecessary_interpolation`.  This
      lets you tell tailor to check for strings that use
      interpolation, but do it in a gross way.  Defaults to
      false.
    * [gh-150](https://github.com/turboladen/tailor/issues/150)
      Added new ruler: `allow_unnecessary_double_quotes`.  This
      lets you tell tailor to check for strings that use
      double-quotes but aren't doing interpolation.  Defaults to
      false.
* Bug fixes
    * [gh-154](https://github.com/turboladen/tailor/issues/154)
      Fixed indentation when do/end block chained on a {} block.
      This change also simplified IndentationManager.  Thanks
      @hollow!

### 1.3.1 2013-09-29 ###

* Bug fixes
    * [gh-147](https://github.com/turboladen/tailor/issues/147)
      Added license type to the gemspec.

### 1.3.0 2013-09-27 ###

* Features
    * [gh-91](https://github.com/turboladen/tailor/issues/91)
      (partial fix) @acrmp added the spaces_after_conditional
      ruler, which checks for conditional keywords that aren't
      followed with a space.
* Bug fixes
    * [gh-116](https://github.com/turboladen/tailor/issues/116) and
      [gh-135](https://github.com/turboladen/tailor/issues/135)
      Recursive file sets now accept style properly.  Thanks,
      @acrmp!
    * [gh-117](https://github.com/turboladen/tailor/issues/117) and
      [gh-118](https://github.com/turboladen/tailor/issues/118)
      Command line options can now be turned off using `false`
      and `off`. Thanks, @acrmp!

### 1.2.1 2013-03-12 ###

* Improvements
    * [gh-134](https://github.com/turboladen/tailor/issues/134)
      Turned logging off by default when using `bin/tailor`.
      This was a regression introduced in 1.2.0.

### 1.2.0 2013-03-06 ###

* Features
    * [gh-131](https://github.com/turboladen/tailor/issues/131)
      Added YAML output formatter.  Thanks @leandronsp!
    * [gh-133](https://github.com/turboladen/tailor/issues/133)
      Added support for Ruby 2.0.0-p0.  ...which is actually
      just accounting for a [fix to Ripper](https://bugs.ruby-lang.org/issues/6211)
      that finally got merged in to a Ruby release.
* Improvements
    * [gh-130](https://github.com/turboladen/tailor/issues/130)
      `AllowInvalidRubyRuler` now handles file names with spaces
      in them.
* Bug fixes
    * [gh-119](https://github.com/turboladen/tailor/issues/119)
      `AllowInvalidRubyRuler` now uses `Gem.ruby` to use the
      ruby that tailor was run with.

### 1.1.5 2013-01-30 ###

* Bug fixes
    * [gh-127](https://github.com/turboladen/tailor/issues/127)
      The last fix had `SystemExit` being displayed to the user
      at all times (since it should've been getting rescued from
      when the program exits). Properly rescuing this now for
      Rake tasks, so it now behaves just like `bin/tailor` in
      this respect.

### 1.1.4 2013-01-29 ###

* Improvements
    * tailor should now abort (and let you know) when it can't
      find the config file that you told it to use.  Previously,
      it would just fall back to default settings.
* Bug fixes
    * [gh-127](https://github.com/turboladen/tailor/issues/127)
      `RakeTask` now actually does something (works).

### 1.1.3 2013-01-28 ###

* Bug fixes
    * [gh-121](https://github.com/turboladen/tailor/issues/121)
      Camel case methods are now detected properly when used
      inside of a class. Thanks @jasonku!

### 1.1.2 2012-06-01 ###

* Improvements
    * [gh-101](https://github.com/turboladen/tailor/issues/101)
      Tailor now handles code that uses backslashes to break up
      statements to multiple lines.  Note that this is somewhat
      of a hack, since Ripper does not tokenize these
      backslashes--it actually just treats what we see as 2
      lines of code as a single line of code.  In order to
      preserve line numbering and indentation tracking, tailor
      replaces the backslash with a special comment that it can
      detect and handle accordingly. While this isn't ideal,
      given the current design, it seemed like the way to deal
      with this.
* Bug fixes
    * [gh-103](https://github.com/turboladen/tailor/issues/103)
      Tailor now properly handles string interpolation inside
      string interpolation.

### 1.1.1 2012-05-31 ###

* Bug fixes
    * [gh-110](https://github.com/turboladen/tailor/issues/110)
      Tailor now exits with 0 if non-error problems are found.

### 1.1.0 2012-05-07 ###

* Features
    * [gh-89](https://github.com/turboladen/tailor/issues/89)
      You can now use `Tailor::RakeTask` to create a Rake task.
    * [gh-100](https://github.com/turboladen/tailor/issues/100)
      Added `Tailor::Configuration#recursive_file_set`.  This
      lets you do the following in your config file, which will
      recursively match all files in your current path that end
      with `_spec.rb`:

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
* Improvements
    * Configuration files now don't force you to use the
      :default file set.  If you don't specify any file sets,
      then the default is used; if you specify file sets, it
      uses what you specify.
    * CLI options now override config file options for all file
      sets (previously, only the :default file set's option
      would get overridden by the CLI option).
* Bug fixes
    * [gh-107](https://github.com/turboladen/tailor/issues/107)
      Fixed `--no-color` option.
    * [gh-108](https://github.com/turboladen/tailor/issues/108)
      Fixed `--create-config`, which created style level options
      with a missing ':' for the Hash value.

### 1.0.1 2012-04-23 ###

* Bug fixes
    * [gh-104](https://github.com/turboladen/tailor/issues/104):
      Fixed incorrect rendering of config file when using
      `tailor --create-config`.

### 1.0.0 2012-04-17 ###

* Features
    * Big update to config file.
    * [gh-92](https://github.com/turboladen/tailor/issues/92)
      Users can now turn off a ruler...
        * CLI: `--my-option off`
        * Config file: `my_option 1, level: :off`
    * [gh-86](https://github.com/turboladen/tailor/issues/86)
      Indentation checking implemented.
* Improvements
    * [gh-99](https://github.com/turboladen/tailor/issues/99)
      Now warns by default if `ruby -c [file]` fails.
* Bug fixes
    * Fix for indentation checking on nested Hashes.
    * Fix for overriding default style in config files.
    * Fix to exit after `--show-config`.
    * [gh-93](https://github.com/turboladen/tailor/issues/93)
      2 'end's on the same line don't cause an indentation
      error.
    * [gh-68](https://github.com/turboladen/tailor/issues/68)
      Spaces aren't improperly detected after a token when the
      line ends with a backslash.

### 1.0.0.alpha2 2012-04-09 ###

* Bug fixes
    * Fix for when not using a config file.

### 1.0.0.alpha 2012-04-09 ###

* Complete rewrite.
* Features
    * New style checks:
        * Indentation.
        * LOC count in a class.
        * LOC count in a method.
        * Trailing newlines at EOF.
    * Configuration file use--both .tailor and ~/.tailorrc--lets
      you specify groups of files.
    * Turn checks off via CLI options.

### 0.1.5 2011-09-27 ###

* Bug fixes
    * Fixed post install message to use heredoc instead of %w
      (<-wth was I thinking?)

### 0.1.4 2011-09-27 ###

* Improvements
    * Removed dependency on hoe for gem building.
    * Added -v/--version to `bin/tailor`.
* Bug fixes
    * gh-81: Return exit status of 1 if problems were found.
    * Fixed Rakefile and .gemspec. [sergio-fry]
    * Fixed documentation indentation.

### 0.1.3 2010-12-14 ###

* Improvements
    * Added check for .erb files.

### 0.1.2 2010-09-01 ###

* Improvements
    * Added ability to check a single file.

### 0.1.0 2010-05-21 ###

* Improvements
    * Added checks for spacing around { and }.
    * Added check for spacing around ternary ':'.
    * Colorized error messages to be red.
    * Problem message are now grouped by file line (when
      multiple problems per line).
    * Temporarily removed reporting of # of trailing
      whitespaces.

### 0.0.3 2010-04-26 ###

* Improvements
    * Added checks for spacing around commas.
    * Added checks for spacing around open/closed
      parenthesis/brackets.

### 0.0.2 2010-04-23 ###

* Improvements
    * Renamed project from ruby_style_checker to Tailor.
    * Added check for lines > 80 characters.

### 0.0.1 2010-04-22 ###

* Initial release!
* Command-line executable takes a directory and checks all
  files, recursively.
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
