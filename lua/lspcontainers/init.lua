local utils = require("lspcontainers.utils")
local config = require("lspcontainers.config")
local supported_languages = require("lspcontainers.language_servers")
local image = require("lspcontainers.image")

--- Setup function for lspcontainers.nvim
---@param options lspcontainersConfig
local function setup(options)
  for key, value in pairs(options) do
      config[key] = value
  end
end

-- Default command to run an lsp container
---@param runtime string -- Runtime for the container
---@param workdir string -- Working directory to start the container in
---@param image_name string -- Image to run
---@param network string -- Network to run container in
---@param volume string -- Volume to attach to the container
---@return table<string> -- Command to run container
local default_cmd = function (runtime, workdir, image_name, network, volume)
  if vim.loop.os_uname().sysname == "Windows_NT" then
    workdir = utils.Dos2UnixSafePath(workdir)
  end

  local mnt_volume
  if volume ~= nil then
    mnt_volume ="--volume="..volume..":"..workdir..":z"
  else
    mnt_volume = "--volume="..workdir..":"..workdir..":z"
  end

  return {
    runtime,
    "container",
    "run",
    "--interactive",
    "--rm",
    "--network="..network,
    "--workdir="..workdir,
    mnt_volume,
    image_name
  }
end

---Validation on language server and and parse user options
---@param server string -- The language server to run
---@param user_opts table -- User options for command
local function command(server, user_opts)
  -- Start out with the default values:
  local opts =  {
    container_runtime = config.driver,
    root_dir = vim.fn.getcwd(),
    cmd_builder = default_cmd,
    network = "none",
    docker_volume = nil,
  }

  -- If the LSP is known, it override the defaults:
  if supported_languages[server] ~= nil then
    opts = vim.tbl_extend("force", opts, supported_languages[server])
  end

  -- If any opts were passed, those override the defaults:
  if user_opts ~= nil then
    opts = vim.tbl_extend("force", opts, user_opts)
  end

  if not opts.image then
    error(string.format("lspcontainers: no image specified for `%s`", server))
    return 1
  end

  return opts.cmd_builder(opts.container_runtime, opts.root_dir, opts.image, opts.network, opts.docker_volume)
end

image.create_user_commands()

---@class lspcontainers
---@field command function -- Command to run container
---@field images_pull function -- Pull all supported images
---@field images_remove function -- Remove all supported images
---@field setup function -- Setup function
---@field supported_languages LanguageServers -- lspcontainers supported language servers
return {
  command = command,
  images_pull = image.images_pull,
  images_remove = image.images_remove,
  setup = setup,
  supported_languages = supported_languages
}
