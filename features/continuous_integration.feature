Feature: Continuous Integration
  As a Ruby developer, I want builds to fail when my project encounters tailor
  errors so I can be sure to fix those errors as soon as possible.

  Scenario: tailor executable, warnings found, but no errors
    Given my configuration file ".tailor" looks like:
    """
    Tailor.config do |config|
      config.file_set do |style|
        style.trailing_newlines 0, level: :warn
      end
    end
    """
    And a file named "warnings.rb" with:
    """
    puts 'hi'
    
    
    """
    When I successfully run `tailor -d -c .tailor warnings.rb`
    Then the output should match /File has 2 trailing newlines/
    And the exit status should be 0
    
  Scenario: tailor executable, errors found
    Given my configuration file ".tailor" looks like:
    """
    Tailor.config do |config|
      config.file_set do |style|
        style.trailing_newlines 0, level: :error
      end
    end
    """
    And a file named "errors.rb" with:
    """
    puts 'hi'
    
    
    """
    When I run `tailor -d -c .tailor errors.rb`
    Then the output should match /File has 2 trailing newlines/
    And the output should not match /SystemExit/
    And the exit status should be 1

  Scenario: Rake task, warnings found, but no errors
    Given a file named "warnings.rb" with:
    """
    puts 'hi'


    """
    And my configuration file ".tailor" looks like:
    """
    Tailor.config do |config|
      config.file_set 'warnings.rb' do |style|
        style.trailing_newlines 0, level: :warn
      end
    end
    """
    And a file named "Rakefile" with:
    """
    require 'tailor/rake_task'

    Tailor::RakeTask.new
    """
    When I successfully run `rake tailor`
    Then the output should match /File has 2 trailing newlines/
    And the exit status should be 0

  Scenario: Rake task, errors found
    Given a file named "errors.rb" with:
    """
    puts 'hi'


    """
    And my configuration file ".tailor" looks like:
    """
    Tailor.config do |config|
      config.file_set 'errors.rb' do |style|
        style.trailing_newlines 0, level: :error
      end
    end
    """
    And a file named "Rakefile" with:
    """
    require 'tailor/rake_task'

    Tailor::RakeTask.new
    """
    When I run `rake tailor`
    Then the output should match /File has 2 trailing newlines/
    And the output should not match /SystemExit/
    And the exit status should be 1

  Scenario: Rake task, override config file
    Given a file named "errors.rb" with:
    """
    puts 'hi'


    """
    And my configuration file ".tailor" looks like:
    """
    Tailor.config do |config|
      config.file_set 'errors.rb' do |style|
        style.trailing_newlines 0, level: :error
      end
    end
    """
    And a file named "Rakefile" with:
    """
    require 'tailor/rake_task'

    Tailor::RakeTask.new do |task|
      task.file_set 'errors.rb' do |style|
        style.trailing_newlines 2, level: :error
      end
    end
    """
    When I successfully run `rake tailor`
    Then the output should match /errors\.rb\s+|\s+0/

  Scenario: Rake task, missing config file
    Given a file named "errors.rb" with:
    """
    puts 'hi'


    """
    And my configuration file ".tailor" looks like:
    """
    Tailor.config do |config|
      config.file_set 'errors.rb' do |style|
        style.trailing_newlines 0, level: :error
      end
    end
    """
    And a file named "Rakefile" with:
    """
    require 'tailor/rake_task'

    Tailor::RakeTask.new do |t|
      t.config_file = 'asdfasdfasdfasdfadsfasdfasdfadsfadsfadsfasdfasdfasdfsad'
    end
    """
    When I run `rake tailor`
    Then the output should match /No config file found at/
    And the output should not match /SystemExit/
    And the exit status should be 1
