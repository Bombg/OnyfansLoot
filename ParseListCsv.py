from slpp import slpp as lua
import csv

namePosition = 0
lootPosition = 6
lootToName = {}
csvArray = []

with open("OFLootList-8-11-24.csv", mode = 'r') as file:
    csvFile = csv.reader(file)
    headers = next(csvFile)
    for line in csvFile:
        csvArray.append(line)
        for i in range(lootPosition,len(line)):
            if ''.join(line[i]).strip():
                lootToName[line[i].strip().lower()] = []

for i in range(lootPosition,25):
    rollString = {}
    for line in csvArray:
        if ''.join(line[i]).strip():
            if line[i].strip().lower() not in rollString:
                rollString[line[i].strip().lower()] =  line[0] + ", "
            else:
                rollString[line[i].strip().lower()] = rollString[line[i].strip().lower()] + line[0] + ", "
    for k, v in rollString.items():
        lootToName[k].append(v.strip().rstrip(','))


f = open("LuaTable.txt",mode = "w")
f.write(lua.encode(lootToName))
f.close()



