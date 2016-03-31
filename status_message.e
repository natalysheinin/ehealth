note
	description: "Summary description for {STATUS_MESSAGE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class STATUS_MESSAGE

inherit
	ANY redefine out end


create

	pt_id_used,
	pt_id_nonpositive

feature {ETF_COMMAND}

	pt_id_used
	do
		create report.make_empty
		report := "patient id already in use"
	end

	pt_id_nonpositive
	do
		create report.make_empty
		report := "patient id must be a positive integer"
	end

feature {NONE} -- model attributes

	report: STRING

feature -- Output

	out: STRING_8
	do
		Result := report
	end

end
