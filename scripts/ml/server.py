import asyncio
import json
import torch
import websockets
from dataset import GameDataset
from torch.utils.data import DataLoader
import torch.nn as nn

model = torch.jit.load("player_model_ts.pt")
model.eval()

BATCH_SIZE = 64
EPOCHS = 500
MAX_PROJECTILES = 20
LR = 1e-3
K = 10
N = 3

loss_fn = nn.MSELoss()
optimizer = torch.optim.Adam(model.parameters(), lr=LR)

device = torch.accelerator.current_accelerator().type if torch.accelerator.is_available() else "cpu"
print(f"[ML] Using {device} device")

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

async def start_train(ws, data):
      log_path = data["log_path"]

      def progress(epoch, loss):
            asyncio.run_coroutine_threadsafe(
                  ws.send(json.dumps({
                  "type": "progress",
                  "epoch": epoch,
                  "loss": loss
            })), 
            asyncio.get_event_loop()
      )
            
      await asyncio.to_thread(train_model, log_path, progress)

async def handle_connection(ws):
      print("Client connected!")

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
                 print("Received train packet!")
                 await start_train(ws, data)
            elif packet_type == "inference":
                 print("Received inference packet!")
                 await inference(ws, data)
            else:
                 print("Received unknown packet type: ", packet_type)

      except websockets.ConnectionClosed:
            print("Client disconnected")

async def main():
      async with websockets.serve(handle_connection, "localhost", 8766):
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

asyncio.run(main())
