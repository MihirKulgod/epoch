import torch
import torch.nn as nn

class PlayerModel(nn.Module):
      def __init__(self, maxProj):
            super().__init__()

            self.maxProj = maxProj
            hidden_dim = 512

            self.net = nn.Sequential(
                  nn.Linear(4 * (1 + maxProj), hidden_dim),
                  nn.ReLU(),
                  nn.Linear(hidden_dim, hidden_dim),
                  nn.ReLU(),
                  nn.Linear(hidden_dim, hidden_dim // 2),
                  nn.ReLU(),
                  nn.Linear(hidden_dim // 2, 2),
            )
      def forward(self, x):
            return self.net(x)
            
