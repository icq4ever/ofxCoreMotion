#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){	

    ofSetFrameRate(60);
    ofBackground(255, 255, 0);
	

    coreMotion.setupMagnetometer();
    coreMotion.setupGyroscope();
    coreMotion.setupAccelerometer();
    coreMotion.setupAttitude(CMAttitudeReferenceFrameXMagneticNorthZVertical);
	
	coreLocation = new ofxiOSCoreLocation();
	hasCompass = coreLocation->startHeading();
	hasGPS = coreLocation->startLocation();
	
	heading = 0.0;
	
	lastTickedTimer = ofGetElapsedTimeMillis();
	
	sender.setup(HOST, PORT);
}

//--------------------------------------------------------------
void ofApp::update(){
    coreMotion.update();
	
	if(ofGetElapsedTimeMillis() - lastTickedTimer > 10){	// every 10 ms
		dododo();
		lastTickedTimer = ofGetElapsedTimeMillis();
	}
	
	// mobile이므로, 휴면상태에 빠지지 않도록 1초마다 한번 hearbeat신호를 보낸다.
	if(ofGetFrameNum() % 120 == 0){
		ofxOscMessage m;
		m.setAddress("/misc/heartbeat");
		m.addIntArg(ofGetFrameNum());
		sender.sendMessage(m);
	}
	
	heading = ofLerpDegrees(heading, -coreLocation->getTrueHeading(), 0.7);
	
}

//--------------------------------------------------------------
void ofApp::draw(){
	ofQuaternion quat = coreMotion.getQuaternion();
	ofVec3f a = coreMotion.getAccelerometerData();
	ofVec3f gr = coreMotion.getGravity();
	ofVec3f g = coreMotion.getGyroscopeData();
	ofVec3f m = coreMotion.getMagnetometerData();
	
	ofPushMatrix();
	ofTranslate(ofGetWidth()/2, ofGetHeight()/2);
	
	ofPushMatrix();
	ofTranslate(-distance);
	// 1) quaternion rotations
	float angle;
	ofVec3f axis;//(0,0,1.0f);
	quat.getRotate(angle, axis);
	ofRotate(angle, axis.x, -axis.y, axis.z); // rotate with quaternion
	
	// 2) rotate by multiplying matrix directly
	//    ofMatrix4x4 mat = coreMotion.getRotationMatrix();
	//    mat.rotate(180, 0, -1.0f, 0);
	//    ofMultMatrix(mat); // OF 0.74: glMultMatrixf(mat.getPtr());
	
	// 3) rotate with eulers
	//    ofRotateX( ofRadToDeg( coreMotion.getPitch() ) );
	//    ofRotateY( -ofRadToDeg( coreMotion.getRoll() ) );
	//    ofRotateZ( ofRadToDeg( coreMotion.getYaw() ) );
	
	ofNoFill();
	for(int i=-3; i<3; i++){
		for(int j=-3; j<3; j++){
			for(int k=-3; k<3; k++){
				ofDrawBox(i*100, j*100, k*100, 80); // OF 0.74: ofBox(0, 0, 0, 220);
				ofDrawAxis(10);
			}
		}
		
	}
	
	ofPopMatrix();
	ofPopMatrix();

	
	
	/////////////////////////////////////////  화면출력 및 osc 메시지
	
    // attitude- quaternion
    ofDrawBitmapStringHighlight("Attitude: (quaternion x,y,z,w)", 20, 25);
    ofSetColor(0);
	
	ofxOscMessage quarternion;
	quarternion.setAddress("/status/quarternion");
	
	
	string qx, qy, qz, qw;
	quat.x() < 0 ? qx = ofToString(quat.x(),3) : qx = " " + ofToString(quat.x(), 3);
	quat.y() < 0 ? qx = ofToString(quat.y(),3) : qx = " " + ofToString(quat.y(), 3);
	quat.z() < 0 ? qx = ofToString(quat.z(),3) : qx = " " + ofToString(quat.z(), 3);
	quat.w() < 0 ? qx = ofToString(quat.w(),3) : qx = " " + ofToString(quat.w(), 3);
	
	quarternion.addFloatArg(quat.x());
	quarternion.addFloatArg(quat.y());
	quarternion.addFloatArg(quat.z());
	quarternion.addFloatArg(quat.w());
	sender.sendMessage(quarternion);
	
	ofDrawBitmapStringHighlight(qx, 20, 50, ofColor::yellow, ofColor::black);
    ofDrawBitmapStringHighlight(qy, 90, 50, ofColor::yellow, ofColor::black);
    ofDrawBitmapStringHighlight(qz, 160, 50, ofColor::yellow, ofColor::black);
    ofDrawBitmapStringHighlight(qw, 230, 50, ofColor::yellow, ofColor::black);
    
    // attitude- roll,pitch,yaw
    ofDrawBitmapStringHighlight("Attitude: (roll,pitch,yaw)", 20, 75);
    ofSetColor(0);
	
	ofxOscMessage attitude;
	attitude.setAddress("/status/attitude");
	attitude.addFloatArg(coreMotion.getRoll());
	attitude.addFloatArg(coreMotion.getPitch());
	attitude.addFloatArg(coreMotion.getYaw());
	sender.sendMessage(attitude);
	
	string stRoll, stPitch, stYaw;
	coreMotion.getRoll() < 0	? stRoll = ofToString(coreMotion.getRoll(), 3)	: stRoll = " "  + ofToString(coreMotion.getRoll(), 3);
	coreMotion.getPitch() < 0	? stRoll = ofToString(coreMotion.getPitch(), 3) : stPitch = " " + ofToString(coreMotion.getPitch(), 3);
	coreMotion.getYaw() < 0		? stYaw  = ofToString(coreMotion.getYaw(), 3)	: stRoll = " "  + ofToString(coreMotion.getYaw(), 3);
	
    ofDrawBitmapStringHighlight(stRoll, 20, 100, ofColor::yellow, ofColor::black);
    ofDrawBitmapStringHighlight(stPitch, 120, 100, ofColor::yellow, ofColor::black);
    ofDrawBitmapStringHighlight(stYaw, 220, 100, ofColor::yellow, ofColor::black);
    
    // accelerometer
	
	
	
    ofDrawBitmapStringHighlight("Accelerometer - gravity removed : (x,y,z)", 20, 125);
    ofSetColor(0);
	
	ofxOscMessage accelerometer;
	ofxOscMessage linearAccelerometer;
	
	accelerometer.setAddress("/status/accelerometer");
	linearAccelerometer.setAddress("/status/linearAccelerometer");
	accelerometer.addStringArg(ofToString(a.x, 3));
	accelerometer.addStringArg(ofToString(a.y, 3));
	accelerometer.addStringArg(ofToString(a.z, 3));
	
	linearAccelerometer.addStringArg(ofToString(linearAccel.x, 3));
	linearAccelerometer.addStringArg(ofToString(linearAccel.y, 3));
	linearAccelerometer.addStringArg(ofToString(linearAccel.z, 3));
	
	sender.sendMessage(accelerometer);
	sender.sendMessage(linearAccelerometer);
	
	string aX, aY, aZ;
	a.x - gr.x < 0 ? aX = ofToString(a.x - gr.x ,3) : aX = " " + ofToString(a.x - gr.x ,3);
	a.y - gr.y < 0 ? aY = ofToString(a.y - gr.y ,3) : aY = " " + ofToString(a.y - gr.y ,3);
	a.z - gr.z < 0 ? aZ = ofToString(a.z - gr.z ,3) : aZ = " " + ofToString(a.z - gr.z ,3);
	
    ofDrawBitmapStringHighlight(aX, 20, 150, ofColor::yellow, ofColor::black);
    ofDrawBitmapStringHighlight(aY, 120, 150, ofColor::yellow, ofColor::black);
    ofDrawBitmapStringHighlight(aZ, 220, 150, ofColor::yellow, ofColor::black);
    
    // gyroscope
	
	
	ofSetColor(255);
//	ofDrawRectangle(20, 172,
    ofDrawBitmapStringHighlight("Gyroscope: (x,y,z)", 20, 175);
    ofSetColor(0);
	
	ofxOscMessage gyroscope;
	gyroscope.setAddress("/status/gyroscope");
	gyroscope.addStringArg(ofToString(g.x));
	gyroscope.addStringArg(ofToString(g.y));
	gyroscope.addStringArg(ofToString(g.z));
	sender.sendMessage(gyroscope);
	
	string gX, gY, gZ;
	g.x < 0 ? gX = ofToString(g.x, 3) : gX = " " + ofToString(g.x, 3);
	g.y < 0 ? gY = ofToString(g.y, 3) : gY = " " + ofToString(g.y, 3);
	g.z < 0 ? gZ = ofToString(g.z, 3) : gZ = " " + ofToString(g.z, 3);
	
    ofDrawBitmapStringHighlight(gX, 20, 200, ofColor::yellow, ofColor::black);
    ofDrawBitmapStringHighlight(gY, 120, 200, ofColor::yellow, ofColor::black);
    ofDrawBitmapStringHighlight(gZ, 220, 200, ofColor::yellow, ofColor::black);
    
    // magnetometer
	
    ofDrawBitmapStringHighlight("Magnetometer: (x,y,z)", 20, 225);
    ofSetColor(0);
	
	ofxOscMessage magnetometer;
	magnetometer.setAddress("/status/magnetometer");
	magnetometer.addStringArg(ofToString(m.x));
	magnetometer.addStringArg(ofToString(m.y));
	magnetometer.addStringArg(ofToString(m.z));
	sender.sendMessage(magnetometer);
	
	string mX, mY, mZ;
	m.x <0 ? mX = ofToString(m.x,3) : mX = " " + ofToString(m.x,3);
	m.y <0 ? mY = ofToString(m.y,3) : mY = " " + ofToString(m.y,3);
	m.z <0 ? mZ = ofToString(m.z,3) : mZ = " " + ofToString(m.z,3);
	
    ofDrawBitmapStringHighlight(mX, 20, 250, ofColor::yellow, ofColor::black);
    ofDrawBitmapStringHighlight(mY, 120, 250, ofColor::yellow, ofColor::black);
    ofDrawBitmapStringHighlight(mZ, 220, 250, ofColor::yellow, ofColor::black);
    
	ofDrawBitmapStringHighlight("Speedometer: (x,y,z)", 20, 325);
	ofSetColor(0);
	
	string sX, sY, sZ;
	speed.x < 0 ? sX = ofToString(speed.x,3) : sX = " " + ofToString(speed.x,3);
	speed.y < 0 ? sY = ofToString(speed.y,3) : sY = " " + ofToString(speed.y,3);
	speed.z < 0 ? sZ = ofToString(speed.z,3) : sZ = " " + ofToString(speed.z,3);
	
	ofDrawBitmapStringHighlight(sX, 20, 350, ofColor::yellow, ofColor::black);
	ofDrawBitmapStringHighlight(sY, 120, 350, ofColor::yellow, ofColor::black);
	ofDrawBitmapStringHighlight(sZ, 220, 350, ofColor::yellow, ofColor::black);
	
	ofDrawBitmapStringHighlight("Pedometer: (x,y,z)", 20, 375);
	ofSetColor(0);
	
	string dX, dY, dZ;
	distance.x < 0 ? dX = ofToString(distance.x,3) : dX = " " + ofToString(distance.x,3);
	distance.y < 0 ? dY = ofToString(distance.y,3) : dY = " " + ofToString(distance.y,3);
	distance.z < 0 ? dZ = ofToString(distance.z,3) : dZ = " " + ofToString(distance.z,3);
	
	ofDrawBitmapStringHighlight(dX, 20, 400, ofColor::yellow, ofColor::black);
	ofDrawBitmapStringHighlight(dY, 120, 400, ofColor::yellow, ofColor::black);
	ofDrawBitmapStringHighlight(dZ, 220, 400, ofColor::yellow, ofColor::black);
	
	ofxOscMessage mSpeed, mDistance;
	mSpeed.setAddress("/status/speed");
	mDistance.setAddress("/status/distance");
	
	mSpeed.addStringArg(ofToString(speed.x));
	mSpeed.addStringArg(ofToString(speed.y));
	mSpeed.addStringArg(ofToString(speed.z));
	
	mDistance.addStringArg(ofToString(distance.x));
	mDistance.addStringArg(ofToString(distance.y));
	mDistance.addStringArg(ofToString(distance.z));
	
	sender.sendMessage(mSpeed);
	sender.sendMessage(mDistance);
	
	
	
	// GPS 정보 출력
	if(hasGPS){
		ofDrawBitmapStringHighlight("LAT : " + ofToString(coreLocation->getLatitude()), 20, 425, ofColor::cyan, ofColor::black);
		ofDrawBitmapStringHighlight("LON : " + ofToString(coreLocation->getLongitude()), ofGetWidth()/2+20, 425, ofColor::cyan, ofColor::black);
		gpsLatitude = coreLocation->getLatitude();
		gpsLongitude = coreLocation->getLongitude();
		
		
		// GPS 정보를 OSC로 전달
		ofxOscMessage gpsLocation;
		gpsLocation.setAddress("/status/gpsLocation");
		gpsLocation.addStringArg(ofToString(gpsLatitude));
		gpsLocation.addStringArg(ofToString(gpsLongitude));
		
		sender.sendMessage(gpsLocation);
	}
	
//	if(method01)	{
//		ofDrawBitmapStringHighlight("2nd", ofGetWidth()-40, ofGetHeight()-40, ofColor::magenta, ofColor::white);
//	} else {
//		ofDrawBitmapStringHighlight("1st", ofGetWidth() - 40, ofGetHeight()-40, ofColor::magenta, ofColor::white);
//	}
	
	// instruction text
    ofFill();
    ofDrawBitmapStringHighlight(ofToString("Double tap to reset \nAttitude reference frame"), 20, ofGetHeight() - 50, ofColor::yellow, ofColor::black);
}


// update() 에서 매번 업데이트됨.
void ofApp::dododo(){
	
	// 변수 설명
	// accel		: raw 가속도계
	// linearAccel  : (raw 가속도 - 중력가속도) -> 필터링된 가속도계
	
	// 가속도, 자이로, 중력값을 얻어와 vector3으로 얻어온다.
	// ofVec3f linearAccel : 전역 변수로 적용됨.
	ofVec3f accel = coreMotion.getAccelerometerData();
	ofVec3f gyro = coreMotion.getGyroscopeData();
	ofVec3f gravity = coreMotion.getGravity();
	
	
	// 가속도계에서 중력 벡터를 제거한다.
	
	linearAccel = accel - gravity;
	
	//*******************************************************************************  필터링
	// 가속도계의 변화가 미비할경우 (폰이 고정되어있을 때), 가속도를 0으로 무시한다.
	if(abs(linearAccel.x) < 0.1 ) linearAccel.x = 0;
	if(abs(linearAccel.y) < 0.1 ) linearAccel.y = 0;
	if(abs(linearAccel.z) < 0.1 ) linearAccel.z = 0;
	
	// 지속적으로 폰이 고정되어있다고 판단되면, 카운트를 증가시키는데..
	linearAccel.x == 0 ? countx++ : countx = 0;
	linearAccel.y == 0 ? county++ : county = 0;
	linearAccel.z == 0 ? countz++ : countz = 0;
	
	// 20번이상 고정되어있다 판단되면, 속도를 0으로 바꾼다.
	if(countx>=20)	{ speed.x = 0; lastSpeed.x = 0;}
	if(county>=20)	{ speed.y = 0; lastSpeed.y = 0;}
	if(countz>=20)	{ speed.z = 0; lastSpeed.z = 0;}
	
	
	// 자이로의 값이 클경우에는 가속도, 속도를 0으로 무시한다
	if(abs(gyro.x) > 1 || abs(gyro.y) > 1 || abs(gyro.z) > 1){
		linearAccel.x = 0;
		speed.x = 0;
		linearAccel.y = 0;
		speed.y = 0;
		linearAccel.z = 0;
		speed.z = 0;
	}
	
	
//	if(method01){
		// Newton - D'Lambery physics for no relativistic speeds dictates
		// speed = lastSpeed + (currentAcceleration + lastAcceleration)/2 * INTERVAL
		// 적분 : 속도 = 이전속도 + 가속도 평균 * 시간차
		speed.x = lastSpeed.x + (linearAccel.x + lastLinearAccel.x)/2 * 1/100;
		speed.y = lastSpeed.y + (linearAccel.y + lastLinearAccel.y)/2 * 1/100;
		speed.z = lastSpeed.z + (linearAccel.z + lastLinearAccel.z)/2 * 1/100;
		
		
		// location = lastLocation + (currentSpeed + lastSpeed)/2 * INTERVAL
		// 적분 : 거리 = 이전거리 + 속도 평균 * 시간차
		distance.x = lastDistance.x + (speed.x + lastSpeed.x)/2 * 1/100;
		distance.y = lastDistance.y + (speed.y + lastSpeed.y)/2 * 1/100;
		distance.z = lastDistance.z + (speed.z + lastSpeed.z)/2 * 1/100;
//	}
//	else {
//		speed.x = lastSpeed.x + lastLinearAccel.x + (linearAccel.x - lastLinearAccel.x)/2 * 1/100;
//		speed.y = lastSpeed.y + lastLinearAccel.y + (linearAccel.y - lastLinearAccel.y)/2 * 1/100;
//		speed.z = lastSpeed.z + lastLinearAccel.z + (linearAccel.z - lastLinearAccel.z)/2 * 1/100;
//		
//		
//		// location = lastLocation + (currentSpeed + lastSpeed)/2 * INTERVAL
//		distance.x = lastDistance.x + lastSpeed.x + (speed.x - lastSpeed.x)/2 * 1/100;
//		distance.y = lastDistance.y + lastSpeed.y + (speed.y - lastSpeed.y)/2 * 1/100;
//		distance.z = lastDistance.z + lastSpeed.z + (speed.z - lastSpeed.z)/2 * 1/100;
//	}

	
	lastAccel = accel;
	lastLinearAccel = linearAccel;
	lastSpeed = speed;
	lastDistance = distance;
	lastGyro = gyro;
}

//--------------------------------------------------------------
void ofApp::exit(){ }
//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){ }
//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){ }
//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){ }
//--------------------------------------------------------------
// 더블탭을 할 경우..
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    // resets attitude to current
    coreMotion.resetAttitude();
	
	speed = ofVec3f(0, 0, 0);
	lastSpeed = ofVec3f(0,0,0);
	distance = ofVec3f(0, 0, 0);
	lastDistance = ofVec3f(0,0,0);
	
//	method01 = !method01;
}


//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){ }
//--------------------------------------------------------------
void ofApp::lostFocus(){ }
//--------------------------------------------------------------
void ofApp::gotFocus(){ }
//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){ }
//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){ }
