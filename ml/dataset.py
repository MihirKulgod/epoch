import numpy as np
import torch
from torch.utils.data import Dataset

def load_data(path):
      import json
      frames = []
      with open(path) as f:
            for line in f:
                  line = line.strip()
                  if not line:
                        continue
                  try:
                        frames.append(json.loads(line))
                  except json.JSONDecodeError as e:
                        print("Bad log line: ", line)
                        continue
      return frames

def make_samples(frames, N, K, maxEnemies, maxProjectiles):
      inputs = []
      targets = []

      frames = frames[:1500]

      num_frames = len(frames)
      max_start = num_frames - N * K

      for i in range(max_start):
            f0 = frames[i]

            player = np.array(f0["player"], dtype=np.float32)
            enemies = pad(f0["enemies"], maxEnemies)
            projectiles = pad(f0["projectiles"], maxProjectiles)
            input_vec = np.concatenate([player, enemies, projectiles])

            future_positions = []

            for n in range(1, N + 1):
                  fn = frames[i + n * K]
                  pos = np.array(fn["player"][:2], dtype=np.float32)
                  future_positions.append(pos)

            target_vec = np.concatenate(future_positions)

            inputs.append(input_vec)
            targets.append(target_vec)

      return (
            torch.as_tensor(inputs, dtype=torch.float32),
            torch.as_tensor(targets, dtype=torch.float32)
      )



def pad(projectiles, max_no_projectiles):
      arr = np.zeros((max_no_projectiles, 4), dtype=np.float32)
      for i in range(len(projectiles)):
            if i >= max_no_projectiles:
                  break
            arr[i] = projectiles[i]
      return arr.flatten()

class GameDataset(Dataset):
      def __init__(self, log_path, n=5, k=10, max_enemies=16, max_projectiles=24):
            frames = load_data(log_path)
            self.X, self.Y = make_samples(frames, n, k, max_enemies, max_projectiles)

      def __len__(self):
            return len(self.X)

      def __getitem__(self, idx):
            return self.X[idx], self.Y[idx]