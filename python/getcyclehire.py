import requests
import sys
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

# test
apikey = API_KEY

# make the call
url = "https://api.cyclestreets.net/v2/pois.locations?"

url += "type=bikeshops"
url += "&bbox=%f,%f,%f,%f" % (ll + ur)
url += "&fields=id,latitude,longitude,name,osmTags,website"
url += "&key=%s" % apikey

r = requests.get(url)

# search json for any bike rental tags

j = r.json()
allfeatures = j["features"]

# hack, bike shops with hire
hackedhire = {
"Grizedale Mountain Bike": (True, u"http://www.velobikes.co.uk/" ),
"Ghyllside Cycles": (True, u"http://www.ghyllside.co.uk/cycle-hire.html"),
"Biketreks": (False, u"http://www.bike-treks.co.uk/"),
"Country Lanes": (True, u"http://www.countrylaneslakedistrict.co.uk/"),
"Gill Cycles" :(True, u"http://www.ghyllside.co.uk/cycle-hire.html"),
"DC Cycles": (False, u"http://www.dc-cycles.co.uk/"),
"Wheelbase Lakeland Ltd": (False, u"http://www.wheelbase.co.uk/"),
"Evans Cycles": (False, u"https://www.evanscycles.com/"),
"Brucies Bike Shop": (False, u"https://www.facebook.com/Brucies-Bike-Shop-210863188934295/"),
"Pro Bike Kit": (False, u"http://www.probikekit.co.uk/home.dept"),
"Askew Cycles": (False, u"http://www.askewcycles.co.uk/"),
"Dyno-Start Cycle Centre": (False, u"http://www.dynostart.com/"),
"Kirkby Stephen Cycle Centre": (None, None),
"Bentham Sports": (None, None),
"Grizedale Mountain Bikes": (True, u"http://www.velobikes.co.uk/about-us-grizedale.aspx"),
"Slug and Hare Bicycle Company": (None, None),
"Cycle 100": (None, None)}

# loop over features and hack in websites and cycle hire available
for f in allfeatures:
    nam = f["properties"]["name"]
    if nam in hackedhire:
        hasHire, website = hackedhire[nam]
        if (website != None) and not f["properties"]["website"]: 
            f["properties"]["website"] = website
        if (hasHire != None) and not f["properties"]["osmTags"]: # TODO add support for incomplete osmTags
            f["properties"]["osmTags"] = {u"service:bicycle:rental": hasHire and u"yes" or u"no"}
    else:
        print "to add: ", nam


d = json.dumps(j)
open("../geodata/cyclehireshops.geojson", "w").write(d)

