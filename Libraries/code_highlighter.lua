function HighlightCode(code)
	local keywords = {
		["if"] = 4,
		["then"] = 4,
		["else"] = 4,
		["elseif"] = 4,
		["end"] = 4,
		["for"] = 4,
		["while"] = 4,
		["repeat"] = 4,
		["until"] = 4,
		["break"] = 4,
		["function"] = 2,
		["local"] = 2,
		["return"] = 2,
		["and"] = 6,
		["or"] = 6,
		["not"] = 6,
		["="] = 6,
		["=="] = 6,
		["~="] = 6,
		["<="] = 6,
		["<"] = 6,
		[">="] = 6,
		[">"] = 6,
		["+"] = 6,
		["-"] = 6,
		["*"] = 6,
		["/"] = 6,
		["%"] = 6,
		["in"] = 2,
		["nil"] = 1,
		["true"] = 1,
		["false"] = 1,
	}
	local number_color = 1
	local comment_color = 8
	local function_color = 5
	local other_color = 15
	local delimiters = {
		["["] = 12,
		["]"] = 12,
		["("] = 12,
		[")"] = 12,
		["{"] = 12,
		["}"] = 12,
		[","] = 12,
		[":"] = 12,
		["."] = 12,
		["\""] = 11,
		["'"] = 11,
		[" "] = 0,
		["	"] = 0,
		["\n"] = 0,
	}

	local new_string = ""
	local temp_code = " " .. code .. " \""
	local last_delimiter = 1
	local quotations = 0 -- 0 for none, 1 for ', 2 for "
	local comment = false
	for i = 1, #temp_code do
		local character = temp_code:sub(i, i)
		local delimiter_code = delimiters[character]
		if character == "-" and temp_code:sub(i + 1, i + 1) == "-" then
				comment = true
		elseif delimiter_code then
			if character == "'" and not comment then
				if quotations == 1 then
					if temp_code:sub(i - 1, i - 1) ~= "\\" or temp_code:sub(i - 2, i - 2) == "\\" then
						quotations = 0
					end
				elseif quotations == 0 then
					quotations = 1
				end
			elseif character == "\"" and not comment then
				if quotations == 2 then
					if temp_code:sub(i - 1, i - 1) ~= "\\" or temp_code:sub(i - 2, i - 2) == "\\" then
						quotations = 0
					end
				elseif quotations == 0 then
					quotations = 2
				end
			end
			if quotations == 0 then
				if (character == "'" or character == "\"") and not comment then
					local text = temp_code:sub(last_delimiter + 1, i)
					last_delimiter = i
					new_string = new_string .. "\27[38;5;" .. delimiter_code .. "m" .. text
				elseif not comment or character == "\n" then
					local word = temp_code:sub(last_delimiter + 1, i - 1)
					last_delimiter = i
					local color_code = keywords[word]
					if character == "(" then
						new_string = new_string .. "\27[38;5;" .. function_color .. "m" .. word
					elseif color_code then
						new_string = new_string .. "\27[38;5;" .. color_code .. "m" .. word
					elseif comment then
						new_string = new_string .. "\27[38;5;" .. comment_color .. "m" .. word
					elseif tonumber(word) then
						new_string = new_string .. "\27[38;5;" .. number_color .. "m" .. word
					else
						new_string = new_string .. "\27[38;5;" .. other_color .. "m" .. word
					end
					new_string = new_string .. "\27[38;5;" .. delimiter_code .. "m" .. character
					comment = false
				end
			end
		end
	end
	return new_string:sub(21) .. "\27[0m"
end
