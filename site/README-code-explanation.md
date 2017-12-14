# SNODAS Tools Web Application Developer Documentation

This documentation provides information about the SNODAS Tools web application for use by software developers.

**This documentation includes code snippets as of 2017-12-14 to illustrate the application design and logic.  Changes to code after this will require updating this documentation (or documentation will be out of date but hopefully close).**

## What is SNODAS? ##

This web application tool provides access to a historical archive of SNODAS data products for Colorado water supply basins. Snow Data Assimilation System (SNODAS) data from the National Operational Hydrologic Remote Sensing Center (NOHRSC) are processed daily by a scheduled Python program to calculate Snow Water Equivalent (SWE) and Snow Coverage statistics for water supply basins in Colorado.  TSTool software is also used to create graph images (although in the future interactive graphs may be implemented using JavaScript libraries). Snow Water Equivalent is the estimate of the depth of liquid water contained within the snowpack. Snow coverage is a percent of the basin land surface covered by snow (water bodies in the basin are ignored). The national SNODAS gridded dataset has been processed to provide data products for Colorado.

The files created by the Python program are used by the web application, in particular to provide a map display.  Mean SWE is displayed in the map using a legend similar to the National Weather Service. The SNODAS Tools website provides access to an archive of daily products.

## Source Files ##

* index.html [Contains all the html and javascript code that was developed by Kory Clark at OWF]
* javascript [Contains all the javascript files that the index.html file references]
    * papaparse.js [PapaParse javascript framework. Contains all the javascript to run PapaParse]
    * lightbox.js [Lightbox javascript framework. Contains all the javascript to run Lightbox]
    * leaflet.zoomhome.min.js [Leaflet ZoomHome plugin. Contains all the javascript to run zoomHome]
    * leaflet.js [Leaflet javascript framework. Contains all the javascript to run leaflet]
    * jquery.min.js [jquery javascript framework. Contains all the javascript to run jquery]
    * L.Control.mousePosition.js [Leaflet mouseposition plugin. Contains all the javascript to run mouseposition]
* json [Contains all the geojson data that is read in by the SNODAS web app]
* css [Contains all the cascading style sheets used to style the index.html]
* StaticData [Contains .zip and .xlsx files used for the Basin Boundaries]
* SnowpackStatisticsByDate [Contains the .txt file which contains a list of all the dates of data available, as well as csv files that contain data for all basins per date]
* SnowpackStatisticsByBasin [Contains csv files, each of which contains SNODAS data for one basin]
* SnowpackGraphsByBasin [Contains .png files of all the graphs associated to each basin]


All the javascript code that Kory Clark wrote lives within the index.html file. This is not standard when using javascript within html and should eventually be put into a separate javascript file that the index.html file will include and make references to. In general practices, inlining more than 10 lines of javascript code within the index.html file is a poor design choice. Instead as mentioned earlier, there should be a separate javascript file that will be referenced by the html file. Every method mentioned below should be put into a separate javascript file and referenced by index.html.

**NOTE** The limited test data is included and the deployed application will have access to the full history of the data files.

## Summary of Logic ##

The general logic for the application is as follows:

1. Browser loads the `index.html` file as per normal conventions.
	1. Scripts are loaded in multiple sections of the index.html file. This type of organization was done so the code was easier to read and follow. All the initial setup code is in the first <script> element near line 226 where the Leaflet map is created. This section also contains some of the layer styling functions that are called when creating new leaflet data layers (i.e. the basin layers that belong to the choropleth map). The next <script> element near line 486 and 538 is where all the data is read in are. This was done so that all the data that was being read in could be done so synchronously (i.e. below the Ajax sync false command).
2. Order of execution (loading data files, initializing map, etc.)
    1. Initialize Leaflet map
    2. Load the list of dates to populate the Select Date button
    3. Load the Colorado Boundary geojson file to display the boundary of Colorado
    4. Load the SnowpackStatisticsByDate csv file
    5. Load the SNODAS_CO_BasinBoundaries geojson file
    6. Merge the csv data with the geojson data and add this to the map
3. After initialization, user interacts with the application and events cause other actions, as described in this documentation
	1. Calls to updateFile() will update the layer that is displayed on the Leaflet map
	2. Calls to reload(), playSlider(), and PauseSlider() control the animation when a user enters in a range of dates to display on the Leaflet map
	3. Calls to clickOnMapItem() will update the selected basin on the map and will update the graphs associated with that basin
	4. Calls to navbarClick() will update which tab is selected on the navigational bar (i.e. About, Documentation, Data)

**NOTE** There is no general naming convention used for components or variables. The variable names were created to allow users/developers have a simple idea of what that variable is used for. Functions are not alphabetized. The data loading happens up front and then will happen in the background when a different basin or date is selected.

## Main Components ##

The SNODAS web application contains three main components within the user interface:

1. A tabbed navigation panel on the left side that contains information about what SNODAS is, the data associated with this application, and some documentation on how the data is accessed and processed within this web tool.
2. A choropleth map that is uses Leaflet. This map is generated using geojson and csv data read in using a JavaScript library called PapaParse. Users are allowed to hover over and click on certain basins in order to display the data associated with that basin.
3. The animation and graphing tools. These live on the right side of the screen and use JavaScript on the backend to display map data for selected dates, and graphs associated with selected basins.

The section below explains the initial steps/functions that are called in order to initialize this web application and display the choropleth map.

## Initial Setup ##

**NOTE** everything within this section is called on app load and should be executed as soon as the browser is loaded.

Once the SNODAS web application has been loaded in a web browser, the Leaflet map will be initialized and attached to the <div> element with the id 'mapid' near line **225**. The map initialization takes place on line **228** by instantiating a new variable called `map`:

```
var map = L.map('mapid', {zoomControl: false}).setView([38.99, -105.54], 7);
```

This line of code calls Leaflet by using the global leaflet singleton `L` and creates a map by calling the map() function that will attach to the id `mapid` **NOTE** This is the id of the div that was mentioned above. The `setView` latitude and longitude value pair is the default view the user will see (38.99,-105.54 is the lat/long for the center of Colorado). The `7` indicates the zoom level, the higher the number, the closer the map is zoomed in.  `7` displays the entire State of Colorado.

Once the `map` variable has been instantiated, a tileLayer is added to the map to provide a background (e.g. satellite, street, gray, etc). As configured, the tileLayer is provided by MapBox and is called "light".  This is done on line **228**
```
L.tileLayer('https://api.mapbox.com/styles/v1/korysam/cixur5uy7003g2sqwthpjmbxa/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoia29yeXNhbSIsImEiOiJjaXd4dDRxbTQwMXRkMm9tZzd5b3BqdTBwIn0.A2EGyNrWG2Lbbd5c-I-94w', {
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery &copy;<a href="http://mapbox.com">Mapbox</a>',
    maxZoom: 18
}).addTo(map);
```

In order to create a tileLayer through mapbox you must create a mapbox account and gain an access token. This allows developers to call to the MapBox API. For more information on MapBox click on the following [link](https://www.mapbox.com/help/define-access-token/).  **NOTE** This will need to be changed eventually to an Open Water Foundation or Trilynx account since Kory Clark will be leaving us here soon.**

Some of the additional plugins that are used within the SNODAS web app are the leaflet.zoomhome (which allows the developer to specify the default/home zoom options), leaflet.mousePosition (which displays the coordinates lat/lng of where the mouse is on the map in the lower right hand side of the map), and leaflet.control.scale plugins (which displays a scale in km and mi for users to measure the distance between two points). The following code is used to initialize these plugins and add them to the map. This can be near lines **237** - **258**.
```
var zoomHome = L.Control.zoleaomHome();
zoomHome.addTo(map);

L.control.mousePosition({position: 'bottomright',lngFormatter: function(num) {
    var direction = (num < 0) ? 'W' : 'E';
    var formatted = Math.abs(L.Util.formatNum(num, 3)) + 'º ' + direction;
    return formatted;
},
latFormatter: function(num) {
    var direction = (num < 0) ? 'S' : 'N';
    var formatted = Math.abs(L.Util.formatNum(num, 3)) + 'º ' + direction;
    return formatted;
}}).addTo(map);

L.control.scale({position: 'bottomright',imperial: true}).addTo(map);
```

Now skip to line **487**. This line of code sets ajax's asynchronous to false, thus being synchronous. This means that ajax requests (i.e. $.get()) will no longer be run asynchronously and will instead be run synchronously. This changes the scope of where this data can live. For example, if a developer were to use the $.get() command asynchronously, then the data's scope would only be within the $.get() function:

EX:

$.get("FILENAME",function(data){
**THE DATA WILL ONLY BE ACCESSIBLE WITHIN THIS FUNCTION**. In other words, the scope of the data variable is local to the function and not accessible globally.
}
});

Using this method for reading in data is quick and very efficient, however it poses problems when trying to access that data in later code.

The other option is to run the $.get() command synchronously by setting the async property false (look at code below).

EX:

var input;
$.get("FILENAME",function(data){
}
});
**THE DATA WILL BE ACCESSIBLE IN LATER CODE (I.E. OUTSIDE THE FUNCTION**


This allows the code to query data and set that data to global variables outside the $.get() call rather
```
$.ajaxSetup({
    async: false
});
```

On line **493** this is where the `ListOfDates.txt` file is read in using the .get() command. This will request the file from the web server and will read in the data within the file. This file contains a list of valid dates that have been generated for the SNODAS data. The following lines of code will read in the data, sort the data in descending order (i.e. the earliest date), and then adds the data to a list that is then appended to the **Select Date** button.
```
$.get("SnowpackStatisticsByDate/ListOfDates.txt",function(data)
{
    text = data.split('\n');
    /* Sort the dates in descending order (Most recent day first) */
    text.sort(function(a, b) {
        return b - a;
    });
    /* trim each element. For some reason the split keeps the newline
    delimiter. */
    for(var date in text)
    {
        text[date] = text[date].trim();
    }
    Current_Date = text[0];
    for(var index = text.length-1; index > 0; index--)
    {
        if(text[index] != "")
        {
            Latest_Date = text[index];
            break;
        }
    }
    document.getElementById('ListOfDates').appendChild(createDateList(text));
});
```

If you now skip to line **542** this is where the black boundary that outlines Colorado is read in. The data that is read can be found in the CO_boundary.geojson file. This file is read in using the `.get()` command and is added to the leaflet map using the Leaflet geojson function below:

```
L.geoJSON(data, {style: setStateBoundaryStyle}).addTo(map);
```

This line of code will call the setStateBoundaryStyle function on line **302**. This function will add a weight of 5, color of black, and fillOpacity of 0 to each data layer that is specified within the CO_boundary.geojson file.

The next few lines near lines **547** - **589** are used to read in the SNODAS data from CSV files. Again, on line **548** the .get() command is used to read in the SnowpackStatisticsByDate_<current date>.csv file. The <current date> field is specified when reading in the ListOfDates.txt file on line **506**. On line **551** PapaParse is called to read in the csv data and create an array of that data. This array of data is then assigned to the variable SNODAS_Statistics. Then on line **556** the SNODAS_Geometry variable is assigned the data being read in from the SNODAS_CO_BasinBoundaries.geojson file. This file contains data that creates the actual basin boundaries on leaflet.
```
$.getJSON("json/CO_boundary.geojson",function(data){
    L.geoJSON(data, {style: setStateBoundaryStyle}).addTo(map);
});

var SNODAS_FILE = "SnowpackStatisticsByDate/SnowpackStatisticsByDate_" + Current_Date + ".csv";
var SNODAS_Statistics;
$.get(SNODAS_FILE, function(data)
{
    SNODAS_Statistics = Papa.parse(data, { header: true, skipEmptyLines: true, quotes: true});
});


var SNODAS_Geometry = (function() {
    var result;
    $.getJSON("json/SNODAS_CO_BasinBoundaries.geojson",function(data) {
        result = data;
    }); return result;
})();

```

The next step taken is merging the geojson data with the csv data (i.e. the SNODAS_Statistics variable with the SNODAS_Geometry variable).  This is done in the following line of code.

```
geojson = L.geoJson(MergeData(SNODAS_Geometry,SNODAS_Statistics), {style: setSWELayerStyle, onEachFeature: onEachFeature}).addTo(map);
```

This line of code makes a call to the MergeData function on line **572**. At the point that this funciton is called, both files (.geojson and .csv) have already been read in. This function takes in two arrays as parameters (i.e. the geojson data array, and the csv data array) and iterates  through both arrays and add the statistics to its corresponding basin. This is done by making sure that the current SNODAS_Statistics item's local_ID matches the SNODAS_Geometry item's local_ID. If they match then each property will be added to the geojson file without affecting properties that already existed. This line of code will also call the setSWELayerStyle as well as the onEachFeature functions near lines **362** and **291**. These will set the styling of each layer as well as the mouseover, mouseout, and click events when a user mouse’s over, out or clicks on a basin within the leaflet map.

Once this line has been executed, the initial map setup should be complete and a choropleth map will be displayed.

## Navigational Panel Function Calls ##

The one and only function that is associated with the left navigational panel is the navbarClick function specified on line **183**. This function will change the class of each id to active or not-active depending on which tab was selected. It will then go through each id and set the display to none or block depending on which tab was selected. This is done in order to make sure that only information for the selected tab is displayed within the navigational panel.
```
function navbarClick(source, other, source_id)
{
    if(source.toString() == "analysis")
    {
        $('#analysisTab').removeClass('not-active');
        $('#analysisTab').addClass('active');
        $('#aboutTab').removeClass('active')
        $('#aboutTab').addClass('not-active');
        $('#dataTab').removeClass('active');
        $('#dataTab').addClass('not-active');
    }
    else if(source.toString() == "data")
    {
        $('#dataTab').removeClass('not-active');
        $('#dataTab').addClass('active');
        $('#aboutTab').removeClass('active')
        $('#aboutTab').addClass('not-active');
        $('#analysisTab').removeClass('active')
        $('#analysisTab').addClass('not-active');
                        }
    else if(source.toString() == "about")
    {
        $('#aboutTab').removeClass('not-active')
        $('#aboutTab').addClass('active');
        $('#dataTab').removeClass('active');
        $('#dataTab').addClass('not-active');
        $('#analysisTab').removeClass('active')
        $('#analysisTab').addClass('not-active');
    }
    for(var index in other)
    {
        document.getElementById(other[index]).style.display = "none";
    }
    document.getElementById(source).style.display = "block";
}
```

## Select Date Function Calls ##

This button can be found on the right hand side of the web application tool. It lives within the navigational panel on the right of the screen next to the map.

When a user selects a new date using the **Select Date** button, this function will be called. It will get the date selected and update the data to the current date selected. It will then call the MergeData and the map will display the new choropleth data.
The following function is on line **595**.
```
function updateFile(file)
{
    var FileName = file.toString();
    FileName = FileName.substr(0,4) + "-" + FileName.substr(4,2) + "-" + FileName.substr(6,2);
    file = "SnowpackStatisticsByDate/SnowpackStatisticsByDate_" + file + ".csv";
    d3.selectAll("#FileDate").text(" " + FileName);
    geojson.clearLayers();

    $.get(file, function(data) {
        data_array = Papa.parse(data, { header: true, skipEmptyLines: true});
    });
    geojson.addData(MergeData(SNODAS_Geometry,data_array));
}
```

## Animation Function Calls ##

The following functions are used to run the animation when a user wants to see data associated with a range of dates. The reload() function will clear the interval created in the PlaySlider (i.e. stop the timer from changing the data), set the iterations to zero, updated the startdate to the original startdate (i.e. the beginning date) and will then call the PlaySlider() function to restart the animation.

The PlaySlider() function will check if the animation has completed. If it has then it will return false and stop the animation from running. If it hasn't it will then check if the iterations variable equals zero. If that is true the original startdate will be instantiated to the date the animation was set to by the user (i.e. the startdate specified). This function will also check a boolean called has_reset. This variable is instantiated to true and will be changed later in the PlaySlider() function to false. The reasoning behind this is to know if a user has clicked the reset button. If this boolean was not used within the code and a user were to click on the reset button, and then start the animation again, the animation would start playing from the wrong date (i.e. the startdate variable would never get updated to the original startdate that was specified by the user).

If the has_reset variable is set to true, the PlaySlider() function will then change the data on an interval (similar to a timer). Every X amount of seconds the animation will updated the map with a new date's data.

The PauseSlider() will clear the interval thus stopping the interval from running.


updateSliderMin_Max is called whenever the animation submit button is selected. It will update the min and max value of the range animation element. This then also creates tick marks on the slidebar by an increment of one.


```
var RangeDates = new Array();
var range_size, startdate, interval, step, original_startdate;
var has_complete = false;
var has_reset = true;
var iterations = 0;


/* This is the function the reset button calls. This will reset the
range to the beginning date (startdate) and will update certain booleans
so the animation can run properly */
function reload()
{
    clearInterval(interval);
    iterations = 0;
    startdate = original_startdate;
    document.getElementById("dateSlider").value = text.indexOf(startdate);
    showValue(startdate);
    has_complete = false;
    has_reset = true;
    PlaySlider();
}
/* This function is in charge of playing/running the animation
slider. It will progress through an array of dates that the
user inputted (startdate to enddate). Once it has reached the
end the user must click the reset button in order to play the
animation again. */
function PlaySlider()
{
    if(has_complete == true)
    {
        return false;
    }
    if(iterations == 0)
    {
        original_startdate = startdate;
    }
    if(has_reset == true)
    {
        has_reset = false;
        interval = setInterval(function(){
        if(iterations % step == 0)
        {
            document.getElementById("dateSlider").value = text.indexOf(startdate);
            showValue(startdate.toString());
        }
        iterations++;
        if(startdate == RangeDates[RangeDates.length-1])
        {
            has_complete = true;
            clearInterval(interval);
            iterations = 0;
            return false;
        }
        startdate = RangeDates[iterations];
        },875/step);
    }
}

/* This function is called by the animation pause button. When the pause button
is clicked, it wil clear the interval that is created in the PlaySlider() function.
The interval variable is a timing events. This interval allows execution of code at
a specified time interval. This is what pauses the animation */
function PauseSlider()
{
    clearInterval(interval);
    has_reset = true;
}

/* The ShowValue function is called in order to display the current date
the animation is on. This function will grab the span element with id='range'
and update it's innerHTML value to equal the current date in the format
YYYY-MM-DD. */
function showValue(newValue)
{
    document.getElementById("range").innerHTML = newValue.substr(0,4) + "-" + newValue.substr(4,2) + "-" + newValue.substr(6,2);
    updateFile(newValue);
}

function updateSliderMin_Max(startdate,enddate,scale)
{
    if(scale == "")
    {
        scale = 1;
    }
    iterations = 0;
    has_complete = false;
    has_reset = true;
    clearInterval(interval);
    RangeDates = [];
    has_reset = true;
    /* If the startdate string matches the format YYYY-MM-DD,
    then the startdate will be updated to match the format
    YYYYMMDD. This is neccessary when calling the updateFile() function. */
    if(startdate.match(/^\d{4}\-\d{1,2}\-\d{1,2}$/))
    {
        startdate = startdate.replace("-","");
        startdate = startdate.replace("-","");
    }
    /* If the enddate string matches the format YYYY-MM-DD,
    then the enddate will be updated to match the format
    YYYYMMDD. This is neccessary when calling the updateFile() function. */
    if(enddate.match(/^\d{4}\-\d{1,2}\-\d{1,2}$/))
    {
        enddate = enddate.replace("-","");
        enddate = enddate.replace("-","");
    }

    step = scale;
    this.startdate = startdate;
    range_size = (enddate - startdate) + 1;
    /* Call updateFile() function to update the current layer displaying on
    the leaflet map. */
    updateFile(startdate);



    /* The below code grabs the span with id "range" and updates the innerhtml to display the
    current layers date. It will display below the range animation as YYYY-MM-DD. */
    document.getElementById("range").innerHTML = startdate.substr(0,4) + "-" + startdate.substr(4,2) + "-" + startdate.substr(6,2);

    /* datalist is an element that will contain multiple option elements
    that each contain a date specified in the RangeDates array. */
    var datalist = document.getElementById('datalist');

    /* Populate the RangeDates array to contain the dates specified
    within the range the user inputted. For example, if the user wanted the range
    2017-03-01 to 2017-03-05, the RangeDates array would contain the following dates:
    2017-03-01, 2017-03-02, 2017-03-03,2017-03-04, 2017-03-05. Also resort the array of
    dates to be in ascending order. This is so the animation range bar will not act in reverse.*/
    text.sort(function(a, b) {
        return a - b;
    });
    var start_index = text.indexOf(startdate);
    var end_index = text.indexOf(enddate);

    /* The below document.getElementById() code will update the ranges min,
    max, value, and step values. This is what controls the animation range
    and step size. The min value is the "startdate", the max value is the "enddate",
    the scale is the increment days integer. */
    document.getElementById("dateSlider").min = start_index;
    document.getElementById("dateSlider").value = start_index;
    document.getElementById("dateSlider").max = end_index;

    for(start_index; start_index <= end_index; start_index++)
    {
        RangeDates.push(text[start_index]);
        var option = document.createElement('option');
        option.appendChild(document.createTextNode(start_index));
        document.getElementById('datalist').appendChild(option);
    }
}
```

## Select Basin Function Calls ##

A basin can be selected either by clicking on the map or selecting from the basin list on the right side of the application.

When a user selects a basin using the 'Select Basin' button, this function will be called. The LOCAL_ID of the basin selected will be passed in and the layer will then get updated to highlight which basin was selected on the map. The function will then update all the sources of each Plot by calling the SetSNODASPlot() function located on line **1024**.

SetSNODASPlot is called whenever a basin is clicked. Once clicked this function will recieve the LOCAL_ID of that basin and then update the SNDOAS Plots image section with the proper plot graph. This will then get updated everytime a new basin is selected.

```
function clickOnMapItem(Local_ID) {
  if(basin_selected)
  {
  var old_layer = geojson.getLayer(old_basin);
  old_layer.feature.properties.hasBeenSelected = false;
  old_layer.fireEvent('mouseout');
  }
  var id = Local_ID;
  old_basin = Local_ID;
  //get target layer by it's id
  var layer = geojson.getLayer(id);
  //fire event 'click' on target layer
  layer.fireEvent('mouseover');
  layer.feature.properties.hasBeenSelected = true;
  SetSNODASPlot(Local_ID);
  // select_basin_call = true;
  basin_selected = true;
  }
```

```
function SetSNODASPlot(name)
{
    document.getElementById("button_one").disabled = false;
    document.getElementById("button_two").disabled = false;
    document.getElementById("button_three").disabled = false;
    document.getElementById("button_four").disabled = false;
    document.getElementById("button_five").disabled = false;
    document.getElementById("button_six").disabled = false;
    document.getElementById("button_seven").disabled = false;


    document.getElementById("Basin_SnowCover_img").src = "SnowpackGraphsByBasin/" + name + "-SNODAS-SnowCover.png";
    document.getElementById("close-button-snowcover").innerHTML = "Click anywhere to close graph view"

    document.getElementById("Basin_SWE_img").src = "SnowpackGraphsByBasin/" + name + "-SNODAS-SWE.png";
    document.getElementById("close-button-swe").innerHTML = "Click anywhere to close graph view";

    document.getElementById("Basin_SWE_Volume_img").src = "SnowpackGraphsByBasin/" + name + "-SNODAS-SWE-Volume.png";
    document.getElementById("close-button-swe-volume").innerHTML = "Click anywhere to close graph view";

    document.getElementById("Basin_SWE_Upstream_Total_img").src = "SnowpackGraphsByBasin/" + name + "-UpstreamTotal-SNODAS-SWE-Volume.png";
    document.getElementById("close-button-swe-upstream-total").innerHTML = "Click anywhere to close graph view";

    document.getElementById("Basin_SWE_Upstream_Cumulative_img").src = "SnowpackGraphsByBasin/" + name + "-UpstreamTotal-SNODAS-SWE-Volume-Gain-Cumulative.png";
    document.getElementById("close-button-swe-upstream-cumulative").innerHTML = "Click anywhere to close graph view";

    document.getElementById("Basin_Swe_Volume_1WeekChange_img").src = "SnowpackGraphsByBasin/" + name + "-SNODAS-SWE-Volume-1WeekChange.png";
    document.getElementById("close-button-swe-volume-change").innerHTML = "Click anywhere to close graph view";

    document.getElementById("Basin_Swe_Volume_Gain_img").src = "SnowpackGraphsByBasin/" + name + "-SNODAS-SWE-Volume-Gain-Cumulative.png";
    document.getElementById("close-button-swe-volume-gain").innerHTML = "Click anywhere to close graph view";

    document.getElementById("BasinID").innerHTML = "Selected Basin ID: " + name;
    document.getElementById("BasinName").innerHTML = "Basin Name: " + getBasinName(name);

}
```

### Display Graph Buttons

When a user clicks on one of the seven buttons to display a graph specific to a basin (i.e. SNODAS Snow Cover Graph, SWE Graph, SWE Volume Graph, Upstream Total Volume Graph, SWE 1 Week Change Graph, Volume Gain, Cumulative Graph, and SWE Upstream Total Volume Gain, Cumulative Graph), the clickOnMapItem() function is called. This function call is specified within the createBasinList() function. As you can see below, this function creates a list of link elements (i.e. <a></a>). Each link element will have an attribute called 'onClick' that is set to call the clickOnMapItem() function with a string that contains the local id of the selected basin. Once a basin has been selected either using the 'Select Basin' button or clicking on a basin within the map, the clickOnMapItem function will be called on the selected basin.

```
function createBasinList()
{
    /* SORT Snodas_Geometry by local name and local id in ascending order A to Z */
    SNODAS_Geometry.features.sort(function(a,b){
        if (a["properties"]["LOCAL_NAME"].toLowerCase() < b["properties"]["LOCAL_NAME"].toLowerCase()) return -1;
        if (a["properties"]["LOCAL_NAME"].toLowerCase() > b["properties"]["LOCAL_NAME"].toLowerCase()) return 1;
        if (a["properties"]["LOCAL_NAME"].toLowerCase() == b["properties"]["LOCAL_NAME"].toLowerCase())
        {
            if (a["properties"]["LOCAL_ID"].toLowerCase() < b["properties"]["LOCAL_ID"].toLowerCase()) return -1;
            if (a["properties"]["LOCAL_ID"].toLowerCase() > b["properties"]["LOCAL_ID"].toLowerCase()) return 1;
            return
        }
        return 0;
    });
    var list = document.createElement('span');
    for(var index in SNODAS_Geometry.features)
    {
        // var li = document.createElement('li');
        var a = document.createElement('a');
        a.setAttribute("href","#");
        a.setAttribute("onclick",'clickOnMapItem(' + '"' + SNODAS_Geometry.features[index]["properties"]["LOCAL_ID"] + '");');
        a.setAttribute("style","font-size: 14px;");
        var basin = document.createTextNode(SNODAS_Geometry.features[index]["properties"]["LOCAL_NAME"] + " (" + SNODAS_Geometry.features[index]["properties"]["LOCAL_ID"] + ")");
        a.appendChild(basin);
        list.appendChild(a);
    }
    return list;
}
```
