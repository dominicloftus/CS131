#12145 12146 12147 12148 12149

import asyncio
import sys
import time
import aiohttp
import json

server_name = ""
servers = ["Hill", "Jaquez", "Smith", "Campbell", "Singleton"]
port = {"Hill" : 12145, "Jaquez" : 12146, "Smith" : 12147,
        "Campbell" : 12148, "Singleton" : 12149}
connections = {"Hill" : ["Jaquez", "Smith"], "Jaquez" : ["Hill", "Singleton"],
               "Smith" : ["Hill", "Campbell", "Singleton"],
               "Campbell" : ["Smith", "Singleton"],
               "Singleton" : ["Jaquez", "Smith", "Campbell"]}
locations = {}

API_KEY = "API_KEY"

async def main():
    server = await asyncio.start_server(handle_connection, host='127.0.0.1', port=port[server_name])
    await server.serve_forever()

async def log_write(log):
    try:
        log_file.write(log)
    except:
        pass

async def iamat(command, time_diff):
    if(time_diff >= 0):
        time_stamp = "+" + str(time_diff)
    else:
        time_stamp = "-" + str(time_diff)
    info_store = ["AT", server_name, time_stamp] + command[1:]
    locations[command[1]] = info_store
    response = ' '.join(info_store)
    for serv in connections[server_name]:
        try:
            await log_write("Flooding " + response + " to " + serv + '\n')
            _, writer = await asyncio.open_connection('127.0.0.1', port[serv])
            writer.write(response.encode())
            writer.write_eof()
            await writer.drain()
            writer.close()
            await writer.wait_closed()
        except:
            await log_write("Flood to " + serv + " failed\n")

    return response

async def at(command):
    if not command[3] in locations.keys() or locations[command[3]] != command:
        locations[command[3]] = command
        for serv in connections[server_name]:
            try:
                response = ' '.join(command)
                await log_write("Flood " + response + " to " + serv + '\n')
                _, writer = await asyncio.open_connection('127.0.0.1', port[serv])
                writer.write(response.encode())
                writer.write_eof()
                await writer.drain()
                writer.close()
                await writer.wait_closed()
            except:
                await log_write("Flood to " + serv + " failed\n")
        

async def whatsat(command):
    radius = 1000 * float(command[2])
    num_entries = int(command[3])
    if not command[1] in locations.keys() or radius > 50000 or num_entries > 20:
        return "? " + ' '.join(command)
    client = locations[command[1]]
    coords = client[4]
    lat, coords = coords[0], coords[1:]
    ind = coords.find('+')
    if ind == -1:
        ind = coords.find('-')
    lat += coords[:ind]
    lon = coords[ind:]
    latitude, longitude = float(lat[1:]), float(lon[1:])
    if lat[0] == '-':
        latitude *= -1
    if lon[0] == '-':
        longitude *= -1
    if lat[0] == '+':
        lat = lat[1:]
    if lon[0] == '+':
        lon = lon[1:]
    
    async with aiohttp.ClientSession(connector=aiohttp.TCPConnector(ssl=False)) as session:
        url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json" 
        params = [('location', lat + ',' + lon), ('radius', str(radius)), ('key', API_KEY)]
        async with session.get(url, params=params) as resp:
            response = await resp.json()
            response["results"] = response["results"][:num_entries]
            entries = json.dumps(response, indent=3)
            return ' '.join(client) + '\n' + entries + '\n'
    



async def handle_connection(reader, writer):
    data = await reader.read()
    time_stamp = time.time()
    name = data.decode()
    await log_write("Received input: " + name + '\n')
    command = name.split()
    command = [x for x in command if not x.isspace()]
    if len(command) == 0:
        writer.write("? ".encode())
        writer.write_eof()
        writer.close()
        await writer.wait_closed()
        return
    comm = command[0]
    if comm == "IAMAT" and len(command) == 4:
        response = await iamat(command, time_stamp - float(command[3]))
    elif comm == "WHATSAT" and len(command) == 4:
        response = await whatsat(command)
    elif comm == "AT" and len(command) == 6:
        await at(command)
        writer.close()
        await writer.wait_closed()
        return
    else:
        response = "? " + name

    await log_write("Sending output: " + response + '\n')
    writer.write(response.encode())
    writer.write_eof()
    writer.close()
    await writer.wait_closed()


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Proper use: server.py <ServerName>.")
        exit(1)
    else:
        server_name = sys.argv[1]
        if not server_name in servers:
            print("Unknown server name")
            exit(1)
    global log_file 
    file_name = server_name + ".log"
    log_file = open(file_name, 'a+', 1)
    log_file.write("Server " + server_name + " running\n")

    asyncio.run(main())

