from slpp import slpp as lua
import csv
import re

namePosition = 0
lootPosition = 6
lootToName = {}
csvArray = []
versionArr = []


listVersion = 5
listDateTime = "8-18-24:20:05"

def cleanString(string: str):
    newString = string.strip()
    newString = newString.strip("[")
    newString = newString.strip("]")
    newString = newString.rstrip(",")
    newString = newString.lower()
    return newString


with open("OFLootList-8-18-24.csv", mode = 'r') as file:
    csvFile = csv.reader(file)
    headers = next(csvFile)
    for line in csvFile:
        csvArray.append(line)
        for i in range(lootPosition,len(line)):
            if ''.join(line[i]).strip(): ## Checking for empty cell
                if "?" in line[i]:
                    loots = line[i].split("?")
                    for string in loots:
                        lootToName[cleanString(string)] = []
                else:
                    lootToName[cleanString(line[i])] = []
                    print(cleanString(line[i]))

for i in range(lootPosition,24):
    rollString = {}
    for line in csvArray:
        if ''.join(line[i]).strip():
            if "?" in line[i]:
                loots = line[i].split("?")
                for loot in loots:
                    if cleanString(line[i]) not in rollString:
                        rollString[cleanString(loot)] =  line[0] + ", "
                    else:
                        rollString[cleanString(loot)] = rollString[cleanString(loot)] + line[0] + ", "
            elif cleanString(line[i]) not in rollString:
                rollString[cleanString(line[i])] =  line[0] + ", "
            else:
                rollString[cleanString(line[i])] = rollString[cleanString(line[i])] + line[0] + ", "
    for k, v in rollString.items():
        lootToName[cleanString(k)].append(cleanString(v))

versionArr.append(listVersion)
versionArr.append(listDateTime)
lootToName["version"] = versionArr
f = open("LuaTable.txt",mode = "w")
f.write(lua.encode(lootToName))
f.close()



