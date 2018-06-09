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

    it 'should set count' do
      expect(Throttled::Countdown.new(4, 3.minutes.ago).count).to eql(4)
    end

    it 'should set timestamp' do
      expect(Throttled::Countdown.new(1, 2.minutes.ago).timestamp).to eql(2.minutes.ago)
    end

    it 'should use Time.now as timestamp when only one argument is passed' do
      expect(Throttled::Countdown.new(5).timestamp).to eql(Time.now)
    end
  end

  describe '#discard_at' do
    before do
      @now = Time.now
      @countdown = Throttled::Countdown.new(4, @now)
    end

    it 'should return the time at which this countdown can be discarded' do
      expect(@countdown.discard_at(30.minutes)).to eql(@now + 30.minutes)
    end
  end

  describe '#discard?' do
    before do
      @countdown = Throttled::Countdown.new(4, 5.minutes.ago)
    end

    it 'should return false when the window of time has not yet passed' do
      expect(@countdown.discard?(10.minutes)).to eql(false)
    end

    it 'should return true when the window of time has passed' do
      expect(@countdown.discard?(2.minutes)).to eql(true)
    end
  end
end
