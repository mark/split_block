require_relative 'split_block'

class SimpleCase

  def with_resource
    puts "simple: SETUP RESOURCE"
    yield
    puts "simple: CLEANUP RESOURCE"
  end
  
  split_block :with_resource, :setup_resource, :cleanup_resource

end

class HarderCase

  def with_resource
    puts "harder: SETUP RESOURCE"
    yield
  ensure
    puts "harder: CLEANUP RESOURCE"
  end
  
  split_block :with_resource, :setup_resource, :cleanup_resource

end

class RepeatedCase
    
  def initialize; @resource_count = 1; end
  
  def with_resource
    resource_id = @resource_count
    @resource_count += 1
    puts "repeated: SETUP RESOURCE #{ resource_id }"
    yield
    puts "repeated: CLEANUP RESOURCE #{ resource_id }"
  end
  
  split_block :with_resource, :setup_resource, :cleanup_resource
  
end
 
class MultipleCase
  
  def with_resource_a
    puts "multiple: SETUP RESOURCE A"
    yield
    puts "multiple: CLEANUP RESOURCE A"
  end
  
  def with_resource_b
    puts "multiple: SETUP RESOURCE B"
    yield
    puts "multiple: CLEANUP RESOURCE B"
  end
  
  split_block :with_resource_a, :setup_resource_a, :cleanup_resource_a
  split_block :with_resource_b, :setup_resource_b, :cleanup_resource_b
  
end

def label(n)
  puts "\nCASE #{n}\n\n"
end

label("1 actual")

subject = SimpleCase.new

subject.with_resource { }

label("1 split")

subject = SimpleCase.new

subject.setup_resource
subject.cleanup_resource

label('2 actual')

subject = HarderCase.new

subject.with_resource { }

label('2 split')

subject = HarderCase.new
  
subject.setup_resource
subject.cleanup_resource

label('3 actual')

subject = RepeatedCase.new

subject.with_resource { }
subject.with_resource { }

label('3 split')

subject = RepeatedCase.new
  
subject.setup_resource
subject.cleanup_resource
subject.setup_resource
subject.cleanup_resource

label('4 actual')

subject = RepeatedCase.new

subject.with_resource { subject.with_resource { } }

label('4 split')

subject = RepeatedCase.new

subject.setup_resource
subject.setup_resource
subject.cleanup_resource
subject.cleanup_resource
 
label('5 actual')

subject = MultipleCase.new

subject.with_resource_a { }
subject.with_resource_b { }

label('5 split')

subject = MultipleCase.new

subject.setup_resource_a
subject.cleanup_resource_a
subject.setup_resource_b
subject.cleanup_resource_b

label('6 actual')

subject = MultipleCase.new

subject.with_resource_a { subject.with_resource_b { } }

label('6 split')

subject = MultipleCase.new

subject.setup_resource_a
subject.setup_resource_b
subject.cleanup_resource_b
subject.cleanup_resource_a

label('7 actual')

puts "== NOT POSSIBLE =="

label('7 split')

subject = MultipleCase.new

subject.setup_resource_a
subject.setup_resource_b
subject.cleanup_resource_a
subject.cleanup_resource_b
