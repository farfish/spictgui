library(shinycssloaders)
library(hodfr)

navbarPage(id = "nav", windowTitle = "FarFish SPiCtGui",
                  title = div(
                      span("FarFish SPiCtGui"),
                      a(icon("github", lib = "font-awesome"),
                          href="https://github.com/farfish/spictgui",
                          class="navbar-brand",
                          style="position: absolute; top: 0; right: 0")),
                  tabPanel("Edit data",

                      div(class="row",
                          div(class="col-md-3",
                              fileInput('loadData', 'Load SPiCt data',
                                  accept = c('.xlsx')),
                              div(style = "margin-top: -15px", span("...or"), actionLink("loadDemo", "Load demo data"))),
                          div(class="col-md-3",
                              textInput('filename', NULL, label="Filename to save as")),
                          div(class="col-md-3",
                              downloadButton("saveData", "Save data to xlsx", style = "margin-top: 25px"))),

                      h3('Model configuration'),
                      div(class="row",
                          div(class = "col-md-3", checkboxInput("spict_seaprod", "Seasonal Productivity", value = FALSE)),
                          div(class = "col-md-3", checkboxInput("spict_timevaryinggrowth", "Time-varying growth", value = FALSE))),

                      h3('Catch data'),
                      p('Enter the unit for catch data in the field above, e.g. "Tonnes".'),
                      hodfr(
                          "catch",
                          fields = list(
                              list(name = "catch", title = "Catch")),
                          values = list(type = 'timeseries', min = 2000, max = 2000),  #  js_debug = TRUE,
                          params = list(rowHeaderWidth = 170),
                          orientation = 'vertical'),

                      h3('Abundance Index 1'),
                      p("If you do not enter a month, it will be assumed to be at the beginning of the year."),
                      hodfr(
                          "abundance_index_1",
                          fields = list(
                              list(name = "month", title = "Month"),
                              list(name = "index", title = "Index")),
                          values = list(type = 'year', min = 2000, max = 2000),
                          params = list(rowHeaderWidth = 170),
                          orientation = 'vertical'),

                      h3('Abundance Index 2'),
                      p("If you do not enter a month, it will be assumed to be at the beginning of the year."),
                      hodfr(
                          "abundance_index_2",
                          fields = list(
                              list(name = "month", title = "Month"),
                              list(name = "index", title = "Index")),
                          values = list(type = 'year', min = 2000, max = 2000),
                          params = list(rowHeaderWidth = 170),
                          orientation = 'vertical'),

                      p("")),

                  tabPanel("Catch / Abundance Index Plot",
                      withSpinner(plotOutput("catchPlot", height=700)),
                      downloadButton("catchPlotDownload", label = "Download plot")),

                  tabPanel("SPiCt messages",
                      downloadButton("fitObjectDownload", "Download spict.fit Rdata"),
                      h4('SPiCt messages:'),
                      withSpinner(verbatimTextOutput("fitMessage"))),

                  tabPanel("SPiCt summary plots",
                      withSpinner(plotOutput("fitPlot", height=700)),
                      downloadButton("fitPlotDownload", label = "Download plot")),

                  tabPanel("SPiCt diagnostics plots",
                      withSpinner(plotOutput("diagnosticsPlot", height=700)),
                      downloadButton("diagnosticsDownload", label = "Download plot")),

                  footer = includeHTML("footer.html")
)
