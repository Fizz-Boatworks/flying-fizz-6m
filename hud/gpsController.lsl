key USER_KEY;
integer GPS_STATE = FALSE;
integer BOAT_RECEIVER;
integer DEFAULT_RANGE = 10;

// lists
list MAIN_MENU_LIST = ["power on/off"];
list MAIN_MENU_LIST2 = ["set waypoint", "select route", "set range"];
list RANGE_MENU_LIST = ["+10", "-10", "default (10m)", "↩️ back"];
list inventoryList;

//listener
integer listener;

// menu channels
integer mainMenuChannel;
integer waypointMenuChannel;
integer routeMenuChannel;
integer rangeMenuChannel;

//selected
integer selectedRange = DEFAULT_RANGE;
list selectedRoute;
integer selectedWaypoint;

menu(key id, integer channel, string title, list buttons) 
{
    llListenRemove(listener);
    listener = llListen(channel, "", id, "");
    llDialog(id, title, buttons, channel);
    llSetTimerEvent(30.0);
}

mainMenu(key id)
{
    mainMenuChannel = randomNumber();
    list thisList = MAIN_MENU_LIST;
    if (GPS_STATE) thisList = MAIN_MENU_LIST + MAIN_MENU_LIST2;
    menu
    (
        id,
        mainMenuChannel, 
        "Select an option...",
        llListSort(thisList, 1, FALSE) 
    );
}

handleMainMenu(key id, string message)
{
    switch (message)
    {
        case "set waypoint":
            handleWaypointMenu(id);
            break;
        case "select route":
            handleRouteMenu(id);
            break;
        case "set range":
            handleRangeMenu(id);
            break;
        case "main":
            mainMenu(id);
            break;
        default:
            toggleGPS();
            break;
    }
}

handleWaypointMenu(key id)
{
    waypointMenuChannel = randomNumber();
    llListenRemove(listener);
    listener = llListen(waypointMenuChannel, "", id, "");
    llTextBox(USER_KEY, "Please enter a waypoint in USB format!", waypointMenuChannel);
}

handleRouteMenu(key id)
{
    // llOwnerSay(message);
    string thisMessage = "Pease select a notecard to navigate to: \n\n";
    list thisList;
    integer a;
    integer i = (llGetListLength(inventoryList) - 1);

    for (a = 0; a <= i; a++)
    {
        thisMessage = thisMessage + ("(" + (string)a + ") " + (string)inventoryList[a] + "\n");
        thisList = thisList + (string)a;
    }

    llOwnerSay((string)thisList);
    routeMenuChannel = randomNumber();
    menu
    (
        id,
        routeMenuChannel, 
        thisMessage,
        llListSort(thisList, 3, FALSE)  
    );
}

handleRangeMenu(key id)
{
    rangeMenuChannel = randomNumber();
    menu
    (
        id,
        rangeMenuChannel, 
        "Select an option...",
        RANGE_MENU_LIST 
    );
}

onWaypointSet(string message)
{
    if (llSubStringIndex(message, "maps.secondlife.com") > 0)
    {
        llMessageLinked(BOAT_RECEIVER, selectedRange, message, "");
    } else
    {
        llOwnerSay("\nERROR: \nThis is not a properly formated url or USB style waypoint.");
    }
}

onRangeSet(string message)
{
    switch(message)
    {
        case (string)RANGE_MENU_LIST[0]:
            selectedRange = selectedRange + 10;
            llOwnerSay("GPS auto waypoint advance is set to " + (string)selectedRange);
            handleRangeMenu(USER_KEY);
            break;
        case (string)RANGE_MENU_LIST[1]:
            selectedRange = selectedRange - 10;
            llOwnerSay("GPS auto waypoint advance is set to " + (string)selectedRange);
            handleRangeMenu(USER_KEY);
            break;
        case (string)RANGE_MENU_LIST[2]:
            selectedRange = DEFAULT_RANGE;
            llOwnerSay("GPS auto waypoint advance is set to " + (string)selectedRange);
            handleRangeMenu(USER_KEY);
            break;
        default:
            handleMainMenu(USER_KEY, "main");
            break;
    }
}

onRouteSet(string message)
{
    llOwnerSay(message);
}

getInventoryList()
{
    integer a;
    integer i = (llGetInventoryNumber(INVENTORY_NOTECARD) -1);
    if (i > 12) {
        llOwnerSay("\nERROR: \nMax notecards in inventory (12) has been reached. This feature will be disabled until fixed.");
        return;
    }
    if (i < 1)
    {
        inventoryList = [];
        return;
    }
    for (a = 0; a <= i; a++)
    {
        inventoryList = inventoryList + llGetInventoryName(INVENTORY_NOTECARD, a);
    }

}

integer randomNumber()
{
    return ((integer) (llFrand(99999.0) * -1));    
}

toggleGPS()
{
    integer i = llGetNumberOfPrims();
    for (; i >= 0; --i)
    {
        string name = llGetLinkName(i);
        if (name == "boatReceiver")
        {
            BOAT_RECEIVER = i;
            if (!GPS_STATE) {
                GPS_STATE = TRUE;
                mainMenu(USER_KEY);
            }
            else 
            {
                GPS_STATE = FALSE;
                mainMenu(USER_KEY);
            }
        }
    }
}


default
{
    state_entry()
    {
        getInventoryList();
    }

    touch_start(integer number)
    {
        USER_KEY = llDetectedKey(0);
        mainMenu(USER_KEY);
    }

    listen(integer channel, string name, key id, string message)
    {
        switch (channel)
        {
            case (waypointMenuChannel):
                onWaypointSet(message);
                break;
            case (routeMenuChannel):
                onRouteSet(message);
                break;
            case (rangeMenuChannel):
                onRangeSet(message);
                break;
            default:
                handleMainMenu(id, message);
                break;
        }
    }

    timer()
    {
        llListenRemove(listener);
        llSetTimerEvent(0.0);
        llOwnerSay("Flying Fizz 6m GPS menu timed out...");
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
