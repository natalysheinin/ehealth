note
	description: "Studenst write their tessts here"
	author: "Michael Harrison and Nataly Sheinin"
	date: "$Date$"
	revision: "$Revision$"

class
	MY_TESTS

inherit
	ES_TEST

create
	make

feature {NONE} -- Initialization
	zero : VALUE
	one: VALUE

	make
			-- Initialization for `Current'.
		do
			add_boolean_case (agent t1)
			add_boolean_case (agent t2)
			add_boolean_case (agent t3)
		end

feature -- tests
	t1: BOOLEAN
	local
		db:EHEALTH
	do
		--create db.make --commented since it needs access to class and currently restricted
		--db.add_patient (1, "mike")
		--db.add_patient (-1, "mike")
		comment("t1: Testing add_patient")
		Result := true
	end
	t2: BOOLEAN
	local
		db:EHEALTH
	do
		comment("t2: Testing add physician and add medication")
		Result := true
	end
	t3: BOOLEAN
	local
		db:EHEALTH
	do
		comment("t3: Testing main features of EHEALTH")
		Result := true
	end
end
