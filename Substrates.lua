--[[

]]

script_name = "Substrates"
script_description = "Provide substrate for selected lines"
script_author = "sam1367"
script_version = "0.0.1"

include("karaskel.lua")

function do_for_selected(sub, sel, act)
	local meta, styles = karaskel.collect_head(sub,false)
	
	buttons={"Apply","Cancel"}

	dialog_config=
	{
		{class="checkbox",name="gcolor0",x=0,y=0,width=1,height=1,label="\\c",value=true},
		{class="color",name="gcolor1",x=1,y=0,width=1,height=1,value="&H9F9FB1&"},
		{class="checkbox",name="ghd1",x=0,y=1,width=1,height=1,label="Horizontal dilation",value=true},
		{class="intedit",name="ghdv1",x=1,y=1,width=1,height=1,value=0},
		{class="checkbox",name="gvd1",x=0,y=2,width=1,height=1,label="Vertical dilation",value=true},
		{class="intedit",name="gvdv1",x=1,y=2,width=1,height=1,value=-8},
		{class="checkbox",name="go1",x=0,y=3,width=1,height=1,label="\\bord",value=true},
		{class="intedit",name="gov1",x=1,y=3,width=1,height=1,value=0, min=0, max=1000},
		{class="color",name="gcolor3",x=2,y=3,width=1,height=1,value="&H000000&"},
		{class="checkbox",name="gs1",x=0,y=4,width=1,height=1,label="\\shad",value=false},
		{class="intedit",name="gsv1",x=1,y=4,width=1,height=1,value=0, min=0, max=1000},
		{class="color",name="gcolor4",x=2,y=4,width=1,height=1,value="&H000000&"},
		{class="checkbox",name="gb1",x=0,y=5,width=1,height=1,label="\\blur",value=true},
		{class="intedit",name="gbv1",x=1,y=5,width=1,height=1,value=2, min=0, max=1000},
		{class="label",x=0,y=6,width=1,height=1,label="* Uncheck for unchanging values"}
	}
	
	pressed, res = aegisub.dialog.display(dialog_config,buttons)
	if pressed=="Cancel" then
		aegisub.cancel()
	end
	
	for si,li in ipairs(sel) do
		line = sub[li]
		
		karaskel.preproc_line(sub,meta,styles,line)
		
		line2 = line
		text1 = line2.text_stripped
		text2 = line2.text:gsub("\\i%d","")
		
		if res.gcolor0 then
			text2 = text2:gsub("\\c&H%x+&","")
			text2 = text2:gsub("{}","")
			str1 = string.find(text2, "}")
			str2 = "&H"..string.sub(res.gcolor1,6,7)..string.sub(res.gcolor1,4,5)..string.sub(res.gcolor1,2,3).."&"
			if str1==nil then
				text2="{\\c"..str2.."}"..text2
			else
				text2 = text2:gsub("}","\\c"..str2.."}")
			end
		end
		if res.ghd1 then
			width1=line2.width+2*res.ghdv1
		else
			width1=line2.width
		end
		if res.gvd1 then
			height1=line2.height+2*res.gvdv1
			py=text2:match("\\pos%([%d.-]+,([%d.-]+)")
			if not py then
				if line2.styleref.align == 2 then
					px = line2.center
					py = line2.bottom+res.gvdv1
					str1 = string.find(text2, "}")
					if str1==nil then
						text2="{\\pos("..px..","..py..")".."}"..text2
					else
						text2 = text2:gsub("}","\\pos("..px..","..py..")".."}")
					end
				end
				if line2.styleref.align == 8 then
					px = line2.center
					py = line2.bottom-res.gvdv1
					str1 = string.find(text2, "}")
					if str1==nil then
						text2="{\\pos("..px..","..py..")".."}"..text2
					else
						text2 = text2:gsub("}","\\pos("..px..","..py..")".."}")
					end
				end
			else
				if line2.valign == "bottom" then
					py = py+res.gvdv1
					text2 = text2:gsub("\\pos%(([%d.-]+),([%d.-]+)%)","\\pos(%1,"..py..")")
				end
				if line2.valign == "top" then
					py = py-res.gvdv1
					text2 = text2:gsub("\\pos%(([%d.-]+),([%d.-]+)%)","\\pos(%1,"..py..")")
				end
			end
		else
			height1=line2.height
		end
		
		if res.go1 then
			str1 = string.find(text2, "\\bord")
			if str1==nil then
				text2="{\\bord"..res.gov1.."}"..text2
			else
				text2 = text2:gsub("\\bord[%d.-]+","\\bord"..res.gov1)
			end
			text2 = text2:gsub("\\3c&H%x+&","")
			text2 = text2:gsub("{}","")
			str2 = "&H"..string.sub(res.gcolor3,6,7)..string.sub(res.gcolor3,4,5)..string.sub(res.gcolor3,2,3).."&"
			text2 = text2:gsub("}","\\3c"..str2.."}")
		end
		if res.gs1 then
			str1 = string.find(text2, "\\shad")
			if str1==nil then
				text2="{\\shad"..res.gsv1.."}"..text2
			else
				text2 = text2:gsub("\\shad[%d.-]+","\\shad"..res.gsv1)
			end
			text2 = text2:gsub("\\4c&H%x+&","")
			text2 = text2:gsub("{}","")
			str2 = "&H"..string.sub(res.gcolor4,6,7)..string.sub(res.gcolor4,4,5)..string.sub(res.gcolor4,2,3).."&"
			text2 = text2:gsub("}","\\4c"..str2.."}")
		end
		if res.gb1 then
			str1 = string.find(text2, "\\blur")
			if str1==nil then
				text2="{\\blur"..res.gbv1.."}"..text2
			else
				text2 = text2:gsub("\\blur[%d.-]+","\\blur"..res.gbv1)
			end
		end
		
		text2 = text2:gsub("\\b%d+","");text2 = text2:gsub("\\u%d","");text2 = text2:gsub("\\s%d","");text2 = text2:gsub("\\fsp%d+","")
		text2 = text2:gsub("\\k%d+","");text2 = text2:gsub("\\K%d+","");text2 = text2:gsub("\\kf%d+","");text2 = text2:gsub("\\ko%d+","")
		text2 = text2:gsub("\\q%d","");text2 = text2:gsub("\\r","");text2 = text2:gsub("\\r%a","");text2 = text2:gsub("\\clip","");text2 = text2:gsub("\\iclip","")
		text2 = text2:gsub("{}","");text2 = text2:gsub(text1,"")
		if #text2 == 0 then
			text2 = "{\\p1}"
		else
			text2 = text2:gsub("}","\\p1}")
		end
		
		--to check later: fs, bord, xbord, ybord, shad..., be, blur, fscx, fscy, an, p
		
		text2 = text2.."m 0 0 l "..width1.." 0 "..width1.." "..height1.." 0 "..height1
		line2.text = text2
		sub.append(line2)
		
		line = sub[li]
		line.layer = line.layer + 1
		sub[li] = line
	end
	aegisub.set_undo_point(script_name)
	return sel
end

function macro_validation(sub, sel, act)
	return true
end

aegisub.register_macro(script_name,script_description,do_for_selected,macro_validation)
