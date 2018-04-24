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
    # 41.0/255.0, green: 171.0/255.0, blue: 226.0/255.0
    """ render svg on html """
    return """
    <html>
        <body>
            <h1 style="color: rgb(41, 171, 226)">RushMe Data Analytics </h1><h3>Last Updated """ + str(datetime.datetime.now()).split(".")[0] +  """</h3>
            <figure>
            <embed type = "image/svg+xml" src = "/favoritesGraph/"/>
            </figure>
            <figure>
            <embed type="image/svg+xml" src="/popularityGraph/" />
            </figure>
            <figure>
            <embed type="image/svg+xml" src="/grossPopularityGraph/" />
            </figure>
            <figure>
            <embed type="image/svg+xml" src="/deviceGraph/" />
            </figure>
        </body>
    </html>'
    """
@app.route('/deviceGraph/')
def deviceGraph():
    query = """
            SELECT devicetype, deviceSoftware, count(deviceuuid) count 
            FROM devices 
            WHERE devicetype NOT LIKE '%Simulator%' 
            GROUP BY devicetype, devicesoftware ORDER BY count DESC
            """
    cursor.execute(query)
    bar_chart = pygal.Pie(title = "RushMe User Device Characteristics")
    bar_chart.value_formatter = lambda x: "{0} requests".format(x)
    bar_chart.x_labels = ['Device Characteristics']
    for devicetype, devicesoftware, count in cursor:
        bar_chart.add(devicetype + " : " + devicesoftware, int(count))
    
    #print(len(deviceUUIDs), "devices made a total of", numberOfRequests, "requests:")
    #print(dictionaryAnalysis(deviceTypes, numberOfRequests, "\t{:.1f}% of requests from {}\n"))
    #print(dictionaryAnalysis(actions, numberOfRequests, "\t{:.1f}% of requests of type {}\n"))
    #print(dictionaryAnalysis(softwareTypes, numberOfRequests, "\t{:.1f}% of requests from iOS {}\n"))
    return Response(response=bar_chart.render(), content_type='image/svg+xml')   
@app.route('/grossPopularityGraph/')
def grossPopularityGraph():
    fraternities = getFraternities()
    query = "SELECT options, count(*) traffic FROM sqlrequests WHERE options IS NOT NULL AND requesttime <> '0000/00/00 00:00:00' GROUP BY options ORDER BY traffic DESC"
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
    bar_chart = pygal.StackedBar(title = u'RushMe Net Favorites', x_label_rotation = 30)
    bar_chart.style = Style(foreground = '#29abe2', colors = ('green', 'red', "#7CCCEE"))  
    bar_chart.value_formatter = lambda x: "{0:0.1f}%".format(x*100)
    query = "SELECT options, count(*) FROM sqlrequests WHERE action = 'Fraternity Favorited' GROUP BY options, deviceuuid"
    cursor.execute(query)
    favorites = dict(cursor)
    query = "SELECT options, count(*) FROM sqlrequests WHERE action = 'Fraternity Unfavorited' GROUP BY options, deviceuuid"
    cursor.execute(query)
    unfavorites = dict(cursor)  
    grossDict = dict()
    for frat, num in favorites.items():
        #print(frat, num)
        grossDict[frat] = (num, 0)
    for frat, num in unfavorites.items():
        #print(frat, -1*num)
        leftVal = 0
        if frat in grossDict:
            leftVal = grossDict[frat][0]
        grossDict[frat] = (leftVal, num*-1)
            
    fratNames = []
    favs = []
    unfavs = []
    net = []
    maxVol = 0
    for frat, (numFavs, numUnfavs) in sorted(grossDict.items(), key= lambda x : (x[1][0]+x[1][1])/(x[1][0]-x[1][1]), reverse= True)[:15]:
        maxVol = max(maxVol, numFavs-numUnfavs)
    for frat, (numFavs, numUnfavs) in sorted(grossDict.items(), key= lambda x : (x[1][0]+x[1][1])/(x[1][0]-x[1][1]), reverse= True)[:15]:
        fratNames.append(frat)
        favs.append(numFavs/maxVol)
        unfavs.append(numUnfavs/maxVol)
        net.append((numFavs + numUnfavs)/maxVol)
        
    bar_chart.add('Favorites', favs)
    bar_chart.add('Unfavorites', unfavs)
    bar_chart.add('Net', net)
    bar_chart.x_labels = fratNames
    return Response(response=bar_chart.render(), content_type='image/svg+xml') 

@app.route('/favoritesGraph/')
def favoritesGraph():
    fraternities = getFraternities() 
    """ render svg graph """
    bar_chart = pygal.Bar(title = u'RushMe Net Favorites', x_label_rotation = 30)
    
    fratInfo = dict()
    query = """
                SELECT name, count(deviceuuid) FROM favorites WHERE didfavorite = 1 GROUP BY name
            """
    bar_chart.style = Style(foreground = '#29abe2', colors = ("#7CCCEE", "#4FBAE8", "#0472A2", "#29AAE2"))    
    cursor.execute(query)
    fratNames = []
    fratValues = []
    totalLikes = 0
    for fratName, count in cursor:
        fratNames.append(fratName)
        fratValues.append(int(count))
        
    bar_chart.add('Favorites', fratValues)  
    bar_chart.x_labels = fratNames
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

