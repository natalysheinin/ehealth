note
	description: ""
	author: "Michael Harrison and Nataly Sheinin"
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
			if not(model.is_id_overflow(medication_id)) then
				model.set_report(model.md_id_nonpositive)
			elseif not(model.md_exists_2(medication_id)) then
				model.set_report(model.medication_not_registered)
			else
				model.prescriptions_q(medication_id)
			end
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
