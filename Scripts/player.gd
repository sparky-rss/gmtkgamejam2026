extends AnimatedSprite2D

func _ready() -> void:
	idle()

func _process(_delta: float) -> void:
	var idle_variant : int
	idle_variant = randi_range(0,400)
	if idle_variant == 0 and self.animation == "idle" and self.frame == 0 and !Globals.end_of_day:
		self.play("idle_variant", 1.0)
	if self.animation == "idle_variant" and self.frame == 5 and !Globals.end_of_day:
		idle()
	if self.animation == "fall_asleep" and self.frame == 1 and Globals.end_of_day:
		if !flip_h:
			self.play("sleep", 0.5)
		else:
			self.play("sleep_inverse", 0.5)

func run() -> void:
	self.play("run", 1.0)

func idle() -> void:
	self.play("idle", 1.0)

func fall_asleep() -> void:
	self.play("fall_asleep", 1.0)

func face(facing : String) -> void:
	if facing == "left":
		flip_h = true
	elif facing == "right":
		flip_h = false
