---@class LanguageConfiguration
return {
    cmd_builder = function(runtime, workdir, image, network)
        local volume = workdir .. ":" .. workdir .. ":z"
        local env = vim.api.nvim_eval("environ()")
        local gopath = env.GOPATH or env.HOME .. "/go"
        local gopath_volume = gopath .. ":" .. gopath .. ":z"

        local group_handle = io.popen("id -g")
        local user_handle = io.popen("id -u")

        local group_id = string.gsub(group_handle:read("*a"), "%s+", "")
        local user_id = string.gsub(user_handle:read("*a"), "%s+", "")

        group_handle:close()
        user_handle:close()

        local user = user_id .. ":" .. group_id

        if runtime == "docker" then
            network = "bridge"
        elseif runtime == "podman" then
            network = "slirp4netns"
        end

        return {
            runtime,
            "container",
            "run",
            "--env",
            "GOPATH=" .. gopath,
            "--interactive",
            "--network=" .. network,
            "--rm",
            "--workdir=" .. workdir,
            "--volume=" .. volume,
            "--volume=" .. gopath_volume,
            "--user=" .. user,
            image,
        }
    end,
    image = "docker.io/lspcontainers/gopls",
}
