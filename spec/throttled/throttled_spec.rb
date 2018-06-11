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
      expect(throttled_class).to receive(:set_request_throttle).with(throttled_class.bits_key(window), bits, window)
      throttled_class.set_rate_throttle(bits, window)
    end
  end

  describe '.remove_rate_throttle' do
    it 'should call .remove_request_throttle' do
      expect(throttled_class).to receive(:remove_request_throttle).with(throttled_class.bits_key(window))
      throttled_class.remove_rate_throttle(window)
    end
  end

  describe '.set_backoff_time' do
    context 'when seconds is less than 0' do
      before do
        throttled_class.set_backoff_time(-3)
      end

      it 'sets __throttled_backoff to nil' do
        expect(throttled_class.class_variable_get('@@__throttled_backoff')).to eql(nil)
      end

      it 'sets __throttled_backoff_started_at to nil' do
        expect(throttled_class.class_variable_get('@@__throttled_backoff_started_at')).to eql(nil)
      end
    end

    context 'when seconds is 0' do
      before do
        throttled_class.set_backoff_time(0)
      end

      it 'sets __throttled_backoff to nil' do
        expect(throttled_class.class_variable_get('@@__throttled_backoff')).to eql(nil)
      end

      it 'sets __throttled_backoff_started_at to nil' do
        expect(throttled_class.class_variable_get('@@__throttled_backoff_started_at')).to eql(nil)
      end
    end

    context 'when seconds is greater than 0' do
      let(:backoff_time) { (2..100).to_a.sample }

      context 'and we don\'t want the let statement here hold onto values for the next context' do
        it 'sets __throttled_backoff to seconds' do
          throttled_class.set_backoff_time(backoff_time)
          expect(throttled_class.class_variable_get('@@__throttled_backoff')).to eql(backoff_time)
        end
      end

      # context 'and when __throttled_backoff_started_at is not yet set' do
      #   before do
      #     @now = Date.today.to_time
      #     Timecop.freeze(@now)
      #     throttled_class.set_backoff_time(backoff_time)
      #   end

      #   after do
      #     Timecop.return
      #   end

      #   it 'sets __throttled_backoff_started_at to Time.now' do
      #     expect(throttled_class.class_variable_get('@@__throttled_backoff_started_at')).to eql(@now)
      #   end
      # end

      # context 'and when __throttled_backoff_started_at has already been set' do
      #   let(:just_now) { Date.today.to_time }

      #   before do
      #     Timecop.freeze(just_now)
      #     throttled_class.set_backoff_time(backoff_time)
      #     Timecop.return
      #   end

      #   it 'does not change __throttled_backoff_started_at' do
      #     expect(throttled_class.class_variable_get('@@__throttled_backoff_started_at')).to eql(just_now)
      #   end
      # end
    end
  end

  describe '.backoff_time' do
    context 'when __throttled_backoff is nil' do
      let(:throttled_for_backoff_time) { throttled_class.set_backoff_time(0) }

      it 'should return 0' do
        expect(throttled_class.backoff_time).to eq(0)
      end
    end
  end
end
