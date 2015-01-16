require 'em-synchrony/connection_pool'

class LazyEvaluatedPool < EventMachine::Synchrony::ConnectionPool
  def initialize(opts, &block)
    @reserved  = {}   # map of in-progress connections
    @available = []   # pool of free connections
    @pending   = []   # pending reservations (FIFO)
    @config = opts
    opts[:size].times do
      @available.push(block) if block_given?
    end
  end

  private
  def acquire(fiber)
    if conn = @available.pop
      conn = self.instance_eval(&conn) if conn.respond_to?(:call)
      @reserved[fiber.object_id] = conn
      conn
    else
      Fiber.yield @pending.push fiber
      acquire(fiber)
    end
  end

  class << self
    def pool_with_config(config, &block)
      config[:size] ||= 10
      LazyEvaluatedPool.new(config, &(block || connection))
    end
    private
    def connection; raise 'Please, override connection method or supply block' end
  end
end

