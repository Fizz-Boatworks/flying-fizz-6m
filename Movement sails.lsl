// Sails script
// By Mothgirl Dibou
// Last change 2008/06/19
// Put this in the root prim
// This scripts makes sure the sails are shown/hidden and the sheet angle is show by rotating the sails and boom
// (gennaker does not rotate)
//
// Settings for sails: "Sails" notecard, contains dimensions and offsets for each sail
// layout: 
// mainsail, <size>, <offset>, <zero rotation>, <distance center to rotationpoint>, sculpt image key port, sculpt image key sb, alpha(float), <90 rotation>, <-90 rotation>
// foresail, <size>, <offset>, <zero rotation>, <distance center to rotationpoint>, sculpt image key port, sculpt image key sb, alpha(float)
// gennaker, <offset port>, <rotation port>, <offset sb>, <rotation sb>, <offset hidden>, <rotation hidden>, sculpt image key port, sculpt image key sb, alpha(float)
// boom, <offset>, <zero rotation> 
// the order of the rows is fixed here (name of the sail is for info only)
//
// link messages received: 
// MODECHANGE, 0/1/2/3  set moored, sailing, floating, motoring
// SETTINGSCHANGE, show <sailname>
// SETTINGSCHANGE, hide <sailname> 
// SAILINFO, 
//    0 sheet angle mainsail(deg.),    
//    1 sail shape mainsail(0-3), 
//    2 sheet setting mainsail (0-flapping, 1-loose, 2- optimal, 3-tight, 4-very tight),
//    3 sheet angle foresail(deg.), 
//    4 sail shape foresail(0-3), 
//    5 sheet setting foresail (0-flapping, 1-loose, 2- optimal, 3-tight, 4-very tight),
//    6 foresailVisible(0,1), 
//    7 sheet angle gennaker(deg.), 
//    8 sail shape gennaker(0-3), 
//    9 sheet setting gennaker (0-flapping, 1-loose, 2- optimal, 3-tight, 4-very tight),
//    10 gennaker visible(0/1/-1), 
//    11 capsized(0/1/-1)

// mainsail angles:
// sculpt image key port, sculpt image key sb, alpha(float), sizeround(vector), sizeflat(vector)
//-75: 104.2,285,104.8  -  -1.120,2.466,11.786
//-60: 97.5,300,98.5  -  -1.706,2.242,11.786
//-45: 94.1,315,95.7  -  -2.274,1.819,11.786
//-30: 92.3,330,94.5  -  -2.706,1.282,11.786
//-15: 91.3,345,94.1  -  -2.978,0.693,11.786
//0:  90,0,94  -  -3.023,0,11.786
//15: 88.7,15,94.1  -  -2.978,-0.693,11.786
//30: 87.7,30,94.5  -  -2.706,-1.282,11.786
//45: 85.9,45,95.7  -  -2.274,-1.819,11.786
//60: 82.5,60,98.5  -  -1.706,-2.242,11.786
//75: 75.8,75,104.8  -  -1.120,-2.466,11.786

integer MSGTYPE_SETTINGS=1000;
integer MSGTYPE_MODECHANGE=50001;
integer MSGTYPE_SAILINFO=50007;
integer MSGTYPE_TEXTURECHANGE=7988;
integer MSGTYPE_SETTINGSCHANGE=50003;

//others parts
integer MSGTYPE_STEERING=55016;
integer MSGTYPE_CREWINFO=50100;

//sails constants
integer mainMinAngle=7;   //degrees
integer mainMaxAngle=70;   //degrees
integer jibMinAngle=23;   //degrees
integer jibMaxAngle=70;   //degrees
integer genMinAngle=30;   //degrees
integer genMaxAngle=70;   //degrees
vector mainRot=<0,-4,0>;   //degres
vector boomRot=<0,0,0>;   //degres
vector jibRot=<0,-21.6,0>;   //degres
vector genRot=<0,-28,0>;   //degres

//sails parameters
vector mainOpenSize=<6.28077, 0.62823, 8.03341>;
vector mainOpenPos=<0.42824, 0.0, 5.54929>;
vector mainOpenRot=<0.0,-4.0,0.0>;
vector mainCloseSize=<6.28077,0.01,0.01>;
vector mainClosePos=<0.42824, 0.0, 1.49017>;
vector mainCloseRot=<0.0,0.0,0.0>;

vector jibOpenSize=<4.27705, 0.39654, 6.17853>;
vector jibOpenPos=<1.71127, 0.0, 4.24774>;
vector jibOpenRot=<0.0,-21.6,0.0>;
vector jibCloseSize=<0.01000, 0.01000, 6.17853>;
vector jibClosePos=<1.71127, 0.0, 4.24774>;
vector jibCloseRot=<0.0,-21.6,0.0>;

vector genOpenSize=<7.29577, 1.46682, 9.20438>;
vector genOpenPos=<2.56068, 0.0, 5.28257>;
vector genOpenRot=<0.0,-28.0,0.0>;
vector genCloseSize=<0.10000, 0.10000, 0.10000>;
vector genClosePos=<2.56068, 0.0, 1.21111>;
vector genCloseRot=<0.0,-28,0.0>;

//sheets constants
vector UP=<0.0,0.0,1.0>;
vector offsetBoom=<1.823225,0,0.05121>;
vector offsetJibs=<2.13070,0.03595,2.06747>;
vector offsetJibp=<2.13070,-0.03195,2.06747>;  //0.0639
vector offsetGens=<3.647885,0.0791,2.0263>;
vector offsetGenp=<3.647885,-0.08,2.0263>;
vector mainsheetCloseSize=<1.25392, 0.02147, 0.09142>;
vector mainsheetCloseRot=<90,0,90>;

//variables
integer VEHICLE_SAILING=1;

// linknums
integer mainsailLinkNum=0;
integer foresailLinkNum=0;
integer gennakerLinkNum=0;
integer boomLinkNum=0;
integer mainsheetLinkNum=0;
integer jibsheetsLinkNum=0;
integer jibsheetpLinkNum=0;
integer gensheetsLinkNum=0;
integer gensheetpLinkNum=0;
integer rudderLinkNum=0;
integer tillerLinkNum=0;
integer POINTLINK;

//sheets variables
vector posBoom;
vector posMainSheet;
vector sizeMainSheet;
vector posJib;
vector posJibSheets;
vector posJibSheetp;
vector sizeJibSheets;
vector sizeJibSheetp;
vector posGen;
vector posGenSheets;
vector posGenSheetp;
vector sizeGenSheets;
vector sizeGenSheetp;

// sailing variables;
integer sailingMode=0;
integer hasCapsized=0;
integer curMainsailAngle=999;
integer curForesailAngle=999;
integer curGennakerAngle=999;
integer curMainsailSide=0;
integer curForesailSide=0;
integer curGennakerSide=0;
integer curGennakerVisible=9;
integer curTellTalesMain=-1;
integer curTellTalesJib=-1;

integer curSteeringDir=9;
integer curPoseHelmsman=0;
integer curPoseCrew0=0;
integer curPoseCrew1=0;

// settings read
list mainsailTextures=[];
list jibsailTextures=[];

init()
{
    sailingMode=0;
    hasCapsized=0;
    curMainsailAngle=999;
    curForesailAngle=999;
    curGennakerAngle=999;
    curGennakerVisible=9;
    curMainsailSide=0;
    curForesailSide=0;
    curGennakerSide=0;
    curTellTalesMain=-1;
    curTellTalesJib=-1;
    getLinkNums();
    mainsailTextures=[];
    jibsailTextures=[];
    llSetLinkPrimitiveParamsFast(gennakerLinkNum,[PRIM_POS_LOCAL,genClosePos,PRIM_SIZE,genCloseSize,PRIM_ROT_LOCAL,llEuler2Rot(genCloseRot*DEG_TO_RAD)]);
    llSetLinkPrimitiveParamsFast(boomLinkNum,[PRIM_ROT_LOCAL,ZERO_ROTATION]);
    llSetLinkPrimitiveParamsFast(mainsheetLinkNum,[PRIM_ROT_LOCAL,llEuler2Rot(mainsheetCloseRot*DEG_TO_RAD),PRIM_SIZE,mainsheetCloseSize]);
    llSetLinkPrimitiveParamsFast(rudderLinkNum,[PRIM_ROT_LOCAL,ZERO_ROTATION]);
    llSetLinkPrimitiveParamsFast(mainsailLinkNum,[PRIM_POS_LOCAL,mainClosePos,PRIM_SIZE,mainCloseSize,PRIM_ROT_LOCAL,llEuler2Rot(mainCloseRot*DEG_TO_RAD)]);
    llSetLinkPrimitiveParamsFast(foresailLinkNum,[PRIM_POS_LOCAL,jibClosePos,PRIM_SIZE,jibCloseSize,PRIM_ROT_LOCAL,llEuler2Rot(jibCloseRot*DEG_TO_RAD)]);

    posBoom=llList2Vector(llGetLinkPrimitiveParams(boomLinkNum,[PRIM_POS_LOCAL]),0);
    posMainSheet=llList2Vector(llGetLinkPrimitiveParams(mainsheetLinkNum,[PRIM_POS_LOCAL]),0);
    sizeMainSheet=mainsheetCloseSize;
    posJib=jibOpenPos;
    posJibSheets=llList2Vector(llGetLinkPrimitiveParams(jibsheetsLinkNum,[PRIM_POS_LOCAL]),0);
    posJibSheetp=llList2Vector(llGetLinkPrimitiveParams(jibsheetpLinkNum,[PRIM_POS_LOCAL]),0);
    sizeJibSheets=llList2Vector(llGetLinkPrimitiveParams(jibsheetsLinkNum,[PRIM_SIZE]),0);
    sizeJibSheetp=llList2Vector(llGetLinkPrimitiveParams(jibsheetpLinkNum,[PRIM_SIZE]),0); 
    posGen=genOpenPos;
    posGenSheets=llList2Vector(llGetLinkPrimitiveParams(gensheetsLinkNum,[PRIM_POS_LOCAL]),0);
    posGenSheetp=llList2Vector(llGetLinkPrimitiveParams(gensheetpLinkNum,[PRIM_POS_LOCAL]),0);
    sizeGenSheets=llList2Vector(llGetLinkPrimitiveParams(gensheetsLinkNum,[PRIM_SIZE]),0);
    sizeGenSheetp=llList2Vector(llGetLinkPrimitiveParams(gensheetpLinkNum,[PRIM_SIZE]),0); 
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
        else if (str=="jibsheets") jibsheetsLinkNum=i;
        else if (str=="jibsheetp") jibsheetpLinkNum=i;
        else if (str=="gennakersheets") gensheetsLinkNum=i;
        else if (str=="gennakersheetp") gensheetpLinkNum=i;
        else if (str=="rudder") rudderLinkNum=i;
        else if (str=="tiller") tillerLinkNum=i;
        else if (str=="pointlink") POINTLINK=i;
    }
}

notecardRead(integer msgId, string str) {
    list    in=llCSV2List(str);
    if(msgId==90) mainsailTextures=in; 
    else if(msgId==91) jibsailTextures=in; 
    //llOwnerSay((string)msgId+"   "+(string)llGetListLength(in));
    if(msgId==91){ 
        llOwnerSay(llGetScriptName()+" ready ("+(string)llGetFreeMemory()+" free)");
    }
}

setMainsail(integer angle, integer setting) {
    //llOwnerSay("setMainsail("+(string)angle+", "+(string)setting+")");
    integer side;
    //angle=(angle/2)*2;
    if(setting==0) {}  // flapping  poner sonido de flapping
    if(angle!=curMainsailAngle) {
        if(llAbs(angle)<mainMinAngle && angle!=0) angle=mainMinAngle*angle/llAbs(angle);
        else if(llAbs(angle)>mainMaxAngle) angle=mainMaxAngle*angle/llAbs(angle);
        llSetLinkPrimitiveParamsFast(mainsailLinkNum,[PRIM_ROT_LOCAL,llEuler2Rot(DEG_TO_RAD*<mainRot.x,mainRot.y,-angle>)]);
        llSetLinkPrimitiveParamsFast(boomLinkNum,[PRIM_ROT_LOCAL,llEuler2Rot(DEG_TO_RAD*<boomRot.x,boomRot.y,-angle>)]);
        //Pone el lado visible de la vela
        if(angle<=0) side=1;
        else side=2;
        if(side!=curMainsailSide){
            llSetLinkPrimitiveParamsFast(mainsailLinkNum,[PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0,PRIM_COLOR,side,<1,1,1>,1.0]);
            curMainsailSide=side;
        }
        curMainsailAngle=angle;
        //carga de las texturas de las catas
        if(setting!=curTellTalesMain) {  
            string texture = llList2String(mainsailTextures,setting);
            if((key)texture) llSetLinkPrimitiveParamsFast(mainsailLinkNum,[PRIM_TEXTURE,ALL_SIDES,(key)texture,<1,1,1>,<0,0,0>,0.0]);
            curTellTalesMain=setting;
        }
        //posicionamiento del mainsheet        
        vector vt=posBoom-offsetBoom+(offsetBoom-offsetBoom*llEuler2Rot(DEG_TO_RAD*<boomRot.x,boomRot.y,-angle>))*ZERO_ROTATION;
        vector vt2=vt-posMainSheet;
        //sizeMainSheet.x=llVecMag(vt2)*2;
        sizeMainSheet.x=llVecMag(vt2)*2;
        vt2=llVecNorm(vt2);
        vector left=llVecNorm(UP%vt2);
        //llSetLinkPrimitiveParamsFast(POINTLINK,[PRIM_POS_LOCAL,vt]);
        llSetLinkPrimitiveParamsFast(mainsheetLinkNum,[PRIM_ROT_LOCAL,llAxes2Rot(vt2,left,llVecNorm(vt2%left)),PRIM_SIZE,sizeMainSheet]);
    }
}

setForesail(integer angle, integer setting) {
//    llOwnerSay("setForesail("+(string)angle+", "+(string)shape+")");
    integer side;
    //angle=(angle/2)*2;
    if(setting==0) {} // flapping
    if(angle!=curForesailAngle) {
        if(llAbs(angle)<jibMinAngle) angle=jibMinAngle*angle/llAbs(angle);
        else if(llAbs(angle)>jibMaxAngle) angle=jibMaxAngle*angle/llAbs(angle);
        llSetLinkPrimitiveParamsFast(foresailLinkNum,[PRIM_ROT_LOCAL,llEuler2Rot(DEG_TO_RAD*<jibRot.x,jibRot.y,-angle>)]);
        //Pone el lado visible de la vela
        if(angle<0) side=1;
        else side=2;
        if(side!=curForesailSide){
            llSetLinkPrimitiveParamsFast(foresailLinkNum,[PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0,PRIM_COLOR,side,<1,1,1>,1.0]);
            if(curForesailSide==1) llSetLinkPrimitiveParamsFast(jibsheetsLinkNum,[PRIM_SIZE,<0.01,0.01,0.01>]);
            else llSetLinkPrimitiveParamsFast(jibsheetpLinkNum,[PRIM_SIZE,<0.01,0.01,0.01>]);
            curForesailSide=side;
        }
        curForesailAngle=angle;
        //carga de las texturas de las catas
        if(setting!=curTellTalesJib) {  //carga de las texturas del jib
            string texture = llList2String(jibsailTextures,setting);
            if((key)texture) llSetLinkPrimitiveParamsFast(foresailLinkNum,[PRIM_TEXTURE,ALL_SIDES,(key)texture,<1,1,1>,<0,0,0>,0.0]);
            curTellTalesJib=setting;
        }  
        //posicionamiento del sheet  
        if(side==1){   
            vector vt=posJib-offsetJibs+(offsetJibs-offsetJibs*llEuler2Rot(DEG_TO_RAD*<jibRot.x,jibRot.y,-angle>))*ZERO_ROTATION;
            //llSetLinkPrimitiveParamsFast(POINTLINK,[PRIM_POS_LOCAL,vt]);
            vt=vt-posJibSheets;
            sizeJibSheets.x=llVecMag(vt)*2;
            vt=llVecNorm(vt);
            llSetLinkPrimitiveParamsFast(jibsheetsLinkNum,[PRIM_ROT_LOCAL,llAxes2Rot(vt,llVecNorm(UP%vt),llVecNorm(vt%llVecNorm(UP%vt))),PRIM_SIZE,sizeJibSheets]);
        }else{
            vector vt=posJib-offsetJibp+(offsetJibp-offsetJibp*llEuler2Rot(DEG_TO_RAD*<jibRot.x,jibRot.y,-angle>))*ZERO_ROTATION;
            //llSetLinkPrimitiveParamsFast(POINTLINK,[PRIM_POS_LOCAL,vt]);
            vt=vt-posJibSheetp;
            sizeJibSheetp.x=llVecMag(vt)*2;
            vt=llVecNorm(vt);
            llSetLinkPrimitiveParamsFast(jibsheetpLinkNum,[PRIM_ROT_LOCAL,llAxes2Rot(vt,llVecNorm(UP%vt),llVecNorm(vt%llVecNorm(UP%vt))),PRIM_SIZE,sizeJibSheetp]);
        }
    }
}

setGennaker(integer angle, integer setting) {
    integer side;
    //angle=(angle/2)*2;
    if(gennakerLinkNum>0 && curGennakerVisible!=0) {
        if(setting==1) {}  // collapsed
        //curGennakerSide = setSail(angle, curGennakerAngle, shape, curGennakerShape, gennakerParams, gennakerLinkNum, curGennakerSide,2,2);
        //curGennakerSide = setSail(angle, curGennakerAngle, gennakerLinkNum, curGennakerSide,2,2);
        if(angle!=curGennakerAngle) {
            //llOwnerSay("setGennaker("+(string)angle+", current: "+(string)curGennakerAngle+" visible:"+(string)curGennakerVisible);
            if(llAbs(angle)<genMinAngle) angle=genMinAngle*angle/llAbs(angle);
            else if(llAbs(angle)>genMaxAngle) angle=genMaxAngle*angle/llAbs(angle);
            llSetLinkPrimitiveParamsFast(gennakerLinkNum,[PRIM_ROT_LOCAL,llEuler2Rot(DEG_TO_RAD*<genRot.x,genRot.y,-angle>)]);  //put gen rotation
            if(angle<0) side=1;
            else side=2;
            if(side!=curGennakerSide){  //if face change
                llSetLinkPrimitiveParamsFast(gennakerLinkNum,[PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0,PRIM_COLOR,side,<1,1,1>,1.0]);  //put face visible
                //remove the old sheet
                if(curGennakerSide==1) llSetLinkPrimitiveParamsFast(gensheetsLinkNum,[PRIM_SIZE,<0.01,0.01,0.01>]);
                else llSetLinkPrimitiveParamsFast(gensheetpLinkNum,[PRIM_SIZE,<0.01,0.01,0.01>]);
                curGennakerSide=side; //keep current side
            }
            curGennakerAngle=angle;

            //posicionamiento del sheet  
            if(side==1){   
                vector vt=posGen-offsetGens+(offsetGens-offsetGens*llEuler2Rot(DEG_TO_RAD*<genRot.x,genRot.y,-angle>))*ZERO_ROTATION;
                //llSetLinkPrimitiveParamsFast(POINTLINK,[PRIM_POS_LOCAL,vt]);
                vt=vt-posGenSheets;
                sizeGenSheets.x=llVecMag(vt)*2;
                vt=llVecNorm(vt);
                llSetLinkPrimitiveParamsFast(gensheetsLinkNum,[PRIM_ROT_LOCAL,llAxes2Rot(vt,llVecNorm(UP%vt),llVecNorm(vt%llVecNorm(UP%vt))),PRIM_SIZE,sizeGenSheets]);
            }else{
                vector vt=posGen-offsetGenp+(offsetGenp-offsetGenp*llEuler2Rot(DEG_TO_RAD*<genRot.x,genRot.y,-angle>))*ZERO_ROTATION;
                //llSetLinkPrimitiveParamsFast(POINTLINK,[PRIM_POS_LOCAL,vt]);
                vt=vt-posGenSheetp;
                sizeGenSheetp.x=llVecMag(vt)*2;
                vt=llVecNorm(vt);
                llSetLinkPrimitiveParamsFast(gensheetpLinkNum,[PRIM_ROT_LOCAL,llAxes2Rot(vt,llVecNorm(UP%vt),llVecNorm(vt%llVecNorm(UP%vt))),PRIM_SIZE,sizeGenSheetp]);
            }
        }
    }
}

moveRudder(integer steeringDir) {
    integer n;
    if(steeringDir==1) n=-15;
    else if(steeringDir==-1) n=15;
    else n=0;
    llSetLinkPrimitiveParamsFast(rudderLinkNum,[PRIM_ROT_LOCAL,llEuler2Rot(DEG_TO_RAD*<0,0,n>)]);
    moveTiller(curPoseHelmsman); //????? posehelm
}

moveTiller(integer poseHelmsman) {
    curPoseHelmsman=poseHelmsman;
}

setNewSailMode(integer newSailingMode) { 
    sailingMode=newSailingMode;
    llSetLinkPrimitiveParamsFast(gennakerLinkNum,[PRIM_POS_LOCAL,genClosePos,PRIM_SIZE,genCloseSize,PRIM_ROT_LOCAL,llEuler2Rot(genCloseRot*DEG_TO_RAD)]);
    llSetLinkPrimitiveParamsFast(boomLinkNum,[PRIM_ROT_LOCAL,ZERO_ROTATION]);
    llSetLinkPrimitiveParamsFast(mainsheetLinkNum,[PRIM_SIZE,mainsheetCloseSize,PRIM_ROT_LOCAL,llEuler2Rot(mainsheetCloseRot*DEG_TO_RAD)]); 
    llSetLinkPrimitiveParamsFast(mainsheetLinkNum,[PRIM_SIZE,mainsheetCloseSize]); 
    llSetLinkPrimitiveParamsFast(rudderLinkNum,[PRIM_ROT_LOCAL,ZERO_ROTATION]);
    llSetLinkPrimitiveParamsFast(gensheetsLinkNum,[PRIM_SIZE,<0.01,0.01,0.01>]);
    llSetLinkPrimitiveParamsFast(gensheetpLinkNum,[PRIM_SIZE,<0.01,0.01,0.01>]);
    if(sailingMode==VEHICLE_SAILING){
        llSetLinkPrimitiveParamsFast(mainsailLinkNum,[PRIM_POS_LOCAL,mainOpenPos,PRIM_SIZE,mainOpenSize,PRIM_ROT_LOCAL,llEuler2Rot(mainOpenRot*DEG_TO_RAD),PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0,PRIM_COLOR,2,<1,1,1>,1.0]);
        llSetLinkPrimitiveParamsFast(foresailLinkNum,[PRIM_POS_LOCAL,jibOpenPos,PRIM_SIZE,jibOpenSize,PRIM_ROT_LOCAL,llEuler2Rot(jibOpenRot*DEG_TO_RAD),PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0,PRIM_COLOR,2,<1,1,1>,1.0]);

    }else{
        llSetLinkPrimitiveParamsFast(mainsailLinkNum,[PRIM_POS_LOCAL,mainClosePos,PRIM_SIZE,mainCloseSize,PRIM_ROT_LOCAL,llEuler2Rot(mainCloseRot*DEG_TO_RAD)]);
        llSetLinkPrimitiveParamsFast(foresailLinkNum,[PRIM_POS_LOCAL,jibClosePos,PRIM_SIZE,jibCloseSize,PRIM_ROT_LOCAL,llEuler2Rot(jibCloseRot*DEG_TO_RAD)]);
        llSetLinkPrimitiveParamsFast(jibsheetsLinkNum,[PRIM_SIZE,<0.01,0.01,0.01>]);
        llSetLinkPrimitiveParamsFast(jibsheetpLinkNum,[PRIM_SIZE,<0.01,0.01,0.01>]);
        
        

        //vector vt=posBoom-offsetBoom+(offsetBoom-offsetBoom*ZERO_ROTATION)*ZERO_ROTATION;
        //llSetLinkPrimitiveParamsFast(POINTLINK,[PRIM_POS_LOCAL,vt]);
        
        hasCapsized=0;
        //set sails to default pos
        curMainsailAngle=0;
        curMainsailSide=0;
        curTellTalesMain=0;
        curForesailAngle=0;
        curForesailSide=0;
        curTellTalesJib=0;
        curGennakerAngle=0;
        curGennakerSide=0;
        curGennakerVisible=0;
        //moveTiller(0);
        llSetTimerEvent(1.0);
    }
}

default {
    state_entry() {
        init();
    }

    link_message(integer sender,integer num,string str,key id) {
        //llOwnerSay("==== "+(string)sailingMode+"   "+str);
        if(num==MSGTYPE_SETTINGS){
            num=(integer)str;
            if(num==90 || num==91) notecardRead(num,(string)id);
        }else if(num == MSGTYPE_MODECHANGE) {
            list settings=llCSV2List(str);
            integer newSailingMode=llList2Integer(settings, 0);
       // llOwnerSay("MSGTYPE_MODECHANGE:"+str);
            if(newSailingMode!=sailingMode) setNewSailMode(newSailingMode);
        } else if(num == MSGTYPE_SAILINFO && sailingMode==VEHICLE_SAILING) {
            list    sailInfo = llCSV2List(str);
            setMainsail(llList2Integer(sailInfo,0), llList2Integer(sailInfo,2));
            setForesail(llList2Integer(sailInfo,3), llList2Integer(sailInfo,5));
            if(FALSE || curGennakerVisible!=(integer)llList2String(sailInfo,10)){  //if gen visible change
                if(FALSE || llList2String(sailInfo,10)=="1"){   //gen visible
                    llSetLinkPrimitiveParamsFast(gennakerLinkNum,[PRIM_POS_LOCAL,genOpenPos,PRIM_SIZE,genOpenSize,PRIM_ROT_LOCAL,
                                llEuler2Rot(DEG_TO_RAD*<genRot.x,genRot.y,llList2Integer(sailInfo,7)>)]);
                    curGennakerVisible=1;
                }else{  //gen invisible
                    llSetLinkPrimitiveParamsFast(gennakerLinkNum,[PRIM_POS_LOCAL,genClosePos,PRIM_SIZE,genCloseSize,PRIM_ROT_LOCAL,
                                llEuler2Rot(genCloseRot*DEG_TO_RAD)]);
                    curGennakerVisible=0;
                    //put sheets invisible
                    if(curGennakerSide==1) llSetLinkPrimitiveParamsFast(gensheetsLinkNum,[PRIM_SIZE,<0.01,0.01,0.01>]);
                    else llSetLinkPrimitiveParamsFast(gensheetpLinkNum,[PRIM_SIZE,<0.01,0.01,0.01>]);
                    curGennakerSide=0; //reset current side
                }
            }
            if(curGennakerVisible) setGennaker(llList2Integer(sailInfo,7), llList2Integer(sailInfo,9));
            //llOwnerSay(llList2String(sailInfo,9)+"    "+llList2String(sailInfo,10));
        } else if(num == MSGTYPE_STEERING && rudderLinkNum>0) { 
            integer steeringDir=(integer)llGetSubString(str,0,1);
            if(steeringDir!=curSteeringDir) moveRudder(steeringDir);
        } else if(num == MSGTYPE_CREWINFO) { 
            list    in = llCSV2List(str);
            if(llList2Integer(in, 1)<=0) {
                integer    poseHelmsman=llList2Integer(in, 0);
                if(tillerLinkNum>0 && poseHelmsman!=curPoseHelmsman) moveTiller(poseHelmsman); 
            }
        }
    }
    
    timer() {
        llSetTimerEvent(0.0);
        llSetLinkAlpha(mainsailLinkNum,0.0,ALL_SIDES);
        llSetLinkAlpha(foresailLinkNum,0.0,ALL_SIDES);
    }
        
}

