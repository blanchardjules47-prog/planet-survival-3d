extends Node3D

@export var resource_name: String = "ore"
@export var amount: int = 1
@export var spin_speed: float = 1.2

var mesh_instance: MeshInstance3D
var original_y: float

func _ready():
    original_y = global_position.y
    mesh_instance = MeshInstance3D.new()
    var sphere = SphereMesh.new()
    sphere.radius = 0.5
    sphere.height = 1.0
    mesh_instance.mesh = sphere
    var material = StandardMaterial3D.new()
    material.albedo_color = get_color_for(resource_name)
    material.emission_enabled = true
    material.emission = get_color_for(resource_name)
    material.emission_energy_multiplier = 1.8
    mesh_instance.material_override = material
    add_child(mesh_instance)

func _process(delta):
    if mesh_instance == null:
        return
    rotation.y += delta * spin_speed
    position.y = original_y + sin(Time.get_ticks_msec() * 0.0015 + position.x) * 0.25

func collect():
    visible = false
    queue_free()

func get_color_for(type_name: String) -> Color:
    match type_name:
        "ore":
            return Color(0.68, 0.82, 0.25)
        "battery":
            return Color(0.95, 0.88, 0.26)
        "water":
            return Color(0.24, 0.84, 1.0)
        "scrap":
            return Color(0.76, 0.72, 0.72)
        _:
            return Color(1, 1, 1)
