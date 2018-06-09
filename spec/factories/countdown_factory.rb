FactoryBot.define do
  factory 'Throttled::Countdown' do
    count 0
    timestamp Time.now

    initialize_with { new(count, timestamp) }
  end
end
