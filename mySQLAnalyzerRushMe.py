import mysql.connector
import plotly as py
numTopItemsToPrint = 3
APIKEY = "3rK5IWtkAMtZ2QvpxVE3"
py.tools.set_credentials_file(username = "adamthk", api_key = APIKEY)
def dictionaryAnalysis(d, total, stringToFormat):
    outString = ""
    for item in d:
        outString += stringToFormat.format(float(d[item])*100/(float(total)), item)

    return outString

def countTypes(d):
    result = dict()
    for item in d:
        if item in result:
            result[item] += 1
        else:
            result[item] = 1
    return result

def printTopItems(d, stringToFormat):
    number = 1
    outString = ""
    for k, v in sorted(d.items(), key = lambda x : -x[1])[:numTopItemsToPrint]:
        outString += "\t%s. "% number + stringToFormat.format(k, v)
        number += 1
    return outString
connection = mysql.connector.connect(user = 'RushMePublic',
                                     password = 'fras@a&etHaS#7eyudrum+Hak?fresax',
                                     host = 'rushmedbinstance.cko1kwfapaog.us-east-2.rds.amazonaws.com',
                                     database = 'fratinfo')
cursor = connection.cursor()
query = "SELECT deviceuuid, devicetype, devicesoftware, action FROM sqlrequests"
cursor.execute(query)
numberOfRequests = 0
deviceTypes = dict()
softwareTypes = dict()
deviceUUIDs = set()
actions = dict()
for deviceuuid, deviceType, deviceSoftware, action in cursor:
    numberOfRequests += 1
    if deviceTypes.has_key(deviceType):
        deviceTypes[deviceType] += 1
    else:
        deviceTypes[deviceType] = 1
    if softwareTypes.has_key(deviceSoftware):
        softwareTypes[deviceSoftware] += 1
    else:
        softwareTypes[deviceSoftware] = 1
    if actions.has_key(action):
        actions[action] += 1
    else:
        actions[action] = 1
    deviceUUIDs.add(deviceuuid)
    #print(deviceuuid)


print len(deviceUUIDs), "devices made a total of", numberOfRequests, "requests:"
print(dictionaryAnalysis(deviceTypes, numberOfRequests, "\t{:.1f}% of requests from {}\n"))
print(dictionaryAnalysis(actions, numberOfRequests, "\t{:.1f}% of requests of type {}\n"))
print(dictionaryAnalysis(softwareTypes, numberOfRequests, "\t{:.1f}% of requests from iOS {}\n"))

query = "SELECT options FROM sqlrequests WHERE action='Fraternity Favorited'"
cursor.execute(query)
favorites = countTypes(cursor)
#for fraternity in favorites:
    #print fraternity, "favorited", favorites[fraternity], "times"
#print ""
query = "SELECT options FROM sqlrequests WHERE action='Fraternity Unfavorited'"
cursor.execute(query)
unfavorites = countTypes(cursor)
#for fraternity in unfavorites:
    #print fraternity, "UNfavorited", unfavorites[fraternity], "times"
#print ""
volume = dict()
netFavorites = dict()
for fraternity in favorites.viewkeys() | unfavorites.viewkeys():
    totalFavorites = 0
    netFavorites[fraternity] = 0
    volume[fraternity] = 0
    if fraternity in favorites:
        totalFavorites += favorites[fraternity]
        volume[fraternity] += favorites[fraternity]
    if fraternity in unfavorites:
        volume[fraternity] += unfavorites[fraternity]
        totalFavorites -= unfavorites[fraternity]
    netFavorites[fraternity] += abs(totalFavorites)
    #print "\t", fraternity, "favorited", totalFavorites, "times (total volume", volume[fraternity], ")"
print "Most Favorited:"
print(printTopItems(netFavorites, "{0: <24} : {1}\n"))
print "Top Volume:"
print(printTopItems(volume, "{0: <24} : {1}\n"))

connection.close()