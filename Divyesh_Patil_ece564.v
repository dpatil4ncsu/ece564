module MyDesign (clk, reset_b, dut_run, dut_busy, 
input_sram_write_enable, input_sram_write_addresss, input_sram_write_data, input_sram_read_address,input_sram_read_data, 
weights_sram_write_enable,weights_sram_write_addresss, weights_sram_write_data, weights_sram_read_address, weights_sram_read_data, 
scratchpad_sram_write_enable, scratchpad_sram_write_addresss, scratchpad_sram_write_data, scratchpad_sram_read_address, scratchpad_sram_read_data, 
output_sram_write_enable, output_sram_write_addresss, output_sram_write_data, output_sram_read_address, output_sram_read_data,
);
//---------------------------------------------------------------------------
//Control signals
  input   wire dut_run                    ; 
  output  reg dut_busy                   ;
  input   wire reset_b                    ;  
  input   wire clk                        ;   
  
  parameter [11:0]
  A0 = 12'd0,
  A1 = 12'd1,
  A2 = 12'd2,
  A3 = 12'd3,
  A4 = 12'd4,
  A5 = 12'd5,
  
  B0 = 12'd0,
  B1 = 12'd1,
  B2 = 12'd2,
  B3 = 12'd3,
  B4 = 12'd4,
  B5 = 12'd5,
  B6 = 12'd6,
  B7 = 12'd7,
  B8 = 12'd8,
  B9 = 12'd9,
  B10 = 12'd10,
  B11 = 12'd11,
  B12 = 12'd12,
  B13 = 12'd13,
  B14 = 12'd14,
  B15 = 12'd15,
  
  C0 = 12'd0,
  C1 = 12'd1,
  C2 = 12'd2,
  C3 = 12'd3,
  C4 = 12'd4,
  C5 = 12'd5,
  C6 = 12'd6,
  C7 = 12'd7,
  C8 = 12'd8,
  C9 = 12'd9,
  C10 = 12'd10,
  C11 = 12'd11,
  C12 = 12'd12;
  
  //dut_busy register
  reg  dut_busyns;
  parameter dut_busys0 = 1'b0,  dut_busys1 = 1'b1;

  //interfacing with kernal matrix
  reg [11:0] kernaladdgen, kernaladdgenns, ktp;
  wire weights_sram_write_enabled;
  wire [11:0] weights_sram_read_addressed;
  wire signed [15:0] weights_sram_read_datad;
  reg signed [7:0] k0,k1,k2,k3,k4,k5,k6,k7,k8; 

  
//interfacing with input matrix
  wire nsquarebytwocom, zeecomp, inputffff, input_sram_write_enabled;
  wire [11:0] finaladd, baapadd, input_sram_read_addressed;
  reg [11:0] inputaddgenns,mux3, mux4, mux5, beta, baap,inputaddgen;
  reg signed [7:0] mux2,nregister;
  wire signed [15:0] input_sram_read_datad; 
  wire signed [13:0] nsquarebytwowire, zeeadd, nby2, nplus3, nby2sub1,lastelementadd;
  reg signed [13:0]  zee, mux1,lastelement,lastelementmux;
   
  // building multiplier input
  reg[11:0] itp1;
  reg signed [7:0] km1, km2, km3, km4, i1, i2;

  //multiplication pipeline and execution
  reg[11:0] itp2,itp4,itp5, itp6,itp3;
  reg signed [7:0] km1p, km1i, km2p, km2i, km3p, km3i, km4p, km4i, i1p;
  wire signed [15:0] k1multiply, k2multiply, k3multiply, k4multiply;
  reg signed [19:0] k1reg, k2reg, k3reg, k4reg, tempreg1, tempreg2, accum0, accum1;
  wire signed [19:0] accum0wire, accum1wire, tempadd1, tempadd2, mux10,mux11;
  reg signed [11:0] i1i, i2p,i2i;

  //RELU function and first compare
  reg signed [7:0] regrelu0, regrelu1,regcompare;
  reg[11:0] itp7,itp8, itp9;

  // write to scratchpad SRAM
  wire scratchpad_sram_write_enabled;
  wire [11:0] scratchpad_sram_write_addresssed, spaddgenwire;
  wire signed [15:0] scratchpad_sram_write_datad;
  reg [11:0] spaddgen;

  // Maxpool
  reg [11:0]   maxpoolbeta, opaddgen,mtp1,mtp2,mtp3, maxpoolbaap, finaladdmaxpool, zeemaxpool, nsub2by2sq, nsub2by2sqmux, maxpooladdgen, maxpooladdgenns;  
  wire [11:0] output_sram_write_addresssed, opaddgenwire,  mux16, nby2sub1max,  maxpoolbaapadd, mux18, zeemaxpoolwire, nsub2by2sqwire;
  wire  output_sram_write_enabled, zeemaxcomp, nsub2by2sqcomp, maxpoolffff;
  reg  [7:0] nregistermaxpool, amaxpool, bmaxpool, cmaxpool, dmaxpool, reg0max, reg1max;
  wire  [7:0] maxcomp1, maxcomp2;
  wire  [15:0] concanatemax, shiftconcanatemax, scratchpad_sram_read_datad, output_sram_write_datad, mux17;
  reg mystery, maxcounter;

//---------------------------------------------------------------------------
//Input SRAM interface
  output reg        input_sram_write_enable    ;
  output reg [11:0] input_sram_write_addresss  ;
  output reg [15:0] input_sram_write_data      ;
  output reg [11:0] input_sram_read_address    ;
  input wire [15:0] input_sram_read_data       ;

//---------------------------------------------------------------------------
//Output SRAM interface
  output reg        output_sram_write_enable    ;
  output reg [11:0] output_sram_write_addresss  ;
  output reg [15:0] output_sram_write_data      ;
  output reg [11:0] output_sram_read_address    ;
  input wire [15:0] output_sram_read_data       ;

//---------------------------------------------------------------------------
//Scratchpad SRAM interface
  output reg        scratchpad_sram_write_enable    ;
  output reg [11:0] scratchpad_sram_write_addresss  ;
  output reg [15:0] scratchpad_sram_write_data      ;
  output reg [11:0] scratchpad_sram_read_address    ;
  input wire [15:0] scratchpad_sram_read_data       ;

//---------------------------------------------------------------------------
//Weights SRAM interface                                                       
  output reg        weights_sram_write_enable    ;
  output reg [11:0] weights_sram_write_addresss  ;
  output reg [15:0] weights_sram_write_data      ;
  output reg [11:0] weights_sram_read_address    ;
  input wire [15:0] weights_sram_read_data       ;

//dut_busy register
always@(posedge clk or negedge reset_b)
begin
if(!reset_b) dut_busy <= dut_busys0;
else dut_busy <= dut_busyns;
end

always@(*)
begin
casex (dut_busy)
dut_busys0: begin
if (dut_run) dut_busyns = dut_busys1;
else dut_busyns = dut_busys0;
end

dut_busys1: begin
if (mystery) dut_busyns = dut_busys0;
else dut_busyns = dut_busys1;
end
endcase
end

//interfacing with kernal matrix
assign weights_sram_write_enabled = 1'b0;
assign weights_sram_read_addressed = kernaladdgen;
assign weights_sram_read_datad = weights_sram_read_data;

always@(*)
begin
weights_sram_read_address <= weights_sram_read_addressed;
weights_sram_write_enable <= weights_sram_write_enabled;
end

always@(posedge clk)
begin
if(dut_busy) kernaladdgen <= kernaladdgenns;
else kernaladdgen <= A5;
end


always@(*)
begin
case (kernaladdgen)
A0: begin
kernaladdgenns = A1;
end
A1: begin
kernaladdgenns = A2;
end
A2: begin
kernaladdgenns = A3;
end
A3: begin
kernaladdgenns = A4;
end
A4: begin
kernaladdgenns = A4;
end
A5: begin
kernaladdgenns = A0;
end
default : kernaladdgenns = A5;
endcase
end

always@ (posedge clk)
begin
ktp <= kernaladdgen;

begin
if(ktp==A0)
k0 <= (weights_sram_read_datad)>>> 8;
else 
k0 <= k0;
end

begin
if(ktp==A0)
k1 <= weights_sram_read_datad;
else 
k1 <= k1;
end

begin
if(ktp==A1)
k2 <= (weights_sram_read_datad)>>> 8;
else 
k2 <= k2;
end

begin
if(ktp==A1)
k3 <= weights_sram_read_datad;
else 
k3 <= k3;
end

begin
if(ktp==A2)
k4 <= (weights_sram_read_datad)>>> 8;
else 
k4 <= k4;
end

begin
if(ktp==A2)
k5 <= weights_sram_read_datad;
else 
k5 <= k5;
end

begin
if(ktp==A3)
k6 <= (weights_sram_read_datad)>>> 8;
else 
k6 <= k6;
end

begin
if(ktp==A3)
k7 <= weights_sram_read_datad;
else 
k7 <= k7;
end

begin
if(ktp==A4)
k8 <= (weights_sram_read_datad)>>> 8;
else 
k8 <= k8;
end
end

//interfacing with input matrix
always@(posedge clk)
begin
begin
if(dut_busy && (kernaladdgen==A4)) inputaddgen <= inputaddgenns;
else inputaddgen <= B0;
end
//n register initialization
begin
if(dut_busy)
nregister <= mux2;
else 
nregister <= 8'd0;
end

//beta initialization
begin
if(dut_busy)
beta <= finaladd;
else 
beta <= 12'd0;
end

//zee register initialization
begin
if(dut_busy)
zee <= zeeadd;
else 
zee<=12'd0;
end

//last element reg initial
begin
  if(dut_busy)
lastelement <= lastelementadd;
else 
lastelement<=12'd0;
end


//baap initialization
begin
if(dut_busy)
baap <= baapadd;
else 
baap <= 12'd1;
end
end

assign finaladd = mux3 + mux4;
assign baapadd = baap + mux5;
assign nsquarebytwowire = (nregister*nregister)>>>1;

assign nby2 = nregister>>>1;
assign nby2sub1 = nby2 - 12'sd1;
assign nplus3 = nregister + 12'sd3;
assign zeeadd = mux1 + zee;
assign lastelementadd = lastelementmux + lastelement;
assign input_sram_write_enabled = 1'b0;
assign input_sram_read_datad = input_sram_read_data;
assign inputffff = (input_sram_read_datad==16'shFFFF)? 1'b1:1'b0;
assign nsquarebytwocom = (finaladd==lastelement)? 1'b1:1'b0;
assign zeecomp = (finaladd==zee)? 1'b1:1'b0;

always@(*)
begin
input_sram_read_address <= finaladd;
input_sram_write_enable <= input_sram_write_enabled;
end

always@(*)
begin
case (inputaddgen)
B0: begin
if (inputffff) inputaddgenns = B14;
else inputaddgenns = B1;
end
B1: begin
if (inputffff) inputaddgenns = B14;
else inputaddgenns = B2;
end
B2: begin
if (inputffff) inputaddgenns = B14;
else inputaddgenns = B3;
end
B3: begin
if (inputffff) inputaddgenns = B14;
else inputaddgenns = B4;
end
B4: begin
if (inputffff) inputaddgenns = B14;
else inputaddgenns = B5;
end
B5: begin
if (inputffff) inputaddgenns = B14;
else inputaddgenns = B6;
end
B6: begin
if (inputffff) inputaddgenns = B14;
else inputaddgenns = B7;
end
B7: begin
if (inputffff) inputaddgenns = B14;
else inputaddgenns = B8;
end
B8: begin
if (inputffff) inputaddgenns = B14;
else inputaddgenns = B9;
end
B9: begin
if (inputffff) inputaddgenns = B14;
else if (nsquarebytwocom) inputaddgenns = B10;
else if (zeecomp) inputaddgenns = B11;
else inputaddgenns = B12;
end
B10: begin
if (inputffff) inputaddgenns = B14;
else inputaddgenns = B0;
end
B11: begin
if (inputffff) inputaddgenns = B14;
else inputaddgenns = B13;
end
B12: begin
if (inputffff) inputaddgenns = B14;
else inputaddgenns = B13;
end
B13: begin
if (inputffff) inputaddgenns = B14;
else inputaddgenns = B4;
end
B14: begin
inputaddgenns = B15;
end
B15: begin
inputaddgenns = B15;
end
default : inputaddgenns = B0;
endcase
end

always@(*)
begin
case(inputaddgen)
B0 : begin
mux1 <= 12'sd0;
mux2 <= nregister;
mux3 <= 12'b0;
mux4 <= beta;
mux5 <= 12'b0;
lastelementmux <= 12'sd0;
end
B1 : begin
mux1 <= 12'sd0;
mux2 <= input_sram_read_datad;
mux3 <= 12'b0;
mux4 <= beta;
mux5 <= 12'b0;
lastelementmux <= 12'sd0;
end
B2 : begin
mux1 <= 3*nby2;
mux2 <= nregister;
mux3 <= 12'b0;
mux4 <= beta;
mux5 <= 12'b0;
lastelementmux <= nsquarebytwowire;
end
B3 : begin
mux1 <= 12'sd0;
mux2 <= nregister;
mux3 <= 12'b1;
mux4 <= beta;
mux5 <= 12'b0;
lastelementmux <= 12'sd0;
end
B4 : begin
mux1 <= 12'sd0;
mux2 <= nregister;
mux3 <= 12'b1;
mux4 <= beta;
mux5 <= 12'b0;
lastelementmux <= 12'sd0;
end
B5 : begin
mux1 <= 8'sd0;
mux2 <= nregister;
mux3 <= nby2sub1;
mux4 <= beta;
mux5 <= 12'b0;
lastelementmux <= 12'sd0;
end
B6 : begin
mux1 <= 12'sd0;
mux2 <= nregister;
mux3 <= 12'b1;
mux4 <= beta;
mux5 <= 12'b0;
lastelementmux <= 12'sd0;
end
B7 : begin
mux1 <= 12'sd0;
mux2 <= nregister;
mux3 <= nby2sub1;
mux4 <= beta;
mux5 <= 12'b0;
lastelementmux <= 12'sd0;
end
B8 : begin
mux1 <= 12'sd0;
mux2 <= nregister;
mux3 <= 12'b1;
mux4 <= beta;
mux5 <= 12'b0;
lastelementmux <= 12'sd0;
end
B9 : begin
mux1 <= 12'sd0;
mux2 <= nregister;
mux3 <= 12'b0;
mux4 <= beta;
mux5 <= 12'b0;
lastelementmux <= 12'sd0;
end
B10 : begin
mux1 <= 12'sd1;
mux2 <= nregister;
mux3 <= 12'd1;
mux4 <= beta;
mux5 <= nplus3;
lastelementmux <= 12'sd1;
end
B11 : begin
mux1 <= nby2;
mux2 <= nregister;
mux3 <= 12'd0;
mux4 <= beta;
mux5 <= 12'd2;
lastelementmux <= 12'sd0;
end
B12 : begin
mux1 <= 12'sd0;
mux2 <= nregister;
mux3 <= 12'b0;
mux4 <= beta;
mux5 <= 12'd1;
lastelementmux <= 12'sd0;
end
B13 : begin
mux1 <= 12'sd0;
mux2 <= nregister;
mux3 <= 12'b0;
mux4 <= baap;
mux5 <= 12'b0;
lastelementmux <= 12'sd0;
end
B14 : begin
mux1 <= 12'sd0;
mux2 <= nregister;
mux3 <= 12'b0;
mux4 <= beta;
mux5 <= 12'b0;
lastelementmux <= 12'sd0;
end
default : begin
mux1 <= 12'sd0;
mux2 <= nregister;
mux3 <= 12'b0;
mux4 <= baap;
mux5 <= 12'b0;
lastelementmux <= 12'sd0;
end
endcase
end


// building multiplier input
always@(posedge clk)
begin
itp1 <= inputaddgen;
i1 <= (input_sram_read_datad)>>>8;
i2 <= input_sram_read_datad;
end

always@(posedge clk)
begin
case(itp1)
B0: begin
km1 <= 8'sd0;
km2 <= 8'sd0;
km3 <= 8'sd0;
km4 <= 8'sd0;
end
B1: begin
km1 <= 8'sd0;
km2 <= 8'sd0;
km3 <= 8'sd0;
km4 <= 8'sd0;
end
B2: begin
km1 <= 8'sd0;
km2 <= 8'sd0;
km3 <= 8'sd0;
km4 <= 8'sd0;
end
B3: begin
km1 <= k0;
km2 <= k1;
km3 <= 8'sd0;
km4 <= k0;
end
B4: begin
km1 <= k2;
km2 <= 8'sd0;
km3 <= k1;
km4 <= k2;
end
B5: begin
km1 <= k3;
km2 <= k4;
km3 <= 8'sd0;
km4 <= k3;
end
B6: begin
km1 <= k5;
km2 <= 8'sd0;
km3 <= k4;
km4 <= k5;
end
B7: begin
km1 <= k6;
km2 <= k7;
km3 <= 8'sd0;
km4 <= k6;
end
B8: begin
km1 <= k8;
km2 <= 8'sd0;
km3 <= k7;
km4 <= k8;
end
B9: begin
km1 <= 8'sd0;
km2 <= 8'sd0;
km3 <= 8'sd0;
km4 <= 8'sd0;
end
B10: begin
km1 <= 8'sd0;
km2 <= 8'sd0;
km3 <= 8'sd0;
km4 <= 8'sd0;
end
B11: begin
km1 <= 8'sd0;
km2 <= 8'sd0;
km3 <= 8'sd0;
km4 <= 8'sd0;
end
B12: begin
km1 <= 8'sd0;
km2 <= 8'sd0;
km3 <= 8'sd0;
km4 <= 8'sd0;
end
B13: begin
km1 <= k0;
km2 <= k1;
km3 <= 8'sd0;
km4 <= k0;
end
B14: begin
km1 <= 8'sd0;
km2 <= 8'sd0;
km3 <= 8'sd0;
km4 <= 8'sd0;
end
B15: begin
km1 <= 8'sd0;
km2 <= 8'sd0;
km3 <= 8'sd0;
km4 <= 8'sd0;
end
endcase
end

//multiplication pipeline and execution
always@(posedge clk)
begin
itp2 <= itp1;
itp4 <= itp3;
itp5 <= itp4;
itp6 <= itp5;
itp3 <= itp2;
km1p <= km1;
km1i <= km1p;
km2p <= km2;
km2i <= km2p;
km3p <= km3;
km3i <= km3p;
km4p <= km4;
km4i <= km4p;
i1p <= i1;
i1i <= i1p;
i2p <= i2;
i2i <= i2p;
k1reg <= k1multiply;
k2reg <= k2multiply;
k3reg <= k3multiply;
k4reg <= k4multiply;
tempreg1 <= tempadd1;
tempreg2 <= tempadd2;

//accum0 and accum1 initilization:
begin
if(dut_busy)
accum0 <= mux10;
else 
accum0 <= 20'd0;
end

begin
if(dut_busy)
accum1 <= mux11;
else 
accum1 <= 20'd0;
end

end

assign k1multiply = km1i * i1i;
assign k2multiply = km2i * i2i;
assign k3multiply = km3i * i1i;
assign k4multiply = km4i * i2i;
assign tempadd1 = k1reg + k2reg;
assign tempadd2 = k3reg + k4reg;
assign accum0wire = accum0 + tempreg1;
assign accum1wire = accum1 + tempreg2;
assign mux10 = (itp6==B9)? 20'sd0:accum0wire;
assign mux11 = (itp6==B9)? 20'sd0:accum1wire;


//RELU function and first compare
always@(posedge clk)
begin
if(accum0<20'sd0) regrelu0 <= 8'sd0;
else if(accum0>20'sd127) regrelu0 <= 8'sd127;
else regrelu0 <= accum0;

if(accum1<20'sd0) regrelu1<= 8'sd0;
else if(accum1>20'sd127) regrelu1<= 8'sd127;
else regrelu1 <= accum1;

itp7 <= itp6;
itp8 <= itp7;
itp9 <= itp8;

if (regrelu0>regrelu1) regcompare <= regrelu0;
else regcompare <= regrelu1;
end

// write to scratchpad SRAM
  always@(posedge clk)
  begin
  if(dut_busy)
    spaddgen <= spaddgenwire;
    else spaddgen <= 12'd0;
  end

  always@(*)  
  begin
  scratchpad_sram_write_enable <= scratchpad_sram_write_enabled;
  scratchpad_sram_write_addresss <= scratchpad_sram_write_addresssed;
  scratchpad_sram_write_data <= scratchpad_sram_write_datad;
  end

  assign scratchpad_sram_write_enabled = (itp9==B8 || itp9==B2 || itp9==B14)? 1'b1:1'b0;
  assign scratchpad_sram_write_datad = (itp9==B14)? 16'shFFFF:(itp9==B2)? {8'd0,nregister}:{8'd0,regcompare};
  assign scratchpad_sram_write_addresssed = spaddgen;
  assign spaddgenwire = (itp9==B8 || itp9==B2 || itp9==B14)? spaddgen + 12'd1 : spaddgen;


// Maxpool
always@(posedge clk)
begin
begin
if(dut_busy && (itp9==B15))  maxpooladdgen <= maxpooladdgenns; 
else maxpooladdgen<= C0;
end
mtp1 <= maxpooladdgen;
mtp2 <= mtp1;
mtp3 <= mtp2;

//maxpoolbeta register initialization
begin
if(dut_busy)
maxpoolbeta <= finaladdmaxpool;
else 
maxpoolbeta <= 12'd0;
end

//maxpool baap initialization
begin
if(dut_busy)
maxpoolbaap <= maxpoolbaapadd;
else 
maxpoolbaap <= 12'd1;
end 


reg0max <= maxcomp1;
reg1max <= maxcomp2;

begin
if(dut_busy)
opaddgen <= opaddgenwire;
else opaddgen <= 12'd0;
end

//zeemaxpool register initialization
begin
if(dut_busy)
zeemaxpool <= zeemaxpoolwire;
else 
zeemaxpool <= 12'd0;
end

//last element nsub2by2sqwire
begin
if(dut_busy)
nsub2by2sq <= nsub2by2sqwire;
else 
nsub2by2sq <= 12'd0;
end

begin
if(mtp3==C9)
mystery <= 1'b1;
else mystery <= 1'b0;
end

begin
if(mtp1==C0)
nregistermaxpool <= scratchpad_sram_read_datad;
else nregistermaxpool <= nregistermaxpool;
end

begin
if(mtp1==C3)
amaxpool <= scratchpad_sram_read_datad;
else amaxpool <= amaxpool;
end

begin
if(mtp1==C4)
bmaxpool <= scratchpad_sram_read_datad;
else bmaxpool <= bmaxpool;
end

begin
if(mtp1==C5)
cmaxpool <= scratchpad_sram_read_datad;
else cmaxpool <= cmaxpool;
end

begin
if(mtp1==C6)
dmaxpool <= scratchpad_sram_read_datad;
else dmaxpool <= dmaxpool;
end

begin
if(maxpooladdgen == C3 || maxpooladdgen == C4)
maxcounter <= 1'b0;
else if (maxpooladdgen == C5 || maxpooladdgen == C6)
maxcounter <= 1'b1;
else maxcounter <= maxcounter;
end
end

assign maxcomp1 = (amaxpool>bmaxpool)? amaxpool:bmaxpool;
assign maxcomp2 = (cmaxpool>dmaxpool)? cmaxpool:dmaxpool;
assign concanatemax = {reg0max,reg1max};
assign shiftconcanatemax = {reg0max,8'd0};
assign opaddgenwire = opaddgen + mux16;
assign scratchpad_sram_read_datad = scratchpad_sram_read_data;
assign output_sram_write_addresssed = opaddgen;
assign output_sram_write_enabled = (mtp3==C6 || mtp3==C4)? 1'b1:1'b0;
assign zeemaxpoolwire = mux17 + zeemaxpool;
assign nsub2by2sqwire = nsub2by2sq + nsub2by2sqmux;
assign maxpoolffff = (scratchpad_sram_read_datad==16'hffff)? 1'b1:1'b0;
assign nsub2by2sqcomp = (nsub2by2sq==finaladdmaxpool)?  1'b1:1'b0;
assign zeemaxcomp = (zeemaxpool==finaladdmaxpool)? 1'b1:1'b0;
assign output_sram_write_datad = (mtp3==C4)? shiftconcanatemax:concanatemax;
assign mux16 = (mtp3==C6 || mtp3==C7)? 12'b1:12'b0;
assign nby2sub1max = (nregistermaxpool>>>1)- 12'd1;
assign maxpoolbaapadd = maxpoolbaap + mux18;
assign mux17 = (mtp2==C1 || mtp2==C8)? 2*nby2sub1max: (mtp2==C7)? 12'd1: 12'd0;
assign mux18 = (maxpooladdgen==C4 || maxpooladdgen==C6)? 12'd1 : (maxpooladdgen==C7)? nby2sub1max+12'd1:(maxpooladdgen==C8)? nby2sub1max:12'd0;

always@(*)
begin
scratchpad_sram_read_address <= finaladdmaxpool;
output_sram_write_addresss <= output_sram_write_addresssed;
output_sram_write_enable <= output_sram_write_enabled;
output_sram_write_data <= output_sram_write_datad;

case(maxpooladdgen)
C0: begin
if (maxpoolffff)
maxpooladdgenns <= C9;
 else maxpooladdgenns <= C1;
end
C1: begin
if (maxpoolffff)
maxpooladdgenns <= C9;
else maxpooladdgenns <= C2;
end
C2: begin
if (maxpoolffff)
maxpooladdgenns <= C9;
else maxpooladdgenns <= C3;
end
C3: begin
if (maxpoolffff)
maxpooladdgenns <= C9;
else maxpooladdgenns <= C4;
end
C4: begin
if (maxpoolffff)
maxpooladdgenns <= C9;
else if(nsub2by2sqcomp==1'b1)
maxpooladdgenns <= C7;
else if(zeemaxcomp==1'b1)
maxpooladdgenns <= C8;
else maxpooladdgenns <= C5;
end
C5: begin
if (maxpoolffff)
maxpooladdgenns <= C9;
else maxpooladdgenns <= C6;
end
C6: begin
if (maxpoolffff)
maxpooladdgenns <= C9;
else if(zeemaxcomp==1'b1)
maxpooladdgenns <= C8;
else maxpooladdgenns <= C3;
end
C7: begin
if (maxpoolffff)
maxpooladdgenns <= C9;
else maxpooladdgenns <= C0;
end
C8: begin
if (maxpoolffff)
maxpooladdgenns <= C9;
else if (maxcounter==1'b1)
  maxpooladdgenns <= C3;
  else maxpooladdgenns <= C5;
end
C9: begin
maxpooladdgenns <= C9;
end
default:
maxpooladdgenns <= C0;
endcase
end

always@(*)
begin
case(maxpooladdgen)
C0: begin
finaladdmaxpool <= maxpoolbeta;
nsub2by2sqmux <= 12'd0;
end
C1: begin
finaladdmaxpool <= maxpoolbeta;
nsub2by2sqmux <= 12'd0;
end
C2: begin
finaladdmaxpool <= maxpoolbeta;
nsub2by2sqmux <= 2*(nby2sub1max*nby2sub1max);
end
C3: begin
finaladdmaxpool <= maxpoolbaap;
nsub2by2sqmux <= 12'd0;
end
C4: begin
finaladdmaxpool <= maxpoolbeta + nby2sub1max;
nsub2by2sqmux <= 12'd0;
end
C5: begin
finaladdmaxpool <= maxpoolbaap;
nsub2by2sqmux <= 12'd0;
end
C6: begin
finaladdmaxpool <= maxpoolbeta + nby2sub1max;
nsub2by2sqmux <= 12'd0;
end
C7: begin
finaladdmaxpool <= maxpoolbeta + 12'd1;
nsub2by2sqmux <= 12'd1;
end
C8: begin
finaladdmaxpool <= maxpoolbeta;
nsub2by2sqmux <= 12'd0;
end
C9: begin
finaladdmaxpool <= maxpoolbeta;
nsub2by2sqmux <= 12'd0;
end
default: begin
finaladdmaxpool <= maxpoolbeta;
nsub2by2sqmux <= 12'd0;
end
endcase
end
endmodule

