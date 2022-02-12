`timescale 1ns / 1ps
module kuznechik_cipher(
    input               clk_i,      // Тактовый сигнал
                        resetn_i,   // Синхронный сигнал сброса с активным уровнем LOW
                        request_i,  // Сигнал запроса на начало шифрования
                        ack_i,      // Сигнал подтверждения приема зашифрованных данных
                [127:0] data_i,     // Шифруемые данные

    output              busy_o,     // Сигнал, сообщающий о невозможности приёма
                                    // очередного запроса на шифрование, поскольку
                                    // модуль в процессе шифрования предыдущего
                                    // запроса
           reg          valid_o,    // Сигнал готовности зашифрованных данных
           reg  [127:0] data_o      // Зашифрованные данные
);

reg [127:0] key_mem [0:9];

reg [7:0] S_box_mem [0:255];

reg [7:0] L_mul_16_mem  [0:255];
reg [7:0] L_mul_32_mem  [0:255];
reg [7:0] L_mul_133_mem [0:255];
reg [7:0] L_mul_148_mem [0:255];
reg [7:0] L_mul_192_mem [0:255];
reg [7:0] L_mul_194_mem [0:255];
reg [7:0] L_mul_251_mem [0:255];
reg [127:0] data_main;

initial begin
    $readmemh("keys.mem",key_mem );
    $readmemh("S_box.mem",S_box_mem );

    $readmemh("L_16.mem", L_mul_16_mem );
    $readmemh("L_32.mem", L_mul_32_mem );
    $readmemh("L_133.mem",L_mul_133_mem);
    $readmemh("L_148.mem",L_mul_148_mem);
    $readmemh("L_192.mem",L_mul_192_mem);
    $readmemh("L_194.mem",L_mul_194_mem);
    $readmemh("L_251.mem",L_mul_251_mem);
end
    localparam IDLE = 0;
    localparam KEY_PHASE = 1;
    localparam S_PHASE = 2;
    localparam L_PHASE = 3;
    localparam FINISH = 4;

    reg[2:0] State;
    reg[2:0] StateNext;
    reg[3:0] KeyCounter;
    reg[4:0] LCounter;
    always @(posedge clk_i) begin
        if (!resetn_i) begin
            State <= IDLE;
        end
        else begin
            State <= StateNext
        end
    end

    reg[3:0] KeyCounter;
    reg[4:0] LCounter;
    always @(posedge clk_i) begin
        if (!resetn_i) begin
            StateNext <= IDLE;
            KeyCounter <= d'0;
            LCounter <= d'0;
        end
        else begin
            if (State == IDLE) begin
                if (request_i) begin
                    StateNext <= KEY_PHASE;
                    KeyCounter <= d'0;
                end
                else begin
                    StateNext <= IDLE;
                end
            end
            else if (State == KEY_PHASE) begin
                if (KeyCounter < d'10) begin
                    KeyCounter <= KeyCounter + d'1;
                    StateNext <= S_PHASE;
                end
                else begin
                    StateNext <= FINISH;
                end
            end
            else if (State == S_PHASE) begin
                StateNext <= L_PHASE;
            end
            else if (State == L_PHASE) begin
                if (LCounter < d'16) begin
                    LCounter <= LCounter + d'1;
                    StateNext <= L_PHASE;
                end
                else begin
                    StateNext <= KEY_PHASE;
                end
            end
            else if (State == FINISH) begin
                KeyCounter <= d'0;
                if (request_i) begin
                    StateNext <= KEY_PHASE;
                end
                else if (ack_i) begin
                    StateNext <= IDLE;
                end
                else begin
                    StateNext <= FINISH;
                end
            end
        end
    end


    always @(posedge clk) begin
        if (!resetn) begin
            data_main <= 'b0;
            valid_o <= 'b0;
        end
        else begin
            case (State)
                IDLE: begin
                    data_main <= data_i;
                    valid_o <= 'b0;
                end
                KEY_PHASE: begin
                    data_main <= key_mem[KeyCounter] ^ data_main;
                    valid_o <= 'b0;
                end
                S_PHASE: data_main <= {S_box_mem[data_mem[127:120]], S_box_mem[data_mem[119:112]], S_box_mem[data_mem[111:104]], S_box_mem[data_mem[103:96]], S_box_mem[data_mem[95:88]], S_box_mem[data_mem[87:80]], S_box_mem[data_mem[79:72]], S_box_mem[data_mem[71:64]], S_box_mem[data_mem[63:56]], S_box_mem[data_mem[55:48]], S_box_mem[data_mem[47:40]], S_box_mem[data_mem[39:32]], S_box_mem[data_mem[31:24]], S_box_mem[data_mem[23:16]], S_box_mem[data_mem[15:8]], S_box_mem[data_mem[7:0]]};
                L_PHASE: data_main <= {data_main[119:0], L_mul_148_mem[data_mem[127:120]] ^ L_mul_32_mem[data_mem[119:112]] ^ L_mul_133_mem[data_mem[111:104]] ^ L_mul_16_mem[data_mem[103:96]] ^ L_mul_194_mem[data_mem[95:88]] ^ L_mul_192_mem[data_mem[87:80]] ^ data_mem[79:72] ^ L_mul_251_mem[data_mem[71:64]] ^ data_mem[63:56] ^ L_mul_192_mem[data_mem[55:48]] ^ L_mul_194_mem[data_mem[47:40]] ^ L_mul_16_mem[data_mem[39:32]] ^ L_mul_133_mem[data_mem[31:24]] ^ L_mul_32_mem[data_mem[23:16]] ^ L_mul_148_mem[data_mem[15:8]] ^ data_mem[7:0]};
                FINISH: begin
                    valid_o <= 'b1;
                    data_o <= data_main;
                end
            endcase
        end
    end

    assign busy_o = !(State == IDLE || State == FINISH);

endmodule
