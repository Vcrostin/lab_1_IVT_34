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
)
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
            StateNext <= IDLE;
        end
        else begin
            StateNext <= State
        end
    end

    reg[3:0] KeyCounter;
    reg[4:0] LCounter;
    always @(clk_i) begin
        if (!resetn_i) begin
            State <= IDLE;
            KeyCounter <= 0;
            LCounter <= 0;
        end
        else begin
            if (StateNext == IDLE) begin
                State <= KEY_PHASE;
            end
            else if (StateNext == KEY_PHASE) begin
                if (KeyCounter < 10) begin
                    KeyCounter <= KeyCounter + 1;
                    State <= S_PHASE;
                end
                else begin
                    State <= FINISH;
                end
            end
            else if (StateNext == S_PHASE) begin
                State <= L_PHASE;
            end
            else if (StateNext == L_PHASE) begin
                if (LCounter < 16) begin
                    LCounter <= LCounter + 1;
                end
                else begin
                    State <= KEY_PHASE;
                end
            end
            else if (StateNext == FINISH) begin
                KeyCounter <= 0;
                State <= IDLE;
            end
        end
    end



endmodule

