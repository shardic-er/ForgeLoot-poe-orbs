-- ForgeOrbs: Client addon for PoE-style forge orbs
-- Handles the Scroll of Identification rename popup and Divine Orb confirmation.

local ADDON_PREFIX = "FORB"

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", function(self, event, prefix, msg, channel, sender)
    if prefix ~= ADDON_PREFIX then return end

    -- Server sends "ID:<itemName>" to request a rename
    if msg:sub(1, 3) == "ID:" then
        local itemName = msg:sub(4)
        StaticPopupDialogs["FORGE_ORB_RENAME"] = {
            text = "Enter a new name for |cffffffff" .. itemName .. "|r\n(3-32 characters, letters/numbers/spaces)",
            button1 = "Rename",
            button2 = "Cancel",
            hasEditBox = true,
            maxLetters = 32,
            editBoxWidth = 260,
            OnShow = function(self)
                self.editBox:SetText("")
                self.editBox:SetFocus()
            end,
            OnAccept = function(self)
                local text = self.editBox:GetText()
                if text and text ~= "" then
                    SendAddonMessage(ADDON_PREFIX, "N:" .. text, "WHISPER", UnitName("player"))
                end
            end,
            EditBoxOnEnterPressed = function(self)
                local text = self:GetText()
                if text and text ~= "" then
                    SendAddonMessage(ADDON_PREFIX, "N:" .. text, "WHISPER", UnitName("player"))
                end
                self:GetParent():Hide()
            end,
            EditBoxOnEscapePressed = function(self)
                self:GetParent():Hide()
            end,
            timeout = 60,
            whileDead = false,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("FORGE_ORB_RENAME")
    end

    -- Server sends "DV:<quality>|<slotName>|<sourceName>" to request transmog confirmation
    if msg:sub(1, 3) == "DV:" then
        local payload = msg:sub(4)
        -- Parse: quality|slotName|sourceName
        local sep1 = payload:find("|", 1, true)
        local sep2 = sep1 and payload:find("|", sep1 + 1, true)
        local qualityStr = sep1 and payload:sub(1, sep1 - 1) or "0"
        local slotName = (sep1 and sep2) and payload:sub(sep1 + 1, sep2 - 1) or "equipment"
        local sourceName = sep2 and payload:sub(sep2 + 1) or payload

        local QUALITY_COLORS = {
            [0] = "|cff9d9d9d", [1] = "|cffffffff", [2] = "|cff1eff00",
            [3] = "|cff0070dd", [4] = "|cffa335ee", [5] = "|cffff8000",
        }
        local qColor = QUALITY_COLORS[tonumber(qualityStr) or 0] or "|cffffffff"
        local coloredName = qColor .. sourceName .. "|r"

        StaticPopupDialogs["FORGE_ORB_TRANSMOG"] = {
            text = "Do you really want to destroy " .. coloredName .. " and apply its appearance to the item currently equipped in your |cffffffff" .. slotName .. "|r slot?",
            button1 = "Confirm",
            button2 = "Cancel",
            OnAccept = function()
                SendAddonMessage(ADDON_PREFIX, "D:OK", "WHISPER", UnitName("player"))
            end,
            OnCancel = function()
                SendAddonMessage(ADDON_PREFIX, "D:NO", "WHISPER", UnitName("player"))
            end,
            timeout = 60,
            whileDead = false,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("FORGE_ORB_TRANSMOG")
    end
end)