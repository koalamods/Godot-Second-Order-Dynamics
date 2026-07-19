# Godot Second Order Dynamics 3D

A small Godot 4 addon for adding smooth, spring-like second order motion to `Node3D` objects. Ported from the [video](https://www.youtube.com/watch?v=KPoeNZZ6H4s) "Giving Personality to Procedural Animations using Math" by t3ssel8r.
![Dynamics Showcase](showcase.gif)

---

## Features

- Smooth 3D position following
- Resource-based settings for reusable parameters
- Supports `_process()` and `_physics_process()`
- In-Editor preview
- Reset button for invalid or infinite transforms
---

## Installation

Copy the addon folder into your Godot project:

```text
res://addons/second_order_dynamics/
```

Then enable the plugin:
Project > Project Settings > Plugins > Second Order Dynamics


---

## Quick Setup

1. Add a `SecondOrderController3D` to your 3D scene.
2. Add a `SecondOrderDynamics` resource to `Dynamics`.
3. Add the `Node3D` to `Target Node Path`. This node will get modified by the Second Order Dynamics.
4. Add another `Node3D` to `Input Node`. This node provides the position input for the dynamics system. It is advised to use a Marker3D.
5. Tweak the FZR - Parameters and test in the editor by moving the input node.
