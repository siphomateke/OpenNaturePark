class Particle {
  int mass;
  PVector loc;
  PVector vel;
  PVector accel;
  PVector force;
  float angVel;
  float angle;
  float lifetime;
  float age;
  boolean dead;
  Particle(int x, int y, PVector vel, float angVel, float angle, float lifetime) {
    mass = 5;
    this.loc = new PVector(x,y);
    this.vel = vel;
    this.force = new PVector();
    this.accel = new PVector();
    this.angle = angle; 
    this.angVel = angVel;
    this.lifetime = lifetime;
    age = 0;
    dead = false;
  }
  public void update(float time) {
    angle += angVel;
    force.add(new PVector(0,0.01));
    accel = force.copy().div(mass);
    vel.add(accel);
    loc.add(vel);
    
    if (loc.x<0) {
      dead = true;
    }
    if (loc.y<0) {
      dead = true;
    }
    if (loc.x>REALWIDTH) {
      dead = true;
    }
    if (loc.y>REALHEIGHT) {
      dead = true;
    }
    age+=time;
    if (age>=lifetime && !dead) { 
      dead = true;
    }
  }
  public void display() {
    drawImage(getImage("combo_star"),int(loc.x),int(loc.y),((lifetime-age)/lifetime),angle);
  }
} 

class ParticleSim {
  ArrayList<Particle> particles = new ArrayList<Particle>();
  ParticleSim() {
    
  }
  
  public void update(float time) {
    ArrayList<Particle> tmpParticles = new ArrayList<Particle>(particles); 
    for (Particle p : tmpParticles) {
      p.update(time);
      if (p.dead) {
        particles.remove(p);
      }
    }
  }
  
  public void display() {
    for (Particle p : particles) {
      p.display();
    }
  }
  
  public void addParticle(int x, int y, PVector vel, float angVel, float angle, float lifetime) {
    particles.add(new Particle(x,y,vel,angVel,angle,lifetime)); 
  }
  
  public void explode(int x, int y) {
    for (int i=0;i<10;i++) {
      addParticle(x,y,PVector.fromAngle(random(2*PI)).mult(random(1,3)),random(0,radians(5)),random(0,2*PI),random(2000,3000));
    }
  }
}