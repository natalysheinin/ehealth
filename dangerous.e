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

feature --model methods

        out : STRING
        do
        		Result := "(" + patient_name + "," + patient_id.out + ")->{ "
        end

end
