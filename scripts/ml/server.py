import asyncio
import json
import torch
import websockets
from dataset import GameDataset
from torch.utils.data import DataLoader
from model import PlayerModel
import torch.nn as nn

print(torch.__version__)
print(torch.version.cuda)
print(torch.cuda.is_available())

training_lock = asyncio.Lock()

device = "cuda" if torch.cuda.is_available() else "cpu"

model = torch.jit.load("player_model_ts.pt").to(device)
model.eval()

BATCH_SIZE = 64
EPOCHS = 300
MAX_PROJECTILES = 50
MAX_ENEMIES = 16
LR = 1e-3
# The number of frames between successive predicted positions
K = 6
# Number of positions to predict
N = 3

loss_fn = nn.MSELoss()
optimizer = torch.optim.Adam(model.parameters(), lr=LR)
print(f"Using {device} device")

def train_model(log_path, progress_callback):
      dataset = GameDataset(log_path, N, K, MAX_ENEMIES, MAX_PROJECTILES)
      loader = DataLoader(dataset, batch_size=BATCH_SIZE, shuffle=True)

      print("Starting training...")

      for epoch in range(EPOCHS):
            total_loss = 0.0

            for batch_x, batch_y in loader:
                  batch_x = batch_x.to(device)
                  batch_y = batch_y.to(device)

                  pred = model(batch_x)

                  loss = loss_fn(pred, batch_y)

                  optimizer.zero_grad()
                  loss.backward()
                  optimizer.step()

                  total_loss += loss.item()

            avg_loss = total_loss / len(loader)
            progress_callback(epoch, avg_loss)
            print(f"Epoch {epoch+1}/{EPOCHS}, Loss: {avg_loss:.6f}")

      print("Training finished!")
      example_input = torch.randn(1, (1 + MAX_ENEMIES + MAX_PROJECTILES) * 4)

      traced = torch.jit.trace(model, example_input)
      traced.save("player_model_ts.pt")

      print("Saved TorchScript model to player_model_ts.pt")

async def start_train(ws, data, loop):
      log_path = data["log_path"]

      await ws.send(json.dumps({
           "type": "train_start",
           "max_epoch": EPOCHS
      }))

      def progress(epoch, loss):
            asyncio.run_coroutine_threadsafe(
                  ws.send(json.dumps({
                  "type": "progress",
                  "epoch": epoch,
                  "loss": loss
            })), 
            loop
      )
            
      await asyncio.to_thread(train_model, log_path, progress)

      await ws.send(json.dumps({
           "type": "train_complete"
      }))

async def handle_connection(ws, loop):
      print("Client connected!")

      await ws.send(json.dumps({
            "type": "connection_success"
      }))

      try:
        async for message in ws:
            try:
                  data = json.loads(message)
            except json.JSONDecodeError:
                  print("Received invalid JSON: ", message)
                  continue

            if not isinstance(data, dict):
                 print("Received a packet that is not a dict: ", data)
                 continue
            
            if "type" not in data:
                 print("Packet missing 'type': ", data)
                 continue
            
            packet_type = data["type"]

            if packet_type == "train":
                  if training_lock.locked():
                        await ws.send(json.dumps({"type": "error", "message": "Training already running"}))
                  else:
                        async with training_lock:
                              await start_train(ws, data, loop)
            elif packet_type == "inference":
                 await inference(ws, data)
            elif packet_type == "reset":
                  if training_lock.locked():
                        await ws.send(json.dumps({"type": "error", "message": "Cannot reset during training"}))
                  else:
                        await reset(ws)
            else:
                 print("Received unknown packet type: ", packet_type)

      except websockets.ConnectionClosed:
            print("Client disconnected")

async def main():
      loop = asyncio.get_running_loop()

      async with websockets.serve(
           lambda ws: handle_connection(ws, loop),
           "localhost",
           8766
      ):
            print("Server running on ws://localhost:8766")
            await asyncio.Future()

async def inference(ws, data):
      player = data["player"]
      
      enemies = data["enemies"][:MAX_ENEMIES]
      while len(enemies) < MAX_ENEMIES:
            enemies.append([0, 0, 0, 0])
      ene_flat = [val for e in enemies for val in e]

      projectiles = data["projectiles"][:MAX_PROJECTILES]
      while len(projectiles) < MAX_PROJECTILES:
            projectiles.append([0, 0, 0, 0])
      proj_flat = [val for p in projectiles for val in p]

      state = player + ene_flat + proj_flat

      x = torch.tensor(state, dtype=torch.float32).unsqueeze(0).to(device)

      with torch.no_grad():
            pred = model(x).squeeze().tolist()

      await ws.send(json.dumps({
           "type": "prediction",
           "prediction": pred
      }))

async def reset(ws):
      print("Resetting!")
      global model, optimizer

      model = PlayerModel(N, MAX_ENEMIES, MAX_PROJECTILES).to(device)
      model.eval()

      optimizer = torch.optim.Adam(model.parameters(), lr=LR)

      await ws.send(json.dumps({
            "type": "reset"
      }))

asyncio.run(main())
