local fortune_name = SplitString(Input, " ")[1]
local fortune_path = GetCommandItem(fortune_name)

local fortunes_list_path = fortune_path
table.insert(fortunes_list_path, "fortunes")
if not item_exists(fortunes_list_path) then
	new_item(fortunes_list_path)
	set_text(fortunes_list_path, get_data("https://raw.githubusercontent.com/bmc/fortunes/master/fortunes"))
end

local fortunes_list_text = get_text(fortunes_list_path)

local fortunes_list = SplitString(fortunes_list_text, "\n%%\n")

return { fortunes_list[math.random(1, #fortunes_list)] }
