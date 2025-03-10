local split_input = SplitString(Input, " ")
local path = StringToPath(split_input[2])

if not item_exists(path) then
    print("item not found: " .. PathToString(path))
    return
end

local new_text = ""

print("type program:finish to finish writing your text")

while true do
    local input = io.read()
    if input == "program:finish" then
        new_text = string.sub(new_text, 1, string.len(new_text) - 1)
        break
    end
    new_text = new_text .. input .. "\n"
end

if not set_text(path, new_text) then
    print("cannot mutate immutable item")
end
