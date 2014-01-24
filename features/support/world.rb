module IndentationHelpers

  # Used for getting the faked file contexts from the indentation_cases.rb file.
  #
  # @param [String] file_name The name of the fake file to get.
  # @return [String]
  def get_file_contents(file_name)
    path_chunks = file_name.split('/')
    const_name = path_chunks.first(2).each { |c| c.upcase! }.join('_')
    const = Kernel.const_get(const_name)

    const[path_chunks.last.to_sym]
  end
end
World(IndentationHelpers)
