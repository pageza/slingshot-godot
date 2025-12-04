# Physics Tuning Quick Reference

## Current Default Values (Starting Point)

### Core Gameplay Loop
```
Player drags back → Calculates force → Spawns projectile → Projectile impacts → Damage applied → Objects destroyed
```

## Key Physics Values

### Launch Mechanics (Slingshot.gd)
```
max_drag_distance:    200.0 px    (how far back you can drag)
force_multiplier:     15.0        (drag distance → launch velocity)
min_launch_force:     50.0        (minimum to fire)
```
**Calculation**: `launch_velocity = drag_distance * force_multiplier`

Example: 150px drag × 15.0 = 2250 pixels/sec launch velocity

### Projectile Physics (Projectile.gd)
```
projectile_mass:      1.0 kg
bounce_factor:        0.3         (30% energy retained on bounce)
friction:             0.5
gravity_scale:        1.0         (uses global gravity)
base_damage:          10.0
velocity_damage:      0.5         (per pixel/sec of impact speed)
```
**Damage Calculation**: `total_damage = base_damage + (impact_velocity * velocity_damage_multiplier)`

Example: 10.0 + (300 pixels/sec × 0.5) = 160.0 total damage

### Block Physics (Block.gd)
```
max_health:           20.0        (typical block)
block_mass:           2.0 kg      (2× projectile mass)
friction:             0.8
bounce_factor:        0.1         (very little bounce)
damage_threshold:     5.0         (ignore small impacts)
break_velocity:       500.0 px/s  (instant break if moving this fast)
```

### Target Physics (Target.gd)
```
max_health:           30.0        (50% tougher than blocks)
target_mass:          3.0 kg      (3× projectile mass)
friction:             0.8
bounce_factor:        0.2
```

### Global Physics (project.godot)
```
default_gravity:      980.0 px/s²  (Earth-like gravity)
linear_damp:          0.1          (air resistance)
angular_damp:         1.0          (rotation slowdown)
```

## Physics Interactions

### Projectile vs Block
- Projectile (1.0 kg) hits Block (2.0 kg)
- At 300 px/s: Deals 160 damage → Destroys block (20 HP)
- At 100 px/s: Deals 60 damage → Damages block (survives with partial health)
- Block bounces away based on momentum transfer

### Projectile vs Target
- Projectile (1.0 kg) hits Target (3.0 kg)
- At 300 px/s: Deals 160 damage → Damages target (survives with 30-160 = negative, destroys)
- At 200 px/s: Deals 110 damage → Damages target (survives with partial health)
- Target harder to knock over due to 3× mass

### Typical Launch Arc
With force_multiplier = 15.0 and max_drag = 200px:
- Maximum velocity: 3000 px/s
- At 45° angle: ~1500 px/s horizontal, ~1500 px/s vertical
- Time to peak: ~1.5 seconds (gravity pulls down)
- Range: ~2300 pixels (~2 screen widths at 1080px)

## Balance Relationships

### Force Chain
```
Drag Distance → Launch Velocity → Impact Velocity → Damage → Destruction
    200px    →    3000 px/s    →   2500 px/s    → 1260 dmg → Anything dies
    100px    →    1500 px/s    →   1200 px/s    →  610 dmg → Targets/blocks die
    50px     →     750 px/s    →    600 px/s    →  310 dmg → Heavy damage
```

### Mass Relationships (affects knockback and momentum)
```
Projectile:  1.0 kg  (baseline)
Block:       2.0 kg  (2× harder to push)
Target:      3.0 kg  (3× harder to push)
```

### Health Relationships
```
Block:   20 HP  (baseline)
Target:  30 HP  (1.5× tougher)
```

To destroy a block at minimum, need: 20 HP / 10 base damage = MUST hit
To destroy a target at minimum, need: 30 HP / 10 base damage = MUST hit hard

### Bounce Energy Loss
```
Projectile bounce: 0.3  (loses 70% energy per bounce)
Block bounce:      0.1  (loses 90% energy per bounce)
Target bounce:     0.2  (loses 80% energy per bounce)
```

After 2 bounces, projectile retains: 0.3 × 0.3 = 9% of original velocity

## Recommended Tuning Order

When adjusting gameplay feel, tune in this order:

1. **Launch Feel** (Slingshot.gd)
   - Adjust force_multiplier for power level
   - Adjust max_drag_distance for control precision

2. **Arc/Trajectory** (Global Physics)
   - Adjust default_gravity for arc steepness
   - Or adjust projectile gravity_scale for individual control

3. **Impact Feel** (Projectile.gd)
   - Adjust projectile_mass for momentum
   - Adjust bounce_factor for rebound behavior

4. **Destruction Balance** (Block.gd, Target.gd)
   - Adjust max_health for difficulty
   - Adjust block_mass for toppling behavior
   - Adjust damage_threshold to ignore weak hits

5. **Fine-Tuning**
   - Friction for sliding behavior
   - Damping for speed reduction
   - Thresholds for edge cases

## Test Scenarios

### Scenario 1: Direct Hit Test
- Drag back 150px at horizontal angle
- Should destroy 1 block with direct hit
- Should damage target but not destroy (requires 2+ hits)

### Scenario 2: Arc Shot Test
- Drag back 180px at 45° angle upward
- Should arc over first structure
- Should hit second structure from above

### Scenario 3: Ricochet Test
- Drag back 100px at shallow angle
- Projectile should bounce once
- Second bounce should be much weaker (energy loss)

### Scenario 4: Toppling Test
- Hit base block in pyramid structure
- Block should be destroyed
- Upper blocks should topple realistically
- Target at top should fall

### Scenario 5: Weak Hit Test
- Drag back only 30px (below min_launch_force = 50)
- Should NOT launch projectile
- Visual feedback should clear

## Debug Console Messages

Expected console output during gameplay:
```
Drag started at: (200, 1600)
Projectile launched with velocity: (1800, -500) (magnitude: 1867.56)
Projectile spawned at: (200, 1580)
Projectile hit: Block1 with velocity: 1650.34 damage: 835.17
Block took damage: 835.17 | Remaining health: -815.17
Block destroyed at: (740, 1600)
TARGET took damage: 456.78 | Remaining health: -426.78
TARGET DESTROYED at: (800, 1410)
Target destroyed! Progress: 1/2
... (after second target destroyed) ...
Target destroyed! Progress: 2/2
=== LEVEL COMPLETE! ALL TARGETS DESTROYED! ===
```

## Performance Metrics

Expected performance characteristics:
- FPS: 60 fps (VSync enabled)
- Physics updates: 60 Hz
- Projectile spawn time: <1ms
- Block destruction time: <2ms
- Max concurrent projectiles: 10 (before cleanup)
- Scene node count: ~50 nodes (TestLevel)

## Common Issues & Fixes

### Issue: Blocks fly too far when hit
**Cause**: Too much momentum transfer
**Fix**: Increase block_mass (2.0 → 3.5) or decrease projectile_mass (1.0 → 0.7)

### Issue: Projectiles bounce too much
**Cause**: High bounce_factor
**Fix**: Decrease projectile bounce_factor (0.3 → 0.15)

### Issue: Can't destroy targets
**Cause**: Not enough damage
**Fix**: Increase force_multiplier (15 → 20) or increase base_damage (10 → 15)

### Issue: Trajectory preview doesn't match actual path
**Cause**: Different initial conditions or simulation mismatch
**Fix**: Check projectile_spawn_offset matches preview calculation
**Check**: Verify gravity_scale is 1.0 (or adjust preview to match)

### Issue: Structures collapse on their own
**Cause**: Blocks too light or friction too low
**Fix**: Increase block_mass (2.0 → 3.0) and increase friction (0.8 → 0.95)

### Issue: Projectiles stick in air
**Cause**: Too much linear_damp
**Fix**: Decrease default_linear_damp (0.1 → 0.05) in project settings

## Optimal "Feel" Targets

For satisfying gameplay, aim for:
- Launch feels powerful but controllable
- Trajectory is predictable (preview matches reality)
- Direct hits destroy 1-2 blocks
- Targets require 2-3 hits or one perfect shot
- Blocks topple realistically when base is removed
- Projectiles don't bounce endlessly (2-3 bounces max)
- Clear visual/audio feedback on impact
- Victory feels earned but achievable

## File Paths for Quick Access

Edit these files to tune values:
- `/home/zach/Projects/Godot/slingshot/scripts/Slingshot.gd` (launch mechanics)
- `/home/zach/Projects/Godot/slingshot/scripts/Projectile.gd` (projectile physics)
- `/home/zach/Projects/Godot/slingshot/scripts/Block.gd` (block behavior)
- `/home/zach/Projects/Godot/slingshot/scripts/Target.gd` (target behavior)
- `/home/zach/Projects/Godot/slingshot/project.godot` (global physics)

Or adjust in Godot Editor:
- Open scene: `/home/zach/Projects/Godot/slingshot/scenes/TestLevel.tscn`
- Select nodes and adjust @export parameters in Inspector panel
