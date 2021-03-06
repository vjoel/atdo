require 'thread'

class AtDo
  VERSION = "0.6"

  # Storage classes known to work: Array (default), MultiRBTree.
  def initialize storage: Array
    @storage_class = storage
    @events = storage.new
    @sorted = !defined?(@events.reverse)
    @mon = Monitor.new
    @cvar = @mon.new_cond
    @thread = nil
  end

  def inspect
    "#<#{self.class}:0x#{self.object_id.to_s(16)} #{@events}>"
  end

  def stop
    @mon.synchronize do
      @thread.kill if @thread
    end
  end

  def stop!
    @thread.kill if @thread
  end

  def wait
    @thread.join
  end

  def at time, &action
    thread
    raise ArgumentError unless time.kind_of? Time

    @mon.synchronize do
      if @sorted
        @events[time] = action
        first_event_time, _ = @events.first
      else
        @events << [time, action]
        first_event_time, _ = @events.sort_by! {|t, a| t}.first
      end
      @cvar.signal if first_event_time == time
    end
    self
  end

  def thread
    @thread ||= Thread.new do
      Thread.current.abort_on_exception = true
      @mon.synchronize do
        loop do
          duration =
            loop do
              t, a = @events.first
              break nil if !t
              t_now = Time.now
              break t-t_now if t > t_now
              begin
                a.call
              rescue
                # exception handling is left to client code
              end
              @events.shift
            end
          @cvar.wait(*duration)
        end
      end
    end
  end
end
