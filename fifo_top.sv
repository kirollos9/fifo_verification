/**********************************************************************************
 * module:fifo_top
 * auther:kirollos gerges sobhy
 **********************************************************************************/
module fifo_top();
	bit clk;
	/*******************************************************************************************
	 * declaring the clock for the system
	*******************************************************************************************/
	initial begin
		clk=0;
		forever begin
			#1clk=~clk;
		end
	end
	/*********************************************************************************
	 * concatinate every module with the interface 
	 *********************************************************************************/
	FIFO_if f (clk);
	FIFO dut (f);
	fifo_tb tb(f);
	//bind FIFO fifo_sva fifo_sva_inst(f); 
endmodule