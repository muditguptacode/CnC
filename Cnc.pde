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
  //Serial.flush();
  //Serial.println("Seek end");
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
    if(x!=0 && x<=250 && x>=-250 )
    {
      stepperX.step((-1)*signX);
      x=x+signX;
    }
    if(y!=0 && y<=175 && y>=-175)
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
  SteppityStep(0,0,9);
}

char chr;
int first =1;
void setup()
{    
  //These speeds don't mean anything right now
  stepperX.setSpeed(50);
  stepperY.setSpeed(200);
  stepperZ.setSpeed(100);
  Serial.begin(4800); //Serial initialization 
  Serial.write("Ready for receiving commands...");
  Serial.flush();
  while(!Serial.available());
  chr=Serial.read();
  if(chr=='?')
  {
    Serial.print('r');
  }
  else
  {
    Serial.print(chr);
  }
  initPos();
}
int rx , ry, in , jk;
char c;

char arr[5];
void loop()
{
  
  PenPoise();
  //PenDown();
  while(1)
  {
    if(Serial.available())
    {
      c = Serial.read();
      
      if( c=='(')
      {  
        in=0;
        for (jk=0;jk<5;jk++)
        {
          arr[jk]='\0';
        }     
       // Serial.println("arr = ");
       // Serial.println(arr);
       // Serial.println("//arr");
        while(1)
        {
          while(!Serial.available());
          c=Serial.read();
          //Serial.println(c);

          if(c==',')
          {
            goto out1;
          }
          arr[in++]=c;
        }
        out1:
        rx=atoi(arr);
        //Serial.println(arr);
        in=0;
        for (jk=0;jk<5;jk++)
        {
          arr[jk]='\0';
        } 
        while(1)
        {
          while(!Serial.available());
          c=Serial.read();
          //Serial.println(c);
          
          if(c==')')
          {
            goto out2;
          }
         // Serial.println(arr);
          arr[in++]=c;
        }
        out2:  
        ry=atoi(arr);
        seek(rx,ry);
        if(first==1)
        {
          PenDown();
        }
        Serial.flush();
        //Serial.println(rx);
        //Serial.println(ry);
        Serial.print('n');
        //Serial.flush();
          
        
      }
      else
      {
     // Serial.println("no (, got instead");
      //Serial.print(c);
      Serial.flush();
      
      }
    }
  }
}





