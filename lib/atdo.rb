require 'thread'

class AtDo
  VERSION = "0.3"

  def initialize
    @events = [] ## option to use rbtree
    @mon = Monitor.new
    @cvar = @mon.new_cond
    @thread = nil
  end
  
  def stop
    @mon.synchronize do
      @thread.kill if @thread
    end
  end

  def stop!
    @thread.kill if @thread
  end
  
  def at time, &action
    thread
    @mon.synchronize do
      @events << [time, action]
      t, a = @events.sort_by! {|t, a| t}.first
      @cvar.signal if t == time
    end
  end
  
  def thread
    @thread ||= Thread.new do
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
              rescue => ex
                ## ?
              end
              @events.shift
            end
          @cvar.wait *duration
        end
      end
    end
  end
end
