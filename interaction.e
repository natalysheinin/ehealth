note
	description: "Summary description for {PERSCRIPTION}."
	author: "Nataly Sheinin"
	date: "$Date$"
	revision: "$Revision$"

class
	INTERACTION

inherit
	 COMPARABLE
                redefine is_equal, is_less
                end

create
	make

feature{NONE} -- Creation

        make(a_id:INTEGER_64; b_id: INTEGER_64)
                do
                      	 id1 := a_id
                       	 id2 := b_id

                end
             -- might change interaction to actually be made up of 2 medicine objects instead of integers.

feature -- interaction attributes

	id1 : INTEGER_64
	id2 : INTEGER_64


feature --redefine COMPARABLE methods
        is_equal (other: like Current): BOOLEAN
                        -- Is `other' value equal to current
              do
                if (other.id1 = id1 AND other.id2 = id2) then
                	Result := true

                end
			  ensure then
		      	Result = (other.id1 = id1 AND other.id2 = id2)
              end

        is_less alias "<" (other: like Current): BOOLEAN
                        -- Is current object less than `other'?
                do
                        if id1 < other.id1 then
                                Result := true
                        else
                                Result := false
                        end
                ensure then
                        Result = (id1 < other.id1)
                end

end
