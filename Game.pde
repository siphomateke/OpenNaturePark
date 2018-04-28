HashMap<String, Float> timers;
boolean paused = false;
boolean gameover = false;
boolean newGame = true;
public void drawMainBar() {
  PImage left = getImage("main_bar_bg_left");
  PImage right = getImage("main_bar_bg_right");
  drawImage(left,0,0);
  for (int x=0;x<gameWidth-right.width-left.width;x++) {
    drawImage(getImage("main_bar_bg_center"),left.width+x,0);
  }
  drawImage(right,gameWidth-right.width,0);
  drawImage(getImage("main_bar_score"),1,0);
  PImage highScore = getImage("main_bar_highscore");
  drawImage(highScore,gameWidth-highScore.width-3,0);
}
public void drawGameBackground() {
  background(36,182,255);
  drawMainBar();
}
public void makeGameBoard() {
  board = new GameBoard(3,15);  
}
public void game(float time) {
  if (gameStateChanged) {
    drawGameBackground();
    
    // Create the game board
    makeGameBoard();
    
    int nextPlayerSize = int(TILESIZE * getMaximumShapeSize().x);
    gameWidth = board.getRightEdge()+nextPlayerSize+(TILESIZE * 4);
    gameHeight = board.getBottomEdge();
    updateGameSize();
    
    timers = new HashMap<String, Float>();
    timers.put("keyLeft",0f);
    timers.put("keyRight",0f);
    timers.put("keyDown",0f);
    timers.put("gameStart1",0f);
    timers.put("gameStart2",0f);
    timers.put("gameStart3",0f);
  }
  if (!gameover && !newGame && !paused) {
    if (isKeyDown("left")) {
      timers.put("keyLeft",timers.get("keyLeft")+time);
      if (timers.get("keyLeft")>500) {
        board.player.move(-1,0);
      }
    }
    if (isKeyDown("right") && timers.get("keyRight")>200) {
      timers.put("keyRight",timers.get("keyRight")+time);
      if (timers.get("keyRight")>500) {
        board.player.move(1,0);
      }
    }
    
    if (isKeyDown("up") && !wasKeyDown("up")) {
      Shape p = board.player; 
      if (p.blocks.length>0) {
        p.shift();
      }
    }
    for (HashMap.Entry<String,Boolean> entry : keysDown.entrySet()) {
      wereKeysDown.put(entry.getKey(),false);
      wereKeysDown.put(entry.getKey(),entry.getValue());
    }
    timers.put("keyDown",timers.get("keyDown")+time);
    
    board.player.checkCollisions();
    
    scoreFont.update(time);
    comboFont.update(time);
    // If this is a new high score
    // Update save file
    if (score>config.get("highScore")) {
      config.set("highScore", score);
      config.save();
    }
  }  
  else if (gameover) {
    board.fillUp(time);
  }
  /*else if (newGame) {
    if (timers.get("gameStart1")==0) {
      playSound("ready");
    }
    timers.put("gameStart1",timers.get("gameStart1")+time);
    if (timers.get("gameStart1")>1000 && timers.get("gameStart2")==0) {
      playSound("set");
    }
    if (timers.get("gameStart1")>1000 && timers.get("gameStart3")==0) {
      timers.put("gameStart2",timers.get("gameStart2")+time);
      if (timers.get("gameStart2")>1000) {
        playSound("go");  
      }
    }
    if (timers.get("gameStart2")>1000) {
      timers.put("gameStart3",timers.get("gameStart3")+time);
      if (timers.get("gameStart3")>750) {
        newGame();
      }
    }
  }*/
  if (!paused) {
    board.update(time);
  }
  drawGameBackground();
  board.display();
  if (paused) {
    drawImage("paused",11,60);
  }
  drawImageStack(time);
  scoreFont.write(str(score),65,4);
  scoreFont.write(str(config.get("highScore")),gameWidth-3,4);
  /*if (combos>2) {
    drawImage(getImage("combo"), 17, 39);
    drawImage(getImage("combo_star"), 11, 60);
    drawImage(getImage("combo_star"), 23, 42);
    drawImage(getImage("combo_star"), 26, 73);
    drawImage(getImage("combo_star"), 48, 36);
    drawImage(getImage("combo_star"), 46, 78);
    drawImage(getImage("combo_star"), 56, 63);
  }*/
  sim.update(time);
  sim.display();
  comboFont.display();
  
  /*if (newGame) {
    if (timers.get("gameStart1")<1000 && timers.get("gameStart2")==0) {
      drawImage(getImage("ready_txt"),11,60);
    }
    else if (timers.get("gameStart2")<1000) {
      drawImage(getImage("set_txt"),11,60);
    }
    else if (timers.get("gameStart3")<1000) {
      drawImage(getImage("go_txt"),11,60);
    }
  }*/
}

public void gameOver() {
  newGame = true;
  gameover = false;
  level = 0;
  score = 0;
  board.setNextPlayer(null);
  config.save();
}

public void newGame() {
  if (newGame) {
    newGame = false;
    // Redraw the score bar
    drawMainBar();
    // Clear the board
    board.reset();
    score = 0;  
    // Create the next player
    board.setNextPlayer(randomShape());
    nextPlayer();
    
    // Reset the speed back to the original speed
    speed = initspeed;
    level = 0;
    score = 0;
    
    timers.put("gameStart1",0f);
    timers.put("gameStart2",0f);
    timers.put("gameStart3",0f);
  }
}