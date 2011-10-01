from PIL import Image
import time
import serial
import ImageDraw
import math
#import ankur 2.5 2.5                                       //private joke
ser=serial.Serial("com1" , 4800)
def make_bezier(xys):
    # xys should be a sequence of 2-tuples (Bezier control points)
    n=len(xys)
    combinations=pascal_row(n-1)
    def bezier(ts):
        # This uses the generalized formula for bezier curves
        # http://en.wikipedia.org/wiki/B%C3%A9zier_curve#Generalization
        result=[]
        for t in ts:
            tpowers=(t**i for i in range(n))
            upowers=reversed([(1-t)**i for i in range(n)])
            coefs=[c*a*b for c,a,b in zip(combinations,tpowers,upowers)]
            result.append(
                tuple(sum([coef*p for coef,p in zip(coefs,ps)]) for ps in zip(*xys)))
        return result
    return bezier

def pascal_row(n):
    # This returns the nth row of Pascal's Triangle
    result=[1]
    x,numerator=1,n
    for denominator in range(1,n//2+1):
        # print(numerator,denominator,x)
        x*=numerator
        x/=denominator
        result.append(x)
        numerator-=1
    if n&1==0:
        # n is even
        result.extend(reversed(result[:-1]))
    else:
        result.extend(reversed(result)) 
    return result
#following function extracts the SVG path information from a pre prepared txt file. instructions on how to prepare this file coming soon
def get_paths():
    f=open("paths.txt", "r")
    paths=f.read()
    path=paths.split("\n")
    for command in path:
        if command[-1]=='c':
            coords=command.split(" ")
            #Dividimg by ten to bring to required image scale
            xys=[(int(coords[0])/10, int(coords[1])/10), (int(coords[2])/10, int(coords[3])/10), (int(coords[4])/10, int(coords[5])/10)]      
            bezier=make_bezier(xys)
            points.extend(bezier(ts))   
#following function brings image coodinates to my CNC's coordinate scale           
def scale(point):
    pointcncxy=(int((point[0]/675)*318)-159,int((point[1]/920)*350)-175)
    return pointcncxy
    
if __name__=='__main__':
    counter = 0
    ser.write('?')
    if ser.read() == 'r':
        print "CNC is Alive"
    
    im = Image.new('RGBA', (675, 920), (0, 0, 0, 0)) 
    draw = ImageDraw.Draw(im)
    ts=[t/100.0 for t in range(101)]
    xys=[(290 ,897), (304 ,869), (304 ,866)]
    bezier=make_bezier(xys)
    points=bezier(ts)
    get_paths()
    prevdot=(0,0)
    #print str(points[0])
    for dot in points:
        curdot=scale(dot)
        if math.sqrt(((prevdot[0]-curdot[0])*(prevdot[0]-curdot[0]))+((prevdot[1]-curdot[1])*(prevdot[1]-curdot[1]))) >= 1 :
            print str(scale(dot))
            ser.write(str(scale(dot)))
            while ser.read() != 'n':
                continue
            ser.flushInput()
            ser.flushOutput()
            counter+=1
            print "GOT n \n"
            time.sleep(0.02)
        prevdot=curdot
    print "Number f Unique points drawn : ",counter
    draw.polygon(points,outline='red')
    im.save('out.png')
