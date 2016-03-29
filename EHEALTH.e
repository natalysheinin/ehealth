note
        description: "A default business model."
        author: "Jackie Wang and Michael Harrison and Nataly Sheinin"
        date: "$Date$"
        revision: "$Revision$"

class
        EHEALTH

inherit
        ANY
                redefine
                        out
                end

		ETF_TYPE_CONSTRAINTS

				redefine
						out
				end

create {ETF_MODEL_ACCESS}
        make

feature {NONE} -- Initialization
        make
                        -- Initialization for `Current'.
                do
                        create s.make_empty
                        i := 0
                                -- initial size of patient hash talbe is 0
                        create {SORTED_TWO_WAY_LIST[PATIENT]} patient_set.make
                        create {SORTED_TWO_WAY_LIST[MEDICATION]} medication_set.make
                        create {SORTED_TWO_WAY_LIST[PHYSICIAN]} physician_set.make
                        create {SORTED_TWO_WAY_LIST[PRESCRIPTION]} prescriptions.make
						create {SORTED_TWO_WAY_LIST[INTERACTION]} interactions.make
						create {SORTED_TWO_WAY_LIST[MEDICINE]} medicines.make



                        set_report("ok")
                end

feature {NONE} -- model attributes
        s : STRING
        i : INTEGER_64

                -- INTEGER_64 used to meet range requirment of id
        patient_set : LIST[PATIENT]
        medication_set : LIST[MEDICATION]
        physician_set : LIST[PHYSICIAN]

        interactions: LIST[INTERACTION]
        prescriptions: LIST[PRESCRIPTION]
        medicines: LIST[MEDICINE]

feature -- model operations
        default_update
                        -- Perform update to the model state.
                do
                        i := i + 1

                end

        reset
                        -- Reset model state.
                do
                        make
                end

feature {ETF_COMMAND} -- reports
        report: STRING
        attribute
                create Result.make_empty
        end

        pt_id_used: STRING
        attribute
                Result := "patient id already in use"
        end

        pt_id_nonpositive: STRING
        attribute
                Result := "patient id must be a positive integer"
        end

        pt_name_invalid: STRING
        attribute
                Result := "patient name must start with a letter"
        end

        md_name_invalid: STRING
        attribute
                Result := "medication name must start with a letter"
        end

        md_name_nonunique: STRING
        attribute
                Result := "medication name already in use"
        end

        md_id_nonunique: STRING
        attribute
                Result := "medication id already in use"
        end

        md_id_nonpositive: STRING
        attribute
                Result := "medication id must be a positive integer"
        end

		phys_id_nonpositive: STRING
        attribute
                Result := "physician id must be a positive integer"
        end

        phys_name_invalid: STRING
        attribute
                Result := "physician name must start with a letter"
        end

        phys_id_used: STRING
        attribute
                Result := "physician id already in use"
        end

        phys_name_nonunique: STRING
        attribute
                Result := "physician name already in use"
        end

        interaction_not_unique: STRING
        attribute
        		Result := "interaction already exists"
        end

        interaction_different: STRING
        attribute
        		Result := "medication ids must be different"
        end

        interaction_not_registered: STRING
        attribute
        		Result := "medications with these ids must be registered"
        end

        invalid_interaction_id: STRING
        attribute
        		Result := "medication ids must be positive integers"
        end

        prescription_not_unique: STRING
        attribute
        		Result := "prescription id already in use"
        end

        physician_not_valid: STRING
        attribute
        		Result := "physician with this id not registered"
        end

        perscription_nonpositive: STRING
        attribute
        		Result := " prescription id must be a positive integer"
        end

		patient_not_valid: STRING
		attribute
				Result := "physician with this id not registered"
		end

feature -- set report
        set_report (nr: STRING)
        do
                report := nr
        end

feature --command
                -- add new patient to database
        add_patient(id: INTEGER_64 ; name: STRING)
                -- check id precondition first
        require
                int_64_invalid:
                        is_id_overflow(id)
                id_unique_invalid:
                        is_id_unique(id)
                name_begins_letter:
                        name_valid(name)
        local
                new_patient : PATIENT
        do
                create new_patient.make (name, id)
                patient_set.extend (new_patient)
                set_report("ok")
        ensure
                number_of_pt_increased:
                        patient_set.count = old patient_set.count + 1
                pt_added_to_list:
                        pt_exists(id, name)
                other_pt_unchanged:
                        pt_unchanged_other_than(id, old patient_set.deep_twin)
        end

				--add new physician to the database
		add_physician(a_id: INTEGER_64; a_name: STRING; a_kind: INTEGER_64)
		require
                int_64_invalid:
                        is_id_overflow(a_id)
                id_unique_invalid:
                        phys_is_id_unique(a_id)
                name_begins_letter:
                        name_valid(a_name)

		local
				new_physician : PHYSICIAN
		do
				create new_physician.make (a_id, a_name, a_kind)
				physician_set.extend (new_physician)
				set_report("ok")

		ensure
				number_of_phys_increased:
                        physician_set.count = old physician_set.count + 1

		end
                -- add new medication to the database
        add_medication(id: INTEGER_64 ; medicine: TUPLE[name: STRING; kind: INTEGER_64; low: VALUE; hi: VALUE])
        require
   				int_64_invalid:
                        is_id_overflow(id)
                id_unique_invalid:
                        md_is_id_unique(id)
                medicine_name_unique:
                        mn_name_unique(medicine.name)
                name_begins_letter:
                        name_valid(medicine.name)
        local
                new_medication : MEDICATION
        do
                create new_medication.make (id, medicine.name, medicine.kind, medicine.low, medicine.hi)
                medication_set.extend (new_medication)
                set_report("ok")
        ensure
                number_of_md_increased:
                        medication_set.count = old medication_set.count + 1
                md_added_to_list:
                        md_exists(id, medicine.name, medicine.kind, medicine.low, medicine.hi)
                other_md_unchanged:
                        pd_unchanged_other_than(id, medicine.name, old medication_set.deep_twin)
        end

			-- add new interaction to the database
        add_interaction(a_id: INTEGER_64; b_id: INTEGER_64)
        require
        	medicine_1_exists:
        			md_exists_2(a_id)
        	medicine_2_exists:
        			md_exists_2(b_id)
        	check_interaction_exists:
        			not interaction_exists(a_id, b_id)
        	different_intereactions:
        			not(a_id = b_id)
        	is_valid:
        			is_id_overflow(a_id)
        	is_valid_2:
        			is_id_overflow(b_id)

        local
        	new_interaction : INTERACTION
			md1 : STRING
			md2 : STRING
        do
        	--get medicine names

			md1 := (medication_set.at (get_md(a_id))).medicine.name
			md2 := (medication_set.at (get_md(b_id))).medicine.name

            --set id1 to medicine who's name is less
            if (md1 < md2) then
            	create new_interaction.make (a_id, b_id)
            else
            	create new_interaction.make (b_id, a_id)
            end

        	interactions.extend (new_interaction)
        	set_report("ok")

         ensure
                number_of_interactions_increased:
                        interactions.count = old interactions.count + 1
        end

        	--add a prescription to the database
        new_prescription(id: INTEGER_64 ; doctor: INTEGER_64 ; patient: INTEGER_64)
        require
        	ps_by_generalist:
        		true
        	id_is_valid:
        		is_id_overflow(id)
        	doc_is_valid:
        		is_id_overflow(doctor)
        	patient_is_valid:
        		is_id_overflow(patient)
        	id_is_unique:
        		not(prescription_exists(id))
        	doc_exists:
        		phys_exists(doctor)
        	patient_exists:
        		pt_id_exists(patient)
        local
        	new_ps : PRESCRIPTION
        do
        	create new_ps.make (id, doctor, patient)
        	prescriptions.extend (new_ps)
        	set_report("ok")

        end

        	--add a medicine to a prescription (stores it in medicine database)
        	add_medicine(med_id: INTEGER_64 ; medicine: INTEGER_64 ; dose: VALUE)
        	require
        		id_is_valid:
        			is_id_overflow(med_id)
        		med_id_is_valid:
        			is_id_overflow(medicine)
        		dose_is_valid:
        			true
        		medication_exists:
        			md_exists_2(medicine)
        		medicine_is_unique:
        			true
        		-- A new medicine can be added to a prescription by a generalist provided that it does not
				-- cause a dangerous interaction with other medicines taken by the patient. A specialist can add
				-- a dangerous interaction, provided it appears in the dpr_q query.
        		medicine_safe:
        			true
			local
				new_medicine : MEDICINE
			do
				create new_medicine.make (med_id, medicine, dose)
				medicines.extend(new_medicine)
				set_report("ok")

			end

feature --util
                -- is id greater than or less than limits
        is_id_overflow(id: INTEGER_64): BOOLEAN
        do
                if (id > 9223372036854775807 or id < 1) then
                        Result := false
                else
                        Result := true
                end
        ensure
                Result = (id <= 9223372036854775807 and id >= 1)
        end

--		 is_value_overflow(id: VALUE): BOOLEAN
--        do
--                if (id > 9223372036854775807 or id < 1) then
--                        Result := false
--                else
--                        Result := true
--                end
--        ensure
--                Result = (id <= 9223372036854775807 and id >= 1)
--        end

                -- is this name a valid name (does it start with a letter)
        name_valid(name: STRING): BOOLEAN
        do
                if name.count > 0 then
                        Result := name.at (1).is_alpha
                else
                        Result := false
                end
        end
       	-----------------------------------------------------------------------------------MEDICINE HELPERS
       	-- print out all prescriptions in the prescriptions database
		medicine_to_string : STRING
		local
			temp : STRING
		do
			from
				medicines.start
				temp := ""
			until
				medicines.after
			loop
				  temp := temp + medicines.item.out
				  medicines.forth
			end

			Result := temp
		end
       	-------------------------------------------------------------------------------MEDICINE HELPERS END
		-------------------------------------------------------------------------------PRESCRIPTION HELPERS
		--if prescription exists, returns true, otherwise returns false.
		prescription_exists(id: INTEGER_64) : BOOLEAN
		do
			from
                        prescriptions.start
                        Result := false

                until
                        prescriptions.after or Result
                loop
                        if (prescriptions.item.p_id = id) then
                        		Result  := true

                        end
                        prescriptions.forth
                end
		end


		-- print out all prescriptions in the prescriptions database
		prescriptions_to_string : STRING
		local
			temp : STRING
		do
			from
				prescriptions.start
				temp := ""
			until
				prescriptions.after
			loop
				  temp := temp + "%N    " + prescriptions.item.p_id.out + "->" + prescriptions.item.out
				  temp := temp + "("
				  -- print associated medicines here AKA call medicine out method
				  temp := temp + medicine_to_string
				  temp := temp + ")]"

				prescriptions.forth
			end

			Result := temp
		end
		----------------------------------------------------------------------------PRESCRIPTION HELPERS END

		--------------------------------------------------------------------------------INTERACTION HELPERS
		-- returns true if interaction exists
		interaction_exists(id1: INTEGER_64; id2: INTEGER_64): BOOLEAN
		do
			from
				interactions.start
				Result := false
			until
				interactions.after or Result
			loop
				if (interactions.item.id1 = id1 AND interactions.item.id2 = id2) then
					Result := true
				elseif (interactions.item.id1 = id2 AND interactions.item.id2 = id1) then
					Result := true
				else
					Result := false
				end

				interactions.forth
			end

		end

		-- print out all interactions in the interactions database
		interaction_to_string : STRING
		local
			temp : STRING
		do
			from
				interactions.start
				temp := ""
			until
				interactions.after
			loop
				temp := temp + "%N    [" + (medication_set.at(get_md(interactions.item.id1)).medicine.name).out + ","
				if ((medication_set.at(get_md(interactions.item.id1)).medicine.kind) = 1) then
                        temp := temp + "pl,"
                else
                        temp := temp + "lq,"
                end
				temp := temp + (medication_set.at(get_md(interactions.item.id1)).id ).out + "]->["
				temp := temp + (medication_set.at(get_md(interactions.item.id2)).medicine.name).out + ","
				if ((medication_set.at(get_md(interactions.item.id2)).medicine.kind) = 1) then
			                        temp := temp + "pl,"
			                else
			                        temp := temp + "lq,"
			                end
	 			temp := temp + (medication_set.at(get_md(interactions.item.id2)).id).out + "]"

				interactions.forth
			end

			Result := temp
		end
        ----------------------------------------------------------------------------INTERACTION HELPERS END

        ---------------------------------------------------------------------------------MEDICATION HELPERS
               -- get index of medicine using the_id
        get_md(the_id: INTEGER_64): INTEGER
        local
        	temp : BOOLEAN
        	count : INTEGER
        do
                from
                        medication_set.start
                        temp := true
						count := 0

                until
                        medication_set.after or not(temp)
                loop
                        if (medication_set.item.id = the_id) then
                        		temp := false

                        end
                        medication_set.forth
                        count := count + 1
                end
                Result := count
        end


               -- find medicine with id
               -- returns true if found, false otherwise
        md_exists_2(the_id: INTEGER_64): BOOLEAN
        do
                from
                        medication_set.start
                        Result := false

                until
                        medication_set.after or Result
                loop
                        if (medication_set.item.id = the_id) then
                        		Result  := true

                        end
                        medication_set.forth
                end
        end


                -- check if medication already exists in the database
        md_exists(a_id: INTEGER_64; name: STRING; kind: INTEGER_64; low: VALUE; hi: VALUE): BOOLEAN
        do
                from
                        medication_set.start
                        Result := false
                until
                        Result or medication_set.after
                loop
                        if (medication_set.item.id = a_id and
                                medication_set.item.medicine.name ~ name) then
                                Result := true
                        end
                        medication_set.forth
                end
        ensure
                Result = across medication_set as md some
                                        md.item.id = a_id and md.item.medicine.name ~ name
                                 end
        end

                -- check if medication with this name already exists in the database
        mn_name_unique(name: STRING): BOOLEAN
        do
                from
                        medication_set.start
                        Result := true
                until
                        medication_set.after or not(Result)
                loop
                        if (medication_set.item.medicine.name ~ name) then
                                Result := false
                        end
                        medication_set.forth
                end
        end

                   --Is the structure sorted?
        medicine_is_sorted: BOOLEAN
        local
                temp_medication : MEDICATION
        do
                from
                        medication_set.start
                        Result := true
                until
                        medication_set.after or not Result
                loop
                        temp_medication := medication_set.item
                        medication_set.forth
                        if (not medication_set.after) then
                                Result := temp_medication.id <= medication_set.item.id
                        end
                end
        end
                -- is the new id unique
        md_is_id_unique(id: INTEGER_64): BOOLEAN
        do
                from
                        medication_set.start
                        Result := true
                until
                        medication_set.after or not (Result)
                loop
                        if medication_set.item.id = id then
                                Result := false
                        end
                        medication_set.forth
                end
        end

                 -- are medications other than `id' and `name' unchanged?
        pd_unchanged_other_than(id: INTEGER_64; name: STRING; old_medication_set: like medication_set): BOOLEAN
        do
                old_medication_set.compare_objects

		 from
                        Result := true
                        medication_set.start
                until
                        medication_set.after or not Result
                loop
                        if (medication_set.item.id /= id and
                                        medication_set.item.medicine.name ~ name) then
                                Result := Result and then
                                        old_medication_set.has (medication_set.item)
                        end
                        medication_set.forth
                end
        ensure
                Result =
                        across
                                medication_set as m all
                                        m.item.id /= id and m.item.medicine.name /~ name IMPLIES
                                                old_medication_set.has (m.item)
                                end
        end

                -- check if all medication names and ids in the database are unique
        md_ids_and_names_is_unique: BOOLEAN
        local
                temp_id : INTEGER_64
                temp_name : STRING
        do
                from
                        medication_set.start
                        Result := true
                until
                        medication_set.after or not (Result)
                loop
                        temp_id := medication_set.item.id
                        temp_name := medication_set.item.medicine.name
                        from
                                medication_set.start
                        until
                                medication_set.after
                        loop
                                medication_set.forth
                                if not medication_set.after then
                                        if temp_id = medication_set.item.id or
                                           temp_name ~ medication_set.item.medicine.name then
                                                Result := false
                                        end
                                end
                        end
                        medication_set.forth
                end
        end

                -- print out all medications in the medication database
        medication_to_string : STRING
        local
                temp : STRING
        do
                from
                        medication_set.start
                        temp := ""
                until
                        medication_set.after
                loop
                        temp := temp + "%N    " + medication_set.item.id.out + "->" + medication_set.item.out
						medication_set.forth
                end
                temp := temp + "%N"
                Result := temp
        end


        -----------------------------------------------------------------------------MEDICATION HELPERS END

        ------------------------------------------------------------------------------------PATIENT HELPERS
                --Is the structure sorted?
        patient_is_sorted: BOOLEAN
        local
                temp_patient : PATIENT

		  do
                from
                        patient_set.start
                        Result := true
                until
                        patient_set.after or not Result
                loop
                        temp_patient := patient_set.item
                        patient_set.forth
                        if (not patient_set.after) then
                                Result := temp_patient.id <= patient_set.item.id
                        end
                end
        end

                -- check if patient with this id and name exists in the database
                -- returns true if patient exists, false otherwise
        pt_exists(id: INTEGER_64; name: STRING): BOOLEAN
        do
                from
                        patient_set.start
                        Result := false
                until
                        Result or patient_set.after
                loop
                        if (patient_set.item.id = id) and (patient_set.item.name ~ name) then
                                Result := true
                        end
                        patient_set.forth
                end

        end
        		-- check if patient with this id and name exists in the database using just id
                -- returns true if patient exists, false otherwise
        pt_id_exists(id: INTEGER_64): BOOLEAN
         do
                from
                        patient_set.start
                        Result := false
                until
                        Result or patient_set.after
                loop
                        if (patient_set.item.id = id) then
                                Result := true
                        end
                        patient_set.forth
                end

        end

                -- is the new id unique
        is_id_unique(id: INTEGER_64): BOOLEAN
        do
                from
                        patient_set.start
                        Result := true
                until
                        patient_set.after or not (Result)
                loop
                        if patient_set.item.id = id then
                                Result := false
                        end
                        patient_set.forth
                end
        end

                -- are patients other than `id' unchanged?
        pt_unchanged_other_than(id: INTEGER_64; old_patient_set: like patient_set): BOOLEAN
        do
                old_patient_set.compare_objects
                from
                        Result := true
                        patient_set.start
                until
                        patient_set.after or not Result
                loop
                        if patient_set.item.id /= id then
                                Result := Result and then
                                        old_patient_set.has (patient_set.item)
                        end
                        patient_set.forth
                end
        ensure
                Result =
                        across
                                patient_set as p all
                                        p.item.id /= id IMPLIES
                                                old_patient_set.has (p.item)
                                end
        end

               -- check if all patient ids in the database are unique
        pt_ids_is_unique: BOOLEAN
        local
                temp_id : INTEGER_64
        do
                from
                        patient_set.start
                        Result := true
                until
                        patient_set.after or not (Result)
                loop
                        temp_id := patient_set.item.id
                        from
                                patient_set.start
                        until
                                patient_set.after
                        loop
                                patient_set.forth
                                if not patient_set.after then
                                        if temp_id = patient_set.item.id then
                                                Result := false
                                        end
                                end
                        end
                        patient_set.forth
                end
        end

        -- print out all patients in the patient database
        patient_to_string : STRING
        local
                temp : STRING
        do
                from
                        patient_set.start
                        temp := ""
                until
                        patient_set.after
                loop
                        temp := temp + "%N    " + patient_set.item.id.out + "->" + patient_set.item.name.out
                        patient_set.forth
                end
                temp := temp +"%N"
                Result := temp
        end
        --------------------------------------------------------------------------------PATIENT HELPERS END

        ----------------------------------------------------------------------------------PHYSICIAN HELPERS
		 --Is the structure sorted?
		 physician_is_sorted: BOOLEAN
        local
                temp_phys : PHYSICIAN

		  do
                from
                        physician_set.start
                        Result := true
                until
                        physician_set.after or not Result
                loop
                        temp_phys := physician_set.item
                        physician_set.forth
                        if (not physician_set.after) then
                                Result := temp_phys.id <= physician_set.item.id
                        end
                end
        end
		         -- is the new id unique - physician
        phys_is_id_unique(id: INTEGER_64): BOOLEAN
        do
                from
                        physician_set.start
                        Result := true
                until
                        physician_set.after or not (Result)
                loop
                        if physician_set.item.id = id then
                                Result := false
                        end
                        physician_set.forth
                end
        end

				-- returns true if physician exists, and false otherwise
		phys_exists(id: INTEGER_64) : BOOLEAN
		 do
                from
                        physician_set.start
                        Result := false
                until
                        physician_set.after or Result
                loop
                        if physician_set.item.id = id then
                                Result := true
                        end
                        physician_set.forth
                end
        end

        -- print out all physicians in the medication database
		physician_to_string : STRING
		local
			temp : STRING
		do
			from
				physician_set.start
				temp := ""
			until
				physician_set.after
			loop
				temp := temp + "%N    " + physician_set.item.id.out + "->" + physician_set.item.out
				physician_set.forth
			end
			temp := temp + "%N"
			Result := temp
		end


         -----------------------------------------------------------------------------PHYSICIAN HELPERS END


feature -- queries
                -- print out the state of the entire class
        out : STRING
                local
                        temp : STRING
                do
                        temp := "  " + i.out + ": " + report.out + "%N"
                        temp := temp + "  Physicians: " + physician_to_string.out + "  "
                        temp := temp + "Patients: " + patient_to_string.out + "  "
                        temp := temp + "Medications: " + medication_to_string + "  "
                        temp := temp + "Interactions: "  + interaction_to_string + " %N "
                        temp := temp + " Prescriptions: " + prescriptions_to_string + "%N"
                        create Result.make_from_string (temp)
                end

invariant
                -- patient ids must be unique
        pt_ids_unique:
                pt_ids_is_unique
                -- patient structure must be sorted by ids
        pt_are_sorted:
                patient_is_sorted
                -- medication ids AND names must be unique
        md_ids_and_names_unique:
                md_ids_and_names_is_unique
                -- medicantion structure is sorted by ids
        md_are_sorted:
                medicine_is_sorted
end



