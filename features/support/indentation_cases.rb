INDENT_OK = {}

INDENT_OK[:class] = %Q{
class MyClass
end
}

INDENT_OK[:class_empty] = %Q{
class MyClass

end
}

INDENT_OK[:class_include] = %Q{
class MyClass
  include Stuff
end
}

INDENT_OK[:def] = %Q{
def a_method
end
}

INDENT_OK[:def_empty] = %Q{
def a_method

end
}

INDENT_OK[:nested_def] = %Q{
def first_method
  def second_method
    puts "hi"
  end
end
  }

INDENT_OK[:nested_class] = %Q{
class MyClass
  class AnotherClass
  end
end
  }

INDENT_OK[:require_class_include] = %Q{
require 'time'

class MyClass
  include Stuff
end
}

INDENT_OK[:require_class_include_def] = %Q{
require 'time'

class MyClass
  include Stuff

  def a_method
  end
end
}

INDENT_OK[:require_class_include_def_content] = %Q{
require 'time'

class MyClass
  include Stuff

  def a_method
    puts "hello"
  end
end
}

