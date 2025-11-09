import numpy as np
import torch
from torch.utils.data import Dataset

MAX_PROJ = 20

def load_data(path):
      import json
      frames = []
      with open(path) as f:
            for line in f:
                  frames.append(json.loads(line))
      return frames

def make_samples(frames, K, maxProjectiles):
      inputs = []
      targets = []

      for i in range(len(frames) - K):
            f0 = frames[i]
            f1 = frames[i + K]

            player = np.array(f0["player"], dtype=np.float32)
            proj = pad_projectiles(f0["projectiles"], maxProjectiles)
            input_vec = np.concatenate([player, proj])
            target_vec = np.array(f1["player"][:2], dtype=np.float32)

            inputs.append(input_vec)
            targets.append(target_vec)

      return torch.as_tensor(inputs, dtype=torch.float32), torch.as_tensor(targets, dtype=torch.float32)


def pad_projectiles(projectiles, max_no_projectiles):
      arr = np.zeros((max_no_projectiles, 4), dtype=np.float32)
      for i in range(len(projectiles)):
            if i >= max_no_projectiles:
                  break
            arr[i] = projectiles[i]
      return arr.flatten()

class GameDataset(Dataset):
      def __init__(self, log_path, k=10, max_projectiles=20):
            frames = load_data(log_path)
            self.X, self.Y = make_samples(frames, k, max_projectiles)

      def __len__(self):
            return len(self.X)

      def __getitem__(self, idx):
            return self.X[idx], self.Y[idx]