function execute_potential_admin_possibility(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)
	if is_admin then
		for possibility_key,possibility in ipairs(admin_possibilities.http) do
			local match = false
			for k,v in ipairs(possibility.command) do
				if (command == v) then
					match = true
				end
			end
			if match == true then
				possibility.send(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)
			elseif type(possibility.commandfunction) == "function" then
				if possibility.commandfunction(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four) then
					possibility.send(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)
				end
			end
		end
		for possibility_key,possibility in ipairs(admin_possibilities.no_http) do
			local match = false
			for k,v in ipairs(possibility.command) do
				if (command == v) then
					match = true
				end
			end
			if match == true then
				possibility.run(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)
			elseif type(possibility.commandfunction) == "function" then
				if possibility.commandfunction(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four) then
					possibility.run(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)
				end
			end
		end
	end
end