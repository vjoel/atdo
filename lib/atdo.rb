require 'thread'

class AtDo
  VERSION = 0.2

  def initialize
    @events = [] ## option to use rbtree
    @mutex = Mutex.new
    @cvar = ConditionVariable.new
    @thread = nil
  end
  
  def stop
    @thread.kill if @thread
  end
  
  def at time, &action
    thread
    @mutex.synchronize do
      @events << [time, action]
      t, a = @events.sort_by! {|t, a| t}.first
      @cvar.signal if t == time
    end
  end
  
  def thread
    @thread ||= Thread.new do
      @mutex.synchronize do
        loop do
          t_now = Time.now
          duration =
            loop do
              t, a = @events.first
              break nil if !t
              break t-t_now if t > t_now
              a.call
              @events.shift
            end
          @cvar.wait @mutex, *duration
        end
      end
    end
  end
end
