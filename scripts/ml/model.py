import torch
import torch.nn as nn

class PlayerModel(nn.Module):
      def __init__(self, n, maxProj):
            super().__init__()

            self.maxProj = maxProj
            self.n = n
            hidden_dim = 256

            self.net = nn.Sequential(
                  nn.Linear(4 * (1 + maxProj), 256),
                  nn.ReLU(),
                  nn.LayerNorm(256),

                  nn.Linear(256, 256),
                  nn.ReLU(),
                  nn.LayerNorm(256),

                  nn.Linear(256, 128),
                  nn.ReLU(),

                  nn.Linear(128, 2*n)
            )
      def forward(self, x):
            return self.net(x)
            
