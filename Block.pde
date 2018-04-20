class Block {
  int x;
  int y;
  PVector loc;
  PImage img;
  PVector imgSize;
  String type;
  float timer;
  boolean explode;
  Block(int x, int y, String type) {
    this.x = x;
    this.y = y;
    this.type = type;
    updateLoc();
    if (getType().name!="blank") {
      img = getImage(getType().img);
      imgSize = imgToWorldCoords(img);
    }
  }
  public void updateLoc() {
    loc = toWorldCoords(new PVector(x*TILESIZE,y*TILESIZE));
  }
  public BlockType getType() {
    return blockTypes.get(type);  
  }
  public void display() {
    if (getType().name!="blank") {
      image(img,loc.x,loc.y,imgSize.x,imgSize.y);
    }
  }
  public boolean update(float delta) {
    boolean exploded = false;
    if (explode) {
      timer+=delta;
      if (timer<200) {
        img = getImage("block_explosion1");
      }
      else if (timer<400) {
        img = getImage("block_explosion2");
      }
      else if (timer>=400) {
        board.setBlock(x,y,"blank");  
        score++;
        exploded = true;
      }
    }
    return exploded;
  }
}

public Block makeBlock(int x, int y, String type) {
  return new Block(x,y,type);
}

HashMap<String,BlockType> blockTypes;

class BlockType {
  String name;
  String img;
  BlockType(String name, String img) {
    this.name = name;
    this.img = img;
  }
}

public void addBlockType(BlockType t) {
  blockTypes.put(t.name, t);
}

public void generateBlocks() {
  blockTypes = new HashMap<String,BlockType>();
  addBlockType(new BlockType("blank",""));
  addBlockType(new BlockType("blue","block_blue"));
  addBlockType(new BlockType("purple","block_purple"));
  addBlockType(new BlockType("green","block_green"));
  addBlockType(new BlockType("yellow","block_yellow"));
  addBlockType(new BlockType("red","block_red"));
  addBlockType(new BlockType("star","block_star"));
  addBlockType(new BlockType("n","block_n"));
  addBlockType(new BlockType("lightning","block_lightning"));
  addBlockType(new BlockType("stone","block_stone"));
}

class Shape{
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
  public void toBoard() {
    while (bottom<YTILES-1 && !colliding(x,y+1)) {
      this.y++;
      updateBounds();
    }
    if (top>=0) {
      for (Block b : blocks) {
        board.tiles[b.x+x][b.y+y] = makeBlock(b.x+x,b.y+y,b.type);
      }
    }
    blocks = new Block[]{};
  }
  public boolean colliding(int x1, int y1) {
    for (Block b : blocks) {
      if (blockExists(b.x+x1,b.y+y1) && board.tiles[b.x+x1][b.y+y1].getType().name!="blank") {
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
    if (right>XTILES-1) {
      x -= right-(XTILES-1);
    }
    updateBounds();
  }
  public void move(int x1, int y1) {
    if (!colliding(x+x1,y+y1)) {
      this.x += x1;
      this.y += y1;
    }
  }
  public void update(float delta) {
    updateBounds();
    timer+=delta;
    if (timer>speed) {
      // Move the shape down if it's not hitting the bottom
      if (bottom<YTILES-1 && !colliding(x,y+1)) {
        this.y++;
      }
      timer = 0;
    }
    // Game over || gameover
    if (colliding(x,y) && y==0) {
      //board.reset();
    }
    // If it hits the bottom add this to the board
    if (!(bottom<YTILES-1 && !colliding(x,y+1))) {
      toBoard = true;
    }
    if (toBoard) {
      toBoard();
    }
  }
  public void display(boolean myLoc) {
    pushMatrix();
    if (myLoc) {
      PVector loc = toWorldCoords(new PVector(x*TILESIZE,y*TILESIZE));
      translate(loc.x,loc.y);
    }
    for (Block b : blocks) {
      // Don't render the block if it's off the screen
      if (b.y+y>=0 || !myLoc) {
        b.display();
      }
    }
    popMatrix();
  }
  public void shift () {
    int firstX = blocks[0].x;
    int firstY = blocks[0].y;
    for (int i=0;i<blocks.length;i++) {
      if (i+1<blocks.length) {
        blocks[i].x = blocks[i+1].x;
        blocks[i].y = blocks[i+1].y;
      }
      else {
        blocks[i].x = firstX;
        blocks[i].y = firstY;
      }
      blocks[i].updateLoc();
    }
  }
}

public Shape randomShape() {
  //int x = int(random(XTILES));
  int x = 2;
  int y = 0;
  String[] types = new String[]{"blue","green","purple","yellow","red"};
  String type = "";
  Block[] blocks = new Block[]{};
  int shapeType = int(random(3));
  int rand;
  ArrayList<Block[][]> shapeTypes = new ArrayList<Block[]>();
  
  shapeTypes.add();
  /*switch (shapeType) {
    case 0:
      type = types[int(random(types.length))];
      blocks = new Block[]{makeBlock(0,0,type)};
      break;
    case 1:
      rand = int(random(2));
      switch (rand) {
        case 0:
          // O O 
          blocks = new Block[]{makeBlock(0,0,randomType(types)),makeBlock(1,0,randomType(types))};
          break;
        case 1:
          // O
          // O
          blocks = new Block[]{makeBlock(0,0,randomType(types)),makeBlock(0,1,randomType(types))};
          break;
      }
      break;
    case 2:
      rand = int(random(4));
      switch (rand) {
        case 0:
          // O O 
          //   O
          blocks = new Block[]{makeBlock(0,0,randomType(types)),makeBlock(1,0,randomType(types)),makeBlock(1,1,randomType(types))};
          break;
        case 1:
          // O  
          // O O
          blocks = new Block[]{makeBlock(0,0,randomType(types)),makeBlock(1,1,randomType(types)),makeBlock(0,1,randomType(types))};
          break;
        case 2:
          // O O 
          // O  
          blocks = new Block[]{makeBlock(0,0,randomType(types)),makeBlock(1,0,randomType(types)),makeBlock(0,1,randomType(types))};
          break;
        case 3:
          //   O 
          // O O
          blocks = new Block[]{makeBlock(1,0,randomType(types)),makeBlock(1,1,randomType(types)),makeBlock(0,1,randomType(types))};
          break;
      }
      break;
  }*/
  Shape rShape = new Shape(x,y,blocks);
  //Shape rShape = new Shape(x,y,new Block[]{makeBlock(1,0,type),makeBlock(1,1,type),makeBlock(0,0,type)});
  rShape.updateBounds();
  rShape.y -= rShape.bottom;
  rShape.checkCollisions();
  return rShape;
}

public void nextPlayer() {
  board.setPlayer(board.nextPlayer);
  board.setNextPlayer(randomShape());  
}