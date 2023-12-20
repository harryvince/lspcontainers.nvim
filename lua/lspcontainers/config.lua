---@class lspcontainersConfig
---@field ensure_installed table<string> -- Table of Language Servers to install
---@field driver string -- The driver to run lspcontainers on
---@field drivers table<string> -- A table of drivers
return {
    ensure_installed = {},
    driver = "docker",
    drivers = {
        "docker"
    },
}
