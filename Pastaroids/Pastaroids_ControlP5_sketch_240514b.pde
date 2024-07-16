import controlP5.*;

ControlP5 cp5;
Button startButton;
Slider laserSizeSlider;
Slider bouncinessSlider;
Slider numAsteroidsSlider;
int numAsteroids = 5; // Number of asteroids
float shipX, shipY, shipAngle; // Ship position and angle
float shipVelX, shipVelY; // Ship velocity
boolean leftKey, rightKey, upKey; // Key press states
ArrayList<Laser> lasers; // List of lasers
ArrayList<Explosion> explosions; // List of explosions
ArrayList<Asteroid> asteroids; // List of asteroids
float laserSize = 5; // Initial size of the laser beam
int score = 0; // Initial score
int highScore = 0; // High score
boolean gameStarted = false; // Game start state
boolean gameOver = false; // Game over state
int gameOverTime = 0; // Game over timer
PFont font; // Font for text

void setup() {
  size(1024, 768); // Set up window size
  cp5 = new ControlP5(this);
  startButton = cp5.addButton("Start Game")
                   .setPosition(width / 2 - 50, height / 2 - 20)
                   .setSize(100, 40)
                   .onClick(new CallbackListener() {
                     public void controlEvent(CallbackEvent event) {
                       startGame();
                     }
                   });

  laserSizeSlider = cp5.addSlider("Laser Size")
                       .setPosition(width / 2 - 100, 20)
                       .setSize(200, 20)
                       .setRange(1, 10)
                       .setValue(laserSize);

  bouncinessSlider = cp5.addSlider("Bounciness")
                        .setPosition(width / 2 - 100, height - 40)
                        .setSize(200, 20)
                        .setRange(0, 100)
                        .setValue(50);

  numAsteroidsSlider = cp5.addSlider("Number of Asteroids")
                          .setPosition(width - 320, height - 40)
                          .setSize(200, 20)
                          .setRange(1, 20)
                          .setNumberOfTickMarks(20) // Ensures whole numbers
                          .setValue(numAsteroids);

  lasers = new ArrayList<Laser>(); // Initialize lasers list
  explosions = new ArrayList<Explosion>(); // Initialize explosions list
  asteroids = new ArrayList<Asteroid>(); // Initialize asteroids list
  font = createFont("Arial", 24, true); // Create a smooth font
  textFont(font); // Set the font
  resetGame();
}

void draw() {
  background(0); // Clear the background

  // Display the score and high score
  fill(255);
  textSize(24);
  textAlign(LEFT, CENTER);
  text("Score: " + score, 20, 30);
  textAlign(RIGHT, CENTER);
  text("High Score: " + highScore, width - 20, 30);

  if (gameStarted) {
    laserSize = laserSizeSlider.getValue(); // Update laser size from slider
    float bounciness = bouncinessSlider.getValue() / 100.0; // Update bounciness from slider
    int desiredNumAsteroids = int(numAsteroidsSlider.getValue()); // Update number of asteroids from slider

    if (desiredNumAsteroids != asteroids.size()) {
      updateAsteroidCount(desiredNumAsteroids);
    }

    drawShip(); // Draw the ship
    updateShip(); // Update ship position and angle

    // Update and draw lasers
    for (int i = lasers.size() - 1; i >= 0; i--) {
      Laser l = lasers.get(i);
      l.update();
      l.display();
      if (l.isOffScreen()) {
        lasers.remove(i);
        continue;
      }
      for (int j = asteroids.size() - 1; j >= 0; j--) {
        Asteroid a = asteroids.get(j);
        if (a.contains(l.x, l.y)) {
          explosions.add(new Explosion(a.x, a.y));
          asteroids.set(j, new Asteroid());
          lasers.remove(i);
          score++; // Increment the score
          break;
        }
      }
    }

    // Update and draw asteroids
    for (int i = 0; i < asteroids.size(); i++) {
      Asteroid a = asteroids.get(i);
      a.update();
      a.display();

      // Check for collisions with other asteroids
      for (int j = i + 1; j < asteroids.size(); j++) {
        Asteroid b = asteroids.get(j);
        if (a.intersects(b)) {
          a.bounce(b, bounciness);
        }
      }

      if (a.contains(shipX, shipY)) {
        explosions.add(new Explosion(shipX, shipY));
        gameOver = true;
        gameStarted = false;
        gameOverTime = millis();
        if (score > highScore) {
          highScore = score; // Update high score
        }
        break;
      }
    }

    // Update and draw explosions
    for (int i = explosions.size() - 1; i >= 0; i--) {
      Explosion e = explosions.get(i);
      e.update();
      e.display();
      if (e.isDone()) {
        explosions.remove(i);
      }
    }

    if (gameOver) {
      displayGameOver();
    }
  } else {
    if (gameOver) {
      displayGameOver();
    } else {
      startButton.show();
    }
  }
}

void drawShip() {
  pushMatrix();
  translate(shipX, shipY);
  rotate(shipAngle);
  stroke(255);
  noFill();
  beginShape();
  vertex(10, 0);
  vertex(-10, 10);
  vertex(-5, 0);
  vertex(-10, -10);
  endShape(CLOSE);
  popMatrix();
}

void updateShip() {
  if (leftKey) shipAngle -= 0.05;
  if (rightKey) shipAngle += 0.05;
  if (upKey) {
    shipVelX += cos(shipAngle) * 0.1; // Accelerate the ship
    shipVelY += sin(shipAngle) * 0.1;
  }

  shipX += shipVelX; // Update position based on velocity
  shipY += shipVelY;

  // Wrap around screen edges
  if (shipX < 0) shipX = width;
  if (shipX > width) shipX = 0;
  if (shipY < 0) shipY = height;
  if (shipY > height) shipY = 0;

  // Apply friction to slow down the ship gradually
  shipVelX *= 0.99;
  shipVelY *= 0.99;
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) leftKey = true;
    if (keyCode == RIGHT) rightKey = true;
    if (keyCode == UP) upKey = true;
  } else if (key == ' ') {
    lasers.add(new Laser(shipX, shipY, shipAngle, laserSize));
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == LEFT) leftKey = false;
    if (keyCode == RIGHT) rightKey = false;
    if (keyCode == UP) upKey = false;
  }
}

void startGame() {
  println("Starting game..."); // Debugging
  gameStarted = true;
  gameOver = false;
  score = 0;
  startButton.hide();
  resetGame();
}

void resetGame() {
  println("Resetting game..."); // Debugging
  shipX = width / 2; // Reset ship position
  shipY = height / 2;
  shipAngle = 0; // Reset ship angle
  shipVelX = 0; // Reset ship velocity
  shipVelY = 0;
  lasers.clear(); // Clear lasers list
  explosions.clear(); // Clear explosions list
  updateAsteroidCount(int(numAsteroidsSlider.getValue()));
}

void updateAsteroidCount(int count) {
  asteroids.clear();
  for (int i = 0; i < count; i++) {
    asteroids.add(new Asteroid());
  }
}

void displayGameOver() {
  fill(255);
  textSize(40);
  textAlign(CENTER, CENTER);
  text("Game Over", width / 2, height / 2);

  if (millis() - gameOverTime > 2000) { // Display for 2 seconds
    startButton.show();
    gameOver = false;
  }
}

class Laser {
  float x, y, angle, speed, size;

  Laser(float x, float y, float angle, float size) {
    this.x = x;
    this.y = y;
    this.angle = angle;
    this.speed = 5;
    this.size = size;
  }

  void update() {
    x += cos(angle) * speed;
    y += sin(angle) * speed;
  }

  void display() {
    stroke(255, 0, 0); // Red color for the laser
    strokeWeight(size); // Set laser size
    point(x, y);
  }

  boolean isOffScreen() {
    return x < 0 || x > width || y < 0 || y > height;
  }
}

class Asteroid {
  float x, y, speedX, speedY, size;
  float minSpeed = 1.5;
  float maxSpeed = 3.0;

  Asteroid() {
    x = random(width);
    y = random(height);
    speedX = random(-1, 1);
    speedY = random(-1, 1);
    while (speedX == 0 && speedY == 0) {
      speedX = random(-1, 1);
      speedY = random(-1, 1);
    }
    size = random(30, 70);
    float speedFactor = random(minSpeed, maxSpeed) / dist(0, 0, speedX, speedY);
    speedX *= speedFactor;
    speedY *= speedFactor;
  }

  void update() {
    x += speedX;
    y += speedY;
    if (x < 0) x = width;
    if (x > width) x = 0;
    if (y < 0) y = height;
    if (y > height) y = 0;
  }

  void display() {
    stroke(255);
    noFill();
    ellipse(x, y, size, size);
  }

  boolean contains(float px, float py) {
    return dist(px, py, x, y) < size / 2;
  }

  boolean intersects(Asteroid other) {
    return dist(x, y, other.x, other.y) < (size / 2 + other.size / 2);
  }

  void bounce(Asteroid other, float bounciness) {
    float angle = atan2(other.y - y, other.x - x);
    float targetX = x + cos(angle) * (size / 2 + other.size / 2);
    float targetY = y + sin(angle) * (size / 2 + other.size / 2);
    float ax = (targetX - other.x) * bounciness;
    float ay = (targetY - other.y) * bounciness;
    speedX -= ax;
    speedY -= ay;
    other.speedX += ax;
    other.speedY += ay;
  }
}

class Explosion {
  float x, y;
  int timer;
  int duration = 30; // Duration of the explosion

  Explosion(float x, float y) {
    this.x = x;
    this.y = y;
    this.timer = 0;
  }

  void update() {
    timer++;
  }

  void display() {
    int col = timer * 255 / duration;
    if (timer < duration / 3) {
      stroke(255, col, 0); // Red
    } else if (timer < 2 * duration / 3) {
      stroke(255, 255, col); // Orange
    } else {
      stroke(255, col, 0); // Yellow
    }
    noFill();
    ellipse(x, y, timer * 2, timer * 2); // Expanding circle for explosion
  }

  boolean isDone() {
    return timer > duration;
  }
}
