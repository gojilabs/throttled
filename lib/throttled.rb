require "throttled/version"
require 'active_support/dependencies/autoload'
require 'active_support/concern'
require 'active_support/core_ext/numeric'
require 'active_support/duration'
require 'throttled/countdown'
require 'throttled/rolling_window'

module Throttled
  extend ActiveSupport::Concern

  BITS_KEY_PREFIX = '__bits_'

  included do
    def throttle_violated?
      self.class.backoff_time > 0 || @@global_throttles.any? { |_, throttle| throttle.in_violation? }
    end

    def add_throttled_bits(bit_count, timestamp = Time.now)
      @@global_throttles.each { |key, throttle| throttle.add(bit_count, timestamp) if key.starts_with?(Throttled::BITS_KEY_PREFIX) }
    end

    def add_throttled_request(type, weight = 1, timestamp = Time.now)
      add_throttled_quantity(type, weight, timestamp)
    end

    private

    def add_throttled_quantity(type, count, timestamp = Time.now)
      @@global_throttles[type]&.add(count, timestamp)
    end
  end

  class_methods do
    def bits_key(window)
      Throttled::BITS_KEY_PREFIX + window
    end

    def set_rate_throttle(bits, window)
      set_request_throttle(bits_key(window), bits, window)
    end

    def remove_rate_throttle(window)
      remove_request_throttle(bits_key(window))
    end

    def set_request_throttle(type, count, window)
      set_throttle(type, count, window)
    end

    def remove_request_throttle(type)
      remove_throttle(type)
    end

    def set_backoff_time(seconds)
      if seconds == 0
        @@global_throttle_backoff = nil
        @@global_throttle_backoff_started_at = nil
      else
        @@global_throttle_backoff = seconds
        @@global_throttle_backoff_started_at ||= Time.now
      end
    end

    def backoff_time
      (Time.now - @@global_throttle_backoff - @@global_throttle_backoff_started_at if @@global_throttle_backoff).to_i
    end

    def set_throttle(type, count, window)
      @@global_throttles ||= {}
      throttle = @@global_throttles[type]
      current_counts = throttle ? throttle.expiring_counts : []
      @@global_throttles[type] = RollingWindow.new(count, window, current_counts)
    end

    def remove_throttle(type)
      @@global_throttles ||= {}
      @@global_throttles.delete(type)
    end
  end
end
