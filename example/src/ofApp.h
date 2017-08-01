#pragma once

#include "ofxiOS.h"
#include "ofxCoreMotion.h"
#include "ofxOSC.h"

#define HOST "192.168.0.11"
#define PORT 12345

class ofApp : public ofxiOSApp {
	
public:
    
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
	
	void dododo();

    ofxCoreMotion coreMotion;
	
	ofVec3f lastAccel;
	
	ofVec3f speed;
	ofVec3f lastSpeed;
	
	ofVec3f distance;
	ofVec3f lastDistance;
	
	ofVec3f gyro, lastGyro;
	
	uint64_t lastTickedTimer;
	
	unsigned int countx, county ,countz;
	
	ofxOscSender sender;
};


