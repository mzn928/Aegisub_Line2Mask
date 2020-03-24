--[[

]] script_name = "Line2Mask"
script_description = "Create masks based on line properties."
script_author = "Sam1367"
script_version = "0.0.3"

include("karaskel.lua")

function do_for_selected(sub, sel, act)
    local meta, styles = karaskel.collect_head(sub, false)

    buttons = {"Apply", "Cancel"}

    dialog_config = {
        {
            class = "checkbox",
            name = "gcolor0",
            x = 0,
            y = 0,
            width = 1,
            height = 1,
            label = "\\c",
            value = true
        }, {
            class = "color",
            name = "gcolor1",
            x = 1,
            y = 0,
            width = 1,
            height = 1,
            value = "&H9F9FB1&"
        }, {
            class = "checkbox",
            name = "ghd1",
            x = 0,
            y = 1,
            width = 1,
            height = 1,
            label = "Horizontal dilation",
            value = true
        }, {
            class = "intedit",
            name = "ghdv1",
            x = 1,
            y = 1,
            width = 1,
            height = 1,
            value = 10
        }, {
            class = "checkbox",
            name = "gvd1",
            x = 0,
            y = 2,
            width = 1,
            height = 1,
            label = "Vertical dilation",
            value = true
        }, {
            class = "intedit",
            name = "gvdv1",
            x = 1,
            y = 2,
            width = 1,
            height = 1,
            value = -3
        }, {
            class = "checkbox",
            name = "go1",
            x = 0,
            y = 3,
            width = 1,
            height = 1,
            label = "\\bord",
            value = true
        }, {
            class = "intedit",
            name = "gov1",
            x = 1,
            y = 3,
            width = 1,
            height = 1,
            value = 0,
            min = 0,
            max = 1000
        }, {
            class = "color",
            name = "gcolor3",
            x = 2,
            y = 3,
            width = 1,
            height = 1,
            value = "&H000000&"
        }, {
            class = "checkbox",
            name = "gs1",
            x = 0,
            y = 4,
            width = 1,
            height = 1,
            label = "\\shad",
            value = true
        }, {
            class = "intedit",
            name = "gsv1",
            x = 1,
            y = 4,
            width = 1,
            height = 1,
            value = 0,
            min = 0,
            max = 1000
        }, {
            class = "color",
            name = "gcolor4",
            x = 2,
            y = 4,
            width = 1,
            height = 1,
            value = "&H000000&"
        }, {
            class = "checkbox",
            name = "gb1",
            x = 0,
            y = 5,
            width = 1,
            height = 1,
            label = "\\blur",
            value = true
        }, {
            class = "intedit",
            name = "gbv1",
            x = 1,
            y = 5,
            width = 1,
            height = 1,
            value = 1,
            min = 0,
            max = 1000
        }, {
            class = "label",
            x = 0,
            y = 6,
            width = 1,
            height = 1,
            label = "*Uncheck for unchanging values"
        }
    }

    pressed, res = aegisub.dialog.display(dialog_config, buttons)
    if pressed == "Cancel" then aegisub.cancel() end

    for si, li in ipairs(sel) do
        line = sub[li]

        karaskel.preproc_line(sub, meta, styles, line)

        line2 = line
        text1 = line2.text_stripped
        text2 = line2.text:gsub("\\i%d", "")

        if res.gcolor0 then
            text2 = text2:gsub("\\c&H%x+&", "")
            text2 = text2:gsub("{}", "")
            str1 = string.find(text2, "}")
            str2 = "&H" .. string.sub(res.gcolor1, 6, 7) ..
                       string.sub(res.gcolor1, 4, 5) ..
                       string.sub(res.gcolor1, 2, 3) .. "&"
            if str1 == nil then
                text2 = "{\\c" .. str2 .. "}" .. text2
            else
                text2 = text2:gsub("}", "\\c" .. str2 .. "}")
            end
        end
        n1 = 0;
        text12 = line2.text_stripped;
        width1 = 0
        line3 = sub[li]
        logi1 = true
        while logi1 do
            str1 = string.find(text12, "\\N")
            if str1 == nil then
                logi1 = false
                line3.text = text12
                sub[li] = line3
                line3 = sub[li]
                karaskel.preproc_line(sub, meta, styles, line3)
                width1 = math.max(width1, line3.width)
            else
                n1 = n1 + 1
                line3.text = string.sub(text12, 1, str1 - 1)
                sub[li] = line3
                line3 = sub[li]
                karaskel.preproc_line(sub, meta, styles, line3)
                width1 = math.max(width1, line3.width)
                text12 = string.sub(text12, str1 + 2, #text12)
            end
        end
        sub[li] = line

        if res.ghd1 then
            width1 = width1 + 2 * res.ghdv1
            shiftX = res.ghdv1
        else
            shiftX = 0
        end
        if res.gvd1 then
            height1 = (n1 + 1) * line2.height + 2 * res.gvdv1
            shiftY = res.gvdv1
        else
            height1 = (n1 + 1) * line2.height
            shiftY = 0
        end

        align1 = tonumber(text2:match("\\an(%d+)"))
        if align1 then
            if align1 < 4 then
                alignV = "bottom"
            elseif align1 < 7 then
                alignV = "middle"
            else
                alignV = "top"
            end
            if align1 % 3 == 1 then
                alignH = "left"
            elseif align1 % 3 == 2 then
                alignH = "center"
            else
                alignH = "right"
            end
            aft = true -- align forced tag
        else
            align1 = line2.styleref.align
            alignV = line2.valign
            alignH = line2.halign
            aft = false
        end

        px, py = text2:match("\\pos%(([%d.-]+),([%d.-]+)")
        if not px then
            px1, py1, px2, py2 = text2:match(
                                     "\\move%(([%d.-]+),([%d.-]+),([%d.-]+),([%d.-]+)")
            if not px1 then
                if aft then
                    if alignH == "left" then
                        px = line2.eff_margin_l - shiftX
                    elseif alignH == "center" then
                        px = meta.res_x / 2
                    else
                        px = meta.res_x - line2.eff_margin_r + shiftX
                    end
                    if alignV == "bottom" then
                        py = meta.res_y - line.eff_margin_b + shiftY
                    elseif alignV == "middle" then
                        py = meta.res_y / 2
                    else
                        py = line.eff_margin_t - shiftY
                    end
                else
                    if alignH == "left" then
                        px = line2.left - shiftX
                    elseif alignH == "center" then
                        px = line2.center
                    else
                        px = line2.right + shiftX
                    end
                    if alignV == "bottom" then
                        py = line2.bottom + shiftY
                    elseif alignV == "middle" then
                        py = line2.middle
                    else
                        py = line2.top - shiftY
                    end
                end
                str1 = string.find(text2, "}")
                if str1 == nil then
                    text2 = "{\\pos(" .. px .. "," .. py .. ")" .. "}" .. text2
                else
                    text2 = text2:gsub("}",
                                       "\\pos(" .. px .. "," .. py .. ")" .. "}")
                end
            else
                if alignH == "left" then
                    px1 = px1 - shiftX
                    px2 = px2 - shiftX
                end
                if alignH == "right" then
                    px1 = px1 + shiftX
                    px2 = px2 + shiftX
                end
                if alignV == "bottom" then
                    py1 = py1 + shiftY
                    py2 = py2 + shiftY
                end
                if alignV == "top" then
                    py1 = py1 - shiftY
                    py2 = py2 - shiftY
                end
                text2 = text2:gsub(
                            "\\move%(([%d.-]+),([%d.-]+),([%d.-]+),([%d.-]+)",
                            "\\move(" .. px1 .. "," .. py1 .. "," .. px2 .. "," ..
                                py2)
            end
        else
            if alignH == "left" then px = px - shiftX end
            if alignH == "right" then px = px + shiftX end
            if alignV == "bottom" then py = py + shiftY end
            if alignV == "top" then py = py - shiftY end
            text2 = text2:gsub("\\pos%(([%d.-]+),([%d.-]+)%)",
                               "\\pos(" .. px .. "," .. py .. ")")
        end

        if res.go1 then
            str1 = string.find(text2, "\\bord")
            if str1 == nil then
                str2 = string.find(text2, "}")
                if str2 == nil then
                    text2 = "{\\bord" .. res.gov1 .. "}" .. text2
                else
                    text2 = text2:gsub("}", "\\bord" .. res.gov1 .. "}")
                end
            else
                text2 = text2:gsub("\\bord[%d.-]+", "\\bord" .. res.gov1)
            end
            text2 = text2:gsub("\\3c&H%x+&", "")
            text2 = text2:gsub("{}", "")
            str2 = "&H" .. string.sub(res.gcolor3, 6, 7) ..
                       string.sub(res.gcolor3, 4, 5) ..
                       string.sub(res.gcolor3, 2, 3) .. "&"
            text2 = text2:gsub("}", "\\3c" .. str2 .. "}")
        end
        if res.gs1 then
            str1 = string.find(text2, "\\shad")
            if str1 == nil then
                str2 = string.find(text2, "}")
                if str2 == nil then
                    text2 = "{\\shad" .. res.gsv1 .. "}" .. text2
                else
                    text2 = text2:gsub("}", "\\shad" .. res.gsv1 .. "}")
                end
            else
                text2 = text2:gsub("\\shad[%d.-]+", "\\shad" .. res.gsv1)
            end
            text2 = text2:gsub("\\4c&H%x+&", "")
            text2 = text2:gsub("{}", "")
            str2 = "&H" .. string.sub(res.gcolor4, 6, 7) ..
                       string.sub(res.gcolor4, 4, 5) ..
                       string.sub(res.gcolor4, 2, 3) .. "&"
            text2 = text2:gsub("}", "\\4c" .. str2 .. "}")
        end
        if res.gb1 then
            str1 = string.find(text2, "\\blur")
            if str1 == nil then
                str2 = string.find(text2, "}")
                if str2 == nil then
                    text2 = "{\\blur" .. res.gbv1 .. "}" .. text2
                else
                    text2 = text2:gsub("}", "\\blur" .. res.gbv1 .. "}")
                end
            else
                text2 = text2:gsub("\\blur[%d.-]+", "\\blur" .. res.gbv1)
            end
        end

        text2 = text2:gsub("\\b%d+", "");
        text2 = text2:gsub("\\u%d", "");
        text2 = text2:gsub("\\s%d", "");
        text2 = text2:gsub("\\fsp%d+", "")
        text2 = text2:gsub("\\k%d+", "");
        text2 = text2:gsub("\\K%d+", "");
        text2 = text2:gsub("\\kf%d+", "");
        text2 = text2:gsub("\\ko%d+", "")
        text2 = text2:gsub("\\q%d", "");
        text2 = text2:gsub("\\r", "");
        text2 = text2:gsub("\\r%a", "");
        text2 = text2:gsub("\\clip", "");
        text2 = text2:gsub("\\iclip", "")
        text2 = text2:gsub("{}", "");
        text2 = text2:gsub(text1, "")
        str1 = string.find(text2, "}")
        if str1 == nil then
            text2 = "{\\p1}" .. text2
        else
            text2 = text2:gsub("}", "\\p1}")
        end

        text2 = text2 .. "m 0 0 l " .. width1 .. " 0 " .. width1 .. " " ..
                    height1 .. " 0 " .. height1
        line2.text = text2
        sub.append(line2)

        line = sub[li]
        line.layer = line.layer + 1
        sub[li] = line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function macro_validation(sub, sel, act) return true end

aegisub.register_macro(script_name, script_description, do_for_selected,
                       macro_validation)
