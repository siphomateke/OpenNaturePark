public void gameSettings(float time) {
  if (gameStateChanged) {
    // Set the settings to their current value
    GSlider s = (GSlider) getGUIElement("SpeedSlider");
    s.setValue(numToFastest);
    GTextField q = (GTextField) getGUIElement("GridSizeXTextField");
    q.setText(str(xTiles));
    q = (GTextField) getGUIElement("GridSizeYTextField");
    q.setText(str(yTiles));
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
  //initGUI();
  center = new PVector(width/2,height/2);
}

public void saveConfig() {
  JSONObject json = new JSONObject();
  json.setFloat("version",VERSION);
  json.setInt("highScore",highScore);
  json.setInt("numToFastest",numToFastest);
  json.setInt("xTiles",xTiles);
  json.setInt("yTiles",yTiles);
  saveJSONObject(json, "data/config.json");
}

public void loadConfig() {
  File f = new File(dataPath("config.json"));
  if (f.exists()) {
    JSONObject json = loadJSONObject("data/config.json");
    if (json.hasKey("high_score")) {
      highScore = json.getInt("high_score");
    }
    else if (json.hasKey("highScore")) {
      highScore = json.getInt("highScore");
    }
    if (json.hasKey("numToFastest")) {
      numToFastest = json.getInt("numToFastest");
    }
    if (json.hasKey("xTiles")) {
      xTiles = json.getInt("xTiles");
    }
    if (json.hasKey("yTiles")) {
      yTiles = json.getInt("yTiles");
    }
  }
  updateGameSize();
}