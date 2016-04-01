note
	description: "A default business model."
	author: "Michael Harrison and Nataly Sheinin"
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
			create {SORTED_TWO_WAY_LIST [PATIENT]} patient_set.make
			create {SORTED_TWO_WAY_LIST [MEDICATION]} medication_set.make
			create {SORTED_TWO_WAY_LIST [PHYSICIAN]} physician_set.make
			create {SORTED_TWO_WAY_LIST [PRESCRIPTION]} prescriptions.make
			create {TWO_WAY_LIST [INTERACTION]} interactions.make
			create {SORTED_TWO_WAY_LIST [MEDICINE]} medicines.make

			create {TWO_WAY_LIST [DANGEROUS]} dpr_set.make

			query_active := false
			set_report ("ok")
		end

feature {NONE} -- model attributes

	s: STRING

	i: INTEGER_64

		-- INTEGER_64 used to meet range requirment of id

	patient_set: LIST [PATIENT]

	medication_set: LIST [MEDICATION]

	physician_set: LIST [PHYSICIAN]

	interactions: LIST [INTERACTION]

	prescriptions: LIST [PRESCRIPTION]

	medicines: LIST [MEDICINE]

	dpr_set: LIST [DANGEROUS]

	query_active: BOOLEAN

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

	md_already_pres : STRING
		attribute
			Result := "medication is already prescribed"
		end

	pt_id_nonpositive: STRING
		attribute
			Result := "patient id must be a positive integer"
		end

	pt_name_invalid: STRING
		attribute
			Result := "name must start with a letter"
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

	low_nle_high: STRING
		attribute
			Result := "require 0 < low-dose <= hi-dose"
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

	interaction_first_remove: STRING
		attribute --what?
			Result := "first remove conflicting medicine prescribed by generalist"
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
			Result := "prescription id must be a positive integer"
		end

	prescription_id_dne : STRING
		attribute
			Result := "prescription with this id does not exist"
		end
	patient_not_valid: STRING
		attribute
			Result := "patient with this id not registered"
		end

	prescription_exists_for_pair: STRING
		attribute
			Result := "prescription already exists for this physician and patient"
		end

	specialist_required: STRING
		attribute
			Result := "specialist is required to add a dangerous interaction"
		end

	medication_not_registered: STRING
		attribute
			Result := "medication id must be registered"
		end

	invalid_dosage: STRING
		attribute
			Result := "dose is outside allowed range"
		end

	medication_not_in_rx: STRING
		attribute
			Result := "medication is not in the prescription"
		end

feature -- set report

	set_report (nr: STRING)
		do
			report := nr
		end

feature --command

		-- add new patient to database
	add_patient (id: INTEGER_64; name: STRING)
			-- check id precondition first
		require
			int_64_invalid: is_id_overflow (id)
			id_unique_invalid: is_id_unique (id)
			name_begins_letter: name_valid (name)
		local
			new_patient: PATIENT
		do
			create new_patient.make (name, id)
			patient_set.extend (new_patient)
			set_report ("ok")
		ensure
			number_of_pt_increased: patient_set.count = old patient_set.count + 1
			pt_added_to_list: pt_exists (id, name)
			other_pt_unchanged: pt_unchanged_other_than (id, old patient_set.deep_twin)
		end

		--add new physician to the database
	add_physician (a_id: INTEGER_64; a_name: STRING; a_kind: INTEGER_64)
		require
			int_64_invalid: is_id_overflow (a_id)
			id_unique_invalid: phys_is_id_unique (a_id)
			name_begins_letter: name_valid (a_name)
		local
			new_physician: PHYSICIAN
		do
			create new_physician.make (a_id, a_name, a_kind)
			physician_set.extend (new_physician)
			set_report ("ok")
		ensure
			number_of_phys_increased: physician_set.count = old physician_set.count + 1
		end

			-- add new medication to the database
	add_medication (id: INTEGER_64; medicine: TUPLE [name: STRING; kind: INTEGER_64; low: VALUE; hi: VALUE])
		require
			int_64_invalid: is_id_overflow (id)
			id_unique_invalid: md_is_id_unique (id)
			medicine_name_unique: mn_name_unique (medicine.name)
			name_begins_letter: name_valid (medicine.name)
		local
			new_medication: MEDICATION
		do
			create new_medication.make (id, medicine.name, medicine.kind, medicine.low, medicine.hi)
			medication_set.extend (new_medication)
			set_report ("ok")
		ensure
			number_of_md_increased: medication_set.count = old medication_set.count + 1
			md_added_to_list: md_exists (id, medicine.name, medicine.kind, medicine.low, medicine.hi)
			other_md_unchanged: pd_unchanged_other_than (id, medicine.name, old medication_set.deep_twin)
		end

		-- add new interaction to the database

	add_interaction (a_id: INTEGER_64; b_id: INTEGER_64)
		require
			medicine_1_exists: md_exists_2 (a_id)
			medicine_2_exists: md_exists_2 (b_id)
			check_interaction_exists: not interaction_exists(a_id, b_id)
			different_intereactions: not (a_id = b_id)
			is_valid: is_id_overflow (a_id)
			is_valid_2: is_id_overflow (b_id)
		local
			new_interaction: INTERACTION
			md1: STRING
			md2: STRING
		do
				--get medicine names

			md1 := (medication_set.at (get_md (a_id))).medicine.name
			md2 := (medication_set.at (get_md (b_id))).medicine.name

				--set id1 to medicine who's name is less
			if (md1 < md2) then
				create new_interaction.make (a_id, b_id)
			else
				create new_interaction.make (b_id, a_id)
			end
			interactions.extend (new_interaction)
			set_report ("ok")
		ensure
			number_of_interactions_increased:
				interactions.count = old interactions.count + 1
			other_interactions_unchanged:
				interactions_unchanged_other_than(a_id, b_id, old interactions.deep_twin)
			interaction_added:
				interaction_exists (a_id, b_id)
		end

		--add a prescription to the database

	new_prescription (id: INTEGER_64; doctor: INTEGER_64; patient: INTEGER_64)
		require
			id_is_valid: is_id_overflow (id)
			doc_is_valid: is_id_overflow (doctor)
			patient_is_valid: is_id_overflow (patient)
			id_is_unique: not (prescription_exists (id))
			doc_exists: phys_exists (doctor)
			patient_exists: pt_id_exists (patient)
			is_no_presc:
				not prescription_exists_for_phy_pt (doctor,patient)
		local
			new_ps: PRESCRIPTION
		do
			create new_ps.make (id, doctor, patient)
			prescriptions.extend (new_ps)
			set_report ("ok")
		ensure
			number_of_prescriptions_increased: prescriptions.count = old prescriptions.count + 1
			other_prescriptions_unchanged:
				other_prescriptions_unchanged_other_than(id, doctor, patient, prescriptions.deep_twin)
		end

		--add a medicine to a prescription (stores it in medicine database)

	add_medicine (rx_id: INTEGER_64; medicine: INTEGER_64; dose: VALUE)
		require
			id_is_valid: is_id_overflow (rx_id)
			med_id_is_valid: is_id_overflow (medicine)
			dose_is_valid: true
			rx_is_valid: prescription_exists (rx_id)
			medication_exists: md_exists_2 (medicine)
				--NEED TO DO THIS!!! CHECK IF MEDICATION ALREADY PRESCRIBED TO PATIENT
			already_prescribed: true
			valid_dosage: is_dosage_valid (rx_id, medicine, dose)
		local
			new_medicine: MEDICINE
			my_patient: INTEGER_64
			my_doctor_id: INTEGER_64
			my_doctor_type: INTEGER_64
			dangerous_interaction_exists: BOOLEAN
		do
			my_patient := prescriptions.at (find_prescription_by_pid (rx_id).as_integer_32).p_patient
			my_doctor_id := prescriptions.at (find_prescription_by_pid (rx_id).as_integer_32).p_doctor
			my_doctor_type := physician_set.at (find_physician_by_id (my_doctor_id).as_integer_32).type
			dangerous_interaction_exists := check_interaction_dangerous (my_patient, medicine)
			if dangerous_interaction_exists then
					--IF SPECIALIST: you can add
				if (my_doctor_type = 4) then
					create new_medicine.make (rx_id, medicine, dose)
					medicines.extend (new_medicine)
					set_report ("ok")

						--IF GENERALIST: can't add
				else
						-- DO NOT ADD
						-- NEED TO LOOK INTO THIS! FOR PROPER DESIGN, THIS ERROR SHOULD THROW
						-- BEFORE EVEN GETTING HERE
						-- THIS IS A DESIGN DECISION - THIS IS WHY WE ADDED A POST CONDITION
					set_report (specialist_required)
				end

					--medicine is safe to add, and physician type doesn't matter
			else
				create new_medicine.make (rx_id, medicine, dose)
				medicines.extend (new_medicine)
				set_report ("ok")
			end
		end

	remove_medicine (rx_id: INTEGER_64; medicine: INTEGER_64)
		require
			rx_valid: is_id_overflow (rx_id)
			prescription_id_exists: prescription_exists (rx_id)
			medicine_valid: is_id_overflow (medicine)
			rx_exists: prescription_exists (rx_id)
			medicine_exists: md_exists_2 (medicine)
		do
				-- find medicine with this prescription id

			medicines.go_i_th (find_medicine_by_rxid (rx_id, medicine).as_integer_32)
			medicines.remove
			set_report ("ok")
		ensure
			number_of_medicines_decreased: medicines.count = old medicines.count - 1
		end

feature --queries

	-- dangerous prescription report
	-- e.g. There are dangerous prescriptions:
	--(Dora,3)->{ [Sulfamethizole,pl,2]->[Wafarin,pl,1] }
	dpr_q
		local
			list_of_meds: LIST [INTEGER_64]
			count : INTEGER_32
			new_dpr : DANGEROUS
		do
			query_active := true

			from
				patient_set.start
--				create {TWO_WAY_LIST [INTEGER_64]} list_of_meds.make
			until
				patient_set.after
			loop
					create {TWO_WAY_LIST [INTEGER_64]} list_of_meds.make
					from
						prescriptions.start
					until
						prescriptions.after
					loop
							if (prescriptions.item.p_patient = patient_set.item.id) then
									from
										medicines.start
									until
										medicines.after
									loop
										-- add to list!
										if (medicines.item.rx_id = prescriptions.item.p_id) then
											list_of_meds.extend (medicines.item.med_md)
										end
										medicines.forth
									end
							end
						prescriptions.forth
					end

						--CHECK FOR DANGEROUS INTERACTION PER PATIENT
										from
											list_of_meds.start
											count := 1
										until
											list_of_meds.after
										loop
											from
												count := 1
											until
												list_of_meds.count = (count + 1) -- one extra
											loop
												if (interaction_exists(list_of_meds.item, list_of_meds.at (count))) then
													--add to dpr_set
													--check if it exists in dpr_set already if does, don't add
													if not(check_exists_dpr(patient_set.item.id, list_of_meds.item, list_of_meds.at(count))) then
														create new_dpr.make (patient_set.item.name, patient_set.item.id, list_of_meds.item, list_of_meds.at(count))
														dpr_set.extend (new_dpr)
													end

												end
												count := count + 1
											end

											list_of_meds.forth
										end

				patient_set.forth
			end

			dpr_to_string

			create {TWO_WAY_LIST [DANGEROUS]} dpr_set.make

				--An interaction is always printed by name alphabetically, e.g. [mn3,lq,3]->[mn8,pl,8] and
				-- not [mn8,pl,8] -> [mn3,lq,3]. However, in the dpr report, the dangerous interactions are
				-- entered in the set in the order they appear,e.g. for patient pt3:
				-- (pt3,3)->{ [mn1,pl,1]- >[mn2,pl,2], [mn3,lq,3]->[mn8,pl,8] }. ???? wtf test against oracle
		end

		-- shows list of patient-ids -> patients
		-- with this medication in a prescription

	prescriptions_q (medication_id: INTEGER_64)
		require
			medication_valid: is_id_overflow (medication_id)
			medication_exists: md_exists_2 (medication_id)
		do
			query_active := true
			p_q_to_string (medication_id)
		end

feature --util
	-- is id greater than or less than limits

	is_id_overflow (id: INTEGER_64): BOOLEAN
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

	name_valid (name: STRING): BOOLEAN
		do
			if name.count > 0 then
				Result := name.at (1).is_alpha
			else
				Result := false
			end
		end
	------------------------------------------------------------------------------------------QUERY HELPERS
	--returns true if it already exists in the dpr set
	check_exists_dpr(pid: INTEGER_64; md1: INTEGER_64; md2: INTEGER_64) : BOOLEAN
	local
		temp : BOOLEAN
	do
		from
				dpr_set.start
				temp := false
		until
				dpr_set.after or temp
				loop
					if (dpr_set.item.patient_id = pid AND dpr_set.item.md1 = md1 AND dpr_set.item.md2 = md2) then
						temp := true
					elseif (dpr_set.item.patient_id = pid AND dpr_set.item.md1 = md2 AND dpr_set.item.md2 = md1) then
						temp := true
					end
					dpr_set.forth
				end
		Result := temp
	end

	dpr_to_string
	local
		temp : STRING
		medication_index_1 : INTEGER_64
		medication_index_2 : INTEGER_64
	do
		temp := "  "

		if dpr_set.count > 0 then
			temp := temp + "There are dangerous prescriptions:"
		else
		 	temp := temp + "There are no dangerous prescriptions"
		end

		from
			dpr_set.start
		until
			dpr_set.after
		loop

			medication_index_1 := find_medication_by_id(dpr_set.item.md1)
			medication_index_2 := find_medication_by_id(dpr_set.item.md2)

			temp := temp + "%N"
			temp := temp + dpr_set.item.out + "[" + medication_set.at(medication_index_1.as_integer_32).medicine.name + ","
			 if (medication_set.at(medication_index_1.as_integer_32).medicine.kind = 1) then
                        temp := temp + "pl"
             else
                        temp := temp + "lq"
             end
			temp := temp + "," + medication_set.at(medication_index_1.as_integer_32).id.out
			temp := temp + "]->[" + medication_set.at(medication_index_2.as_integer_32).medicine.name + ","
			 if (medication_set.at(medication_index_2.as_integer_32).medicine.kind = 1) then
                        temp := temp + "pl"
             else
                        temp := temp + "lq"
             end
			temp := temp + "," + medication_set.at(medication_index_2.as_integer_32).id.out  + "] }"

			dpr_set.forth
		end

		set_report (temp)
	end

	p_q_to_string (mid: INTEGER_64)
		local
			temp: STRING
		do
			temp := "  Output: medication is " + (medication_set.at (find_medication_by_id (mid).as_integer_32)).medicine.name.out
			temp := temp + pq_helper (mid)
			set_report (temp)
		end

	pq_helper (mid: INTEGER_64): STRING
		local
			temp: STRING
		do
			temp := ""
			from
				patient_set.start
			until
				patient_set.after
			loop
					from
						prescriptions.start
					until
						prescriptions.after
					loop
						if prescriptions.item.p_patient = patient_set.item.id then
								from
									medicines.start
								until
									medicines.after
								loop
									if (medicines.item.rx_id = prescriptions.item.p_id AND medicines.item.med_md = mid)then
										-- print medicine
										temp := temp + "%N"
										temp := temp + "    " + patient_set.item.id.out + "->" + patient_set.item.name
									end
									medicines.forth
								end
						end
						prescriptions.forth
					end
					patient_set.forth
			end
			Result := temp
		end
		----------------------------------------------------------------------------------QUERY HELPERS END

		-----------------------------------------------------------------------------------MEDICINE HELPERS
		-- returns true if medicine exists for this specific prescription, false otherwise
		medicine_exists_for_rx(rx_id: INTEGER_64; med_id: INTEGER_64) : BOOLEAN
		local
			count: INTEGER_64
			temp: BOOLEAN
		do
			from
				medicines.start
				count := 1
				temp := false
			until
				medicines.after or temp
			loop
				if (medicines.item.rx_id = rx_id AND medicines.item.med_md = med_id) then
					temp := true
				end
				medicines.forth
				count := count + 1
			end

			Result := temp
		end

		-- special helper function required for medicine creation
		-- returns true if medication to be added will cause dangerous interaction with another prescripted medicine, otherwise false

		check_interaction_dangerous (the_patient_id: INTEGER_64; the_medication_id: INTEGER_64): BOOLEAN
		local
			dangerous_interaction_exists: BOOLEAN
			new_danger: DANGEROUS
		do
				--loop through prescriptions to find all prescriptions for a patient
			from
				prescriptions.start
				dangerous_interaction_exists := FALSE
			until
				prescriptions.after or dangerous_interaction_exists
			loop
					-- prescription for patient is found
				if prescriptions.item.p_patient = the_patient_id then
						-- loop through medicines with prescription id to find all medicines in that prescription
					from
						medicines.start
					until
						medicines.after or dangerous_interaction_exists
					loop
							-- medicine from a prescription is found
						if medicines.item.rx_id = prescriptions.item.p_id then
								-- it exists in the interaction database , meaning it is dangerous and can only be added by a specialist
							if interaction_exists (the_medication_id, medicines.item.med_md) then
								dangerous_interaction_exists := true

								create new_danger.make(patient_set.at(find_patient_by_id(the_patient_id).as_integer_32).name, the_patient_id, the_medication_id, medicines.item.med_md)
								dpr_set.extend (new_danger)
							end
						end
						medicines.forth
					end
				end
				prescriptions.forth
			end
			Result := dangerous_interaction_exists
		end

		-- returns true if dosage is within valid range, false otherwise

		is_dosage_valid (this_rx: INTEGER_64; this_med: INTEGER_64; this_dose: VALUE): BOOLEAN
		local
			temp: BOOLEAN
			d_min: VALUE
			d_max: VALUE
		do
			d_min := medication_set.at (find_medication_by_id (this_med).as_integer_32).medicine.low
			d_max := medication_set.at (find_medication_by_id (this_med).as_integer_32).medicine.hi
			temp := false
			if (this_dose <= d_max AND this_dose >= d_min) then
				temp := true
			end
			Result := temp
		end

		-- returns index of medicine with prescription id: rx_id & medication id med_id

	find_medicine_by_rxid (rx_id: INTEGER_64; med_id: INTEGER_64): INTEGER_64
		local
			count: INTEGER_64
			temp: BOOLEAN
		do
			from
				medicines.start
--				count := 1
				count := 0
				temp := false
			until
				medicines.after or temp
			loop
				count := count + 1
				if (medicines.item.rx_id = rx_id and medicines.item.med_md = med_id) then
					Result := count
					temp := true
				end
				medicines.forth

			end
		end
			--check if medicine is part of a dangerous interaction
			--returns true if medicine is part of dangerous interaction, and false if not.

	med_is_dangerous (mid: INTEGER_64): BOOLEAN
		do
			from
				interactions.start
				Result := false
			until
				interactions.after or Result
			loop
				if (interactions.item.id1 = mid OR interactions.item.id2 = mid) then
					Result := true
				end
				interactions.forth
			end
		end

		-- ensure other prescriptions unchanged

	other_prescriptions_unchanged_other_than(a_id : INTEGER_64; a_doctor : INTEGER_64; a_patient : INTEGER_64; old_prescriptions : like prescriptions) : BOOLEAN

	do
		old_prescriptions.compare_objects
		from
			prescriptions.start
			Result := true
		until
			prescriptions.after or not Result
		loop
			if a_id = -1 then
				Result := false
			end
			prescriptions.forth
		end
	end


		--if medicine exists, returns true, otherwise returns false.

	medicine_exists (id: INTEGER_64): BOOLEAN
		do
			from
				medicines.start
				Result := false
			until
				medicines.after or Result
			loop
				if (medicines.item.rx_id = id) then
					Result := true
				end
				medicines.forth
			end
		end

		-- print out all prescriptions in the prescriptions database

	medicine_to_string (rx_id: INTEGER_64): STRING
		local
			temp: STRING
			count: INTEGER_64
		do
			from
				medicines.start
				temp := ""
				count := 0
			until
				medicines.after
			loop
				if medicines.item.rx_id = rx_id then
					if count > 0 then
						temp := temp + ","
					end
					temp := temp + medicines.item.out
					count := count + 1
				end
				medicines.forth
			end
			Result := temp
		end
			-------------------------------------------------------------------------------MEDICINE HELPERS END
			-------------------------------------------------------------------------------PRESCRIPTION HELPERS
			--returns index of prescription with pid : id

	find_prescription_by_pid (id: INTEGER_64): INTEGER_64
		local
			count: INTEGER_64
			temp: BOOLEAN
		do
			from
				prescriptions.start
				count := 1
				temp := false
			until
				prescriptions.after or temp
			loop
				if (prescriptions.item.p_id = id) then
					Result := count
					temp := true
				end
				prescriptions.forth
				count := count + 1
			end
		end

	-- ensure no precription already exists for this physician and patient
	-- returns true is prescription exists, false otherwise.
	prescription_exists_for_phy_pt (a_doctor : INTEGER_64; a_patient : INTEGER_64): BOOLEAN
	local
		temp : BOOLEAN
	do
		temp := false
		from
			prescriptions.start
		until
			prescriptions.after or temp
		loop
			if prescriptions.item.p_doctor = a_doctor AND prescriptions.item.p_patient = a_patient then
					temp := true
			end
			prescriptions.forth
		end
		Result := temp
	end

	--if prescription exists, returns true, otherwise returns false.
	prescription_exists (id: INTEGER_64): BOOLEAN
		do
			from
				prescriptions.start
				Result := false
			until
				prescriptions.after or Result
			loop
				if (prescriptions.item.p_id = id) then
					Result := true
				end
				prescriptions.forth
			end
		end

		-- print out all prescriptions in the prescriptions database

	prescriptions_to_string: STRING
		local
			temp: STRING
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
				temp := temp + medicine_to_string (prescriptions.item.p_id)
				temp := temp + ")]"
				prescriptions.forth
			end
			Result := temp
		end
			----------------------------------------------------------------------------PRESCRIPTION HELPERS END

		--------------------------------------------------------------------------------INTERACTION HELPERS
		-- returns true if interaction conflicts with medications prescribed by at least one generalist
		-- otherwise returns false
		interaction_conflicts(md1: INTEGER_64; md2: INTEGER_64) : BOOLEAN
		local
			list_of_meds : LIST[INTEGER_64]
			temp : BOOLEAN
			count : INTEGER_32
		do
			from
				patient_set.start
				temp := false
			until
				patient_set.after or temp
			loop
					create {TWO_WAY_LIST [INTEGER_64]} list_of_meds.make
					from
						prescriptions.start
					until
						prescriptions.after or temp
					loop
							if (prescriptions.item.p_patient = patient_set.item.id AND ((physician_set.at(find_physician_by_id (prescriptions.item.p_doctor).as_integer_32).type)) = 3) then
									from
										medicines.start
									until
										medicines.after
									loop
										-- add to list!
										if (medicines.item.rx_id = prescriptions.item.p_id) then
											list_of_meds.extend (medicines.item.med_md)
										end
										medicines.forth
									end
							end
						prescriptions.forth
					end

					--CHECK FOR CONFLICTING INTERACTION
					if list_of_meds.count > 1 then
						from
											list_of_meds.start
											count := 1
										until
											list_of_meds.after or temp
										loop
											from
												count := 1
											until
												list_of_meds.count = count + 1  or temp-- one extra
											loop

												if (list_of_meds.item = md1 AND list_of_meds.at(count) = md2) then
													--interaction conflicts
													temp := true
												elseif (list_of_meds.item = md2 AND list_of_meds.at(count) = md1)  then
													temp := true
												end
												count := count + 1
											end
											list_of_meds.forth
										end
					end
				patient_set.forth
			end

			Result := temp
		end

		-- returns true if interaction exists
		interaction_exists (id1: INTEGER_64; id2: INTEGER_64): BOOLEAN
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

		interaction_to_string: STRING
		local
			temp: STRING
		do
			from
				interactions.start
				temp := " "
			until
				interactions.after
			loop
				temp := temp + "%N    [" + (medication_set.at (get_md (interactions.item.id1)).medicine.name).out + ","
				if ((medication_set.at (get_md (interactions.item.id1)).medicine.kind) = 1) then
					temp := temp + "pl,"
				else
					temp := temp + "lq,"
				end
				temp := temp + (medication_set.at (get_md (interactions.item.id1)).id).out + "]->["
				temp := temp + (medication_set.at (get_md (interactions.item.id2)).medicine.name).out + ","
				if ((medication_set.at (get_md (interactions.item.id2)).medicine.kind) = 1) then
					temp := temp + "pl,"
				else
					temp := temp + "lq,"
				end
				temp := temp + (medication_set.at (get_md (interactions.item.id2)).id).out + "]"
				interactions.forth
			end
			Result := temp
		end
			----------------------------------------------------------------------------INTERACTION HELPERS END

		---------------------------------------------------------------------------------MEDICATION HELPERS
		--returns index of medication with id : id

	find_medication_by_id (id: INTEGER_64): INTEGER_64
		local
			count: INTEGER_64
			temp: BOOLEAN
		do
			from
				medication_set.start
				count := 1
				temp := false
			until
				medication_set.after or temp
			loop
				if (medication_set.item.id = id) then
					Result := count
					temp := true
				end
				medication_set.forth
				count := count + 1
			end
		end

		-- get index of medicine using the_id

	get_md (the_id: INTEGER_64): INTEGER
		local
			temp: BOOLEAN
			count: INTEGER
		do
			from
				medication_set.start
				temp := true
				count := 0
			until
				medication_set.after or not (temp)
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

	md_exists_2 (the_id: INTEGER_64): BOOLEAN
		do
			from
				medication_set.start
				Result := false
			until
				medication_set.after or Result
			loop
				if (medication_set.item.id = the_id) then
					Result := true
				end
				medication_set.forth
			end
		end

		-- check if medication already exists in the database

	md_exists (a_id: INTEGER_64; name: STRING; kind: INTEGER_64; low: VALUE; hi: VALUE): BOOLEAN
		do
			from
				medication_set.start
				Result := false
			until
				Result or medication_set.after
			loop
				if (medication_set.item.id = a_id and medication_set.item.medicine.name ~ name) then
					Result := true
				end
				medication_set.forth
			end
		ensure
			Result = across medication_set as md some md.item.id = a_id and md.item.medicine.name ~ name end
		end

		-- check if medication with this name already exists in the database

	mn_name_unique (name: STRING): BOOLEAN
		do
			from
				medication_set.start
				Result := true
			until
				medication_set.after or not (Result)
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
			temp_medication: MEDICATION
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

	md_is_id_unique (id: INTEGER_64): BOOLEAN
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

	pd_unchanged_other_than (id: INTEGER_64; name: STRING; old_medication_set: like medication_set): BOOLEAN
		do
			old_medication_set.compare_objects
			from
				Result := true
				medication_set.start
			until
				medication_set.after or not Result
			loop
				if (medication_set.item.id /= id and medication_set.item.medicine.name ~ name) then
					Result := Result and then old_medication_set.has (medication_set.item)
				end
				medication_set.forth
			end
		ensure
			Result = across medication_set as m all m.item.id /= id and m.item.medicine.name /~ name IMPLIES old_medication_set.has (m.item) end
		end

		-- check if all medication names and ids in the database are unique

	md_ids_and_names_is_unique: BOOLEAN
		local
			temp_id: INTEGER_64
			temp_name: STRING
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
						if temp_id = medication_set.item.id or temp_name ~ medication_set.item.medicine.name then
							Result := false
						end
					end
				end
				medication_set.forth
			end
		end

		-- print out all medications in the medication database

	medication_to_string: STRING
		local
			temp: STRING
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
		--returns index of patient with id : id

	find_patient_by_id (id: INTEGER_64): INTEGER_64
		local
			count: INTEGER_64
			temp: BOOLEAN
		do
			from
				patient_set.start
				count := 1
				temp := false
			until
				patient_set.after or temp
			loop
				if (patient_set.item.id = id) then
					Result := count
					temp := true
				end
				patient_set.forth
				count := count + 1
			end
		end

		--Is the structure sorted?

	patient_is_sorted: BOOLEAN
		local
			temp_patient: PATIENT
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

		--check if medicine on dangerous interactions list is being precribed
		-- if yes, check if the sp is prescribing. return false if sp is prescribing
		-- return true if generalist is prescribing

	is_danger_no_sp(a_id : INTEGER_64; a_medicine: INTEGER_64): BOOLEAN
	do
		Result := false
	end

	-- check if patient with this id and name exists in the database
	-- returns true if patient exists, false otherwise
	pt_exists (id: INTEGER_64; name: STRING): BOOLEAN
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
	pt_id_exists (id: INTEGER_64): BOOLEAN
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

	is_id_unique (id: INTEGER_64): BOOLEAN
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

		-- are interactions other than `id1' and `id2' unchanged?
	interactions_unchanged_other_than(a_id1: INTEGER_64; a_id2: INTEGER_64; old_interactions: like interactions): BOOLEAN
	do
		old_interactions.compare_objects
		from
			interactions.start
		until
			interactions.after or Result
		loop
			if not (a_id1 = a_id2) then
				Result := true
			end
		end
	ensure
		Result =
			across
				interactions as inter
			all
				inter.item.id1 /~ a_id1 IMPLIES
					old_interactions.has (inter.item)
			end
	end

		-- ensure low value less than or equal to high
		-- returns true if 0 < low-dose <= hi-dose
	low_le_high(a_low : VALUE; a_high : VALUE): BOOLEAN
	local
		temp: VALUE
	do
		if temp.zero < a_low AND a_low <= a_high then
			Result := true
		else
			Result := false

		end
	end

		-- are patients other than `id' unchanged?

	pt_unchanged_other_than (id: INTEGER_64; old_patient_set: like patient_set): BOOLEAN
		do
			old_patient_set.compare_objects
			from
				Result := true
				patient_set.start
			until
				patient_set.after or not Result
			loop
				if patient_set.item.id /= id then
					Result := Result and then old_patient_set.has (patient_set.item)
				end
				patient_set.forth
			end
		ensure
			Result = across patient_set as p all p.item.id /= id IMPLIES old_patient_set.has (p.item) end
		end

		-- check if all patient ids in the database are unique

	pt_ids_is_unique: BOOLEAN
		local
			temp_id: INTEGER_64
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

	patient_to_string: STRING
		local
			temp: STRING
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
			temp := temp + "%N"
			Result := temp
		end
			--------------------------------------------------------------------------------PATIENT HELPERS END

		----------------------------------------------------------------------------------PHYSICIAN HELPERS
		--returns index of physician with physid : id

	find_physician_by_id (id: INTEGER_64): INTEGER_64
		local
			count: INTEGER_64
			temp: BOOLEAN
		do
			from
				physician_set.start
				count := 1
				temp := false
			until
				physician_set.after or temp
			loop
				if (physician_set.item.id = id) then
					Result := count
					temp := true
				end
				physician_set.forth
				count := count + 1
			end
		end

		--Is the structure sorted?

	physician_is_sorted: BOOLEAN
		local
			temp_phys: PHYSICIAN
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

	phys_is_id_unique (id: INTEGER_64): BOOLEAN
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
	phys_exists (id: INTEGER_64): BOOLEAN
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

	physician_to_string: STRING
		local
			temp: STRING
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

	out: STRING
		local
			temp: STRING
		do
			if query_active then
				temp := "  " + i.out + ": ok%N" + report.out
			else
				temp := "  " + i.out + ": " + report.out + "%N"
				temp := temp + "  Physicians:" + physician_to_string.out + "  "
				temp := temp + "Patients: " + patient_to_string.out + "  "
				temp := temp + "Medications: " + medication_to_string + "  "
				temp := temp + "Interactions:" + interaction_to_string + "%N  "
				temp := temp + "Prescriptions:" + prescriptions_to_string
			end
			query_active := false
			create Result.make_from_string (temp)
		end

invariant
		-- patient ids must be unique
	pt_ids_unique: pt_ids_is_unique
		-- patient structure must be sorted by ids
	pt_are_sorted: patient_is_sorted
		-- medication ids AND names must be unique
	md_ids_and_names_unique: md_ids_and_names_is_unique
		-- medicantion structure is sorted by ids
	md_are_sorted: medicine_is_sorted

end
