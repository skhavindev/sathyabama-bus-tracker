try:
    import redis
    REDIS_AVAILABLE = True
except ImportError:
    REDIS_AVAILABLE = False
    redis = None

import json
import logging
from typing import Optional, List, Dict
from ..config import settings

# Set up logging
logger = logging.getLogger(__name__)

# Redis client (optional)
redis_client = None
redis_connection_attempted = False

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
        logger.warning(f"⚠️  Redis unavailable: {e}. Running without cache (this is OK for development).")
        return None


class CacheService:
    """Service for caching active bus locations in Redis."""
    
    @staticmethod
    def set_bus_location(bus_number: str, location_data: dict, ttl: int = 60) -> bool:
        """
        Cache bus location in Redis.
        TTL: 60 seconds (auto-expire if driver disconnects)
        """
        client = get_redis_client()
        if not client:
            return False
        key = f"bus:location:{bus_number}"
        try:
            client.setex(key, ttl, json.dumps(location_data))
            # Add to active buses set
            client.sadd("active_buses", bus_number)
            return True
        except Exception as e:
            logger.debug(f"Redis error: {e}")
            return False
    
    @staticmethod
    def get_bus_location(bus_number: str) -> Optional[dict]:
        """Get cached bus location."""
        client = get_redis_client()
        if not client:
            return None
        key = f"bus:location:{bus_number}"
        try:
            data = client.get(key)
            return json.loads(data) if data else None
        except Exception as e:
            logger.debug(f"Redis error: {e}")
            return None
    
    @staticmethod
    def get_all_active_buses() -> List[dict]:
        """Get all active bus locations from cache."""
        client = get_redis_client()
        if not client:
            return []
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
    
    @staticmethod
    def remove_bus(bus_number: str) -> bool:
        """Remove bus from active tracking."""
        client = get_redis_client()
        if not client:
            return False
        try:
            client.delete(f"bus:location:{bus_number}")
            client.srem("active_buses", bus_number)
            return True
        except Exception as e:
            logger.debug(f"Redis error: {e}")
            return False
    
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
