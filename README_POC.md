# Slingshot Physics POC - Setup and Tuning Guide

## Project Overview
A proof-of-concept slingshot physics game built in Godot 4.5.1. Test drag-to-launch mechanics, destructible blocks, and target-based win conditions.

## Quick Start
1. Open Godot 4.5.1
2. Import project: `/home/zach/Projects/Godot/slingshot/project.godot`
3. The main scene (`scenes/TestLevel.tscn`) should load automatically
4. Press F5 to play

## How to Play
1. Click near the slingshot (bottom-left) and drag backward
2. A yellow line shows your drag direction
3. A cyan dotted line shows the predicted trajectory
4. Release to launch the projectile
5. Destroy all RED targets (with crosshairs) to win

## Project Structure
```
/home/zach/Projects/Godot/slingshot/
├── project.godot              # Main project configuration
├── scenes/
│   ├── TestLevel.tscn         # Playable test level
│   └── Projectile.tscn        # Projectile scene template
└── scripts/
    ├── Slingshot.gd           # Drag-to-launch mechanics
    ├── Projectile.gd          # Physics projectile behavior
    ├── Block.gd               # Destructible block logic
    ├── Target.gd              # Special target objects
    └── GameManager.gd         # Win condition tracking
```

## Physics Tuning Guide

### Slingshot Parameters (scripts/Slingshot.gd)
Open TestLevel.tscn, select the "Slingshot" node, adjust in Inspector:

- **max_drag_distance**: 200.0
  - Maximum pixels player can drag back
  - INCREASE: Allows more dramatic aiming (but can feel imprecise)
  - DECREASE: Tighter control, less power variance

- **force_multiplier**: 15.0
  - Converts drag distance to launch velocity
  - INCREASE: More powerful shots (projectiles fly farther/faster)
  - DECREASE: Weaker shots (may not reach targets)
  - RECOMMENDED RANGE: 10.0 - 25.0

- **min_launch_force**: 50.0
  - Minimum force required to spawn projectile
  - INCREASE: Prevents accidental weak launches
  - DECREASE: Allows gentle taps

- **show_trajectory**: true
  - Toggle trajectory preview line
  - Set to false for more challenge

- **trajectory_points**: 30
  - Number of dots in prediction arc
  - INCREASE: More accurate but slower
  - DECREASE: Faster but less accurate

### Projectile Parameters (scripts/Projectile.gd)
Select any spawned projectile in scene tree during play, or edit Projectile.tscn:

- **projectile_mass**: 1.0
  - Mass affects momentum and impact force
  - INCREASE: Heavier hits, less affected by collisions, harder to stop
  - DECREASE: Lighter, more bouncy, easier to deflect
  - RECOMMENDED RANGE: 0.5 - 3.0

- **bounce_factor**: 0.3
  - Bounciness (0 = no bounce, 1 = perfect bounce)
  - INCREASE: More bouncy (fun but chaotic)
  - DECREASE: Sticks more on impact
  - RECOMMENDED RANGE: 0.1 - 0.5

- **gravity_scale_value**: 1.0
  - Multiplier for gravity effect
  - INCREASE: Faster fall (more arc in trajectory)
  - DECREASE: Floatier projectiles
  - RECOMMENDED RANGE: 0.8 - 1.5

- **base_damage**: 10.0
  - Base damage on any impact
  - INCREASE: Blocks break easier
  - DECREASE: Requires more precise hits
  - RECOMMENDED RANGE: 5.0 - 20.0

- **velocity_damage_multiplier**: 0.5
  - Additional damage based on impact speed
  - INCREASE: Rewards faster shots
  - DECREASE: Makes damage more consistent regardless of speed

- **max_lifetime**: 10.0
  - Auto-destroy after this many seconds
  - INCREASE: Longer lifetime (projectiles persist)
  - DECREASE: Faster cleanup (better performance)

- **sleep_timer_threshold**: 2.0
  - Destroy if stopped moving for this long
  - INCREASE: Projectiles stay longer after stopping
  - DECREASE: Faster cleanup

### Block Parameters (scripts/Block.gd)
Select blocks in TestLevel scene, adjust in Inspector:

- **max_health**: 20.0
  - Total health before destruction
  - INCREASE: Tougher blocks (requires multiple hits)
  - DECREASE: Easier to destroy
  - RECOMMENDED RANGE: 10.0 - 50.0

- **block_mass**: 2.0
  - Mass affects how easily blocks topple
  - INCREASE: Heavier, harder to knock over
  - DECREASE: Lighter, topples easily
  - RECOMMENDED RANGE: 0.5 - 5.0

- **friction**: 0.8
  - Surface friction
  - INCREASE: Blocks slide less (more stable stacks)
  - DECREASE: Blocks slide more (easier to topple)

- **bounce_factor**: 0.1
  - How bouncy blocks are
  - INCREASE: More bouncy collisions
  - DECREASE: More dampened impacts

- **block_size**: Vector2(50, 50)
  - Physical size of block
  - Adjust for variety in level design

- **damage_threshold**: 5.0
  - Minimum damage to register a hit
  - INCREASE: Ignores light taps
  - DECREASE: Sensitive to any impact

- **break_velocity_threshold**: 500.0
  - Velocity that causes instant destruction
  - INCREASE: Blocks survive higher speeds
  - DECREASE: Blocks break easier when moving fast

### Target Parameters (scripts/Target.gd)
Select targets in TestLevel scene:

- **max_health**: 30.0
  - Targets are tougher than regular blocks
  - INCREASE: Harder to destroy (more challenging)
  - DECREASE: Easier win condition
  - RECOMMENDED RANGE: 20.0 - 60.0

- **target_mass**: 3.0
  - Heavier than blocks by default
  - INCREASE: More stable targets
  - DECREASE: Easier to knock over

### Global Physics (project.godot)
Edit in Project Settings > Physics > 2D:

- **default_gravity**: 980.0
  - Global gravity value (pixels/s²)
  - INCREASE: Faster falling (more arc)
  - DECREASE: Floatier physics
  - REFERENCE: 980 ≈ Earth gravity in cm/s²

- **default_linear_damp**: 0.1
  - Air resistance/drag
  - INCREASE: Objects slow down faster
  - DECREASE: Objects maintain velocity longer

- **default_angular_damp**: 1.0
  - Rotational drag
  - INCREASE: Objects stop spinning faster
  - DECREASE: More spin persistence

## Common Tuning Scenarios

### "Projectiles are too weak"
- INCREASE: force_multiplier (15.0 → 20.0)
- INCREASE: base_damage (10.0 → 15.0)
- INCREASE: projectile_mass (1.0 → 1.5)

### "Projectiles are too strong"
- DECREASE: force_multiplier (15.0 → 10.0)
- DECREASE: base_damage (10.0 → 7.0)
- INCREASE: block_mass (2.0 → 3.0)

### "Blocks fall over too easily"
- INCREASE: block_mass (2.0 → 3.5)
- INCREASE: friction (0.8 → 0.9)
- DECREASE: bounce_factor (0.1 → 0.05)

### "Trajectory is too steep/floaty"
- Steep: INCREASE default_gravity (980 → 1200)
- Floaty: DECREASE default_gravity (980 → 800)
- Or adjust gravity_scale_value on projectile

### "Hard to aim precisely"
- DECREASE: max_drag_distance (200 → 150)
- INCREASE: trajectory_points (30 → 50)
- DECREASE: force_multiplier (15.0 → 12.0)

### "Game is too easy/hard"
Easy:
- INCREASE: target max_health (30 → 50)
- INCREASE: target_mass (3.0 → 4.5)
- DECREASE: projectile base_damage (10.0 → 7.0)

Hard:
- DECREASE: target max_health (30 → 20)
- INCREASE: projectile base_damage (10.0 → 15.0)
- INCREASE: force_multiplier (15.0 → 18.0)

## Testing Checklist

1. Launch projectiles at different angles
2. Verify blocks take damage and darken when hit
3. Verify blocks are destroyed when health reaches 0
4. Test that targets (red with crosshairs) register as destroyed
5. Confirm victory message appears when all targets destroyed
6. Check console output (F1 or View > Output) for debug messages
7. Test trajectory preview accuracy
8. Verify projectiles auto-cleanup after stopping or timeout

## Known Limitations (POC)

- No art assets (colored shapes only)
- No sound effects
- No particle effects (basic debris only)
- No UI polish
- Unlimited projectiles
- Single level only
- Mouse input only (no mobile touch optimization)
- No restart button (press F5)

## Next Steps for Full Game

1. Add projectile limit (3-5 shots per level)
2. Create level progression system
3. Add sound effects (launch, impact, destruction)
4. Implement particle effects
5. Create sprite art for all objects
6. Add mobile touch controls
7. Build level editor or JSON level loader
8. Add score/star rating system
9. Implement power-ups or special projectiles
10. Add menu system

## Troubleshooting

### "Projectiles pass through blocks"
- Enable Continuous Collision Detection (CCD) on projectiles
- Reduce physics timestep in Project Settings
- Check collision layers are set correctly

### "Blocks don't take damage"
- Verify Block.gd has `take_damage()` method
- Check console for "Block took damage" messages
- Verify projectile collision_mask includes layer 2 (blocks)

### "Targets don't register as destroyed"
- Check targets are in "targets" group
- Verify Target.gd emits `target_destroyed` signal
- Check GameManager is in the scene

### "Slingshot doesn't respond to clicks"
- Click very close to slingshot base (within 100 pixels)
- Check Input Map has "drag_start" and "drag_release" actions
- Verify Slingshot.gd script is attached

### "Victory message doesn't appear"
- Check GameManager node exists in TestLevel
- Verify all targets have Target.gd script
- Check console for target destruction messages

## Performance Notes

For optimal performance on mobile (future):
- Limit simultaneous projectiles (1-2 active max)
- Keep block count under 20 per level
- Use simple collision shapes (circles, rectangles)
- Enable object pooling for projectiles
- Reduce trajectory_points for preview (15-20 instead of 30)

## File Locations

- Project root: `/home/zach/Projects/Godot/slingshot/`
- Main scene: `/home/zach/Projects/Godot/slingshot/scenes/TestLevel.tscn`
- Scripts: `/home/zach/Projects/Godot/slingshot/scripts/`

## Contact & Credits

Built with Godot 4.5.1 stable
Physics POC created: 2025-12-04
