INDENT_OK = {}

INDENT_OK[:class] = %Q{
class MyClass
end
}

INDENT_OK[:one_line_class] = %Q{
class MyClass; end
}

INDENT_OK[:class_empty] = %Q{
class MyClass

end
}

INDENT_OK[:class_singlestatement] = %Q{
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

INDENT_OK[:require_class_singlestatement] = %Q{
require 'time'

class MyClass
  include Stuff
end
}

INDENT_OK[:require_class_singelstatement_def] = %Q{
require 'time'

class MyClass
  include Stuff

  def a_method
  end
end
}

INDENT_OK[:require_class_singelstatement_def_content] = %Q{
require 'time'

class MyClass
  include Stuff

  def a_method
    puts "hello"
  end
end
}

#-------------------------------------------------------------------------------
# INDENT_1
#-------------------------------------------------------------------------------
INDENT_1 = {}

INDENT_1[:class_indented_end] = %Q{
class MyClass
 end
}

INDENT_1[:class_indented_singlestatement] = %Q{
class MyClass
   include Something
end
}

INDENT_1[:class_outdented_singlestatement] = %Q{
class MyClass
 include Something
end
}

INDENT_1[:def_indented_end] = %Q{
def a
 end
}

INDENT_1[:def_content_indented_end] = %Q{
def a
  puts "stuff"
 end
}

INDENT_1[:class_def_content_outdented_end] = %Q{
class A
  def a
    puts "stuff"
 end
end
}

INDENT_1[:class_def_outdented_content] = %Q{
class A
  def a
   puts "stuff"
  end
end
}

