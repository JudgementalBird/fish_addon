user_possibilities = {
	http = {
		{
			command = {"?howmany","?hm","?howmanydetail","?hmd"},
			send = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				local detail = 0
				if command:find("d") then
					detail = 1
				end
				local request = "/howmanyfish/"..get_steam_id(user_peer_id).."/"..detail.."/"..user_peer_id
				send_peer_http(request)
			end,
			replyflags = {"thismanyfish"},
			handlers = {
				function(reply)
					local to_print
					local peer_flag = getpeerflag(reply)
					if peer_flag == nil then
						peer_flag = -1
						to_print = withoutpeerflag(reply)
						warn_entire_chat("Backend didn't send back peer id to direct message to, this will not cause a crash, but please contact judge")
					else
						peer_flag = tonumber(peer_flag)
						to_print = withoutreplyflag(withoutpeerflag(reply))
					end
					peer_popup(peer_flag, 8, to_print)
				end
			}
		}
	},
	no_http = {
		{
			command = {"?fishhelp","?fhelp"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				-- v this is ENTIRELY copied from dog addon with 1 word changed v
				if one then
					--check user http possibilities for alias match
					for _,http_possibility in ipairs(user_possibilities.http) do
						local found = false
						for _,v in ipairs(http_possibility.command) do
							if v:find(one) then
								found = true
							end
						end
						if found then
							local text = "Command has the following aliases: "
							for k,v in ipairs(http_possibility.command) do
								text = text..v..", "
							end
							peerprint(user_peer_id,text:sub(1,-3))
						end
					end
					--check user non-http possibilities for alias match
					for _,possibility in ipairs(user_possibilities.no_http) do
						local found = false
						for _,v in ipairs(possibility.command) do
							if v:find(one) then
								found = true
							end
						end
						if found then
							local text = "Command has the following aliases: "
							for k,v in ipairs(possibility.command) do
								text = text..v..", "
							end
							peerprint(user_peer_id,text:sub(1,-3))
						end
					end
				else
					local commands = ""
					for k,v in ipairs(user_possibilities.http) do
						commands = commands..v.command[1]..", "
					end
					for k,v in ipairs(user_possibilities.no_http) do
						commands = commands..v.command[1]..", "
					end
					commands = commands:sub(1,-3)
					peerprint(user_peer_id,"As a user you have access to the following commands, some of which may have aliases:\n"..commands)
					peerprint(user_peer_id,"FYI: Use ?fishhelp (command name) for more info about a specific command")
				end
				-- ^ this is ENTIRELY copied from dog addon with 1 word changed ^
			end
		}
	}
}