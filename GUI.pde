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
  return getGUIElement(name).control;
}

ArrayList<GUIElement> GUINames;
public void initGUI() {
  GUINames = new ArrayList<GUIElement>();
  // Images must be scaled up and then saved for the gui elements
  addGUIElement("PlayButton",STATEINTRO,new GImageButton(this, toWorldX(14), toWorldY(100), toWorldX(14), toWorldY(14), new String[]{
    scaleImageToWorld("play_button"),
    scaleImageToWorld("play_button2"),
    scaleImageToWorld("play_button3")
  }));
  addGUIElement("SettingsButton",STATEINTRO,new GImageButton(this, toWorldX(100), toWorldY(100), toWorldX(14), toWorldY(14), new String[]{
    scaleImageToWorld("settings_button"),
    scaleImageToWorld("settings_button2"),
    scaleImageToWorld("settings_button3")
  }));
  
  addGUIElement("BackButtonGame",STATEGAME,new GImageButton(this, toWorldX(gameWidth-18), toWorldY(16), toWorldX(14), toWorldY(14), new String[]{
    scaleImageToWorld("back_button"),
    scaleImageToWorld("back_button2"),
    scaleImageToWorld("back_button3")
  }));
  
  addGUIElement("RestartButton",STATEGAME,new GImageButton(this, toWorldX(gameWidth-18), toWorldY(32), toWorldX(14), toWorldY(14), new String[]{
    scaleImageToWorld("restart_button"),
    scaleImageToWorld("restart_button2"),
    scaleImageToWorld("restart_button3")
  }));
  
  addGUIElement("SpeedSliderLabel",STATESETTINGS,new GLabel(this, toWorldX(10), toWorldY(5), toWorldX(50), toWorldY(20), "Acceleration: "));
  addGUIElement("SpeedSlider",STATESETTINGS,new GSlider(this, toWorldX(55), toWorldY(5), toWorldX(60), toWorldY(20), 15));
  GSlider s = (GSlider) getGUIControl("SpeedSlider");
  s.setLimits(200f,50f,500f);
  s.setNumberFormat(0,1);
  s.setShowLimits(true);
  //s.setTickLabels(new String[]{"easy","difficult","hard"});
  //s.setLocalColorScheme(7);
  s.setShowValue(true);
  
  addGUIElement("GridSizeLabel",STATESETTINGS,new GLabel(this, toWorldX(10), toWorldY(25), toWorldX(50), toWorldY(20), "Grid Size: "));
  addGUIElement("GridSizeXTextField",STATESETTINGS,new GTextField(this, toWorldX(50), toWorldY(30), toWorldX(20), toWorldY(10)));
  addGUIElement("GridSizeTimesLabel",STATESETTINGS,new GLabel(this, toWorldX(77), toWorldY(25), toWorldX(50), toWorldY(20), "x"));
  addGUIElement("GridSizeYTextField",STATESETTINGS,new GTextField(this, toWorldX(90), toWorldY(30), toWorldX(20), toWorldY(10)));
  
  GTextField q = (GTextField) getGUIControl("GridSizeXTextField");
  q.setText(str(xTiles));
  q = (GTextField) getGUIControl("GridSizeYTextField");
  q.setText(str(yTiles));
  
  addGUIElement("BackButtonSettings",STATESETTINGS,new GImageButton(this, toWorldX(100), toWorldY(100), toWorldX(14), toWorldY(14), new String[]{
    scaleImageToWorld("back_button"),
    scaleImageToWorld("back_button2"),
    scaleImageToWorld("back_button3")
  }));
  
  addGUIElement("SaveButton",STATESETTINGS,new GImageButton(this, toWorldX(14), toWorldY(100), toWorldX(14), toWorldY(14), new String[]{
    scaleImageToWorld("save_button"),
    scaleImageToWorld("save_button2"),
    scaleImageToWorld("save_button3")
  }));
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
    numToFastest = s.getValueI();
    GTextField qx = (GTextField) getGUIControl("GridSizeXTextField");
    GTextField qy = (GTextField) getGUIControl("GridSizeYTextField");
    xTiles = int(qx.getText());
    yTiles = int(qy.getText());
    saveConfig();
    updateGameSize();
    gameState = STATEINTRO;
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
    numToFastest = slider.getValueI();
  }*/
}