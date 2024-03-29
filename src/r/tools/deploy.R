# PsychroLib (version 2.5.0) (https://github.com/psychrometrics/psychrolib).
# Copyright (c) 2018-2020 The PsychroLib Contributors. Licensed under the MIT License.

#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)

copy_file <- function () {
    # copy LICENSE file
    message("Copy LICENSE file")
    status <- file.copy("../../LICENSE.txt", "LICENSE", overwrite = TRUE)
    if (!status) stop("Failed to copy LICENSE file.")

    # copy README and logo
    message("Copy README and logo")
    status <- file.copy("../../README.md", ".", overwrite = TRUE)
    if (!status) stop("Failed to copy README.md.")
    if (!dir.exists("man/figures")) dir.create("man/figures", recursive = TRUE)
    status <- file.copy("../../assets/psychrolib_logo.svg", "man/figures", overwrite = TRUE)
    if (!status) stop("Failed to copy psychrolib library logo.")

}

update_license <- function () {
    lic <- readLines("LICENSE", warn = FALSE)
    re <- "Copyright \\(c\\) ((?:\\d{4})\\s*(?:-\\s*\\d{4})*) (.*?)(?:\\.)*$"
    m <- regexec(re, lic, perl = TRUE)
    if (all(sapply(m, length) == 1L)) stop("Failed to locate copyright field in LICENSE")

    r <- Filter(function (x) length(x) > 0L, regmatches(lic, m))

    year <- as.integer(unlist(strsplit(sapply(r, "[[", 2L), "\\s*-\\s*")))
    auth <- unlist(strsplit(sapply(r, "[[", 3L), "\\s*(,|and)\\s*"))

    # multiple years
    if (length(year) > 1L) {
        year <- paste(min(year), max(year), sep = "-")
    }

    # multiple authors
    if (length(auth) > 1L) {
        if (length(auth) == 2L) {
            auth <- paste(auth, collapse = " and ")
        } else {
            auth <- paste(
                paste(auth[-length(auth)], collapse = " ,"),
                "and", auth[length(auth)]
            )
        }
    }

    lic <- c(
        paste("YEAR:", year),
        paste("COPYRIGHT HOLDER:", auth)
    )

    writeLines(lic, "LICENSE")
}

update_links <- function () {
    # update links
    message("Update README links")
    readme <- readLines("README.md", warn = FALSE)
    ## logo
    readme[1] <- sub(
        'src="assets/psychrolib_logo.svg"',
        'src="man/figures/psychrolib_logo.svg"',
        readme[1],
        fixed = TRUE
    )
    ## files
    repo <- "https://github.com/psychrometrics/psychrolib"
    readme <- gsub("(\\[.+\\])\\(LICENSE.txt\\)", "\\1(LICENSE)", readme)
    readme <- gsub("(\\[.+\\])\\((.+\\.md)\\)", paste0("\\1(", repo, "/blob/master/\\2)"), readme)
    writeLines(readme, "README.md")

    # update all links in packages
    message("Check URLs and update if necessary")
    check_install_urlchecker()
    suppressMessages(urlchecker::url_update(), "cliMessage")
    NULL
}

check_install_urlchecker <- function () {
    check_devtools()

    # check and install urlchecker if necessary
    if (!require("urlchecker", character.only = TRUE, quietly = TRUE)) {
        message("'urlchecker' package is needed but not installed. Try to install it via GitHub")
        install.packages("urlchecker")
    }
}

check_devtools <- function () {
    # check devtools
    if (!require("devtools", quietly = TRUE)) {
        stop("'devtools' package is needed but not installed")
    }
}

fake_namespace <- function () {
    writeLines("# Generated by roxygen2", "NAMESPACE")
}

# run all
if (length(args) > 1L) stop("Only one argument is accepted")

if (!length(args)) {
    copy_file()
    update_license()
    update_links()
    check_devtools()
    devtools::install_deps()
    fake_namespace()
    devtools::document()
    Rcpp::compileAttributes()
    devtools::install()
    message("Completed")
} else if (args %in% c("--prepare", "-p")) {
    copy_file()
    update_license()
    update_links()
    message("Completed")
} else if (args %in% c("--doc", "-d")) {
    check_devtools()
    devtools::install_deps()
    fake_namespace()
    devtools::document()
    Rcpp::compileAttributes()
    message("Completed")
} else if (args %in% c("--install", "-i")) {
    check_devtools()
    devtools::install_deps()
    fake_namespace()
    devtools::document()
    Rcpp::compileAttributes()
    devtools::install()
    message("Completed")
} else if (args %in% c("--help", "-h")) {
    cat(
        "Usage: deploy.R [OPTION]",
        "    --prepare, -p: copy LICENSE.txt, README.md and update links in README",
        "    --doc, -d: create/update package documentation",
        "    --install, -i: update package documentation and install package",
        "    --help, -h: print this help messages",
        sep = "\n"
    )
} else {
    stop("Invalid option found. Please use 'deploy.R --help' for help")
}

0L
