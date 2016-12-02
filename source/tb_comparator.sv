module tb_comparator ();

reg [255:0] tb_target, tb_SHAoutput;
reg tb_valid;

comparator DUT
(
	.target(tb_target),
	.SHAoutput(tb_SHAoutput),
	.valid(tb_valid)
);

integer i,q = 0;

initial begin
	tb_target = '0;
	tb_SHAoutput = '0;
	
	for(i = 0; i < 10; i++)
	begin
		for(q = 0; q < 10; q++)
		begin
			tb_target = i;
			tb_SHAoutput = q;
			#(0.1)
			assert(tb_valid == (tb_SHAoutput < tb_target))
			else $error("incorrect tb_valid value expected: %d recevied: %d", (tb_SHAoutput < tb_target), tb_valid);
		end
	end

	$info("All tests complete!");
end

endmodule