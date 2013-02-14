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
      # @param [Hash] problems Values are filenames; keys are problems for each
      #   of those files.
      def summary_report(problems)
        build_hash(problems).to_yaml
      end

      private
      def build_hash(problems)
        detected = problems.select {|k,v| !v.empty?}
        return {} if detected.empty?

        detected.inject({}) do |result, hash|
          filename = hash[0]
          probs = hash[1].first
          result[filename] = {
            type: probs[:type],
            line: probs[:line],
            column: probs[:column],
            message: probs[:message],
            level: probs[:level]
          }
          result
        end
      end
    end
  end
end
