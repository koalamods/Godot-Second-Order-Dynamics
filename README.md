# Godot Second Order Dynamics 3D

A small Godot 4 addon for adding smooth, spring-like second order motion to `Node3D` objects.

Useful for:

- camera smoothing
- follow targets
- floating objects
- weapon sway
- soft tracking
- procedural spring motion

The system is controlled by three main parameters:

- `f`: frequency / response speed
- `z`: damping
- `r`: initial response / anticipation

It also includes an optional Inspector preview graph to make tuning easier.

---

## Features

- Smooth 3D position following
- Resource-based settings
- Reusable parameter presets
- Supports `_process()` and `_physics_process()`
- Optional editor updates with `@tool`
- Inspector preview graph
- Reset button for invalid or infinite transforms
- Inspector tooltips for easier setup

---

## Installation

Copy the files into your Godot project:

```text
res://
  SecondOrderDynamics3D.gd
  SecondOrderController3D.gd

  addons/
    second_order_preview/
      plugin.cfg
      plugin.gd
      second_order_inspector_plugin.gd
      second_order_preview_control.gd
