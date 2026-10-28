local tbl = 
{
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "if not gLj_Toolbox then\n    gLj_Toolbox = {}\nend\nif not gLj_Toolbox.Settings then\n    gLj_Toolbox.Settings = {\n        roleOptions = {\n            tank = { \"MT\", \"OT\" },\n            healer = { \"H1\", \"H2\" },\n            dps = { \"M1\", \"M2\", \"R1\", \"R2\" }\n        },\n        selectedRole = 1,\n        partyRoles = {},\n        savedProfiles = {},\n        showPartyAssigner = false\n    }\nelse\n    gLj_Toolbox.Settings.roleOptions = gLj_Toolbox.Settings.roleOptions or {\n        tank = { \"MT\", \"OT\" },\n        healer = { \"H1\", \"H2\" },\n        dps = { \"M1\", \"M2\", \"R1\", \"R2\" }\n    }\n    gLj_Toolbox.Settings.partyRoles = gLj_Toolbox.Settings.partyRoles or {}\n    gLj_Toolbox.Settings.savedProfiles = gLj_Toolbox.Settings.savedProfiles or {}\nend\nif not gLj_Toolbox.Constants then\n    gLj_Toolbox.Constants = {\n        ROLE_COLORS = {\n            tank = { 0.2, 0.4, 0.8, 1.0 },\n            healer = { 0.2, 0.5, 0.2, 1.0 },\n            dps = { 0.7, 0.2, 0.2, 1.0 }\n        },\n        ROLE_BTN_WIDTH = 155,\n        ROLE_BTN_HEIGHT = 18,\n        ROLE_BUTTON_ID = \"##JacobRoleButton\",\n        allRoles = { \"MT\", \"OT\", \"H1\", \"H2\", \"M1\", \"M2\", \"R1\", \"R2\" }\n    }\nend\ngLj_Toolbox.GetRoleOptionsForJob = gLj_Toolbox.GetRoleOptionsForJob or function(job)\n    if job == 19 or job == 21 or job == 32 or job == 37 then\n        return gLj_Toolbox.Settings.roleOptions.tank, \"tank\"\n    elseif job == 24 or job == 28 or job == 33 or job == 40 then\n        return gLj_Toolbox.Settings.roleOptions.healer, \"healer\"\n    end\n    return gLj_Toolbox.Settings.roleOptions.dps, \"dps\"\nend\ngLj_Toolbox.GetRoleOptions = gLj_Toolbox.GetRoleOptions or function()\n    local player = TensorCore.mGetPlayer()\n    return gLj_Toolbox.GetRoleOptionsForJob(player and player.job or 0)\nend\ngLj_Toolbox.UpdateRoleOptions = gLj_Toolbox.UpdateRoleOptions or function()\n    local player = TensorCore.mGetPlayer()\n    local options, roleType = gLj_Toolbox.GetRoleOptionsForJob(player and player.job or 0)\n    local selected = tonumber(gLj_Toolbox.Settings.selectedRole) or 1\n    local saved = player and player.name and gLj_Toolbox.Settings.savedProfiles[player.name]\n    if saved and saved.job == player.job then\n        for index, role in ipairs(options) do\n            if role == saved.role then\n                selected = index\n                break\n            end\n        end\n    end\n    if player and (player.job == 23 or player.job == 31 or player.job == 38) and not saved then\n        selected = math.max(selected, 3)\n    elseif player and (player.job == 25 or player.job == 27 or player.job == 35 or player.job == 42) and not saved then\n        selected = math.max(selected, 4)\n    end\n    if selected < 1 or selected > #options then selected = 1 end\n    gLj_Toolbox.Settings.selectedRole = selected\n    if player and player.name then\n        local role = options[selected]\n        gLj_Toolbox.Settings.partyRoles[player.name] = role\n        if player.id then\n            if not gLj_PartyRoles then gLj_PartyRoles = {} end\n            for candidate, entityID in pairs(gLj_PartyRoles) do\n                if entityID == player.id then gLj_PartyRoles[candidate] = 0 end\n            end\n            gLj_PartyRoles[role] = player.id\n        end\n    end\n    return options, roleType\nend\ngLj_Toolbox.SaveProfile = gLj_Toolbox.SaveProfile or function(name, job, role)\n    if name and job and role then\n        gLj_Toolbox.Settings.savedProfiles[name] = { job = job, role = role }\n    end\nend\nif not gLj_PartyRoles then gLj_PartyRoles = {} end\nif not GetCurrentRole then\n    function GetCurrentRole()\n        local options = gLj_Toolbox.GetRoleOptions()\n        return options[gLj_Toolbox.Settings.selectedRole]\n    end\nend\nif not GetRole then\n    function GetRole(roleStr)\n        local entityID = gLj_PartyRoles[roleStr]\n        if entityID and entityID > 0 then\n            return TensorCore.mGetEntity(entityID)\n        end\n        return nil\n    end\nend\nif not GetLightParty then\n    function GetLightParty(roleStr)\n        local targetRole = roleStr or GetCurrentRole()\n        if targetRole == \"MT\" or targetRole == \"H1\" or targetRole == \"M1\" or targetRole == \"R1\" then return 1 end\n        if targetRole == \"OT\" or targetRole == \"H2\" or targetRole == \"M2\" or targetRole == \"R2\" then return 2 end\n        return 0\n    end\nend\n\nGUI:SetNextWindowSize(320, 240, GUI.SetCond_Always)\n\nGUI:PushStyleColor(GUI.Col_WindowBg, 0.07, 0.20, 0.30, 1.0)\nGUI:PushStyleColor(GUI.Col_ChildWindowBg, 0.07, 0.20, 0.30, 1.0)\nGUI:Begin(\"###StandaloneStrats\", true, GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoScrollWithMouse + GUI.WindowFlags_AlwaysAutoResize)\nGUI:BeginChild(\"##JacobToolboxHeader\", 0, 28, false)\nGUI:Text(\"Jacob's Toolbox\")\nGUI:SameLine()\n\nlocal function toolboxHover(text)\n    if GUI:IsItemHovered() then GUI:SetTooltip(text) end\nend\n\nlocal function drawHeaderPageButton(label, selected)\n    if selected then\n        GUI:PushStyleColor(GUI.Col_Button, 0.16, 0.38, 0.56, 1.0)\n        GUI:PushStyleColor(GUI.Col_ButtonHovered, 0.22, 0.48, 0.68, 1.0)\n        GUI:PushStyleColor(GUI.Col_ButtonActive, 0.11, 0.28, 0.42, 1.0)\n    else\n        GUI:PushStyleColor(GUI.Col_Button, 0.08, 0.22, 0.32, 1.0)\n        GUI:PushStyleColor(GUI.Col_ButtonHovered, 0.14, 0.32, 0.44, 1.0)\n        GUI:PushStyleColor(GUI.Col_ButtonActive, 0.06, 0.16, 0.24, 1.0)\n    end\n    local pressed = GUI:Button(label, 24, 20)\n    toolboxHover(label == \"1\" and \"Show the main Toolbox controls.\" or \"Show extra Toolbox utilities and settings.\")\n    GUI:PopStyleColor(3)\n    return pressed\nend\n\nlocal pageOneClicked = drawHeaderPageButton(\"1\", jacobUtilitiesOpen ~= true)\nGUI:SameLine()\nlocal pageTwoClicked = drawHeaderPageButton(\"2\", jacobUtilitiesOpen == true)\nif pageOneClicked then\n    jacobUtilitiesOpen = false\nend\nif pageTwoClicked then\n    jacobUtilitiesOpen = true\nend\nGUI:EndChild()\nGUI:Spacing()\nlocal jacobNow = Now()\ndata.jacob_job_swap = data.jacob_job_swap or {}\nlocal jobSwap = data.jacob_job_swap\nif jobSwap.loadGearSets ~= \"v10\" then\n    jobSwap.list = {}\n    jobSwap.roleByJob = {\n        [8] = \"Crafters\", [9] = \"Crafters\", [10] = \"Crafters\", [11] = \"Crafters\",\n        [12] = \"Crafters\", [13] = \"Crafters\", [14] = \"Crafters\", [15] = \"Crafters\",\n        [16] = \"Gatherers\", [17] = \"Gatherers\", [18] = \"Gatherers\",\n        [19] = \"Tank\", [21] = \"Tank\", [32] = \"Tank\", [37] = \"Tank\",\n        [24] = \"Healer\", [28] = \"Healer\", [33] = \"Healer\", [40] = \"Healer\",\n        [20] = \"DPS\", [22] = \"DPS\", [23] = \"DPS\", [25] = \"DPS\",\n        [26] = \"DPS\", [27] = \"DPS\", [30] = \"DPS\", [31] = \"DPS\", [34] = \"DPS\",\n        [35] = \"DPS\", [38] = \"DPS\", [39] = \"DPS\",\n        [41] = \"DPS\", [42] = \"DPS\",\n        [36] = \"Limited jobs\", [43] = \"Limited jobs\"\n    }\n    jobSwap.jobNameById = {\n        [8] = \"Carpenter\", [9] = \"Blacksmith\", [10] = \"Armorer\", [11] = \"Goldsmith\",\n        [12] = \"Leatherworker\", [13] = \"Weaver\", [14] = \"Alchemist\", [15] = \"Culinarian\",\n        [16] = \"Miner\", [17] = \"Botanist\", [18] = \"Fisher\",\n        [19] = \"Paladin\", [20] = \"Monk\", [21] = \"Warrior\", [22] = \"Dragoon\",\n        [23] = \"Bard\", [24] = \"White Mage\", [25] = \"Black Mage\", [26] = \"Arcanist\",\n        [27] = \"Summoner\", [28] = \"Scholar\", [30] = \"Ninja\", [31] = \"Machinist\",\n        [32] = \"Dark Knight\", [33] = \"Astrologian\", [34] = \"Samurai\", [35] = \"Red Mage\",\n        [36] = \"Blue Mage\", [37] = \"Gunbreaker\", [38] = \"Dancer\", [39] = \"Reaper\",\n        [40] = \"Sage\", [41] = \"Viper\", [42] = \"Pictomancer\", [43] = \"Beastmaster\"\n    }\n    jobSwap.jobIconPathById = {}\n    jobSwap.roleIconPathByCategory = {}\n    local function addIconIfPresent(path)\n        if path and FileExists and FileExists(path) then\n            return path\n        end\n        return nil\n    end\n    local function joinLuaModsPath(relativePath)\n        local root = GetLuaModsPath and GetLuaModsPath() or nil\n        if not root then\n            return nil\n        end\n        local last = string.sub(root, -1)\n        if last ~= \"\\\\\" and last ~= \"/\" then\n            root = root .. \"\\\\\"\n        end\n        return root .. relativePath\n    end\n    local jobIconBasePath = joinLuaModsPath(\"JacobAddon\\\\Images\\\\Jobs\\\\\")\n    if jobIconBasePath then\n        for _, supportedJobID in ipairs({ 19, 20, 21, 22, 23, 24, 25, 27, 28, 30, 31, 32, 33, 34, 35, 37, 38, 39, 40, 41, 42 }) do\n            local iconPath = addIconIfPresent(jobIconBasePath .. tostring(supportedJobID) .. \".png\")\n            if iconPath then\n                jobSwap.jobIconPathById[supportedJobID] = iconPath\n            end\n        end\n        local roleIconByCategory = {\n            DPS = jobIconBasePath .. \"DPSRole.png\",\n            Healer = jobIconBasePath .. \"HealerRole.png\",\n            Tank = jobIconBasePath .. \"TankRole.png\"\n        }\n        for category, iconPath in pairs(roleIconByCategory) do\n            local availablePath = addIconIfPresent(iconPath)\n            if availablePath then\n                jobSwap.roleIconPathByCategory[category] = availablePath\n            end\n        end\n    end\n    local blueMageIcon = joinLuaModsPath(\"JacobAddon\\\\Images\\\\Jobs\\\\36.png\")\n    blueMageIcon = addIconIfPresent(blueMageIcon)\n    if blueMageIcon then\n        jobSwap.jobIconPathById[36] = blueMageIcon\n    end\n    local namedJobIconFiles = {\n        [8] = \"Carpenter.png\",\n        [9] = \"Blacksmith.png\",\n        [10] = \"Armorer.png\",\n        [11] = \"Goldsmith.png\",\n        [12] = \"Leatherworker.png\",\n        [14] = \"Alchemist.png\",\n        [15] = \"Culinarian.png\",\n        [16] = \"Mining.png\",\n        [17] = \"Botanist.png\",\n        [18] = \"Fisher.png\",\n        [43] = \"BST.png\"\n    }\n    for jobID, iconFileName in pairs(namedJobIconFiles) do\n        local iconPath = addIconIfPresent(jobIconBasePath and (jobIconBasePath .. iconFileName) or nil)\n        if iconPath then\n            jobSwap.jobIconPathById[jobID] = iconPath\n        end\n    end\n    local gearSets = Player and Player.GetGearSetList and Player:GetGearSetList() or {}\n    for index, gearSet in pairs(gearSets) do\n        if gearSet then\n            local jobID = tonumber(gearSet.job) or 0\n            local category = jobSwap.roleByJob[jobID]\n            if category then\n                jobSwap.list[#jobSwap.list + 1] = {\n                    index = index,\n                    name = tostring(gearSet.name or index),\n                    jobID = jobID,\n                    jobName = jobSwap.jobNameById[jobID] or \"Unknown\",\n                    category = category\n                }\n            end\n        end\n    end\n    table.sort(jobSwap.list, function(left, right)\n        if left.category ~= right.category then return left.category < right.category end\n        if left.jobName ~= right.jobName then return left.jobName < right.jobName end\n        if left.name ~= right.name then return left.name < right.name end\n        return (tonumber(left.index) or 0) < (tonumber(right.index) or 0)\n    end)\n    jobSwap.loadGearSets = \"v10\"\nend\n\nif not jacobWaymarkImportState then\n    jacobWaymarkImportState = {\n        raw = \"\",\n        status = \"\",\n        progress = 0\n    }\nend\nif not jacobImportWaymarkPreset then\n    jacobImportWaymarkPreset = function(raw)\n        local w = AnyoneCore and AnyoneCore.Waymarks\n        if not w or not w.io or not w.store or not AnyoneCore.JSON then\n            return false, \"AnyoneCore Waymark Helper is unavailable.\", false\n        end\n        local clean = tostring(raw or \"\")\n        local fence = string.char(96) .. string.char(96) .. string.char(96)\n        clean = string.gsub(clean, \"^%s*\" .. fence .. \"json%s*\", \"\")\n        clean = string.gsub(clean, \"^%s*\" .. fence .. \"%s*\", \"\")\n        clean = string.gsub(clean, \"%s*\" .. fence .. \"%s*$\", \"\")\n        local okObject, object = pcall(function()\n            return AnyoneCore.JSON.decode(clean)\n        end)\n        if not okObject or type(object) ~= \"table\" then\n            return false, \"Invalid waymark JSON.\", false\n        end\n        local okMarks, marks = pcall(function()\n            return w.io.parseWPP(clean)\n        end)\n        if not okMarks or type(marks) ~= \"table\" then\n            return false, \"The text is not a valid WPP preset.\", false\n        end\n        local markCount = 0\n        for _, markName in ipairs({ \"A\", \"B\", \"C\", \"D\", \"One\", \"Two\", \"Three\", \"Four\" }) do\n            local mark = marks[markName]\n            if type(mark) == \"table\" and type(mark.x) == \"number\" and type(mark.y) == \"number\" and type(mark.z) == \"number\" then\n                markCount = markCount + 1\n            end\n        end\n        if markCount == 0 then\n            return false, \"No active waymarks were found.\", false\n        end\n        local name = tostring(object.Name or object.name or \"Imported Waymarks\")\n        if name == \"\" then name = \"Imported Waymarks\" end\n        local existing = w.store.findEquivalent(marks)\n        if existing then\n            return true, \"Already exists as \" .. tostring(existing) .. \".\", false\n        end\n        local all = w.store.all() or {}\n        local baseName = name\n        local suffix = 0\n        while all[name] do\n            suffix = suffix + 1\n            name = baseName .. \" (\" .. tostring(suffix) .. \")\"\n        end\n        local mapID = tonumber(object.MapID or object.map or 0) or 0\n        local zone = mapID > 0 and { map = mapID } or nil\n        local okPut, putResult = pcall(function()\n            return w.store.put(name, marks, \"Imported\", zone)\n        end)\n        if not okPut then\n            return false, \"Import failed: \" .. tostring(putResult), false\n        end\n        if w.store.save then\n            pcall(w.store.save)\n        end\n        return true, \"Imported \" .. name .. \".\", true\n    end\nend\n\n\nif jacobWikiWaymarkCodeVersion ~= 2 then\n    jacobQueueWikiWaymarkPage = nil\n    jacobExtractWikiWaymarkBlocks = nil\n    jacobBuildWikiWaymarkRecords = nil\n    jacobDispatchWikiWaymarkPage = nil\n    jacobStartWikiWaymarkImport = nil\n    jacobProcessWikiWaymarkImport = nil\n    jacobWikiWaymarkCodeVersion = 2\nend\nif not jacobWikiWaymarkState then\n    jacobWikiWaymarkState = { phase = \"idle\", queue = {}, queued = {}, queueIndex = 1, pages = {}, pageOrder = {}, pending = false, records = {}, recordIndex = 1, imported = 0, duplicates = 0, failed = 0, fetched = 0, failedPages = 0, errors = {}, status = \"\", progress = 0 }\nend\nif not jacobQueueWikiWaymarkPage then\n    jacobQueueWikiWaymarkPage = function(slug)\n        local s = jacobWikiWaymarkState\n        if type(slug) ~= \"string\" or slug == \"\" or s.queued[slug] or #s.queue >= 100 then return end\n        s.queued[slug] = true\n        s.queue[#s.queue + 1] = slug\n    end\nend\nif not jacobExtractWikiWaymarkBlocks then\n    jacobExtractWikiWaymarkBlocks = function(body)\n        local blocks, seen = {}, {}\n        local fence = string.char(96) .. string.char(96) .. string.char(96)\n        local function add(raw)\n            raw = tostring(raw or \"\")\n            raw = string.gsub(raw, \"^%s+\", \"\")\n            raw = string.gsub(raw, \"%s+$\", \"\")\n            if raw ~= \"\" and not seen[raw] then seen[raw] = true; blocks[#blocks + 1] = raw end\n        end\n        for raw in string.gmatch(body or \"\", fence .. \"json%s*(%b{})%s*\" .. fence) do add(raw) end\n        for raw in string.gmatch(body or \"\", string.char(96) .. \"(%b{})\" .. string.char(96)) do add(raw) end\n        return blocks\n    end\nend\nif not jacobBuildWikiWaymarkRecords then\n    jacobBuildWikiWaymarkRecords = function()\n        local s = jacobWikiWaymarkState\n        s.records, s.recordKeys = {}, {}\n        for _, slug in ipairs(s.pageOrder) do\n            for _, raw in ipairs(jacobExtractWikiWaymarkBlocks(s.pages[slug])) do\n                if not s.recordKeys[raw] then\n                    s.recordKeys[raw] = true\n                    s.records[#s.records + 1] = { raw = raw, page = slug }\n                end\n            end\n        end\n        s.recordIndex = 1\n    end\nend\nif not jacobDispatchWikiWaymarkPage then\n    jacobDispatchWikiWaymarkPage = function()\n        local s = jacobWikiWaymarkState\n        if s.phase ~= \"fetching\" or s.pending or s.queueIndex > #s.queue then return end\n        local slug = s.queue[s.queueIndex]\n        s.queueIndex = s.queueIndex + 1\n        s.pending, s.currentPage = true, slug\n        s.status = \"Fetching \" .. slug .. \"...\"\n        HttpRequest({\n            host = \"raw.githubusercontent.com\",\n            path = \"/wiki/Em-Six/FFXIVWaymarkPresets/\" .. slug .. \".md\",\n            port = 443, https = true, method = \"GET\",\n            headers = { [\"User-Agent\"] = \"TensorReactions-JacobToolbox\" },\n            onsuccess = function(response, header, statusCode)\n                local state = jacobWikiWaymarkState\n                if state.phase == \"cancelled\" then return end\n                local code, body = tonumber(statusCode) or 0, tostring(response or \"\")\n                state.pending = false\n                if code == 200 and body ~= \"\" then\n                    state.pages[slug] = body\n                    state.pageOrder[#state.pageOrder + 1] = slug\n                    state.fetched = state.fetched + 1\n                    for linkedSlug in string.gmatch(body, \"github%.com/Em%-Six/FFXIVWaymarkPresets/wiki/([^%s%]]+)\") do\n                        linkedSlug = string.gsub(linkedSlug, \"[?#].*$\", \"\")\n                        if string.sub(linkedSlug, -1) == \")\" then\n                            linkedSlug = string.sub(linkedSlug, 1, -2)\n                        end\n                        jacobQueueWikiWaymarkPage(linkedSlug)\n                    end\n                    state.status = \"Loaded \" .. slug\n                else\n                    state.failedPages = state.failedPages + 1\n                    state.errors[#state.errors + 1] = slug .. \" (\" .. tostring(code) .. \")\"\n                    state.status = \"Could not load \" .. slug\n                end\n            end,\n            onfailure = function(error, header, statusCode)\n                local state = jacobWikiWaymarkState\n                if state.phase == \"cancelled\" then return end\n                state.pending = false\n                state.failedPages = state.failedPages + 1\n                state.errors[#state.errors + 1] = slug\n                state.status = \"Could not load \" .. slug\n            end\n        })\n    end\nend\nif not jacobStartWikiWaymarkImport then\n    jacobStartWikiWaymarkImport = function()\n        local s = jacobWikiWaymarkState\n        s.phase, s.queue, s.queued, s.queueIndex = \"fetching\", {}, {}, 1\n        s.pages, s.pageOrder, s.pending = {}, {}, false\n        s.records, s.recordKeys, s.recordIndex = {}, {}, 1\n        s.imported, s.duplicates, s.failed = 0, 0, 0\n        s.fetched, s.failedPages, s.errors = 0, 0, {}\n        s.progress, s.status = 0, \"Starting wiki import...\"\n        jacobQueueWikiWaymarkPage(\"Home\")\n    end\nend\nif not jacobProcessWikiWaymarkImport then\n    jacobProcessWikiWaymarkImport = function()\n        local s = jacobWikiWaymarkState\n        if s.phase == \"fetching\" then\n            if not s.pending and s.queueIndex <= #s.queue then\n                jacobDispatchWikiWaymarkPage()\n            elseif not s.pending and s.queueIndex > #s.queue then\n                jacobBuildWikiWaymarkRecords()\n                s.phase, s.status, s.progress = \"importing\", \"Importing \" .. tostring(#s.records) .. \" presets...\", 0.65\n            end\n        elseif s.phase == \"importing\" then\n            local record = s.records[s.recordIndex]\n            if record then\n                local okImport, importStatus, added = jacobImportWaymarkPreset(record.raw)\n                if okImport and added then s.imported = s.imported + 1 elseif okImport then s.duplicates = s.duplicates + 1 else s.failed = s.failed + 1 end\n                s.status = importStatus .. \" (\" .. tostring(s.recordIndex) .. \"/\" .. tostring(#s.records) .. \")\"\n                s.recordIndex = s.recordIndex + 1\n                if #s.records > 0 then s.progress = 0.65 + (0.35 * ((s.recordIndex - 1) / #s.records)) end\n            else\n                local w = AnyoneCore and AnyoneCore.Waymarks\n                if w and w.store and w.store.save then pcall(w.store.save) end\n                s.phase, s.progress, s.status = \"complete\", 1, \"Finished wiki import.\"\n            end\n        end\n    end\nend\n\nlocal jacobPlayer = TensorCore and TensorCore.mGetPlayer and TensorCore.mGetPlayer() or nil\nlocal jacobInCombat = jacobPlayer and jacobPlayer.incombat == true\nif jacobUtilitiesExtracting == true and jacobInCombat then\n    jacobUtilitiesExtracting = false\n    jacobUtilitiesNextExtract = nil\nend\nif jacobUtilitiesExtracting == true and jacobNow >= (jacobUtilitiesNextExtract or 0) then\n    if ffxiv_craft and ffxiv_craft.Canextractmateria and ffxiv_craft.extractmateria and ffxiv_craft.Canextractmateria() then\n        if ffxiv_craft.extractmateria() then\n            jacobUtilitiesNextExtract = jacobNow + 4000\n        else\n            jacobUtilitiesExtracting = false\n        end\n    else\n        jacobUtilitiesExtracting = false\n    end\nend\n\n\nGUI:Spacing()\nif jacobUtilitiesOpen == true then\n    GUI:Text(\"Utilities\")\n    GUI:PushStyleColor(GUI.Col_Button, 0.60, 0.18, 0.12, 1.0)\n    GUI:PushStyleColor(GUI.Col_ButtonHovered, 0.78, 0.28, 0.16, 1.0)\n    GUI:PushStyleColor(GUI.Col_ButtonActive, 0.45, 0.10, 0.08, 1.0)\n    local returnClicked = GUI:Button(\"Return\", 95, 20)\n    GUI:PopStyleColor(3)\n    if returnClicked then\n        jacobUtilitiesOpen = false\n    end\n    GUI:SameLine()\n    local extractionBusy = jacobUtilitiesExtracting == true\n    if extractionBusy then\n        GUI:Button(\"Extracting...\", 145, 20)\n        GUI:SameLine(0, 2)\n        GUI:PushStyleColor(GUI.Col_Button, 0.78, 0.08, 0.08, 1.0)\n        GUI:PushStyleColor(GUI.Col_ButtonHovered, 0.95, 0.16, 0.16, 1.0)\n        GUI:PushStyleColor(GUI.Col_ButtonActive, 0.58, 0.04, 0.04, 1.0)\n        local stopClicked = GUI:Button(\"STOP\", 78, 26)\n        GUI:PopStyleColor(3)\n        if stopClicked then\n            jacobUtilitiesExtracting = false\n            jacobUtilitiesNextExtract = nil\n        end\n        GUI:Spacing()\n        GUI:Text(\"Extracting spiritbonded gear...\")\n    else\n        local extractClicked = GUI:Button(\"Extract Materia\", 145, 20)\n        if extractClicked then\n            if jacobInCombat then\n                GUI:OpenPopup(\"JacobExtractCombatPopup\")\n            else\n                jacobUtilitiesExtracting = true\n                jacobUtilitiesNextExtract = 0\n            end\n        end\n    end\n    if GUI:BeginPopup(\"JacobExtractCombatPopup\") then\n        GUI:Text(\"cannot use this in combat.\")\n        if GUI:Button(\"OK\", 70, 20) then\n            GUI:CloseCurrentPopup()\n        end\n        GUI:EndPopup()\n    end\n    GUI:Spacing()\n\n    GUI:Spacing()\n    local autoMelderClicked = GUI:Button(\"Auto Melder\", 110, 20)\n    if autoMelderClicked and AnyoneCore and AnyoneCore.Data then\n        AnyoneCore.Data.autoMelderOpen = true\n    end\n    GUI:SameLine()\n    local importWaymarksClicked = GUI:Button(\"Import Waymarkers\", 145, 20)\n    if importWaymarksClicked then\n        if jacobInCombat then GUI:OpenPopup(\"JacobWaymarkImportCombatPopup\") else GUI:OpenPopup(\"JacobWaymarkBulkConfirmPopup\") end\n    end\n    if GUI:BeginPopup(\"JacobWaymarkImportCombatPopup\") then\n        GUI:Text(\"Cannot import waymarks in combat.\")\n        if GUI:Button(\"OK\", 70, 20) then GUI:CloseCurrentPopup() end\n        GUI:EndPopup()\n    end\n    if GUI:BeginPopup(\"JacobWaymarkBulkConfirmPopup\") then\n        GUI:Text(\"Import all wiki waymark presets?\")\n        GUI:Text(\"This fetches every linked wiki page and skips duplicates.\")\n        if GUI:Button(\"Confirm\", 90, 20) then jacobStartWikiWaymarkImport(); GUI:CloseCurrentPopup() end\n        GUI:SameLine()\n        if GUI:Button(\"Cancel\", 90, 20) then GUI:CloseCurrentPopup() end\n        GUI:EndPopup()\n    end\n    GUI:Spacing()\n    local customDrawMonitorClicked = GUI:Button(\"Draw Monitor\", 140, 24)\n    if customDrawMonitorClicked then\n        jacobCustomDrawMonitorOpen = jacobCustomDrawMonitorOpen ~= true\n    end\n    GUI:SameLine()\n    if GUI:Button(\"AutoSim\", 140, 24) then\n        jacobAutoSimEditorOpen = jacobAutoSimEditorOpen ~= true\n    end\n    if GUI:IsItemHovered() then GUI:SetTooltip(\"Open or close saved fight-specific AutoSim settings.\") end\n    GUI:Spacing()\n    if GUI:Button(\"Mitigations\", 140, 24) then\n        GUI:OpenPopup(\"JacobMitigationsPopup\")\n    end\n    GUI:SameLine()\n    if GUI:Button(\"Gear Sets\", 140, 24) then\n        jacobGearPlannerOpen = jacobGearPlannerOpen ~= true\n    end\n    if GUI:IsItemHovered() then GUI:SetTooltip(\"Open or close your gear catalog, inventory comparison, combined acquisition plan and food preferences.\") end\n    local reactionSettings = AnyoneCore and AnyoneCore.Settings and AnyoneCore.Settings.Reactions\nif GUI:BeginPopup(\"JacobMitigationsPopup\") then\n    GUI:Text(\"Ultimates\")\n    if reactionSettings and reactionSettings.dmu then\n        reactionSettings.dmu.primaryMitigation = GUI:Checkbox(\"DMU Primary\", reactionSettings.dmu.primaryMitigation == true)\n    end\n    if reactionSettings then\n        reactionSettings.fruPrimaryMitigation = GUI:Checkbox(\"FRU Primary\", reactionSettings.fruPrimaryMitigation == true)\n        reactionSettings.UWUEnableMitigation = GUI:Checkbox(\"UWU Primary\", reactionSettings.UWUEnableMitigation == true)\n    end\n\n    GUI:Separator()\n    GUI:Text(\"Savages\")\n    if reactionSettings then\n        reactionSettings.arcadionPrimaryMitigation = GUI:Checkbox(\"M9S-M12S Primary\", reactionSettings.arcadionPrimaryMitigation == true)\n        reactionSettings.arcadionPrimaryMitigation = GUI:Checkbox(\"M5S-M8S Primary\", reactionSettings.arcadionPrimaryMitigation == true)\n        reactionSettings.secondaryMitigation = not GUI:Checkbox(\"P11S-P12S Primary\", reactionSettings.secondaryMitigation ~= true)\n    end\n    GUI:EndPopup()\nend\n    GUI:Spacing()\n    local thirdPartyClicked = GUI:Button(\"Third party\", 120, 24)\n    if thirdPartyClicked and AnyoneCore then\n        AnyoneCore.open = true\n        AnyoneCore.selectedTab = \"Third Party\"\n    end\n\nelse\nlocal clicked = GUI:Button(\"Strats\", 95, 20)\n    toolboxHover(\"Open or close AnyoneCore's fight strategy and reaction settings.\")\nGUI:SameLine()\nlocal agentClicked = GUI:Button(\"Agent\", 95, 20)\n    toolboxHover(\"Open or close the TensorReactions editor to manage profiles, reactions and timelines.\")\nif agentClicked and TensorCore and TensorCore.API and TensorCore.API.TensorReactions then\n    TensorCore.API.TensorReactions.toggleGUI()\nend\nGUI:SameLine()\nlocal rosterClicked = GUI:Button(\"Roster\", 95, 20)\nif GUI:IsItemHovered() then\n    GUI:SetTooltip(\"Open AnyoneCore's party roster to assign your party roles.\")\nend\nif rosterClicked then\n    local popup = AnyoneCore and AnyoneCore.RosterPopup\n    if popup and type(popup.openManual) == \"function\" then\n        local ok, err = pcall(popup.openManual)\n        gLj_Toolbox.rosterError = not ok and (\"Roster could not open: \" .. tostring(err)) or nil\n    else\n        gLj_Toolbox.rosterError = \"AnyoneCore roster is unavailable\"\n    end\nend\nif gLj_Toolbox.rosterError then GUI:Text(gLj_Toolbox.rosterError) end\n\nGUI:Spacing()\nlocal profilerClicked = GUI:Button(\"Profiler\", 95, 20)\n    toolboxHover(\"Open the performance profiler to see which features take time to run.\")\nGUI:SameLine()\nlocal acrOptionsClicked = GUI:Button(\"ACR Options\", 95, 20)\n    toolboxHover(\"Open the settings for your current combat routine.\")\nGUI:SameLine()\nlocal devMonitorClicked = GUI:Button(\"Dev Monitor\", 95, 20)\n    toolboxHover(\"Show or hide AnyoneCore's developer monitor for live game information and debugging.\")\nif profilerClicked and Profiler and Profiler.open then\n    Profiler.open()\nend\nif acrOptionsClicked and ACR and ACR.OpenProfileOptions then\n    ACR.OpenProfileOptions()\nend\nif devMonitorClicked and AnyoneCore and AnyoneCore.Settings then\n    AnyoneCore.Settings.DevMonitor = not AnyoneCore.Settings.DevMonitor\nend\nif AnyoneCore and AnyoneCore.Settings and AnyoneCore.Settings.DutyHelper then\n    AnyoneCore.Settings.DutyHelper.enabled = GUI:Checkbox(\"DutyHelper\", AnyoneCore.Settings.DutyHelper.enabled == true)\n    toolboxHover(\"Enable or disable AnyoneCore's duty-specific assistance.\")\n    GUI:SameLine()\nend\nlocal reactionSettings = AnyoneCore and AnyoneCore.Settings and AnyoneCore.Settings.Reactions\ngStartCombat = GUI:Checkbox(\"Combat\", gStartCombat)\n    toolboxHover(\"Allow the combat routine to use combat actions. Turn this off to pause combat actions.\")\nlocal prepullHelper = AnyoneCore and AnyoneCore.Settings and AnyoneCore.Settings.PrepullHelper\nif prepullHelper then\n    GUI:SameLine()\n    prepullHelper.enabled = GUI:Checkbox(\"Prepull Helper\", prepullHelper.enabled == true)\n    toolboxHover(\"Enable or disable AnyoneCore's helper for preparation before a pull.\")\nend\n\nGUI:Spacing()\nlocal slidecastEnabled = TensorDrift_SlidecastEnabled == true\nlocal slidecastMode = tostring(TensorDrift_SlidecastMode or \"off\"):lower()\nlocal slideButtonActive = slidecastEnabled and slidecastMode == \"slide\"\nlocal stutterButtonActive = slidecastEnabled and slidecastMode == \"stutter\"\nlocal slidecastOffHold = TensorDrift_SlidecastForceHold == true\nlocal slidecastDisableHold = TensorDrift_SlidecastDisableHold == true\nlocal offButtonActive = (not slidecastEnabled) or slidecastMode == \"off\" or slidecastOffHold or slidecastDisableHold\n\nlocal function drawSlidecastButton(label, mode, active)\n    GUI:PushStyleColor(GUI.Col_Button, 0.38, 0.10, 0.10, 1.0)\n    GUI:PushStyleColor(GUI.Col_ButtonHovered, 0.52, 0.16, 0.16, 1.0)\n    GUI:PushStyleColor(GUI.Col_ButtonActive, 0.30, 0.06, 0.06, 1.0)\n    if active then\n        GUI:PushStyleColor(GUI.Col_Button, 0.20, 0.65, 0.25, 1.0)\n        GUI:PushStyleColor(GUI.Col_ButtonHovered, 0.25, 0.75, 0.30, 1.0)\n        GUI:PushStyleColor(GUI.Col_ButtonActive, 0.15, 0.55, 0.20, 1.0)\n    end\n    local pressed = GUI:Button(label, 65, 20)\n    local hints = {\n        slide = \"Enable Slide mode in TensorDrift's casting movement helper. Green means this mode is selected.\",\n        stutter = \"Enable Stutter mode in TensorDrift's casting movement helper. Green means this mode is selected.\",\n        off = \"Disable TensorDrift's slidecasting helper.\"\n    }\n    toolboxHover(hints[mode])\n    GUI:PopStyleColor(active and 6 or 3)\n    if pressed then\n        if mode == \"off\" then\n            TensorDrift_SlidecastEnabled = false\n        else\n            TensorDrift_SlidecastEnabled = true\n            TensorDrift_SlidecastMode = mode\n        end\n    end\nend\n\ndrawSlidecastButton(\"Slide\", \"slide\", slideButtonActive)\nGUI:SameLine()\ndrawSlidecastButton(\"Stutter\", \"stutter\", stutterButtonActive)\nGUI:SameLine()\ndrawSlidecastButton(\"Off\", \"off\", offButtonActive)\nGUI:SameLine()\nlocal mapIDPlayer = TensorCore.mGetPlayer()\nlocal mapID = mapIDPlayer and mapIDPlayer.localmapid or 0\nGUI:Text(\"MapID: \" .. tostring(mapID))\n\nGUI:Spacing()\nif gLj_Toolbox and gLj_Toolbox.Constants and gLj_Toolbox.Settings and gLj_Toolbox.UpdateRoleOptions then\n    local roleOptions, roleType = gLj_Toolbox.UpdateRoleOptions()\n    local currentRole = roleOptions and roleOptions[gLj_Toolbox.Settings.selectedRole] or \"Role\"\n    local roleColor = gLj_Toolbox.Constants.ROLE_COLORS and gLj_Toolbox.Constants.ROLE_COLORS[roleType]\n    GUI:Text(\"Role: \")\n    GUI:SameLine()\n    GUI:PushStyleVar(GUI.StyleVar_FramePadding, 4, 2)\n    if roleColor then GUI:PushStyleColor(GUI.Col_Button, roleColor[1], roleColor[2], roleColor[3], roleColor[4]) end\n    local roleClicked = GUI:Button(currentRole .. (gLj_Toolbox.Constants.ROLE_BUTTON_ID or \"##JacobRoleButton\"), gLj_Toolbox.Constants.ROLE_BTN_WIDTH or 155, gLj_Toolbox.Constants.ROLE_BTN_HEIGHT or 18)\n    toolboxHover(\"Left-click to choose your Toolbox role. Right-click to show or hide Toolbox party assignments. Use Roster for AnyoneCore's separate role assignments.\")\n    local roleRightClicked = GUI:IsItemHovered() and GUI:IsMouseClicked(1)\n    if roleColor then GUI:PopStyleColor() end\n    GUI:PopStyleVar()\n\n    local rolePopupID = \"JacobRoleSelectPopup\"\n    if roleClicked then GUI:OpenPopup(rolePopupID) end\n    if roleRightClicked then gLj_Toolbox.Settings.showPartyAssigner = not gLj_Toolbox.Settings.showPartyAssigner end\n\n    if GUI:BeginPopup(rolePopupID) then\n        for i, role in ipairs(roleOptions or {}) do\n            if GUI:MenuItem(role) then\n                gLj_Toolbox.Settings.selectedRole = i\n                local localPlayer = TensorCore.mGetPlayer()\n                if localPlayer and localPlayer.name then\n                    for n, r in pairs(gLj_Toolbox.Settings.partyRoles) do\n                        if n == localPlayer.name then gLj_Toolbox.Settings.partyRoles[n] = nil end\n                    end\n                    for name, r in pairs(gLj_Toolbox.Settings.partyRoles) do\n                        if r == role then\n                            gLj_Toolbox.Settings.partyRoles[name] = \"None\"\n                            local pJob = nil\n                            if gLj_Toolbox.Cache and gLj_Toolbox.Cache.sortedParty then\n                                for _, e in ipairs(gLj_Toolbox.Cache.sortedParty) do\n                                    if e.name == name then pJob = e.job break end\n                                end\n                            end\n                            if pJob and gLj_Toolbox.SaveProfile then gLj_Toolbox.SaveProfile(name, pJob, \"None\") end\n                        end\n                    end\n                    gLj_Toolbox.Settings.partyRoles[localPlayer.name] = role\n                    if gLj_Toolbox.SaveProfile then gLj_Toolbox.SaveProfile(localPlayer.name, localPlayer.job, role) end\n                    local eID = localPlayer.id\n                    if gLj_PartyRoles and gLj_Toolbox.Constants.allRoles then\n                        for _, r in ipairs(gLj_Toolbox.Constants.allRoles) do\n                            if gLj_PartyRoles[r] == eID then\n                                gLj_PartyRoles[r] = 0\n                                if _G[\"gLj_Role_\" .. r] then _G[\"gLj_Role_\" .. r] = 0 end\n                            end\n                        end\n                        gLj_PartyRoles[role] = eID\n                        if _G[\"gLj_Role_\" .. role] then _G[\"gLj_Role_\" .. role] = eID end\n                    end\n                end\n            end\n        end\n        GUI:EndPopup()\n    end\nend\n\nGUI:Spacing()\nlocal assistRunning = FFXIV_Common_BotRunning == true\nlocal assistReady = not FFXIVData_IsReady or FFXIVData_IsReady()\nlocal assistColor = assistRunning and { r = 0, g = 0.10, b = 0, a = 0.75 } or { r = 0.10, g = 0, b = 0, a = 0.75 }\nGUI:PushStyleVar(GUI.StyleVar_ChildWindowRounding, 10)\nGUI:PushStyleColor(GUI.Col_ChildWindowBg, assistColor.r, assistColor.g, assistColor.b, assistColor.a)\nGUI:BeginChild(\"##JacobAssist\", 120, 40, true)\nGUI:AlignFirstTextHeightToWidgets()\nGUI:Text(\"Assist\")\nGUI:EndChild()\ntoolboxHover(\"Start or stop Minion's current bot mode. Green means it is running.\")\nif assistReady and GUI:IsItemHovered() and GUI:IsMouseClicked(0) then\n    ffxivminion.DutyCurrentData = {}\n    ml_global_information.ToggleRun()\nend\nGUI:PopStyleColor()\nGUI:PopStyleVar()\n\nGUI:SameLine()\nlocal waymarksClicked = GUI:Button(\"Waymarks\", 95, 40)\n    toolboxHover(\"Show or hide AnyoneCore's saved arena waymark presets.\")\nif waymarksClicked and AnyoneCore and AnyoneCore.Data then\n    AnyoneCore.Data.waymarkPresets = not (AnyoneCore.Data.waymarkPresets == true)\nend\n\nGUI:SameLine()\nlocal jobSwapClicked = GUI:Button(\"Jobs\", 65, 40)\n    toolboxHover(\"Choose one of your saved gear sets to switch jobs.\")\nif jobSwapClicked then\n    GUI:OpenPopup(\"JacobJobSwapPopup\")\nend\nGUI:PushStyleColor(GUI.Col_PopupBg, 0.025, 0.07, 0.11, 1.0)\nif GUI:BeginPopup(\"JacobJobSwapPopup\") then\n    local refreshGearSets = GUI:Button(\"Refresh\", 70, 20)\n    toolboxHover(\"Reload the list of saved gear sets shown in this menu.\")\n    if refreshGearSets then\n        jobSwap.loadGearSets = nil\n    end\n    GUI:Spacing()\n\n    local function drawGearSetMenu(label, category, red, green, blue)\n        local textRed = math.min(red + 0.25, 1.0)\n        local textGreen = math.min(green + 0.25, 1.0)\n        local textBlue = math.min(blue + 0.25, 1.0)\n        GUI:PushStyleColor(GUI.Col_Header, red, green, blue, 1.0)\n        GUI:PushStyleColor(GUI.Col_HeaderHovered, math.min(red + 0.12, 1.0), math.min(green + 0.12, 1.0), math.min(blue + 0.12, 1.0), 1.0)\n        GUI:PushStyleColor(GUI.Col_HeaderActive, red * 0.78, green * 0.78, blue * 0.78, 1.0)\n        GUI:PushStyleColor(GUI.Col_Text, textRed, textGreen, textBlue, 1.0)\n        local categoryIconPath = jobSwap.roleIconPathByCategory[category]\n        if categoryIconPath then\n            GUI:Image(categoryIconPath, 16, 16)\n            GUI:SameLine()\n        end\n        local menuOpen = GUI:BeginMenu(string.upper(label))\n        toolboxHover(\"Show saved \" .. label:lower() .. \" gear sets.\")\n        GUI:PopStyleColor(4)\n        if menuOpen then\n            local grouped = {}\n            local jobNames = {}\n            for _, gearSet in ipairs(jobSwap.list or {}) do\n                if gearSet.category == category then\n                    local jobName = gearSet.jobName or \"Unknown\"\n                    if not grouped[jobName] then\n                        grouped[jobName] = {}\n                        jobNames[#jobNames + 1] = jobName\n                    end\n                    grouped[jobName][#grouped[jobName] + 1] = gearSet\n                end\n            end\n            local function drawJobMenu(jobName)\n                if not grouped[jobName] then\n                    return false\n                end\n                local firstGearSet = grouped[jobName][1]\n                local iconPath = firstGearSet and jobSwap.jobIconPathById[firstGearSet.jobID] or nil\n                GUI:BeginGroup()\n                if iconPath then\n                    GUI:Image(iconPath, 16, 16)\n                    GUI:SameLine()\n                end\n                local jobOpen = GUI:BeginMenu(jobName)\n                toolboxHover(\"Show your saved \" .. jobName .. \" gear sets.\")\n                if jobOpen then\n                    table.sort(grouped[jobName], function(left, right)\n                        if left.name ~= right.name then return left.name < right.name end\n                        return (tonumber(left.index) or 0) < (tonumber(right.index) or 0)\n                    end)\n                    for _, gearSet in ipairs(grouped[jobName]) do\n                        local menuLabel = gearSet.name .. \"##JacobGearSet\" .. tostring(gearSet.index)\n                        if GUI:MenuItem(menuLabel) then\n                            SendTextCommand(\"/gs equip \" .. tostring(gearSet.index))\n                        end\n                        toolboxHover(\"Equip gear set: \" .. gearSet.name .. \". This switches to its saved job and equipment.\")\n                    end\n                    GUI:EndMenu()\n                end\n                GUI:EndGroup()\n                return true\n            end\n\n            local jobNameGroups = {}\n            if category == \"DPS\" then\n                jobNameGroups = {\n                    { \"Machinist\", \"Dancer\", \"Bard\" },\n                    { \"Monk\", \"Dragoon\", \"Ninja\", \"Samurai\", \"Reaper\", \"Viper\" },\n                    { \"Black Mage\", \"Arcanist\", \"Summoner\", \"Red Mage\", \"Pictomancer\" }\n                }\n            else\n                local sortedJobNames = {}\n                for _, jobName in ipairs(jobNames) do\n                    sortedJobNames[#sortedJobNames + 1] = jobName\n                end\n                table.sort(sortedJobNames)\n                jobNameGroups = { sortedJobNames }\n            end\n\n            local renderedGroup = false\n            for _, group in ipairs(jobNameGroups) do\n                local groupHasJobs = false\n                for _, jobName in ipairs(group) do\n                    if grouped[jobName] then\n                        groupHasJobs = true\n                        break\n                    end\n                end\n                if groupHasJobs then\n                    if renderedGroup then\n                        GUI:Separator()\n                    end\n                    for _, jobName in ipairs(group) do\n                        drawJobMenu(jobName)\n                    end\n                    renderedGroup = true\n                end\n            end\n            if #jobNames == 0 then\n                GUI:Text(\"No gear sets.\")\n            end\n            GUI:EndMenu()\n        end\n    end\n\n    drawGearSetMenu(\"DPS\", \"DPS\", 0.55, 0.12, 0.12)\n    drawGearSetMenu(\"Healer\", \"Healer\", 0.12, 0.50, 0.20)\n    drawGearSetMenu(\"Tank\", \"Tank\", 0.12, 0.30, 0.60)\n    drawGearSetMenu(\"Crafters\", \"Crafters\", 0.55, 0.30, 0.10)\n    drawGearSetMenu(\"Gatherers\", \"Gatherers\", 0.34, 0.20, 0.55)\n    drawGearSetMenu(\"Limited jobs\", \"Limited jobs\", 0.28, 0.28, 0.30)\n    GUI:EndPopup()\nend\nGUI:PopStyleColor()\n\nif clicked and AnyoneCore then\n    local isReactionsOpen = AnyoneCore.open and AnyoneCore.selectedTab == \"Reactions\"\n    AnyoneCore.open = not isReactionsOpen\n    if AnyoneCore.open then\n        AnyoneCore.selectedTab = \"Reactions\"\n    end\nend\nend\njacobProcessWikiWaymarkImport()\nGUI:End()\nGUI:PopStyleColor(2)\n\nif jacobCustomDrawMonitorOpen == true then\n    GUI:SetNextWindowSize(620, 420, GUI.SetCond_FirstUseEver)\n    local drawMonitorVisible, drawMonitorOpen = GUI:Begin(\"Custom Draw Monitor\", jacobCustomDrawMonitorOpen, GUI.WindowFlags_NoCollapse)\n    jacobCustomDrawMonitorOpen = drawMonitorOpen == true\n    if drawMonitorVisible then\n        local drawCount = Argus.getNumTimedDraws()\n        GUI:Text(\"Active Argus timed draws: \" .. tostring(drawCount))\n        GUI:Text(\"Argus does not report the source reaction; inspect each UUID, timing, color, and shape.\")\n        GUI:Separator()\n        GUI:BeginChild(\"##JacobCustomDrawList\", 0, 330, true)\n        if drawCount == 0 then\n            GUI:Text(\"No timed draws are active.\")\n        else\n            for index = 1, drawCount do\n                local shape, x, y, z, startTime, duration, delay, uuid, colorStart, colorEnd =\n                    Argus.getTimedDrawBaseInfo(index)\n                local entityAttach, targetAttach, keepLength, keepHeading, headingOffset, colorMid, colorOutline, outlineThickness =\n                    Argus.getTimedDrawOptArgs(index)\n                if uuid ~= nil then\n                    GUI:Text(tostring(index) .. \". \" .. tostring(shape) .. \"  UUID: \" .. tostring(uuid))\n                    GUI:Text(\"Position: \" .. tostring(x) .. \", \" .. tostring(y) .. \", \" .. tostring(z)\n                        .. \"  start=\" .. tostring(startTime) .. \" duration=\" .. tostring(duration)\n                        .. \" delay=\" .. tostring(delay))\n                    GUI:Text(\"Attach: \" .. tostring(entityAttach) .. \" -> \" .. tostring(targetAttach)\n                        .. \"  colors start/mid/end: \" .. tostring(colorStart) .. \"/\"\n                        .. tostring(colorMid) .. \"/\" .. tostring(colorEnd))\n                    GUI:Text(\"Outline: \" .. tostring(colorOutline) .. \"  thickness=\" .. tostring(outlineThickness)\n                        .. \"  headingOffset=\" .. tostring(headingOffset)\n                        .. \"  keepLength=\" .. tostring(keepLength) .. \" keepHeading=\" .. tostring(keepHeading))\n                    local geometryText = nil\n                    if shape == \"arrow\" then\n                        local length, width, tipLength, tipWidth, heading = Argus.getTimedArrowInfo(index)\n                        geometryText = \"Arrow length=\" .. tostring(length) .. \" width=\" .. tostring(width)\n                            .. \" tip=\" .. tostring(tipLength) .. \"x\" .. tostring(tipWidth)\n                            .. \" heading=\" .. tostring(heading)\n                    elseif shape == \"circle\" then\n                        local radius, segments = Argus.getTimedCircleInfo(index)\n                        geometryText = \"Circle radius=\" .. tostring(radius) .. \" segments=\" .. tostring(segments)\n                    elseif shape == \"rect\" then\n                        local length, width, heading = Argus.getTimedRectInfo(index)\n                        geometryText = \"Rect length=\" .. tostring(length) .. \" width=\" .. tostring(width)\n                            .. \" heading=\" .. tostring(heading)\n                    elseif shape == \"centeredrect\" then\n                        local length, width, heading = Argus.getTimedCenteredRectInfo(index)\n                        geometryText = \"Centered rect length=\" .. tostring(length) .. \" width=\" .. tostring(width)\n                            .. \" heading=\" .. tostring(heading)\n                    elseif shape == \"cone\" then\n                        local radius, angle, heading = Argus.getTimedConeInfo(index)\n                        geometryText = \"Cone radius=\" .. tostring(radius) .. \" angle=\" .. tostring(angle)\n                            .. \" heading=\" .. tostring(heading)\n                    elseif shape == \"donut\" then\n                        local inner, outer = Argus.getTimedDonutInfo(index)\n                        geometryText = \"Donut inner=\" .. tostring(inner) .. \" outer=\" .. tostring(outer)\n                    elseif shape == \"donutcone\" then\n                        local inner, outer, angle, heading = Argus.getTimedDonutConeInfo(index)\n                        geometryText = \"Donut cone inner=\" .. tostring(inner) .. \" outer=\" .. tostring(outer)\n                            .. \" angle=\" .. tostring(angle) .. \" heading=\" .. tostring(heading)\n                    elseif shape == \"cross\" then\n                        local length, width, heading = Argus.getTimedCrossInfo(index)\n                        geometryText = \"Cross length=\" .. tostring(length) .. \" width=\" .. tostring(width)\n                            .. \" heading=\" .. tostring(heading)\n                    elseif shape == \"linesegment\" then\n                        local x2, y2, z2, endpointThickness = Argus.getTimedLineSegmentInfo(index)\n                        geometryText = \"Line end=\" .. tostring(x2) .. \", \" .. tostring(y2) .. \", \" .. tostring(z2)\n                            .. \" endThickness=\" .. tostring(endpointThickness)\n                    elseif shape == \"chevron\" then\n                        local length, thickness, heading = Argus.getTimedChevronInfo(index)\n                        geometryText = \"Chevron length=\" .. tostring(length) .. \" thickness=\" .. tostring(thickness)\n                            .. \" heading=\" .. tostring(heading)\n                    end\n                    if geometryText then GUI:Text(geometryText) end\n                    GUI:Separator()\n                end\n            end\n        end\n        GUI:EndChild()\n        if GUI:Button(\"Close\", 90, 22) then\n            jacobCustomDrawMonitorOpen = false\n        end\n    end\n    GUI:End()\nend\n\nif jacobWikiWaymarkState.phase == \"fetching\" or jacobWikiWaymarkState.phase == \"importing\" or jacobWikiWaymarkState.phase == \"complete\" then\n    GUI:Begin(\"Jacob's Waymark Import\", true, GUI.WindowFlags_AlwaysAutoResize)\n    GUI:Text(\"Wiki preset import\")\n    if jacobWikiWaymarkState.phase == \"fetching\" then\n        GUI:Text(\"Loading wiki pages...\")\n        GUI:Text(\"Pages loaded: \" .. tostring(jacobWikiWaymarkState.fetched) .. \" / \" .. tostring(#jacobWikiWaymarkState.queue))\n    elseif jacobWikiWaymarkState.phase == \"importing\" then\n        GUI:Text(\"Importing presets into AnyoneCore...\")\n        GUI:Text(\"Added: \" .. tostring(jacobWikiWaymarkState.imported) .. \"  Duplicates: \" .. tostring(jacobWikiWaymarkState.duplicates) .. \"  Failed: \" .. tostring(jacobWikiWaymarkState.failed))\n    else\n        GUI:Text(\"Import complete.\")\n        GUI:Text(\"Added: \" .. tostring(jacobWikiWaymarkState.imported) .. \"  Duplicates: \" .. tostring(jacobWikiWaymarkState.duplicates) .. \"  Failed: \" .. tostring(jacobWikiWaymarkState.failed))\n        if jacobWikiWaymarkState.failedPages > 0 then GUI:Text(\"Pages unavailable: \" .. tostring(jacobWikiWaymarkState.failedPages)) end\n    end\n    GUI:ProgressBar(jacobWikiWaymarkState.progress, 300, 12, string.format(\"%d%%\", math.floor(jacobWikiWaymarkState.progress * 100)))\n    GUI:Text(jacobWikiWaymarkState.status or \"\")\n    if jacobWikiWaymarkState.phase == \"complete\" then\n        if GUI:Button(\"Close\", 90, 20) then jacobWikiWaymarkState.phase = \"idle\" end\n    elseif GUI:Button(\"Cancel\", 90, 20) then\n        jacobWikiWaymarkState.phase, jacobWikiWaymarkState.pending = \"cancelled\", false\n        jacobWikiWaymarkState.status = \"Import cancelled.\"\n    end\n    GUI:End()\nend\n\nif AnyoneCore and AnyoneCore.Data and AnyoneCore.Data.autoMelderOpen == true and AnyoneCore.DrawAutomelder then\n    AnyoneCore.DrawAutomelder()\nend\n\n\n\nself.used = true\n\n-- Embedded in Jacob's Toolbox OnDraw action. Inventory API: Minion Dev/dev.lua;\n-- carried/armoury containers: ffxivminion/ffxiv_common_cne.lua.\nif not JacobGearPlanner or JacobGearPlanner.version~=25 then\n local previous=JacobGearPlanner\n local P={version=25,tab=1,job='All',fight='All',search='',page=1,owned={},hq={},currency={},locations={},catalog=nil,status='Open the planner to load the catalog.'}\n P.storageVisited=previous and previous.storageVisited or false\n P.dresserVisitIdentity=previous and previous.dresserVisitIdentity\n JacobGearPlanner=P\n local root=GetStartupPath()..[[\\LuaMods\\JacobGearPlanner\\]]\n local configPath=root..'preferences.json'\n local function readJSON(path)\n  local f=io.open(path,'r');if not f then return nil end\n  local text=f:read('*a');f:close();return AnyoneCore.JSON.decode(text)\n end\n local slots={'Weapon','OffHand','Head','Body','Hand','Legs','Feet','Ears','Neck','Wrist','RingLeft','RingRight'}\n local fights={'All','UCOB','UWU','TEA','DSR','TOP','FRU','DMU','General'}\n local jobs={'All','PLD','WAR','DRK','GNB','WHM','SCH','AST','SGE','MNK','DRG','NIN','SAM','RPR','VPR','BRD','MCH','DNC','BLM','SMN','RDM','PCT','BST','BLU'}\n local function help(s)if GUI:IsItemHovered()then GUI:SetTooltip(s)end end\n local function button(s,tip,w)local b=GUI:Button(s,w or 110,22);if tip then help(tip)end;return b end\n local function label(s)GUI:Text(tostring(s or''))end\n local function copy(s)GUI:SetClipboardText(s);P.status='Copied to clipboard.'end\n local function choose(label,value,values)\n  local index=1;for i,v in ipairs(values)do if v==value then index=i;break end end\n  GUI:PushItemWidth(220);local n=GUI:Combo(label,index,values);GUI:PopItemWidth();return values[n]or value\n end\n function P.exportPlan()\n  if not P.catalog or not P.prefs or not P.storageIdentity then return end\n  local selected={};for id,on in pairs(P.prefs.plan or{})do local set=on and P.byID[id];if set then for _,it in pairs(set.items)do\n   if it.id and it.id>0 then selected[it.id]=true end\n   for _,alt in ipairs(it.alternatives or{})do selected[alt]=true end\n  end end end\n  local ids={};for id in pairs(selected)do ids[#ids+1]=id end;table.sort(ids)\n  local text=json.encode({schemaVersion=1,character=P.storageIdentity,highlight=P.prefs.highlight==true,itemIds=ids})\n  if text==P.exportedPlan then return end\n  local f=io.open(root..'plan.json','w');if f then f:write(text);f:close();P.exportedPlan=text end\n end\n function P.importArmoire()\n  local ok,snapshot=pcall(readJSON,root..'armoire.json')\n  if not ok or type(snapshot)~='table'or snapshot.schemaVersion~=1 or snapshot.complete~=true or snapshot.character~=P.storageIdentity or type(snapshot.itemIds)~='table'or type(snapshot.scannedAt)~='number'then return end\n  local st=P.storageAll[P.storageIdentity]\n  if st.armoire and st.armoire.scannedAt>=snapshot.scannedAt then return end\n  local ids={};for _,id in ipairs(snapshot.itemIds)do if type(id)~='number'or id<=0 or id%1~=0 then return end;ids[id]=true end\n  st.armoire={items=ids,scannedAt=snapshot.scannedAt,complete=true}\n  local f=io.open(root..'storage.json','w');if f then f:write(json.encode(P.storageAll));f:close()end\n  if P.catalog then P.scan()end\n end\n function P.save()\n  local ok,err=pcall(function()\n   local text=json.encode(P.prefs);local f,e=io.open(configPath,'w');assert(f,e);assert(f:write(text));assert(f:close())\n  end)\n  P.exportPlan()\n  P.status=ok and'Saved preferences.'or('Could not save: '..tostring(err))\n end\n function P.scan()\n  local player=TensorCore.mGetPlayer()\n  if player and player.incombat and P.scanAt then P.status='Rescan after combat; current snapshot retained.';return end\n  P.owned={};P.hq={};P.locations={};P.currency={};P.resolved={};P.filterKey=nil;P.scanAt=Now()\n  for _,id in ipairs({0,1,2,3,1000,3200,3201,3202,3203,3204,3205,3206,3207,3208,3209,3300,3400,3500,2000,2001,4000,4001,4100,4101})do\n   local bag=Inventory:Get(id)\n   if bag then for _,it in pairs(bag:GetList()or{})do\n    if it.id and it.id>0 then\n     local iid=it.id%1000000;local count=it.count or 1\n     P.owned[iid]=(P.owned[iid]or 0)+count\n     if it.ishq then P.hq[iid]=(P.hq[iid]or 0)+count end\n     local bagName=id<=3 and('Inventory page '..(id+1))or ({[1000]='Equipped',[2000]='Currency pouch',[2001]='Crystals',[4000]='Saddlebag page 1',[4001]='Saddlebag page 2',[4100]='Premium saddlebag page 1',[4101]='Premium saddlebag page 2'})[id]or('Armoury container '..id)\n     local loc=bagName..(it.slot~=nil and(' / slot '..(it.slot+1))or'')..' / '..count..(it.ishq and' HQ'or'')\n     P.locations[iid]=P.locations[iid]or{};P.locations[iid][#P.locations[iid]+1]=loc\n    end\n   end end\n  end\n  for _,cur in pairs(Inventory:GetSpecialCurrencies()or{})do\n   P.currency[cur.itemid]=cur.count\n   if cur.count>0 then P.locations[cur.itemid]=P.locations[cur.itemid]or{};P.locations[cur.itemid][#P.locations[cur.itemid]+1]='Currency window / '..cur.count end\n  end\n  local cache=P.storageAll and P.storageIdentity and P.storageAll[P.storageIdentity]\n  local armoire=cache and cache.armoire\n  if armoire and armoire.complete then for key in pairs(armoire.items or{})do local id=tonumber(key);if id then\n   P.owned[id]=(P.owned[id]or 0)+1;P.locations[id]=P.locations[id]or{};P.locations[id][#P.locations[id]+1]='Armoire (cached '..os.date('%d-%m %H:%M',armoire.scannedAt)..')'\n  end end end\n  local dresser=cache and cache.dresser\n  if dresser and dresser.complete then for _,it in ipairs(dresser.items)do\n   P.owned[it.id]=(P.owned[it.id]or 0)+1;if it.hq then P.hq[it.id]=(P.hq[it.id]or 0)+1 end\n   P.locations[it.id]=P.locations[it.id]or{};P.locations[it.id][#P.locations[it.id]+1]='Glamour dresser / '..(({[0]='Weapons',[1]='Shields',[2]='Head',[3]='Body',[4]='Hands',[5]='Legs',[6]='Feet',[7]='Earrings',[8]='Necklaces',[9]='Bracelets',[10]='Rings'})[it.tab]or('tab '..it.tab))..' / page '..it.page..' / slot '..it.slot..' (cached '..os.date('%d-%m %H:%M',dresser.scannedAt)..')'\n  end end\n  P.cachedOwned={}\n  for retainer,snapshot in pairs(cache and cache.retainers or{})do local available=not cache.retainerRoster or(cache.retainerRoster[retainer]and cache.retainerRoster[retainer].active==true);if available then for _,it in ipairs(snapshot.items or{})do if not it.listed then\n   local id=it.id;local count=it.count\n   P.owned[id]=(P.owned[id]or 0)+count;P.cachedOwned[id]=(P.cachedOwned[id]or 0)+count\n   if it.hq then P.hq[id]=(P.hq[id]or 0)+count end\n   local container=it.bag<=10006 and('Inventory page '..(it.bag-9999))or({[11000]='Equipped',[12000]='Gil',[12001]='Crystals'})[it.bag]or('Container '..it.bag)\n   P.locations[id]=P.locations[id]or{};P.locations[id][#P.locations[id]+1]='Retainer '..retainer..' / '..container..' / slot '..it.slot..' / '..count..(it.hq and' HQ'or'')..' (cached '..os.date('%d-%m %H:%M',snapshot.scannedAt)..')'\n  end end end end\n  P.status='Snapshot refreshed. Saddlebag counts require its contents to be loaded; open it and rescan. Retainer/dresser visit caches included when available. Listed market items excluded.'\n end\n function P.load()\n  local ok,c=pcall(readJSON,root..'catalog.json')\n  if not ok or type(c)~='table'or type(c.sets)~='table'then P.status='Catalog unavailable; check catalog.json and reload.';return false end\n  P.catalog=c;P.byID={};P.resolved={}\n  for _,s in ipairs(c.sets)do P.byID[s.id]=s end\n  local good,prefs=pcall(readJSON,configPath)\n  P.prefs=good and type(prefs)=='table'and prefs or{}\n  P.prefs.plan=P.prefs.plan or{};P.prefs.food=P.prefs.food or{};P.prefs.sources=P.prefs.sources or{};P.prefs.personal=P.prefs.personal or{}\n  for _,s in ipairs(P.prefs.personal)do if not P.byID[s.id]then c.sets[#c.sets+1]=s;P.byID[s.id]=s end end\n  P.scan();return true\n end\n local function stable(v)\n  if type(v)~='table'then return type(v)..':'..tostring(v)end\n  local keys={};for k in pairs(v)do keys[#keys+1]=k end;table.sort(keys,function(a,b)return tostring(a)<tostring(b)end)\n  local out={};for _,k in ipairs(keys)do out[#out+1]=stable(k)..'='..stable(v[k])end;return'{'..table.concat(out,';')..'}'\n end\n local function signature(s)\n  local items={};local rings={}\n  for slot,it in pairs(s.items)do\n   local m={};for _,id in ipairs(it.materia or{})do if id>0 then m[#m+1]=id end end;table.sort(m)\n   local rs={};for k,v in pairs(it.relicStats or{})do if v~=0 then rs[k]=v end end\n   local x={id=it.id,materia=m,relicStats=rs,custom=it.custom,unresolvedRelic=it.unresolvedRelic}\n   if it.custom then x.id=nil end\n   if slot=='RingLeft'or slot=='RingRight'then rings[#rings+1]=stable(x)else items[slot]=x end\n  end\n  table.sort(rings);items.Rings=rings\n  return stable({job=s.job,level=s.level,sync=s.sync,food=s.food,items=items})\n end\n function P.import(url,job,fight)\n  if P.busy then P.status='An import is already running.';return end\n  local host,path,provider,key\n  key=url:match('etro%.gg/gearset/([%x%-]+)')\n  if key and #key==36 then host='etro.gg';path='/api/gearsets/'..key..'/';provider='etro'\n  else\n   local decoded=url:gsub('%%7[Cc]','|'):gsub('%%2[Ff]','/')\n   if not(decoded:match('^https://xivgear%.app/')or decoded:match('^https://share%.xivgear%.app/'))then P.status='Use a public XIVGear or Etro set link.';return end\n   key=decoded:match('sl[/|]+([%x%-]+)')or decoded:match('/share/([%x%-]+)')\n   if key and #key==36 then host='api.xivgear.app';path='/shortlink/'..key;provider='xivgear'\n   else\n    key=decoded:match('bis[/|]([%w/_|%-]+)')\n    if not key then P.status='Unsupported link. Use a shared sheet/set or a specific BiS sheet.';return end\n    key=key:gsub('|','/');host='api.xivgear.app';path='/fulldata/bis/'..key;provider='xivgear-bis'\n   end\n  end\n  P.busy=true;P.status='Importing public gear sheet...'\n  local function request(h,p,callback)\n   HttpRequest({host=h,path=p,port=443,method='GET',https=true,\n    onsuccess=function(body,_,status)\n     if status~=200 then P.busy=false;P.status='Import HTTP '..tostring(status);return end\n     local ok,data=pcall(AnyoneCore.JSON.decode,body)\n     if not ok or type(data)~='table'then P.busy=false;P.status='Provider returned invalid JSON.';return end\n     local good,err=pcall(callback,data);if not good then P.busy=false;P.status='Import failed: '..tostring(err)end\n    end,\n    onfailure=function(err)P.busy=false;P.status='Import failed: '..tostring(err)end})\n  end\n  request(host,path,function(rootData)\n   local queue={};local extra={}\n   if provider=='etro'then\n    if rootData.food then queue[#queue+1]={kind='food',id=rootData.food}end\n    for _,id in pairs(rootData.relics or{})do queue[#queue+1]={kind='relic',id=id}end\n   end\n   local function finish()\n    local added,merged=0,0;local known={}\n    for _,s in ipairs(P.catalog.sets)do known[signature(s)]=s end\n    for index,row in ipairs(rootData.sets or{rootData})do\n     local items={};local custom={};for _,c in ipairs(rootData.customItems or{})do custom[c.fakeId]=c end\n     if provider=='etro'then\n      local aliases={Weapon='weapon',OffHand='offHand',Head='head',Body='body',Hand='hands',Legs='legs',Feet='feet',Ears='ears',Neck='neck',Wrist='wrists',RingLeft='fingerL',RingRight='fingerR'}\n      local params={['22']='dhit',['27']='crit',['44']='determination',['45']='skillspeed',['46']='spellspeed',['19']='tenacity',['6']='piety'}\n      for slot,k in pairs(aliases)do\n       local id=row[k];local stats={};local rel=(row.relics or{})[k]\n       if rel and extra['relic:'..rel]then local r=extra['relic:'..rel];id=r.baseItemId\n        for i=0,5 do local param=r['param'..i];local val=r['param'..i..'Value'];if param and val and val~=0 then stats[params[tostring(param)]or tostring(param)]=val end end\n       end\n       if id then local mk=tostring(id)..(k=='fingerL'and'L'or k=='fingerR'and'R'or'');local materia={};for _,v in pairs((row.materia or{})[mk]or{})do materia[#materia+1]=v end;table.sort(materia);items[slot]={id=id,materia=materia,relicStats=stats}end\n      end\n     else\n      for slot,it in pairs(row.items or{})do\n       local m={};for _,x in ipairs(it.materia or{})do if x.id and x.id>0 then m[#m+1]=x.id end end;table.sort(m)\n       local c=custom[it.id];local cp\n       if c then cp={};for k,v in pairs(c)do if k~='name'and k~='fakeId'then cp[k]=v end end end\n       items[slot]={id=it.id,materia=m,relicStats=it.relicStats or{},custom=cp,customName=c and c.name}\n      end\n     end\n     if not row.isSeparator and next(items)then\n      local food=row.food;if provider=='etro'and food then food=extra['food:'..food].item end\n      local j=row.job or rootData.jobAbbrev or rootData.job;if type(j)~='string'then j=job end\n      local s={name=row.name or'Imported set',job=j,level=row.level or rootData.level,sync=row.ilvlSync or rootData.ilvlSync or rootData.itemLevelSync,food=food,items=items,fights={fight},sources={{page=url,link=url,title='Personal import',provider=provider,sheet=key,setIndex=index-1,setName=row.name}},sheetName=rootData.name or'',description=row.description or''}\n      local sig=signature(s)\n      if known[sig]then merged=merged+1\n      else\n       s.id='personal:'..provider..':'..key..':'..index;local baseID=s.id;local suffix=1;while P.byID[s.id]do suffix=suffix+1;s.id=baseID..':'..suffix end;known[sig]=s\n       P.prefs.personal[#P.prefs.personal+1]=s;P.catalog.sets[#P.catalog.sets+1]=s;P.byID[s.id]=s;added=added+1\n      end\n     end\n    end\n    P.save();P.busy=false;P.status='Imported '..added..' distinct builds; skipped '..merged..' duplicates. Unknown item names display IDs until catalog refresh.'\n   end\n   local function nextExtra()\n    local q=table.remove(queue,1);if not q then finish();return end\n    request('etro.gg','/api/'..q.kind..'/'..q.id..'/',function(data)extra[q.kind..':'..q.id]=data;nextExtra()end)\n   end\n   nextExtra()\n  end)\n end\n local function name(id)return P.catalog.items[tostring(id)]and P.catalog.items[tostring(id)].name or('Item '..tostring(id))end\n function P.resolve(s)\n  P.resolved=P.resolved or{};if P.resolved[s.id]then return P.resolved[s.id]end\n  local choices,order,owners,result={},{},{},{}\n  for slot,it in pairs(s.items)do if it.id and not it.custom and not it.unresolvedRelic then\n   choices[slot]={it.id};for _,id in ipairs(it.alternatives or{})do choices[slot][#choices[slot]+1]=id end;order[#order+1]=slot\n  end end\n  table.sort(order,function(a,b)return #choices[a]<#choices[b]end)\n  local function assign(slot,seen)\n   for _,id in ipairs(choices[slot])do if not seen[id]then\n    seen[id]=true;local capacity=P.owned[id]or 0;local meta=P.catalog.items[tostring(id)];if meta and meta.unique then capacity=math.min(1,capacity)end\n    owners[id]=owners[id]or{}\n    if #owners[id]<capacity then owners[id][#owners[id]+1]=slot;result[slot]=id;return true end\n    for i,other in ipairs(owners[id])do if assign(other,seen)then owners[id][i]=slot;result[slot]=id;return true end end\n   end end\n   return false\n  end\n  for _,slot in ipairs(order)do assign(slot,{})end\n  P.resolved[s.id]=result;return result\n end\n local function need(s)\n  local n={};local custom=0\n  local resolved=P.resolve(s)\n  for slot,it in pairs(s.items)do if it.custom or it.unresolvedRelic or not it.id or it.id<=0 or it.id>=1000000 then custom=custom+1 else local id=resolved[slot]or it.id;n[id]=(n[id]or 0)+1 end end\n  return n,custom\n end\n function P.count(s)\n  local n,custom=need(s);local have,total=0,custom\n  for id,q in pairs(n)do total=total+q;have=have+math.min(P.owned[id]or 0,q)end\n  return have,total,custom\n end\n function P.filterBuilds()\n  local rows={};local counts={};local ownership=P.prefs.ownership or'All builds'\n  for _,s in ipairs(P.catalog.sets)do\n   local fight=P.fight=='All';for _,f in ipairs(s.fights)do if P.fight==f then fight=true end end\n   if fight and(P.job=='All'or P.job==s.job)and(s.name..' '..(s.sheetName or'')):lower():find(P.search:lower(),1,true)then\n    local have,total,custom=P.count(s);local complete=total>0 and have==total and custom==0\n    if ownership=='All builds'or(ownership=='Fully owned'and complete)or(ownership=='Partly owned'and have>0 and not complete)or(ownership=='No pieces owned'and have==0)or(ownership=='Selected plans'and P.prefs.plan[s.id])then\n     rows[#rows+1]=s;counts[s.id]={have=have,total=total}\n    end\n   end\n  end\n  local mode=P.prefs.sort or'Most owned pieces'\n  table.sort(rows,function(a,b)\n   local x,y=counts[a.id],counts[b.id]\n   if mode=='Highest owned percentage'then local xp=x.total>0 and x.have/x.total or 0;local yp=y.total>0 and y.have/y.total or 0;if xp~=yp then return xp>yp end\n   elseif mode=='Fewest missing pieces'then local xm=x.total-x.have;local ym=y.total-y.have;if xm~=ym then return xm<ym end\n   elseif mode=='Most owned pieces'and x.have~=y.have then return x.have>y.have end\n   if mode~='Name'then local xm=x.total-x.have;local ym=y.total-y.have;if xm~=ym then return xm<ym end end\n   local an,bn=a.job..' '..a.name,b.job..' '..b.name;if an~=bn then return an<bn end;return a.id<b.id\n  end)\n  return rows\n end\n local function selected(s)\n  local changed=false;local v=GUI:Checkbox('Plan##'..s.id,P.prefs.plan[s.id]==true)\n  if v~=(P.prefs.plan[s.id]==true)then P.prefs.plan[s.id]=v or nil;P.filterKey=nil;P.save()end\n end\n local function filters()\n  local old=P.job..P.fight..P.search\n  local auto=GUI:Checkbox('Use current job',P.prefs.autoJob~=false)\n  help('Follow your active job automatically. Turn this off or choose a different job to browse manually.')\n  if auto~=(P.prefs.autoJob~=false)then P.prefs.autoJob=auto;P.save()end\n  if auto then local player=TensorCore.mGetPlayer();local current=player and P.catalog.jobNames and P.catalog.jobNames[tostring(player.job)];if current and current~=''then P.job=current end end\n  local chosen=choose('Job',P.job,jobs)\n  if chosen~=P.job then P.job=chosen;P.prefs.autoJob=false;P.save()end\n  GUI:SameLine();P.fight=choose('Fight',P.fight,fights)\n  help('Fight tags come from the source sheet name; General includes current/progression and unclassified sets. They are not all LPDU-approved sets.')\n  local ownership=choose('Ownership',P.prefs.ownership or'All builds',{'All builds','Fully owned','Partly owned','No pieces owned','Selected plans'})\n  help('Filter builds by the pieces you own, including accepted alternatives and cached storage. Custom templates still need checking.')\n  local sort=choose('Sort',P.prefs.sort or'Most owned pieces',{'Most owned pieces','Fewest missing pieces','Highest owned percentage','Name'})\n  help('Most owned pieces shows builds with the largest owned piece count first. Ties prefer fewer missing pieces, then name.')\n  if ownership~=P.prefs.ownership or sort~=P.prefs.sort then P.prefs.ownership=ownership;P.prefs.sort=sort;P.filterKey=nil;P.page=1;P.save()end\n  GUI:PushItemWidth(450);P.search=GUI:InputText('Search sets',P.search);GUI:PopItemWidth()\n  if old~=P.job..P.fight..P.search then P.page=1 end\n end\n local function detail(s)\n  if button('Back to sets','Return to the catalog.')then P.detail=nil;return end\n  label(s.job..' / '..table.concat(s.fights,', ')..' / '..s.name);selected(s)\n  label('Level '..tostring(s.level or'?')..' | Sync '..tostring(s.sync or'none')..' | '..s.sheetName)\n  label('Ownership checks pieces only. Melds, relic allocation and stat caps still need verification.')\n  GUI:Separator()\n  for _,slot in ipairs(slots)do local it=s.items[slot];if it then\n   local itemName=it.customName or name(it.id)\n   local status=it.custom and'CUSTOM / SYNC TEMPLATE - verify manually'or it.unresolvedRelic and'RELIC REFERENCE UNRESOLVED'or((P.owned[it.id]or 0)>0 and'Piece owned'or'Missing')\n   local accepted=P.resolve(s)[slot]\n   if accepted and accepted~=it.id then status='Alternative owned: '..name(accepted)end\n   label(slot..': '..itemName..'  |  '..status)\n   if it.alternatives and #it.alternatives>0 then\n    label('  Accepted synced alternatives:')\n    for _,id in ipairs(it.alternatives)do GUI:TextColored((P.owned[id]or 0)>0 and 0.3 or 1,(P.owned[id]or 0)>0 and 1 or 0.8,0.4,1,'    '..name(id)..' / owned '..(P.owned[id]or 0))end\n   end\n   local ms={};for _,id in ipairs(it.materia or{})do if type(id)=='number' and id>0 then local m=P.catalog.items[tostring(id)];local text=m and m.name;if text and text~='' and text:lower()~='missing'then ms[#ms+1]=text end end end\n   if #ms>0 then label('  Materia: '..table.concat(ms,', '))end\n   local rs={};for k,v in pairs(it.relicStats or{})do rs[#rs+1]=k..' '..v end;table.sort(rs)\n   if #rs>0 then label('  Relic: '..table.concat(rs,', '))end\n  end end\n  if s.food then label('Recommended food: '..name(s.food))end\n  GUI:Separator();label('Sources (same build may be linked from several guides):')\n  local seen={};for i,r in ipairs(s.sources)do if not seen[r.page..r.link]then\n   seen[r.page..r.link]=true;label(r.title);label(r.setName)\n   if button('Copy source link##'..i,'Copy the original public gear-planner link.')then copy(r.link)end\n   GUI:SameLine();if button('Copy guide link##'..i,'Copy the page that recommended this set.')then copy(r.page)end\n  end end\n end\n function P.plan()\n  local needs={};local custom=0;local count=0\n  for id,on in pairs(P.prefs.plan)do local s=on and P.byID[id];if s then\n   count=count+1;local n,c=need(s);custom=custom+c\n   for item,q in pairs(n)do\n    local v=needs[item]or{quantity=0,sets={}};needs[item]=v\n    v.quantity=math.max(v.quantity,q);v.sets[#v.sets+1]=s.job..' / '..table.concat(s.fights,', ')..' / '..s.name\n   end\n  end end\n  return needs,count,custom\n end\n local function drawPlan()\n  if button('Refresh items','Rescan your readable inventory, quantities and locations, then reapply saved storage snapshots. Open retainers and the dresser to refresh their cached contents.',150)then P.scan()end\n  GUI:Separator()\n  local highlight=GUI:Checkbox('Highlight planned items in containers',P.prefs.highlight==true)\n  help('Requires Gear Sets Companion in Dalamud. Shows green outlines on supported visible inventory slots, including accepted alternatives. Does not move items.')\n  if highlight~=(P.prefs.highlight==true)then P.prefs.highlight=highlight;P.save()end\n  label('Selected plans')\n  local plans={};for id,on in pairs(P.prefs.plan)do if on and P.byID[id]then plans[#plans+1]=P.byID[id]end end\n  table.sort(plans,function(a,b)return a.job..a.name..a.id<b.job..b.name..b.id end)\n  if #plans==0 then label('No sets selected. Choose Plan beside a set in Fights / Sets.')end\n  for _,s in ipairs(plans)do\n   if button('x##removePlan'..s.id,'Unselect this set from your plan. It stays in the catalog.',24)then P.prefs.plan[s.id]=nil;P.save()end\n   GUI:SameLine();label(s.job..' / '..table.concat(s.fights,', ')..' / '..s.name)\n  end\n  GUI:Separator()\n  local needs,count,custom=P.plan();label(count..' sets planned. Shared items counted once; duplicate rings require two copies.')\n  label('Custom/synced item templates to verify manually: '..custom)\n  local hide=GUI:Checkbox('Hide owned items',P.prefs.hideOwned==true)\n  help('Hide pieces for which you already own the required quantity. This preference is saved.')\n  if hide~=(P.prefs.hideOwned==true)then P.prefs.hideOwned=hide;P.save()end\n  local ids={};for id in pairs(needs)do ids[#ids+1]=id end;table.sort(ids,function(a,b)return name(a)<name(b)end)\n  local out={};for _,id in ipairs(ids)do local v=needs[id];local missing=math.max(0,v.quantity-(P.owned[id]or 0));if missing>0 then out[#out+1]=missing..' x '..name(id)..' ['..id..']'end end\n  if button('Copy missing list','Copies a combined shopping/farming checklist without spending gil or starting automation.',150)then copy(table.concat(out,'\\n'))end\n  GUI:Separator()\n  for _,id in ipairs(ids)do local v=needs[id];local missing=math.max(0,v.quantity-(P.owned[id]or 0));local key=tostring(id);local meta=P.catalog.items[key]or{}\n   local source=P.prefs.sources[key]or{kind='Unknown',note=''}\n   local text=(missing==0 and'OWNED'or('MISSING '..missing))..' | '..name(id)..' | '..(meta.untradable and'Untradable'or'Tradeable')\n   if missing>0 or not P.prefs.hideOwned then\n   if missing==0 then GUI:PushStyleColor(GUI.Col_Text,0.3,1,0.4,1)end\n   local expanded=GUI:CollapsingHeader(text..'##'..id)\n   if missing==0 then GUI:PopStyleColor()end\n   if (P.owned[id]or 0)>0 then help('Owned '..(P.owned[id]or 0)..' pieces.\\n'..table.concat(P.locations[id]or{'No location recorded; rescan your inventory.'},'\\n'))end\n   if expanded then\n    if (P.owned[id]or 0)>0 then label('Owned item locations:');for _,loc in ipairs(P.locations[id]or{})do GUI:TextWrapped('  '..loc)end end\n    label('Detected sources (Garland Tools):')\n    if meta.sources and #meta.sources>0 then for _,entry in ipairs(meta.sources)do\n     GUI:TextWrapped('  '..entry.kind..': '..entry.text)\n     for ai,alt in ipairs(entry.currencies or{})do\n      label('    Exchange option '..ai..' (for '..math.max(1,missing)..' missing pieces):')\n      for _,cost in ipairs(alt.costs)do\n       local required=math.ceil(math.max(1,missing)/(alt.yield or 1))*cost.amount\n       local owned=cost.hq and(P.hq[cost.id]or 0)or(P.currency[cost.id]and(P.currency[cost.id]+((P.cachedOwned or{})[cost.id]or 0))or P.owned[cost.id]or 0)\n       local r,g,b=1,0.3,0.3;if owned>=required then r,g,b=0.3,1,0.4 elseif owned>0 then r,g,b=1,0.6,0.15 end\n       GUI:TextColored(r,g,b,1,'      '..cost.name..(cost.hq and' HQ'or'')..': '..owned..' / '..required)\n       if GUI:IsItemHovered()then\n        local lines={'Snapshot amount: '..owned..' / required '..required,'Locations (slots are numbered from 1):'}\n        for _,loc in ipairs(P.locations[cost.id]or{})do lines[#lines+1]=loc end\n        if not P.locations[cost.id]then lines[#lines+1]='None found in readable containers. Open saddlebag and Rescan to include it.'end\n        if owned<required then\n         lines[#lines+1]='How to obtain:';local routes=P.catalog.currencySources and P.catalog.currencySources[tostring(cost.id)]\n         if routes and #routes>0 then local hasDuty=false;for _,route in ipairs(routes)do if route.kind=='Farm'then hasDuty=true end end;for _,route in ipairs(routes)do if not hasDuty or route.kind=='Farm'then lines[#lines+1]=route.kind..': '..route.text end end else lines[#lines+1]='No verified acquisition record available; check the item source page.'end\n        end\n        lines[#lines+1]='Amounts are not reserved across alternative exchanges or other planned pieces.'\n        GUI:SetTooltip(table.concat(lines,'\\n'))\n       end\n      end\n     end\n    end else label('  No verified source recorded; use a manual note below.')end\n    if meta.sourceURL and button('Copy source page##'..id,'Copy this item’s source database page.',150)then copy(meta.sourceURL)end\n    for _,s in ipairs(v.sets)do label('  '..s)end\n    local kind=choose('Source##'..id,source.kind,{'Unknown','Farm','Buy','Craft','Exchange'})\n    local note=GUI:InputText('Location / note##'..id,source.note)\n    if kind~=source.kind or note~=source.note then P.prefs.sources[key]={kind=kind,note=note};P.save()end\n    help('Optional manual override or extra note. Detected alternatives remain visible above; market availability is not checked.')\n   end\n   end\n  end\n end\n local function drawFood()\n  label('Food preferences are planning choices; this tool does not automatically consume food.')\n  local foods={};local seen={};for _,s in ipairs(P.catalog.sets)do if s.food and not seen[s.food]then seen[s.food]=true;foods[#foods+1]=s.food end end\n  table.sort(foods,function(a,b)return name(a)<name(b)end)\n  local labels={'Set recommendation'};for _,id in ipairs(foods)do labels[#labels+1]=name(id)..' ['..id..']'end\n  local fight=P.foodFight or'DSR';fight=choose('Food fight',fight,{'UCOB','UWU','TEA','DSR','TOP','FRU','DMU','General'});P.foodFight=fight\n  for _,job in ipairs(jobs)do if job~='All'then\n   local key=fight..':'..job;local saved=P.prefs.food[key];local index=1\n   for i,id in ipairs(foods)do if id==saved then index=i+1 end end\n   local chosen=GUI:Combo(job,index,labels)\n   if chosen~=index then P.prefs.food[key]=foods[chosen-1];P.save()end\n  end end\n end\n local function drawSources()\n  label('Imported '..P.catalog.retrieved)\n  local s=P.catalog.summary\n  label(s.sheets..' sheets | '..s.buildsBeforeDedup..' build rows | '..s.uniqueBuilds..' unique builds')\n  label(s.duplicateBuildsMerged..' duplicates merged | '..s.explanatoryRowsSkipped..' explanatory rows skipped')\n  label('Catalog sources: The Balance and Icy Veins. Item names: XIVAPI. Acquisition: Garland Tools.')\n  label('No automatic BiS choice: select a build that fits your fight, GCD and relic route.')\n  label('Historical sheets are retained; a linked set is not necessarily current or LPDU-specific.')\n  for _,e in ipairs(P.catalog.errors or{})do label('Unavailable: '..tostring(e.url or e.stage)..' / '..tostring(e.error))end\n  if button('Reload catalog','Loads the local refreshed catalog and saved preferences.',150)then P.load()end\n  GUI:Separator();label('Storage cache status')\n  local storage=P.storageAll and P.storageAll[P.storageIdentity]\n  for name,entry in pairs(storage and storage.retainerRoster or{})do\n   local snapshot=storage.retainers and storage.retainers[name]\n   label(name..': '..(not entry.active and'Inactive / excluded from ownership'or snapshot and('Cached '..os.date('%d-%m %H:%M',snapshot.scannedAt))or'Not scanned; visit this retainer'))\n  end\n  GUI:Separator();label('Import your own public set or full sheet')\n  P.importURL=GUI:InputText('XIVGear / Etro URL',P.importURL or'')\n  P.importJob=choose('Fallback job',P.importJob or'DNC',jobs)\n  P.importFight=choose('Imported fight',P.importFight or'General',fights)\n  if button('Import sheet','Imports every build in this public sheet, merging identical builds. The selected job is used only when the sheet does not declare one.',150)then P.import(P.importURL,P.importJob,P.importFight)end\n end\n -- Retainer menu name / inventory schema verified live with Hume on 28-10-2026.\n function P.updateRetainer()\n  local storage=P.storageAll[P.storageIdentity]\n  if IsControlOpen('RetainerList')then\n   P.retainerName=nil;P.retainerNameAt=nil;P.retainerCandidate=nil;P.retainerVisitSaved=false\n   local raw=GetControl('RetainerList'):GetRawData();local count=raw[3]and raw[3].value\n   if type(count)=='number'and count>=0 and count<=10 then\n    local roster={};local valid=true\n    for i=0,count-1 do local base=4+i*10;local name=raw[base]and raw[base].value;local active=raw[base+8]\n     if type(name)~='string'or name==''or not active or active.type~='bool'then valid=false;break end\n     roster[name]={active=active.value==true,index=i,occupied=raw[base+3]and raw[base+3].value}\n    end\n    if valid then local fingerprint=json.encode(roster)\n     if P.retainerRosterFingerprint~=fingerprint then\n      storage.retainerRoster=roster;storage.retainerRosterAt=os.time();P.retainerRosterFingerprint=fingerprint\n      local f=io.open(root..'storage.json','w');if f then f:write(json.encode(P.storageAll));f:close()end\n      if P.catalog then P.scan()end\n     end\n    end\n   end\n   return\n  end\n  if IsControlOpen('SelectString')then\n   local strings=GetControl('SelectString'):GetStrings();local text=strings and strings[2]\n   local name=type(text)=='string'and text:match('^Retainer: ([^\\r\\n]+)')\n   if name then P.retainerName=name;P.retainerNameAt=Now()end\n  end\n  local open=IsControlOpen('InventoryRetainerLarge')\n  if not open then P.retainerCandidate=nil;P.retainerVisitSaved=false;return end\n  if not P.retainerName or not P.retainerNameAt or Now()-P.retainerNameAt>120000 and not P.retainerVisitSaved then return end\n  local availability=storage.retainerRoster and storage.retainerRoster[P.retainerName]\n  if storage.retainerRoster and(not availability or availability.active~=true)then return end\n  local records={};local occupied=0\n  for _,id in ipairs({10000,10001,10002,10003,10004,10005,10006,11000,12000,12001,12002})do\n   local bag=Inventory:Get(id);if not bag or (id>=10000 and id<=10006 and bag.size~=25)then return end\n   for _,it in pairs(bag:GetList()or{})do if it.id and it.id>0 then\n    if id>=10000 and id<=10006 then occupied=occupied+1 end\n    records[#records+1]={id=it.id%1000000,hq=it.ishq==true,count=it.count or 1,bag=id,slot=(it.slot or 0)+1,listed=id==12002}\n   end end\n  end\n  local text=GetControl('InventoryRetainerLarge'):GetStrings();local used=tonumber(text and tostring(text[62]):match('^(%d+)/175'))\n  if not used or used~=occupied then return end\n  table.sort(records,function(a,b)return a.bag<b.bag or a.bag==b.bag and a.slot<b.slot end)\n  local fingerprint=json.encode(records)\n  if P.retainerCandidate~=fingerprint then P.retainerCandidate=fingerprint;return end\n  local st=P.storageAll[P.storageIdentity];st.retainers=st.retainers or{}\n  local old=st.retainers[P.retainerName]\n  if P.retainerVisitSaved and old and old.fingerprint==fingerprint then return end\n  st.retainers[P.retainerName]={name=P.retainerName,items=records,scannedAt=os.time(),fingerprint=fingerprint,occupied=occupied}\n  local f=io.open(root..'storage.json','w');if f then f:write(json.encode(P.storageAll));f:close()end\n  P.retainerVisitSaved=true\n  if P.catalog then P.scan()end\n end\n -- Dresser UI schema verified with Minion Dev Spy on 28-10-2026 (agent 303).\n function P.updateStorage()\n  local now=Now();if P.storageTick and now-P.storageTick<500 then return end;P.storageTick=now\n  local player=TensorCore.mGetPlayer();if not player or not player.name or not player.homeworld then return end\n  local identity=player.name..'@'..player.homeworld\n  if P.storageIdentity~=identity then\n   P.storageIdentity=identity;P.storageRun=nil;P.storageVisited=P.dresserVisitIdentity==identity and P.storageVisited or false;P.dresserVisitIdentity=identity;P.retainerName=nil;P.retainerVisitSaved=false;P.retainerCandidate=nil\n   local ok,data=pcall(readJSON,root..'storage.json');P.storageAll=ok and type(data)=='table'and data or{};P.storageAll[identity]=P.storageAll[identity]or{}\n   P.owned={};P.hq={};P.currency={};P.locations={};P.resolved={};P.scanAt=nil;if P.catalog then P.scan()end\n  end\n  if player.incombat then return end\n  P.importArmoire();P.exportPlan()\n  P.updateRetainer()\n  if not IsControlOpen('MiragePrismPrismBox')then\n   P.dresserClosedAt=P.dresserClosedAt or now\n   -- UI refreshes can briefly hide the control; only a sustained close ends a visit.\n   if now-P.dresserClosedAt>=2000 then P.storageVisited=false;P.storageRun=nil end\n   return\n  end\n  P.dresserClosedAt=nil\n  local control=GetControl('MiragePrismPrismBox');local raw=control:GetRawData()\n  local function value(i)return raw[i]and raw[i].value end\n  if not P.storageRun then\n   if P.storageVisited then return end\n   if type(value(352))~='number'or type(value(361))~='number'then return end\n   P.storageVisited=true;P.storageVisitTotal=value(361);P.storageRun={tab=0,page=0,total=value(361),items={},count=0,restore=value(352),signatures={},physical={}}\n   UIEvent(303,0,{{5,0},{5,0},{0,0}});UIEvent(303,0,{{5,1},{5,0},{0,0}});return\n  end\n  local run=P.storageRun\n  if value(352)~=run.tab then P.status='Dresser scan cancelled: tab changed.';P.storageRun=nil;return end\n  local count=value(359)\n  if type(count)~='number'or count<0 or count>50 or value(361)~=run.total then P.storageRun=nil;P.status='Dresser changed during scan; reopen it to retry.';return end\n  local signature={};for i=1,count do signature[i]=tostring(value(100+i))..':'..tostring(value(200+i))end\n  local fingerprint=table.concat(signature,',');local key=run.tab..':'..fingerprint\n  if count>0 and run.signatures[key]then count=0 end\n  run.signatures[key]=true\n  for i=1,count do\n   local rawID=value(100+i)\n   if type(rawID)~='number'or rawID<=0 then P.storageRun=nil;P.status='Dresser row unavailable; cache retained.';return end\n   local physical=value(200+i)\n   if type(physical)~='number'or physical<0 or physical>=value(362)then P.storageRun=nil;P.status='Dresser physical slot unavailable; cache retained.';return end\n   if not run.physical[physical]then run.physical[physical]={};run.count=run.count+1 end\n   if not run.physical[physical][rawID]then\n    run.physical[physical][rawID]=true;run.items[#run.items+1]={id=rawID%1000000,hq=rawID>=1000000,tab=run.tab,page=run.page+1,slot=i,physicalSlot=physical+1,count=1}\n   end\n  end\n  if count==50 and run.page<16 then run.page=run.page+1;UIEvent(303,0,{{5,1},{5,1},{0,0}});return end\n  if run.tab<10 then run.tab=run.tab+1;run.page=0;UIEvent(303,0,{{5,0},{5,run.tab},{0,0}});UIEvent(303,0,{{5,1},{5,0},{0,0}});return end\n  local snapshot={items=run.items,scannedAt=os.time(),count=run.count,total=run.total,complete=run.count==run.total}\n  if snapshot.complete then P.storageAll[identity].dresser=snapshot else P.storageAll[identity].dresserPartial=snapshot end\n  local f,e=io.open(root..'storage.json','w');if f then f:write(json.encode(P.storageAll));f:close()end\n  UIEvent(303,0,{{5,0},{5,run.restore},{0,0}})\n  P.storageRun=nil;P.status='Dresser cached '..#run.items..' pieces in '..run.count..' / '..run.total..(snapshot.complete and' items.'or' items; incomplete snapshot excluded from ownership.')\n  if P.catalog then P.scan()end\n end\n function P.draw()\n  if not jacobGearPlannerOpen then return end\n  if not P.catalog and not P.load()then return end\n  GUI:SetNextWindowSize(1000,700,GUI.SetCond_FirstUseEver)\n  local visible,open=GUI:Begin(\"Jacob's Gear Sets\",true);jacobGearPlannerOpen=open\n  if visible then\n   for i,tab in ipairs({'Fights / Sets','Plan','Food','Sources'})do if i>1 then GUI:SameLine()end;if button(tab,'Show '..tab..'.',145)then P.tab=i;P.detail=nil end end\n   GUI:Separator()\n   if button('Rescan','Read carried inventory, equipped items and armoury. Does not count closed retainers or other characters.')then P.scan()end\n   GUI:SameLine();label(P.status)\n   GUI:BeginChild('##GearPlannerBody',0,0,true)\n   if P.detail and P.byID[P.detail]then detail(P.byID[P.detail])\n   elseif P.tab==2 then drawPlan()\n   elseif P.tab==3 then drawFood()\n   elseif P.tab==4 then drawSources()\n   else\n    filters();local filterKey=P.job..'|'..P.fight..'|'..P.search..'|'..#P.catalog.sets\n    if P.filterKey~=filterKey then\n    P.filtered=P.filterBuilds();P.filterKey=filterKey\n    end\n    local rows=P.filtered\n    local pages=math.max(1,math.ceil(#rows/25));P.page=math.min(P.page,pages)\n    if button('Previous','Previous 25 builds.',85)then P.page=math.max(1,P.page-1)end;GUI:SameLine()\n    if button('Next','Next 25 builds.',85)then P.page=math.min(pages,P.page+1)end;GUI:SameLine();label(#rows..' builds / page '..P.page..' of '..pages)\n    label('Piece ownership only; melds and relic stats are shown in Details.')\n    for n=(P.page-1)*25+1,math.min(P.page*25,#rows)do local s=rows[n];local have,total,custom=P.count(s)\n     GUI:Separator();selected(s);GUI:SameLine();label(s.job..' | '..s.name)\n     local r,g,b=1,0.35,0.35\n     if total>0 and have==total and custom==0 then r,g,b=0.3,1,0.4 elseif have>0 then r,g,b=1,0.8,0.2 end\n     GUI:TextColored(r,g,b,1,'Pieces '..have..'/'..total..(custom>0 and(' | '..custom..' custom templates')or'')..' | '..table.concat(s.fights,', '))\n     help('Green: every piece owned. Yellow: some pieces owned or custom templates need checking. Red: no pieces owned. Melds are not included in this count.')\n     if button('Details##'..s.id,'Show exact gear, materia, relic allocation, food and source links.')then P.detail=s.id end\n    end\n   end\n   GUI:EndChild()\n  end\n  GUI:End()\n end\nend\nJacobGearPlanner.updateStorage()\nJacobGearPlanner.draw()\n",
						name = "Draw Strats Button",
						uuid = "ec7e680b-0125-7238-8aef-ca7cc8b03a42",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
			},
			eventType = 13,
			name = "Jacob's Toolbox",
			uuid = "27f36af1-09c3-7e00-915b-f98bc6b2f102",
			version = 2,
		},
	},
	
	{
		data = 
		{
			displayPath = "",
			name = "Quantum40",
			uuid = "0ec92a52-5024-a375-bbe9-122a2296a5ae",
		},
		objectType = "folder",
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "db05d474-20ea-ff51-8153-f100e505cac5",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Alert",
						alertDuration = 2500,
						alertPriority = 3,
						alertScale = 0.89999997615814,
						alertText = "NO DEBUFF",
						conditions = 
						{
							
							{
								"22e37a6e-3216-796e-9b04-67b9ef438e3d",
								true,
							},
							
							{
								"ab86153d-46f9-5d16-9902-342adb140bba",
								true,
							},
						},
						displayPath = "Quantum40",
						name = "NO DEBUFF",
						uuid = "fb6639f3-4878-24f3-be47-10a019724da4",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "aaf061f6-de9f-51f9-9bf4-cb1f5395478a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 8,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40",
						localmapid = 1311,
						name = "Quantum40 Map",
						uuid = "22e37a6e-3216-796e-9b04-67b9ef438e3d",
						version = 3,
					},
				},
				
				{
					data = 
					{
						buffCheckType = 6,
						buffIDList = 
						{
							4559,
							4560,
						},
						category = "Self",
						displayPath = "Quantum40",
						name = "Missing Dark + Light Vengeance",
						uuid = "ab86153d-46f9-5d16-9902-342adb140bba",
						version = 3,
					},
				},
			},
			displayPath = "Quantum40",
			name = "[Quantum40] No Debuff Alert",
			throttleTime = 1000,
			timeout = 2,
			uuid = "655a7796-641b-bc6f-a75a-6440b4f3f051",
			version = 2,
		},
	},
	
	{
		data = 
		{
			displayPath = "Quantum40",
			name = "Bounds of Sin",
			uuid = "7101e7b2-c732-1eb8-a65a-75ccebab0885",
		},
		objectType = "folder",
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "d843c19d-9af4-f82b-951b-53a723d62a05",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Bounds of Sin",
						uuid = "2fba1be0-837d-dce2-83c9-53f3cb8cf536",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "local p = TensorCore.mGetPlayer()\nif p == nil or p.pos == nil then\n    self.used = true\n    return\nend\n\nlocal function assignedRole(entity)\n    if entity == nil then\n        return nil\n    end\n    if entity.name and gLj_Toolbox and gLj_Toolbox.Settings and gLj_Toolbox.Settings.partyRoles then\n        local assigned = gLj_Toolbox.Settings.partyRoles[entity.name]\n        if assigned ~= nil and assigned ~= \"None\" then\n            return assigned\n        end\n    end\n    if gLj_PartyRoles and entity.id ~= nil then\n        for candidate, entityID in pairs(gLj_PartyRoles) do\n            if entityID == entity.id then\n                return candidate\n            end\n        end\n    end\n    return nil\nend\n\nlocal function roleKind(role)\n    if role == \"MT\" or role == \"OT\" then\n        return \"tank\"\n    elseif role == \"H1\" or role == \"H2\" then\n        return \"healer\"\n    elseif role == \"M1\" or role == \"M2\" then\n        return \"melee\"\n    elseif role == \"R1\" or role == \"R2\" then\n        return \"ranged\"\n    end\n    return nil\nend\n\nlocal function jobKind(job)\n    if job == 19 or job == 21 or job == 32 or job == 37 then\n        return \"tank\"\n    elseif job == 24 or job == 28 or job == 33 or job == 40 then\n        return \"healer\"\n    elseif job == 20 or job == 22 or job == 30 or job == 34 or job == 39 or job == 41 then\n        return \"melee\"\n    end\n    return \"ranged\"\nend\n\nlocal function entityKind(entity)\n    return roleKind(assignedRole(entity)) or jobKind(entity and entity.job)\nend\n\nlocal kind = entityKind(p)\nif kind == nil then\n    self.used = true\n    return\nend\n\nlocal party = TensorCore.getEntityGroupList(\"Party\") or {}\nlocal seen = {}\nlocal function addEntity(entity)\n    if entity and entity.id and not seen[entity.id] then\n        seen[entity.id] = true\n        return true\n    end\n    return false\nend\naddEntity(p)\n\nlocal entities = {p}\nfor _, entity in pairs(party) do\n    if addEntity(entity) then\n        table.insert(entities, entity)\n    end\nend\n\nlocal centerX = -600.0\nlocal centerZ = -300.0\nlocal minX, maxX = p.pos.x, p.pos.x\nlocal minZ, maxZ = p.pos.z, p.pos.z\nfor _, entity in ipairs(entities) do\n    if entity.pos then\n        minX = math.min(minX, entity.pos.x)\n        maxX = math.max(maxX, entity.pos.x)\n        minZ = math.min(minZ, entity.pos.z)\n        maxZ = math.max(maxZ, entity.pos.z)\n    end\nend\n\nlocal axis\nlocal xSpread = maxX - minX\nlocal zSpread = maxZ - minZ\nif xSpread > zSpread * 1.15 then\n    axis = \"WE\"\nelseif zSpread > xSpread * 1.15 then\n    axis = \"NS\"\nelse\n    axis = \"NS\"\nend\n\nlocal partnerKind\nif axis == \"NS\" then\n    if kind == \"tank\" then\n        partnerKind = \"melee\"\n    elseif kind == \"melee\" then\n        partnerKind = \"tank\"\n    elseif kind == \"healer\" then\n        partnerKind = \"ranged\"\n    elseif kind == \"ranged\" then\n        partnerKind = \"healer\"\n    end\nelse\n    if kind == \"tank\" then\n        partnerKind = \"ranged\"\n    elseif kind == \"ranged\" then\n        partnerKind = \"tank\"\n    elseif kind == \"healer\" then\n        partnerKind = \"melee\"\n    elseif kind == \"melee\" then\n        partnerKind = \"healer\"\n    end\nend\n\nif partnerKind == nil then\n    self.used = true\n    return\nend\n\nlocal partnerRoles = {}\nif axis == \"NS\" then\n    if kind == \"tank\" then\n        partnerRoles = { \"M1\", \"M2\" }\n    elseif kind == \"melee\" then\n        partnerRoles = { \"MT\", \"OT\" }\n    elseif kind == \"healer\" then\n        partnerRoles = { \"R1\", \"R2\" }\n    elseif kind == \"ranged\" then\n        partnerRoles = { \"H1\", \"H2\" }\n    end\nelse\n    if kind == \"tank\" then\n        partnerRoles = { \"R1\", \"R2\" }\n    elseif kind == \"ranged\" then\n        partnerRoles = { \"MT\", \"OT\" }\n    elseif kind == \"healer\" then\n        partnerRoles = { \"M1\", \"M2\" }\n    elseif kind == \"melee\" then\n        partnerRoles = { \"H1\", \"H2\" }\n    end\nend\n\nlocal exactPartners = {}\nlocal fallbackPartners = {}\nlocal exactSeen = {}\nlocal fallbackSeen = {}\nfor _, entity in ipairs(entities) do\n    if entity.id ~= p.id and entity.pos then\n        local entityRole = assignedRole(entity)\n        local exact = false\n        for _, partnerRole in ipairs(partnerRoles) do\n            if entityRole == partnerRole then\n                exact = true\n                break\n            end\n        end\n        if exact and not exactSeen[entity.id] then\n            exactSeen[entity.id] = true\n            table.insert(exactPartners, entity)\n        end\n        if entityKind(entity) == partnerKind and not fallbackSeen[entity.id] then\n            fallbackSeen[entity.id] = true\n            table.insert(fallbackPartners, entity)\n        end\n    end\nend\n\nlocal partners = (#exactPartners > 0) and exactPartners or fallbackPartners\n\nlocal sideOffset = 8.5\nlocal sideX, sideZ\nif axis == \"NS\" then\n    sideX = centerX\n    sideZ = (kind == \"tank\" or kind == \"melee\") and (centerZ - sideOffset) or (centerZ + sideOffset)\nelse\n    sideX = (kind == \"tank\" or kind == \"ranged\") and (centerX - sideOffset) or (centerX + sideOffset)\n    sideZ = centerZ\nend\n\nlocal target = {x = sideX, y = p.pos.y, z = sideZ}\nlocal distance = TensorCore.getDistance2d(p.pos, target)\nlocal heading = TensorCore.getHeadingToTarget(p.pos, target)\nlocal length = math.max(3.0, math.min(distance, sideOffset))\nlocal drawer = TensorCore.getCachedFlatDrawer(0xDD50FF70, 0xDD50FF70, 0xDD50FF70, 0xFFFFFFFF, 2.4, 1)\ndrawer:addTimedArrow(8000, p.pos.x, p.pos.y, p.pos.z, heading, length, 0.9, 1.8, 1.3, 0, false)\n\nlocal labels = {}\nfor _, entity in ipairs(partners) do\n    drawer:addTimedCircleOnEnt(8000, entity.id, 1.5, 0, false, true)\n    local label = tostring(entity.name or \"\")\n    if label == \"\" or label == \"Player\" then\n        label = tostring(assignedRole(entity) or entity.job or partnerKind)\n    end\n    table.insert(labels, label)\nend\n\nlocal partnerLabel\nif #labels == 0 then\n    partnerLabel = tostring(partnerKind)\nelseif #labels == 1 then\n    partnerLabel = labels[1]\nelse\n    partnerLabel = table.concat(labels, \" / \")\nend\nTensorCore.addAlertText(3500, \"STACK WITH \" .. partnerLabel, 0.85, 2, false)\n\nself.used = true\n",
						conditions = 
						{
							
							{
								"0a7dc35e-6b42-8c22-a225-ae1cd971443a",
								true,
							},
							
							{
								"827cb6c8-2801-74a2-80c7-aa643e6e571e",
								true,
							},
						},
						displayPath = "Quantum40/Bounds of Sin",
						name = "Draw partner split and marker",
						uuid = "88d16770-1de3-6ad0-bd23-78dddac39706",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "8c853c46-22b0-20c8-8d52-709f1a5e3615",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Bounds of Sin",
						uuid = "2f4611a3-91a6-5fc8-8d97-55bf9816bb52",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						conditionLua = "\nlocal p = TensorCore.mGetPlayer()\nreturn p ~= nil and p.localmapid == 1311 and spellID == 44121 and entityContentID == 14038\n",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Bounds of Sin",
						eventArgType = 2,
						eventSpellID = 44121,
						name = "Bounds cast spell (Argus)",
						uuid = "0a7dc35e-6b42-8c22-a225-ae1cd971443a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Bounds of Sin",
						eventArgOptionType = 2,
						eventEntityContentID = 14038,
						name = "Devoured Eater entity (Moogle)",
						uuid = "827cb6c8-2801-74a2-80c7-aa643e6e571e",
						version = 3,
					},
				},
			},
			displayPath = "Quantum40/Bounds of Sin",
			eventType = 3,
			name = "[Quantum40] Bounds of Sin - Partner Split",
			throttleTime = 1000,
			timeout = 2,
			uuid = "2b6dcf02-6c8a-ee29-bbbf-7cc4b69b0628",
			version = 2,
		},
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "d283bc78-e1ad-57ae-8907-a6c60632ee8b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Bounds of Sin",
						uuid = "394711c2-1e44-cba5-a6ee-d340c87528d8",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "\nlocal p = TensorCore.mGetPlayer()\nif p == nil or p.pos == nil then\n    self.used = true\n    return true\nend\n\nlocal role = nil\nif gLj_Toolbox and gLj_Toolbox.Settings and gLj_Toolbox.Settings.partyRoles and p.name then\n    role = gLj_Toolbox.Settings.partyRoles[p.name]\nend\nif role == nil and gLj_PartyRoles then\n    for candidate, entityID in pairs(gLj_PartyRoles) do\n        if entityID == p.id then\n            role = candidate\n            break\n        end\n    end\nend\nif role == nil then\n    self.used = true\n    return true\nend\n\nlocal centerX = -600.0\nlocal centerZ = -300.0\nlocal targetX = centerX\nlocal targetZ = centerZ\nif role == \"MT\" or role == \"OT\" then\n    targetX = centerX - 6.0\n    targetZ = centerZ - 6.0\nelseif role == \"M1\" or role == \"M2\" then\n    targetX = centerX + 6.0\n    targetZ = centerZ - 6.0\nelseif role == \"H1\" or role == \"H2\" then\n    targetX = centerX + 6.0\n    targetZ = centerZ + 6.0\nelseif role == \"R1\" or role == \"R2\" then\n    targetX = centerX - 6.0\n    targetZ = centerZ + 6.0\nelse\n    self.used = true\n    return true\nend\n\nlocal target = {x = targetX, y = p.pos.y, z = targetZ}\nlocal distance = TensorCore.getDistance2d(p.pos, target)\nlocal heading = TensorCore.getHeadingToTarget(p.pos, target)\nlocal length = math.max(3.0, math.min(distance, 9.0))\nlocal drawer = TensorCore.getCachedFlatDrawer(0xCC20BFFF, 0xCC20BFFF, 0xCC20BFFF, 0xFFFFFFFF, 2.2, 1)\ndrawer:addTimedArrow(6500, p.pos.x, p.pos.y, p.pos.z, heading, length, 0.8, 1.6, 1.2, 0, false)\ndrawer:addTimedCircle(6500, targetX, p.pos.y, targetZ, 1.25, 0, false, true)\n\nif TensorCore.hasBuff(p, 4559) then\n    TensorCore.addAlertText(3500, \"SWAP TO LIGHT FOR TOWER\", 0.95, 3, true)\nelse\n    TensorCore.addAlertText(2000, \"YOUR TOWER\", 0.85, 2, false)\nend\n\nself.used = true\nreturn true\n",
						conditions = 
						{
							
							{
								"03b8aa15-d3b9-56ad-8ff7-a1d02fbc6d21",
								true,
							},
							
							{
								"4b51d832-e238-456f-bbed-bcb05bf07b35",
								true,
							},
						},
						displayPath = "Quantum40/Bounds of Sin",
						name = "Draw role tower and debuff warning",
						uuid = "ad91edcc-ad37-f360-8d16-abc6acd12c38",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "1ea5bc67-3f43-a5e1-9b6e-01f583eb7222",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Bounds of Sin",
						uuid = "0e70886f-e8cf-24c0-b370-969ec926bd5c",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						conditionLua = "\nlocal p = TensorCore.mGetPlayer()\nreturn p ~= nil and p.localmapid == 1311 and spellID == 44123 and entityContentID == 14038\n",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Bounds of Sin",
						eventArgType = 2,
						eventSpellID = 44123,
						name = "Bounds tower spell (Argus)",
						uuid = "03b8aa15-d3b9-56ad-8ff7-a1d02fbc6d21",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Bounds of Sin",
						eventArgOptionType = 2,
						eventEntityContentID = 14038,
						name = "Devoured Eater entity (Moogle)",
						uuid = "4b51d832-e238-456f-bbed-bcb05bf07b35",
						version = 3,
					},
				},
			},
			displayPath = "Quantum40/Bounds of Sin",
			eventType = 2,
			name = "[Quantum40] Bounds of Sin - Tower Guide",
			throttleTime = 1000,
			timeout = 2,
			uuid = "64ef40b6-02c5-0f42-bf1e-dbc1aab77b03",
			version = 2,
		},
	},
	
	{
		data = 
		{
			displayPath = "Quantum40",
			name = "Scourging Blaze",
			uuid = "683b5ad9-1c55-91ea-b7ce-22a866951bde",
		},
		objectType = "folder",
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "512ed5ed-28d7-287f-8dd0-0978b337f406",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Scourging Blaze",
						uuid = "e527e176-c01d-cc5d-a14d-df2ba9b40c4c",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "\ndata.quantum40_scourging = data.quantum40_scourging or {}\nlocal state = data.quantum40_scourging\nstate.mode = (spellID == 44798) and \"NS\" or \"EW\"\nstate.firstSetDrawn = false\nstate.firstCount = 0\nstate.has12 = false\nstate.has34 = false\nself.used = true\nreturn true\n",
						conditions = 
						{
							
							{
								"07690648-780c-8f50-b16f-2255bb3c2f79",
								true,
							},
							
							{
								"37f7f123-0880-72a2-9260-812178764381",
								true,
							},
						},
						displayPath = "Quantum40/Scourging Blaze",
						name = "Store NS or EW opening",
						uuid = "de15a572-5cda-fb2d-8c85-acdc5fbf35b7",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "f11198c2-b641-395c-8930-2c397448ffff",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Scourging Blaze",
						uuid = "b427d4e9-a754-faec-ae47-f48a97b889d1",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						conditionLua = "\nlocal p = TensorCore.mGetPlayer()\nreturn p ~= nil and p.localmapid == 1311 and entityContentID == 14037 and (spellID == 44798 or spellID == 44797)\n",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Scourging Blaze",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Scourging opening spell (Argus)",
						spellIDList = 
						{
							44798,
							44797,
						},
						uuid = "07690648-780c-8f50-b16f-2255bb3c2f79",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Scourging Blaze",
						eventArgOptionType = 2,
						eventEntityContentID = 14037,
						name = "Eminent Grief entity (Moogle)",
						uuid = "37f7f123-0880-72a2-9260-812178764381",
						version = 3,
					},
				},
			},
			displayPath = "Quantum40/Scourging Blaze",
			eventType = 3,
			name = "[Quantum40] Scourging Blaze - Read Opening",
			throttleTime = 1000,
			timeout = 2,
			uuid = "c1c3a626-fafd-2386-bfe2-3fea2dd4de96",
			version = 2,
		},
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "ab791120-7dbf-cb49-af12-9b2b79d5fef4",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Scourging Blaze",
						uuid = "b2e6c343-c910-6395-95dd-a9a3ea08defe",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "\ndata.quantum40_scourging = data.quantum40_scourging or {}\nlocal stateData = data.quantum40_scourging\nif stateData.mode == nil or stateData.firstSetDrawn == true then\n    self.used = true\n    return true\nend\n\nstateData.firstCount = (stateData.firstCount or 0) + 1\nif math.abs(x + 594.0) < 1.0 and math.abs(z + 300.0) < 1.0 then\n    stateData.has12 = true\nelseif math.abs(x + 606.0) < 1.0 and math.abs(z + 300.0) < 1.0 then\n    stateData.has34 = true\nend\n\nlocal safeNumber = nil\nif stateData.has12 then\n    safeNumber = (stateData.mode == \"NS\") and 3 or 1\nelseif stateData.has34 then\n    safeNumber = (stateData.mode == \"NS\") and 2 or 4\nelseif stateData.firstCount >= 6 then\n    safeNumber = (stateData.mode == \"NS\") and 2 or 4\nend\n\nif safeNumber ~= nil then\n    local pNow = TensorCore.mGetPlayer()\n    if pNow and pNow.pos then\n        local targetX = -600.0\n        local targetZ = -300.0\n        if safeNumber == 1 then\n            targetX = -594.134\n            targetZ = -313.405\n        elseif safeNumber == 2 then\n            targetX = -594.209\n            targetZ = -286.234\n        elseif safeNumber == 3 then\n            targetX = -605.534\n            targetZ = -286.200\n        elseif safeNumber == 4 then\n            targetX = -605.629\n            targetZ = -313.525\n        end\n\n        local target = {x = targetX, y = pNow.pos.y, z = targetZ}\n        local distance = TensorCore.getDistance2d(pNow.pos, target)\n        local heading = TensorCore.getHeadingToTarget(pNow.pos, target)\n        local length = math.max(3.0, math.min(distance, 10.0))\n        local drawer = TensorCore.getCachedFlatDrawer(0xCCFFD040, 0xCCFFD040, 0xCCFFD040, 0xFFFFFFFF, 2.2, 1)\n        drawer:addTimedArrow(26000, pNow.pos.x, pNow.pos.y, pNow.pos.z, heading, length, 0.9, 1.8, 1.3, 0, false)\n        drawer:addTimedCircle(26000, targetX, pNow.pos.y, targetZ, 1.6, 0, false, true)\n        TensorCore.addAlertText(3500, \"SCOURGING SAFE \" .. tostring(safeNumber), 0.95, 2, false)\n        stateData.firstSetDrawn = true\n    end\nend\n\nself.used = true\nreturn true\n",
						conditions = 
						{
							
							{
								"f4c260ce-5982-faf7-8cbe-21ea12a692d4",
								true,
							},
						},
						displayPath = "Quantum40/Scourging Blaze",
						name = "Draw numbered safe marker",
						uuid = "9d9ea67d-e1db-05da-8c40-0cc2c888e7c3",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "453d5c83-91b5-ca11-b6a1-45e04e23afae",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Scourging Blaze",
						uuid = "7f0ebb9c-ca5c-223b-934e-892c740a6967",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "\nlocal p = TensorCore.mGetPlayer()\nreturn p ~= nil and p.localmapid == 1311 and keyID == 2014832 and state == 1\n",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Scourging Blaze",
						name = "Scourging crystal",
						uuid = "f4c260ce-5982-faf7-8cbe-21ea12a692d4",
						version = 3,
					},
				},
			},
			displayPath = "Quantum40/Scourging Blaze",
			eventType = 29,
			name = "[Quantum40] Scourging Blaze - Safe Marker",
			throttleTime = 250,
			timeout = 2,
			uuid = "3524d451-0379-0f88-9c13-4cf95a1e0a25",
			version = 2,
		},
	},
	
	{
		data = 
		{
			displayPath = "Quantum40",
			name = "LJ Quantum",
			uuid = "ee420cd5-0db9-33ac-8c40-aad7f5e869c0",
		},
		objectType = "folder",
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						aType = "Misc",
						conditions = 
						{
							
							{
								"5485188d-ecba-2fc5-aafe-665761770072",
								true,
							},
							
							{
								"a8f5541e-5c47-c2f8-8448-c8bf00409550",
								true,
							},
							
							{
								"db7d4579-907f-39b7-b172-6b66edd143a5",
								true,
							},
						},
						endIfUsed = true,
						name = "Stop Moving",
						stopMoving = true,
						uuid = "9fa3b01d-c6c8-282c-b6a7-67b2e5f4ba12",
						version = 2.1,
					},
				},
				
				{
					data = 
					{
						aType = "Misc",
						conditions = 
						{
							
							{
								"5485188d-ecba-2fc5-aafe-665761770072",
								true,
							},
							
							{
								"a8f5541e-5c47-c2f8-8448-c8bf00409550",
								true,
							},
							
							{
								"e58acd91-04e3-d91f-9f80-ec5d646975b7",
								true,
							},
							
							{
								"2955e76e-d6c1-84e3-94d9-7565b11b7c2c",
								false,
							},
							
							{
								"693fe82e-8708-e70c-873a-bf286231a30b",
								false,
							},
							
							{
								"f051a4f7-b8c4-c279-a6c2-262d1a147434",
								false,
							},
						},
						endIfUsed = true,
						name = "Target Dark Boss",
						setTarget = true,
						targetContentID = 14038,
						targetType = "ContentID",
						uuid = "18de7548-aa73-37c7-a1f6-1e91f567b1ea",
						version = 2.1,
					},
				},
				
				{
					data = 
					{
						aType = "Misc",
						conditions = 
						{
							
							{
								"5485188d-ecba-2fc5-aafe-665761770072",
								true,
							},
							
							{
								"a8f5541e-5c47-c2f8-8448-c8bf00409550",
								true,
							},
							
							{
								"ede039a8-7958-e8a8-882c-5946fd4798fa",
								true,
							},
							
							{
								"6047a452-1222-a016-a6ef-bb33ed71a0b4",
								false,
							},
							
							{
								"693fe82e-8708-e70c-873a-bf286231a30b",
								false,
							},
							
							{
								"f051a4f7-b8c4-c279-a6c2-262d1a147434",
								false,
							},
						},
						endIfUsed = true,
						name = "Target Light Boss",
						setTarget = true,
						targetContentID = 14037,
						targetType = "ContentID",
						uuid = "93d84d1d-cf4c-a327-b95b-bcdf0f43adca",
						version = 2.1,
					},
				},
				
				{
					data = 
					{
						aType = "Misc",
						conditions = 
						{
							
							{
								"5485188d-ecba-2fc5-aafe-665761770072",
								true,
							},
							
							{
								"a8f5541e-5c47-c2f8-8448-c8bf00409550",
								true,
							},
							
							{
								"f051a4f7-b8c4-c279-a6c2-262d1a147434",
								true,
							},
						},
						endIfUsed = true,
						name = "Target Adds or Nail",
						setTarget = true,
						targetType = "Detection Target",
						uuid = "814a0c68-c483-3342-b4f4-b91d2b3dd7a2",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						localMapIDList = 
						{
							1311,
							1333,
							1290,
						},
						uuid = "5485188d-ecba-2fc5-aafe-665761770072",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return FFXIV_Common_BotRunning",
						name = "Assist Enabled",
						uuid = "a8f5541e-5c47-c2f8-8448-c8bf00409550",
						version = 3,
					},
				},
				
				{
					data = 
					{
						buffID = 4562,
						category = "Self",
						name = "Chains of Condemnation",
						uuid = "db7d4579-907f-39b7-b172-6b66edd143a5",
						version = 3,
					},
				},
				
				{
					data = 
					{
						buffID = 4559,
						category = "Self",
						name = "Dark Vengeance",
						uuid = "e58acd91-04e3-d91f-9f80-ec5d646975b7",
						version = 3,
					},
				},
				
				{
					data = 
					{
						buffID = 4560,
						category = "Self",
						name = "Light Vengeance",
						uuid = "ede039a8-7958-e8a8-882c-5946fd4798fa",
						version = 3,
					},
				},
				
				{
					data = 
					{
						conditionType = 2,
						contentid = 14038,
						name = "Dark Boss Target",
						uuid = "2955e76e-d6c1-84e3-94d9-7565b11b7c2c",
						version = 3,
					},
				},
				
				{
					data = 
					{
						conditionType = 2,
						contentid = 14037,
						name = "Light Boss Target",
						uuid = "6047a452-1222-a016-a6ef-bb33ed71a0b4",
						version = 3,
					},
				},
				
				{
					data = 
					{
						conditionType = 2,
						contentid = 14041,
						name = "Flameborn Target",
						uuid = "693fe82e-8708-e70c-873a-bf286231a30b",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Filter",
						filterTargetType = "ContentID",
						name = "F - Nails",
						partyTargetContentID = 14042,
						uuid = "5c27b545-a9fe-7903-9b71-62fc4205f3a1",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Filter",
						filterTargetSubtype = "Highest HP",
						filterTargetType = "ContentID",
						name = "F - Adds",
						partyTargetContentID = 14039,
						uuid = "b2fe0626-0c36-1950-b025-8e9c6171c5bd",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Filter",
						matchAnyBuff = true,
						name = "F - Adds OR Nails Exist",
						partyTargetNumber = 0,
						uuid = "f051a4f7-b8c4-c279-a6c2-262d1a147434",
						version = 3,
					},
				},
			},
			displayPath = "Quantum40/LJ Quantum",
			name = "Lj: Quantum | Target Selector",
			uuid = "40224de3-4d02-c249-b25b-10539f963535",
			version = 2,
		},
	},
	
	{
		data = 
		{
			displayPath = "Quantum40",
			name = "Mitigations",
			uuid = "9fba9542-7e62-e56d-90c4-6e766c2661a1",
		},
		objectType = "folder",
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "a45f18e4-f6c8-bc73-86ea-9da6d0252332",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "b9731fa9-7d09-dac7-b999-91a5f75abb28",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Alert",
						alertPriority = 3,
						alertScale = 0.9,
						alertTTS = true,
						alertText = "TANK LIMIT BREAK NOW",
						alertVolume = 90,
						conditions = 
						{
							
							{
								"4c23ee99-4416-4473-8536-1c688c147d3f",
								true,
							},
							
							{
								"a9064e4c-00c2-d9cd-b3f2-5c3f3b0a0836",
								true,
							},
							
							{
								"a19b5e12-a8fc-10a7-acb5-3bffee198b2b",
								true,
							},
						},
						displayPath = "Quantum40/Mitigations",
						name = "TTS - Tank LB",
						uuid = "900e73b2-ee19-78c1-82a0-0e186708a6c0",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "1ec9c4ea-9ed6-a35e-a9e7-2076b0b722e6",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "94156228-a9d9-4c0e-be40-6e5e52f7cf9e",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations",
						localMapIDList = 
						{
							1311,
							1333,
							1290,
						},
						name = "Q40 map",
						uuid = "4c23ee99-4416-4473-8536-1c688c147d3f",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations",
						eventArgType = 2,
						eventSpellID = 44171,
						name = "Self-destruct action",
						uuid = "a9064e4c-00c2-d9cd-b3f2-5c3f3b0a0836",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local player = TensorCore.mGetPlayer()\nif not player or not eventArgs or eventArgs.spellID ~= 44171 then\n    return false\nend\n\nif TensorReactions_Q40MitigationRole ~= \"Tank\" then\n    return false\nend\n\nlocal mapID = tonumber(player.localmapid)\nif mapID ~= 1311 and mapID ~= 1333 and mapID ~= 1290 then\n    return false\nend\n\ndata.quantum40_tank_lb_warning = data.quantum40_tank_lb_warning or {}\nlocal state = data.quantum40_tank_lb_warning\nlocal timer = tonumber(TensorReactions_CurrentCombatTimer) or 0\n\nif state.lastTimer ~= nil and timer < state.lastTimer then\n    state.selfDestructCount = 0\nend\n\nstate.lastTimer = timer\nstate.selfDestructCount = (state.selfDestructCount or 0) + 1\nreturn state.selfDestructCount == 3",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations",
						name = "Third Self-destruct (Tank role)",
						uuid = "a19b5e12-a8fc-10a7-acb5-3bffee198b2b",
						version = 3,
					},
				},
			},
			displayPath = "Quantum40/Mitigations",
			eventType = 3,
			name = "[Quantum40] Self-destruct 3 - Tank LB Warning",
			throttleTime = 5000,
			timeout = 3,
			uuid = "7d8acfa2-a1f0-c531-b3f9-3e14a4ae934a",
			version = 2,
		},
	},
	
	{
		data = 
		{
			displayPath = "Quantum40/Mitigations",
			name = "Melee",
			uuid = "2c9c1c1c-89f7-ef9d-a03f-321b9253c143",
		},
		objectType = "folder",
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "7dc28493-30b1-84e6-9377-36f38f0213cf",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "296facb8-9e6c-9229-b853-b4fddc9e33e6",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Melee",
						uuid = "ab884bef-7d12-4537-8142-12cf0d7dc5d7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7549,
						conditions = 
						{
							
							{
								"c5a06620-9486-9d28-9078-8b40868ed592",
								true,
							},
							
							{
								"d657332f-d817-0c0b-a8c2-c2f44c55baeb",
								true,
							},
							
							{
								"01b3f279-4e6b-d2d7-afb0-5ab913a91709",
								true,
							},
							
							{
								"d0842d09-5bf7-1f54-b2fe-5e2828a8b023",
								true,
							},
							
							{
								"46f2a6f2-694b-5290-a60a-86f247bb1782",
								true,
							},
						},
						displayPath = "Quantum40/Mitigations/Melee",
						name = "Feint",
						targetType = "Event Entity",
						uuid = "942fd2bb-cc46-e8a9-942a-7d9d62cf1d90",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "5980f7c4-2ada-7bdc-ade6-256e2938d163",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "a85ba89f-c62b-e39a-92bc-fb778c760a6d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Melee",
						uuid = "c98af0a3-e0d8-0c73-be46-712274ba94ab",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Melee",
						localMapIDList = 
						{
							1311,
							1333,
							1290,
						},
						name = "Q40 map",
						uuid = "c5a06620-9486-9d28-9078-8b40868ed592",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Melee",
						eventArgOptionType = 2,
						eventEntityContentID = 14037,
						name = "Eminent Grief caster",
						uuid = "d657332f-d817-0c0b-a8c2-c2f44c55baeb",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Melee",
						eventArgType = 2,
						eventSpellID = 45119,
						name = "Eminent Grief cast",
						uuid = "01b3f279-4e6b-d2d7-afb0-5ab913a91709",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Melee",
						jobIDList = 
						{
							20,
							22,
							30,
							34,
							39,
							41,
						},
						name = "Melee jobs",
						uuid = "d0842d09-5bf7-1f54-b2fe-5e2828a8b023",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local player = TensorCore.mGetPlayer()\nif not player or not eventArgs or eventArgs.spellID ~= 45119 then\n    return false\nend\n\nlocal roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal slot = roster.mySlot()\nif slot ~= \"M1\" and slot ~= \"M2\" then\n    return false\nend\n\nlocal timer = tonumber(TensorReactions_CurrentCombatTimer) or 0\ndata.quantum40_melee_spinelash = data.quantum40_melee_spinelash or {}\nlocal state = data.quantum40_melee_spinelash\n\nif state.lastTimer ~= nil and timer < state.lastTimer then\n    state.count = 0\n    state.lastTimer = nil\nend\n\nif state.lastTimer ~= nil and math.abs(timer - state.lastTimer) < 1.0 then\n    return false\nend\n\nstate.lastTimer = timer\nstate.count = (state.count or 0) + 1\nreturn state.count >= 2",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Melee",
						name = "Planned occurrence and Melee role",
						uuid = "46f2a6f2-694b-5290-a60a-86f247bb1782",
						version = 3,
					},
				},
			},
			displayPath = "Quantum40/Mitigations/Melee",
			eventType = 3,
			name = "[Quantum40] Spinelash - Melee Feint (Eminent Grief)",
			throttleTime = 5000,
			timeout = 3,
			uuid = "4e5d483f-4f98-7cc6-9cfa-f74f467a49c8",
			version = 2,
		},
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "3361091f-0fc0-0d23-ad5e-d657b6559697",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "6c2fc472-214a-cdcd-81da-e9b1dd78fd39",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Melee",
						uuid = "9c3c306c-b679-2bf0-9774-bad6f3d6d85d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7549,
						conditions = 
						{
							
							{
								"64b29811-b28b-796b-a9db-1f94733d9fef",
								true,
							},
							
							{
								"de157243-b889-3e66-ab1c-441d595203ff",
								true,
							},
							
							{
								"bd799627-5f93-b0c7-80ea-59507696ae2a",
								true,
							},
							
							{
								"7ed81f8d-1e67-7cc0-974c-e191fd3a3d58",
								true,
							},
							
							{
								"fa80284e-358d-ec36-b258-ad2877263a99",
								true,
							},
						},
						displayPath = "Quantum40/Mitigations/Melee",
						name = "Feint",
						targetType = "Event Entity",
						uuid = "6ad08119-28bb-1187-b602-8626e20759eb",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "0803f831-0472-367b-befa-8618bd388627",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "29535866-5bcc-fe8d-9594-c738efcfbea0",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Melee",
						uuid = "26f7844c-e186-7ed0-bc93-711c968f6263",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Melee",
						localMapIDList = 
						{
							1311,
							1333,
							1290,
						},
						name = "Q40 map",
						uuid = "64b29811-b28b-796b-a9db-1f94733d9fef",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Melee",
						eventArgOptionType = 2,
						eventEntityContentID = 14038,
						name = "Devoured Eater caster",
						uuid = "de157243-b889-3e66-ab1c-441d595203ff",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Melee",
						eventArgType = 2,
						eventSpellID = 44164,
						name = "Devoured Eater cast",
						uuid = "bd799627-5f93-b0c7-80ea-59507696ae2a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Melee",
						jobIDList = 
						{
							20,
							22,
							30,
							34,
							39,
							41,
						},
						name = "Melee jobs",
						uuid = "7ed81f8d-1e67-7cc0-974c-e191fd3a3d58",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local player = TensorCore.mGetPlayer()\nif not player or not eventArgs or eventArgs.spellID ~= 44164 then\n    return false\nend\n\nlocal roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal slot = roster.mySlot()\nif slot ~= \"M1\" and slot ~= \"M2\" then\n    return false\nend\n\nlocal timer = tonumber(TensorReactions_CurrentCombatTimer) or 0\ndata.quantum40_melee_unholy_darkness = data.quantum40_melee_unholy_darkness or {}\nlocal state = data.quantum40_melee_unholy_darkness\n\nif state.lastTimer ~= nil and timer < state.lastTimer then\n    state.count = 0\n    state.lastTimer = nil\nend\n\nif state.lastTimer ~= nil and math.abs(timer - state.lastTimer) < 1.0 then\n    return false\nend\n\nstate.lastTimer = timer\nstate.count = (state.count or 0) + 1\nreturn state.count == 3",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Melee",
						name = "Planned occurrence and Melee role",
						uuid = "fa80284e-358d-ec36-b258-ad2877263a99",
						version = 3,
					},
				},
			},
			displayPath = "Quantum40/Mitigations/Melee",
			eventType = 3,
			name = "[Quantum40] Unholy Darkness 3 - Melee Feint (Devoured Eater)",
			throttleTime = 5000,
			timeout = 3,
			uuid = "729daaba-4b69-992a-8aba-a4666d3e9699",
			version = 2,
		},
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "101de1e9-d2f0-1b27-8c93-b7dd5dfca0b9",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "d46fbf6b-61cd-cd27-9aa9-5a54ece6b2b7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Melee",
						uuid = "6f8d9059-26fd-f2bd-83c9-34f3688f16a4",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Alert",
						alertPriority = 3,
						alertScale = 0.9,
						alertTTS = true,
						alertText = "USE PILGRIM'S POTION",
						alertVolume = 90,
						conditions = 
						{
							
							{
								"10a79961-5136-ba4d-a26a-dcbe47bb7a17",
								true,
							},
							
							{
								"cd15c52f-e6ef-ae1a-8d02-febfa3acf6b8",
								true,
							},
							
							{
								"5f7418f1-1e02-916f-aa06-b744f73f441d",
								true,
							},
							
							{
								"a64a04e1-ab41-1d40-baab-78a516992752",
								true,
							},
							
							{
								"fdf9052d-12a6-5028-ac9b-8004a31f6beb",
								true,
							},
						},
						displayPath = "Quantum40/Mitigations/Melee",
						name = "Use Pilgrim's Potion",
						uuid = "a36ada05-c759-713d-b708-b52d0c3a85b7",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "55846b6d-7f52-e231-ae03-2a73571fa65b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "c96ee4bd-40d3-2496-9ca4-d41fa90f60a8",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Melee",
						uuid = "5227ae09-7322-d8d3-bcc8-4342dc586269",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Melee",
						localMapIDList = 
						{
							1311,
							1333,
							1290,
						},
						name = "Q40 map",
						uuid = "10a79961-5136-ba4d-a26a-dcbe47bb7a17",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Melee",
						eventArgOptionType = 2,
						eventEntityContentID = 14037,
						name = "Eminent Grief caster",
						uuid = "cd15c52f-e6ef-ae1a-8d02-febfa3acf6b8",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Melee",
						eventArgType = 2,
						eventSpellID = 44144,
						name = "Searing Chains cast",
						uuid = "5f7418f1-1e02-916f-aa06-b744f73f441d",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Melee",
						jobIDList = 
						{
							20,
							22,
							30,
							34,
							39,
							41,
						},
						name = "Melee jobs",
						uuid = "a64a04e1-ab41-1d40-baab-78a516992752",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local player = TensorCore.mGetPlayer()\nif not player or not eventArgs or eventArgs.spellID ~= 44144 then\n    return false\nend\n\nlocal roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal slot = roster.mySlot()\nif slot ~= \"M1\" and slot ~= \"M2\" then\n    return false\nend\n\nlocal timer = tonumber(TensorReactions_CurrentCombatTimer) or 0\ndata.quantum40_melee_searing_chains = data.quantum40_melee_searing_chains or {}\nlocal state = data.quantum40_melee_searing_chains\n\nif state.lastTimer ~= nil and timer < state.lastTimer then\n    state.count = 0\n    state.lastTimer = nil\nend\n\nif state.lastTimer ~= nil and math.abs(timer - state.lastTimer) < 1.0 then\n    return false\nend\n\nstate.lastTimer = timer\nstate.count = (state.count or 0) + 1\nreturn state.count == 3",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Melee",
						name = "Third cast and Melee role",
						uuid = "fdf9052d-12a6-5028-ac9b-8004a31f6beb",
						version = 3,
					},
				},
			},
			displayPath = "Quantum40/Mitigations/Melee",
			eventType = 2,
			name = "[Quantum40] Searing Chains 3 - Pilgrim's Potion Alert",
			throttleTime = 5000,
			timeout = 3,
			uuid = "7e209b67-784e-0b02-94ca-384d0e4e5889",
			version = 2,
		},
	},
	
	{
		data = 
		{
			displayPath = "Quantum40/Mitigations",
			name = "Extra",
			uuid = "d705a58c-6034-5fdb-8cb2-aa179f74461e",
		},
		objectType = "folder",
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "4e171314-42bc-123c-9a9b-bab5a026a83b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "77ac1927-0224-83a0-b0c4-c38ef2b2821f",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Extra",
						uuid = "9a33473e-ed8b-a0e2-b975-2ebd709d69f6",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 2887,
						conditions = 
						{
							
							{
								"e119fac1-dbb0-eec6-9abe-8ac5f53780cb",
								true,
							},
							
							{
								"565da555-ae75-7489-a340-e0d901af1a75",
								true,
							},
							
							{
								"5c3cf96b-e990-32a1-8cb7-d7d658d25dfa",
								true,
							},
							
							{
								"bbed7e57-6b74-4662-8af2-11fb47f5d5b3",
								true,
							},
							
							{
								"8c68de46-94d3-0d1b-bf78-9031fedcc94d",
								true,
							},
						},
						displayPath = "Quantum40/Mitigations/Extra",
						name = "Dismantle",
						targetType = "Event Entity",
						uuid = "1aea5580-0a69-9850-98d9-32d870625447",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "64824b84-b2a6-69c7-8d32-3065dec7abca",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "ced1ef1f-675c-bfb6-85c5-8308cb4ce456",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Extra",
						uuid = "d5e706f4-363e-5fc7-8c58-bc7cc891a839",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						localMapIDList = 
						{
							1311,
							1333,
							1290,
						},
						name = "Q40 map",
						uuid = "e119fac1-dbb0-eec6-9abe-8ac5f53780cb",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						eventArgOptionType = 2,
						eventEntityContentID = 14037,
						name = "Eminent Grief",
						uuid = "565da555-ae75-7489-a340-e0d901af1a75",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						eventArgType = 2,
						eventSpellID = 45119,
						name = "Spinelash",
						uuid = "5c3cf96b-e990-32a1-8cb7-d7d658d25dfa",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						jobIDList = 
						{
							31,
						},
						name = "Machinist",
						uuid = "bbed7e57-6b74-4662-8af2-11fb47f5d5b3",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 2887,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Quantum40/Mitigations/Extra",
						name = "Dismantle ready",
						uuid = "8c68de46-94d3-0d1b-bf78-9031fedcc94d",
						version = 3,
					},
				},
			},
			displayPath = "Quantum40/Mitigations/Extra",
			eventType = 3,
			name = "[Quantum40] Spinelash - Extra Dismantle (Eminent Grief)",
			throttleTime = 5000,
			timeout = 3,
			uuid = "076eaf13-cad5-3c02-8672-2634ae464135",
			version = 2,
		},
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "5f0ab4b0-26e2-a242-a839-21edeabed775",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "18726694-3dcb-7ddd-97b0-61bae13e53e8",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Extra",
						uuid = "a200d97a-f1a4-ffc1-95bf-b3d6d74a4de3",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 34685,
						conditions = 
						{
							
							{
								"052aa91a-9d0b-a81d-ad07-5bc4e3e81eb6",
								true,
							},
							
							{
								"1f6dc91b-7884-b5d8-b726-aed68568c0fa",
								true,
							},
							
							{
								"29190464-45b2-d947-8c7b-bbc365c107be",
								true,
							},
							
							{
								"25ec32c5-f0b5-e259-a8d1-127cc9397ba6",
								true,
							},
							
							{
								"02052fa3-bc1a-7bc4-b975-deac35c55664",
								true,
							},
						},
						displayPath = "Quantum40/Mitigations/Extra",
						name = "Tempera Coat",
						uuid = "c8757075-3dff-843b-ae8e-5268f0bfe8b7",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "596d7673-9e2d-83f1-ba6d-bcaff1a9ae76",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "9b7bc74f-afae-6699-8d5f-ddd34e0a5e08",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Extra",
						uuid = "7c87b289-8f20-34b4-a858-81edd252fc50",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						localMapIDList = 
						{
							1311,
							1333,
							1290,
						},
						name = "Q40 map",
						uuid = "052aa91a-9d0b-a81d-ad07-5bc4e3e81eb6",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						eventArgOptionType = 2,
						eventEntityContentID = 14037,
						name = "Eminent Grief",
						uuid = "1f6dc91b-7884-b5d8-b726-aed68568c0fa",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						eventArgType = 2,
						eventSpellID = 45119,
						name = "Spinelash",
						uuid = "29190464-45b2-d947-8c7b-bbc365c107be",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						jobIDList = 
						{
							42,
						},
						name = "Pictomancer",
						uuid = "25ec32c5-f0b5-e259-a8d1-127cc9397ba6",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 34685,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Quantum40/Mitigations/Extra",
						name = "Tempera Coat ready",
						uuid = "02052fa3-bc1a-7bc4-b975-deac35c55664",
						version = 3,
					},
				},
			},
			displayPath = "Quantum40/Mitigations/Extra",
			eventType = 3,
			name = "[Quantum40] Spinelash - Extra Tempera Coat",
			throttleTime = 5000,
			timeout = 3,
			uuid = "ab65b34a-9331-8e94-a384-2735787f9bf3",
			version = 2,
		},
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "492bb13c-cd35-c14b-87fc-753d097470c0",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "e8403a71-2eba-cc0b-a3e8-8fa19ef5344c",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Extra",
						uuid = "f642876a-17fe-0b5b-8e95-5513cdfd5f8c",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 34685,
						conditions = 
						{
							
							{
								"efb1d458-27f1-9288-a451-ed3087ca47a0",
								true,
							},
							
							{
								"e8f49a1e-659e-725e-827d-719649b9deef",
								true,
							},
							
							{
								"db0cd96f-c4ff-85f7-9fe9-2bc3cb4c2598",
								true,
							},
							
							{
								"38d34e6c-5df8-d3fa-bbc6-ed6801f0ae53",
								true,
							},
							
							{
								"6d601cdf-ccb4-721b-9b62-03af75b3e5df",
								true,
							},
							
							{
								"5716d74e-ce47-69e4-82e1-55876954914c",
								true,
							},
						},
						displayPath = "Quantum40/Mitigations/Extra",
						name = "Tempera Coat",
						uuid = "ad1e0af3-6497-ca90-bb20-23db082f826f",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "031c9615-8ff1-c849-9eaf-f1f4d017b2f3",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "ea4808f5-9cd2-0846-bd99-1b6ddd5cc08c",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Extra",
						uuid = "3bc11124-0b62-8296-830c-6b69cf9fa7de",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						localMapIDList = 
						{
							1311,
							1333,
							1290,
						},
						name = "Q40 map",
						uuid = "efb1d458-27f1-9288-a451-ed3087ca47a0",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						eventArgOptionType = 2,
						eventEntityContentID = 14041,
						name = "Flameborn",
						uuid = "e8f49a1e-659e-725e-827d-719649b9deef",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						eventArgType = 2,
						eventSpellID = 44171,
						name = "Self-destruct",
						uuid = "db0cd96f-c4ff-85f7-9fe9-2bc3cb4c2598",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						jobIDList = 
						{
							42,
						},
						name = "Pictomancer",
						uuid = "38d34e6c-5df8-d3fa-bbc6-ed6801f0ae53",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 34685,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Quantum40/Mitigations/Extra",
						name = "Tempera Coat ready",
						uuid = "6d601cdf-ccb4-721b-9b62-03af75b3e5df",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local player = TensorCore.mGetPlayer()\nif not player or not eventArgs or eventArgs.spellID ~= 44171 then\n    return false\nend\n\nlocal timer = tonumber(TensorReactions_CurrentCombatTimer) or 0\ndata.quantum40_extra_tempera_selfdestruct = data.quantum40_extra_tempera_selfdestruct or {}\nlocal state = data.quantum40_extra_tempera_selfdestruct\n\nif state.lastTimer ~= nil and timer < state.lastTimer then\n    state.count = 0\n    state.lastTimer = nil\nend\n\nif state.lastTimer ~= nil and math.abs(timer - state.lastTimer) < 1.0 then\n    return false\nend\n\nstate.lastTimer = timer\nstate.count = (state.count or 0) + 1\nreturn state.count == 1",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						name = "First Self-destruct",
						uuid = "5716d74e-ce47-69e4-82e1-55876954914c",
						version = 3,
					},
				},
			},
			displayPath = "Quantum40/Mitigations/Extra",
			eventType = 3,
			name = "[Quantum40] Self-destruct 1 - Extra Tempera Coat",
			throttleTime = 5000,
			timeout = 3,
			uuid = "aad20d1c-8113-6d69-b8b0-25258b93bf7f",
			version = 2,
		},
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "5a63e415-2638-47d3-946b-6249939a5b4d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "58178415-319f-82ec-95e8-7633f6019672",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Extra",
						uuid = "b9e7e193-ccdd-08e9-8acf-b79eeb31fc97",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7560,
						conditions = 
						{
							
							{
								"7334a929-f60e-e0d1-835a-7f472473fa52",
								true,
							},
							
							{
								"30eafe88-b789-76f8-be2f-4bed952fb853",
								true,
							},
							
							{
								"0b1ac748-dc71-35c2-afbf-13683d0772e5",
								true,
							},
							
							{
								"b4ba838a-c69b-4aad-86e1-834132030cc8",
								true,
							},
							
							{
								"33d5f5b9-adb5-f6e6-9e55-4f9ba1e4e690",
								true,
							},
							
							{
								"db7d2a3c-e951-4121-9347-3c1238a31794",
								true,
							},
						},
						displayPath = "Quantum40/Mitigations/Extra",
						name = "Addle",
						targetType = "Event Entity",
						uuid = "c89d6444-452f-8ce1-a5b0-871543f350b2",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "eb1d3963-57ce-1b2c-92de-7a07475aef48",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "e35481de-4bf7-878d-8d19-fca083c375bc",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Extra",
						uuid = "1698985f-780e-44c9-ac5e-470896e0fe3b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						localMapIDList = 
						{
							1311,
							1333,
							1290,
						},
						name = "Q40 map",
						uuid = "7334a929-f60e-e0d1-835a-7f472473fa52",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						eventArgOptionType = 2,
						eventEntityContentID = 14038,
						name = "Devoured Eater",
						uuid = "30eafe88-b789-76f8-be2f-4bed952fb853",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						eventArgType = 2,
						eventSpellID = 44164,
						name = "Unholy Darkness",
						uuid = "0b1ac748-dc71-35c2-afbf-13683d0772e5",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						jobIDList = 
						{
							25,
							27,
							35,
							42,
						},
						name = "Caster jobs",
						uuid = "b4ba838a-c69b-4aad-86e1-834132030cc8",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7560,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Quantum40/Mitigations/Extra",
						name = "Addle ready",
						uuid = "33d5f5b9-adb5-f6e6-9e55-4f9ba1e4e690",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local player = TensorCore.mGetPlayer()\nif not player or not eventArgs or eventArgs.spellID ~= 44164 then\n    return false\nend\n\nlocal timer = tonumber(TensorReactions_CurrentCombatTimer) or 0\ndata.quantum40_extra_addle_unholy = data.quantum40_extra_addle_unholy or {}\nlocal state = data.quantum40_extra_addle_unholy\n\nif state.lastTimer ~= nil and timer < state.lastTimer then\n    state.count = 0\n    state.lastTimer = nil\nend\n\nif state.lastTimer ~= nil and math.abs(timer - state.lastTimer) < 1.0 then\n    return false\nend\n\nstate.lastTimer = timer\nstate.count = (state.count or 0) + 1\nreturn state.count == 1 or state.count == 3",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						name = "First or third Unholy Darkness",
						uuid = "db7d2a3c-e951-4121-9347-3c1238a31794",
						version = 3,
					},
				},
			},
			displayPath = "Quantum40/Mitigations/Extra",
			eventType = 3,
			name = "[Quantum40] Unholy Darkness - Extra Addle (Devoured Eater)",
			throttleTime = 5000,
			timeout = 3,
			uuid = "2698723d-895a-ab4f-9d46-99163aeb106f",
			version = 2,
		},
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "0b3609b2-2ec2-77ae-a396-901eb21a0c7b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "abcc40f0-80ab-1792-90e9-58f2b08b3dd9",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Extra",
						uuid = "a3062da1-e751-66ca-a98f-9047ed45f9e6",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 25857,
						conditions = 
						{
							
							{
								"119cd133-7ef3-9e91-9811-938c95ef6b98",
								true,
							},
							
							{
								"2da494a9-0e57-84e9-a237-87e56385a0a4",
								true,
							},
							
							{
								"86afa486-7148-9553-b9a7-08e9be242dc5",
								true,
							},
							
							{
								"486b02dc-fb84-a16a-9000-ce132ed6c08b",
								true,
							},
							
							{
								"4824f96e-d4bf-9f6f-848d-4e8950e377e3",
								true,
							},
						},
						displayPath = "Quantum40/Mitigations/Extra",
						name = "Magick Barrier",
						uuid = "b5ca2bda-e355-be3a-96a9-7010d527dffa",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "9c804006-0b4f-9306-a0df-234df6efb929",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "143dbba4-c823-1b81-87f8-3867aa1c62a9",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Extra",
						uuid = "64ac8fdb-4d00-a41f-91d7-e56ea3264e51",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						localMapIDList = 
						{
							1311,
							1333,
							1290,
						},
						name = "Q40 map",
						uuid = "119cd133-7ef3-9e91-9811-938c95ef6b98",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						eventArgOptionType = 2,
						eventEntityContentID = 14037,
						name = "Eminent Grief",
						uuid = "2da494a9-0e57-84e9-a237-87e56385a0a4",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						eventArgType = 2,
						eventSpellID = 44139,
						name = "Abyssal Sun",
						uuid = "86afa486-7148-9553-b9a7-08e9be242dc5",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						jobIDList = 
						{
							35,
						},
						name = "Red Mage",
						uuid = "486b02dc-fb84-a16a-9000-ce132ed6c08b",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 25857,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Quantum40/Mitigations/Extra",
						name = "Magick Barrier ready",
						uuid = "4824f96e-d4bf-9f6f-848d-4e8950e377e3",
						version = 3,
					},
				},
			},
			displayPath = "Quantum40/Mitigations/Extra",
			eventType = 2,
			name = "[Quantum40] Abyssal Sun - Extra Magick Barrier",
			throttleTime = 5000,
			timeout = 3,
			uuid = "398f1a36-5ed3-f8f6-9ebf-bb1cbf630499",
			version = 2,
		},
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "7f414b7f-6e5b-2855-897c-d134206f0fc9",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "68b073bb-994f-d824-bb6e-77eabce61f3d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Extra",
						uuid = "0c084d91-8663-9a76-8c88-a4a5cb6a0f4c",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 25857,
						conditions = 
						{
							
							{
								"7d1afcda-1d13-e320-b4ec-577f6cfbd60b",
								true,
							},
							
							{
								"993f3060-237d-8114-8fff-2ac1d5b60550",
								true,
							},
							
							{
								"1be02f14-25a7-39d4-bb78-630b1b5ebae0",
								true,
							},
							
							{
								"fea8da52-75b9-81a4-9a30-d93d297ee964",
								true,
							},
							
							{
								"913a2a0c-7188-ac4f-bbcd-3fc5701bf205",
								true,
							},
							
							{
								"b988ca7f-df68-631c-9266-b895e8029f5a",
								true,
							},
						},
						displayPath = "Quantum40/Mitigations/Extra",
						name = "Magick Barrier",
						uuid = "cbc12a70-aa13-4c0c-ad18-140ecc49b8be",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
				
				{
					data = 
					{
						displayPath = "",
						name = "Quantum40",
						uuid = "6066f0bb-07e2-bcc9-b2f7-280e4fcd4bae",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40",
						name = "Mitigations",
						uuid = "785654b1-d71d-0f6f-94a4-ec899ad5a129",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Quantum40/Mitigations",
						name = "Extra",
						uuid = "9234a450-97b7-3ba5-a14a-17146b91ea81",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						localMapIDList = 
						{
							1311,
							1333,
							1290,
						},
						name = "Q40 map",
						uuid = "7d1afcda-1d13-e320-b4ec-577f6cfbd60b",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						eventArgOptionType = 2,
						eventEntityContentID = 14037,
						name = "Eminent Grief",
						uuid = "993f3060-237d-8114-8fff-2ac1d5b60550",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						eventArgType = 2,
						eventSpellID = 44144,
						name = "Searing Chains",
						uuid = "1be02f14-25a7-39d4-bb78-630b1b5ebae0",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						jobIDList = 
						{
							35,
						},
						name = "Red Mage",
						uuid = "fea8da52-75b9-81a4-9a30-d93d297ee964",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 25857,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Quantum40/Mitigations/Extra",
						name = "Magick Barrier ready",
						uuid = "913a2a0c-7188-ac4f-bbcd-3fc5701bf205",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local player = TensorCore.mGetPlayer()\nif not player or not eventArgs or eventArgs.spellID ~= 44144 then\n    return false\nend\n\nlocal timer = tonumber(TensorReactions_CurrentCombatTimer) or 0\ndata.quantum40_extra_magick_searing = data.quantum40_extra_magick_searing or {}\nlocal state = data.quantum40_extra_magick_searing\n\nif state.lastTimer ~= nil and timer < state.lastTimer then\n    state.count = 0\n    state.lastTimer = nil\nend\n\nif state.lastTimer ~= nil and math.abs(timer - state.lastTimer) < 1.0 then\n    return false\nend\n\nstate.lastTimer = timer\nstate.count = (state.count or 0) + 1\nreturn state.count == 2",
						dequeueIfLuaFalse = true,
						displayPath = "Quantum40/Mitigations/Extra",
						name = "Second Searing Chains",
						uuid = "b988ca7f-df68-631c-9266-b895e8029f5a",
						version = 3,
					},
				},
			},
			displayPath = "Quantum40/Mitigations/Extra",
			eventType = 2,
			name = "[Quantum40] Searing Chains 2 - Extra Magick Barrier",
			throttleTime = 5000,
			timeout = 3,
			uuid = "17cae36f-ad88-afe1-9725-0cf084517095",
			version = 2,
		},
	},
	
	{
		data = 
		{
			displayPath = "",
			name = "Definitions",
			uuid = "78b6778a-f3f4-a8b4-a758-9a31de70f01d",
		},
		objectType = "folder",
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "---@alias U32Color integer\n---@alias ArgusRenderFlags integer\n---If omitted, renderFlags defaults to FLAG_WARP_TERRAIN (Argus2.RenderFlags.FLAG_WARP_TERRAIN).\n---Use FLAG_OCCLUDE for invisible blocker draws; combine it with FLAG_WARP_TERRAIN when the shape should follow uneven ground.\n---Use FLAG_OCCLUSION_BASE for the visible base draw that receives occluder cutouts, outlines, and gradients for its occlusion channel.\n---Use FLAG_RENDER_UI when 3D draws should avoid being affected by weather effects and other misc effects, but still render underneath the in-game UI and behind objects.\n---Pass 0 for flat non-overlay rendering. Ignored when oldDraw is true.\n---occlusionChannel is separate from renderFlags. If omitted, it defaults to channel 0. Use raw integer channel indices 0..31.\n---Channel 0 is the default channel; Argus2.getNextUnusedChannel does not return it.\n---Use Argus2.getNextUnusedChannel(true) when a draw needs its own available channel for this frame.\n",
						uuid = "5e285f9e-121e-2b08-9d23-da13ade947fb",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
			},
			displayPath = "Definitions",
			name = "Subtractive draws",
			uuid = "9fb8283e-950b-9b71-89cb-e955b3ca04d9",
			version = 2,
		},
		inheritedIndex = 27,
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "---Adds floating text into the game for a certain amount of time.\n---@param time number @Milliseconds to render the text for.\n---@param text string @Text of the render.\n---@param position ThreeDimensionalPos @Position of the render.\n---@param color? integer @RGB U32 color of the text.\n---@param background? boolean @Whether the text should have a transparent black box to help make it pop out.\n---@param sizeMultiplier? number @Makes text size larger. ie; 1.5 would be 1.5x or 50% larger than default.\n---@return string @UUID of world text.\nfunction AnyoneCore.addTimedWorldText(time, text, position, color, background, sizeMultiplier) end\n\n---Adds floating text into the game tied to a given entity's position.\n---@param timer integer @Milliseconds to render the text for.\n---@param str string @Text to display.\n---@param entID number @ID of the entity to draw on\n---@param color? number @U32 value of a color\n---@param bg? boolean @Whether to add a dark background to make the text more visible\n---@param sizeMultiplier? number @Multiplies the scale of the text\n---@param heightAddition? number @Adds extra height to the y value of entity position if needed to make the text more visible.\n---@return string @UUID of world text.\nfunction AnyoneCore.addTimedWorldTextOnEnt(timer, str, entID, color, bg, sizeMultiplier, heightAddition) end\n\n-- REUSABLE ENTITY-FOLLOWING COUNTDOWN (added 18-10-2026; original documentation above retained)\n-- Installed by [Helper] Entity-following world countdowns in jacob's toolbox and TOPReactions\\lpdudraws.\n-- Public helper API authored here, independent of AnyoneCore's undocumented OnEnt-countdown overload:\n-- JacobWorldText.addEntityCountdown(timeoutMs, entityID, colorU32, background, sizeMultiplier, heightAddition, key)\n-- timeoutMs: total remaining lifetime in milliseconds; call ONCE per mechanic.\n-- entityID: entity to follow; heightAddition defaults to1; sizeMultiplier defaults to1.\n-- colorU32 defaults white; background defaults true. Optional key deduplicates a still-active timer.\n-- Returns the timer key; JacobWorldText.cancelEntityCountdown(key) removes only that timer.\n-- Example (inside an event reaction, after the helper has installed):\n-- local p=TensorCore.mGetPlayer()\n-- JacobWorldText.addEntityCountdown(4300,p.id,0xFF33FF33,true,1.1,1,'p1-personal-spread')\n-- A shared OnDraw renderer updates text and entity position continuously; no per-second timed-text recreation.\n-- The SAME installer can exist in general and timeline profiles: one global registry/version/frame guard prevents duplicate draws.\n-- Expired, dead/missing-entity and changed-map entries clean themselves up; offscreen entities simply do not render.\n-- Wait for JacobWorldText to exist before committing a one-shot assignment if called before the first OnDraw.\n-- Definitions/reference: GUI:GetFrameCount, GUI:AddText, GUI:CalcTextSize, GUI:AddRectFilled, GUI:SetWindowFontScale.\n-- World-to-screen reference: https://wiki.mmominion.com/doku.php?id=gui_api\n-- Native draw reference: RenderManager:WorldToScreen({x=...,y=...,z=...},true) returns screen x,y.\n-- AnyoneCore.addWorldTextCountdownOnEnt was observed by name only; its argument signature is NOT established here.\n",
						uuid = "ea21fcfe-15a1-a809-9cb4-6f9c0c4e4cb4",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
			},
			displayPath = "Definitions",
			enabled = false,
			name = "Documentation for world text",
			uuid = "ec34525c-0d4e-1d94-a57a-fa075f57a34b",
			version = 2,
		},
		inheritedIndex = 28,
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "# Party Roster — implementation guide (usage.md)\n\nStatus: Current reference.\nAudience: reaction/encounter authors wiring the Party Roster into profiles.\nArchitecture and rationale: `design.md` (same folder). Modules:\n`modules/utility/roster.lua` (identity), `modules/utility/roster_derive.lua`\n(derivations + resolver), `modules/utility/roster_strategies_dmu.lua`\n(example encounter payloads), `modules/draw/roster_popup.lua` (UI).\n\nThe tiers below are cumulative: most encounters only ever need Tier 1.\n\n---\n\n## Concepts (30 seconds)\n\n- **Slots**: `T1 T2 H1 H2 M1 M2 R1 R2` — canonical, always. Display\n  notation (MT/OT, D1-D4, C1) exists only in `Roster.labelFor`.\n- **Record**: the persisted party->slot mapping, keyed by member guid\n  (a string). Auto-recalled when the same 8 people group up; replacing one\n  player re-seats only that slot. Users confirm/edit in the popup; you\n  never manage records from reaction code.\n- **Effective seating**: what `slotOf/entOf/idOf/mySlot` return. Normally\n  the record; while an observed overlay is active (Tier 5) it is the\n  observation. Reactions do not need to care which.\n- **Everything is entity-id keyed at the boundary**: roster reads hand you\n  live ids/entities; publish id-keyed tables into `data.*` exactly like\n  every other `[Core]` producer.\n\n## Tier 1 — basic party priority (most encounters stop here)\n\nGoal: your reactions need \"who is M1\" or \"rank these 8 players\".\n\n**1. Give the encounter a roster row** so users see and edit the roster on\nits General tab (`modules/draw/reaction_schema.lua`):\n\n```lua\nrows = {\n    ros(),          -- Party Roster summary + Edit button\n    ...\n}\n```\n\n**2. Gate on the roster existing** (conditionLua):\n\n```lua\nreturn AnyoneCore.Roster ~= nil and AnyoneCore.Roster.current() ~= nil\n```\n\n`Roster.current()` is non-nil once 8 guid-carrying members resolved.\n`Roster.isReady()` is stricter: all 8 slots resolve to LIVE entities right\nnow (use for draws that need positions immediately).\n\n**3. Read identity/ranks in a `[Core]` setup action** and publish to\n`data.*`:\n\n```lua\nlocal Roster = AnyoneCore.Roster\nlocal prio = Roster.prio(\"conga\")   -- T1 T2 H1 H2 M1 M2 R1 R2\n-- prio.byId[entityID] = 1..8, prio.byRank[1..8] = entityID,\n-- prio.bySlot[\"M1\"] = rank\nif (#prio.byRank ~= 8) then self.used = true return end\ndata.myPriority = prio.byId\n```\n\nDirect lookups, any time (cheap table reads, drift-repaired ids):\n\n```lua\nRoster.slotOf(entID)     -- \"M1\" | nil     (also accepts a guid string)\nRoster.idOf(\"T1\")        -- entity id | nil (cached, ValidatePartyData-repaired)\nRoster.entOf(\"T1\")       -- live GameObject | nil\nRoster.mySlot()          -- the local player's slot\nRoster.labelFor(\"R2\")    -- display text honoring the user's notation settings\n```\n\nSorting anything by priority:\n\n```lua\ntable.sort(list, function(a, b)\n    return (prio.byId[a.id] or 99) < (prio.byId[b.id] or 99)\nend)\n```\n\nOrder specs accept stock names (`\"conga\"`, `\"pantokrator\"`, `\"TMRH\"`,\n`\"partyListSupport\"`, `\"partyListDps\"`, `\"supports\"`, `\"dps\"`, `\"g1\"`,\n`\"g2\"`) or any slot string like `\"R1 M1 M2 R2\"`.\n\nThat is a complete basic integration: no observers, no strategies, no UI\nwork beyond the `ros()` row.\n\n## Tier 2 — groups, pairs, spots, schedules\n\nAll in `roster_derive.lua`; everything returns entity-id keyed structures.\n\n```lua\nRoster.groups(\"support\")        -- id[] for one stock group\nRoster.groups()                 -- all: support/dps/tanks/healers/melee/\n                                --      ranged/g1/g2/trueLP1/trueLP2\nRoster.pairsOf(\"lightPairs\")    -- pairs list + partnerOf[id] = partnerId\n-- stock pair specs: rolePairs (T+T/H+H/M+M/R+R), pairStacks (T1+M1...),\n-- quadPairs/colorPartners (T1+R1...), lightPairs/jpFixed (T1+H1, M1+R1)\n-- or explicit: Roster.pairsOf({ T1 = \"H2\", T2 = \"H1\", M1 = \"R1\", M2 = \"R2\" })\n\nRoster.spotMap(\"clockSupportsCardinals\")  -- byId[id]=\"N\", bySlot[\"T1\"]=\"N\"\nRoster.zip(\"THMR\", { \"A\", \"B\", \"C\", \"D\" })-- rank i -> spots[i], byId\nRoster.scheduleAt(\"AAABBBBA\", setIdx)     -- \"A\"/\"B\" (cycles)\nRoster.rotate(n, 2, 4)                    -- \"2 places ahead\" arithmetic\n```\n\nPersonal assignments (\"what am I doing for mechanic X\"): publish once,\nresolve per-player:\n\n```lua\nRoster.pull.set(\"towers\", byIdOrBySlotTable)  -- per-pull, wipe-cleared\nlocal mine = Roster.my(\"towers\")              -- my id first, then my slot\n```\n\nLabels: `Roster.showLabels()` re-draws slot labels (the popup button does\nthis); labels re-show automatically after roster edits and observations.\n\n## Tier 3 — strategy payloads + user overrides\n\nWhen an encounter has named community strategies whose pairings/orders/spot\nmaps differ, ship them as data instead of settings rows (this is what\ncollapsed the DMU Forsaken tab from ~30 controls to 3).\n\n```lua\nAnyoneCore.Roster.registerStrategy(\"enc.mechanic.3\", {\n    version = 1,\n    label = \"MeowBraindead\",\n    pairs = { buddies = { T1 = \"H1\", T2 = \"H2\", M1 = \"R1\", M2 = \"R2\" } },\n    orders = { cone = \"R1 M1 M2 R2\" },\n    spotMaps = { tether = { T1 = \"N\", T2 = \"W\", ... } },\n})\n```\n\nRegistration validates: `version` required; order specs must parse to real\nslots; pair maps must cover 8 slots exactly once (4 entries, no self-pairs,\nno reuse). Invalid payloads are rejected with a log line.\n\nConventions (see `roster_strategies_dmu.lua` for the worked example):\n\n- Register at file scope in a `modules/utility/roster_strategies_<enc>.lua`\n  placed AFTER `roster_derive.lua` in `module.def`.\n- Seed payloads VERBATIM from what the community strat prescribes.\n- User deviations are per-strat override tables in the encounter's settings\n  (e.g. `forsakenPairOverrides[tostring(strat)]` = full pair map), read by\n  a small glue helper — never mutate the shipped payload, so switching\n  strategies can never clobber a hand-tuned override.\n- Give overrides a collapsed \"advanced\" drawer (see\n  `RS_dmuForsakenOverrides` in `reaction_panel.lua`): preset radio choices\n  are valid-by-construction and beat 8 free dropdowns.\n\n## Tier 4 — runtime composition (resolveFlex)\n\nFor the dominant ultimate idiom — a runtime partition (debuffs, tethers,\nmarkers) crossed with a slot priority and a flex rule (\"the higher priority\nof the doubles flexes to the other group\"):\n\n```lua\nlocal groups, swaps = Roster.resolveFlex({\n    groups = { g1 = g1Ids, g2 = g2Ids },  -- exactly two base groups\n    attrOf = attrById,                    -- runtime fact per id (your job)\n    prio = \"M1 M2 R1 R2 T1 T2 H1 H2\",     -- who counts as \"higher\"\n    polarity = \"higherMoves\",             -- or \"higherStays\"\n    flexClass = \"melee\",                  -- optional: restrict movers\n    pins = { [tankId] = true },           -- optional: never move these\n    partnerDrag = \"lightPairs\",           -- optional: partner crosses too\n    sticky = \"apocGroups\",                -- optional: freeze in Roster.pull\n})\n```\n\nDeterministic on every client given the same inputs. Duplicated attributes\ninside a group are resolved by swapping with the other group's duplicate\nholder; an id never moves twice per resolution (inconsistent inputs stop\nwith a log instead of ping-ponging). Division of labor is a standing rule:\nthe REACTION gathers the runtime facts (debuff scans, tether events,\ngeometry); the resolver only decides who moves.\n\n## Tier 5 — observe mode (solver write-through)\n\nOnly for encounters with a recorded mechanic that reveals seating (the DMU\nWave Cannon / Teletrounce pattern). The roster then self-learns in PF and\nverifies in statics — with zero extra UI.\n\nSolver side (append to the solver's actionLua after it stores results):\n\n```lua\nif (AnyoneCore.Roster ~= nil and AnyoneCore.Roster.observeSlots ~= nil) then\n    AnyoneCore.Roster.observeSlots({\n        T1 = ids.T1, T2 = ids.T2, H1 = ids.H1, H2 = ids.H2,\n        M1 = ids.M1, M2 = ids.M2, R1 = ids.R1, R2 = ids.R2,\n    }, \"Wave Cannon\")\nend\n```\n\n(If the solver speaks D1-D4, convert through the strategy's DPS order — see\n`RosterStrategies.dmuObserveForsaken`.)\n\nEverything else is automatic, gated by the record's trust tier:\n\n- **Unconfirmed roster** (new party, never confirmed): the observation\n  becomes the effective seating for the pull; labels re-draw; the popup\n  offers \"Adopt as saved roster\" at the next PartyWipe/CombatEnd.\n- **Confirmed roster** (popup \"Confirm\"): the observation only VERIFIES —\n  matching seating is silent; a mismatch toasts mid-pull and the popup shows\n  \"expected X, saw Y\" with Adopt/Dismiss after the pull. Never a silent\n  re-seat.\n- **Locked roster** (popup \"Lock in\"): observations are ignored entirely —\n  no warning, no overlay. This is how a group stops the mismatch nag\n  mid-session. `observeSlots` returns early when the record is locked.\n- Lifecycle (standing rule — do not \"simplify\"): observations survive\n  wipes, are overwritten by the next pull's observation, and are cleared by\n  zone/membership changes, manual edits, or adopt/dismiss.\n- `Roster.mode()` / `Roster.confirm()` exist, but reaction code should not\n  need them; the `identityMode` setting (auto/static/observe) is the user\n  override.\n\n## Testing and tooling\n\n- **Offline sims**: `tools/tensor-reactions/sim/stubs.lua` stubs identity\n  reads from `fixture.roster` (slot -> entity id) + `fixture.mySlot`. For\n  derivations/resolveFlex in a sim, `dofile` the real\n  `modules/utility/roster_derive.lua` against that stub.\n- **Profile edits**: bodies via\n  `tools/tensor-reactions/action_lua.py extract/replace --uuid <actionUuid>`\n  (the uuid sits a few lines BELOW the action's `name =` line). Gotcha:\n  the helper writes LF — if the target file is CRLF (`stagingParty.lua`),\n  reconvert after editing or the diff explodes.\n- **Gates**: `reaction_check` (MCP) on every edited reaction;\n  `tools/scripts/check_reaction_settings_invariants.py` (guards\n  migration-vs-payload pairing sync); repo LuaLS + the concatenated\n  `module.def` compile per `CLAUDE.md`.\n- **Settings**: user-facing options live in `AnyoneCore.Settings.Roster`\n  (labels, notation, `anonymizeNames`, popup/toast, `nearMatchTolerance`,\n  `identityMode`),\n  surfaced in the GUI at Reactions > General > Party Roster (the\n  `schema.encounters.Roster` page, whose rows use `scope = \"Settings.Roster\"`\n  — a dotted scope path `_RSStore` resolves from `AnyoneCore`). Roster\n  records live in `AnyoneData.RosterProfiles` (own settings file). Do not\n  write either from reaction code.\n",
						uuid = "457af3f6-8adc-a79e-824a-cbf38f26cde8",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
			},
			displayPath = "Definitions",
			enabled = false,
			name = "Partyrole documentation",
			uuid = "524f499f-0239-ef17-a2f5-eda3715ba5c8",
			version = 2,
		},
		inheritedIndex = 29,
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "if data.clicked then\n    self.colorBoolean = not self.colorBoolean\n    if not self.colorBoolean then\n        AnyoneCore.Navigation.stop(\"move to flag cancelled\")\n    end\nend\n\nif self.colorBoolean then\n    local flag = GetMapFlagPosition()\n    local p = TensorCore.mGetPlayer()\n    if not (flag and flag.mapid and flag.x and flag.z) then\n        d(\"[Move To Flag] No valid map flag.\")\n        self.colorBoolean = false\n        return\n    end\n\n    if not CanAccessMap(flag.mapid) then\n        d(\"[Move To Flag] You cannot access that map.\")\n        self.colorBoolean = false\n        return\n    end\n\n    local goal = { x = flag.x, y = p.pos.y, z = flag.z, mapID = flag.mapid }\n    if p.localmapid == flag.mapid and NavigationManager ~= nil then\n        local meshPoint = NavigationManager:GetClosestPointOnMesh(goal)\n        if table.valid(meshPoint) then\n            goal = meshPoint\n            goal.mapID = flag.mapid\n        end\n    end\n\n    AnyoneCore.Navigation.goTo(goal, { range = 2, mapID = flag.mapid, overwrite = true })\n    if p.localmapid == flag.mapid and TensorCore.getDistance3d(p.pos, goal) <= 3 then\n        d(\"[Move To Flag] Arrived at location.\")\n        self.colorBoolean = false\n    end\nend",
						uuid = "8b452dea-7543-64d5-a327-0f8f7a1a8d68",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
			},
			displayPath = "Definitions",
			enabled = false,
			name = "Navigation API",
			uuid = "22161195-c5d8-ce9c-b618-47029b5dd937",
			version = 2,
		},
		inheritedIndex = 30,
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "GUI:Begin(\"party GUI\",true,GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoScrollWithMouse + GUI.WindowFlags_NoCollapse + GUI.WindowFlags_AlwaysAutoResize)\nif data.JOBID_to_name == nil then\n    data.JOBID_to_name = {\n    \"GLA\",\n    \"PGL\",\n    \"MRD\",\n    \"LNC\",\n    \"ARC\",\n    \"CNJ\",\n    \"THM\",\n    \"CRP\",\n    \"BSM\",\n    \"ARM\",\n    \"GSM\",\n    \"LTW\",\n    \"WVR\",\n    \"ALC\",\n    \"CUL\",\n    \"MIN\",\n    \"BTN\",\n    \"FSH\",\n    \"PLD\",\n    \"MNK\",\n    \"WAR\",\n    \"DRG\",\n    \"BRD\",\n    \"WHM\",\n    \"BLM\",\n    \"ACN\",\n    \"SMN\",\n    \"SCH\",\n    \"ROG\",\n    \"NIN\",\n    \"MCH\",\n    \"DRK\",\n    \"AST\",\n    \"SAM\",\n    \"RDM\",\n    \"BLU\",\n    \"GNB\",\n    \"DNC\",\n    \"RPR\",\n    \"SGE\",\n    \"VPR\",\n    \"PCT\",\n}\nend\nif table.size(megaminx_ppparty) == 0 then\n    local party = TensorCore.getEntityGroupList(\"ContentID\",{contentid=0}) \n    megaminx_ppparty = {party = {},pos=0,selected = 1}\n    if table.size(party) < 9 then\n        for k,v in pairs(party) do\n            table.insert(megaminx_ppparty.party,{id = v.id,name = v.name, job = v.job})\n        end\n    end\n    local p = TensorCore.mGetPlayer()\n    table.insert(megaminx_ppparty.party,{id = p.id,name = p.name,job = p.job})\n\n    local job_order = {\n        \"WAR\", \"PLD\", \"GNB\", \"DRK\", \"AST\", \"WHM\", \"SGE\", \"SCH\",\n        \"SAM\", \"MNK\", \"VPR\", \"RPR\", \"DRG\", \"NIN\", \"BRD\", \"MCH\",\n        \"DNC\", \"PCT\", \"BLM\", \"SMN\", \"RDM\"\n    }\n    \n    -- Create a lookup table for job order priority\n    local job_priority = {}\n    for priority, job_name in ipairs(job_order) do\n        job_priority[job_name] = priority\n    end\n\n    table.sort(megaminx_ppparty.party, function(a, b)\n        local job_a = data.JOBID_to_name[a.job]\n        local job_b = data.JOBID_to_name[b.job]\n        local priority_a = job_priority[job_a] or math.huge -- Default to high number if not found\n        local priority_b = job_priority[job_b] or math.huge -- Default to high number if not found\n        return priority_a < priority_b\n    end)\nend\n\n\n\nGUI:Button(\"Get Party\")\nif (GUI:IsItemHovered()) then\n\tif (GUI:IsMouseClicked(0)) then\n        megaminx_ppparty.party = {}\n        local party = TensorCore.getEntityGroupList(\"ContentID\",{contentid=0}) \n        --local party = TensorCore.getEntityGroupList(\"Party\")\n\t\tif table.size(party) < 9 then\n            for k,v in pairs(party) do\n                table.insert(megaminx_ppparty.party,{id = v.id,name = v.name, job = v.job})\n            end\n        end\n        local p = TensorCore.mGetPlayer()\n        table.insert(megaminx_ppparty.party,{id = p.id,name = p.name,job = p.job})\n\n        local job_order = {\n            \"WAR\", \"PLD\", \"GNB\", \"DRK\", \"AST\", \"WHM\", \"SGE\", \"SCH\",\n            \"SAM\", \"MNK\", \"VPR\", \"RPR\", \"DRG\", \"NIN\", \"BRD\", \"MCH\",\n            \"DNC\", \"PCT\", \"BLM\", \"SMN\", \"RDM\"\n        }\n        \n        local job_priority = {}\n        for priority, job_name in ipairs(job_order) do\n            job_priority[job_name] = priority\n        end\n\n        table.sort(megaminx_ppparty.party, function(a, b)\n            local job_a = data.JOBID_to_name[a.job]\n            local job_b = data.JOBID_to_name[b.job]\n            local priority_a = job_priority[job_a] or math.huge -- Default to high number if not found\n            local priority_b = job_priority[job_b] or math.huge -- Default to high number if not found\n            return priority_a < priority_b\n        end)\n\tend\nend\n\nlocal screenX,screenY = GUI:GetScreenSize()\nGUI:ListBoxHeader(\"##Jobs\", 200, 250)\nfor i=1,table.size(megaminx_ppparty.party) do\n    local currentseletion = function() if i == megaminx_ppparty.selected then return true end return false end\n    --d(currentseletion())\n    GUI:Selectable(\"[\" .. data.JOBID_to_name[megaminx_ppparty.party[i].job] .. \"]\" .. megaminx_ppparty.party[i].name, currentseletion())\n    if GUI:IsItemHovered(GUI.HoveredFlags_AllowWhenBlockedByPopup + GUI.HoveredFlags_AllowWhenBlockedByActiveItem + GUI.HoveredFlags_AllowWhenOverlapped) then\n        if GUI:IsMouseDown(0) then\n            if megaminx_ppparty.pos == 0 then\n                if megaminx_ppparty.pos ~= i then megaminx_ppparty.pos = i end\n                if megaminx_ppparty.selected ~= i then megaminx_ppparty.selected = i end\n            elseif megaminx_ppparty.pos ~= i then\n                local move = megaminx_ppparty.party[megaminx_ppparty.pos]\n                megaminx_ppparty.party[megaminx_ppparty.pos] = megaminx_ppparty.party[i]\n                megaminx_ppparty.party[i] = move\n                megaminx_ppparty.pos = i\n                if megaminx_ppparty.selected ~= i then megaminx_ppparty.selected = i end\n            end\n        end\n    end\n    if megaminx_ppparty.pos ~= 0 and (GUI:IsMouseReleased(0) or not GUI:IsMouseDown(0)) then\n        megaminx_ppparty.pos = 0\n    end\nend\n\nGUI:ListBoxFooter()\nif megaminx_ppparty.pos ~= 0 and not GUI:IsItemHovered(GUI.HoveredFlags_AllowWhenBlockedByPopup + GUI.HoveredFlags_AllowWhenBlockedByActiveItem + GUI.HoveredFlags_AllowWhenOverlapped) then megaminx_ppparty.pos = 0 end\nGUI:End()\nself.used = true",
						gVar = "ACR_RikuWAR2_CD",
						uuid = "e175f1cd-8ee8-b792-ad5a-edbd3066136c",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
			},
			enabled = false,
			eventType = 13,
			name = "partyGUI",
			uuid = "802792fa-b0ff-ce47-8583-497db86d27e5",
			version = 2,
		},
	},
	
	{
		data = 
		{
			displayPath = "",
			name = "Helpers",
			uuid = "c91dd0f4-f3b6-c275-8438-90103c9cf42c",
		},
		objectType = "folder",
	},
	
	{
		data = 
		{
			actions = 
			{
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "-- Reusable entity-following countdown; identical installer may exist in multiple profiles.\n-- RenderManager:WorldToScreen documented at wiki.mmominion.com/doku.php?id=gui_api.\nif not JacobWorldText or (JacobWorldText.version or 0)<1 then\n local H={version=1,entries={},serial=0}\n JacobWorldText=H\n function H.addEntityCountdown(timeoutMs,entityID,color,background,sizeMultiplier,heightAddition,key)\n  local e=TensorCore.mGetEntity(entityID)\n  local p=TensorCore.mGetPlayer()\n  if not e or not e.pos or timeoutMs<=0 then return nil end\n  if key and H.entries[key] and H.entries[key].deadline>Now() then return key end\n  H.serial=H.serial+1;key=key or ('entity-countdown-'..H.serial)\n  H.entries[key]={entityID=entityID,deadline=Now()+timeoutMs,color=color or 0xFFFFFFFF,background=background~=false,scale=sizeMultiplier or 1,height=heightAddition or 1,map=p and p.localmapid}\n  return key\n end\n function H.cancelEntityCountdown(key) H.entries[key]=nil end\nend\nlocal H=JacobWorldText\nlocal frame=GUI:GetFrameCount()\nif H.lastFrame==frame then self.used=true return end\nH.lastFrame=frame\nif not next(H.entries) then self.used=true return end\nlocal now=Now();local p=TensorCore.mGetPlayer()\nlocal active={}\nfor key,entry in pairs(H.entries) do\n local e=TensorCore.mGetEntity(entry.entityID)\n if now>=entry.deadline or not p or p.localmapid~=entry.map or not e or not e.pos or not e.alive then H.entries[key]=nil\n else active[#active+1]={entry=entry,entity=e} end\nend\nif #active==0 then self.used=true return end\nlocal width,height=GUI:GetScreenSize()\nGUI:SetNextWindowPos(0,0,GUI.SetCond_Always)\nGUI:SetNextWindowSize(width,height,GUI.SetCond_Always)\nGUI:PushStyleColor(GUI.Col_WindowBg,0,0,0,0)\nlocal flags=GUI.WindowFlags_NoTitleBar+GUI.WindowFlags_NoResize+GUI.WindowFlags_NoMove+GUI.WindowFlags_NoScrollbar+GUI.WindowFlags_NoSavedSettings+GUI.WindowFlags_NoInputs+GUI.WindowFlags_NoFocusOnAppearing\nlocal visible=GUI:Begin('##JacobEntityCountdownOverlay',true,flags)\nif visible then\n for _,item in ipairs(active) do\n  local entry,e=item.entry,item.entity\n  local x,y=RenderManager:WorldToScreen({x=e.pos.x,y=e.pos.y+entry.height,z=e.pos.z},true)\n  if x and y then\n   GUI:SetWindowFontScale(entry.scale)\n   local text=string.format('%.1f',math.max(0,(entry.deadline-now)/1000))\n   local w,h=GUI:CalcTextSize(text)\n   x,y=x-w/2,y-h/2\n   if entry.background then GUI:AddRectFilled(x-4,y-2,x+w+4,y+h+2,0xA0000000,4) end\n   GUI:AddText(x,y,entry.color,text)\n  end\n end\n GUI:SetWindowFontScale(1)\nend\nGUI:End();GUI:PopStyleColor()\nself.used=true\n",
						name = "Install and render shared entity countdowns",
						uuid = "0cfe6439-d32b-c03a-9841-88da69cebef3",
						version = 2.1,
					},
				},
			},
			conditions = 
			{
			},
			displayPath = "Helpers",
			eventType = 13,
			name = "[Helper] Entity-following world countdowns",
			uuid = "5847cc6e-8cf3-99a4-972d-81e9d54f5ca3",
			version = 2,
		},
	},
	
	{
		data = 
		{
			displayPath = "",
			name = "AutoSim Fight Editor",
			uuid = "8c40a39b-26b7-e72a-838e-2a3011296154",
		},
		objectType = "folder",
	},
	
	{
		data = 
		{
			actions = 
			{
			},
			conditions = 
			{
			},
			displayPath = "AutoSim Fight Editor",
			eventType = 9,
			execute = "local E=AutoSimFightEditor\nif E then\n E.applied=false;E.pending=false;E.progress=nil;E.compatible=nil;E.pullConfig=nil;E.pullName=nil\nend\nself.used=true",
			executeType = 2,
			name = "[AutoSim] Reset pull state",
			uuid = "bc9f9922-942c-91a7-baff-44835b9cd3d8",
			version = 2,
		},
	},
	
	{
		data = 
		{
			actions = 
			{
			},
			conditions = 
			{
			},
			displayPath = "AutoSim Fight Editor",
			execute = "local E=AutoSimFightEditor\nif not E then return end\nlocal player=TensorCore.mGetPlayer()\nif not player then return end\nlocal combat=player.incombat\nif combat and not E.wasCombat and not E.applied then E.pending=true end\nif not combat and E.wasCombat then\n    E.applied=false;E.pending=false;E.progress=nil;E.compatible=nil;E.pullConfig=nil;E.pullName=nil\nend\nE.wasCombat=combat\nif not E.pending or E.applied then return end\nif player.job~=34 or player.level~=100 then\n    E.status=\"AutoSim editor requires level-100 Samurai.\"\n    E.pending=false\n    return\nend\nif E.compatible==nil then\n    E.compatible=false\n    for _,group in ipairs(TensorCore.API.TensorACR.getMenuOptions()) do\n        for _,option in ipairs(group.toggles) do\n            if option.var==\"ACR_TensorWeeb4_AutoSimDoTTickTracking\" then E.compatible=true end\n        end\n    end\nend\nif not E.compatible then\n    E.status=\"Select TensorWeeb4 to apply these settings.\"\n    E.pending=false\n    return\nend\nlocal ok,time=pcall(TensorCore.API.TensorACR.getAutoSimTime)\nif not ok then return end\nif time>5 then\n    E.status=\"Missed the pull setup window; saved settings will apply next pull.\"\n    E.pending=false\n    return\nend\nlocal success,result=pcall(E.apply,player)\nif success then\n    E.applied=true;E.pending=false\nelse\n    -- Progress checkpoints avoid adding a phase twice while readiness is pending.\n    E.status=\"AutoSim could not accept the settings: \"..tostring(result)\nend\n",
			executeType = 2,
			name = "[AutoSim] Apply saved fight settings",
			uuid = "1c36594c-d13d-3499-b4ca-79951a0e7d7a",
			version = 2,
		},
	},
	
	{
		data = 
		{
			actions = 
			{
			},
			conditions = 
			{
			},
			displayPath = "AutoSim Fight Editor",
			eventType = 16,
			execute = "local E=AutoSimFightEditor\nif E then\n E.applied=false;E.pending=true;E.progress=nil;E.compatible=nil;E.pullConfig=nil;E.pullName=nil\nend\nself.used=true",
			executeType = 2,
			name = "[AutoSim] Prepare selected fight",
			uuid = "216cee5c-0362-5232-b85b-d1065a40ac92",
			version = 2,
		},
	},
	
	{
		data = 
		{
			actions = 
			{
			},
			conditions = 
			{
			},
			displayPath = "AutoSim Fight Editor",
			eventType = 17,
			execute = "local E=AutoSimFightEditor\nif E then\n E.applied=false;E.pending=false;E.progress=nil;E.compatible=nil;E.pullConfig=nil;E.pullName=nil\nend\nself.used=true",
			executeType = 2,
			name = "[AutoSim] Cancel pending setup",
			uuid = "4db6ad6c-b974-8c5c-9f33-7c047df40b51",
			version = 2,
		},
	},
	
	{
		data = 
		{
			actions = 
			{
			},
			conditions = 
			{
			},
			displayPath = "AutoSim Fight Editor",
			eventType = 13,
			execute = "-- Runs only in TensorReactions OnDraw. Settings are local to this installation.\nif not AutoSimFightEditor or AutoSimFightEditor.codeVersion ~= 9 then\n    local previous=AutoSimFightEditor\n    local E = {codeVersion=9, open=false, selected=0, mode=0, status=\"No overrides applied.\", dirty=false}\n    AutoSimFightEditor = E\n    E.path = GetStartupPath() .. [[\\LuaMods\\TensorReactions\\AutoSimFightEditor.settings.tsv]]\n    E.types = {\"FullDowntime\", \"MeleeDowntime\", \"CasterDowntime\"}\n    E.typeLabels = {\"Full downtime\", \"Out of melee range\", \"Cannot cast\"}\n    E.names = {\"DSR\", \"DMU\", \"FRU\", \"UWU\", \"UCOB\", \"TOP\", \"Custom 1\", \"Custom 2\", \"Custom 3\"}\n    E.config = {}\n    for i=1,#E.names do\n        E.config[i] = {enabled=false, zone=0, killEnabled=false, kill=600,\n            movementEnabled=false, movement=5, meleeEnabled=false, melee=5, phases={}}\n    end\n    function E.copy(value)\n        if type(value) ~= \"table\" then return value end\n        local result = {}\n        for k,v in pairs(value) do result[k] = E.copy(v) end\n        return result\n    end\n    local file = io.open(E.path,\"r\")\n    if file then\n        for line in file:lines() do\n            local fields = {}\n            for item in line:gmatch(\"[^\\t]+\") do fields[#fields+1]=item end\n            if fields[1]==\"selection\" then\n                E.selected=math.max(0,math.min(#E.names-1,tonumber(fields[2]) or 0))\n                E.mode=tonumber(fields[3])==1 and 1 or 0\n            elseif fields[1]==\"fight\" then\n                local cfg=E.config[tonumber(fields[2])]\n                if cfg then\n                    cfg.enabled=fields[3]==\"1\"; cfg.zone=tonumber(fields[4]) or 0\n                    cfg.killEnabled=fields[5]==\"1\"; cfg.kill=tonumber(fields[6]) or 600\n                    cfg.movementEnabled=fields[7]==\"1\"; cfg.movement=tonumber(fields[8]) or 5\n                    cfg.meleeEnabled=fields[9]==\"1\"; cfg.melee=tonumber(fields[10]) or 5\n                    cfg.level=tonumber(fields[11])\n                end\n            elseif fields[1]==\"phase\" then\n                local cfg=E.config[tonumber(fields[2])]\n                if cfg and #cfg.phases<3 then\n                    cfg.phases[#cfg.phases+1]={kind=tonumber(fields[3]) or 0,\n                        start=tonumber(fields[4]) or 0,finish=tonumber(fields[5]) or 1}\n                end\n            end\n        end\n        file:close()\n    end\n    E.saved=E.copy(E.config); E.savedSelected=E.selected; E.savedMode=E.mode\n    if previous then\n        for _,key in ipairs({\"config\",\"saved\",\"selected\",\"mode\",\"savedSelected\",\"savedMode\",\"dirty\",\n            \"pending\",\"applied\",\"wasCombat\",\"progress\",\"compatible\",\"pullConfig\",\"pullName\",\"ff\"}) do\n            E[key]=previous[key]\n        end\n        E.status=\"Editor updated. Existing fight settings and unsaved edits were retained.\"\n    end\n    E.levels={90,100,100,70,70,90,100,100,100}\n    for i,cfg in ipairs(E.config) do cfg.level=cfg.level or E.levels[i] end\n    for i,cfg in ipairs(E.saved) do cfg.level=cfg.level or E.levels[i] end\n    function E.combo(label,current,items)\n        GUI:Text(label)\n        GUI:PushItemWidth(280)\n        -- This installed Minion widget uses one-based selections.\n        local selected=GUI:Combo(\"##autosim\"..label,current+1,items)\n        GUI:PopItemWidth()\n        local value=math.max(0,math.min(#items-1,selected-1))\n        return value,value~=current\n    end\n    function E.parseTime(text)\n        local minutes,seconds=text:match(\"^%s*(%d+):(%d+%.?%d*)%s*$\")\n        if minutes then\n            local secs=tonumber(seconds)\n            if secs and secs<60 then return tonumber(minutes)*60+secs end\n            return nil\n        end\n        return tonumber(text)\n    end\n    function E.formatTime(seconds)\n        return string.format(\"%d:%04.1f\",math.floor(seconds/60),seconds%60)\n    end\n    function E.timeEditor(label,object,key,id)\n        GUI:Text(label)\n        local draftKey=key..\"Text\"\n        if object[draftKey]==nil then object[draftKey]=E.formatTime(object[key]) end\n        GUI:PushItemWidth(180)\n        local text,changed=GUI:InputText(\"##\"..id,object[draftKey])\n        GUI:PopItemWidth()\n        if changed or text~=object[draftKey] then\n            object[draftKey]=text\n            local number=E.parseTime(text)\n            if number then object[key]=number end\n            E.dirty=true\n        end\n        if not E.parseTime(object[draftKey]) then GUI:Text(\"Enter seconds or m:ss, e.g. 70 or 1:10.\") end\n    end\n    function E.percentEditor(label,object,key)\n        GUI:Text(label)\n        local draftKey=key..\"Text\"\n        if object[draftKey]==nil then object[draftKey]=tostring(object[key]) end\n        GUI:PushItemWidth(180)\n        local text,changed=GUI:InputText(\"##percent\"..key,object[draftKey])\n        GUI:PopItemWidth()\n        if changed or text~=object[draftKey] then\n            object[draftKey]=text\n            local number=tonumber(text)\n            if number then object[key]=number end\n            E.dirty=true\n        end\n    end\n    function E.validate(cfg)\n        local function finite(n) return type(n)==\"number\" and n==n and n>-math.huge and n<math.huge end\n        if not finite(cfg.level) or cfg.level<1 or cfg.level>100 or cfg.level%1~=0 then return \"Duty level must be an integer from 1 to 100.\" end\n        if not finite(cfg.zone) or cfg.zone<0 or cfg.zone%1~=0 then return \"Zone ID must be a nonnegative integer.\" end\n        if cfg.killEnabled and cfg.killText and not E.parseTime(cfg.killText) then return \"Enter a valid expected kill time.\" end\n        if cfg.killEnabled and (not finite(cfg.kill) or cfg.kill<=0 or cfg.kill>1200) then return \"Kill time must be between 0 and 1200 seconds.\" end\n        for _,key in ipairs({\"movement\",\"melee\"}) do\n            if cfg[key..\"Enabled\"] and cfg[key..\"Text\"] and not tonumber(cfg[key..\"Text\"]) then return \"Enter a numeric percentage.\" end\n            if not finite(cfg[key]) or cfg[key]<0 or cfg[key]>5 then return \"Unexpected percentages must be between 0 and 5.\" end\n        end\n        for i,p in ipairs(cfg.phases) do\n            if (p.startText and not E.parseTime(p.startText)) or (p.finishText and not E.parseTime(p.finishText)) then\n                return \"Phase \"..i..\": enter valid start and end times.\"\n            end\n            if not E.types[p.kind+1] then return \"Choose a valid phase type.\" end\n            if not finite(p.start) or not finite(p.finish) or p.start<0 or p.finish<=p.start or p.finish>1200 then\n                return \"Each phase needs 0 <= start < end <= 1200 seconds.\"\n            end\n            if cfg.killEnabled and p.finish>cfg.kill then return \"A phase ends after the expected kill time.\" end\n            for j=1,i-1 do\n                local q=cfg.phases[j]\n                if p.kind==q.kind and p.start<q.finish and q.start<p.finish then return \"Phases of the same type cannot overlap.\" end\n            end\n        end\n    end\n    function E.save()\n        for _,cfg in ipairs(E.config) do\n            local errorText=E.validate(cfg)\n            if errorText then E.status=errorText;return end\n        end\n        if E.mode==1 then\n            local zones={}\n            for i,cfg in ipairs(E.config) do\n                if cfg.enabled and cfg.zone>0 then\n                    if zones[cfg.zone] then E.status=\"Two enabled fights share a zone ID. Use manual selection or distinct zones.\";return end\n                    zones[cfg.zone]=i\n                end\n            end\n        end\n        local f,err=io.open(E.path,\"w\")\n        if not f then E.status=\"Could not save: \"..tostring(err);return end\n        local function flag(v) return v and 1 or 0 end\n        f:write(\"version\\t1\\nselection\\t\",E.selected,\"\\t\",E.mode,\"\\n\")\n        for i,cfg in ipairs(E.config) do\n            f:write(table.concat({\"fight\",i,flag(cfg.enabled),cfg.zone,flag(cfg.killEnabled),cfg.kill,\n                flag(cfg.movementEnabled),cfg.movement,flag(cfg.meleeEnabled),cfg.melee,cfg.level},\"\\t\"),\"\\n\")\n            for _,p in ipairs(cfg.phases) do\n                f:write(table.concat({\"phase\",i,p.kind,p.start,p.finish},\"\\t\"),\"\\n\")\n            end\n        end\n        f:close()\n        E.saved=E.copy(E.config); E.savedSelected=E.selected; E.savedMode=E.mode\n        E.dirty=false; E.status=\"Saved. Changes apply on the next pull.\"\n    end\n    function E.choose(player)\n        if E.savedMode==0 then return E.saved[E.savedSelected+1],E.names[E.savedSelected+1] end\n        for i,cfg in ipairs(E.saved) do\n            if cfg.enabled and cfg.zone>0 and cfg.zone==player.localmapid then return cfg,E.names[i] end\n        end\n    end\n    function E.apply(player)\n        if not E.pullConfig then\n            local selected,name=E.choose(player)\n            if selected then E.pullConfig=E.copy(selected);E.pullName=name end\n        end\n        local cfg,name=E.pullConfig,E.pullName\n        if not cfg or not cfg.enabled then E.status=\"No enabled fight settings for this pull.\";return true end\n        local errorText=E.validate(cfg)\n        if errorText then E.status=errorText;return true end\n        if cfg.level~=100 then E.status=\"This duty syncs to level \"..cfg.level..\". Samurai v1 AutoSim only supports level 100; overrides were skipped.\";return true end\n        local A=TensorCore.API.TensorACR\n        E.progress=E.progress or {phases=0}\n        local progress=E.progress\n        -- No clears here: preserve automatic inputs for types without custom phases.\n        if cfg.killEnabled and not progress.kill then A.setAutoSimKillTime(cfg.kill);progress.kill=true end\n        if cfg.movementEnabled and not progress.movement then A.setAutoSimUnexpectedMovementPct(cfg.movement/100);progress.movement=true end\n        if cfg.meleeEnabled and not progress.melee then A.setAutoSimUnexpectedMeleeDowntimePct(cfg.melee/100);progress.melee=true end\n        for i=progress.phases+1,#cfg.phases do\n            local p=cfg.phases[i]\n            A.addAutoSimPhase(E.types[p.kind+1],p.start,p.finish)\n            progress.phases=i\n        end\n        E.status=\"Applied \"..name..\" settings for this pull.\"\n        return true\n    end\nend\nlocal E=AutoSimFightEditor\n-- Embedded in the OnDraw editor. Background PowerShell owns network calls.\nif not E.ff or E.ff.codeVersion~=4 then\n    local F={source=0,count=\"5\",days=\"90\",scan=\"30\",region=\"\",links=\"\",samurai=false,estimate=0,status=\"Not checked.\",encounters={}}\n    F.root=GetStartupPath()..[[\\LuaMods\\TensorReactions\\]]\n    F.helper=GetStartupPath()..[[\\LuaMods\\TensorReactions\\Agent\\tools\\AutoSimFightEditor\\FFLogs.ps1]]\n    function F.hex(s) return tostring(s):gsub(\".\",function(c)return string.format(\"%02x\",c:byte())end) end\n    function F.unhex(s) return (s:gsub(\"%x%x\",function(c)return string.char(tonumber(c,16))end)) end\n    F.keys={\"source\",\"count\",\"days\",\"scan\",\"region\",\"links\",\"samurai\",\"estimate\"}\n    -- Nonsecret preferences only. Credentials never enter Lua or reaction exports.\n    F.preferences=GetStartupPath()..[[\\LuaMods\\TensorReactions\\AutoSimFightEditor.fflogs.tsv]]\n    local f=io.open(F.preferences,\"r\")\n    if f then\n        for line in f:lines() do\n            local k,v=line:match(\"^([^\\t]+)\\t(.*)$\")\n            if k and v then\n                v=F.unhex(v)\n                if k==\"source\" then F.source=tonumber(v)==2 and 2 or 0\n                elseif k==\"estimate\" then F.estimate=tonumber(v)==1 and 1 or 0\n                elseif k==\"samurai\" then F.samurai=v==\"true\"\n                elseif k:match(\"^encounter%d+$\") or k:match(\"^encounterID%d+$\") or k:match(\"^level%d+$\") then F.encounters[k]=v\n                else for _,key in ipairs(F.keys) do if key==k then F[k]=v end end end\n            end\n        end\n        f:close()\n    end\n    if E.ff then\n        for _,key in ipairs(F.keys) do if E.ff[key]~=nil then F[key]=E.ff[key] end end\n        F.source=F.source==2 and 2 or 0\n        F.encounters=E.ff.encounters or F.encounters\n        F.region=\"\"\n        F.status=\"Choose a fight and sample public clears. Region is optional.\"\n    end\n    function F.save()\n        local f=io.open(F.preferences,\"w\")\n        if not f then F.status=\"Could not save FFLogs preferences.\";return false end\n        for _,k in ipairs(F.keys) do f:write(k,\"\\t\",F.hex(F[k]),\"\\n\") end\n        for k,v in pairs(F.encounters) do f:write(k,\"\\t\",F.hex(v),\"\\n\") end\n        f:close();return true\n    end\n    function F.start(mode)\n        if F.busy then return end\n        if not F.save() then return end\n        local helper=io.open(F.helper,\"r\")\n        if not helper then F.status=\"FFLogs helper missing: \"..F.helper;return end\n        helper:close()\n        -- The helper creates its directory; use an existing local parent for the request.\n        local request=GetStartupPath()..[[\\LuaMods\\TensorReactions\\AutoSimFightEditor.fflogs-request.tsv]]\n        local f=io.open(request,\"w\")\n        if not f then F.status=\"Could not write the local FFLogs request.\";return end\n        F.job=tostring(os.time())..\"-\"..tostring(math.random(100000,999999))\n        local values={job=F.job,fightIndex=E.selected,source=F.source,count=F.count,days=F.days,scan=F.scan,\n            region=F.region,links=F.links,\n            samurai=F.samurai and \"1\" or \"0\",encounter=F.encounters[\"encounter\"..E.selected] or \"\",\n            encounterID=F.encounters[\"encounterID\"..E.selected] or \"0\"}\n        for k,v in pairs(values) do f:write(k,\"\\t\",F.hex(v),\"\\n\") end\n        f:close()\n        -- Static command; user inputs travel only in the encoded request file.\n        local command='powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File \"'..F.helper..'\" -Mode '..mode..' -RequestPath \"'..request..'\"'\n        local pipe=io.popen(command)\n        if not pipe then F.status=\"Could not launch FFLogs helper.\";return end\n        pipe:close()\n        F.busy=true;F.started=os.time();F.polled=0;F.result=nil;F.status=mode==\"Credentials\" and \"Enter credentials in the FFLogs connection window.\" or \"Checking FFLogs in the background...\"\n    end\n    function F.poll()\n        if not F.busy or os.time()==F.polled then return end\n        F.polled=os.time()\n        local f=io.open(F.root..\"AutoSimFightEditor.fflogs-result.tsv\",\"r\")\n        if f then\n            local result={rows={},warnings={}}\n            for line in f:lines() do\n                local fields={};for field in (line..\"\\t\"):gmatch(\"(.-)\\t\") do fields[#fields+1]=field end\n                local kind=table.remove(fields,1)\n                for i,v in ipairs(fields) do fields[i]=F.unhex(v) end\n                if kind==\"job\" then result.job=fields[1]\n                elseif kind==\"summary\" then result.summary=fields\n                elseif kind==\"clear\" then result.rows[#result.rows+1]=fields\n                elseif kind==\"warning\" then result.warnings[#result.warnings+1]=fields[1]\n                elseif kind==\"status\" or kind==\"error\" then result.status=fields[1];result.error=kind==\"error\" end\n            end\n            f:close()\n            if result.job==F.job then F.result=result;F.busy=false;F.status=result.status or \"Check finished.\" end\n        end\n        if F.busy and os.time()-F.started>900 then F.busy=false;F.status=\"Check timed out. Wait for the background helper to finish before retrying.\" end\n    end\n    function F.draw(cfg)\n        if not GUI:CollapsingHeader(\"FFLogs check\") then return end\n        GUI:TextWrapped(\"Sample public clears and review kill times.\\nMovement phases are edited separately.\")\n        if GUI:CollapsingHeader(\"FFLogs connection\") then\n            GUI:TextWrapped(\"Create a v2 API client at www.fflogs.com/api/clients. Enter Client ID and Client Secret in the separate connection window. The secret is encrypted for this Windows user and excluded from reaction exports. Public reports only.\")\n            if not F.busy then\n                if GUI:Button(\"Set FFLogs credentials\") then F.start(\"Credentials\") end\n                if GUI:Button(\"Check connection\") then F.start(\"Connection\") end\n            end\n        end\n        local source=E.combo(\"Clear source\",F.source==2 and 1 or 0,{\"Random public clears\",\"Paste report links or codes\"})\n        F.source=source==1 and 2 or 0\n        local function input(label,obj,key)\n            GUI:Text(label)\n            GUI:PushItemWidth(-1)\n            obj[key]=GUI:InputText(\"##fflogs\"..key,tostring(obj[key] or \"\"))\n            GUI:PopItemWidth()\n        end\n        if F.source==0 then\n            local regions={\"\",\"EU\",\"NA\",\"JP\",\"OC\"}\n            local selectedRegion=0\n            for i,r in ipairs(regions) do if r==F.region then selectedRegion=i-1 end end\n            selectedRegion=E.combo(\"Region (optional)\",selectedRegion,{\"Any region\",\"Europe\",\"North America\",\"Japan\",\"Oceania\"})\n            F.region=regions[selectedRegion+1]\n            GUI:TextWrapped(\"Samples public ranked clears for the selected fight. No character or server needed.\")\n        else\n            GUI:Text(\"Report links / codes\")\n            F.links=GUI:InputTextMultiline(\"##fflogsLinks\",F.links,0,90,0)\n        end\n        local k=tostring(E.selected)\n        local defaults={\"Dragonsong\",\"Dancing Mad\",\"Futures Rewritten\",\"Weapon's Refrain\",\"Unending Coil\",\"Omega Protocol\",\"\",\"\",\"\"}\n        F.encounters[\"encounter\"..k]=F.encounters[\"encounter\"..k] or defaults[E.selected+1]\n        input(\"Clears in sample (1-20)\",F,\"count\")\n        if GUI:CollapsingHeader(\"Advanced FFLogs search\") then\n            input(\"Encounter name contains\",F.encounters,\"encounter\"..k)\n            input(\"Exact encounter ID (optional)\",F.encounters,\"encounterID\"..k)\n            input(\"Look back days (1-365)\",F,\"days\")\n            input(\"Maximum reports to inspect (1-100)\",F,\"scan\")\n            F.samurai=GUI:Checkbox(\"Require a Samurai in the clear\",F.samurai)\n            GUI:TextWrapped(\"Public samples use the latest encounter partition and up to five execution-ranking pages, mixed within pages 1-20. Ranked clears may differ from ordinary groups; this is not a census of all uploads.\")\n        end\n        F.estimate=E.combo(\"Kill-time estimate\",F.estimate,{\"Mean (average)\",\"Median (less affected by outliers)\"})\n        if not F.busy then\n            if GUI:Button(F.source==0 and \"Sample public clears\" or \"Check pasted reports\") then F.start(\"Check\") end\n            if GUI:Button(\"Save FFLogs preferences\") then if F.save() then F.status=\"FFLogs preferences saved.\" end end\n        end\n        GUI:TextWrapped(F.status)\n        local result=F.result\n        if result and result.summary then\n            local s=result.summary\n            GUI:Text(string.format(\"Found %s / %s clears; mean %.1fs; median %.1fs\",s[3],s[4],tonumber(s[1]) or 0,tonumber(s[2]) or 0))\n            GUI:Text(\"Range: \"..s[5]..\" - \"..s[6]..\" seconds\")\n            for _,w in ipairs(result.warnings) do GUI:TextWrapped(w) end\n            if GUI:CollapsingHeader(\"Clears used\") then\n                for _,row in ipairs(result.rows) do\n                    GUI:TextWrapped(row[4]..\" | \"..row[3]..\" | \"..row[5]..\"s\")\n                    GUI:TextWrapped(\"https://www.fflogs.com/reports/\"..row[1]..\"?fight=\"..row[2])\n                end\n            end\n            if tonumber(s[7])~=E.selected then GUI:TextWrapped(\"Select the fight this check was run for to use its result.\")\n            else\n                local estimate=tonumber(s[F.estimate+1])\n                if estimate and estimate>0 and estimate<=1200 then\n                    if GUI:Button(\"Use estimate as expected kill time\") then\n                        cfg.kill=math.floor(estimate*10+0.5)/10;cfg.killText=nil;cfg.killEnabled=true;E.dirty=true\n                        F.status=\"Copied to this fight's draft. Enable overrides and Save all fight settings to use it next pull.\"\n                    end\n                else GUI:TextWrapped(\"Estimate is outside the editor's supported 0-1200 second range.\") end\n            end\n        end\n    end\n    F.codeVersion=4\n    E.ff=F\nend\nE.ff.poll()\n\nif jacobAutoSimEditorOpen ~= true then return end\nlocal visible,open=GUI:Begin(\"AutoSim Fight Editor\",jacobAutoSimEditorOpen)\njacobAutoSimEditorOpen=open\nif visible then\n    do\n        local function tooltip(text) if GUI:IsItemHovered() then GUI:SetTooltip(text) end end\n        local function field(object,key,value,changed)\n            if changed or object[key]~=value then E.dirty=true end\n            object[key]=value\n        end\n        local idx,changed=E.combo(\"Fight to edit\",E.selected,E.names)\n        field(E,\"selected\",idx,changed)\n        idx,changed=E.combo(\"Apply mode\",E.mode,{\"Selected fight (manual)\",\"Match current zone\"})\n        field(E,\"mode\",idx,changed)\n        tooltip(\"Manual: the saved selected fight is used on every pull. Zone mode: only an enabled fight bound to your current zone is used.\")\n        local cfg=E.config[E.selected+1]\n        local value,change=GUI:Checkbox(\"Enable this fight's overrides\",cfg.enabled)\n        field(cfg,\"enabled\",value,change)\n        GUI:Text(\"Duty synced level: \"..tostring(cfg.level))\n        if E.selected>=6 then\n            local levelText=GUI:InputText(\"Custom duty level\",cfg.levelText or tostring(cfg.level))\n            if levelText~=(cfg.levelText or tostring(cfg.level)) then cfg.levelText=levelText;cfg.level=tonumber(levelText) or 0;E.dirty=true end\n        end\n        if cfg.level~=100 then GUI:TextWrapped(\"Samurai v1 AutoSim supports level 100 only. You can review logs and save drafts here, but this duty's overrides will not apply.\") end\n        local player=TensorCore.mGetPlayer()\n        GUI:Text(\"Current zone: \"..tostring(player and player.localmapid or \"unknown\"))\n        value,change=GUI:InputInt(\"Fight zone ID\",cfg.zone,1,10);field(cfg,\"zone\",value,change)\n        if GUI:Button(\"Bind this fight to current zone\") and player then cfg.zone=player.localmapid;E.dirty=true end\n        tooltip(\"Bind inside the actual duty, not in a city or housing area. Used only in Match current zone mode.\")\n        GUI:Separator()\n        GUI:TextWrapped(\"Times start at the pull. Type seconds (70) or minutes:seconds (1:10). Save before the next countdown. Samurai v1: keep at most 3 planned windows total.\")\n        value,change=GUI:Checkbox(\"Set expected kill time\",cfg.killEnabled);field(cfg,\"killEnabled\",value,change)\n        if cfg.killEnabled then E.timeEditor(\"Expected kill time\",cfg,\"kill\",\"killTime\") end\n        local remove\n        for section=1,2 do\n            local movementSection=section==2\n            if GUI:CollapsingHeader(movementSection and \"Movement phases\" or \"Boss downtime phases\") then\n                GUI:TextWrapped(movementSection\n                    and \"Plan movement that prevents casting or takes you out of melee. This predicts your movement; it does not move your character.\"\n                    or \"Use this when no enemy can be attacked, such as a boss disappearance or transition.\")\n                local count=0\n                for i,phase in ipairs(cfg.phases) do\n                    if (phase.kind~=0)==movementSection then\n                        count=count+1\n                        GUI:Separator()\n                        GUI:Text((movementSection and \"Movement \" or \"Downtime \")..count)\n                        if movementSection then\n                            GUI:Text(\"What happens?\")\n                            local currentKind=phase.kind==2 and 0 or 1\n                            value,change=E.combo(\"Movement type##\"..i,currentKind,\n                                {\"Moving: cannot cast\", \"Out of melee range\"})\n                            if value~=currentKind then\n                                phase.kind=value==0 and 2 or 1\n                                E.dirty=true\n                            end\n                            GUI:TextWrapped(phase.kind==2\n                                and \"Melee attacks remain available; casts such as Iaijutsu are unavailable to the model.\"\n                                or \"Melee attacks are unavailable to the model. Samurai v1 does not expect 8-yalm Iaijutsu here.\")\n                        end\n                        E.timeEditor(\"Starts at\",phase,\"start\",\"phaseStart\"..i)\n                        E.timeEditor(\"Ends at\",phase,\"finish\",\"phaseEnd\"..i)\n                        GUI:Text(string.format(\"Duration: %.1f seconds\",phase.finish-phase.start))\n                        if GUI:Button(\"Remove this phase##\"..i) then remove=i end\n                    end\n                end\n                if count==0 then GUI:Text(movementSection and \"No movement windows added.\" or \"No boss downtime added.\") end\n                if #cfg.phases<3 then\n                    if GUI:Button(movementSection and \"Add movement phase\" or \"Add boss downtime phase\") then\n                        cfg.phases[#cfg.phases+1]={kind=movementSection and 2 or 0,start=70,finish=90}\n                        E.dirty=true\n                    end\n                else GUI:TextWrapped(\"3 planned windows added. Remove one to add another; keep minor movement in the default uncertainty.\") end\n            end\n        end\n        if remove then table.remove(cfg.phases,remove);E.dirty=true end\n        if GUI:CollapsingHeader(\"Optional uncertainty overrides\") then\n            GUI:TextWrapped(\"Leave these disabled to use the ACR defaults. These are percentages, not scheduled downtime.\")\n            value,change=GUI:Checkbox(\"Override unexpected movement\",cfg.movementEnabled);field(cfg,\"movementEnabled\",value,change)\n            if cfg.movementEnabled then E.percentEditor(\"Unexpected movement (%)\",cfg,\"movement\") end\n            value,change=GUI:Checkbox(\"Override unexpected melee downtime\",cfg.meleeEnabled);field(cfg,\"meleeEnabled\",value,change)\n            if cfg.meleeEnabled then E.percentEditor(\"Unexpected melee downtime (%)\",cfg,\"melee\") end\n        end\n        local errorText=E.validate(cfg)\n        if errorText then GUI:TextWrapped(errorText) end\n        E.ff.draw(cfg)\n        GUI:Separator()\n        if GUI:Button(\"Save all fight settings\") then E.save() end\n        GUI:SameLine()\n        if GUI:Button(\"Close editor\") then jacobAutoSimEditorOpen=false end\n        if E.dirty then GUI:Text(\"Unsaved edits - the previous saved settings will be used.\") end\n        GUI:TextWrapped(E.status)\n        GUI:TextWrapped(\"Runs with level-100 Samurai / TensorWeeb4. Existing encounter scripts can also supply AutoSim phases; avoid configuring the same schedule in both places.\")\n    end\nend\nGUI:End()\n",
			executeType = 2,
			name = "[AutoSim] Fight settings editor",
			uuid = "55b371f9-caba-6378-876c-b471ff13ef48",
			version = 2,
		},
	}, 
	inheritedProfiles = 
	{
	},
}



return tbl