#!/bin/bash
#
# This script configures the APT repository for the Othello CLI game.
#
# Usage:
#   curl -sS https://hantaro171902.github.io/othello-cli/install.sh | sudo bash
#

set -e

# Add the GPG key
echo "Adding repository GPG key..."
curl -sS https://hantaro171902.github.io/othello-cli/public.key | gpg --dearmor | tee /usr/share/keyrings/othello-cli-repo.gpg >/dev/null

# Add the repository to the sources list
echo "Adding APT repository..."
echo "deb [signed-by=/usr/share/keyrings/othello-cli-repo.gpg] https://hantaro171902.github.io/othello-cli stable main" | tee /etc/apt/sources.list.d/othello-cli.list >/dev/null

# Update the package list
echo "Updating package lists..."
apt-get update

echo ""
echo "Repository setup complete."
echo "You can now install the game with: sudo apt install othello-cli"
