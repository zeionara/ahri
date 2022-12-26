#!/usr/bin/env Rscript

library(plumber)

api <- plumber::plumb("ahri/endpoint.r")
api$run(host = "127.0.0.1", port = 1717)
