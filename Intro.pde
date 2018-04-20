String introAnimal = "bunny";
public void intro(float time) {
  if (gameStateChanged) {
    /*background(#240254);
    drawImage("cloud",0,82);
    drawImage("intro_frame",0,0);
    drawImage("main_boat",38,53);*/
    introAnimal = randomAnimalName();
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
  background(#240254);
  /*drawParallax("cloud",0,82,2);
  drawParallax("intro_frame",0,0,0);
  drawParallax("intro_bigstar", 36, 7,2);
  drawParallax("intro_bigstar", 86, 34,2);
  drawParallax("intro_bigstar", 111, 21,2);
  drawParallax("intro_midstar", 63, 11,3);
  drawParallax("intro_midstar", 88, 9,3);
  drawParallax("intro_midstar", 29, 40,3);
  drawParallax("intro_midstar", 22, 60,3);
  drawParallax("intro_smallstar", 12, 37,4);
  drawParallax("intro_smallstar", 42, 38,4);
  drawParallax("intro_smallstar", 29, 64,4);
  drawParallax("intro_buble",61,31,1);
  drawParallax("intro_buble",30,31,1);*/
  drawImage("cloud",0,82);
  drawImage("intro_frame",0,0);
  drawImage("intro_bigstar", 36, 7);
  drawImage("intro_bigstar", 86, 34);
  drawImage("intro_bigstar", 111, 21);
  drawImage("intro_midstar", 63, 11);
  drawImage("intro_midstar", 88, 9);
  drawImage("intro_midstar", 29, 40);
  drawImage("intro_midstar", 22, 60);
  drawImage("intro_smallstar", 12, 37);
  drawImage("intro_smallstar", 42, 38);
  drawImage("intro_smallstar", 29, 64);
  drawImage("intro_buble",61,31);
  drawImage("intro_buble",30,31);
  animals.get(introAnimal).display(36,51,"happy","open",false,true);
  drawImage("intro_title",16,7);
  drawImage("intro_flower1",37,16);
  //drawImage("play_button",14,90);
  //drawImage("settings_button",100,90);
}