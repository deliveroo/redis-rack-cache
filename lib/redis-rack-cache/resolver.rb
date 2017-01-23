require 'uri'
require 'rack/utils'

class Redis
  module Rack
    module Cache
      class Resolver
        SHARDED = "sharded".freeze

        def initialize(uri)
          @uri = URI(uri) # parse String or noop if already URI
        end

        def resolve
          if sharded?
            uris = get_shard_uris
            [uris, get_options(uris)]
          else
            @uri.to_s
          end
        end

        private

        def sharded?
          @uri.host == SHARDED
        end

        def get_shard_uris
          params = ::Rack::Utils.parse_nested_query(@uri.query)
          params.fetch("shards").map { |s| File.join(s.to_s, @uri.path) }
        end

        def get_options(uris)
          base = ::Redis::Store::Factory.resolve(uris.first)
          base[:namespace] ? { namespace: base[:namespace] } : {}
        end
      end
    end
  end
end
