FactoryBot.define do
  factory :future_countdown, class: Throttled::Countdown do
    sequence(:count, 1000)
    timestamp { 2.hours.from_now }

    initialize_with { new(count, timestamp) }
  end

  factory :countdown, class: Throttled::Countdown do
    sequence(:count, 1000)

    initialize_with { new(count) }
  end

  factory :active_countdown, class: Throttled::Countdown do
    sequence(:count, 1000)
    timestamp { 2.hours.ago }

    initialize_with { new(count, timestamp) }
  end
end
