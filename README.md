extends CharacterBody3D

var player_ref: Node3D
var speed: float = 2.8
var attack_damage: float = 10.0
var attack_range: float = 1.8
var attack_interval: float = 1.0
var attack_timer: float = 0.0
var health: float = 30.0
var gravity: float = 18.0

func _ready():
    player_ref = get_parent().player
    var body = MeshInstance3D.new()
    var sphere = SphereMesh.new()
    sphere.radius = 0.8
    sphere.height = 1.8
    body.mesh = sphere
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.44, 0.82, 0.34)
    mat.emission_enabled = true
    mat.emission = Color(0.2, 0.8, 0.2)
    mat.emission_energy_multiplier = 0.9
    body.material_override = mat
    add_child(body)

func _physics_process(delta):
    if player_ref == null or not is_instance_valid(player_ref):
        return

    if attack_timer > 0.0:
        attack_timer -= delta

    if not is_on_floor():
        velocity.y -= gravity * delta

    var direction = player_ref.global_position - global_position
    var distance = direction.length()
    direction.y = 0
    if direction.length() > 0.001:
        direction = direction.normalized()

    if distance > attack_range:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0.0, speed)
        velocity.z = move_toward(velocity.z, 0.0, speed)

    move_and_slide()

func can_attack() -> bool:
    if attack_timer <= 0.0:
        attack_timer = attack_interval
        return true
    return false

func take_damage(amount: float):
    health -= amount
    if health <= 0.0:
        queue_free()
        if get_parent() and get_parent().has_method("remove_enemy"):
            get_parent().remove_enemy(self)
