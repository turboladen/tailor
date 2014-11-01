LINE_INDENT = {}

LINE_INDENT['hash_spans_lines'] =
  %(db_connection = { :host => "localhost", :username => 'root',
  :password => node['db']['password'] })

LINE_INDENT['if_else'] =
  %(case "foo"
when "foo"
  if node["foo"]["version"].to_f >= 5.5
    default['foo']['service_name'] = "foo"
    default['foo']['pid_file'] = "/var/run/foo/foo.pid"
  else
    default['foo']['service_name'] = "food"
    default['foo']['pid_file'] = "/var/run/food/food.pid"
  end
end)

LINE_INDENT['line_continues_at_same_indentation'] =
  %(if someconditional_that == is_really_long.function().stuff() or
  another_condition == some_thing
  puts "boop"
end)

LINE_INDENT['line_continues_further_indented'] =
  %(if someconditional_that == is_really_long.function().stuff() or
    another_condition == some_thing
  puts "boop"
end)

LINE_INDENT['line_continues_without_nested_statements'] =
  %(attribute "foo/password",
  :display_name => "Password",
  :description => "Randomly generated password",
  :default => "randomly generated")

LINE_INDENT['minitest_test_cases'] =
  %q(describe "foo" do
  it 'includes the disk_free_limit configuration setting' do
    file("#{node['foo']['config_root']}/foo.config").
      must_match /\{disk_free_limit, \{mem_relative, #{node['foo']['df']}/
  end
  it 'includes the vm_memory_high_watermark configuration setting' do
    file("#{node['foo']['config_root']}/foo.config").
      must_match /\{vm_memory_high_watermark, #{node['foo']['vm']}/
  end
end)

LINE_INDENT['nested_blocks'] =
  %(node['foo']['client']['packages'].each do |foo_pack|
  package foo_pkg do
    action :install
  end
end)

LINE_INDENT['one_assignment_per_line'] =
  %(default['foo']['bar']['apt_key_id'] = 'BD2EFD2A'
default['foo']['bar']['apt_uri'] = "http://repo.example.com/apt"
default['foo']['bar']['apt_keyserver'] = "keys.example.net")

LINE_INDENT['parameters_continuation_indent_across_lines'] =
  %(def something(waka, baka, bing,
    bla, goop, foop)
  stuff
end)

LINE_INDENT['parameters_no_continuation_indent_across_lines'] =
  %(def something(waka, baka, bing,
  bla, goop, foop)
  stuff
end)
