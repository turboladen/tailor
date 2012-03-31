require_relative 'tailor/configuration'
require_relative 'tailor/runtime_error'

class Tailor
  def self.config &block
    @configuration = {}
    @configuration[:file_sets] = {}
    instance_eval &block
    
    @configuration
  end
  
  def self.method_missing(meth, *args, &blk)
    default_config = Tailor::Configuration.default
    ok_methods = default_config[:file_sets][:default][:style].keys
    
    if meth == :formatters
      @configuration[:formatters] = args.first
    elsif meth == :file_set
      if args.first.nil?
        msg = ":file_set can't be nil. "
        msg << "Please specify a file, directory or glob to check."
        raise Tailor::RuntimeError, msg
      elsif args.first.class != String
        msg = ":file_set can't be a(n) #{args.first.class}. "
        msg << "Please use a String to provide a directory or glob to check."
        raise Tailor::RuntimeError, msg
      end
      
      @label = args[1] ? args[1].to_sym : :default
      
      @configuration[:file_sets][@label] = {
        file_list: args.first,
        style: {}
      }
      instance_eval &blk
    elsif ok_methods.include? meth
      @configuration[:file_sets][@label][:style][meth] = args.first
    else
      super(meth, args, blk)
    end
  end
end
