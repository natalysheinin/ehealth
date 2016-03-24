note
	description: "Summary description for {PHYSICIANTYPE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PHYSICIANTYPE


create
	make_type

feature{NONE} -- Creation

        make_type(a_type:STRING)
        local
        	type : STRING
        do
        	type := a_type
        end
end
