import g4p_controls.*;

//import processing.sound.*;

public static final float VERSION = 0.7;

// Declare constants
public static final int TILESIZE = 10;
public static final int XTILES = 6;
public static final int YTILES = 10;
// The actual width of the game on a phone
// to allow scaling up proportionately
public static final int REALWIDTH = 128;
public static final int REALHEIGHT = 128;
int windowWidth = 0;
int padding = 0;

GameBoard board;
ParticleSim sim;
int initspeed = 1000;
int speed = initspeed;
int fastestSpeed = 200;
// The number of placements till the game is
// at its fastest speed
int numToFastest = 200;
int numLevels = 10;
int level = 0;
int score = 0;
int highScore = 0;
int combos = 0;

// Delay the spawn of the next player
//float nextPlayerDelay = 1000;

int gameState = 1;
public static final int STATEINTRO = 1;
public static final int STATEGAME = 2;
public static final int STATESETTINGS = 3;
int prevGameState = 0;
boolean gameStateChanged = false;

NumericFont scoreFont;
NumericFont comboFont;

PVector center;

void setup() {
  size(256,256);
  //fullScreen();
  noSmooth();
  center = new PVector(width/2,height/2);
  windowWidth = height;
  padding = ((width-windowWidth)/2);
  // Load all images in the data directory
  loadAllImages("/");
  // Generate all the different block types
  generateBlocks();
  // Generate all the animals
  addAnimals();
  
  initRandomShapeGen();
  loadConfig();
  initGUI();
  //initSounds();
  sim = new ParticleSim();
  
  scoreFont = new NumericFont(new String[][] {
      {"00", "0"}, 
      {"01", "1"},
      {"02", "2"},
      {"03", "3"},
      {"04", "4"},
      {"05", "5"},
      {"06", "6"},
      {"07", "7"},
      {"08", "8"},
      {"09", "9"},
  });
  comboFont = new NumericFont(new String[][] {
      {"combo_0", "0"}, 
      {"combo_1", "1"},
      {"combo_2", "2"},
      {"combo_3", "3"},
      {"combo_4", "4"},
      {"combo_5", "5"},
      {"combo_6", "6"},
      {"combo_7", "7"},
      {"combo_8", "8"},
      {"combo_9", "9"},
  });
}

float now = 0, then = 0, time = 0;
void draw() {
  now = millis();
  time = now-then;
  
  gameStateChanged = false;
  if (gameState!=prevGameState) {
    gameStateChanged = true;  
  }
  prevGameState = gameState;
  
  noStroke();
  fill(50);
  rect(0,0,padding,height);
  rect(padding+windowWidth,0,padding,height);
  translate(padding,0);
  noFill();
  switch (gameState) {
    case STATEINTRO:
      intro(time);
      break;
    case STATEGAME:
      game(time);
      break;
    case STATESETTINGS:
      gameSettings(time);
      break;
  }
  updateGUI(time);
  then = now;
}

public void keyPressed() {
  if (key==CODED) {
    setMove(str(keyCode), true, true);
  } else {
    setMove(str(key), false, true);
  }
  if (key == ESC) {
    //key = 0;
  }
  if (gameState==STATEGAME) {
    if (!gameover && !newGame) {
      if (isKeyDown("left")) {
        board.player.move(-1,0);
        timers.put("keyLeft",0f);
      }
      if (isKeyDown("right")) {
        board.player.move(1,0);
        timers.put("keyRight",0f);
      }
    }
  }
}

public void keyReleased() {
  if (key==CODED) {
    setMove(str(keyCode), true, false);
  } else {
    setMove(str(key), false, false);
  }
  if (gameState==STATEGAME) {
    if (!gameover && !newGame) {
      if (keyCode==DOWN && timers.get("keyDown")>0) {
        board.player.toBoard = true;
        timers.put("keyDown",0f);
      }
    }
    if (key==' ') {
      if (newGame) {
        newGame();
      }
      else if (!newGame) {
        paused = !paused;
      }
    }
  }
}

String introAnimal = "bunny";
public void intro(float time) {
  if (gameStateChanged) {
    /*background(#240254);
    drawImage("cloud",0,82);
    drawImage("intro_frame",0,0);
    drawImage("main_boat",38,53);*/
    introAnimal = randomAnimalName();
  }
  
  animals.get(introAnimal).update(time);
  
  drawIntro();
}

public void drawParallax(String img, int x, int y, int z) {
  if (z>0) {
    x+=int(center.x-mouseX)/(z*20);
    y+=int(center.y-mouseY)/(z*20);
  }
  drawImage(img,x,y);
}

public void drawIntro() {
  background(#240254);
  /*drawParallax("cloud",0,82,2);
  drawParallax("intro_frame",0,0,0);
  drawParallax("intro_bigstar", 36, 7,2);
  drawParallax("intro_bigstar", 86, 34,2);
  drawParallax("intro_bigstar", 111, 21,2);
  drawParallax("intro_midstar", 63, 11,3);
  drawParallax("intro_midstar", 88, 9,3);
  drawParallax("intro_midstar", 29, 40,3);
  drawParallax("intro_midstar", 22, 60,3);
  drawParallax("intro_smallstar", 12, 37,4);
  drawParallax("intro_smallstar", 42, 38,4);
  drawParallax("intro_smallstar", 29, 64,4);
  drawParallax("intro_buble",61,31,1);
  drawParallax("intro_buble",30,31,1);*/
  drawImage("cloud",0,82);
  drawImage("intro_frame",0,0);
  drawImage("intro_bigstar", 36, 7);
  drawImage("intro_bigstar", 86, 34);
  drawImage("intro_bigstar", 111, 21);
  drawImage("intro_midstar", 63, 11);
  drawImage("intro_midstar", 88, 9);
  drawImage("intro_midstar", 29, 40);
  drawImage("intro_midstar", 22, 60);
  drawImage("intro_smallstar", 12, 37);
  drawImage("intro_smallstar", 42, 38);
  drawImage("intro_smallstar", 29, 64);
  drawImage("intro_buble",61,31);
  drawImage("intro_buble",30,31);
  animals.get(introAnimal).display(36,51,"happy","open",false,true);
  drawImage("intro_title",16,7);
  drawImage("intro_flower1",37,16);
  //drawImage("play_button",14,90);
  //drawImage("settings_button",100,90);
}