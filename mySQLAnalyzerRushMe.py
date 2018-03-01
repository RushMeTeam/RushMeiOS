import mysql.connector
import plotly
import plotly.plotly as py
from plotly.graph_objs import *
import random
import math
import networkx as nx
import jenkspy
numTopItemsToPrint = 3
APIKEY = "3rK5IWtkAMtZ2QvpxVE3"
plotly.tools.set_credentials_file(username = "adamthk", api_key = APIKEY)
plotly.tools.set_config_file(world_readable=True, sharing='public')

plotEnabled = True
selectedFraternities = {}#{"Rensselaer Society of Engineers", "Alpha Chi Rho", "Delta Phi"}

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

print(len(fraternities), "fraternities had user interactions.\n")

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
    query = "SELECT deviceuuid, requesttime, action, options FROM sqlrequests WHERE ((action = 'Fraternity Favorited' OR action = 'Fraternity Unfavorited' OR action = 'Fraternity Favorited by Swipe' OR action = 'Fraternity Unfavorited by Swipe') AND deviceuuid = " + str(uuid) + ") ORDER BY requesttime ASC"
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
fratConnections = []
for frat in fratInfo:
    for anotherFrat in sorted(fratInfo):
        if frat != anotherFrat and (len(selectedFraternities) == 0 or (frat in selectedFraternities) or (anotherFrat in selectedFraternities)):
            fratConnections.append((frat, anotherFrat, (fratInfo[frat] & fratInfo[anotherFrat])))
print("Most Favorited:")
x = []
y = []
totalFavorites = 0
for fratLikes in sorted(fratInfo.items(), key= lambda x : len(x[1]), reverse= True)[:10]:
    print("\t{0:<24} {1}".format(fratLikes[0], len(fratLikes[1])))
    numberFavorites = len(fratLikes[1])
    x.append(fratLikes[0])
    y.append(len(fratLikes[1]))
    totalFavorites += numberFavorites
for i in range(len(y)):
    y[i] = str(float(y[i])*100/float(totalFavorites)) + "%"


fig1 = Figure(data=[Bar(x=x,
                        y=y,
                        text=y,
                        textposition = 'auto',
                        marker = dict(color = 'rgb(41, 171, 226)'))],
              layout=Layout(
                 title='<br>RushMe Net Favorites by Fraternity',
                titlefont=dict(size=16),
                showlegend=False,
                hovermode='closest',
                annotations=[ dict(
                    text="by Adam Kuniholm (for RPI IFC E-Board only)",
                    showarrow=False,
                    xref="paper", yref="paper",
                    x=0.005, y=-0.002 ) ],
                xaxis=XAxis(showgrid=False, zeroline=True, showticklabels=True),
                yaxis=YAxis(showgrid=True, zeroline=False, showticklabels=False)))

# ############################################################################################## #
# ############################################################################################## #
height = 10
width = 20
colors = ["7CCCEE", "4FBAE8", "0472A2", "29AAE2"]
squareLength = min(height, width)
numFrats = len(fratInfo)
# ############################################################################################## #
totalSharedUsers = 0
sharedUserArray = []
for _, _, sharedUsers in fratConnections:
    totalSharedUsers += len(sharedUsers)
    sharedUserArray.append(len(sharedUsers))
averageSharedUsers = totalSharedUsers/len(fratConnections)
breaks = sorted(set(jenkspy.jenks_breaks(sharedUserArray, nb_class = 6)))
# ############################################################################################## #
# Create graph
G = nx.Graph()
fratNum = 0
# Add all nodes (fraternities) to model graph
for frat in sorted(fratInfo):
    G.add_node(frat)
    fratTime = (fratNum/numFrats)*2*math.pi
    G.node[frat]['pos'] = squareLength*math.cos(fratTime)/2, squareLength*math.sin(fratTime)/2
    fratNum += 1
# Add all edges (shared rushees) to model graph
for fraternity, otherFrat, sharedUsers in fratConnections:
    connectionWeight = len(sharedUsers)
    if connectionWeight > averageSharedUsers or len(breaks) < 10:
        G.add_edge(fraternity, otherFrat, weight = connectionWeight)
# ############################################################################################## #
# Define edge traces
#        (to add visual differences between ranges of values)
edge_traces = dict()
for lowerBound in breaks:
    edge_traces[lowerBound] = Scatter(x = [],
                                      y = [],
                                      text = [],
                                      line = Line(width = breaks.index(lowerBound),
                                                  color = colors[breaks.index(lowerBound)%len(colors)]),
                                      hoverinfo='text',
                                      mode = 'lines')
# ############################################################################################## #
# Define all edges visually
pos = nx.get_node_attributes(G, 'pos')
for edge in G.edges():
    x0, y0 = G.node[edge[0]]['pos']
    x1, y1 = G.node[edge[1]]['pos']
    for lowerBound in sorted(edge_traces):
        if lowerBound > G.edges[edge]['weight'] or lowerBound == breaks[-1]:
            edge_traces[lowerBound]['x'] += [x0, x1, None]
            edge_traces[lowerBound]['y'] += [y0, y1, None]
            break
node_trace = Scatter(x = [], y = [], text = [], mode = 'markers+text', hoverinfo='none', textposition = 'top')
# ############################################################################################## #
# Define all nodes visually
for node in G.nodes():
    x, y = G.node[node]['pos']
    node_trace['x'].append(x)
    node_trace['y'].append(y)
    node_trace['text'].append(node)
for node, adjacencies in G.adjacency():
    node_info = node + ': '+str(len(adjacencies)) + " mutual rushees"
# ############################################################################################## #
# Compile all visual node/edge traces
allTraces = list(edge_traces.values())
allTraces.append(node_trace)
fig2 = Figure(data=Data(allTraces),
             layout=Layout(
                title='<br>RushMe Favorites Network',
                titlefont=dict(size=16),
                showlegend=False,
                hovermode='closest',
                margin=dict(b=20,l=5,r=5,t=40),
                annotations=[ dict(
                    text="by Adam Kuniholm (for RPI IFC E-Board only)",
                    showarrow=False,
                    xref="paper", yref="paper",
                    x=0.005, y=-0.002 ) ],
                xaxis=XAxis(showgrid=False, zeroline=False, showticklabels=False),
                yaxis=YAxis(showgrid=False, zeroline=False, showticklabels=False)))
# ############################################################################################## #
# Finally, plot the node/edge traces
if G.number_of_edges() > 0 and plotEnabled:
    py.plot(fig1, filename="netLikeBarChart", auto_open = False)
    if len(selectedFraternities) > 0:
        filename = ""
        newTitle = ""
        for frat in selectedFraternities:
            filename += frat.replace(" ", "")
            newTitle += frat + "-"
        filename += "NetworkPlot"
        title = "Favorites Network"
        fig2.update(dict(layout = dict(title = "Selected Fraternities Favorites Network")))
        py.plot(fig2, filename = filename, auto_open = True)
    else:
        py.plot(fig2, filename = "NetworkPlot", auto_open = False)

else:
    print("Plots not plotted")

#import plotly.tools as tls
#print(tls.get_embed('https://plot.ly/~chris/1638'))

connection.close()