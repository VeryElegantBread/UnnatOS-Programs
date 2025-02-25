if not item_exists({ "System",  "Libraries" }) then
	new_item({ "System", "Libraries" }, false)
end
if not item_exists({ "System", "Libraries", "code_highlighter.lua" }) then
	new_item({ "System", "Libraries", "code_highlighter.lua" }, true)
	set_text({ "System", "Libraries", "code_highlighter.lua" }, get_data("https://raw.githubusercontent.com/VeryElegantBread/UnnatOS-Programs/main/Libraries/code_highlighter.lua"))
end

require("System/Libraries/code_highlighter.lua")

local path = StringToPath(SplitString(Input, " ")[2])

if item_exists(path) then
	local return_string = HighlightCode(get_text(path))
	if SplitString(Input, " ")[3] ~= "no-nums" then
		local new_return_string = ""
		for line_num, line in pairs(SplitString(return_string, "\n")) do
			new_return_string = new_return_string .. "\27[38;5;8m" .. string.format("%3s", line_num) .. " " .. line .. "\n"
		end
		return_string = new_return_string:sub(1, #new_return_string - 1)
	end
	return { return_string }
else
	print("item not found: " .. PathToString(path))
end
