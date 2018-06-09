FactoryBot.define do
  factory :rolling_window do
    maximum { (5..20).to_a.sample }
    window 5.seconds
    expiring_counts []
  end
end
