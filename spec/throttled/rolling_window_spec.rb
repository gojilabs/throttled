RSpec.describe 'Throttled::RollingWindow' do
  describe '.initialize' do
    it 'should accept two parameters' do
      expect { Throttled::RollingWindow.new(10, 2.hours) }.to_not raise_exception
    end

    it 'should assign an empty array to expiring_counts when two parameters are used' do
      expect(Throttled::RollingWindow.new(30, 1.hour).expiring_counts).to eql([])
    end

    it 'should accept three parameters' do
      expect { Throttled::RollingWindow.new(10, 2.hours, [Throttled::Countdown.new(10, 10.minutes.ago)]) }.to_not raise_exception
    end
  end

  describe '#maximum' do
    it 'should return the value of @maximum' do
      my_maximum = 200
      expect(Throttled::RollingWindow.new(my_maximum, 1.hour).maximum).to eql(my_maximum)
    end
  end

  describe '#window' do
    it 'should return the value of @window' do
      my_window = 7.minutes
      expect(Throttled::RollingWindow.new(20, my_window).window).to eql(my_window)
    end
  end

  describe '#expiring_counts' do
    it 'should return the value of @expiring_counts' do
      my_expiring_counts = [Throttled::Countdown.new(10, 10.minutes.ago)]
      expect(Throttled::RollingWindow.new(30, 1.hour, my_expiring_counts).expiring_counts).to eql(my_expiring_counts)
    end
  end

  describe '#add' do
    before do
      @rw = Throttled::RollingWindow.new(17, 40.minutes)
    end

    it 'should enqueue the new countdown' do
      maximum = 14
      timestamp = 1.minute.ago
      @rw.add(maximum, timestamp)
      @rw.add(maximum - 3, timestamp + 5.minutes)
      expect(@rw.expiring_counts.first).to eq(Throttled::Countdown.new(maximum, timestamp))
    end

    it 'should use Time.now when only one argument is provided' do
      maximum = 14
      now = Time.now
      Timecop.freeze(now)
      @rw.add(maximum)
      expect(@rw.expiring_counts.first).to eq(Throttled::Countdown.new(maximum, now))
      Timecop.return
    end
  end

  describe '#since' do
    before do
      @rw = Throttled::RollingWindow.new(12, 3.minutes)
    end

    it 'should return the timestamp of the first expiring count' do
      maximum = 14
      timestamp = 1.minute.ago
      @rw.add(maximum, timestamp)
      @rw.add(maximum - 3, timestamp + 2.minutes)
      expect(@rw.since).to eq(timestamp)
    end

    it 'should return nil when there are no expiring counts' do
      expect(@rw.since).to eq(nil)
    end
  end

  describe '#counts' do
    before do
      @rw = Throttled::RollingWindow.new(14, 6.minutes)
    end

    it 'should return the sum of all countdown counts' do
      count1 = 17
      count2 = 12
      count3 = 1
      @rw.add(count1)
      @rw.add(count2)
      @rw.add(count3)
      expect(@rw.send(:counts)).to eql(count1 + count2 + count3)
    end

    it 'should return 0 when there are no expiring counts' do
      expect(@rw.send(:counts)).to eql(0)
    end
  end
end
