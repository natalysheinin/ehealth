note
	description: "A default business model."
	author: "Jackie Wang and Michael Harrison"
	date: "$Date$"
	revision: "$Revision$"

class
	EHEALTH

inherit
	ANY
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
			create {SORTED_TWO_WAY_LIST[MEDICATION]} medicine_set.make
			set_report("ok")
		end

feature -- model attributes
	s : STRING
	i : INTEGER_64

		-- INTEGER_64 used to meet range requirment of id
	patient_set : LIST[PATIENT]
	medicine_set : LIST[MEDICATION]

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
		medicine_set.extend (new_medication)
		set_report("ok")
	ensure
		number_of_md_increased:
			medicine_set.count = old medicine_set.count + 1
		md_added_to_list:
			md_exists(id, medicine.name, medicine.kind, medicine.low, medicine.hi)
		other_md_unchanged:
			pd_unchanged_other_than(id, medicine.name, old medicine_set.deep_twin)
	end

feature --util
		-- check if medication already exists in the database
	md_exists(a_id: INTEGER_64; name: STRING; kind: INTEGER_64; low: VALUE; hi: VALUE): BOOLEAN
	do
		from
			medicine_set.start
			Result := false
		until
			Result or medicine_set.after
		loop
			if (medicine_set.item.id = a_id and
				medicine_set.item.medicine.name ~ name) then
				Result := true
			end
			medicine_set.forth
		end
	ensure
		Result = across medicine_set as md some
					md.item.id = a_id and md.item.medicine.name ~ name
				 end
	end

		-- check if medication with this name already exists in the database
	mn_name_unique(name: STRING): BOOLEAN
	do
		from
			medicine_set.start
			Result := true
		until
			medicine_set.after or not(Result)
		loop
			if (medicine_set.item.medicine.name ~ name) then
				Result := false
			end
			medicine_set.forth
		end
	end

		--Is the tructure sorted?
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

		--Is the tructure sorted?
	medicine_is_sorted: BOOLEAN
	local
		temp_medication : MEDICATION
	do
		from
			medicine_set.start
			Result := true
		until
			medicine_set.after or not Result
		loop
			temp_medication := medicine_set.item
			medicine_set.forth
			if (not medicine_set.after) then
				Result := temp_medication.id <= medicine_set.item.id
			end
		end
	end

		-- check if patient with this id and name exists in the database
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

		-- is the new id unique
	md_is_id_unique(id: INTEGER_64): BOOLEAN
	do
		from
			medicine_set.start
			Result := true
		until
			medicine_set.after or not (Result)
		loop
			if medicine_set.item.id = id then
				Result := false
			end
			medicine_set.forth
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

		-- are medications other than `id' and `name' unchanged?
	pd_unchanged_other_than(id: INTEGER_64; name: STRING; old_medicine_set: like medicine_set): BOOLEAN
	do
		old_medicine_set.compare_objects
		from
			Result := true
			medicine_set.start
		until
			medicine_set.after or not Result
		loop
			if (medicine_set.item.id /= id and
					medicine_set.item.medicine.name ~ name) then
				Result := Result and then
					old_medicine_set.has (medicine_set.item)
			end
			medicine_set.forth
		end
	ensure
		Result =
			across
				medicine_set as m all
					m.item.id /= id and m.item.medicine.name /~ name IMPLIES
						old_medicine_set.has (m.item)
				end
	end

		-- is this name a valid name (does it start with a letter)
	name_valid(name: STRING): BOOLEAN
	do
		if name.count > 0 then
			Result := name.at (1).is_alpha
		else
			Result := false
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

		-- check if all medication names and ids in the database are unique
	md_ids_and_names_is_unique: BOOLEAN
	local
		temp_id : INTEGER_64
		temp_name : STRING
	do
		from
			medicine_set.start
			Result := true
		until
			medicine_set.after or not (Result)
		loop
			temp_id := medicine_set.item.id
			temp_name := medicine_set.item.medicine.name
			from
				medicine_set.start
			until
				medicine_set.after
			loop
				medicine_set.forth
				if not medicine_set.after then
					if temp_id = medicine_set.item.id or
					   temp_name ~ medicine_set.item.medicine.name then
						Result := false
					end
				end
			end
			medicine_set.forth
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

		-- print out all medications in the medication database
	medication_to_string : STRING
	local
		temp : STRING
	do
		from
			medicine_set.start
			temp := ""
		until
			medicine_set.after
		loop
			temp := temp + "%N    " + medicine_set.item.id.out + "->" + medicine_set.item.out
			medicine_set.forth
		end
		temp := temp + "%N"
		Result := temp
	end


feature -- queries
		-- print out the state of the entire class
	out : STRING
		local
			temp : STRING
		do
			temp := "  " + i.out + ": " + report.out + "%N"
			temp := temp + "  Physicians:%N  Patients: " + patient_to_string.out + "  "
			temp := temp + "Medications: " + medication_to_string + "  "
			temp:= temp + "Interactions: %N  Prescriptions:%N"
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




