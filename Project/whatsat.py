import asyncio
import time

port = {"Hill" : 12145, "Jaquez" : 12146, "Smith" : 12147,
        "Campbell" : 12148, "Singleton" : 12149}

async def main():
	reader, writer = await asyncio.open_connection('127.0.0.1', port["Hill"])
	temp = " "
	writer.write(temp.encode())
	#writer.write("hello again\n".encode())
	writer.write_eof()
	await writer.drain()
	data = await reader.read()
	print(data.decode())
	writer.close()
	await writer.wait_closed()


if __name__ == '__main__':
	asyncio.run(main())