String introAnimal = "bunny";
public void intro(float time) {
  if (gameStateChanged) {
    introAnimal = randomAnimalName();
    surface.setSize(int(INTROWIDTH*gameScale),int(INTROHEIGHT*gameScale));
  }
  
  animals.get(introAnimal).update(time);
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
  // animals.get(introAnimal).display(36,51,"happy","open",false,true);
}