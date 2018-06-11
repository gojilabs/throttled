RSpec.describe Throttled do

  let(:throttled_class) { Struct.new(nil) { include Throttled } }
  let(:throttled) { throttled_class.new }
  let(:window) { 4.minutes }

  describe '.bits_key' do
    it 'should concatenate Throttled::BITS_KEY_INDEX and the given window' do
      expect(throttled.class.bits_key(window)).to eql("#{Throttled::BITS_KEY_PREFIX}#{window}")
    end
  end

  describe '.set_rate_throttle' do
    it 'should call .set_request_throttle' do
      bits = (0..1000).to_a.sample
      expect(throttled.class).to receive(:set_request_throttle).with(throttled.class.bits_key(window), bits, window)
      throttled.class.set_rate_throttle(bits, window)
    end
  end

  describe '.remove_rate_throttle' do
    it 'should call .remove_request_throttle' do
      expect(throttled.class).to receive(:remove_request_throttle).with(throttled.class.bits_key(window))
      throttled.class.remove_rate_throttle(window)
    end
  end
end
