tool
class_name SquareGridContainer
extends GridContainer


func _ready() -> void:
	get_tree().connect("tree_changed", self, "_on_tree_changed")


func _on_tree_changed() -> void:
	columns = max(1, ceil(sqrt(get_child_count())))
