class Animal {
  float timer;
  HashMap<String, Float> timers;
  HashMap<String, Float> timerLengths;
  HashMap<String, HashMap<String, Frame>> components;
  int type;
  boolean visible;
  String emotion;
  int myX;
  int myY;
  PVector target;
  Animal (int type, int x, int y) {
    this.type = type;
    timer = 0;
    timers = new HashMap<String, Float>();
    timerLengths = new HashMap<String, Float>();
    components = new HashMap<String, HashMap<String, Frame>>();
    setComponent("wheel", new Frame[] {new Frame("wheel", 18, 47)});
    setComponent("mainWave", new Frame[] {new Frame("main_wave", 0, 69)});
    visible = true;
    emotion = "normal";
    addTimer("blink");
    addTimer("blinking");
    addTimer("emotion");
    myX = x;
    myY = y;
    target = new PVector(myX, myY);
  }

  public void setComponent(String s, Frame[] frames) {
    HashMap<String, Frame> q = new HashMap<String, Frame>();
    for (Frame f : frames) {
      q.put(f.name, f);
    }
    this.components.put(s, q);
  }

  public void addTimer(String name) {
    resetTimer(name);
  }

  public void resetTimer(String name) {
    timers.put(name, 0f);
    timerLengths.put(name, 0f);
  }

  public float getTimer(String name) {
    return timers.get(name);
  }

  public boolean timerOver(String name) {
    return getTimer(name) >= timerLengths.get(name);
  }

  public void update (float delta) {
    timer+=delta;
    for (HashMap.Entry<String, Float> e : timers.entrySet()) {
      if (e.getValue() < timerLengths.get(e.getKey())) {
        timers.put(e.getKey(), e.getValue()+delta);
      }
    }
    target = toGameCoords(new PVector(mouseX, mouseY));
  }

  public void display(int x, int y, String cEye, String cMouth, boolean crying, boolean intro) {
    if (visible) {
      int move = int(timer/500%2);
      x+=myX;
      y+=myY;
      y+=move;
      //drawImage("main_boat",x,y+8);
      drawComponent("boat", x, y);
      /*drawImage("intro_buble",61,31+move);
       drawImage("intro_buble",30,31+move);*/
      drawComponent("face", x, y);

      if (timerOver("blink") && timerOver("blinking")) {
        resetTimer("blink");
        // Blink every 10 seconds
        timerLengths.put("blink", 10000f);
        resetTimer("blinking");
        // Blink for 0.15 seconds
        timerLengths.put("blinking", 150f);
      }

      int eX = 0;
      int eY = 0;
      /*
      // Follow mouse with eyes
      PVector eyeLoc = getComponentLoc("eye", cEye);
      PVector diff = PVector.sub(target, new PVector(eyeLoc.x+x, eyeLoc.y+y)).normalize().mult(2);
      eX = int(diff.x);
      eY = int(diff.y);*/
      if (!timerOver("blinking") && (cEye=="normal" || cEye=="suprised")) {
        drawComponent("eye", "closed", x+eX, y+eY);
      } else {
        drawComponent("eye", cEye, x+eX, y+eY);
      }

      if (crying) {
        int move2 = int((timer+250)/500%2);
        drawComponent("tear", x, y+move2);
      }

      drawComponent("mouth", cMouth, x, y);
      drawComponent("wheel", x, y);

      drawComponent("hand", "right", x, y);
      if (intro) {
        drawComponent("hand", "intro", x, y);
      } else {
        drawComponent("hand", "left", x, y);
        drawComponent("mainWave", x, y);
      }
    }
    if (timerOver("emotion")) {
      emotion = "normal";
    }
  }

  public void display (int x, int y) {
    String mouth = "closed";
    String eye = "normal";
    if (emotion=="happy") {
      eye = "happy";
      mouth = "open";
    }
    if (emotion=="sad") {
      eye = "suprised";
      mouth = "sad";
    }
    display(x, y, eye, mouth, false, false);
  }

  public PVector getComponentLoc(String name, String state) {
    Frame part = components.get(name).get(state);
    return new PVector(part.x, part.y);
  }

  public void drawComponent(String name, String state, int x, int y) {
    Frame part = components.get(name).get(state);
    if (part!=null) {
      drawImage(part.img, x+part.x, y+part.y);
    }
  }

  public void drawComponent(String name, int x, int y) {
    drawComponent(name, "0", x, y);
  }

  public void setEmotion(String name, float len) {
    emotion = name;
    resetTimer("emotion");
    timerLengths.put("emotion", len);
  }
}

HashMap<String, Animal> animals;
HashMap<Integer, String> animalTypes;
public void addAnimals() {
  animals = new HashMap<String, Animal>();
  animalTypes = new HashMap<Integer, String>();

  Animal bunny = new Animal(0, 0, -6);
  bunny.setComponent("face", new Frame[] {
    new Frame("bunny_face", 0, 0), 
    });
  bunny.setComponent("boat", new Frame[] {
    new Frame("main_boat", 0, 8), 
    });
  bunny.setComponent("eye", new Frame[] {
    new Frame("normal", "bunny_eye_01", 18, 29), 
    new Frame("happy", "bunny_eye_02", 16, 31), 
    new Frame("suprised", "bunny_eye_03", 14, 29), 
    new Frame("closed", "bunny_eye_04", 15, 29)
    });
  bunny.setComponent("tear", new Frame[] {
    new Frame("bunny_tear_01", 16, 33), 
    });
  bunny.setComponent("mouth", new Frame[] {
    new Frame("closed", "bunny_mouth_01", 22, 39), 
    new Frame("parted", "bunny_mouth_02", 22, 39), 
    new Frame("sad", "bunny_mouth_03_04", 22, 39), 
    new Frame("open", "bunny_mouth_03_04", 22, 39), 
    });
  bunny.setComponent("hand", new Frame[] {
    new Frame("left", "bunny_hand_left", 15, 46), 
    new Frame("right", "bunny_hand_right", 33, 46), 
    new Frame("intro", "bunny_hand_intro", 0, 28), 
    });
  animals.put("bunny", bunny);  
  animalTypes.put(0, "bunny");

  // Panda
  Animal pan = new Animal(1, 5, 2);
  pan.setComponent("face", new Frame[] {new Frame("pan_face", 0, 0)});
  pan.setComponent("boat", new Frame[] {new Frame("main_boat", -5, -2)});
  pan.setComponent("wheel", new Frame[] {new Frame("wheel", 13, 37)});
  pan.setComponent("mainWave", new Frame[] {new Frame("main_wave", -5, 60)});
  pan.setComponent("eye", new Frame[] {
    new Frame("happy", "pan_eye_02", 13, 19), 
    new Frame("suprised", "pan_eye_03", 12, 18), 
    new Frame("closed", "pan_eye_04", 13, 19)
    });
  pan.setComponent("tear", new Frame[] {
    new Frame("pan_tear_01", 16, 33)
    });
  pan.setComponent("mouth", new Frame[] {
    new Frame("closed", "pan_mouth_01", 18, 33), 
    new Frame("open", "pan_mouth_02", 17, 30), 
    new Frame("sad", "pan_mouth_04", 16, 32), 
    new Frame("parted", "pan_mouth_03", 19, 33)
    });
  pan.setComponent("hand", new Frame[] {
    new Frame("left", "pan_hand_left", 9, 36), 
    new Frame("right", "pan_hand_right", 28, 36), 
    new Frame("intro", "pan_hand_left", 9, 36)
    });
  animals.put("pan", pan);  
  animalTypes.put(1, "pan");

  //Bird
  Animal du = new Animal(2, 7, 2);
  du.setComponent("face", new Frame[] {
    new Frame("du_face", 0, 0)
    });
  du.setComponent("boat", new Frame[] {
    new Frame("main_boat", -7, -2)
    });
  du.setComponent("wheel", new Frame[] {new Frame("wheel", 11, 38)});
  du.setComponent("mainWave", new Frame[] {new Frame("main_wave", -5, 60)});
  du.setComponent("eye", new Frame[] {
    new Frame("normal", "du_eye_01", 2, 15), 
    new Frame("happy", "du_eye_02", 2, 16), 
    new Frame("closed", "du_eye_04", 2, 18), 
    new Frame("suprised", "du_eye_03", 1, 7)
    });
  du.setComponent("tear", new Frame[] {
    new Frame("0", "du_tear_01", 16, 33), 
    new Frame("1", "du_tear_02", 16, 33)
    });
  du.setComponent("mouth", new Frame[] {
    new Frame("closed", "du_mouth_01", 6, 27), 
    new Frame("parted", "du_mouth_02", 7, 24), 
    new Frame("sad", "du_mouth_03", 7, 22), 
    new Frame("open", "du_mouth_03", 7, 22)
    });
  du.setComponent("hand", new Frame[] {
    new Frame("hand1", "du_hand_01", 9, 36), 
    new Frame("hand2", "du_hand_02", 9, 36), 
    new Frame("left", "du_hand_left", 7, 37), 
    new Frame("right", "du_hand_right", 23, 37), 
    new Frame("intro", "du_hand_left", 7, 37)
    });
  animals.put("du", du);  
  animalTypes.put(2, "du");
}

class Frame {
  String name;
  String img;
  int x;
  int y;
  Frame (String name, String img, int x, int y) {
    this.name = name;
    this.img = img;
    this.x = x;
    this.y = y;
  }
  Frame (String img, int x, int y) {
    this("0", img, x, y);
  }
}

public String randomAnimalName() {
  return animalTypes.get(int(random(animalTypes.size())));
}

public Animal randomAnimal() {
  return animals.get(randomAnimalName());
}