install.packages('remotes')

install.packages("ellipse")  # Required by spict
remotes::install_github("tokami/spict/spict", ref="tvp_blim")

remotes::install_github("r-lib/memoise")
install.packages("openxlsx")  # Data input/output
install.packages('ggplot2')

remotes::install_github("daattali/shinycssloaders", "197ef14")
remotes::install_github("shuttlethread/hodfr")
install.packages('shiny')

# Development dependencies
if (nzchar(Sys.getenv('DEVEL_MODE'))) {
    install.packages('unittest')
}
