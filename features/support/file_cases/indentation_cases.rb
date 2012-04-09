INDENT_OK = {}

INDENT_OK[:class] = 
%Q{class MyClass
end}

INDENT_OK[:one_line_class] =
%Q{class MyClass; end}

INDENT_OK[:one_line_subclass] =
  %Q{class MyClass < RuntimeError; end}

INDENT_OK[:one_line_subclass_with_inheritance] =
  %Q{class MyClass < Array
  class MyError < RuntimeError; end
  include AnotherThing
end}

INDENT_OK[:class_empty] =
%Q{class MyClass

end}

INDENT_OK[:class_empty_trailing_comment] =
  %Q{class MyClass    # Comment!

end}

INDENT_OK[:class_singlestatement] =
%Q{class MyClass
  include Stuff
end}

INDENT_OK[:assignment_addition_multistatement] =
%Q{thing = 1 +
  2 + 3 + 4 +
  5}

INDENT_OK[:assignment_addition_multistatement_trailing_comment] =
  %Q{thing = 1 +    # Comment!
  2 + 3 + 4 +
  5}

INDENT_OK[:assignment_hash_multistatement] =
%Q{thing = {
  :one => 'one',
  two: 'two'
}}

INDENT_OK[:assignment_hash_multistatement_trailing_comment] =
  %Q{thing = {
  :one => 'one', # Comment
  two: 'two'
}}

INDENT_OK[:assignment_array_multistatement] =
%Q{thing = [
  :one,
  :two
]}

INDENT_OK[:assignment_array_multistatement_trailing_comment] =
  %Q{thing = [
  :one,            # comment
  :two
]}

INDENT_OK[:assignment_paren_multistatement] =
  %Q{eval('puts',
  binding,
  'my_file.rb',
  5)}

INDENT_OK[:assignment_paren_multistatement_trailing_comment] =
  %Q{eval('puts',
  binding,
  'my_file.rb',         # comment
  5)}

INDENT_OK[:assignment_twolevel_hash_multistatement] =
%Q{thing = {
  :one => {
    :a => 'a',
    b: => 'b'
  },
  two: {
    x: 'x',
    :y => 'y'
  }
}}

INDENT_OK[:assignment_twolevel_array_multistatement] =
%Q{thing = [
  [:one],
  [
    :two,
    :three
  ]
]}

INDENT_OK[:assignment_twolevel_paren_multistatement] =
%Q{result = Integer(
  String.new(
    "1"
  ).to_i,
  16
)}

INDENT_OK[:method_call_multistatement] =
%Q{my_method_with_many_params(one, two,
  three,
  four,
  five)}

INDENT_OK[:method_call_multistatement_trailing_comment] =
  %Q{my_method_with_many_params(one, two,
  three,    # comment
  four,
  five)}

INDENT_OK[:method_call_multistatement_lonely_paren] =
  %Q{my_method_with_many_params(one, two,
  three,
  four,
  five
)}

INDENT_OK[:method_call_multistatement_lonely_paren_trailing_comment] =
  %Q{my_method_with_many_params(one, two,  # comment
  three,
  four,
  five
)}

INDENT_OK[:rescue_ending_with_comma] =
  %Q{begin
  ssh.upload source, dest
  @logger.info "Successfully copied the file \#{source} to " +
    "\#{@config[:scp_hostname]}:\#{dest}."
rescue SocketError, ArgumentError, SystemCallError,
  Net::SCP::Exception, Timeout::Error => ex
  @logger.error "Failed to copy the file \#{source} to \#{dest} due to " +
    "\#{ex.message}"
end}

INDENT_OK[:rescue_ending_with_comma_trailing_comment] =
  %Q{begin
  ssh.upload source, dest
  @logger.info "Successfully copied the file \#{source} to " +
    "\#{@config[:scp_hostname]}:\#{dest}."
rescue SocketError, ArgumentError, SystemCallError,     # comment
  Net::SCP::Exception, Timeout::Error => ex
  @logger.error "Failed to copy the file \#{source} to \#{dest} due to " +
    "\#{ex.message}"
end}

INDENT_OK[:keyword_ending_with_period] =
  %Q{if [].
  empty?
  puts 'hi'
end}

INDENT_OK[:keyword_ending_with_period_trailing_comment] =
  %Q{if [].   # comment
  empty?
  puts 'hi'
end}

INDENT_OK[:def] =
%Q{def a_method
end}

INDENT_OK[:def_empty] =
%Q{def a_method

end}

INDENT_OK[:nested_def] =
%Q{def first_method
  def second_method
    puts "hi"
  end
end}

INDENT_OK[:nested_class] =
%Q{class MyClass
  class AnotherClass
  end
end}

INDENT_OK[:require_class_singlestatement] =
%Q{require 'time'

class MyClass
  include Stuff
end}

INDENT_OK[:require_class_singlestatement_def] =
%Q{require 'time'

class MyClass
  include Stuff

  def a_method
  end
end}

INDENT_OK[:require_class_singlestatement_def_content] =
%Q{require 'time'

class MyClass
  include Stuff

  def a_method
    puts "hello"
  end
end}

INDENT_OK[:if_modifier] =
%Q{puts "hi" if nil.nil?}

INDENT_OK[:if_modifier2] =
  %Q{start_key_registration_server if @profiles.values.include? :SM5000}

INDENT_OK[:def_return_if_modifier] =
%Q{def a_method
  return @something if @something
end}

INDENT_OK[:unless_modifier] =
%Q{puts "hi" unless nil.nil?}

INDENT_OK[:def_return_unless_modifier] =
%Q{def a_method
  return @something unless @something
end}

INDENT_OK[:multi_line_if_with_trailing_andop] =
  %Q{unless Tim::Runner.configuration[:scp_hostname].nil?
  @reporter.secure_copy if Tim::Runner.configuration[:scp_username] &&
    Tim::Runner.configuration[:scp_password]
end}

INDENT_OK[:while_within_single_line_block] =
  %Q{Timeout::timeout(DEVICE_TIMEOUT) { sleep(0.5) while @device_server.urls.nil? }}

INDENT_OK[:case_whens_level] =
  %Q{def my_method
  case true
  when true
    puts "stuff"
  when false
    puts "blah blah"
  end
end}

INDENT_OK[:case_strings_in_strings] =
  %Q{case type
when :output
  "I like to \#{eval('puts')}, but should be \#{eval('print')}"
when :input
  "Gimme \#{eval('gets')}!"
end}

INDENT_OK[:case_whens_in] =
  %Q{def my_method
  case true
    when true
      puts "stuff"
    when false
      puts "blah blah"
  end
end}

INDENT_OK[:while_do_loop] =
  %Q{while true do
  puts "something"
end}

INDENT_OK[:while_do_loop2] =
  %Q{i = 0;
num = 5;

while i < num do
  puts("Inside the loop i = \#{i}");
  i +=1;
end}

INDENT_OK[:until_do_loop] =
  %Q{until true do
  puts "something"
end}

INDENT_OK[:until_do_loop2] =
  %Q{i = 0;
num = 5;

until i > num  do
  puts("Inside the loop i = \#{i}");
  i +=1;
end}

INDENT_OK[:for_do_loop] =
  %Q{for i in 1..100 do
  puts i
end}

INDENT_OK[:loop_do_loop] =
  %Q{loop do
  puts 'looping'
end}

INDENT_OK[:while_as_modifier_loop] =
  %Q{i = 0;
num = 5;
begin
  puts("Inside the loop i = \#{i}");
  i +=1;
end while i < num}

INDENT_OK[:until_as_modifier_loop] =
  %Q{i = 0;
num = 5;
begin
  puts("Inside the loop i = \#{i}");
  i +=1;
end until i > num}

INDENT_OK[:for_with_break_loop] =
  %Q{for i in 0..5
  if i > 2 then
    break
  end
  puts "Value of local variable is \#{i}"
end}

INDENT_OK[:for_with_next_loop] =
  %Q{for i in 0..5
  if i < 2 then
    next
  end
  puts "Value of local variable is \#{i}"
end}

INDENT_OK[:for_with_redo_loop] =
  %Q{for i in 0..5
  if i < 2 then
    puts "Value of local variable is \#{i}"
    redo
  end
end}

INDENT_OK[:for_with_retry_loop] =
  %Q{for i in 1..5
  retry if  i > 2
  puts "Value of local variable is \#{i}"
end}

INDENT_OK[:loop_with_braces] =
  %Q{loop {
  puts 'stuff'
}}

#----------- Braces ----------#
INDENT_OK[:single_line_braces] =
  %Q{{ one: 1, two: 2 }}

INDENT_OK[:single_line_braces_as_t_string] =
  %Q{%Q{this is a t string!}}

INDENT_OK[:multi_line_braces] =
  %Q{{ one: 1,
  two: 2 }}

INDENT_OK[:multi_line_braces_as_t_string] =
  %Q{%Q{this is a t string!
suckaaaaaa!}}

INDENT_OK[:multi_line_lonely_braces] =
  %Q{{
  :one => 'one', :two => 'two',
  :three => 'three'
}}

INDENT_OK[:multi_line_lonely_braces_as_t_string] =
  %Q{%Q{
this is a t string!
suckaaaaaa!
}}

INDENT_OK[:multi_line_braces_embedded_arrays] =
  %Q{{
  :one => ['one', 17, {}], :two => ['two'],
  :three => 'three'
}}
INDENT_OK[:braces_combo] =
  %Q{{ three: 3 }
{
  three: 3 }
{ three: 3
}
{
  three: 3
}}

#----------- Brackets ----------#
INDENT_OK[:single_line_brackets] =
  %Q{['one', 'two', 'three']}

INDENT_OK[:single_line_brackets_as_t_string] =
  %Q{%Q[this is a t string!]}

INDENT_OK[:multi_line_brackets] =
  %Q{['one',
  'two',
  'three']}

INDENT_OK[:multi_line_brackets_as_t_string] =
  %Q{%Q[this is a t string!
                                it doesn't matter that this is way over here.
suckaaaaaa!]}

INDENT_OK[:multi_line_lonely_brackets] =
  %Q{[
  'one',
  'two',
  'three'
]}

INDENT_OK[:multi_line_lonely_brackets_as_t_string] =
  %Q{%Q[
this is a t string!
                                it doesn't matter that this is way over here.
suckaaaaaa!
]}

INDENT_OK[:multi_line_brackets_embedded_hashes] =
  %Q{summary_table.rows << [{ value: "File", align: :center },
  { value: "Total Problems", align: :center }]}

INDENT_OK[:brackets_combo] =
  %Q{[2]
[
  2]
[2
]
[
  2
]}

#----------- Parens ----------#

INDENT_OK[:single_line_parens] =
  %Q{(true || false)}

INDENT_OK[:single_line_parens_as_t_string] =
  %Q{%Q(this is a t string!)}

INDENT_OK[:multi_line_parens] =
  %Q{my_method(first_argument, second_arg,
  third_arg)}

INDENT_OK[:multi_line_parens_as_t_string] =
  %Q{%Q(this is a t string!
and i'm not going
anywhere!')}

INDENT_OK[:multi_line_lonely_parens] =
  %Q{my_method(
  first_argument
)}

INDENT_OK[:multi_line_lonely_parens_with_commas] =
  %Q{my_method(
  first_argument, second_arg,
  third_arg
)}

INDENT_OK[:multi_line_lonely_parens_as_t_string] =
  %Q{%Q(
this is a t string!
and i'm not going
anywhere!'
)}

INDENT_OK[:parens_combo] =
  %Q{(1)
(
  1)
(1
)
(
  1
)}


#-------------------------------------------------------------------------------
# Operators
#-------------------------------------------------------------------------------
INDENT_OK[:multi_line_ops] =
  %Q{2 -
  1 -
  0 +
  12}

INDENT_OK[:multi_line_andop_in_method] =
  %Q{def end_of_multiline_string?(lexed_line_output)
  lexed_line_output.any? { |e| e[1] == :on_tstring_end } &&
    lexed_line_output.none? { |e| e[1] == :on_tstring_beg }
end}

INDENT_OK[:multi_line_rshift_in_method] =
  %Q{rule(:transport_specifier) do
  match('[A-Za-z]').repeat(3).as(:streaming_protocol) >> forward_slash >>
    match('[A-Za-z]').repeat(3).as(:profile) >>
    (forward_slash >> match('[A-Za-z]').repeat(3).as(:transport_protocol)).maybe
end

rule(:interleaved) do
  str('interleaved=') >> number.as(:rtp_channel) >> dash >>
    number.as(:rtcp_channel)
end

rule(:ttl) do
  str('ttl=') >> match('[\d]').repeat(1, 3).as(:ttl)
end}

INDENT_OK[:multi_line_string_concat_with_plus] =
  %Q{DVR_SSDP_NOTIFICATION_TEMPLATE = File.dirname(__FILE__) +
  '/profiles/DVR5000/ssdp_notification.erb'}

INDENT_OK[:multi_line_string_concat_with_plus_in_parens] =
  %Q{DVR_CONFIG_RENDERER = Erubis::Eruby.new(File.read File.dirname(__FILE__) +
  '/profiles/DVR5000/device_config.xml.erb')}

INDENT_OK[:multi_line_string_concat_twice] =
  %Q{unless Tim::Runner.configuration[:email].nil? ||
  Tim::Runner.configuration[:email].empty?
  Tim::EmailReporter.subject_status ||= subject_status
  @email_reporter.send_email
end

def print_iteration_start iteration_number
  iteration_message = "Running Iteration \#{iteration_number} of " +
    @config[:suite_iterations].to_s
  @logger.info bar(iteration_message)
end}

#-------------------------------------------------------------------------------
# Method calls
#-------------------------------------------------------------------------------
INDENT_OK[:multi_line_method_call] =
  %Q{def initialize(raw_response)
  if raw_response.nil? || raw_response.empty?
    raise RTSP::Error,
      "\#{self.class} received nil string--this shouldn't happen."
  end

  @raw_response = raw_response

  head, body = split_head_and_body_from @raw_response
  parse_head(head)
  @body = parse_body(body)
end}

INDENT_OK[:multi_line_method_call_ends_with_period] =
  %Q{unless streamer == MulticastStreamer.instance
  streamer.state = :DISCONNECTED
  UnicastStreamer.pool << streamer unless UnicastStreamer.pool.
    member? streamer
end}

INDENT_OK[:multi_line_method_call_ends_with_many_periods] =
  %Q{my_hashie.first_level.
  second_level.
  third_level}

INDENT_OK[:method_closing_lonely_paren] =
  %Q{def your_thing(one
  )
end}

INDENT_OK[:method_lonely_args] =
  %Q{def your_thing(
  one
)
  puts "stuff"
end}

#------------------------------------------------------------------------------
# If + logical operators
#------------------------------------------------------------------------------
INDENT_OK[:multi_line_if_logical_and] =
  %Q{if @indentation_ruler.op_statement_nesting.empty? &&
  @indentation_ruler.tstring_nesting.empty? &&
  @indentation_ruler.paren_nesting.empty? &&
  @indentation_ruler.brace_nesting.empty? &&
  @indentation_ruler.bracket_nesting.empty?
  if current_line.line_ends_with_comma?
    if @indentation_ruler.last_comma_statement_line.nil?
      @indentation_ruler.increase_next_line
    end

    @indentation_ruler.last_comma_statement_line = lineno
    log "last: \#{@indentation_ruler.last_comma_statement_line}"
  end
end}

INDENT_OK[:multi_line_each_block] =
  %Q{style.each do |ruler_name, value|
  instance_eval(
    "Tailor::Rulers::\#{camelize(ruler_name.to_s)}Ruler.new(\#{value})"
  )
  parent_ruler.add_child_ruler(ruler)
end}

INDENT_OK[:multi_line_each_block_with_op_and_parens] =
  %Q{style.each do |ruler_name, value|
  ruler =
    instance_eval(
      "Tailor::Rulers::\#{camelize(ruler_name.to_s)}Ruler.new(\#{value})"
    )
  parent_ruler.add_child_ruler(ruler)
end}

#-------------------------------------------------------------------------------
# Single-line keywords
#-------------------------------------------------------------------------------
INDENT_OK[:single_line_begin_rescue_end] =
  %Q{def log
  l = begin; lineno; rescue; "<EOF>"; end
  c = begin; column; rescue; "<EOF>"; end
  subclass_name = self.class.to_s.sub(/^Tailor::/, '')
  args.first.insert(0, "<\#{subclass_name}> \#{l}[\#{c}]: ")
  Tailor::Logger.log(*args)
end}

#-------------------------------------------------------------------------------
# Combos
#-------------------------------------------------------------------------------
INDENT_OK[:combo1] =
  %Q{def set_default_smtp
  Mail.defaults do
    @config = Tim::Runner.configuration
    delivery_method(:smtp,
      { :address => @config[:smtp_server],
        :port => @config[:smtp_server_port] })
  end
end}

INDENT_OK[:combo2] =
%Q{class C

  send :each do
    def foo
    end
  end

end}

INDENT_OK[:brace_bracket_paren_combo1] =
  %Q{[{ :one => your_thing(
  1)
}
]}

INDENT_OK[:paren_comma_combo1] =
  %Q{def do_something
  self[:log_file_location] = Time.now.strftime(File.join(Tim::LOG_DIR,
    "\#{self[:product]}_%Y-%m-%d_%H-%M-%S.log"))

  handle_arguments arg_list
end}

INDENT_OK[:line_ends_with_label] =
  %Q{options = {
  actual_trailing_spaces:
    lexed_line.last_non_line_feed_event.last.size
}}

#-------------------------------------------------------------------------------
# INDENT_1 (1 problem)
#-------------------------------------------------------------------------------
INDENT_1 = {}

INDENT_1[:class_indented_end] =
%Q{class MyClass
 end}

INDENT_1[:class_indented_singlestatement] =
%Q{class MyClass
   include Something
end}

INDENT_1[:class_indented_singlestatement_trailing_comment] =
  %Q{class MyClass
   include Something     # comment
end}

INDENT_1[:class_outdented_singlestatement] =
%Q{class MyClass
 include Something
end}

INDENT_1[:def_indented_end] =
%Q{def a
 end}

INDENT_1[:def_content_indented_end] =
%Q{def a
  puts "stuff"
 end}

INDENT_1[:class_def_content_outdented_end] =
%Q{class A
  def a
    puts "stuff"
 end
end}

INDENT_1[:class_def_outdented_content] =
%Q{class A
  def a
   puts "stuff"
  end
end}

INDENT_1[:class_method_def_using_self_outdented] =
%Q{class A
 self.my_method
    puts 'stuff'
  end
end}

INDENT_1[:case_indented_whens_level] =
%Q{def my_method
   case true
  when true
    puts "stuff"
  when false
    puts "blah blah"
  end
end}

INDENT_1[:case_indented_whens_level_trailing_comment] =
  %Q{def my_method
   case true        # comment
  when true
    puts "stuff"
  when false
    puts "blah blah"
  end
end}

INDENT_1[:case_outdented_whens_level] =
%Q{def my_method
 case true
  when true
    puts "stuff"
  when false
    puts "blah blah"
  end
end}

INDENT_1[:case_when_indented_whens_level] =
  %Q{def my_method
  case true
   when true
    puts "stuff"
  when false
    puts "blah blah"
  end
end}

INDENT_1[:case_when_outdented_whens_level] =
  %Q{def my_method
  case true
 when true
    puts "stuff"
  when false
    puts "blah blah"
  end
end}

INDENT_1[:case_indented_whens_in] =
  %Q{def my_method
   case true
    when true
      puts "stuff"
    when false
      puts "blah blah"
  end
end}

INDENT_1[:while_do_indented] =
  %Q{ while true do
  puts "something"
end}

INDENT_1[:while_do_outdented] =
  %Q{def my_method
 while true do
    puts "something"
  end
end}

INDENT_1[:while_do_content_outdented] =
  %Q{def my_method
  while true do
   puts "something"
  end
end}

INDENT_1[:while_do_content_indented] =
  %Q{def my_method
  while true do
     puts "something"
  end
end}

INDENT_1[:while_do_indented2] =
  %Q{i = 0;
num = 5;

 while i < num do
  puts("Inside the loop i = \#{i}" );
  i +=1;
end}

INDENT_1[:while_do_indented2_trailing_comment] =
  %Q{i = 0;
num = 5;

 while i < num do        # comment
  puts("Inside the loop i = \#{i}" );
  i +=1;
end}

INDENT_1[:until_do_indented] =
  %Q{i = 0;
num = 5;

 until i > num  do
  puts("Inside the loop i = \#{i}" );
  i +=1;
end}

INDENT_1[:for_do_indented] =
  %Q{ for i in 1..100 do
  puts i
end}

INDENT_1[:loop_do_indented] =
  %Q{ loop do
  puts 'looping'
end}

INDENT_1[:multi_line_string_first_line_indented] =
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

INDENT_1[:multi_line_string_first_line_indented_trailing_comment] =
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

#-------------------------------------------------------------------------------
# Operators
#-------------------------------------------------------------------------------
INDENT_1[:multi_line_andop_first_line_indented] =
  %Q{def end_of_multiline_string?(lexed_line_output)
   lexed_line_output.any? { |e| e[1] == :on_tstring_end } &&
    lexed_line_output.none? { |e| e[1] == :on_tstring_beg }
end}

INDENT_1[:multi_line_andop_first_line_indented_trailing_comment] =
  %Q{def end_of_multiline_string?(lexed_line_output)
   lexed_line_output.any? { |e| e[1] == :on_tstring_end } && # comment
    lexed_line_output.none? { |e| e[1] == :on_tstring_beg }
end}

INDENT_1[:multi_line_andop_second_line_indented] =
  %Q{def end_of_multiline_string?(lexed_line_output)
  lexed_line_output.any? { |e| e[1] == :on_tstring_end } &&
     lexed_line_output.none? { |e| e[1] == :on_tstring_beg }
end}

INDENT_1[:multi_line_string_concat_with_plus_out] =
  %Q{DVR_SSDP_NOTIFICATION_TEMPLATE = File.dirname(__FILE__) +
 '/profiles/DVR5000/ssdp_notification.erb'}

INDENT_1[:multi_line_method_call_end_in] =
  %Q{def initialize(raw_response)
  if raw_response.nil? || raw_response.empty?
    raise RTSP::Error,
      "#{self.class} received nil string--this shouldn't happen."
   end
end}

INDENT_1[:multi_line_method_call_ends_with_period_2nd_line_in] =
  %Q{unless streamer == MulticastStreamer.instance
  streamer.state = :DISCONNECTED
  UnicastStreamer.pool << streamer unless UnicastStreamer.pool.
     member? streamer
end}

INDENT_1[:multi_line_method_call_ends_with_many_periods_last_in] =
  %Q{my_hashie.first_level.
  second_level.
    third_level}

INDENT_1[:multi_line_method_call_ends_with_many_periods_last_in_trailing_comment] =
  %Q{my_hashie.first_level.
  second_level.
    third_level  # comment}

