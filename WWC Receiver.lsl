// WWC receiver
// By Mothgirl Dibou
// Last change 2008/09/05
//


// constants
string secretScriptKey="JKLU97RW";
integer MSGTYPE_SCRIPTCHECK=54350;
string THISCLASSNAME="flying fizz 3.05";  // always in lowercase
float TIMERINTERVAL=1.0;  // in seconds
float RACETIMEOUT=7200.0;  // in seconds;
float DIALOGTIMEOUT=60.0;
float EMAILTIMEOUT=60.0;
float ms2knots=1.945;

integer MSGTYPE_SENDCRWWCREQ=701;
integer MSGTYPE_SENDRCWWCREQ=702;
integer MSGTYPE_SENDRCSUB=703;
integer MSGTYPE_GETNEWWWC=70001;
integer MSGTYPE_CREWSEATED=70400; // 1-4 crewmembers 70401 = helmsman, 70402 = crew 1, 70403=crew2, 70404=crew 3, send avatar's UUID when seated and NULL_KEY when avatar has left
integer MSGTYPE_WWCRACE=70500;
integer MSGTYPE_WWCWIND=70501;
integer MSGTYPE_WWCWAVES=70502;
integer MSGTYPE_WWCCURRENT=70503;
integer MSGTYPE_WWCLOCALSCLEAR=70600;
integer MSGTYPE_WWCLOCALS=70601;

integer EMAILSCRIPTCOUNT=2;  // change this number if you dont have 2 email scripts
integer    currentEmailScript=0;
integer    wwcCruiseHandle=0;
integer    wwcRaceHandle=0;
integer       dialogHandle=0;
integer    dialogChannel=2905;
integer    wwcCruiseChannel=0;
integer    wwcRaceChannel=0;
key        helmsman;
key        crew1;
key        crew2;
key        crew3;
integer    wwcLocked=0;
integer    askSailModeAsap=0;

// variables WWC setter
integer    wwcId=0;
integer    wwcParametersReceived=0;
integer    wwcRaceId=0;
float    wwcWndDir=0;
float    wwcWndSpeed=8.5;
float    wwcWndGusts=0;
float    wwcWndShifts=0;
float    wwcWndChangeRate=10.0;
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
integer  wwcSailMode=-1;
integer  wwcCrewSize=0;
string   wwcRcName="";
string   wwcRcClass="";
string   wwcRcVersion="";
string   wwcRcExtra1="";
string   wwcRcExtra2="";
float    wwcWaterDepth=10.0;
float   wwcSpeedMultiplier=1.5;
list     wwcLocalFluctuations=[];
key        wwcSetter;
string    wwcEmailExpected="";

// operational variables
integer receivedRaceId=0;
float    emailTimeOut=0;
float   dialogTimeOut=0;
float    raceTimeOut=0;
integer hasSubscribedToRace=0;
integer ignoreRaces=0;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Cruise secret channel:                                                                                       //
integer cruiseChannel() {                                                                                      //
    string date=llGetDate(); // format 2008-09-16                                                              //
    list dl=llParseString2List(date,["-"],[]);                                                                 //
    string a=(string)((llList2Integer(dl,2)*2389)+(llList2Integer(dl,1)*62790)+(llList2Integer(dl,0)*94979));  //
    integer b=-(integer)llGetSubString((string)a,(llStringLength(a)-8),-1);                                    //
    return b;                                                                                                  //
}                                                                                                              //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Race secret channel:                                                                                         //
integer raceChannel() {                                                                                        //
    string date=llGetDate(); // format 2008-09-16                                                              //
    list dl=llParseString2List(date,["-"],[]);                                                                 //
    string a=(string)((llList2Integer(dl,2)*9835)+(llList2Integer(dl,1)*68964)+(llList2Integer(dl,0)*17643));  //
    integer b=-(integer)llGetSubString((string)a,(llStringLength(a)-8),-1);                                    //
    return b;                                                                                                  //
}                                                                                                              //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

init()
{
    resetVars();    
    llSetTimerEvent(TIMERINTERVAL);
    llGetNextEmail("", "");  // to empty the queue
    helmsman = NULL_KEY;   // this is set to the helmsman upon sitting down
    crew1=NULL_KEY;   // same here for crewmembers
    crew2=NULL_KEY;
    crew3=NULL_KEY;
    receivedRaceId=0;
    emailTimeOut=0;
    dialogTimeOut=0;
    raceTimeOut=0;
    hasSubscribedToRace=0;
    wwcLocked=0;
    llSetText("",<1,1,1>,1.0);  // code for testing only
//    llOwnerSay("key:"+(string)llGetKey());
    llOwnerSay(llGetScriptName()+" ready ("+(string)llGetFreeMemory()+" free)");
}

resetVars() {
    wwcId=0;
    wwcParametersReceived=0;
    wwcWndDir=0;
    wwcWndSpeed=8.5;
    wwcWndGusts=0;
    wwcWndShifts=0;
    wwcWndChangeRate=1;
    wwcWndSystem="";
    wwcWaveHeight=0.5;
    wwcWaveLength=15;
    wwcWaveSpeed=5;
    wwcWaveHeightVariance=0.5;
    wwcWaveLengthVariance=0.2;
    wwcWaveOriginX = 0;
    wwcWaveOriginY = 0;
    wwcWaveSystem="";
    wwcCrntDir=0;
    wwcCrntSpeed=0;
    wwcCrntSystem="";
    wwcLocalFluctuations=[];
    wwcSailMode=-1;
    wwcCrewSize=0;
    wwcRcName="";
    wwcRcClass="";
    wwcRcVersion="";
    wwcRcExtra1="";
    wwcRcExtra2="";
    wwcRaceId=0;
    wwcWaterDepth=10.0;
    wwcSpeedMultiplier=1.5;
    wwcEmailExpected="";
}

integer realAngle2LslAngle(integer realAngle) {
    integer lslAngle= (realAngle-90)*-1;
    while(lslAngle>=360) lslAngle-=360;
    while(lslAngle<0) lslAngle+=360;
    return lslAngle;
}
integer lslAngle2RealAngle(integer lslAngle) {
    integer realAngle= (lslAngle-90)*-1;
    while(realAngle>=360) realAngle-=360;
    while(realAngle<0) realAngle+=360;
    return realAngle;
}

readWwcRow(string messageType, list row) {
//        llOwnerSay("readRow:"+(string)llGetListLength(row)+" "+messageType+" "+llList2CSV(row));
    if((messageType=="CrWnd" || messageType=="RcWnd") && llGetListLength(row)>=6) {
        wwcWndDir=llList2Integer(row,0);
        wwcWndSpeed=llList2Float(row,1);
        wwcWndGusts=llList2Float(row,2);
        wwcWndShifts=llList2Integer(row,3);
        wwcWndChangeRate=llList2Float(row,4);
        wwcWndSystem=llList2String(row,5);
        wwcSpeedMultiplier=llList2Float(row,6);
    } else if((messageType=="CrWav" || messageType=="RcWav") && llGetListLength(row)>=8) {
        wwcWaveHeight=llList2Float(row,0);
        wwcWaveLength=llList2Float(row,1);
        wwcWaveSpeed=llList2Float(row,2);
        wwcWaveHeightVariance=llList2Float(row,3);
        wwcWaveLengthVariance=llList2Float(row,4);
        wwcWaveOriginX=llList2Float(row,5);
        wwcWaveOriginY=llList2Float(row,6);
        wwcWaterDepth=llList2Float(row,7);
        wwcWaveSystem=llList2String(row,8);
    } else if((messageType=="CrCrt" || messageType=="RcCrt") && llGetListLength(row)>=3) {
        wwcCrntDir=llList2Float(row,0);
        wwcCrntSpeed=llList2Float(row,1);
        wwcWaterDepth=llList2Float(row,2);
        wwcCrntSystem=llList2String(row,3);
    } else if(messageType=="Rc") {
        wwcRcName=llList2String(row,0);
        wwcRcClass=llList2String(row,1);
        wwcRcVersion=llList2String(row,2);
        wwcCrewSize=llList2Integer(row,3);
        wwcSailMode=llList2Integer(row,4);
        wwcRcExtra1=llList2String(row,5);
        wwcRcExtra2=llList2String(row,6);
    } else if((messageType=="CrWwcLoc" || messageType=="RcWwcLoc") && llGetListLength(row)==9) {
        integer    rowOK=1;
        integer radius100=llList2Integer(row,2);
        integer radius0=llList2Integer(row,3);
        float windSpeedMultiplier=(llList2Float(row,4)/100.0)+1.0;
        integer extraWindAngle=llList2Integer(row,5);
        float waveHeightMultiplier=(llList2Float(row,6)/100.0)+1.0;
        float currentSpeedMultiplier=(llList2Float(row,7)/100.0)+1.0;
        integer extraCurrentAngle=llList2Integer(row,8);
        if(radius100<0) rowOK=0;
        if(radius100>200) rowOK=0;
        if(radius0<radius100) rowOK=0;
        if(radius0>255) rowOK=0;
        if(windSpeedMultiplier<0.0) rowOK=0;
        if(windSpeedMultiplier>3.0) rowOK=0;
        if(waveHeightMultiplier<0.0) rowOK=0;
        if(waveHeightMultiplier>3.0) rowOK=0;
        if(currentSpeedMultiplier<0.0) rowOK=0;
        if(currentSpeedMultiplier>3.0) rowOK=0;
        if(extraWindAngle<-180) rowOK=0;
        if(extraWindAngle>180) rowOK=0;
        if(extraCurrentAngle<-180) rowOK=0;
        if(extraCurrentAngle>180) rowOK=0;
        if(rowOK) {
            wwcLocalFluctuations+=llList2List(row,0,3);
            wwcLocalFluctuations+=windSpeedMultiplier;
            wwcLocalFluctuations+=extraWindAngle;
            wwcLocalFluctuations+=waveHeightMultiplier;
            wwcLocalFluctuations+=currentSpeedMultiplier;
            wwcLocalFluctuations+=extraCurrentAngle;
        }
    }
}

limitAllValuesWithinNormalRange() {
    while(wwcWndDir>=360.0) wwcWndDir-=360.0;
    while(wwcWndDir<0.0) wwcWndDir+=360.0;
    if(wwcWndSpeed>15.0) wwcWndSpeed=15.0;
    if(wwcWndSpeed<1.0) wwcWndSpeed=1.0;
    if(wwcWndGusts>1.0) wwcWndGusts=1.0;
    if(wwcWndGusts<0.0) wwcWndGusts=0.0;
    if(wwcWndShifts>180.0) wwcWndShifts=180.0;
    if(wwcWndShifts<0.0) wwcWndShifts=0.0;
    if(wwcWndChangeRate>5.0) wwcWndChangeRate=5.0;
    if(wwcWndChangeRate<0.1) wwcWndChangeRate=0.1;

    if(wwcWaveHeight>5.0) wwcWaveHeight=5.0;
    if(wwcWaveHeight<0.0) wwcWaveHeight=0.0;
    if(wwcWaveLength>100.0) wwcWaveLength=100.0;
    if(wwcWaveLength<10.0) wwcWaveLength=10.0;
    if(wwcWaveSpeed>15.0) wwcWaveSpeed=15.0;
    if(wwcWaveSpeed<3.0) wwcWaveSpeed=3.0;
    if(wwcWaveHeightVariance>2.0) wwcWaveHeightVariance=2.0;
    if(wwcWaveHeightVariance<0.0) wwcWaveHeightVariance=0.0;
    if(wwcWaveLengthVariance>0.75) wwcWaveLengthVariance=0.75;
    if(wwcWaveLengthVariance<0.0) wwcWaveLengthVariance=0.0;
    if(wwcSpeedMultiplier>2.0) wwcSpeedMultiplier=2.0;
    if(wwcSpeedMultiplier<1.0) wwcSpeedMultiplier=1.0;


    while(wwcCrntDir>=360.0) wwcCrntDir-=360.0;
    while(wwcCrntDir<0.0) wwcCrntDir+=360.0;
    if(wwcCrntSpeed>3.0) wwcCrntSpeed=3.0;
    if(wwcCrntSpeed<0.0) wwcCrntSpeed=0.0;

    if(wwcSailMode>3) wwcSailMode=3;

    if(wwcCrewSize>10) wwcCrewSize=10;
    if(wwcCrewSize<0) wwcCrewSize=0;

    if(wwcCrewSize>10) wwcCrewSize=10;
    if(wwcCrewSize<0) wwcCrewSize=0;

    if(wwcWaterDepth<5.0) wwcWaterDepth=5.0;
}

askSailMode() {
    if(dialogHandle) llListenRemove(dialogHandle);
    dialogHandle=llListen(dialogChannel,"",helmsman,"");
    dialogTimeOut=0; 
    llDialog(helmsman, "Wind parameters received.\nwind speed: "+llGetSubString((string)(wwcWndSpeed*ms2knots),0,3)+" kts.\nwave height: "+llGetSubString((string)wwcWaveHeight,0,2)+" m. \ncurrent: "+llGetSubString((string)(wwcCrntSpeed*ms2knots),0,2)+" kts.\nPlease select your settings. (see \"instructions\" for details)", ["novice", "competition", "expert", "fun mode"], dialogChannel);\
    askSailModeAsap=0;
}

askLock() {
    if(dialogHandle) llListenRemove(dialogHandle);
    dialogHandle=llListen(dialogChannel,"",helmsman,"");
    dialogTimeOut=0; 
    llDialog(helmsman, "Do you want to lock these settings or keep receiving new settings?\nwind speed: "+llGetSubString((string)(wwcWndSpeed*ms2knots),0,3)+" kts.\nwave height: "+llGetSubString((string)wwcWaveHeight,0,2)+" m. \ncurrent: "+llGetSubString((string)(wwcCrntSpeed*ms2knots),0,2)+" kts.", ["lock", "don't lock"], dialogChannel);
}

passWwcInfoToAllScripts() {
    integer    i;
    integer     sendSailMode=wwcSailMode;
    if(sendSailMode<0) sendSailMode=0;
    llMessageLinked(LINK_SET, MSGTYPE_WWCRACE,
        (string)((integer)wwcRaceId)+","+
        wwcRcName+","+
        (string)((integer)sendSailMode)+","+
        (string)((integer)wwcCrewSize)+","+
        wwcRcVersion+","+
        wwcRcExtra1+","+
        wwcRcExtra2, NULL_KEY);
//llOwnerSay("sendwwcSailMode:"+(string)wwcSailMode);
    llMessageLinked(LINK_SET, MSGTYPE_WWCWIND,
        (string)((integer)wwcWndDir)+","+
        llGetSubString((string)wwcWndSpeed,0,3)+","+
        llGetSubString((string)wwcWndGusts,0,3)+","+
        (string)((integer)wwcWndShifts)+","+
        llGetSubString((string)wwcWndChangeRate,0,3)+","+
        wwcWndSystem+","+
        llGetSubString((string)wwcSpeedMultiplier,0,3),NULL_KEY);

    llMessageLinked(LINK_SET, MSGTYPE_WWCWAVES,
        llGetSubString((string)wwcWaveHeight,0,3)+","+
        (string)((integer)wwcWaveLength)+","+
        llGetSubString((string)wwcWaveSpeed,0,3)+","+
        llGetSubString((string)wwcWaveHeightVariance,0,3)+","+
        llGetSubString((string)wwcWaveLengthVariance,0,3)+","+
        (string)((integer)wwcWaveOriginX)+","+
        (string)((integer)wwcWaveOriginY)+","+
        llGetSubString((string)wwcWaterDepth,0,3)+","+
        wwcWaveSystem,NULL_KEY);
        
    llMessageLinked(LINK_SET, MSGTYPE_WWCCURRENT,
        (string)((integer)wwcCrntDir)+","+
        llGetSubString((string)wwcCrntSpeed,0,3)+","+
        llGetSubString((string)wwcWaterDepth,0,3)+","+
        wwcCrntSystem,NULL_KEY);
    
    llMessageLinked(LINK_SET, MSGTYPE_WWCLOCALSCLEAR,"",NULL_KEY);

//llOwnerSay("llGetListLength(wwcLocalFluctuations):"+(string)llGetListLength(wwcLocalFluctuations));
    for(i=0;i<llGetListLength(wwcLocalFluctuations);i+=9) {
        llMessageLinked(LINK_SET, MSGTYPE_WWCLOCALS, llList2CSV(llList2List(wwcLocalFluctuations,i,i+8)), NULL_KEY);
    }
}


default
{
    state_entry()
    {
        init();
    }

//    touch_start(integer i) {
//            wwcEmailExpected="";
//            wwcParametersReceived=0;
//            wwcId=0;
//    }
    
    link_message(integer sender_num, integer num, string str, key id)
    {
        if(num==MSGTYPE_GETNEWWWC) {
            wwcEmailExpected="";
            wwcParametersReceived=0;
            wwcId=0;
            wwcLocked=0;
            ignoreRaces=0;
            llSetTimerEvent(TIMERINTERVAL);
        } else if(num==MSGTYPE_CREWSEATED) {
            helmsman=id;
            if(helmsman) {
                wwcEmailExpected="";
                wwcParametersReceived=0;
                if(dialogHandle) llListenRemove(dialogHandle);
                dialogHandle=0;
                wwcId=0;
                wwcLocked=0;
                ignoreRaces=0;
                llSetTimerEvent(TIMERINTERVAL);
                llGetNextEmail("", "");  // clear queue
                wwcCruiseChannel=cruiseChannel();
                wwcCruiseHandle=llListen(wwcCruiseChannel,"",NULL_KEY,"");
                wwcRaceChannel=raceChannel();
                wwcRaceHandle=llListen(wwcRaceChannel,"",NULL_KEY,"");
            } else {
                llSetTimerEvent(0.0);
                if(wwcRaceHandle>0)llListenRemove(wwcRaceHandle);
                if(wwcCruiseHandle>0) llListenRemove(wwcCruiseHandle);
                wwcRaceHandle=0;
                wwcCruiseHandle=0;
            }
           // llOwnerSay("helmsman:"+(string)helmsman);
        } else if(num==MSGTYPE_CREWSEATED+1) {
            crew1=id;
//            llOwnerSay("crew1:"+(string)crew1);
        } else if(num==MSGTYPE_CREWSEATED+2) {
            crew2=id;
        } else if(num==MSGTYPE_CREWSEATED+3) {
            crew3=id;
        } else if (num==MSGTYPE_SCRIPTCHECK) {
            llMessageLinked(LINK_ROOT, MSGTYPE_SCRIPTCHECK+1, llSHA1String(secretScriptKey+str),NULL_KEY);
        }
    }

    listen(integer channel, string name, key id, string msg) {
//        llOwnerSay("received:"+msg +" on:"+(string)channel+" wwcLocked:"+(string)wwcLocked+" wwcParametersReceived:"+(string)wwcParametersReceived+" wwcId:"+(string)wwcId);
        if(channel==wwcRaceChannel && wwcParametersReceived<=2 && wwcRaceChannel!=0) {
            list raceNot=llCSV2List(msg);
            if (llList2String(raceNot,0)=="Rc" && llGetListLength(raceNot)>=7) {
                string className=llToLower(llList2String(raceNot,3));
                if(llStringLength(className)<=2 || className=="all" || className==THISCLASSNAME) {
                    integer    crewSize=llList2Integer(raceNot,5);
                    integer actualCrewSize=1;
                    if(crew1) actualCrewSize++;
                    if(crew2) actualCrewSize++;
                    if(crew3) actualCrewSize++;
                    if(crewSize<=0 || actualCrewSize==crewSize) {
                        if(helmsman) {
                            string    raceDirector = llList2String(raceNot,6);
                            string    raceName=llList2String(raceNot,2);
                            string    className=llList2String(raceNot,3);
                            integer    sailMode=llList2Integer(raceNot,4);
                            string    dialog = "Do you wish to subscribe to ";
                            if(llStringLength(raceName)>0) dialog = dialog + raceName;
                            else dialog = dialog + "the race";
                            if(llStringLength(className)>0) dialog = dialog + " for " + className+"?\n";
                            else dialog = dialog + "?\n";
                            if(llStringLength(raceDirector)>0) dialog = dialog + "Hosted by " + raceDirector+ "\n";
                            if(sailMode==1) dialog = dialog + "Novice mode";
                            else if(sailMode==2) dialog = dialog + "Competition mode ";
                            else if(sailMode==3) dialog = dialog + "Expert mode ";
                            if(crewSize>0) dialog = dialog + (string)crewSize+" persons";
                            llDialog(helmsman, dialog, ["Yes", "No"], wwcRaceChannel);
                            dialogTimeOut=0;
                            receivedRaceId=llList2Integer(raceNot,1);
                            wwcSetter=id;
                            wwcParametersReceived+=100;  // this is only temporary to hold any other incoming messages (see timer for timeout)
                            askSailModeAsap=0;
                        }
                    }
                }
            }
        } else if(channel==wwcRaceChannel && id==helmsman) {  // dialog response
//        llOwnerSay("received:"+msg +" on:"+(string)channel);
            if(msg=="Yes") {
                llMessageLinked(LINK_THIS, (MSGTYPE_SENDRCWWCREQ*100)+currentEmailScript, "RcWwcReq,"+(string)receivedRaceId, wwcSetter);
                currentEmailScript++;
                if(currentEmailScript>=EMAILSCRIPTCOUNT) currentEmailScript=0;
           //     llEmail((string)wwcSetter+"@lsl.secondlife.com","RcWwcReq","RcWwcReq,"+(string)receivedRaceId);
                llWhisper(0,"waiting for race parameters...");
                wwcParametersReceived=3;
                wwcEmailExpected="RcWwc";
                emailTimeOut=0;
                wwcLocalFluctuations=[];
                wwcSailMode=0;  // 0 = dont ask for sailmode
                wwcCrewSize=0;
                wwcRcName="";
                wwcRcClass="";
                wwcRaceId=receivedRaceId;
                raceTimeOut=0;
                hasSubscribedToRace=0;
                llListenRemove(wwcRaceHandle);
                if(wwcCruiseHandle>0) llListenRemove(wwcCruiseHandle);
                wwcRaceHandle=0;
                wwcCruiseHandle=0;
                askSailModeAsap=0;
            } else if(msg=="No") {
                wwcParametersReceived-=100;  // set it back to the original value
                llListenRemove(wwcRaceHandle);
                wwcRaceHandle=0;
                wwcCrewSize=0;
                if(wwcSailMode==0) wwcSailMode=-1;  // 0 = ask for sailmode
                askSailModeAsap=1;
                ignoreRaces=1;
            } else {
                wwcParametersReceived-=100;  // set it back to the original value
                if(wwcSailMode==0) wwcSailMode=-1;  // 0 = dont ask for sailmode
            }
        } else if(channel==wwcCruiseChannel && (wwcParametersReceived<=1 || (wwcParametersReceived==2 && wwcLocked==0)) && wwcCruiseChannel!=0) {
            list not=llCSV2List(msg);
            if (llList2String(not,0)=="WwcSetter" && llList2Integer(not,1)!=wwcId) {
                wwcId=llList2Integer(not,1);
    //        llOwnerSay("received:"+msg +" on:"+(string)channel);
                wwcSetter=id;
                llMessageLinked(LINK_THIS, (MSGTYPE_SENDCRWWCREQ*100)+currentEmailScript, "", wwcSetter);
                currentEmailScript++;
                if(currentEmailScript>=EMAILSCRIPTCOUNT) currentEmailScript=0;
     //           llEmail((string)wwcSetter+"@lsl.secondlife.com","CrWwcReq","");
                wwcParametersReceived=2;
                wwcEmailExpected="CrWwc";
                emailTimeOut=0;
                wwcLocalFluctuations=[];
                wwcSailMode=-1;
                wwcCrewSize=0;
                wwcRcName="";
                wwcRcClass="";
                wwcRaceId=0;
                llListenRemove(wwcCruiseHandle);
                wwcCruiseHandle=0;
                askSailModeAsap=1;
            }
        } else if(channel==dialogChannel) {
            if(msg=="novice") wwcSailMode=1;
            else if(msg=="competition")    wwcSailMode=2;
            else if(msg=="expert") wwcSailMode=3;
            else if(msg=="fun mode") wwcSailMode=0;
            else if(msg=="lock") {
                wwcLocked=1;
                passWwcInfoToAllScripts();
                return;
            } else {
                wwcLocked=0;
                passWwcInfoToAllScripts();
                return;
            }
            askLock();
        }
     }

    timer() {
        if(wwcRaceHandle>0 && wwcParametersReceived>=100) {
            dialogTimeOut+=TIMERINTERVAL;
            if(dialogTimeOut>DIALOGTIMEOUT) {
                llListenRemove(wwcRaceHandle);
                wwcRaceHandle=0;
                wwcParametersReceived-=100;  // set it back to the original value
            }
        }
        if(dialogHandle>0) {
            dialogTimeOut+=TIMERINTERVAL;
            if(dialogTimeOut>DIALOGTIMEOUT) {
                llListenRemove(dialogHandle);
                dialogHandle=0;
                // passWwcInfoToAllScripts();
            }
        }
        
        if(wwcRaceId<=0 && llStringLength(wwcEmailExpected)>0) {
            emailTimeOut+=TIMERINTERVAL;
            if(emailTimeOut>EMAILTIMEOUT) {
                if(wwcRaceId<=0) wwcEmailExpected="";
            }
        }
        
        if(wwcRaceId>0) {
            raceTimeOut+=TIMERINTERVAL;
            if(raceTimeOut>RACETIMEOUT) {
                wwcEmailExpected="";
                wwcRaceId=0;
                hasSubscribedToRace=0;
                llListenRemove(wwcRaceHandle);
            }
        }

       // llOwnerSay(wwcEmailExpected +" from "+(string)wwcSetter);
        if(llStringLength(wwcEmailExpected)>0) {
            llGetNextEmail((string)wwcSetter+"@lsl.secondlife.com", wwcEmailExpected);
        } else if(askSailModeAsap>0 && wwcSailMode<0) askSailMode();
    }
 
    email(string time, string address, string subj, string message, integer num_left) {
//        llOwnerSay("receiver email from:"+address +" subject:"+subj+" body:"+message);
        if(subj==wwcEmailExpected) {
            if(subj=="CrWwc") {
                list rows=llParseString2List(message,["\n"],[""]);
                integer    r=0;
                for(r=0;r<llGetListLength(rows);r++) {
                    list    row = llParseString2List(llList2String(rows,r),[", ",","],[""]);
                    string    messageType = llList2String(row,0);
                    readWwcRow(messageType,llList2List(row,1,-1));
                }
                wwcEmailExpected="";
                limitAllValuesWithinNormalRange();
                if(wwcWndSpeed>=9.0) llSay(0,"This windspeed is very strong. It is recommended to use windspeeds of 10-15 knots. (5-8 m/s)");
           }
            if(subj=="RcWwc") {
                list rows=llParseString2List(message,["\n"],[""]);
                integer    r=0;
                string    rcSubMessage;
                for(r=0;r<llGetListLength(rows);r++) {
                    list    row = llParseString2List(llList2String(rows,r),[", ",","],[""]);
                    string    messageType = llList2String(row,0);
                    integer    raceId = llList2Integer(row,1);
                    if(raceId==wwcRaceId) {
                        readWwcRow(messageType,llList2List(row,2,-1));
                    }
                }
                wwcEmailExpected="RcWwc";  // we keep listening for changes during the race
                limitAllValuesWithinNormalRange();
                passWwcInfoToAllScripts();
                raceTimeOut=0;
                if(hasSubscribedToRace<=0) {
                    hasSubscribedToRace=1;
                    rcSubMessage="RcSub,"+(string)receivedRaceId;
                    if(helmsman) rcSubMessage = rcSubMessage+","+llKey2Name(helmsman);
                    if(crew1) rcSubMessage = rcSubMessage+","+llKey2Name(crew1);
                    if(crew2) rcSubMessage = rcSubMessage+","+llKey2Name(crew2);
                    if(crew3) rcSubMessage = rcSubMessage+","+llKey2Name(crew3);
                    llMessageLinked(LINK_THIS, (MSGTYPE_SENDRCSUB*100)+currentEmailScript, rcSubMessage, wwcSetter);
                    currentEmailScript++;
                    if(currentEmailScript>=EMAILSCRIPTCOUNT) currentEmailScript=0;
 //                   llEmail((string)wwcSetter+"@lsl.secondlife.com","RcSub",rcSubMessage);
                }
            }
        }
        if(num_left>0) llGetNextEmail("", "");  // clear any spam messages to keep the queue empty for the real stuff
    }

}
