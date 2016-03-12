#!/usr/bin/env python
import sys
import requests
import json

boxjsonurl = "https://raw.githubusercontent.com/cyclestreets/transporthack/master/geodata/ld-local-authority-bbox.geojson"
boxjson = requests.get(boxjsonurl).json()
box = boxjson["features"][0]["geometry"]["coordinates"]
c0 = box[0][0][0], box[0][0][1]
c1 = box[0][1][0], box[0][1][1]
c2 = box[0][2][0], box[0][2][1]
c3 = box[0][3][0], box[0][3][1]
ll = min(c0[0], c1[0], c2[0], c3[0]), min(c0[1], c1[1], c2[1], c3[1])
ur = max(c0[0], c1[0], c2[0], c3[0]), max(c0[1], c1[1], c2[1], c3[1])


bbox = (ll[1], ll[0], ur[1], ur[0])
print bbox

import overpy

api = overpy.Overpass()

# fetch all ways and nodes
result = api.query("""
[out:json][timeout:25];
(
  node["amenity"="bicycle_rental"](%f,%f,%f,%f);""" % bbox + """
  way["amenity"="bicycle_rental"](%f,%f,%f,%f);""" % bbox + """
  relation["amenity"="bicycle_rental"](%f,%f,%f,%f);""" % bbox + """
);
out body;
>;
out skel qt;
    """)

print result, result.__dict__
