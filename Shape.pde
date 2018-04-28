class Shape {
  int x;
  int y;
  Block[] blocks;
  float timer;
  int left;
  int right;
  int top;
  int bottom;
  boolean toBoard;
  Shape(int x, int y, Block[] blocks) {
    this.x = x;
    this.y = y;
    this.blocks = blocks;
    timer = 0;
    left = -1;
    right = -1;
    top = -1;
    bottom = -1;
    toBoard = false;
  }
  public void updateBounds() {
    left = -1;
    right = -1;
    top = -1;
    bottom = -1;
    for (Block b : blocks) {
      if (b.x>right || right==-1) {
        right = b.x;
      }
      if (b.x<left || left==-1) {
        left = b.x;
      }
      if (b.y<top || top==-1) {
        top = b.y;
      }
      if (b.y>bottom || bottom==-1) {
        bottom = b.y;
      }
    }
    right += x;
    left += x;
    top += y;
    bottom += y;
  }
  public PVector getCenter() {
    return new PVector(
      (right - left + 1) / 2.0f,
      (bottom - top + 1) / 2.0f
    );
  }
  public void toBoard() {
    while (bottom<config.getInt("yTiles")-1 && !colliding(x, y+1)) {
      this.y++;
      updateBounds();
    }
    for (Block b : blocks) {
      if (b.y+y>=0) {
        board.tiles[b.x+x][b.y+y] = makeBlock(b.x+x, b.y+y, b.type);
      } else {
        gameover = true;
      }
    }
    blocks = new Block[]{};
  }
  public boolean colliding(int x1, int y1) {
    for (Block b : blocks) {
      if (blockExists(b.x+x1, b.y+y1) && !"blank".equals(board.tiles[b.x+x1][b.y+y1].getType().name)) {
        return true;
      }
    }
    return false;
  }
  public void checkCollisions() {
    updateBounds();
    if (left<0) {
      x = 0;
    }
    if (right>config.getInt("xTiles")-1) {
      x -= right-(config.getInt("xTiles")-1);
    }
    updateBounds();
  }
  public void move(int x1, int y1) {
    if (!colliding(x+x1, y+y1)) {
      this.x += x1;
      this.y += y1;
    }
  }
  public void update(float delta) {
    updateBounds();
    timer+=delta;
    if (timer>speed) {
      // Move the shape down if it's not hitting the bottom
      if (bottom<config.getInt("yTiles")-1 && !colliding(x, y+1)) {
        this.y++;
      }
      // If it hits the bottom add this to the board
      else {
        toBoard = true;
      }
      timer = 0;
    }
    updateBounds();
    // Game over || gameover
    if (colliding(x, y) && top<=0) {
      gameover = true;
    }
    if (toBoard) {
      toBoard();
    }
  }
  public void display(boolean myLoc) {
    pushMatrix();
    if (myLoc) {
      PVector loc = toWorldCoords(new PVector(x*TILESIZE, y*TILESIZE));
      translate(loc.x, loc.y);
    }
    for (Block b : blocks) {
      // Don't render the block if it's off the screen
      if (b.y+y>=0 || !myLoc) {
        b.display();
      }
    }
    popMatrix();
  }
  // Rotate the blocks positions
  public void shift () {
    int firstX = blocks[0].x;
    int firstY = blocks[0].y;
    for (int i=0; i<blocks.length; i++) {
      if (i+1<blocks.length) {
        blocks[i].x = blocks[i+1].x;
        blocks[i].y = blocks[i+1].y;
      } else {
        blocks[i].x = firstX;
        blocks[i].y = firstY;
      }
      blocks[i].updateLoc();
    }
  }
}

class ShapeType {
  PVector[][] blocks;
  boolean canBeSpecial;
  ShapeType(PVector[][] blocks, boolean canBeSpecial) {
    this.blocks = blocks;
    this.canBeSpecial = canBeSpecial;
  }
  ShapeType(PVector[][] blocks) {
    this(blocks, false);
  }
}

ArrayList<ShapeType> shapeTypes = new ArrayList<ShapeType>();
ArrayList<ShapeType> possibleShapeTypes = new ArrayList<ShapeType>();
public void addShapeType(ShapeType b, float chance) {
  possibleShapeTypes.add(b);
  for (int i=0; i<chance*100; i++) {
    shapeTypes.add(b);
  }
}

public PVector getShapeSize(PVector[] blocks) {
  float left = -1;
  float right = -1;
  float top = -1;
  float bottom = -1;
  for (PVector v : blocks) {
    if (v.x>right || right==-1) {
      right = v.x;
    }
    if (v.x<left || left==-1) {
      left = v.x;
    }
    if (v.y<top || top==-1) {
      top = v.y;
    }
    if (v.y>bottom || bottom==-1) {
      bottom = v.y;
    }
  }
  return new PVector((abs(right-left)+1), (abs(bottom-top)+1));
}

public PVector getMaximumShapeSize() {
  PVector maxSize = new PVector();
  for (ShapeType shapeType : possibleShapeTypes) {
    for (int rotation=0;rotation<shapeType.blocks.length;rotation++) {
      PVector size = getShapeSize(shapeType.blocks[rotation]);
      if (size.x > maxSize.x) {
        maxSize.x = size.x;
      }
      if (size.y > maxSize.y) {
        maxSize.y = size.y;
      }
    }
  }
  return maxSize;
}

ArrayList<ArrayList<String>> colorTypes = new ArrayList<ArrayList<String>>();
ArrayList<ArrayList<String>> specialColorTypes = new ArrayList<ArrayList<String>>();  
public void initColorTypes() {
  for (int i=0;i<numLevels;i++) {
    colorTypes.add(i,new ArrayList<String>());
    specialColorTypes.add(i,new ArrayList<String>());
  }
}
public void addColorType(String c, float chance, int lvl, boolean special) {
  for (int i=0; i<chance*100; i++) {
    for (int j=lvl;j<numLevels;j++) {
      if (!special) {
        colorTypes.get(j).add(c);
      }
      
      specialColorTypes.get(j).add(c);
    }
  }
}

public void addColorType(String c, float chance, int lvl) {
  addColorType(c, chance, lvl, false);
}

public String randomType(boolean special) {
  // Select a random type based on the current level
  if (special) {
    return specialColorTypes.get(level).get(int(random(specialColorTypes.get(level).size())));
  } else {
    return colorTypes.get(level).get(int(random(colorTypes.get(level).size())));
  }
}

public String randomType() {
  return randomType(false);
}

public void initRandomShapeGen() {
  initColorTypes();
  
  addColorType("blue", 0.5, 0);
  addColorType("yellow", 0.5, 0);
  addColorType("red", 0.5, 0);
  addColorType("green", 0.5, 0);
  addColorType("purple", 0.5, 1);
  addColorType("stone", 0.2, 3);
  // 0.15 for specials
  addColorType("n", 0.3, 2, true);
  addColorType("lightning", 0.3, 2, true);
  addColorType("star", 0.3, 2, true);

  // 1
  addShapeType(new ShapeType(new PVector[][]{
    // O 
    new PVector[]{new PVector(0, 0)}, 
    }, true // Can be a speical block
    ), 0.1); // Probability

  // 2
  addShapeType(new ShapeType(new PVector[][]{
    // O O 
    new PVector[]{new PVector(0, 0), new PVector(1, 0)}, 
    // O
    // O
    new PVector[]{new PVector(0, 0), new PVector(0, 1)}, 
    }), 0.2);

  // 3
  addShapeType(new ShapeType(new PVector[][]{
    // O O 
    //   O
    new PVector[]{new PVector(0, 0), new PVector(1, 0), new PVector(1, 1)}, 
    // O  
    // O O
    new PVector[]{new PVector(0, 0), new PVector(1, 1), new PVector(0, 1)}, 
    // O O 
    // O  
    new PVector[]{new PVector(0, 0), new PVector(1, 0), new PVector(0, 1)}, 
    //   O 
    // O O
    new PVector[]{new PVector(1, 0), new PVector(1, 1), new PVector(0, 1)}, 
    }), 0.4);

  // 3.5
  addShapeType(new ShapeType(new PVector[][]{
    // O O O
    new PVector[]{new PVector(0, 0), new PVector(1, 0), new PVector(2, 0)}, 
    // O
    // O
    // O
    new PVector[]{new PVector(0, 0), new PVector(0, 1), new PVector(0, 2)}, 
    }), 0.3);
}

public Shape randomShape() {
  int x = 2;
  int y = 0;

  // Choose a random shape type
  int rand = int(random(shapeTypes.size()));
  ShapeType st = shapeTypes.get(rand);

  // Choose a random orientation
  int rotation = int(random(st.blocks.length));

  Block[] blocks = new Block[st.blocks[rotation].length];
  // For each position vector generate a new random block
  for (int i=0; i<st.blocks[rotation].length; i++) {
    PVector v = st.blocks[rotation][i];
    String type = randomType(); 
    if (st.canBeSpecial) {
      type = randomType(true);
    }
    blocks[i] = makeBlock(int(v.x), int(v.y), type);
  }

  // Make the new shape
  Shape rShape = new Shape(x, y, blocks);
  // Ensure it's on not off the screen on the x-axis
  rShape.updateBounds();
  rShape.y -= rShape.bottom;
  rShape.checkCollisions();
  return rShape;
}

public void nextPlayer() {
  board.setPlayer(board.nextPlayer);
  board.setNextPlayer(randomShape());
  if (speed>fastestSpeed) {
    speed-=((initspeed-fastestSpeed)/config.getInt("numToFastest"));
    level = (initspeed-speed) / ((initspeed-fastestSpeed)/numLevels);
  }
}