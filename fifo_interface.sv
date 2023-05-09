/**********************************************************************************
 * module:fifo_interface
 * auther:kirollos gerges sobhy
 **********************************************************************************/
interface FIFO_if(clk);
	/****************************************************************************
	 * input clk 
	 ****************************************************************************/
	input bit clk;
	/****************************************************************************
	 * input design
	 ****************************************************************************/
	logic [15:0]data_in;
	logic wr_en;
	logic rd_en;
	logic rst_n;
	/****************************************************************************
	 * output design
	 ****************************************************************************/
	 logic [15:0]data_out;
	 logic full;
	 logic almostfull;
	 logic empty;
	 logic almostempty;
	 logic overflow;
	 logic underflow;
	 logic wr_ack;
	 /*****************************************************************************************************************
	  *                                        modports  
	  *****************************************************************************************************************/
	 modport DUT(input clk,data_in,wr_en,rd_en,rst_n,output data_out,full,almostfull,empty,almostempty,overflow,underflow,wr_ack);//modports for the design 
	 modport TEST (input clk,data_out, full, almostfull, empty, almostempty, overflow, underflow, wr_ack,output data_in, wr_en, rd_en, rst_n);//modports for the testbench
endinterface 