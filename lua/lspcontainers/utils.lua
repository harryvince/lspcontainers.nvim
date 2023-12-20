---@class utils
local M = {}

---Escape a string using Dos2Unix like escaping
---@param string string
---@return string
function M.Dos2UnixSafePath(string)
    string = string.gsub(string, ":", "")
    string = string.gsub(string, "\\", "/")
    string = "/" .. string
    return string
end

---Print all standard out on an event
---@param _ number The Job Id
---@param data table<string> Contains output from stdout / stderr
---@param event string The type of event, must be stdout
function M.on_event(_, data, event)
  --if event == "stdout" or event == "stderr" then
  if event == "stdout" then
    if data then
      for _, v in pairs(data) do
        print(v)
      end
    end
  end
end

return M
