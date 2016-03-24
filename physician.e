note
	description: "Summary description for {PHYSICIAN}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PHYSICIAN

inherit
--	PHYSICIANTYPE

create
	make_physician

feature{NONE} -- Creation

        make_physician(a_id:INTEGER; a_name:STRING; a_type: PHYSICIANTYPE)
                        -- Create a customer with an `account'
                local
                        the_id: INTEGER
                        the_name: STRING
                        the_type: PHYSICIANTYPE
                do
                       	the_id := a_id
                       	the_name := a_name
                       	create the_type.make_type(a_type)

                end

feature -- queries

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
