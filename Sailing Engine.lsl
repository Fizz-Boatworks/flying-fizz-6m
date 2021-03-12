// Fixed values messaging
integer MSGTYPE_MODECHANGE=50001;
integer MSGTYPE_SAILHANDLING=50002;
integer MSGTYPE_SETTINGSCHANGE=50003;
integer MSGTYPE_STEERING=55016;
integer MSGTYPE_SAILMODE=50017;
integer MSGTYPE_SAILINFO=50007;
integer MSGTYPE_CREWINFO=50100;
integer MSGTYPE_CREWSEATED=70400; // 1-4 crewmembers 70401 = helmsman, 70402 = crew 1, 70403=crew2, 70404=crew 3, send avatar's UUID when seated and NULL_KEY when avatar has left
integer MSGTYPE_TACKING = 50019;
integer MSGTYPE_SAY = 51000;
integer MSGTYPE_WHISPER = 52000;
integer MSGTYPE_SHOUT = 53000;
integer MSGTYPE_WWCRACE=70500;
integer MSGTYPE_WWCWAVES=70502;
integer MSGTYPE_MOTORING=50018;
integer MSGTYPE_CAPSIZED=50147;
integer MSGTYPE_SCRIPTCHECK=54350;
integer MSGTYPE_TEXTURECHANGE=79880;

// Fixed values other
integer VEHICLE_SAILING=1;
integer VEHICLE_FLOATING=2;
integer VEHICLE_MOORED=0;
float   TIMERINTERVAL=0.6;        //timer frequency, seconds
float   FLOATLEVEL=-0.45;
float   HEELTHRESHOLD=0.05;
float   LEVELTHRESHOLD=0.03;

// Settings propulsion
integer mainSailArea=25;
integer jibSailArea=15;
integer gnkSailArea=48;
integer gnkCollapseWindAngle=85;
integer gnkCollapseWindAngleTo=160;
integer shouldRemoveJib=0;
float   windPower2Kg=1.0;
float   windDragFactor=1.0;
float   windSpeedSailOpen=14.0;
float   windDragEff=1.0;
float   dragEfficX=1.0;
float   dragEfficY=1.0;
float   hullSpeed=2.8;
integer canPlane=1;
float   foilSpeed=0.0;
float   speedMultiplier=1.0;
float   waveSpeedSensitivity=1.0;
float   waveSteerSensitivity=1.0;
float   weatherHelmSensitivity=1.0;
float   extraDrag45=1.0;
integer minSheetAngle=5;  // send to this script by link message
integer maxSheetAngle=70;  // send to this script by link message
integer minUpwindAngle=22;
float   upwindStretchFactor=0.15; // increase this if you want the boat to sail higher upwind

// Settings heel
float   widthHull=1.0;
integer mastHeight=7;
integer weightHull=80;
integer weightCrewPerPerson=75;
integer weightRig=15;
integer ballast=0;
float   ballastDepth=0.0;
float   wingsTouchWaterHeel=0.0;
float   waveHeelAt1MeterHeight=11.0;
float   momentumHeelX=1.5;
float   momentumHeelY=2.5;
float   overallStability=1.0;
float   heelXsensitivityCrew=1.0;
float   heelXsensitivityRig=1.0;
float   heelXsensitivityHull=1.0;
float   heelYsensitivity=1.0;
float   heelPattern=1.0; // 0-99.9 bigger: more end heel, smaller less end heel
float   WAVEDELAY=0.5; // 0.0 for ultralight boats, 1.0 for very heavy boats
float   EXTRAHEELPLANING=5.0;

// Settings vehicle
float   EXTRAHEIGHT_HEELY=20.0;
float   EXTRAHEIGHT_HEELX=20.0;
float   MAXTURNSPEED=1.5;  // was 1.8
float   TURNINCREASE=0.15;  // was 0.52
float   TURN_HEEL = 1.25; // extra turnspeed because of heel;

// linknums
integer mainsailLinkNum=0;
integer foresailLinkNum=0;
integer gennakerLinkNum=0;
integer boomLinkNum=0;
integer mainsheetLinkNum=0;
integer rudderLinkNum=0;  //only for test
integer jibsheetLinkNum=0;
integer gennakersheetLinkNum=0;

// sails variables;
//integer sailingMode=0;
//integer hasCapsized=0;
integer curMainsailAngle=999;
integer curForesailAngle=999;
integer curGennakerAngle=999;
integer curMainsailSide=0;
integer curForesailSide=0;
integer curGennakerSide=0;
integer curTellTalesMain=-1;
integer curTellTalesJib=-1;

// Variables sailing
integer compass;
float   boatSpeed;
float   boatSpeedX;
float   boatSpeedY;
float   waterSpeed;
integer relativeWindDir;
integer absRelWindDir;
float   apparentWindSpeed;
float   apparentWindSpeedX;
integer apparentWindDir;
integer absApparentWindDir;
integer windType;

// Variables propulsion
integer isPlaning;
integer isFoiling;
integer dropGennakerCounter=0;
integer raiseGennakerCounter=0;
integer gennakerToRaise=0;



integer mainSheetSetting=2;  // sheet setting mainsail (0-flapping, 1-loose, 2-optimal, 3-tight, 4-very tight),
integer jibSheetSetting=2;  // sheet setting jib (0-flapping, 1-loose, 2-optimal, 3-tight, 4-very tight),
integer gennakerSheetSetting=2;  // sheet setting gennaker (0-flapping, 1-loose, 2-optimal, 3-tight, 4-very tight),
integer mainSheetAngle=45;
integer jibSheetAngle=45;
integer gnkSheetAngle=45;
integer mainTrim=2;
integer jibTrim=2;
integer jibRaised=1;
integer gnkRaised=0;
integer gnkCollapsed=0;
integer idealSailTrim;
float   idealSailWindAngle;
integer idealSheet;
integer airFlowAngle;
float   airFlow;
float   windDrag;
float   windPush;
float   sailForceX;
float   sailForceY;
float   dragX;
float   speedX=0.0;
float   speedY=0.0;

// Variables heel
integer hasCapsized=0;
integer capsizeCounter=0;
integer extraHikeCounter=0;
integer extraHike=0;
integer crewCount=2;
integer crew0Pos=0;
integer crew1Pos=0;
integer crew2Pos=0;
integer crew3Pos=0;
float   heelX=0.0;
float   actualHeelX=0.0;
float   heelY;
float   boatRotX=0.0;
integer actualHeelXWhenSteering=0;
float   waveHeight=0.0;
float   waveLength;
float   waveCycle;
float   waveHeelX;
float   waveElevation;
float   waveHeelY;
float   waveSpeedEffect;
float   steerEffect;
float   noseDivePoints=0.0;

// Variables vehicle
integer steerCounter=0;
float   seaLevel=20.0;
float   curHeight=0.0;
integer steeringDir=0;
float   counterSteer=0.0;
float   currentSpeed;
integer currentDir;
float   currentX;
float   currentY;

// Variables other
integer sailingMode=0;
integer prevcrew0Pos=99;
integer prevcrew1Pos=99;
integer prevcrew2Pos=99;
integer prevcrew3Pos=99;
integer prevSailValues=999;
integer prevGennaker=999;
integer prevCapsized=999;
float   prevZRot=0.0;
float   prevXRot=0.0;
float   prevYRot=0.0;
integer prevSteeringDir=0;
vector  globalPos;
float   globalTime;
float   previousTime=0.0;

// WWC parameters
integer wwcRaceId=0;
integer wwcSailMode=0;
integer wwcCrewSize=0;
string  wwcRcName="";
string  wwcRcClass="";
string  wwcRcVersion="";
string  wwcRcExtra1="";
string  wwcRcExtra2="";
float   wwcWaveOriginX=0.0;
float   wwcWaveOriginY=0.0;
float   wwcWaveSpeed=0.0;
float   wwcWaveLength=0.0;

// variables for reading notecards
key     settingsQueryID;             // id used to identify dataserver queries reading notecard
string  notecardName;
integer controlNotecardLine;

integer willCapsize=0;
integer activatedYN=0;
integer scriptCheck=0;
string secretScriptKey="JKLU97RW";
string expectedScriptReply="";
integer extraTexureScriptPresent=0;

init() {
    getLinkNums();
    activatedYN=1;
    llSetTimerEvent(0);
    gnkRaised=0;
    hasCapsized=0;
    prevSailValues=999;
    prevGennaker=999;
    prevCapsized=999;
    sailingMode=VEHICLE_MOORED;
    setPhysicsOnOff();
//llOwnerSay((string)llGetFreeMemory());
    llOwnerSay(llGetScriptName()+" ready ("+(string)llGetFreeMemory()+" free)");
}

getLinkNums() {
    integer i;
    integer linkcount=llGetNumberOfPrims();
    for (i=1;i<=linkcount;++i) {
        string str=llGetLinkName(i);
        if (str=="mainsail") mainsailLinkNum=i;
        else if (str=="foresail") foresailLinkNum=i;
        else if (str=="gennaker") gennakerLinkNum=i;
        else if (str=="boom") boomLinkNum=i;
        else if (str=="mainsheet") mainsheetLinkNum=i;
        else if (str=="rudder") rudderLinkNum=i;
        else if (str=="jib sheet") jibsheetLinkNum=i;
        else if (str=="gennaker sheet") gennakersheetLinkNum=i;
    }
}

setPhysicsOnOff() {
    setVehicleParams();
    if(sailingMode!=VEHICLE_MOORED) {
        llSetStatus(STATUS_PHYSICS,TRUE);            //*****
    } else {
        llSetStatus(STATUS_PHYSICS,FALSE);
        setInitialPosition();
        //upright();
    }
}

setInitialPosition() {
    vector pos=llGetPos();
    float groundHeight=llGround(ZERO_VECTOR);
    float waterHeight = llWater(ZERO_VECTOR);
    seaLevel=llWater(ZERO_VECTOR);
    //upright
    vector vecRot = llRot2Euler(llGetRot());
    llSetRot(llEuler2Rot(<0,0,vecRot.z>));
    //if over water, set boat height to sealevel;
    if (groundHeight <= waterHeight) {
        pos.z = waterHeight + FLOATLEVEL;
        while (llVecDist(llGetPos(),pos)>.001) llSetPos(pos);
    } else seaLevel=groundHeight;
}

setVehicleParams() {
    llSetVehicleType         (VEHICLE_TYPE_BOAT);
    llSetVehicleRotationParam(VEHICLE_REFERENCE_FRAME,ZERO_ROTATION);
    llSetVehicleFlags        (VEHICLE_FLAG_NO_DEFLECTION_UP | VEHICLE_FLAG_HOVER_GLOBAL_HEIGHT | VEHICLE_FLAG_LIMIT_MOTOR_UP );
    llSetVehicleVectorParam  (VEHICLE_LINEAR_FRICTION_TIMESCALE,<100.0,100.0,0.5>);
    llSetVehicleFloatParam   (VEHICLE_LINEAR_MOTOR_TIMESCALE,0.6);
    llSetVehicleFloatParam   (VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE,0.6);
    llSetVehicleVectorParam  (VEHICLE_ANGULAR_FRICTION_TIMESCALE,<0.1,0.1,0.04>);  // <1000,1000,0.01>
    llSetVehicleFloatParam   (VEHICLE_ANGULAR_MOTOR_TIMESCALE,0.02);// was 0.04
    llSetVehicleFloatParam   (VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE,0.6);
    llSetVehicleVectorParam  (VEHICLE_LINEAR_MOTOR_DIRECTION,ZERO_VECTOR);
    llSetVehicleVectorParam  (VEHICLE_ANGULAR_MOTOR_DIRECTION,ZERO_VECTOR);
    llSetVehicleFloatParam   (VEHICLE_LINEAR_DEFLECTION_EFFICIENCY,0.85);
    llSetVehicleFloatParam   (VEHICLE_LINEAR_DEFLECTION_TIMESCALE,1.0);
    llSetVehicleFloatParam   (VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY,1.0);
    llSetVehicleFloatParam   (VEHICLE_ANGULAR_DEFLECTION_TIMESCALE,1.0);
    llSetVehicleFloatParam   (VEHICLE_VERTICAL_ATTRACTION_TIMESCALE,3.0);
    llSetVehicleFloatParam   (VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY,0.8);
    llSetVehicleFloatParam   (VEHICLE_BANKING_EFFICIENCY,0.0);
    llSetVehicleFloatParam   (VEHICLE_BANKING_MIX,0.8);
    llSetVehicleFloatParam   (VEHICLE_BANKING_TIMESCALE,1.0);
    llSetVehicleFloatParam   (VEHICLE_HOVER_HEIGHT,seaLevel+FLOATLEVEL);
    llSetVehicleFloatParam   (VEHICLE_HOVER_EFFICIENCY,2.0);
    llSetVehicleFloatParam   (VEHICLE_HOVER_TIMESCALE,1.0);
    llSetVehicleFloatParam   (VEHICLE_BUOYANCY,1.0);
}

vehicleSail() {
    float    zRot=prevZRot;
    float    remainingSteerEffect=steerEffect;
//    llOwnerSay("steerEffect:"+(string)steerEffect+" counterSteer:"+(string)counterSteer);
    if((steerEffect>0.0 && counterSteer>0.0) || (steerEffect<0.0 && counterSteer<0.0)) counterSteer=0.0;
    remainingSteerEffect=remainingSteerEffect*(1.0 - llFabs(counterSteer));
//    llOwnerSay("remainingSteerEffect:"+(string)remainingSteerEffect);

    if(steeringDir==0) {
        if(steerCounter>3) steerCounter-=3;
        else if(steerCounter>0) steerCounter--;
        if(prevZRot!=0.0) {
//            if(currentX!=0.0 || currentY!=0.0) llSetVehicleVectorParam  (VEHICLE_LINEAR_FRICTION_TIMESCALE,<100.0,100.0,0.5>);
//            else llSetVehicleVectorParam  (VEHICLE_LINEAR_FRICTION_TIMESCALE,<100.0,0.5,0.5>);
            llSetVehicleVectorParam  (VEHICLE_LINEAR_FRICTION_TIMESCALE,<100.0,100.0,0.5>);
 //           llOwnerSay("steerEffect:"+(string)steerEffect);
            prevZRot=0.0;
        }
        llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION,<0,0,remainingSteerEffect>);
        counterSteer=counterSteer*0.8;    
    } else {
        float newZRot;
        float rotationSpeed=0.08+(waterSpeed*0.05);
        if(zRot<=0.0) zRot=rotationSpeed;
        zRot=zRot+((((MAXTURNSPEED+(1.25+rotationSpeed))/2.0)-zRot)*TURNINCREASE);
        newZRot=zRot;
        llSetVehicleVectorParam  (VEHICLE_LINEAR_FRICTION_TIMESCALE,<100.0,0.05,0.5>);
        if(steeringDir>0) {
            if(steerCounter>0) newZRot=newZRot + ((heelX/45.0) * TURN_HEEL);
            if(newZRot<0.4) newZRot=0.4;
            if(newZRot>3.0) newZRot=3.0;
            llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION,<0,0,newZRot+(steerEffect*2.0)>);
   //         llOwnerSay("newZRot:"+(string)newZRot+" steerEffect:"+(string)steerEffect);
            counterSteer=1.0;
        } else {
            if(steerCounter>0) newZRot=newZRot - ((heelX/45.0) * TURN_HEEL);
            if(newZRot<0.4) newZRot=0.4;
            if(newZRot>3.0) newZRot=3.0;
            llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION,<0,0,(-1.0*newZRot)+(steerEffect*2.0)>);
 //           llOwnerSay("newZRot:"+(string)newZRot+" steerEffect:"+(string)steerEffect);
            counterSteer= -1.0;
        }
        steerCounter++;
        prevZRot=zRot;
        if(hasCapsized<=0) heelX = heelX * 0.7;
    }
//llOwnerSay("speedX:"+(string)speedX+" speedY:"+(string)speedY);
    llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION,<speedX+currentX,speedY+currentY,0.0>);
    vehicleHeel();
    prevSteeringDir=steeringDir;
}

vehicleHeel() {
    float    extraHeight;
    float    newHeight;
    float   vehHeelX=(waveHeelX+heelX)*DEG_TO_RAD;
    float   vehHeelY=(waveHeelY+heelY)*DEG_TO_RAD;
    
    if(isPlaning==1) {
        vehHeelY-=(EXTRAHEELPLANING*DEG_TO_RAD);
    }
    if(llFabs(vehHeelX-prevXRot)>HEELTHRESHOLD || llFabs(vehHeelY-prevYRot)>HEELTHRESHOLD) {
        llSetVehicleRotationParam(VEHICLE_REFERENCE_FRAME,llEuler2Rot(<(vehHeelX * -1.0),(vehHeelY * -1.0),0.0>));
        prevXRot=vehHeelX;
        prevYRot=vehHeelY;
    }

    extraHeight=(llFabs(llSin(DEG_TO_RAD*vehHeelX))*EXTRAHEIGHT_HEELX) + (llFabs(llSin(DEG_TO_RAD*vehHeelY))*EXTRAHEIGHT_HEELY);
//llOwnerSay("extrasheight:"+(string)extraHeight);
    newHeight = seaLevel+FLOATLEVEL+extraHeight-0.15;
    if(llFabs(newHeight-curHeight)>LEVELTHRESHOLD) {
        llSetVehicleFloatParam (VEHICLE_HOVER_HEIGHT, newHeight);
        curHeight=newHeight;
    }
}

vehicleCapsize() {
    float    zRot=0.0;
    if(prevCapsized!=hasCapsized && hasCapsized==2) {
        heelY=80.0;
    } else if(prevCapsized!=hasCapsized && hasCapsized==1) {
        if(actualHeelX>0.0) heelX=80.0;
        else heelX=-80.0;
        actualHeelX=0.0;
    } else if(hasCapsized==2) {
//    llOwnerSay("heelY"+(string)heelY);
         llSetVehicleVectorParam  (VEHICLE_ANGULAR_FRICTION_TIMESCALE,<1000,1000,0.04>);
        if(heelX>=0 && heelX<80) heelX+=5;
        else if(heelX<0 && heelX>-80) heelX-=5;
        else {
            hasCapsized=1;
            llMessageLinked(LINK_SET,MSGTYPE_CAPSIZED,"1",NULL_KEY);
            llSetVehicleVectorParam  (VEHICLE_ANGULAR_FRICTION_TIMESCALE,<0.1,0.1,0.04>);
        }
        heelY=(80.0-llFabs(heelX))*1.8;
    } else if(hasCapsized==1) {
        heelY=0.0;
        if(heelX>70) heelX-= 7;
        else if(heelX<-70) heelX+=7;
        else if(heelX>5) heelX -= 2;
        else if(heelX < -5) heelX += 2;
        if(llFabs(heelX)<=5.0) {
            hasCapsized=0;
            llMessageLinked(LINK_SET,MSGTYPE_CAPSIZED,"0",NULL_KEY);
            playSound();
            mainSheetAngle=maxSheetAngle;
            jibSheetSetting=maxSheetAngle;
            gnkRaised=0;
            jibRaised=1;
        }
        zRot = relativeWindDir*DEG_TO_RAD*0.3;  // rotate towards wind
        //if(heelX<0.0) zRot=zRot*-1.0;
    } else {
        if(heelX>0) heelX+=10.0;
        else heelX-=10.0;
        if(llFabs(heelX)>=75.0) {
            llMessageLinked(LINK_SET,MSGTYPE_CAPSIZED,"1",NULL_KEY);
            playSound();
            hasCapsized=1;
        }
    }
    vehicleHeel();
    llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION,<currentX,currentY,0.0>);
    llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION,<0.0,0.0,zRot>);
}

getWWCvariables() {
    list    in = llCSV2List(llGetObjectDesc());
//        compass=llList2Integer(in,0);
    calcSpeedXandY();
    float boatSpeed=llList2Float(in,1)/10.0;
    boatSpeed = boatSpeed/speedMultiplier;
    waterSpeed=llList2Float(in,2)/(10.0*speedMultiplier);
    if(boatSpeed>0.0) waterSpeed=waterSpeed*(boatSpeedX/boatSpeed);
    relativeWindDir=llList2Integer(in,3);
    apparentWindDir=llList2Integer(in,5);
    if(relativeWindDir<50 && relativeWindDir>0) {
        relativeWindDir=(integer)(((float)relativeWindDir+(50.0*upwindStretchFactor))/(1.0+upwindStretchFactor));
        apparentWindDir=(integer)(((float)apparentWindDir+(50.0*upwindStretchFactor))/(1.0+upwindStretchFactor));
    }
    if(relativeWindDir>-50 && relativeWindDir<0) {
        relativeWindDir=(integer)(((float)relativeWindDir+(-50.0*upwindStretchFactor))/(1.0+upwindStretchFactor));
        apparentWindDir=(integer)(((float)apparentWindDir+(-50.0*upwindStretchFactor))/(1.0+upwindStretchFactor));
    }
    absRelWindDir=llAbs(relativeWindDir);
    apparentWindSpeed=llList2Float(in,4)/10.0;
    apparentWindSpeedX=llCos(DEG_TO_RAD*relativeWindDir)*apparentWindSpeedX;
    absApparentWindDir=llAbs(apparentWindDir);
    waveHeight=llList2Float(in,6)/10.0;
    if(sailingMode==VEHICLE_SAILING) {
        currentSpeed=llList2Float(in,7)/10.0;
        currentDir=llList2Integer(in,8);
    } else {
        currentSpeed=0.0;
        currentDir=0;
        currentX=0.0;
        currentY=0.0;
    }
    //llSetLinkPrimitiveParamsFast(rudderLinkNum,[PRIM_TEXT, "AWA:"+(string)apparentWindDir+"   windspd:"+(string)apparentWindSpeed, <1,0,0>, 1.0]);
}

setSailMode(integer newMode) {
    if(wwcRaceId<=0) {
        wwcSailMode=newMode;
        llMessageLinked(LINK_ROOT, MSGTYPE_WHISPER,(string)(3+wwcSailMode), ""); // Switched to sailmode
        if(wwcSailMode>=1) llMessageLinked(LINK_ROOT, MSGTYPE_SAY, "49", "");  // show little help info
        if(wwcSailMode>=2) llMessageLinked(LINK_ROOT, MSGTYPE_SAY, "50", "");  // show little help info
        if(wwcSailMode>=3) llMessageLinked(LINK_ROOT, MSGTYPE_SAY, "51", "");  // show little help info
        if(wwcSailMode>=2) llMessageLinked(LINK_ROOT, MSGTYPE_SAY, "53", "");  // show little help info
    }
}

playSound() {
    llStopSound();
    if(sailingMode==VEHICLE_SAILING && hasCapsized==0) {
        if(mainSheetSetting==0) llLoopSound("flapping",1.0);
        else if(isPlaning>0) llLoopSound("planing",1.0);
        else llLoopSound("sailing",0.4);
    }
}

float limit(float value, float min, float max) {
    if(value<min) return min;
    if(value>max) return max;
    return value;
}
integer intLimit(integer value, integer min, integer max) {
    if(value<min) return min;
    if(value>max) return max;
    return value;
}

integer lslAngle2RealAngle(integer lslAngle) {
    integer realAngle= (lslAngle-90)*-1;
    while(realAngle>=360) realAngle-=360;
    while(realAngle<0) realAngle+=360;
    return realAngle;
}
calcSpeedXandY() {
    vector currEuler=llRot2Euler(llGetRot());
    vector spdVec=llGetVel();
    rotation rot = llEuler2Rot(<0,0,(0-currEuler.z)>);
    vector  rotatedSpeed=spdVec * rot;
    boatSpeedX = rotatedSpeed.x;
    boatSpeedY = rotatedSpeed.y;
    compass=lslAngle2RealAngle((integer)(currEuler.z * RAD_TO_DEG));
    boatRotX=currEuler.x*RAD_TO_DEG;
//    llOwnerSay("velocity: "+(string)spdVec+" rotatedSpeed:"+(string)rotatedSpeed);
}

calcIdealSailSettings() {
    float angle1 = absApparentWindDir-15.0;
    float angle2 = absApparentWindDir/2.0;
    idealSheet = intLimit((integer)((angle1+angle2)/2.0), 15, maxSheetAngle);
//    idealSheet= intLimit((integer)(((angle1*180.0)+(angle2*absApparentWindDir))/(absApparentWindDir+180.0)), minSheetAngle, maxSheetAngle);
    idealSailWindAngle=limit((float)(absApparentWindDir-idealSheet),0,90);
    idealSailTrim = (integer)(3.0-((apparentWindSpeed/windSpeedSailOpen)*3.0));
//llOwnerSay("3.0-(("+(string)apparentWindSpeed+"/"+(string)windSpeedSailOpen+")*3.0)="+(string)idealSailTrim);
    idealSailTrim = intLimit(idealSailTrim + (integer)((absApparentWindDir-45.0)/20.0), 0, 3);
//    llOwnerSay((string)idealSailTrim + "+(integer)(("+(string)absApparentWindDir+"-35.0)/20.0)="+(string)idealSailTrim);
}

integer calcSheetSetting(integer angle, integer currentSetting) {
    float    increment = limit((float)idealSheet*0.2,4.0,10.0);
    float    calcSetting=(idealSheet-angle)/increment;
    return intLimit(llRound((((calcSetting+2.0)*3.0)+(float)currentSetting)/4.0), 0,4);    
}
integer sheetAngleForSetting(integer setting) {
    float    increment = limit((float)idealSheet*0.2,4.0,10.0);
    integer angle = idealSheet-(integer)((float)(intLimit(setting,0,4)-2)*increment);
//    integer    maxAngle = intLimit(maxSheetAngle,0,absApparentWindDir);
    return intLimit(angle, minSheetAngle, maxSheetAngle);
}


calcSailPower(integer sqm, integer sheetSetting, integer trim, integer isGnk) {
    float    forceX = 0;
    float    forceY = 0;
    float    sailWindAngle =0;
    float    airFlowAngle=0;
    float    airFlow=0;
    float    windPush=0;
    float    force;
    float    drag;
    integer sheetAngle=sheetAngleForSetting(sheetSetting);
    if(sheetAngle>apparentWindDir && apparentWindDir>0) sheetAngle=apparentWindDir;
    if(sheetAngle<apparentWindDir && apparentWindDir<0) sheetAngle=apparentWindDir;

    sailWindAngle = (float)(absApparentWindDir-sheetAngle);
    windPush = llFabs(llSin(DEG_TO_RAD*sailWindAngle))*apparentWindSpeed; // parachute effect
    
    airFlowAngle=limit(llFabs((sailWindAngle-idealSailWindAngle)*3.0),0,90); // if sheet == idealSheet ==> angle=0 ==> 1-sin()=1 (times 3.0 makes the total angle between 30 degrees too tight and 30 degrees too loose)
    airFlow = (1.0-llSin(DEG_TO_RAD*airFlowAngle))*llFabs(llCos(DEG_TO_RAD*idealSailWindAngle))*apparentWindSpeed; // wing effect
//float oldAirFlow=airFlow;
    if(absApparentWindDir<minUpwindAngle) airFlow=airFlow*0.85;
    integer startAngleEffect=(integer)((float)minUpwindAngle*1.3);
    if(absApparentWindDir<startAngleEffect) {
        airFlow=airFlow * (0.6+((absApparentWindDir / startAngleEffect)*0.4));
    }
//    llOwnerSay("absApparentWindDir:"+(string)absApparentWindDir+" airfolw:"+(string)oldAirFlow+" -> "+(string)airFlow);
    
    if(isGnk) {
        if(shouldRemoveJib && jibRaised) {
            gnkCollapseWindAngle+=5;
            gnkCollapseWindAngleTo-=5;
        }

        if(gnkCollapsed) {
            if((absApparentWindDir+llFrand(4.0)-2)>(gnkCollapseWindAngle+5) && (absApparentWindDir+llFrand(4.0)-2)<(gnkCollapseWindAngleTo-5)) gnkCollapsed=0;
        } else if(wwcSailMode>1) {
            if((absApparentWindDir+llFrand(4.0)-2)<gnkCollapseWindAngle || (absApparentWindDir+llFrand(4.0)-2)>gnkCollapseWindAngleTo || sailWindAngle<=0.0) {
                gnkCollapsed=1;
                llMessageLinked(LINK_ROOT, MSGTYPE_WHISPER+52, "", NULL_KEY); // XX controls the main trim
            }
        }
        if(gnkCollapsed) {
            force = (windPush*0.3) * (float)sqm;
        } else {
            force = ((windPush*0.5) + (airFlow*0.7)) * (float)sqm;
            if(jibRaised) force=force*0.8;
        }
        trim=idealSailTrim;
    } else {
        force = ((windPush*0.4) + airFlow) * (float)sqm;
    }

    // sail thickness = 10% for a very round sail (+1.0 is for roughness material)
    drag = airFlow * 0.1 * (float)sqm * windDragFactor * 0.4;
    if(gnkCollapsed>0 && isGnk>0) drag=drag*1.1;
        
    // convert both forces to X en Y
    forceX += llSin(DEG_TO_RAD*sheetAngle)*force;
    forceX -= llCos(DEG_TO_RAD*sheetAngle)*drag;
    forceX = forceX*windPower2Kg*0.1;
    forceX = forceX*(1.0-llFabs(llSin(DEG_TO_RAD*actualHeelX)));

    if(isGnk) {
        forceY += (0.4+(llCos(DEG_TO_RAD*sheetAngle)*0.6))*force*2.0;
        forceY += (0.1+(llSin(DEG_TO_RAD*sheetAngle)*0.9))*drag*2.0;
    } else {
        forceY += (0.3+(llCos(DEG_TO_RAD*sheetAngle)*0.7))*force;
        forceY += (0.1+(llSin(DEG_TO_RAD*sheetAngle)*0.9))*drag;
    }
    forceY = forceY*windPower2Kg*0.1;
//if(sqm==mainSailArea) llOwnerSay("sheetSetting:"+(string)sheetSetting+" forceY:"+(string)forceY);
    if(sheetSetting==3 && isGnk==0) forceY=forceY*1.5;
    if(sheetSetting==4 && isGnk==0) forceY=forceY*2.0;
//    if(sqm==mainSailArea) llOwnerSay("sheetSetting:"+(string)sheetSetting+"  new Y:"+(string)forceY);
    forceY = forceY * (1.0-(llFabs(llSin(DEG_TO_RAD*actualHeelX))*0.25));

    if(trim>idealSailTrim) {
        forceX -= (forceX * (float)(trim - idealSailTrim)*0.07);
        forceY += (forceY * (float)(trim - idealSailTrim)*0.4);
    } else if(trim<idealSailTrim) {
        forceX -= (forceX * (float)(idealSailTrim-trim)*0.3);
        forceY -= (forceY * (float)(idealSailTrim-trim)*0.3);
    }    
    sailForceX+=forceX;
    sailForceY+=forceY;
//if(sqm==mainSailArea) llOwnerSay("force:<"+(string)forceX+","+(string)forceY+"> sheetAngle:"+(string)sheetAngle+" absApparentWindDir:"+(string)absApparentWindDir+" apparentWindSpeed:"+(string)apparentWindSpeed+" idealSheet:"+(string)idealSheet+" trim:"+(string)mainTrim+(string)idealSailTrim);
}

calcSails() {
    integer calcSheetAngle=0;
    sailForceX=0;
    sailForceY=0;
    calcIdealSailSettings();
    integer prevSetting=mainSheetSetting;
    mainSheetSetting=calcSheetSetting(mainSheetAngle, mainSheetSetting);
    jibSheetSetting=calcSheetSetting(jibSheetAngle, jibSheetSetting);
    gennakerSheetSetting=calcSheetSetting(gnkSheetAngle, gennakerSheetSetting);
    if(wwcSailMode<=1) {
        if(absApparentWindDir>(gnkCollapseWindAngle+2) && absApparentWindDir<(gnkCollapseWindAngleTo-2)) gnkRaised=1;
        if(absApparentWindDir<(gnkCollapseWindAngle-2) || absApparentWindDir>(gnkCollapseWindAngleTo+2)) gnkRaised=0;
    }
    if(shouldRemoveJib && gnkRaised) jibRaised=0;
    else jibRaised=1;
    if(wwcSailMode<=0) { // in fun mode it goes automatic
        if(mainSheetSetting!=2) {
            mainSheetSetting=2;
            mainSheetAngle=sheetAngleForSetting(mainSheetSetting);
        }
        if(jibRaised>0 && jibSheetSetting!=2) {
            jibSheetSetting=2;
            jibSheetAngle=sheetAngleForSetting(jibSheetSetting);
        }
        if(gnkRaised>0 && gennakerSheetSetting!=2) {
            gennakerSheetSetting=2;
            gnkSheetAngle=sheetAngleForSetting(gennakerSheetSetting);
        }
    }
    if((mainSheetSetting==0 && prevSetting!=0) || (prevSetting==0 && mainSheetSetting!=0)) playSound();
    if(wwcSailMode<3) {
        mainTrim=idealSailTrim;
        jibTrim=idealSailTrim;
    }
    if(steerCounter>1) { // if you make a big course change we use ideal settings, to prevent speed loss
        calcSailPower(mainSailArea, 2, idealSailTrim, 0);
        if(gnkRaised==1) calcSailPower(gnkSailArea, 2, 0, 1);
        else if(jibRaised==1) calcSailPower(jibSailArea, 2, idealSailTrim, 0);
    } else {
        calcSailPower(mainSailArea, mainSheetSetting, mainTrim, 0);
        if(gnkRaised==1) calcSailPower(gnkSailArea, gennakerSheetSetting, 0, 1);
        else if(jibRaised==1) calcSailPower(jibSailArea, jibSheetSetting, jibTrim, 0);
    }
//    llOwnerSay("sailForceX:"+(string)sailForceX+", y:"+(string)sailForceY);
}

calcCrewPos() {
//    integer    calcHeelX=(integer)actualHeelX;
    integer    calcHeelX=(integer)heelX;
// zit aan bb: relWind:+ heel:+ poseCrew0:-
// zit aan sb: relWind:- heel:- poseCrew0:+
//llOwnerSay("crewCount:"+(string)crewCount+" relativeWindDir:"+(string)relativeWindDir+" calcHeelX:"+(string)calcHeelX+" crew0Pos:"+(string)crew0Pos);
    if(relativeWindDir>0 && crew0Pos>0) {
        crew0Pos=-1;
        extraHike=0;
        return;
    }
    if(relativeWindDir<0 && crew0Pos<0 && heelX<0) {
        crew0Pos=1;
        extraHike=0;
        return;
    }
//    llOwnerSay(" crew0Pos:"+(string)crew0Pos);
    if(calcHeelX<-15) {
        if((crew3Pos<=crew2Pos || crew2Pos==0) && crew3Pos!=0) {
            if(++crew3Pos==0) crew3Pos++; 
        } else if((crew3Pos>crew2Pos || crew3Pos==0) && (crew2Pos<=crew1Pos || crew1Pos==0) && crew2Pos!=0) {
            if(++crew2Pos==0) crew2Pos++; 
        } else if((crew2Pos>crew1Pos || crew2Pos==0) && crew1Pos<=crew0Pos && crew1Pos!=0) {
            if(++crew1Pos==0) crew1Pos++; 
        } else {
            if(++crew0Pos==0) crew0Pos++; 
        }
    }
    if(calcHeelX>15) {
        if((crew3Pos>=crew2Pos || crew2Pos==0) && crew3Pos!=0) {
            if(--crew3Pos==0) crew3Pos--; 
        } else if((crew3Pos<crew2Pos || crew3Pos==0) && (crew2Pos>=crew1Pos || crew1Pos==0) && crew2Pos!=0) {
            if(--crew2Pos==0) crew2Pos--; 
        } else if((crew2Pos<crew1Pos || crew2Pos==0) && crew1Pos>=crew0Pos && crew1Pos!=0) {
            if(--crew1Pos==0) crew1Pos--; 
        } else  {
            if(--crew0Pos==0) crew0Pos--; 
        }
    }
    if(crew3Pos>2) {
        crew3Pos=2;
        crew2Pos++;
    }
    if(crew2Pos>2) {
        crew2Pos=2;
        crew1Pos++;
    }
    if(crew1Pos>2) {
        crew1Pos=2;
        crew0Pos++;
    }
    if(crew0Pos>2) crew0Pos=2;
    if(crew3Pos<-2) {
        crew3Pos=-2;
        crew2Pos--;
    }
    if(crew2Pos<-2) {
        crew2Pos=-2;
        crew1Pos--;
    }
    if(crew1Pos<-2) {
        crew1Pos=-2;
        crew0Pos--;
    }
    if(crew0Pos<-2) crew0Pos=-2;
//    llOwnerSay(" crew0Pos:"+(string)crew0Pos);
}

calcWindDrag() {
    float crewFactor=0.7;
    windDrag = windDragEff * apparentWindSpeedX;
    if(crew0Pos!=0) crewFactor+=0.2;
    if(crew1Pos!=0) crewFactor+=0.15;
    if(crew2Pos!=0) crewFactor+=0.10;
    if(crew3Pos!=0) crewFactor+=0.05;
    windDrag = windDrag * crewFactor;
    // have to limit this to prevent big boats from getting too much wind drag because of 1 or 2 crewmembers
}

calcWaves() {
    float time;
    float freq;  // waves per second
    integer wavesPassed;
    float distance=llVecDist(globalPos, <wwcWaveOriginX,wwcWaveOriginY,0>);
    float waveHeel;
    float calcSpeed=waterSpeed;
    if(wwcWaveSpeed<=0.0) return;
    if(calcSpeed<1.0) calcSpeed=1.0;
    freq=wwcWaveLength/wwcWaveSpeed;
    time= globalTime-(distance/wwcWaveSpeed);  // time it took the waves to get here
    wavesPassed = (integer)(time/freq);  // can be negative
    waveCycle = (time-((float)wavesPassed*freq))/freq;
    if(waveCycle<0.0) waveCycle=waveCycle*-1.0;  // not sure if this is possible, better safe than sorry
    waveElevation = waveHeight*llSin(DEG_TO_RAD*(waveCycle*360.0));
    waveHeel = waveHeight*llCos(DEG_TO_RAD*(waveCycle*360.0))*waveHeelAt1MeterHeight;
    waveHeelX = waveHeel*llSin(DEG_TO_RAD*(float)absRelWindDir);
    if(absRelWindDir>100) waveHeelY = waveHeel*llCos(DEG_TO_RAD*(float)absRelWindDir)*0.5;
    else waveHeelY = waveHeel*llCos(DEG_TO_RAD*(float)absRelWindDir);
//llSay(0,"globalPos:"+(string)globalPos+" origin:"+(string)wwcWaveOriginX+", "+(string)wwcWaveOriginY+" globalTime:"+(string)globalTime+" freq:"+(string)freq);
    //if(waterSpeed>2.5) waveHeelY = waveHeelY * (2.5/waterSpeed);

    waveSpeedEffect = ((waveHeelY/90.0) * waveSpeedSensitivity  * 9.0);
    if(sailingMode==VEHICLE_SAILING) steerEffect = llFabs(waveHeel) * -0.032 * llSin(DEG_TO_RAD*(relativeWindDir*2.0)) * waveSteerSensitivity/(calcSpeed*calcSpeed);

    if(absRelWindDir>120) waveHeelY=waveHeelY*0.8;  // reduce the visual wave effect a little when going downwind
}

calcHeelY() {
    float balanceForce=0.0;
    float maxHullStab=(float)widthHull*(float)(mainSailArea+jibSailArea+gnkSailArea)*0.5;
    float newHeelY=0.0;
//    float windDirFactor = 1.0;
//    if(relativeWindDir<0) windDirFactor=-1.0;
//    if(gnkRaised>0) newHeelY=boatRotX*windDirFactor*0.12;
//    else newHeelY=boatRotX*windDirFactor*0.08;
    if(steeringDir!=0) {
        if(actualHeelXWhenSteering==0) actualHeelXWhenSteering=intLimit((integer)actualHeelX*steeringDir,-20,20);
        newHeelY-=(90.0/(float)mastHeight)*((float)actualHeelXWhenSteering/20.0);
    } else actualHeelXWhenSteering=0;
    heelY = ((heelY*(momentumHeelY-1.0)) + newHeelY) / momentumHeelY;
    if(absRelWindDir>60 && actualHeelXWhenSteering<0 && (steeringDir*relativeWindDir)<0) {
        newHeelY=heelY;
        if(waveCycle>0.1 && waveCycle<=0.5) newHeelY+=((waveHeelAt1MeterHeight*0.3*waveHeight) * ((float)actualHeelXWhenSteering/-20.0) * (apparentWindSpeed/9.0));
        if(newHeelY>(60.0/(float)mastHeight)) {
            hasCapsized=2;
            llMessageLinked(LINK_SET,MSGTYPE_CAPSIZED,"2",NULL_KEY);
            playSound();
        }
    }
}

calcHeelX() {
    if(weightCrewPerPerson!=0 || (ballast!=0 && ballastDepth!=0)) {
        float   forceY ;
        float   balanceForce=0;
        float   balanceDiff=0;
        float   hullStab=0;
        float   rigDestab=0;
        integer weightCrew=0;
        float   newHeelX=0.0;
        float calcMomentumHeel=momentumHeelX;
        forceY = sailForceY * ((float)mastHeight / 2.0);
        if(relativeWindDir<0) forceY=forceY*-1.0;

        weightCrew-=(integer)((float)weightCrewPerPerson * limit((float)crew0Pos,-2.5,2.5));
        weightCrew-=(weightCrewPerPerson * crew1Pos);
        weightCrew-=(weightCrewPerPerson * crew2Pos);
        weightCrew-=(weightCrewPerPerson * crew3Pos);
        balanceForce = llCos(DEG_TO_RAD*actualHeelX) * (float)weightCrew * 0.70;
        balanceForce = balanceForce/heelXsensitivityCrew;
//        llOwnerSay("cos("+(string)heelX+") * "+(string)weightCrew+" * 0.70 ="+(string)balanceForce+" (balanceForce) "+(string)crew0Pos+(string)crew1Pos+(string)crew2Pos+(string)crew3Pos);

        rigDestab = llCos(DEG_TO_RAD*(actualHeelX-90.0))*(float)weightRig*((float)mastHeight/2.0)*0.8;
        rigDestab=rigDestab*heelXsensitivityRig*0.6;
//        llOwnerSay("(cos("+(string)heelX+" - 90.0) * "+(string)weightRig+" * 0.85) = "+(string)rigDestab+" (rigDestab)");
//        llOwnerSay("("+(string)balanceForce+"-"+(string)rigDestab+") = "+(string)(balanceForce-rigDestab)+" forceY:"+(string)forceY);
        balanceForce = balanceForce-rigDestab;

        newHeelX = limit(((forceY-balanceForce)/(overallStability*40.0))*90.0,-90.0, 90.0);
       // newHeelX = (heelX + newHeelX) / 2.0;
        hullStab = llSin(DEG_TO_RAD*newHeelX)*(weightHull+(weightCrewPerPerson*crewCount)+ballast)*(widthHull/2.0)*0.4;
//        llOwnerSay("sin("+(string)newHeelX+") * ("+(string)weightHull+" + "+(string)weightCrew+" + "+(string)ballast+") * "+(string)widthHull+" * 0.5 * 0.5 = "+(string)hullStab+" (hullStab)");
        if(ballast>0) hullStab = hullStab+(llSin(DEG_TO_RAD*newHeelX)*ballastDepth*ballast*0.005);
        hullStab = hullStab/heelXsensitivityHull;
        balanceForce+=hullStab;

        if(llFabs(forceY)<llFabs(balanceForce) && llFabs(heelX)<20.0 && boatSpeedX>=0.5) balanceForce+=((forceY-balanceForce)*0.7);  // extra compensation for small negative heel when there is little pressure in the sail
        balanceForce+=((forceY-balanceForce)/4.0);  // extra compensation for lack of smooth hiking in/out

        newHeelX = ((forceY-balanceForce)/(overallStability*40.0))*90.0;
//        llOwnerSay("newHeelX:"+(string)newHeelX);
        float courseMultiplier = 1.0; // + (((limit((float)absRelWindDir,45.0,135.0)-45.0)/90.0)*0.15); // more heel when heading 90+ degrees to the wind
        newHeelX = newHeelX * courseMultiplier;
        newHeelX = limit(newHeelX,-90.0, 90.0);
        newHeelX= newHeelX*((llCos(DEG_TO_RAD*newHeelX)+heelPattern)/(heelPattern+1.0));  // more heel in the beginning, less in the end
        if(steeringDir>0) newHeelX+=45.0;
        else if(steeringDir<0) newHeelX-=45.0;
        newHeelX = limit(newHeelX,-90.0, 90.0);

        heelX = ((heelX*(calcMomentumHeel-1.0)) + newHeelX) / calcMomentumHeel;
        actualHeelX = ((actualHeelX*(momentumHeelX-1.0)) + heelX) / momentumHeelX;
        if(actualHeelX>15.0) steerEffect+= (weatherHelmSensitivity*0.008*(actualHeelX-15)*llCos(DEG_TO_RAD*(absRelWindDir/2.0)));
        else if(actualHeelX<-15.0) steerEffect+= (weatherHelmSensitivity*0.008*(actualHeelX+15)*llCos(DEG_TO_RAD*(absRelWindDir/2.0)));

        if(llFabs(actualHeelX+(waveHeelX*0.6))>44.2) willCapsize++;
        else willCapsize=0;
        if(willCapsize>4 && wwcSailMode>1) {
            llMessageLinked(LINK_SET,MSGTYPE_CAPSIZED,"2",NULL_KEY);
            playSound();
            hasCapsized=1;
        }
    }
}

calcDrag() {
    float    calcHeelX=llFabs(actualHeelX);
    dragX = (dragEfficX*1.5*waterSpeed);
    if(calcHeelX>8) dragX = dragX + (dragX * llFabs(llSin(DEG_TO_RAD*((calcHeelX-8.0)*2.0)))*extraDrag45*1.0);  // was 1.5
    if(heelY<80) dragX = dragX + (dragX * (heelY/10.0)*extraDrag45);
    if(isFoiling) {
        dragX=dragX*0.3;
    } else if(isPlaning) {
        dragX+=(0.05*dragX*dragX);
        dragX=dragX*0.8;
    } else {
        dragX+=(0.05*dragX*dragX);
    }
    dragX+=windDrag;
}

calcSpeed() {
    float weight = weightRig+weightHull;
    weight+=(weightCrewPerPerson * (crew0Pos/2.0));
    weight+=(weightCrewPerPerson * (crew1Pos/2.0));
    weight+=(weightCrewPerPerson * (crew2Pos/2.0));
    weight+=(weightCrewPerPerson * (crew3Pos/2.0));
    speedX = sailForceX-(dragX*0.4);
    speedX = speedX * 0.2;
    float momentum;
//llOwnerSay("speedX:"+(string)speedX);
//llOwnerSay("speedX:"+(string)speedX+" sailForceX:"+(string)sailForceX+" dragX:"+(string)dragX+" momentum:"+(string)momentum+" boatSpeedX:"+(string)boatSpeedX+" waveSpeedEffect:"+(string)waveSpeedEffect+" computedSpeed:"+(string)((speedX + (momentum*boatSpeedX))/(1.0+momentum)));

    float courseMultiplier1=1.0;
    if(absRelWindDir>16 && absRelWindDir<43) courseMultiplier1 -= llFabs((float)(absRelWindDir-30)/13.0)*0.4;
    if(absRelWindDir>43 && absRelWindDir<65) courseMultiplier1 += (0.2-(llFabs((float)(absRelWindDir-54)/11.0)*0.2));

    float courseMultiplier2 = 1.0 + ((1.0 - (limit((float)absRelWindDir,0.0,90.0)/90.0))*0.5); // 0-40% more speed when heading 0-90 degrees to the wind 
    if(gnkRaised>0) speedX = speedX * 1.2;  // 20% extra when gnk raised
    if(isPlaning) speedX= speedX*1.1;  // 10% more planing effect;
//    llOwnerSay("absRelWindDir:"+(string)absRelWindDir+" speedX:"+(string)speedX+" courseMultiplier1:"+(string)courseMultiplier1+" courseMultiplier2:"+(string)courseMultiplier2+" corrected:"+(string)(speedX * courseMultiplier1 * courseMultiplier2));
    speedX = speedX * speedMultiplier * courseMultiplier1 * courseMultiplier2;
    if(speedX>waterSpeed) momentum=weight/200.0;
    else momentum=weight/600.0;
    speedX = (speedX + (momentum*waterSpeed))/(1.0+momentum);
    speedX+=waveSpeedEffect;
    if(isPlaning) {
        if(speedX<hullSpeed) {
            isPlaning=0;
            playSound();
        }
    } else {
        float    preReducedSpeedX=speedX;
        if(waterSpeed>hullSpeed && hullSpeed>0.0) speedX=((speedX*1.5)+hullSpeed)/2.5;
        if(canPlane>0 && waterSpeed>(hullSpeed*1.15)) {
            isPlaning=1;
            speedX=preReducedSpeedX;
            playSound();
        }
    }
    if(isFoiling>0) {
        if(speedX<foilSpeed) isFoiling=0;
    } else if(foilSpeed>0 && speedX>foilSpeed) {
        isFoiling=1;
    }

    speedY = (sailForceY/(float)(mainSailArea+jibSailArea))* (hullSpeed*0.9) * llCos(DEG_TO_RAD*mainSheetAngle) * speedMultiplier;
    speedY = speedY/limit((apparentWindSpeed/10.0),0.8,3.0);  // more wind-> relatively less leewadrd drift
    speedY = speedY * (0.15 + llFabs(llSin(DEG_TO_RAD*actualHeelX)*0.85)) * 1.0;
    if(relativeWindDir>0) speedY=speedY*-1.0;
    if(absApparentWindDir<minUpwindAngle) speedY=speedY*1.5;
//    llOwnerSay("speedY:"+(string)speedX+" sailForceY:"+(string)sailForceY+" momentum:"+(string)momentum+" boatSpeedY:"+(string)boatSpeedY+" computedSpeed:"+(string)((speedY + (momentum*boatSpeedX))/(1.0+momentum))+" actualHeelX:"+(string)actualHeelX);
// llOwnerSay("speedYL:"+(string)speedY+" boatSpeedY:"+(string)boatSpeedY);
    speedY = (speedY + boatSpeedY)/2.0;
}

/*
readControl(list data) {
    jibSheetAngle=mainSheetAngle;
    gnkSheetAngle=mainSheetAngle;
    jibTrim=mainTrim;
}
*/

default
{
    state_entry()
    {
        init();
        llSetLinkPrimitiveParamsFast(rudderLinkNum,[PRIM_TEXT, "", <1,0,0>, 0.0]);
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        if(num == MSGTYPE_MODECHANGE) {      // read setting params passed by control unit
            integer    newMode=(integer)str;
            if(newMode!=sailingMode) {
                sailingMode=newMode;
                if(sailingMode!=VEHICLE_MOORED){
                    previousTime=0.0;
                    llSetTimerEvent(0);
                    llSetTimerEvent(TIMERINTERVAL);
                    boatSpeedX=0;
                    boatSpeedY=0;
                    waterSpeed=0;
                    heelX=0;
                    actualHeelX=0;
                    mainSheetAngle=45;
                    jibSheetAngle=45;
                    gnkSheetAngle=70;
                    prevcrew0Pos=99;
                    prevcrew1Pos=99;
                    prevcrew2Pos=99;
                    prevcrew3Pos=99;
                    gnkRaised=0;
                    isPlaning=0;
                    curHeight=9999.9;
                    getWWCvariables();
                    if(relativeWindDir>0) crew0Pos=-1;
                    else crew0Pos=1;
                    playSound();
                }else if(sailingMode==VEHICLE_MOORED){
                    playSound();
                    llSetTimerEvent(0);
                }
                setPhysicsOnOff();
            }
        } else if(num == MSGTYPE_TACKING) {
            if(llGetSubString(str,0,3)=="hike") {
                integer    crewId=(integer)llGetSubString(str,4,4);
                if(crewId==0) {  // helmsman
                    integer newValue=(integer)llGetSubString(str,5,-1);
//                    llOwnerSay("newValue:"+(string)newValue+" crew0Pos:"+(string)crew0Pos+" extraHikeCounter:"+(string)extraHikeCounter+" heel:"+(string)heel);
                    if(crew0Pos==newValue && extraHikeCounter<=100 && newValue==2) {
                        if(actualHeelX<0) { 
                            extraHike=5;
                            newValue=3;
                            extraHikeCounter+=50;
                        } else newValue=2;
                    } else if(crew0Pos==newValue && extraHikeCounter<=100 && newValue==-2) {
                        if(actualHeelX>0) { 
                            extraHike=5;
                            newValue=-3;
                            extraHikeCounter+=50;
                        } else newValue=-2;
                    }
                    prevcrew0Pos=99;
                    crew0Pos = newValue;
                } else if(crewId==1) {
                    prevcrew1Pos=99;
                    crew1Pos = (integer)llGetSubString(str,5,-1);
                } else if(crewId==2) {
                    prevcrew2Pos=99;
                    crew2Pos = (integer)llGetSubString(str,5,-1);
                } else if(crewId==3) {
                    prevcrew3Pos=99;
                    crew3Pos = (integer)llGetSubString(str,5,-1);
                }
            }
        } else if(num == MSGTYPE_SAILHANDLING) {
            if(wwcSailMode>0 && llGetSubString(str,0,4)=="sheet") {
                integer    crewId=(integer)llGetSubString(str,5,5);
                integer    increment=(integer)llGetSubString(str,7,-1)*-1;
                mainSheetAngle=sheetAngleForSetting(mainSheetSetting+increment);
                jibSheetAngle=sheetAngleForSetting(jibSheetSetting+increment);
                gnkSheetAngle=sheetAngleForSetting(gennakerSheetSetting+increment);
                //llOwnerSay((string)mainSheetSetting+"   "+(string)increment+"   "+(string)mainSheetAngle);   //lalia
            } else if(wwcSailMode>=3 && llGetSubString(str,0,3)=="sail") {
                integer    crewId=(integer)llGetSubString(str,4,4);
                integer    increment=(integer)llGetSubString(str,5,-1);
                jibTrim+=increment;
                if(jibTrim>3) jibTrim=3;
                if(jibTrim<0) jibTrim=0;
                llMessageLinked(LINK_ROOT, MSGTYPE_WHISPER+38+jibTrim, "", NULL_KEY);
                mainTrim+=increment;
                if(mainTrim>3) mainTrim=3;
                if(mainTrim<0) mainTrim=0;
                llMessageLinked(LINK_ROOT, MSGTYPE_WHISPER+34+mainTrim, "", NULL_KEY);
            } //else if(wwcRaceId<=0 && str=="control") toggleControl();
        } else if(num == MSGTYPE_MOTORING) {
            speedX=(float)str;
        } else if(num == MSGTYPE_SAILMODE) {
            setSailMode((integer)str);
        } else if(num == MSGTYPE_CREWSEATED) {  //lalia se sienta el helm
            if(id) {
                crew0Pos=1;
                crewCount=1;
            } else {
                crew0Pos=0;
                crewCount=0;
            }
        } else if(num >= MSGTYPE_CREWSEATED+1 && num <= MSGTYPE_CREWSEATED+3) {   //lalia se sienta un crew
            if(id) {
                if((num-MSGTYPE_CREWSEATED)==1)    crew1Pos=1;
                if((num-MSGTYPE_CREWSEATED)==2)    crew2Pos=1;
                if((num-MSGTYPE_CREWSEATED)==3)    crew3Pos=1;
            } else {
                if((num-MSGTYPE_CREWSEATED)==1)    crew1Pos=0;
                if((num-MSGTYPE_CREWSEATED)==2)    crew2Pos=0;
                if((num-MSGTYPE_CREWSEATED)==3)    crew3Pos=0;
            }
            crewCount=1;                    //lalia 1 solo helm
            if(crew1Pos!=0)crewCount++;     //lalia 2 helm + 1 crew
            if(crew2Pos!=0)crewCount++;     //lalia 3 helm + 2 crew
            if(crew3Pos!=0)crewCount++;     //lalia 4 helm + 3 crew
        } else if(num==MSGTYPE_STEERING) {
            steeringDir=(integer)str;    //-1, 0, 1
            if(hasCapsized==0 && sailingMode!=VEHICLE_MOORED) {
                llSetTimerEvent(0);
                //if(steeringDir==0) llSetTimerEvent(TIMERINTERVAL);
                //else llSetTimerEvent(0.4);
                llSetTimerEvent(TIMERINTERVAL);
                if(steerCounter>0) speedX = speedX * 0.9;
                vehicleSail();
            }
        } else if(num==MSGTYPE_WWCRACE) {
            list in = llCSV2List(str);
            wwcRaceId=llList2Integer(in,0);
            wwcRcName=llList2String(in,1);
            setSailMode((integer)llList2Integer(in,2));
            wwcCrewSize=llList2Integer(in,3);
            wwcRcVersion=llList2String(in,4);
            wwcRcExtra1=llList2String(in,5);
            wwcRcExtra2=llList2String(in,6);
            // if(wwcRaceId>0) setDefaultControl();
        } else if(num==MSGTYPE_WWCWAVES) {
            list in = llCSV2List(str);
            wwcWaveLength=llList2Float(in,1);
            wwcWaveSpeed=llList2Float(in,2);
            wwcWaveOriginX=llList2Float(in,5);
            wwcWaveOriginY=llList2Float(in,6);
        //} else if(num==MSGTYPE_SETTINGSCHANGE && llGetSubString(str,0,3)=="gen " && sailingMode==VEHICLE_SAILING && wwcSailMode>1) {
        } else if(num==MSGTYPE_SETTINGSCHANGE) {
            if(str=="gen" && sailingMode==VEHICLE_SAILING && wwcSailMode>=0) {  //prueba
                gennakerToRaise = (integer)((string)id);
                if(gnkRaised==0 && gennakerToRaise==0) gennakerToRaise=1;
                if(gnkRaised!=gennakerToRaise) {
                    if(gnkRaised>0 && dropGennakerCounter<=0) {
                        llMessageLinked(LINK_ROOT, MSGTYPE_WHISPER,"42", ""); // Dropping gennaker...
                        // dropGennakerCounter=10;
                        dropGennakerCounter=1;
                        llMessageLinked(LINK_THIS, MSGTYPE_SETTINGSCHANGE,"gendown","");
                    } else if(gennakerToRaise>0 && dropGennakerCounter<=0){
                        // raiseGennakerCounter=10;
                        raiseGennakerCounter=1;
                        llMessageLinked(LINK_ROOT, MSGTYPE_WHISPER,(string)(42+gennakerToRaise), ""); // Raising gennaker...
                        //llMessageLinked(LINK_THIS, MSGTYPE_SETTINGSCHANGE,"genup","");
                    }
                } 
            }else if(str=="global") windType=0;   //wwc
            else if(str=="mywind") windType=1;   //personal wind
        }
    }

    timer() {
        globalPos=llGetPos()+llGetRegionCorner();
        globalTime=(float)(llGetUnixTime()%-1000000);
        if(globalTime<=previousTime) globalTime+=TIMERINTERVAL; // unix time is in seconds and the timer can have smaller intervals
        if((integer)globalTime%5 ==0) playSound(); 
        previousTime=globalTime;
        extraHikeCounter--;
        if(--extraHike==0) {
            if(crew0Pos<-2) crew0Pos=-2;
            if(crew0Pos>2) crew0Pos=2;
        }
        if(--dropGennakerCounter==0) {
            gnkRaised=0;
            if(gennakerToRaise>0) {
                //raiseGennakerCounter=10;
                raiseGennakerCounter=1;
                llMessageLinked(LINK_ROOT, MSGTYPE_WHISPER,(string)(42+gennakerToRaise), ""); // Raising gennaker...
            }
        }
        if(--raiseGennakerCounter==0) {
            gnkRaised=gennakerToRaise;
            gennakerToRaise=0;
        }

        getWWCvariables();
        
        if(sailingMode==VEHICLE_SAILING) {
            calcSails();
            if(wwcSailMode<=1) calcCrewPos();
        } else {
            speedY=0.0;
            speedX=(speedX*0.8);
            if(llFabs(speedX)<0.05) speedX=0.0;
            heelX=0.0;
            actualHeelX=0.0;
            heelY=0.0;
            //actualHeelY=0.0;
        }
        
        steerEffect=0.0;
        if(!windType) calcWaves();

        if(sailingMode==VEHICLE_SAILING && hasCapsized<=0) {
            calcWindDrag();
            calcHeelY();
            calcHeelX();
            calcDrag();
            calcSpeed();
        }

        if(steeringDir!=0){ 
            if(steerCounter>30 || hasCapsized>0 || sailingMode==VEHICLE_MOORED) steeringDir=0;
        }
//      if(steeringDir==0) {
        if(currentSpeed!=0.0) {
            currentDir=(compass-currentDir);
            currentX= llCos(DEG_TO_RAD*currentDir)*currentSpeed;
            currentY= llSin(DEG_TO_RAD*currentDir)*currentSpeed;
        }

        if(hasCapsized<=0 && (sailingMode!=VEHICLE_MOORED)) vehicleSail();
        else if(hasCapsized>0 && (sailingMode!=VEHICLE_MOORED)) vehicleCapsize();
        //llOwnerSay((string)mainSheetAngle);  //lalia
        integer passMainSheet=mainSheetAngle;
        integer passJibSheet=jibSheetAngle;
        integer passGennakerSheet=gnkSheetAngle;
        if(relativeWindDir>0 && hasCapsized==0) {
            passMainSheet=passMainSheet*-1;
            passJibSheet=passJibSheet*-1;
            passGennakerSheet=passGennakerSheet*-1;
        }

        if(sailingMode==VEHICLE_SAILING) {
            integer newSailValues=mainSheetSetting+
                (jibSheetSetting*5)+
                (gnkCollapsed*25)+
                (mainTrim*125)+
                (jibTrim*500)+
                (passMainSheet*2000)+
                (passJibSheet*140000)+
                (passGennakerSheet*9800000);
            if(newSailValues!=prevSailValues || prevGennaker!=gnkRaised) {
                integer passMainSheet=mainSheetAngle;
                integer passJibSheet=jibSheetAngle;
                integer passGennakerSheet=gnkSheetAngle;
                integer passGennakerSheetSetting=2;
                if(relativeWindDir>0 && hasCapsized==0) {
                    passMainSheet=passMainSheet*-1;
                    passJibSheet=passJibSheet*-1;
                    passGennakerSheet=passGennakerSheet*-1;
                }
                llMessageLinked(LINK_ROOT, MSGTYPE_SAILINFO, 
                    (string)passMainSheet+"," +
                    (string)mainTrim+"," +
                    (string)mainSheetSetting+","+
                    (string)passJibSheet+","+
                    (string)jibTrim+","+
                    (string)jibSheetSetting+","+
                    "1,"+
                    (string)passGennakerSheet+","+
                    "0,"+
                    (string)gnkCollapsed+","+
                    (string)gnkRaised, 
                    NULL_KEY);                
                
                prevGennaker=gnkRaised;
                prevSailValues=newSailValues;
            }
        }
//        }
        // helmsman
        if(crew0Pos!=prevcrew0Pos || hasCapsized>0 || hasCapsized!=prevCapsized) {
            prevcrew0Pos=crew0Pos;
            llMessageLinked(LINK_SET, MSGTYPE_CREWINFO, (string)crew0Pos+","+(string)hasCapsized+","+(string)((integer)heelX), NULL_KEY);
        }

        // crew
        if(crew1Pos!=prevcrew1Pos || hasCapsized>0 || hasCapsized!=prevCapsized) {
            prevcrew1Pos=crew1Pos;
            llMessageLinked(LINK_SET, MSGTYPE_CREWINFO+1, (string)crew1Pos+","+(string)hasCapsized+","+(string)((integer)heelX), NULL_KEY);

        }
        prevCapsized=hasCapsized;
//llOwnerSay("sailing control free memory:"+(string)llGetFreeMemory());
//llSetText("spd:"+(string)boatSpeed,<1,1,1>,1.0);
    }
}

// sheet handling testen
// zeil textures incl. de telltales maken (5 textures, ook voor flapping, met een beetje vervorming en schaduwplooien (grid gebruiken))
// trimlijnen maken
// dubbele particle boxes
// alle textures en sculpts op ongebruikte vlakken zetten met een script, dat eenmalig draait
// opschonen:
// gennaker sheet altijd gelijk aan jibsheet maken
// commentaar eruit

