library(jsonlite)
library(ggplot2)
library(memoise)
library(hodfr)
library(spict)
library(callr)

source('spicttools.R')

options(shiny.sanitize.errors = FALSE)

# Add a timeout and memoisation around fit.spict
memoised_fit.spict <- memoise::memoise(function (x) {
    callr::r(function(x) {
        library(spict)
        fit.spict(x)
    }, args = list(x), timeout = 240)
}, cache = memoise::cache_filesystem('/tmp/spictfit'))

# Read all worksheets, converse of write.xlsx
read_all_xlsx <- function (xlsx_path, ...) {
    df_names <- openxlsx::getSheetNames(xlsx_path)
    dfs <- lapply(df_names, function (n) openxlsx::read.xlsx(xlsx_path, sheet = n, ...))
    names(dfs) <- df_names
    return(dfs)
}

server <- function(input, output, session) {
    # Get names of data.frame inputs from UI
    df_names <- shiny::isolate(names(Filter(is.data.frame, reactiveValuesToList(input))))
    names(df_names) <- df_names

    #### Reactive file output

    spict_doc <- reactive({
        doc <- lapply(df_names, function (x) input[[x]])

        # Mangle into expected shape
        for (n in grep('^catch$|^abundance_index_', names(doc), value = TRUE)) {
          if ('month' %in% names(doc[[n]])) {
              custom_month <- suppressWarnings(as.numeric(doc[[n]]$month))
          } else {
              custom_month <- rep(NA, nrow(doc[[n]]))
          }

          # Default to 1, same as dimension_timeseries:update_init
          month <- vapply(strsplit(rownames(doc[[n]]), "_"), function (x) {
              as.integer(ifelse(length(x) > 1, x[[2]], 1))
          }, integer(1))
          doc[[n]]$year <- vapply(strsplit(rownames(doc[[n]]), "_"), function (x) { as.integer(x[[1]]) }, integer(1))
          doc[[n]]$month <- ifelse(is.na(custom_month), month, custom_month)
          rownames(doc[[n]]) <- paste(doc[[n]]$year, doc[[n]]$month, sep = "_")

          # Make sure values are numeric, converting "NA" --> NA
          if ('catch' %in% names(doc[[n]])) {
              doc[[n]]$catch <- suppressWarnings(as.numeric(doc[[n]]$catch))
          } else if ('index' %in% names(doc[[n]])) {
              doc[[n]]$index <- suppressWarnings(as.numeric(doc[[n]]$index))
          } else if ('abundance_index_1' %in% names(doc[[n]])) {
              doc[[n]]$index <- suppressWarnings(as.numeric(doc[[n]]$abundance_index_1))
          }
        }

        ffdbdoc_to_spictstock(
            doc)
# TODO:           seaprod = input$spict_seaprod,
 #           timevaryinggrowth = input$spict_timevaryinggrowth)
    })

    spict_fit <- reactive({
        memoised_fit.spict(spict_doc())
    })

    ##### File handling
    observeEvent(input$loadData, {
        updateTextInput(session, "filename", value = gsub('.\\w+$', '', input$loadData$name))
        dfs <- read_all_xlsx(input$loadData$datapath,
            colNames = TRUE,
            rowNames = TRUE,
            skipEmptyCols = TRUE)
        for (n in names(dfs)) {
            updateHodfrInput(session, n, dfs[[n]])
        }
    })

    output$saveData <- downloadHandler(
        filename = function() {
            paste0(input$filename, ".xlsx")
        },
        content = function(file) {
            openxlsx::write.xlsx(
                spictstock_to_ffdbdoc(spict_doc()),
                file,
                col.names = TRUE,
                row.names = TRUE)
        }
    )

    plotPlusDownload <- function (fn_name, fn) {
        output[[fn_name]] <- renderPlot({ fn() })
        output[[paste0(fn_name, 'Download')]] <- downloadHandler(
          filename = function() { paste(input$document_name, ".", fn_name, ".png", sep="") },
          content = function(file) { png(file) ; print(fn()) ; dev.off() }
        )
    }

    #### Catch / Abundance index Plot

    plotPlusDownload('catchPlot', function () {
        st <- spict_doc()
        plotspict.data(st)
    })

    #### Fit

    output$fitMessage <- renderPrint({
        spict_fit()
    })

    plotPlusDownload('fitPlot', function () {
        fit <- spict_fit()
        if (fit$opt$convergence == 0) {
            plot(fit)
        }
    })

    output$fitObjectDownload <- downloadHandler(
        filename = function() {
            paste0(input$filename, ".fit.RData")
        },
        content = function(file) {
            fit <- spict_fit()
            save(fit, file = file)
        }
    )

    #### Diagnostics

    plotPlusDownload('diagnosticsPlot', function () {
        fit <- spict_fit()

        plotspict.diagnostic(calc.osa.resid(fit))
    })
}
