#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){	

    ofSetFrameRate(60);
    ofBackground(255, 255, 0);
    

    coreMotion.setupMagnetometer();
    coreMotion.setupGyroscope();
    coreMotion.setupAccelerometer();
    coreMotion.setupAttitude(CMAttitudeReferenceFrameXMagneticNorthZVertical);
	
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
	
	if(ofGetFrameNum() % 120 == 0){
		ofxOscMessage m;
		m.setAddress("/misc/heartbeat");
		m.addIntArg(ofGetFrameNum());
		sender.sendMessage(m);
	}
	
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
	
	linearAccelerometer.addStringArg(ofToString(a.x-gr.x, 3));
	linearAccelerometer.addStringArg(ofToString(a.y-gr.y, 3));
	linearAccelerometer.addStringArg(ofToString(a.z-gr.z, 3));
	
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
	
	
	
    ofFill();
    ofDrawBitmapStringHighlight(ofToString("Double tap to reset \nAttitude reference frame"), 20, ofGetHeight() - 50, ofColor::yellow, ofColor::black);
}

void ofApp::dododo(){
//	ofVec3f speed;
//	ofVec3f distance;
	ofVec3f accel = coreMotion.getAccelerometerData();
	ofVec3f gyro = coreMotion.getGyroscopeData();
//	ofVec3f magneto = coreMotion.getMagnetometerData();
	ofVec3f gravity = coreMotion.getGravity();
//	ofVec3f angle = coreMotion.get
	
	
	// remove acceleration from gravity
	accel = accel - gravity;
//	accel.z -= (abs(gyro.y) - abs(lastGyro.y));
	
	// filtering
	if(abs(accel.x) < 0.1 ) accel.x = 0;
	if(abs(accel.y) < 0.1 ) accel.y = 0;
	if(abs(accel.z) < 0.1 ) accel.z = 0;
	
	accel.x == 0 ? countx++ : countx = 0;
	accel.y == 0 ? county++ : county = 0;
	accel.z == 0 ? countz++ : countz = 0;
	
	
	if(countx>=20)	{ speed.x = 0; lastSpeed.x = 0;}
	if(county>=20)	{ speed.y = 0; lastSpeed.y = 0;}
	if(countz>=20)	{ speed.z = 0; lastSpeed.z = 0;}
	
	
	// Newton - D'Lambery physics for no relativistic speeds dictates
	// speed = lastSpeed + (currentAcceleration - lastAcceleration)/2 * INTERVAL
	speed.x = lastSpeed.x + lastAccel.x + (accel.x - lastAccel.x)/2 * 1/100;
	speed.y = lastSpeed.y + lastAccel.y + (accel.y - lastAccel.y)/2 * 1/100;
	speed.z = lastSpeed.z + lastAccel.z + (accel.z - lastAccel.z)/2 * 1/100;
	
	
	// location = lastLocation + (currentSpeed - lastSpeed)/2 * INTERVAL
	distance.x = lastDistance.x + lastSpeed.x + (speed.x - lastSpeed.x)/2 * 1/100;
	distance.y = lastDistance.y + lastSpeed.y + (speed.y - lastSpeed.y)/2 * 1/100;
	distance.z = lastDistance.z + lastSpeed.z + (speed.z - lastSpeed.z)/2 * 1/100;

	lastAccel = accel;
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
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    // resets attitude to current
    coreMotion.resetAttitude();
	
	speed = ofVec3f(0, 0, 0);
	lastSpeed = ofVec3f(0,0,0);
	distance = ofVec3f(0, 0, 0);
	lastDistance = ofVec3f(0,0,0);
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
