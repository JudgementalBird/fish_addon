---- DEBUG / PRINT ----
function debugprint(...) --
	local args = {...}
	local assembled = ""
	for i = 1, #args do
		assembled = assembled .. tostring(args[i]) .. ", "
	end
	
	--trailing comma and space
	if #assembled > 2 then
		assembled = assembled:sub(1, -3)
	end

	assembled = assembled:gsub(".?.?#", ""):gsub("&.?.?", "")
	
	server.announce("[Fish Expansion]", assembled, ANNOUNCE_TO)
end
function peerprint(peer_id,...)
	ANNOUNCE_TO = peer_id
	debugprint(...)
	ANNOUNCE_TO = -1
end
--just different names to provide intent where calling:
function warn_entire_chat(...)
	debugprint(...)
end
function announce_to_entire_chat(...)
	debugprint(...)
end
function debug_announce_to_chat(debug_level,...)
	if logging.debugstate >= debug_level then
		debugprint(...)
	end
end
function warn_peer_in_chat(peer_id, ...)
	peerprint(peer_id, ...)
end

function print_r(t, fd)
	local function print(str)
		str = str or ""
		debugprint(str)
	end
	local print_r_cache={}
	local function sub_print_r(t,indent)
		local function quotesm(thing)
			if type(thing) == "string" then return "\""..thing.."\"" end
			return tostring(thing)
		end
		if (print_r_cache[tostring(t)]) then
			print(indent.."*"..tostring(t))
		else
		print_r_cache[tostring(t)]=true
		if (type(t)=="table") then
			for pos,val in pairs(t) do
				if (type(val)=="table") then
					print(indent.."["..quotesm(pos).."] = {")
					sub_print_r(val,indent..string.rep(" ",string.len(pos)+6))
					print(indent..string.rep(" ",string.len(pos)+4).."}")
				elseif (type(val)=="string") then
					print(indent.."["..quotesm(pos)..'] = "'..val..'"')
				else
					print(indent.."["..quotesm(pos).."] = "..tostring(val))
				end
			end
			else
				print(indent..tostring(t))
			end
		end
	end
	if (type(t)=="table") then
		print(" {")
		sub_print_r(t,"  ")
		print("}")
	else
		sub_print_r(t,"  ")
	end
	print()
end

function printsent(request)
	debug_announce_to_chat(2, "Sent: "..request)
end

function getreplyflag(reply)
	return reply:sub(1,reply:find("|") -1)
end
function withoutreplyflag(reply)
	return reply:sub(reply:find("|")+1, -1)
end
function hasreplyflag(reply)
	return is_number(reply:find("|"))
end

function getpeerflag(reply)
	return reply:sub(reply:find("#")+1, -1)
end
function withoutpeerflag(reply)
	return reply:sub(1, reply:find("#")-1)
end