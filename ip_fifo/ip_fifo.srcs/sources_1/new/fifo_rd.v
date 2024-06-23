`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2024/06/21 10:08:21
// Design Name: ip_fifo
// Module Name: top_fifo
// Target Devices: Xilinx Virtex7 vc707
// Tool Versions: 
// copyright@ Raynaril from Purple Mountain Laboratories
//////////////////////////////////////////////////////////////////////////////////

module fifo_rd(
    //system clock
    input               rd_clk      , //ʱ���ź� 100M
    input               rst_n       , //��λ�ź�
    //FIFO interface
    input               rd_rst_busy , //����λæ�ź�
    input        [7:0]  fifo_rd_data, //��FIFO����������
    input               full        , //FIFO���ź�
    input               almost_empty, //FIFO�����ź�
    output  reg         fifo_rd_en    //FIFO��ʹ��
);

//reg define
reg       full_d0;
reg       full_d1;

//��Ϊfull�ź�������FIFOдʱ�����
//���Զ�full������ͬ������ʱ������
always @(posedge rd_clk or negedge rst_n) begin
    if(!rst_n) begin
        full_d0 <= 1'b0;
        full_d1 <= 1'b0;
    end
    else begin
        full_d0 <= full;
        full_d1 <= full_d0;
    end
end    
    
//��fifo_rd_en���и�ֵ,FIFOд��֮��ʼ��������֮��ֹͣ��
always @(posedge rd_clk or negedge rst_n) begin
    if(!rst_n) 
        fifo_rd_en <= 1'b0;
    else if(!rd_rst_busy) begin
        if(full_d1)           // д����ʼ��
           fifo_rd_en <= 1'b1;
        else if(almost_empty) // ���ֹͣ��
           fifo_rd_en <= 1'b0; 
    end
    else
        fifo_rd_en <= 1'b0;
end

endmodule