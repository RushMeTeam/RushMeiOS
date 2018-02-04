import mysql.connector

def dictionaryAnalysis(d):

    print(d)


connection = mysql.connector.connect(user = 'RushMePublic',
                                     password = 'fras@a&etHaS#7eyudrum+Hak?fresax',
                                     host = 'rushmedbinstance.cko1kwfapaog.us-east-2.rds.amazonaws.com',
                                     database = 'fratinfo')
cursor = connection.cursor()
query = "SELECT deviceuuid, devicetype, devicesoftware FROM sqlrequests"
cursor.execute(query)
numberOfRequests = 0
deviceTypes = dict()
softwareTypes = dict()
for deviceuuid, deviceType, deviceSoftware in cursor:
    numberOfRequests += 1
    if deviceTypes.has_key(deviceType):
        deviceTypes[deviceType] += 1
    else:
        deviceTypes[deviceType] = 1
    if softwareTypes.has_key(deviceSoftware):
        softwareTypes[deviceSoftware] += 1
    else:
        softwareTypes[deviceSoftware] = 1
    #print(deviceuuid)

print numberOfRequests, "requests found:"
for deviceType in deviceTypes:
    print "\t{:.1f}% of requests from".format(float(deviceTypes[deviceType])*100/float(numberOfRequests)), deviceType
connection.close()