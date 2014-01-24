#-------------------------------------------------------------------------------
# INDENT_1 (1 problem)
#-------------------------------------------------------------------------------
INDENT_1 = {}

INDENT_1['class_indented_end'] =
  %Q{class MyClass
 end}

INDENT_1['class_indented_single_statement'] =
  %Q{class MyClass
   include Something
end}

INDENT_1['class_indented_single_statement_trailing_comment'] =
  %Q{class MyClass
   include Something     # comment
end}

INDENT_1['class_outdented_single_statement'] =
  %Q{class MyClass
 include Something
end}

INDENT_1['def_indented_end'] =
  %Q{def a
 end}

INDENT_1['def_content_indented_end'] =
  %Q{def a
  puts 'stuff'
 end}

INDENT_1['class_def_content_outdented_end'] =
  %Q{class A
  def a
    puts 'stuff'
 end
end}

INDENT_1['class_def_outdented_content'] =
  %Q{class A
  def a
   puts 'stuff'
  end
end}

INDENT_1['class_method_def_using_self_outdented'] =
  %Q{class A
 def self.my_method
    puts 'stuff'
  end
end}

INDENT_1['case_indented_whens_level'] =
  %Q{def my_method
   case true
  when true
    puts 'stuff'
  when false
    puts 'blah blah'
  end
end}

INDENT_1['case_indented_whens_level_trailing_comment'] =
  %Q{def my_method
   case true        # comment
  when true
    puts 'stuff'
  when false
    puts 'blah blah'
  end
end}

INDENT_1['case_outdented_whens_level'] =
  %Q{def my_method
 case true
  when true
    puts 'stuff'
  when false
    puts 'blah blah'
  end
end}

INDENT_1['case_when_indented_whens_level'] =
  %Q{def my_method
  case true
   when true
    puts 'stuff'
  when false
    puts 'blah blah'
  end
end}

INDENT_1['case_when_outdented_whens_level'] =
  %Q{def my_method
  case true
 when true
    puts 'stuff'
  when false
    puts 'blah blah'
  end
end}

INDENT_1['case_indented_whens_in'] =
  %Q{def my_method
   case true
    when true
      puts 'stuff'
    when false
      puts 'blah blah'
  end
end}

INDENT_1['while_do_indented'] =
  %Q{ while true do
  puts 'something'
end}

INDENT_1['while_do_outdented'] =
  %Q{def my_method
 while true do
    puts 'something'
  end
end}

INDENT_1['while_do_content_outdented'] =
  %Q{def my_method
  while true do
   puts 'something'
  end
end}

INDENT_1['while_do_content_indented'] =
  %Q{def my_method
  while true do
     puts 'something'
  end
end}

INDENT_1['while_do_indented2'] =
  %Q{i = 0;
num = 5;

 while i < num do
  puts("Inside the loop i = \#{i}");
  i +=1;
end}

INDENT_1['while_do_indented2_trailing_comment'] =
  %Q{i = 0;
num = 5;

 while i < num do        # comment
  puts("Inside the loop i = \#{i}");
  i +=1;
end}

INDENT_1['until_do_indented'] =
  %Q{i = 0;
num = 5;

 until i > num  do
  puts("Inside the loop i = \#{i}");
  i +=1;
end}

INDENT_1['for_do_indented'] =
  %Q{ for i in 1..100 do
  puts i
end}

INDENT_1['loop_do_indented'] =
  %Q{ loop do
  puts 'looping'
end}

INDENT_1['if_line_indented'] =
  %Q{def a_method
   if defined? Term::ANSIColor
    message << %Q{#  \#{(i + 1).to_s.bold}.
#    * position:  \#{position}
#    * type:      \#{problem[:type].to_s.red}
#    * message:   \#{problem[:message].red}
}
  else
    message << %Q{#  \#{(i + 1)}.
#    * position:  \#{position}
#    * type:      \#{problem[:type]}
#    * message:   \#{problem[:message]}
}
  end
end}

INDENT_1['if_line_indented_trailing_comment'] =
  %Q{def a_method
   if defined? Term::ANSIColor     # comment
    message << %Q{#  \#{(i + 1).to_s.bold}.
#    * position:  \#{position}
#    * type:      \#{problem[:type].to_s.red}
#    * message:   \#{problem[:message].red}
}
  else
    message << %Q{#  \#{(i + 1)}.
#    * position:  \#{position}
#    * type:      \#{problem[:type]}
#    * message:   \#{problem[:message]}
}
  end
end}

INDENT_1['multi_line_tstring'] =
  %Q{INDENT_OK[:class] =
%Q{class MyClass
end}}

#-------------------------------------------------------------------------------
# Operators
#-------------------------------------------------------------------------------
INDENT_1['multi_line_andop_first_line_indented'] =
  %Q{def end_of_multiline_string?(lexed_line_output)
   lexed_line_output.any? { |e| e[1] == :on_tstring_end } &&
    lexed_line_output.none? { |e| e[1] == :on_tstring_beg }
end}

INDENT_1['multi_line_andop_first_line_indented_trailing_comment'] =
  %Q{def end_of_multiline_string?(lexed_line_output)
   lexed_line_output.any? { |e| e[1] == :on_tstring_end } && # comment
    lexed_line_output.none? { |e| e[1] == :on_tstring_beg }
end}

INDENT_1['multi_line_andop_second_line_indented'] =
  %Q{def end_of_multiline_string?(lexed_line_output)
  lexed_line_output.any? { |e| e[1] == :on_tstring_end } &&
     lexed_line_output.none? { |e| e[1] == :on_tstring_beg }
end}

INDENT_1['multi_line_string_concat_with_plus_out'] =
  %Q{DVR_SSDP_NOTIFICATION_TEMPLATE = File.dirname(__FILE__) +
 '/profiles/DVR5000/ssdp_notification.erb'}

INDENT_1['multi_line_method_call_end_in'] =
  %q{def initialize(raw_response)
  if raw_response.nil? || raw_response.empty?
    raise RTSP::Error,
      "#{self.class} received nil string--this shouldn't happen."
   end
end}

INDENT_1['multi_line_method_call_ends_with_period_2nd_line_in'] =
  %Q{unless streamer == MulticastStreamer.instance
  streamer.state = :DISCONNECTED
  UnicastStreamer.pool << streamer unless UnicastStreamer.pool.
     member? streamer
end}

INDENT_1['multi_line_method_call_ends_with_many_periods_last_in'] =
  %Q{my_hashie.first_level.
  second_level.
    third_level}

INDENT_1['multi_line_method_call_ends_with_many_periods_last_in_trailing_comment'] =
  %Q{my_hashie.first_level.
  second_level.
    third_level  # comment}
