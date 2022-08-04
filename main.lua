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

RegisterEmote('BasedRetard', 'BasedRetard.tga')
RegisterEmote('CluelessClown', 'CluelessClown.tga')
RegisterEmote('PantsGrab', 'PantsGrab.tga')
RegisterEmote('peepoFlushed', 'peepoFlushed.tga')

RegisterAnimatedEmote('HUHH', 'HUHH.tga', 47, 32, 2048, 20)
RegisterAnimatedEmote('yeppers', 'yeppers.tga', 2, 32, 64, 12)