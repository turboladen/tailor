require_relative 'tailor/configuration'

class Tailor
  def self.config &block
    @configuration = {}
    @configuration[:file_sets] = []
    instance_eval &block
    
    @configuration
  end
  
  def self.method_missing(meth, *args, &blk)
    default_config = Tailor::Configuration.default
    ok_methods = default_config[:file_sets].first[:style].keys
    
    if meth == :formatters
      @configuration[:formatters] = args.first
    elsif meth == :file_set
      @configuration[:file_sets] << { file_list: args.first, style: {} }
      instance_eval &blk
    elsif ok_methods.include? meth
      @configuration[:file_sets].last[:style][meth] = args.first
    else
      super(meth, args, blk)
    end
  end
end
