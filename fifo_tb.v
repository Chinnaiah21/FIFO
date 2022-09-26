module tb;
reg clk=0; always #5 clk = clk+1;
reg rst=1; initial #2 rst =0;
reg rd=0, rdNBA;
reg wr=0, wrNBA=0;
reg [7:0] din=0, dinNBA=0;
wire [7:0] dout;
wire [3:0] wrptr,rdptr;
wire nostock, housefull;

`ifdef workaround
wire [7:0] Box[1:10];
assign Box[1]=tb.kabali.Box[1];
assign Box[2]=tb.kabali.Box[2];
assign Box[3]=tb.kabali.Box[3];
assign Box[4]=tb.kabali.Box[4];
assign Box[5]=tb.kabali.Box[5];
assign Box[6]=tb.kabali.Box[6];
assign Box[7]=tb.kabali.Box[7];
assign Box[8]=tb.kabali.Box[8];
assign Box[9]=tb.kabali.Box[9];
assign Box[10]=tb.kabali.Box[10];
`endif

always@* {rdNBA,wrNBA, dinNBA}<= {rd,wr,din};

fifo kabali
(
clk,rst,wrNBA,rdNBA,dinNBA,dout, wrptr, rdptr, nostock, housefull
);

task wrpulse;
begin
	@(posedge clk);
	wr=1; din=$random;
	@(posedge clk);
	wr=0; din=0;
end
endtask

task rdpulse;
begin
	@(posedge clk);
	rd=1; 
	@(posedge clk);
	rd=0; 
end
endtask

reg [1:0] flag;
initial 
begin
repeat(1000)
	begin
    flag=$random;//00,01,10,11
	case (flag)
		2'b00: {wr,rd}=2'b00;
		2'b01: wrpulse;
		2'b10: rdpulse;
		2'b11: fork
				wrpulse;
				rdpulse;
				join
	endcase
	
	repeat (5) @(posedge clk);
	end
$finish;
end
endmodule