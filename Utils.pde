HashMap<String,PImage> images = new HashMap<String,PImage>(); 

public void addImage(String name, String path) {
  images.put(name,loadImage(path));
}

public PImage getImage(String img) {
  PImage result = images.get(img);
  if (result==null) {
    images.put(img,loadImage(img));
  }
  return result;
}

public void loadAllImages(String dir) {
  String otherFolder = dir;
  File folder = new File(dataPath("")+otherFolder);
  File[] files = folder.listFiles();
  if (files!=null) {
    for (File fileEntry : files) {
      if (!fileEntry.isDirectory()) {
        String fileName = fileEntry.getName();
        if (fileName.toLowerCase().endsWith(".png") || fileName.toLowerCase().endsWith(".jpg")) {
          String name = fileName.substring(0,fileName.indexOf("."));
          addImage(name,otherFolder+fileName);
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

public void drawImage(PImage img, int x, int y) {
  PVector size = imgToWorldCoords(img);
  image(img,toWorldX(x),toWorldY(y),size.x,size.y);
}

public void drawImage(String img, int x, int y) {
  drawImage(getImage(img),x,y);
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
  return (float(x)/float(REALWIDTH))*width;
}

public float toWorldY(int y) {
  return (float(y)/float(REALHEIGHT))*height;
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