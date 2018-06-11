class Throttled::RollingWindow
  attr_accessor :maximum, :window
  attr_reader :expiring_counts

  def initialize(maximum, window, expiring_counts = [])
    @maximum = maximum #integer
    @window = window #ActiveSupport::Duration (e.g. 1.week)
    @expiring_counts = expiring_counts #[]Throttled::Countdown
  end

  def add(count, timestamp = Time.now)
    @expiring_counts.push(Throttled::Countdown.new(count, timestamp))
    self
  end

  def in_violation?
    prune
    counts > maximum
  end

  def since
    @expiring_counts.first&.timestamp
  end

  private

  def counts
    @expiring_counts.inject(0) { |sum, countdown| sum + countdown.count }
  end

  def prune
    @expiring_counts.shift while @expiring_counts.first&.discard?(window)
    self
  end
end
