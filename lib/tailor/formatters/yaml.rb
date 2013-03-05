require 'pathname'
require 'yaml'
require_relative '../formatter'

class Tailor
  module Formatters
    class Yaml < Tailor::Formatter
      attr_reader :accepts_output_file

      def initialize
        @accepts_output_file = true
        super
      end

      # Prints the report on all of the files that just got checked.
      #
      # @param [Hash] report Values are filenames; keys are problems for each
      #   of those files.
      def summary_report(report)
        build_hash(report).to_yaml
      end

      private

      # @param [Hash] report The list of problems found by Tailor::CLI.
      # @return [Hash] The Hash of problems to be converted to YAML.
      def build_hash(report)
        report.reject! { |_, v| v.empty? }

        report.inject({}) do |result, problem_set|
          file_name = problem_set.first
          problems = problem_set.last

          problems.each do |problem|
            result[file_name] ||= []

            result[file_name] << {
              type: problem[:type],
              line: problem[:line],
              column: problem[:column],
              message: problem[:message],
              level: problem[:level]
            }
          end

          result
        end
      end
    end
  end
end
