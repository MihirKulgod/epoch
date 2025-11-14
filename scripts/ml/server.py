import asyncio
import json
import torch
import websockets

model = torch.jit.load("player_model_ts.pt")
model.eval()

MAX_PROJECTILES = 20

async def handle_connection(ws):
      print("Client connected")

      try:
        async for message in ws:
            data = json.loads(message)
            player = data["player"]
            
            projectiles = data["projectiles"][:MAX_PROJECTILES]
            while len(projectiles) < MAX_PROJECTILES:
                  projectiles.append([0, 0, 0, 0])

            proj_flat = [val for p in projectiles for val in p]

            state = player + proj_flat

            x = torch.tensor(state, dtype=torch.float32).unsqueeze(0)

            # Run prediction
            with torch.no_grad():
                pred = model(x).squeeze().tolist()

            # Send back prediction
            await ws.send(json.dumps({"prediction": pred}))

      except websockets.ConnectionClosed:
            print("Client disconnected")

async def main():
      async with websockets.serve(handle_connection, "localhost", 8766):
            print("Server running on ws://localhost:8766")
            await asyncio.Future()

asyncio.run(main())
