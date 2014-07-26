require 'minitest/autorun'
require 'atdo'

module AtDoTests
  def setup
    @s = make_atdo
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
    (0..20).each do |i|
      assert_in_delta t0 + i/100.0, a[i], 0.02
    end
  end

  def test_reentrant
    t0 = Time.now
    n = 20
    dt = 0.01
    i = 0
    q = Queue.new
    pr = proc do
      i += 1
      if i <= n
        t1 = t0 + i*dt
        @s.at t1, &pr
      else
        assert_in_delta n*dt, Time.now - t0, 0.01
        q << 1
      end
    end
    pr.call
    q.pop
  end

  def test_at_with_no_events
    q = Queue.new
    @s.at Time.now + 0.1 do
      q << true
    end
    q.pop; Thread.pass

    events = @s.instance_variable_get(:@events)
    assert_empty events
    assert_equal "sleep", @s.thread.status

    @s.at Time.now + 0.1 do
      q << true
    end
    q.pop; Thread.pass

    assert_empty events
    assert_equal "sleep", @s.thread.status
  end

  def test_at_negative
    q = Queue.new
    @s.at Time.now - 1 do
      q << true
    end
    q.pop; Thread.pass

    events = @s.instance_variable_get(:@events)
    assert_empty events
    assert_equal "sleep", @s.thread.status
  end

  def test_incomparable
    assert_raises ArgumentError do
      @s.at(1) {}
    end
    assert_raises ArgumentError do
      @s.at("foo") {}
    end
  end
end

class TestAtDo < Minitest::Test
  include AtDoTests

  def make_atdo
    AtDo.new
  end
end

begin
  require 'rbtree'

rescue LoadError => ex
  $stderr.puts "skipping tests for AtDo with RBTree: #{ex}"

else
  class TestAtDoRBTree < Minitest::Test
    include AtDoTests

    def make_atdo
      AtDo.new storage: MultiRBTree
    end
  end
end
