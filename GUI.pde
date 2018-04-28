class GUIElement{
  GAbstractControl control;
  String name;
  int state;
  GUIElement(String name, int state, GAbstractControl control) {
    this.name = name;
    this.state = state;
    this.control = control;
  }
}

// Scale an image to the right size, save it and return the file name
public String scaleImageToWorld(String imgName) {
  PImage img = getImage(imgName);
  PVector size = imgToWorldCoords(img);
  PGraphics g = createGraphics(int(size.x),int(size.y));
  g.beginDraw();
  g.image(img,0,0,size.x,size.y);
  g.endDraw();
  String name = "data/scaledImages/"+imgName+".png";
  g.save(name);
  return name;
}

public void addGUIElement(String name, int state, GAbstractControl control) {
  GUINames.add(new GUIElement(name,state,control));
}

public GUIElement getGUIElement(String name) {
  GUIElement element = null;
  searchLoop:
  for (GUIElement e : GUINames) {
    if (e.name==name) {
      element = e;
      break searchLoop;
    }
  }
  return element;
}

public GAbstractControl getGUIControl(String name) {
  GUIElement e = getGUIElement(name);
  if (e != null) {
    return e.control;
  } else {
    return null;
  }
}

ArrayList<GUIElement> GUINames = new ArrayList<GUIElement>();
public void initGUI() {
  // Images must be scaled up and then saved for the gui elements
  addGUIElement("PlayButton",STATEINTRO,new GImageButton(this, 0, 0, toWorldX(14), toWorldY(14), new String[]{
    scaleImageToWorld("play_button"),
    scaleImageToWorld("play_button2"),
    scaleImageToWorld("play_button3")
  }));
  addGUIElement("SettingsButton",STATEINTRO,new GImageButton(this, 0, 0, toWorldX(14), toWorldY(14), new String[]{
    scaleImageToWorld("settings_button"),
    scaleImageToWorld("settings_button2"),
    scaleImageToWorld("settings_button3")
  }));
  
  addGUIElement("BackButtonGame",STATEGAME,new GImageButton(this, 0, 0, toWorldX(14), toWorldY(14), new String[]{
    scaleImageToWorld("back_button"),
    scaleImageToWorld("back_button2"),
    scaleImageToWorld("back_button3")
  }));
  
  addGUIElement("RestartButton",STATEGAME,new GImageButton(this, 0, 0, toWorldX(14), toWorldY(14), new String[]{
    scaleImageToWorld("restart_button"),
    scaleImageToWorld("restart_button2"),
    scaleImageToWorld("restart_button3")
  }));
  
  addGUIElement("SpeedSliderLabel",STATESETTINGS,new GLabel(this, 0, 0, toWorldX(50), toWorldY(20), "Acceleration: "));
  addGUIElement("SpeedSlider",STATESETTINGS,new GSlider(this, 0, 0, toWorldX(60), toWorldY(20), 15));
  GSlider s = (GSlider) getGUIControl("SpeedSlider");
  s.setLimits(200f,50f,500f);
  s.setNumberFormat(0,1);
  s.setShowLimits(true);
  //s.setTickLabels(new String[]{"easy","difficult","hard"});
  //s.setLocalColorScheme(7);
  s.setShowValue(true);
  
  addGUIElement("GridSizeLabel",STATESETTINGS,new GLabel(this, 0, 0, toWorldX(50), toWorldY(20), "Grid Size: "));
  addGUIElement("GridSizeXTextField",STATESETTINGS,new GTextField(this, 0, 0, toWorldX(20), toWorldY(10)));
  addGUIElement("GridSizeTimesLabel",STATESETTINGS,new GLabel(this, 0, 0, toWorldX(50), toWorldY(20), "x"));
  addGUIElement("GridSizeYTextField",STATESETTINGS,new GTextField(this, 0, 0, toWorldX(20), toWorldY(10)));
  
  GTextField q = (GTextField) getGUIControl("GridSizeXTextField");
  q.setText(str(config.get("xTiles")));
  q = (GTextField) getGUIControl("GridSizeYTextField");
  q.setText(str(config.get("yTiles")));
  
  addGUIElement("BackButtonSettings",STATESETTINGS,new GImageButton(this, 0, 0, toWorldX(14), toWorldY(14), new String[]{
    scaleImageToWorld("back_button"),
    scaleImageToWorld("back_button2"),
    scaleImageToWorld("back_button3")
  }));
  
  addGUIElement("SaveButton",STATESETTINGS,new GImageButton(this, 0, 0, toWorldX(14), toWorldY(14), new String[]{
    scaleImageToWorld("save_button"),
    scaleImageToWorld("save_button2"),
    scaleImageToWorld("save_button3")
  }));
}

public void moveControl(String name, int x, int y) {
  GAbstractControl c = getGUIControl(name);
  if (c != null) {
    c.moveTo(toWorldX(x), toWorldY(y));
  }
}

public void refreshGUIPositions() {
  moveControl("BackButtonGame", 14, 100);
  moveControl("PlayButton", 14, 100);
  moveControl("SettingsButton", 100, 100);
  moveControl("BackButtonGame", gameWidth-18, 16);
  moveControl("RestartButton", gameWidth-18, 32);
  moveControl("SpeedSliderLabel", 10, 5);
  moveControl("SpeedSlider", 55, 5);  
  moveControl("GridSizeLabel", 10, 25);
  moveControl("GridSizeXTextField", 50, 30);
  moveControl("GridSizeTimesLabel", 77, 25);
  moveControl("GridSizeYTextField", 90, 30);
  moveControl("BackButtonSettings", 100, 100);
  moveControl("SaveButton", 14, 100);
}

public void updateGUI(float time) {
  for (GUIElement e : GUINames) {
    if (e.control.isVisible() && e.state!=gameState) {
      e.control.setVisible(false);
    }
    else if (!e.control.isVisible() && e.state==gameState) {
      e.control.setVisible(true);
    }
  }
}

public String getGUIControlName(GAbstractControl b) {
  String name = "";
  searchLoop:
  for (GUIElement e : GUINames) {
    if (e.control==b) {
      name = e.name;
      break searchLoop;
    }
  }
  return name;
}

public void handleButtonEvents(GImageButton button, GEvent event) {
  String name = getGUIControlName(button);
  //println(name+" was "+event.name());
  if (name=="PlayButton" && gameState==STATEINTRO) {
    gameState = STATEGAME;
  }
  if (name=="SettingsButton" && gameState==STATEINTRO) {
    gameState = STATESETTINGS;
  }
  if (name=="BackButtonSettings" && gameState==STATESETTINGS) {
    gameState = STATEINTRO;
  }
  if (name=="SaveButton" && gameState==STATESETTINGS) {
    GValueControl s = (GValueControl) getGUIControl("SpeedSlider");
    config.set("numToFastest", s.getValueI());
    GTextField qx = (GTextField) getGUIControl("GridSizeXTextField");
    GTextField qy = (GTextField) getGUIControl("GridSizeYTextField");
    int xTiles = int(qx.getText());
    int yTiles = int(qy.getText());
    config.set("xTiles", xTiles);
    config.set("yTiles", yTiles);
    config.save();
    updateGameSize();
    gameState = STATEINTRO;
    // Once saving gameScale is possible, this will need to exit since
    // G4P doesn't allow resizing controls after initialization
    /* int response = showConfirmDialog("Changing game scale requires a restart. Would you like to exit now?\n(Cancelling or pressing no will revert changes made to game scale)", "Warning");
    if (response == 0) {
      exit();
    } */
  }
  if (name=="BackButtonGame" && gameState==STATEGAME) {
    gameState = STATEINTRO;
    gameOver();
  }
  if (name=="RestartButton" && gameState==STATEGAME) {
    gameOver();
    newGame();
  }
}

public void handleTextEvents(GEditableTextControl textcontrol, GEvent event) {

}

public void handleSliderEvents(GValueControl slider, GEvent event) {
  /*String name = getGUIControlName(slider);
  if (name=="SpeedSlider" && gameState==STATESETTINGS) {
    config.set("numToFastest", slider.getValueI());
  }*/
}
