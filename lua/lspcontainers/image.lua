local utils = require("lspcontainers.utils")
local config = require("lspcontainers.config")
local supported_languages = require("lspcontainers.language_servers")

---@class Image
local M = {}

---Pull all images to machine
M.images_pull = function()
    local jobs = {}
    local runtime = config.driver

    for idx, server_name in ipairs(config.ensure_installed) do
        local server = supported_languages[server_name]

        local job_id = vim.fn.jobstart(runtime .. " image pull " .. server["image"], {
            on_stderr = utils.on_event,
            on_stdout = utils.on_event,
            on_exit = utils.on_event,
        })

        table.insert(jobs, idx, job_id)
    end

    local _ = vim.fn.jobwait(jobs)

    print("lspcontainers: Language servers successfully pulled")
end

---Remove all images from machine
M.images_remove = function()
    local jobs = {}
    local runtime = config.driver

    for _, v in pairs(supported_languages) do
        local job = vim.fn.jobstart(runtime .. " image rm --force " .. v["image"] .. ":latest", {
            on_stderr = utils.on_event,
            on_stdout = utils.on_event,
            on_exit = utils.on_event,
        })

        table.insert(jobs, job)
    end

    local _ = vim.fn.jobwait(jobs)

    print("lspcontainers: All language servers removed")
end

---Creates user commands
M.create_user_commands = function()
    vim.api.nvim_create_user_command("LspImagesPull", M.images_pull, {})
    vim.api.nvim_create_user_command("LspImagesRemove", M.images_remove, {})
end

return M
