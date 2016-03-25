note
	description: "Summary description for {PHYSICIAN}."
	author: "Nataly"
	date: "$Date$"
	revision: "$Revision$"

class
	PHYSICIAN

inherit
	 COMPARABLE
                redefine is_equal, is_less, out
                end

create
	make

feature{NONE} -- Creation

        make(a_id:INTEGER_64; a_name:STRING; a_type: INTEGER_64)
                do
                      	 id := a_id
                       	name := a_name
                       	type := a_type

                end

feature -- physician attributes

	id : INTEGER_64
	name : STRING
	type : INTEGER_64

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
                temp := "[" + physician.name + "," + physician.kind + "]"

                Result := temp
        end

end
