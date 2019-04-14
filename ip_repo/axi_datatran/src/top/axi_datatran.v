
`timescale 1 ns / 1 ps

module axi_datatran #(
	parameter integer C_S_AXI_DATA_WIDTH	= 32,
	parameter integer C_S_AXI_ADDR_WIDTH	= 4
)(
    // Users to add ports here
    //common
    output clk,
    output rst,
    //brama
    output [31:0] addr_a,
    //clk
    //din
    input [31:0] din_b,//connect bram dout
    output en_rd,
    //rst
    output [3:0] we_rd,
      
    //bramb
    output [31:0] addr_b,
    //clk
    output [31:0] outsig_o,    
    //dout
    output en_wr,    
    //rst
    output [3:0] we_wr,
       
    //other
    input [3:0] outsig,
    output fs_enb,
    output [15:0]  ram_rd_out,
    output globalresetn,
    output pwm_o,
    // User ports ends
    input wire                              axi4lite_ext_aclk,
    input wire                              axi4lite_ext_aresetn,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0]   axi4lite_ext_awaddr,
    input wire [                   2 : 0]   axi4lite_ext_awprot,
    input wire                              axi4lite_ext_awvalid,
    output wire                             axi4lite_ext_awready,
    input wire [C_S_AXI_DATA_WIDTH-1 : 0]   axi4lite_ext_wdata,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1:0] axi4lite_ext_wstrb,
    input wire                              axi4lite_ext_wvalid,
    output wire                             axi4lite_ext_wready,
    output wire [                    1 : 0] axi4lite_ext_bresp,
    output wire                             axi4lite_ext_bvalid,
    input wire                              axi4lite_ext_bready,
    input wire [  C_S_AXI_ADDR_WIDTH-1 : 0] axi4lite_ext_araddr,
    input wire [                     2 : 0] axi4lite_ext_arprot,
    input wire                              axi4lite_ext_arvalid,
    output wire                             axi4lite_ext_arready,
    output wire [C_S_AXI_DATA_WIDTH-1 : 0]  axi4lite_ext_rdata,
    output wire [                   1 : 0]  axi4lite_ext_rresp,
    output wire                             axi4lite_ext_rvalid,
    input wire                              axi4lite_ext_rready
);
	
    wire [15:0] din;
    wire [10:0] addr_rd;
    wire [11:0] addr_rd_o;

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi4lite_datatran_awaddr;
	reg  	                        axi4lite_datatran_awready;
	reg  	                        axi4lite_datatran_wready;
	reg [                   1 : 0] 	axi4lite_datatran_bresp;
	reg  	                        axi4lite_datatran_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi4lite_datatran_araddr;
	reg                          	axi4lite_datatran_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi4lite_datatran_rdata;
	reg [                   1 : 0] 	axi4lite_datatran_rresp;
	reg  	                        axi4lite_datatran_rvalid;

    
	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 1;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 4
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;

	// I/O Connections assignments

	assign axi4lite_ext_awready = axi4lite_datatran_awready;
	assign axi4lite_ext_wready	 = axi4lite_datatran_wready;
	assign axi4lite_ext_bresp	 = axi4lite_datatran_bresp;
	assign axi4lite_ext_bvalid	 = axi4lite_datatran_bvalid;
	assign axi4lite_ext_arready  = axi4lite_datatran_arready;
	assign axi4lite_ext_rdata	 = axi4lite_datatran_rdata;
	assign axi4lite_ext_rresp	 = axi4lite_datatran_rresp;
	assign axi4lite_ext_rvalid	 = axi4lite_datatran_rvalid;
	// Implement axi4lite_datatran_awready generation
	// axi4lite_datatran_awready is asserted for one axi4lite_ext_aclk clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi4lite_datatran_awready is
	// de-asserted when reset is low.

	always @( posedge axi4lite_ext_aclk )
	begin
	  if ( axi4lite_ext_aresetn == 1'b0 )
	    begin
	      axi4lite_datatran_awready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi4lite_datatran_awready && axi4lite_ext_awvalid && axi4lite_ext_wvalid)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi4lite_datatran_awready <= 1'b1;
	        end
	      else           
	        begin
	          axi4lite_datatran_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi4lite_datatran_awaddr latching
	// This process is used to latch the address when both 
	// axi4lite_ext_awvalid and axi4lite_ext_wvalid are valid. 

	always @( posedge axi4lite_ext_aclk )
	begin
	  if ( axi4lite_ext_aresetn == 1'b0 )
	    begin
	      axi4lite_datatran_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi4lite_datatran_awready && axi4lite_ext_awvalid && axi4lite_ext_wvalid)
	        begin
	          // Write Address latching 
	          axi4lite_datatran_awaddr <= axi4lite_ext_araddr;
	        end
	    end 
	end       

	// Implement axi4lite_datatran_wready generation
	// axi4lite_datatran_wready is asserted for one axi4lite_ext_aclk clock cycle when both
	// axi4lite_ext_awvalid and axi4lite_ext_wvalid are asserted. axi4lite_datatran_wready is 
	// de-asserted when reset is low. 

	always @( posedge axi4lite_ext_aclk )
	begin
	  if ( axi4lite_ext_aresetn == 1'b0 )
	    begin
	      axi4lite_datatran_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi4lite_datatran_wready && axi4lite_ext_wvalid && axi4lite_ext_awvalid)
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi4lite_datatran_wready <= 1'b1;
	        end
	      else
	        begin
	          axi4lite_datatran_wready <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi4lite_datatran_awready, axi4lite_ext_wvalid, axi4lite_datatran_wready and axi4lite_ext_wvalid are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi4lite_datatran_wready && axi4lite_ext_wvalid && axi4lite_datatran_awready && axi4lite_ext_awvalid;

	always @( posedge axi4lite_ext_aclk )
	begin
	  if ( axi4lite_ext_aresetn == 1'b0 )
	    begin
	      slv_reg0 <= 0;
	      slv_reg1 <= 0;
	      slv_reg2 <= 0;
	      slv_reg3 <= 0;
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi4lite_datatran_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          2'h0:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( axi4lite_ext_wstrb[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 0
	                slv_reg0[(byte_index*8) +: 8] <= axi4lite_ext_wdata[(byte_index*8) +: 8];
	              end  
	          2'h1:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( axi4lite_ext_wstrb[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 1
	                slv_reg1[(byte_index*8) +: 8] <= axi4lite_ext_wdata[(byte_index*8) +: 8];
	              end  
	          2'h2:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( axi4lite_ext_wstrb[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 2
	                slv_reg2[(byte_index*8) +: 8] <= axi4lite_ext_wdata[(byte_index*8) +: 8];
	              end  
	          2'h3:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( axi4lite_ext_wstrb[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 3
	                slv_reg3[(byte_index*8) +: 8] <= axi4lite_ext_wdata[(byte_index*8) +: 8];
	              end  
	          default : begin
	                      slv_reg0 <= slv_reg0;
	                      slv_reg1 <= slv_reg1;
	                      slv_reg2 <= slv_reg2;
	                      slv_reg3 <= slv_reg3;
	                    end
	        endcase
	      end
	  end
	end    

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi4lite_datatran_wready, axi4lite_ext_wvalid, axi4lite_datatran_wready and axi4lite_ext_wvalid are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge axi4lite_ext_aclk )
	begin
	  if ( axi4lite_ext_aresetn == 1'b0 )
	    begin
	      axi4lite_datatran_bvalid  <= 0;
	      axi4lite_datatran_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi4lite_datatran_awready && axi4lite_ext_awvalid && ~axi4lite_datatran_bvalid && axi4lite_datatran_wready && axi4lite_ext_wvalid)
	        begin
	          // indicates a valid write response is available
	          axi4lite_datatran_bvalid <= 1'b1;
	          axi4lite_datatran_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (axi4lite_ext_bready && axi4lite_datatran_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi4lite_datatran_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi4lite_datatran_arready generation
	// axi4lite_datatran_arready is asserted for one axi4lite_ext_aclk clock cycle when
	// S_AXI_ARVALID is asserted. axi4lite_datatran_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi4lite_datatran_araddr is reset to zero on reset assertion.

	always @( posedge axi4lite_ext_aclk )
	begin
	  if ( axi4lite_ext_aresetn == 1'b0 )
	    begin
	      axi4lite_datatran_arready <= 1'b0;
	      axi4lite_datatran_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi4lite_datatran_arready && axi4lite_ext_arvalid)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi4lite_datatran_arready <= 1'b1;
	          // Read address latching
	          axi4lite_datatran_araddr  <= axi4lite_ext_araddr;
	        end
	      else
	        begin
	          axi4lite_datatran_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi4lite_datatran_arvalid generation
	// axi4lite_datatran_rvalid is asserted for one axi4lite_ext_aclk clock cycle when both 
	// S_AXI_ARVALID and axi4lite_datatran_arready are asserted. The slave registers 
	// data are available on the axi4lite_datatran_rdata bus at this instance. The 
	// assertion of axi4lite_datatran_rvalid marks the validity of read data on the 
	// bus and axi4lite_datatran_rresp indicates the status of read transaction.axi4lite_datatran_rvalid 
	// is deasserted on reset (active low). axi4lite_datatran_rresp and axi4lite_datatran_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge axi4lite_ext_aclk )
	begin
	  if ( axi4lite_ext_aresetn == 1'b0 )
	    begin
	      axi4lite_datatran_rvalid <= 0;
	      axi4lite_datatran_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi4lite_datatran_arready && axi4lite_ext_arvalid && ~axi4lite_datatran_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi4lite_datatran_rvalid <= 1'b1;
	          axi4lite_datatran_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi4lite_datatran_rvalid && axi4lite_ext_arready)
	        begin
	          // Read data is accepted by the master
	          axi4lite_datatran_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi4lite_datatran_arready & axi4lite_ext_arvalid & ~axi4lite_datatran_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi4lite_datatran_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        2'h0   : reg_data_out <= {21'd0,addr_rd};//slv_reg0;
	        2'h1   : reg_data_out <= {20'd0,addr_rd_o};//slv_reg1;
	        2'h2   : reg_data_out <= slv_reg2;
	        2'h3   : reg_data_out <= slv_reg3;
	        default : reg_data_out <= 0;
	      endcase
	end

	// Output register or memory read data
	always @( posedge axi4lite_ext_aclk )
	begin
	  if ( axi4lite_ext_aresetn == 1'b0 )
	    begin
	      axi4lite_datatran_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (axi4lite_ext_arvalid) with 
	      // acceptance of read address by the slave (axi4lite_datatran_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi4lite_datatran_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    

	// Add user logic here
    signalch s1(
        .clk(axi4lite_ext_aclk),
        .rst_n(globalresetn),
        .we_rd(we_rd),
        .en_rd(en_rd),
        .addr_rd(addr_rd),
        .fs_enb(fs_enb),
        .din(din),
        .ram_rd_out(ram_rd_out)
     );
            
     datawr d1(
        .clk(axi4lite_ext_aclk),
        .rst_n( globalresetn),
        .we_wr(we_wr),
        .en_wr(en_wr),
        .addr_rd_o(addr_rd_o)
     );
     
     pwm_control pc_inst(
         .clk(axi4lite_ext_aclk),
         .globalresetn(globalresetn),
         .pwm_o(pwm_o),
         .outsig(outsig)
         );
         
     assign globalresetn = slv_reg2[0];


	// Add user logic here
    assign clk = axi4lite_ext_aclk;
    assign rst = ~axi4lite_ext_aresetn;
    assign outsig_o = {28'd0, outsig};
    assign din = din_b[15:0];
    assign addr_a = {19'd0, addr_rd, 2'b0};
    assign addr_b = {18'd0, addr_rd_o, 2'b0};
    
	// User logic ends

	endmodule
