note
	description: ""
	author: "Nataly Sheinin"
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
			 if (id < 1) then
                                model.set_report (model.phys_id_nonpositive)
                        elseif (not model.phys_is_id_unique (id)) then
                                model.set_report (model.phys_id_used)
                        elseif (not model.mn_name_unique (name)) then
                                model.set_report (model.phys_name_nonunique)
                        elseif (not model.name_valid (name)) then
                                model.set_report (model.phys_name_invalid)
                        else
                                model.add_physician(id, name, kind)
                        end

			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
