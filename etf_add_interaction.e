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
			-- perform some update on the model state

			-- make sure interaction doesn't already exist
			if model.interaction_exists then

				model.set_report (model.interaction_not_unique)
			else
				model.add_interaction (id1, id2)
			end
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
