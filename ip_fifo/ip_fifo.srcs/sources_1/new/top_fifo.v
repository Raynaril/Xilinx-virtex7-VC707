`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2024/06/21 10:08:21
// Design Name: ip_fifo
// Module Name: top_fifo
// Target Devices: Xilinx Virtex7 vc707
// Tool Versions: 
// copyright@ Raynaril from Purple Mountain Laboratories
//////////////////////////////////////////////////////////////////////////////////
module ip_fifo(
        input       sys_clk_p ,  // vc707�������ʱ�� 200Mhz
        input       sys_clk_n , 
        input       sys_rst   ,  // vc707ϵͳ��λ����Ч
        output reg [7:0] led
    );
    
    //wire define
    wire         clk_50m       ;  // 50Mʱ��
    wire         clk_100m      ;  // 100Mʱ��
    wire         locked        ;  // ʱ�������ź�
    wire         rst_n         ;  // ��λ������Ч
    wire         wr_rst_busy   ;  // д��λæ�ź�
    wire         rd_rst_busy   ;  // ����λæ�ź�
    wire         fifo_wr_en    ;  // FIFOдʹ���ź�
    wire         fifo_rd_en    ;  // FIFO��ʹ���ź�
    wire  [7:0]  fifo_wr_data  ;  // д�뵽FIFO������
    wire  [7:0]  fifo_rd_data  ;  // ��FIFO����������
    wire         almost_full   ;  // FIFO�����ź�
    wire         almost_empty  ;  // FIFO�����ź�
    wire         full          ;  // FIFO���ź�
    wire         empty         ;  // FIFO���ź�
    wire  [7:0]  wr_data_count ;  // FIFOдʱ��������ݼ���
    wire  [7:0]  rd_data_count ;  // FIFO��ʱ��������ݼ���
    wire         sys_clk_ibufg ;  // ʱ�ӻ������
    wire         fifo_wr_flag  ;  // FIFOд��־
    reg          state         ;  // ״̬����
    reg   [27:0] count         ;  // ��ʱ����
    
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
        
    // ����ʱ�� IP��
    clk_wiz_0 u_clk_wiz_0 (
        .clk_out1(clk_50m ),      // output clk_out1 50M
        .clk_out2(clk_100m),      // output clk_out2 100M
        .locked  (locked  ),      // output locked
        
        .clk_in1 (sys_clk_ibufg ) // input clk_in1
    );     
    
    // ͨ��sys_rst��ʱ������locked�źŲ����µĸ�λ�ź� ����Ч
    assign   rst_n = (~sys_rst) & locked;
    
    // FIFOдģʽ��ָʾ����ѭ�� 
    // ����FIFO��д����̫�� �����0.5s��ȫ�ɺ��� �Ӿ���ʾ��ˮ����ֹͣ��� ����ila�������Կ���
    always @(posedge clk_50m or negedge rst_n) begin
         if(!rst_n )begin
            led   <= 8'b00000001;
            count <= 28'd0      ;
            state <= 1'd0       ;
         end
         else begin
            case(state) 
                1'd0:begin
                    if(fifo_wr_flag) begin  // ���FIFO��ʼд
                        state <= 1'd1;      // ������ʱ״̬
                        led   <= led ;
                    end
                    else begin
                        state <= state;
                        led   <= led  ; 
                    end
                end
                1'd1:begin  //�ȴ�
                    if(count ==28'd2500_0000)begin
                        count <= 16'd0             ;
                        state <= 1'd0              ;
                        led   <= {led[6:0],led[7]} ; // ��ˮ����ѭ��
                    end
                    else begin
                        count <= count+1;
                        led   <=led     ;
                        state <= state  ;
                    end
                 end
                 default: begin
                    state <=1'd0;
                    led   <=led ;
                 end
            endcase
         end
    end
      
    // ����FIFO IP��
    fifo_generator_0  u_fifo_generator_0 (
        .rst           (~rst_n       ),  // input wire rst
        .wr_clk        (clk_50m      ),  // input wire wr_clk
        .rd_clk        (clk_100m     ),  // input wire rd_clk
        .wr_en         (fifo_wr_en   ),  // input wire wr_en
        .rd_en         (fifo_rd_en   ),  // input wire rd_en
        .din           (fifo_wr_data ),  // input wire [7 : 0] din
        .dout          (fifo_rd_data ),  // output wire [7 : 0] dout
        .almost_full   (almost_full  ),  // output wire almost_full
        .almost_empty  (almost_empty ),  // output wire almost_empty
        .full          (full         ),  // output wire full
        .empty         (empty        ),  // output wire empty
        .wr_data_count (wr_data_count),  // output wire [7 : 0] wr_data_count   
        .rd_data_count (rd_data_count),  // output wire [7 : 0] rd_data_count
        .wr_rst_busy   (wr_rst_busy  ),  // output wire wr_rst_busy
        .rd_rst_busy   (rd_rst_busy  )   // output wire rd_rst_busy
    );
    
    // ����FIFOдģ��
    fifo_wr  u_fifo_wr (
        .wr_clk        (clk_50m     ), // дʱ��
        .rst_n         (rst_n       ), // ��λ�ź�
        .wr_rst_busy   (wr_rst_busy ), // д��λæ�ź�
        .fifo_wr_en    (fifo_wr_en  ), // fifoд����
        .fifo_wr_data  (fifo_wr_data), // д��FIFO������
        .empty         (empty       ), // fifo���ź�
        .almost_full   (almost_full ),  // fifo�����ź�
        .fifo_wr_flag  (fifo_wr_flag ) // fifoд��־
    );
    
    //����FIFO��ģ��
    fifo_rd  u_fifo_rd (
        .rd_clk       (clk_100m    ),  // ��ʱ��
        .rst_n        (rst_n       ),  // ��λ�ź�
        .rd_rst_busy  (rd_rst_busy ),  // ����λæ�ź�
        .fifo_rd_en   (fifo_rd_en  ),  // fifo������
        .fifo_rd_data (fifo_rd_data),  // ��FIFO���������
        .almost_empty (almost_empty),  // fifo�����ź�
        .full         (full        )   // fifo���ź�
    );
//    // fifo_wr ila��
//    ila_0 u_ila_wr (
//        .clk       (clk_50m      ), // input wire clk
    
//        .probe0    (fifo_wr_en   ), // input wire [0:0]  probe0  
//        .probe1    (fifo_wr_data ), // input wire [7:0]  probe1 
//        .probe2    (almost_full  ), // input wire [0:0]  probe2 
//        .probe3    (full         ), // input wire [0:0]  probe3 
//        .probe4    (wr_data_count), // input wire [7:0]  probe4
//        .probe5    (fifo_wr_flag )  // input wire [0:0]  probe5
//    );
    
//    // fifo_rd ila��
//    ila_1 u_ila_rd (
//        .clk       (clk_100m     ), // input wire clk
    
//        .probe0    (fifo_rd_en   ), // input wire [0:0]  probe0  
//        .probe1    (fifo_rd_data ), // input wire [7:0]  probe1 
//        .probe2    (almost_empty ), // input wire [0:0]  probe2 
//        .probe3    (empty        ), // input wire [0:0]  probe3 
//        .probe4    (rd_data_count)  // input wire [7:0]  probe4
//    );
    //top_fifo ila��
//    ila_2 u_ila_top (
//        .clk   (clk_50m), // input wire clk
        
//        .probe0(clk_50m), // input wire [0:0]  probe0 
//        .probe1(count  ), // input wire [15:0]  probe1
//        .probe2(state ), // input wire [0:0]  probe2
//        .probe3(led)     // input wire [7:0]  probe0  
//);
    
endmodule 

