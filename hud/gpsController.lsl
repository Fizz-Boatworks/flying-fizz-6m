key userKey;

integer gpsState = FALSE;
integer boatReceiver;
integer defaultRange = 10;
integer selectedRange = 10;

// lists
list mainMenuList = ["power on/off"];
list mainMenuList2 = ["set waypoint", "select route", "set range"];
list rangeMenuList = ["+10", "-10", "default (10m)", "↩️ back"];
list selectedRoute;
list inventoryList;

//listener
integer listener;

// menu channels
integer mainMenuChannel;
integer waypointMenuChannel;
integer routeMenuChannel;
integer rangeMenuChannel;

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
    list thisList = mainMenuList;
    if (gpsState) thisList = mainMenuList + mainMenuList2;
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
    llTextBox(userKey, "Please enter a waypoint in USB format!", waypointMenuChannel);
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
        rangeMenuList 
    );
}

onWaypointSet(string message)
{
    llOwnerSay(message);
    // message linked waypoint & range
}

onRangeSet(string message)
{
    switch(message)
    {
        case (string)rangeMenuList[0]:
            selectedRange = selectedRange + 10;
            llOwnerSay("GPS auto waypoint advance is set to " + (string)selectedRange);
            // message linked waypoint & range
            handleRangeMenu(userKey);
            break;
        case (string)rangeMenuList[1]:
            selectedRange = selectedRange - 10;
            llOwnerSay("GPS auto waypoint advance is set to " + (string)selectedRange);
            // message linked waypoint & range
            handleRangeMenu(userKey);
            break;
        case (string)rangeMenuList[2]:
            selectedRange = defaultRange;
            llOwnerSay("GPS auto waypoint advance is set to " + (string)selectedRange);
            // message linked waypoint & range
            handleRangeMenu(userKey);
            break;
        default:
            handleMainMenu(userKey, "main");
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
        llOwnerSay("WARNING: \n Max notecards in inventory (12) has been reached. This feature will be disabled until fixed.");
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
            if (!gpsState) {
                gpsState = TRUE;
                llOwnerSay("Flying Fizz 6m GPS on...");
                mainMenu(userKey);
            }
            else 
            {
                gpsState = FALSE;
                llOwnerSay("Flying Fizz 6m GPS off...");
                mainMenu(userKey);
            }
        }
    }
}


default
{
    state_entry()
    {
        llOwnerSay("Flying Fizz 6m GPS ready!");
        getInventoryList();
    }

    touch_start(integer number)
    {
        userKey = llDetectedKey(0);
        mainMenu(userKey);
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

    dataserver( key queryid, string data )
    {
        
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
