import java.util.Observable;
import java.util.Arrays;

// view settings page
public void gameSettings(float time) {
  if (gameStateChanged) {
    // Set the settings to their current value
    GSlider s = (GSlider) getGUIControl("SpeedSlider");
    s.setValue(config.get("numToFastest"));
    GTextField q = (GTextField) getGUIControl("GridSizeXTextField");
    q.setText(str(config.get("xTiles")));
    q = (GTextField) getGUIControl("GridSizeYTextField");
    q.setText(str(config.get("yTiles")));
  }
  background(#8abde1);
}

public void drawImageRandom(String img, int num) {
  for (int i=0;i<num;i++) {
    drawImage(img,int(random(15,gameWidth-15)),int(random(15,gameHeight-15)));
  }
}

public void updateGameSize() {
  surface.setSize(int(gameWidth * gameScale), int(gameHeight * gameScale));
  windowWidth = width;
  windowHeight = height;
  center = new PVector(width/2,height/2);
  refreshGUIPositions();
}

class ConfigPropChangeEvent {
  ArrayList<String> changed;
  ConfigPropChangeEvent(ArrayList<String> changed) {
    this.changed = changed;
  }
  ConfigPropChangeEvent(String changed) {
    this.changed = new ArrayList<String>();
    this.changed.add(changed);
  }
}

class ConfigLoadEvent extends ConfigPropChangeEvent {
  ConfigLoadEvent(ArrayList<String> changed) {
    super(changed);
  }
}

class ConfigLoadError extends Exception {
  public ConfigLoadError(String message) {
    super(message);
  }
}

// Config singleton
class Config extends Observable {
  public String version;
  public String loadPath;
  public String savePath;
  public HashMap<String, Integer> intConfigs;
  Config(String defaultPath) {
    // Integer configurations
    this.intConfigs = new HashMap<String, Integer>();
    this.version = VERSION;
    this.set("highScore", 0);
    this.set("xTiles", 6);
    this.set("yTiles", 10);
    // The number of placements till the game is
    // at its fastest speed
    this.set("numToFastest", 200);

    this.loadPath = defaultPath;
    this.savePath = defaultPath;
  }
  public boolean hasProp(String name) {
    boolean intHas = this.intConfigs.containsKey(name);
    return intHas;
  }
  public boolean set(String name, int val, boolean notify) {
    boolean shouldSet = !this.hasProp(name) || (this.hasProp(name) && val != this.get(name));
    if (shouldSet) {
      this.intConfigs.put(name, val);
      this.setChanged();

      if (notify) {
        this.notifyObservers(new ConfigPropChangeEvent(name));
      }
      return true;
    } else {
      return false;
    }
  }
  public boolean set(String name, int val) {
    return this.set(name, val, true);
  }
  public Integer get(String name) {
    for (String name2 : this.intConfigs.keySet()) {
      if (name2 == name) {
        return this.intConfigs.get(name2);
      }
    }
    return null;
  }
  public void loadDefault() {
    ArrayList<String> changed = new ArrayList<String>();
    for (String name : this.intConfigs.keySet()) {
      changed.add(name);
    }
    this.setChanged();
    this.notifyObservers(new ConfigLoadEvent(changed));
  }
  public void load(String path, boolean refreshGui) throws ConfigLoadError {
    File f = new File(path);
    if (f.exists()) {
      JSONObject json = loadJSONObject(path);
      if (json.hasKey("version")) {
        String version = "";
        try {
          version = json.getString("version");
        } catch (Exception e) {
          // Handle older versions where the version was stored as a float
          try {
            version = Float.toString(json.getFloat("version"));
          } catch (Exception e2) {
            throw new ConfigLoadError("Unknown configuration file format.\nPath: "+path);
          }
        }

        String[] supportedVersions = new String[]{"0.75"};
        if (!version.equals(this.version) && !Arrays.asList(supportedVersions).contains(version)) {
          // TODO: Decide on better layout for long paths
          throw new ConfigLoadError("Configuration file is from an unsupported version ("+version+").\nSupported versions are "+Arrays.toString(supportedVersions)+"\nConfig path: "+path);
        }

        ArrayList<String> allChanged = new ArrayList<String>();
        for (String name : this.intConfigs.keySet()) {
          if (json.hasKey(name)) {
            int val = json.getInt(name);
            boolean changed = this.set(name, val, false);
            if (changed) {
              allChanged.add(name);
            }
          }
        }
        this.notifyObservers(new ConfigLoadEvent(allChanged));
      } else {
        throw new ConfigLoadError("Configuration file is of an unknown format. (Could not find a version property)\nPath: "+path);
      }
    } else {
      throw new ConfigLoadError("Specified configuration file does not exist.\nPath: "+path);
    }
  }
  public void load(String path) throws ConfigLoadError {
    this.load(path, true);
  }
  public void load() throws ConfigLoadError {
    this.load(this.loadPath);
  }
  public void save(String path) {
    // TODO: min and max num tiles
    JSONObject json = new JSONObject();
    json.setString("version", this.version);
    for (String name : this.intConfigs.keySet()) {
      json.setInt(name, this.intConfigs.get(name));
    }
    saveJSONObject(json, path);
  }
  public void save() {
    this.save(this.savePath);
  }
}