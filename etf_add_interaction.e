note
	description: ""
	author: "Nataly Sheinin"
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_ADD_INTERACTION
inherit
	ETF_ADD_INTERACTION_INTERFACE
		redefine add_interaction end
create
	make
feature -- command
	add_interaction(id1: INTEGER_64 ; id2: INTEGER_64)
		require else
			add_interaction_precond(id1, id2)
    	do
--			-- perform some update on the model state

			-- make sure interaction doesn't already exist
			if not (model.is_id_overflow (id1)) or not(model.is_id_overflow(id2)) then
				model.set_report(model.invalid_interaction_id)
			elseif id1 = id2 then
				model.set_report(model.interaction_different)
			elseif model.interaction_exists(id1, id2) then
				model.set_report (model.interaction_not_unique)
			elseif model.md_exists_2 (id1) = false then
				model.set_report(model.interaction_not_registered)
			elseif model.md_exists_2(id2) = false then
				model.set_report(model.interaction_not_registered)

			else
				model.add_interaction (id1, id2)
			end
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
