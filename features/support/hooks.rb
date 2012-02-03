Before do
  @original_home = ENV['HOME']
  ENV['HOME'] = '.'
end

After do
  ENV['HOME'] = @original_home
end
