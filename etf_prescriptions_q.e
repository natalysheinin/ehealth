note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_PRESCRIPTIONS_Q
inherit 
	ETF_PRESCRIPTIONS_Q_INTERFACE
		redefine prescriptions_q end
create
	make
feature -- command 
	prescriptions_q(medication_id: INTEGER_64)
		require else 
			prescriptions_q_precond(medication_id)
    	do
			-- perform some update on the model state
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
