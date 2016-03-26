note
	description: "Summary description for {PERSCRIPTION}."
	author: "Nataly Sheinin"
	date: "$Date$"
	revision: "$Revision$"

class
	INTERACTION

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

end
