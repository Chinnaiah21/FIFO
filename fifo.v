module fifo (
input clk,rst,wr,rd,
input [7:0] din,
output reg [7:0] dout,
output reg [3:0] wrptr,
output reg [3:0] rdptr,
output nostock, housefull
);
integer i;
wire [3:0] wrptrplus1;
wire [3:0] rdptrplus1;
parameter PAR=2'b00,FUL=2'b01, EMP=2'b10;
reg[1:0] state;

wire s1,s2;

assign nostock = state==EMP;
assign housefull = state==FUL;

assign s1= wr && s2;
assign s2= (wrptrplus1==rdptr);
always @ (posedge clk or posedge rst)
begin
	if (rst) state<=EMP;
	else
	case (state)
	EMP: state <= wr ? PAR: EMP;
	PAR: case (1)
		rd && (rdptrplus1==wrptr): state<=EMP;
		wr && (wrptrplus1==rdptr): state <=FUL;
        default: state<=state;
		endcase		
	FUL: case({rd,wr})
			2'b00: state<=FUL;
			2'b01: state<=FUL;
			2'b10: state<=PAR;
			2'b11: state<= FUL;
		endcase
	endcase
end
	
always @ (posedge clk or posedge rst)
begin
	if (rst) rdptr<=1;
	else
	case (state)
	EMP: rdptr<=rdptr;
	PAR,FUL: rdptr<= rd ? (rdptrplus1) : rdptr;
	endcase
end

always @ (posedge clk or posedge rst)
begin
	if (rst) wrptr<=1;
	else
	case (state)
	FUL: case({rd,wr})
			2'b00: wrptr<= wrptr;
			2'b01: wrptr<= wrptr;
			2'b10: wrptr<= wrptr;
			2'b11: wrptr<= wrptrplus1;
		 endcase
	PAR, EMP: wrptr <= wr ? (wrptrplus1): wrptr;
	endcase
end

assign wrptrplus1= wrptr==10 ? 1: (wrptr+1);
assign rdptrplus1= rdptr==10 ? 1: (rdptr+1);

reg [7:0] Box [1:10];
always @ (posedge clk or posedge rst)
begin

	if (rst) 
		for(i=1; i<=10; i=i+1) 
		Box [i]<=0;
	else
		case (state)
		EMP,PAR: if (wr) Box [wrptr]<=din;
		endcase
end

always @ (posedge clk or posedge rst)
begin
	if (rst)
	dout<=0;
	else
	case (state)
		EMP: dout<= dout;
		PAR,FUL: dout<=rd ? Box [rdptr]: dout;
		endcase
end
endmodule
