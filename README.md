<div align="center">

# NOVA Framework - Launch Scripts

**The essential scripts that come free and open-source with the NOVA Framework.**

10 scripts ready to use — everything you need to launch your FiveM RP server.

[![License](https://img.shields.io/badge/license-GPL--3.0-green)](LICENSE)
[![FiveM](https://img.shields.io/badge/FiveM-compatible-blue)](https://fivem.net)
[![Docs](https://img.shields.io/badge/docs-GitBook-orange)](https://novaframeworkdoc.gitbook.io/novaframework/)

</div>

---

## Included Scripts

| Script | Description |
|--------|-------------|
| **nova_bank** | Banking system — deposits, withdrawals, transfers |
| **nova_chat** | Styled chat with command system |
| **nova_garage** | Vehicle storage, retrieval, and impound |
| **nova_hud** | Health, armor, hunger, thirst, job display |
| **nova_inventory** | Drag & drop inventory with usable items |
| **nova_multichar** | Character creation, selection, and appearance |
| **nova_notify** | Toast notification system |
| **nova_shops** | Clothing, barber, tattoo, and general stores |

## Quick Start

**Requirements:** [nova_core](https://github.com/NoVaPTdev/nova-core), [oxmysql](https://github.com/overextended/oxmysql), MySQL/MariaDB

1. Place all scripts inside `resources/[nova]/`
2. Import SQL schemas:
   - `nova_core/sql/nova.sql`
   - `nova_bank/sql/bank.sql`
3. Add to `server.cfg`:
```cfg
ensure oxmysql
ensure nova_core
ensure nova_bridge
ensure nova_notify
ensure nova_multichar
ensure nova_hud
ensure nova_chat
ensure nova_inventory
ensure nova_bank
ensure nova_garage
ensure nova_shops
```

## Load Order

```
oxmysql
└── nova_core
    ├── nova_bridge
    ├── nova_notify
    ├── nova_multichar
    ├── nova_hud
    ├── nova_chat
    ├── nova_inventory
    │   └── nova_shops
    ├── nova_bank
    └── nova_garage
```

## Documentation

Full documentation for all scripts, exports, events, and configuration:

### **[Read the Docs](https://novaframeworkdoc.gitbook.io/novaframework/)**

## License

This project is licensed under the GPL-3.0 License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**NOVA Framework** — Made with care for the FiveM community.

[Documentation](https://novaframeworkdoc.gitbook.io/novaframework/) · [Discord](https://discord.gg/dxYfwqYRD) · [GitHub](https://github.com/NoVaPTdev)

</div>
