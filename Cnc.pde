#include <Stepper.h>
#include <math.h>


#define STEPS 100

//Define pins for stepper control
Stepper stepperX(STEPS, 2, 4, 3, 5);
Stepper stepperZ(STEPS, 6, 8, 7, 9);
Stepper stepperY(STEPS, 10, 12, 11, 13);

//Variables for current Head position
int curPosX,curPosY,curPosz;

//Initialization function
void initPos(int x =0, int y=0 , int z=0)
{
curPosX=0;
curPosY=0;
curPosz=0;
}

//This function moves head to an absolute target x,y position
void seek(int tx, int ty)
{
int dx=abs(tx-curPosX);
if(tx<curPosX)
  {
  dx=dx*-1;
  }

int dy=abs(ty-curPosY);
if(ty>curPosY)
  {
  dy=dy*-1;
  }
SteppityStep(dx,dy,0); //Moves x,y but but leaves z unchanged
curPosX=tx;
curPosY=ty;
}

//Function takes given number of steps in provided direction (+ or -)
void SteppityStep(int x, int y, int z)
{
  int signX ,signY , signZ;
  if(x<0)
  {
    signX=1;
  }
  else
  {
    signX=-1;
  }
  if(y<0)
  {
    signY=1;
  }
  else
  {
    signY=-1;
  }
  if(z<0)
  {
    signZ=1;
  }
  else
  {
    signZ=-1;
  }
  int i=abs(x);
  int j;
  if(abs(y)>i)
  {
    i=abs(y);
  }
  if(abs(z)>i)
  {
    i=abs(z);
  }
  for(j=0;j<i;j++)
  {
    if(x!=0)
    {
      stepperX.step((-1)*signX);
      x=x+signX;
    }
    if(y!=0)
    {
      stepperY.step((-9)*signY); // Y-axis steps 9 times per x or z axis step to maintain synchronization
      y=y+signY;
    }
    if(z!=0)
    {
      stepperZ.step((-1)*signZ);
      z=z+signZ;
    }
  }
}




void setup()
{    
  //These speeds don't mean anything right now
  stepperX.setSpeed(50);
  stepperY.setSpeed(200);
  stepperZ.setSpeed(100);
  Serial.begin(9600); //Serial initialization 
  initPos();
}
//Following Pen commands correspond to the placement of the pen in my setup
//Brings pen to a position just .5 cm above the paper to ensure fast penups and pendowns
void PenPoise()
{
  SteppityStep(0,0,-150);
  SteppityStep(0,0,130);
}
//To be called after PenDOwn to raise pen to intermediate position
void PenUp()
{
SteppityStep(0,0,-30);
}
//Touches pen to paper
void PenDown()
{
SteppityStep(0,0,25);
}

void loop()
{
  
  PenPoise();
  int i;
  //Draw a circle using parametric equation for a circle
  //Y-axis coordiantes are multiplied by a factor of 1.13 to compensate to elliptical error
  //trignometric function accept value in rads therfore multiply degrees by 0.0174
  for(i=0;i<360;i++)
  {
    seek((100*cos(i*0.0174)),(100*sin(i*0.0174))*1.13);
    Serial.println((100*cos(i*0.0174)));
    Serial.print(" , ");
    Serial.println((100*sin(i*0.0174))*1.13);
    if(i==0)
      {
       PenDown();  
      }
  }
  //draw an astroid inside the circle
  for(i=0;i<360;i++)
  {
    seek(100*(pow(cos(i*0.0174),3)),100*(pow(sin(i*0.0174),3))*1.13);
    if(i==0)
      {
       PenDown();  
      }
  }
  //wait and return to center
  delay(3000);
  PenUp();
  seek(0,0);
  delay(3000);
  seek(-220,200);
  //draw a sine wave
  for(i=-220;i<220;i++)
  {
    seek(i,200+(25*sin(i*0.0174))*1.13);
    if(i==-220)
      {
       PenDown();  
      }
  }
  //wait and return to center
  delay(3000);
  PenUp();
  seek(0,0);
  while(1);
}
