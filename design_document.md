Here is a **tight, deploy-ready design document** you can hand directly to **Claude Code CLI** as the master specification for your slingshot-physics game MVP and post-MVP enhancements.

No fluff. No filler.
This is exactly the kind of structured doc Claude will follow cleanly.

---

# **SLINGSHOT PHYSICS GAME — DESIGN DOCUMENT (FOR CLAUDE CODE CLI)**

## **Project Overview**

Create a 2D slingshot-based physics game inspired by Angry Birds mechanics but using **original code and assets**.
Gameplay loop: drag to aim → release projectile → destroy target structures → clear objectives → proceed to next level.

Project must be built using **Godot 4.5.1**, with **minimal manual editor work**. Claude should generate:

* `.tscn` scene files
* `.gd` scripts
* input mappings
* camera behavior
* physics bodies
* destructible structures
* level loader
* UI scenes
* boost/ad logic scaffolding

Godot Editor is used *only* to import assets and run the game.

---

# **ENGINE REFERENCES FOR RAG**

Claude is allowed to reference patterns from these templates:

### **Primary Template (Base Architecture)**

* **Basic 2D Platformer Starter Template (Godot 4.5.1)**
  Used for:

  * node structure patterns
  * physics setup (RigidBody2D, StaticBody2D, CollisionShape2D)
  * camera follow logic
  * scene hierarchy conventions

### **Supplemental Reference Templates**

* **Basic 2D Defender-Style Template**
  Used for:

  * projectile patterns
  * firing arcs
  * object pooling (if needed)

* **Basic Enemy AI – LOS Template**
  Used for:

  * detection logic
  * target identification
  * clean state machine patterns

Claude must **NOT** copy code directly from these templates.
Claude must **adapt and write original GDScript**, only reusing structural patterns.

---

# **TARGET PLATFORM**

* iOS and Android
* Fast startup (goal: under 5 seconds)
* Lightweight scene loads
* Keep scripts modular

---

# **CORE MVP FEATURES**

## **1. Game Loop**

Each round should be ~30–60 seconds:

* Player aims slingshot via drag gesture
* Trajectory line preview
* Release to fire
* Projectile collides with destructible blocks and targets
* If all targets destroyed → level clear screen
* Otherwise player retries with limited projectiles

Projectiles should behave as **RigidBody2D** with:

* adjustable force multiplier
* gravity
* bounce factor
* collision mask/layers

---

## **2. Controls**

Touch + mouse support:

* Press and drag on slingshot band → aim
* Longer drag = more force
* Angle determined by drag direction
* Release → fire projectile
* Slingshot returns to idle state

Claude should write input handling fully in code.

---

## **3. Scene Structure**

Claude should generate scenes as `.tscn` text files.

**Example Scene Structure (Level Scene):**

```
Level1.tscn
  - Root (Node2D)
      - Camera2D
      - Slingshot (Node2D)
          - BandFront (Sprite2D)
          - BandBack (Sprite2D)
          - LaunchPoint (Position2D)
      - ProjectileSpawn (Position2D)
      - LevelTerrain (StaticBody2D)
          - CollisionShape2D
      - Blocks (Node2D)
          - Block_* (RigidBody2D)
          - Target_* (RigidBody2D with custom script)
      - UI (CanvasLayer)
          - LevelLabel
          - ShotCounter
          - ResetButton
```

Claude should fully generate these layouts in `.tscn` XML/TSCN syntax.

---

## **4. Physics**

* **RigidBody2D** for projectile and blocks
* **StaticBody2D** for the ground
* Destructible blocks have:

  * health
  * damage on impact
  * break animation or disappearance

Claude should expose tunable parameters at top of scripts.

---

## **5. Level Flow**

Levels are standalone `.tscn` files.

Add a **LevelManager** autoload that:

* loads current level
* on win → show popup → load next level
* on fail → reset the level
* tracks basic stats (shots used, stars rating, etc. but simple for MVP)

---

## **6. UI Requirements**

Minimal MVP UI:

* Start menu with “Play” button
* Level complete popup
* Retry button
* Simple text indicators (shots remaining, level name)

Claude should generate UI scenes with:

* `Control` / `VBoxContainer` nodes
* simple theme or no theme

All UI built via code-created `.tscn`.

---

# **BOOST / AD SYSTEM (POST-MVP FEATURE SET)**

Claude should **not** implement ads.
Claude should generate logical **hooks** and **boost scaffolding**, not ad SDK code.

### **Boost Types**

Start with 3 base boosts:

1. **Power Boost** – increases projectile force by X%
2. **Explosive Boost** – projectile triggers area damage on impact
3. **Precision Boost** – extra-long trajectory preview

Boosts are selected **before** starting a level.

### **Ad Hooks**

User can:

* watch **1 ad for 1 boost**
* or **2 ads for all 3 boosts**

Boost availability must be **optional** — game always fully playable without them.

### **Boost Duration**

One level per boost.
Claude should make this configurable.

### **Boost API (Code Scaffold)**

Claude will generate:

* BoostManager.gd
* reusable functions:

  * `apply_boosts(active_boosts)`
  * `reset_boosts()`
  * parameters: `force_multiplier`, `explosion_radius`, `trajectory_length`, etc.

---

# **TECHNICAL REQUIREMENTS**

## **Script Conventions**

* Godot 4.5.1
* GDScript only
* Signals used for UI + events
* Use clean, self-contained scripts
* Use grouped nodes (e.g., `"targets"`, `"blocks"`)
* Avoid plugins
* No external servers

## **Technical Goals**

* Scenes and scripts generated entirely by Claude
* Test via Godot’s Play button
* Iterative error correction via CLI
* Assets imported manually, referenced by filename

---

# **MVP TASK ORDER (Claude should follow this)**

1. Create base project structure
2. Generate Level1 scene (root, slingshot, projectile, terrain)
3. Implement drag-to-aim + fire controls
4. Add block/target destructible physics
5. Add basic UI (shots counter + reset button)
6. Add LevelManager autoload
7. Add win/loss conditions
8. Add menu → Level1
9. Polish physics values
10. Export test build

---

# **POST-MVP FEATURES** (Claude should not prioritize until MVP works)

* Level select screen
* Multi-level pack
* Boost/ad system implementation
* Special projectile types (split shot, heavy shot, sticky shot)
* Dynamic obstacles (moving blocks, rotating platforms)
* Particle effects on break
* Sound effects
* Star rating per level
* Basic analytics (local only)

---

# **DELIVERABLES FROM CLAUDE**

Claude Code CLI must generate:

### **Files**

* `/scenes/Menu.tscn`
* `/scenes/Level1.tscn`
* `/scripts/Slingshot.gd`
* `/scripts/Projectile.gd`
* `/scripts/Block.gd`
* `/scripts/Target.gd`
* `/scripts/LevelManager.gd`
* `/scripts/BoostManager.gd` (placeholder for post-MVP)

### **Project Settings**

* InputMap (`drag_start`, `drag_update`, `drag_release`)
* Autoload (`LevelManager.gd`)

### **Documentation**

* A short `README.md` describing how to run the project and where main nodes/scripts are located.

---

If you want, I can also produce a **Claude-optimized prompt** version of this document (ultra-compact, laser-focused) designed to paste directly into Claude Code CLI to begin work immediately.
