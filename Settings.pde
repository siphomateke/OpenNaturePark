import java.util.Observable;
import java.util.Arrays;

// view settings page
public void gameSettings(float time) {
  if (gameStateChanged) {
    // Set the settings to their current value
    GSlider s = (GSlider) getGUIControl("SpeedSlider");
    s.setValue(config.getInt("numToFastest"));
    GTextField q = (GTextField) getGUIControl("GridSizeXTextField");
    q.setText(str(config.getInt("xTiles")));
    q = (GTextField) getGUIControl("GridSizeYTextField");
    q.setText(str(config.getInt("yTiles")));
    q = (GTextField) getGUIControl("GameScaleTextField");
    q.setText(str(config.getFloat("gameScale")));
  }
  background(#8abde1);
}

public void drawImageRandom(String img, int num) {
  for (int i=0;i<num;i++) {
    drawImage(img,int(random(15,gameWidth-15)),int(random(15,gameHeight-15)));
  }
}

public void updateGameSize() {
  surface.setSize(int(gameWidth * config.getFloat("gameScale")), int(gameHeight * config.getFloat("gameScale")));
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

public enum ConfigTypes {
  INTEGER,
  FLOAT,
  STRING,
  BOOLEAN
}

// Config singleton
class Config extends Observable {
  public String version;
  public String loadPath;
  public String savePath;
  public HashMap<String, ConfigTypes> configTypes;
  public HashMap<String, Object> configs;
  Config(String defaultPath) {
    this.version = VERSION;
    
    this.configs = new HashMap<String, Object>();
    this.configTypes = new HashMap<String, ConfigTypes>();
    this.configTypes.put("highScore", ConfigTypes.INTEGER);
    this.configTypes.put("xTiles", ConfigTypes.INTEGER);
    this.configTypes.put("yTiles", ConfigTypes.INTEGER);
    this.configTypes.put("numToFastest", ConfigTypes.INTEGER);
    this.configTypes.put("gameScale", ConfigTypes.FLOAT);

    // Currently it's just determined from the default value
    this.set("highScore", 0);
    this.set("gameScale", 2f);
    this.set("xTiles", 6);
    this.set("yTiles", 10);
    // The number of placements till the game is
    // at its fastest speed
    this.set("numToFastest", 200);

    this.loadPath = defaultPath;
    this.savePath = defaultPath;
  }
  public boolean hasProp(String name) {
    return this.configs.containsKey(name);
  }
  public boolean configEqual(String name, Object val2) {
    ConfigTypes type = this.configTypes.get(name);
    Object valObj = this.get(name);
    if (type == ConfigTypes.INTEGER) {
      return ((Integer) valObj) == val2;
    } else if (type == ConfigTypes.STRING) {
      if (valObj != null) {
        return ((String) valObj).equals((String) val2);
      } else {
        return valObj == val2;
      }
    } else if (type == ConfigTypes.FLOAT) {
      return ((Float) valObj) == val2;
    } else if (type == ConfigTypes.BOOLEAN) {
      return ((Boolean) valObj) == val2;
    }
    return false;
  }
  public boolean set(String name, Object val, boolean notify) {
    boolean shouldSet = !this.hasProp(name) || (this.hasProp(name) && !this.configEqual(name, val));
    if (shouldSet) {
      this.configs.put(name, val);
      this.setChanged();

      if (notify) {
        this.notifyObservers(new ConfigPropChangeEvent(name));
      }
      return true;
    } else {
      return false;
    }
  }
  public boolean set(String name, Object val) {
    return this.set(name, val, true);
  }
  public Object get(String name) {
    for (String name2 : this.configs.keySet()) {
      if (name2.equals(name)) {
        return this.configs.get(name2);
      }
    }
    return null;
  }
  public Integer getInt(String name) {
    return (int) this.get(name);
  }
  public String getString(String name) {
    return (String) this.get(name);
  }
  public Float getFloat(String name) {
    return (float) this.get(name);
  }
  public Boolean getBoolean(String name) {
    return (boolean) this.get(name);
  }
  public void loadDefault() {
    ArrayList<String> changed = new ArrayList<String>();
    for (String name : this.configs.keySet()) {
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

        String[] supportedVersions = new String[]{"0.75", "0.8"};
        if (version != null && !version.equals(this.version) && !Arrays.asList(supportedVersions).contains(version)) {
          // TODO: Decide on better layout for long paths
          throw new ConfigLoadError("Configuration file is from an unsupported version ("+version+").\nSupported versions are "+Arrays.toString(supportedVersions)+"\nConfig path: "+path);
        }

        ArrayList<String> allChanged = new ArrayList<String>();
        for (String name : this.configTypes.keySet()) {
          if (json.hasKey(name)) {
            Object val = null;
            ConfigTypes type = this.configTypes.get(name);
            if (type == ConfigTypes.INTEGER) {
              val = json.getInt(name);
            }
            if (type == ConfigTypes.STRING) {
              val = json.getString(name);
            }
            if (type == ConfigTypes.FLOAT) {
              val = json.getFloat(name);
            }
            if (type == ConfigTypes.BOOLEAN) {
              val = json.getBoolean(name);
            }
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
    for (String name : this.configs.keySet()) {
      Object val = this.configs.get(name);
      ConfigTypes type = this.configTypes.get(name);
      if (type == ConfigTypes.INTEGER) {
        json.setInt(name, (Integer) val);
      }
      if (type == ConfigTypes.STRING) {
        json.setString(name, (String) val);
      }
      if (type == ConfigTypes.FLOAT) {
        json.setFloat(name, (Float) val);
      }
      if (type == ConfigTypes.BOOLEAN) {
        json.setBoolean(name, (Boolean) val);
      }
    }
    saveJSONObject(json, path);
  }
  public void save() {
    this.save(this.savePath);
  }
}