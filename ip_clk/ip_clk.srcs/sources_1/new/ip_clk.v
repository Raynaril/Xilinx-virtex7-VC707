`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2024/06/20 12:44:34
// Design Name: ip_clk
// Module Name: ip_clk
// Target Devices: Xilinx Virtex7 vc707
// Tool Versions: 
// copyright@ Raynaril from Purple Mountain Laboratories
//////////////////////////////////////////////////////////////////////////////////
module ip_clk(
        input       sys_clk_p, // vc707�������ʱ�� 200Mhz
        input       sys_clk_n, 
        input       rst      , // vc707��λ ����Ч
        output reg [7:0] led
    );
    // wire define
    wire sys_clk_ibufg;
    wire clk;
    // reg define
    reg [26:0]count;
    
    IBUFGDS #   // ���ʱ��ת����ԭ��        
    (
    .DIFF_TERM ("FALSE"),
    .IBUF_LOW_PWR ("FALSE")
    )
    u_ibufg_sys_clk
    (
    .I (sys_clk_p),    // ���ʱ����������
    .IB (sys_clk_n),   // ���ʱ�Ӹ�������
    .O (sys_clk_ibufg) // ʱ�ӻ������
    );
    
    // ����ʱ��ip��
    clk_wiz_0 u_clk_wiz_0(
        .clk_out1(clk),  // output clk_out1 = 5MHZ  
        
        .reset(rst),     // input reset
        .locked(),       // output locked
        .clk_in1(sys_clk_ibufg)
    );  
         
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            count <= 0;
            led   <= 8'b00000001;
        end
        else begin 
            if(count ==26'd2499999)begin
                count<= 0;
                led<={led[6:0],led[7]}; // ��ˮ��ѭ��
            end
            else count <=count+1;
        end
    end
    
endmodule

