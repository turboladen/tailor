require 'spec_helper'
require 'tailor/critic'
require 'tailor/configuration/style'

LONG_METHOD_IN_CLASS = {}
LONG_METHOD_IN_CLASS['ok_with_equals'] = <<-METH
class Test
  def method1
    [1, 2, 3, 4].each do |uuid|
      next if (@profiles[uuid].to_s.start_with? "SM" || @profiles[uuid] ==
        :SystemLogger)
    end
  end

  def method2
    puts 'Do not ever get here.'
  end
end
METH

describe 'Long method detection' do
  before do
    allow(Tailor::Logger).to receive(:log)
    FakeFS.activate!
    File.open('long_method.rb', 'w') { |f| f.write contents }
    subject.check_file(file_name, style.to_hash)
  end

  subject do
    Tailor::Critic.new
  end

  let(:contents) { LONG_METHOD_IN_CLASS[file_name] }

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.indentation_spaces 2, level: :off
    style.allow_invalid_ruby true, level: :off
    style.max_code_lines_in_method 3

    style
  end

  context 'methods are within limits' do
    context 'method ends with line that ends with ==' do
      let(:file_name) { 'ok_with_equals' }
      specify do
        pending 'https://github.com/turboladen/tailor/issues/112'

        expect(subject.problems[file_name].size).to eq 1
      end
    end
  end
end
