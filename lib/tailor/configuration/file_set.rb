require_relative '../runtime_error'
require_relative '../logger'
require_relative 'style'

class Tailor
  class Configuration
    class FileSet < Hash
      include Tailor::Logger::Mixin

      DEFAULT_GLOB = 'lib/**/*.rb'

      attr_reader :style
      attr_accessor :file_list

      # @param [Hash] style Style options to merge into the default Style
      #   settings.
      # @param [String,Array] file_expression
      def initialize(file_expression=nil, style=nil)
        @style = if style
          Style.new.to_hash.merge(style)
        else
          Style.new.to_hash
        end

        self[:style] = @style

        file_expression ||= DEFAULT_GLOB
        @file_list = build_file_list(file_expression)
        self[:file_list] = @file_list
      end

      def update_file_list(file_expression)
        new_list = build_file_list(file_expression)
        @file_list.concat(new_list).uniq!
      end

      def update_style(new_style)
        @style.to_hash.merge!(new_style)
      end

      def [](key)
        if key == :style
          @style.to_hash
        elsif key == :file_list
          @file_list
        else
          raise Tailor::RuntimeError, "Invalid key requested: #{key}"
        end
      end

      def file_list=(file_expression)
        @file_list = build_file_list(file_expression)
      end

      private

      # The list of the files in the project to check.
      #
      # @param [String] file_expression Path to the file, directory or file_expression to check.
      # @return [Array] The list of files to check.
      def build_file_list(file_expression)
        files_in_project = if file_expression.is_a? Array
          log "Configured file_expression is an Array: #{file_expression}"

          file_expression.map do |e|
            if File.directory?(e)
              all_files_in_dir(e)
            else
              e
            end
          end.flatten.uniq
        elsif File.directory? file_expression
          log "Configured file_expression is an directory: #{file_expression}"
          all_files_in_dir(file_expression)
        elsif File.file? file_expression
          log "Configured file_expression is a single-file: #{file_expression}"
          [file_expression]
        else
          log "Configured file_expression is a glob: #{file_expression}"
          Dir.glob file_expression
        end

        list_with_absolute_paths = []

        files_in_project.each do |file|
          new_file = File.expand_path(file)
          log "file: #{new_file}"

          if File.exists? new_file
            list_with_absolute_paths <<  new_file
          end
        end

        list_with_absolute_paths.sort
      end

      # Gets a list of only files that are in +base_dir+.
      #
      # @param [String] base_dir The directory to get the file list for.
      # @return [Array<String>] The List of files.
      def all_files_in_dir(base_dir)
        Dir.glob(File.join(base_dir, '**', '*')).find_all do |file|
          file if File.file?(file)
        end
      end
    end
  end
end
