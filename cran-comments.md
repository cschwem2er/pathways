## Test environments

* local windows 10, R 3.5.0
* win-builder (devel and release)
* linux mint 18.3, R 3.5.0

## R CMD check results

There was one NOTE:

checking installed package size ... NOTE
  installed size is 97.4Mb

## Comment on large data file

This package includes dataa on political representation in eight European democracies and a corresponding shiny application.
The data was compressed to achieve the lowest file size (still ~ 50MB). 
This package is meant as a data package and will rarely be updated. 
For this reason, I hope the CRAN team permits the larger file size, as user should only need to install and download the package once.
