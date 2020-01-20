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
    readme <- gsub("(\\[.+\\])\\((.+\\.md)\\)", paste0("\\1(", repo, "\\2)"), readme)
    writeLines(readme, "README.md")
}

check_devtools <- function () {
    # check devtools
    if (!require("devtools", quietly = TRUE)) {
        stop("'devtools' package is needed but not installed")
    }
}

# run all
if (length(args) > 1L) stop("Only one argument is accepted")

if (!length(args)) {
    copy_file()
    update_links()
    check_devtools()
    devtools::install_deps()
    devtools::document()
    devtools::install()
    message("Completed")
} else if (args %in% c("--prepare", "-p")) {
    copy_file()
    update_links()
    message("Completed")
} else if (args %in% c("--doc", "-d")) {
    check_devtools()
    devtools::install_deps()
    devtools::document()
    message("Completed")
} else if (args %in% c("--install", "-i")) {
    check_devtools()
    devtools::install_deps()
    devtools::document()
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
