class GameBoard {
  PVector offset;
  int xOffset;
  int yOffset;
  Block[][] tiles;
  Shape player;
  Shape nextPlayer;
  GraphicRegion nextPlayerRegion;
  PImage img;
  PVector imgSize;
  float timer;
  float timer2;
  int fillProgress;
  float fillTimer;
  private PImage borderImage;
  GameBoard(int xOffset, int yOffset) {
    // The offset to draw the game board
    this.xOffset = xOffset;
    this.yOffset = yOffset;
    offset = toWorldCoords(new PVector(xOffset, yOffset));
    // The array which stores the tiles
    tiles = new Block[xTiles][yTiles];
    // Start of with a balnk board
    for (int x=0; x<xTiles; x++) {
      for (int y=0; y<yTiles; y++) {
        setBlock(x, y, "blank");
      }
    }

    borderImage = getImage("bg_border_tile");

    int w = int(getMaximumShapeSize().x * TILESIZE);
    int h = int(getMaximumShapeSize().y * TILESIZE);
    nextPlayerRegion = new GraphicRegion(this.getVisibleWidth(), borderImage.height, w, h, 2);

    generateBackground();
    // Timer to keep track of when to next update
    timer = 0;
    timer2 = 0;
    fillProgress = 0;
    fillTimer = 0;
  }
  public void drawBorder(PGraphics g, int offsetX, int offsetY, int width, int height) {
    // Width and height border inclusive
    int w = width + (borderImage.width * 2);
    int h = height + (borderImage.height * 2);
    // Create new graphics object to crop output
    PGraphics cropped = createGraphics(w,h);
    cropped.beginDraw();
    cropped.pushMatrix();
    // Draw the border tiles at the top and bottom of the screen
    for (int x=0;x<w/(borderImage.width-1);x++) {
      for (int y=0;y<2;y++) {
        cropped.image(borderImage,x*(borderImage.width-1),y*(height+borderImage.height));
      }
    }
    // Draw the border tiles on the left and right of the screen
    for (int y=0;y<h/(borderImage.height-1);y++) {
      for (int x=0;x<2;x++) {
        cropped.image(borderImage,x*(width+borderImage.width),y*(borderImage.height-1));
      }
    }
    cropped.popMatrix();
    cropped.endDraw();

    g.pushMatrix();
    g.translate(offsetX, offsetY);
    g.translate(-borderImage.width, -borderImage.height);
    g.image(cropped,0,0);
    g.popMatrix();
  }
  public void drawNextPlayerBackground(PGraphics g) {
    g.noStroke();
    g.fill(#ffffab);
    g.rect(
      nextPlayerRegion.x,
      nextPlayerRegion.y,
      nextPlayerRegion.width,
      nextPlayerRegion.height);
    g.fill(255,255,171);
    drawBorder(g, 
      nextPlayerRegion.x,
      nextPlayerRegion.y,
      nextPlayerRegion.width,
      nextPlayerRegion.height);
  }
  public void generateBackground() {
    int h = getVisibleHeight();
    int w = getVisibleWidth()+nextPlayerRegion.width+borderImage.width;
    if (h < nextPlayerRegion.height) {
      h = nextPlayerRegion.height;
    }
    PGraphics g = createGraphics(w,h);
    g.beginDraw();
    
    drawBorder(g, borderImage.width, borderImage.height, getWidth(), getHeight());
    drawNextPlayerBackground(g);
    
    // Draw the actual game background tiles
    g.translate(borderImage.width, borderImage.height);
    PImage i = getImage("bg_tile");
    for (int x=0; x<xTiles; x++) {
      for (int y=0; y<yTiles; y++) {
        g.image(i, x*TILESIZE, y*TILESIZE);
      }
    }
    g.endDraw();
    img = g;
    imgSize = imgToWorldCoords(img);
  }
  public int getWidth() {
    return xTiles * TILESIZE;
  }
  public int getHeight() {
    return yTiles * TILESIZE;
  }
  public int getVisibleWidth() {
    return getWidth() + borderImage.width*2;
  }
  public int getVisibleHeight() {
    return getHeight() + borderImage.height*2;
  }
  public int getLeftEdge() {
    return this.xOffset;
  }
  public int getRightEdge() {
    return this.getLeftEdge()+this.getVisibleWidth();
  }
  public int getTopEdge() {
    return this.yOffset;
  }
  public int getBottomEdge() {
    return this.getTopEdge()+this.getVisibleHeight();
  }
  // Reset the board
  // called when game is over
  public void reset() {
    for (int x=0; x<xTiles; x++) {
      for (int y=0; y<yTiles; y++) {
        setBlock(x, y, "blank");
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

  public void drawNextPlayer() {
    if (nextPlayer!=null) {
      pushMatrix();
      PVector nextPlayerCenter = nextPlayer.getCenter().mult(TILESIZE);
      float x1 = nextPlayerRegion.x + (nextPlayerRegion.width / 2) - nextPlayerCenter.x;
      float y1 = nextPlayerRegion.y + (nextPlayerRegion.height / 2) - nextPlayerCenter.y;
      translate(toWorldX(int(x1)), toWorldY(int(y1)));
      nextPlayer.display(false);
      popMatrix();
    }
  }

  public void display() {
    pushMatrix();
    translate(offset.x, offset.y);
    // The offset of the image
    image(img, 0, 0, imgSize.x, imgSize.y);

    drawNextPlayer();

    g.translate(toWorldX(borderImage.width), toWorldY(borderImage.height));
    // Draw all the tiles on the board
    for (int x=0; x<xTiles; x++) {
      for (int y=0; y<yTiles; y++) {
        tiles[x][y].display();
      }
    }
    // Draw the player shape
    if (player!=null) {
      player.display(true);
    }
    popMatrix();
  }
  
  public void fillUp(float delta) {
    String[] rainbow = new String[]{"red","yellow","green","blue","purple"};
    fillTimer += delta;
    if (fillTimer>100) {
      fillProgress++;
      fillTimer = 0;
      boolean filled = false;
      outerloop:
      for (int y=yTiles-1; y>=0; y--) {
        for (int x=0; x<xTiles; x++) {
          if (!filled) {
            if (tiles[x][y].getType().name=="blank") {
              setBlock(x,y,rainbow[y%5]);
              filled = true;
            }
          }
          else {
            break outerloop;
          }
        }
      }
      if (!filled) {
        gameOver();
      }
    }
  }
  public void update(float delta) {
    if (!gameover && !newGame) {
      boolean stable = true;
      boolean appliedGravity = true;
      while (appliedGravity) {
        appliedGravity = false;
        for (int x=0; x<xTiles; x++) {
          for (int y=yTiles-1; y>=0; y--) {
            // Apply gravity if there is no block underneath
            if (blockExists(x, y+1, "blank") && tiles[x][y].type!="blank") {
              tiles[x][y+1] = makeBlock(x, y+1, tiles[x][y].type);
              tiles[x][y] = makeBlock(x, y, "blank");
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
        for (int x=0; x<xTiles; x++) {
          for (int y=yTiles-1; y>=0; y--) {
            String type = tiles[x][y].getType().name;
            if (type!="blank") {
              if (type!="lightning" && type!="star" && type!="n" && type!="stone") {
                if ( (blockExists(x+1, y, type) && blockExists(x-1, y, type) && !tiles[x+1][y].explode && !tiles[x-1][y].explode) ||
                  (blockExists(x, y+1, type) && blockExists(x, y-1, type) && !tiles[x][y+1].explode && !tiles[x][y+1].explode) ||
                  (blockExists(x+1, y+1, type) && blockExists(x-1, y-1, type) && !tiles[x+1][y+1].explode && !tiles[x-1][y-1].explode) ||
                  (blockExists(x-1, y+1, type) && blockExists(x+1, y-1, type) && !tiles[x-1][y+1].explode && !tiles[x+1][y-1].explode)) {
                  explode(x, y);
                  avgX+=x;
                  avgY+=y;
                  total+=1;
                  //stable = false; 
                  ArrayList<PVector> explodePositions = new ArrayList<PVector>();
                  // Horizontal
                  if (blockExists(x+1, y, type) && blockExists(x-1, y, type)) {
                    explodePositions.add(new PVector(x+1, y));
                    explodePositions.add(new PVector(x-1, y));
                    explodePositions.add(new PVector(x+2, y));
                    explodePositions.add(new PVector(x-2, y));
                  }
                  // Vertical
                  if (blockExists(x, y+1, type) && blockExists(x, y-1, type)) {
                    explodePositions.add(new PVector(x, y+1));
                    explodePositions.add(new PVector(x, y-1));
                    explodePositions.add(new PVector(x, y+2));
                    explodePositions.add(new PVector(x, y-2));
                  }
                  // Diagonal 1
                  if (blockExists(x+1, y+1, type) && blockExists(x-1, y-1, type)) {
                    explodePositions.add(new PVector(x+1, y+1));
                    explodePositions.add(new PVector(x-1, y-1));
                    explodePositions.add(new PVector(x+2, y+2));
                    explodePositions.add(new PVector(x-2, y-2));
                  }
                  // Diagonal 2
                  if (blockExists(x-1, y+1, type) && blockExists(x+1, y-1, type)) {
                    explodePositions.add(new PVector(x-1, y+1));
                    explodePositions.add(new PVector(x+1, y-1));
                    explodePositions.add(new PVector(x-2, y+2));
                    explodePositions.add(new PVector(x+2, y-2));
                  }
  
                  for (PVector p : explodePositions) {
                    int px = int(p.x);
                    int py = int(p.y);
                    if (blockExists(px, py, type)) {
                      explode(px, py);
                      avgX+=px;
                      avgY+=py;
                      total+=1;
                    }
                  }
                }
              } else if (type=="n") {
                explode(x, y);
                avgX+=x;
                avgY+=y;
                total+=1;
                //stable = false;
  
                explode(x+1, y);
                explode(x-1, y);
                explode(x, y+1);
                explode(x, y-1);
                explode(x+1, y-1);
                explode(x+1, y+1);
                explode(x-1, y-1);
                explode(x-1, y+1);
              } else if (type=="lightning") {
                avgX+=x;
                avgY+=y;
                total+=1;
                //stable = false;
  
                // Explode all blocks below
                for (int j=y; j<yTiles; j++) {
                  explode(x, j);
                }
              }
              // Explode all the same color
              else if (type=="star" && blockExists(x, y+1)) {
                explode(x, y);
                String typeCheck = tiles[x][y+1].getType().name;
                for (int x2=0; x2<xTiles; x2++) {
                  for (int y2=yTiles-1; y2>=0; y2--) {
                    if (tiles[x2][y2].getType().name==typeCheck) {
                      explode(x2, y2);
                    }
                  }
                }
              }
            }
          }
        }
        // Broken -/- 
        if (isExploding()) {
          combos++;
        }
        if (combos>1 && total>0) {
          animals.get(animalTypes.get(animal)).setEmotion("happy",2000);
          int xc = avgX/total;
          int yc = avgY/total;  
          drawCombos(xc, yc);
          sim.explode((xc*TILESIZE)+board.xOffset, (yc*TILESIZE)+board.yOffset);
        }
  
        timer = 0;
      }
      // If stable add new player
      if (isStable() && player.blocks.length==0) {
        timer2+=time;
        // if (timer2>nextPlayerDelay) {
        if (timer2>speed) {
          combos = 1;
          timer2 = 0;
          nextPlayer();
        }
      }
      player.update(delta);
    }
    for (int x=0; x<xTiles; x++) {
      for (int y=yTiles-1; y>=0; y--) {
        tiles[x][y].update(time);
      }
    }
  }
  public void explode(int x, int y) {
    if (blockExists(x, y)) {
      tiles[x][y].explode = true;
    }
  }
  public boolean isStable() {
    boolean stable = true;
    loop:
    for (int x=0; x<xTiles; x++) {
      for (int y=yTiles-1; y>=0; y--) {
        if (tiles[x][y].getType().name!="blank") {
          // If this will fall or disappear then it's unstable
          if (blockExists(x, y+1, "blank") || tiles[x][y].explode || (blockExists(x, y+1) && tiles[x][y+1].explode)) {
            stable = false;
            break loop;
          }
        }
      }
    }
    return stable;
  }
  public boolean isExploding() {
    boolean exploding = false;
    loop:
    for (int x=0; x<xTiles; x++) {
      for (int y=yTiles-1; y>=0; y--) {
        if (tiles[x][y].getType().name!="blank") {
          if (tiles[x][y].exploding) {
            exploding = true;
            break loop;
          }
        }
      }
    }
    return exploding;
  }
}

public void drawCombos(int x, int y) {
  comboFont.writeDelay(str(combos), 1000, (x*TILESIZE)+board.xOffset+TILESIZE, (y*TILESIZE)+board.yOffset);
  //comboFont.writeDelay(str(combos), 1000, 34, 56);
}

public boolean blockExists(int x, int y, String name) {
  if (x<xTiles && x>=0 && y<yTiles && y>=0 && ((board.tiles[x][y].getType().name==name || (name=="any" && board.tiles[x][y].getType().name!="blank")) || name==null)) {
    return true;
  } else {
    return false;
  }
}

public boolean blockExists(int x, int y) {
  return blockExists(x, y, null);
}