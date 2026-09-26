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
						actionLua = "if not gLj_Toolbox then\n    gLj_Toolbox = {}\nend\nif not gLj_Toolbox.Settings then\n    gLj_Toolbox.Settings = {\n        roleOptions = {\n            tank = { \"MT\", \"OT\" },\n            healer = { \"H1\", \"H2\" },\n            dps = { \"M1\", \"M2\", \"R1\", \"R2\" }\n        },\n        selectedRole = 1,\n        partyRoles = {},\n        savedProfiles = {},\n        showPartyAssigner = false\n    }\nelse\n    gLj_Toolbox.Settings.roleOptions = gLj_Toolbox.Settings.roleOptions or {\n        tank = { \"MT\", \"OT\" },\n        healer = { \"H1\", \"H2\" },\n        dps = { \"M1\", \"M2\", \"R1\", \"R2\" }\n    }\n    gLj_Toolbox.Settings.partyRoles = gLj_Toolbox.Settings.partyRoles or {}\n    gLj_Toolbox.Settings.savedProfiles = gLj_Toolbox.Settings.savedProfiles or {}\nend\nif not gLj_Toolbox.Constants then\n    gLj_Toolbox.Constants = {\n        ROLE_COLORS = {\n            tank = { 0.2, 0.4, 0.8, 1.0 },\n            healer = { 0.2, 0.5, 0.2, 1.0 },\n            dps = { 0.7, 0.2, 0.2, 1.0 }\n        },\n        ROLE_BTN_WIDTH = 155,\n        ROLE_BTN_HEIGHT = 18,\n        ROLE_BUTTON_ID = \"##JacobRoleButton\",\n        allRoles = { \"MT\", \"OT\", \"H1\", \"H2\", \"M1\", \"M2\", \"R1\", \"R2\" }\n    }\nend\ngLj_Toolbox.GetRoleOptionsForJob = gLj_Toolbox.GetRoleOptionsForJob or function(job)\n    if job == 19 or job == 21 or job == 32 or job == 37 then\n        return gLj_Toolbox.Settings.roleOptions.tank, \"tank\"\n    elseif job == 24 or job == 28 or job == 33 or job == 40 then\n        return gLj_Toolbox.Settings.roleOptions.healer, \"healer\"\n    end\n    return gLj_Toolbox.Settings.roleOptions.dps, \"dps\"\nend\ngLj_Toolbox.GetRoleOptions = gLj_Toolbox.GetRoleOptions or function()\n    local player = TensorCore.mGetPlayer()\n    return gLj_Toolbox.GetRoleOptionsForJob(player and player.job or 0)\nend\ngLj_Toolbox.UpdateRoleOptions = gLj_Toolbox.UpdateRoleOptions or function()\n    local player = TensorCore.mGetPlayer()\n    local options, roleType = gLj_Toolbox.GetRoleOptionsForJob(player and player.job or 0)\n    local selected = tonumber(gLj_Toolbox.Settings.selectedRole) or 1\n    local saved = player and player.name and gLj_Toolbox.Settings.savedProfiles[player.name]\n    if saved and saved.job == player.job then\n        for index, role in ipairs(options) do\n            if role == saved.role then\n                selected = index\n                break\n            end\n        end\n    end\n    if player and (player.job == 23 or player.job == 31 or player.job == 38) and not saved then\n        selected = math.max(selected, 3)\n    elseif player and (player.job == 25 or player.job == 27 or player.job == 35 or player.job == 42) and not saved then\n        selected = math.max(selected, 4)\n    end\n    if selected < 1 or selected > #options then selected = 1 end\n    gLj_Toolbox.Settings.selectedRole = selected\n    if player and player.name then\n        local role = options[selected]\n        gLj_Toolbox.Settings.partyRoles[player.name] = role\n        if player.id then\n            if not gLj_PartyRoles then gLj_PartyRoles = {} end\n            for candidate, entityID in pairs(gLj_PartyRoles) do\n                if entityID == player.id then gLj_PartyRoles[candidate] = 0 end\n            end\n            gLj_PartyRoles[role] = player.id\n        end\n    end\n    return options, roleType\nend\ngLj_Toolbox.SaveProfile = gLj_Toolbox.SaveProfile or function(name, job, role)\n    if name and job and role then\n        gLj_Toolbox.Settings.savedProfiles[name] = { job = job, role = role }\n    end\nend\nif not gLj_PartyRoles then gLj_PartyRoles = {} end\nif not GetCurrentRole then\n    function GetCurrentRole()\n        local options = gLj_Toolbox.GetRoleOptions()\n        return options[gLj_Toolbox.Settings.selectedRole]\n    end\nend\nif not GetRole then\n    function GetRole(roleStr)\n        local entityID = gLj_PartyRoles[roleStr]\n        if entityID and entityID > 0 then\n            return TensorCore.mGetEntity(entityID)\n        end\n        return nil\n    end\nend\nif not GetLightParty then\n    function GetLightParty(roleStr)\n        local targetRole = roleStr or GetCurrentRole()\n        if targetRole == \"MT\" or targetRole == \"H1\" or targetRole == \"M1\" or targetRole == \"R1\" then return 1 end\n        if targetRole == \"OT\" or targetRole == \"H2\" or targetRole == \"M2\" or targetRole == \"R2\" then return 2 end\n        return 0\n    end\nend\n\nGUI:SetNextWindowSize(320, 240, GUI.SetCond_Always)\n\nGUI:PushStyleColor(GUI.Col_WindowBg, 0.07, 0.20, 0.30, 1.0)\nGUI:PushStyleColor(GUI.Col_ChildWindowBg, 0.07, 0.20, 0.30, 1.0)\nGUI:Begin(\"###StandaloneStrats\", true, GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoScrollWithMouse + GUI.WindowFlags_AlwaysAutoResize)\nGUI:BeginChild(\"##JacobToolboxHeader\", 0, 28, false)\nGUI:Text(\"Jacob's Toolbox\")\nGUI:SameLine()\n\nlocal function drawHeaderPageButton(label, selected)\n    if selected then\n        GUI:PushStyleColor(GUI.Col_Button, 0.16, 0.38, 0.56, 1.0)\n        GUI:PushStyleColor(GUI.Col_ButtonHovered, 0.22, 0.48, 0.68, 1.0)\n        GUI:PushStyleColor(GUI.Col_ButtonActive, 0.11, 0.28, 0.42, 1.0)\n    else\n        GUI:PushStyleColor(GUI.Col_Button, 0.08, 0.22, 0.32, 1.0)\n        GUI:PushStyleColor(GUI.Col_ButtonHovered, 0.14, 0.32, 0.44, 1.0)\n        GUI:PushStyleColor(GUI.Col_ButtonActive, 0.06, 0.16, 0.24, 1.0)\n    end\n    local pressed = GUI:Button(label, 24, 20)\n    GUI:PopStyleColor(3)\n    return pressed\nend\n\nlocal pageOneClicked = drawHeaderPageButton(\"1\", jacobUtilitiesOpen ~= true)\nGUI:SameLine()\nlocal pageTwoClicked = drawHeaderPageButton(\"2\", jacobUtilitiesOpen == true)\nif pageOneClicked then\n    jacobUtilitiesOpen = false\nend\nif pageTwoClicked then\n    jacobUtilitiesOpen = true\nend\nGUI:EndChild()\nGUI:Spacing()\nlocal jacobNow = Now()\ndata.jacob_job_swap = data.jacob_job_swap or {}\nlocal jobSwap = data.jacob_job_swap\nif jobSwap.loadGearSets ~= \"v10\" then\n    jobSwap.list = {}\n    jobSwap.roleByJob = {\n        [8] = \"Crafters\", [9] = \"Crafters\", [10] = \"Crafters\", [11] = \"Crafters\",\n        [12] = \"Crafters\", [13] = \"Crafters\", [14] = \"Crafters\", [15] = \"Crafters\",\n        [16] = \"Gatherers\", [17] = \"Gatherers\", [18] = \"Gatherers\",\n        [19] = \"Tank\", [21] = \"Tank\", [32] = \"Tank\", [37] = \"Tank\",\n        [24] = \"Healer\", [28] = \"Healer\", [33] = \"Healer\", [40] = \"Healer\",\n        [20] = \"DPS\", [22] = \"DPS\", [23] = \"DPS\", [25] = \"DPS\",\n        [26] = \"DPS\", [27] = \"DPS\", [30] = \"DPS\", [31] = \"DPS\", [34] = \"DPS\",\n        [35] = \"DPS\", [38] = \"DPS\", [39] = \"DPS\",\n        [41] = \"DPS\", [42] = \"DPS\",\n        [36] = \"Limited jobs\", [43] = \"Limited jobs\"\n    }\n    jobSwap.jobNameById = {\n        [8] = \"Carpenter\", [9] = \"Blacksmith\", [10] = \"Armorer\", [11] = \"Goldsmith\",\n        [12] = \"Leatherworker\", [13] = \"Weaver\", [14] = \"Alchemist\", [15] = \"Culinarian\",\n        [16] = \"Miner\", [17] = \"Botanist\", [18] = \"Fisher\",\n        [19] = \"Paladin\", [20] = \"Monk\", [21] = \"Warrior\", [22] = \"Dragoon\",\n        [23] = \"Bard\", [24] = \"White Mage\", [25] = \"Black Mage\", [26] = \"Arcanist\",\n        [27] = \"Summoner\", [28] = \"Scholar\", [30] = \"Ninja\", [31] = \"Machinist\",\n        [32] = \"Dark Knight\", [33] = \"Astrologian\", [34] = \"Samurai\", [35] = \"Red Mage\",\n        [36] = \"Blue Mage\", [37] = \"Gunbreaker\", [38] = \"Dancer\", [39] = \"Reaper\",\n        [40] = \"Sage\", [41] = \"Viper\", [42] = \"Pictomancer\", [43] = \"Beastmaster\"\n    }\n    jobSwap.jobIconPathById = {}\n    jobSwap.roleIconPathByCategory = {}\n    local function addIconIfPresent(path)\n        if path and FileExists and FileExists(path) then\n            return path\n        end\n        return nil\n    end\n    local function joinLuaModsPath(relativePath)\n        local root = GetLuaModsPath and GetLuaModsPath() or nil\n        if not root then\n            return nil\n        end\n        local last = string.sub(root, -1)\n        if last ~= \"\\\\\" and last ~= \"/\" then\n            root = root .. \"\\\\\"\n        end\n        return root .. relativePath\n    end\n    local jobIconBasePath = joinLuaModsPath(\"JacobAddon\\\\Images\\\\Jobs\\\\\")\n    if jobIconBasePath then\n        for _, supportedJobID in ipairs({ 19, 20, 21, 22, 23, 24, 25, 27, 28, 30, 31, 32, 33, 34, 35, 37, 38, 39, 40, 41, 42 }) do\n            local iconPath = addIconIfPresent(jobIconBasePath .. tostring(supportedJobID) .. \".png\")\n            if iconPath then\n                jobSwap.jobIconPathById[supportedJobID] = iconPath\n            end\n        end\n        local roleIconByCategory = {\n            DPS = jobIconBasePath .. \"DPSRole.png\",\n            Healer = jobIconBasePath .. \"HealerRole.png\",\n            Tank = jobIconBasePath .. \"TankRole.png\"\n        }\n        for category, iconPath in pairs(roleIconByCategory) do\n            local availablePath = addIconIfPresent(iconPath)\n            if availablePath then\n                jobSwap.roleIconPathByCategory[category] = availablePath\n            end\n        end\n    end\n    local blueMageIcon = joinLuaModsPath(\"JacobAddon\\\\Images\\\\Jobs\\\\36.png\")\n    blueMageIcon = addIconIfPresent(blueMageIcon)\n    if blueMageIcon then\n        jobSwap.jobIconPathById[36] = blueMageIcon\n    end\n    local namedJobIconFiles = {\n        [8] = \"Carpenter.png\",\n        [9] = \"Blacksmith.png\",\n        [10] = \"Armorer.png\",\n        [11] = \"Goldsmith.png\",\n        [12] = \"Leatherworker.png\",\n        [14] = \"Alchemist.png\",\n        [15] = \"Culinarian.png\",\n        [16] = \"Mining.png\",\n        [17] = \"Botanist.png\",\n        [18] = \"Fisher.png\",\n        [43] = \"BST.png\"\n    }\n    for jobID, iconFileName in pairs(namedJobIconFiles) do\n        local iconPath = addIconIfPresent(jobIconBasePath and (jobIconBasePath .. iconFileName) or nil)\n        if iconPath then\n            jobSwap.jobIconPathById[jobID] = iconPath\n        end\n    end\n    local gearSets = Player and Player.GetGearSetList and Player:GetGearSetList() or {}\n    for index, gearSet in pairs(gearSets) do\n        if gearSet then\n            local jobID = tonumber(gearSet.job) or 0\n            local category = jobSwap.roleByJob[jobID]\n            if category then\n                jobSwap.list[#jobSwap.list + 1] = {\n                    index = index,\n                    name = tostring(gearSet.name or index),\n                    jobID = jobID,\n                    jobName = jobSwap.jobNameById[jobID] or \"Unknown\",\n                    category = category\n                }\n            end\n        end\n    end\n    table.sort(jobSwap.list, function(left, right)\n        if left.category ~= right.category then return left.category < right.category end\n        if left.jobName ~= right.jobName then return left.jobName < right.jobName end\n        if left.name ~= right.name then return left.name < right.name end\n        return (tonumber(left.index) or 0) < (tonumber(right.index) or 0)\n    end)\n    jobSwap.loadGearSets = \"v10\"\nend\n\nif not jacobWaymarkImportState then\n    jacobWaymarkImportState = {\n        raw = \"\",\n        status = \"\",\n        progress = 0\n    }\nend\nif not jacobImportWaymarkPreset then\n    jacobImportWaymarkPreset = function(raw)\n        local w = AnyoneCore and AnyoneCore.Waymarks\n        if not w or not w.io or not w.store or not AnyoneCore.JSON then\n            return false, \"AnyoneCore Waymark Helper is unavailable.\", false\n        end\n        local clean = tostring(raw or \"\")\n        local fence = string.char(96) .. string.char(96) .. string.char(96)\n        clean = string.gsub(clean, \"^%s*\" .. fence .. \"json%s*\", \"\")\n        clean = string.gsub(clean, \"^%s*\" .. fence .. \"%s*\", \"\")\n        clean = string.gsub(clean, \"%s*\" .. fence .. \"%s*$\", \"\")\n        local okObject, object = pcall(function()\n            return AnyoneCore.JSON.decode(clean)\n        end)\n        if not okObject or type(object) ~= \"table\" then\n            return false, \"Invalid waymark JSON.\", false\n        end\n        local okMarks, marks = pcall(function()\n            return w.io.parseWPP(clean)\n        end)\n        if not okMarks or type(marks) ~= \"table\" then\n            return false, \"The text is not a valid WPP preset.\", false\n        end\n        local markCount = 0\n        for _, markName in ipairs({ \"A\", \"B\", \"C\", \"D\", \"One\", \"Two\", \"Three\", \"Four\" }) do\n            local mark = marks[markName]\n            if type(mark) == \"table\" and type(mark.x) == \"number\" and type(mark.y) == \"number\" and type(mark.z) == \"number\" then\n                markCount = markCount + 1\n            end\n        end\n        if markCount == 0 then\n            return false, \"No active waymarks were found.\", false\n        end\n        local name = tostring(object.Name or object.name or \"Imported Waymarks\")\n        if name == \"\" then name = \"Imported Waymarks\" end\n        local existing = w.store.findEquivalent(marks)\n        if existing then\n            return true, \"Already exists as \" .. tostring(existing) .. \".\", false\n        end\n        local all = w.store.all() or {}\n        local baseName = name\n        local suffix = 0\n        while all[name] do\n            suffix = suffix + 1\n            name = baseName .. \" (\" .. tostring(suffix) .. \")\"\n        end\n        local mapID = tonumber(object.MapID or object.map or 0) or 0\n        local zone = mapID > 0 and { map = mapID } or nil\n        local okPut, putResult = pcall(function()\n            return w.store.put(name, marks, \"Imported\", zone)\n        end)\n        if not okPut then\n            return false, \"Import failed: \" .. tostring(putResult), false\n        end\n        if w.store.save then\n            pcall(w.store.save)\n        end\n        return true, \"Imported \" .. name .. \".\", true\n    end\nend\n\n\nif jacobWikiWaymarkCodeVersion ~= 2 then\n    jacobQueueWikiWaymarkPage = nil\n    jacobExtractWikiWaymarkBlocks = nil\n    jacobBuildWikiWaymarkRecords = nil\n    jacobDispatchWikiWaymarkPage = nil\n    jacobStartWikiWaymarkImport = nil\n    jacobProcessWikiWaymarkImport = nil\n    jacobWikiWaymarkCodeVersion = 2\nend\nif not jacobWikiWaymarkState then\n    jacobWikiWaymarkState = { phase = \"idle\", queue = {}, queued = {}, queueIndex = 1, pages = {}, pageOrder = {}, pending = false, records = {}, recordIndex = 1, imported = 0, duplicates = 0, failed = 0, fetched = 0, failedPages = 0, errors = {}, status = \"\", progress = 0 }\nend\nif not jacobQueueWikiWaymarkPage then\n    jacobQueueWikiWaymarkPage = function(slug)\n        local s = jacobWikiWaymarkState\n        if type(slug) ~= \"string\" or slug == \"\" or s.queued[slug] or #s.queue >= 100 then return end\n        s.queued[slug] = true\n        s.queue[#s.queue + 1] = slug\n    end\nend\nif not jacobExtractWikiWaymarkBlocks then\n    jacobExtractWikiWaymarkBlocks = function(body)\n        local blocks, seen = {}, {}\n        local fence = string.char(96) .. string.char(96) .. string.char(96)\n        local function add(raw)\n            raw = tostring(raw or \"\")\n            raw = string.gsub(raw, \"^%s+\", \"\")\n            raw = string.gsub(raw, \"%s+$\", \"\")\n            if raw ~= \"\" and not seen[raw] then seen[raw] = true; blocks[#blocks + 1] = raw end\n        end\n        for raw in string.gmatch(body or \"\", fence .. \"json%s*(%b{})%s*\" .. fence) do add(raw) end\n        for raw in string.gmatch(body or \"\", string.char(96) .. \"(%b{})\" .. string.char(96)) do add(raw) end\n        return blocks\n    end\nend\nif not jacobBuildWikiWaymarkRecords then\n    jacobBuildWikiWaymarkRecords = function()\n        local s = jacobWikiWaymarkState\n        s.records, s.recordKeys = {}, {}\n        for _, slug in ipairs(s.pageOrder) do\n            for _, raw in ipairs(jacobExtractWikiWaymarkBlocks(s.pages[slug])) do\n                if not s.recordKeys[raw] then\n                    s.recordKeys[raw] = true\n                    s.records[#s.records + 1] = { raw = raw, page = slug }\n                end\n            end\n        end\n        s.recordIndex = 1\n    end\nend\nif not jacobDispatchWikiWaymarkPage then\n    jacobDispatchWikiWaymarkPage = function()\n        local s = jacobWikiWaymarkState\n        if s.phase ~= \"fetching\" or s.pending or s.queueIndex > #s.queue then return end\n        local slug = s.queue[s.queueIndex]\n        s.queueIndex = s.queueIndex + 1\n        s.pending, s.currentPage = true, slug\n        s.status = \"Fetching \" .. slug .. \"...\"\n        HttpRequest({\n            host = \"raw.githubusercontent.com\",\n            path = \"/wiki/Em-Six/FFXIVWaymarkPresets/\" .. slug .. \".md\",\n            port = 443, https = true, method = \"GET\",\n            headers = { [\"User-Agent\"] = \"TensorReactions-JacobToolbox\" },\n            onsuccess = function(response, header, statusCode)\n                local state = jacobWikiWaymarkState\n                if state.phase == \"cancelled\" then return end\n                local code, body = tonumber(statusCode) or 0, tostring(response or \"\")\n                state.pending = false\n                if code == 200 and body ~= \"\" then\n                    state.pages[slug] = body\n                    state.pageOrder[#state.pageOrder + 1] = slug\n                    state.fetched = state.fetched + 1\n                    for linkedSlug in string.gmatch(body, \"github%.com/Em%-Six/FFXIVWaymarkPresets/wiki/([^%s%]]+)\") do\n                        linkedSlug = string.gsub(linkedSlug, \"[?#].*$\", \"\")\n                        if string.sub(linkedSlug, -1) == \")\" then\n                            linkedSlug = string.sub(linkedSlug, 1, -2)\n                        end\n                        jacobQueueWikiWaymarkPage(linkedSlug)\n                    end\n                    state.status = \"Loaded \" .. slug\n                else\n                    state.failedPages = state.failedPages + 1\n                    state.errors[#state.errors + 1] = slug .. \" (\" .. tostring(code) .. \")\"\n                    state.status = \"Could not load \" .. slug\n                end\n            end,\n            onfailure = function(error, header, statusCode)\n                local state = jacobWikiWaymarkState\n                if state.phase == \"cancelled\" then return end\n                state.pending = false\n                state.failedPages = state.failedPages + 1\n                state.errors[#state.errors + 1] = slug\n                state.status = \"Could not load \" .. slug\n            end\n        })\n    end\nend\nif not jacobStartWikiWaymarkImport then\n    jacobStartWikiWaymarkImport = function()\n        local s = jacobWikiWaymarkState\n        s.phase, s.queue, s.queued, s.queueIndex = \"fetching\", {}, {}, 1\n        s.pages, s.pageOrder, s.pending = {}, {}, false\n        s.records, s.recordKeys, s.recordIndex = {}, {}, 1\n        s.imported, s.duplicates, s.failed = 0, 0, 0\n        s.fetched, s.failedPages, s.errors = 0, 0, {}\n        s.progress, s.status = 0, \"Starting wiki import...\"\n        jacobQueueWikiWaymarkPage(\"Home\")\n    end\nend\nif not jacobProcessWikiWaymarkImport then\n    jacobProcessWikiWaymarkImport = function()\n        local s = jacobWikiWaymarkState\n        if s.phase == \"fetching\" then\n            if not s.pending and s.queueIndex <= #s.queue then\n                jacobDispatchWikiWaymarkPage()\n            elseif not s.pending and s.queueIndex > #s.queue then\n                jacobBuildWikiWaymarkRecords()\n                s.phase, s.status, s.progress = \"importing\", \"Importing \" .. tostring(#s.records) .. \" presets...\", 0.65\n            end\n        elseif s.phase == \"importing\" then\n            local record = s.records[s.recordIndex]\n            if record then\n                local okImport, importStatus, added = jacobImportWaymarkPreset(record.raw)\n                if okImport and added then s.imported = s.imported + 1 elseif okImport then s.duplicates = s.duplicates + 1 else s.failed = s.failed + 1 end\n                s.status = importStatus .. \" (\" .. tostring(s.recordIndex) .. \"/\" .. tostring(#s.records) .. \")\"\n                s.recordIndex = s.recordIndex + 1\n                if #s.records > 0 then s.progress = 0.65 + (0.35 * ((s.recordIndex - 1) / #s.records)) end\n            else\n                local w = AnyoneCore and AnyoneCore.Waymarks\n                if w and w.store and w.store.save then pcall(w.store.save) end\n                s.phase, s.progress, s.status = \"complete\", 1, \"Finished wiki import.\"\n            end\n        end\n    end\nend\n\nlocal jacobPlayer = TensorCore and TensorCore.mGetPlayer and TensorCore.mGetPlayer() or nil\nlocal jacobInCombat = jacobPlayer and jacobPlayer.incombat == true\nif jacobUtilitiesExtracting == true and jacobInCombat then\n    jacobUtilitiesExtracting = false\n    jacobUtilitiesNextExtract = nil\nend\nif jacobUtilitiesExtracting == true and jacobNow >= (jacobUtilitiesNextExtract or 0) then\n    if ffxiv_craft and ffxiv_craft.Canextractmateria and ffxiv_craft.extractmateria and ffxiv_craft.Canextractmateria() then\n        if ffxiv_craft.extractmateria() then\n            jacobUtilitiesNextExtract = jacobNow + 4000\n        else\n            jacobUtilitiesExtracting = false\n        end\n    else\n        jacobUtilitiesExtracting = false\n    end\nend\n\n\nGUI:Spacing()\nif jacobUtilitiesOpen == true then\n    GUI:Text(\"Utilities\")\n    GUI:PushStyleColor(GUI.Col_Button, 0.60, 0.18, 0.12, 1.0)\n    GUI:PushStyleColor(GUI.Col_ButtonHovered, 0.78, 0.28, 0.16, 1.0)\n    GUI:PushStyleColor(GUI.Col_ButtonActive, 0.45, 0.10, 0.08, 1.0)\n    local returnClicked = GUI:Button(\"Return\", 95, 20)\n    GUI:PopStyleColor(3)\n    if returnClicked then\n        jacobUtilitiesOpen = false\n    end\n    GUI:SameLine()\n    local extractionBusy = jacobUtilitiesExtracting == true\n    if extractionBusy then\n        GUI:Button(\"Extracting...\", 145, 20)\n        GUI:SameLine(0, 2)\n        GUI:PushStyleColor(GUI.Col_Button, 0.78, 0.08, 0.08, 1.0)\n        GUI:PushStyleColor(GUI.Col_ButtonHovered, 0.95, 0.16, 0.16, 1.0)\n        GUI:PushStyleColor(GUI.Col_ButtonActive, 0.58, 0.04, 0.04, 1.0)\n        local stopClicked = GUI:Button(\"STOP\", 78, 26)\n        GUI:PopStyleColor(3)\n        if stopClicked then\n            jacobUtilitiesExtracting = false\n            jacobUtilitiesNextExtract = nil\n        end\n        GUI:Spacing()\n        GUI:Text(\"Extracting spiritbonded gear...\")\n    else\n        local extractClicked = GUI:Button(\"Extract Materia\", 145, 20)\n        if extractClicked then\n            if jacobInCombat then\n                GUI:OpenPopup(\"JacobExtractCombatPopup\")\n            else\n                jacobUtilitiesExtracting = true\n                jacobUtilitiesNextExtract = 0\n            end\n        end\n    end\n    if GUI:BeginPopup(\"JacobExtractCombatPopup\") then\n        GUI:Text(\"cannot use this in combat.\")\n        if GUI:Button(\"OK\", 70, 20) then\n            GUI:CloseCurrentPopup()\n        end\n        GUI:EndPopup()\n    end\n    GUI:Spacing()\n\n    GUI:Spacing()\n    local autoMelderClicked = GUI:Button(\"Auto Melder\", 110, 20)\n    if autoMelderClicked and AnyoneCore and AnyoneCore.Data then\n        AnyoneCore.Data.autoMelderOpen = true\n    end\n    GUI:SameLine()\n    local importWaymarksClicked = GUI:Button(\"Import Waymarkers\", 145, 20)\n    if importWaymarksClicked then\n        if jacobInCombat then GUI:OpenPopup(\"JacobWaymarkImportCombatPopup\") else GUI:OpenPopup(\"JacobWaymarkBulkConfirmPopup\") end\n    end\n    if GUI:BeginPopup(\"JacobWaymarkImportCombatPopup\") then\n        GUI:Text(\"Cannot import waymarks in combat.\")\n        if GUI:Button(\"OK\", 70, 20) then GUI:CloseCurrentPopup() end\n        GUI:EndPopup()\n    end\n    if GUI:BeginPopup(\"JacobWaymarkBulkConfirmPopup\") then\n        GUI:Text(\"Import all wiki waymark presets?\")\n        GUI:Text(\"This fetches every linked wiki page and skips duplicates.\")\n        if GUI:Button(\"Confirm\", 90, 20) then jacobStartWikiWaymarkImport(); GUI:CloseCurrentPopup() end\n        GUI:SameLine()\n        if GUI:Button(\"Cancel\", 90, 20) then GUI:CloseCurrentPopup() end\n        GUI:EndPopup()\n    end\n    GUI:Spacing()\n    local customDrawMonitorClicked = GUI:Button(\"Draw Monitor\", 140, 24)\n    if customDrawMonitorClicked then\n        jacobCustomDrawMonitorOpen = jacobCustomDrawMonitorOpen ~= true\n    end\n    GUI:Spacing()\n    local thirdPartyClicked = GUI:Button(\"Third party\", 120, 24)\n    if thirdPartyClicked and AnyoneCore then\n        AnyoneCore.open = true\n        AnyoneCore.selectedTab = \"Third Party\"\n    end\n    GUI:SameLine()\n    local minionMusicClicked = GUI:Button(\"Music\", 95, 24)\n    if minionMusicClicked and ffxiv_music and ffxiv_music.ToggleMenu then\n        ffxiv_music.ToggleMenu()\n    end\nelse\nlocal clicked = GUI:Button(\"Strats\", 95, 20)\nGUI:SameLine()\nlocal agentClicked = GUI:Button(\"Agent\", 95, 20)\nif agentClicked and TensorCore and TensorCore.API and TensorCore.API.TensorReactions then\n    TensorCore.API.TensorReactions.toggleGUI()\nend\nGUI:SameLine()\nlocal mitigationButtonClicked = GUI:Button(\"Mitigations\", 95, 20)\nif mitigationButtonClicked then\n    GUI:OpenPopup(\"JacobMitigationsPopup\")\nend\nGUI:Spacing()\nlocal profilerClicked = GUI:Button(\"Profiler\", 95, 20)\nGUI:SameLine()\nlocal acrOptionsClicked = GUI:Button(\"ACR Options\", 95, 20)\nGUI:SameLine()\nlocal devMonitorClicked = GUI:Button(\"Dev Monitor\", 95, 20)\nif profilerClicked and Profiler and Profiler.open then\n    Profiler.open()\nend\nif acrOptionsClicked and ACR and ACR.OpenProfileOptions then\n    ACR.OpenProfileOptions()\nend\nif devMonitorClicked and AnyoneCore and AnyoneCore.Settings then\n    AnyoneCore.Settings.DevMonitor = not AnyoneCore.Settings.DevMonitor\nend\nif AnyoneCore and AnyoneCore.Settings and AnyoneCore.Settings.DutyHelper then\n    AnyoneCore.Settings.DutyHelper.enabled = GUI:Checkbox(\"DutyHelper\", AnyoneCore.Settings.DutyHelper.enabled == true)\n    GUI:SameLine()\nend\nlocal reactionSettings = AnyoneCore and AnyoneCore.Settings and AnyoneCore.Settings.Reactions\ngStartCombat = GUI:Checkbox(\"Combat\", gStartCombat)\nlocal prepullHelper = AnyoneCore and AnyoneCore.Settings and AnyoneCore.Settings.PrepullHelper\nif prepullHelper then\n    GUI:SameLine()\n    prepullHelper.enabled = GUI:Checkbox(\"Prepull Helper\", prepullHelper.enabled == true)\nend\nif GUI:BeginPopup(\"JacobMitigationsPopup\") then\n    GUI:Text(\"Ultimates\")\n    if reactionSettings and reactionSettings.dmu then\n        reactionSettings.dmu.primaryMitigation = GUI:Checkbox(\"DMU Primary\", reactionSettings.dmu.primaryMitigation == true)\n    end\n    if reactionSettings then\n        reactionSettings.fruPrimaryMitigation = GUI:Checkbox(\"FRU Primary\", reactionSettings.fruPrimaryMitigation == true)\n        reactionSettings.UWUEnableMitigation = GUI:Checkbox(\"UWU Primary\", reactionSettings.UWUEnableMitigation == true)\n    end\n\n    GUI:Separator()\n    GUI:Text(\"Savages\")\n    if reactionSettings then\n        reactionSettings.arcadionPrimaryMitigation = GUI:Checkbox(\"M9S-M12S Primary\", reactionSettings.arcadionPrimaryMitigation == true)\n        reactionSettings.arcadionPrimaryMitigation = GUI:Checkbox(\"M5S-M8S Primary\", reactionSettings.arcadionPrimaryMitigation == true)\n        reactionSettings.secondaryMitigation = not GUI:Checkbox(\"P11S-P12S Primary\", reactionSettings.secondaryMitigation ~= true)\n    end\n    GUI:EndPopup()\nend\nGUI:Spacing()\nlocal slidecastEnabled = TensorDrift_SlidecastEnabled == true\nlocal slidecastMode = tostring(TensorDrift_SlidecastMode or \"off\"):lower()\nlocal slideButtonActive = slidecastEnabled and slidecastMode == \"slide\"\nlocal stutterButtonActive = slidecastEnabled and slidecastMode == \"stutter\"\nlocal slidecastOffHold = TensorDrift_SlidecastForceHold == true\nlocal slidecastDisableHold = TensorDrift_SlidecastDisableHold == true\nlocal offButtonActive = (not slidecastEnabled) or slidecastMode == \"off\" or slidecastOffHold or slidecastDisableHold\n\nlocal function drawSlidecastButton(label, mode, active)\n    GUI:PushStyleColor(GUI.Col_Button, 0.38, 0.10, 0.10, 1.0)\n    GUI:PushStyleColor(GUI.Col_ButtonHovered, 0.52, 0.16, 0.16, 1.0)\n    GUI:PushStyleColor(GUI.Col_ButtonActive, 0.30, 0.06, 0.06, 1.0)\n    if active then\n        GUI:PushStyleColor(GUI.Col_Button, 0.20, 0.65, 0.25, 1.0)\n        GUI:PushStyleColor(GUI.Col_ButtonHovered, 0.25, 0.75, 0.30, 1.0)\n        GUI:PushStyleColor(GUI.Col_ButtonActive, 0.15, 0.55, 0.20, 1.0)\n    end\n    local pressed = GUI:Button(label, 65, 20)\n    GUI:PopStyleColor(active and 6 or 3)\n    if pressed then\n        if mode == \"off\" then\n            TensorDrift_SlidecastEnabled = false\n        else\n            TensorDrift_SlidecastEnabled = true\n            TensorDrift_SlidecastMode = mode\n        end\n    end\nend\n\ndrawSlidecastButton(\"Slide\", \"slide\", slideButtonActive)\nGUI:SameLine()\ndrawSlidecastButton(\"Stutter\", \"stutter\", stutterButtonActive)\nGUI:SameLine()\ndrawSlidecastButton(\"Off\", \"off\", offButtonActive)\nGUI:SameLine()\nlocal mapIDPlayer = TensorCore.mGetPlayer()\nlocal mapID = mapIDPlayer and mapIDPlayer.localmapid or 0\nGUI:Text(\"MapID: \" .. tostring(mapID))\n\nGUI:Spacing()\nif gLj_Toolbox and gLj_Toolbox.Constants and gLj_Toolbox.Settings and gLj_Toolbox.UpdateRoleOptions then\n    local roleOptions, roleType = gLj_Toolbox.UpdateRoleOptions()\n    local currentRole = roleOptions and roleOptions[gLj_Toolbox.Settings.selectedRole] or \"Role\"\n    local roleColor = gLj_Toolbox.Constants.ROLE_COLORS and gLj_Toolbox.Constants.ROLE_COLORS[roleType]\n    GUI:Text(\"Role: \")\n    GUI:SameLine()\n    GUI:PushStyleVar(GUI.StyleVar_FramePadding, 4, 2)\n    if roleColor then GUI:PushStyleColor(GUI.Col_Button, roleColor[1], roleColor[2], roleColor[3], roleColor[4]) end\n    local roleClicked = GUI:Button(currentRole .. (gLj_Toolbox.Constants.ROLE_BUTTON_ID or \"##JacobRoleButton\"), gLj_Toolbox.Constants.ROLE_BTN_WIDTH or 155, gLj_Toolbox.Constants.ROLE_BTN_HEIGHT or 18)\n    local roleRightClicked = GUI:IsItemHovered() and GUI:IsMouseClicked(1)\n    if roleColor then GUI:PopStyleColor() end\n    GUI:PopStyleVar()\n\n    local rolePopupID = \"JacobRoleSelectPopup\"\n    if roleClicked then GUI:OpenPopup(rolePopupID) end\n    if roleRightClicked then gLj_Toolbox.Settings.showPartyAssigner = not gLj_Toolbox.Settings.showPartyAssigner end\n\n    if GUI:BeginPopup(rolePopupID) then\n        for i, role in ipairs(roleOptions or {}) do\n            if GUI:MenuItem(role) then\n                gLj_Toolbox.Settings.selectedRole = i\n                local localPlayer = TensorCore.mGetPlayer()\n                if localPlayer and localPlayer.name then\n                    for n, r in pairs(gLj_Toolbox.Settings.partyRoles) do\n                        if n == localPlayer.name then gLj_Toolbox.Settings.partyRoles[n] = nil end\n                    end\n                    for name, r in pairs(gLj_Toolbox.Settings.partyRoles) do\n                        if r == role then\n                            gLj_Toolbox.Settings.partyRoles[name] = \"None\"\n                            local pJob = nil\n                            if gLj_Toolbox.Cache and gLj_Toolbox.Cache.sortedParty then\n                                for _, e in ipairs(gLj_Toolbox.Cache.sortedParty) do\n                                    if e.name == name then pJob = e.job break end\n                                end\n                            end\n                            if pJob and gLj_Toolbox.SaveProfile then gLj_Toolbox.SaveProfile(name, pJob, \"None\") end\n                        end\n                    end\n                    gLj_Toolbox.Settings.partyRoles[localPlayer.name] = role\n                    if gLj_Toolbox.SaveProfile then gLj_Toolbox.SaveProfile(localPlayer.name, localPlayer.job, role) end\n                    local eID = localPlayer.id\n                    if gLj_PartyRoles and gLj_Toolbox.Constants.allRoles then\n                        for _, r in ipairs(gLj_Toolbox.Constants.allRoles) do\n                            if gLj_PartyRoles[r] == eID then\n                                gLj_PartyRoles[r] = 0\n                                if _G[\"gLj_Role_\" .. r] then _G[\"gLj_Role_\" .. r] = 0 end\n                            end\n                        end\n                        gLj_PartyRoles[role] = eID\n                        if _G[\"gLj_Role_\" .. role] then _G[\"gLj_Role_\" .. role] = eID end\n                    end\n                end\n            end\n        end\n        GUI:EndPopup()\n    end\nend\n\nGUI:Spacing()\nlocal assistRunning = FFXIV_Common_BotRunning == true\nlocal assistReady = not FFXIVData_IsReady or FFXIVData_IsReady()\nlocal assistColor = assistRunning and { r = 0, g = 0.10, b = 0, a = 0.75 } or { r = 0.10, g = 0, b = 0, a = 0.75 }\nGUI:PushStyleVar(GUI.StyleVar_ChildWindowRounding, 10)\nGUI:PushStyleColor(GUI.Col_ChildWindowBg, assistColor.r, assistColor.g, assistColor.b, assistColor.a)\nGUI:BeginChild(\"##JacobAssist\", 120, 40, true)\nGUI:AlignFirstTextHeightToWidgets()\nGUI:Text(\"Assist\")\nGUI:EndChild()\nif assistReady and GUI:IsItemHovered() and GUI:IsMouseClicked(0) then\n    ffxivminion.DutyCurrentData = {}\n    ml_global_information.ToggleRun()\nend\nGUI:PopStyleColor()\nGUI:PopStyleVar()\n\nGUI:SameLine()\nlocal waymarksClicked = GUI:Button(\"Waymarks\", 95, 40)\nif waymarksClicked and AnyoneCore and AnyoneCore.Data then\n    AnyoneCore.Data.waymarkPresets = not (AnyoneCore.Data.waymarkPresets == true)\nend\n\nGUI:SameLine()\nlocal jobSwapClicked = GUI:Button(\"Jobs\", 65, 40)\nif jobSwapClicked then\n    GUI:OpenPopup(\"JacobJobSwapPopup\")\nend\nGUI:PushStyleColor(GUI.Col_PopupBg, 0.025, 0.07, 0.11, 1.0)\nif GUI:BeginPopup(\"JacobJobSwapPopup\") then\n    local refreshGearSets = GUI:Button(\"Refresh\", 70, 20)\n    if refreshGearSets then\n        jobSwap.loadGearSets = nil\n    end\n    GUI:Spacing()\n\n    local function drawGearSetMenu(label, category, red, green, blue)\n        local textRed = math.min(red + 0.25, 1.0)\n        local textGreen = math.min(green + 0.25, 1.0)\n        local textBlue = math.min(blue + 0.25, 1.0)\n        GUI:PushStyleColor(GUI.Col_Header, red, green, blue, 1.0)\n        GUI:PushStyleColor(GUI.Col_HeaderHovered, math.min(red + 0.12, 1.0), math.min(green + 0.12, 1.0), math.min(blue + 0.12, 1.0), 1.0)\n        GUI:PushStyleColor(GUI.Col_HeaderActive, red * 0.78, green * 0.78, blue * 0.78, 1.0)\n        GUI:PushStyleColor(GUI.Col_Text, textRed, textGreen, textBlue, 1.0)\n        local categoryIconPath = jobSwap.roleIconPathByCategory[category]\n        if categoryIconPath then\n            GUI:Image(categoryIconPath, 16, 16)\n            GUI:SameLine()\n        end\n        local menuOpen = GUI:BeginMenu(string.upper(label))\n        GUI:PopStyleColor(4)\n        if menuOpen then\n            local grouped = {}\n            local jobNames = {}\n            for _, gearSet in ipairs(jobSwap.list or {}) do\n                if gearSet.category == category then\n                    local jobName = gearSet.jobName or \"Unknown\"\n                    if not grouped[jobName] then\n                        grouped[jobName] = {}\n                        jobNames[#jobNames + 1] = jobName\n                    end\n                    grouped[jobName][#grouped[jobName] + 1] = gearSet\n                end\n            end\n            local function drawJobMenu(jobName)\n                if not grouped[jobName] then\n                    return false\n                end\n                local firstGearSet = grouped[jobName][1]\n                local iconPath = firstGearSet and jobSwap.jobIconPathById[firstGearSet.jobID] or nil\n                GUI:BeginGroup()\n                if iconPath then\n                    GUI:Image(iconPath, 16, 16)\n                    GUI:SameLine()\n                end\n                local jobOpen = GUI:BeginMenu(jobName)\n                if jobOpen then\n                    table.sort(grouped[jobName], function(left, right)\n                        if left.name ~= right.name then return left.name < right.name end\n                        return (tonumber(left.index) or 0) < (tonumber(right.index) or 0)\n                    end)\n                    for _, gearSet in ipairs(grouped[jobName]) do\n                        local menuLabel = gearSet.name .. \"##JacobGearSet\" .. tostring(gearSet.index)\n                        if GUI:MenuItem(menuLabel) then\n                            SendTextCommand(\"/gs equip \" .. tostring(gearSet.index))\n                        end\n                    end\n                    GUI:EndMenu()\n                end\n                GUI:EndGroup()\n                return true\n            end\n\n            local jobNameGroups = {}\n            if category == \"DPS\" then\n                jobNameGroups = {\n                    { \"Machinist\", \"Dancer\", \"Bard\" },\n                    { \"Monk\", \"Dragoon\", \"Ninja\", \"Samurai\", \"Reaper\", \"Viper\" },\n                    { \"Black Mage\", \"Arcanist\", \"Summoner\", \"Red Mage\", \"Pictomancer\" }\n                }\n            else\n                local sortedJobNames = {}\n                for _, jobName in ipairs(jobNames) do\n                    sortedJobNames[#sortedJobNames + 1] = jobName\n                end\n                table.sort(sortedJobNames)\n                jobNameGroups = { sortedJobNames }\n            end\n\n            local renderedGroup = false\n            for _, group in ipairs(jobNameGroups) do\n                local groupHasJobs = false\n                for _, jobName in ipairs(group) do\n                    if grouped[jobName] then\n                        groupHasJobs = true\n                        break\n                    end\n                end\n                if groupHasJobs then\n                    if renderedGroup then\n                        GUI:Separator()\n                    end\n                    for _, jobName in ipairs(group) do\n                        drawJobMenu(jobName)\n                    end\n                    renderedGroup = true\n                end\n            end\n            if #jobNames == 0 then\n                GUI:Text(\"No gear sets.\")\n            end\n            GUI:EndMenu()\n        end\n    end\n\n    drawGearSetMenu(\"DPS\", \"DPS\", 0.55, 0.12, 0.12)\n    drawGearSetMenu(\"Healer\", \"Healer\", 0.12, 0.50, 0.20)\n    drawGearSetMenu(\"Tank\", \"Tank\", 0.12, 0.30, 0.60)\n    drawGearSetMenu(\"Crafters\", \"Crafters\", 0.55, 0.30, 0.10)\n    drawGearSetMenu(\"Gatherers\", \"Gatherers\", 0.34, 0.20, 0.55)\n    drawGearSetMenu(\"Limited jobs\", \"Limited jobs\", 0.28, 0.28, 0.30)\n    GUI:EndPopup()\nend\nGUI:PopStyleColor()\n\nif clicked and AnyoneCore then\n    local isReactionsOpen = AnyoneCore.open and AnyoneCore.selectedTab == \"Reactions\"\n    AnyoneCore.open = not isReactionsOpen\n    if AnyoneCore.open then\n        AnyoneCore.selectedTab = \"Reactions\"\n    end\nend\nend\njacobProcessWikiWaymarkImport()\nGUI:End()\nGUI:PopStyleColor(2)\n\nif jacobCustomDrawMonitorOpen == true then\n    GUI:SetNextWindowSize(620, 420, GUI.SetCond_FirstUseEver)\n    local drawMonitorVisible, drawMonitorOpen = GUI:Begin(\"Custom Draw Monitor\", jacobCustomDrawMonitorOpen, GUI.WindowFlags_NoCollapse)\n    jacobCustomDrawMonitorOpen = drawMonitorOpen == true\n    if drawMonitorVisible then\n        local drawCount = Argus.getNumTimedDraws()\n        GUI:Text(\"Active Argus timed draws: \" .. tostring(drawCount))\n        GUI:Text(\"Argus does not report the source reaction; inspect each UUID, timing, color, and shape.\")\n        GUI:Separator()\n        GUI:BeginChild(\"##JacobCustomDrawList\", 0, 330, true)\n        if drawCount == 0 then\n            GUI:Text(\"No timed draws are active.\")\n        else\n            for index = 1, drawCount do\n                local shape, x, y, z, startTime, duration, delay, uuid, colorStart, colorEnd =\n                    Argus.getTimedDrawBaseInfo(index)\n                local entityAttach, targetAttach, keepLength, keepHeading, headingOffset, colorMid, colorOutline, outlineThickness =\n                    Argus.getTimedDrawOptArgs(index)\n                if uuid ~= nil then\n                    GUI:Text(tostring(index) .. \". \" .. tostring(shape) .. \"  UUID: \" .. tostring(uuid))\n                    GUI:Text(\"Position: \" .. tostring(x) .. \", \" .. tostring(y) .. \", \" .. tostring(z)\n                        .. \"  start=\" .. tostring(startTime) .. \" duration=\" .. tostring(duration)\n                        .. \" delay=\" .. tostring(delay))\n                    GUI:Text(\"Attach: \" .. tostring(entityAttach) .. \" -> \" .. tostring(targetAttach)\n                        .. \"  colors start/mid/end: \" .. tostring(colorStart) .. \"/\"\n                        .. tostring(colorMid) .. \"/\" .. tostring(colorEnd))\n                    GUI:Text(\"Outline: \" .. tostring(colorOutline) .. \"  thickness=\" .. tostring(outlineThickness)\n                        .. \"  headingOffset=\" .. tostring(headingOffset)\n                        .. \"  keepLength=\" .. tostring(keepLength) .. \" keepHeading=\" .. tostring(keepHeading))\n                    local geometryText = nil\n                    if shape == \"arrow\" then\n                        local length, width, tipLength, tipWidth, heading = Argus.getTimedArrowInfo(index)\n                        geometryText = \"Arrow length=\" .. tostring(length) .. \" width=\" .. tostring(width)\n                            .. \" tip=\" .. tostring(tipLength) .. \"x\" .. tostring(tipWidth)\n                            .. \" heading=\" .. tostring(heading)\n                    elseif shape == \"circle\" then\n                        local radius, segments = Argus.getTimedCircleInfo(index)\n                        geometryText = \"Circle radius=\" .. tostring(radius) .. \" segments=\" .. tostring(segments)\n                    elseif shape == \"rect\" then\n                        local length, width, heading = Argus.getTimedRectInfo(index)\n                        geometryText = \"Rect length=\" .. tostring(length) .. \" width=\" .. tostring(width)\n                            .. \" heading=\" .. tostring(heading)\n                    elseif shape == \"centeredrect\" then\n                        local length, width, heading = Argus.getTimedCenteredRectInfo(index)\n                        geometryText = \"Centered rect length=\" .. tostring(length) .. \" width=\" .. tostring(width)\n                            .. \" heading=\" .. tostring(heading)\n                    elseif shape == \"cone\" then\n                        local radius, angle, heading = Argus.getTimedConeInfo(index)\n                        geometryText = \"Cone radius=\" .. tostring(radius) .. \" angle=\" .. tostring(angle)\n                            .. \" heading=\" .. tostring(heading)\n                    elseif shape == \"donut\" then\n                        local inner, outer = Argus.getTimedDonutInfo(index)\n                        geometryText = \"Donut inner=\" .. tostring(inner) .. \" outer=\" .. tostring(outer)\n                    elseif shape == \"donutcone\" then\n                        local inner, outer, angle, heading = Argus.getTimedDonutConeInfo(index)\n                        geometryText = \"Donut cone inner=\" .. tostring(inner) .. \" outer=\" .. tostring(outer)\n                            .. \" angle=\" .. tostring(angle) .. \" heading=\" .. tostring(heading)\n                    elseif shape == \"cross\" then\n                        local length, width, heading = Argus.getTimedCrossInfo(index)\n                        geometryText = \"Cross length=\" .. tostring(length) .. \" width=\" .. tostring(width)\n                            .. \" heading=\" .. tostring(heading)\n                    elseif shape == \"linesegment\" then\n                        local x2, y2, z2, endpointThickness = Argus.getTimedLineSegmentInfo(index)\n                        geometryText = \"Line end=\" .. tostring(x2) .. \", \" .. tostring(y2) .. \", \" .. tostring(z2)\n                            .. \" endThickness=\" .. tostring(endpointThickness)\n                    elseif shape == \"chevron\" then\n                        local length, thickness, heading = Argus.getTimedChevronInfo(index)\n                        geometryText = \"Chevron length=\" .. tostring(length) .. \" thickness=\" .. tostring(thickness)\n                            .. \" heading=\" .. tostring(heading)\n                    end\n                    if geometryText then GUI:Text(geometryText) end\n                    GUI:Separator()\n                end\n            end\n        end\n        GUI:EndChild()\n        if GUI:Button(\"Close\", 90, 22) then\n            jacobCustomDrawMonitorOpen = false\n        end\n    end\n    GUI:End()\nend\n\nif jacobWikiWaymarkState.phase == \"fetching\" or jacobWikiWaymarkState.phase == \"importing\" or jacobWikiWaymarkState.phase == \"complete\" then\n    GUI:Begin(\"Jacob's Waymark Import\", true, GUI.WindowFlags_AlwaysAutoResize)\n    GUI:Text(\"Wiki preset import\")\n    if jacobWikiWaymarkState.phase == \"fetching\" then\n        GUI:Text(\"Loading wiki pages...\")\n        GUI:Text(\"Pages loaded: \" .. tostring(jacobWikiWaymarkState.fetched) .. \" / \" .. tostring(#jacobWikiWaymarkState.queue))\n    elseif jacobWikiWaymarkState.phase == \"importing\" then\n        GUI:Text(\"Importing presets into AnyoneCore...\")\n        GUI:Text(\"Added: \" .. tostring(jacobWikiWaymarkState.imported) .. \"  Duplicates: \" .. tostring(jacobWikiWaymarkState.duplicates) .. \"  Failed: \" .. tostring(jacobWikiWaymarkState.failed))\n    else\n        GUI:Text(\"Import complete.\")\n        GUI:Text(\"Added: \" .. tostring(jacobWikiWaymarkState.imported) .. \"  Duplicates: \" .. tostring(jacobWikiWaymarkState.duplicates) .. \"  Failed: \" .. tostring(jacobWikiWaymarkState.failed))\n        if jacobWikiWaymarkState.failedPages > 0 then GUI:Text(\"Pages unavailable: \" .. tostring(jacobWikiWaymarkState.failedPages)) end\n    end\n    GUI:ProgressBar(jacobWikiWaymarkState.progress, 300, 12, string.format(\"%d%%\", math.floor(jacobWikiWaymarkState.progress * 100)))\n    GUI:Text(jacobWikiWaymarkState.status or \"\")\n    if jacobWikiWaymarkState.phase == \"complete\" then\n        if GUI:Button(\"Close\", 90, 20) then jacobWikiWaymarkState.phase = \"idle\" end\n    elseif GUI:Button(\"Cancel\", 90, 20) then\n        jacobWikiWaymarkState.phase, jacobWikiWaymarkState.pending = \"cancelled\", false\n        jacobWikiWaymarkState.status = \"Import cancelled.\"\n    end\n    GUI:End()\nend\n\nif AnyoneCore and AnyoneCore.Data and AnyoneCore.Data.autoMelderOpen == true and AnyoneCore.DrawAutomelder then\n    AnyoneCore.DrawAutomelder()\nend\n\n\n\nself.used = true",
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
			name = "Sildihn criterion",
			uuid = "fdd915dc-0d3d-7f8f-a90f-989f6525aeb4",
		},
		objectType = "folder",
	},
	
	{
		data = 
		{
			displayPath = "Sildihn criterion",
			name = "Trash",
			uuid = "63414d33-f077-2977-a6c0-e42216d79621",
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
						name = "Sildihn criterion",
						uuid = "fbb11028-0497-e279-b46d-d5bb8f635058",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Trash",
						uuid = "34e18922-bfbd-69d6-b9d9-b440fa1681ed",
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
						alertText = "MOVE IN — ATROPINE SPORE (DONUT)",
						conditions = 
						{
							
							{
								"4cea36e9-c7ce-167a-bf82-abad0b8e93c4",
								true,
							},
							
							{
								"b2cadf11-08e4-4565-9c3b-c8e557426d06",
								true,
							},
							
							{
								"2098ebb2-ef28-4c7b-a1bc-a373b833ef3c",
								true,
							},
						},
						displayPath = "Sildihn criterion/Trash",
						name = "MOVE IN — ATROPINE SPORE (DONUT)",
						uuid = "d086c2a4-9ec1-f3a0-908b-3c1134060c05",
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
						name = "Sildihn criterion",
						uuid = "18c9960c-e915-71a8-aed0-0a1f499e3b94",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Trash",
						uuid = "d639e6d5-2e7f-6f5f-b802-eb3fa4eb5fe5",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						localMapIDList = 
						{
							1075,
							1076,
						},
						name = "Sil'dihn map",
						uuid = "4cea36e9-c7ce-167a-bf82-abad0b8e93c4",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						eventArgOptionType = 2,
						eventEntityContentID = 11514,
						name = "[Alert] Belladonna",
						uuid = "b2cadf11-08e4-4565-9c3b-c8e557426d06",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						eventArgType = 2,
						eventSpellID = 31072,
						name = "Atropine Spore",
						uuid = "2098ebb2-ef28-4c7b-a1bc-a373b833ef3c",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Trash",
			eventType = 3,
			name = "[Alert] Belladonna - Atropine Spore",
			uuid = "0ed0ef9d-3722-35cf-bc00-4e475cbef9cf",
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
						name = "Sildihn criterion",
						uuid = "3a05ce3e-8fb1-f8da-bcb2-1050348d2ad9",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Trash",
						uuid = "6502539f-62cc-5f75-aad4-d1c46ad5bb67",
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
						alertText = "MOVE AWAY — ARBOREAL STORM",
						conditions = 
						{
							
							{
								"7952754c-398e-2caf-a5f9-cb679d7c8d5d",
								true,
							},
							
							{
								"f76f82e3-a25b-e302-a097-711414caa4f9",
								true,
							},
							
							{
								"06f8d3a9-36de-c2d4-94d0-9bda69228287",
								true,
							},
						},
						displayPath = "Sildihn criterion/Trash",
						name = "MOVE AWAY — ARBOREAL STORM",
						uuid = "24d54d4c-60ff-9c76-b400-69e1b2895d35",
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
						name = "Sildihn criterion",
						uuid = "25e9daeb-39c2-1151-95f1-236f2f1c8cde",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Trash",
						uuid = "d1f21a56-41d5-1cd6-9259-fd49af7120f4",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						localMapIDList = 
						{
							1075,
							1076,
						},
						name = "Sil'dihn map",
						uuid = "7952754c-398e-2caf-a5f9-cb679d7c8d5d",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						eventArgOptionType = 2,
						eventEntityContentID = 11513,
						name = "[Alert] Dryad",
						uuid = "f76f82e3-a25b-e302-a097-711414caa4f9",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						eventArgType = 2,
						eventSpellID = 31063,
						name = "Arboreal Storm",
						uuid = "06f8d3a9-36de-c2d4-94d0-9bda69228287",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Trash",
			eventType = 3,
			name = "[Alert] Dryad - Arboreal Storm",
			uuid = "0a2fd9bb-44aa-94ea-9577-40aea04be147",
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
						name = "Sildihn criterion",
						uuid = "0d170318-fb4d-ee3b-8fe3-4ec2f6b2b1a7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Trash",
						uuid = "f09491c0-997d-8a70-975b-0b176e244832",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Alert",
						alertPriority = 3,
						alertScale = 0.89999997615814,
						alertTTS = true,
						alertText = "DODGE FRONTAL — BLOODY CARESS",
						conditions = 
						{
							
							{
								"29d892e0-1ecd-ac16-afe5-02b19c9ff1a9",
								true,
							},
							
							{
								"4da208c7-80ce-fcb9-ae2e-dfd3e0127600",
								true,
							},
							
							{
								"babc77cb-b5ca-65ba-80d5-79922ca23279",
								true,
							},
						},
						displayPath = "Sildihn criterion/Trash",
						name = "DODGE FRONTAL — BLOODY CARESS",
						uuid = "3cd4b693-ef8c-88ec-9ea1-8119b417c371",
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
						name = "Sildihn criterion",
						uuid = "f279c76a-8f4a-a3d9-93cf-6c89b0939de5",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Trash",
						uuid = "42284b4a-c829-60dd-a48e-bc6ccbca09c5",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						localMapIDList = 
						{
							1075,
							1076,
						},
						name = "Sil'dihn map",
						uuid = "29d892e0-1ecd-ac16-afe5-02b19c9ff1a9",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						eventArgOptionType = 2,
						eventEntityContentID = 11512,
						name = "[Alert] Sapria",
						uuid = "4da208c7-80ce-fcb9-ae2e-dfd3e0127600",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						eventArgType = 2,
						eventSpellID = 31071,
						name = "Bloody Caress",
						uuid = "babc77cb-b5ca-65ba-80d5-79922ca23279",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Trash",
			eventType = 3,
			name = "[Alert] Sapria - Bloody Caress",
			uuid = "03872596-c9db-7b09-9833-e106567f3015",
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
						name = "Sildihn criterion",
						uuid = "3396cb7b-5a48-62e3-91d7-50a277d0087e",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Trash",
						uuid = "1bd0a640-a843-8534-bd78-6740a41d2093",
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
						alertText = "DODGE FRONTAL — HONEYED FRONT",
						conditions = 
						{
							
							{
								"6340d4e2-fc28-f9af-81fc-1bed8812e755",
								true,
							},
							
							{
								"cc7a793f-0f0c-50ca-8ca6-8ee83cbca28f",
								true,
							},
							
							{
								"ba77ec7d-66ae-0029-83f6-a341e0dc4bbf",
								true,
							},
						},
						displayPath = "Sildihn criterion/Trash",
						name = "DODGE FRONTAL — HONEYED FRONT",
						uuid = "fbbf07ed-b259-7afd-9b9f-375df6f8ee62",
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
						name = "Sildihn criterion",
						uuid = "a59326cc-8610-4309-ba6a-2a681bfb556d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Trash",
						uuid = "a354db6d-1fe0-164c-93d1-868c0b9df3c9",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						localMapIDList = 
						{
							1075,
							1076,
						},
						name = "Sil'dihn map",
						uuid = "6340d4e2-fc28-f9af-81fc-1bed8812e755",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						eventArgOptionType = 2,
						eventEntityContentID = 11511,
						name = "[Alert] Udumbara",
						uuid = "cc7a793f-0f0c-50ca-8ca6-8ee83cbca28f",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						eventArgType = 2,
						eventSpellID = 31069,
						name = "Honeyed Front",
						uuid = "ba77ec7d-66ae-0029-83f6-a341e0dc4bbf",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Trash",
			eventType = 3,
			name = "[Alert] Udumbara - Honeyed Front",
			uuid = "329e7b6d-fd31-8806-9d6b-1c912f48e8b2",
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
						name = "Sildihn criterion",
						uuid = "2e435078-3c5b-1fe6-8c09-0fb84f32498f",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Trash",
						uuid = "b5dfdf6e-99e8-dbc7-8cfd-2761713593a8",
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
						alertText = "DODGE FRONTAL — CREEPING IVY",
						conditions = 
						{
							
							{
								"83bb8aa9-ffa3-b2c3-a9c5-108cad4b7dfd",
								true,
							},
							
							{
								"66fd8e53-cee1-fdc7-bd39-6cfec94b9d16",
								true,
							},
							
							{
								"7d5055b9-eac4-2127-a887-b66fbb886a12",
								true,
							},
						},
						displayPath = "Sildihn criterion/Trash",
						name = "DODGE FRONTAL — CREEPING IVY",
						uuid = "be86a262-e84a-85b4-8e76-7fb822c63a64",
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
						name = "Sildihn criterion",
						uuid = "52182e74-94b5-0de4-b042-1b089bd1c7b2",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Trash",
						uuid = "820102d2-5146-5ec6-9505-55c40517bcdb",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						localMapIDList = 
						{
							1075,
							1076,
						},
						name = "Sil'dihn map",
						uuid = "83bb8aa9-ffa3-b2c3-a9c5-108cad4b7dfd",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						eventArgOptionType = 2,
						eventEntityContentID = 11510,
						name = "[Alert] Kaluk",
						uuid = "66fd8e53-cee1-fdc7-bd39-6cfec94b9d16",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						eventArgType = 2,
						eventSpellID = 31077,
						name = "Creeping Ivy",
						uuid = "7d5055b9-eac4-2127-a887-b66fbb886a12",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Trash",
			eventType = 3,
			name = "[Alert] Kaluk - Creeping Ivy",
			uuid = "127bae9e-4b22-d9b9-b03a-77710eaf8a41",
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
						name = "Sildihn criterion",
						uuid = "75caf4bb-a615-580f-be98-dd0c17238612",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Trash",
						uuid = "c98eea2b-b888-32a3-9718-c0f5ecb794c5",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Alert",
						alertPriority = 3,
						alertScale = 0.89999997615814,
						alertTTS = true,
						alertText = "LOOK AWAY — FROND AFFRONT",
						conditions = 
						{
							
							{
								"62c939ec-8579-7bee-8c63-3375c73e21f5",
								true,
							},
							
							{
								"1c3c7e01-c59e-2f00-9bb7-78f139eaac4c",
								true,
							},
							
							{
								"fa730ddf-95fe-8710-b56a-db35daf78001",
								true,
							},
						},
						displayPath = "Sildihn criterion/Trash",
						name = "LOOK AWAY — FROND AFFRONT",
						uuid = "a10513cf-2a98-77e4-aad8-13e6e480e77b",
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
						name = "Sildihn criterion",
						uuid = "965c048a-2b08-9421-bc1c-23d4e319404d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Trash",
						uuid = "70773bb0-e1f5-08f0-b1e2-1304b78794be",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						localMapIDList = 
						{
							1075,
							1076,
						},
						name = "Sil'dihn map",
						uuid = "62c939ec-8579-7bee-8c63-3375c73e21f5",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						eventArgOptionType = 2,
						eventEntityContentID = 11514,
						name = "[Alert] Belladonna",
						uuid = "1c3c7e01-c59e-2f00-9bb7-78f139eaac4c",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						eventArgType = 2,
						eventSpellID = 31073,
						name = "Frond Affront",
						uuid = "fa730ddf-95fe-8710-b56a-db35daf78001",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Trash",
			eventType = 3,
			name = "[Alert] Belladonna - Frond Affront",
			uuid = "674b2166-1ec7-97a6-b51f-6e6f03bb8f71",
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
						name = "Sildihn criterion",
						uuid = "2232fdd4-ed37-0e1e-a216-70e2b21874fc",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Trash",
						uuid = "6ce6123b-b138-d7f8-81ff-d100dc6a79d4",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Alert",
						alertPriority = 3,
						alertScale = 0.89999997615814,
						alertTTS = true,
						alertText = "LOOK AT CAST — LEFT/RIGHT SWEEP",
						conditions = 
						{
							
							{
								"a37fa924-0e1b-ac5e-9ab0-e14ea3415fd4",
								true,
							},
							
							{
								"d8b5c9f1-3e96-e504-a1ad-48876b81a311",
								true,
							},
							
							{
								"159ca91e-8274-f32f-a37e-7986f711e543",
								true,
							},
						},
						displayPath = "Sildihn criterion/Trash",
						name = "LOOK AT CAST — LEFT/RIGHT SWEEP",
						uuid = "7de56c87-96f4-0ea8-b1ad-adfa65a76877",
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
						name = "Sildihn criterion",
						uuid = "4f5c1908-f47e-33b0-b970-372de2081b13",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Trash",
						uuid = "d8f42226-93cd-8fd8-80ba-cf503beb6c59",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						localMapIDList = 
						{
							1075,
							1076,
						},
						name = "Sil'dihn map",
						uuid = "a37fa924-0e1b-ac5e-9ab0-e14ea3415fd4",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						eventArgOptionType = 2,
						eventEntityContentID = 11510,
						name = "[Alert] Kaluk",
						uuid = "d8b5c9f1-3e96-e504-a1ad-48876b81a311",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Left/Right Sweep",
						spellIDList = 
						{
							31075,
							31076,
						},
						uuid = "159ca91e-8274-f32f-a37e-7986f711e543",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Trash",
			eventType = 3,
			name = "[Alert] Kaluk - Left/Right Sweep",
			uuid = "f0ddd3b3-39ed-32dc-9a2c-e738d8c6f559",
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
						name = "Sildihn criterion",
						uuid = "9aacbb6f-09c1-cfeb-bc00-d60caba16da7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Trash",
						uuid = "a858f59c-2938-dd6a-a1a2-7a5d87755519",
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
						alertText = "DODGE BACK — HONEYED LEFT/RIGHT",
						conditions = 
						{
							
							{
								"0f1b3192-3bac-1079-a181-18da8fa4b714",
								true,
							},
							
							{
								"f65ef2cd-3055-c92d-8e11-9c78d1b650c9",
								true,
							},
							
							{
								"e5f7ba28-ae6c-8b58-958b-0a43049a6616",
								true,
							},
						},
						displayPath = "Sildihn criterion/Trash",
						name = "DODGE BACK — HONEYED LEFT/RIGHT",
						uuid = "d0d25632-1c63-14d0-a8e9-36e671c5b014",
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
						name = "Sildihn criterion",
						uuid = "5d2ef2f5-f4f3-1c93-b26a-aedd1c688670",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Trash",
						uuid = "52056840-1fda-638e-bd82-835e5186b79f",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						localMapIDList = 
						{
							1075,
							1076,
						},
						name = "Sil'dihn map",
						uuid = "0f1b3192-3bac-1079-a181-18da8fa4b714",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						eventArgOptionType = 2,
						eventEntityContentID = 11511,
						name = "[Alert] Udumbara",
						uuid = "f65ef2cd-3055-c92d-8e11-9c78d1b650c9",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Trash",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Honeyed Left/Right",
						spellIDList = 
						{
							31067,
							31068,
						},
						uuid = "e5f7ba28-ae6c-8b58-958b-0a43049a6616",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Trash",
			eventType = 3,
			name = "[Alert] Udumbara - Honeyed Left/Right",
			uuid = "fb86e09b-9ac4-d3ed-87dc-4bda161b216d",
			version = 2,
		},
	},
	
	{
		data = 
		{
			displayPath = "Sildihn criterion",
			name = "Silkie",
			uuid = "8adb4d25-a93b-da04-b8cc-f0a0c850fb7e",
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
						name = "Sildihn criterion",
						uuid = "a8bcd692-b001-9db5-aae4-be80cbf0de3a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "cb60a29f-0184-2bf4-87f1-fc634bba76e5",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "local player = TensorCore.mGetPlayer()\nif not player or not player.pos or not eventArgs then\n    self.used = true\n    return\nend\nlocal puff = TensorCore.mGetEntity(eventArgs.sourceEntityID)\nif not puff then\n    self.used = true\n    return\nend\nlocal _, _, puffKind = Argus.getEntityAuras(puff)\nif puffKind ~= 1512 then\n    self.used = true\n    return\nend\nlocal centerX = 0\nlocal centerZ = 0\nlocal centerCount = 0\nlocal puffList = TensorCore.getEntityGroupList(\"ContentID\", {contentid = 11370})\nfor _, candidate in pairs(puffList or {}) do\n    if candidate and candidate.pos and Argus.isEntityVisible(candidate) then\n        centerX = centerX + candidate.pos.x\n        centerZ = centerZ + candidate.pos.z\n        centerCount = centerCount + 1\n    end\nend\nif centerCount > 0 then\n    centerX = centerX / centerCount\n    centerZ = centerZ / centerCount\nelse\n    local bossList = TensorCore.getEntityGroupList(\"ContentID\", {contentid = 11369})\n    local boss = nil\n    for _, candidate in pairs(bossList or {}) do\n        if candidate and candidate.pos then boss = candidate break end\n    end\n    if not boss then self.used = true return end\n    centerX = boss.pos.x\n    centerZ = boss.pos.z\nend\nlocal target = {x = centerX, y = player.pos.y, z = centerZ}\nlocal distance = TensorCore.getDistance2d(player.pos, target)\nif not distance or distance < 0.25 then\n    self.used = true\n    return\nend\nlocal heading = TensorCore.getHeadingToTarget(player.pos, target)\nlocal tipLength = math.min(2.2, math.max(1.2, distance * 0.35))\nlocal baseLength = math.max(0.15, distance - tipLength)\nlocal drawer = TensorCore.getCachedDrawer(0xFF66FF66, 0xFF30B830, 0xFF188018, 0xFFFFFFFF, 3)\ndrawer:addTimedArrow(6500, player.pos.x, player.pos.y, player.pos.z, heading, baseLength, 1.0, tipLength, 2.4, 0, false, Argus2.RenderFlags.FLAG_RENDER_OVERLAY)\nself.used = true",
						conditions = 
						{
							
							{
								"be87a283-e664-5031-8f86-84b49891a62a",
								true,
							},
							
							{
								"5b25f2ac-2339-aa08-9a7d-4b04b8da9dcb",
								true,
							},
						},
						displayPath = "Sildihn criterion/Silkie",
						name = "Green tail donut arrow",
						uuid = "e5d32b9c-bb5d-6401-adf0-66a89ef67566",
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
						name = "Sildihn criterion",
						uuid = "ba8d07ec-6c9a-8f99-be8f-7e28bfe687c3",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "82b7337c-a64f-6c0c-bc6e-c334ab52a766",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Silkie",
						localMapIDList = 
						{
							1075,
							1076,
						},
						name = "Sil'dihn map",
						uuid = "be87a283-e664-5031-8f86-84b49891a62a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local player = TensorCore.mGetPlayer()\nif not player or not eventArgs or eventArgs.sourceEntityContentID ~= 11370 or eventArgs.newTetherID ~= 216 or eventArgs.newTargetID ~= player.id then\n    return false\nend\nlocal puff = TensorCore.mGetEntity(eventArgs.sourceEntityID)\nif not puff then\n    return false\nend\nlocal _, _, puffKind = Argus.getEntityAuras(puff)\nreturn puffKind == 1512",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Silkie",
						name = "[Draw] Silkie - Green Tail Donut Arrow tether",
						uuid = "5b25f2ac-2339-aa08-9a7d-4b04b8da9dcb",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Silkie",
			eventType = 15,
			name = "[Draw] Silkie - Green Tail Donut Arrow",
			uuid = "80ad918e-7d90-430c-8811-9210e85b2fe1",
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
						name = "Sildihn criterion",
						uuid = "75c4e6e2-1658-d54e-b30e-d95928148ae8",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "ae52bc0f-4b33-2b10-a7a0-7f53b3d483b8",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Alert",
						alertPriority = 3,
						alertScale = 0.89999997615814,
						alertTTS = true,
						alertText = "SPREAD — YELLOW TAIL",
						conditions = 
						{
							
							{
								"a12b1b57-d410-d379-8869-ac8ccae575d9",
								true,
							},
							
							{
								"35c5a2dd-1f63-c81c-81be-086ca1b6dd68",
								true,
							},
						},
						displayPath = "Sildihn criterion/Silkie",
						name = "SPREAD — YELLOW TAIL",
						uuid = "4db2cff2-e1c5-eb71-b621-e9f0ca857803",
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
						name = "Sildihn criterion",
						uuid = "350e6771-982c-448e-8464-e94bef89aabc",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "7915df52-3c58-d7bd-a743-29f89d530bb6",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Silkie",
						localMapIDList = 
						{
							1075,
							1076,
						},
						name = "Sil'dihn map",
						uuid = "a12b1b57-d410-d379-8869-ac8ccae575d9",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local player = TensorCore.mGetPlayer()\nif not player or not eventArgs or eventArgs.sourceEntityContentID ~= 11370 or eventArgs.newTetherID ~= 216 or eventArgs.newTargetID ~= player.id then\n    return false\nend\nlocal puff = TensorCore.mGetEntity(eventArgs.sourceEntityID)\nif not puff then\n    return false\nend\nlocal _, _, puffKind = Argus.getEntityAuras(puff)\nreturn puffKind == 1510",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Silkie",
						name = "[Alert] Silkie - Yellow Tail Spread tether",
						uuid = "35c5a2dd-1f63-c81c-81be-086ca1b6dd68",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Silkie",
			eventType = 15,
			name = "[Alert] Silkie - Yellow Tail Spread",
			uuid = "96e9b163-e2e6-299e-b1a8-ef8c0e83db71",
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
						name = "Sildihn criterion",
						uuid = "24f4e34c-10f9-0caa-b81d-f1373ce1baba",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "06e3ffdc-af9e-ce84-b1af-d651db521a44",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Alert",
						alertPriority = 3,
						alertScale = 0.89999997615814,
						alertTTS = true,
						alertText = "JUMP NOW — BLUE TAIL / FREEZE",
						conditions = 
						{
							
							{
								"af8b443b-a4a9-e20f-87fb-74096a423eae",
								true,
							},
							
							{
								"51ebaccb-a66b-e713-8581-1be4732dc95c",
								true,
							},
						},
						displayPath = "Sildihn criterion/Silkie",
						name = "JUMP NOW — BLUE TAIL / FREEZE",
						uuid = "33bb5d01-f42b-d2d0-abbf-afa5e19929bf",
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
						name = "Sildihn criterion",
						uuid = "38f9e067-d3e9-e067-8953-3cb5e1c053b9",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "c08eb55e-3a4c-d1cb-b5bc-00ce23cf4aa7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Silkie",
						localMapIDList = 
						{
							1075,
							1076,
						},
						name = "Sil'dihn map",
						uuid = "af8b443b-a4a9-e20f-87fb-74096a423eae",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local player = TensorCore.mGetPlayer()\nif not player or not eventArgs or eventArgs.sourceEntityContentID ~= 11370 or eventArgs.newTetherID ~= 216 or eventArgs.newTargetID ~= player.id then\n    return false\nend\nlocal puff = TensorCore.mGetEntity(eventArgs.sourceEntityID)\nif not puff then\n    return false\nend\nlocal _, _, puffKind = Argus.getEntityAuras(puff)\nreturn puffKind == 1511",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Silkie",
						name = "[Alert] Silkie - Blue Tail Freeze tether",
						uuid = "51ebaccb-a66b-e713-8581-1be4732dc95c",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Silkie",
			eventType = 15,
			name = "[Alert] Silkie - Blue Tail Freeze",
			uuid = "51cffc14-8506-93fc-b6f6-a5a641de9d7c",
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
						name = "Sildihn criterion",
						uuid = "629e9f74-e826-f158-96e5-fd23e459c086",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "3d6f6746-4b76-f7d8-ba33-9b79a257c47a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "local player = TensorCore.mGetPlayer()\nif not player or not player.pos or not eventArgs then\n    self.used = true\n    return\nend\n\nlocal puff = TensorCore.mGetEntity(eventArgs.sourceEntityID)\nif not puff or not puff.pos then\n    self.used = true\n    return\nend\n\nlocal bossList = TensorCore.getEntityGroupList(\"ContentID\", {contentid = 11369})\nlocal boss = nil\nfor _, candidate in pairs(bossList or {}) do\n    if candidate and candidate.pos then\n        boss = candidate\n        break\n    end\nend\nif not boss then\n    self.used = true\n    return\nend\n\nlocal _, bossTail = Argus.getEntityAuras(boss)\nif bossTail ~= 1501 and bossTail ~= 1502 then\n    self.used = true\n    return\nend\n\nlocal _, _, puffKind = Argus.getEntityAuras(puff)\n\nlocal centerX = 0\nlocal centerZ = 0\nlocal centerCount = 0\nlocal puffList = TensorCore.getEntityGroupList(\"ContentID\", {contentid = 11370})\nfor _, candidate in pairs(puffList or {}) do\n    if candidate and candidate.pos and Argus.isEntityVisible(candidate) then\n        local _, _, candidateKind = Argus.getEntityAuras(candidate)\n        if candidateKind == 1510 or candidateKind == 1511 then\n            centerX = centerX + candidate.pos.x\n            centerZ = centerZ + candidate.pos.z\n            centerCount = centerCount + 1\n        end\n    end\nend\n\nif centerCount > 0 then\n    centerX = centerX / centerCount\n    centerZ = centerZ / centerCount\nelse\n    centerX = boss.pos.x\n    centerZ = boss.pos.z\nend\n\nlocal dx = puff.pos.x - centerX\nlocal dz = puff.pos.z - centerZ\nlocal radialDistance = math.sqrt(dx * dx + dz * dz)\nif radialDistance < 0.5 then\n    self.used = true\n    return\nend\n\nlocal edgeRadius = 18.0\nlocal targetX\nlocal targetZ\n\nlocal function projectToSquareEdge(x, z)\n    local dominant = math.max(math.abs(x), math.abs(z))\n    if dominant < 0.5 then\n        return nil, nil\n    end\n    local scale = edgeRadius / dominant\n    return centerX + x * scale, centerZ + z * scale\nend\n\nif bossTail == 1501 then\n    -- Blue tail: both puff colours are sent straight out to the nearest square edge.\n    targetX, targetZ = projectToSquareEdge(dx, dz)\nelseif puffKind == 1511 then\n    -- Green tail, blue puff: use a cardinal edge.\n    if math.abs(dx) >= math.abs(dz) then\n        targetX = centerX + (dx >= 0 and edgeRadius or -edgeRadius)\n        targetZ = centerZ\n    else\n        targetX = centerX\n        targetZ = centerZ + (dz >= 0 and edgeRadius or -edgeRadius)\n    end\nelseif puffKind == 1510 then\n    -- Green tail, yellow puff: use the closest square edge in its current direction.\n    targetX, targetZ = projectToSquareEdge(dx, dz)\nelse\n    self.used = true\n    return\nend\n\nif not targetX or not targetZ then\n    self.used = true\n    return\nend\n\nlocal source = player.pos\nlocal target = {x = targetX, y = source.y, z = targetZ}\nlocal distance = TensorCore.getDistance2d(source, target)\nif distance > 0.25 then\n    local heading = TensorCore.getHeadingToTarget(source, target)\n    local tipLength = math.min(2.4, distance * 0.35)\n    local baseLength = math.max(0.1, distance - tipLength)\n    local drawer = TensorCore.getCachedDrawer(\n        0xFF66CCFF, 0xFF2080FF, 0xFF1060AA, 0xFFFFFFFF, 3\n    )\n    drawer:addTimedArrow(\n        6500,\n        source.x, source.y, source.z,\n        heading,\n        baseLength, 1.1, tipLength, 2.6,\n        0, false, Argus2.RenderFlags.FLAG_RENDER_OVERLAY\n    )\nend\n\nself.used = true",
						conditions = 
						{
							
							{
								"33195c54-fa29-cee0-b7c6-810e8e371873",
								true,
							},
						},
						displayPath = "Sildihn criterion/Silkie",
						name = "Silkie Fresh Puff - move tethered puff",
						uuid = "93a89c94-57ba-248e-94b4-07b439cea969",
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
						name = "Sildihn criterion",
						uuid = "6d74e28b-23ec-08ae-8555-b1c114806d6f",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "8c4ca671-2756-f7f4-9592-bcc005232a5c",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local player = TensorCore.mGetPlayer()\nif not player or not eventArgs or eventArgs.sourceEntityContentID ~= 11370 or eventArgs.newTetherID ~= 216 or eventArgs.newTargetID ~= player.id then\n    return false\nend\nlocal puff = TensorCore.mGetEntity(eventArgs.sourceEntityID)\nif not puff then\n    return false\nend\nlocal _, _, puffKind = Argus.getEntityAuras(puff)\nreturn puffKind ~= 1512",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Silkie",
						name = "Silken Puff tether to me",
						uuid = "33195c54-fa29-cee0-b7c6-810e8e371873",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Silkie",
			eventType = 15,
			name = "[Draw] Silkie Fresh Puff - Tail Guidance",
			uuid = "48dc1812-9b1b-1917-a405-b34932d71284",
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
						name = "Sildihn criterion",
						uuid = "88ba406b-29ae-33ef-a218-a54e067528c9",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "2a9fe53d-f95d-da26-9879-ad18e95b53b4",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Alert",
						alertPriority = 3,
						alertScale = 0.89999997615814,
						alertTTS = true,
						alertText = "MOVE IN — GREEN TAIL / DONUT",
						conditions = 
						{
							
							{
								"7d0c26fb-d642-f6d4-807f-159ecbdf7e97",
								true,
							},
							
							{
								"17426275-395e-3eb3-889e-6f7ee7771336",
								true,
							},
						},
						displayPath = "Sildihn criterion/Silkie",
						name = "MOVE IN — GREEN TAIL / DONUT",
						uuid = "c5de5b3f-0565-cfa3-afe8-8f7e2145fd71",
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
						name = "Sildihn criterion",
						uuid = "d8d92d15-3633-84ec-af7a-df272d3199b8",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "ae97a7b1-517a-5f9a-863e-e9e621cba5c6",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Silkie",
						localMapIDList = 
						{
							1075,
							1076,
						},
						name = "Sil'dihn map",
						uuid = "7d0c26fb-d642-f6d4-807f-159ecbdf7e97",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local player = TensorCore.mGetPlayer()\nif not player or not eventArgs or eventArgs.sourceEntityContentID ~= 11370 or eventArgs.newTetherID ~= 216 or eventArgs.newTargetID ~= player.id then\n    return false\nend\nlocal puff = TensorCore.mGetEntity(eventArgs.sourceEntityID)\nif not puff then\n    return false\nend\nlocal _, _, puffKind = Argus.getEntityAuras(puff)\nreturn puffKind == 1512",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Silkie",
						name = "[Alert] Silkie - Green Tail Donut tether",
						uuid = "17426275-395e-3eb3-889e-6f7ee7771336",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Silkie",
			eventType = 15,
			name = "[Alert] Silkie - Green Tail Donut",
			uuid = "bf8ccc1c-f21d-d94f-9c35-3838fd4da295",
			version = 2,
		},
	},
	
	{
		data = 
		{
			displayPath = "Sildihn criterion/Silkie",
			name = "Fresh Puff 1",
			uuid = "e2c73bc9-9e5a-c302-81c6-d57ae3a662f6",
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
						name = "Sildihn criterion",
						uuid = "dd973da2-fb56-1fed-9c8a-448469ebc463",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "612bdd2b-d193-fdfa-8b9d-59eb2cbce4ed",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Silkie",
						name = "Fresh Puff 1",
						uuid = "1543dcf4-e5ee-c33f-a446-65842c77f34b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "local puffs = TensorCore.getEntityGroupList(\"ContentID\", {contentid = 11370})\nlocal flags = Argus2.RenderFlags.FLAG_RENDER_OVERLAY\nfor _, puff in pairs(puffs or {}) do\n    if puff and puff.pos and puff.modelID == 14835 and Argus.isEntityVisible(puff) then\n        local _, _, kind = Argus.getEntityAuras(puff)\n        local drawer\n        if kind == 1510 then\n            drawer = TensorCore.getCachedDrawer(0xFFFFFF00, 0xFFFFFF00, 0xFFCC9900, 0xFFFFFFFF, 2.0, 0, flags)\n        elseif kind == 1511 then\n            drawer = TensorCore.getCachedDrawer(0xFF4D7FFF, 0xFF4D7FFF, 0xFF2040CC, 0xFFFFFFFF, 2.0, 0, flags)\n        elseif kind == 1512 then\n            drawer = TensorCore.getCachedDrawer(0xFF33DD66, 0xFF33DD66, 0xFF168A3A, 0xFFFFFFFF, 2.0, 0, flags)\n        end\n        if drawer then\n            drawer:addTimedCircle(12000, puff.pos.x, puff.pos.y, puff.pos.z, 2.8, 0, false, true, flags)\n        end\n    end\nend\nself.used = true",
						conditions = 
						{
							
							{
								"27e03684-4be4-e52c-8e20-354bd68998bb",
								true,
							},
						},
						displayPath = "Sildihn criterion/Silkie/Fresh Puff 1",
						name = "Draw Fresh Puff 1 pom colours",
						uuid = "5bb31241-8132-fd51-9b84-b56ad3a732a5",
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
						name = "Sildihn criterion",
						uuid = "3f1241eb-8eda-6b43-b3f4-fbad225e076e",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "5bf290c6-38c2-e798-81da-fcd955e14608",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Silkie",
						name = "Fresh Puff 1",
						uuid = "cc88eff7-5a2d-9a71-9fc7-ffaba9a9c13e",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local event = eventArgs\nif not event or event.entityContentID ~= 11370 then\n    return false\nend\nlocal changed = event.newActiveAura2\nif changed ~= 1510 and changed ~= 1511 and changed ~= 1512 then\n    return false\nend\nlocal count = 0\nlocal puffs = TensorCore.getEntityGroupList(\"ContentID\", {contentid = 11370})\nfor _, puff in pairs(puffs or {}) do\n    if puff and puff.pos and puff.modelID == 14835 and Argus.isEntityVisible(puff) then\n        local _, _, kind = Argus.getEntityAuras(puff)\n        if kind == 1510 or kind == 1511 or kind == 1512 then\n            count = count + 1\n        end\n    end\nend\nreturn count == 3",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Silkie/Fresh Puff 1",
						name = "Fresh Puff 1 has three visible poms",
						uuid = "27e03684-4be4-e52c-8e20-354bd68998bb",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Silkie/Fresh Puff 1",
			eventType = 25,
			name = "[Draw] Silkie Fresh Puff 1 - Pom Colours",
			uuid = "3c4dbd3c-695a-5403-beb5-8b4734e5886d",
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
						name = "Sildihn criterion",
						uuid = "b2f9c2a6-f35f-401b-b02d-d38ed9b69b6e",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "e0e3615b-f513-b234-bebf-a014b92e6612",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Silkie",
						name = "Fresh Puff 1",
						uuid = "39c1bfad-f493-fd7e-98bb-3ac55647dcbb",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "local player = TensorCore.mGetPlayer()\nlocal boss = eventArgs and TensorCore.mGetEntity(eventArgs.entityID)\nif not player or not player.pos or not boss or not boss.pos then\n    self.used = true\n    return\nend\nlocal dx = boss.pos.x - player.pos.x\nlocal dz = boss.pos.z - player.pos.z\nlocal distance = math.sqrt(dx * dx + dz * dz)\nif distance > 0.25 then\n    local heading = TensorCore.getHeadingToTarget(player.pos, boss.pos)\n    local tipLength = math.min(2.4, distance * 0.35)\n    local baseLength = math.max(0.1, distance - tipLength)\n    local drawer = TensorCore.getCachedDrawer(0xFFFFFFFF, 0xFFFFFFFF, 0xFFB8B8B8, 0xFFFFFFFF, 2.2, 0, Argus2.RenderFlags.FLAG_RENDER_OVERLAY)\n    drawer:addTimedArrow(7000, player.pos.x, player.pos.y, player.pos.z, heading, baseLength, 1.2, tipLength, 2.8, 0, false, Argus2.RenderFlags.FLAG_RENDER_OVERLAY)\nend\nlocal puffs = TensorCore.getEntityGroupList(\"ContentID\", {contentid = 11370})\nfor _, puff in pairs(puffs or {}) do\n    if puff and puff.pos and puff.modelID == 14835 and Argus.isEntityVisible(puff) then\n        local _, _, kind = Argus.getEntityAuras(puff)\n        local drawer\n        if kind == 1510 then\n            drawer = TensorCore.getCachedDrawer(0xFFFFFF00, 0xFFFFFF00, 0xFFCC9900, 0xFFFFFFFF, 1.5, 0, Argus2.RenderFlags.FLAG_RENDER_OVERLAY)\n        elseif kind == 1511 then\n            drawer = TensorCore.getCachedDrawer(0xFF4D7FFF, 0xFF4D7FFF, 0xFF2040CC, 0xFFFFFFFF, 1.5, 0, Argus2.RenderFlags.FLAG_RENDER_OVERLAY)\n        elseif kind == 1512 then\n            drawer = TensorCore.getCachedDrawer(0xFF33DD66, 0xFF33DD66, 0xFF168A3A, 0xFFFFFFFF, 1.5, 0, Argus2.RenderFlags.FLAG_RENDER_OVERLAY)\n        end\n        if drawer then\n            drawer:addTimedCircle(7000, puff.pos.x, puff.pos.y, puff.pos.z, 2.8, 0, false, true, Argus2.RenderFlags.FLAG_RENDER_OVERLAY)\n        end\n    end\nend\nself.used = true",
						conditions = 
						{
							
							{
								"32704b00-2603-fe60-a662-9e9f26055051",
								true,
							},
						},
						displayPath = "Sildihn criterion/Silkie/Fresh Puff 1",
						name = "Arrow to Silkie for Fresh Puff 1 stack",
						uuid = "9930bbca-9ab5-8e8d-8ca1-ce06fe001b73",
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
						name = "Sildihn criterion",
						uuid = "d9c8fd48-7e49-b6d3-91ad-74fdbfadd922",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "1e63de0a-782a-681c-a8b6-c21987982731",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Silkie",
						name = "Fresh Puff 1",
						uuid = "7c1b5348-51ab-be78-8f94-8fe6fb2c09e5",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local event = eventArgs\nif not event or event.entityContentID ~= 11369 or event.spellID ~= 30551 then\n    return false\nend\nlocal count = 0\nlocal puffs = TensorCore.getEntityGroupList(\"ContentID\", {contentid = 11370})\nfor _, puff in pairs(puffs or {}) do\n    if puff and puff.pos and puff.modelID == 14835 and Argus.isEntityVisible(puff) then\n        local _, _, kind = Argus.getEntityAuras(puff)\n        if kind == 1510 or kind == 1511 or kind == 1512 then\n            count = count + 1\n        end\n    end\nend\nreturn count == 3",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Silkie/Fresh Puff 1",
						name = "Fresh Puff 1 Bracing Suds",
						uuid = "32704b00-2603-fe60-a662-9e9f26055051",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Silkie/Fresh Puff 1",
			eventType = 3,
			name = "[Draw] Silkie Fresh Puff 1 - Stack Behind Boss",
			uuid = "4c336e4e-d0ec-6755-be1f-11de712696f5",
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
						name = "Sildihn criterion",
						uuid = "8afcc7ed-8213-7fc9-a1bf-b748e188660b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "453fb5b1-633e-3dca-8e90-20da1a861ec6",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Silkie",
						name = "Fresh Puff 1",
						uuid = "7c196ea6-eeff-551d-840b-b9193ed6c539",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "local player = TensorCore.mGetPlayer()\nif not player or not player.pos then\n    self.used = true\n    return\nend\nlocal target\nlocal targetKind\nlocal puffs = TensorCore.getEntityGroupList(\"ContentID\", {contentid = 11370})\nfor _, puff in pairs(puffs or {}) do\n    if puff and puff.pos and puff.modelID == 14835 and Argus.isEntityVisible(puff) then\n        local _, _, kind = Argus.getEntityAuras(puff)\n        if kind == 1510 or kind == 1511 then\n            target = puff\n            targetKind = kind\n            break\n        end\n    end\nend\nif not target or not target.pos then\n    self.used = true\n    return\nend\nlocal distance = TensorCore.getDistance2d(player.pos, target.pos)\nif distance and distance > 0.25 then\n    local heading = TensorCore.getHeadingToTarget(player.pos, target.pos)\n    local tipLength = math.min(2.8, distance * 0.4)\n    local baseLength = math.max(0.1, distance - tipLength)\n    local drawer\n    if targetKind == 1510 then\n        drawer = TensorCore.getCachedDrawer(0xFFFFFF00, 0xFFFFFF00, 0xFFCC9900, 0xFFFFFFFF, 2.4, 0, Argus2.RenderFlags.FLAG_RENDER_OVERLAY)\n    else\n        drawer = TensorCore.getCachedDrawer(0xFF66AAFF, 0xFF66AAFF, 0xFF2040CC, 0xFFFFFFFF, 2.4, 0, Argus2.RenderFlags.FLAG_RENDER_OVERLAY)\n    end\n    drawer:addTimedArrow(7500, player.pos.x, player.pos.y, player.pos.z, heading, baseLength, 1.4, tipLength, 3.0, 0, false, Argus2.RenderFlags.FLAG_RENDER_OVERLAY)\nend\nlocal markerDrawer\nif targetKind == 1510 then\n    markerDrawer = TensorCore.getCachedDrawer(0xFFFFFF00, 0xFFFFFF00, 0xFFCC9900, 0xFFFFFFFF, 2.0, 0, Argus2.RenderFlags.FLAG_RENDER_OVERLAY)\nelse\n    markerDrawer = TensorCore.getCachedDrawer(0xFF66AAFF, 0xFF66AAFF, 0xFF2040CC, 0xFFFFFFFF, 2.0, 0, Argus2.RenderFlags.FLAG_RENDER_OVERLAY)\nend\nmarkerDrawer:addTimedCircle(7500, target.pos.x, target.pos.y, target.pos.z, 3.4, 0, false, true, Argus2.RenderFlags.FLAG_RENDER_OVERLAY)\nself.used = true",
						conditions = 
						{
							
							{
								"0eb8e1c1-9755-216e-a799-037630da66c9",
								true,
							},
						},
						displayPath = "Sildihn criterion/Silkie/Fresh Puff 1",
						name = "Arrow to remaining non-green pom",
						uuid = "ae0858b1-0ec2-f7c0-a900-6150320b8d2a",
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
						name = "Sildihn criterion",
						uuid = "970a79fa-0daf-68e3-b00b-13c6f0b6e05c",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "7830e464-5e30-f4d7-bb54-7f9e33643806",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Silkie",
						name = "Fresh Puff 1",
						uuid = "0e99b6f8-2c63-7a5a-b849-2a341e52a06d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local event = eventArgs\nif not event or event.entityContentID ~= 11369 or event.spellID ~= 30558 then\n    return false\nend\nlocal count = 0\nlocal puffs = TensorCore.getEntityGroupList(\"ContentID\", {contentid = 11370})\nfor _, puff in pairs(puffs or {}) do\n    if puff and puff.pos and puff.modelID == 14835 and Argus.isEntityVisible(puff) then\n        local _, _, kind = Argus.getEntityAuras(puff)\n        if kind == 1510 or kind == 1511 or kind == 1512 then\n            count = count + 1\n        end\n    end\nend\nreturn count == 3",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Silkie/Fresh Puff 1",
						name = "Fresh Puff 1 Slippery Soap",
						uuid = "0eb8e1c1-9755-216e-a799-037630da66c9",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Silkie/Fresh Puff 1",
			eventType = 3,
			name = "[Draw] Silkie Fresh Puff 1 - Slippery Soap Target",
			uuid = "c2096eda-90b4-d3ad-9287-5b3e2507c243",
			version = 2,
		},
	},
	
	{
		data = 
		{
			displayPath = "Sildihn criterion",
			name = "Zeless Gah",
			uuid = "9f153ed9-895f-e4f6-9d5c-5f6965d78911",
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
						name = "Sildihn criterion",
						uuid = "78459d9c-df96-af7b-8c12-fcef4932fb32",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Zeless Gah",
						uuid = "8a4351d1-5e30-7dd0-bbd3-423a1b85f39a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "local state = data.zeless_infern_brand3\nif not state then\n    state = {}\n    data.zeless_infern_brand3 = state\nend\n\nif state.second_drawn then\n    self.used = true\n    return\nend\n\nlocal player = TensorCore.mGetPlayer()\nif not player or not player.pos then\n    self.used = true\n    return\nend\n\nlocal centerX = 289.0\nlocal centerZ = -105.0\nlocal source = {\n    x = player.pos.x,\n    y = player.pos.y,\n    z = player.pos.z\n}\nlocal isNorth\nif state.first_is_north ~= nil then\n    isNorth = not state.first_is_north\nelse\n    isNorth = player.pos.z < centerZ\nend\nlocal target = {\n    x = centerX,\n    y = player.pos.y,\n    z = isNorth and -119.0 or -91.0\n}\nlocal distance = TensorCore.getDistance2d(source, target)\nif not distance or distance < 0.5 then\n    state.second_drawn = true\n    self.used = true\n    return\nend\n\nlocal heading = TensorCore.getHeadingToTarget(source, target)\nlocal tipLength = math.min(2.5, math.max(1.5, distance * 0.35))\nlocal baseLength = math.max(0.5, distance - tipLength)\nlocal scale = math.min(1.4, math.max(0.7, distance / 10.0))\nlocal drawer = TensorCore.getCachedDrawer(\n    0xFFFFFFFF,\n    0xFF80FF80,\n    0xFF22AA22,\n    0xFFFFFFFF,\n    2\n)\ndrawer:addTimedArrow(\n    5500,\n    source.x, source.y, source.z,\n    heading,\n    baseLength, 0.65 * scale,\n    tipLength, 1.6 * scale,\n    0, false, Argus2.RenderFlags.FLAG_RENDER_OVERLAY\n)\nAnyoneCore.addTimedWorldText(\n    5500,\n    \"JP BAIT 2\",\n    target,\n    0xFF80FF80,\n    true,\n    1.4\n)\n\nstate.second_drawn = true\nself.used = true",
						conditions = 
						{
							
							{
								"a821814a-8005-532a-a04b-1eaf39654f34",
								true,
							},
							
							{
								"faf56e8d-d9eb-bbc8-b15a-15e6e1baccc4",
								true,
							},
							
							{
								"18406b71-c306-b716-8b57-4fa6aa8bc3d0",
								true,
							},
						},
						displayPath = "Sildihn criterion/Zeless Gah",
						name = "JP second bait arrow",
						uuid = "6bc521d5-3139-c1d9-b9b9-c304059b51ab",
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
						name = "Sildihn criterion",
						uuid = "b02b01b5-29fe-2950-be7c-97b27164f098",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Zeless Gah",
						uuid = "5f826a77-8f5d-38e1-85ff-5b486b2cadca",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless portal caster",
						uuid = "a821814a-8005-532a-a04b-1eaf39654f34",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29845,
						name = "Portal activation",
						uuid = "faf56e8d-d9eb-bbc8-b15a-15e6e1baccc4",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Zeless Gah",
						eventArgOptionType = 2,
						eventArgType = 3,
						eventTargetContentID = 11394,
						name = "Red portal wave",
						uuid = "18406b71-c306-b716-8b57-4fa6aa8bc3d0",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Zeless Gah",
			eventType = 2,
			name = "[Draw] Zeless Infern Brand 3 - JP Second Bait",
			uuid = "ce141ded-b17b-4abd-a555-c842679f94d8",
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
						name = "Sildihn criterion",
						uuid = "516fa6ef-fb36-4517-8fce-66736bd0e581",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Zeless Gah",
						uuid = "8fe01453-89b5-e927-aa03-2f77e48dd636",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "local state = data.zeless_infern_brand2\nif not state then\n    state = {}\n    data.zeless_infern_brand2 = state\nend\n\nif state.first_cut_shown then\n    self.used = true\n    return\nend\n\nlocal font = TensorCore.mGetEntity(eventArgs.entityID)\nif not font or not font.pos then\n    self.used = true\n    return\nend\n\nlocal centerX = 289.0\nlocal centerZ = -105.0\nlocal dx = font.pos.x - centerX\nlocal dz = font.pos.z - centerZ\n\nlocal firstText\nlocal firstColor\nif math.abs(dx) > math.abs(dz) then\n    firstText = \"CUT BLUE FIRST\"\n    firstColor = 0xFF4080FF\nelse\n    firstText = \"CUT RED FIRST\"\n    firstColor = 0xFFFF4040\nend\n\nlocal textPosition = {\n    x = centerX,\n    y = font.pos.y + 3.0,\n    z = centerZ\n}\nAnyoneCore.addTimedWorldText(15000, firstText, textPosition, firstColor, true, 1.5)\nstate.first_cut_shown = true\nself.used = true",
						conditions = 
						{
							
							{
								"86edd801-4756-38d9-936e-f373f41566bb",
								true,
							},
						},
						displayPath = "Sildihn criterion/Zeless Gah",
						name = "First Cut Direction",
						uuid = "00e49941-8501-e17e-a7fe-ebf0ff7c63bd",
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
						name = "Sildihn criterion",
						uuid = "312c036e-362b-4bcd-a62c-301c7048e8cd",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Zeless Gah",
						uuid = "51f6d061-1830-c147-95a6-225c2c92557d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11397,
						name = "Zeless Arcane Font",
						uuid = "86edd801-4756-38d9-936e-f373f41566bb",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Zeless Gah",
			eventType = 5,
			name = "[Draw] Zeless Infern Brand 2 - First Cut",
			throttleTime = 15000,
			uuid = "e4078392-caa9-b6ce-b40b-6c0382250f13",
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
						name = "Sildihn criterion",
						uuid = "48e1b7a5-15b0-ef4a-b25d-9c63cdf8cb36",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Zeless Gah",
						uuid = "a7d18132-e554-549f-82b8-1161e56b5dcf",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "local state = data.zeless_infern_brand3\nif not state then\n    state = {}\n    data.zeless_infern_brand3 = state\nend\n\nif state.first_drawn then\n    self.used = true\n    return\nend\n\nlocal player = TensorCore.mGetPlayer()\nif not player or not player.pos then\n    self.used = true\n    return\nend\n\nlocal centerX = 289.0\nlocal centerZ = -105.0\nlocal source = {\n    x = player.pos.x,\n    y = player.pos.y,\n    z = player.pos.z\n}\nlocal isNorth = player.pos.z < centerZ\nlocal target = {\n    x = centerX,\n    y = player.pos.y,\n    z = isNorth and -119.0 or -91.0\n}\nlocal distance = TensorCore.getDistance2d(source, target)\nif not distance or distance < 0.5 then\n    state.first_drawn = true\n    state.first_is_north = isNorth\n    self.used = true\n    return\nend\n\nlocal heading = TensorCore.getHeadingToTarget(source, target)\nlocal tipLength = math.min(2.5, math.max(1.5, distance * 0.35))\nlocal baseLength = math.max(0.5, distance - tipLength)\nlocal scale = math.min(1.4, math.max(0.7, distance / 10.0))\nlocal drawer = TensorCore.getCachedDrawer(\n    0xFFFFFFFF,\n    0xFF80FF80,\n    0xFF22AA22,\n    0xFFFFFFFF,\n    2\n)\ndrawer:addTimedArrow(\n    5500,\n    source.x, source.y, source.z,\n    heading,\n    baseLength, 0.65 * scale,\n    tipLength, 1.6 * scale,\n    0, false, Argus2.RenderFlags.FLAG_RENDER_OVERLAY\n)\nAnyoneCore.addTimedWorldText(\n    5500,\n    \"JP BAIT 1\",\n    target,\n    0xFF80FF80,\n    true,\n    1.4\n)\nAnyoneCore.addTimedWorldText(\n    3000,\n    \"HOLD FOR TELEPORT\",\n    source,\n    0xFFFFFFFF,\n    true,\n    1.0\n)\n\nstate.first_drawn = true\nstate.first_is_north = isNorth\nself.used = true",
						conditions = 
						{
							
							{
								"945141c1-ff03-f8de-9200-5454e359f2ec",
								true,
							},
							
							{
								"5b59233e-a7da-4235-88b4-3c9896ce7732",
								true,
							},
							
							{
								"276173f7-3cab-9e10-81e1-05c586322014",
								true,
							},
						},
						displayPath = "Sildihn criterion/Zeless Gah",
						name = "JP first bait arrow",
						uuid = "3e27e513-f7ff-2eea-a3ed-39e358e39aac",
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
						name = "Sildihn criterion",
						uuid = "43c5c834-8265-0f0e-a9c0-474ba5e46c19",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Zeless Gah",
						uuid = "0ecf9587-d24a-f26c-b362-4906b3396c1d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless portal caster",
						uuid = "945141c1-ff03-f8de-9200-5454e359f2ec",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29845,
						name = "Portal activation",
						uuid = "5b59233e-a7da-4235-88b4-3c9896ce7732",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Zeless Gah",
						eventArgOptionType = 2,
						eventArgType = 3,
						eventTargetContentID = 11395,
						name = "Blue portal wave",
						uuid = "276173f7-3cab-9e10-81e1-05c586322014",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Zeless Gah",
			eventType = 2,
			name = "[Draw] Zeless Infern Brand 3 - JP First Bait",
			uuid = "5b62d778-f79c-f74d-bbdf-bd3cc910cee5",
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
						name = "Sildihn criterion",
						uuid = "ae10f94d-8e99-39f5-a961-56eabea11380",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Gladiator of Sil'dih",
						uuid = "c49da52b-663e-4914-834c-2cabbe62eac0",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Zeless Gah",
						uuid = "732ee02e-8318-786a-ab91-b80648d4016d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "local player = TensorCore.mGetPlayer()\nif not player or (player.localmapid ~= 1075 and player.localmapid ~= 1076) then\n    self.used = true\n    return\nend\n\nlocal label = ({\n    [3272] = \"1\",\n    [3273] = \"2\",\n    [3274] = \"3\",\n    [3275] = \"4\"\n})[tonumber(buffID)]\n\nlocal targetID = tonumber(entityID)\nif label and targetID and targetID ~= 0 and AnyoneCore and AnyoneCore.addTimedWorldTextOnEnt then\n    local seconds = tonumber(buffDuration) or 20\n    if seconds <= 0 then\n        seconds = 20\n    end\n    seconds = math.max(1, math.min(seconds, 30))\n    AnyoneCore.addTimedWorldTextOnEnt(\n        math.floor(seconds * 1000),\n        label,\n        targetID,\n        0xFFFFFFFF,\n        true,\n        1.5,\n        2.0\n    )\nend\n\nself.used = true",
						conditions = 
						{
							
							{
								"499b137e-3219-f86e-87c6-1fe77b5a8e59",
								true,
							},
						},
						displayPath = "Sildihn criterion/Zeless Gah",
						name = "Draw flame number above player",
						uuid = "aa509a45-886b-df83-9930-8a4d2e0338ae",
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
						name = "Sildihn criterion",
						uuid = "1f111ba9-b5e4-eea2-8b6a-5c83b5e6232b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Zeless Gah",
						uuid = "c1022204-6a40-28f9-9773-0a9fa9d312ed",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 12,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Zeless Gah",
						localMapIDList = 
						{
							1075,
							1076,
						},
						name = "Sil'dihn maps",
						uuid = "499b137e-3219-f86e-87c6-1fe77b5a8e59",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Zeless Gah",
			eventType = 8,
			name = "[Draw] Sil'dihn Third Boss - Flame Number",
			uuid = "e31a8d3b-a4cb-18b6-8907-abb96054464e",
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
						name = "Sildihn criterion",
						uuid = "d5ead3ce-0f1c-f232-8fba-704db5eaa180",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Zeless Gah",
						uuid = "fff75fb8-ee13-47b1-86c4-9b8f324514a9",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "local player = TensorCore.mGetPlayer()\nif not player or player.localmapid ~= 1075 then\n    self.used = true\n    return\nend\n\nlocal roster = AnyoneCore and AnyoneCore.Roster\nif not roster or not roster.isReady() then\n    self.used = true\n    return\nend\n\nlocal seconds = tonumber(channelTimeMax) or 4.7\nseconds = math.max(4.7, math.min(seconds + 0.8, 12.0))\nlocal duration = math.floor(seconds * 1000)\nlocal radius = 7.0\nlocal overlay = Argus2.RenderFlags.FLAG_RENDER_OVERLAY\n\nlocal green = TensorCore.getCachedDrawer(\n    0xFF80FF80,\n    0xFF80FF80,\n    0xFF22AA22,\n    0xFFFFFFFF,\n    2\n)\nlocal red = TensorCore.getCachedDrawer(\n    0xFFFF8080,\n    0xFFFF8080,\n    0xFFAA2222,\n    0xFFFFFFFF,\n    2\n)\nlocal blue = TensorCore.getCachedDrawer(\n    0xFF8080FF,\n    0xFF8080FF,\n    0xFF2222AA,\n    0xFFFFFFFF,\n    2\n)\n\n-- Player hitboxes: tanks/healers are fixed (green); DPS are flex (red).\nlocal slots = {\"T1\", \"T2\", \"H1\", \"H2\", \"M1\", \"M2\", \"R1\", \"R2\"}\nfor _, slot in ipairs(slots) do\n    local entID = roster.idOf(slot)\n    if entID and entID ~= 0 and entID ~= -1 then\n        local role = string.sub(slot, 1, 1)\n        local drawer = (role == \"T\" or role == \"H\") and green or red\n        drawer:addTimedCircleOnEnt(\n            duration,\n            entID,\n            radius,\n            0,\n            false,\n            true,\n            overlay\n        )\n    end\nend\n\n-- Rough Firesteel assignment spots around the arena:\n-- green = fixed, red = default flex, blue = alternate flex.\nlocal y = (player.pos and player.pos.y) or 521.0\nlocal spots = {\n    {277.0, -116.0, green},\n    {301.0, -116.0, green},\n    {277.0, -94.0, green},\n    {301.0, -94.0, green},\n    {283.0, -119.0, red},\n    {295.0, -119.0, red},\n    {283.0, -91.0, red},\n    {295.0, -91.0, red},\n    {277.0, -105.0, blue},\n    {301.0, -105.0, blue}\n}\nfor _, spot in ipairs(spots) do\n    spot[3]:addTimedCircle(\n        duration,\n        spot[1],\n        y,\n        spot[2],\n        1.25,\n        0,\n        false,\n        true,\n        overlay\n    )\nend\n\nself.used = true",
						conditions = 
						{
							
							{
								"0ec95893-1955-52fa-b161-7e2d315f9395",
								true,
							},
							
							{
								"00dc1558-8be7-4308-bc20-c18750ce4f20",
								true,
							},
						},
						displayPath = "Sildihn criterion/Zeless Gah",
						name = "Draw player AoEs and assignment spots",
						uuid = "1faf8ed2-87d7-681e-a1e6-c52da2f6045e",
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
						name = "Sildihn criterion",
						uuid = "7d400e8d-9ced-5a19-ad84-7c84675c6ab0",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Zeless Gah",
						uuid = "1af213db-dba4-af31-95ce-cf46aed08214",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "0ec95893-1955-52fa-b161-7e2d315f9395",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29872,
						name = "Firesteel Strike",
						uuid = "00dc1558-8be7-4308-bc20-c18750ce4f20",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Zeless Gah",
			eventType = 3,
			name = "[Draw] Zeless Firesteel Strike - Player AoEs & Spots",
			uuid = "42f034c3-7eea-c0d6-8dee-c83c3124b2f9",
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
						name = "Sildihn criterion",
						uuid = "6ca63335-c59c-5b60-82c7-25ea3f882307",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Zeless Gah",
						uuid = "40d7a7b4-098d-1733-8eff-e6316122e10c",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "Lua",
						actionLua = "local player = TensorCore.mGetPlayer()\nif not player or player.localmapid ~= 1075 then\n    self.used = true\n    return\nend\n\nlocal vfx = tonumber(vfxID)\nif vfx ~= 24 and vfx ~= 61 and vfx ~= 120 then\n    self.used = true\n    return\nend\n\nlocal brand = TensorCore.mGetEntity(primaryEntityID)\nlocal target = TensorCore.mGetEntity(secondaryEntityID)\nif not brand or not target or not brand.pos or not target.pos then\n    self.used = true\n    return\nend\n\nlocal function flameNumber(entity)\n    if not entity then\n        return nil\n    end\n    if TensorCore.getBuff(entity, 3272) then return 1 end\n    if TensorCore.getBuff(entity, 3273) then return 2 end\n    if TensorCore.getBuff(entity, 3274) then return 3 end\n    if TensorCore.getBuff(entity, 3275) then return 4 end\n    return nil\nend\n\nlocal targetNumber = flameNumber(target)\nlocal nextNumber = 99\nlocal roster = AnyoneCore and AnyoneCore.Roster\nif roster and roster.isReady() then\n    local slots = {\"T1\", \"T2\", \"H1\", \"H2\", \"M1\", \"M2\", \"R1\", \"R2\"}\n    for _, slot in ipairs(slots) do\n        local entID = roster.idOf(slot)\n        if entID and entID ~= 0 and entID ~= -1 then\n            local number = flameNumber(TensorCore.mGetEntity(entID))\n            if number and number < nextNumber then\n                nextNumber = number\n            end\n        end\n    end\nend\n\nlocal targetID = tonumber(secondaryEntityID)\nlocal playerID = tonumber(player.id)\nlocal isMine = targetID and playerID and targetID == playerID\nlocal isMyTurn = isMine and targetNumber and targetNumber == nextNumber\nlocal overlay = Argus2.RenderFlags.FLAG_RENDER_OVERLAY\n\nlocal drawer\nif isMyTurn then\n    drawer = TensorCore.getCachedDrawer(0xFF40FF40, 0xFF40FF40, 0xFF20AA20, 0xFFFFFFFF, 3)\nelseif isMine then\n    drawer = TensorCore.getCachedDrawer(0xFF80C0FF, 0xFF80C0FF, 0xFF4060AA, 0xFFFFFFFF, 2)\nelse\n    drawer = TensorCore.getCachedDrawer(0xFF707070, 0xFF707070, 0xFF404040, 0xFFFFFFFF, 1)\nend\n\ndrawer:addTimedLine(\n    10000,\n    brand.pos.x,\n    brand.pos.y + 0.15,\n    brand.pos.z,\n    target.pos.x,\n    target.pos.y + 0.15,\n    target.pos.z,\n    isMyTurn and 0.35 or 0.16,\n    isMyTurn and 0.8 or 0.35,\n    0\n)\n\nself.used = true",
						conditions = 
						{
							
							{
								"4c6b8730-f618-3329-be7b-3932a6b8bafb",
								true,
							},
						},
						displayPath = "Sildihn criterion/Zeless Gah",
						name = "Highlight current Firesteel tether",
						uuid = "5916f512-7bed-3bc0-b63f-01b75fe812a6",
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
						name = "Sildihn criterion",
						uuid = "6c083c3e-38c8-370a-9bab-0c5dc3f425d6",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Zeless Gah",
						uuid = "12fd7e9c-61ef-ab3e-9b24-bb3fb8f5d48f",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Zeless Gah",
						eventArgOptionType = 2,
						eventArgType = 3,
						eventEntityContentID = 11394,
						name = "Infern Brand",
						uuid = "4c6b8730-f618-3329-be7b-3932a6b8bafb",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Zeless Gah",
			eventType = 27,
			name = "[Draw] Zeless Gah - Firesteel tether order",
			timeout = 10,
			uuid = "3ed7b307-15e9-688b-9613-3aa56468b9a5",
			version = 2,
		},
	},
	
	{
		data = 
		{
			displayPath = "Sildihn criterion",
			name = "Mitigations",
			uuid = "d0a2220f-a707-26ea-84a1-edac59739dd3",
		},
		objectType = "folder",
	},
	
	{
		data = 
		{
			displayPath = "Sildihn criterion/Mitigations",
			name = "Silkie",
			uuid = "5af26557-165a-9f32-abe6-ce24d6bcb90e",
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
						name = "Sildihn criterion",
						uuid = "1a7f9c55-bf6d-8ad7-acaa-9894641d07a2",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "1729f3c5-0ea2-516a-b6f0-468726a419f2",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "16708bb0-6f09-2e7c-85bb-eb3e7e4221e6",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7388,
						conditions = 
						{
							
							{
								"6bb0467a-24a0-6da7-87e8-adcdb731abb4",
								true,
							},
							
							{
								"b8b32624-a125-c0bd-a67c-f507a8a96719",
								true,
							},
							
							{
								"130eaa0d-95ba-363d-88e2-1e056ba6c761",
								true,
							},
							
							{
								"f6cad215-db62-a40a-a867-888cf8b118a7",
								true,
							},
							
							{
								"3ac8dbc8-affb-ecaf-a9c5-7c74a4934383",
								true,
							},
							
							{
								"6d586bbb-ca96-7c26-827b-f0e1fb833a17",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Shake It Off",
						uuid = "1a1482d4-4ecf-a965-8425-025bdc00d562",
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
						name = "Sildihn criterion",
						uuid = "53ffafd1-328a-7806-88a1-c0203780a274",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "a72f8f46-8382-a2eb-88a7-b43fe010cff3",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "b9ea4eaa-d816-1d63-b88f-25b13332f8b1",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgOptionType = 2,
						eventEntityContentID = 11369,
						name = "Silkie",
						uuid = "6bb0467a-24a0-6da7-87e8-adcdb731abb4",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgType = 2,
						eventSpellID = 30544,
						name = "Total Wash",
						uuid = "b8b32624-a125-c0bd-a67c-f507a8a96719",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 13,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						jobValue = "WARRIOR",
						name = "WAR",
						uuid = "130eaa0d-95ba-363d-88e2-1e056ba6c761",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7388,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Shake It Off ready",
						uuid = "f6cad215-db62-a40a-a867-888cf8b118a7",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 300",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Before enrage",
						uuid = "3ac8dbc8-affb-ecaf-a9c5-7c74a4934383",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer >= 120 and TensorReactions_CurrentCombatTimer < 220",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Normal-wash window",
						uuid = "6d586bbb-ca96-7c26-827b-f0e1fb833a17",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Silkie",
			eventType = 3,
			name = "[Mit] Silkie Total Wash - WAR Shake It Off",
			uuid = "8d533a5c-f446-48e2-9249-6897cdaae7e1",
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
						name = "Sildihn criterion",
						uuid = "d14d3c93-b996-6b7f-a0a1-f6589a68402d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "0d737c91-dc87-122e-839e-d3b8add26df6",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "811c90a2-0a05-6c31-a874-638491351812",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7535,
						conditions = 
						{
							
							{
								"586d395d-f7af-e1d8-b683-150810bb4b3a",
								true,
							},
							
							{
								"d333deeb-9384-3bc6-8610-494a38c85985",
								true,
							},
							
							{
								"7e9ed185-05a4-7bc1-920b-373c0ecca2db",
								true,
							},
							
							{
								"530d9903-fd02-ddab-9c62-e564eec65530",
								true,
							},
							
							{
								"9eba5472-9767-c520-a32f-8c507c4739d0",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Reprisal",
						targetType = "Event Entity",
						uuid = "36afabb0-a7ac-69c2-b9f4-772e8c90ab51",
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
						name = "Sildihn criterion",
						uuid = "6d50117e-d687-590a-b035-7e9e5ce1703a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "f1ae2207-f692-0c44-8f6a-9552f250a79b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "13f63023-f523-6fa4-91c2-a9ee3bf0b9e0",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgOptionType = 2,
						eventEntityContentID = 11369,
						name = "Silkie",
						uuid = "586d395d-f7af-e1d8-b683-150810bb4b3a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgType = 2,
						eventSpellID = 30544,
						name = "Total Wash",
						uuid = "d333deeb-9384-3bc6-8610-494a38c85985",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						jobIDList = 
						{
							1,
							3,
							32,
							37,
						},
						jobValue = "WARRIOR",
						name = "Tanks",
						uuid = "7e9ed185-05a4-7bc1-920b-373c0ecca2db",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7535,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Reprisal ready",
						uuid = "530d9903-fd02-ddab-9c62-e564eec65530",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 300",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Before enrage",
						uuid = "9eba5472-9767-c520-a32f-8c507c4739d0",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Silkie",
			eventType = 3,
			name = "[Mit] Silkie Total Wash - Tank Reprisal",
			uuid = "89f81c47-3cec-0e72-b44a-21c9d6d736a1",
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
						name = "Sildihn criterion",
						uuid = "fd5cbcbd-5bab-d573-a698-31c0c21ff9c7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "c66d34d9-6b99-1467-b2a1-fcc66e5577f8",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "0ea2d1b7-c2b2-b30b-8e71-4b9c174b59c4",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "ACR",
						conditions = 
						{
							
							{
								"110ec150-54bc-273e-bc9c-286af454aaff",
								true,
							},
							
							{
								"9e4291a8-da99-e8bb-8bbf-303bab329ffd",
								true,
							},
							
							{
								"0739cb27-549b-c814-8503-6d40147bfa24",
								true,
							},
							
							{
								"43f7acea-e394-f98c-9644-40d7c091aa26",
								true,
							},
							
							{
								"6fbbe75d-e41d-fb02-836a-65739b9240f9",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						gVar = "ACR_RikuSCH3_Healbar_SacredSoil",
						name = "Sacred Soil - Total Wash",
						uuid = "4637162d-17f3-dfdf-be74-5aff8abbd5c0",
						variableTogglesType = 3,
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
						name = "Sildihn criterion",
						uuid = "c4358a33-0a49-ce12-a211-aaa64f23f5c2",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "f41cdb91-c7a2-4886-b309-04458423fe8b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "e7074d1b-5b16-cfdb-b9d9-0fa4ac50b332",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgOptionType = 2,
						eventEntityContentID = 11369,
						name = "Silkie",
						uuid = "110ec150-54bc-273e-bc9c-286af454aaff",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgType = 2,
						eventSpellID = 30544,
						name = "Total Wash",
						uuid = "9e4291a8-da99-e8bb-8bbf-303bab329ffd",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"H1\" and mySlot ~= \"H2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 28",
						conditionType = 13,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						jobValue = "SCHOLAR",
						name = "Party roster: H1/H2 Scholar",
						uuid = "0739cb27-549b-c814-8503-6d40147bfa24",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 188,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Sacred Soil ready",
						uuid = "43f7acea-e394-f98c-9644-40d7c091aa26",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 300",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Before enrage",
						uuid = "6fbbe75d-e41d-fb02-836a-65739b9240f9",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Silkie",
			eventType = 3,
			name = "[Mit] Silkie Total Wash - SCH Sacred Soil",
			uuid = "79f58041-445f-b1d8-b00f-e886f6bf8665",
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
						name = "Sildihn criterion",
						uuid = "f3afd5ff-9bd8-88e4-940f-f476860603cd",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "e3938012-60ff-d18c-9768-8c96bcd401ce",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "dacf26d2-28c1-567a-84eb-1f713c33524b",
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
								"34408cc5-fac4-3daa-b332-efcc582d2368",
								true,
							},
							
							{
								"2aeb9e8d-900b-f404-a15a-88ae5de61dbe",
								true,
							},
							
							{
								"65f16bee-3621-9b56-9c67-18cf58d41683",
								true,
							},
							
							{
								"7952f89a-14d6-a5a8-b729-335ceb72448b",
								true,
							},
							
							{
								"e15277a0-45fc-9db4-8133-57d7f93785de",
								true,
							},
							
							{
								"0904f886-2cda-fed8-a424-7a1a482b668f",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Addle",
						targetType = "Event Entity",
						uuid = "3a7ae2b4-d345-a2a2-ab75-0b2c857dba0f",
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
						name = "Sildihn criterion",
						uuid = "8f54d86d-c0fc-a643-8cb5-57dc97f9b41e",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "1d1d755f-618a-09b9-b8c5-31e496fb5732",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "d797cb02-27c6-8826-a3ef-a9e7103a4e27",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgOptionType = 2,
						eventEntityContentID = 11369,
						name = "Silkie",
						uuid = "34408cc5-fac4-3daa-b332-efcc582d2368",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgType = 2,
						eventSpellID = 30544,
						name = "Total Wash",
						uuid = "2aeb9e8d-900b-f404-a15a-88ae5de61dbe",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"R2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 25 or job == 27 or job == 35 or job == 42",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						jobIDList = 
						{
							25,
							27,
							35,
							42,
						},
						jobValue = "BLACKMAGE",
						name = "Party roster: R2 caster",
						uuid = "65f16bee-3621-9b56-9c67-18cf58d41683",
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
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Addle ready",
						uuid = "7952f89a-14d6-a5a8-b729-335ceb72448b",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 300",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Before enrage",
						uuid = "e15277a0-45fc-9db4-8133-57d7f93785de",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return (TensorReactions_CurrentCombatTimer >= 120 and TensorReactions_CurrentCombatTimer < 220) or (TensorReactions_CurrentCombatTimer >= 240 and TensorReactions_CurrentCombatTimer < 300)",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Normal-wash window",
						uuid = "0904f886-2cda-fed8-a424-7a1a482b668f",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Silkie",
			eventType = 3,
			name = "[Mit] Silkie Total Wash - Caster Addle",
			uuid = "7faa467f-d070-1eef-8a0a-0177fc338a08",
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
						name = "Sildihn criterion",
						uuid = "87e0d0b1-d34c-e4f7-bbe8-f08f73580993",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "cef11066-2520-5b1d-9633-076de9d0382a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "b2409ec8-6728-d4b4-a2af-74978cfa48bf",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16538,
						conditions = 
						{
							
							{
								"23d45d22-e397-6abc-8019-e8bf3d980a07",
								true,
							},
							
							{
								"946015c5-a179-fc93-bdbc-5544fc08829a",
								true,
							},
							
							{
								"5eb58162-0676-d5bd-9508-b397e05503be",
								true,
							},
							
							{
								"b1a3295c-13a3-6f8f-8330-dc8a2392a4e8",
								true,
							},
							
							{
								"711a1b22-1adb-1f0b-8ce8-d383dda4acbf",
								true,
							},
							
							{
								"78abfe8d-1f3a-0f6f-a295-76a8079b6382",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Fey Illumination",
						uuid = "2250a7b9-af23-c857-a7c7-ea6b7398b67f",
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
						name = "Sildihn criterion",
						uuid = "fc44612a-d274-3cca-ba7b-ac75a70dbb37",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "41f10537-9d77-606e-b0e7-36e550dabd0e",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "854ce105-4b56-524a-933a-92d203b81673",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgOptionType = 2,
						eventEntityContentID = 11369,
						name = "Silkie",
						uuid = "23d45d22-e397-6abc-8019-e8bf3d980a07",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgType = 2,
						eventSpellID = 30544,
						name = "Total Wash",
						uuid = "946015c5-a179-fc93-bdbc-5544fc08829a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"H1\" and mySlot ~= \"H2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 28",
						conditionType = 13,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						jobValue = "SCHOLAR",
						name = "Party roster: H1/H2 Scholar",
						uuid = "5eb58162-0676-d5bd-9508-b397e05503be",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16538,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Fey Illumination ready",
						uuid = "b1a3295c-13a3-6f8f-8330-dc8a2392a4e8",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 300",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Before enrage",
						uuid = "711a1b22-1adb-1f0b-8ce8-d383dda4acbf",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 120 or (TensorReactions_CurrentCombatTimer >= 240 and TensorReactions_CurrentCombatTimer < 300)",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Normal-wash window",
						uuid = "78abfe8d-1f3a-0f6f-a295-76a8079b6382",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Silkie",
			eventType = 3,
			name = "[Mit] Silkie Total Wash - SCH Fey Illumination",
			uuid = "71ef4145-c37a-4d94-a92b-53de8cef0555",
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
						name = "Sildihn criterion",
						uuid = "f07ac2e3-d8b6-2466-a26c-e2cfce93d659",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "9c42042a-9c7e-b53b-8654-f0032b7bc1ce",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "699f0852-090f-67c2-8d48-5ffc88ab2e4d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 25868,
						conditions = 
						{
							
							{
								"f350cc5e-6c80-4cfe-9b1e-29f704d66afe",
								true,
							},
							
							{
								"6b9d0b79-510e-21c5-9b8b-111a0219fc12",
								true,
							},
							
							{
								"53907c0a-5d9d-5aac-8343-46486f14cf08",
								true,
							},
							
							{
								"31f28c1c-44f5-2713-b147-c58c776c543a",
								true,
							},
							
							{
								"eecead5f-b851-6d61-a257-86cb5474fcc2",
								true,
							},
							
							{
								"1c26feb6-3294-a071-9555-122222cbf822",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Expedient",
						uuid = "ddf7521f-509f-ff62-9846-64886012600b",
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
						name = "Sildihn criterion",
						uuid = "666fded2-1132-e03d-b11b-ca3ffbadc7aa",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "e825d574-d2ee-5eed-83de-f572565d1874",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "6c40d427-2fd2-cf9e-b426-a1ec4f642503",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgOptionType = 2,
						eventEntityContentID = 11369,
						name = "Silkie",
						uuid = "f350cc5e-6c80-4cfe-9b1e-29f704d66afe",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgType = 2,
						eventSpellID = 30544,
						name = "Total Wash",
						uuid = "6b9d0b79-510e-21c5-9b8b-111a0219fc12",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"H1\" and mySlot ~= \"H2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 28",
						conditionType = 13,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						jobValue = "SCHOLAR",
						name = "Party roster: H1/H2 Scholar",
						uuid = "53907c0a-5d9d-5aac-8343-46486f14cf08",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 25868,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Expedient ready",
						uuid = "31f28c1c-44f5-2713-b147-c58c776c543a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 300",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Before enrage",
						uuid = "eecead5f-b851-6d61-a257-86cb5474fcc2",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer >= 120 and TensorReactions_CurrentCombatTimer < 220",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Normal-wash window",
						uuid = "1c26feb6-3294-a071-9555-122222cbf822",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Silkie",
			eventType = 3,
			name = "[Mit] Silkie Total Wash - SCH Expedient",
			uuid = "5b5b5b8e-d606-6e74-94c1-a51e93660cd8",
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
						name = "Sildihn criterion",
						uuid = "eb6986a8-9253-2721-b569-2346cea695b5",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "13b1af9c-1624-e5b3-a6c0-7245ed0d377d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "fe283496-2933-7d72-a6ab-f0a278a44663",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "0fe30d59-4631-873f-a8df-07864df51d72",
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
								"00a2c59e-d02a-0e30-81e9-ac58e4422d6a",
								true,
							},
							
							{
								"adca4c80-2ca1-740a-921d-c97cfde16dbd",
								true,
							},
							
							{
								"bd89c91b-8153-d665-99b9-ac7e9a0369f8",
								true,
							},
							
							{
								"c4d40983-0b87-ef4c-b68f-07c7ee4fe956",
								true,
							},
							
							{
								"2e05a79c-9f30-ff25-8868-31b0a704fbac",
								true,
							},
							
							{
								"41e0be91-818e-a280-93ec-c0a1752e4e1a",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Feint - Total Wash",
						targetType = "Event Entity",
						uuid = "77509856-52e3-3c85-a0ef-ee3f487ca642",
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
						name = "Sildihn criterion",
						uuid = "f62e74df-575f-e145-8ade-1a88c4fc84f6",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "3316af21-23dd-4657-8f39-446b8856e9e3",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "0470fc56-7386-d6fe-9062-ed22638dfb80",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "c1974fe7-f056-9365-9545-4a0d1249a8d5",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgOptionType = 2,
						eventEntityContentID = 11369,
						name = "Silkie",
						uuid = "00a2c59e-d02a-0e30-81e9-ac58e4422d6a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgType = 2,
						eventSpellID = 30544,
						name = "Total Wash",
						uuid = "adca4c80-2ca1-740a-921d-c97cfde16dbd",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7549,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Feint ready",
						uuid = "c4d40983-0b87-ef4c-b68f-07c7ee4fe956",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"M1\" and mySlot ~= \"M2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 20 or job == 22 or job == 30 or job == 34 or job == 39 or job == 41",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						jobIDList = 
						{
							2,
							4,
							29,
							34,
							39,
							41,
						},
						jobValue = "VIPER",
						name = "Party roster: M1/M2 melee",
						uuid = "bd89c91b-8153-d665-99b9-ac7e9a0369f8",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 300",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Before enrage",
						uuid = "2e05a79c-9f30-ff25-8868-31b0a704fbac",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 120 or (TensorReactions_CurrentCombatTimer >= 240 and TensorReactions_CurrentCombatTimer < 300)",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Normal-wash window",
						uuid = "41e0be91-818e-a280-93ec-c0a1752e4e1a",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Silkie",
			eventType = 3,
			name = "[Mit] Silkie Total Wash - Melee Feint",
			uuid = "8e07f379-ae7e-d044-b653-e9c0cc17a950",
			version = 2,
		},
		inheritedIndex = 60,
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
						name = "Sildihn criterion",
						uuid = "043e0a47-c2f7-33c5-aff1-6c868da1f396",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "03fc99b9-4a8f-d85a-b59a-36f514d6f9c5",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "31679a0e-db2e-885b-8acb-878fba4cb813",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "350b407a-ce22-79dc-9fb4-4b3eff0b75c2",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7548,
						conditions = 
						{
							
							{
								"dc319243-58bb-8b3d-ab96-c63a37d1503e",
								true,
							},
							
							{
								"7445ce75-8036-b668-ada7-e15c284c657f",
								true,
							},
							
							{
								"42cdb118-dea1-97f3-8d94-5e9791eeed8f",
								true,
							},
							
							{
								"23727dd1-f7cd-e4ca-9a9d-57439a366205",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Arm's Length - Dust Bluster",
						uuid = "a3b6e5b6-b1bb-ac2f-af4a-58f406f31ceb",
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
						name = "Sildihn criterion",
						uuid = "5e854842-0c87-2ab1-a7ea-867a557b9383",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Silkie",
						uuid = "06db8e51-493b-63b5-be2c-a8bad84db903",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "dec50b20-11b9-e611-8be5-465151a44b42",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "252223a7-3ae9-5d6d-94f3-3c6e8cf711e2",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgOptionType = 2,
						eventEntityContentID = 11369,
						name = "Silkie",
						uuid = "dc319243-58bb-8b3d-ab96-c63a37d1503e",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgType = 2,
						eventSpellID = 30572,
						name = "Dust Bluster",
						uuid = "7445ce75-8036-b668-ada7-e15c284c657f",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						jobIDList = 
						{
							1,
							3,
							32,
							37,
						},
						jobValue = "WARRIOR",
						name = "Tanks",
						uuid = "42cdb118-dea1-97f3-8d94-5e9791eeed8f",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7548,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Arm's Length ready",
						uuid = "23727dd1-f7cd-e4ca-9a9d-57439a366205",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Silkie",
			eventType = 3,
			name = "[Mit/Utility] Silkie Dust Bluster - Tank Arm's Length",
			uuid = "2180bfac-3873-ad4d-9ae8-e7ba5af0d979",
			version = 2,
		},
		inheritedIndex = 61,
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
						name = "Sildihn criterion",
						uuid = "b77b0b32-0bec-9927-adfb-fb0d8624bfcf",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "d2cb1ff4-6c96-33f5-8f92-cc100b00c7b7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "5f7e0158-7c76-2cb7-bffe-5b75f436ab22",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16012,
						conditions = 
						{
							
							{
								"6ac94545-725b-05c2-a097-a9dc30ecbda0",
								true,
							},
							
							{
								"1096d741-7209-5859-b0b6-84a0c1764e9b",
								true,
							},
							
							{
								"d56161f6-8749-c35c-8453-c360034f81d8",
								true,
							},
							
							{
								"b212e664-5aeb-3521-aa29-3feb1590edc3",
								true,
							},
							
							{
								"4539cfce-e8d3-5452-a1b6-74fea98a29de",
								true,
							},
							
							{
								"f1f89e79-ccfc-bc5b-a126-a2516b2760e5",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Shield Samba",
						uuid = "f98822b5-12ad-2396-9aa8-df04e5901cbf",
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
						name = "Sildihn criterion",
						uuid = "76676f03-8003-8a52-8f08-3ab0ce7d1093",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "0935cdc9-d21e-e76a-aced-9382fc9614b0",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "73e15c55-ae2e-55a1-bd62-9dd567a0a16d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgOptionType = 2,
						eventEntityContentID = 11369,
						name = "Silkie",
						uuid = "6ac94545-725b-05c2-a097-a9dc30ecbda0",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgType = 2,
						eventSpellID = 30544,
						name = "Total Wash",
						uuid = "1096d741-7209-5859-b0b6-84a0c1764e9b",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"R1\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 38",
						conditionType = 13,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						jobValue = "DANCER",
						name = "Party roster: R1 physical ranged (Dancer)",
						uuid = "d56161f6-8749-c35c-8453-c360034f81d8",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16012,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Shield Samba ready",
						uuid = "b212e664-5aeb-3521-aa29-3feb1590edc3",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 300",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Before enrage",
						uuid = "4539cfce-e8d3-5452-a1b6-74fea98a29de",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return (TensorReactions_CurrentCombatTimer >= 120 and TensorReactions_CurrentCombatTimer < 220) or (TensorReactions_CurrentCombatTimer >= 240 and TensorReactions_CurrentCombatTimer < 300)",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Normal-wash window",
						uuid = "f1f89e79-ccfc-bc5b-a126-a2516b2760e5",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Silkie",
			eventType = 3,
			name = "[Mit] Silkie Total Wash - DNC Shield Samba",
			uuid = "5dac0a94-7cff-2a3a-895f-13addfa49a1f",
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
						name = "Sildihn criterion",
						uuid = "b8a4720a-359d-5072-ae30-711320785af2",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "9f457fb6-6525-a5b2-ab8f-4d436523b532",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "eee08174-99a8-bf3f-8e58-972fa4c9ebda",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 44,
						conditions = 
						{
							
							{
								"d23f482e-77b0-3d30-be48-98f13ee5879a",
								true,
							},
							
							{
								"6b36a30d-302c-b624-8e89-1b15b7d11592",
								true,
							},
							
							{
								"b26e234e-de69-9cf7-90da-6eb44988958f",
								true,
							},
							
							{
								"80178a1c-da11-2b96-bdca-3434561fd878",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Vengeance",
						uuid = "c5c81428-598f-6544-8bd2-dcf24339d440",
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
						name = "Sildihn criterion",
						uuid = "395b7334-46b3-8340-82d6-fc398b6034c3",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "d9ca8554-f1d0-24d6-947b-241eba187119",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "7df5de91-2819-9ede-aea4-bdc5122dd24a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgOptionType = 2,
						eventEntityContentID = 11369,
						name = "Silkie",
						uuid = "d23f482e-77b0-3d30-be48-98f13ee5879a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgType = 2,
						eventSpellID = 30543,
						name = "Carpet Beater",
						uuid = "6b36a30d-302c-b624-8e89-1b15b7d11592",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 13,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						jobValue = "WARRIOR",
						name = "WAR",
						uuid = "b26e234e-de69-9cf7-90da-6eb44988958f",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 44,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Vengeance ready",
						uuid = "80178a1c-da11-2b96-bdca-3434561fd878",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Silkie",
			eventType = 3,
			name = "[Mit] Silkie Carpet Beater - WAR Vengeance",
			uuid = "c0a39014-b2dc-1476-b1fd-835e6ba6a409",
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
						name = "Sildihn criterion",
						uuid = "5b93e26a-370f-f9d9-b091-2a6dd7fb09ce",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "9d801afc-30e5-c66e-ba33-8c862bc1ab21",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "c7911de1-1694-375b-9b83-3707bea0dc3b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 25751,
						conditions = 
						{
							
							{
								"ec4cd126-4cf9-0c6f-8aa7-686bc16f9919",
								true,
							},
							
							{
								"c9fdbf44-f37b-65b8-9404-6c7ea7824368",
								true,
							},
							
							{
								"1e68244f-58ca-c28b-81ea-a32df2fc3d1f",
								true,
							},
							
							{
								"fceb8459-bcd0-543c-8d00-061cc08faf6d",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Bloodwhetting",
						uuid = "f8410449-d371-e772-8e0d-d5e461ef0538",
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
						name = "Sildihn criterion",
						uuid = "96d4651a-4cc1-0f21-b74a-721106e26fe7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "90a4bd51-d2b6-643e-a3f2-0f2bd6dca440",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "42d8d678-6259-017b-9cd2-6a1e5c788d1b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgOptionType = 2,
						eventEntityContentID = 11369,
						name = "Silkie",
						uuid = "ec4cd126-4cf9-0c6f-8aa7-686bc16f9919",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgType = 2,
						eventSpellID = 30543,
						name = "Carpet Beater",
						uuid = "c9fdbf44-f37b-65b8-9404-6c7ea7824368",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 13,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						jobValue = "WARRIOR",
						name = "WAR",
						uuid = "1e68244f-58ca-c28b-81ea-a32df2fc3d1f",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 25751,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Bloodwhetting ready",
						uuid = "fceb8459-bcd0-543c-8d00-061cc08faf6d",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Silkie",
			eventType = 3,
			name = "[Mit] Silkie Carpet Beater - WAR Bloodwhetting",
			uuid = "82bab5fa-a9b9-3769-bd85-d2c1b87b5958",
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
						name = "Sildihn criterion",
						uuid = "1e37c648-58a3-fb66-af92-823e86089a3b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "de628683-3d67-17af-ad2d-fdecf46a414d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "e4a6c82c-1036-d443-9067-e72b90389a20",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7531,
						conditions = 
						{
							
							{
								"20fb0895-01d9-8ec7-a099-88df8f26615c",
								true,
							},
							
							{
								"f45f15d1-bfc2-5607-bd91-9cbc00fb2c56",
								true,
							},
							
							{
								"111b60b9-b0aa-3e84-8dcd-f05bb6bd8b21",
								true,
							},
							
							{
								"91d857ad-0b6c-fc90-ac8a-e8f820fec194",
								true,
							},
							
							{
								"3e2457f0-4cbc-5603-9fd7-79a0d9a75de4",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Rampart - Carpet Beater",
						uuid = "70986e95-2ee2-e937-81cf-642b9ed0a57d",
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
						name = "Sildihn criterion",
						uuid = "9c00cb29-59f7-8e7f-b4bb-fd3f167f6ad4",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "2781db9f-aa82-748e-b53a-2900d91b57c5",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "993a28a0-57fc-e57d-9aa2-84ecdee21773",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgOptionType = 2,
						eventEntityContentID = 11369,
						name = "Silkie",
						uuid = "20fb0895-01d9-8ec7-a099-88df8f26615c",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgType = 2,
						eventSpellID = 30543,
						name = "Carpet Beater",
						uuid = "f45f15d1-bfc2-5607-bd91-9cbc00fb2c56",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 13,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						jobValue = "WARRIOR",
						name = "WAR",
						uuid = "111b60b9-b0aa-3e84-8dcd-f05bb6bd8b21",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7531,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Rampart ready",
						uuid = "91d857ad-0b6c-fc90-ac8a-e8f820fec194",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 120",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "First Carpet Beater",
						uuid = "3e2457f0-4cbc-5603-9fd7-79a0d9a75de4",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Silkie",
			enabled = false,
			eventType = 3,
			name = "[Mit] Silkie Carpet Beater - WAR Rampart (disabled)",
			uuid = "d9299af9-44ce-6916-8f41-4e06a0e3f6a8",
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
						name = "Sildihn criterion",
						uuid = "56c57cb7-f94b-5325-a02e-34ffb823222f",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "d8e24f6d-bf77-8bb0-a097-947475680e2f",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "ea618c6e-a070-6474-b164-fe6a847b0c9d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 3540,
						conditions = 
						{
							
							{
								"f1ebec50-a6ec-4b57-bc7f-62a8424b8443",
								true,
							},
							
							{
								"4e33f4ae-d3cf-5736-a044-5f0f74e68e72",
								true,
							},
							
							{
								"96275419-df94-6a25-b505-ace84bbbf23b",
								true,
							},
							
							{
								"28455f91-73b6-946a-8205-16d47ffd79ba",
								true,
							},
							
							{
								"3dac32b5-bb10-cbaf-ad4b-798979b9b8e9",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Divine Veil",
						uuid = "714860a5-1f64-f21c-933e-7de0ace645b7",
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
						name = "Sildihn criterion",
						uuid = "01f9b168-d8ff-fbb1-bdd4-291863d017e7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "d6b9ff17-3fc3-086e-bb2a-ea06da6ef00e",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "e863dbf9-6229-90f0-8830-1ac362e09e9a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgOptionType = 2,
						eventEntityContentID = 11369,
						name = "Silkie",
						uuid = "f1ebec50-a6ec-4b57-bc7f-62a8424b8443",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgType = 2,
						eventSpellID = 30544,
						name = "Total Wash",
						uuid = "4e33f4ae-d3cf-5736-a044-5f0f74e68e72",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						jobIDList = 
						{
							19,
						},
						name = "Paladin",
						uuid = "96275419-df94-6a25-b505-ace84bbbf23b",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 3540,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Divine Veil ready",
						uuid = "28455f91-73b6-946a-8205-16d47ffd79ba",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer >= 120 and TensorReactions_CurrentCombatTimer < 220",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Normal-wash window",
						uuid = "3dac32b5-bb10-cbaf-ad4b-798979b9b8e9",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Silkie",
			eventType = 3,
			name = "[Mit] Silkie Total Wash - Divine Veil",
			uuid = "1fcca1c9-efbc-f86a-af42-0307cfd4c24e",
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
						name = "Sildihn criterion",
						uuid = "f5f676be-42d7-997e-a334-c3d9eb8a2563",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "8b90355c-005d-22ab-9195-17ab28411ce6",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "ce572a5b-6b66-bb2c-893b-7b03fe6af7e2",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16160,
						conditions = 
						{
							
							{
								"7ed0152c-9a0d-d7c8-a9b7-5b880c40b530",
								true,
							},
							
							{
								"50708d5d-ec8e-dc75-a787-f883b8ed304c",
								true,
							},
							
							{
								"1f03106a-1334-0c7e-886f-b506c2c4fb04",
								true,
							},
							
							{
								"8cfd6c78-754e-34e5-a44a-a90f2a61fcf4",
								true,
							},
							
							{
								"126511ba-352c-4c89-b22f-611ffce75d14",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Heart of Light",
						uuid = "2c362eae-9b02-ed0a-ae0d-224fb7329eae",
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
						name = "Sildihn criterion",
						uuid = "39279bba-0b4b-089d-aacd-2cea7bef15f5",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "34c83648-c6fd-a04d-bd7c-8c8e8f7d1024",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "bd1d1b5b-b01d-1e55-a85d-4ab156a583d4",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgOptionType = 2,
						eventEntityContentID = 11369,
						name = "Silkie",
						uuid = "7ed0152c-9a0d-d7c8-a9b7-5b880c40b530",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgType = 2,
						eventSpellID = 30544,
						name = "Total Wash",
						uuid = "50708d5d-ec8e-dc75-a787-f883b8ed304c",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						jobIDList = 
						{
							37,
						},
						name = "Gunbreaker",
						uuid = "1f03106a-1334-0c7e-886f-b506c2c4fb04",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16160,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Heart of Light ready",
						uuid = "8cfd6c78-754e-34e5-a44a-a90f2a61fcf4",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer >= 120 and TensorReactions_CurrentCombatTimer < 220",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Normal-wash window",
						uuid = "126511ba-352c-4c89-b22f-611ffce75d14",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Silkie",
			eventType = 3,
			name = "[Mit] Silkie Total Wash - Heart of Light",
			uuid = "c94f358c-792a-61af-a67c-a54f9f4c74ae",
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
						name = "Sildihn criterion",
						uuid = "e944ea97-af7c-d6b7-b5fa-a9a91a334a2c",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "8017d362-d672-7b25-8108-373d9826ceeb",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "5beee395-a6af-1bd3-8b39-174844d9dce7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16471,
						conditions = 
						{
							
							{
								"92e8d5f5-72b2-2d31-8f4c-456f947e5df6",
								true,
							},
							
							{
								"6c31f00e-be2b-eb90-be3b-ca0caf282a71",
								true,
							},
							
							{
								"0591cd09-8f4d-01dd-9d73-d3f17648de49",
								true,
							},
							
							{
								"ff53e6f6-bf9d-71f0-b6e9-8494c026912b",
								true,
							},
							
							{
								"9b3c7537-c2c2-8752-8d99-e9984b7b5b76",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Dark Missionary",
						uuid = "93f1bb36-ac39-4976-960f-03eeb666ac1f",
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
						name = "Sildihn criterion",
						uuid = "9c2bccde-eac4-2ba6-bba4-f6bd3620466a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "7f22a5ce-fcf5-6d0e-bc15-b68e62be87b9",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Silkie",
						uuid = "c6597a1d-e3b2-4fbe-b235-edaa2b488715",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgOptionType = 2,
						eventEntityContentID = 11369,
						name = "Silkie",
						uuid = "92e8d5f5-72b2-2d31-8f4c-456f947e5df6",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						eventArgType = 2,
						eventSpellID = 30544,
						name = "Total Wash",
						uuid = "6c31f00e-be2b-eb90-be3b-ca0caf282a71",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						jobIDList = 
						{
							32,
						},
						name = "Dark Knight",
						uuid = "0591cd09-8f4d-01dd-9d73-d3f17648de49",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16471,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Dark Missionary ready",
						uuid = "ff53e6f6-bf9d-71f0-b6e9-8494c026912b",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer >= 120 and TensorReactions_CurrentCombatTimer < 220",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Silkie",
						name = "Normal-wash window",
						uuid = "9b3c7537-c2c2-8752-8d99-e9984b7b5b76",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Silkie",
			eventType = 3,
			name = "[Mit] Silkie Total Wash - Dark Missionary",
			uuid = "6b65d5b7-bed4-6b5a-bf25-dc702d43e3fd",
			version = 2,
		},
	},
	
	{
		data = 
		{
			displayPath = "Sildihn criterion/Mitigations",
			name = "Gladiator of Sil'dih",
			uuid = "e15f5cb1-1050-b78b-9a4f-04cc8959e87c",
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
						name = "Sildihn criterion",
						uuid = "4c077af0-e531-5d81-b42e-28bb7caaea88",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "43be4e9f-d06b-5e07-832a-148ed7423acc",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "3726ffed-e676-1c10-bd49-e6981a9dc18c",
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
								"d363571b-c084-e255-857b-572bde920e74",
								true,
							},
							
							{
								"02b9893c-5c57-fcb6-a5dd-5857fa8047b0",
								true,
							},
							
							{
								"d82812a7-11e0-19f1-bff0-901a2ca945b0",
								true,
							},
							
							{
								"71869601-5d1b-888e-a9cd-99b7994dea08",
								true,
							},
							
							{
								"b3f77cf3-ccb9-d011-994c-b6e909827d88",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Feint - Rush of Might",
						targetType = "Event Entity",
						uuid = "793f6739-0cba-cd30-b1e4-b7ab88042f4d",
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
						name = "Sildihn criterion",
						uuid = "0fb0d713-87c7-b6e8-bb60-d0b82518d6f7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "1392cf17-cae0-63c4-877c-866b83e72a7d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "1b6e36a6-e507-8fdb-8e36-b57cd096c426",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "d363571b-c084-e255-857b-572bde920e74",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Rush of Might",
						spellIDList = 
						{
							30299,
							30300,
						},
						uuid = "02b9893c-5c57-fcb6-a5dd-5857fa8047b0",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"M1\" and mySlot ~= \"M2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 20 or job == 22 or job == 30 or job == 34 or job == 39 or job == 41",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							2,
							4,
							29,
							34,
							39,
							41,
						},
						name = "Party roster: M1/M2 melee",
						uuid = "d82812a7-11e0-19f1-bff0-901a2ca945b0",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7549,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Feint ready",
						uuid = "71869601-5d1b-888e-a9cd-99b7994dea08",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local entity = TensorCore.mGetEntity(eventArgs.entityID)\nreturn entity ~= nil and entity.targetable",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Boss targetable",
						uuid = "b3f77cf3-ccb9-d011-994c-b6e909827d88",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			enabled = false,
			eventType = 3,
			name = "[Mit] Gladiator Rush of Might - Melee Feint (disabled: avoidable)",
			uuid = "a3307508-4383-a0fa-a7f6-6f965094fd57",
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
						name = "Sildihn criterion",
						uuid = "76638e21-7453-cc89-a699-0bbd35c550dc",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "b48b8b9c-a207-e5f9-bf53-4c54293599c2",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "306f9e31-9a10-d0a3-bc93-5474526d2f60",
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
								"eab126db-b91f-a8ca-a488-6d865eb7ed0f",
								true,
							},
							
							{
								"d0d41ccb-060e-523a-b778-c6d51d130a6b",
								true,
							},
							
							{
								"0bf99972-0e7c-a036-bd08-0d69dd205ecf",
								true,
							},
							
							{
								"f9e86eb1-e86e-c7d7-b628-691b7656ebb0",
								true,
							},
							
							{
								"d828b8af-359d-d06e-a3c8-0736f80f3890",
								true,
							},
							
							{
								"ce15bfaa-4170-e5ca-8808-fcd3ed7a5fac",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Feint - Flash of Steel",
						targetType = "Event Entity",
						uuid = "68b7849c-b1d4-3a71-ac36-2b26b5b68c62",
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
						name = "Sildihn criterion",
						uuid = "e7392373-c986-3069-9510-32f1a8d9ff6f",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "14a1cec2-7db5-d6a6-b329-b6263e6e9716",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "6b8f2507-f599-795e-a0de-921606883a7f",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Flash of Steel",
						spellIDList = 
						{
							30284,
							30287,
							30294,
							30321,
							30329,
							30643,
							30651,
							31282,
							31283,
						},
						uuid = "d0d41ccb-060e-523a-b778-c6d51d130a6b",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "eab126db-b91f-a8ca-a488-6d865eb7ed0f",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"M1\" and mySlot ~= \"M2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 20 or job == 22 or job == 30 or job == 34 or job == 39 or job == 41",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							2,
							4,
							29,
							34,
							39,
							41,
						},
						name = "Party roster: M1/M2 melee",
						uuid = "0bf99972-0e7c-a036-bd08-0d69dd205ecf",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7549,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Feint ready",
						uuid = "f9e86eb1-e86e-c7d7-b628-691b7656ebb0",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local entity = TensorCore.mGetEntity(eventArgs.entityID)\nreturn entity ~= nil and entity.targetable",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Boss targetable",
						uuid = "d828b8af-359d-d06e-a3c8-0736f80f3890",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer >= 180 and TensorReactions_CurrentCombatTimer < 319",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Post-Mighty Feint window",
						uuid = "ce15bfaa-4170-e5ca-8808-fcd3ed7a5fac",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Gladiator Flash of Steel - Melee Feint",
			uuid = "8221ac54-3b61-d899-b433-bebe83ff5a67",
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
						name = "Sildihn criterion",
						uuid = "c10026b9-c581-fde7-a4b1-4dd253606e76",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "0d579044-926b-5d4c-b13f-3b87f56fab25",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "779fd8d5-06fa-6022-8701-58cbefd8f4f0",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7535,
						conditions = 
						{
							
							{
								"c1d83262-3ca6-7907-a2cb-0357282b1ae3",
								true,
							},
							
							{
								"647f57b9-f4cf-7828-b7b6-33015551fa76",
								true,
							},
							
							{
								"fcb2cb78-ecd9-08b5-b8fe-0b0858b2536d",
								true,
							},
							
							{
								"71bd3e29-d648-2d0d-bcb6-3f8b4e1d723b",
								true,
							},
							
							{
								"48a5482b-6997-9e7f-becb-31d44cfaae98",
								true,
							},
							
							{
								"b3e4eaae-7fff-9c47-8e68-be6b8f60a75e",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Tank Reprisal",
						targetType = "Event Entity",
						uuid = "cb0991c3-2b40-9078-9da3-06d2405c6b8d",
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
						name = "Sildihn criterion",
						uuid = "6c92b82e-a48c-4321-80f9-9816a0030dcc",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "f8923ce8-4875-568d-8493-1a6cec6c41c3",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "c13187d4-9e5d-41d7-ae23-921fb45cc212",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "c1d83262-3ca6-7907-a2cb-0357282b1ae3",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Flash of Steel",
						spellIDList = 
						{
							30284,
							30287,
							30294,
							30321,
							30329,
							30643,
							30651,
							31282,
							31283,
						},
						uuid = "647f57b9-f4cf-7828-b7b6-33015551fa76",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							1,
							3,
							32,
							37,
						},
						name = "Tank jobs",
						uuid = "fcb2cb78-ecd9-08b5-b8fe-0b0858b2536d",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7535,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Reprisal ready",
						uuid = "71bd3e29-d648-2d0d-bcb6-3f8b4e1d723b",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local entity = TensorCore.mGetEntity(eventArgs.entityID)\nreturn entity ~= nil and entity.targetable",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Boss targetable",
						uuid = "48a5482b-6997-9e7f-becb-31d44cfaae98",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 319",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Before enrage",
						uuid = "b3e4eaae-7fff-9c47-8e68-be6b8f60a75e",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Flash of Steel - Tank Reprisal",
			uuid = "8736b946-2201-aa0d-841a-e229eca10b04",
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
						name = "Sildihn criterion",
						uuid = "090d45e8-2568-dc05-af1c-74e08d97dfee",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "6324f17f-8f08-bf1d-bb41-4e08ee181318",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "da6579f0-f258-3db9-8bab-cbae1c0660b3",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7388,
						conditions = 
						{
							
							{
								"f0437824-d26a-f9c8-93f5-d9c7c28eb888",
								true,
							},
							
							{
								"b44a41d5-d1d1-832b-b241-e93122c26cd9",
								true,
							},
							
							{
								"eebd6ecc-60e0-d8b9-b5a5-b526ae1233de",
								true,
							},
							
							{
								"371db8d1-f401-a100-a1b8-e024156517c6",
								true,
							},
							
							{
								"c03a3f10-1a1f-0bca-85d2-b4f6f90e6832",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "WAR Shake It Off",
						uuid = "b8a15693-b479-d4e5-aa4d-9204c6005847",
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
						name = "Sildihn criterion",
						uuid = "9112063b-96f4-79b7-84d8-7dfe845fc952",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "49fe20c4-f32d-5994-bcb0-a738a451697d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "781eb067-5fff-a6e0-b8d5-0f13542d9077",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "f0437824-d26a-f9c8-93f5-d9c7c28eb888",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Flash of Steel",
						spellIDList = 
						{
							30284,
							30287,
							30294,
							30321,
							30329,
							30643,
							30651,
							31282,
							31283,
						},
						uuid = "b44a41d5-d1d1-832b-b241-e93122c26cd9",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							3,
						},
						name = "Warrior",
						uuid = "eebd6ecc-60e0-d8b9-b5a5-b526ae1233de",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7388,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Shake It Off ready",
						uuid = "371db8d1-f401-a100-a1b8-e024156517c6",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 319",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Before enrage",
						uuid = "c03a3f10-1a1f-0bca-85d2-b4f6f90e6832",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Flash of Steel - WAR Shake It Off",
			uuid = "706bdf44-5a00-0c1b-bb26-56283acf358a",
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
						name = "Sildihn criterion",
						uuid = "e137db6f-4fa0-762c-8712-68ce02d3c98d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "9c4a6bdd-4278-9a7b-919e-8d2d39624357",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "7f8c308b-cf4e-ea6c-8e56-79102015103d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "ACR",
						conditions = 
						{
							
							{
								"2a326423-ef84-0a54-aa1d-7f06c30eb496",
								true,
							},
							
							{
								"5fbf5bfa-6a43-5b37-a9e7-6677535193a3",
								true,
							},
							
							{
								"55eb7820-fa4c-c496-9f44-695e16ccbb08",
								true,
							},
							
							{
								"34857045-a8fc-96f1-a0eb-c8cdb7eda361",
								true,
							},
							
							{
								"15b6852c-4798-a366-bb8b-52c16c7c6795",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						gVar = "ACR_RikuSCH3_Healbar_SacredSoil",
						name = "Sacred Soil - Gladiator",
						uuid = "5a472586-7912-ccfe-9920-21ba236b046e",
						variableTogglesType = 3,
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
						name = "Sildihn criterion",
						uuid = "d4e86287-81bd-f534-9782-9fd0badb44e2",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "90144db0-b516-81df-8fe8-57b4dc8230ea",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "f2dee8f6-03c2-e21d-a09f-043a1183ab32",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "2a326423-ef84-0a54-aa1d-7f06c30eb496",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Flash of Steel",
						spellIDList = 
						{
							30284,
							30287,
							30294,
							30321,
							30329,
							30643,
							30651,
							31282,
							31283,
						},
						uuid = "5fbf5bfa-6a43-5b37-a9e7-6677535193a3",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"H1\" and mySlot ~= \"H2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 28",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							28,
						},
						name = "Party roster: H1/H2 Scholar",
						uuid = "55eb7820-fa4c-c496-9f44-695e16ccbb08",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 188,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Sacred Soil ready",
						uuid = "34857045-a8fc-96f1-a0eb-c8cdb7eda361",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 319",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Before enrage",
						uuid = "15b6852c-4798-a366-bb8b-52c16c7c6795",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Flash of Steel - SCH Sacred Soil",
			uuid = "650ebea5-d681-23fc-9156-68481117e1ed",
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
						name = "Sildihn criterion",
						uuid = "8da0ee0f-19f0-77ec-baa1-f8fd1d037f49",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "47604d1b-79cf-fcf2-ac85-3cc9a8f647f7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "9ba70650-7ebd-3ba9-b55d-4995ff8cb618",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 25868,
						conditions = 
						{
							
							{
								"67cae4f4-e5d5-d50e-9ef3-8422af269f92",
								true,
							},
							
							{
								"0f114935-97e9-925b-b611-da43de265174",
								true,
							},
							
							{
								"e8fb6998-0cd4-0b46-b69a-f68f26cf7807",
								true,
							},
							
							{
								"332666fd-f0d3-b5c4-9ed4-587ac80c4f3a",
								true,
							},
							
							{
								"702b9170-faff-bbb2-adac-169581c02956",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "SCH Expedient",
						uuid = "43c8b993-045f-57ef-a268-a1e41c8453a0",
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
						name = "Sildihn criterion",
						uuid = "a6607fa3-5277-b9fe-b12f-dc1eb2b6b354",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "b0c4c212-47bb-4676-afce-c438bb0bcc50",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "50d6da00-b377-4933-a715-7b5369176518",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "67cae4f4-e5d5-d50e-9ef3-8422af269f92",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Flash of Steel",
						spellIDList = 
						{
							30284,
							30287,
							30294,
							30321,
							30329,
							30643,
							30651,
							31282,
							31283,
						},
						uuid = "0f114935-97e9-925b-b611-da43de265174",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"H1\" and mySlot ~= \"H2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 28",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							28,
						},
						name = "Party roster: H1/H2 Scholar",
						uuid = "e8fb6998-0cd4-0b46-b69a-f68f26cf7807",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 25868,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Expedient ready",
						uuid = "332666fd-f0d3-b5c4-9ed4-587ac80c4f3a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 319",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Before enrage",
						uuid = "702b9170-faff-bbb2-adac-169581c02956",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Flash of Steel - SCH Expedient",
			uuid = "d0ce3584-6dcf-4e93-b5bb-28623d86a721",
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
						name = "Sildihn criterion",
						uuid = "df82caac-c105-ff52-bc7f-6635d8a93fc6",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "b2fb703d-4ccd-12c1-adf7-fb4e951bb23e",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "2834a657-cd99-023c-aab3-5a06f7cd0f7d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16012,
						conditions = 
						{
							
							{
								"e578fb26-8ee4-7fe1-a17c-06fdddfcd14a",
								true,
							},
							
							{
								"528ba64f-afb9-cd52-8590-8eb59b828a9c",
								true,
							},
							
							{
								"5f20a22f-41f1-bdba-be2b-19590dc86abc",
								true,
							},
							
							{
								"5f4296a8-93f0-79fa-ab4b-d35dbb6dcf95",
								true,
							},
							
							{
								"e22d77ca-d9cd-6543-9330-f7f544aae975",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "DNC Shield Samba",
						uuid = "a39a187e-7b7d-c7d0-bb4f-354bb38c0743",
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
						name = "Sildihn criterion",
						uuid = "2408f137-c58a-5453-b84c-02ec104f5576",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "9887b494-5741-102b-b265-d73574d38743",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "df8a179b-87f8-0cd6-ade6-79ca29b37363",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "e578fb26-8ee4-7fe1-a17c-06fdddfcd14a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Flash of Steel",
						spellIDList = 
						{
							30284,
							30287,
							30294,
							30321,
							30329,
							30643,
							30651,
							31282,
							31283,
						},
						uuid = "528ba64f-afb9-cd52-8590-8eb59b828a9c",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"R1\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 38",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							38,
						},
						name = "Party roster: R1 physical ranged (Dancer)",
						uuid = "5f20a22f-41f1-bdba-be2b-19590dc86abc",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16012,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Shield Samba ready",
						uuid = "5f4296a8-93f0-79fa-ab4b-d35dbb6dcf95",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 319",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Before enrage",
						uuid = "e22d77ca-d9cd-6543-9330-f7f544aae975",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Flash of Steel - DNC Shield Samba",
			uuid = "cb033768-f884-4a8a-9d8d-2bc82ff5d66c",
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
						name = "Sildihn criterion",
						uuid = "0eaae134-72cb-f65b-93c9-837f3931495d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "d415eb0b-1b7d-2bc9-a3f6-dbb217dbbe56",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "b1b0bb29-8092-2cf3-abf6-91218dde874c",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7535,
						conditions = 
						{
							
							{
								"d4aa7c61-32e9-4b13-8427-841929453a7b",
								true,
							},
							
							{
								"d991f13f-1f97-76be-a7d0-10ae977fe02c",
								true,
							},
							
							{
								"dbe3ba64-be83-8ecc-a949-e5159764bfee",
								true,
							},
							
							{
								"9584a35f-bd4e-8ea1-9668-450b1194b7a2",
								true,
							},
							
							{
								"27db1125-16c2-53a4-b610-8fb3dd4ec9bf",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Tank Reprisal",
						targetType = "Event Entity",
						uuid = "a6f79fc4-b232-ee1e-9f5a-fd9a73fda77a",
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
						name = "Sildihn criterion",
						uuid = "11a5936c-ff09-b1f8-98c3-564fe5671e66",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "71d446f0-60cb-1b6a-8e9d-d7342aa7b76b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "3694e9fa-4e3a-3ad0-86a8-3f78c3e52897",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "d4aa7c61-32e9-4b13-8427-841929453a7b",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Sculptor's Passion",
						spellIDList = 
						{
							30282,
							30316,
							30638,
							31219,
							31220,
						},
						uuid = "d991f13f-1f97-76be-a7d0-10ae977fe02c",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							1,
							3,
							32,
							37,
						},
						name = "Tank jobs",
						uuid = "dbe3ba64-be83-8ecc-a949-e5159764bfee",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7535,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Reprisal ready",
						uuid = "9584a35f-bd4e-8ea1-9668-450b1194b7a2",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local entity = TensorCore.mGetEntity(eventArgs.entityID)\nreturn entity ~= nil and entity.targetable",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Boss targetable",
						uuid = "27db1125-16c2-53a4-b610-8fb3dd4ec9bf",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Sculptor's Passion - Tank Reprisal",
			uuid = "cf17c9e6-5909-9677-9c60-e92f41155bc7",
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
						name = "Sildihn criterion",
						uuid = "a83f3695-1818-d115-a440-03c0bdde01b1",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "1a31bc4c-95cb-348d-a8c8-b6373cd4ace7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "febec55b-6495-8cae-93b3-f0fdb41bd1fd",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "ACR",
						conditions = 
						{
							
							{
								"2a11ccd3-d895-726b-983e-6d3a018f07c4",
								true,
							},
							
							{
								"f4d13849-982d-5267-806a-ddaf8cbc8292",
								true,
							},
							
							{
								"4cc78ac9-54e0-13ff-8dbb-539174622b52",
								true,
							},
							
							{
								"d0df3957-d670-6f6a-b697-ca24387f3783",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						gVar = "ACR_RikuSCH3_Healbar_SacredSoil",
						name = "Sacred Soil - Gladiator",
						uuid = "2c33151b-6408-582c-8deb-d9dd075ad757",
						variableTogglesType = 3,
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
						name = "Sildihn criterion",
						uuid = "8dafd88b-e397-c734-a228-da62e93d4d72",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "4ac2c642-d688-e5a0-9dcc-17bfa1e83f3d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "75188f95-5511-2bec-a0aa-6996770b71e7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "2a11ccd3-d895-726b-983e-6d3a018f07c4",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Sculptor's Passion",
						spellIDList = 
						{
							30282,
							30316,
							30638,
							31219,
							31220,
						},
						uuid = "f4d13849-982d-5267-806a-ddaf8cbc8292",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"H1\" and mySlot ~= \"H2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 28",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							28,
						},
						name = "Party roster: H1/H2 Scholar",
						uuid = "4cc78ac9-54e0-13ff-8dbb-539174622b52",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 188,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Sacred Soil ready",
						uuid = "d0df3957-d670-6f6a-b697-ca24387f3783",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Sculptor's Passion - SCH Sacred Soil",
			uuid = "55e42d04-e9f7-f382-b29c-ff43b8e9b3e0",
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
						name = "Sildihn criterion",
						uuid = "b6d800e8-d514-7cb9-9a90-39926f2dd6e2",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "486c4b61-a27a-9137-aaba-554ebab2e844",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "c65d3e74-23d9-0b03-8e24-b43d8dafa826",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16538,
						conditions = 
						{
							
							{
								"31c61223-652f-2363-aea9-62efd9562b44",
								true,
							},
							
							{
								"be7b3193-8bb7-344d-b8a7-58809e0b5d48",
								true,
							},
							
							{
								"d1eded90-1909-47be-b537-1cfac03e611e",
								true,
							},
							
							{
								"b5c6a5d5-9b00-daff-8222-922892230d7c",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "SCH Fey Illumination",
						uuid = "0691b285-8914-bf03-a351-d4bbd96ea83d",
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
						name = "Sildihn criterion",
						uuid = "d7460e4b-6eab-cae9-8117-a650fe706d77",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "18034d15-993b-2427-8446-e63949bca987",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "2859a6b8-a593-5519-8669-4cdad9e64497",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "31c61223-652f-2363-aea9-62efd9562b44",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Sculptor's Passion",
						spellIDList = 
						{
							30282,
							30316,
							30638,
							31219,
							31220,
						},
						uuid = "be7b3193-8bb7-344d-b8a7-58809e0b5d48",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"H1\" and mySlot ~= \"H2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 28",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							28,
						},
						name = "Party roster: H1/H2 Scholar",
						uuid = "d1eded90-1909-47be-b537-1cfac03e611e",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16538,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Fey Illumination ready",
						uuid = "b5c6a5d5-9b00-daff-8222-922892230d7c",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Sculptor's Passion - SCH Fey Illumination",
			uuid = "909bca5f-b27a-e160-855a-f402a10d3ece",
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
						name = "Sildihn criterion",
						uuid = "27684129-8270-53eb-a119-9e3101a1c3cc",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "7f01410b-e8eb-fd5f-bbac-7dd42ea3ac38",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "e16050f3-9b92-7978-855f-ce863b3475d9",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7535,
						conditions = 
						{
							
							{
								"f9fb2f43-dd58-e316-8b63-13345c28e5c2",
								true,
							},
							
							{
								"8351648f-680a-ae23-8b60-cea2acf7eaae",
								true,
							},
							
							{
								"14a287b9-0fb8-b510-b082-c64bca37440c",
								true,
							},
							
							{
								"dda31306-bc88-ed6c-af79-b5d0c887cef8",
								true,
							},
							
							{
								"cff5163c-b89a-a41d-aff4-f3c8d1b31c41",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Tank Reprisal",
						targetType = "Event Entity",
						uuid = "8d8b0ed4-f727-23a0-b9eb-a7e76912c1d9",
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
						name = "Sildihn criterion",
						uuid = "2b9e17c6-6615-241d-b96c-3f41b57a615a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "e53ae460-0067-1681-8381-7c55c526f371",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "880c6a14-caa7-001e-9438-938917b5857a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "f9fb2f43-dd58-e316-8b63-13345c28e5c2",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Mighty Smite",
						spellIDList = 
						{
							30295,
							30322,
							30644,
						},
						uuid = "8351648f-680a-ae23-8b60-cea2acf7eaae",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							1,
							3,
							32,
							37,
						},
						name = "Tank jobs",
						uuid = "14a287b9-0fb8-b510-b082-c64bca37440c",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7535,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Reprisal ready",
						uuid = "dda31306-bc88-ed6c-af79-b5d0c887cef8",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local entity = TensorCore.mGetEntity(eventArgs.entityID)\nreturn entity ~= nil and entity.targetable",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Boss targetable",
						uuid = "cff5163c-b89a-a41d-aff4-f3c8d1b31c41",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Mighty Smite - Tank Reprisal",
			uuid = "fea339d0-6b38-d815-a7e1-7350c3040610",
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
						name = "Sildihn criterion",
						uuid = "d9c8420d-50b9-b778-8ff8-0d40aaf752eb",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "bd4c4456-df60-94dd-a757-8910eb357347",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "2e1ad08c-d5ad-7ebe-90b5-d7dac8833a7d",
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
								"364ade11-1eff-7d18-bd0a-366b1d3ba7b6",
								true,
							},
							
							{
								"f2b63664-50b0-edf4-a54b-8bd0467c72f5",
								true,
							},
							
							{
								"05ca63ed-1fe1-e40b-b527-cefc1e2d105b",
								true,
							},
							
							{
								"1481d0e0-cd7d-0163-aae6-7615bdb925d6",
								true,
							},
							
							{
								"3e772bbb-15b9-be95-8987-f5cc9eb19d9f",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Melee Feint",
						targetType = "Event Entity",
						uuid = "9c3766a8-cf30-f145-99d7-2bb0d34bd9c7",
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
						name = "Sildihn criterion",
						uuid = "ea72a58a-415c-b590-b326-f014bb46faa9",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "5b3cba89-1440-defc-b2d9-db7836c16c9f",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "0b4f111e-cf1f-578f-be73-ee8364dccaa5",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "364ade11-1eff-7d18-bd0a-366b1d3ba7b6",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Mighty Smite",
						spellIDList = 
						{
							30295,
							30322,
							30644,
						},
						uuid = "f2b63664-50b0-edf4-a54b-8bd0467c72f5",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"M1\" and mySlot ~= \"M2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 20 or job == 22 or job == 30 or job == 34 or job == 39 or job == 41",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							2,
							4,
							29,
							34,
							39,
							41,
						},
						name = "Party roster: M1/M2 melee",
						uuid = "05ca63ed-1fe1-e40b-b527-cefc1e2d105b",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7549,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Feint ready",
						uuid = "1481d0e0-cd7d-0163-aae6-7615bdb925d6",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local entity = TensorCore.mGetEntity(eventArgs.entityID)\nreturn entity ~= nil and entity.targetable",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Boss targetable",
						uuid = "3e772bbb-15b9-be95-8987-f5cc9eb19d9f",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Mighty Smite - Melee Feint",
			uuid = "0fcdda1d-fdd8-cb43-a676-8866dfb5afde",
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
						name = "Sildihn criterion",
						uuid = "62b0b105-76ce-98f6-9269-a8629c0f9688",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "d49a2034-c188-7b69-b837-e591d285d140",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "fd8dd536-050b-6249-bffb-52220b43999d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 44,
						conditions = 
						{
							
							{
								"62d96bb7-6c08-1d94-b72f-e6279af1d126",
								true,
							},
							
							{
								"b706e0a2-3159-c318-b94c-fbd0e5fe25a6",
								true,
							},
							
							{
								"66151f1e-a4a5-3720-9100-ada2902265f9",
								true,
							},
							
							{
								"cedaf5e8-0804-db1c-ad7b-1e6d916660c0",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "WAR Vengeance",
						uuid = "11b9d4e1-c37d-1884-9144-63d8693fd184",
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
						name = "Sildihn criterion",
						uuid = "86561769-b1d2-e308-a718-db765739caca",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "ce037dcf-d83e-1647-a828-c97194f5683f",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "2b03b3e4-e1e2-e84d-be42-02adbdaefc8f",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "62d96bb7-6c08-1d94-b72f-e6279af1d126",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Mighty Smite",
						spellIDList = 
						{
							30295,
							30322,
							30644,
						},
						uuid = "b706e0a2-3159-c318-b94c-fbd0e5fe25a6",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							3,
						},
						name = "Warrior",
						uuid = "66151f1e-a4a5-3720-9100-ada2902265f9",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 44,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Vengeance ready",
						uuid = "cedaf5e8-0804-db1c-ad7b-1e6d916660c0",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Mighty Smite - WAR Vengeance",
			uuid = "bddbcc1e-447c-bd72-91f0-c1a426998ae5",
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
						name = "Sildihn criterion",
						uuid = "17f3bcca-2f89-7f88-8a39-fad542b79b61",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "4366ee4f-2ca8-8ec1-b51c-69b608a9c77c",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "fa2ff83a-ea73-2a73-91c4-744be7fe9190",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7531,
						conditions = 
						{
							
							{
								"add11fab-4a1b-9064-8a3c-cc586d3a4a96",
								true,
							},
							
							{
								"73524f03-af24-9ac7-9287-5d64f6ae684e",
								true,
							},
							
							{
								"c63e86b6-4979-ef4a-bbbd-b19599cf453d",
								true,
							},
							
							{
								"14dbd1b2-c72b-8710-bc19-7bef24cc834a",
								true,
							},
							
							{
								"8fa4a429-ee97-62cb-9952-01d8ba47a36d",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "WAR Rampart fallback",
						uuid = "095dc540-b559-2d99-99bf-b655b033f852",
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
						name = "Sildihn criterion",
						uuid = "ded6a780-fed9-8b53-b844-ef2d1fe9fafa",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "b26e4dd4-2d3d-a9e9-8ca5-5cc81ac3e061",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "830e68f6-163c-2ff2-adfb-b75316c67110",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "add11fab-4a1b-9064-8a3c-cc586d3a4a96",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Mighty Smite",
						spellIDList = 
						{
							30295,
							30322,
							30644,
						},
						uuid = "73524f03-af24-9ac7-9287-5d64f6ae684e",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							3,
						},
						name = "Warrior",
						uuid = "c63e86b6-4979-ef4a-bbbd-b19599cf453d",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7531,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Rampart ready",
						uuid = "14dbd1b2-c72b-8710-bc19-7bef24cc834a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 44,
						category = "Self",
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Vengeance unavailable",
						uuid = "8fa4a429-ee97-62cb-9952-01d8ba47a36d",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Mighty Smite - WAR Rampart fallback",
			uuid = "c7f420cd-5df4-404c-a5bc-97337ab81bda",
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
						name = "Sildihn criterion",
						uuid = "6075c71f-408a-3d1b-94ef-1cf7308f0ecf",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "606a7811-dae0-5fa2-ab66-09a86630be89",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "25832b18-a2b2-434c-842c-691a44905679",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7535,
						conditions = 
						{
							
							{
								"e99da686-5352-28a5-ba54-6edec387efa5",
								true,
							},
							
							{
								"2825ee6d-c974-0bdf-8267-d6b25edf849c",
								true,
							},
							
							{
								"15f1cf37-693f-b79f-93fc-2bda5f9c8174",
								true,
							},
							
							{
								"8f7f099a-96e7-5c8d-b600-9d08e4d3297b",
								true,
							},
							
							{
								"3c793d9e-5390-dd06-b46c-a87f686ee6a5",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Tank Reprisal",
						targetType = "Event Entity",
						uuid = "83a54fc7-62fe-f998-a34d-638e02fed692",
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
						name = "Sildihn criterion",
						uuid = "6e6f1103-4052-384f-a201-bb043507ef85",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "255183fe-15a4-1a83-a1f7-5ebd12e58bff",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "ace6e83a-e520-624b-b843-eedf04e8ae88",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "e99da686-5352-28a5-ba54-6edec387efa5",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Nothing Beside Remains",
						spellIDList = 
						{
							30347,
							30348,
							30652,
							30653,
						},
						uuid = "2825ee6d-c974-0bdf-8267-d6b25edf849c",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							1,
							3,
							32,
							37,
						},
						name = "Tank jobs",
						uuid = "15f1cf37-693f-b79f-93fc-2bda5f9c8174",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7535,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Reprisal ready",
						uuid = "8f7f099a-96e7-5c8d-b600-9d08e4d3297b",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local entity = TensorCore.mGetEntity(eventArgs.entityID)\nreturn entity ~= nil and entity.targetable",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Boss targetable",
						uuid = "3c793d9e-5390-dd06-b46c-a87f686ee6a5",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Nothing Beside Remains - Tank Reprisal",
			uuid = "53b96c8a-4864-a439-957e-054ada12b611",
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
						name = "Sildihn criterion",
						uuid = "1d400159-ed1d-876c-b56c-39e1216b5580",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "479ef76b-1fe8-1198-ad70-2b5b63229732",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "afaf78fc-b43d-7780-80f8-0745bc92ef57",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "ACR",
						conditions = 
						{
							
							{
								"f7e9738b-ea6c-b2bd-b488-093d4bc9a9c1",
								true,
							},
							
							{
								"944fbc52-f238-ec66-b07d-b03368fd5595",
								true,
							},
							
							{
								"66943017-d983-3885-94ad-d4a84da71a01",
								true,
							},
							
							{
								"a923e778-263d-71d4-a867-de4b38c54f6d",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						gVar = "ACR_RikuSCH3_Healbar_SacredSoil",
						name = "Sacred Soil - Gladiator",
						uuid = "f99db521-487f-08d8-a056-fb8117f8b1cc",
						variableTogglesType = 3,
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
						name = "Sildihn criterion",
						uuid = "c1b6fa92-7ef5-4c2f-babf-273485646fe5",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "c4aeef36-bc3b-7cea-9d0c-a11a6cc9c33e",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "4e45da52-5949-fc1a-8238-bd27e26685af",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "f7e9738b-ea6c-b2bd-b488-093d4bc9a9c1",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Nothing Beside Remains",
						spellIDList = 
						{
							30347,
							30348,
							30652,
							30653,
						},
						uuid = "944fbc52-f238-ec66-b07d-b03368fd5595",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"H1\" and mySlot ~= \"H2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 28",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							28,
						},
						name = "Party roster: H1/H2 Scholar",
						uuid = "66943017-d983-3885-94ad-d4a84da71a01",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 188,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Sacred Soil ready",
						uuid = "a923e778-263d-71d4-a867-de4b38c54f6d",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Nothing Beside Remains - SCH Sacred Soil",
			uuid = "4fd71621-a3df-105d-a8f9-9f169d9b370e",
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
						name = "Sildihn criterion",
						uuid = "b90ec400-76be-b208-8fbc-2bea6bad7429",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "4c22715a-8bba-1d00-8d3c-b9247d4854cf",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "4f358cee-0a6e-5c28-8520-355381cef1f5",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "ACR",
						conditions = 
						{
							
							{
								"e59f86e9-a95b-48fa-9f81-854025f42934",
								true,
							},
							
							{
								"094716ae-c9ab-20a9-a44d-5832923ccfcc",
								true,
							},
							
							{
								"55155d80-da3f-405a-befa-c8ed48b1a0a0",
								true,
							},
							
							{
								"900b924b-e011-277b-acae-005ab745095e",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						gVar = "ACR_RikuSCH3_Healbar_SacredSoil",
						name = "Sacred Soil - Towers",
						uuid = "ed78cad5-34f5-eaa5-89a0-196db90e5b20",
						variableTogglesType = 3,
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
						name = "Sildihn criterion",
						uuid = "17f727a6-ed15-2712-b7ae-3e7faf9c8720",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "3dec9883-ec1c-76e7-bdd8-6b440e0003e7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "0d55343c-d791-6e1f-9e88-f31a0c310ef6",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "e59f86e9-a95b-48fa-9f81-854025f42934",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Colossal Wreck",
						spellIDList = 
						{
							30313,
							30635,
						},
						uuid = "094716ae-c9ab-20a9-a44d-5832923ccfcc",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							28,
						},
						name = "Scholar",
						uuid = "55155d80-da3f-405a-befa-c8ed48b1a0a0",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 188,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "SCH Sacred Soil ready",
						uuid = "900b924b-e011-277b-acae-005ab745095e",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			enabled = false,
			eventType = 3,
			name = "[Mit] Colossal Wreck - SCH Sacred Soil (disabled: tower spread)",
			uuid = "8613936c-b8b6-2b91-9eef-8ac9b7a8b057",
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
						name = "Sildihn criterion",
						uuid = "502462ea-7099-5963-916f-39f579a2f53c",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "c76fdaec-8646-5379-8b33-3bcbd4fe790e",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "058c33b1-8a77-8af6-a02d-8d75fcdaf17d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7388,
						conditions = 
						{
							
							{
								"518feeae-fa18-5435-a34c-c6227a6e05d4",
								true,
							},
							
							{
								"6f0ba2db-a588-d145-a365-76e53968f25e",
								true,
							},
							
							{
								"41cf7298-fc4f-becd-835b-037fca20fee8",
								true,
							},
							
							{
								"9d42eed3-967c-b6b8-ad8a-eba92a79c11b",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "WAR Shake It Off",
						uuid = "70c50a01-58ff-be50-9e6a-4636d1375141",
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
						name = "Sildihn criterion",
						uuid = "252e5c8c-6a96-78fb-8934-a047839dd393",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "0f4c80ff-08f2-4be5-814d-850100a0592b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "29d85345-7740-6250-bc28-ad35fcebb113",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "518feeae-fa18-5435-a34c-c6227a6e05d4",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Colossal Wreck",
						spellIDList = 
						{
							30313,
							30635,
						},
						uuid = "6f0ba2db-a588-d145-a365-76e53968f25e",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							3,
						},
						name = "Warrior",
						uuid = "41cf7298-fc4f-becd-835b-037fca20fee8",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7388,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "WAR Shake It Off ready",
						uuid = "9d42eed3-967c-b6b8-ad8a-eba92a79c11b",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Colossal Wreck - WAR Shake It Off",
			uuid = "686d47ac-f7dd-a637-b391-dc6fc502dcc3",
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
						name = "Sildihn criterion",
						uuid = "7b7d864e-46ba-ac7a-b48d-238ece5c1a3f",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "5084dbed-60a3-e6a2-8a46-6fda43775221",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "0b501ba5-73e6-9a09-b30a-5b5f0cf4ba55",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16012,
						conditions = 
						{
							
							{
								"a7131293-fb57-5e45-b300-d1784e8693a7",
								true,
							},
							
							{
								"c6c8f0f2-a6b5-b55e-be42-f47116cb8900",
								true,
							},
							
							{
								"acdc9919-2ce7-4a60-b5ef-5b5532b0dc86",
								true,
							},
							
							{
								"a082d46c-65d1-72a8-bfad-b3aba5bd35bd",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "DNC Shield Samba",
						uuid = "db5fc130-6f12-ff22-a8d7-f2f96dfb1137",
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
						name = "Sildihn criterion",
						uuid = "96e0aa21-bd86-6851-bffd-b8d945e667a7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "fdf3ce2a-a81b-0abf-92d1-9496ee011e2d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "2acfbe4d-76c2-b554-b4e3-702f23354830",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "a7131293-fb57-5e45-b300-d1784e8693a7",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Colossal Wreck",
						spellIDList = 
						{
							30313,
							30635,
						},
						uuid = "c6c8f0f2-a6b5-b55e-be42-f47116cb8900",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"R1\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 38",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							38,
						},
						name = "Party roster: R1 physical ranged (Dancer)",
						uuid = "acdc9919-2ce7-4a60-b5ef-5b5532b0dc86",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16012,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "DNC Shield Samba ready",
						uuid = "a082d46c-65d1-72a8-bfad-b3aba5bd35bd",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Colossal Wreck - DNC Shield Samba",
			uuid = "dbac092e-5f7e-18c0-b951-c58ce7eeafda",
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
						name = "Sildihn criterion",
						uuid = "7bfe4784-7a85-1e28-9147-0197babcbb24",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "8d4d1aae-da96-5539-b543-101dd914e739",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "acf5901b-3588-36df-8a01-f0f490141692",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16015,
						conditions = 
						{
							
							{
								"a56f9dcd-19e2-5fa2-bcb1-ba46e62266a1",
								true,
							},
							
							{
								"0218296e-c917-a1bc-9262-12065a32029f",
								true,
							},
							
							{
								"3f017f16-9c9d-35c9-9a13-f9486d3ffddf",
								true,
							},
							
							{
								"680c2496-c484-4ddd-9a69-348ec8263821",
								true,
							},
							
							{
								"52e73958-86fd-d357-9342-aad694156ad4",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "DNC Curing Waltz",
						uuid = "9e5af1ee-3486-4500-8aa4-679800ac8a31",
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
						name = "Sildihn criterion",
						uuid = "008ad655-8cc8-8687-8e85-b1d9e24de4db",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "988cabc1-e465-96c3-afd6-81b63f382a45",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "d04c3fd5-aae6-445b-8902-d9b6f2fc802a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "a56f9dcd-19e2-5fa2-bcb1-ba46e62266a1",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Raidwide damage",
						spellIDList = 
						{
							30284,
							30287,
							30294,
							30321,
							30329,
							30643,
							30651,
							31282,
							31283,
							30282,
							30316,
							30638,
							31219,
							31220,
							30347,
							30348,
							30652,
							30653,
						},
						uuid = "0218296e-c917-a1bc-9262-12065a32029f",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"R1\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 38",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							38,
						},
						name = "Party roster: R1 physical ranged (Dancer)",
						uuid = "3f017f16-9c9d-35c9-9a13-f9486d3ffddf",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16015,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Curing Waltz ready",
						uuid = "680c2496-c484-4ddd-9a69-348ec8263821",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 319",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Before enrage",
						uuid = "52e73958-86fd-d357-9342-aad694156ad4",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 2,
			name = "[Heal] Gladiator of Sil'dih - Curing Waltz",
			uuid = "cc915b0a-9425-7c35-9e3c-58e76b5b9ffc",
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
						name = "Sildihn criterion",
						uuid = "f514992d-3282-620e-a112-57d346869cc8",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "23e83291-026d-223d-b7bc-22204311772b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "96849d73-e416-49a8-9b4b-aa8b98ec3d5b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16537,
						conditions = 
						{
							
							{
								"0301c3c5-5f72-3015-acbf-4ab0fd83768b",
								true,
							},
							
							{
								"909979d2-4fae-08e1-885b-393ff826df82",
								true,
							},
							
							{
								"007a64ea-566c-0abf-9904-6a1a89f7ca25",
								true,
							},
							
							{
								"e7bdb639-f016-2e73-97e6-d1d492555a35",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "SCH Whispering Dawn",
						uuid = "3c070f25-655c-f8f1-8163-0f329e4240c0",
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
						name = "Sildihn criterion",
						uuid = "c34e9c19-c7b9-1d1b-9572-292c163ba4b3",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "1dea0ba6-6ea6-838c-8082-1d6ed055a012",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "86aa7e43-e279-0d41-829f-c95f3498ea61",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "0301c3c5-5f72-3015-acbf-4ab0fd83768b",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Sculptor / tower setup",
						spellIDList = 
						{
							30282,
							30316,
							30638,
							31219,
							31220,
							30313,
							30635,
						},
						uuid = "909979d2-4fae-08e1-885b-393ff826df82",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"H1\" and mySlot ~= \"H2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 28",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							28,
						},
						name = "Party roster: H1/H2 Scholar",
						uuid = "007a64ea-566c-0abf-9904-6a1a89f7ca25",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16537,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Whispering Dawn ready",
						uuid = "e7bdb639-f016-2e73-97e6-d1d492555a35",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit/Heal] Gladiator of Sil'dih - SCH Whispering Dawn",
			uuid = "b5ac0385-b39f-be73-97c4-cd6134a216da",
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
						name = "Sildihn criterion",
						uuid = "90bad7c8-38c3-01af-b50f-2eec65002cf8",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "3a45d655-01ed-8012-b82e-cf9aa9ed0ccf",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "46a2f0b7-a714-8698-b6f9-cbbdea60baab",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7437,
						conditions = 
						{
							
							{
								"019db9db-c745-d311-ad3e-a4d6686da0bc",
								true,
							},
							
							{
								"e2cb191e-a5af-fe0b-b82d-f59a752660ac",
								true,
							},
							
							{
								"8435f515-8d3f-de6a-89c2-35d13d941fb5",
								true,
							},
							
							{
								"6ec917dc-9236-aab7-800b-2e05b9017492",
								true,
							},
							
							{
								"c16cbec3-dde4-c6be-af59-2718609b162b",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "SCH Aetherpact",
						targetType = "Event Target",
						uuid = "459d3675-09f6-af8e-b61b-3167dafc2df1",
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
						name = "Sildihn criterion",
						uuid = "3c23394a-a06f-d414-9dab-928a78400091",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "fc40dbee-166a-ff93-8a36-ac9e91d3ee14",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "388e66d1-d685-1f8c-8264-c1a0d363faa7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "019db9db-c745-d311-ad3e-a4d6686da0bc",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Mighty Smite",
						spellIDList = 
						{
							30295,
							30322,
							30644,
						},
						uuid = "e2cb191e-a5af-fe0b-b82d-f59a752660ac",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"H1\" and mySlot ~= \"H2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 28",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							28,
						},
						name = "Party roster: H1/H2 Scholar",
						uuid = "8435f515-8d3f-de6a-89c2-35d13d941fb5",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 6,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						gaugeIndex = 2,
						gaugeValue = 10,
						name = "Fey Gauge (10+)",
						uuid = "6ec917dc-9236-aab7-800b-2e05b9017492",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7437,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Aetherpact ready",
						uuid = "c16cbec3-dde4-c6be-af59-2718609b162b",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit/Utility] Mighty Smite - SCH Aetherpact",
			uuid = "eb1758b7-4f0a-ce77-8bd2-7c6633f36678",
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
						name = "Sildihn criterion",
						uuid = "7ce29e38-0bf3-7898-9a78-813998869bc8",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "f6bf7c79-4298-8b5d-8100-012c5deb505d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "6ec6ab6b-7655-a0fa-9e0b-c9bc22948a7a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16543,
						conditions = 
						{
							
							{
								"2a0f5e1e-4414-9624-afb2-8ef6cfbeef53",
								true,
							},
							
							{
								"6274471b-75b3-06e2-a4cf-85a845390c2d",
								true,
							},
							
							{
								"938c7c9c-bfc2-7a2b-9c41-2f0d7e2a3d76",
								true,
							},
							
							{
								"5652ffad-fb89-4d85-b5a8-0ee53ad40120",
								true,
							},
							
							{
								"2841d830-168e-1755-8067-71c839ae94ce",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "SCH Fey Blessing",
						uuid = "ea207656-e4df-7d24-8691-38a642ab395a",
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
						name = "Sildihn criterion",
						uuid = "9462a0f2-b953-3c5d-83da-09d9dd0bff3c",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "321c71ec-7d13-d205-b8f2-67dc362b7abd",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "43c6b842-44b2-40d0-ace4-0a1ec0b07a2c",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "2a0f5e1e-4414-9624-afb2-8ef6cfbeef53",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Flash / Nothing",
						spellIDList = 
						{
							30284,
							30287,
							30294,
							30321,
							30329,
							30643,
							30651,
							31282,
							31283,
							30347,
							30348,
							30652,
							30653,
						},
						uuid = "6274471b-75b3-06e2-a4cf-85a845390c2d",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"H1\" and mySlot ~= \"H2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 28",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							28,
						},
						name = "Party roster: H1/H2 Scholar",
						uuid = "938c7c9c-bfc2-7a2b-9c41-2f0d7e2a3d76",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16543,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Fey Blessing ready",
						uuid = "5652ffad-fb89-4d85-b5a8-0ee53ad40120",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer >= 140 and TensorReactions_CurrentCombatTimer < 319",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Blessing window (2:20-5:19)",
						uuid = "2841d830-168e-1755-8067-71c839ae94ce",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Heal] Gladiator of Sil'dih - SCH Fey Blessing",
			uuid = "6bbf8061-9d89-25e5-af27-4bdc980c3102",
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
						name = "Sildihn criterion",
						uuid = "6863fd42-e565-b1ae-b56a-e09e90efe8c2",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "fba444d6-f528-3e16-8e9c-29f1e224b630",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "1d4bdbef-909d-7e5e-85cb-8c984f199d76",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 3540,
						conditions = 
						{
							
							{
								"782ef937-b652-5287-a4f4-d4604c3b5942",
								true,
							},
							
							{
								"0e573d6f-7398-2855-a7da-79a867bdc50f",
								true,
							},
							
							{
								"5f7f6c26-012f-cc4a-a4ef-dcffc3ffb64a",
								true,
							},
							
							{
								"e3939ba4-e8cc-0742-a017-31000b20f2ad",
								true,
							},
							
							{
								"3b55548b-bfa1-8d8b-a46a-170a9d50b7fa",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Divine Veil",
						uuid = "f31dc0dd-a133-4c49-8702-a0c419485ca0",
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
						name = "Sildihn criterion",
						uuid = "f2ebf82a-8c03-e1b5-a7f4-5ad2e2728c09",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "20428d96-1b53-e2e2-853a-17aef676cbd8",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "f0efd31c-2b80-d6ed-81bc-537d4f4f121e",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "782ef937-b652-5287-a4f4-d4604c3b5942",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Flash of Steel",
						spellIDList = 
						{
							30284,
							30287,
							30294,
							30321,
							30329,
							30643,
							30651,
							31282,
							31283,
						},
						uuid = "0e573d6f-7398-2855-a7da-79a867bdc50f",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							19,
						},
						name = "Paladin",
						uuid = "5f7f6c26-012f-cc4a-a4ef-dcffc3ffb64a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 3540,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Divine Veil ready",
						uuid = "e3939ba4-e8cc-0742-a017-31000b20f2ad",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 319",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Before enrage",
						uuid = "3b55548b-bfa1-8d8b-a46a-170a9d50b7fa",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Flash of Steel - Divine Veil",
			uuid = "8807abdd-5d2d-c5de-a7f8-0753427808da",
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
						name = "Sildihn criterion",
						uuid = "4e4a1ebb-e029-c345-b548-a495b2a72db6",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "a17c18c5-55ef-f67c-8022-67f2bd9127db",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "9676caa3-8e1a-03c2-8b6b-3b62d52802e0",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16160,
						conditions = 
						{
							
							{
								"96ef73b0-d94f-36ab-b626-04135e3772a3",
								true,
							},
							
							{
								"0017a3be-bc8e-73d6-8329-3a3d492f3f2b",
								true,
							},
							
							{
								"abacd1c8-8895-1f3b-a559-e23958f34daf",
								true,
							},
							
							{
								"5b731a16-bf5a-e93c-91c7-7f81efd6c8ca",
								true,
							},
							
							{
								"e6268279-d61d-1beb-a373-b890db18956c",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Heart of Light",
						uuid = "ae5e75ee-40ed-3487-a0dc-7c646e7d657a",
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
						name = "Sildihn criterion",
						uuid = "7f0d110b-35d1-3705-9be0-f71447d5674b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "3f96ed30-1653-d80b-a41f-2bd0ef27b674",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "c552ca3b-bf88-3783-97eb-ba80dda3f85a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "96ef73b0-d94f-36ab-b626-04135e3772a3",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Flash of Steel",
						spellIDList = 
						{
							30284,
							30287,
							30294,
							30321,
							30329,
							30643,
							30651,
							31282,
							31283,
						},
						uuid = "0017a3be-bc8e-73d6-8329-3a3d492f3f2b",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							37,
						},
						name = "Gunbreaker",
						uuid = "abacd1c8-8895-1f3b-a559-e23958f34daf",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16160,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Heart of Light ready",
						uuid = "5b731a16-bf5a-e93c-91c7-7f81efd6c8ca",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 319",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Before enrage",
						uuid = "e6268279-d61d-1beb-a373-b890db18956c",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Flash of Steel - Heart of Light",
			uuid = "72616e77-88be-14dd-b82f-a000d05021f8",
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
						name = "Sildihn criterion",
						uuid = "88cf662b-841c-be55-9f12-39633fd74597",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "dab1ff19-f1f3-dd78-955d-81eccf9efa51",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "ae52c983-2b0b-5606-b952-422469a94542",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16471,
						conditions = 
						{
							
							{
								"474c8b75-de50-3f45-918d-f3b952e27100",
								true,
							},
							
							{
								"993062d0-48c7-ca7b-b0e7-a8d43281d38a",
								true,
							},
							
							{
								"ab99eeff-46b5-5a88-9c39-c88563395c1a",
								true,
							},
							
							{
								"806e202b-c245-ff42-8a7c-a11c9dfd2284",
								true,
							},
							
							{
								"2e316f10-bb3a-c5ed-8c79-de8f5f82255c",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Dark Missionary",
						uuid = "508b6398-d3a2-5e15-b019-2a8c0b4527e2",
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
						name = "Sildihn criterion",
						uuid = "a81d4279-abc3-ddbb-bfa6-7a845b36cbd8",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "5e3f4748-5f2b-448f-b809-cf8df9d542f0",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Gladiator of Sil'dih",
						uuid = "d1684c0f-b9db-82ad-a63f-99538b7583d9",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 2,
						eventEntityContentID = 11387,
						name = "Gladiator of Sil'dih",
						uuid = "474c8b75-de50-3f45-918d-f3b952e27100",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Flash of Steel",
						spellIDList = 
						{
							30284,
							30287,
							30294,
							30321,
							30329,
							30643,
							30651,
							31282,
							31283,
						},
						uuid = "993062d0-48c7-ca7b-b0e7-a8d43281d38a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						jobIDList = 
						{
							32,
						},
						name = "Dark Knight",
						uuid = "ab99eeff-46b5-5a88-9c39-c88563395c1a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16471,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Dark Missionary ready",
						uuid = "806e202b-c245-ff42-8a7c-a11c9dfd2284",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 319",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
						name = "Before enrage",
						uuid = "2e316f10-bb3a-c5ed-8c79-de8f5f82255c",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Gladiator of Sil'dih",
			eventType = 3,
			name = "[Mit] Flash of Steel - Dark Missionary",
			uuid = "245b0f72-6659-8255-a66d-310db77019ea",
			version = 2,
		},
	},
	
	{
		data = 
		{
			displayPath = "Sildihn criterion/Mitigations",
			name = "Zeless Gah",
			uuid = "02c49af8-140e-2872-a079-26f77ae89e00",
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
						name = "Sildihn criterion",
						uuid = "f795091f-bf8d-1db7-86ec-7c0287a6927b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "a07e2af6-07a2-cab0-a35c-980eda153e68",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "ba44c901-e64f-2578-93a5-ba6c2319079a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 3540,
						conditions = 
						{
							
							{
								"39698d88-199c-2aed-9520-a5de155f047c",
								true,
							},
							
							{
								"b22f8417-e694-09c9-bbd8-ce23d0e6da1e",
								true,
							},
							
							{
								"49e1481f-9e18-addf-9f31-f68b7ea06c46",
								true,
							},
							
							{
								"4ae95513-9a25-13ff-b692-79617dc36eba",
								true,
							},
							
							{
								"07ddad09-1c3f-c41f-affe-4cc606174e5d",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Divine Veil",
						uuid = "6f6f0bff-9a77-e47d-b21c-54d33da82287",
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
						name = "Sildihn criterion",
						uuid = "705a8e02-9d1d-516f-bfdf-93ff51aaf392",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "0bd3af6f-0a68-b3b3-b515-69b85ff8c42b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "6774066c-506c-d43b-8ccb-d0fb67d4623f",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "39698d88-199c-2aed-9520-a5de155f047c",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29871,
						name = "Show of Strength",
						uuid = "b22f8417-e694-09c9-bbd8-ce23d0e6da1e",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						jobIDList = 
						{
							19,
						},
						name = "Paladin",
						uuid = "49e1481f-9e18-addf-9f31-f68b7ea06c46",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 3540,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Divine Veil ready",
						uuid = "4ae95513-9a25-13ff-b692-79617dc36eba",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 333",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Before enrage",
						uuid = "07ddad09-1c3f-c41f-affe-4cc606174e5d",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Mit] Zeless Show of Strength - Divine Veil",
			uuid = "c70f7cd0-5356-ea84-81eb-a5e33581eca4",
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
						name = "Sildihn criterion",
						uuid = "0fb44812-57bc-a63b-91e4-adecd81e87b1",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "ea117dfe-8ebe-a304-a0c2-5704e27ceb77",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "0101a652-c40e-7d36-af46-7a0282f3018b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16160,
						conditions = 
						{
							
							{
								"8ff1a6c9-f008-add6-9c0d-2ddd26eaecb1",
								true,
							},
							
							{
								"2c4ab0b1-81e8-53e4-ade7-03c4d4a12f97",
								true,
							},
							
							{
								"d5cb66d8-35eb-feaa-8358-35f633f20540",
								true,
							},
							
							{
								"182f0b2b-e31c-f6ea-8e70-2139f4b8015e",
								true,
							},
							
							{
								"b38b54f3-fd3f-fa6c-b030-e44e7c2d2bbe",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Heart of Light",
						uuid = "34c75874-8fa9-ac3d-bdc8-68b27dd6f2ad",
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
						name = "Sildihn criterion",
						uuid = "da4bd10e-8239-5b63-8d2d-5d7208702910",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "dcec9823-603a-98d0-8280-c4390e5da1da",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "d48d184b-7f32-0ca5-9901-2e7b2dfd43ee",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "8ff1a6c9-f008-add6-9c0d-2ddd26eaecb1",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29871,
						name = "Show of Strength",
						uuid = "2c4ab0b1-81e8-53e4-ade7-03c4d4a12f97",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						jobIDList = 
						{
							37,
						},
						name = "Gunbreaker",
						uuid = "d5cb66d8-35eb-feaa-8358-35f633f20540",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16160,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Heart of Light ready",
						uuid = "182f0b2b-e31c-f6ea-8e70-2139f4b8015e",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 333",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Before enrage",
						uuid = "b38b54f3-fd3f-fa6c-b030-e44e7c2d2bbe",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Mit] Zeless Show of Strength - Heart of Light",
			uuid = "bff31a5f-21d8-df19-b0a8-8212252efd99",
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
						name = "Sildihn criterion",
						uuid = "6037d689-0731-bb23-967d-2e1e3bc03012",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "97d39367-12dd-e8d4-a35d-d58c1c3ffd17",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "4762972a-f20e-fd0c-8f1a-6cf5dd33bd8a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16471,
						conditions = 
						{
							
							{
								"dbe44c4f-6e7a-1e3a-a1a4-2d95ae3c8212",
								true,
							},
							
							{
								"c3489641-28ea-3a91-9576-386a6b6307f6",
								true,
							},
							
							{
								"b792069a-d65e-f32e-b650-0612d2c839b0",
								true,
							},
							
							{
								"e9f940d8-9081-b38d-a2d2-d40133318ea2",
								true,
							},
							
							{
								"36a4df63-e76a-4be4-8a14-db9ef3436c26",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Dark Missionary",
						uuid = "10756843-91b9-c8fd-9f98-452dca2607fe",
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
						name = "Sildihn criterion",
						uuid = "4cf38f01-47a2-00b7-972a-7de93b61caf9",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "9db35ebd-a61a-938b-8d43-089320a8bb76",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "d6649233-d06a-0cde-8b7a-ea058876fe12",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "dbe44c4f-6e7a-1e3a-a1a4-2d95ae3c8212",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29871,
						name = "Show of Strength",
						uuid = "c3489641-28ea-3a91-9576-386a6b6307f6",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						jobIDList = 
						{
							32,
						},
						name = "Dark Knight",
						uuid = "b792069a-d65e-f32e-b650-0612d2c839b0",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16471,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Dark Missionary ready",
						uuid = "e9f940d8-9081-b38d-a2d2-d40133318ea2",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 333",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Before enrage",
						uuid = "36a4df63-e76a-4be4-8a14-db9ef3436c26",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Mit] Zeless Show of Strength - Dark Missionary",
			uuid = "55b2938f-bcbd-41ea-951c-10de3e628940",
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
						name = "Sildihn criterion",
						uuid = "31c52352-4c13-3e16-98b9-40676182acee",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "4f203c4f-115f-e661-9d4c-d77143b4d621",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "9be437d9-9e05-2ef9-bb2d-5218fb013f34",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7388,
						conditions = 
						{
							
							{
								"b16da9f2-8cb8-2f95-bc1b-112bd96c4db1",
								true,
							},
							
							{
								"83113ffc-8370-aeb1-b3a1-b5f0f1e731a5",
								true,
							},
							
							{
								"e7eda0d4-fecc-c3bd-aa7a-83da3b2c640d",
								true,
							},
							
							{
								"a7ec7d0a-1754-940a-bd47-e44a1ac36b26",
								true,
							},
							
							{
								"1bed7e0a-fa2c-017e-949c-4c56b97b0e2f",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Shake It Off",
						uuid = "8a15e299-42fc-b014-bf62-a68483943c67",
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
						name = "Sildihn criterion",
						uuid = "3f004b49-8a2a-b552-86dc-fc8c63760e3a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "ea09357c-1472-084d-8e31-ba7995b8b9d8",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "787f3df0-a412-67a1-94c6-872ba0e7800e",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "b16da9f2-8cb8-2f95-bc1b-112bd96c4db1",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29871,
						name = "Show of Strength",
						uuid = "83113ffc-8370-aeb1-b3a1-b5f0f1e731a5",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						jobIDList = 
						{
							3,
						},
						name = "Warrior",
						uuid = "e7eda0d4-fecc-c3bd-aa7a-83da3b2c640d",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7388,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Shake It Off ready",
						uuid = "a7ec7d0a-1754-940a-bd47-e44a1ac36b26",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 333",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Before enrage",
						uuid = "1bed7e0a-fa2c-017e-949c-4c56b97b0e2f",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Mit] Zeless Show of Strength - WAR Shake It Off",
			uuid = "5ce32b8d-8ffa-86ea-8474-147c5867c800",
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
						name = "Sildihn criterion",
						uuid = "c280e9c8-39db-615b-a878-a9a431c43e2d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "f26aaf61-38a4-57aa-a6a9-4530bd3ed431",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "1b1139c1-b594-a844-ae62-13037f05bcf2",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 44,
						conditions = 
						{
							
							{
								"ed641335-d1b2-0d8c-9a52-8f601bd80197",
								true,
							},
							
							{
								"fabc4009-83b2-654e-9d6e-200561a4d809",
								true,
							},
							
							{
								"9c6c4333-a99f-ead3-b522-95ae333a6ed1",
								true,
							},
							
							{
								"3f101b52-0e60-9ff8-93e7-03eef0152e04",
								true,
							},
							
							{
								"412f9423-ca06-718c-b44c-534658e7f6d8",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Vengeance",
						uuid = "8d007f79-011d-7b41-9743-6f84062d01cb",
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
						name = "Sildihn criterion",
						uuid = "1aed33da-c5e5-9824-b886-0cad10b515f9",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "d7309b5c-1fde-b633-985f-88b47e740fef",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "9b6565b1-81b3-1986-abf7-157629b5a425",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "ed641335-d1b2-0d8c-9a52-8f601bd80197",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29872,
						name = "Firesteel Strike",
						uuid = "fabc4009-83b2-654e-9d6e-200561a4d809",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						jobIDList = 
						{
							3,
						},
						name = "Warrior",
						uuid = "9c6c4333-a99f-ead3-b522-95ae333a6ed1",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 44,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Vengeance ready",
						uuid = "3f101b52-0e60-9ff8-93e7-03eef0152e04",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 333",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Before enrage",
						uuid = "412f9423-ca06-718c-b44c-534658e7f6d8",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Mit] Zeless Firesteel Strike - WAR Vengeance",
			uuid = "6da35853-a100-4bb8-b2e2-d2ffb53798fd",
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
						name = "Sildihn criterion",
						uuid = "c443b597-bd68-28d4-a52b-9379bc2fd0eb",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "5bf3cd9a-efed-f047-b145-0107a5fcea66",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "3befd9b3-a7f6-2cb6-b84a-b4b1c183bc80",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7531,
						conditions = 
						{
							
							{
								"6664293e-8443-cd35-83c2-010e167b66b7",
								true,
							},
							
							{
								"fe91b0aa-babe-6207-a741-bbc3b95c168b",
								true,
							},
							
							{
								"ba8971be-287f-f46c-9275-8c93b6b3bd97",
								true,
							},
							
							{
								"2e0a29ca-991d-9661-81ed-1d1dc990d3f5",
								true,
							},
							
							{
								"1f18992b-5a33-3121-a06e-d3af7397edd2",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Rampart",
						uuid = "23fac3c3-54aa-8ebc-bdfc-e39eb7999c3b",
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
						name = "Sildihn criterion",
						uuid = "a393c1be-34bc-851c-b0a1-e47c171574dc",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "34404349-e677-a645-b79e-ac9adaa4ff1d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "3b2c2635-021c-de32-aacf-55516043cc3e",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "6664293e-8443-cd35-83c2-010e167b66b7",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Firesteel Fracture",
						spellIDList = 
						{
							29868,
							29869,
							30404,
						},
						uuid = "fe91b0aa-babe-6207-a741-bbc3b95c168b",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						jobIDList = 
						{
							3,
						},
						name = "Warrior",
						uuid = "ba8971be-287f-f46c-9275-8c93b6b3bd97",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7531,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Rampart ready",
						uuid = "2e0a29ca-991d-9661-81ed-1d1dc990d3f5",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 333",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Before enrage",
						uuid = "1f18992b-5a33-3121-a06e-d3af7397edd2",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Mit] Zeless Firesteel Fracture - WAR Rampart",
			uuid = "48199c53-a27a-614a-8393-816afdd3dad2",
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
						name = "Sildihn criterion",
						uuid = "da395e06-514f-3011-be2b-11b42dfa206b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Zeless Gah",
						uuid = "0afcaa72-56f2-1538-9053-7ff6e332c6d5",
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
								"893eba12-1fc5-c9a5-b4a2-99eceb00f94f",
								true,
							},
							
							{
								"83a3840a-6faf-b23a-9db6-47150dc40784",
								true,
							},
							
							{
								"3b60d2e1-e515-0ba8-9411-20dee4e3be94",
								true,
							},
						},
						displayPath = "Sildihn criterion/Zeless Gah",
						name = "Feint - Show of Strength",
						targetType = "Event Entity",
						uuid = "ba10d723-b381-d99e-9001-43d6e8f52f24",
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
						name = "Sildihn criterion",
						uuid = "ce20e16c-02db-9170-9053-24a379436ac2",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Zeless Gah",
						uuid = "8a0d1c99-201f-ce97-a3ce-f0600fdb4447",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "893eba12-1fc5-c9a5-b4a2-99eceb00f94f",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29871,
						name = "Show of Strength",
						uuid = "83a3840a-6faf-b23a-9db6-47150dc40784",
						version = 3,
					},
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "9204a70c-d57b-d076-a2a3-8e4079255d34",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "ac8f15d8-cddd-63fc-8b0c-d1e72690aa66",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal slot = roster.mySlot()\nif slot ~= \"M1\" and slot ~= \"M2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 20 or job == 22 or job == 30 or job == 34 or job == 39 or job == 41",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Party roster: M1/M2 melee",
						uuid = "3b60d2e1-e515-0ba8-9411-20dee4e3be94",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Mit] Zeless Show of Strength - Feint",
			uuid = "7f25b12b-f020-1d6d-a46d-1114d2a2acbb",
			version = 2,
		},
		inheritedIndex = 103,
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
						name = "Sildihn criterion",
						uuid = "e20fe747-b391-dbd6-b967-bd859ebe5105",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Zeless Gah",
						uuid = "8a55274d-f7e2-f0ec-bfe8-588bafeb52be",
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
								"1d9955c9-acf7-dd2d-9ea5-deae9a9efed5",
								true,
							},
							
							{
								"7ba22cef-e946-4a12-a314-cfcb79958bbe",
								true,
							},
							
							{
								"0cfe2503-2e9e-27b7-882b-93e6c21afaad",
								true,
							},
						},
						displayPath = "Sildihn criterion/Zeless Gah",
						name = "Feint - Firesteel Strike",
						targetType = "Event Entity",
						uuid = "6fbfecb4-f9e5-e243-8162-aac555e278a4",
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
						name = "Sildihn criterion",
						uuid = "6ed010fd-7157-02ea-bdce-35ad2848ad1e",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Zeless Gah",
						uuid = "d45fb9ce-69a4-b741-bacc-e2030b5b7833",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "1d9955c9-acf7-dd2d-9ea5-deae9a9efed5",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29872,
						name = "Firesteel Strike",
						uuid = "7ba22cef-e946-4a12-a314-cfcb79958bbe",
						version = 3,
					},
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "09d1748c-3472-5b38-94cf-da725a9e0b95",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "115ff4ab-cc0b-fd28-9131-deb0611eb6b8",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal slot = roster.mySlot()\nif slot ~= \"M1\" and slot ~= \"M2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 20 or job == 22 or job == 30 or job == 34 or job == 39 or job == 41",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Party roster: M1/M2 melee",
						uuid = "0cfe2503-2e9e-27b7-882b-93e6c21afaad",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Mit] Zeless Firesteel Strike - Feint",
			uuid = "4e322ae7-db43-4862-bae5-575948d926fe",
			version = 2,
		},
		inheritedIndex = 104,
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
						name = "Sildihn criterion",
						uuid = "3a8ede5c-f34d-64d1-8897-c26d46509062",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "b61dabf1-80c6-6752-b92e-5bd0a386acdf",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "daa29766-07c8-3158-aabd-cd9d1223270e",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7535,
						conditions = 
						{
							
							{
								"c943339e-9a7d-1950-989f-7beadb8dad96",
								true,
							},
							
							{
								"1ff36fe5-06b0-e81a-b497-f599c4be38e9",
								true,
							},
							
							{
								"d72e07d0-a37f-fe83-a1e7-ef7240c7ce54",
								true,
							},
							
							{
								"5d319cf0-717d-7eb8-88a1-386ad6e055f1",
								true,
							},
							
							{
								"faa6460f-3de1-e557-be2c-6cb9c5a55b6a",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Reprisal",
						targetType = "Event Entity",
						uuid = "7d539e15-4518-bb4e-84c2-67e6b1d4793f",
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
						name = "Sildihn criterion",
						uuid = "10587a25-7276-4899-aefa-c80e3dd8c2d3",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "5fb12aee-841d-8341-93b0-d90f4fc85441",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "6a5734ae-07b3-167c-99d6-b603a114f2f7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "c943339e-9a7d-1950-989f-7beadb8dad96",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29871,
						name = "Show of Strength",
						uuid = "1ff36fe5-06b0-e81a-b497-f599c4be38e9",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Self",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						jobIDList = 
						{
							1,
							3,
							32,
							37,
						},
						name = "Tanks",
						uuid = "d72e07d0-a37f-fe83-a1e7-ef7240c7ce54",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7535,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Reprisal ready",
						uuid = "5d319cf0-717d-7eb8-88a1-386ad6e055f1",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 333",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Before enrage",
						uuid = "faa6460f-3de1-e557-be2c-6cb9c5a55b6a",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Mit] Zeless Show of Strength - Tank Reprisal",
			uuid = "d6abc625-221f-1438-9cb1-dbebf50620db",
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
						name = "Sildihn criterion",
						uuid = "382e6dc7-da22-d5d0-9acb-1c4c06504312",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "7120a207-179d-b3de-8beb-a9f7ccda5b48",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "ca0d63e6-2185-ca3d-b799-45d4ff44e012",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						aType = "ACR",
						conditions = 
						{
							
							{
								"0c158e2f-7293-ee11-aa0e-fee3a27d7216",
								true,
							},
							
							{
								"4517202d-3f25-bb58-ad10-a55aaf589370",
								true,
							},
							
							{
								"16edc979-a1d0-47a8-843b-763be4af7104",
								true,
							},
							
							{
								"c851542e-55c7-03af-9f36-a4d227710aee",
								true,
							},
							
							{
								"36cfda06-0c26-23c9-a62c-86019156adb5",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						gVar = "ACR_RikuSCH3_Healbar_SacredSoil",
						name = "Sacred Soil",
						uuid = "f3148291-91f8-6b38-9e84-9ec1015a4204",
						variableTogglesType = 3,
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
						name = "Sildihn criterion",
						uuid = "497e2d97-4f12-5ff3-9eef-d8a3e1cc92f0",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "d2275420-ad8c-6ed3-8418-5517559a4837",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "cfb4c32b-61ec-84ca-a0ff-4d1b3be9753a",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "0c158e2f-7293-ee11-aa0e-fee3a27d7216",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29871,
						name = "Show of Strength",
						uuid = "4517202d-3f25-bb58-ad10-a55aaf589370",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"H1\" and mySlot ~= \"H2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 28",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						jobIDList = 
						{
							28,
						},
						name = "Party roster: H1/H2 Scholar",
						uuid = "16edc979-a1d0-47a8-843b-763be4af7104",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 188,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Sacred Soil ready",
						uuid = "c851542e-55c7-03af-9f36-a4d227710aee",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 30",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Opening Show window",
						uuid = "36cfda06-0c26-23c9-a62c-86019156adb5",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Mit] Zeless Show of Strength - SCH Sacred Soil",
			uuid = "54672183-97cd-ca9b-acf5-03fff0b54bbb",
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
						name = "Sildihn criterion",
						uuid = "7b0c2a5f-a92b-b253-946f-09000b8e57df",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "3ab9d8cf-5401-110e-8cb8-a01602434740",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "dbbe2326-eac0-c0ec-b218-9b8e273d3010",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16538,
						conditions = 
						{
							
							{
								"18f7b607-e804-d2c0-b1c1-fbd7204cee7a",
								true,
							},
							
							{
								"ae60b0de-75e2-e529-b977-734126ee4499",
								true,
							},
							
							{
								"d7275613-6609-9f15-92e9-5b87120b1b1b",
								true,
							},
							
							{
								"893f452b-c996-4e63-aae1-b30326fab506",
								true,
							},
							
							{
								"b6d7cebf-d373-fc78-b38b-42e60b545b62",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Fey Illumination",
						uuid = "777e4f34-a6ae-27e9-affe-4e5eb28970a8",
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
						name = "Sildihn criterion",
						uuid = "5a95089d-6b68-a7e4-a51c-5160c9bc7b55",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "6a47ab12-551c-1106-87a5-9aab07932535",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "ffb7e0fa-8957-c479-98bc-11aa44e2596f",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "18f7b607-e804-d2c0-b1c1-fbd7204cee7a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29871,
						name = "Show of Strength",
						uuid = "ae60b0de-75e2-e529-b977-734126ee4499",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"H1\" and mySlot ~= \"H2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 28",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						jobIDList = 
						{
							28,
						},
						name = "Party roster: H1/H2 Scholar",
						uuid = "d7275613-6609-9f15-92e9-5b87120b1b1b",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16538,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Fey Illumination ready",
						uuid = "893f452b-c996-4e63-aae1-b30326fab506",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 30",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Opening Show window",
						uuid = "b6d7cebf-d373-fc78-b38b-42e60b545b62",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Mit] Zeless Show of Strength - SCH Fey Illumination",
			uuid = "7fe51226-9023-3f20-b6fa-25a43812411f",
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
						name = "Sildihn criterion",
						uuid = "66e6cdd8-584d-51d4-8529-652f7582db01",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "abbfe180-3c0c-721b-b957-cb4d019293ba",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "f05f3499-6c45-7453-8761-7caed8f2e9e4",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16537,
						conditions = 
						{
							
							{
								"6f8bcd38-d724-bf4d-97ad-64a00373ca78",
								true,
							},
							
							{
								"f221aa49-e4e9-5bef-9bc7-29ac02471d19",
								true,
							},
							
							{
								"dc926325-de5c-49e1-a19b-dd40f6abbc0a",
								true,
							},
							
							{
								"e69aaa4b-3459-f9fa-a324-007ae39f1c4a",
								true,
							},
							
							{
								"c89a6212-c5d0-8ddc-ba6c-6f1d26e2ad6e",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Whispering Dawn",
						uuid = "3ba9fa13-b257-53c1-88b9-72b1ef1d3b71",
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
						name = "Sildihn criterion",
						uuid = "e27064e9-20cf-7a16-ba2a-cfb896951eed",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "bdc57a85-da18-b488-a05f-c9c6ef380a0d",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "6c0777b4-f4b7-c9a8-8751-48ae0d31429f",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "6f8bcd38-d724-bf4d-97ad-64a00373ca78",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29871,
						name = "Show of Strength",
						uuid = "f221aa49-e4e9-5bef-9bc7-29ac02471d19",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"H1\" and mySlot ~= \"H2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 28",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						jobIDList = 
						{
							28,
						},
						name = "Party roster: H1/H2 Scholar",
						uuid = "dc926325-de5c-49e1-a19b-dd40f6abbc0a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16537,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Whispering Dawn ready",
						uuid = "e69aaa4b-3459-f9fa-a324-007ae39f1c4a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer >= 100 and TensorReactions_CurrentCombatTimer < 328",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Later Show window",
						uuid = "c89a6212-c5d0-8ddc-ba6c-6f1d26e2ad6e",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Mit/Heal] Zeless Show of Strength - SCH Whispering Dawn",
			uuid = "7c5571e9-60c6-d3ae-8437-f199b2b0e276",
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
						name = "Sildihn criterion",
						uuid = "2ab832cb-60ea-93ba-8178-2cbd3e5985da",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "f9fc9b77-19d7-73a1-9dab-23d13e8fa475",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "09080dd3-a310-a75a-8c43-d4d700dd3707",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16543,
						conditions = 
						{
							
							{
								"7470af21-810b-b47f-b89d-7877f0d16849",
								true,
							},
							
							{
								"58e6d6b3-f99a-0bc6-aa60-278aff5d5ab5",
								true,
							},
							
							{
								"5bd005b4-73ca-67d8-bc66-cad7e7780d7f",
								true,
							},
							
							{
								"baef3eac-f9a4-118b-83cc-078e0538e881",
								true,
							},
							
							{
								"0bacd01b-a34e-f5b8-ae0c-f895ab260b9d",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Fey Blessing",
						uuid = "95da1d03-df10-f3cb-99b4-388089a87c1d",
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
						name = "Sildihn criterion",
						uuid = "355b79ba-383c-1752-b6e9-cda1e17a7bd8",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "5b9a5492-8407-1959-892e-603a5c3b5875",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "3930eb45-8cba-05b7-825b-072f0eb1e204",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "7470af21-810b-b47f-b89d-7877f0d16849",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29871,
						name = "Show of Strength",
						uuid = "58e6d6b3-f99a-0bc6-aa60-278aff5d5ab5",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"H1\" and mySlot ~= \"H2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 28",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						jobIDList = 
						{
							28,
						},
						name = "Party roster: H1/H2 Scholar",
						uuid = "5bd005b4-73ca-67d8-bc66-cad7e7780d7f",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16543,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Fey Blessing ready",
						uuid = "baef3eac-f9a4-118b-83cc-078e0538e881",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer >= 100 and TensorReactions_CurrentCombatTimer < 328",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Later Show window",
						uuid = "0bacd01b-a34e-f5b8-ae0c-f895ab260b9d",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Heal] Zeless Show of Strength - SCH Fey Blessing",
			uuid = "30dbb61b-67c9-2e27-b973-4e3712f04419",
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
						name = "Sildihn criterion",
						uuid = "ffab0f3d-23de-a903-8170-53bc500bf2fb",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "300fc954-48e6-bfb9-b8cd-c1eaa0dd36d1",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "e1578dc4-51a4-e7da-9192-233ed4390081",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 7437,
						conditions = 
						{
							
							{
								"40f52c9c-2957-7fe9-8fea-4ce653eda36d",
								true,
							},
							
							{
								"932bfae7-a63d-1e3f-8410-41a3e05b5d80",
								true,
							},
							
							{
								"8736f3c9-bf75-314f-af5a-ac8373a28fa9",
								true,
							},
							
							{
								"9ea9a4f4-10e4-c80b-a73d-5e4b5d42d498",
								true,
							},
							
							{
								"96b3f2e4-37c9-9cc9-a5c3-36ff95dbdd3d",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Aetherpact",
						targetType = "Event Target",
						uuid = "368ed454-99b5-b822-835c-afde82d6a27a",
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
						name = "Sildihn criterion",
						uuid = "bc558f9c-2c1b-e031-a15d-bc666e128793",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "b661730a-a293-33d3-87f6-a181f347f23b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "0761deab-9d90-1e3a-92ee-39b417e51242",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "40f52c9c-2957-7fe9-8fea-4ce653eda36d",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29872,
						name = "Firesteel Strike",
						uuid = "932bfae7-a63d-1e3f-8410-41a3e05b5d80",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"H1\" and mySlot ~= \"H2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 28",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						jobIDList = 
						{
							28,
						},
						name = "Party roster: H1/H2 Scholar",
						uuid = "8736f3c9-bf75-314f-af5a-ac8373a28fa9",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7437,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Aetherpact ready",
						uuid = "9ea9a4f4-10e4-c80b-a73d-5e4b5d42d498",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 333",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Before enrage",
						uuid = "96b3f2e4-37c9-9cc9-a5c3-36ff95dbdd3d",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Mit/Utility] Zeless Firesteel Strike - SCH Aetherpact",
			uuid = "09c729b9-6c4a-1247-9dd8-3e18360fc760",
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
						name = "Sildihn criterion",
						uuid = "c2c491ce-4c7f-82f8-9327-9e1a58f6cf63",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "d6c4d13a-c813-01c9-aa4f-ffee388236e4",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "abb7d876-5734-b45a-9d05-6d2e71b9a64b",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16012,
						conditions = 
						{
							
							{
								"2bbb1693-a33b-382f-bbbc-f8f93ebb44e0",
								true,
							},
							
							{
								"19a1eb89-7c8e-eb0e-a3b7-5ea43f84a440",
								true,
							},
							
							{
								"e06ef597-c3ee-8386-85ea-9603320c5f1a",
								true,
							},
							
							{
								"2c42a2bf-a4a2-db0f-96fe-09285fdcd14f",
								true,
							},
							
							{
								"defd963a-40cf-e656-b8f5-382ec69beef5",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Shield Samba",
						uuid = "61dea08e-d910-32c1-8088-d738ed25541f",
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
						name = "Sildihn criterion",
						uuid = "6963d24c-4ba8-df39-ba33-b5c623b5251f",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "22fa350c-d133-fec6-9a6c-4954b2e55e27",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "4336b1ab-c786-285b-a1f1-6f5967dbc4aa",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "2bbb1693-a33b-382f-bbbc-f8f93ebb44e0",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29871,
						name = "Show of Strength",
						uuid = "19a1eb89-7c8e-eb0e-a3b7-5ea43f84a440",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"R1\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 38",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						jobIDList = 
						{
							38,
						},
						name = "Party roster: R1 physical ranged (Dancer)",
						uuid = "e06ef597-c3ee-8386-85ea-9603320c5f1a",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16012,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Shield Samba ready",
						uuid = "2c42a2bf-a4a2-db0f-96fe-09285fdcd14f",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 30",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Opening Show window",
						uuid = "defd963a-40cf-e656-b8f5-382ec69beef5",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Mit] Zeless Show of Strength - DNC Shield Samba",
			uuid = "1e292c4e-9162-111a-a2e7-9bbb68dffc41",
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
						name = "Sildihn criterion",
						uuid = "31339e9b-317e-1978-bd10-1e90779babc7",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "bf9edd30-e053-caeb-97b1-dcdaf74493e5",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "ebf9572d-c898-1e37-8836-746bc377e960",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16015,
						conditions = 
						{
							
							{
								"bf47b0b8-a448-1acc-9643-13881b60d906",
								true,
							},
							
							{
								"7939cb08-78a1-edf2-91a1-41725b90c0d1",
								true,
							},
							
							{
								"bd481c05-e8fa-23ea-b368-6fad15d3a16e",
								true,
							},
							
							{
								"62737d8d-ec3d-34b8-94ac-20934263fb72",
								true,
							},
							
							{
								"becb6539-f1c7-7077-921c-96e76b5808b3",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Curing Waltz",
						uuid = "306846d7-a603-db62-9831-4f5c41e1fdf3",
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
						name = "Sildihn criterion",
						uuid = "92834870-f2f5-7fc5-aece-9b5461a5d7ec",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "1718b801-9a7b-7670-8d5c-e801d78255e3",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "30c2aa00-88e8-fb80-9d95-9f774d77d1a8",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "bf47b0b8-a448-1acc-9643-13881b60d906",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29871,
						name = "Show of Strength",
						uuid = "7939cb08-78a1-edf2-91a1-41725b90c0d1",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"R1\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 38",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						jobIDList = 
						{
							38,
						},
						name = "Party roster: R1 physical ranged (Dancer)",
						uuid = "bd481c05-e8fa-23ea-b368-6fad15d3a16e",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16015,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Curing Waltz ready",
						uuid = "62737d8d-ec3d-34b8-94ac-20934263fb72",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer >= 100 and TensorReactions_CurrentCombatTimer < 328",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Later Show window",
						uuid = "becb6539-f1c7-7077-921c-96e76b5808b3",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Heal] Zeless Show of Strength - DNC Curing Waltz",
			uuid = "4e7e0d59-dcac-e4db-b433-a5a8d8fa0039",
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
						name = "Sildihn criterion",
						uuid = "3fda9196-66e8-3d46-bf8f-8d21b0324f67",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "d8bc3cdc-7a8f-5fc6-a7b2-d8e7046f4e46",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "7291f7f0-2b0a-d702-be85-a5890ad78bff",
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
								"0520d847-a236-5953-844b-9d58482ed8c2",
								true,
							},
							
							{
								"1d8c1c53-e7ac-c86d-b5ee-6e90f3d3458c",
								true,
							},
							
							{
								"63c2c6fe-ce9a-98e1-b876-828ddac5e648",
								true,
							},
							
							{
								"97335079-4410-6d53-8de3-bc5cb91dde78",
								true,
							},
							
							{
								"3b18d3a0-69ef-b71e-857b-302c8340ae56",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Feint - Firesteel Fracture",
						targetType = "Event Entity",
						uuid = "a43533e0-0f2d-1f58-8d2e-b2bce0a1bae2",
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
						name = "Sildihn criterion",
						uuid = "9d83454a-2339-aae4-b3d3-dbdd6188fd58",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "cd33542b-8390-4515-a1f6-2f59fc385ceb",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "2e29ed98-6ee4-23c0-9f41-8f379c95b7a0",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "0520d847-a236-5953-844b-9d58482ed8c2",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 3,
						eventArgType = 2,
						name = "Firesteel Fracture",
						spellIDList = 
						{
							29868,
							29869,
							30404,
						},
						uuid = "1d8c1c53-e7ac-c86d-b5ee-6e90f3d3458c",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 7549,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Feint ready",
						uuid = "63c2c6fe-ce9a-98e1-b876-828ddac5e648",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer < 333",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Before enrage",
						uuid = "97335079-4410-6d53-8de3-bc5cb91dde78",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal slot = roster.mySlot()\nif slot ~= \"M1\" and slot ~= \"M2\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 20 or job == 22 or job == 30 or job == 34 or job == 39 or job == 41",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Party roster: M1/M2 melee",
						uuid = "3b18d3a0-69ef-b71e-857b-302c8340ae56",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Mit] Zeless Firesteel Fracture - Melee Feint",
			uuid = "72a4a007-ec8f-cf8a-b76a-fd1944cde56e",
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
						name = "Sildihn criterion",
						uuid = "440722c3-e9b0-dc2a-8e19-a167ca8e3a25",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "868fab39-2d9e-e3f5-850b-3c264e9890bd",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "b2cfe269-528f-80ea-95cd-99e03fa2cd41",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						actionID = 16012,
						conditions = 
						{
							
							{
								"2587f52d-3ccb-3d1e-acaa-900431d4032c",
								true,
							},
							
							{
								"4359ab83-ee05-0839-abda-d370a1d7bc75",
								true,
							},
							
							{
								"1c89a8a1-e906-5e0f-bd3d-94eeb904cece",
								true,
							},
							
							{
								"dc53d693-899a-1c55-b24c-19b1e9998d92",
								true,
							},
							
							{
								"9d58137e-89d5-fdb6-8098-a783a7783510",
								true,
							},
						},
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Shield Samba 2",
						uuid = "6b4e2a25-d491-7fdf-bae2-485a9bf204de",
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
						name = "Sildihn criterion",
						uuid = "61a61215-7c89-bac7-b475-1f49397bb42c",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion",
						name = "Mitigations",
						uuid = "89f7a56d-903c-a745-ac2f-e482900f8670",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						displayPath = "Sildihn criterion/Mitigations",
						name = "Zeless Gah",
						uuid = "35966472-54f5-c0b2-919c-dc0c7cd98240",
					},
					objectType = "folder",
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgOptionType = 2,
						eventEntityContentID = 11393,
						name = "Zeless Gah",
						uuid = "2587f52d-3ccb-3d1e-acaa-900431d4032c",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Event",
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						eventArgType = 2,
						eventSpellID = 29871,
						name = "Show of Strength",
						uuid = "4359ab83-ee05-0839-abda-d370a1d7bc75",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "local roster = AnyoneCore and AnyoneCore.Roster\nif roster == nil or roster.current() == nil then\n    return false\nend\nlocal mySlot = roster.mySlot()\nif mySlot ~= \"R1\" then\n    return false\nend\nlocal player = TensorCore.mGetPlayer()\nif player == nil then\n    return false\nend\nlocal job = tonumber(player.job)\nreturn job == 38",
						conditionType = 14,
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						jobIDList = 
						{
							38,
						},
						name = "Party roster: R1 physical ranged (Dancer)",
						uuid = "1c89a8a1-e906-5e0f-bd3d-94eeb904cece",
						version = 3,
					},
				},
				
				{
					data = 
					{
						actionCDValue = 1,
						actionID = 16012,
						category = "Self",
						comparator = 2,
						conditionType = 4,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Shield Samba ready",
						uuid = "dc53d693-899a-1c55-b24c-19b1e9998d92",
						version = 3,
					},
				},
				
				{
					data = 
					{
						category = "Lua",
						conditionLua = "return TensorReactions_CurrentCombatTimer >= 220 and TensorReactions_CurrentCombatTimer < 328",
						dequeueIfLuaFalse = true,
						displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
						name = "Later Show window",
						uuid = "9d58137e-89d5-fdb6-8098-a783a7783510",
						version = 3,
					},
				},
			},
			displayPath = "Sildihn criterion/Mitigations/Zeless Gah",
			eventType = 3,
			name = "[Mit] Zeless Show of Strength 2 - DNC Shield Samba",
			uuid = "f3c221f9-f4af-c8fd-9150-90bcaef4175b",
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
						actionLua = "---Adds floating text into the game for a certain amount of time.\n---@param time number @Milliseconds to render the text for.\n---@param text string @Text of the render.\n---@param position ThreeDimensionalPos @Position of the render.\n---@param color? integer @RGB U32 color of the text.\n---@param background? boolean @Whether the text should have a transparent black box to help make it pop out.\n---@param sizeMultiplier? number @Makes text size larger. ie; 1.5 would be 1.5x or 50% larger than default.\n---@return string @UUID of world text.\nfunction AnyoneCore.addTimedWorldText(time, text, position, color, background, sizeMultiplier) end\n\n---Adds floating text into the game tied to a given entity's position.\n---@param timer integer @Milliseconds to render the text for.\n---@param str string @Text to display.\n---@param entID number @ID of the entity to draw on\n---@param color? number @U32 value of a color\n---@param bg? boolean @Whether to add a dark background to make the text more visible\n---@param sizeMultiplier? number @Multiplies the scale of the text\n---@param heightAddition? number @Adds extra height to the y value of entity position if needed to make the text more visible.\n---@return string @UUID of world text.\nfunction AnyoneCore.addTimedWorldTextOnEnt(timer, str, entID, color, bg, sizeMultiplier, heightAddition) end",
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
		inheritedIndex = 116,
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
		inheritedIndex = 117,
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
		inheritedIndex = 118,
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
	inheritedProfiles = 
	{
	},
}



return tbl