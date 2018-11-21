local curl = require "lcurl.safe"

script_info = {
	["title"] = "去转盘",
	["description"] = "http://www.quzhuanpan.com/",
	["version"] = "0.0.1",
}

function onSearch(key, page)
	local data = ""
	local c = curl.easy{
		url = "http://www.quzhuanpan.com/source/search.action?q=" .. pd.urlEncode(key) .. "&days=down&o=1&currentPage=" .. page,
		followlocation = 1,
		timeout = 15,
		proxy = pd.getProxy(),
		writefunction = function(buffer)
			data = data .. buffer
			return #buffer
		end,
	}
	c:perform()
	c:close()
	return parse(data)
end

function onItemClick(item)
	return ACT_SHARELINK, item.url 
end

function parse(data)
	local result = {}
	local start = 1
	while true do
		local a, b, url, title, time = string.find(data, "data%-shorturl='(.-)'.-title=\"(.-)\".-<span class=\"default\">(%d%d%d%d%-%d%d%-%d%d)</span>", start)
		if url == nil then
			break
		end
		local tooltip = string.gsub(title, "<span style='color:red'>(.-)</span>", "%1")
		title = string.gsub(title, "<span style='color:red'>(.-)</span>", "{c #ff0000}%1{/c}")
		table.insert(result, {["url"] = "https://pan.baidu.com/s/" .. url, ["title"] = title, ["time"] = time, ["showhtml"] = "true", ["tooltip"] = tooltip, ["check_url"] = "true"})
		start = b + 1
	end
	return result
end