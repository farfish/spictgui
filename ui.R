library(shinycssloaders)
library(hodfr)

# Inline version of shiny::withMathJax
withInlineMathJax <- function (...) {
    path <- "https://mathjax.rstudio.com/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"
    tagList(
        tags$head(
            singleton(tags$script(src = path, type = "text/javascript")),
            singleton(tags$script(HTML("MathJax.Hub.Config({tex2jax: {inlineMath: [['$-$','$-$']]}})")))),
        ...,
        tags$script(HTML("if (window.MathJax && document.currentScript) MathJax.Hub.Queue([\"Typeset\", MathJax.Hub, document.currentScript.previousElementSibling]);")))
}


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

                      # NB: CITATION syntax invalid in tvp_blim
                      #p("Based on:"),
                      #HTML(format(citation('spict'), style="html")),

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
                      p("If you do not enter a month, it will be assumed to be at the beginning of the year. Leave all values blank if you do not have an appropriate index"),
                      hodfr(
                          "abundance_index_1",
                          fields = list(
                              list(name = "month", title = "Month"),
                              list(name = "index", title = "Index")),
                          values = list(type = 'year', min = 2000, max = 2000),
                          params = list(rowHeaderWidth = 170),
                          orientation = 'vertical'),

                      h3('Abundance Index 2'),
                      p("If you do not enter a month, it will be assumed to be at the beginning of the year. Leave all values blank if you do not have an appropriate index"),
                      hodfr(
                          "abundance_index_2",
                          fields = list(
                              list(name = "month", title = "Month"),
                              list(name = "index", title = "Index")),
                          values = list(type = 'year', min = 2000, max = 2000),
                          params = list(rowHeaderWidth = 170),
                          orientation = 'vertical'),

                      h3('Abundance Index 3'),
                      p("If you do not enter a month, it will be assumed to be at the beginning of the year. Leave all values blank if you do not have an appropriate index"),
                      hodfr(
                          "abundance_index_3",
                          fields = list(
                              list(name = "month", title = "Month"),
                              list(name = "index", title = "Index")),
                          values = list(type = 'year', min = 2000, max = 2000),
                          params = list(rowHeaderWidth = 170),
                          orientation = 'vertical'),

                      h3('Abundance Index 4'),
                      p("If you do not enter a month, it will be assumed to be at the beginning of the year. Leave all values blank if you do not have an appropriate index"),
                      hodfr(
                          "abundance_index_4",
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

                  tabPanel("Results summary",
                      downloadButton("fitObjectDownload", "Download spict.fit Rdata"),
                      withSpinner(verbatimTextOutput("fitMessage"))),

                  tabPanel("Preliminary checklist",
                      h4('Checklist for the acceptance of a SPiCT assessment'),
                      p('Based on the', a('spict guidelines documentation', href="https://github.com/DTUAqua/spict/blob/master/spict/inst/doc/spict_guidelines.pdf")),
                      shiny::tags$ol(
                         shiny::tags$li(
                             p('The assessment converged (fit$opt$convergence equals 0).'),
                             withSpinner(verbatimTextOutput("testConvergence"), proxy.height = "100px")),
                         shiny::tags$li(
                             p('All variance parameters of the model parameters are finite (all(is.finite(fit$sd)) should be TRUE).'),
                             withSpinner(verbatimTextOutput('testVariance'), proxy.height = "100px")),
                         shiny::tags$li(
                             p('No violation of model assumptions based on one-step-ahead residuals (bias, auto-correlation, normality). This means, that p-values are insignificant (> 0.05), indicated by green titles in the graphs of spictplot.diagnostic(fit). Slight violations of these assumptions do not necessarily invalidate model results.'),
                             withSpinner(verbatimTextOutput('testResiduals'), proxy.height = "100px")),
                         #shiny::tags$li(
                         #    withInlineMathJax(p('Consistent patterns in the retrospective analysis (fit <- retro(fit)). This means that there is no tendency of consistent under- or overestimation of the relative fishing mortality ($-$F / F_{MSY}$-$) and relative biomass ($-$B/B_{MSY}$-$) in successive assessment. The retrospective trajectories of those two quantities should be inside the confidence intervals of the base run.')),
                         #    withSpinner(verbatimTextOutput('testRetro'), proxy.height = "100px")),
                         # NB: Not available on tvp_blim branch yet
                         #shiny::tags$li(
                         #    withInlineMathJax(p('Realistic production curve. The shape of the production curve should not be too skewed ( $-$B_{MSY}/K$-$ should be between 0.1 and 0.9). Low values of $-$B_{MSY}/K$-$ allow for an infinite population growth rate (calc.bmsyk(fit)).')),
                         #    withSpinner(verbatimTextOutput('testProd'), proxy.height = "100px")),
                         #shiny::tags$li(
                         #    withInlineMathJax(p('High assessment uncertainty can indicate a lack of contrast in the input data or violation of the ecological model assumptions. The main variance parameters (logsdb, logsdc, logsdi, logsdf) should not be unrealistically high. Confidence intervals for $-$B/B_{MSY}$-$ and $-$F / F_{MSY}$-$ should not span more than 1 order of magnitude (calc.om(fit)).')),
                         #    withSpinner(verbatimTextOutput('testUncertainty'), proxy.height = "100px")),
                         #shiny::tags$li(
                         #    p('Initial values do not influence the parameter estimates (fit <- check.ini(fit)). The estimates should be the same for all initial values (fit$check.ini$resmat). Runs which did not converge should not be considered in this regard.'),
                         #    withSpinner(verbatimTextOutput('testInitial'), proxy.height = "100px")),
                         ""),
                      p("Please note that this is a preliminary checklist, you should consult the",
                        a('SPiCt guidelines documentation', href="https://github.com/DTUAqua/spict/blob/master/spict/inst/doc/spict_guidelines.pdf"),
                        "for a full list of requirements to check."),
                      ""),

                  tabPanel("Summary plots",
                      withSpinner(plotOutput("fitPlot", height=700)),
                      downloadButton("fitPlotDownload", label = "Download plot")),

                  # NB: Broken on tvp_blim branch
                  #tabPanel("Retrospective analysis plots",
                  #    withSpinner(plotOutput("retroPlot", height=700)),
                  #    downloadButton("retroDownload", label = "Download plot")),

                  tabPanel("Diagnostics plots",
                      withSpinner(plotOutput("diagnosticsPlot", height=700)),
                      downloadButton("diagnosticsDownload", label = "Download plot")),

                  footer = includeHTML("footer.html")
)
