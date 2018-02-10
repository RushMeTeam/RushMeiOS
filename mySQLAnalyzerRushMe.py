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

def stringTopItems(d, stringToFormat, numToPrint = numTopItemsToPrint):
    if numToPrint <= 0:
        numToPrint = len(d)
    number = 1
    outString = ""
    for k, v in sorted(d.items(), key = lambda x : x[1], reverse = True)[:numToPrint]:
        #print(k)
        outString += ("\t{0:2}. ".format(number)) + stringToFormat.format(str(k), str(v))
        number += 1
    return outString
connection = mysql.connector.connect(user = 'RushMePublic',
                                     password = 'fras@a&etHaS#7eyudrum+Hak?fresax',
                                     host = 'rushmedbinstance.cko1kwfapaog.us-east-2.rds.amazonaws.com',
                                     database = 'fratinfo')
cursor = connection.cursor()
#query = "SELECT deviceuuid, devicetype, devicesoftware, action FROM sqlrequests"
#cursor.execute(query)
#numberOfRequests = 0
#deviceTypes = dict()
#softwareTypes = dict()
#deviceUUIDs = set()
#actions = dict()
#for deviceuuid, deviceType, deviceSoftware, action in cursor:
    #numberOfRequests += 1
    #if deviceType in deviceTypes:
        #deviceTypes[deviceType] += 1
    #else:
        #deviceTypes[deviceType] = 1
    #if deviceSoftware in softwareTypes:
        #softwareTypes[deviceSoftware] += 1
    #else:
        #softwareTypes[deviceSoftware] = 1
    #if action in actions:
        #actions[action] += 1
    #else:
        #actions[action] = 1
    #deviceUUIDs.add(deviceuuid)
    ##print(deviceuuid)


#print(len(deviceUUIDs), "devices made a total of", numberOfRequests, "requests:")
#print(dictionaryAnalysis(deviceTypes, numberOfRequests, "\t{:.1f}% of requests from {}\n"))
#print(dictionaryAnalysis(actions, numberOfRequests, "\t{:.1f}% of requests of type {}\n"))
#print(dictionaryAnalysis(softwareTypes, numberOfRequests, "\t{:.1f}% of requests from iOS {}\n"))

#query = "SELECT options FROM sqlrequests WHERE action='Fraternity Favorited'"
#cursor.execute(query)
#favorites = countTypes(cursor)
##for fraternity in favorites:
    ##print fraternity, "favorited", favorites[fraternity], "times"
##print ""
#query = "SELECT options FROM sqlrequests WHERE action='Fraternity Unfavorited'"
#cursor.execute(query)
#unfavorites = countTypes(cursor)
#for fraternity in unfavorites:
    #print fraternity, "UNfavorited", unfavorites[fraternity], "times"
#print ""
#volume = dict()
#netFavorites = dict()
#for fraternity in favorites.keys() | unfavorites.keys():
    #totalFavorites = 0
    #netFavorites[fraternity] = 0
    #volume[fraternity] = 0
    #if fraternity in favorites:
        #totalFavorites += favorites[fraternity]
        #volume[fraternity] += favorites[fraternity]
    #if fraternity in unfavorites:
        #volume[fraternity] += unfavorites[fraternity]
        #totalFavorites -= unfavorites[fraternity]
    #netFavorites[fraternity] += abs(totalFavorites)
    ##print("\t", fraternity, "favorited", totalFavorites, "times (total volume", volume[fraternity], ")")
#print("Most Favorited:")
#print(stringTopItems(netFavorites, "{0: <24} : {1}\n"))
#print("Top Volume:")
#print(stringTopItems(volume, "{0: <24} : {1}\n"))


# Gather requests by UUID, count favorites/unfavorites
# Gather UUID's, request Favorites by UUID
query = "SELECT options FROM sqlrequests WHERE action = 'Fraternity Selected' OR action = 'Fraternity Favorited' OR action = 'Fraternity Unfavorited'"
cursor.execute(query)
fraternities = set(cursor)

print(len(fraternities), "fraternities had user interactions.")

query = "SELECT deviceuuid FROM sqlrequests"
cursor.execute(query)
uuids = set()
for uuid in cursor:
    uuids.add(uuid[0])
userInfo = dict()
fratInfo = dict()
for frat in fraternities:
    fratInfo[frat[0]] = set()
for uuid in uuids:
    #print(uuid)
    query = "SELECT deviceuuid, requesttime, action, options FROM sqlrequests WHERE deviceuuid = " + uuid
    cursor.execute(query)
    userActions = sorted(set(cursor), key = lambda x : int(x[1]))
    #print(userActions)
    favorites = set()
    for uuid, requesttime, action, fraternity in userActions:
        print(uuid, requesttime, action, fraternity)
        if "Favorited" in action and "Unfavorited" not in action:
            favorites.add(fraternity)        
        if "Unfavorited" in action and fraternity in favorites:
            favorites.remove(fraternity)        
    for favorite in favorites:
        fratInfo[favorite].add(int(uuid))
    print("User " + uuid + " favorites",favorites)
        
print(fratInfo)
fratConnections = dict.fromkeys(fratInfo.keys(), dict())
for fraternity1 in fratInfo:
    for fraternity2 in fratInfo:
        if fraternity1 != fraternity2:
            fratConnections[fraternity1][fraternity2] = fratInfo[fraternity1] & fratInfo[fraternity2]
            fratConnections[fraternity2][fraternity1] = fratInfo[fraternity2] & fratInfo[fraternity1]
            
            #print(fraternity1, fraternity2, (fratConnections[fraternity1][fraternity2]))
            
for frat in sorted(fratConnections.keys()):
    print(fratConnections[frat])
topFrats = dict()
#for fraternity in fratConnections:
    #for otherFrat in fratConnections[fraternity]:
        #if fraternity != otherFrat:
            #if fraternity < otherFrat:
                #key = "{0:<20} : {1}".format(fraternity, otherFrat)
            #else:
                #key = "{0:<20} : {1}".format(otherFrat, fraternity)
            
            #topFrats[key] = (fratConnections[fraternity][otherFrat])
            #print(len(fratConnections[fraternity][otherFrat]), " === ", len(fratConnections[otherFrat][fraternity]))
            #print(key, len(fratConnections[key[0]][key[1]]))
#print("Top Fraternity Like Overlap:")
#print(stringTopItems(topFrats, "{0:<24} {1} favorites in common\n", 10))
#for frat in topFrats:
    #print(frat, topFrats[frat])
connection.close()