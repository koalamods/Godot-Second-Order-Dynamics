# Godot Second Order Dynamics 3D

A small Godot 4 addon for adding smooth, spring-like second order motion to `Node3D` objects.

This addon is based on the second order dynamics system shown in  
![Giving Personality to Procedural Animations using Math](https://www.youtube.com/watch?v=KPoeNZZ6H4s) by ![@t3ssel8r](https://www.youtube.com/@t3ssel8r).

![Dynamics Showcase](showcase.gif)

---

## Features

- Smooth second order motion for `Node3D` objects
- Supports position, rotation, and scale smoothing
- Separate reusable `Resource` settings for position, rotation, and scale
- Supports `_process()` and `_physics_process()`
- Optional collision-aware movement with `CharacterBody3D`
- In-editor preview graph for tuning `f`, `z`, and `r`
- Reset button for invalid, infinite, or NaN transforms
- Inspector tooltips for easier setup

---

## Installation

Copy the addon folder into your Godot project:

```text
res://addons/second_order_dynamics/
```

Then enable the plugin:

```text
Project > Project Settings > Plugins > Second Order Dynamics
```
---

## Quick Setup

1. Add a `SecondOrderController3D` node to your 3D scene.
2. Assign an **Input Node**.
  - This node provides the target transform.
  - A `Marker3D` works well for this.
3. Set **Target Node Path**.
  - This is the node that will be modified by the second order system.
4. Choose a **Transform Channel**.
  - `POSITION`
  - `ROTATION`
  - `SCALE`
  - `POSITION_AND_ROTATION`
  - `POSITION_ROTATION_AND_SCALE`
5. Add one or more `SecondOrderDynamics3D` resources:
  - Position Dynamics
  - Rotation Dynamics
  - Scale Dynamics
6. Tweak the `f`, `z`, and `r` parameters.
7. Move the input node in the editor or during runtime to test behavior.

---

## Parameters

### `f` (Frequency)

Controls how quickly the output follows the input. The higher the value, the more faster and responsive the movement.

### `z` (Damping)

Controls how much the system overshoots or oscillates.
- `z < 1.0` makes the movement behave like a spring and overshoot.
- `z = 1.0` is close to critical damping.
- `z > 1.0` exaggerates the damping.

### `r` (Inital Response)

Controls how strongly the system reacts to input velocity.
- `r < 0.0` creates anticipation by moving the object away from the target before following it.
- `r = 0.0` creates a neutral reaction.
- `r > 0.0` creates an overshoot when reaching the target.

---

## Transform Channels

The `SecondOrderController3D` can apply second order smoothing to different parts of a `Node3D` transform.
  - `POSITION`
  - `ROTATION`
  - `SCALE`
  - `POSITION_AND_ROTATION`
  - `POSITION_ROTATION_AND_SCALE`

Each transform channel uses its own optional dynamics resource:
  - Position Dynamics
  - Rotation Dynamics
  - Scale Dynamics

This makes it possible to tune position, rotation, and scale independently.

---

## Update Modes

The `SecondOrderController3D` supports both `_process()` and `physics_process()`.

While the `_process()` mode is more generally used for general animation and visual smoothing, the `physics_process()` mode comes in handy for handling physics-related objects and provides support for collision-aware movement (see next chapter).

---

## Collision-Aware Movement
If the target should collide with `StaticBody3D` objects or other physics bodies, use:
- Position Apply Mode: `CHARACTER_BODY_MOVE_AND_SLIDE`
- Update Mode: `PHYSICS_PROCESS`

The target node must be a `CharacterBody3D` with a valid `CollisionShape3D`.

**Important**: 
Collision-aware movement currently applies only to position.
Rotation and scale are applied directly to the target transform.

---

## Reset Button

Since simulated second order systems can sometimes result in non-finite values (which can break the entire setup), the controller includes a reset button (`Reset Second Order Target Transform`).
