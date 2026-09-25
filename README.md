# Planet Survival 3D

A 3D survival and exploration game set on an alien planet.

## Story
You crash-land on the planet Aurelion after a failed atmospheric probe mission. The landing signal is damaged, the ship is powerless, and the only way to survive is to recover essential materials scattered across the world. As you gather resources and restore the beacon, you discover that the planet hides an ancient artificial structure beneath a fractured crater.

## Gameplay
- Explore a large open 3D environment
- Collect ore, batteries, water, and scrap
- Restore the planetary beacon at your base camp
- Survive the world and uncover the hidden truth beneath the surface
- Finish the mission by activating the emergency relay

## Controls
- W/A/S/D: Move
- Shift: Sprint
- Space: Jump
- E: Collect nearby resource
- Mouse: Look around
- Esc: Toggle mouse capture

## How to run
1. Open the project in Godot 4.x.
2. Import the folder as a project.
3. Press F5 to run.

## Project structure
- `Main.tscn`: main scene entry point
- `scripts/Player.gd`: first-person movement controller
- `scripts/Main.gd`: world generation and gameplay loop
- `scripts/ResourceNode.gd`: collectible resource objects
- `scripts/QuestTracker.gd`: story progression and objective tracking

## Goal
Collect enough resources to repair the beacon and reach the final relay objective before the planet's storms and radiation take the base offline.
