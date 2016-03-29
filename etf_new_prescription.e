note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_NEW_PRESCRIPTION
inherit
	ETF_NEW_PRESCRIPTION_INTERFACE
		redefine new_prescription end
create
	make
feature -- command
	new_prescription(id: INTEGER_64 ; doctor: INTEGER_64 ; patient: INTEGER_64)
		require else
			new_prescription_precond(id, doctor, patient)
    	do
			-- perform some update on the model state
			if  model.prescription_exists(id) then
				model.set_report(model.prescription_not_unique)

			elseif not(model.is_id_overflow (id)) then
				model.set_report (model.perscription_nonpositive)

			elseif not(model.is_id_overflow (doctor)) then
				model.set_report (model.phys_id_nonpositive)

			elseif not(model.is_id_overflow (patient)) then
				model.set_report (model.pt_id_nonpositive)

			elseif not(model.phys_exists(doctor))then
				model.set_report (model.physician_not_valid)

			elseif not(model.pt_id_exists(patient)) then
				model.set_report (model.patient_not_valid)

			else
				model.new_prescription (id, doctor, patient)
			end

			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
