require 'minitest/autorun'
require 'atdo'

class TestAtDo < Minitest::Test
  def setup
    @s = AtDo.new
  end
  
  def teardown
    @s.stop
  end

  def test_timing
    t0 = Time.now
    a = []
    (0..20).to_a.shuffle.each do |i|
      @s.at t0 + i/100.0 do
        a[i] = Time.now
      end
    end
    sleep 0.21
    assert a.all?
    assert_in_delta t0, a[0], 0.02
    (1..20).each do |i|
      assert_in_delta t0 + i/100.0, a[i], 0.01
    end
  end

  def test_reentrant
    t0 = Time.now
    n = 20
    dt = 0.01
    i = 0
    done = false
    pr = proc do
      i += 1
      if i <= n
        t1 = t0 + i*dt
        assert_operator t1, :>, Time.now
        @s.at t1, &pr
      else
        assert_in_delta n*dt, Time.now - t0, 0.01
        done = true
      end
    end
    pr.call
    sleep 0.1 until done
  end

  def test_wait_indefinitely
    done = false
    @s.at Time.now + 0.1 do
      done = true
    end

    sleep 0.1 until done

    events = @s.instance_variable_get(:@events)
    assert_empty events
    assert_equal "sleep", @s.thread.status

    done = false
    @s.at Time.now + 0.1 do
      done = true
    end

    sleep 0.1 until done

    assert_empty events
    assert_equal "sleep", @s.thread.status
  end

  def test_wait_negative
    done = false
    @s.at Time.now - 1 do
      done = true
    end

    sleep 0.1 until done

    events = @s.instance_variable_get(:@events)
    assert_empty events
    assert_equal "sleep", @s.thread.status
  end
end
