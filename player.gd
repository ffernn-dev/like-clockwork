extends CharacterBody2D

class_name Player2D

@export var README: String = "IMPORTANT: MAKE SURE TO ASSIGN 'left' 'right' 'jump' 'dash' 'up' 'down' in the project settings input map."

#INFO READEME 
#IMPORTANT: MAKE SURE TO ASSIGN 'left' 'right' 'jump' 'dash' 'up' 'down' in the project settings input map. THIS IS REQUIRED

@export var PlayerSprite: AnimatedSprite2D
@export_category("Colliders")
@export var IdleCollider: CollisionShape2D
@export var RunCollider: CollisionShape2D
@export var JumpCollider: CollisionShape2D
@export var DeathCollider: CollisionShape2D

#INFO HORIZONTAL MOVEMENT 
@export_category("L/R Movement")
@export_range(50, 500) var maxSpeed: float = 200.0
@export_range(0, 4) var timeToReachMaxSpeed: float = 0.2
@export_range(0, 4) var timeToReachZeroSpeed: float = 0.2
@export var directionalSnap: bool = false
@export var runningModifier: bool = false

#INFO JUMPING 
@export_category("Jumping and Gravity")
@export_range(0, 20) var jumpHeight: float = 2.0
@export_range(0, 4) var jumps: int = 1
@export_range(0, 100) var gravityScale: float = 20.0
@export_range(0, 1000) var terminalVelocity: float = 500.0
@export_range(0.5, 3) var descendingGravityFactor: float = 1.3
@export var shortHopAkaVariableJumpHeight: bool = true
@export_range(0, 0.5) var coyoteTime: float = 0.2
@export_range(0, 0.5) var jumpBuffering: float = 0.2

@export_category("Dashing")
@export_enum("None", "Horizontal", "Vertical", "Four Way", "Eight Way") var dashType: int
@export_range(0, 10) var dashes: int = 1
@export var dashCancel: bool = true
@export_range(1.5, 4) var dashLength: float = 2.5

@export_category("Corner Cutting/Jump Correct")
@export var cornerCutting: bool = false
@export_range(1, 5) var correctionAmount: float = 1.5
@export var leftRaycast: RayCast2D
@export var middleRaycast: RayCast2D
@export var rightRaycast: RayCast2D

@export_category("Down Input")
@export var crouch: bool = false
# (REMOVED roll controls)

@export var groundPound: bool
@export_range(0.05, 0.75) var groundPoundPause: float = 0.25
@export var upToCancel: bool = false

@export_category("Animations (Check Box if has animation)")
@export var run: bool
@export var jump: bool
@export var idle: bool
@export var walk: bool
@export var death: bool
@export var slide: bool
@export var falling: bool
@export var crouch_idle: bool
@export var crouch_walk: bool
# (REMOVED roll + latch animations)

# --- INTERNAL VARIABLES ---
var appliedGravity: float
var maxSpeedLock: float
var appliedTerminalVelocity: float
var friction: float
var acceleration: float
var deceleration: float
var instantAccel: bool = false
var instantStop: bool = false

var jumpMagnitude: float = 500.0
var jumpCount: int
var jumpWasPressed: bool = false
var coyoteActive: bool = false
var dashMagnitude: float
var gravityActive: bool = true
var dashing: bool = false
var dashCount: int
var crouching
var groundPounding

var twoWayDashHorizontal
var twoWayDashVertical
var eightWayDash

var wasMovingR: bool
var wasPressingR: bool
var movementInputMonitoring: Vector2 = Vector2(true, true)

var gdelta: float = 1
var dset = false

var colliderScaleLockY
var colliderPosLockY
var colliderPosLockX
var anim
var animKey
var col
var animScaleLock : Vector2
var keyPosLockX

#Inputs
var upHold
var downHold
var leftHold
var leftTap
var leftRelease
var rightHold
var rightTap
var rightRelease
var jumpTap
var jumpRelease
var runHold
var dashTap
var downTap

var dead

var interactable : Node = null

func _ready():
	dead = false
	wasMovingR = true
	anim = PlayerSprite
	animKey = $Key
	col = IdleCollider
	_updateData()

func die():
	dead = true

func _on_interact_box_area_entered(area):
	if area.has_method("highlight"):
		area.highlight(true)
	if area.has_method("interact"):
		interactable = area

func _on_interact_box_area_exited(area):
	if area.has_method("interact"):
		area.highlight(false)
	if interactable == area:
		interactable = null

func _input(event):
	if event.is_action_pressed("interact") and interactable:
		interactable.interact(self)

func _updateData():
	acceleration = maxSpeed / timeToReachMaxSpeed
	deceleration = -maxSpeed / timeToReachZeroSpeed
	
	jumpMagnitude = (10.0 * jumpHeight) * gravityScale
	jumpCount = jumps
	
	dashMagnitude = maxSpeed * dashLength
	dashCount = dashes
	maxSpeedLock = maxSpeed
	
	animScaleLock = abs(anim.scale)
	keyPosLockX = animKey.position.x
	colliderScaleLockY = col.scale.y
	colliderPosLockY = col.position.y
	
	if timeToReachMaxSpeed == 0:
		instantAccel = true
		timeToReachMaxSpeed = 1
	elif timeToReachMaxSpeed < 0:
		timeToReachMaxSpeed = abs(timeToReachMaxSpeed)
		instantAccel = false
	else:
		instantAccel = false
		
	if timeToReachZeroSpeed == 0:
		instantStop = true
		timeToReachZeroSpeed = 1
	elif timeToReachMaxSpeed < 0:
		timeToReachMaxSpeed = abs(timeToReachMaxSpeed)
		instantStop = false
	else:
		instantStop = false
		
	if jumps > 1:
		jumpBuffering = 0
		coyoteTime = 0
	
	coyoteTime = abs(coyoteTime)
	jumpBuffering = abs(jumpBuffering)
	
	if directionalSnap:
		instantAccel = true
		instantStop = true
		
# Dash type setup
	if dashType == 0:
		pass
	if dashType == 1:
		twoWayDashHorizontal = true
	elif dashType == 2:
		twoWayDashVertical = true
	elif dashType == 3:
		twoWayDashHorizontal = true
		twoWayDashVertical = true
	elif dashType == 4:
		eightWayDash = true

func _process(_delta):
	if dead:
		if death:
			anim.speed_scale = 1
			anim.play("death")
			_setHitbox("death")
			animKey.visible = false
			death = false
		return

	# Flip sprite
	if rightHold:
		anim.scale.x = animScaleLock.x
		animKey.scale.x = animScaleLock.x
		animKey.position.x = keyPosLockX
	if leftHold:
		anim.scale.x = animScaleLock.x * -1
		animKey.scale.x = animScaleLock.x * -1
		animKey.position.x = -keyPosLockX
	
	# Run & idle
	if run and idle and !dashing and !crouching:
		animKey.play("default")
		if abs(velocity.x) > 0.1 and is_on_floor():
			anim.speed_scale = abs(velocity.x / maxSpeed)
			anim.play("run")
			_setHitbox("run")
		elif abs(velocity.x) < 0.1 and is_on_floor():
			anim.speed_scale = 1
			anim.play("idle")
			_setHitbox("idle")
	elif run and idle and walk and !dashing and !crouching:
		if abs(velocity.x) > 0.1 and is_on_floor():
			anim.speed_scale = abs(velocity.x / maxSpeed)
			if abs(velocity.x) < (maxSpeedLock):
				anim.play("walk")
				_setHitbox("idle")
			else:
				anim.play("run")
				_setHitbox("run")
		elif abs(velocity.x) < 0.1 and is_on_floor():
			anim.speed_scale = 1
			anim.play("idle")
			_setHitbox("idle")
		
	# Jump + fall anims
	if velocity.y < 0 and jump and !dashing:
		anim.play("jump")
		_setHitbox("jump")
	if velocity.y > 40 and falling and !dashing and !crouching:
		anim.play("falling")
		
	# crouch
	if crouching:
		if abs(velocity.x) > 10:
			anim.play("crouch_walk")
		else:
			anim.play("crouch_idle")

func _physics_process(delta):
	if !dset:
		gdelta = delta
		dset = true
	
	# --- INPUT DETECTION ---
	leftHold = Input.is_action_pressed("left") and not dead
	rightHold = Input.is_action_pressed("right") and not dead
	upHold = Input.is_action_pressed("up") and not dead
	downHold = Input.is_action_pressed("down") and not dead
	leftTap = Input.is_action_just_pressed("left") and not dead
	rightTap = Input.is_action_just_pressed("right") and not dead
	leftRelease = Input.is_action_just_released("left") and not dead
	rightRelease = Input.is_action_just_released("right") and not dead
	jumpTap = Input.is_action_just_pressed("jump") and not dead
	jumpRelease = Input.is_action_just_released("jump") and not dead
	runHold = false # (enable if you add a "run" input)
	dashTap = Input.is_action_just_pressed("dash") and not dead
	downTap = Input.is_action_just_pressed("down") and not dead
	
	# --- LEFT / RIGHT MOVEMENT ---
	if rightHold and leftHold and movementInputMonitoring:
		if !instantStop:
			_decelerate(delta, false)
		else:
			velocity.x = -0.1
	elif rightHold and movementInputMonitoring.x:
		if velocity.x > maxSpeed or instantAccel:
			velocity.x = maxSpeed
		else:
			velocity.x += acceleration * delta
		if velocity.x < 0:
			if !instantStop:
				_decelerate(delta, false)
			else:
				velocity.x = -0.1
	elif leftHold and movementInputMonitoring.y:
		if velocity.x < -maxSpeed or instantAccel:
			velocity.x = -maxSpeed
		else:
			velocity.x -= acceleration * delta
		if velocity.x > 0:
			if !instantStop:
				_decelerate(delta, false)
			else:
				velocity.x = 0.1
	
	if velocity.x > 0:
		wasMovingR = true
	elif velocity.x < 0:
		wasMovingR = false
		
	if rightTap: wasPressingR = true
	if leftTap: wasPressingR = false
	
	# Run modifier
	if runningModifier and !runHold:
		maxSpeed = maxSpeedLock / 2
	elif is_on_floor(): 
		maxSpeed = maxSpeedLock
	
	if !(leftHold or rightHold):
		if !instantStop:
			_decelerate(delta, false)
		else:
			velocity.x = 0
	
	# --- CROUCHING ---
	if crouch:
		if downHold and is_on_floor():
			crouching = true
		elif !downHold and ((runHold and runningModifier) or !runningModifier):
			crouching = false
	if !is_on_floor():
		crouching = false
	
	if crouching:
		maxSpeed = maxSpeedLock / 2
		col.scale.y = colliderScaleLockY / 2
		col.position.y = colliderPosLockY + (8 * colliderScaleLockY)
	else:
		maxSpeed = maxSpeedLock
		col.scale.y = colliderScaleLockY
		col.position.y = colliderPosLockY
	
	# --- JUMP & GRAVITY ---
	if velocity.y > 0:
		appliedGravity = gravityScale * descendingGravityFactor
	else:
		appliedGravity = gravityScale
	
	appliedTerminalVelocity = terminalVelocity
	
	if gravityActive:
		if velocity.y < appliedTerminalVelocity:
			velocity.y += appliedGravity
		elif velocity.y > appliedTerminalVelocity:
			velocity.y = appliedTerminalVelocity
	
	if shortHopAkaVariableJumpHeight and jumpRelease and velocity.y < 0:
		velocity.y = velocity.y / 2
	
	if jumps == 1:
		# Coyote time
		if !is_on_floor():
			if coyoteTime > 0:
				coyoteActive = true
				_coyoteTime()
		# Jump presses
		if jumpTap:
			if coyoteActive:
				coyoteActive = false
				_jump()
			if jumpBuffering > 0:
				jumpWasPressed = true
				_bufferJump()
			elif jumpBuffering == 0 and coyoteTime == 0 and is_on_floor():
				_jump()
		if is_on_floor():
			jumpCount = jumps
			coyoteActive = true
			if jumpWasPressed:
				_jump()
	elif jumps > 1:
		if is_on_floor():
			jumpCount = jumps
		if jumpTap and jumpCount > 0:
			velocity.y = -jumpMagnitude
			jumpCount -= 1
			_endGroundPound()
	
	# --- DASHING ---
	if is_on_floor():
		dashCount = dashes
	
	if eightWayDash and dashTap and dashCount > 0:
		var input_direction = Input.get_vector("left", "right", "up", "down")
		var dTime = 0.0625 * dashLength
		_dashingTime(dTime)
		_pauseGravity(dTime)
		velocity = dashMagnitude * input_direction
		dashCount -= 1
		movementInputMonitoring = Vector2(false, false)
		_inputPauseReset(dTime)
	
	if twoWayDashVertical and dashTap and dashCount > 0:
		var dTime = 0.0625 * dashLength
		if upHold and !downHold:
			_dashingTime(dTime)
			_pauseGravity(dTime)
			velocity.x = 0
			velocity.y = -dashMagnitude
			dashCount -= 1
			movementInputMonitoring = Vector2(false, false)
			_inputPauseReset(dTime)
		elif downHold and !upHold:
			_dashingTime(dTime)
			_pauseGravity(dTime)
			velocity.x = 0
			velocity.y = dashMagnitude
			dashCount -= 1
			movementInputMonitoring = Vector2(false, false)
			_inputPauseReset(dTime)
	
	if twoWayDashHorizontal and dashTap and dashCount > 0:
		var dTime = 0.0625 * dashLength
		if wasPressingR and !(upHold or downHold):
			velocity.y = 0
			velocity.x = dashMagnitude
			_pauseGravity(dTime)
			_dashingTime(dTime)
			dashCount -= 1
			movementInputMonitoring = Vector2(false, false)
			_inputPauseReset(dTime)
		elif !(upHold or downHold):
			velocity.y = 0
			velocity.x = -dashMagnitude
			_pauseGravity(dTime)
			_dashingTime(dTime)
			dashCount -= 1
			movementInputMonitoring = Vector2(false, false)
			_inputPauseReset(dTime)
	
	if dashing and velocity.x > 0 and leftTap and dashCancel:
		velocity.x = 0
	if dashing and velocity.x < 0 and rightTap and dashCancel:
		velocity.x = 0
	
	# --- CORNER CUTTING ---
	if cornerCutting:
		if velocity.y < 0 and leftRaycast.is_colliding() and !rightRaycast.is_colliding() and !middleRaycast.is_colliding():
			position.x += correctionAmount
		if velocity.y < 0 and !leftRaycast.is_colliding() and rightRaycast.is_colliding() and !middleRaycast.is_colliding():
			position.x -= correctionAmount
	
	# --- GROUND POUND ---
	if groundPound and downTap and !is_on_floor():
		groundPounding = true
		gravityActive = false
		velocity.y = 0
		await get_tree().create_timer(groundPoundPause).timeout
		_groundPound()
	if is_on_floor() and groundPounding:
		_endGroundPound()
	
	move_and_slide()
	
	if upToCancel and upHold and groundPounding:
		_endGroundPound()

func _bufferJump():
	await get_tree().create_timer(jumpBuffering).timeout
	jumpWasPressed = false

func _coyoteTime():
	await get_tree().create_timer(coyoteTime).timeout
	coyoteActive = false
	jumpCount += -1

func _setHitbox(hitbox: String):
	pass
	col.disabled = true
	col.visible = false
	match hitbox:
		"idle":
			col = IdleCollider
		"jump":
			col = JumpCollider
		"run":
			col = RunCollider
		"death":
			col = DeathCollider
			if anim.scale.x != animScaleLock.x:
				col.position.x = -col.position.x
				col.scale.y = -1
	_updateData()
	col.disabled = false
	col.visible = true
	
func _jump():
	if jumpCount > 0:
		velocity.y = -jumpMagnitude
		jumpCount += -1
		jumpWasPressed = false

func _inputPauseReset(time):
	await get_tree().create_timer(time).timeout
	movementInputMonitoring = Vector2(true, true)
	

func _decelerate(delta, vertical):
	if !vertical:
		if velocity.x > 0:
			velocity.x += deceleration * delta
		elif velocity.x < 0:
			velocity.x -= deceleration * delta
	elif vertical and velocity.y > 0:
		velocity.y += deceleration * delta


func _pauseGravity(time):
	gravityActive = false
	await get_tree().create_timer(time).timeout
	gravityActive = true

func _dashingTime(time):
	dashing = true
	await get_tree().create_timer(time).timeout
	dashing = false

func _groundPound():
	appliedTerminalVelocity = terminalVelocity * 10
	velocity.y = jumpMagnitude * 2
	
func _endGroundPound():
	groundPounding = false
	appliedTerminalVelocity = terminalVelocity
	gravityActive = true

func _placeHolder():
	print("")
