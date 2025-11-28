# EPOCH

**Epoch** is a wave-based bullet-hell game built in the **Godot** engine.  
Each round, the player’s behavior is logged and used to train a machine learning model that predicts future movement.  
Certain enemies then aim attacks based on these predictions — creating an adaptive challenge that becomes smarter as you play.

## How to Run
- Go to the Releases section of this repository
- Download the latest release (.zip)
- Extract the contents
- Run the included executable to start the game

Currently supported: *Windows*
## Features
- **Real-time data collection**  
  Every frame, the kinematic states (position–velocity pairs) of the player, enemies, and projectiles are appended to a JSONL dataset.  
  Since survival depends on dodging bullets and colliding with enemies to damage them, this data is crucial for learning the player’s movement patterns.

- **Between-wave training**  
  When a wave is cleared, the ML model trains on the data produced during that round.

- **WebSocket communication between Godot and Python**  
  Allows the game to receive real-time movement predictions from the PyTorch model during gameplay.

- **Prediction-based enemy behavior**  
  After Wave 10, more advanced enemies use the predicted future positions of the player to aim precise and difficult-to-dodge attacks.

- **20 handcrafted enemy waves**  
  Each designed to gradually exploit increasing predictability in the player's movement patterns.

## Tech Stack

| Component       | Info                |
|-----------------|---------------------|
| Game Engine     | Godot 4.5 (GDScript)|
| ML Framework    | PyTorch             |
| Communication   | WebSockets          |
| Data Formats    | JSON / JSONL / INI  |
| Languages       | Python, GDScript    |

