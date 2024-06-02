require 'ruby2d'

set title: "Mini Golf Start Page"
set background: 'white'
set width: 800
set height: 600

# Constants
BALL_RADIUS = 10
HOLE_RADIUS = 15
OBSTACLE_SIZE = 50
DRAG_MULTIPLIER = 1.6 # Increase sensitivity further
MAX_SHOT_SPEED = 10 # Max shot speed
DAMPING_FACTOR = 0.977 # Adjust damping factor to control slowdown rate
STOP_THRESHOLD = 0.5 # Adjust threshold for stopping velocity
DARK_GREEN = '#006400'  # Mörkare grön
BUNKER_RADIUS = 30
# For drawing menu 

game_started = false

# Track mouse position
mouse_down = nil
mouse_up = nil
ball_in_motion = false
shot_velocity = [0, 0]

######## START MENU ###########
start_button = Rectangle.new(
  x: 150, y: 250,
  width: 550, height: 100,
  color: 'green'
)

start_text = Text.new(
  "STARTA GENOM ATT TRYCKA SPACE",
  x: 165, y: 280,
  size: 30,
  color: 'white'
)




###### bana1 #########
motstånd1 = Rectangle.new(x: 0, y: 0, width: 790, height: 50,  color: DARK_GREEN)
motstånd2 = Rectangle.new(x: 0, y: 550, width: 790, height: 50,  color: DARK_GREEN)
bunker1 = Circle.new(x: 650, y: 250, radius: BUNKER_RADIUS, color: 'yellow')
bunker2 = Circle.new(x: 550, y: 380, radius: BUNKER_RADIUS, color: 'yellow')
bunker3 = Circle.new(x: 500, y: 250, radius: BUNKER_RADIUS, color: 'yellow')
bunker4 = Circle.new(x: 650, y: 400, radius: BUNKER_RADIUS, color: 'yellow')
hole = Circle.new(x: 700, y: 300, radius: HOLE_RADIUS, color: 'black')
  
  
obstacles = [
  Rectangle.new(x: 0, y: 0, width: 800, height: 10, color: 'brown'),
  Rectangle.new(x: 0, y: 0, width: 10, height: 600, color: 'brown'),
  Rectangle.new(x: 0, y: 590, width: 800, height: 10, color: 'brown'),
  Rectangle.new(x: 790, y: 0, width: 10, height: 600, color: 'brown'),
  Rectangle.new(x: 200, y: 200, width: OBSTACLE_SIZE, height: OBSTACLE_SIZE, color: 'brown'),
  Rectangle.new(x: 300, y: 420, width: OBSTACLE_SIZE, height: OBSTACLE_SIZE, color: 'brown'),
  Rectangle.new(x: 500, y: 100, width: OBSTACLE_SIZE, height: OBSTACLE_SIZE, color: 'brown'),
  Rectangle.new(x: 380, y: 300, width: OBSTACLE_SIZE, height: OBSTACLE_SIZE, color: 'brown'),
  Rectangle.new(x: 100, y: 480, width: OBSTACLE_SIZE, height: OBSTACLE_SIZE, color: 'brown'),
  Rectangle.new(x: 600, y: 480, width: OBSTACLE_SIZE, height: OBSTACLE_SIZE, color: 'brown'),
  Rectangle.new(x: 350, y: 180, width: OBSTACLE_SIZE, height: OBSTACLE_SIZE, color: 'brown'),

]

boom = Sprite.new(
  'boom.png',
  clip_width: 127,
  x: 635, y: 230,
  time: 75
)

ball = Circle.new(x: 100, y: 350, radius: BALL_RADIUS, color: 'white')

####### GAME functions ###########

# Reset ball position
def reset_ball(ball)
  ball.x = 100
  ball.y = 350
end

# Calculate shot velocity
def calculate_velocity(mouse_down, mouse_up)
  shot_dx = mouse_up[0] - mouse_down[0]
  shot_dy = mouse_up[1] - mouse_down[1]
  magnitude = Math.sqrt(shot_dx**2 + shot_dy**2)
  normalized_dx = shot_dx / magnitude
  normalized_dy = shot_dy / magnitude
  shot_speed = [magnitude / 10, MAX_SHOT_SPEED].min # Adjust sensitivity and max speed here
  [-normalized_dx * shot_speed, -normalized_dy * shot_speed] # Invert velocity
end

# Check collision with obstacles
def collides_with_obstacle?(ball, obstacle)
  obstacle_center_x = obstacle.x + obstacle.width / 2
  obstacle_center_y = obstacle.y + obstacle.height / 2
  distance_x = (ball.x - obstacle_center_x).abs
  distance_y = (ball.y - obstacle_center_y).abs

  if distance_x > (obstacle.width / 2.0 + BALL_RADIUS)
    closest_x = obstacle.x + obstacle.width / 2.0
  else
    closest_x = [ball.x, obstacle.x].max
    closest_x = [closest_x, obstacle.x + obstacle.width].min
  end

  if distance_y > (obstacle.height / 2.0 + BALL_RADIUS)
    closest_y = obstacle.y + obstacle.height / 2.0
  else
    closest_y = [ball.y, obstacle.y].max
    closest_y = [closest_y, obstacle.y + obstacle.height].min
  end

  distance_x = ball.x - closest_x
  distance_y = ball.y - closest_y
  distance = Math.sqrt(distance_x**2 + distance_y**2)

  distance <= BALL_RADIUS
end
# Check if ball reached hole
def reached_hole?(ball, hole)
  distance = Math.sqrt((ball.x - hole.x) ** 2 + (ball.y - hole.y) ** 2)
  distance <= BALL_RADIUS + HOLE_RADIUS
end

def reached_bunker?(ball, bunker)
  distance = Math.sqrt((ball.x - bunker.x) ** 2 + (ball.y - bunker.y) ** 2)
  distance <= BALL_RADIUS + BUNKER_RADIUS_RADIUS
end

# Calculate velocity magnitude
def velocity_magnitude(velocity)
  Math.sqrt(velocity[0]**2 + velocity[1]**2)
end

# Clamp function to constrain value within a range
def clamp(value, min, max)
  if value < min
    min
  elsif value > max
    max
  else
    value
  end
end

########## Key listners #######################
on :key_down do |event|
  if event_key = 'space'
    start_button.remove
    start_text.remove
    game_started = !game_started
  end
    
end

on :mouse_down do |event|
  if !ball_in_motion
    mouse_down = [event.x, event.y]
  end
end

on :mouse_up do |event|
  if !ball_in_motion
    mouse_up = [event.x, event.y]
    shot_velocity = calculate_velocity(mouse_down, mouse_up)
    ball_in_motion = true
  end
end

on :key_down do |event|
  reset_ball(ball) if event.key == 'r' && !ball_in_motion
end

########## gameloop #############
update do

  if(game_started)
    set background: 'green'
    hole.add
    
    bunker1.add
    bunker2.add
    bunker3.add
    bunker4.add
    motstånd1.add
    motstånd2.add
    obstacles[0].add
    obstacles[1].add
    obstacles[2].add
    obstacles[3].add
    obstacles[4].add
    obstacles[5].add
    obstacles[6].add
    obstacles[7].add
    obstacles[8].add
    obstacles[9].add
    obstacles[10].add
    ball.add
    start_button.remove
    start_text.remove

  else
    set background: 'white'
    hole.remove
    ball.remove
    bunker1.remove
    bunker2.remove
    bunker3.remove
    bunker4.remove
    motstånd1.remove
    motstånd2.remove
    obstacles[0].remove
    obstacles[1].remove
    obstacles[2].remove
    obstacles[3].remove
    obstacles[4].remove
    obstacles[5].remove
    obstacles[6].remove
    obstacles[7].remove
    obstacles[8].remove
    obstacles[9].remove
    obstacles[10].remove
    

    start_button.add
    start_text.add

  end


  if ball_in_motion
    # Apply damping to slow down the ball
    shot_velocity[0] *= DAMPING_FACTOR
    shot_velocity[1] *= DAMPING_FACTOR


    if(ball.y < 50 || ball.y > 550)
      shot_velocity[0] *= 0.95
      shot_velocity[1] *= 0.95
    end

    ball.x += shot_velocity[0]
    ball.y += shot_velocity[1]

    obstacles.each do |obstacle|
      if collides_with_obstacle?(ball, obstacle)
        # Calculate reflection vector
        closest_x = clamp(ball.x, obstacle.x, obstacle.x + obstacle.width)
        closest_y = clamp(ball.y, obstacle.y, obstacle.y + obstacle.height)
        distance_x = ball.x - closest_x
        distance_y = ball.y - closest_y
        distance = Math.sqrt(distance_x**2 + distance_y**2)
        normal_x = distance_x / distance
        normal_y = distance_y / distance
        dot_product = shot_velocity[0] * normal_x + shot_velocity[1] * normal_y
        reflection_x = shot_velocity[0] - 2 * dot_product * normal_x
        reflection_y = shot_velocity[1] - 2 * dot_product * normal_y
        shot_velocity = [reflection_x, reflection_y]
      end
    end

    if reached_hole?(ball, hole)
      # Change background color to green when the ball reaches the hole
      boom.play 
      reset_ball(ball)
      ball_in_motion = false
    end

    if velocity_magnitude(shot_velocity) < STOP_THRESHOLD
      # Allow shooting again when the ball's velocity falls below the threshold
      ball_in_motion = false
    end
  end
end


show


