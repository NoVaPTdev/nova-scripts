# NOVA Framework - Launch Scripts Overview

The NOVA Framework includes a set of FiveM scripts that provide core roleplay functionality. This document provides an overview of all launch scripts, their purpose, installation order, and dependencies.

## Scripts Summary

| Script | Description | Dependencies |
|--------|-------------|--------------|
| **nova_core** | Core framework - player management, jobs, callbacks, database | oxmysql |
| **nova_bridge** | Bridge layer for compatibility | nova_core |
| **nova_notify** | Toast notification system | — |
| **nova_multichar** | Character creation, selection, and appearance | nova_core |
| **nova_hud** | Health, armor, hunger, thirst, job display, progress bar | nova_core |
| **nova_chat** | Styled chat with command system | nova_core |
| **nova_inventory** | Drag & drop inventory with usable items | nova_core |
| **nova_bank** | Banking system with deposits, withdrawals, transfers | nova_core |
| **nova_garage** | Vehicle storage, retrieval, and impound | nova_core |
| **nova_shops** | Clothing, barber, tattoo, and general stores | nova_core, nova_inventory |

## Installation Order

Scripts must be loaded in the correct order to ensure dependencies are available. The recommended load order in your `server.cfg`:

```
# 1. Dependencies first
ensure oxmysql

# 2. Core framework (required by all other scripts)
ensure nova_core

# 3. Bridge (if using)
ensure nova_bridge

# 4. UI/Utility scripts (no dependencies on other NOVA scripts)
ensure nova_notify

# 5. Character & Login
ensure nova_multichar

# 6. HUD & Chat (player-facing UI)
ensure nova_hud
ensure nova_chat

# 7. Inventory (required by shops)
ensure nova_inventory

# 8. Economy & Vehicles
ensure nova_bank
ensure nova_garage

# 9. Shops (depends on inventory for item purchases)
ensure nova_shops
```

When using the `[frameworklancamento]` resource folder, ensure the entire folder:

```
ensure [frameworklancamento]
```

The resources within the folder are typically loaded in alphabetical order. Ensure `nova_core` starts before other nova_* scripts by naming or explicit ordering in the resource manifest.

## Dependency Graph

```
nova_core
    ├── nova_notify (optional, used for notifications)
    ├── nova_multichar
    ├── nova_hud
    ├── nova_chat
    ├── nova_inventory
    │   └── nova_shops (for item purchases)
    ├── nova_bank
    └── nova_garage
```

## Database Requirements

Before running the framework, execute the following SQL files in order:

1. **nova_core/sql/nova.sql** - Core tables (`nova_users`, `nova_characters`, `nova_vehicles`, `nova_jobs`, etc.)
2. **nova_bank/sql/bank.sql** - Bank transactions table (`nova_transactions`)

## Notes

- All NOVA scripts require **Lua 5.4** (`lua54 'yes'` in fxmanifest).
- The framework uses **oxmysql** for database operations.
- **nova_notify** is used throughout the framework for user feedback; ensure it loads early.
- **nova_inventory** must load before **nova_shops** so item purchases work correctly.
