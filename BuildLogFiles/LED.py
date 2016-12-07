import RPi.GPIO as GPIO  
import time
# blinking function  
def blink(pin):  
        GPIO.output(pin,GPIO.HIGH)  
        time.sleep(0.125)  
        GPIO.output(pin,GPIO.LOW)  
        time.sleep(0.125)  
        return  
# to use Raspberry Pi board pin numbers  
GPIO.setmode(GPIO.BOARD)  
# set up GPIO output channel  
GPIO.setup(12, GPIO.OUT)  
# blink GPIO17 50 times  
for i in range(0,11):  
        blink(12)  
GPIO.cleanup() 
