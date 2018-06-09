class Throttled::Countdown
  attr_reader :count, :timestamp

  def initialize(count, timestamp = Time.now)
    @count = count
    @timestamp = timestamp
  end

  def discard_at(window)
    @timestamp + window
  end

  def discard?(window)
   Time.now > discard_at(window)
  end

  def ==(countdown)
    count == countdown.count && timestamp == countdown.timestamp
  end
end
