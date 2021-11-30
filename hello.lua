function split (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

filename = vim.fn.expand('%')
--filename = "main.c"
local file = assert(io.popen("~/.local/bin/norminette " .. filename))
local output = file:read('*all')
file:close()

output = split(output,"\n")
output_by_lines = {}
for i,out in pairs(output)
do
	if (string.match(out, "Error:") and string.match(out,"line:") and string.match(out,"\t*")) then
		s, e = string.find(out, "line:")
		line = string.match(out, "%d+",e)
		s, e = string.find(out, "col:")
		col = string.match(out, "%d+",e)
		s,e = string.find(out, "\t.+")
		out = string.sub(out, s+1,e)
		if output_by_lines[line]==nil then
			output_by_lines[line] = out .. "(col:" .. col .. ")"
		else
			output_by_lines[line] = output_by_lines[line] .. ", " .. out .. "(col:" .. col .. ")"
		end
	end
end

local bnr = vim.fn.bufnr('%')
local ns_id = vim.api.nvim_create_namespace('demo')
file = io.open(filename)
lines = file:lines()
line_number = 1
for line in lines
do
	if not (output_by_lines[tostring(line_number)]==nil) then
		local opts = {
		  --end_line = 10,
		  id = line_number+1,
		  virt_text = {{"  ",""},{output_by_lines[tostring(line_number)], "StatusLine"}},
		  virt_text_pos = 'eol',
		  -- virt_text_win_col = 20,
		}
		len = string.len(line)
		vim.api.nvim_buf_set_extmark(bnr, ns_id, line_number - 1, 0, opts)
	end
	line_number = line_number + 1
end
io.close(file)
