note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_DPR_Q
inherit 
	ETF_DPR_Q_INTERFACE
		redefine dpr_q end
create
	make
feature -- command 
	dpr_q
    	do
			-- perform some update on the model state
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
