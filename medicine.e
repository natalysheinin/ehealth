note
	description: "Summary description for {MEDICINE}."
	author: "Nataly Sheinin"
	date: "$Date$"
	revision: "$Revision$"

class
	MEDICINE

inherit
	 COMPARABLE
                redefine is_equal, is_less, out
                end

create
	make

feature{NONE} -- Creation

        make(id: INTEGER_64 ; medicine: INTEGER_64 ; dose: VALUE)
                do
                      	 rx_id := id
                       	 med_md := medicine
                       	 med_dose := dose

                end

feature -- interaction attributes

	rx_id : INTEGER_64
	med_md : INTEGER_64
	med_dose : VALUE


feature --redefine COMPARABLE methods
        is_equal (other: like Current): BOOLEAN
                        -- Is `other' value equal to current
              do
                if (other.rx_id = rx_id AND other.med_md = med_md AND other.med_dose = med_dose) then
                	Result := true

                end
			  ensure then
		      	Result = (other.rx_id = rx_id AND other.med_md = med_md AND other.med_dose = med_dose)
              end

			--based on id of medicine
        is_less alias "<" (other: like Current): BOOLEAN
                        -- Is current object less than `other'?
                do
                        if med_md < other.med_md then
                                Result := true
                        elseif med_md = other.med_md and rx_id < other.rx_id then
                        		Result := true
                        else
                                Result := false
                        end
                ensure then
                        Result = (med_md < other.med_md)
                        or else (med_md = other.med_md and rx_id < other.rx_id)
                end

feature --model methods

        out : STRING
        do
                Result := med_md.out + "->" + med_dose.out
        end


end

