require 'tailor/indentation'
require 'tailor/file_line'

Given /^that file is indented properly$/ do
  pending
  current_line = 1
  
  file_path = Pathname.new(File.expand_path(@file_list[0]))

  current_level = 0.0
  problem_count = 0
  next_proper_level = 0.0

  check_file do |line|
    line = Tailor::FileLine.new(line, file_path, current_line)

    puts '----'
    puts "line = #{current_line}"
    puts "current = #{current_level}"
    actual_level = line.is_at_level
    puts "actual = #{actual_level}"
    should_be_at = line.should_be_at_level(current_level)
    puts "should = #{should_be_at}"

    problem_count += 1 if line.at_proper_level?(actual_level, should_be_at)
    next_proper_level = line.next_line_should_be_at_level current_level
    puts "next proper = #{next_proper_level}"
    current_level = next_proper_level

    current_line += 1
  end
end

Given /^the indentation of that file starts at level (\d*)$/ do |level|
  current_line = 1
  result = nil
  
  file_path = Pathname.new(File.expand_path(@file_list[0]))

  check_file do |line|
    line = FileLine.new(line, file_path, current_line)
    result = line.is_at_level
    break line
  end

  result.should == 0
end

Given /^the line (\d*) is a "([^\"]*)" statement$/ do |line_num, statement_type|
  current_line = 1
  result = nil

  check_file do |line|
    result = line.strip =~ /^#{statement_type}/
    current_line == line_num.to_i ? (break line) : current_line += 1
  end
  result.should_not be_nil 
end

Then "the checker should tell me my indentation is OK" do
  pending
end

=begin
Then /^the level of line 1 should be 0.0$/ do
  file_path = Pathname.new(File.expand_path(@file_list[0]))
  @current_level = nil

  check_file do |line|
    line = FileLine.new(line, file_path, 1)

    @current_level = line.is_at_level
    @level_change = @current_level + line.next_line_level_change
    break line
  end
  @current_level.should.eql? 0.0
end
=end


Then /^the level of line (\d*) should be (\d+\.\d+)$/ do |line_num_to_check, level_to_check|
  file_path = Pathname.new(File.expand_path(@file_list[0]))
  current_line_num = 1
  next_proper_level = 0.0
  current_proper_level = 0.0
 
  check_file do |line|
    line = FileLine.new(line, file_path, current_line_num)

    if current_line_num == line_num_to_check
      line.is_at_level.should == level_to_check.to_f
    
      # Determine what the next line's level should be at, based on the current line's
      # level.
      next_proper_level = current_proper_level + line.indent_next_line_by
    end

    current_line_num += 1
  end
end

=begin
Then /^the level of line (\d*) should be (\d+\.\d+)$/ do |line_num_to_check, level_to_check|
  file_path = Pathname.new(File.expand_path(@file_list[0]))
  current_line = 1
  actual_level = nil
  current_level = 0.0   # new
  level_change = nil    # new

  check_file do |line|
    line = FileLine.new(line, file_path, current_line)

    # If the first line of the file, 
    if current_line == 1    # new
      level_change = current_level + line.next_line_level_change  #new
      break line    #new
    else  # new
      actual_level = line.is_at_level
    end  # new

    # Only check the line specified; skip if it's the first line.
    if (current_line == line_num_to_check) and (line_num_to_check > 1)
      this_level = current_level + level_change   # new
      this_level < 0.0 ? (this_level = 0.0) : this_level  # new
      this_level.should == level_to_check    # new
      actual_level.should == this_level
      level_change = line.next_line_level_change
      break line
    else
      current_line += 1
    end
  end
  if current_line == 1
    current_level.should.eql? level_to_check
  else
    current_level += level_change  #new
  end
end
=end