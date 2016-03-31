note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_ADD_MEDICINE
inherit
	ETF_ADD_MEDICINE_INTERFACE
		redefine add_medicine end
create
	make
feature -- command
	add_medicine(id: INTEGER_64 ; medicine: INTEGER_64 ; dose: VALUE)
		require else
			add_medicine_precond(id, medicine, dose)
    	do
			-- perform some update on the model state

			if (id < 1) then
				model.set_report(model.perscription_nonpositive)
			elseif not(model.prescription_exists(id)) then
				model.set_report(model.prescription_id_dne)
			elseif not(model.is_id_overflow(medicine)) then
				model.set_report (model.md_id_nonpositive)
			elseif not model.md_exists_2(medicine) then
				model.set_report(model.medication_not_registered)
--			elseif not model.check_md_already_pres(id) then --todo what
--				model.set_report(model.md_already_pres)
--			elseif model.is_danger_no_sp(id, medicine) then --todo method
--				model.set_report(model.specialist_required)
			elseif not(model.is_dosage_valid(id, medicine, dose)) then
				model.set_report(model.invalid_dosage)
			else
				model.add_medicine (id, medicine, dose)

			end
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
