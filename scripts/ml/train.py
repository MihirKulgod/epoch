import dataset
from model import PlayerModel
from dataset import GameDataset
import torch
import torch.nn as nn
from torch.utils.data import DataLoader

import sys
log_path = sys.argv[1]

# Max no. of projectiles to take into account
MAX_PROJECTILES = 20

# The player's position will be predicted K physics frames in the future
K = 10

# TRAINING SETUP
batch_size = 64
epochs = 10
learning_rate = 1e-3

# -----------------

dataset = GameDataset(log_path, K, MAX_PROJECTILES)
model = PlayerModel(MAX_PROJECTILES)

loader = DataLoader(dataset, batch_size=batch_size, shuffle=True)

loss_fn = nn.MSELoss()
optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)

device = torch.accelerator.current_accelerator().type if torch.accelerator.is_available() else "cpu"
print(f"[ML] Using {device} device")

print("Starting training...")

for epoch in range(epochs):
      total_loss = 0.0

      for batch_x, batch_y in loader:
            pred = model(batch_x)

            loss = loss_fn(pred, batch_y)

            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

            total_loss += loss.item()

      avg_loss = total_loss / len(loader)
      print(f"Epoch {epoch+1}/{epochs}, Loss: {avg_loss:.6f}")

example_input = torch.randn(1, (MAX_PROJECTILES + 1) * 4)

traced = torch.jit.trace(model, example_input)
traced.save("player_model_ts.pt")

print("Saved TorchScript model to player_model_ts.pt")