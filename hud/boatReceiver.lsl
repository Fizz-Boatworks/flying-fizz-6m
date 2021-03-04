string numbersUUID = "0f31aea7-a4e6-d672-812d-4d4105002a6b";
string selectedWaypoint ="http://maps.secondlife.com/secondlife/Sugar%20Reef/73/178/21,ORANGE CCW";
string selectedRegionName;
string selectedDescription;
vector selectedRegionCorner;
vector selectedVector;
integer selectedRange;

float textOpacity = 1;

integer defaultChannelNumber = -29000;
integer rlvChannelNumber = 29000;
integer rlvListener;
integer rlvEnabled = FALSE;
integer defaultListenHandler;
integer rootLink;
integer ktsLink;
integer cogLink;
integer brgLink;
integer awaLink;
integer awsLink;

list numbers = [
    <-0.37500, 0.37500, 0>,
    <-0.12500, 0.37500, 0>,
    <0.12500, 0.37500, 0>,
    <0.37500, 0.37500, 0>,
    <-0.37500, 0.12500, 0>,
    <-0.12500, 0.12500, 0>,
    <0.12500, 0.12500, 0>,
    <0.37500, 0.12500, 0>,
    <-0.37500, -0.12500, 0>,
    <-0.12500, -0.12500, 0>
];

vector textColor = <.24, .61, .98>;
vector currentWaypoint;
vector prevWaypoint;
vector nextWaypoint;
key gpsQuery = NULL_KEY;

GetHUDLinks()
{
    integer i = llGetNumberOfPrims();
    for (; i >= 0; --i)
    {
        string name = llGetLinkName(i);
        switch(name)
        {
            case "kts":
                ktsLink = i;
                break;
            case "cog":
                cogLink = i;
                break;
            case "brg":
                brgLink = i;
                break;
            case "awa":
                awaLink = i;
                break;
            case "aws":
                awsLink = i;
                break;
            default:
                rootLink = i;
                break;
        }
    }
}

string FormatDecimal(float number, integer precision)
{    
    float roundingValue = llPow(10, -precision)*0.5;
    float rounded;

    if (number < 0) rounded = number - roundingValue;
    else rounded = number + roundingValue;
 
    if (precision < 1) // Rounding integer value
    {
        integer intRounding = (integer)llPow(10, -precision);
        rounded = (integer)rounded/intRounding*intRounding;
        precision = -1; // Don't truncate integer value
    }
 
    string strNumber = (string)rounded;
    return llGetSubString(strNumber, 0, llSubStringIndex(strNumber, ".") + precision);
}

SetDigits(string param, integer linkNumber, integer showDecimal)
{
    if (showDecimal) param = llDeleteSubString(param, -2, -2);
    list digits = [
        (integer)llGetSubString(param, 0, 0),
        (integer)llGetSubString(param, 1, 1),
        (integer)llGetSubString(param, 2, 2)
    ];
    if ((integer)param <= 99) digits = [0, (integer)llGetSubString(param, 0, 0), (integer)llGetSubString(param, 1, 1)];
    if ((integer)param <= 9) digits = [0, 0, (integer)llGetSubString(param, 0, 0)];
    llSetLinkPrimitiveParamsFast(
        linkNumber,
        [
            PRIM_TEXTURE, 0, numbersUUID, <0.25, 0.25, 0.0>, (vector)numbers[(integer)digits[0]], 0.0,
            PRIM_TEXTURE, 1, numbersUUID, <0.25, 0.25, 0.0>, (vector)numbers[(integer)digits[1]], 0.0,
            PRIM_TEXTURE, 2, numbersUUID, <0.25, 0.25, 0.0>, (vector)numbers[(integer)digits[2]], 0.0 
        ]
    );
}

string ParseUSBRegionName(string regionName)
{
    integer i = llSubStringIndex(regionName, "%");
    return llInsertString(llDeleteSubString(regionName, i, i + 2), i, " ");
}

string CalculateBearing(string param)
{
    vector globalPosition = (vector)param;
    selectedVector.z = globalPosition.z;
    vector waypoint = selectedRegionCorner + selectedVector;
    integer brg = llRound( llAtan2(globalPosition.x - waypoint.x, globalPosition.y - waypoint.y) * 180.0 / PI + 180.0 ) % 360;
    return (string)brg;
}

string CalculateRange(string param)
{
    vector globalPosition = (vector)param;
    selectedVector.z = globalPosition.z;
    vector waypoint = selectedRegionCorner + selectedVector;
    integer range = (integer)llVecMag(globalPosition - waypoint);
    return (string)range;
}

string CalculateBTT(integer brg, integer hdg)
{
    integer diff = brg - hdg;
    if (diff > 180) return (string)(diff - 360);
    return (string)diff; 
}

default
{
    state_entry()
    {
        GetHUDLinks();
        defaultListenHandler = llListen(defaultChannelNumber, "", "", "");
        rlvListener = llListen(rlvChannelNumber, "", "", "");
        llOwnerSay("@version=" + (string)rlvChannelNumber);
    }
    
    on_rez(integer param)
    {
        llSetText("", textColor, textOpacity);
        llOwnerSay("@version=" + (string)rlvChannelNumber);
    }
    
    listen(integer channel, string name, key id, string message) 
    {
        if (channel == rlvChannelNumber) rlvEnabled = TRUE;
        
        if (channel == defaultChannelNumber)
        {
            list params = llParseStringKeepNulls(message, [","], []);
            if (llList2String(params, 0) == "updateHud")
            {
                string hdg = (string)params[1];
                string btspd = FormatDecimal((float)params[2]*1.944, 1);
                string awa = (string)llAbs((integer)params[3]);
                string aws = FormatDecimal((float)params[4]*1.944, 1);
                string brg = CalculateBearing((string)params[5] + "," + (string)params[6] + "," + (string)params[7]);
                string range = CalculateRange((string)params[5] + "," + (string)params[6] + "," + (string)params[7]);
                string btt = CalculateBTT((integer)brg, (integer)hdg);
                
                SetDigits(hdg, cogLink, 0);
                SetDigits(btspd, ktsLink, 1);
                SetDigits(awa, awaLink, 0);
                SetDigits(aws, awsLink, 1);
                SetDigits(brg, brgLink, 0);

                llSetText(selectedRegionName + " [ " + selectedDescription + " ] \n" +
                    range + "m | turn: " + btt,
                    textColor,
                    textOpacity
                );

            } else {
                SetDigits("0", cogLink, 0);
                SetDigits("0", awaLink, 0);
                SetDigits("0", awsLink, 0);
                SetDigits("0", ktsLink, 0);
                llSetText("", textColor, textOpacity);
            }
        }    
    }

    link_message(integer sender_num, integer num, string message, key id)
    {
        if (llSubStringIndex(message, "maps.secondlife.com") > 0) {
            list waypoint = llParseStringKeepNulls(message, ["/", ","], []);
            selectedVector = <(float)waypoint[5], (float)waypoint[6], (float)waypoint[7]>;
            selectedRegionName = ParseUSBRegionName((string)waypoint[4]);
            selectedDescription = (string)waypoint[8];
            selectedRange = (integer)num;
            gpsQuery = llRequestSimulatorData(selectedRegionName, DATA_SIM_POS);
        }
    }

    dataserver(key queryid, string data)
    {
        if (queryid == gpsQuery)
        {
            selectedRegionCorner = (vector)data;
            if (rlvEnabled)
            {
                llOwnerSay("@showworldmap=n");
                llMapDestination(selectedRegionName, selectedVector, ZERO_VECTOR);
                llOwnerSay("@showworldmap=y");
            }
        }
    }

    changed(integer change) 
    {
        if (change && CHANGED_INVENTORY) 
        {
            llSleep(0.5);
            llResetScript(); 
        }
    }
}