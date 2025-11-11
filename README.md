# Othello - Terminal Edition (C++ · OOP · ANSI / Unicode UI)
A terminal-first reimplementation of Othello (Reversi) written in modern C++.
No GUI framework — just Unicode glyphs, ANSI color codes, and careful terminal control. This repo showcases algorithmic reasoning (move prediction + flipping), defensive systems programming, and a polished CLI UX. It's one of my most complicated projects so far — predicting valid moves and applying flips correctly across 8 directions produces many edge cases.

---

## Live demo / screenshots

Add screenshots or a short gif to `assets/` and reference them here.

Example (replace with your files):

<img width="847" height="628" alt="image" src="https://github.com/user-attachments/assets/b866da5d-bf43-4824-b68c-db6ddd1309cf" />


---

## Features

- Playable Othello (Reversi) in the terminal with keyboard controls (arrow keys or WASD).
- OOP architecture: `Board`, `Game`, `Renderer`, `Utils`, `Color`.
- Full move prediction: highlights valid moves before placing.
- Atomic flipping across 8 directions (`scanAndFlip`) — handles edges/corners and multi-direction captures.
- Historical move list (scrollable) + side menu with score, timer, and current-turn indicator.
- Cross-platform input handling (termios on Unix; `conio.h` fallback for Windows).
- Unicode box-drawing and circle glyphs (●, ○) for clean, consistent rendering.

---

## Quick start

### Requirements

- A C++17-capable compiler (g++ / clang / MSVC).
- Terminal that supports UTF-8 + ANSI color codes (Linux terminal, macOS Terminal/iTerm2, Windows Terminal recommended).

### Installation (Debian/Ubuntu)

**Recommended: One-Line Install**

This command will automatically add the repository and its GPG key.

```bash
curl -sS https://hantaro171902.github.io/othello-cli/install.sh | sudo bash
```

**Manual Installation**

If you prefer to add the repository manually, follow these steps:

1.  **Add the GPG Key:**
    ```bash
    curl -sS https://hantaro171902.github.io/othello-cli/public.key | sudo gpg --dearmor -o /usr/share/keyrings/othello-cli-repo.gpg
    ```

2.  **Add the repository to your sources list:**
    ```bash
    echo "deb [signed-by=/usr/share/keyrings/othello-cli-repo.gpg] https://hantaro171902.github.io/othello-cli stable main" | sudo tee /etc/apt/sources.list.d/othello-cli.list
    ```

**Install the Game**

After setting up the repository (either with the one-liner or manually), update your package list and install the game:

```bash
sudo apt update
sudo apt install othello-cli
```

### Build (simple)

From project root:

```bash
# quick one-file-ish compile (adjust for subfolders)
g++ -std=c++17 src/main.cpp src/game.cpp src/board.cpp src/renderer.cpp src/utils.cpp src/color.cpp -o othello

# or use the provided CMake build
mkdir -p build && cd build
cmake ..
make -j
./Othello
```

(Windows: run `othello.exe`)

Tip: If compilation fails because of missing headers, ensure the `.hpp` files are present in the right include path and adjust the compile command accordingly.

---

## Controls

- Arrow keys or W / A / S / D — move cursor
- ENTER — place disk (if valid)
- R — reset game
- Q or ESC — quit
- [ / ] — scroll move history

---

## File structure

```
.
├─ src/
│  ├─ main.cpp           # entry point
│  ├─ game.cpp / .hpp    # main loop, menu, state transitions, move history
│  ├─ board.cpp / .hpp   # board model, move prediction, flipping logic
│  ├─ renderer.cpp / .hpp# terminal drawing and side menu
│  ├─ utils.cpp / .hpp   # terminal helpers, input helpers, time formatting
│  └─ color.cpp / .hpp   # ANSI color helpers
└─ assets/               # screenshots, sounds (optional)
```

---

## Core logic — how move prediction & flipping works

Two pieces of logic are critical (and subtly tricky):

1) Move prediction (`Board::isValid`, `Board::getValid`, `Board::scan`)

For every empty cell candidate, the code scans in all 8 directions.

A direction is valid if starting from the neighbor in that direction:

- there is a contiguous sequence of opponent disks (at least one), and
- the sequence is terminated by a friendly disk before the board edge.

If any direction validates, the cell is a legal move.

Why this is tricky: corners/edges and immediate-adjacent squares must be handled without off-by-one errors. You must ensure you see at least one opponent disk before accepting a friendly disk as a terminator.

2) Flipping (`Board::scanAndFlip`)

After placing a disk, the code re-scans all 8 directions.
If the scan confirms an enclosing friendly disk, flip every intermediate cell between the placed disk and the terminator to the placing player's disk.
If the scan reaches an empty cell or runs off the board, do not flip anything in that direction.

Atomicity: Each direction flips only after confirming enclosure. This avoids partial flips and maintains board consistency.

### Pseudocode (conceptual)

```
function isValid(x, y, player):
	if cell[x,y] != Empty: return false
	for each direction (dx, dy):
		if scan(x, y, dx, dy, player) returns true:
			return true
	return false

function scan(startX, startY, dx, dy, player):
	x = startX + dx; y = startY + dy
	foundOpponent = false
	while inBounds(x,y):
		if board[y][x] == Empty: return false
		if board[y][x] == player: return foundOpponent
		foundOpponent = true
		x += dx; y += dy
	return false

function put(x, y, player):
	assert cell empty
	place player at x,y
	for each (dx,dy) call scanAndFlip(x,y,dx,dy)
```

---

## Complexity

- Time complexity of naive move check: O(boardSize^3) in worst case — for each of boardSize^2 cells, you may scan up to boardSize steps across 8 directions.
- Space complexity: O(boardSize^2) to store the grid.

In practice for typical Othello sizes (8×8 to 12×12), this is trivial; the code avoids extra allocations during logic passes for snappy interactivity.

---

## Robustness & UX details

- Non-blocking input loop so timer/renderer stay responsive while waiting for user input.
- Cursor movement is purely visual until ENTER is pressed — prevents accidental state changes.
- Side menu placement adapts with `get_terminal_size()` to avoid overflowing small terminals.
- ANSI color codes are centralized in `color.cpp` for easy tweaking.
- Move history is stored as `MoveRecord` and rendered in a scrollable section.

---

## Testing & suggestions

Recommended next steps for more confidence and portability:

- Extract board logic into a testable module and add unit tests (GoogleTest or Catch2). Test cases to include:
	- edge/corner captures,
	- no-flip directions,
	- multi-direction flips,
	- pass-turn conditions.
- Add CI to run the unit tests automatically on push.

---

## Future improvements

- Add an AI opponent (minimax + heuristic; optional alpha-beta pruning).
- Save / load game state.
- Replay mode (step through historical moves).
- Networked multiplayer via a simple TCP server.
- Better Windows support (native Win32 console API for cursor & color if needed).

---

## Known issues / troubleshooting

- Terminal must support UTF-8 and ANSI escape codes; Windows CMD may render poorly — use Windows Terminal or WSL.
- Sound playback uses `aplay` on Linux; silence will occur if not installed.
- Very small terminals may truncate UI — resize or use a smaller board size.

---

## License

MIT © Hantaro171902

---

## Contact / attribution

If you found this useful or want to collaborate, open an issue or PR.

---

Enjoy playing Othello in your terminal!
