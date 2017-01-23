require 'redis/distributed_store'

module RedisDistributedStoreSetexPatch
  def setex(key, expiry, value, options = nil)
    node_for(key).setex(key, expiry, value, options)
  end
end

Redis::DistributedStore.include RedisDistributedStoreSetexPatch
