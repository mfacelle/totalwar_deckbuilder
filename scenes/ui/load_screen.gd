extends CanvasLayer

signal loading_screen_ready()

@export var anim_player: AnimationPlayer

func _ready() -> void:
    await anim_player.animation_finished
    loading_screen_ready.emit()


func _on_progress_changed(_new_value: float) -> void:
    pass


func _on_load_finished() -> void:
    anim_player.play_backwards("transition")
    await anim_player.animation_finished
    queue_free()
