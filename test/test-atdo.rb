require 'minitest/autorun'
require 'atdo'

class TestAtDo < Minitest::Test
  def setup
    @s = AtDo.new
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
end
