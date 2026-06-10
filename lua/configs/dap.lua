local dap = require "dap"
local mason_data = vim.fn.stdpath "data" .. "/mason"

-- codelldb: C, C++, Swift, Rust (rustaceanvim also picks this up)
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = mason_data .. "/bin/codelldb",
    args = { "--port", "${port}" },
  },
}

local codelldb_config = {
  {
    name = "Launch",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
}

dap.configurations.c = codelldb_config
dap.configurations.cpp = codelldb_config
dap.configurations.swift = codelldb_config

-- js-debug-adapter: JS, TS, JSX, TSX, Node
dap.adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = "node",
    args = {
      mason_data .. "/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
      "${port}",
    },
  },
}

local js_config = {
  {
    type = "pwa-node",
    request = "launch",
    name = "Launch Current File",
    program = "${file}",
    cwd = "${workspaceFolder}",
    sourceMaps = true,
  },
  {
    type = "pwa-node",
    request = "attach",
    name = "Attach to Process",
    processId = require("dap.utils").pick_process,
    cwd = "${workspaceFolder}",
    sourceMaps = true,
  },
  {
    type = "pwa-node",
    request = "launch",
    name = "Debug Jest Tests",
    runtimeExecutable = "node",
    runtimeArgs = { "./node_modules/.bin/jest", "--runInBand" },
    cwd = "${workspaceFolder}",
    console = "integratedTerminal",
    internalConsoleOptions = "neverOpen",
  },
}

for _, lang in ipairs { "javascript", "javascriptreact", "typescript", "typescriptreact" } do
  dap.configurations[lang] = js_config
end
