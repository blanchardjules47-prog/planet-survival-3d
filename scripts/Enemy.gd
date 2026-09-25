extends Node3D

var player: CharacterBody3D
var resources: Array = []
var enemies: Array = []
var base_node: Node3D
var quest_tracker: QuestTracker
var canvas: CanvasLayer
var objective_label: Label
var inventory_label: Label
var status_label: Label

var collected = {
    "ore": 0,
    "battery": 0,
    "water": 0,
    "scrap": 0,
}

var total_needed = {
    "ore": 6,
    "battery": 3,
    "water": 2,
    "scrap": 4,
}

var player_health: float = 100.0
var player_max_health: float = 100.0
var story_phase = 0
var game_ended = false

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    build_environment()
    build_player()
    build_resources()
    build_base()
    build_enemies()
    build_hud()
    quest_tracker = QuestTracker.new()
    update_objective()

func _process(_delta):
    if game_ended:
        return

    handle_interaction()
    update_hud()
    update_objective()
    update_enemy_attacks()
    check_exit_condition()

func build_environment():
    var ground = MeshInstance3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(160, 160)
    ground.mesh = plane
    var ground_mat = StandardMaterial3D.new()
    ground_mat.albedo_color = Color(0.24, 0.38, 0.28)
    ground.material_override = ground_mat
    ground.position = Vector3(0, -1, 0)
    add_child(ground)

    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-30, 40, 0)
    sun.light_energy = 1.8
    add_child(sun)

    for i in range(40):
        var rock = MeshInstance3D.new()
        var cube = BoxMesh.new()
        cube.size = Vector3(randf_range(1.2, 3.7), randf_range(0.7, 2.8), randf_range(1.2, 3.7))
        rock.mesh = cube
        var rock_mat = StandardMaterial3D.new()
        rock_mat.albedo_color = Color(0.45, 0.44, 0.42)
        rock.material_override = rock_mat
        rock.position = Vector3(randf_range(-70, 70), 0.25, randf_range(-70, 70))
        add_child(rock)

func build_player():
    var player_node = CharacterBody3D.new()
    player_node.set_script(load("res://scripts/Player.gd"))
    player_node.name = "Player"
    player_node.position = Vector3(0, 1.8, 18)
    add_child(player_node)
    player = player_node

func build_resources():
    var resource_types = ["ore", "battery", "water", "scrap"]
    for i in range(18):
        var type = resource_types[i % resource_types.size()]
        var node = Node3D.new()
        node.set_script(load("res://scripts/ResourceNode.gd"))
        node.resource_name = type
        node.amount = 1 if type != "ore" else 2
        node.position = Vector3(randf_range(-35, 35), 0.5, randf_range(-35, 35))
        add_child(node)
        resources.append(node)

    var cluster_points = [
        Vector3(-12, 0.5, -15),
        Vector3(-18, 0.5, 8),
        Vector3(20, 0.5, -12),
        Vector3(0, 0.5, 26),
        Vector3(30, 0.5, 12),
        Vector3(-25, 0.5, 22),
    ]

    for idx in range(cluster_points.size()):
        var type = resource_types[idx % resource_types.size()]
        var node = Node3D.new()
        node.set_script(load("res://scripts/ResourceNode.gd"))
        node.resource_name = type
        node.amount = 1 if type != "ore" else 2
        node.position = cluster_points[idx]
        add_child(node)
        resources.append(node)

func build_base():
    base_node = Node3D.new()
    base_node.position = Vector3(24, 0, -24)
    add_child(base_node)

    var base_mesh = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = Vector3(5, 2.2, 5)
    base_mesh.mesh = box
    var base_mat = StandardMaterial3D.new()
    base_mat.albedo_color = Color(0.7, 0.7, 0.75)
    base_mesh.material_override = base_mat
    base_mesh.position = Vector3(0, 1.1, 0)
    base_node.add_child(base_mesh)

    var beacon = MeshInstance3D.new()
    var cylinder = CylinderMesh.new()
    cylinder.top_radius = 0.25
    cylinder.bottom_radius = 0.25
    cylinder.height = 3.5
    beacon.mesh = cylinder
    var beacon_mat = StandardMaterial3D.new()
    beacon_mat.albedo_color = Color(0.3, 0.9, 1.0)
    beacon.material_override = beacon_mat
    beacon.position = Vector3(0, 2.8, 0)
    base_node.add_child(beacon)

func build_enemies():
    for i in range(7):
        var enemy = CharacterBody3D.new()
        enemy.set_script(load("res://scripts/Enemy.gd"))
        enemy.name = "Enemy_%d" % i
        var position = Vector3(randf_range(-45, 45), 0.9, randf_range(-45, 45))
        while position.distance_to(base_node.global_position) < 12.0:
            position = Vector3(randf_range(-45, 45), 0.9, randf_range(-45, 45))
        enemy.position = position
        add_child(enemy)
        enemies.append(enemy)

func build_hud():
    canvas = CanvasLayer.new()
    add_child(canvas)

    var panel = PanelContainer.new()
    panel.anchor_left = 0.02
    panel.anchor_top = 0.02
    panel.anchor_right = 0.35
    panel.anchor_bottom = 0.18
    canvas.add_child(panel)

    var vbox = VBoxContainer.new()
    panel.add_child(vbox)

    objective_label = Label.new()
    objective_label.add_theme_font_size_override("font_size", 22)
    objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(objective_label)

    inventory_label = Label.new()
    inventory_label.add_theme_font_size_override("font_size", 18)
    vbox.add_child(inventory_label)

    status_label = Label.new()
    status_label.add_theme_font_size_override("font_size", 20)
    status_label.modulate = Color(1, 1, 0.4)
    vbox.add_child(status_label)

func update_hud():
    var inventory_text = "Inventory\n"
    for key in ["ore", "battery", "water", "scrap"]:
        inventory_text += "%s: %d / %d\n" % [key.capitalize(), collected[key], total_needed[key]]
    inventory_text += "Health: %d / %d\n" % [int(player_health), int(player_max_health)]
    inventory_label.text = inventory_text

    if player:
        var nearest = find_nearest_resource()
        if nearest != null and nearest.global_position.distance_to(player.global_position) < 3.0:
            status_label.text = "Press E to collect %s" % nearest.resource_name.capitalize()
        elif player_health <= 20.0:
            status_label.text = "You are badly wounded. Keep moving."
        else:
            status_label.text = "Explore the planet"

func update_objective():
    var text = quest_tracker.get_current_objective(collected, total_needed)
    objective_label.text = "Objective: %s" % text

func check_exit_condition():
    if game_ended:
        return

    var dist_to_base = player.global_position.distance_to(base_node.global_position)
    var ready = true
    for key in total_needed.keys():
        ready = ready and collected[key] >= total_needed[key]

    if ready and dist_to_base < 6.0:
        game_ended = true
        status_label.text = "Mission complete — the beacon is restored and the planet can be mapped."
        objective_label.text = "Objective: Escape the planet"

func handle_interaction():
    if not player:
        return

    var nearest = find_nearest_resource()
    if nearest == null:
        return

    var distance = nearest.global_position.distance_to(player.global_position)
    if distance <= 3.0 and Input.is_action_just_pressed("interact"):
        collected[nearest.resource_name] += nearest.amount
        nearest.collect()
        resources.erase(nearest)
        quest_tracker.register_pickup(nearest.resource_name)

func find_nearest_resource():
    var closest = null
    var closest_dist = INF
    for resource_node in resources:
        if resource_node == null or not is_instance_valid(resource_node):
            continue
        if resource_node.visible == false:
            continue
        var dist = resource_node.global_position.distance_to(player.global_position)
        if dist < closest_dist:
            closest_dist = dist
            closest = resource_node
    return closest

func update_enemy_attacks():
    for enemy in enemies:
        if enemy == null or not is_instance_valid(enemy):
            continue
        var dist = enemy.global_position.distance_to(player.global_position)
        if dist <= 1.8:
            if enemy.has_method("can_attack") and enemy.can_attack():
                damage_player(enemy.attack_damage)

func damage_player(amount: float):
    player_health = max(0.0, player_health - amount)
    status_label.text = "Alien hit! Health: %d" % int(player_health)

    if player_health <= 0.0:
        game_ended = true
        objective_label.text = "Objective: You were overrun by the creatures"
        status_label.text = "The creatures destroyed your crew. The mission failed."

func _input(event):
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
