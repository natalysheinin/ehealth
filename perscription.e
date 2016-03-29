note
	description: "Summary description for {PERSCRIPTION}."
	author: "Nataly Sheinin"
	date: "$Date$"
	revision: "$Revision$"

class
	PERSCRIPTION

inherit

        COMPARABLE
                redefine is_equal, is_less
                end

create
        make

feature {NONE} -- Initialization
		make(id: INTEGER_64 ; doctor: INTEGER_64 ; patient: INTEGER_64)
		do
				p_id := id
				p_doctor := doctor
				p_patient := patient

		end

feature -- perscription attributes

	p_id : INTEGER_64
	p_doctor : INTEGER_64
	p_patient : INTEGER_64

feature --redefine COMPARABLE methods
        is_equal (other: like Current): BOOLEAN
                        -- Is `other' value equal to current
              do
                if (other.p_id = p_id AND other.p_doctor = p_doctor AND other.p_patient = p_patient) then
                	Result := true

                end
			  ensure then
		      	Result = (other.p_id = p_id AND other.p_doctor = p_doctor AND other.p_patient = p_patient)
              end

        is_less alias "<" (other: like Current): BOOLEAN
                        -- Is current object less than `other'?
                do
                        if p_id < other.p+id then
                                Result := true
                        else
                                Result := false
                        end
                ensure then
                        Result = (p_id < other.p_id)
                end
end
