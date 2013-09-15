module SplitBlock

  class NeverSetUp      < StandardError; end
  class TooManyCleanups < StandardError; end

  module ModuleMethod

    def split_block(block_method, setup_method, cleanup_method)
      split_blocks = Hash.new { |h, k| h[k] = [] }

      define_method(setup_method) do |*args|
        fiber = Fiber.new do
          send(block_method, *args) do |*resources|
            Fiber.yield(*resources)
          end
        end

        fiber.resume.tap do |resource|
          split_blocks[resource] << fiber
        end
      end

      define_method(cleanup_method) do |*resources|
        resource = resources.first
        msg      = "Error with cleanup for #{ resource.inspect }"

        raise NeverSetUp, msg      unless split_blocks.has_key?(resource)
        raise TooManyCleanups, msg unless split_blocks[resource].any?

        split_blocks[resource].pop.resume
      end

    end

  end

end

class Module
  include SplitBlock::ModuleMethod
end
