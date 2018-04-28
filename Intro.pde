public void intro(float time) {
  if (gameStateChanged) {
    surface.setSize(int(INTROWIDTH*config.getFloat("gameScale")),int(INTROHEIGHT*config.getFloat("gameScale")));
  }
  
  drawIntro();
}

public void drawParallax(String img, int x, int y, int z) {
  if (z>0) {
    x+=int(center.x-mouseX)/(z*20);
    y+=int(center.y-mouseY)/(z*20);
  }
  drawImage(img,x,y);
}

public void drawIntro() {
  drawImage("intro_bg",0,0);
}