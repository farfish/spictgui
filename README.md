# FarFish SPiCt shiny app

Formats and presents analyses of data via. SPiCt. Standalone version.

## Prerequisites

R and shiny server need to be installed, follow instructions at https://www.rstudio.com/products/shiny/download-server/

## Installation

Make sure required dependencies are installed with:

    > source('install-deps.R')

...then lanuch the app with:

    shiny::runApp()

If using a [Shiny Server](https://rstudio.com/products/shiny/shiny-server/),
symlink this directory into the shiny server root, for example:

    ln -rs . /srv/shiny-server/spictgui

## Authors

* [Jamie Lentin](https://github.com/lentinj) - jamie.lentin@shuttlethread.com
* [Margarita Rincón Hidalgo](https://github.com/mmrinconh) - margarita.rincon@csic.es
* Javier Ruiz - javier.ruiz@csic.es

## License

This project is GPL-3.0 licensed - see the LICENSE file for details

## Acknowledgements

This project has received funding from the European Union’s Horizon 2020 research and innovation programme under grant agreement no. 727891.
