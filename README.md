# cdss-webapp-snodas-tools

Colorado's Decision Support Systems (CDSS) Snow Data Assimilation System (SNODAS) web application.

The website provides access to archived SNODAS web products that are made available on a static website.

## Getting Started

A standard development folder structure is recommended, consistent with the main
[CDSS SNODAS Tools software](https://github.com/OpenWaterFoundation/cdss-app-snodas-tools).
The website development files can be set up as follows (Windows is assumed, but Linux would be similar):

```
> C:
> cd \Users\user
> mkdir CDSS-SNODAS-Tools
> cd CDSS-SNODAS-Tools
> mkdir git-repos
> cd git-repos
> git clone https://github.com/OpenWaterFoundation/cdss-webapp-snodas-tools.git
```

The repository contains a folder `site` with website files, including top-level `index.html`.

This repository also includes one full month of data in order for users to clone down and run 
the web app tool on a python server. The dates range from 03-01-2017 to 03-20-2017. It also includes
graphs for basins 402 all the way up to 3297. These are the only basins that will have graphs associated
to them when a user clicks and or selects that basin.




## Additional Documentation

See also:

* [SNODAS Tools Developer Manual](http://software.openwaterfoundation.org/cdss-app-snodas-tools-doc-dev/)
* [SNODAS Tools User Manual](http://software.openwaterfoundation.org/cdss-app-snodas-tools-doc-user/)
