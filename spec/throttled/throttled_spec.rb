RSpec.describe Throttled do
  before do
    @throttled = build(:throttled)
    @window = 4.minutes
  end

  describe '.bits_key' do
    # expect(@throttled.bits_key(@window)).to eql(Throttled::BITS_KEY_PREFIX + @window)
    puts 'yes'
    puts @throttled.class.name
  end
end
