import mysql.connector
import plotly
import plotly.plotly as py
from plotly.graph_objs import *
import random
import networkx as nx
numTopItemsToPrint = 3
APIKEY = "3rK5IWtkAMtZ2QvpxVE3"
plotly.tools.set_credentials_file(username = "adamthk", api_key = APIKEY)
plotly.tools.set_config_file(world_readable=True, sharing='public')

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
query = "SELECT deviceuuid, devicetype, devicesoftware, action FROM sqlrequests"
cursor.execute(query)
numberOfRequests = 0
deviceTypes = dict()
softwareTypes = dict()
deviceUUIDs = set()
actions = dict()
for deviceuuid, deviceType, deviceSoftware, action in cursor:
    numberOfRequests += 1
    if deviceType in deviceTypes:
        deviceTypes[deviceType] += 1
    else:
        deviceTypes[deviceType] = 1
    if deviceSoftware in softwareTypes:
        softwareTypes[deviceSoftware] += 1
    else:
        softwareTypes[deviceSoftware] = 1
    if action in actions:
        actions[action] += 1
    else:
        actions[action] = 1
    deviceUUIDs.add(deviceuuid)
    #print(deviceuuid)


print(len(deviceUUIDs), "devices made a total of", numberOfRequests, "requests:")
print(dictionaryAnalysis(deviceTypes, numberOfRequests, "\t{:.1f}% of requests from {}\n"))
print(dictionaryAnalysis(actions, numberOfRequests, "\t{:.1f}% of requests of type {}\n"))
print(dictionaryAnalysis(softwareTypes, numberOfRequests, "\t{:.1f}% of requests from iOS {}\n"))

query = "SELECT options FROM sqlrequests WHERE action='Fraternity Favorited'"
cursor.execute(query)
favorites = countTypes(cursor)
##for fraternity in favorites:
    ##print fraternity, "favorited", favorites[fraternity], "times"
##print ""
query = "SELECT options FROM sqlrequests WHERE action='Fraternity Unfavorited'"
cursor.execute(query)
unfavorites = countTypes(cursor)
#for fraternity in unfavorites:
    #print fraternity, "UNfavorited", unfavorites[fraternity], "times"
#print ""
volume = dict()
netFavorites = dict()
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
    ###print("\t", fraternity, "favorited", totalFavorites, "times (total volume", volume[fraternity], ")")

#print("Top Volume:")
#print(stringTopItems(volume, "{0: <24} : {1}\n"))


# Gather requests by UUID, count favorites/unfavorites
# Gather UUID's, request Favorites by UUID
query = "SELECT options FROM sqlrequests WHERE action = 'Fraternity Selected' OR action = 'Fraternity Favorited' OR action = 'Fraternity Unfavorited'"
cursor.execute(query)
fraternities = set(cursor)

print(len(fraternities), "fraternities had user interactions.")

query = "SELECT deviceuuid FROM sqlrequests WHERE (action = 'Fraternity Selected' OR action = 'Fraternity Favorited' OR action = 'Fraternity Unfavorited' OR action = 'Fraternity Favorited by Swipe' OR action = 'Fraternity Unfavorited by Swipe')"
cursor.execute(query)
uuids = set()
for uuid in cursor:
    uuids.add(int(uuid[0]))
uuids = sorted(uuids)
userInfo = dict()
fratInfo = dict()
for frat in fraternities:
    fratInfo[frat[0]] = set()
for uuid in uuids:
    #print(uuid)
    query = "SELECT deviceuuid, requesttime, action, options FROM sqlrequests WHERE ((action = 'Fraternity Favorited' OR action = 'Fraternity Unfavorited' OR action = 'Fraternity Favorited by Swipe' OR action = 'Fraternity Unfavorited by Swipe') AND deviceuuid = " + str(uuid) + ") ORDER BY deviceuuid, requesttime"
    cursor.execute(query)
    favorites = set()
    for uuid, requesttime, action, fraternity in cursor:
        #print(uuid, requesttime, action, fraternity)
        if "Favorited" in action and "Unfavorited" not in action:
            favorites.add(fraternity)
        if "Unfavorited" in action and fraternity in favorites:
            favorites.remove(fraternity)
    for favorite in favorites:
        fratInfo[favorite].add(int(uuid))
    #print("User " + str(uuid) + " favorites",favorites)



fratConnections = dict.fromkeys(fratInfo.keys(), dict())
for frat in sorted(fratInfo):
    for anotherFrat in sorted(fratInfo):
        if frat != anotherFrat and len(fratInfo[frat]) > 0 and len(fratInfo[frat]) > 0:
            #print(frat, anotherFrat, fratInfo[frat] & fratInfo[anotherFrat])
            fratConnections[frat][anotherFrat] = fratInfo[frat] & fratInfo[anotherFrat]
topFrats = dict()
for fraternity in sorted(fratConnections):
    for otherFrat in sorted(fratConnections[fraternity]):
        if len(fratConnections[fraternity][otherFrat]) > 0 and fraternity != otherFrat:
            if fraternity < otherFrat:
                key = (fraternity, otherFrat)
            else:
                key = (otherFrat, fraternity)

            topFrats[key] = len(fratConnections[fraternity][otherFrat])
            #print((fratConnections[fraternity][otherFrat]), " === ", (fratConnections[otherFrat][fraternity]))
            #print(key, len(fratConnections[key[0]][key[1]]))
print("Top Fraternity Like Overlap:")
print(stringTopItems(topFrats, "{0:<24} {1} favoriters in common\n", 10))
#for frat in topFrats:
    #print(frat, topFrats[frat])
print("Most Favorited:")
x = []
y = []
for fratLikes in sorted(fratInfo.items()):
    #print(fratLikes)
    x.append(fratLikes[0])
    y.append(len(fratLikes[1]))
data = [Bar(x=x, y=y, text=y, textposition = 'auto')]
#py.plot(data, filename="coolio")


height = 10
width = 20
G = nx.Graph()#nx.random_geometric_graph(len(fratInfo.keys()), 0.125)
for frat in fratConnections:
    G.add_node(frat)
    G.node[frat]['pos'] = hash(frat[:-1:])/width, hash(frat)/height
    G.node[frat]['identity'] = frat
#p=nx.single_source_shortest_path_length(G,ncenter)

edge_trace = Scatter(x = [], y = [], line = Line(width = 0.5, color = '#29abe2'), hoverinfo='text', mode = 'lines+text')

for fraternity, otherFrat in topFrats:
    weight = topFrats[fraternity, otherFrat]
    if weight > 1:
        #print(fraternity, otherFrat, topFrats[fraternity, otherFrat])
        G.add_edge(fraternity, otherFrat)
        G[fraternity][otherFrat]['text'] = str(topFrats[fraternity, otherFrat])

print(G.number_of_edges())
pos = nx.get_node_attributes(G, 'pos')

dmin=1
ncenter=0
for n in pos:
    x,y=pos[n]
    d=(x-0.5)**2+(y-0.5)**2
    if d<dmin:
        ncenter=n
        dmin=d
for edge in G.edges():
    x0, y0 = G.node[edge[0]]['pos']
    x1, y1 = G.node[edge[1]]['pos']
    edge_trace['x'] += [x0, x1, None]
    edge_trace['y'] += [y0, y1, None]

node_trace = Scatter(x = [], y = [], text = [], mode = 'markers', hoverinfo='text')

for node in G.nodes():
    x, y = G.node[node]['pos']
    node_trace['x'].append(x)
    node_trace['y'].append(y)
for node, adjacencies in G.adjacency():
    node_info = node + ': '+str(len(adjacencies)) + " mutual rushees"
    node_trace['text'].append(node_info)



fig = Figure(data=Data([edge_trace, node_trace]),
             layout=Layout(
                title='<br>RushMe Favorites Network',
                titlefont=dict(size=16),
                showlegend=False,
                hovermode='closest',
                margin=dict(b=20,l=5,r=5,t=40),
                annotations=[ dict(
                    text="Python code: <a href='https://plot.ly/ipython-notebooks/network-graphs/'> https://plot.ly/ipython-notebooks/network-graphs/</a>",
                    showarrow=False,
                    xref="paper", yref="paper",
                    x=0.005, y=-0.002 ) ],
                xaxis=XAxis(showgrid=False, zeroline=False, showticklabels=False),
                yaxis=YAxis(showgrid=False, zeroline=False, showticklabels=False)))
py.plot(fig, "NetworkPlot")

connection.close()