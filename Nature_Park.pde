import g4p_controls.*;
import java.util.Observer;

//import processing.sound.*;

public static final String VERSION = "0.8";

Config config;

// Declare constants
public static final int TILESIZE = 10;
// The actual width of the game on a phone
// to allow scaling up proportionately
public static final int INTROWIDTH = 128;
public static final int INTROHEIGHT = 128;
int gameWidth = 128;
int gameHeight = 128;
float gameScale = 2;
int windowWidth = 0;
int windowHeight = 0;
int padding = 0;

GameBoard board;
ParticleSim sim;
int initspeed = 1000;
int speed = initspeed;
int fastestSpeed = 200;
int numLevels = 10;
int level = 0;
int score = 0;
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

class Events implements Observer {
  @Override
  public void update(Observable o, Object arg) {
    if (o instanceof Config) {
      if (arg instanceof ConfigLoadEvent) {
        updateGameSize(); // needed to scale GUI images
        initGUI();
      }
      if (arg instanceof ConfigPropChangeEvent) {
        ConfigPropChangeEvent e = (ConfigPropChangeEvent) arg;
        // If the number of tiles has changed, re-caculate game width and height
        if (e.changed.contains("xTiles") || e.changed.contains("yTiles")) {
          updateGameSize();
        }
      }
    }
  }
}

Events events;

void setup() {
  size(128,128);
  //fullScreen();
  noSmooth();

  config = new Config(dataPath("config.json"));

  events = new Events();
  config.addObserver(events);

  // Load all images in the data directory
  loadAllImages("/");
  loadAllImages("board/");
  loadAllImages("buttons/");
  loadAllImages("numbers/");
  loadAllImages("blocks/");
  loadAllImages("text/");
  loadAllImages("gui/");
  // Generate all the different block types
  generateBlocks();
  
  initRandomShapeGen();

  // Load last settings and highscore from the config file
  // also initialize the GUI
  try {
    config.load();
  } catch (Exception e) {
    showErrorMessage(e.getMessage()+"\n\n The default configuration will be loaded instead.", "Error loading config");
    config.loadDefault();
  }
  //initSounds();
  // Initialize the particle simulation
  sim = new ParticleSim();
  
  scoreFont = new NumericFont(new String[][] {
      {"0", "0"}, 
      {"1", "1"},
      {"2", "2"},
      {"3", "3"},
      {"4", "4"},
      {"5", "5"},
      {"6", "6"},
      {"7", "7"},
      {"8", "8"},
      {"9", "9"},
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