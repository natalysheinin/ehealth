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
			if not(model.is_id_overflow (id)) then
				model.set_report (model.perscription_nonpositive)
			elseif not(model.prescription_exists (id)) then
				model.set_report (model.prescription_id_dne)
			elseif not(model.is_id_overflow (medicine)) then
				model.set_report (model.md_id_nonpositive)
			elseif not (model.md_exists_2 (medicine)) then
				model.set_report (model.medication_not_registered)
			elseif not(model.medicine_exists_for_rx(id, medicine)) then
				model.set_report (model.medication_not_in_rx)
			else
				model.remove_medicine(id, medicine)
			end
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
