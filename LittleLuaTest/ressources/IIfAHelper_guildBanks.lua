--Parse the IIfA data table (from SavedVariables) via a lua script and get the guild banks for each account
--on each <Server> (NA, EU, PTS)
--They are located here: IIfA_Data["Default"]["@AccountName"]["$AccountWide"]["Data"]["<Server>-guildBanks"]
--Return the guild banks as table, using the <Server> as key, a subtable with the @Accountname as key, and a subtable
--containing the up to 5 guildbank names of the @Account on this server.
-->The order of the guild banks is random! The first entry IS NOT ALWAYS the guild1 on that server!!!
--Example
--[[
    IIfAHelper_guildBanks = {
        ["EU"] = {
            ["@AccountName"] = {
                [1] = "Name of guild";
                [2] = "Name of guild";
                [3] = "Name of guild";
                [4] = "Name of guild";
                [5] = "Name of guild";
            },
        },
        ["NA"] = {
            ["@AccountName"] = {
                [1] = "Name of guild";
                [2] = "Name of guild";
                [3] = "Name of guild";
                [4] = "Name of guild";
                [5] = "Name of guild";
            },
        },
        ["PTS"] = {
            ["@AccountName"] = {
                [1] = "Name of guild";
                [2] = "Name of guild";
                [3] = "Name of guild";
                [4] = "Name of guild";
                [5] = "Name of guild";
            },
        },
    },
]]
--Read the SavedVariables IIFA_DATA
IIfAHelper_guildBanks = {}
if IIfA_Data ~= nil and IIfA_Data["Default"] ~= nil then
    local IIfASVDataDefault = IIfA_Data["Default"]
    local IIfA_serverNames = {
        [1] = "EU",
        [2] = "NA",
        [3] = "PTS",
    }
    --Read the @account names from the SavedVars
    local IIfASVAccounts = {}
    for accountName, _ in pairs(IIfASVDataDefault) do
        IIfASVAccounts[#IIfASVAccounts + 1] = accountName
    end
    if #IIfASVAccounts >= 1 then
        --As we got the accounts in IIfASVAccounts now:
        --Read the guild banks for each account + server now
        for _, accountName in ipairs(IIfASVAccounts) do
            --Get the Data entry for the account name
            local IIfASVAccountData = IIfASVDataDefault[accountName]["$AccountWide"]["Data"]
            if IIfASVAccountData ~= nil then
                for _, serverName in ipairs(IIfA_serverNames) do
                    local guildBankServerCheckStr = serverName .. '-guildBanks'
                    if IIfASVAccountData[guildBankServerCheckStr] ~= nil then
                        --Guild bank for the server were read and saved in IIfA SavedVars already:
                        --Add the guild banks entry to returned global table
                        IIfAHelper_guildBanks[serverName] = {}
                        local IIfASVAccountGuildBanksData = IIfASVAccountData[guildBankServerCheckStr]
                        for guildBankName, _ in pairs(IIfASVAccountGuildBanksData) do
                            IIfAHelper_guildBanks[serverName][accountName] = IIfAHelper_guildBanks[serverName][accountName] or {}
                            IIfAHelper_guildBanks[serverName][accountName][#IIfAHelper_guildBanks[serverName][accountName] + 1] = guildBankName;
                        end
                    end
                end
            end
        end
    end
end