`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2024/06/21 10:08:21
// Design Name: ip_fifo
// Module Name: top_fifo
// Target Devices: Xilinx Virtex7 vc707
// Tool Versions: 
// copyright@ Raynaril from Purple Mountain Laboratories
//////////////////////////////////////////////////////////////////////////////////

module fifo_wr(
    //mudule clock
    input                  wr_clk      ,  // ʱ���ź� 50M
    input                  rst_n       ,  // ��λ�ź�
    //FIFO interface       
    input                  wr_rst_busy ,  // д��λæ�ź�
    input                  empty       ,  // FIFO���ź�
    input                  almost_full ,  // FIFO�����ź�
	output    reg          fifo_wr_en  ,  // FIFOдʹ��
    output    reg  [7:0]   fifo_wr_data,  // д��FIFO������
    output    reg          fifo_wr_flag   // FIFOд��״̬��־λ
);

//reg define
reg        empty_d0;
reg        empty_d1;

//*****************************************************
//**                    main code
//*****************************************************
// д��־λ���
always @(posedge wr_clk or negedge rst_n) begin
    if(!rst_n) begin
        fifo_wr_flag <= 1'b0;
    end
    else if(fifo_wr_data == 8'b1)
        fifo_wr_flag <= 1'b1;
    else 
        fifo_wr_flag <= 1'b0;
end

//��Ϊempty�ź�������FIFO��ʱ�����
//���Զ�empty������ͬ����дʱ������?????
always @(posedge wr_clk or negedge rst_n) begin
    if(!rst_n) begin
        empty_d0 <= 1'b0;
        empty_d1 <= 1'b0;
    end
    else begin
        empty_d0 <= empty;
        empty_d1 <= empty_d0;
    end
end

//��fifo_wr_en��ֵ����FIFOΪ��ʱ��ʼд�룬д����ֹͣд
always @(posedge wr_clk or negedge rst_n) begin
    if(!rst_n) 
        fifo_wr_en <= 1'b0;
    else if(!wr_rst_busy) begin
        if(empty_d1)
            fifo_wr_en <= 1'b1;
        else if(almost_full)
            fifo_wr_en <= 1'b0;  
    end
    else
        fifo_wr_en <= 1'b0;        
end  

//��fifo_wr_data��ֵ,0~254
always @(posedge wr_clk or negedge rst_n) begin
    if(!rst_n) 
        fifo_wr_data <= 8'b0;
    else if(fifo_wr_en && fifo_wr_data < 8'd254)
            fifo_wr_data <= fifo_wr_data + 8'b1;
        else
            fifo_wr_data <= 8'b0;
end

endmodule
