"""
Utilities for Order Routing System
"""

import math
from typing import Tuple, List, Dict, Optional
import frappe
import requests


def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calculate distance between two GPS points using Haversine formula.
    
    Args:
        lat1: Latitude of first point
        lon1: Longitude of first point
        lat2: Latitude of second point
        lon2: Longitude of second point
    
    Returns:
        Distance in meters
    """
    # Radius of earth in meters
    R = 6371000
    
    # Convert to radians
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)
    
    # Haversine formula
    a = (math.sin(delta_phi / 2) ** 2 +
         math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2) ** 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    
    distance = R * c
    
    return distance


def find_nearest_shops(
    customer_lat: float,
    customer_lon: float,
    shops: List[Dict],
    tier_distances: List[int] = [50, 100, 500, 1000, 5000]
) -> Dict[int, List[Dict]]:
    """
    Find shops within distance tiers.
    
    Args:
        customer_lat: Customer latitude
        customer_lon: Customer longitude
        shops: List of shop dicts with 'latitude', 'longitude', and other fields
        tier_distances: Distance tiers in meters
    
    Returns:
        Dictionary with tier distance as key and list of shops in that tier
    """
    shops_by_tier = {tier: [] for tier in tier_distances}
    
    for shop in shops:
        distance = calculate_distance(
            customer_lat,
            customer_lon,
            shop.get('latitude'),
            shop.get('longitude')
        )
        
        # Assign to appropriate tier
        for tier in sorted(tier_distances):
            if distance <= tier:
                shops_by_tier[tier].append({
                    **shop,
                    'distance': distance
                })
                break
    
    return shops_by_tier


def format_distance(meters: float) -> str:
    """
    Format distance in a human-readable format.
    
    Args:
        meters: Distance in meters
    
    Returns:
        Formatted string (e.g., "50 m", "1.5 km")
    """
    if meters < 1000:
        return f"{int(meters)} m"
    else:
        km = meters / 1000
        return f"{km:.1f} km"


@frappe.whitelist()
def geocode_address(address: str):
    """
    Convert address string to GPS coordinates using OpenStreetMap Nominatim API
    
    Args:
        address: Address string (e.g., "123 Main St, Nairobi, Kenya")
    
    Returns:
        Dict with 'latitude' and 'longitude' keys, or None if geocoding fails
    """
    try:
        # Use OpenStreetMap Nominatim (free, no API key required)
        url = "https://nominatim.openstreetmap.org/search"
        params = {
            'q': address,
            'format': 'json',
            'limit': 1
        }
        
        # Add user agent as required by Nominatim
        headers = {
            'User-Agent': 'WhatsApp-Order-System/1.0'
        }
        
        response = requests.get(url, params=params, headers=headers, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            if data and len(data) > 0:
                result = data[0]
                return {
                    'latitude': float(result['lat']),
                    'longitude': float(result['lon'])
                }
        
        frappe.log_error(f"Geocoding failed for address: {address}", "Geocoding Error")
        return None
    
    except Exception as e:
        frappe.log_error(f"Error geocoding address '{address}': {str(e)}", "Geocoding Error")
        return None
