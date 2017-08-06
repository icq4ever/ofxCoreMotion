#pragma once

#include "ofxiOS.h"
#include "ofxCoreMotion.h"
#include "ofxiOSCoreLocation.h"
#include "ofxOSC.h"

#define HOST "192.168.100.12"
//#define HOST "192.168.0.11"			// 프로세싱앱이 실행되는 머신의 ip주소로 변경해줍니다. 아이폰과 실행되는 머신은 같은 공유기 혹은 라우터에 물려있어야 합니다.
#define PORT 12345					// osc 포트주소는 12345


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
	ofxiOSCoreLocation * coreLocation;
	float heading;
	float gpsLatitude;
	float gpsLongitude;
	
	bool hasCompass;
	bool hasGPS;
	
	int numberOfDepthScene = 5;
	
	ofVec3f linearAccel;
	ofVec3f lastLinearAccel;
	ofVec3f lastAccel;
	
	ofVec3f speed;
	ofVec3f lastSpeed;
	
	ofVec3f distance;
	ofVec3f lastDistance;
	
	ofVec3f gyro, lastGyro;
	
	uint64_t lastTickedTimer;
	
	unsigned int countx, county ,countz;
//	bool method01 = true;
	
	ofxOscSender sender;
};


