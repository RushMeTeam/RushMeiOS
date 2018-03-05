import mysql.connector
import plotly
import plotly.plotly as py
from plotly.graph_objs import *
import random
import math
#import networkx as nx
import jenkspy
import datetime
import pygal
from pygal import Config
from pygal.style import Style
from flask import Flask, Response, render_template
app = Flask(__name__)

IGNORE_SIMULATOR = True
connection = mysql.connector.connect(user = 'RushMePublic',
                                     password = 'fras@a&etHaS#7eyudrum+Hak?fresax',
                                     host = 'rushmedbinstance.cko1kwfapaog.us-east-2.rds.amazonaws.com',
                                     database = 'fratinfo')
cursor = connection.cursor()

def getFraternities():
    query = "SELECT options FROM sqlrequests WHERE action = 'Fraternity Selected' OR action = 'Fraternity Favorited' OR action = 'Fraternity Unfavorited'"
    cursor.execute(query)
    fratNames = set()
    for fratName in set(cursor):
        fratNames.add(fratName[0])
    return fratNames       


@app.route('/')
def createPage():
    #query = "SELECT options FROM sqlrequests WHERE action='Fraternity Favorited'"
    #cursor.execute(query)
    #favorites = countTypes(cursor)
    ###for fraternity in favorites:
        ###print fraternity, "favorited", favorites[fraternity], "times"
    ###print ""
    #query = "SELECT options FROM sqlrequests WHERE action='Fraternity Unfavorited'"
    #cursor.execute(query)
    #unfavorites = countTypes(cursor)
    ##for fraternity in unfavorites:
        ##print fraternity, "UNfavorited", unfavorites[fraternity], "times"
    ##print ""
    #volume = dict()
    #netFavorites = dict()
    ##for fraternity in favorites.keys() | unfavorites.keys():
        ##totalFavorites = 0
        ##netFavorites[fraternity] = 0
        ##volume[fraternity] = 0
        ##if fraternity in favorites:
            ##totalFavorites += favorites[fraternity]
            ##volume[fraternity] += favorites[fraternity]
        ##if fraternity in unfavorites:
            ##volume[fraternity] += unfavorites[fraternity]
            ##totalFavorites -= unfavorites[fraternity]
        ##netFavorites[fraternity] += abs(totalFavorites)
        ####print("\t", fraternity, "favorited", totalFavorites, "times (total volume", volume[fraternity], ")")
    
    ##print("Top Volume:")
    ##print(stringTopItems(volume, "{0: <24} : {1}\n"))
    
    
    ## Gather requests by UUID, count favorites/unfavorites
    ## Gather UUID's, request Favorites by UUID
   
    ##print("Most Favorited:")
    #x = []
    #y = []
    #totalFavorites = 0
    #for fratLikes in sorted(fratInfo.items(), key= lambda x : len(x[1]), reverse= True):
        ##print("\t{0:<24} {1}".format(fratLikes[0], len(fratLikes[1])))
        #numberFavorites = len(fratLikes[1])
        #x.append(fratLikes[0])
        #y.append(len(fratLikes[1]))
        #totalFavorites += numberFavorites
    #for i in range(len(y)):
        #y[i] = float(y[i])*100/float(totalFavorites)
    
    
    
    #fig1 = Figure(data=[Bar(x=x,
                            #y=y,
                            #text=y,
                            #textposition = 'auto',
                            #marker = dict(color = 'rgb(41, 171, 226)'))],
                  #layout=Layout(
                      #title='<br>RushMe Net Favorites by Fraternity',
                     #titlefont=dict(size=16),
                    #showlegend=False,
                    #hovermode='closest',
                    #annotations=[ dict(
                        #text="by Adam Kuniholm (for RPI IFC E-Board only)",
                        #showarrow=False,
                        #xref="paper", yref="paper",
                        #x=0.005, y=-0.002 ) ],
                    #xaxis=XAxis(showgrid=False, zeroline=True, showticklabels=True),
                    #yaxis=YAxis(showgrid=True, zeroline=False, showticklabels=False)))
    
    ## ############################################################################################## #
    ## ############################################################################################## #
    #height = 10
    #width = 20
    #colors = ["7CCCEE", "4FBAE8", "0472A2", "29AAE2"]
    #squareLength = min(height, width)
    #numFrats = len(fratInfo)
    ## ############################################################################################## #
    #totalSharedUsers = 0
    #sharedUserArray = []
    #for _, _, sharedUsers in fratConnections:
        #totalSharedUsers += len(sharedUsers)
        #sharedUserArray.append(len(sharedUsers))
    #averageSharedUsers = totalSharedUsers/len(fratConnections)
    #breaks = sorted(set(jenkspy.jenks_breaks(sharedUserArray, nb_class = 6)))
    ## ############################################################################################## #
    ## Create graph
    #G = nx.Graph()
    #fratNum = 0
    ## Add all nodes (fraternities) to model graph
    #for frat in sorted(fratInfo):
        #G.add_node(frat)
        #fratTime = (fratNum/numFrats)*2*math.pi
        #G.node[frat]['pos'] = squareLength*math.cos(fratTime)/2, squareLength*math.sin(fratTime)/2
        #fratNum += 1
    ## Add all edges (shared rushees) to model graph
    #for fraternity, otherFrat, sharedUsers in fratConnections:
        #connectionWeight = len(sharedUsers)
        #if connectionWeight > averageSharedUsers or len(breaks) < 10:
            #G.add_edge(fraternity, otherFrat, weight = connectionWeight)
    ## ############################################################################################## #
    ## Define edge traces
    ##        (to add visual differences between ranges of values)
    #edge_traces = dict()
    #for lowerBound in breaks:
        #edge_traces[lowerBound] = Scatter(x = [],
                                          #y = [],
                                          #text = [],
                                          #line = Line(width = breaks.index(lowerBound),
                                                      #color = colors[breaks.index(lowerBound)%len(colors)]),
                                          #hoverinfo='text',
                                          #mode = 'lines')
    ## ############################################################################################## #
    ## Define all edges visually
    #pos = nx.get_node_attributes(G, 'pos')
    #for edge in G.edges():
        #x0, y0 = G.node[edge[0]]['pos']
        #x1, y1 = G.node[edge[1]]['pos']
        #for lowerBound in sorted(edge_traces):
            #if lowerBound > G.edges[edge]['weight'] or lowerBound == breaks[-1]:
                #edge_traces[lowerBound]['x'] += [x0, x1, None]
                #edge_traces[lowerBound]['y'] += [y0, y1, None]
                #break
    #node_trace = Scatter(x = [], y = [], text = [], mode = 'markers+text', hoverinfo='none', textposition = 'top')
    ## ############################################################################################## #
    ## Define all nodes visually
    #for node in G.nodes():
        #x, y = G.node[node]['pos']
        #node_trace['x'].append(x)
        #node_trace['y'].append(y)
        #node_trace['text'].append(node)
    #for node, adjacencies in G.adjacency():
        #node_info = node + ': '+str(len(adjacencies)) + " mutual rushees"
    ## ############################################################################################## #
    ## Compile all visual node/edge traces
    #allTraces = list(edge_traces.values())
    #allTraces.append(node_trace)
    ##fig2 = Figure(data=Data(allTraces),
                  ##layout=Layout(
                     ##title='<br>RushMe Favorites Network',
                    ##titlefont=dict(size=16),
                    ##showlegend=False,
                    ##hovermode='closest',
                    ##margin=dict(b=20,l=5,r=5,t=40),
                    ##annotations=[ dict(
                        ##text="by Adam Kuniholm (for RPI IFC E-Board only)",
                        ##showarrow=False,
                        ##xref="paper", yref="paper",
                        ##x=0.005, y=-0.002 ) ],
                    ##xaxis=XAxis(showgrid=False, zeroline=False, showticklabels=False),
                    ##yaxis=YAxis(showgrid=False, zeroline=False, showticklabels=False)))
    ## ############################################################################################## #
    ## Finally, plot the node/edge traces
    ##if G.number_of_edges() > 0 and plotEnabled:
        ##py.plot(fig1, filename="netLikeBarChart", auto_open = False)
        ##if len(selectedFraternities) > 0:
            ##filename = ""
            ##newTitle = ""
            ##for frat in selectedFraternities:
                ##filename += frat.replace(" ", "")
                ##newTitle += frat + "-"
            ##filename += "NetworkPlot"
            ##title = "Favorites Network"
            ##fig2.update(dict(layout = dict(title = "Selected Fraternities Favorites Network")))
            ##py.plot(fig2, filename = filename, auto_open = True)
        ##else:
            ##py.plot(fig2, filename = "NetworkPlot", auto_open = False)
    
    ##else:
        ##print("Plots not plotted")   
    ##connection.close()
    # 41.0/255.0, green: 171.0/255.0, blue: 226.0/255.0
    """ render svg on html """
    return """
    <html>
        <body>
            <h1 style="color: rgb(41, 171, 226)">RushMe Data Analytics </h1><h3>Last Updated """ + str(datetime.datetime.now()).split(".")[0] +  """</h3>
            <figure>
            <embed type="image/svg+xml" src="/deviceGraph/" />
            </figure>
            <figure>
            <embed type="image/svg+xml" src="/favoritesGraph/" />
            </figure>
            <figure>
            <embed type="image/svg+xml" src="/grossPopularityGraph/" />
            </figure>
            <figure>
            <embed type="image/svg+xml" src="/overlapGraph/" />
            </figure>
        </body>
    </html>'
    """
@app.route('/deviceGraph/')
def deviceGraph():
    query = "SELECT DISTINCT CONCAT(CONCAT(devicetype, ' | '), deviceSoftware) device, count(devicetype) count FROM sqlrequests WHERE devicetype NOT LIKE '%Simulator%' GROUP BY device ORDER BY count DESC"
    cursor.execute(query)
    numberOfRequests = 0
    deviceTypes = dict()
    softwareTypes = dict()
    deviceUUIDs = set()
    actions = dict()
    connectedDeviceSoftwareTypes = dict()
    bar_chart = pygal.Pie(title = "RushMe User Device Characteristics")
        #print(deviceuuid)
    bar_chart.x_labels = ['Device Characteristics']
    for deviceKey, number in dict(cursor).items():
        bar_chart.add(deviceKey, number)
    
    #print(len(deviceUUIDs), "devices made a total of", numberOfRequests, "requests:")
    #print(dictionaryAnalysis(deviceTypes, numberOfRequests, "\t{:.1f}% of requests from {}\n"))
    #print(dictionaryAnalysis(actions, numberOfRequests, "\t{:.1f}% of requests of type {}\n"))
    #print(dictionaryAnalysis(softwareTypes, numberOfRequests, "\t{:.1f}% of requests from iOS {}\n"))
    return Response(response=bar_chart.render(), content_type='image/svg+xml')   
@app.route('/grossPopularityGraph/')
def grossPopularityGraph():
    fraternities = getFraternities()
    query = "SELECT options, count(*) FROM sqlrequests WHERE options IS NOT NULL GROUP BY options"
    cursor.execute(query)
    
    requests = dict(cursor)
    bar_chart = pygal.Pie(title = "RushMe Gross Traffic Graph")
    bar_chart.x_labels = ['Number of Requests']
    for options in requests:
        if options in fraternities:
            bar_chart.add(options, requests[options])
    return Response(response=bar_chart.render(), content_type='image/svg+xml') 
    
@app.route('/popularityGraph/')
def popularityGraph():
    query = "SELECT options FROM sqlrequests WHERE action = 'Fraternity Selected' OR action = 'Fraternity Favorited' OR action = 'Fraternity Unfavorited'"
    cursor.execute(query)
    fraternities = set(cursor)       
    return "not yet implemented"

@app.route('/favoritesGraph/')
def favoritesGraph():
    fraternities = getFraternities() 
    """ render svg graph """
    bar_chart = pygal.StackedBar(title = u'RushMe Net Favorites', x_label_rotation = 30)
    #bar_chart.value_formatter = lambda x: "{0:0.1f}%".format(x)
    #bar_chart.style = Style(foreground = '#29abe2', colors = ("#7CCCEE", "#4FBAE8", "#0472A2", "#29AAE2"))
    #query = "SELECT deviceuuid FROM sqlrequests WHERE (action = 'Fraternity Selected' OR action = 'Fraternity Favorited' OR action = 'Fraternity Unfavorited' OR action = 'Fraternity Favorited by Swipe' OR action = 'Fraternity Unfavorited by Swipe')"
    #cursor.execute(query)
    #uuids = set()
    #for uuid in cursor:
        #uuids.add(int(uuid[0]))
    #uuids = sorted(uuids)
    #userInfo = dict()
    #fratInfo = dict()
    ##fratUnfavorites = dict()
    #for frat in fraternities:
        #fratInfo[frat] = set()
        ##fratUnfavorites[frat] = set()
        
    query = "SELECT deviceuuid, options FROM sqlrequests WHERE action = 'Fraternity Favorited' OR action = 'Fraternity Unfavorited' GROUP BY deviceuuid"
    cursor.execute(query)
    for deviceuuid, options in cursor:
        print(deviceuuid, options)
    return "Not yet"    
    #for uuid in uuids:
        #print(uuid)
        #query = "SELECT deviceuuid, requesttime, action, options FROM sqlrequests WHERE ((action = 'Fraternity Favorited' OR action = 'Fraternity Unfavorited' OR action = 'Fraternity Favorited by Swipe' OR action = 'Fraternity Unfavorited by Swipe') AND deviceuuid = " + str(uuid) + ") ORDER BY requesttime ASC"
        #cursor.execute(query)
        #favorites = set()
        ##unfavorites = set()
        #for uuid, requesttime, action, fraternity in cursor:
            ##print(uuid, requesttime, action, fraternity)
            #if "Favorited" in action and "Unfavorited" not in action:
                #favorites.add(fraternity)
                ##if fraternity in unfavorites:
                    ##unfavorites.remove(fraternity)
            #if "Unfavorited" in action:
                #if fraternity in favorites:
                    #favorites.remove(fraternity)
                ##unfavorites.add(fraternity)
        #for favorite in favorites:
            #fratInfo[favorite].add(int(uuid))
        ##for unfavorite in unfavorites:
            ##fratUnfavorites[unfavorite].add(int(uuid))
    #fratConnections = []
    ##for frat in fratInfo:
        ##for anotherFrat in sorted(fratInfo):
            ##if frat != anotherFrat:
                ##fratConnections.append((frat, anotherFrat, (fratInfo[frat] & fratInfo[anotherFrat])))
    ##print("Most Favorited:")
    #x = []
    #x_ = []
    #y = []
    #y_ = []
    #totalFavorites = 0
    #totalUnfavorites = 0
    #for fratLikes in sorted(fratInfo.items(), key= lambda x : len(x[1]), reverse= True)[:15]:
        ##print("\t{0:<24} {1}".format(fratLikes[0], len(fratLikes[1])))
        #numFavorites = len(fratLikes[1])
        #x.append(fratLikes[0])
        #y.append(numFavorites)
        #totalFavorites += numFavorites
    ##for fratUnfavorites in sorted(fratInfo.items(), key= lambda x : len(x[1]), reverse= True)[:15]:
        ##numUnfavorites = len(fratInfo[fratLikes[0]])
        ##x_.append(fratLikes[0])
        ##y_.append(-1*numUnfavorites)
        ##totalUnfavorites += numUnfavorites
    #for i in range(len(y)):
        #y[i] = float(y[i])*100/float(totalFavorites)
        ##y_[i] = float(y[i])*100/float(totalUnfavorites)
    #bar_chart.add('Favorites',y)
    ##bar_chart.add('Unfavorites', y_)
    #bar_chart.x_labels = x
    #xLabels = []
    #for frat, anotherFrat, sharedUsers in fratConnections:
        #xLabels += frat
    #bar_chart.x_labels = xLabels
    #for frat, anotherFrat, sharedUsers in fratConnections:
        #if len(sharedUsers) > 0:
            #bar_chart.add(frat, len(sharedUsers))
    return Response(response=bar_chart.render(), content_type='image/svg+xml')    

@app.route('/overlapGraph/')
def overlapGraph():
    return "OverlapGraph not yet implemented"



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
numTopItemsToPrint = 3
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

if __name__ == "__main__" :
    app.run(host='0.0.0.0')


#import plotly.tools as tls
#print(tls.get_embed('https://plot.ly/~chris/1638'))

