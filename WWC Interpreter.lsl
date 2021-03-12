integer MSGTYPE_GETNEWWWC=70001;
integer MSGTYPE_WWCRACE=70500;
integer MSGTYPE_WWCWIND=70501;
integer MSGTYPE_WWCWAVES=70502;
integer MSGTYPE_WWCCURRENT=70503;
integer MSGTYPE_WWCLOCALSCLEAR=70600;
integer MSGTYPE_WWCLOCALS=70601;
integer MSGTYPE_MOVEPRIM=756;
integer MSGTYPE_SETTINGS=1000;
integer MSGTYPE_SETTINGSCHANGE=50003;


integer    moverIndex=0;
integer    moverScripts=5;

integer HudChannel;
integer windType;   //0 global wwc   1 mywind
integer mywindDir=0;
float mywindSpd=8.5;   //m/s
  
float timerInterval=1.0;
float reduceRate=0.2;
integer  sailArea=25;  /// may not be zero;
string boatLength2Bow="1.5";
string boatLength2Stern="2.1";
float  maxWindShadow=0.6;
float  maxWindBend=15;  // in degrees

integer msgTypePassInfo=71958;
integer msgTypeModeChange=50001;
integer vehicleMoored=0;
integer vehicleSailing=1;

integer  calcLocalsInterval=3;
integer  calcCurrentInterval=3;
integer  updateHudInterval=2;
integer  counter=0;
integer  sendBtPosInterval=3;
integer     sendBtPosCounter=0;

integer  wwcRaceId=0;
float    wwcWndDir=0;
float    wwcWndSpeed=8.5;
float    wwcWndGusts=0;
float    wwcWndShifts=0;
float    wwcWndChangeRate=1.0;
string   wwcWndSystem="";
float    wwcWaveHeight=0.5;
float    wwcWaveLength=50;
float    wwcWaveSpeed=3;
float    wwcWaveHeightVariance=0.5;
float    wwcWaveLengthVariance=0.2;
float    wwcWaveOriginX=0;
float    wwcWaveOriginY=0;
string   wwcWaveSystem="";
float    wwcCrntDir=0;
float    wwcCrntSpeed=0;
string   wwcCrntSystem="";
integer  wwcSailMode=0;
integer  wwcCrewSize=0;
string   wwcRcName="";
string   wwcRcClass="";
string   wwcRcVersion="";
string   wwcRcExtra1="";
string   wwcRcExtra2="";
float    wwcWaterDepth=10.0;
list     wwcLocalFluctuations=[];

// boat variables
integer  compass=0;
float    boatSpeed=0.0;
float    waterSpeed=0.0;
float    depth=10.0;
vector   globalPos;
float    globalTime;
float    previousTime=0.0;

// wind variables
integer  trueWindDir=0;
float     trueWindSpeed=0.0;
integer     relativeWindDir=0;
integer  apparentWindDir=0;
float    apparentWindSpeed=0.0;
list     shadowingBoats=[];
float     localWindSpeed=1.0;
integer     localWindDir=0;

// waves variables
float    waveSpeed=0.0;
integer  waveDir=0;
float waveHeight=0.0;
float localWaveHeight=1.0;

// current variables
float    currentSpeed=0.0;
integer  currentDir=0;
float localCurrentDir=0.0;
float localCurrentSpeed=1.0;

// other variables
integer btPosListenHandler=0;
integer sailingMode=0;
integer notecardLine=0;
key settingsQueryID;

// hud variables
integer    fixedPartVisible=0;
float    oldRotCompass=90.0;
float    oldRotWind=0.0;

init() {
    localWindSpeed=1;
    localWindDir=0;
    localWaveHeight=1.0;
    localCurrentDir=0.0;
    localCurrentSpeed=1.0;
    shadowingBoats=[];
    if(btPosListenHandler) llListenRemove(btPosListenHandler);
    btPosListenHandler=0;
    llSetObjectDesc("");
    timerInterval=1.0;
    reduceRate=0.2;
    sailArea=25;
    boatLength2Bow="1.5";
    boatLength2Stern="2.1";
    maxWindShadow=0.6;
    maxWindBend=15;
    msgTypeModeChange=50001;
    vehicleMoored=0;
    vehicleSailing=1;
    calcLocalsInterval=2;
    calcCurrentInterval=3;
    sendBtPosInterval=3;
    msgTypePassInfo=0;
    resetHud();
    //llOwnerSay("wind always North, 8 m/s");
    llOwnerSay(llGetScriptName()+" ready ("+(string)llGetFreeMemory()+" free)");
}

integer lslAngle2RealAngle(integer lslAngle) {
    integer realAngle= (lslAngle-90)*-1;
    while(realAngle>=360) realAngle-=360;
    while(realAngle<0) realAngle+=360;
    return realAngle;
}

calcSpeedAndHeading() {
    vector currEuler=llRot2Euler(llGetRot());
    vector spdVec=llGetVel();
    compass=lslAngle2RealAngle((integer)(currEuler.z * RAD_TO_DEG)); // boat heading
    boatSpeed = llVecMag(spdVec);
    waterSpeed = boatSpeed;
    if(wwcCrntSpeed!=0.0 && !windType) {
        vector  crnVec;
        float multiplier=1.0;
        float lslCrnDir=lslAngle2RealAngle(currentDir)*DEG_TO_RAD;
        if(wwcWaterDepth>0.0) {
            vector crnVec;
            currentDir = (integer)(wwcCrntDir+localCurrentDir);
            while(currentDir>=360) currentDir-=360;
            while(currentDir<0) currentDir+=360;
            currentSpeed = wwcCrntSpeed*localCurrentSpeed;
            multiplier = (((float)depth/10.0)/wwcWaterDepth);
            if(multiplier>2.5) multiplier=2.5;
            if(multiplier<0.0) multiplier=0.0;
        }
        currentSpeed=wwcCrntSpeed*((multiplier+0.5)/1.5); // varies between 0.15 and 2.0 times the default current speed

        crnVec=<llCos(lslCrnDir),llSin(lslCrnDir),0> * currentSpeed;
        spdVec-=crnVec;
        waterSpeed = llVecMag(spdVec);
    } else currentSpeed=0.0;

    globalPos=llGetPos()+llGetRegionCorner();
    globalTime=(float)(llGetUnixTime()%1000000);
    if(globalTime<=previousTime) globalTime+=timerInterval; // unix time is in seconds and the timer can have smaller intervals
    previousTime=globalTime;
}


getLocalFluctuation(float posX, float posY) {
    integer    i=0;
    integer imax=llGetListLength(wwcLocalFluctuations);
    if(imax>0) {
        float localsFound=0.0;
        float locWindSpeed=0.0;
        float locWindDir=0.0;
        float locWaveHeight=0.0;
        float locCurrentSpeed=0.0;
        float locCurrentDir=0.0;
//        if(index==0) llOwnerSay("1:"+llList2CSV(wwcLocalFluctuations));
        for(i=0;i<imax;i+=9) {
            float x=llFabs(posX-llList2Float(wwcLocalFluctuations,i));
//        llOwnerSay("index:"+(string)index+" ("+(string)posX+","+(string)posY+") distanceX:"+(string)x+"locals:"+llList2CSV(llList2List(wwcLocalFluctuations,i,i+8)));
            if(x<256) {
                float radius0 = llList2Float(wwcLocalFluctuations,i+3);
                float y=llFabs(posY-llList2Float(wwcLocalFluctuations,i+1));
                if(y<radius0 && y<radius0) {
                    float distance = llSqrt((x*x)+(y*y));
                    float radius100 = llList2Float(wwcLocalFluctuations,i+2);
                    if(distance<=radius100) {
                        locWindSpeed+=llList2Float(wwcLocalFluctuations,i+4);
                        locWindDir+=llList2Float(wwcLocalFluctuations,i+5);
                        locWaveHeight+=llList2Float(wwcLocalFluctuations,i+6);
                        locCurrentSpeed+=llList2Float(wwcLocalFluctuations,i+7);
                        locCurrentDir+=llList2Float(wwcLocalFluctuations,i+8);
                        localsFound+=1.0;
                    } else if(distance<radius0 && radius0>radius100) {
                        float distanceMultiplier1 = ((distance-radius100)/(radius0-radius100));
                        float distanceMultiplier2 = ((radius0-distance)/(radius0-radius100));
                        float effectValue=llList2Float(wwcLocalFluctuations,i+4);
                        locWindSpeed+=((effectValue+((1.0-effectValue)*distanceMultiplier1))*distanceMultiplier2);
                        effectValue=llList2Float(wwcLocalFluctuations,i+6);
                        locWaveHeight+=((effectValue+((1.0-effectValue)*distanceMultiplier1))*distanceMultiplier2);
                        effectValue=llList2Float(wwcLocalFluctuations,i+7);
                        locCurrentSpeed+=((effectValue+((1.0-effectValue)*distanceMultiplier1))*distanceMultiplier2);
                        locWindDir+=(llList2Float(wwcLocalFluctuations,i+5)*distanceMultiplier2*distanceMultiplier2);
                        locCurrentDir+=(llList2Float(wwcLocalFluctuations,i+8)*distanceMultiplier2*distanceMultiplier2);
                        localsFound+=distanceMultiplier2;
                    }
                }
            }
        }
        if(localsFound>0.0) {
            localWindSpeed=(locWindSpeed/localsFound);
            localWindDir=(integer)(locWindDir/localsFound);
            localWaveHeight=(locWaveHeight/localsFound);
            localCurrentSpeed=(locCurrentSpeed/localsFound);
            localCurrentDir=(locCurrentDir/localsFound);
//        llOwnerSay("index:"+(string)index+" localWindSpeed:"+(string)localWindSpeed+" localWindDir:"+(string)localWindDir);
        } else {
            localWindSpeed=1;
            localWindDir=0;
            localWaveHeight=1;
            localCurrentSpeed=1;
            localCurrentDir=0;
        }
    }
}

calcWind(float posX, float posY) {
    if (windType) {
        trueWindDir=mywindDir;
        relativeWindDir=compass-trueWindDir;
        while(relativeWindDir>180) relativeWindDir-=360;
        while(relativeWindDir<-180) relativeWindDir+=360;
        trueWindSpeed=mywindSpd;
    } else {
        float thetaTime;
        float patternX;
        float patternY;
        float windMultiplier;
        integer patternDirection = ((integer)wwcWndDir*-1)-90;  // convert wind compass angle to pattern direction in SL coordinate system
        thetaTime=globalTime/1903*TWO_PI*wwcWndChangeRate;  // 31.67 minute cycle if wwcWndChangeRate=1.0
    
        patternX=(float)((integer)(posX+(llCos(patternDirection*DEG_TO_RAD)*globalTime*wwcWndChangeRate))%600)/600.0;
        patternX = patternX * (0.4 + (llSin(thetaTime)*0.8) + (llSin(thetaTime*1.5)*0.8)) * TWO_PI;
        patternY=(float)((integer)(posY+(llSin(patternDirection*DEG_TO_RAD)*globalTime*wwcWndChangeRate))%600)/600.0;
        patternY = patternY * (0.4 + (llSin(thetaTime)*0.8) + (llSin(thetaTime*1.9)*0.8)) * TWO_PI;
        windMultiplier=(llSin(thetaTime)*llSin(thetaTime*2)*llSin(thetaTime*9)*0.3)+((llSin(patternX)+llSin(patternY))*0.5);
        trueWindDir=(integer)(wwcWndDir+localWindDir);
        trueWindDir=(integer)(trueWindDir+(wwcWndShifts * windMultiplier));
        if(trueWindDir>=360) trueWindDir-=360;
        if(trueWindDir<0) trueWindDir+=360;
    
        // relative wind dir
        relativeWindDir=compass-trueWindDir;
        while(relativeWindDir>180) relativeWindDir-=360;
        while(relativeWindDir<-180) relativeWindDir+=360;
    
        // windspeed
        patternX=(float)((integer)(posX+(llCos(patternDirection*DEG_TO_RAD)*globalTime*wwcWndChangeRate))%700)/700.0;
        patternX = patternX * (0.4 + (llSin(thetaTime)*0.8) + (llSin(thetaTime*2.5)*0.8)) * TWO_PI;
        patternY=(float)((integer)(posY+(llSin(patternDirection*DEG_TO_RAD)*globalTime*wwcWndChangeRate))%700)/700.0;
        patternY = patternY * (0.4 + (llSin(thetaTime)*0.8) + (llSin(thetaTime*2.9)*0.8)) * TWO_PI;
        windMultiplier=(llSin(thetaTime)*llSin(thetaTime*4)*llSin(thetaTime*10)*0.3)+((llSin(patternX)+llSin(patternY))*0.5);
        trueWindSpeed=wwcWndSpeed*localWindSpeed;
        trueWindSpeed=trueWindSpeed+(trueWindSpeed*wwcWndGusts*windMultiplier);
        if (trueWindSpeed<0) trueWindSpeed=0;
        if (trueWindSpeed>20.0) trueWindSpeed=20.0;
        //trueWindSpeed=8.0;
    }

    {
        integer i;
        float windShadow=0.0;
        float windBend=0.0;
        for(i=0;i<llGetListLength(shadowingBoats);i+=3) {
            float shadow=llList2Float(shadowingBoats,i+1);
            float bend=llList2Float(shadowingBoats,i+2);
            windShadow+=shadow;
            windBend+=bend;
            shadow=shadow*(1.0-reduceRate);
            bend=bend*(1.0-reduceRate);
            if(shadow<0.1 && bend<1.0) {
                shadowingBoats=llDeleteSubList(shadowingBoats,i,i+2);
            } else {
                shadowingBoats=llListReplaceList(shadowingBoats, [shadow, bend], i+1, i+2);
            }
        }
        if(windShadow>maxWindShadow) windShadow=maxWindShadow;
        if(windBend>maxWindBend) windBend=maxWindBend;
        if(windShadow>0.0) trueWindSpeed=trueWindSpeed*(1.0-windShadow);

        if(windBend>0.0) {
            if(relativeWindDir>0) relativeWindDir=relativeWindDir-(integer)windBend;
            else relativeWindDir=relativeWindDir+(integer)windBend;
        }

        // apparent wind
        float    x = (llCos((float)relativeWindDir * DEG_TO_RAD)*trueWindSpeed)+boatSpeed;
        float    y = llSin((float)relativeWindDir * DEG_TO_RAD)*trueWindSpeed;
        apparentWindSpeed=llSqrt((x*x) + (y*y));
        if(x!=0.0) apparentWindDir = (integer)(llAcos(x/apparentWindSpeed) * RAD_TO_DEG);
        else apparentWindDir=relativeWindDir;
        if (relativeWindDir<0) apparentWindDir*=-1;

 //       if(windShadow>0.0 || windBend>0.0) llOwnerSay("windshadow: "+(string)((integer)(windShadow*100))+"%, bend: "+(string)((integer)windBend)+"deg.");
    }
}


calcWaveHeight() {
    float time;
    float theta;
    float offset;
    float multiplier=1.0;
    float freq=0.1;  // waves per second
    integer wavesPassed;
    float distance=llVecDist(globalPos, <wwcWaveOriginX,wwcWaveOriginY,0>);
    if(wwcWaveSpeed<=0.0) return;
    freq=wwcWaveLength/wwcWaveSpeed;
    waveDir = (integer)wwcWndDir;
    waveSpeed = wwcWaveSpeed;
    time= globalTime-(distance/wwcWaveSpeed);  // time it took the waves to get here
    wavesPassed = (integer)(time/freq);  // can be negative
    if(depth>0.0) {
        multiplier = (wwcWaterDepth/depth);
        if(multiplier>2.5) multiplier=2.5;
        if(multiplier<0.0) multiplier=0.0;
    }
    waveHeight=wwcWaveHeight*localWaveHeight;
    waveHeight=wwcWaveHeight*((multiplier+0.5)/1.5); // varies between 0.3 and 2.0 times the default wave height
    theta=time/120*TWO_PI*100.0; // 2 minute cycle
    offset=llSin(theta)*llSin(theta*2)*llSin(theta*5);
    if(wavesPassed%7 == 0) offset=offset+0.5; // make every 7th wave higher
    if(wavesPassed%5 == 0) offset=offset-0.2; // make every 5th wave lower
    if(wavesPassed%3 == 0) offset=offset+0.2; // make every 3th wave higher
    waveHeight = waveHeight+(waveHeight*wwcWaveHeightVariance*offset);
    wavesPassed++;
}

calcCurrent() {
    float multiplier=1.0;
    currentDir = (integer)(wwcCrntDir+localCurrentDir);
    while(currentDir>=360) currentDir-=360;
    while(currentDir<0) currentDir+=360;
    currentSpeed = wwcCrntSpeed*localCurrentSpeed;
    if(wwcWaterDepth>0.0) {
        multiplier = (depth/wwcWaterDepth);
        if(multiplier>2.5) multiplier=2.5;
        if(multiplier<0.0) multiplier=0.0;
    }
    currentSpeed=currentSpeed*((multiplier+0.5)/1.5); // varies between 0.15 and 2.0 times the default current speed
}

sendBtPosMessage() {
    vector pos = llGetPos()+llGetRegionCorner();
    vector velocity=llGetVel();
    string tack = "S";
    integer    channel=-7001;
    if(wwcRaceId>0) channel=-8001;
    if(relativeWindDir<0) tack = "P";
    llSay(channel,"BtPos,"+(string)((integer)globalPos.x)+","+
      (string)((integer)globalPos.y)+","+
      (string)sailArea+","+
      tack+","+
      boatLength2Bow+","+
      boatLength2Stern+","+
      llGetSubString((string)velocity.x,0,3)+","+
      llGetSubString((string)velocity.y,0,3));
}

calcWindShadow(list btPosData, key otherBoat) {
    if(llGetListLength(btPosData)>=9) {
        vector pos = <llList2Float(btPosData,1), llList2Float(btPosData,2), globalPos.z>;
        float distance = llVecDist(pos,globalPos);
        vector bearingVec = llVecNorm(pos-globalPos);
        float otherBoatSize=llList2Float(btPosData,5) + llList2Float(btPosData,6);
        float otherBoatSailArea=llList2Float(btPosData,3);
        vector otherBoatVelocity=<llList2Float(btPosData,7), llList2Float(btPosData,8),0>;
        float effect=0.0;
        float shadow=0.0;
        float bend=0.0;
        float bearingToWind=0.0;
        float bearing = llAcos(bearingVec.x)*RAD_TO_DEG;
        if(llAsin(bearingVec.y)<0.0) bearing=(360.0-bearing);
        bearing=(bearing*-1.0)+90; // convert to compass angle
//        llOwnerSay("distance:"+(string)distance+" compass bearing:"+(string)bearing);
        bearingToWind=bearing-trueWindDir;
        while(bearingToWind>180) bearingToWind-=360;
        while(bearingToWind<-180) bearingToWind+=360;
//        llOwnerSay("distance:"+(string)distance+" bearing to wind:"+(string)bearingToWind);
        if(llFabs(bearingToWind)<90.0) {
            float otherBoatCourse;
            float otherBoatCourseToWind;
            float ourBearingFromOtherBoat;
            float boomAngleOtherBoat;
//        llOwnerSay((string)otherBoatVelocity);
            if (otherBoatVelocity==<0,0,0>) return;  // no use computing anything, since the speed is never exactly zero
            otherBoatVelocity=llVecNorm(otherBoatVelocity);
            otherBoatCourse=llAcos(otherBoatVelocity.x)*RAD_TO_DEG;
            if(llAsin(otherBoatVelocity.y)<0.0) otherBoatCourse=(360.0-otherBoatCourse);
//       llOwnerSay("otherBoatCourse:"+(string)otherBoatCourse);
            otherBoatCourse=(otherBoatCourse*-1.0)+90; // convert to compass angle
//           llOwnerSay("otherBoatCourse:"+(string)otherBoatCourse);

            if(otherBoatSize<=1.0) otherBoatSize=1.0;
            if(distance<otherBoatSize) distance=otherBoatSize;
            //llOwnerSay("(1.0-"+(string)llFabs(llSin(bearing*DEG_TO_RAD))+")*("+(string)otherBoatSize+"/"+(string)distance+")*"+(string)otherBoatSailArea+"/"+(string)sailArea);
            effect=(otherBoatSize/distance)* // bigger distance->less effect
                (otherBoatSize/((float)boatLength2Bow+(float)boatLength2Stern))* // bigger boat->more effect
                otherBoatSailArea/sailArea;  // other sail bigger->more effect, our sail bigger->less effect
            shadow=(llCos(bearingToWind*2.5*DEG_TO_RAD))*  // relative bearing of 0 degrees->max shadow
                effect*
                maxWindShadow; // because a windshadow can never be 100%
//            llOwnerSay("nw shadow:"+(string)shadow+" effect:"+effect);

            otherBoatCourseToWind=otherBoatCourse-trueWindDir;
            while(otherBoatCourseToWind>180) otherBoatCourseToWind-=360;
            while(otherBoatCourseToWind<-180) otherBoatCourseToWind+=360;
            ourBearingFromOtherBoat = (bearing+180)-otherBoatCourse;
            while(ourBearingFromOtherBoat>180) ourBearingFromOtherBoat-=360;
            while(ourBearingFromOtherBoat<-180) ourBearingFromOtherBoat+=360;
//            llOwnerSay("ourBearingFromOtherBoat: ("+(string)bearing+"+180)-"+(string)otherBoatCourse+"="+(string)ourBearingFromOtherBoat+" otherBoatCourse:"+(string)otherBoatCourse+" otherBoatCourseToWind:"+(string)otherBoatCourseToWind);
            if(otherBoatCourseToWind<80 && otherBoatCourseToWind>30) {
//                llOwnerSay("ourBearingFromOtherBoat: ("+(string)bearing+"+180)-"+(string)otherBoatCourse+"="+(string)ourBearingFromOtherBoat);
    // between 90 and 180, 150 is optimum
                if(ourBearingFromOtherBoat>120 && ourBearingFromOtherBoat<180)
                     bend=(1.0-llSin(llFabs((ourBearingFromOtherBoat-150.0)*3.0*DEG_TO_RAD)))*1.25;
            } else if(otherBoatCourseToWind>-80 && otherBoatCourseToWind<-30) {
            //                llOwnerSay("ourBearingFromOtherBoat: ("+(string)bearing+"+180)-"+(string)otherBoatCourse+"="+(string)ourBearingFromOtherBoat);
                // between 90 and 180, 150 is optimum
                if(ourBearingFromOtherBoat<-120 && ourBearingFromOtherBoat>-180)
                     bend=(1.0-llSin(llFabs((ourBearingFromOtherBoat+150.0)*3.0*DEG_TO_RAD)))*1.25;
            }
 //               llOwnerSay("effect:"+(string)effect);
            bend = bend * bend * effect * maxWindBend;
            shadow-=(bend*0.03);  // as the bend gets bigger the shadow is smaller
//            llOwnerSay("nw bend:"+(string)bend+" sin("+(string)((llFabs(ourBearingFromOtherBoat)-90.0)*2.0));
            if(shadow<0.0) shadow=0.0;

            addWindShadowToList(shadow, bend, otherBoat);
        }
    }
}

addWindShadowToList(float shadow, float bend, key otherBoat) {
    integer i;
    for(i=0;i<llGetListLength(shadowingBoats);i+=3) {
        if(llList2String(shadowingBoats,i)==(string)otherBoat) {
            shadowingBoats=llListReplaceList(shadowingBoats, [otherBoat, shadow, bend], i, i+2);
//    llOwnerSay("wind shadowlist:"+llList2CSV(shadowingBoats));
            return;
        }
    }
    shadowingBoats+=[otherBoat, shadow, bend];
//    llOwnerSay("wind shadowlist:"+llList2CSV(shadowingBoats));
}

resetHud() {
    oldRotCompass=999;
    oldRotWind=999;
    fixedPartVisible=0;
}

updateHud() {
    float    rotCompass=90.0;
    float    rotWind=0.0;
    rotCompass+=compass;
    if(llFabs(rotCompass-oldRotCompass)>2.0) {
        oldRotCompass=rotCompass;
    }
    
    rotWind=apparentWindDir;
    if(llFabs(rotWind-oldRotWind)>2.0) {
        oldRotWind=rotWind;
    }

    if(fixedPartVisible<=0) {
        fixedPartVisible=1;
    }
}

default
{
    state_entry()
    {
        notecardLine=0;
        init();
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        //llOwnerSay("link message: num:"+(string)num+"   str:"+str+"   id:"+(string)id);
        if(num == msgTypeModeChange) {      // read setting params passed by control unit
            //llOwnerSay("wwwc interpreter msgtype change "+str);
            sailingMode=(integer)str;
            if(btPosListenHandler) llListenRemove(btPosListenHandler);
            if(sailingMode!=vehicleMoored) {
                if(wwcRaceId>0) btPosListenHandler = llListen(-8001,"","","");
                else btPosListenHandler = llListen(-7001,"","","");
                llSetTimerEvent(timerInterval);
            } else {
                llSetTimerEvent(0);
                btPosListenHandler=0;
                resetHud();
            }
        } else if(num==MSGTYPE_WWCRACE) {
            list in = llCSV2List(str);
            wwcRaceId=llList2Integer(in,0);
            wwcRcName=llList2String(in,1);
            wwcSailMode=llList2Integer(in,2);
            wwcCrewSize=llList2Integer(in,3);
            wwcRcVersion=llList2String(in,4);
            wwcRcExtra1=llList2String(in,5);
            wwcRcExtra2=llList2String(in,6);
            if(wwcRaceId>0 && sailingMode!=vehicleMoored) {
                if(btPosListenHandler) llListenRemove(btPosListenHandler);
                btPosListenHandler = llListen(-8001,"","","");
            }
        } else if(num==MSGTYPE_WWCWIND) {
//        llOwnerSay("link message:"+str);
            list in = llCSV2List(str);
            wwcWndDir=llList2Float(in,0);
            wwcWndSpeed=llList2Float(in,1);
            wwcWndGusts=llList2Float(in,2);
            wwcWndShifts=llList2Float(in,3);
            wwcWndChangeRate=llList2Float(in,4);
            wwcWndSystem=llList2String(in,5);
            shadowingBoats=[]; // reset all windshadows
        } else if(num==MSGTYPE_WWCWAVES) {
            list in = llCSV2List(str);
            wwcWaveHeight=llList2Float(in,0);
            wwcWaveLength=llList2Float(in,1);
            wwcWaveSpeed=llList2Float(in,2);
            wwcWaveHeightVariance=llList2Float(in,3);
            wwcWaveLengthVariance=llList2Float(in,4);
            wwcWaveOriginX=llList2Float(in,5);
            wwcWaveOriginY=llList2Float(in,6);
            wwcWaterDepth=llList2Float(in,7);
            wwcWndSystem=llList2String(in,8);
        } else if(num==MSGTYPE_WWCCURRENT) {
            list in = llCSV2List(str);
            wwcCrntDir=llList2Float(in,0);
            wwcCrntSpeed=llList2Float(in,1);
            wwcWaterDepth=llList2Float(in,2);
            wwcCrntSystem=llList2String(in,3);
        } else if(num==MSGTYPE_WWCLOCALSCLEAR) {
            wwcLocalFluctuations=[];
            localWindSpeed=1.0;
            localWindDir=0;
            localWaveHeight=1.0;
            localCurrentDir=0.0;
            localCurrentSpeed=1.0;
        } else if(num==MSGTYPE_WWCLOCALS) {
            list in = llCSV2List(str);
            if(llGetListLength(in)==9) wwcLocalFluctuations+=in;
        } else if(num==MSGTYPE_SETTINGS) {   
            if(str=="hudchannel") HudChannel=(integer)((string)id);   //receive hud channel from Helmsman script
        } else if(num==MSGTYPE_SETTINGSCHANGE) {  //set global or personal wind and parameters
            if(str=="global"){ 
                windType=0;   //wwc
                llOwnerSay("WWC wind ON");
            }else if(str=="mywind"){ 
                windType=1;   //personal wind
                llOwnerSay("Personal wind ON");
            }else if(str=="winddir"){ 
                mywindDir=(integer)((string)id);
                llOwnerSay("Wind Direction: "+(string)mywindDir+"º");
            }else if(str=="windspd"){ 
                mywindSpd=(float)((string)id)*0.514444;
                llOwnerSay("Wind Speed: "+(string)llRound(mywindSpd*1.94384)+"kt.");
            }
        }
    }

    listen(integer channel, string name, key id, string msg) { 
        if (llGetSubString(msg,0,5)=="BtPos,") {
            calcWindShadow(llCSV2List(msg), id);
        }
    }

    timer() {
        integer flexiBtPosInterval=sendBtPosInterval;
        
        calcSpeedAndHeading();
        if(++counter%calcLocalsInterval==0) getLocalFluctuation(globalPos.x, globalPos.y);
        calcWind(globalPos.x, globalPos.y);
        if(!windType){ //wwc
            if(counter%calcCurrentInterval==0) calcCurrent(); 
            calcWaveHeight();
        }else{
            waveHeight=0;
            currentSpeed=0;
            currentDir=0;
        }
        llSetObjectDesc(
            (string)compass+","+
            (string)((integer)(boatSpeed*10))+","+
            (string)((integer)(waterSpeed*10))+","+
            (string)relativeWindDir+","+
            (string)((integer)(apparentWindSpeed*10))+","+
            (string)apparentWindDir+","+
            (string)((integer)(waveHeight*10))+","+
            (string)((integer)(currentSpeed*10))+","+
            (string)currentDir);
            
        if(HudChannel>0) llWhisper(HudChannel,(string)((integer)(boatSpeed*10))+","+(string)apparentWindDir+","+(string)((integer)(apparentWindSpeed*10))+","+(string)globalPos+","+(string)globalTime);

        if(sailingMode==vehicleSailing && llFabs((float)apparentWindDir)>20) {
            if(++sendBtPosCounter>(sendBtPosInterval+(llGetListLength(shadowingBoats)/4))) {
                sendBtPosCounter=0;
                sendBtPosMessage();
            }
        }

        updateHud();
    }
}
