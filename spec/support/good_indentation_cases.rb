INDENT_OK = {}

INDENT_OK['class'] =
  %(class MyClass
end)

INDENT_OK['one_line_class'] =
  %(class MyClass; end)

INDENT_OK['one_line_subclass'] =
  %(class MyClass < RuntimeError; end)

INDENT_OK['one_line_subclass_with_inheritance'] =
  %(class MyClass < Array
  class MyError < RuntimeError; end
  include AnotherThing
end)

INDENT_OK['class_empty'] =
  %(class MyClass

end)

INDENT_OK['class_empty_trailing_comment'] =
  %(class MyClass    # Comment!

end)

INDENT_OK['class_singlestatement'] =
  %(class MyClass
  include Stuff
end)

INDENT_OK['assignment_addition_multistatement'] =
  %(thing = 1 +
  2 + 3 + 4 +
  5)

INDENT_OK['assignment_addition_multistatement_trailing_comment'] =
  %(thing = 1 +    # Comment!
  2 + 3 + 4 +
  5)

INDENT_OK['assignment_hash_multistatement'] =
  %(thing = {
  :one => 'one',
  two: 'two'
})

INDENT_OK['assignment_hash_multistatement_trailing_comment'] =
  %(thing = {
  :one => 'one', # Comment
  two: 'two'
})

INDENT_OK['assignment_array_multistatement'] =
  %(thing = [
  :one,
  :two
])

INDENT_OK['assignment_array_multistatement_trailing_comment'] =
  %(thing = [
  :one,            # comment
  :two
])

INDENT_OK['assignment_paren_multistatement'] =
  %(eval('puts',
  binding,
  'my_file.rb',
  5))

INDENT_OK['assignment_paren_multistatement_trailing_comment'] =
  %(eval('puts',
  binding,
  'my_file.rb',         # comment
  5))

INDENT_OK['assignment_twolevel_hash_multistatement'] =
  %(thing = {
  :one => {
    :a => 'a',
    b: 'b'
  },
  two: {
    x: 'x',
    :y => 'y'
  }
})

INDENT_OK['assignment_twolevel_array_multistatement'] =
  %(thing = [
  [:one],
  [
    :two,
    :three
  ]
])

INDENT_OK['assignment_twolevel_paren_multistatement'] =
  %(result = Integer(
  String.new(
    '1'
  ).to_i,
  16
))

INDENT_OK['method_call_multistatement'] =
  %(my_method_with_many_params(one, two,
  three,
  four,
  five))

INDENT_OK['method_call_multistatement_trailing_comment'] =
  %(my_method_with_many_params(one, two,
  three,    # comment
  four,
  five))

INDENT_OK['method_call_multistatement_lonely_paren'] =
  %(my_method_with_many_params(one, two,
  three,
  four,
  five
))

INDENT_OK['method_call_multistatement_lonely_paren_trailing_comment'] =
  %(my_method_with_many_params(one, two,  # comment
  three,
  four,
  five
))

#-------------------------------------------------------------------------------
# Continuation keywords
#-------------------------------------------------------------------------------
INDENT_OK['rescue_ending_with_comma'] =
  %(begin
  ssh.upload source, dest
  @logger.info "Successfully copied the file \#{source} to " +
    "\#{@config[:scp_hostname]}:\#{dest}."
rescue SocketError, ArgumentError, SystemCallError,
  Net::SCP::Exception, Timeout::Error => ex
  @logger.error "Failed to copy the file \#{source} to \#{dest} due to " +
    ex.message
end)

INDENT_OK['rescue_ending_with_comma_trailing_comment'] =
  %(begin
  ssh.upload source, dest
  @logger.info "Successfully copied the file \#{source} to " +
    "\#{@config[:scp_hostname]}:\#{dest}."
rescue SocketError, ArgumentError, SystemCallError,     # comment
  Net::SCP::Exception, Timeout::Error => ex
  @logger.error "Failed to copy the file \#{source} to \#{dest} due to " +
    ex.message
end)

INDENT_OK['def_rescue'] =
  %(def some_method
  do_something(one, two)
rescue => e
  log 'It didn't work.'
  raise e
end)

INDENT_OK['keyword_ending_with_period'] =
  %(if [].
  empty?
  puts 'hi'
end)

INDENT_OK['keyword_ending_with_period_trailing_comment'] =
  %(if [].   # comment
  empty?
  puts 'hi'
end)

INDENT_OK['def'] =
  %(def a_method
end)

INDENT_OK['def_empty'] =
  %(def a_method

end)

INDENT_OK['nested_def'] =
  %(def first_method
  def second_method
    puts 'hi'
  end
end)

INDENT_OK['nested_class'] =
  %(class MyClass
  class AnotherClass
  end
end)

INDENT_OK['require_class_singlestatement'] =
  %(require 'time'

class MyClass
  include Stuff
end)

INDENT_OK['class_as_symbol'] =
  %(INDENT_OK = {}

INDENT_OK[:class] =
  %Q{class MyClass
end}

INDENT_OK[:one_line_class] =
  %Q{class MyClass; end})

INDENT_OK['require_class_singlestatement_def'] =
  %(require 'time'

class MyClass
  include Stuff

  def a_method
  end
end)

INDENT_OK['require_class_singlestatement_def_content'] =
  %(require 'time'

class MyClass
  include Stuff

  def a_method
    puts 'hello'
  end
end)

INDENT_OK['if_modifier'] =
  %(puts 'hi' if nil.nil?)

INDENT_OK['if_modifier2'] =
  %(start_key_registration_server if @profiles.values.include? :SM5000)

INDENT_OK['def_return_if_modifier'] =
  %(def a_method
  return @something if @something
end)

INDENT_OK['unless_modifier'] =
  %(puts 'hi' unless nil.nil?)

INDENT_OK['def_return_unless_modifier'] =
  %(def a_method
  return @something unless @something
end)

INDENT_OK['multi_line_if_with_trailing_andop'] =
  %(unless Tim::Runner.configuration[:scp_hostname].nil?
  @reporter.secure_copy if Tim::Runner.configuration[:scp_username] &&
    Tim::Runner.configuration[:scp_password]
end)

INDENT_OK['while_within_single_line_block'] =
  %(Timeout::timeout(DEVICE_TIMEOUT) { sleep(0.5) while @device_server.urls.nil? })

INDENT_OK['case_whens_level'] =
  %(def my_method
  case true
  when true
    puts 'stuff'
  when false
    puts 'blah blah'
  end
end)

INDENT_OK['case_strings_in_strings'] =
  %(case type
when :output
  "I like to \#{eval('puts')}, but should be \#{eval('print')}"
when :input
  "Gimme \#{eval('gets')}!"
end)

=begin
INDENT_OK['case_whens_in'] =
  %(def my_method
  case true
    when true
      puts "stuff"
    when false
      puts "blah blah"
  end
end)
=end

INDENT_OK['while_do_loop'] =
  %(while true do
  puts 'something'
end)

INDENT_OK['while_do_loop2'] =
  %(i = 0;
num = 5;

while i < num do
  puts("Inside the loop i = \#{i}");
  i +=1;
end)

INDENT_OK['until_do_loop'] =
  %(until true do
  puts 'something'
end)

INDENT_OK['until_do_loop2'] =
  %(i = 0;
num = 5;

until i > num  do
  puts("Inside the loop i = \#{i}");
  i +=1;
end)

INDENT_OK['for_do_loop'] =
  %(for i in 1..100 do
  puts i
end)

INDENT_OK['loop_do_loop'] =
  %(loop do
  puts 'looping'
end)

INDENT_OK['while_as_modifier_loop'] =
  %(i = 0;
num = 5;
begin
  puts("Inside the loop i = \#{i}");
  i +=1;
end while i < num)

INDENT_OK['until_as_modifier_loop'] =
  %(i = 0;
num = 5;
begin
  puts("Inside the loop i = \#{i}");
  i +=1;
end until i > num)

INDENT_OK['for_with_break_loop'] =
  %(for i in 0..5
  if i > 2 then
    break
  end
  puts "Value of local variable is \#{i}"
end)

INDENT_OK['for_with_next_loop'] =
  %(for i in 0..5
  if i < 2 then
    next
  end
  puts "Value of local variable is \#{i}"
end)

INDENT_OK['for_with_redo_loop'] =
  %(for i in 0..5
  if i < 2 then
    puts "Value of local variable is \#{i}"
    redo
  end
end)

INDENT_OK['for_with_retry_loop'] =
  %(for i in 1..5
  retry if i > 2
  puts "Value of local variable is \#{i}"
end)

INDENT_OK['loop_with_braces'] =
  %(loop {
  puts 'stuff'
})

#----------- Braces ----------#
INDENT_OK['single_line_braces'] =
  %({ one: 1, two: 2 })

INDENT_OK['single_line_braces_as_t_string'] =
  %(%Q{this is a t string!})

INDENT_OK['multi_line_braces'] =
  %({ one: 1,
  two: 2 })

INDENT_OK['multi_line_braces_as_t_string'] =
  %(%Q{this is a t string!
suckaaaaaa!})

# For some reason, Ruby doesn't like '%Q<> here.
INDENT_OK['multi_line_lonely_braces'] =
  %({
  :one => 'one', :two => 'two',
  :three => 'three'
})

INDENT_OK['multi_line_lonely_braces_as_t_string'] =
  %(%Q{
this is a t string!
suckaaaaaa!
})

INDENT_OK['multi_line_braces_embedded_arrays'] =
  %({
  :one => ['one', 17, {}], :two => ['two'],
  :three => 'three'
})

INDENT_OK['braces_combo'] =
  %({ three: 3 }
{
  three: 3 }
{ three: 3
}
{
  three: 3
})

INDENT_OK['deep_hash_with_rockets'] =
  %(im_deep =
  { 'one' =>
    { '1' =>
      { 'a' => 'A',
        'b' => 'B',
        'c' => 'C' },
      '2' =>
      { 'd' => 'D',
        'e' => 'E',
        'f' => 'F' } } })

INDENT_OK['embedded_strings_in_embedded_strings'] =
  %q(def friendly_time(time)
  if hours < 24
    "#{(hours > 0) ? "#{hours} hour" : '' }#{(hours > 1) ? 's' : ''}" +
      " #{(mins > 0) ? "#{mins} minute" : '' }#{(mins > 1) ? 's' : ''}" +
      " #{seconds} second#{(seconds > 1) ? 's' : ''} ago"
  else
    time.to_s
  end
end)

#----------- Brackets ----------#
INDENT_OK['single_line_brackets'] =
  %(['one', 'two', 'three'])

INDENT_OK['single_line_brackets_as_t_string'] =
  %(%Q[this is a t string!])

INDENT_OK['multi_line_brackets'] =
  %(['one',
  'two',
  'three'])

INDENT_OK['multi_line_brackets_as_t_string'] =
  %(%Q[this is a t string!
                                it doesn't matter that this is way over here.
suckaaaaaa!])

INDENT_OK['multi_line_lonely_brackets'] =
  %([
  'one',
  'two',
  'three'
])

INDENT_OK['multi_line_lonely_brackets_as_t_string'] =
  %(%Q[
this is a t string!
                                it doesn't matter that this is way over here.
suckaaaaaa!
])

INDENT_OK['multi_line_brackets_embedded_hashes'] =
  %(summary_table.rows << [{ value: 'File', align: :center },
  { value: 'Total Problems', align: :center }])

INDENT_OK['brackets_combo'] =
  %([2]
[
  2]
[2
]
[
  2
])

#----------- Parens ----------#

INDENT_OK['single_line_parens'] =
  %((true || false))

INDENT_OK['single_line_parens_as_t_string'] =
  %(%Q(this is a t string!))

INDENT_OK['multi_line_parens'] =
  %(my_method(first_argument, second_arg,
  third_arg))

INDENT_OK['multi_line_parens_as_t_string'] =
  %(%Q(this is a t string!
and i'm not going
anywhere!'))

INDENT_OK['multi_line_lonely_parens'] =
  %(my_method(
  first_argument
))

INDENT_OK['multi_line_lonely_parens_with_commas'] =
  %(my_method(
  first_argument, second_arg,
  third_arg
))

INDENT_OK['multi_line_lonely_parens_as_t_string'] =
  %(%Q(
this is a t string!
and i'm not going
anywhere!'
))

INDENT_OK['parens_combo'] =
  %((1)
(
  1)
(1
)
(
  1
))


#-------------------------------------------------------------------------------
# Operators
#-------------------------------------------------------------------------------
INDENT_OK['multi_line_ops'] =
  %(2 -
  1 -
  0 +
  12)

INDENT_OK['multi_line_andop_in_method'] =
  %(def end_of_multiline_string?(lexed_line_output)
  lexed_line_output.any? { |e| e[1] == :on_tstring_end } &&
    lexed_line_output.none? { |e| e[1] == :on_tstring_beg }
end)

INDENT_OK['multi_line_rshift_in_method'] =
  %(rule(:transport_specifier) do
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
end)

INDENT_OK['multi_line_string_concat_with_plus'] =
  %(DVR_SSDP_NOTIFICATION_TEMPLATE = File.dirname(__FILE__) +
  '/profiles/DVR5000/ssdp_notification.erb')

INDENT_OK['multi_line_string_concat_with_plus_in_parens'] =
  %(DVR_CONFIG_RENDERER = Erubis::Eruby.new(File.read File.dirname(__FILE__) +
  '/profiles/DVR5000/device_config.xml.erb'))

INDENT_OK['multi_line_string_concat_twice'] =
  %(unless Tim::Runner.configuration[:email].nil? ||
  Tim::Runner.configuration[:email].empty?
  Tim::EmailReporter.subject_status ||= subject_status
  @email_reporter.send_email
end

def print_iteration_start iteration_number
  iteration_message = "Running Iteration \#{iteration_number} of " +
    @config[:suite_iterations].to_s
  @logger.info bar(iteration_message)
end)

#-------------------------------------------------------------------------------
# Method calls
#-------------------------------------------------------------------------------
INDENT_OK['multi_line_method_call'] =
  %(def initialize(raw_response)
  if raw_response.nil? || raw_response.empty?
    raise RTSP::Error,
      "\#{self.class} received nil string--this shouldn't happen."
  end

  @raw_response = raw_response

  head, body = split_head_and_body_from @raw_response
  parse_head(head)
  @body = parse_body(body)
end)

INDENT_OK['multi_line_method_call_ends_with_period'] =
  %(unless streamer == MulticastStreamer.instance
  streamer.state = :DISCONNECTED
  UnicastStreamer.pool << streamer unless UnicastStreamer.pool.
    member? streamer
end)

INDENT_OK['multi_line_method_call_ends_with_many_periods'] =
  %(my_hashie.first_level.
  second_level.
  third_level)

=begin
INDENT_OK['method_closing_lonely_paren'] =
  %(def your_thing(one
  )
end)
=end

INDENT_OK['method_lonely_args'] =
  %(def your_thing(
  one
)
  puts 'stuff'
end)

#------------------------------------------------------------------------------
# If + logical operators
#------------------------------------------------------------------------------
INDENT_OK['multi_line_if_logical_and'] =
  %(if @indentation_ruler.op_statement_nesting.empty? &&
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
end)

INDENT_OK['multi_line_each_block'] =
  %(style.each do |ruler_name, value|
  instance_eval(
    "Tailor::Rulers::\#{camelize(ruler_name.to_s)}Ruler.new(\#{value})"
  )
  parent_ruler.add_child_ruler(ruler)
end)

INDENT_OK['multi_line_each_block_with_op_and_parens'] =
  %(style.each do |ruler_name, value|
  ruler =
    instance_eval(
      "Tailor::Rulers::\#{camelize(ruler_name.to_s)}Ruler.new(\#{value})"
    )
  parent_ruler.add_child_ruler(ruler)
end)

INDENT_OK['do_end_block_in_parens'] =
  %(begin
  throw(:result, sexp_line.flatten.compact.any? do |s|
    s == MODIFIERS[self]
  end)
rescue NoMethodError
end)

INDENT_OK['block_in_block_ends_on_same_line'] =
  %(%w{
  foo
  bar
  baz
}.each do |thing|
  function thing do
    puts 'stuff'
  end end

puts 'post ends')

=begin
INDENT_OK['rparen_and_do_same_line'] =
  %(opt.on('-c', '--config-file FILE',
  "Use a specific config file.") do |config|
  options.config_file = config
end)
=end

#-------------------------------------------------------------------------------
# Single-line keywords
#-------------------------------------------------------------------------------
INDENT_OK['single_line_begin_rescue_end'] =
  %(def log
  l = begin; lineno; rescue; '<EOF>'; end
  c = begin; column; rescue; '<EOF>'; end
  subclass_name = self.class.to_s.sub(/^Tailor::/, '')
  args.first.insert(0, "<\#{subclass_name}> \#{l}[\#{c}]: ")
  Tailor::Logger.log(*args)
end)

#-------------------------------------------------------------------------------
# Combos
#-------------------------------------------------------------------------------
INDENT_OK['combo1'] =
  %(def set_default_smtp
  Mail.defaults do
    @config = Tim::Runner.configuration
    delivery_method(:smtp,
      { :address => @config[:smtp_server],
        :port => @config[:smtp_server_port] })
  end
end)

INDENT_OK['combo2'] =
  %(class C

  send :each do
    def foo
    end
  end

end)

INDENT_OK['combo3'] =
  %(def report_turducken(results, performance_results)
  stuffing[:log_files] = { "\#{File.basename @logger.log_file_location}/path" =>
    File.read(@logger.log_file_location).gsub(/(?<f><)(?<q>\\/)?(?<w>\\w)/,
      '\\k<f>!\\k<q>\\k<w>') }.merge remote_logs

  begin
    Stuffer.login(@config[:turducken_server], @config[:turducken_username],
      @config[:turducken_password])
    suite_result_url = Stuffer.stuff(stuffing)
  rescue Errno::ECONNREFUSED
    @logger.error 'Unable to connect to Turducken server!'
  end

  suite_result_url
end)

INDENT_OK['brace_bracket_paren_combo1'] =
  %([{ :one => your_thing(
  1)
}
])

INDENT_OK['paren_comma_combo1'] =
  %(def do_something
  self[:log_file_location] = Time.now.strftime(File.join(Tim::LOG_DIR,
    "\#{self[:product]}_%Y-%m-%d_%H-%M-%S.log"))

  handle_arguments arg_list
end)

INDENT_OK['line_ends_with_label'] =
  %(options = {
  actual_trailing_spaces:
    lexed_line.last_non_line_feed_event.last.size
})
