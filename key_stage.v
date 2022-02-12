`timescale 1ns / 1ps
module key_stage(
    input
                [127:0] key,     // Ключ
                [127:0] data_i     // Шифруемые данные

    output
            reg [127:0] data_o      // Зашифрованные данные
)

    reg [127:0] KEYS [0:9];
    
    initial $readmemh("keys.mem", KEYS);

    always (*) begin
        data_o <= key ^ data_i;
    end

endmodule