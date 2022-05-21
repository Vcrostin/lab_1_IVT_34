`timescale 1ns / 1ps
module kuznechik_cipher_apb_wrapper(
    input               pclk_i,         // clock source 
                        presetn_i,      // reset active LOW
                 [31:0] paddr_i,        // address 
                        psel_i,         // select
                        penable_i,      // select 2nd and more tacts
                        pwrite_i,       // direction write - HIGH, read - LOW
            [3:0] [7:0] pwdata_i,        // write data when pwrite is up
                  [3:0] pstrb_i,        // 

    output              pready_o,
             reg [31:0] prdata_o,
                   wire pslverr_o

);

    localparam IDLE = 0;
    localparam SETUP = 1;
    localparam ACCESS = 2;

    reg [7:0] data [35:0];
    
    
    initial begin
        $readmemh("wrp_mem.mem",data );
    end

    reg [1:0] sel_cicle;

    always @(posedge pclk_i) begin
        if (!presetn_i) begin
            sel_cicle <= {1'b0, 1'b0};
        end
        else begin
            sel_cicle <= {sel_cicle[0], psel_i[0]};
        end
    end

    assign pready_o = sel_cicle[0] & sel_cicle[1];


    reg [1:0] State;


    wire kuznechik_resetn;
    wire kuznechik_req;
    wire kuznechik_ack;
    wire kuznechik_cipher_w;
    wire [127:0] kuznechik_data_i;
    wire [127:0] kuznechik_data_o;
    wire kuznechik_busy;
    wire kuznechik_valid;
    
    // assign kuznechik_data_o = {data[35], data[34], data[33], data[32], data[31], data[30], data[29], data[28], data[27], data[26], data[25], data[24], data[23], data[22], data[21], data[20]};
    assign kuznechik_cipher_w = presetn_i && data['b0];
    assign kuznechik_req = data['b1];
    assign kuznechik_ack = data['b1];
    assign kuznechik_data_i = {data['d19], data['d18], data['d17], data['d16], data['d15], data['d14], data['d13], data['d12], data['d11], data['d10], data['d9], data['d8], data['d7], data['d6], data['d5], data['d4]};
    

    
    kuznechik_cipher DUI (
        .clk_i      (pclk_i),
        .resetn_i   (kuznechik_cipher_w),
        .request_i  (kuznechik_req),
        .ack_i      (kuznechik_ack),
        .data_i     (kuznechik_data_i),
        .busy_o     (kuznechik_busy),
        .valid_o    (kuznechik_valid),
        .data_o     (kuznechik_data_o)
    );

    // assign kuznechik_busy = data[3];
    // assign kuznechik_valid = data[2][0];

    always @(*) begin
        if (presetn_i) begin
            if (kuznechik_valid) begin
                data[35] <= kuznechik_data_o[127:120];
                data[34] <= kuznechik_data_o[119:112];
                data[33] <= kuznechik_data_o[111:104];
                data[32] <= kuznechik_data_o[103:96];
                data[31] <= kuznechik_data_o[95:88];
                data[30] <= kuznechik_data_o[87:80];
                data[29] <= kuznechik_data_o[79:72];
                data[28] <= kuznechik_data_o[71:64];
                data[27] <= kuznechik_data_o[63:56];
                data[26] <= kuznechik_data_o[55:48];
                data[25] <= kuznechik_data_o[47:40];
                data[24] <= kuznechik_data_o[39:32];
                data[23] <= kuznechik_data_o[31:24];
                data[22] <= kuznechik_data_o[23:16];
                data[21] <= kuznechik_data_o[15:8];
                data[20] <= kuznechik_data_o[7:0];
            end
            data[3] <= kuznechik_busy;
            data[2] <= kuznechik_valid;
        end
    end

    always @(posedge pclk_i) begin
        if (!presetn_i) begin
            State <= IDLE;
        end
        else begin
            case (State)
                IDLE: begin
                    if (psel_i && !penable_i) begin
                        State <= SETUP;
                    end
                    else begin
                        State <= IDLE;
                    end
                end
                SETUP: begin
                    if (penable_i) begin
                        State <= ACCESS;
                    end
                    else begin
                        State <= SETUP;
                    end
                end
                ACCESS: begin
                    if (!pready_o) begin
                        State <= ACCESS;
                    end
                    else begin
                        if (psel_i && !penable_i) begin
                            State <= SETUP;
                        end
                        else begin
                            State <= IDLE;
                        end
                    end
                end
            endcase
        end
    end

    reg err;
    assign pslverr_o = err;

    always @(posedge pclk_i) begin
        if (!presetn_i) begin
            err <= 'b1;
        end
        else if (pwrite_i) begin
            if (paddr_i == 'd0) begin
                if (pstrb_i & 'b1100) begin
                    err <= 'b1;
                end
                else begin
                    err <= 'b0;
                    if (pstrb_i & 'b0010) begin
                        data['d1] <= pwdata_i['d1];
                    end
                    if (pstrb_i & 'b0001) begin
                        data['d0] <= pwdata_i['d0];
                    end
                end
            end
            else if (paddr_i <= 'd16 && paddr_i >=4) begin
                err <= 'b0;
                data[paddr_i] <= pwdata_i['d0];
                data[paddr_i + 'd1] <= pwdata_i['d1];
                data[paddr_i + 'd2] <= pwdata_i['d2];
                data[paddr_i + 'd3] <= pwdata_i['d3];
            end
            else begin
                err <= 'b1;
            end
        end
        else begin
            if (paddr_i > 'd35) begin
                err <= 'b1;
            end
            else begin
                err <= 'b0;
                prdata_o = {data[paddr_i + 'd3], data[paddr_i + 'd2], data[paddr_i + 'd1], data[paddr_i]};
            end
        end
    end

    // assign    pslverr_o = pwrite_i && ((20 <= paddr_i) || (paddr_i == 0 && pstrb_i & 'hc));



   
endmodule