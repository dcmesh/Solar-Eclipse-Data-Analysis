"""
2020-05-01
Functions for sunrise and sunset computations.

Function midpoint:
Finds the latitude and longitude of the midpoint between
two given points.  All lat/lons are in degrees.
Formulae are from http://www.movable-type.co.uk/scripts/latlong.html among others

Verify that this returns lat and lon in most useful form--
might want to return a numpy array, for example.

"""

from math import radians, degrees, cos, sin, atan2, sqrt
from numpy import array
def midpoint(lat1, lon1, lat2, lon2):
    # First get the measurements into radians.
    # Note lat and lon are defined positive north&east, negative south/west
    phi1 = radians(lat1)
    lam1 = radians(lon1)
    phi2 = radians(lat2)
    lam2 = radians(lon2)
    delta_lam = lam2-lam1
    
    # Define some intermediates
    Bx = cos(phi2)*cos(delta_lam)
    By = cos(phi2)*sin(delta_lam)
    #calculate midpoint lat lon in radians
    phi_m = atan2(sin(phi1)+sin(phi2), sqrt((cos(phi1)+Bx)**2 + By**2))
    lam_m = lam1 + atan2(By, cos(phi1)+Bx)
    # Convert back to degrees
    lat_m = degrees(phi_m)
    lon_m = degrees(lam_m)
    
    # and return those values
    return(lat_m, lon_m)

def horizon_dip(altitude_m):
# find the angle to the horizon given altitude above mean sea level
    from numpy import arccos
    from skyfield.constants import ERAD #earth radius
    return(arccos(ERAD / (ERAD + altitude_m)))
    

if __name__ == '__main__':
    # Test with two geographic points, print the point midway by great circle
    # and the point midway by averaging latitudes and longitudes.
    lat1=41.493906  # Cleveland Heights
    lon1=-81.57777
    lat2=40.679917 # WWV
    lon2=-105.040944

    print('midpoint Cleveland Heights to WWV: ', midpoint(lat1,lon1, lat2,lon2))

    # find the horizon dip at a given altitude
    altitude_m = 300e3
    horizonDip = round(degrees(horizon_dip(altitude_m)),2)
    print('horizon dip for height above msl ', altitude_m, 'm is ',
          horizonDip, ' degrees')
# lat1=-33  # Valparaiso, Chile (example given on web site for this computation)
# lon1=-71.6
# lat2=31.4 # Shanghai
# lon2=121.8
# 
# 
# 
# print('midpoint Valparaiso-Shanghai: ', midpoint(lat1,lon1, lat2,lon2))
# print('average lat/lon Valparaiso-Shanghai: ', (lat1+lat2)/2, (lon1+lon2)/2-180)
