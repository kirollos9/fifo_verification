/**********************************************************************************
 * module:fifo_test
 * auther:kirollos gerges sobhy
 **********************************************************************************/

class fifo_class;
	rand logic rst;
	rand logic wr_en;
	rand logic rd_en;
	rand logic [15:0] data;
	rand logic [15:0] other;
	constraint c {
		rst dist {0:=1,1:=99};
		wr_en dist {0:=50,1:=50};
		rd_en dist {0:=50,1:=50};
		other != (16'h0000&&16'hffff);
		data dist {other:=50,0:=50,16'hffff:=50};
	}


endclass

module fifo_tb(FIFO_if.TEST f);
	logic [15:0] fifo_queue[$];
	logic [15:0] rand_test[10000];
	int index;
	int q_ind[$];
	covergroup cov @(posedge f.clk);
		rst_cover_point: coverpoint f.rst_n{
		bins z_rst={0};
		bins one_rst={1};
		}
		wr_cover_point: coverpoint f.wr_en{
		bins z_w={0};
		bins one_w={1};
		}
		rd_cover_point: coverpoint f.rd_en{
		bins z_rd={0};
		bins one_rd={1};
		}
		data_cover_point: coverpoint f.data_in{
		bins max={16'hffff};
		bins min ={16'h0000};
		bins other =default;
		bins min_max=(16'h0000=>16'hffff);
		bins max_min=(16'hffff=>16'h0000);
		}
		c1: cross rst_cover_point,wr_cover_point{
			bins wr_rst= binsof(rst_cover_point.one_rst) && binsof(wr_cover_point.one_w);
		}
		c2: cross rst_cover_point,rd_cover_point{
			bins rd_rst= binsof(rst_cover_point.one_rst) && binsof(rd_cover_point.one_rd);
			

		}


	endgroup
	cov cover_inst =new();
	fifo_class cl=new();
	initial begin
		f.rd_en=0;//just to not see x
		f.wr_en=0;// just for initialization
		// first we reset the design before anything
		reset();
		//make the tests input
		for(int i=0;i<10000;i++)begin
			assert(cl.randomize());
			rand_test[i]=cl.data;
		end
		//dirct test to test the under flow flag
		f.rd_en=1;
		f.data_in=rand_test[0];
		@(negedge f.clk);
		f.rd_en=0;

		// testing a the write of  full fifo
		index=0;
		while (fifo_queue.size!=512)begin
			assert (cl.randomize());
			//f.wr_en=cl.wr_en;
			f.wr_en=1;
			if(f.wr_en==1)begin
				f.data_in=rand_test[index];
				fifo_queue.push_back(f.data_in);
				index++;	
			end
			@(negedge f.clk);
			
		end
		f.wr_en=0;
		//direct test to test the over flow flag and assertions
		f.wr_en=1;
		f.data_in=$random;
		@(negedge f.clk);
		f.wr_en=0;
		//tetsting the read from full fifo 
		while(fifo_queue.size!=0)begin
			assert (cl.randomize());
			//f.rd_en=cl.rd_en;
			f.rd_en=1;
			if(f.rd_en==1)begin
				@(negedge f.clk);
				check_read(fifo_queue.pop_front());
			end
		
			

		end
		//random test 

		for(int i=0;i<10000;i++)begin
			assert (cl.randomize());
			f.wr_en=cl.wr_en;
			f.rd_en=!cl.wr_en;
			f.rst_n=cl.rst;
			if(f.rd_en==1&&f.rst_n==1&&f.wr_en==0&&f.empty==0)begin
				@(negedge f.clk);
				check_read(fifo_queue.pop_front());
			end
			if(f.wr_en==1&&f.rst_n==1&&f.rd_en==0&&f.full==0)begin
				f.data_in=cl.data;
				fifo_queue.push_back(f.data_in);	
				@(negedge f.clk);
			end
			
		end
		
			
		

		$display("donne");
		$stop;


	
	end
	task reset();
		f.rst_n=0;
		@(negedge f.clk);
		f.rst_n=1;

	endtask
	task check_read(input logic [15:0] expected);
		if(expected!==f.data_out) $display("there is an error the data out is=%0h and it was expected %0h",f.data_out,expected);
	endtask
	// assert that if the fifo is full then there is no write 
	property a1;
		@(posedge f.clk) f.full |=> !f.wr_ack;
	endproperty
		//this check is almostfull and then one write is done then full signal will get high
	property a2;
		@(posedge f.clk) (f.almostfull ##1 f.wr_ack) |=> f.full;
	endproperty
		//if almostfull is rise and then rd_en is one then empty flag must be set
	property a3;
		@(posedge f.clk) f.rd_en&f.almostempty |=> f.empty;
	endproperty
		// if empty is set and rd_en is set then under flow is done 
	property a4;
		@(posedge f.clk) (f.empty &f.rd_en) |-> f.underflow;
	endproperty
		//if full is set and there is a write operation is done then over fllow is set 
	property a5;
		@(posedge f.clk) (f.full&f.wr_en) |=> f.overflow;
	endproperty
	assert1: assert property(a1);
	assert2: assert property(a2);
	assert3: assert property(a3);
	assert4: assert property(a4);
	assert5: assert property(a5);

	c_assert1: cover property(a1);
	c_assert2: cover property(a2);
	c_assert3: cover property(a3);
	c_assert4: cover property(a4);
	c_assert5: cover property(a5);
	

endmodule 