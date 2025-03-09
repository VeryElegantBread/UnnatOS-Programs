local split_input = SplitStringOutsideQuotes(Input, " ")


local default_cow_path = GetCommandItem(split_input[1])
table.insert(default_cow_path, "default.cow")
if not item_exists(default_cow_path) then
	print("downloading default cow files")
	local cow_files_json = get_data("https://api.github.com/repos/cowsay-org/cowsay/contents/share/cowsay/cows?ref=main", { ["User-Agent"] = "LuaCowsay" })
	for name in cow_files_json:gmatch('"name"%s*:%s*"([^"]+)"') do
		local cow_file_path = default_cow_path
		cow_file_path[#cow_file_path] = name
		if not item_exists(cow_file_path) then
			new_item(cow_file_path, false)
			set_text(cow_file_path, get_data("https://raw.githubusercontent.com/cowsay-org/cowsay/main/share/cowsay/cows/" .. name))
		end
	end
end

local word_wrap = 40
local eyes = "oo"
local toung = "  "
local cowfile = "default"
local text = "Moo"

local current_pos = split_input[1]:len() + 1
local flag_num = 2
while flag_num <= #split_input do
	local flag = split_input[flag_num]
	if flag == "-n" then
		word_wrap = nil
	elseif flag == "-W" then
		current_pos = current_pos + string.len(split_input[flag_num]) + 1
		flag_num = flag_num + 1
		word_wrap = tonumber(split_input[flag_num])
	elseif flag == "-b" then
		eyes = "=="
	elseif flag == "-d" then
		eyes = "XX"
		toung = "U "
	elseif flag == "-g" then
		eyes = "$$"
	elseif flag == "-p" then
		eyes = "@@"
	elseif flag == "-s" then
		eyes = "**"
		toung = "U "
	elseif flag == "-t" then
		eyes = "--"
	elseif flag == "-w" then
		eyes = "OO"
	elseif flag == "-y" then
		eyes = ".."
	elseif flag == "-e" then
		current_pos = current_pos + string.len(flag) + 1
		flag_num = flag_num + 1
		eyes = string.sub(RemoveQuotesIfApplicable(split_input[flag_num]) .. "  ", 1, 2)
	elseif flag == "-T" then
		current_pos = current_pos + string.len(flag) + 1
		flag_num = flag_num + 1
		toung = string.sub(RemoveQuotesIfApplicable(split_input[flag_num]) .. "  ", 1, 2)
	elseif flag == "-f" then
		current_pos = current_pos + string.len(flag) + 1
		flag_num = flag_num + 1
		cowfile = RemoveQuotesIfApplicable(split_input[flag_num])
	elseif flag == "-l" then
		local return_table = {}
		for _, file_name in pairs(get_children(GetCommandItem(split_input[1]))) do
			if file_name:sub(#file_name - 3) == ".cow" then
				table.insert(return_table, file_name:sub(1, #file_name - 4))
			end
		end
		return return_table
	elseif flag ~= "" then
		if string.sub(flag, 1, 1) == "\"" then
			text = RemoveQuotesIfApplicable(flag)
			break
		else
			text = string.sub(Input, current_pos + 1, #Input - 1)
			break
		end

	end

	current_pos = current_pos + string.len(split_input[flag_num]) + 1
	flag_num = flag_num + 1
end

local text_length = 0
local wrapped_text = ""
if word_wrap then
	for _, line in pairs(SplitString(text, "\n")) do
		local wrapped_line = ""
		local current_len = 0
		for _, word in pairs(SplitString(line, " ")) do
			if #word > word_wrap then
				for i = 1, #word, word_wrap do
					wrapped_line = wrapped_line .. "\n" .. word:sub(i, i + word_wrap - 1)
				end
				current_len = #word % word_wrap
				text_length = word_wrap
			elseif current_len + #word > word_wrap then
				wrapped_line = wrapped_line .. "\n" .. word
				text_length = math.max(text_length, current_len - 1)
				current_len = #word
			else
				wrapped_line = wrapped_line .. " " .. word
				current_len = current_len + #word + 1
			end
		end
		text_length = math.max(text_length, current_len - 1)
		wrapped_text = wrapped_text .. "\n" .. wrapped_line:sub(2)
	end
	wrapped_text = wrapped_text:sub(2)
else
	wrapped_text = text
	for  _, line in pairs(SplitString(text, "\n")) do
		text_length = math.max(text_length, #line)
	end
end

local bubble = " __" .. string.rep("_", text_length)

local lines = SplitString(wrapped_text, "\n")
for line_num = 1, #lines, 1 do
	local start_char = "|"
	local end_char = "|"
	if #lines == 1 then
		start_char = "<"
		end_char = ">"
	elseif line_num == 1 then
		start_char = "/"
		end_char = "\\"
	elseif line_num == #lines then
		start_char = "\\"
		end_char = "/"
	end
	bubble = bubble .. "\n" .. start_char .. " " .. string.format("%-" .. text_length + 1 .. "s", lines[line_num]) .. end_char
end

bubble = bubble .. "\n --" .. string.rep("-", text_length)

local cow_file_path = GetCommandItem(split_input[1])
table.insert(cow_file_path, cowfile .. ".cow")

local cow_text = get_text(cow_file_path)
if not cow_text then
	print(cowfile .. " file not found")
	return {}
end

cow_text = cow_text:match("$the_cow = <<\"?EOC\"?;\n(.+)\nEOC")
if not cow_text then
	print("cow art not found in file")
	return {}
end

cow_text = cow_text:gsub("%$thoughts", "\\")
cow_text = cow_text:gsub("%$eyes", eyes)
cow_text = cow_text:gsub("%$tongue", toung)
cow_text = cow_text:gsub("\\\\", "\\")

return {  bubble,  cow_text }

program:finish
