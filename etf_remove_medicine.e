note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_REMOVE_MEDICINE
inherit
	ETF_REMOVE_MEDICINE_INTERFACE
		redefine remove_medicine end
create
	make
feature -- command
	remove_medicine(id: INTEGER_64 ; medicine: INTEGER_64)
		require else
			remove_medicine_precond(id, medicine)
    	do
			-- perform some update on the model state
			--model.remove_medicine(id, medicine)
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
