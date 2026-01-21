try:
    import redis
    REDIS_AVAILABLE = True
except ImportError:
    REDIS_AVAILABLE = False
    redis = None

import json
import logging
from typing import Optional, List, Dict
from datetime import datetime, timedelta
from ..config import settings

# Set up logging
logger = logging.getLogger(__name__)

# Redis client (optional)
redis_client = None
redis_connection_attempted = False

# In-memory fallback cache for development
_memory_cache = {}
_active_buses = set()

def get_redis_client():
    """Get Redis client with lazy initialization and error handling."""
    global redis_client, redis_connection_attempted
    
    if not REDIS_AVAILABLE:
        return None
    
    if redis_client is not None:
        return redis_client
    
    if redis_connection_attempted:
        return None
    
    redis_connection_attempted = True
    
    try:
        # Try to connect to Redis
        client = redis.from_url(
            settings.REDIS_URL, 
            decode_responses=True,
            socket_connect_timeout=2,
            socket_timeout=2,
            retry_on_timeout=False
        )
        # Test connection
        client.ping()
        redis_client = client
        logger.info("✅ Redis connected successfully")
        return redis_client
    except Exception as e:
        logger.warning(f"⚠️  Redis unavailable: {e}. Using in-memory cache for development.")
        return None


class CacheService:
    """Service for caching active bus locations in Redis or memory."""
    
    @staticmethod
    def set_bus_location(bus_number: str, location_data: dict, ttl: int = 60) -> bool:
        """
        Cache bus location in Redis or memory fallback.
        TTL: 60 seconds (auto-expire if driver disconnects)
        """
        client = get_redis_client()
        if client:
            # Use Redis
            key = f"bus:location:{bus_number}"
            try:
                client.setex(key, ttl, json.dumps(location_data))
                client.sadd("active_buses", bus_number)
                return True
            except Exception as e:
                logger.debug(f"Redis error: {e}")
                return False
        else:
            # Use memory fallback
            global _memory_cache, _active_buses
            key = f"bus:location:{bus_number}"
            _memory_cache[key] = {
                "data": location_data,
                "expires": datetime.utcnow() + timedelta(seconds=ttl)
            }
            _active_buses.add(bus_number)
            print(f"📦 Stored in memory cache: {bus_number} -> {location_data}")
            return True
    
    @staticmethod
    def get_bus_location(bus_number: str) -> Optional[dict]:
        """Get cached bus location."""
        client = get_redis_client()
        if client:
            # Use Redis
            key = f"bus:location:{bus_number}"
            try:
                data = client.get(key)
                return json.loads(data) if data else None
            except Exception as e:
                logger.debug(f"Redis error: {e}")
                return None
        else:
            # Use memory fallback
            global _memory_cache
            key = f"bus:location:{bus_number}"
            if key in _memory_cache:
                cache_entry = _memory_cache[key]
                if datetime.utcnow() < cache_entry["expires"]:
                    return cache_entry["data"]
                else:
                    # Expired, remove it
                    del _memory_cache[key]
                    _active_buses.discard(bus_number)
            return None
    
    @staticmethod
    def get_all_active_buses() -> List[dict]:
        """Get all active bus locations from cache."""
        client = get_redis_client()
        if client:
            # Use Redis
            try:
                active_buses = client.smembers("active_buses")
                locations = []
                
                for bus_number in active_buses:
                    location = CacheService.get_bus_location(bus_number)
                    if location:
                        locations.append(location)
                    else:
                        # Remove from active set if no location data
                        client.srem("active_buses", bus_number)
                
                return locations
            except Exception as e:
                logger.debug(f"Redis error: {e}")
                return []
        else:
            # Use memory fallback
            global _memory_cache, _active_buses
            locations = []
            expired_buses = set()
            
            for bus_number in _active_buses.copy():
                location = CacheService.get_bus_location(bus_number)
                if location:
                    locations.append(location)
                else:
                    expired_buses.add(bus_number)
            
            # Clean up expired buses
            _active_buses -= expired_buses
            
            print(f"📦 Retrieved from memory cache: {len(locations)} buses")
            return locations
    
    @staticmethod
    def remove_bus(bus_number: str) -> bool:
        """Remove bus from active tracking."""
        client = get_redis_client()
        if client:
            # Use Redis
            try:
                client.delete(f"bus:location:{bus_number}")
                client.srem("active_buses", bus_number)
                return True
            except Exception as e:
                logger.debug(f"Redis error: {e}")
                return False
        else:
            # Use memory fallback
            global _memory_cache, _active_buses
            key = f"bus:location:{bus_number}"
            if key in _memory_cache:
                del _memory_cache[key]
            _active_buses.discard(bus_number)
            return True
    
    @staticmethod
    def cache_route(route_id: int, route_data: dict, ttl: int = 3600) -> bool:
        """Cache route coordinates (1 hour TTL)."""
        client = get_redis_client()
        if not client:
            return False
        key = f"route:{route_id}"
        try:
            client.setex(key, ttl, json.dumps(route_data))
            return True
        except Exception as e:
            logger.debug(f"Redis error: {e}")
            return False
    
    @staticmethod
    def get_cached_route(route_id: int) -> Optional[dict]:
        """Get cached route."""
        client = get_redis_client()
        if not client:
            return None
        key = f"route:{route_id}"
        try:
            data = client.get(key)
            return json.loads(data) if data else None
        except Exception as e:
            logger.debug(f"Redis error: {e}")
            return None
