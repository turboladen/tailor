STATS_DIRECTORIES = [
  %w(Library            lib/),
  %w(Feature\ tests     features/),
  %w(Unit\ tests        spec/)
].collect { |name, dir| [ name, "#{dir}" ] }.select { |name, dir| File.directory?(dir) }

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require 'code_statistics'
  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end