# cdss-webapp-snodas-tools

Colorado's Decision Support Systems (CDSS) Snow Data Assimilation System (SNODAS) web application.

The web application website provides access to SNODAS daily products that are made available on a static website.  See the deployed sites:

* [State of Colorado server](http://snodas.cdss.state.co.us/app/index.html)
* [Open Water Foundation prototype](http://projects.openwaterfoundation.org/owf-proj-co-cwcb-2016-snodas/prototype/index.html)

This repository contains the web application code and enough data to test the application locally.  See the following sections on this page:

* [Getting Started](#getting-started)
* [Running the Application Locally](#running-the-application-locally)
* [Deploying the Application](#deploying-the-application)
* [Additional Documentation](#additional-documentation)
* [License](#license)
----

## Getting Started

A standard development folder structure is recommended, consistent with the main
[CDSS SNODAS Tools software](https://github.com/OpenWaterFoundation/cdss-app-snodas-tools):

```
C:\Users\users\                        Windows: Developer home folder.
/home/user/                            Linux:  Developer home folder.
  cdss-dev/                            CDSS development home folder.
    CDSS-SNODAS-Tools/                 CDSS SNODAS Tools home folder.
      git-repos/                       Git repositories for the SNODAS Tools.
        cdss-webapp-snodas-tools/      Git repository for this repository.
```

The following files are located within this repository.
The repository contains a folder `site` with website files, including top-level `index.html`.

```
cdss-webapp-snodas-tools/       Git repository files for this repository.
  build-util/                   Utility scripts to help with develop/build.
  doc/                          Additional developer documentation.
  site/                         The web application files to test.
                                Some files will also be deployed.
    SnowpackGraphsByBasin/      Graphs that correspond to the current day.
    SnowpackStatisticsByBasin/  Data products for each basin (multiple days).
    SnowpackStatisticsByDate/   Data products for each date (all basins).
    StaticData/                 Downloadable static files such as basin
                                connectivity spreadsheet.
    css/                        CSS files to control styling.
    fonts/                      Downloadable fonts.
    images/                     Images for website (buttons, etc.).
    javascript/                 JavaScript libraries and app code.
    json/                       Additional data such as basin GeoJSON.
    index.html                  Main application landing page.
  .gitattributes                Git configuration file for repository properties.
  .gitignore                    Git configuration file to ignore files.
  README.md                     This file.
```

This repository also includes one full month of data in order for web application developers to clone and run the web app on a local Python server.
The dates range from 2017-03-01 to 2017-03-20.
Test data includes graphs for basins with LOCAL_ID 402 through 3297.
These are the only basins that will have graphs associated
to them when selecting a basin for data display.

## Running the Application Locally

To run the application locally, such as during development:

1. Must have Python installed.
2. Open a Linux shell (Cygwin, Git Bash, etc.).
3. `cd` to the `build-util` folder.
4. `./run-http-server-8000.sh`

The above will serve the website using a local Python http server.
The run script determines whether Python2 or Python3 are available.
View the website in a web browser using [http://localhost:8000](http://localhost:8000).
Use CTRL-c to kill the local server.
When testing is sufficient, deploy the website as described below.

## Testing the application

Some attempt was made to implement application testing using standard web application testing tools (selenium, etc.).
However, the original project did not include sufficient budget.
The web application is relatively simple.
Consequently, most testing was done through visual inspection.
This is an area that can be improved in the future.

## Deploying the Application

The web application is deployed by installing only the web application files.
Data files are updated daily using files created by the
[CDSS SNODAS Tools application](https://github.com/OpenWaterFoundation/cdss-app-snodas-tools),
which runs daily as a scheduled process.
**Do not deploy test data files from this repository because they will overwrite the main data files from the analysis software.**  To facilitate deployment, run the following scripts:

* OWF prototype:  `build-util/copy-to-owf-amazon-s3.sh`
* State server:  **need to document**

## Additional Documentation

See also:

* [doc/README-code-explanation](doc/README-code-explanation.md)
* [SNODAS Tools Developer Manual](http://software.openwaterfoundation.org/cdss-app-snodas-tools-doc-dev/)
* [SNODAS Tools User Manual](http://software.openwaterfoundation.org/cdss-app-snodas-tools-doc-user/)

## License

The license is being determined as part of the OpenCDSS project.
