HashMap<String,PImage> images = new HashMap<String,PImage>(); 

public void addImageAbsolute(String name, String path) {
  images.put(name,loadImage(path));
}

public void addImage(String name, String path) {
  String extension = "";
  int i = path.lastIndexOf('.');
  if (i <= 0) {
    path = path+".png";
  }
  addImageAbsolute(name, "./"+path);
}

public void addImage(String name, String path, String fileType) {
  addImage(name, path+"."+fileType);
}

public PImage getImage(String img) {
  return images.get(img);
}

public static String combine (String path1, String path2) {
    File file1 = new File(path1);
    File file2 = new File(file1, path2);
    return file2.getPath();
}

public void loadAllImages(String dir) {
  File folder = new File(combine(dataPath(""),dir));
  File[] files = folder.listFiles();
  if (files!=null) {
    for (File fileEntry : files) {
      if (!fileEntry.isDirectory()) {
        String fileName = fileEntry.getName();
        if (fileName.toLowerCase().endsWith(".png") || fileName.toLowerCase().endsWith(".jpg")) {
          String name = fileName.substring(0,fileName.lastIndexOf("."));
          addImageAbsolute(name,fileEntry.getPath());
        }
      }
    }
  }
}

public PImage cropImage(String name, int x, int y, int w, int h) {
  PImage img = getImage(name);
  PGraphics g = createGraphics(w,h);
  g.beginDraw();
  g.image(img,-x,-y);
  g.endDraw();
  return g.get(0,0,w,h);
}

public void drawImage(PImage img, int x, int y, float scale, float angle) {
  PVector size = imgToWorldCoords(img);
  pushMatrix();
  translate(toWorldX(x),toWorldY(y));
  translate(size.x/2,size.y/2);
  rotate(angle);
  scale(scale);
  translate(-size.x/2,-size.y/2);
  image(img,0,0,size.x,size.y);
  popMatrix();
}

public void drawImage(PImage img, int x, int y) {
  drawImage(img,x,y,1,0);
}

public void drawImage(String img, int x, int y, float angle) {
  drawImage(getImage(img),x,y,1,angle);
}

public void drawImage(String img, int x, int y) {
  drawImage(img,x,y,0);
}

public void drawImage(String img, int x, int y, float scale, float angle) {
  drawImage(getImage(img),x,y,scale,angle);
}

class StackImg{
  String img;
  int x;
  int y;
  float delay;
  float timer;
  StackImg(String img, int x, int y, float delay) {
    this.img = img;
    this.x = x;
    this.y = y;
    this.timer = 0;
    this.delay = delay;
  }
}

ArrayList<StackImg> imageStack = new ArrayList<StackImg>();
public void drawImageDelay(String img, int x, int y, float delay) {
  imageStack.add(new StackImg(img,x,y,delay));
}

public void drawImageStack(float time) {
  ArrayList<StackImg> tmpImageStack = new ArrayList<StackImg>(imageStack);
  for (StackImg s : tmpImageStack) {
    if (s.timer<s.delay) {
      drawImage(s.img,s.x,s.y);
      s.timer+=time;
    }
    else {
      imageStack.remove(s);
    }
  }
}

public PVector imgToWorldCoords(PImage img) {
  return toWorldCoords(new PVector(img.width,img.height));
}

public PVector toWorldCoords(PVector coord) {
  PVector vec = new PVector();
  vec.x = toWorldX(int(coord.x));
  vec.y = toWorldY(int(coord.y));
  return vec;
}

public float toWorldX(int x) {
  return (float(x)/float(gameWidth))*windowWidth;
}

public float toWorldY(int y) {
  return (float(y)/float(gameHeight))*windowHeight;
}

public PVector toGameCoords(PVector coord) {
  PVector vec = new PVector();
  vec.x = toGameX(int(coord.x));
  vec.y = toGameY(int(coord.y));
  return vec;
}

public float toGameX(int x) {
  return (float(x)/float(windowWidth))*gameWidth;
}

public float toGameY(int y) {
  return (float(y)/float(windowHeight))*gameHeight;
}

HashMap<String, Boolean> keysDown = new HashMap<String, Boolean>();
HashMap<String, Boolean> wereKeysDown = new HashMap<String, Boolean>();
public void setMove(String k, boolean c, boolean b) {
  if (c) {
    switch (int(k)) {
    case UP:
      k = "up";
      break;
    case DOWN:
      k = "down";
      break;
    case LEFT:
      k = "left";
      break;
    case RIGHT:
      k = "right";
      break;
    case ESC:
      k = "esc";
      break;
    case CONTROL:
      k = "control";
      break;
    }
  }
  keysDown.put(k, b);
}

public boolean isKeyDown(String g) {
  boolean r = false;
  if (keysDown.containsKey(g)) {
    if (keysDown.get(g)) {
      r = true;
    }
  } else {
    r = false;
  }
  return r;
}

public boolean wasKeyDown(String g) {
  boolean r = false;
  if (wereKeysDown.containsKey(g)) {
    if (wereKeysDown.get(g)) {
      r = true;
    }
  } else {
    r = false;
  }
  return r;
}

class GraphicRegion {
  int margin;
  int x;
  int y;
  int width;
  int height;
  int innerX;
  int innerY;
  int innerWidth;
  int innerHeight;
  GraphicRegion(int x, int y, int width, int height, int margin) {
    this.x = x;
    this.y = y;
    this.margin = margin;
    this.innerX = this.x + this.margin;
    this.innerY = this.y + this.margin;
    this.innerWidth = width;
    this.innerHeight = height;
    this.width = this.innerWidth + (this.margin * 2);
    this.height = this.innerHeight + (this.margin * 2);
  }
  GraphicRegion(int x, int y, int width, int height) {
    this(x, y, width, height, 0);
  }
}