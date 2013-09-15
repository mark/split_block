require 'spec_helper'
 
Minitest::Test.i_suck_and_my_tests_are_order_dependent!

describe "the simplest case" do
  
  class SimpleCase
  
    def with_resource
      print "SETUP RESOURCE"
      yield
      print "CLEANUP RESOURCE"
    end
    
    split_block :with_resource, :setup_resource, :cleanup_resource
 
  end
 
  subject { SimpleCase.new }
  
  it "should split the method" do
    lambda { subject.setup_resource   }.must_output "SETUP RESOURCE"
    lambda { subject.cleanup_resource }.must_output "CLEANUP RESOURCE"
  end
  
end
 
describe "with errors" do

  class BadCase

    def with_resource
      # SETUP RESOURCE
      yield
      # CLEANUP RESOURCE
    end
    
    split_block :with_resource, :setup_resource, :cleanup_resource

  end

  subject { BadCase.new }
  
  it "should complain if cleaned up twice" do
    subject.setup_resource
    subject.cleanup_resource
    lambda { subject.cleanup_resource }.must_raise SplitBlock::TooManyCleanups
  end

end

describe "with returning a resource" do

  class ReturningCase

    def with_resource
      # SETUP :resource
      yield :resource
      # CLEANUP :resource
      :cleaned_resource
    end

    split_block :with_resource, :setup_resource, :cleanup_resource

  end

  subject { ReturningCase.new }

  it "should return the resource" do
    subject.setup_resource.must_equal :resource
    subject.cleanup_resource(:resource).must_equal :cleaned_resource
  end

end

describe "with explicit resources" do

  class ExplicitCase

    Resource = Struct.new(:id, :clean)

    def with_resource(id)
      resource = Resource.new(id, false)
      yield resource
      resource.clean = true
    end

    split_block :with_resource, :setup_resource, :cleanup_resource

  end

  subject { ExplicitCase.new }

  it "should allow you to clean up a resource" do
    resource = subject.setup_resource(:foo)
    resource.clean.must_equal false

    subject.cleanup_resource(resource)
    resource.clean.must_equal true
  end

  it "should allow you to clean up multiple resources" do
    resource_1 = subject.setup_resource(:foo)
    resource_2 = subject.setup_resource(:bar)

    resource_1.clean.must_equal false
    resource_2.clean.must_equal false

    subject.cleanup_resource(resource_1)

    resource_1.clean.must_equal true
    resource_2.clean.must_equal false

    subject.cleanup_resource(resource_2)

    resource_1.clean.must_equal true
    resource_2.clean.must_equal true
  end

  it "should allow you to clean up multiple resources in any order" do
    resource_1 = subject.setup_resource(:foo)
    resource_2 = subject.setup_resource(:bar)

    resource_1.clean.must_equal false
    resource_2.clean.must_equal false

    subject.cleanup_resource(resource_1)

    resource_1.clean.must_equal false
    resource_2.clean.must_equal true

    subject.cleanup_resource(resource_2)

    resource_1.clean.must_equal true
    resource_2.clean.must_equal true
  end

end

describe "a harder case" do
  
  class HarderCase
  
    def with_resource
      print "SETUP RESOURCE"
      yield
    ensure
      print "CLEANUP RESOURCE"
    end
    
    split_block :with_resource, :setup_resource, :cleanup_resource
 
  end
 
  subject { HarderCase.new }
  
  it "should split the method" do
    lambda { subject.setup_resource   }.must_output "SETUP RESOURCE"
    lambda { subject.cleanup_resource }.must_output "CLEANUP RESOURCE"
  end
  
end
 
describe "calling it repeatedly" do
 
  class RepeatedCase
    
    def initialize; @resource_count = 1; end
    
    def with_resource
      resource_id = @resource_count
      @resource_count += 1
      print "SETUP RESOURCE #{ resource_id }"
      yield
      print "CLEANUP RESOURCE #{ resource_id }"
    end
    
    split_block :with_resource, :setup_resource, :cleanup_resource
    
  end
  
  subject { RepeatedCase.new }
  
  it "should be able to be called one after another" do
    lambda { subject.setup_resource   }.must_output "SETUP RESOURCE 1"
    lambda { subject.cleanup_resource }.must_output "CLEANUP RESOURCE 1"
    lambda { subject.setup_resource   }.must_output "SETUP RESOURCE 2"
    lambda { subject.cleanup_resource }.must_output "CLEANUP RESOURCE 2"
  end
  
  it "should be able to be called nested" do
    lambda { subject.setup_resource   }.must_output "SETUP RESOURCE 1"
    lambda { subject.setup_resource   }.must_output "SETUP RESOURCE 2"
    lambda { subject.cleanup_resource }.must_output "CLEANUP RESOURCE 2"
    lambda { subject.cleanup_resource }.must_output "CLEANUP RESOURCE 1"
  end
  
end
 
describe "splitting multiple methods" do
  
  class MultipleCase
    
    def with_resource_a
      print "SETUP RESOURCE A"
      yield
      print "CLEANUP RESOURCE A"
    end
    
    def with_resource_b
      print "SETUP RESOURCE B"
      yield
      print "CLEANUP RESOURCE B"
    end
    
    split_block :with_resource_a, :setup_resource_a, :cleanup_resource_a
    split_block :with_resource_b, :setup_resource_b, :cleanup_resource_b
    
  end
  
  subject { MultipleCase.new }
  
  it "should be able to be called one after another" do
    lambda { subject.setup_resource_a   }.must_output "SETUP RESOURCE A"
    lambda { subject.cleanup_resource_a }.must_output "CLEANUP RESOURCE A"
    lambda { subject.setup_resource_b   }.must_output "SETUP RESOURCE B"
    lambda { subject.cleanup_resource_b }.must_output "CLEANUP RESOURCE B"
  end
  
  it "should be able to be called nested" do
    lambda { subject.setup_resource_a   }.must_output "SETUP RESOURCE A"
    lambda { subject.setup_resource_b   }.must_output "SETUP RESOURCE B"
    lambda { subject.cleanup_resource_b }.must_output "CLEANUP RESOURCE B"
    lambda { subject.cleanup_resource_a }.must_output "CLEANUP RESOURCE A"
  end
  
  it "should be able to be called staggered" do
    lambda { subject.setup_resource_a   }.must_output "SETUP RESOURCE A"
    lambda { subject.setup_resource_b   }.must_output "SETUP RESOURCE B"
    lambda { subject.cleanup_resource_a }.must_output "CLEANUP RESOURCE A"
    lambda { subject.cleanup_resource_b }.must_output "CLEANUP RESOURCE B"
  end
  
end
