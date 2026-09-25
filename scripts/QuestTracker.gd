extends RefCounted

var objective_order = [
    "Recover from the crash and locate the beacon core.",
    "Gather all required resources for the repair.",
    "Return to the base and restore the landing beacon.",
    "Find the ancient station beneath the crater and uncover the truth.",
    "Activate the relay and leave the planet."
]

var current_step = 0

func register_pickup(resource_name: String):
    if current_step == 0:
        current_step = 1

func get_current_objective(collected: Dictionary, required: Dictionary) -> String:
    var ready = true
    for key in required.keys():
        ready = ready and collected.get(key, 0) >= required[key]

    if current_step < 1:
        return objective_order[0]
    if not ready:
        return objective_order[1]
    if current_step == 1 and ready:
        current_step = 2
        return objective_order[2]
    if current_step >= 2:
        return objective_order[3] if current_step < 3 else objective_order[4]
    return objective_order[1]
