class Animal {
  float timer;
  int currentFrame;
  String state;
  HashMap<String, Frame[]> states;
  Animal () {
    timer = 0;
    state = "default";
    states = new HashMap<String, Frame[]>();
    this.addState("default",new Frame[]{new Frame(getImage("bunny_face"),2)});
  }
  
  public void addState(String s, Frame[] f) {
    this.states.put(s, f);
  }
  
  public void update (float delta) {
    timer+=delta;
    // Increment current frame based on preset time
    if (currentFrame>=states.get(state).length) {
      currentFrame = 0;
    }
    if (timer>states.get(state)[currentFrame].len) {
      currentFrame++;
      timer = 0;
    }
    if (currentFrame>=states.get(state).length) {
      currentFrame = 0;
    }  
  }
}

class Frame {
  PImage img;
  int len;
  Frame(PImage i, int t) {
    img = i;
    len = t;
  }
}