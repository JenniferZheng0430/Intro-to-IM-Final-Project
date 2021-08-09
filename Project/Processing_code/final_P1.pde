import processing.video.*;
Capture video;
color trackColor; 
float threshold = 25;

import processing.sound.*;
SoundFile beach;
SoundFile bird;
import processing.serial.*;
int NUM_OF_VALUES = 1;   /** YOU MUST CHANGE THIS ACCORDING TO YOUR PROJECT **/
int sensorValues[];

int birdX[] = new int[10];
int birdY[] = new int[10];
float birdSX[] = new float[10];
PImage Bird[] = new PImage[10];

int trashX[] = new int[10];
int trashY[] = new int[10];
PImage trash[] = new PImage[10];

String myString = null;
Serial myPort;
float x = 50;
float y = 700;
//float bird1X = 250;
//float bird1Y = 350;
//float bird1S = 10;
//float bird2X = 550;
//float bird2Y = 300;
//float bird2S = 3;
float crabX = 150;
float crabY = 650;
float crabS = -3;
float stepX = 5;
float stepY = -1.5;
boolean gameover = false;
boolean win  = false;
PImage img;
PImage turtle;
//PImage bird1;
//PImage bird2;
PImage crab;

AudioIn mic;
Amplitude analysis;

int voice;

void setup() {
  setupSerial();
  background(255);
  size(1310,820);
  frameRate(120);
  for (int i=0;i<10;i++){
    birdX[i] = 100*i + 70;
    birdY[i] = int(random(20,400));
    Bird[i] = loadImage("bird1.png");
    trashX[i] = 120*i + 40;
    trashY[i] = int(random(550,650));
    trash[i] = loadImage("trash1.png");
  }
  img = loadImage("beach.jpg");
  turtle = loadImage("turtle.png");
  //bird1 = loadImage("bird1.png");
  //bird2 = loadImage("bird2.png");
  //crab = loadImage("crab.png");
  
  beach = new SoundFile(this, "beach.mp3");
  bird = new SoundFile(this, "bird.mp3");

  
  mic = new AudioIn(this,0);
  mic.start();
  analysis = new Amplitude(this);
  analysis.input(mic);
  
  String[] cameras = Capture.list();
  printArray(cameras);
  video = new Capture(this, cameras[0]);
  video.start();
  trackColor = color(255, 0, 0);
}

void captureEvent(Capture video) {
  video.read();
}

void draw() {
  getSerialData();
  printArray(sensorValues);
  if(gameover == false && win == false) {
    if(beach.isPlaying()==false){
    beach.play();
    }
    image(img,0,0, 1310,820);
    bird();
    turtle();
    trash();
    //crab();
    
    video.loadPixels();
    threshold = 80;
    float avgX = 0;
    float avgY = 0;
  
    int count = 0;
  
    // Begin loop to walk through every pixel
    for (int x = 0; x < video.width; x++ ) {
      for (int y = 0; y < video.height; y++ ) {
        int loc = x + y * video.width;
        // What is current color
        color currentColor = video.pixels[loc];
        float r1 = red(currentColor);
        float g1 = green(currentColor);
        float b1 = blue(currentColor);
        float r2 = red(trackColor);
        float g2 = green(trackColor);
        float b2 = blue(trackColor);
  
        float d = distSq(r1, g1, b1, r2, g2, b2); 
  
        if (d < threshold*threshold) {
          stroke(255);
          strokeWeight(1);
          point(x, y);
          avgX += x;
          avgY += y;
          count++;
        }
      }
    }
  
    // We only consider the color found if its color distance is less than 10. 
    // This threshold of 10 is arbitrary and you can adjust this number depending on how accurate you require the tracking to be.
    if (count > 0) { 
      avgX = avgX / count;
      avgY = avgY / count;
      // Draw a circle at the tracked pixel
      fill(255);
      strokeWeight(4.0);
      stroke(0);
      ellipse(avgX, avgY, 24, 24);
    }
  }
  voice = int(map(analysis.analyze(), 0, 0.5, 1, 1000));

}

float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}
void trash(){
  for (int i=0;i<10;i++){
    image(trash[i],trashX[i],trashY[i],70,40);
  }
}
void turtle() {
  if (sensorValues[0] <10){
    stepX = 0;
    stepY = 0;
  }
  else{
    stepX = 5;
    stepY = -1.5;
  }
  image(turtle,x,y,80,50);
  x += stepX;
  y += stepY;
  if(x > 496 & y < 494){
    win();
  }
}

void bird(){
  for (int i=0;i<10;i++){
     image(Bird[i],birdX[i],birdY[i],80,70);
     birdSX[i] = map((x - birdX[i]), -500,500, -5,5);
  }
  for (int i=0;i<10;i++){
     birdX[i] += birdSX[i];
     birdY[i] += 5;
     
     if (voice>950){
        birdY[i] -= -10;
        bird.play();
      }
     else{
        birdY[i] += 5;
      }
     //if(abs(y - birdY[i]) < 20 & abs(x - birdX[i]) < 50){
     //   gameover();
     // }

  }
  //if(bird1Y > 622){
  //  bird1S = 0;
  //}
  //else{
  //  bird1S = 10;
  //}
  //if(abs(y - bird1Y) < 20 & abs(x - bird1X) < 50){
  //  gameover();
  //}
  //if(bird2Y > 600){
  //  bird2S = 0;
  //}
  //else{
  //  bird2S = 6;
  //}
  //if(abs(y - bird2Y) < 20 & abs(x - bird2X) < 50){
  //  gameover();
  //}
  
}


//void crab(){
//  step = int(map(sensorValues[0],0,100,0,50));
//  image(crab,crabX,crabY,80,70);
//  crabX += crabS;
//  if (crabX == x){
//    gameover();
//  }
//  if (step > 5){
//    crabS = step;
//  }
//  else{
//    crabS = -3;
//  }
//}

void gameover() {
  clear();
  textSize(50);
  text("game over", width/5*2, height/2); 
  fill(0, 102, 153);
  beach.pause();
  gameover = true;
}
  
void win() {
  clear();
  background(0);
  textSize(50);
  text("Yeah!The turtle is back home! Congratulations!", 100, height/2); 
  fill(0, 102, 153);
  win = true;

}

void setupSerial() {
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[7], 9600);

  myPort.clear();
  myString = myPort.readStringUntil( 10 );  // 10 = '\n'  Linefeed in ASCII
  myString = null;

  sensorValues = new int[NUM_OF_VALUES];
}

void getSerialData() {
  while (myPort.available() > 0) {
    myString = myPort.readStringUntil( 10 ); // 10 = '\n'  Linefeed in ASCII
    if (myString != null) {
      String[] serialInArray = split(trim(myString), ",");
     
      if (serialInArray.length == NUM_OF_VALUES) {
        for (int i=0; i<serialInArray.length; i++) {
          sensorValues[i] = int(serialInArray[i]);
        }
      }
    }
  }
}
