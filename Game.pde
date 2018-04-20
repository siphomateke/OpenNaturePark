HashMap<String, Float> timers;
public void game(float time) {
  if (gameStateChanged) {
    background(#fefeaa);
    drawImage(getImage("main_bg_left"),0,15);
    drawImage(getImage("main_bg_top"),0,13);
    drawImage(getImage("main_bar"),0,0);
    drawImage(getImage("main_bg_bottom"),0,125);
    drawImage(getImage("main_bg_right"),72,15);
    drawImage(getImage("main_boat"),72,59);
    drawImage(cropImage("intro_buble",21,0,37,62),107,14);
    drawImage(getImage("main_wave"),72,121);
    
    // Create the game board
    board = new GameBoard(7,20);
    board.setNextPlayer(randomShape());
    nextPlayer();
    
    score = 0;
    highScore = 0;
    timers = new HashMap<String, Float>();
    timers.put("keyLeft",0f);
    timers.put("keyRight",0f);
    timers.put("keyDown",0f);
  }
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
  board.update(time);
  board.display();
  scoreFont.write(str(score),65,4);
  scoreFont.write(str(highScore),123,4);
  scoreFont.update(time);
  comboFont.update(time);
  if (score>highScore) {
    highScore = score;
  }
}

public String randomType(String[] types) {
  return types[int(random(types.length))];
}

class NumericFont {
  HashMap<String, String> imgs;
  int myWidth;
  int myHeight;
  ArrayList<FontText> toWrite;
  NumericFont(String[][] list) {
    imgs = new HashMap<String, String>();
    for (int i=0; i<list.length; i++) {
      imgs.put(list[i][1], list[i][0]);
    }
    PImage p = getImage(list[0][0]);
    myWidth = p.width+1;
    myHeight = p.height;
    toWrite = new ArrayList<FontText>();
  }

  public String getMyImage(String name) {
    return imgs.get(name);
  }

  public void write(String n, int x, int y) {
    int xWidth = myWidth*n.length();
    int xOffset = 0;
    for (int i=0; i<n.length(); i++) { 
      PImage img = getImage(getMyImage(str(n.charAt(i))));
      drawImage(img, x-xWidth+xOffset, y);
      xOffset += myWidth;
    }
  }
  
  public void writeDelay(String n, int delay, int x, int y) {
    toWrite.add(new FontText(n,delay,x,y));
  }
  
  public void update (float time) {
    ArrayList<Integer> toDelete = new ArrayList<Integer>();
    for (int i=0;i<toWrite.size();i++) {
      FontText ft = toWrite.get(i);
      ft.time += time;
      if (ft.time<ft.len) {
        write(ft.txt,ft.x,ft.y);
      }
      else {
        toDelete.add(i);
      }
    }
    for (Integer i : toDelete) {
      toWrite.remove(i);
    }
  }
}

class FontText {
  String txt;
  float len;
  float time;
  int x;
  int y;
  FontText(String txt,float len,int x,int y) {
    this.txt = txt;
    this.time = 0f;
    this.len = len;
    this.x = x;
    this.y = y;
  }
}