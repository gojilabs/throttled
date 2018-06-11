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
    @@_throttled_backoff = nil
    @@_throttled_backoff_started_at = nil
    @@_throttleds = {}

    def throttle_violated?
      self.class.backoff_time > 0 || @@_throttleds.any? { |_, throttle| throttle.in_violation? }
    end

    def add_throttled_bits(bit_count, timestamp = Time.now)
      @@_throttleds.each { |key, throttle| throttle.add(bit_count, timestamp) if key.start_with?(Throttled::BITS_KEY_PREFIX) }
    end

    def add_throttled_request(type, weight = 1, timestamp = Time.now)
      add_throttled_quantity(type, weight, timestamp)
    end

    private

    def add_throttled_quantity(type, count, timestamp = Time.now)
      @@_throttleds[type]&.add(count, timestamp)
    end
  end

  class_methods do
    def bits_key(window)
      "#{Throttled::BITS_KEY_PREFIX}#{window}"
    end

    def set_rate_throttle(bits, window)
      set_request_throttle(bits_key(window), bits, window)
    end

    def remove_rate_throttle(window)
      remove_request_throttle(bits_key(window))
    end

    def set_backoff_time(seconds)
      if seconds <= 0
        @@_throttled_backoff = nil
        @@_throttled_backoff_started_at = nil
      else
        @@_throttled_backoff = seconds
        @@_throttled_backoff_started_at ||= Time.now
      end
    end

    def backoff_time
      (Time.now - @@_throttled_backoff - @@_throttled_backoff_started_at if @@_throttled_backoff).to_i
    end

    def set_throttle(type, count, window)
      @@_throttleds ||= {}
      throttle = @@_throttleds[type]
      current_counts = throttle ? throttle.expiring_counts : []
      @@_throttleds[type] = RollingWindow.new(count, window, current_counts)
    end

    def remove_throttle(type)
      @@_throttleds ||= {}
      @@_throttleds.delete(type)
    end

    alias :remove_request_throttle :remove_throttle
    alias :set_request_throttle :set_throttle
  end
end
