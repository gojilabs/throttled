RSpec.describe Throttled::Countdown do
  describe '.initialize' do
    before do
      Timecop.freeze(Time.now)
    end

    after do
      Timecop.return
    end

    it 'should accept two arguments' do
      expect { Throttled::Countdown.new(3, 10.minutes.ago) }.to_not raise_error
    end

    it 'should accept one argument' do
      expect { Throttled::Countdown.new(2) }.to_not raise_error
    end

    it 'should use Time.now as timestamp when only one argument is passed' do
      expect(Throttled::Countdown.new(5).timestamp).to eql(Time.now)
    end
  end

  describe '#timestamp' do
    before do
      @countdown = build(:countdown)
    end

    it 'should return the timestamp' do
      expect(@countdown.timestamp).to eql(@countdown.instance_variable_get('@timestamp'))
    end
  end

  describe '#count' do
    before do
      @countdown = build(:countdown)
    end

    it 'should return the count' do
      expect(@countdown.count).to eql(@countdown.instance_variable_get('@count'))
    end
  end

  describe '#discard_after' do
    before do
      @countdown = build(:countdown)
    end

    it 'should return the time at which this countdown can be discarded' do
      duration = 3.hours
      expect(@countdown.discard_after(duration)).to eql(@countdown.timestamp + duration)
    end
  end

  describe '#discard?' do
    it 'should return true when the window of time has passed' do
      expect(build(:active_countdown).discard?(1.minute)).to eql(true)
    end

    it 'should return false when the window of time has not yet passed' do
      expect(build(:active_countdown).discard?(3.hours)).to eql(false)
    end
  end
end
