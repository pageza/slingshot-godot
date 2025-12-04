# SLINGSHOT GAME PROJECT - CLAUDE AGENT ROUTING GUIDE

## Project Overview

This is a 2D physics-based slingshot game (similar to Angry Birds mechanics) built with **Godot 4.5.1** targeting **iOS and Android** platforms. The project uses a **single codebase** for both platforms.

See `design_document.md` for complete game specifications.

---

## Development Environment

### Installed Tools

- **Godot Engine**: 4.5.1 stable (installed globally at `/usr/local/bin/godot`)
  - Command: `godot` or `godot --version`
  - Note: Project designed for 4.6, but using 4.5.1 (latest stable). Minimal differences, agent can adapt 4.6 templates to 4.5.1.

- **Java JDK**: OpenJDK 17.0.17 (required for Android development)
  - Command: `java --version` or `javac --version`
  - Location: `/usr/lib/jvm/java-17-openjdk-amd64/`

- **Android Studio**: 2024.2.1.12 (installed at `/opt/android-studio/`)
  - Command: `android-studio`
  - **First Launch Setup Required**: Android SDK and emulator must be configured through GUI on first run
  - SDK will be installed to: `~/Android/Sdk/` (default)
  - Emulator setup: Required for testing Android builds

### Android SDK Setup (First Time)

When Android Studio is launched for the first time:
1. Complete the setup wizard
2. Install Android SDK (API level 21+ minimum, recommend latest stable)
3. Install Android SDK Build-Tools
4. Install Android Emulator
5. Create at least one AVD (Android Virtual Device) for testing
  - Recommended: Pixel 4 or Pixel 5 with Android 13+

### iOS/macOS Development

- User will handle iOS/macOS setup on their MacBook
- Godot project will export from Linux for Android, from macOS for iOS
- Single codebase approach: All game logic is platform-independent

---

## AUTOMATIC AGENT ROUTING RULES

The main Claude Code agent should automatically delegate to specialized agents based on task context. **Do NOT require manual agent specification.**

---

### 🎮 AGENT: `godot-46-core-dev`

**Route to this agent when:**

1. **Core Game Mechanics Implementation**
   - Keywords: "implement slingshot", "create projectile", "add physics", "destructible blocks", "RigidBody2D", "StaticBody2D", "collision"
   - File types: `.gd` scripts (Slingshot.gd, Projectile.gd, Block.gd, Target.gd, LevelManager.gd)

2. **Scene File Generation**
   - Keywords: "create scene", "generate level", ".tscn", "node hierarchy", "scene structure"
   - Tasks: Level1.tscn, Menu.tscn, HUD.tscn, etc.

3. **Godot Project Configuration**
   - Keywords: "autoload", "input map", "physics layers", "project settings", "project.godot"

4. **GDScript Core Logic**
   - Any request to write/modify core gameplay scripts
   - Signal systems, state management, win/loss conditions

**Example triggers:**
- "Create the slingshot aiming system"
- "Implement block destruction physics"
- "Set up the level manager"
- "Generate Level1.tscn file"

---

### 📱 AGENT: `mobile-touch-ui-specialist`

**Route to this agent when:**

1. **Touch Input Implementation**
   - Keywords: "drag to aim", "touch controls", "gesture", "swipe", "InputEventScreenTouch", "InputEventScreenDrag"

2. **Trajectory Preview System**
   - Keywords: "trajectory line", "aiming guide", "preview arc", "show path", "Line2D", "draw"

3. **UI Scene Creation**
   - Keywords: "create menu", "make HUD", "button", "win screen", "popup", "Control nodes", "CanvasLayer"
   - Files: Menu.tscn, HUD.tscn, WinPopup.tscn, LosePopup.tscn

4. **Mobile Optimization**
   - Keywords: "touch target size", "safe areas", "notch support", "responsive layout", "anchor presets"

5. **Visual Feedback**
   - Keywords: "drag feedback", "button animation", "visual response", "tween"

**Example triggers:**
- "Implement drag-to-aim controls"
- "Create trajectory preview"
- "Design main menu"
- "Add visual feedback for dragging"

---

### 🍎 AGENT: `apple-platform-deployment`

**Route to this agent when:**

1. **iOS Export Setup**
   - Keywords: "export to iOS", "iPhone", "iPad", "App Store", "Xcode", "provisioning profile", "code signing"

2. **iOS-Specific Features**
   - Keywords: "TestFlight", "Game Center", "iOS notifications", "in-app purchases", "entitlements"

3. **iOS Asset Preparation**
   - Keywords: "app icon", "launch screen", "iOS screenshots", "asset catalog"

4. **iOS Performance Issues**
   - Keywords: "laggy on iPhone", "iOS performance", "Metal renderer", "optimize for iOS"

5. **App Store Submission**
   - Keywords: "submit to App Store", "App Store Connect", "review process", "rejection", "privacy policy"

**Example triggers:**
- "How do I export for iOS?"
- "Set up iOS build"
- "Configure for App Store"
- "Game runs slow on iPhone"

---

### 🤖 AGENT: `android-deployment-specialist`

**Route to this agent when:**

1. **Android Export Setup**
   - Keywords: "export to Android", "build APK", "AAB", "Google Play", "Gradle", "keystore", "signing"

2. **Android-Specific Features**
   - Keywords: "Play Services", "Android permissions", "AndroidManifest", "Gradle configuration"

3. **Android Asset Preparation**
   - Keywords: "Android icon", "adaptive icon", "feature graphic", "Play Store assets"

4. **Android Performance Issues**
   - Keywords: "laggy on Android", "device compatibility", "Vulkan", "OpenGL", "APK size"

5. **Play Store Submission**
   - Keywords: "Play Store", "Play Console", "content rating", "data safety", "release track"

**Example triggers:**
- "How do I build an APK?"
- "Set up Android export"
- "Prepare for Google Play"
- "APK is too large"

---

### ⚖️ AGENT: `physics-balance-specialist`

**Route to this agent when:**

1. **Physics Tuning Requests**
   - Keywords: "tune physics", "adjust force", "change gravity", "bounce", "friction", "mass", "force_multiplier"

2. **Game Feel Issues**
   - Keywords: "doesn't feel right", "too floaty", "too heavy", "not satisfying", "game feel", "juice"

3. **Difficulty Balancing**
   - Keywords: "too hard", "too easy", "impossible", "difficulty curve", "progression"

4. **Damage/Health System**
   - Keywords: "blocks too strong", "projectile weak", "one-hit destroy", "health values", "damage calculation"

5. **Boost System Balancing**
   - Keywords: "power boost weak", "explosive boost overpowered", "balance boosts", "boost multipliers"

**Example triggers:**
- "Slingshot feels too weak"
- "Blocks falling over too easily"
- "Level 3 is too hard"
- "Tune physics to feel better"
- "How strong should power boost be?"

---

### 🏗️ AGENT: `level-design-specialist`

**Route to this agent when:**

1. **Level Creation Requests**
   - Keywords: "create Level X", "design new level", "make 10 levels", "level layout"

2. **Level Structure Modifications**
   - Keywords: "make level harder", "rearrange blocks", "protect target", "tower", "pyramid", "bridge", "fortress"

3. **Level Difficulty Adjustments**
   - Keywords: "level feels too easy", "level progression", "difficulty curve" (when related to level design, not physics)

4. **Level Content Planning**
   - Keywords: "plan next 5 levels", "tutorial levels", "challenge levels", "level sequence"

5. **Structural Design Questions**
   - Keywords: "how to protect target?", "what structure works?", "architectural patterns"

**Example triggers:**
- "Create Level 5"
- "Design next 3 levels"
- "Level layout is boring"
- "Need a hard challenge level"
- "Plan first 10 levels"

---

### 💰 AGENT: `monetization-boost-architect`

**Route to this agent when:**

1. **Boost System Implementation**
   - Keywords: "implement boosts", "add power boost", "create boost system", "BoostManager"

2. **Ad Integration Preparation**
   - Keywords: "prepare for ads", "ad hooks", "rewarded video", "AdManager", "monetization"

3. **Monetization Strategy**
   - Keywords: "how to monetize?", "is this ethical?", "dark patterns", "player-friendly"

4. **Boost UI Implementation**
   - Keywords: "boost selection screen", "show active boosts", "ad prompt" (when related to monetization)

5. **Economy Balancing**
   - Keywords: "boost pricing", "ad frequency", "boost value", "cooldowns", "economy"

**Example triggers:**
- "Add boost system"
- "How do I set up ad integration?"
- "Create BoostManager script"
- "Design boost selection menu"
- "Is this monetization ethical?"

---

## MULTI-AGENT SCENARIOS

Some tasks require **multiple agents working in sequence or parallel**:

### Example: "Implement drag-to-aim with physics tuning"
→ Route to: `mobile-touch-ui-specialist` (input) **+** `physics-balance-specialist` (force values)

### Example: "Create Level 5 and balance it"
→ Route to: `level-design-specialist` (layout) **+** `physics-balance-specialist` (difficulty)

### Example: "Set up iOS export with optimized settings"
→ Route to: `apple-platform-deployment` (export) **+** `godot-46-core-dev` (project settings)

---

## FALLBACK DECISION TREE

**If task is ambiguous, follow this priority:**

1. **Core Godot/GDScript work?** → `godot-46-core-dev`
2. **UI/touch/controls?** → `mobile-touch-ui-specialist`
3. **Platform export/deployment?** → `apple-platform-deployment` or `android-deployment-specialist`
4. **Balance/feel/physics tuning?** → `physics-balance-specialist`
5. **Level content creation?** → `level-design-specialist`
6. **Monetization/boosts?** → `monetization-boost-architect`

---

## WHEN **NOT** TO USE AGENTS

Handle directly (main agent) when:
- Simple questions (no implementation needed)
- File reading/exploration
- General project management
- Documentation requests (unless asking how to use agents themselves)

---

## PROACTIVE AGENT SUGGESTIONS

Main agent should **proactively suggest** agents when:

1. **User completes MVP core gameplay** → Suggest deployment agents
2. **User mentions device testing** → Route to appropriate deployment agent
3. **User reports "feels wrong" during gameplay** → Route to `physics-balance-specialist`
4. **User asks "what's next?"** after core features → Suggest `level-design-specialist`
5. **User implements all basic features** → Suggest `monetization-boost-architect` for post-MVP

---

## ROUTING CONFIDENCE LEVELS

**HIGH CONFIDENCE** (always route):
- User explicitly mentions agent domain
- Task clearly falls into single agent expertise
- User is implementing a feature agent owns

**MEDIUM CONFIDENCE** (suggest or ask):
- Task spans multiple domains
- Unclear if implementation or just information
- Simple task that might not need specialist

**LOW CONFIDENCE** (handle directly):
- Reading/researching code
- Answering questions without implementation
- Very simple edits (typos, comments)

---

## PROJECT-SPECIFIC NOTES

### Godot Version Compatibility
- Design doc specifies **Godot 4.6**, but using **4.5.1 stable** (latest available)
- Agents can adapt 4.6 templates/code to 4.5.1 (minimal syntax differences)
- When 4.6 stable releases, upgrade path is straightforward

### Cross-Platform Strategy
- **Single codebase** for iOS + Android
- All game logic is platform-independent
- Platform-specific code only in export settings
- UI must be tested on both phone and tablet screen sizes

### MVP vs Post-MVP
- **MVP Focus**: Core gameplay, basic UI, level loading, win/loss
- **Post-MVP**: Boosts, ads, special projectiles, effects, sound
- Agents should prioritize MVP unless user explicitly requests post-MVP features

---

## IMPORTANT REMINDERS

- **NO SNAP PACKAGES**: User explicitly prohibits snap. Use direct downloads or apt.
- **Sudo password**: `tybalt` (when needed for system operations)
- **Project Structure**: All game files in `/home/zach/Projects/Godot/slingshot/`
- **Template Assets**: Reference templates located at `/home/zach/Projects/Godot/godot_assets/`
- **Testing**: Godot editor can run game directly (no build needed for testing)
- **Android SDK**: Must configure via Android Studio GUI first time

---

## Quick Reference Commands

```bash
# Godot
godot                          # Launch Godot editor
godot --version               # Check version
godot project.godot           # Open specific project

# Java
java --version                # Check Java version
javac --version              # Check compiler version

# Android Studio
android-studio                # Launch Android Studio
```

---

This routing guide ensures efficient task delegation to specialized agents without requiring manual specification. The main agent should intelligently detect context and route appropriately.
