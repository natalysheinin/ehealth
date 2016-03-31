note
	description: "Summary description for {DANGEROUS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	DANGEROUS

inherit
	 ANY
                redefine out
                end

create
        make

feature {NONE} -- Initialization
        make(p_name: STRING; p_id: INTEGER_64; med1: INTEGER_64; med2: INTEGER_64)
        do
                create patient_name.make_from_string (p_name)
                patient_id := p_id
                md1 := med1
                md2 := med2
        end

feature --model attributes

        patient_name: STRING
        patient_id: INTEGER_64
        md1: INTEGER_64
        md2: INTEGER_64

--feature --redefine COMPARABLE methods
--        is_equal (other: like Current): BOOLEAN
--                        -- Is `other' value equal to current
--              do
--                if (other.p_id = p_id AND other.p_name ~ p_name AND other.md1 = md1 AND other.md2 = md2) then
--                	Result := true

--                end
--			  ensure then
--		      	Result = (other.id1 = id1 AND other.id2 = id2)
--              end

--        is_less alias "<" (other: like Current): BOOLEAN
--                        -- Is current object less than `other'?
--                do
--                        if id1 < other.id1 then
--                                Result := true
--                        else
--                                Result := false
--                        end
--                ensure then
--                        Result = (id1 < other.id1)
--                end

feature --model methods

        out : STRING
        do
        		Result := "    (" + patient_name + "," + patient_id.out + ")->{ "
        end

end
