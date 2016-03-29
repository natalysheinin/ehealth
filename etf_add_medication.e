note
        description: ""
        author: "Michael Harrison"
        date: "$Date$"
        revision: "$Revision$"

class
        ETF_ADD_MEDICATION
inherit
        ETF_ADD_MEDICATION_INTERFACE
                redefine add_medication end
create
        make
feature -- command
        add_medication(id: INTEGER_64 ; medicine: TUPLE[name: STRING; kind: INTEGER_64; low: VALUE; hi: VALUE])
                require else
                        add_medication_precond(id, medicine)
        do
                        -- perform some update on the model state
                        if (id < 1) then
                                model.set_report (model.md_id_nonpositive)
                        elseif (not model.md_is_id_unique (id)) then
                                model.set_report (model.md_id_nonunique)
                        elseif (not model.mn_name_unique (medicine.name)) then
                                model.set_report (model.md_name_nonunique)
                        elseif (not model.name_valid (medicine.name)) then
                                model.set_report (model.md_name_invalid)
                        else
                                model.add_medication (id, medicine)
                        end
                        model.default_update
                        etf_cmd_container.on_change.notify ([Current])
        end

end
