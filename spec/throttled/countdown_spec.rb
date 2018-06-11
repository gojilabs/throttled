RSpec.describe Throttled::Countdown do
  describe '.initialize' do
    before do
      Timecop.freeze(Time.now)
    end

    after do
      Timecop.return
    end

    context 'when two arguments are passed' do
      let(:countdown) { Throttled::Countdown.new(3, 10.minutes.ago) }

      it 'should return a new countdown' do
        expect { countdown }.to_not raise_error
      end
    end

    context 'when one argument is passed' do
      let(:countdown) { Throttled::Countdown.new(4) }

      it 'should return a new countdown' do
        expect { countdown }.to_not raise_error
      end

      it 'should use Time.now as timestamp when only one argument is passed' do
        expect(countdown.timestamp).to eql(Time.now)
      end
    end
  end

  describe '#timestamp' do
    let(:countdown) { build(:countdown) }

    it 'should return the timestamp' do
      expect(countdown.timestamp).to eql(countdown.instance_variable_get('@timestamp'))
    end
  end

  describe '#count' do
    let(:countdown) { build(:countdown) }

    it 'should return the count' do
      expect(countdown.count).to eql(countdown.instance_variable_get('@count'))
    end
  end

  describe '#discard_after' do
    let(:countdown) { build(:countdown) }
    let(:duration) { 3.hours }

    it 'should return the time at which this countdown can be discarded' do
      expect(countdown.discard_after(duration)).to eql(countdown.timestamp + duration)
    end
  end

  describe '#discard?' do
    let(:countdown) { build(:active_countdown) }

    context 'when the window of time has passed' do
      let(:window) { 1.minute }

      it 'should return true' do
        expect(countdown.discard?(window)).to eql(true)
      end
    end

    context 'when the window of time has not yet passed' do
      let(:window) { 3.hours }

      it 'should return false' do
        expect(countdown.discard?(3.hours)).to eql(false)
      end
    end
  end
end
