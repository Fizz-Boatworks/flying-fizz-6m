integer MSGTYPE_SETTINGS=1000;

string  currentNoteCard="fizz_settings";
integer settingsLine;        // current line number reading notecard
key     settingsQueryID;             // id used to identify dataserver queries reading notecard
list    notecardParams;
integer comIndex;
string sline;
integer msgId;

default
{
    state_entry()
    {
    }
    
    link_message(integer sender_num, integer num, string str, key id)
    {
        if(str=="loadconf") {
            llOwnerSay("Loading Configuration");
            notecardParams=[];
            settingsLine=0;
            settingsQueryID = llGetNotecardLine(currentNoteCard, settingsLine);    // read line
        }
    }

    dataserver(key query_id, string data) {
        if (query_id == settingsQueryID) {
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

}
