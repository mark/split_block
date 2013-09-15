=== Splitting Blocks

In the olden days, when a programmer wanted to allow access to a resource, they defined two methods: one to access the resource, and one to release access to it.  Ruby developers frequently combine both of those methods into a single method that takes a block:

```ruby
def with_resource
  resource = setup_resource
  yield(resource)
  cleanup_resource(resource)
end
```

Now, if the #setup_resource and #cleanup_resource methods are defined, then writing the block version is easy.  However, if only the block version is defined, then splitting that method into separate setup and cleanup methods is harder.

Enter `split_block`.  `Class::split_block` takes three arguments: the method whose block you want to split, and the names you want for the new setup and cleanup methods.

