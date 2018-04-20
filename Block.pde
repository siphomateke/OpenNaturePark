class Block {
  int x;
  int y;
  PVector loc;
  PImage img;
  PVector imgSize;
  String type;
  float timer;
  boolean explode;
  boolean exploding;
  Block(int x, int y, String type) {
    this.x = x;
    this.y = y;
    this.type = type;
    updateLoc();
    if (getType().name!="blank") {
      img = getImage(getType().img);
      imgSize = imgToWorldCoords(img);
    }
    explode = false;
    exploding = false;
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
  public void update(float delta) {
    if (explode) {
      timer+=delta;
      if (timer>(speed/2.5) && timer<(speed/1.6)) {
        exploding = true;
        img = getImage("block_explosion1");
      }
      else if (timer>=(speed/1.6) && timer<(speed/1.25)) {
        img = getImage("block_explosion2");
      }
      else if (timer>=(speed/1.25)) {
        board.setBlock(x,y,"blank");  
        score+=(combos-1);
      }
    }
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
  // Destroy blocks of same color
  addBlockType(new BlockType("star","block_star"));
  // Nuke all blocks in surrounding area
  addBlockType(new BlockType("n","block_n"));
  // Destroy column of blocks
  addBlockType(new BlockType("lightning","block_lightning"));
  // Can only be destroyed by special blocks
  addBlockType(new BlockType("stone","block_stone"));
}