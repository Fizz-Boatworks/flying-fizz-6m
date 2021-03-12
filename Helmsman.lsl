// Crew script
// By Mothgirl Dibou Last change 2008/06/19
// By LaliaCasau jan2021 
// Put this in the root prim
//
//NO Settings for camera: "Camera" notecard and fixed settings for capsizes
//NO layout: <offset>, pitch, distance
//
//NO Settings for animations: "Animations" notecard
//NO layout: animationName, <offset>, <rotation>
//NO ordering: port trapeze, port hiking, sb hiking, sb trapeze
//
// Settings for moored animations: "Moored Animations" notecard
// layout: animationName, <offset>, <rotation>
//
//NO Settings for capsize animations: "Capsize Animations" notecard
//NO side (-1=port, 1=sb),animationName, <offset>, <rotation>, start at capsize heel (biggest heel first)
//
// Recognised chat commands on channel 0 or custom channel: 
//??? sheet (+ or - degrees), sheet (degrees)
//??? sail +, sail -  (change sail trim)
// camera (toggle through camera settings)
// tack or gybe or gibe                                 (lalia gybe)
// hike                                                 (lalia hike or hike+ and hike-)
//NO switch (select other sail to control)
//NO lock (boat can only be sailed by the owner
//NO unlock (boat can be sailed by anyone)
//
// Key controls: 
// Up/down (sheet +/- 1,4,5 degrees while sailing)
//??? Up/down (select sail to control when moored)
// PgUp (hike while sailing)                            (lalia shift arrows)
// PgDn (tack/gybe while sailing)                       (lalia shift arrows)
// PgUp/PgDn (change animation/pose when moored) 
// Left (steer left)
// Right (steer right)
//
// link messages send: 
//
// link messaged received:
// MODECHANGE, <newsailingState>
// CREWINFO, <poseCrew>, <hasCapsized>, <capsize heel>
// possible values for pose crew: -2 (port trapeze), -1 (port hiking), 0 (none), 1 (sb hiking), 2 (sb trapeze)

integer CREWID=0;    // change this for every crew member  0-Helm 1-Crew1 2-Crew2

//string secretScriptKey="JKLU97RW";
//integer MSGTYPE_SCRIPTCHECK=54350;
string boatName = "Flying Fizz";
string versionName = "6m";
key serverKey = "587f987d-d3e8-cfa9-8ffb-dad16c4a6b6a";
//string serverCode = "utf5ry3f7v9";
//channels and handles
integer HudComChannel=-29000;
integer HudChannel;
integer HudInChannel;
integer ChatChannel;
integer listenHandle;  //chat handle
integer listenComHandle;  //common handle
integer listenHudHandle;  //Hud handle


// constants
integer MSGTYPE_SETTINGS=1000;
integer MSGTYPE_MODECHANGE=50001;
integer MSGTYPE_SAILHANDLING=50002;
integer MSGTYPE_SETTINGSCHANGE=50003;
integer MSGTYPE_SETID=50004;
integer MSGTYPE_STEERING=55016;
integer MSGTYPE_SAILMODE=50017;
integer MSGTYPE_MOTORING=50018;
integer MSGTYPE_CREWINFO=50100;
integer MSGTYPE_CREWSEATED=70400; // 1-4 crewmembers 70400 = helmsman, 70401 = crew 1, 70402=crew2, 70403=crew 3, send avatar's UUID when seated and NULL_KEY when avatar has left
integer MSGTYPE_TACKING=50019;
integer MSGTYPE_GETNEWWWC=70001;
integer MSGTYPE_WWCRACE=70500;
integer MSGTYPE_COLOR=50030;
integer VEHICLE_SAILING=1;
integer VEHICLE_FLOATING=2;
integer VEHICLE_MOORED=0;

integer MSGTYPE_SAY = 51000;
integer MSGTYPE_WHISPER = 52000;
integer MSGTYPE_SHOUT = 53000;
integer MSGTYPE_SAYTO = 54000;

// variables read settings
//list    cameraList;   // <offset>, pitch, distance
list animationList=[];   // animationName, <offset>, <rotation> in fixed order (see poseCrew variable)
list mooredAnimationList=[];    //animationName, <offset>, <rotation>
list capsizeAnimationList=[];  // side, animationName, <offset>, <rotation>, start at capsize heel (biggest heel first)
list noseDiveAnimationList=[];
list cameraParams=[];

// operational variables
integer swRun;  //0 not ready   1 ready
integer sailingState=0;
integer cameraMode=0;
integer panoramaCam=0;
integer panoramaCounter=0;

integer sendExtraRudderNeutral=0;
integer regionChanged=0;
integer hasCapsized=0;
integer heel=0;

key     crew1Key=NULL_KEY;
key     crew2Key=NULL_KEY;
key     helmKey=NULL_KEY;
integer helmPose=0; // <possible values: -2 (port trapeze), -1 (port hiking), 0 (none), 1 (sb hiking), 2 (sb trapeze)>
integer mooredPose=0;
string  currentAnimation="";
vector  currentOffset=<0,0,0>;
rotation currentRotation=ZERO_ROTATION;


integer locked=1;
rotation    dockRotation=ZERO_ROTATION;
vector    dockPosition=<0,0,0>;
string    dockSim="";

integer    initCounter=0;
integer    noseDiveDelay=0;
integer    prevCapsized=0;
integer    prevKey=0;
integer prevHeld=0;
integer    steerDir=0;
integer    prevSteerDir=0; 
integer    sailMode=0;
integer shoutOn=0;

init()
{
    list      nameList = llParseString2List(llGetObjectName(), [" C@"], []);
    string    language=llGetSubString(llList2String(nameList,1),0,1);
 
    llSitTarget(<0,0,0.01>,ZERO_ROTATION);
//    cameraList=[];
    animationList=[];
    mooredAnimationList=[];
    capsizeAnimationList=[];
    noseDiveAnimationList=[];
    sailingState=0;
    cameraMode=0;
    panoramaCam=0;
    helmPose=0;
    mooredPose=0;
    hasCapsized=0;
    heel=0;
    helmKey=NULL_KEY;
    currentAnimation="";
    sailMode=0;
    llMessageLinked(LINK_SET, 0, "loadconf",NULL_KEY);    //load configuration
}

notecardRead(integer msgId, string str) {
    list in=llCSV2List(str);
    if(msgId==1) animationList=in;
    else if(msgId==2) mooredAnimationList=in;
    else if(msgId==3) capsizeAnimationList=in;
    else if(msgId==4) noseDiveAnimationList=in;
    else if(msgId==5) cameraParams=in;
    if(msgId==5){   //load settings finish
        llOwnerSay(llGetScriptName()+" ready ("+(string)llGetFreeMemory()+" free)");
        swRun=1;
        llMessageLinked(LINK_SET, MSGTYPE_SETTINGS,"hudchannel",(string)HudChannel); //Send the HUD channel to all scripts
    }
}

setAnimation() {
    if(helmKey) {
        string newAnimation="sit";
        vector newOffset=<0,0,0>;
        vector newRotation=<0,0,0>;
        if(sailingState!=VEHICLE_SAILING) {
            integer n=llGetListLength(mooredAnimationList)/3;  //moored animations number
            if(mooredPose>=n) cameraMode=n-1;
            if(mooredPose<n) {
                newAnimation=llList2String(mooredAnimationList,(mooredPose*3));
                newOffset=(vector)llList2String(mooredAnimationList,((mooredPose*3)+1));
                newRotation=(vector)llList2String(mooredAnimationList,((mooredPose*3)+2));
            }
        } else if(hasCapsized==1) {
            integer i;
            integer n=llGetListLength(capsizeAnimationList)/4; 
            for(i=0;i<n;i++) {
                integer minHeel = llList2Integer(capsizeAnimationList,((i*4)+3));
                //llOwnerSay("heel:"+(string)heel+" minHeel:"+(string)minHeel);
                if((heel<=minHeel && heel>0) || (heel>=minHeel && heel<0)) {
                    newAnimation=llList2String(capsizeAnimationList,(i*4));
                    newOffset=(vector)llList2String(capsizeAnimationList,((i*4)+1));
                    newRotation=(vector)llList2String(capsizeAnimationList,((i*4)+2));
                    i=n;
                }
            }
            helmPose=0;
        } else if(hasCapsized==2 && --noseDiveDelay<=0) {  // nose diving
            integer i;
            integer n=llGetListLength(noseDiveAnimationList)/4;
            for(i=0;i<n;i++) {
                integer minHeel = llList2Integer(noseDiveAnimationList,((i*4)+3));
                //llOwnerSay("heel:"+(string)heel+" minHeel:"+(string)minHeel);
                if((heel<=minHeel && heel>0) || (heel>=minHeel && heel<0)) {
                    newAnimation=llList2String(noseDiveAnimationList,(i*4));
                    newOffset=(vector)llList2String(noseDiveAnimationList,((i*4)+1));
                    newRotation=(vector)llList2String(noseDiveAnimationList,((i*4)+2));
                    i=n;
                }
            }
            helmPose=0;
        } else {
            integer index=0;
            if(helmPose<=0) index=helmPose+3;
            else index=helmPose+2;
            if(helmPose==-3 || helmPose==3) currentAnimation="";
            //llOwnerSay("poseCrew:"+(string)poseCrew+" index:"+(string)index);
            newAnimation=llList2String(animationList,(index*3));
            newOffset=(vector)llList2String(animationList,((index*3)+1));
            newRotation=(vector)llList2String(animationList,((index*3)+2));
        }     
        //llOwnerSay("*mooredPose:"+(string)mooredPose+"   setAnimation:"+(string)newAnimation+" offset:"+(string)newOffset+" rot:"+(string)newRotation+" current:"+(string)currentAnimation);
//        if(currentAnimation!=newAnimation) {
        if(currentAnimation!=newAnimation && llGetInventoryType(newAnimation)==INVENTORY_ANIMATION) {
            if(llStringLength(currentAnimation)>0) llStopAnimation(currentAnimation);
            llStopAnimation("sit_generic");
            llStopAnimation("sit");
            llStartAnimation(newAnimation);
            currentAnimation=newAnimation;
            llSetLinkPrimitiveParamsFast(findLink(helmKey), [PRIM_POSITION,newOffset, PRIM_ROT_LOCAL, llEuler2Rot(newRotation*DEG_TO_RAD)]);
        }
    }
}

setCamera() {
    if(helmKey) {
        if(hasCapsized==1) {  // capsize cam
            llSetCameraParams([
                 CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
                 CAMERA_BEHINDNESS_ANGLE, 0.0, // (0 to 180) degrees
                 CAMERA_BEHINDNESS_LAG, 0.15, // (0 to 3) seconds
                 CAMERA_FOCUS_LAG, 0.0 , // (0 to 3) seconds
                 CAMERA_FOCUS_LOCKED, FALSE, // (TRUE or FALSE)
                 CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
                 CAMERA_POSITION_LAG, 0.0, // (0 to 3) seconds
                 CAMERA_POSITION_LOCKED, FALSE, // (TRUE or FALSE)
                 CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
                 CAMERA_DISTANCE, 5.0,
                 CAMERA_PITCH, 45.0,
                 CAMERA_FOCUS_OFFSET, <-1.5,0,0>
             ]);
        } else if(hasCapsized==2) {  // nose dive cam
            vector offset = <-5,5,3>;
            if(heel>0) offset = <-5,-5,3>;
            llSetCameraParams([
                 CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
                 CAMERA_BEHINDNESS_ANGLE, 0.0, // (0 to 180) degrees
                 CAMERA_BEHINDNESS_LAG, 0.1, // (0 to 3) seconds
                 CAMERA_FOCUS_LAG, 0.0 , // (0 to 3) seconds
                 CAMERA_FOCUS_LOCKED, FALSE, // (TRUE or FALSE)
                 CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
                 CAMERA_POSITION_LAG, 0.0, // (0 to 3) seconds
                 CAMERA_POSITION_LOCKED, FALSE, // (TRUE or FALSE)
                 CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
                 CAMERA_DISTANCE, 7.0,
                 CAMERA_PITCH, 20.0,
                 CAMERA_FOCUS_OFFSET, offset
             ]);
        } else if(sailingState!=VEHICLE_SAILING) {  // moored cam
            llSetCameraParams([
                 CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
                 CAMERA_BEHINDNESS_ANGLE, 0.0, // (0 to 180) degrees
                 CAMERA_BEHINDNESS_LAG, 0.15, // (0 to 3) seconds
                 CAMERA_FOCUS_LAG, 0.0 , // (0 to 3) seconds
                 CAMERA_FOCUS_LOCKED, FALSE, // (TRUE or FALSE)
                 CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
                 CAMERA_POSITION_LAG, 0.0, // (0 to 3) seconds
                 CAMERA_POSITION_LOCKED, FALSE, // (TRUE or FALSE)
                 CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
                 CAMERA_DISTANCE, llList2Float(cameraParams,2),
                 CAMERA_PITCH, llList2Float(cameraParams,1),
                 CAMERA_FOCUS_OFFSET, (vector)llList2String(cameraParams,0)
             ]);
        } else if(panoramaCam>0) {
            llSetCameraParams([
                 CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
                 CAMERA_BEHINDNESS_ANGLE, 0.0, // (0 to 180) degrees
                 CAMERA_BEHINDNESS_LAG, 0.15, // (0 to 3) seconds
                 CAMERA_FOCUS_LAG, 0.0 , // (0 to 3) seconds
                 CAMERA_FOCUS_LOCKED, FALSE, // (TRUE or FALSE)
                 CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
                 CAMERA_POSITION_LAG, 0.0, // (0 to 3) seconds
                 CAMERA_POSITION_LOCKED, FALSE, // (TRUE or FALSE)
                 CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
                 CAMERA_DISTANCE, llList2Float(cameraParams,5),
                 CAMERA_PITCH, llList2Float(cameraParams,4),
                 CAMERA_FOCUS_OFFSET, (vector)llList2String(cameraParams,3)
                 ]);
        } else if(llGetListLength(cameraParams)>7) {
            llSetCameraParams([CAMERA_ACTIVE, 0]);
            if(llAvatarOnSitTarget()) llReleaseCamera(llAvatarOnSitTarget());
            llSetCameraEyeOffset(<-4.6,0,1.4>);  
            llSetCameraAtOffset(<-1,0,1.5>);
        }
    }
}

// Keys: Up/down (sheet, select sail to control when moored), PgUp (hike, switch moored pose), PgDn (tack), left (sail trim flat), right (sail trim round)
rotleft() {
    //llOwnerSay((string)sailingState+"    "+(string)VEHICLE_MOORED+"   "+(string)prevSteerDir+"    "+(string)steerDir);  //lalia
    if(sailingState!=VEHICLE_MOORED && prevSteerDir!=steerDir) {
        llMessageLinked(LINK_SET, MSGTYPE_STEERING, "1", NULL_KEY);     //message to engine
        prevSteerDir=steerDir;
    }
}
rotright() {
    if(sailingState!=VEHICLE_MOORED && prevSteerDir!=steerDir) {
        llMessageLinked(LINK_SET, MSGTYPE_STEERING, "-1", NULL_KEY);
        prevSteerDir=steerDir;
    }
}
neutral() {
    llMessageLinked(LINK_SET, MSGTYPE_STEERING, "0", NULL_KEY);
    prevSteerDir=0;
    steerDir=0;
}
up() {
    if(sailingState==VEHICLE_SAILING) {
        llMessageLinked(LINK_ROOT, MSGTYPE_SAILHANDLING, "sheet"+(string)CREWID+" 1", NULL_KEY);    //message to engine
    } else if(sailingState==VEHICLE_FLOATING) {
        llMessageLinked(LINK_ROOT, MSGTYPE_MOTORING, "1", NULL_KEY);
    }
}
down() {
    if(sailingState==VEHICLE_SAILING) {
        llMessageLinked(LINK_ROOT, MSGTYPE_SAILHANDLING, "sheet"+(string)CREWID+" -1", NULL_KEY);     //message to engine
    } else if(sailingState==VEHICLE_FLOATING) {
        llMessageLinked(LINK_ROOT, MSGTYPE_MOTORING, "-1", NULL_KEY);
    }
}
pgup() {
    if(sailingState==VEHICLE_SAILING) {
        llMessageLinked(LINK_ROOT, MSGTYPE_SAILHANDLING, "sail"+(string)CREWID+" -1", NULL_KEY);    //message to engine
    }
}
pgdn() {
    if(sailingState==VEHICLE_SAILING) {
        llMessageLinked(LINK_ROOT, MSGTYPE_SAILHANDLING, "sail"+(string)CREWID+" 1", NULL_KEY);     //message to engine
    }
}
left() {
    if(sailingState!=VEHICLE_SAILING) {  // moored
        mooredPose--;
        if(mooredPose<0) mooredPose= (llGetListLength(mooredAnimationList)/3)-1;
         //llMessageLinked(LINK_ROOT, MSGTYPE_TACKING, "change pose crew"+(string)CREWID+" "+(string)mooredPose, avatar);
    } else {
        if(sailMode<2) {  //fun mode and beginner mode
            sendExtraRudderNeutral=0;
            steerDir=1;
            rotleft();
            return;
        } else {
            helmPose--;   //helm pose -2, -1, 1, 2
            if(helmPose==0) helmPose=-1;
            else if(helmPose<-2) helmPose=-2;
            //llMessageLinked(LINK_ROOT, MSGTYPE_TACKING, "hike"+(string)CREWID+" "+(string)helmPose, avatar);
        }
    }
    setAnimation();
    //**if(llAvatarOnSitTarget()) llRequestPermissions(llAvatarOnSitTarget(), PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_CONTROL_CAMERA);
}
right() {
    if(sailingState!=VEHICLE_SAILING) {  // moored
        mooredPose++;
        if(mooredPose>=(llGetListLength(mooredAnimationList)/3)) mooredPose=0;
        //llMessageLinked(LINK_ROOT, MSGTYPE_TACKING, "change pose crew"+(string)CREWID+" "+(string)mooredPose, avatar);
    } else {
        if(sailMode<2) {
            sendExtraRudderNeutral=0;
            steerDir=-1;
            rotright();
            return;
        } else {      
            helmPose++;    //helm pose -2, -1, 1, 2
            if(helmPose==0) helmPose=1;
            if(helmPose>2) helmPose=2;
            //llMessageLinked(LINK_ROOT, MSGTYPE_TACKING, "hike"+(string)CREWID+" "+(string)helmPose, avatar);
        }
    }
    setAnimation();
    //**if(llAvatarOnSitTarget()) llRequestPermissions(llAvatarOnSitTarget(), PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_CONTROL_CAMERA);
}

setNewSailMode(integer newsailingState) {
    if(newsailingState!=sailingState) {
        sailingState=newsailingState;
        panoramaCounter=0;
        if(sailingState!=VEHICLE_SAILING){
            hasCapsized=0;
            heel=0;
            helmPose=1;
        }
        llMessageLinked(LINK_SET,MSGTYPE_MODECHANGE,(string)sailingState,NULL_KEY);
        setAnimation();
    }
}

string getInitials() {
    string initials;
    list    nameList = llParseString2List(llToUpper(llKey2Name(helmKey)), [" "], []);
    string    validChars = "ABCDEFGHIJKLMNOPQRSTUVWZXYZ";
    string char = llGetSubString(llList2String(nameList,0),0,0);
    if(llSubStringIndex(validChars, char)<0) initials="A";
    else initials=char;
    char = llGetSubString(llList2String(nameList,1),0,0);
    if(llSubStringIndex(validChars, char)<0) initials=initials+"A";
    else initials=initials+char;
    return initials;
}

setBoatID(string pid) {
    string bName=llGetObjectName();
    string bID="";
    integer n=llSubStringIndex(bName,"#");
    if(n>0){
        bName=llStringTrim(llGetSubString(bName,0,n-1),STRING_TRIM);
        bID=llStringTrim(llGetSubString(bName,n+1,n+8),STRING_TRIM);
    }else if(n==0){
        bName=boatName;
        bID=llGetSubString(bName,1,-1);
    }
    if(llGetSubString(pid,0,0)=="#") pid=llGetSubString(pid,1,8); 
    pid=llStringTrim(pid,STRING_TRIM); 
    if(pid==""){
        if(bID==""){
            integer nr=(integer)llFrand(999.0);
            bID=getInitials()+llGetSubString("00"+(string)nr,-3,-1);
        }
    }else{
        bID=llGetSubString(pid,0,7);
    }
    llSetObjectName(bName+" #"+(string)bID);
    llMessageLinked(LINK_ROOT, MSGTYPE_SAYTO, "7", (string)helmKey+bID);  // Boat id set to
}

sitHelm(key k)
{
    if(!swRun){
        llUnSit(k);
        llRegionSayTo(k,0,"Flying Fizz is not ready");
        return;
    }
    
    helmKey=k;
    cameraMode=0;
    llMessageLinked(LINK_SET, MSGTYPE_CREWSEATED+CREWID, "", helmKey);
    helmPose=0;
    mooredPose=0;
    hasCapsized=0;
    heel=0;
    currentAnimation="";
    llRequestPermissions(helmKey, PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_CONTROL_CAMERA);
    // immediately make the boat physical
    setNewSailMode(VEHICLE_FLOATING);
    llListenRemove(listenHandle);
    listenHandle=llListen(ChatChannel,"",helmKey,"");
//  getWindParams(); later er weer in als samengevoegd wordt
    llMessageLinked(LINK_THIS, MSGTYPE_SAYTO, "47", helmKey);  // show little help info
    llMessageLinked(LINK_THIS, MSGTYPE_SAYTO, "48", helmKey);  // show little help info
    llWhisper(HudComChannel,"sit,"+(string)helmKey+","+(string)HudChannel);   //send hudchannel to hud
    llSetTimerEvent(1.0);
}

unsitHelm()
{
    //if(helmKey==llGetOwner()) llPushObject(helmKey, <5,0,10>,<0,0,0>,TRUE);  // only works for the owner
    if(helmKey == llGetPermissionsKey()) // right user?
        if(llGetPermissions() & PERMISSION_TRIGGER_ANIMATION) // got permissions?
            if(llStringLength(currentAnimation)>0) llStopAnimation(currentAnimation);
    //     llSetStatus(STATUS_PHANTOM,TRUE);  // to enable the crew member to get away from the boat and not be trapped between invisible prims
    llMessageLinked(LINK_THIS, MSGTYPE_CREWSEATED+CREWID, "", NULL_KEY);
    cameraMode=0;
    helmPose=0;
    mooredPose=0;
    llListenRemove(listenHandle);
    llWhisper(HudComChannel,"unsit,"+(string)helmKey+","+(string)HudChannel);   //call hud
    setNewSailMode(VEHICLE_MOORED);
    llMessageLinked(LINK_THIS,MSGTYPE_MODECHANGE,(string)sailingState,NULL_KEY); // redo it as sometimes not all parts understood it the first time
    helmKey = NULL_KEY;
}

hike(integer mode)
{
    if(sailingState!=VEHICLE_SAILING) {  // moored
        if(mode>0){
            mooredPose++;
            if(mooredPose>=llGetListLength(mooredAnimationList)/3) mooredPose=0;
        }else{
            mooredPose--;
            if(mooredPose<0) mooredPose=(llGetListLength(mooredAnimationList)/3)-1;
        }
        setAnimation();
    }else{
    }
}

integer findLink(key k)
{
    if(k){
        if(llGetAgentSize(k)){
            integer n=llGetObjectPrimCount(llGetKey())+1;
            integer max = llGetNumberOfPrims();
            for(n=n;n<=max;n++) if(k==llGetLinkKey(n)) return(n);
            return(0);
        }
    }
    return(0);
}

default
{
    on_rez(integer param)
    {
        llResetScript();
    }

    state_entry()
    {
        llSetStatus( STATUS_PHYSICS | STATUS_BLOCK_GRAB | STATUS_BLOCK_GRAB_OBJECT, FALSE);
        integer i;
        integer n;
        n=llGetInventoryNumber(INVENTORY_SCRIPT);
        for(i=0;i<n;i++){ 
            if(llGetInventoryName(INVENTORY_SCRIPT,i)!=llGetScriptName()) llResetOtherScript(llGetInventoryName(INVENTORY_SCRIPT,i));
        }
        llSleep(0.1);
        HudChannel= -3 -(integer)("0x" + llGetSubString( (string)llGetKey(), -7, -1) );
        HudInChannel=HudChannel-1;
        ChatChannel=0;
        llListenRemove(HudInChannel);
        listenHudHandle=llListen(HudInChannel,"","","");
        llListenRemove(HudComChannel);
        listenComHandle=llListen(HudComChannel,"","","");
        init();
    }

    touch_start(integer total_number)
    {
        if(helmKey) {
            if(llDetectedKey(0)!=helmKey) {
                llSay(0,llKey2Name(llDetectedKey(0))+" clicked "+llKey2Name(helmKey)+"'s boat");
            }
        }
    }

    changed(integer change)
    {
        if(change & CHANGED_LINK)
        {
            key avatar=llAvatarOnSitTarget();
            if(avatar){
                if(helmKey){
                }else if(avatar==llGetOwner()) sitHelm(avatar); 
                else llMessageLinked(LINK_ROOT, MSGTYPE_SAYTO, "1", avatar);   //This boat can only be sailed by the owner 
            }else{
                if(helmKey) unsitHelm();
            }
        }
        if(change & CHANGED_INVENTORY) {
            llOwnerSay("***** change");
            llUnSit(helmKey);
            llResetScript();
        }
        if(change & CHANGED_REGION) {
            regionChanged=1;
        }
    }

    run_time_permissions(integer perm)
    {
        if(perm & PERMISSION_TRIGGER_ANIMATION) {
            setAnimation();
        }
        if (perm & PERMISSION_TAKE_CONTROLS) {
            llTakeControls(CONTROL_RIGHT | CONTROL_LEFT | CONTROL_ROT_RIGHT |
            CONTROL_ROT_LEFT | CONTROL_FWD | CONTROL_BACK | CONTROL_DOWN | CONTROL_UP, TRUE, FALSE);
        }
        if(perm & PERMISSION_CONTROL_CAMERA) setCamera();
    }

    timer() {
        if(steerDir==99) {  //lalia leave key
            neutral();
            sendExtraRudderNeutral=1;
            llSetTimerEvent(1.0);            
        }
        if(panoramaCounter>0) panoramaCounter--;
        if(--panoramaCam==0) {
            //**if(llAvatarOnSitTarget()) llRequestPermissions(llAvatarOnSitTarget(), PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_CONTROL_CAMERA);
            panoramaCounter += 20;
        }
        if(sendExtraRudderNeutral>0) {
            neutral();  // send extra rudder neutral in case of sim crossings
            sendExtraRudderNeutral=0;
        }
        if(--regionChanged==0) {
//            llOwnerSay("hrlm region changed");
            //llMessageLinked(LINK_THIS,MSGTYPE_MODECHANGE,(string)sailingState,NULL_KEY);
            currentAnimation="";
//panoramaCam=1;
            //*if(llAvatarOnSitTarget()) llRequestPermissions(llAvatarOnSitTarget(), PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_CONTROL_CAMERA);
        }
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        if(num==MSGTYPE_SETTINGS){   //receive configuration  num=setting number   id=data
            if((integer)str>=1 && (integer)str<=6) notecardRead((integer)str,(string)id);
        }else if(num == MSGTYPE_CREWINFO) {
            list settings=llCSV2List(str);
            integer newPose=llList2Integer(settings, 0);
            hasCapsized=llList2Integer(settings, 1);  // 1 capsized, 2 nosediving
            heel=llList2Integer(settings, 2);
            if(heel==0) hasCapsized=0;
            if(hasCapsized>0) {
                if(prevCapsized!=hasCapsized) noseDiveDelay=2;
                prevCapsized=hasCapsized;
                //**if(llAvatarOnSitTarget()) llRequestPermissions(llAvatarOnSitTarget(), PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_CONTROL_CAMERA);
                setAnimation();
            } else {
    //llOwnerSay("newPose:"+(string)newPose+" poseCrew:"+(string)poseCrew);
                if(newPose!=helmPose) {
                    helmPose=newPose;
                    //**if(llAvatarOnSitTarget()) llRequestPermissions(llAvatarOnSitTarget(), PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_CONTROL_CAMERA);
                    setAnimation();
                }
            }
        } else if(num==MSGTYPE_WWCRACE) {
            list in = llCSV2List(str);
            integer wwcRaceId=llList2Integer(in,0);
            integer    wwcCrewSize=llList2Integer(in,3);
            sailMode =llList2Integer(in,2);
            if(wwcRaceId>0) {
                setBoatID("");
            }
        } else if(num == MSGTYPE_GETNEWWWC) {
            //hideBoatID();
        //} else if (num==MSGTYPE_SCRIPTCHECK) {
            //llMessageLinked(LINK_ROOT, MSGTYPE_SCRIPTCHECK+1, llSHA1String(secretScriptKey+str),NULL_KEY);
        } else if(num==MSGTYPE_CREWSEATED+1 || num==MSGTYPE_CREWSEATED+2) {
            if(num==MSGTYPE_CREWSEATED+1) crew1Key=id;
            else crew2Key=id;
        }
    }

    control(key id, integer held, integer change) {
        if(prevKey==change && prevHeld==held) return; // ignore repeating keys;
//        llOwnerSay("crew key change:"+(string)change+" held:"+(string)held+" by:"+(string)id+llKey2Name(id));
        if (change & CONTROL_FWD && (held & CONTROL_FWD)) up();  // initial push-in is captured only
        else if (change & CONTROL_BACK && (held & CONTROL_BACK)) down();  // initial push-in is captured only
        if (change & CONTROL_DOWN && (held & CONTROL_DOWN)) pgdn();
        else if (change & CONTROL_UP && (held & CONTROL_UP)) pgup();

        if (((change & CONTROL_ROT_LEFT || change & CONTROL_ROT_RIGHT) && !(held & CONTROL_ROT_LEFT || held & CONTROL_ROT_RIGHT)) || ((change & CONTROL_LEFT || change & CONTROL_RIGHT) && !(held & CONTROL_LEFT || held & CONTROL_RIGHT))) {
            steerDir=99;
            llSetTimerEvent(0.1);
        }
        else if (change & CONTROL_ROT_LEFT && held & CONTROL_ROT_LEFT) {
            sendExtraRudderNeutral=0;
            steerDir=1;
            rotleft();
        } else if (change & CONTROL_ROT_RIGHT  && held & CONTROL_ROT_RIGHT) {
            sendExtraRudderNeutral=0;
            steerDir=-1;
            rotright();
        }
        else if (change & CONTROL_LEFT && held & CONTROL_LEFT) {
            left();
        } else if (change & CONTROL_RIGHT && held & CONTROL_RIGHT) {
            right();
        }
        prevKey=change;
        prevHeld=held;
    }
    
    listen(integer channel, string name, key id, string msg){
        if(channel==HudComChannel){
            if(llGetSubString(msg,0,4)=="hello"){ 
                key k=(key)llGetSubString(msg,6,41);
                if(k){
                    if(k==helmKey || k==crew1Key || k==crew2Key){
                        llRegionSayTo(id,HudComChannel,"sit,"+(string)k+","+(string)HudChannel);   //send hudchannel to hud
                    }
                }
            }
            return;    
        }

        if(msg=="hike+") hike(1);
        else if(msg=="hike-") hike(-1);
        else if(llGetSubString(msg,0,2)=="id " && sailingState!=VEHICLE_SAILING) setBoatID(llGetSubString(msg,3,-1));
        else if(msg=="raise" && sailingState!=VEHICLE_SAILING) setNewSailMode(VEHICLE_SAILING);
        else if((msg=="lower" || msg=="moor") && sailingState!=VEHICLE_FLOATING && hasCapsized<=0) setNewSailMode(VEHICLE_FLOATING);
        else if(msg=="sail+" && sailingState==VEHICLE_SAILING) pgdn();
        else if(msg=="sail-" && sailingState==VEHICLE_SAILING) pgup();
        else if(msg=="eject") llMessageLinked(LINK_SET, MSGTYPE_SETTINGSCHANGE, "eject", NULL_KEY);        
        else if(llGetSubString(msg,0,7)=="gennaker") llMessageLinked(LINK_THIS, MSGTYPE_SETTINGSCHANGE, "gen",llGetSubString(msg,8,9));
        else if (msg=="gybe" && sailingState==VEHICLE_SAILING){ 
            helmPose=helmPose*-1;
            llMessageLinked(LINK_ROOT, MSGTYPE_TACKING, "hike"+(string)CREWID+" "+(string)helmPose, helmKey);
            setAnimation();
        }else if(msg=="fun mode"){
            sailMode =0;
            llMessageLinked(LINK_SET,MSGTYPE_SAILMODE,"0",NULL_KEY);
        }else if(msg=="novice mode"){
            sailMode =1;
            llMessageLinked(LINK_SET,MSGTYPE_SAILMODE,"1",NULL_KEY);
        }else if(msg=="competition mode"){
            sailMode =2;
            llMessageLinked(LINK_SET,MSGTYPE_SAILMODE,"2",NULL_KEY);
        }else if(msg=="expert mode"){
            sailMode =3;
            llMessageLinked(LINK_SET,MSGTYPE_SAILMODE,"3",NULL_KEY);
        }else if(msg=="show sails port" && sailingState==VEHICLE_MOORED){
        }else if(msg=="show sails starboard" && sailingState==VEHICLE_MOORED){
        }else if(msg=="hide sails" && sailingState==VEHICLE_MOORED){
        }else if (msg=="apply textures" && id==llGetOwner()){
        }else if(msg=="remember dock" && sailingState==VEHICLE_MOORED){
            dockRotation=llGetRot();
            dockPosition=llGetPos();
            dockSim=llGetRegionName();
            llMessageLinked(LINK_ROOT, MSGTYPE_WHISPER+28, "", NULL_KEY); // Dock position registered
        }else if(msg=="dock" && sailingState==VEHICLE_MOORED){
            if(dockSim==llGetRegionName() && dockPosition!=<0,0,0>){
                llSetRot(dockRotation);
                while (llVecDist(llGetPos(),dockPosition)>.005) llSetPos(dockPosition);
            }else if(dockPosition!=<0,0,0>) llMessageLinked(LINK_ROOT, MSGTYPE_WHISPER+29, "", NULL_KEY); // Dock sim incorrect
            else llMessageLinked(LINK_ROOT, MSGTYPE_WHISPER+30, "", NULL_KEY); // Dock position not set
        }else if(msg=="set server" && sailingState==VEHICLE_MOORED && id==llGetOwner()) {
            serverKey = (key)llGetSubString(msg,10,-1);
            llMessageLinked(LINK_ROOT, MSGTYPE_WHISPER+25, (string)serverKey, NULL_KEY); // New versions will be requested from server
        }else if(msg=="updated version" && sailingState==VEHICLE_MOORED && id==llGetOwner()) { // updated version
            llMessageLinked(LINK_ROOT, MSGTYPE_WHISPER+24, "", NULL_KEY); // The latest version will be delivered to you shortly.
            //llEmail((string)serverKey+"@lsl.secondlife.com", ((string)serverCode + ":" + (string)llGetOwner()), boatName);
            llEmail((string)serverKey+"@lsl.secondlife.com", "update "+boatName,(string)llGetOwner()+"|"+boatName+"|"+versionName);
        }else if(msg=="panorama"){ // panorama
            if(panoramaCounter>60) llMessageLinked(LINK_ROOT, MSGTYPE_WHISPER+31, "", NULL_KEY); // Panorama view disabled
            else {
                panoramaCam=3;
                setAnimation();
            }
        }else if(msg=="shout"){
            shoutOn=++shoutOn%2;
            llMessageLinked(LINK_ROOT, MSGTYPE_WHISPER+58+shoutOn, "", NULL_KEY); // shout relay on/off
        }else if(llGetSubString(msg,0,6)=="channel "){
            integer chan=(integer)llGetSubString(msg,7,-1);
            if(chan>0){
                ChatChannel=chan;
                llMessageLinked(LINK_THIS, MSGTYPE_SETTINGSCHANGE, "chatchannel",(string)ChatChannel);
                llListenRemove(listenHandle);
                listenHandle=llListen(ChatChannel,"",helmKey,"");
            }
        }else if(msg=="global" || msg=="global wind"){
            llMessageLinked(LINK_THIS, MSGTYPE_SETTINGSCHANGE, "global","");
        }else if(msg=="mywind" || msg=="my wind"){
            llMessageLinked(LINK_THIS, MSGTYPE_SETTINGSCHANGE, "mywind","");
        }else if(llGetSubString(msg,0,7)=="winddir "){
            integer ndir=(integer)llGetSubString(msg,7,-1);
            if(ndir<0 || ndir>359) ndir=0;
            llMessageLinked(LINK_THIS, MSGTYPE_SETTINGSCHANGE, "winddir",(string)ndir);
        }else if(llGetSubString(msg,0,9)=="windspeed "){
            integer nspd=(integer)llGetSubString(msg,9,-1);
            if(nspd>=5 && nspd<30) llMessageLinked(LINK_THIS, MSGTYPE_SETTINGSCHANGE, "windspd",(string)nspd);
        /*
        }if(msg=="camera"){
            cameraMode++;
            if(cameraMode>=(llGetListLength(cameraList)/3)) cameraMode=0;
            setAnimation();
            llMessageLinked(LINK_ROOT, MSGTYPE_WHISPER+2, (string)cameraMode, NULL_KEY); // Camera changed to position 
        */
        }
    }
}