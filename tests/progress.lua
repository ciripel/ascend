local test = TEST or require "u-test"
local new_test_env = require "common.test-env"

test["core - single module - automatic start"] = function()
    ---@type AscendTestEnvOptions
    local options = {
        services = {
            ["date"] = {
                source_path = "assets/services/simple-date.hjson",
                definition = {
                    working_dir = "tmp", --- in case of this service it does not make a difference
                    restart = "always",
                    restart_delay = 5,
                    -- log_file = "none" -- inherits stdout/stderr
                }
            }
        },
        assets = {
            ["scripts/date.lua"] = "assets/scripts/date.lua"
        }
    }

    local first_env_dir = ""
    local second_env_dir = ""

    local result, err = new_test_env(options):run(function(env, ascendOutput)
        local startTime = os.time()

        while true do -- wait for service started
            local line = ascendOutput:read("l", 2)
            if line and line:match("date:default started") then
                break
            end
            if os.time() > startTime + 10 then
                return false, "Service did not start in time"
            end
        end

        first_env_dir = env:get_path()
        return true
    end):result()

    local result2, err2 = new_test_env(options):run(function(env, ascendOutput)
        local startTime = os.time()

        while true do -- wait for service started
            local line = ascendOutput:read("l", 2)
            if line and line:match("date:default started") then
                break
            end
            if os.time() > startTime + 10 then
                return false, "Service did not start in time"
            end
        end

        second_env_dir = env:get_path()
        return true
    end)
    test.assert(result, err)
    test.assert(result2, err2)
    test.assert(first_env_dir ~= second_env_dir, "slice isolation failed")
end
