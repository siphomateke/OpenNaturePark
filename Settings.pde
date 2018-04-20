public void gameSettings(float time) {
  if (gameStateChanged) {
    //drawImage("cloud",0,82);
    //drawImage("intro_frame",0,0);
    //drawImageRandom("intro_bigstar",3);
    //drawImageRandom("intro_midstar",4);
    //drawImageRandom("intro_smallstar",2);
    
    // Set the settings to their current value
    GSlider s = (GSlider) getGUIElement("SpeedSlider");
    s.setValue(numToFastest);
    
    /*GTextField q = (GTextField) getGUIElement("GridSizeXTextField");
    q.setText(str(XTILES));
    q = (GTextField) getGUIElement("GridSizeYTextField");
    q.setText(str(YTILES));*/
  }
  background(#8abde1);
  drawImage("cloud",0,82);
}

public void drawImageRandom(String img, int num) {
  for (int i=0;i<num;i++) {
    drawImage(img,int(random(15,REALWIDTH-15)),int(random(15,REALHEIGHT-15)));
  }
}

public void saveConfig() {
  JSONObject json = new JSONObject();
  json.setFloat("version",VERSION);
  json.setInt("highScore",highScore);
  json.setInt("numToFastest",numToFastest);
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
  }
  updateGameSize();
}