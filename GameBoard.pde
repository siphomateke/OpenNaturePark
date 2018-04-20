class GameBoard {
  PVector offset;
  int xOffset;
  int yOffset;
  Block[][] tiles;
  Shape player;
  Shape nextPlayer;
  PImage img;
  PVector imgSize;
  float timer;
  GameBoard(int xOffset, int yOffset) {
    // The offset to draw the game board
    this.xOffset = xOffset;
    this.yOffset = yOffset;
    offset = toWorldCoords(new PVector(xOffset, yOffset));
    // The array which stores the tiles
    tiles = new Block[XTILES][YTILES];
    // Start of with a balnk board
    for (int x=0; x<XTILES; x++) {
      for (int y=0; y<YTILES; y++) {
        setBlock(x,y,"blank");
      }
    }
    img = getImage("main_bg_main");
    imgSize = imgToWorldCoords(img);
    // Timer to keep track of when to next update
    timer = 0;
  }
  // Reset the board
  // called when game is over
  public void reset() {
    for (int x=0; x<XTILES; x++) {
      for (int y=0; y<YTILES; y++) {
        setBlock(x,y,"blank");
      }
    }
  }
  
  public void setBlock(int x, int y, String name) {
    tiles[x][y] = new Block(x, y, name);
  }
  public void setPlayer(Shape s) {
    player = s;  
  }
  public void setNextPlayer(Shape s) {
    nextPlayer = s;
  }
  
  public void display() {
    drawImage(getImage("main_bg_right"),72,15);
    pushMatrix();
    translate(offset.x, offset.y);
    // The offset of the image
    PVector v = toWorldCoords(new PVector(-5, -5));
    translate(v.x, v.y);
    image(img, 0, 0, imgSize.x, imgSize.y);
    translate(-v.x, -v.y);
    
    // Draw all the tiles on the board
    for (int x=0; x<XTILES; x++) {
      for (int y=0; y<YTILES; y++) {
        tiles[x][y].display();
      }
    }
    // Draw the player shape
    if (player!=null) {
      player.display(true);
    }
    translate(-offset.x, -offset.y);
    if (nextPlayer!=null) {
      float x1 = toWorldX(85)-(((nextPlayer.right-nextPlayer.left+1)/2)*TILESIZE)-(TILESIZE/2);
      float y1 = toWorldY(37)-(((nextPlayer.bottom-nextPlayer.top+1)/2)*TILESIZE)-(TILESIZE/2);
      translate(x1, y1);
      nextPlayer.display(false);
    }
    popMatrix();
  }
  public void update(float delta) {
    boolean stable = true;
    boolean appliedGravity = true;
    while (appliedGravity) {
      appliedGravity = false;
      for (int x=0; x<XTILES; x++) {
        for (int y=YTILES-1; y>=0; y--) {
          // Apply gravity if there is no block underneath
          if (blockExists(x,y+1,"blank") && tiles[x][y].type!="blank") {
            tiles[x][y+1] = makeBlock(x,y+1,tiles[x][y].type);
            tiles[x][y] = makeBlock(x,y,"blank");
            appliedGravity = true;
          }
        } 
      }
    }
    // Add delay between each explosion
    timer += delta;
    if (timer>speed/2) {
      int avgX = 0;
      int avgY = 0;
      int total = 0;
      boolean explode = false;
      for (int x=0; x<XTILES; x++) {
        for (int y=YTILES-1; y>=0; y--) {
          String type = tiles[x][y].getType().name;
          if (type!="blank") {
            if ( (blockExists(x+1,y,type) && blockExists(x-1,y,type) && !tiles[x+1][y].explode && !tiles[x-1][y].explode) ||
            (blockExists(x,y+1,type) && blockExists(x,y-1,type) && !tiles[x][y+1].explode && !tiles[x][y+1].explode) ||
            (blockExists(x+1,y+1,type) && blockExists(x-1,y-1,type) && !tiles[x+1][y+1].explode && !tiles[x-1][y-1].explode) ||
            (blockExists(x-1,y+1,type) && blockExists(x+1,y-1,type) && !tiles[x-1][y+1].explode && !tiles[x+1][y-1].explode)) {
              explode(x,y);
              explode = true;
              avgX+=x;
              avgY+=y;
              total+=1;
              stable = false;
              if (blockExists(x+1,y,type) && blockExists(x-1,y,type)) {
                explode(x+1,y);
                explode(x-1,y);
                avgX+=x+1;
                avgY+=y;
                avgX+=x-1;
                avgY+=y;
                total+=2;
              }
              if (blockExists(x,y+1,type) && blockExists(x,y-1,type)) {
                explode(x,y+1);
                explode(x,y-1);
                avgX+=x;
                avgY+=y+1;
                avgX+=x;
                avgY+=y-1;
                total+=2;
              }
              if (blockExists(x+1,y+1,type) && blockExists(x-1,y-1,type)) {
                explode(x+1,y+1);
                explode(x-1,y-1);
                avgX+=x+1;
                avgY+=y+1;
                avgX+=x-1;
                avgY+=y-1;
                total+=2;
              }
              if (blockExists(x-1,y+1,type) && blockExists(x+1,y-1,type)) {
                explode(x-1,y+1);
                explode(x+1,y-1);
                avgX+=x-1;
                avgY+=y+1;
                avgX+=x+1;
                avgY+=y-1;
                total+=2;
              }
            }
            if (blockExists(x,y+1,"blank")) {
              stable = false;  
            }
          }
        }   
      }
      if (explode) {
        combos++;
      }
      if (combos>=1 && total>0) {
        drawCombos(avgX/total,avgY/total);
      }
      // If stable add new player
      if (stable && player.blocks.length==0) {
        combos = 0;
        nextPlayer();
      }
      
      timer = 0;
    }
    for (int x=0; x<XTILES; x++) {
      for (int y=YTILES-1; y>=0; y--) {
        tiles[x][y].update(time);
      }
    }
    player.update(delta);
  }
  public void explode(int x,int y) {
    tiles[x][y].explode = true;  
  }
}

public void drawCombos(int x, int y) {
  comboFont.writeDelay(str(combos),1000,(x*TILESIZE)+board.xOffset+TILESIZE,(y*TILESIZE)+board.yOffset);  
}

public boolean blockExists(int x, int y, String name) {
  if (x<XTILES && x>=0 && y<YTILES && y>=0 && (board.tiles[x][y].getType().name==name || name==null)) {
    return true;
  } else {
    return false;
  }
}

public boolean blockExists(int x, int y) {
  return blockExists(x, y, null);
}