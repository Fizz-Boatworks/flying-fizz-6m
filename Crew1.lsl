integer CREWID=1;    // change this for every crew member 0-Helm 1-Crew1 2-Crew2
integer HudComChannel=-29000;
integer HudChannel;
integer ChatChannel;


integer MSGTYPE_SETTINGS=1000;
integer MSGTYPE_MODECHANGE=50001;
integer MSGTYPE_SAILHANDLING=50002;
integer MSGTYPE_SETTINGSCHANGE=50003;
integer MSGTYPE_CREWSEATED=70400; // 1-3 crewmembers 70400=helmsman, 70401=crew 1, 70402=crew 2, send avatar's UUID when seated and NULL_KEY when avatar has left

integer MSGTYPE_SAY = 51000;
integer MSGTYPE_WHISPER = 52000;
integer MSGTYPE_SHOUT = 53000;
integer MSGTYPE_SAYTO = 54000;

integer VEHICLE_SAILING=1;
integer VEHICLE_FLOATING=2;
integer VEHICLE_MOORED=0;

//links
integer mastLinkNum=0;

// variables read settings
list animationList=[];   // animationName, <offset>, <rotation> in fixed order (see poseCrew variable)
list mooredAnimationList=[];    //animationName, <offset>, <rotation>
list capsizeAnimationList=[];  // side, animationName, <offset>, <rotation>, start at capsize heel (biggest heel first)
list noseDiveAnimationList=[];
list cameraParams=[];

//crew variables
key crewKey;
integer crewPose;
integer mooredPose;
string  currentAnimation;

//operation variables
integer swRun;  //0 not ready   1 ready
integer listenHandle;  //handle listen ChatChannel
integer sailingState=0;
integer cameraMode;
integer panoramaCam=0;
integer panoramaCounter=0;
integer hasCapsized;
integer heel;
integer noseDiveDelay;

init()
{
    cameraParams=[];
    mooredAnimationList=[];
    capsizeAnimationList=[];
    animationList=[];

    getLinkNums();
    crewKey=NULL_KEY;
    crewPose=0;
    mooredPose=0;
    currentAnimation="";
    hasCapsized=0;
    heel=0;
    sailingState=0;
    cameraMode=0;
}

getLinkNums() 
{
    integer i;
    integer linkcount=llGetObjectPrimCount(llGetKey());
    for (i=1;i<=linkcount;++i) {
        string str=llGetLinkName(i);
        if (str=="mast") mastLinkNum=i;
    }
    vector pos=-llList2Vector(llGetLinkPrimitiveParams(mastLinkNum,[PRIM_POS_LOCAL]),0);
    if(mastLinkNum>0) llLinkSitTarget(mastLinkNum,pos,ZERO_ROTATION);
}


sitCrew(key k)
{
    if(!swRun){
        llUnSit(k);
        llRegionSayTo(k,0,"Flying Fizz is not ready");
        return;
    }
        
    crewKey=k;
    llMessageLinked(LINK_SET, MSGTYPE_CREWSEATED+CREWID, "", crewKey);
    cameraMode=0;
    crewPose=0;
    mooredPose=0;
    currentAnimation="";
    llListenRemove(listenHandle);
    listenHandle=llListen(ChatChannel,"",crewKey,"");
    llRequestPermissions(crewKey, PERMISSION_TRIGGER_ANIMATION | PERMISSION_CONTROL_CAMERA);
    llMessageLinked(LINK_ROOT, MSGTYPE_SAYTO, "47", crewKey);  // show little help info
    llMessageLinked(LINK_ROOT, MSGTYPE_SAYTO, "48", crewKey);  // show little help info
    llWhisper(HudComChannel,"sit,"+(string)crewKey+","+(string)HudChannel);   //call hud
}

unsitCrew()
{
    if(crewKey == llGetPermissionsKey()) // right user?
        if(llGetPermissions() & PERMISSION_TRIGGER_ANIMATION) // got permissions?
            if(llStringLength(currentAnimation)>0) llStopAnimation(currentAnimation);
            
    if(listenHandle) llListenRemove(listenHandle);
    llMessageLinked(LINK_SET, MSGTYPE_CREWSEATED+CREWID, "", crewKey);
    cameraMode=0;
    crewPose=0;
    mooredPose=0;
    llWhisper(HudComChannel,"unsit,"+(string)crewKey+","+(string)HudChannel);   //call hud
    crewKey = NULL_KEY;
}

setCamera() {
    if(crewKey) {
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

setAnimation() {
    if(crewKey) {
        llOwnerSay("setAnimation");
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
            crewPose=0;
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
            crewPose=0;
        } else {
            integer index=0;
            if(crewPose<=0) index=crewPose+3;
            else index=crewPose+2;
            if(crewPose==-3 || crewPose==3) currentAnimation="";
            //llOwnerSay("crewPose:"+(string)crewPose+" index:"+(string)index);
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
            llSetLinkPrimitiveParamsFast(findLink(crewKey), [PRIM_POSITION,newOffset, PRIM_ROTATION, llEuler2Rot(newRotation*DEG_TO_RAD)]);
            //**updateSitTarget(newOffset, llEuler2Rot(newRotation*DEG_TO_RAD));
        }
    }
}

notecardRead(integer msgId, string str) {
    list in=llCSV2List(str);
    if(msgId==18) animationList=in;
    else if(msgId==19) mooredAnimationList=in;
    else if(msgId==20) capsizeAnimationList=in;
    else if(msgId==21) noseDiveAnimationList=in;
    else if(msgId==22) cameraParams=in;
    //llOwnerSay((string)msgId+"   "+(string)llGetListLength(in));
    if(msgId==22) llOwnerSay(llGetScriptName()+" ready ("+(string)llGetFreeMemory()+" free)");
    swRun=1;
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
    integer n=llGetObjectPrimCount(llGetKey())+1;
    integer max = llGetNumberOfPrims();
    for(n=n;n<=max;n++) if(k==llGetLinkKey(n)) return(n);
    return(0);
}

default
{
    state_entry()
    {
        init();
    }
    
    changed(integer change)
    {
        if(change & CHANGED_LINK)
        {
            key avatar=llAvatarOnLinkSitTarget(mastLinkNum);
            if(avatar){
                if(crewKey){
                }else sitCrew(avatar); 
            }else{
                if(crewKey) unsitCrew();
            }
        }
    }
    
    run_time_permissions(integer perm)
    {
        if(perm & PERMISSION_TRIGGER_ANIMATION) {
            setAnimation();
        }
        if(perm & PERMISSION_CONTROL_CAMERA) setCamera();
    }    
    
    link_message(integer sender_num, integer num, string str, key id)
    {
        if(num==MSGTYPE_SETTINGS){   
            if(str=="hudchannel") HudChannel==(integer)((string)id);   //receive hud channel from Helmsman script
            else if((integer)str>=18 && (integer)str<=23) notecardRead((integer)str,(string)id); //receive settings params from messages script
        }else if(num==MSGTYPE_MODECHANGE){ 
            sailingState=(integer)str;
        }else if(num==MSGTYPE_SETTINGSCHANGE){ 
            if(str=="chatchannel"){
                if(crewKey){ 
                    ChatChannel==(integer)((string)id);
                    llListenRemove(listenHandle);
                    listenHandle=llListen(ChatChannel,"",crewKey,"");
                }
            }
        }
    }
    
    listen(integer channel, string name, key id, string msg) 
    {
        if(msg=="hike+") hike(1);
        else if(msg=="hike-") hike(-1);
        else if(msg=="sail+" && sailingState==VEHICLE_SAILING) llMessageLinked(LINK_ROOT, MSGTYPE_SAILHANDLING, "sail"+(string)CREWID+" 1", NULL_KEY);
        else if(msg=="sail-" && sailingState==VEHICLE_SAILING) llMessageLinked(LINK_ROOT, MSGTYPE_SAILHANDLING, "sail"+(string)CREWID+" -1", NULL_KEY);
        else if(llGetSubString(msg,0,7)=="gennaker") llMessageLinked(LINK_THIS, MSGTYPE_SETTINGSCHANGE, "gen "+llGetSubString(msg,8,9), NULL_KEY);
        else if(msg=="camera") { // camera
            cameraMode++;
            if(cameraMode>=(llGetListLength(cameraParams)/3)) cameraMode=0;
            setCamera();
            llMessageLinked(LINK_ROOT, MSGTYPE_WHISPER+2, (string)cameraMode, NULL_KEY); // Camera changed to position 
        }
    }    
}