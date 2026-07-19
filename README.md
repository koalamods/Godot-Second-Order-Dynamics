# Godot Second Order Dynamics 3D

A small Godot 4 addon for adding smooth, spring-like second order motion to `Node3D` objects.

Useful for:

- camera smoothing
- follow targets
- floating objects
- weapon sway
- soft tracking
- procedural spring motion

---

## Features

- Smooth 3D position following
- Resource-based settings for reusable parameters
- Supports `_process()` and `_physics_process()`
- Inspector preview graph
- Reset button for invalid or infinite transforms
---

## Installation

Copy the files into your Godot project:

```text
res://
  addons/
    second_order_dynamics/
      plugin.cfg
      plugin.gd
      second_order_inspector_plugin.gd
      second_order_preview_control.gd
      SecondOrderDynamics3D.gd
      SecondOrderController3D.gd
