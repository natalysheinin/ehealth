note
        description: "Summary description for {PATIENT}."
        author: "Michael Harrison"
        date: "$Date$"
        revision: "$Revision$"

class
        PATIENT

inherit

        COMPARABLE
                redefine is_equal, is_less, out
                end

create
        make

feature {NONE} -- Initialization
        make(a_name: STRING; a_id: INTEGER_64)
        do
                create name.make_from_string (a_name)
                id := a_id
        end

feature --model attributes

        name: STRING
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
        do
                Result := name
        end

end
