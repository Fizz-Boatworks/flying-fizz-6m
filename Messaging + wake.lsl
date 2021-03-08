// constants
integer MSGTYPE_MODECHANGE=50001;
integer VEHICLE_SAILING=1;
integer MSGTYPE_CAPSIZED=50147;
integer MSGTYPE_WWCWAVES=70502;
integer MSGTYPE_SETTINGS=1000;

integer MSGTYPE_SAY = 51000;
integer MSGTYPE_WHISPER = 52000;
integer MSGTYPE_SHOUT = 53000;
integer MSGTYPE_SAYTO = 54000;

//LINKS
integer RUDDER;
integer BOWWAVE;

// operational variables
float   curRateRoot=0.0;
float   curRateRudder=0.0;
float   curRateBow=0.0;
integer boostTimer=0;
integer    nextBoost=10;
integer curSailingState=-1;
integer    hasCapsized=0;

// wwc parameters
float   wwcWaveOriginX=0.0;
float   wwcWaveOriginY=0.0;
float   wwcWaveSpeed=0.0;
float   wwcWaveLength=0.0;
float    waveCycle=0.0;

//messages
string  notecard="Messages";
key     messagesQueryID; //id used to identify dataserver queries reading notecard
list messagesQueue=[];
integer wakeTime;

//read settings notecard
string  currentNoteCard="fizz_settings";
integer settingsLine;        // current line number reading notecard
key     settingsQueryID;             // id used to identify dataserver queries reading notecard
list    notecardParams;
integer comIndex;
string sline;
integer msgId;

init() {
    list      nameList = llParseString2List(llGetObjectName(), [" M@"], []);
    string    language=llGetSubString(llList2String(nameList,1),0,1);
    if(llGetInventoryType("Messages"+language)==INVENTORY_NOTECARD) notecard="Messages"+language;
    else notecard="Messages";
    
    getLinkNums();
    curRateRoot=99.0;
    curRateRudder=99.0;
    curRateBow=99.0;
    boostTimer=0;
    nextBoost=10;
    curSailingState=-1;
    hasCapsized=0;
    setPosition(0);  //wake bow
    wakezero();
    llOwnerSay(llGetScriptName()+" ready ("+(string)llGetFreeMemory()+" free)");
}

getLinkNums() {
    integer i;
    integer linkcount=llGetNumberOfPrims();
    for (i=1;i<=linkcount;++i) {
        string str=llGetLinkName(i);
        if (str=="rudder") RUDDER=i;
        if (str=="bowwave") BOWWAVE=i;
    }
}

wakezero()
{
    llParticleSystem([]);   //wake root
    llLinkParticleSystem(RUDDER,[]);  //wake rudder
    llLinkParticleSystem(BOWWAVE,[]);  //wake bow
    curRateRoot=0;
    curRateRudder=0;
    curRateBow=0;
}

wakeRoot(float prate)
{
    llParticleSystem([
        PSYS_PART_FLAGS, (PSYS_PART_EMISSIVE_MASK | PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK),
        PSYS_SRC_PATTERN, 4,
        PSYS_PART_START_SCALE, <1.0,1.0,1.0>*((prate+0.25)/1.25),
        PSYS_PART_END_SCALE, <2,2,2>*((prate+0.25)/1.25),
        PSYS_PART_START_COLOR, <0.9,1,1>,
        PSYS_PART_END_COLOR, <0.7,0.8,0.8>,
        PSYS_PART_START_ALPHA, 0.6,
        PSYS_PART_END_ALPHA, 0.0,
        PSYS_SRC_ANGLE_BEGIN, 1.7, 
        PSYS_SRC_ANGLE_END, 2.2,
        PSYS_SRC_TEXTURE, (key)"b1b5356d-9c40-e3a7-70ec-c32066f531f6",
        PSYS_PART_MAX_AGE,1.5,
        PSYS_SRC_ACCEL, <0,0,0.4>*prate,
        PSYS_SRC_BURST_SPEED_MIN, 3.0*((1.0+prate)/2.0),
        PSYS_SRC_BURST_SPEED_MAX, 5.0,
        PSYS_SRC_MAX_AGE, 0.00,
        PSYS_SRC_BURST_PART_COUNT, 10,
        PSYS_SRC_BURST_RADIUS, 0.01,
        PSYS_SRC_BURST_RATE, 0.0,
        PSYS_SRC_OMEGA, <0.00,0.00,0.00>
        ]);
}

wakeRudder(float prate)
{
    llLinkParticleSystem(RUDDER,[
        PSYS_PART_FLAGS, (PSYS_PART_EMISSIVE_MASK | PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK),
        PSYS_SRC_PATTERN, 8,
        PSYS_PART_START_SCALE, <0.8,0.8,0.5>*((prate+0.25)/1.25),
        PSYS_PART_END_SCALE, <1.1,1.1,0.7>*((prate+0.25)/1.25),
        PSYS_PART_START_COLOR, <0.85,0.9,0.9>,
        PSYS_PART_END_COLOR, <0.85,0.9,0.9>,
        PSYS_PART_START_ALPHA, 0.3,
        PSYS_PART_END_ALPHA, 0.0,
        PSYS_SRC_ANGLE_BEGIN, 1.6, 
        PSYS_SRC_ANGLE_END, 0.6,
        PSYS_SRC_TEXTURE, (key)"b1b5356d-9c40-e3a7-70ec-c32066f531f6",
        PSYS_PART_MAX_AGE, 0.8,
        PSYS_SRC_ACCEL, <0,0,0.3>*prate,
        PSYS_SRC_BURST_SPEED_MIN, 1.0*((1.0+prate)/2.0),
        PSYS_SRC_BURST_SPEED_MAX, 0.0,
        PSYS_SRC_MAX_AGE, 0.00,
        PSYS_SRC_BURST_PART_COUNT, 10,
        PSYS_SRC_BURST_RADIUS, 0.01,
        PSYS_SRC_BURST_RATE, 0.0,
        PSYS_SRC_OMEGA, <0.00,0.00,0.00>
        ]);    
}

wakeBow(float prate)
{
    llLinkParticleSystem(BOWWAVE,[
        PSYS_PART_FLAGS, (PSYS_PART_EMISSIVE_MASK | PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK),
        PSYS_SRC_PATTERN, 4,
        PSYS_PART_START_SCALE, <1,1,0.9>*((prate+0.25)/1.25),
        PSYS_PART_END_SCALE, <2,2,2>*((prate+0.25)/1.25),
        PSYS_PART_START_COLOR, <0.9,1,1>,
        PSYS_PART_END_COLOR, <0.7,0.8,0.8>,
        PSYS_PART_START_ALPHA, 1.0,
        PSYS_PART_END_ALPHA, 0.2,
        PSYS_SRC_ANGLE_BEGIN, 1.7,
        PSYS_SRC_ANGLE_END, 2.2,
        PSYS_SRC_TEXTURE, (key)"b1b5356d-9c40-e3a7-70ec-c32066f531f6",
        PSYS_PART_MAX_AGE, 1.0,
        PSYS_SRC_ACCEL, <0,0,0.4>*prate,
        PSYS_SRC_BURST_SPEED_MIN, 3.0*((1.0+prate)/2.0),
        PSYS_SRC_BURST_SPEED_MAX, 5.0,
        PSYS_SRC_MAX_AGE, 0.00,
        PSYS_SRC_BURST_PART_COUNT, 10,
        PSYS_SRC_BURST_RADIUS, 0.01,
        PSYS_SRC_BURST_RATE, 0.0,
        PSYS_SRC_OMEGA, <0.00,0.00,0.00>
        ]);    
}

setPosition(integer sailingState) {   //for wake bow
    if(sailingState!=curSailingState) {
        vector  offSet;
        if(sailingState==0) offSet=<1.8,0,0.25>;        //prim position sailing state 0
        else if(sailingState==1) offSet=<0.55,0,0>;     //prim position sailing state 1
        else if(sailingState==2) offSet=<0.33,0,-0.30>; //prim position sailing state 2
        if(offSet!=<0,0,0>) llSetLinkPrimitiveParamsFast(BOWWAVE,[PRIM_POSITION, offSet]);
        sailingState=curSailingState;
    }
}

calcWaves() {     //for wake bow
    vector    globalPos=llGetPos()+llGetRegionCorner();
    float globalTime=(float)(llGetUnixTime()%-1000000);
    float time;
    float freq;  // waves per second
    integer wavesPassed;
    float distance=llVecDist(globalPos, <wwcWaveOriginX,wwcWaveOriginY,0>);
    float waveHeel;
    if(wwcWaveSpeed<=0.0) return;
    freq=wwcWaveLength/wwcWaveSpeed;
    time= globalTime-(distance/wwcWaveSpeed);  // time it took the waves to get here
    wavesPassed = (integer)(time/freq);  // can be negative
    waveCycle = (time-((float)wavesPassed*freq))/freq;
    if(waveCycle<0.0) waveCycle=waveCycle*-1.0;  // not sure if this is possible, better safe than sorry
}

default
{
    on_rez(integer param)
    {
        llResetScript();
        //init();
    }

    state_entry()
    {
        init();
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        if(str=="loadconf") {
            llOwnerSay("Loading Configuration");
            notecardParams=[];
            settingsLine=0;
            settingsQueryID = llGetNotecardLine(currentNoteCard, settingsLine);    // read line
        } else if(num == MSGTYPE_MODECHANGE) { 
            wakezero();
            wakeTime=3;
            if((integer)str==VEHICLE_SAILING) llSetTimerEvent(1.0);
            else llSetTimerEvent(0);
        } else if(num==MSGTYPE_CAPSIZED) {
            hasCapsized=(integer)str;
            if(hasCapsized>0) wakezero();;
        } else if(num==MSGTYPE_WWCWAVES) {
            list in = llCSV2List(str);
            wwcWaveLength=llList2Float(in,1);
            wwcWaveSpeed=llList2Float(in,2);
            wwcWaveOriginX=llList2Float(in,5);
            wwcWaveOriginY=llList2Float(in,6);            
        } 
        
        //messages
        if(num==MSGTYPE_SAYTO | num==MSGTYPE_WHISPER || num==MSGTYPE_SAY || num==MSGTYPE_SHOUT) {
            messagesQueue+=[num,(integer)str,(string)id];
            if(llGetListLength(messagesQueue)<=3) {
                messagesQueryID=llGetNotecardLine(notecard, (integer)str);    // request line with the message
            }
        }
    }
    
    //messages
    dataserver(key query_id, string data) { 
        if (query_id == messagesQueryID) {   //find message
            if (data != EOF) {
                integer msgType=llList2Integer(messagesQueue,0);  //message type
                string extramessage=llList2String(messagesQueue,2);  //keyid for SAYTO  extramessage for others
                if(msgType==MSGTYPE_SAYTO){ 
                    key k=(key)llGetSubString(extramessage,0,35);
                    if(llStringLength(extramessage)>36) extramessage=llGetSubString(extramessage,36,-1);
                    else extramessage="";
                    if(k) llRegionSayTo(k,0,data+" "+extramessage);
                }else if(msgType==MSGTYPE_WHISPER) llWhisper(0,data+" "+extramessage);
                else if(msgType==MSGTYPE_SAY) llSay(0,data+" "+extramessage);
                else if(msgType==MSGTYPE_SHOUT) llShout(0,data+" "+extramessage);
                messagesQueue=llDeleteSubList(messagesQueue,0,2);
                if(llGetListLength(messagesQueue)>=3) messagesQueryID=llGetNotecardLine(notecard, llList2Integer(messagesQueue,1));
            } else {
                messagesQueue=[];
            }
        } else if (query_id == settingsQueryID) {   //load settings
            if (data != EOF) {
                comIndex=llSubStringIndex(data,"//");
                if(comIndex>0) sline=llGetSubString(data,0,comIndex-1);
                else if(comIndex==0) sline="";
                else sline=data;
                sline=llStringTrim(sline,STRING_TRIM);
                if(sline!=""){
                    if(llGetSubString(sline,0,0)=="["){
                        if(msgId>0 && llGetListLength(notecardParams)>0) llMessageLinked(LINK_SET, MSGTYPE_SETTINGS, (string)msgId, llList2CSV(notecardParams));
                        notecardParams=[];
                        msgId=(integer)llGetSubString(sline,1,2);
                        if(msgId==0) llOwnerSay("Fizz Settings Error in line "+sline);
                    }else{
                        notecardParams+=llList2List(llCSV2List(data),0,-1);
                    }
                }
                ++settingsLine;
                settingsQueryID = llGetNotecardLine(currentNoteCard, settingsLine);    // request next line
            }else{
                if(msgId>0) llMessageLinked(LINK_SET, MSGTYPE_SETTINGS, (string)msgId, llList2CSV(notecardParams));
                llOwnerSay("Configuration Loaded");
            }
        }
    }

    timer() {
        float  boatSpeed=llVecMag(llGetVel());
        integer sailingState=0;
        float topBoatSpeed=10.0;    //for roor 10.0  for rudder 6.0  bow 8.0
        float rate=0.0;
        float tmprate=rate;
        float rateRoot=0.0;
        float rateRudder=0.0;
        float rateBow=0.0;
        if(boatSpeed>1.0 && hasCapsized<=0) {
            if(boatSpeed>3.0) sailingState++;
            if(boatSpeed>10.0) sailingState++;
            if(topBoatSpeed<=0.0) topBoatSpeed=10;
            rate = (boatSpeed/topBoatSpeed);
            //bow wake
            calcWaves();
            // __=0 /=0.25 --=0.5 \=0.75
            if(rate>1.0) tmprate=1.0;
            else tmprate=rate;
            if(waveCycle>0.20 && waveCycle<0.40) {  // taking the plunge
                tmprate+=0.5;
            } else if(waveCycle>0.70 && waveCycle<0.90) {  // taking the plunge
                tmprate-=0.3;
            }
            if(sailingState==0) tmprate=tmprate*1.0;
            else if(sailingState==1) tmprate=tmprate*2.0;
            else if(sailingState==2) tmprate=tmprate*1.0;
            if(tmprate>1.0) tmprate=1.0;
            else if(tmprate<0.0) tmprate=0.0;
            if(tmprate==0.0 && curRateBow>0.0) wakezero();
            else if(tmprate<(curRateBow-0.05) || tmprate>(curRateBow+0.05)) {
                wakeBow(tmprate);
                curRateBow=tmprate;
            }
            if(wakeTime==3){
                //others wake
                boostTimer++;
                if(boostTimer>=nextBoost) {
                    if(boostTimer>nextBoost) {
                        boostTimer=0;
                        nextBoost=(integer)llFrand(4.0)+2; // between 2 and 6 = between 5 and 15 seconds
                    }
                    rate+=0.5;
                }
                //root wake
                if(sailingState==0) tmprate=rate*1.0;             
                else if(sailingState==1) tmprate=rate*2.0;     
                else if(sailingState==2) tmprate=rate*1.0;     
                if(tmprate>1.0) tmprate=1.0;
                else if(tmprate<0.0) tmprate=0.0;
                if(tmprate==0.0 && curRateRoot>0.0) wakezero();
                else if(tmprate<(curRateRoot-0.05) || tmprate>(curRateRoot+0.05)) {
                    wakeRoot(tmprate);
                    curRateRoot=tmprate;
                }
                //rudder wake
                if(sailingState==0) tmprate=rate*0.5;             
                else if(sailingState==1) tmprate=rate*1.0;     
                else if(sailingState==2) tmprate=rate*1.0;     
                if(tmprate>1.0) tmprate=1.0;
                else if(tmprate<0.0) tmprate=0.0;
                if(tmprate==0.0 && curRateRudder>0.0) wakezero();
                else if(tmprate<(curRateRudder-0.05) || tmprate>(curRateRudder+0.05)) {
                    wakeRudder(tmprate);
                    curRateRudder=tmprate;
                }
            }
            if(--wakeTime==0) wakeTime=3;
        }else wakezero(); 
    }
}
