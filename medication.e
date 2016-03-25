note
	description: "Summary description for {MEDICATION}."
	author: "Michael Harrison"
	date: "$Date$"
	revision: "$Revision$"

class
	MEDICATION

inherit

	COMPARABLE
		redefine is_equal, is_less, out
		end

create
	make

feature {NONE} -- Initialization
	make(a_id: INTEGER_64; name: STRING; kind: INTEGER_64; low: VALUE; hi: VALUE)
	do
		create medicine.default_create
		medicine.name := name
		medicine.kind := kind
		medicine.low := low
		medicine.hi := hi
		id := a_id
	end

feature --model attributes

	medicine: TUPLE[name: STRING; kind: INTEGER_64; low: VALUE; hi: VALUE]
	id: INTEGER_64

feature --redefine COMPARABLE methods
	is_equal (other: like Current): BOOLEAN
			-- Is `other' value equal to current
		do
			Result := id = other.id
		ensure then
			Result = (id = other.id)
		end

	is_less alias "<" (other: like Current): BOOLEAN
			-- Is current object less than `other'?
		do
			if id < other.id then
				Result := true
			else
				Result := false
			end
		ensure then
			Result = (id < other.id)
		end

feature --model methods

	out : STRING
	local
		temp : STRING
	do
		temp := "[" + medicine.name + ","
		if (medicine.kind = 1) then
			temp := temp + "pl,"
		else
			temp := temp + "lq,"
		end
		temp := temp + medicine.low.out + "," + medicine.hi.out + "]"
		Result := temp
	end

end
