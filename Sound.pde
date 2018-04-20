/*boolean backgroundMusic = true;
boolean soundEffects = true;

HashMap<String, Sound> sounds = new HashMap<String, Sound>();

class Sound {
  String category;
  String name;
  int num;
  SoundFile file;
  SoundFile[] files;
  /*
  NOTE: 'num' is used for random sounds
   for example, 'break1.mp3', 'break2.mp3', break3.mp3'
   one of these is selected to play randomly
   */
  // name, path, format, category, num
  /*Sound (String n, String p, String f, String c, int num) {
    this.num = num;
    category = c;
    name = n;
    if (num>1) {
      file = loadSound(p+"1."+f);
      files = new SoundFile[num];
      for (int i=1; i<=num; i++) {
        files[i-1] = loadSound(p+i+"."+f);
      }
    } else {
      if (f.length()>0) {
        file = loadSound(p+"."+f);
      } else {
        file = loadSound(p);
      }
    }
  }

  Sound (String n, String p, String f, String c) {
    this(n, p, f, c, 1);
  }

  public void play(float rate, float amp) {
    if ((category=="music" && backgroundMusic) || (category=="sfx" && soundEffects)) {
      if (num==1) {
        file.play(rate, amp);
      } else {
        int rand = int(random(0, num));
        files[rand].play(rate, amp);
      }
    }
  }

  public void play() {
    float amp = 1;
    if (category=="music") {
      amp = 0.5;
    }
    this.play(1, amp);
  }

  public void stopPlaying() {
    if (num==1) {
      file.stop();
    } else {
      for (int i=0; i<files.length; i++) {
        files[i].stop();
      }
    }
  }
}

public void addSound(String name, String path, String format, String category) {
  sounds.put(name, new Sound(name, path, format, category));
}

public void addSound(String name, String path, String category) {
  addSound(name, path, "", category);
}

public void addSound(String name, String path, String format, String category, int num) {
  sounds.put(name, new Sound(name, path, format, category, num));
}

public SoundFile loadSound(String fileName) {
  return new SoundFile(this, fileName);
}

public void playSound(String name) {
  sounds.get(name).play();
}

public void playSound(String name, float amp) {
  sounds.get(name).play(1, amp);
}

public void loadAllSounds(String dir) {
  String otherFolder = dir;
  File folder = new File(dataPath("")+otherFolder);
  File[] files = folder.listFiles();
  if (files!=null) {
    for (File fileEntry : files) {
      if (!fileEntry.isDirectory()) {
        String fileName = fileEntry.getName();
        if (fileName.toLowerCase().endsWith(".mp3") || fileName.toLowerCase().endsWith(".ogg")) {
          String name = fileName.substring(0,fileName.indexOf("."));
          addSound(name,otherFolder+fileName,"sfx");
        }
      }
    }
  }
}

public void initSounds() {
  loadAllSounds("/audio/");
}*/