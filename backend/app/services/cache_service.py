try:
    import redis
    REDIS_AVAILABLE = True
except ImportError:
    REDIS_AVAILABLE = False
    redis = None

import json
from typing import Optional, List, Dict
from ..config import settings

# Redis client (optional)
redis_client = None
if REDIS_AVAILABLE:
    try:
        redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)
    except Exception as e:
        print(f"Redis connection failed: {e}. Running without cache.")


class CacheService:
    """Service for caching active bus locations in Redis."""
    
    @staticmethod
    def set_bus_location(bus_number: str, location_data: dict, ttl: int = 60) -> bool:
        """
        Cache bus location in Redis.
        TTL: 60 seconds (auto-expire if driver disconnects)
        """
        if not redis_client:
            return False
        key = f"bus:location:{bus_number}"
        try:
            redis_client.setex(key, ttl, json.dumps(location_data))
            # Add to active buses set
            redis_client.sadd("active_buses", bus_number)
            return True
        except Exception as e:
            print(f"Redis error: {e}")
            return False
    
    @staticmethod
    def get_bus_location(bus_number: str) -> Optional[dict]:
        """Get cached bus location."""
        if not redis_client:
            return None
        key = f"bus:location:{bus_number}"
        try:
            data = redis_client.get(key)
            return json.loads(data) if data else None
        except Exception as e:
            print(f"Redis error: {e}")
            return None
    
    @staticmethod
    def get_all_active_buses() -> List[dict]:
        """Get all active bus locations from cache."""
        if not redis_client:
            return []
        try:
            active_buses = redis_client.smembers("active_buses")
            locations = []
            
            for bus_number in active_buses:
                location = CacheService.get_bus_location(bus_number)
                if location:
                    locations.append(location)
                else:
                    # Remove from active set if no location data
                    redis_client.srem("active_buses", bus_number)
            
            return locations
        except Exception as e:
            print(f"Redis error: {e}")
            return []
    
    @staticmethod
    def remove_bus(bus_number: str) -> bool:
        """Remove bus from active tracking."""
        if not redis_client:
            return False
        try:
            redis_client.delete(f"bus:location:{bus_number}")
            redis_client.srem("active_buses", bus_number)
            return True
        except Exception as e:
            print(f"Redis error: {e}")
            return False
    
    @staticmethod
    def cache_route(route_id: int, route_data: dict, ttl: int = 3600) -> bool:
        """Cache route coordinates (1 hour TTL)."""
        if not redis_client:
            return False
        key = f"route:{route_id}"
        try:
            redis_client.setex(key, ttl, json.dumps(route_data))
            return True
        except Exception as e:
            print(f"Redis error: {e}")
            return False
    
    @staticmethod
    def get_cached_route(route_id: int) -> Optional[dict]:
        """Get cached route."""
        if not redis_client:
            return None
        key = f"route:{route_id}"
        try:
            data = redis_client.get(key)
            return json.loads(data) if data else None
        except Exception as e:
            print(f"Redis error: {e}")
            return None
