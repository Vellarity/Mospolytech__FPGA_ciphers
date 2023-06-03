`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.05.2023 22:31:56
// Design Name: 
// Module Name: gost
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


(* dont_touch = "true" *) module gost_enc(
    input clk,
    input reset_n,
    input start_trigger,
    input [127:0] data_in,
    output [127:0] data_out,
    output reg cycles_done
    );
    
    localparam IDLE = 1;
    localparam START = 2;
    localparam X_TRANSFORM = 3;
    localparam S_TRANSFORM = 4;
    localparam L_TRANSFORM = 5;
    localparam LAST_X_TRANSFORM = 6;
    localparam END_STATE = 7;
    
    reg [10:0] STATE = IDLE;
    
    //Состояния
    reg [127:0] base_data; //Дублирующий регистр для данных с начала
    reg [127:0] after_x_transform;  //Данные после операции X
    reg [127:0] after_s_transform;  //Данные после операции S
    reg [127:0] after_l_transform;  //Данные после операции L
    reg [127:0] after_last; //После последнего X_transform
    reg [127:0] state_out;
    
    reg [4:0] round_counter;
    
    reg [127:0] round_keys [0:9] = '{  
        128'h_8899aabbccddeeff0011223344556677,
        128'h_fedcba98765432100123456789abcdef,
        128'h_db31485315694343228d6aef8cc78c44,
        128'h_3d4553d8e9cfec6815ebadc40a9ffd04,
        128'h_57646468c44a5e28d3e59246f429f1ac,
        128'h_bd079435165c6432b532e82834da581b,
        128'h_51e640757e8745de705727265a0098b1,
        128'h_5a7925017b9fdd3ed72a91a22286f984,
        128'h_bb44e25378c73123a5f32f73cdb6e517,
        128'h_72e9dd7416bcf45b755dbaa88e4a4043
    };
    
    reg [7:0] l_coef [0:15] = {
        'h94, 'h20, 'h85, 'h10, 'hC2, 'hC0, 'h01, 'hFB, 
        'h01, 'hC0, 'hC2, 'h10, 'h85, 'h20, 'h94, 'h01
        //1, 148, 32, 133, 16, 194, 192, 1,
        //251, 1, 192, 194, 16, 133, 32, 148
    };
    
    function [127:0] R_TRANSFORM;
        input [127:0] state;
        integer i;
        reg [7:0] a_zero = state[0+:8];
        begin
            for (i = 0; i < 15; i++)
            begin
                state[8*(i)+:8] = state[8*(i+1)+:8];
                a_zero ^= mul_galoa(state[8*i+:8], l_coef[i]);
            end
            state[120+:8] = a_zero;
            R_TRANSFORM = state;
        end
    endfunction
    
    function [7:0] mul_galoa; //Написано верно
        input [7:0] pol_first;
        input [7:0] pol_second;
        reg [7:0] high_bit;
        integer i;
        begin
            mul_galoa = 0;
            for (i=0;i<8;i=i+1) 
            begin
                if ((pol_second & 1) != 0 ) 
                begin
                    mul_galoa = mul_galoa ^ pol_first;
                end
                
                high_bit = pol_first & 'h80;
                
                pol_first = pol_first << 1;
                
                if (high_bit != 0) 
                begin
                    pol_first = pol_first ^ 'hc3;
                end
                
                pol_second = pol_second >> 1;
            end
        end 
    endfunction
    
    function [7:0] sbox;
        input [7:0] byte_in;
        begin
            case (byte_in)
                0: sbox = 'h_fc;
                1: sbox = 'h_ee;
                2: sbox = 'h_dd;
                3: sbox = 'h_11;
                4: sbox = 'h_cf;
                5: sbox = 'h_6e;
                6: sbox = 'h_31;
                7: sbox = 'h_16;
                8: sbox = 'h_fb;
                9: sbox = 'h_c4;
                10: sbox = 'h_fa;
                11: sbox = 'h_da;
                12: sbox = 'h_23;
                13: sbox = 'h_c5;
                14: sbox = 'h_4;
                15: sbox = 'h_4d;
                16: sbox = 'h_e9;
                17: sbox = 'h_77;
                18: sbox = 'h_f0;
                19: sbox = 'h_db;
                20: sbox = 'h_93;
                21: sbox = 'h_2e;
                22: sbox = 'h_99;
                23: sbox = 'h_ba;
                24: sbox = 'h_17;
                25: sbox = 'h_36;
                26: sbox = 'h_f1;
                27: sbox = 'h_bb;
                28: sbox = 'h_14;
                29: sbox = 'h_cd;
                30: sbox = 'h_5f;
                31: sbox = 'h_c1;
                32: sbox = 'h_f9;
                33: sbox = 'h_18;
                34: sbox = 'h_65;
                35: sbox = 'h_5a;
                36: sbox = 'h_e2;
                37: sbox = 'h_5c;
                38: sbox = 'h_ef;
                39: sbox = 'h_21;
                40: sbox = 'h_81;
                41: sbox = 'h_1c;
                42: sbox = 'h_3c;
                43: sbox = 'h_42;
                44: sbox = 'h_8b;
                45: sbox = 'h_1;
                46: sbox = 'h_8e;
                47: sbox = 'h_4f;
                48: sbox = 'h_5;
                49: sbox = 'h_84;
                50: sbox = 'h_2;
                51: sbox = 'h_ae;
                52: sbox = 'h_e3;
                53: sbox = 'h_6a;
                54: sbox = 'h_8f;
                55: sbox = 'h_a0;
                56: sbox = 'h_6;
                57: sbox = 'h_b;
                58: sbox = 'h_ed;
                59: sbox = 'h_98;
                60: sbox = 'h_7f;
                61: sbox = 'h_d4;
                62: sbox = 'h_d3;
                63: sbox = 'h_1f;
                64: sbox = 'h_eb;
                65: sbox = 'h_34;
                66: sbox = 'h_2c;
                67: sbox = 'h_51;
                68: sbox = 'h_ea;
                69: sbox = 'h_c8;
                70: sbox = 'h_48;
                71: sbox = 'h_ab;
                72: sbox = 'h_f2;
                73: sbox = 'h_2a;
                74: sbox = 'h_68;
                75: sbox = 'h_a2;
                76: sbox = 'h_fd;
                77: sbox = 'h_3a;
                78: sbox = 'h_ce;
                79: sbox = 'h_cc;
                80: sbox = 'h_b5;
                81: sbox = 'h_70;
                82: sbox = 'h_e;
                83: sbox = 'h_56;
                84: sbox = 'h_8;
                85: sbox = 'h_c;
                86: sbox = 'h_76;
                87: sbox = 'h_12;
                88: sbox = 'h_bf;
                89: sbox = 'h_72;
                90: sbox = 'h_13;
                91: sbox = 'h_47;
                92: sbox = 'h_9c;
                93: sbox = 'h_b7;
                94: sbox = 'h_5d;
                95: sbox = 'h_87;
                96: sbox = 'h_15;
                97: sbox = 'h_a1;
                98: sbox = 'h_96;
                99: sbox = 'h_29;
                100: sbox = 'h_10;
                101: sbox = 'h_7b;
                102: sbox = 'h_9a;
                103: sbox = 'h_c7;
                104: sbox = 'h_f3;
                105: sbox = 'h_91;
                106: sbox = 'h_78;
                107: sbox = 'h_6f;
                108: sbox = 'h_9d;
                109: sbox = 'h_9e;
                110: sbox = 'h_b2;
                111: sbox = 'h_b1;
                112: sbox = 'h_32;
                113: sbox = 'h_75;
                114: sbox = 'h_19;
                115: sbox = 'h_3d;
                116: sbox = 'h_ff;
                117: sbox = 'h_35;
                118: sbox = 'h_8a;
                119: sbox = 'h_7e;
                120: sbox = 'h_6d;
                121: sbox = 'h_54;
                122: sbox = 'h_c6;
                123: sbox = 'h_80;
                124: sbox = 'h_c3;
                125: sbox = 'h_bd;
                126: sbox = 'h_d;
                127: sbox = 'h_57;
                128: sbox = 'h_df;
                129: sbox = 'h_f5;
                130: sbox = 'h_24;
                131: sbox = 'h_a9;
                132: sbox = 'h_3e;
                133: sbox = 'h_a8;
                134: sbox = 'h_43;
                135: sbox = 'h_c9;
                136: sbox = 'h_d7;
                137: sbox = 'h_79;
                138: sbox = 'h_d6;
                139: sbox = 'h_f6;
                140: sbox = 'h_7c;
                141: sbox = 'h_22;
                142: sbox = 'h_b9;
                143: sbox = 'h_3;
                144: sbox = 'h_e0;
                145: sbox = 'h_f;
                146: sbox = 'h_ec;
                147: sbox = 'h_de;
                148: sbox = 'h_7a;
                149: sbox = 'h_94;
                150: sbox = 'h_b0;
                151: sbox = 'h_bc;
                152: sbox = 'h_dc;
                153: sbox = 'h_e8;
                154: sbox = 'h_28;
                155: sbox = 'h_50;
                156: sbox = 'h_4e;
                157: sbox = 'h_33;
                158: sbox = 'h_a;
                159: sbox = 'h_4a;
                160: sbox = 'h_a7;
                161: sbox = 'h_97;
                162: sbox = 'h_60;
                163: sbox = 'h_73;
                164: sbox = 'h_1e;
                165: sbox = 'h_0;
                166: sbox = 'h_62;
                167: sbox = 'h_44;
                168: sbox = 'h_1a;
                169: sbox = 'h_b8;
                170: sbox = 'h_38;
                171: sbox = 'h_82;
                172: sbox = 'h_64;
                173: sbox = 'h_9f;
                174: sbox = 'h_26;
                175: sbox = 'h_41;
                176: sbox = 'h_ad;
                177: sbox = 'h_45;
                178: sbox = 'h_46;
                179: sbox = 'h_92;
                180: sbox = 'h_27;
                181: sbox = 'h_5e;
                182: sbox = 'h_55;
                183: sbox = 'h_2f;
                184: sbox = 'h_8c;
                185: sbox = 'h_a3;
                186: sbox = 'h_a5;
                187: sbox = 'h_7d;
                188: sbox = 'h_69;
                189: sbox = 'h_d5;
                190: sbox = 'h_95;
                191: sbox = 'h_3b;
                192: sbox = 'h_7;
                193: sbox = 'h_58;
                194: sbox = 'h_b3;
                195: sbox = 'h_40;
                196: sbox = 'h_86;
                197: sbox = 'h_ac;
                198: sbox = 'h_1d;
                199: sbox = 'h_f7;
                200: sbox = 'h_30;
                201: sbox = 'h_37;
                202: sbox = 'h_6b;
                203: sbox = 'h_e4;
                204: sbox = 'h_88;
                205: sbox = 'h_d9;
                206: sbox = 'h_e7;
                207: sbox = 'h_89;
                208: sbox = 'h_e1;
                209: sbox = 'h_1b;
                210: sbox = 'h_83;
                211: sbox = 'h_49;
                212: sbox = 'h_4c;
                213: sbox = 'h_3f;
                214: sbox = 'h_f8;
                215: sbox = 'h_fe;
                216: sbox = 'h_8d;
                217: sbox = 'h_53;
                218: sbox = 'h_aa;
                219: sbox = 'h_90;
                220: sbox = 'h_ca;
                221: sbox = 'h_d8;
                222: sbox = 'h_85;
                223: sbox = 'h_61;
                224: sbox = 'h_20;
                225: sbox = 'h_71;
                226: sbox = 'h_67;
                227: sbox = 'h_a4;
                228: sbox = 'h_2d;
                229: sbox = 'h_2b;
                230: sbox = 'h_9;
                231: sbox = 'h_5b;
                232: sbox = 'h_cb;
                233: sbox = 'h_9b;
                234: sbox = 'h_25;
                235: sbox = 'h_d0;
                236: sbox = 'h_be;
                237: sbox = 'h_e5;
                238: sbox = 'h_6c;
                239: sbox = 'h_52;
                240: sbox = 'h_59;
                241: sbox = 'h_a6;
                242: sbox = 'h_74;
                243: sbox = 'h_d2;
                244: sbox = 'h_e6;
                245: sbox = 'h_f4;
                246: sbox = 'h_b4;
                247: sbox = 'h_c0;
                248: sbox = 'h_d1;
                249: sbox = 'h_66;
                250: sbox = 'h_af;
                251: sbox = 'h_c2;
                252: sbox = 'h_39;
                253: sbox = 'h_4b;
                254: sbox = 'h_63;
                255: sbox = 'h_b6;
            endcase
        end
    endfunction
    
    assign data_out = state_out;
    
    // Основной цикл состояния
    always @(posedge clk)
    begin
        if (reset_n == 0)
        begin
            round_counter <= 0;
        end
        else
            case (STATE)
                IDLE:
                    begin
                        cycles_done <= 0;
                        if (start_trigger == 1)
                            STATE <= START;
                    end
                START:
                    begin
                        STATE <= X_TRANSFORM;
                        round_counter = 0;
                        base_data <= data_in;
                    end
                X_TRANSFORM:
                    begin
                        round_counter <= round_counter + 1;
                        STATE <= S_TRANSFORM;
                    end
                S_TRANSFORM:
                    begin
                        STATE <= L_TRANSFORM;
                    end
                L_TRANSFORM:
                    begin
                        if (round_counter == 9)
                            STATE <= LAST_X_TRANSFORM;
                        else 
                            STATE <= X_TRANSFORM;
                    end
                LAST_X_TRANSFORM:
                    begin
                        STATE <= END_STATE;
                    end
                END_STATE:
                    begin
                        state_out <= after_x_transform;
                        cycles_done <= 1;
                        STATE <= IDLE;
                    end  
            endcase
    end
    
    //---------------------------------------------------//
    //---------------Обработчик X_TRANSFORM--------------//
    //---------------------------------------------------//
    always @(posedge clk)
    begin
        if (reset_n == 0)
        begin
        //
        end
        else if(STATE == X_TRANSFORM && round_counter == 0)
        begin
            after_x_transform <= base_data ^ round_keys[round_counter];
        end
        else if (STATE == X_TRANSFORM)
        begin
            after_x_transform <= after_l_transform ^ round_keys[round_counter];
        end
        else if (STATE == LAST_X_TRANSFORM)
        begin
            after_x_transform <= after_l_transform ^ round_keys[round_counter];
        end
    end
    //---------------------------------------------------//
    //-----------END Обработчик X_TRANSFORM--------------//
    //---------------------------------------------------//
    
    //---------------------------------------------------//
    //---------------Обработчик S_TRANSFORM--------------//
    //---------------------------------------------------//
    always @(posedge clk)
    begin
        if (reset_n == 0)
        begin
        //
        end
        else if(STATE == S_TRANSFORM)
        begin
            after_s_transform[0+:8] <= sbox(after_x_transform[0+:8]);
            after_s_transform[8+:8] <= sbox(after_x_transform[8+:8]);
            after_s_transform[16+:8] <= sbox(after_x_transform[16+:8]);
            after_s_transform[24+:8] <= sbox(after_x_transform[24+:8]);
            after_s_transform[32+:8] <= sbox(after_x_transform[32+:8]);
            after_s_transform[40+:8] <= sbox(after_x_transform[40+:8]);
            after_s_transform[48+:8] <= sbox(after_x_transform[48+:8]);
            after_s_transform[56+:8] <= sbox(after_x_transform[56+:8]);
            after_s_transform[64+:8] <= sbox(after_x_transform[64+:8]);
            after_s_transform[72+:8] <= sbox(after_x_transform[72+:8]);
            after_s_transform[80+:8] <= sbox(after_x_transform[80+:8]);
            after_s_transform[88+:8] <= sbox(after_x_transform[88+:8]);
            after_s_transform[96+:8] <= sbox(after_x_transform[96+:8]);
            after_s_transform[104+:8] <= sbox(after_x_transform[104+:8]);
            after_s_transform[112+:8] <= sbox(after_x_transform[112+:8]);
            after_s_transform[120+:8] <= sbox(after_x_transform[120+:8]);
        end
    end
    //---------------------------------------------------//
    //-----------END Обработчик S_TRANSFORM--------------//
    //---------------------------------------------------//
    
    //---------------------------------------------------//
    //---------------Обработчик L_TRANSFORM--------------//
    //---------------------------------------------------//
    integer i;
    always @(posedge clk)
    begin  
        if (reset_n == 0)
        begin
        //
        end
        else if(STATE == L_TRANSFORM)
        begin
            after_l_transform = after_s_transform;
            for(i=0; i<16; i=i+1)
            begin
                after_l_transform = R_TRANSFORM(after_l_transform);
            end
        end
    end
    //---------------------------------------------------//
    //-----------END Обработчик L_TRANSFORM--------------//
    //---------------------------------------------------//
    
endmodule
