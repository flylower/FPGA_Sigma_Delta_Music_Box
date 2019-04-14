module dsm_order6 #(
    parameter FAC1_CGAINA = 6445,
    parameter FAC1_CGAINB = 12100,
    parameter FAC1_CGAING = 365,
    parameter FAC2_CGAINA = 14301,
    parameter FAC2_CGAINB = 29435,
    parameter FAC2_CGAING = 1265,
    parameter FAC3_CGAINA = 36520,
    parameter FAC3_CGAINB = 926366,
    parameter FAC3_CGAING = 984
) (
	input clk,
	input rst_n,
	input fs_enb,
	input [15:0] inpsig,
	output [3:0] outsig
);

	wire fs_enb10;
    wire fs_enb20;
    wire fs_enb30;
    
    wire[35:0] inpb1;
    wire[35:0] inpb2;
    wire[35:0] inpb3;
    wire[35:0] inpb4;
    wire[35:0] inpb5;
    wire[35:0] inpb6;
    
    wire[35:0] outa1;
    wire[35:0] outa2;
    wire[35:0] outa3;
    wire[35:0] outa4;
    wire[35:0] outa5;
    wire[35:0] outa6;
    
    wire[35:0] xout1;
    wire[35:0] xout2;
    wire[35:0] xout3;
        
    fsclk_def c1(
    .clk(clk),
    .rst_n(rst_n),
    .fs_enb(fs_enb),
    .fs_enb10(fs_enb10),
    .fs_enb20(fs_enb20),
    .fs_enb30(fs_enb30)
    );
    
    inpsig i1(
     .sine(inpsig),
     .inpb1(inpb1),
     .inpb2(inpb2),
     .inpb3(inpb3),
     .inpb4(inpb4),
     .inpb5(inpb5),
     .inpb6(inpb6)
        );
        
    fac #(
        .CGAINA(FAC1_CGAINA ),
        .CGAINB(FAC1_CGAINB),
        .CGAING(FAC1_CGAING)
    ) f1_inst(
        .clk(clk),
        .rst_n(rst_n),
        .fs_enb(fs_enb30),
        .csump(36'd0),
        .inpba(inpb1),
        .inpbb(inpb2),
        .outaa(outa1),
        .outab(outa2),
        .xout(xout1)
        );
        
   fac #(
        .CGAINA(FAC2_CGAINA ),
        .CGAINB(FAC2_CGAINB),
        .CGAING(FAC2_CGAING)
    ) f2_inst(
        .clk(clk),
        .rst_n(rst_n),
        .fs_enb(fs_enb20),
        .csump(xout1),
        .inpba(inpb3),
        .inpbb(inpb4),
        .outaa(outa3),
        .outab(outa4),
        .xout(xout2)
        );
        
   fac #(
        .CGAINA(FAC3_CGAINA ),
        .CGAINB(FAC3_CGAINB),
        .CGAING(FAC3_CGAING)
    ) f3_inst(
        .clk(clk),
        .rst_n(rst_n),
        .fs_enb(fs_enb10),
        .csump(xout2),
        .inpba(inpb5),
        .inpbb(inpb6),
        .outaa(outa5),
        .outab(outa6),
        .xout(xout3)
        );
        
    outs o1(
        .clk(clk),
        .rst_n(rst_n),
        .fs_enb(fs_enb),
        .xout(xout3),
        .outa1(outa1),
        .outa2(outa2),
        .outa3(outa3),
        .outa4(outa4),
        .outa5(outa5),
        .outa6(outa6),
        .outsig(outsig)
         );

endmodule
