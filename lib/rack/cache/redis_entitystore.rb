require 'rack/cache/entity_store'
require 'redis-rack-cache/constants'
require 'redis-rack-cache/resolver'

module Rack
  module Cache
    class EntityStore
      class RedisBase < self
        # The underlying ::Redis instance used to communicate with the Redis daemon.
        attr_reader :cache

        extend Rack::Utils

        def open(key)
          data = read(key)
          data && [data]
        end

        def self.resolve(uri)
          redis = ::Redis::Rack::Cache::Resolver.new(uri).resolve
          new(*redis)
        end
      end

      class Redis < RedisBase
        def initialize(server, options = {})
          @cache = ::Redis::Store::Factory.create(server, options)
        end

        def exist?(key)
          cache.exists key
        end

        def read(key)
          cache.get key
        end

        def write(body, ttl=0)
          buf = StringIO.new
          key, size = slurp(body){|part| buf.write(part) }

          ttl = ::Redis::Rack::Cache::DEFAULT_TTL if ttl.zero?
          [key, size] if cache.setex(key, ttl, buf.string)
        end

        def purge(key)
          cache.del key
          nil
        end
      end

      REDIS = Redis
    end
  end
end
