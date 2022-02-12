`timescale 1ns / 1ps
module (
    input               clk_i,      // Тактовый сигнал
                        resetn_i,   // Синхронный сигнал сброса с активным уровнем LOW
                [127:0] data_i,     // Шифруемые данные
                  [3:0] iter

    output
                [127:0] data_o      // Зашифрованные данные
)

    reg [127:0] KEYS [0:9];
    
    initial $readmemh("keys.mem", KEYS);

    always (*) begin
        data_o <= KEYS[iter] ^ data_i;
    end

endmodule