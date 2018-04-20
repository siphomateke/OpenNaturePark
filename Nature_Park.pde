// Declare constants
public static final int TILESIZE = 10;
public static final int XTILES = 6;
public static final int YTILES = 10;
// The actual width of the game on a phone
// to allow scaling up proportionately
public static final int REALWIDTH = 128;
public static final int REALHEIGHT = 128;

GameBoard board;
int speed = 500;
int score = 0;
int highScore = 0;
int combos = 0;

int gameState = 1;
public static final int STATEINTRO = 1;
public static final int STATEGAME = 2;
int prevGameState = 0;
boolean gameStateChanged = false;

NumericFont scoreFont;
NumericFont comboFont;

void setup() {
  size(256,256);
  noSmooth();
  // Load all images in the data directory
  loadAllImages("/");
  // Generate all the different block types
  generateBlocks();
  
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
  
  switch (gameState) {
    case STATEINTRO:
      intro(time);
      break;
    case STATEGAME:
      game(time);
      break;
  }
  
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

public void keyReleased() {
  if (key==CODED) {
    setMove(str(keyCode), true, false);
  } else {
    setMove(str(key), false, false);
  }
  if (gameState==STATEGAME) {
    if (keyCode==DOWN && timers.get("keyDown")>0) {
      board.player.toBoard = true;
      timers.put("keyDown",0f);
    }
  }
}

public void intro(float time) {
  if (gameStateChanged) {
    background(#240254);
    drawImage("cloud",0,82);
    drawImage("intro_frame",0,0);
    drawImage("main_boat",38,53);
    drawImage("intro_buble",61,31);
    drawImage("intro_buble",30,31);
    
    
    drawImage("intro_title",16,7);
    drawImage("intro_flower1",37,16);
  }
  
  if (isKeyDown("p")) {
    gameState = STATEGAME;
  }
}