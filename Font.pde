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
  
  public void display() {
    for (int i=0;i<toWrite.size();i++) {
      FontText ft = toWrite.get(i);
      if (ft.time<ft.len) {
        write(ft.txt,ft.x,ft.y);
      }
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