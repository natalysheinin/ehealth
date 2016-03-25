note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_ADD_PHYSICIAN
inherit
	ETF_ADD_PHYSICIAN_INTERFACE
		redefine add_physician end
create
	make
feature -- command
	add_physician(id: INTEGER_64 ; name: STRING ; kind: INTEGER_64)
		require else
			add_physician_precond(id, name, kind)
    	do
			-- perform some update on the model state

			model.add_physician(id, name, kind)
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
