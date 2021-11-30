local bnr = vim.fn.bufnr('%')
local ns_id = vim.api.nvim_create_namespace('demo')
line_number = 1
while line_number < 1000
do
	vim.api.nvim_buf_del_extmark(bnr, ns_id, line_number)
	line_number = line_number + 1
end
