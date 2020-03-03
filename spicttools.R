library(spict)


ffdbdoc_to_spictstock <- function (doc) {
    samplestock<-list(
        seasontype = 1,  # use the spline-based representation of seasonality
        splineorder = 3,
        seaprod = 0,
        timevaryinggrowth = FALSE,
        dteuler = 1/16)

    # Turn tables into obs/time lists
    indices <- grep('^catch$|^abundance_index_', names(doc), value = TRUE)
    data <- lapply(structure(indices, names = indices), function (tbl_name) {
        value_col <- ifelse(tbl_name == 'catch', 'catch', 'index')
        tbl <- doc[[tbl_name]][!is.na(doc[[tbl_name]][[value_col]]), ]

        list(
            obs = tbl[[value_col]],
            time = tbl$year + ((tbl$month - 1) %/% 3) / 4  # Floor to nearest quarter
        )
    })

    # Add catch to obsC/timeC
    samplestock$obsC <- ifelse(data$catch$obs < 0.001, 0.001, data$catch$obs)
    samplestock$timeC <- data$catch$time
    data$catch <- NULL

    # Add everything else to obsI/timeI
    samplestock$obsI <- lapply(data, function (d) d$obs)
    samplestock$timeI <- lapply(data, function (d) d$time)

    # Count seasons in catch data
    samplestock$nseasons <- max(spict::annual(samplestock$timeC, samplestock$timeC, type = length)$annvec)

    # TODO: Then if catches data time resolution is different from yearly or we have available yearly catches and 2 abundance indexes time series

    return(spict::check.inp(samplestock))
}

spictstock_to_ffdbdoc <- function (st) {
    doc <- new.env(parent = emptyenv())

    frac_to_month <- function (x) (x %% 1) * 12 + 1

    assign('catch', data.frame(
        catch = st$obsC,
        row.names = paste(floor(st$timeC), frac_to_month(st$timeC), sep = "_"),
        stringsAsFactors = FALSE), envir = doc)

    for (ind in seq_along(st$obsI)) {
        df <- data.frame(
            row.names = as.character(floor(st$timeI[[ind]])),
            month = frac_to_month(st$timeI[[ind]]),
            index = st$obsI[[ind]],
            stringsAsFactors = FALSE)

        # Fill any gaps in DF with NAs
        full_years <- seq(min(floor(st$timeI[[ind]])), max(floor(st$timeI[[ind]])))
        df_gaps <- data.frame(
            row.names = full_years,
            month = rep(1, length(full_years)),
            index = rep(NA, length(full_years)),
            stringsAsFactors = FALSE)
        df_merged <- merge(df_gaps, df, by = 'row.names', all.x = TRUE, sort = TRUE)
        df_merged$month.y[is.na(df_merged$month.y)] <- 1

        assign(paste0('abundance_index_', ind), data.frame(
            row.names = df_merged[['Row.names']],
            month = df_merged$month.y,
            index = df_merged$index.y,
            stringsAsFactors = FALSE), envir = doc)
    }

    return(as.list(doc))
}