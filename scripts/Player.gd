extends CharacterBody3D

@export var speed: float = 6.5
@export var sprint_speed: float = 10.5
@export var jump_velocity: float = 5.4
@export var gravity: float = 18.0
@export var mouse_sensitivity: float = 0.0025

var camera_pivot: Node3D
var camera: Camera3D

func _ready():
    camera_pivot = Node3D.new()
    camera_pivot.position = Vector3(0, 1.7, 0)
    add_child(camera_pivot)

    camera = Camera3D.new()
    camera.current = true
    camera_pivot.add_child(camera)

func _input(event):
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
        camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-85), deg_to_rad(85))

    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
    if not is_on_floor():
        velocity.y -= gravity * delta

    var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    var desired_speed = sprint_speed if Input.is_action_pressed("sprint") else speed
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    if direction:
        velocity.x = direction.x * desired_speed
        velocity.z = direction.z * desired_speed
    else:
        velocity.x = move_toward(velocity.x, 0, desired_speed)
        velocity.z = move_toward(velocity.z, 0, desired_speed)

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    move_and_slide()
