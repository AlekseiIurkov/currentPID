module PID #(parameter W=15)
(output signed [W:0] u_out,
input signed [W:0] e_in, 
input clk,
input reset);
parameter cn = 50;

reg signed [W:0] u_prev = 0;
reg signed [W:0] e_prev_1 = 0;
reg signed [W:0] e_prev_2 = 0;
reg signed [W:0] r_e_prev_1 = 0;
reg signed [W:0] r_e_prev_2 = 0;
reg signed [W:0] r_e_in = 0;
reg [15:0] cnt = 0;
reg [15:0] cnt_1 = 0;
reg sg_e_in;
reg sg_e_prev_1;
reg sg_e_prev_2;

assign u_out = u_prev + r_e_in - r_e_prev_1 + r_e_prev_2;

always @ (posedge clk)
	if (reset == 0) begin
		u_prev<=0;
		e_prev_1<=0;
		e_prev_2<=0;
		r_e_in <= 0;
		r_e_prev_1 <= 0;
		r_e_prev_2 <= 0;
		
	end 
	else begin
		
		if (u_out > 16'hE000 && u_prev < 16'h0300)
				u_prev<=16'h0300;
		//else if (u_out < u_prev && u_prev < 16'h0301)
			//	u_prev<=16'h0300;
		
		cnt_1 <= cnt_1 + 1;
		if (cnt_1 == cn)// 
		begin
		cnt_1 <= 0;//
			cnt <= cnt + 1;
			if (cnt == cn)// 
				begin
				//cnt <= 0;
				e_prev_2<=e_prev_1;
				e_prev_1<=e_in;
				
				if (u_out < 16'hE000 || u_prev > u_out)
				u_prev<=u_out;				
				
				//r_e_in[W] <= e_in[W];
				
				if (e_in[W] == 0)
				begin
				{r_e_in[W], r_e_in[W-1:W-3], r_e_in[W-4:0]}  <= {e_in[W], 3'b000, e_in[W-1:3]};
				sg_e_in <= 0;
				end
				else
				begin
				{r_e_in[W], r_e_in[W-1:W-3],r_e_in[W-4:0]} <= {e_in[W], 3'b111, e_in[W-1:3]};
				sg_e_in <= 1;
				end
				//r_e_prev_1[W] <= e_prev_1[W];
				
				if (e_prev_1 >= 0)
				begin
				r_e_prev_1 <= {e_prev_1[W], 4'b0000, e_prev_1[W-1:4]};
				sg_e_prev_1 <= 0;
				end
				else
				begin
				r_e_prev_1 <= {e_prev_1[W], 4'b1111, e_prev_1[W-1:4]};
				sg_e_prev_1 <= 0;
				end
				//r_e_prev_2 <= e_prev_2[W];
				
				if (e_prev_2 >= 0)
				begin
				r_e_prev_2 <= {e_prev_2[W], 4'b0000, e_prev_2[W-1:4]};
				sg_e_prev_2 <= 0;
				end
				else
				begin
				r_e_prev_2 <= {e_prev_2[W], 4'b1111, e_prev_2[W-1:4]};
				sg_e_prev_2 <= 1;
				end
				
				cnt <= 0;
			end
		end
end
endmodule
