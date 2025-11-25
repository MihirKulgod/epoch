import asyncio
import json
import torch
import websockets
from dataset import GameDataset
from torch.utils.data import DataLoader
from model import PlayerModel
import torch.nn as nn

training_lock = asyncio.Lock()

model = torch.jit.load("player_model_ts.pt")
model.eval()

BATCH_SIZE = 64
EPOCHS = 1000
MAX_PROJECTILES = 20
LR = 1e-3
# The number of frames between successive predicted positions
K = 10
# Number of positions to predict
N = 3

loss_fn = nn.MSELoss()
optimizer = torch.optim.Adam(model.parameters(), lr=LR)

device = torch.accelerator.current_accelerator().type if torch.accelerator.is_available() else "cpu"
print(f"Using {device} device")

def train_model(log_path, progress_callback):
      dataset = GameDataset(log_path, N, K, MAX_PROJECTILES)
      loader = DataLoader(dataset, batch_size=BATCH_SIZE, shuffle=True)

      print("Starting training...")

      for epoch in range(EPOCHS):
            total_loss = 0.0

            for batch_x, batch_y in loader:
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
      example_input = torch.randn(1, (MAX_PROJECTILES + 1) * 4)

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
      
      projectiles = data["projectiles"][:MAX_PROJECTILES]
      while len(projectiles) < MAX_PROJECTILES:
            projectiles.append([0, 0, 0, 0])

      proj_flat = [val for p in projectiles for val in p]

      state = player + proj_flat

      x = torch.tensor(state, dtype=torch.float32).unsqueeze(0)

      with torch.no_grad():
            pred = model(x).squeeze().tolist()

      await ws.send(json.dumps({
           "type": "prediction",
           "prediction": pred
      }))

async def reset(ws):
      print("Resetting!")
      global model, optimizer

      model = PlayerModel(N, MAX_PROJECTILES)
      model.eval()

      optimizer = torch.optim.Adam(model.parameters(), lr=LR)

      await ws.send(json.dumps({
            "type": "reset"
      }))

asyncio.run(main())
