note
	description: "Summary description for {PHYSICIAN}."
	author: "Nataly"
	date: "$Date$"
	revision: "$Revision$"

class
	PHYSICIAN

inherit
	ANY

create
	make

feature{NONE} -- Creation

        make(a_id:INTEGER_64; a_name:STRING; a_type: INTEGER_64)
                        -- Create a customer with an `account'
--                local
--                        the_id: INTEGER_64
--                        the_name: STRING
--                        the_type: INTEGER_64
                do

                      	 id := a_id
                       	name := a_name
                       	type := a_type
--                       	create the_type.make_type(a_type)

                end

feature -- queries

	id : INTEGER_64
	name : STRING
	type : INTEGER_64

--        name: IMMUTABLE_STRING_8

--        balance: VALUE
--                do
--                        Result := account.balance
--                end

--        account: ACCOUNT

--        out : STRING
--                        -- Return a sorted list of customers.
--                do
--                        Result := "name: " + account.name + ", balance: " + account.balance.out
--                end


--invariant
--        name_consistency: name ~ account.name
--        balance_consistency: balance = account.balance

end
