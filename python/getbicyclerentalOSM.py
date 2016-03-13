#!/usr/bin/env python
import sys
import requests
import json
import overpy
import geojson


def getbbox():
    boxjsonurl = "https://raw.githubusercontent.com/cyclestreets/transporthack/master/geodata/ld-local-authority-bbox.geojson"
    boxjson = requests.get(boxjsonurl).json()
    box = boxjson["features"][0]["geometry"]["coordinates"]
    c0 = box[0][0][0], box[0][0][1]
    c1 = box[0][1][0], box[0][1][1]
    c2 = box[0][2][0], box[0][2][1]
    c3 = box[0][3][0], box[0][3][1]
    ll = min(c0[0], c1[0], c2[0], c3[0]), min(c0[1], c1[1], c2[1], c3[1])
    ur = max(c0[0], c1[0], c2[0], c3[0]), max(c0[1], c1[1], c2[1], c3[1])


    # OSM overpass API wants the bounding box like this:
    bbox = (ll[1], ll[0], ur[1], ur[0])
    return bbox


def queryOSM(qstr):
    api = overpy.Overpass()

    # fetch all ways and nodes
    return api.query(qstr)

def overpass2geojson(r):
    features = []
    for n in r.nodes:
        p = geojson.Point((n.lon, n.lat))
        f = geojson.Feature(geometry=p, properties={'osmTags':n.tags, 'website':"website" in n.tags and n.tags["website"] or None, 'name':n.tags["name"]})
        features.append(f)

    fl = geojson.FeatureCollection(features)
    return fl

bbox = getbbox()
qstr = """
    [out:json][timeout:25];
    (
      node["amenity"="bicycle_rental"](%f,%f,%f,%f);""" % bbox + """
      way["amenity"="bicycle_rental"](%f,%f,%f,%f);""" % bbox + """
      relation["amenity"="bicycle_rental"](%f,%f,%f,%f);""" % bbox + """
    );
    out;
"""

r = queryOSM(qstr)

fl = overpass2geojson(r)

open("../geodata/bicyclehirefromOSM.geojson", "w").write(geojson.dumps(fl))
