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
    always @(clk_i) begin
        if (!resetn_i) begin
            State <= IDLE;
        end
        else begin
            State <= StateNext
        end
    end

    reg[3:0] KeyCounter;
    reg[4:0] LCounter;
    always @(clk_i) begin
        if (!resetn_i) begin
            StateNext <= IDLE;
            KeyCounter <= d'0;
            LCounter <= d'0;
        end
        else begin
            if (State == IDLE) begin
                if (request_i) begin
                    StateNext <= KEY_PHASE;
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


endmodule
