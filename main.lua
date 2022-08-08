function GetAsset(path)
    return format('Interface\\AddOns\\TwitchEmotesExtended\\%s', path)
end

function RegisterEmote(name, file, size)
    if not size then
        size = '28:28'
    end

    TwitchEmotes_defaultpack[name] = string.format("%s:%s", GetAsset('emotes\\' .. file), size)
    TwitchEmotes_emoticons[name] = name
end

function RegisterAnimatedEmote(name, file, numFrames, texWidth, texHeight, fps, size)
    if not size then
        size = '28:28'
    end

    local path = GetAsset('emotes\\' .. file)
    TwitchEmotes_defaultpack[name] = path .. ':' .. size
    TwitchEmotes_emoticons[name] = name
    TwitchEmotes_animation_metadata[path] = {
        ["nFrames"] = numFrames,
        ["frameWidth"] = 32,
        ["frameHeight"] = 32,
        ["imageWidth"] = texWidth,
        ["imageHeight"] = texHeight,
        ["framerate"] = fps
    }
end

-- have to hijack this function to support our own animated emotes
TwitchEmotesAnimator_UpdateEmoteInFontString = function(fontstring, widthOverride, heightOverride)
    local txt = fontstring:GetText();
    if (txt ~= nil) then
        for emoteTextureString in txt:gmatch("(|TInterface\\AddOns\\.-\\emotes.-|t)") do
            local imagepath = emoteTextureString:match("|T(Interface\\AddOns\\.-\\emotes.-.tga).-|t")

            local animdata = TwitchEmotes_animation_metadata[imagepath];
            if (animdata ~= nil) then
                local framenum = TwitchEmotes_GetCurrentFrameNum(animdata);
                local nTxt;
                if(widthOverride ~= nil or heightOverride ~= nil) then
                    nTxt = txt:gsub(emoteTextureString:gsub('%+', '%%+'):gsub('%-', '%%-'),
                                        TwitchEmotes_BuildEmoteFrameStringWithDimensions(
                                        imagepath, animdata, framenum, widthOverride, heightOverride))
                else
                    nTxt = txt:gsub(emoteTextureString:gsub('%+', '%%+'):gsub('%-', '%%-'),
                                        TwitchEmotes_BuildEmoteFrameString(
                                        imagepath, animdata, framenum))
                end

                -- If we're updating a chat message we need to alter the messageInfo as well 
                if (fontstring.messageInfo ~= nil) then
                    fontstring.messageInfo.message = nTxt
                end
                fontstring:SetText(nTxt);
                txt = nTxt;
            end
        end
    end
end

 -- Have to rerun this code manually because..
 -- TwitchEmotes blocks future calls to Emoticons_SetAutoComplete
 function FixAutocomplete()
    AllTwitchEmoteNames = {}

    local i = 0;
    for k, v in pairs(TwitchEmotes_defaultpack) do
        --Some values in emoticons don't have a corresponding key in TwitchEmotes_defaultpack
        --we need to filter these out because we don't have an emote to show for these
        -- if TwitchEmotes_defaultpack[v] ~= nil then
            local excluded = false;
            for j=1, #TwitchEmotes_ExcludedSuggestions do
                if k == TwitchEmotes_ExcludedSuggestions[j] then
                    excluded = true;
                    break;
                end
            end

            if excluded == false then
                AllTwitchEmoteNames[i] = k;
                i = i + 1;
            end
        -- end
    end

    --Sort the list alphabetically
    table.sort(AllTwitchEmoteNames)

    for i=1, NUM_CHAT_WINDOWS do
        local frame = _G["ChatFrame"..i]

        local editbox = frame.editBox;
        local suggestionList = AllTwitchEmoteNames;
        local maxButtonCount = 20;

        local autocompletesettings = {
            perWord = true,
            activationChar = ':',
            closingChar = ':',
            minChars = 2,
            fuzzyMatch = true,
            onSuggestionApplied = function(suggestion)
                UpdateEmoteStats(suggestion, true, false, false);
            end,
            renderSuggestionFN = Emoticons_RenderSuggestionFN,
            suggestionBiasFN = function(suggestion, text)
                --Bias the sorting function towards the most autocompleted emotes
                if TwitchEmoteStatistics[suggestion] ~= nil then
                    return TwitchEmoteStatistics[suggestion][1] * 5
                end
                return 0;
            end,
            interceptOnEnterPressed = true,
            addSpace = true,
            useTabToConfirm = Emoticons_Settings["AUTOCOMPLETE_CONFIRM_WITH_TAB"],
            useArrowButtons = true,
        }

        SetupAutoComplete(editbox, suggestionList, maxButtonCount, autocompletesettings);
    end
end

RegisterEmote('BasedRetard', 'BasedRetard.tga')
RegisterEmote('CluelessClown', 'CluelessClown.tga')
RegisterEmote('PantsGrab', 'PantsGrab.tga')
RegisterEmote('peepoFlushed', 'peepoFlushed.tga')

RegisterAnimatedEmote('Gerbing', 'Gerbing.tga', 10, 32, 512, 50)
RegisterAnimatedEmote('HUHH', 'HUHH.tga', 47, 32, 2048, 20)
RegisterAnimatedEmote('SNIFFA', 'SNIFFA.tga', 40, 32, 2048, 25)
RegisterAnimatedEmote('yeppers', 'yeppers.tga', 2, 32, 64, 12)

FixAutocomplete()