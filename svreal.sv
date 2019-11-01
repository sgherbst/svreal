`ifndef __SVREAL_SV__
`define __SVREAL_SV__

// math functions used to compute parameters

`define SVREAL_EXPR_MIN(a, b) \
    (((a) <= (b)) ? (a) : (b))

`define SVREAL_EXPR_MAX(a, b) \
    (((a) >= (b)) ? (a) : (b))

`define SVREAL_EXPR_RSHIFT(a, rshift) \
    (((``rshift``) >= 0) ? ((``a``) >>> (``rshift``)) : ((``a``) <<< (-(``rshift``))))

`define SVREAL_EXPR_LSHIFT(a, lshift) \
    (((``lshift``) >= 0) ? ((``a``) <<< (``lshift``)) : ((``a``) >>> (-(``lshift``))))

// method to generate an error (only works during simulation at the moment)

`define SVREAL_ERROR \
    initial begin \
        $display("SVREAL ERROR"); \
        $fatal; \
    end

// exponent format

`define SVREAL_EXPONENT(name) ``name``_exponent

`define SVREAL_EXPONENT_WIDTH 16

`define SVREAL_EXPONENT_TYPE \
    logic signed [((`SVREAL_EXPONENT_WIDTH)-1):0]

`define SVREAL_MIN_EXPONENT(a, b) \
    `SVREAL_EXPR_MIN(`SVREAL_EXPONENT(``a``), `SVREAL_EXPONENT(``b``))

`define SVREAL_MAX_EXPONENT(a, b) \
    `SVREAL_EXPR_MAX(`SVREAL_EXPONENT(``a``), `SVREAL_EXPONENT(``b``))

// significand format

`define SVREAL_SIGNIFICAND(name) ``name``_significand

`define SVREAL_SIGNIFICAND_TYPE(width) \
    `ifndef SVREAL_DEBUG \
        logic signed [((``width``)-1):0] \
    `else \
        real \
    `endif

`define SVREAL_SIGNIFICAND_WIDTH(name) \
    `ifndef SVREAL_DEBUG \
        $size(`SVREAL_SIGNIFICAND(``name``)) \
    `else \
        -1 \
    `endif

`define FLOAT_TO_FIXED(float_val, exponent) \
     ((1.0*``float_val``)*((2.0)**(-(``exponent``))))

`define FIXED_TO_FLOAT(fixed_val, exponent) \
     ((1.0*``fixed_val``)*((2.0)**(+(``exponent``))))

`define SVREAL_TO_FLOAT(name) \
    `FIXED_TO_FLOAT(`SVREAL_SIGNIFICAND(``name``), `SVREAL_EXPONENT(``name``)) \

`define FLOAT_TO_SVREAL(value, name) \
    `FLOAT_TO_FIXED(``value``, `SVREAL_EXPONENT(``name``)) \

// macro to print svreal numbers

`define SVREAL_PRINT(name) \
    $display(`"``name``=%0f`", `SVREAL_TO_FLOAT(``name``))

// macro to create svreal numbers conveniently

`define MAKE_SVREAL(name, width, exponent) \
    `SVREAL_SIGNIFICAND_TYPE(``width``) `SVREAL_SIGNIFICAND(``name``); \
    `SVREAL_EXPONENT_TYPE `SVREAL_EXPONENT(``name``) \
    `ifndef SVREAL_DEBUG \
        ; assign `SVREAL_EXPONENT(``name``) = ``exponent`` \
    `else \
        ; assign `SVREAL_EXPONENT(``name``) = 0 \
    `endif

`define SVREAL_COPY_FORMAT(in, out) \
    `MAKE_SVREAL(``out``, `SVREAL_SIGNIFICAND_WIDTH(``in``), `SVREAL_EXPONENT(``in``))

`define SVREAL_SIGNIFICAND_WIDTH_PARAM(name) ``name``_significand_width

`define PASS_SVREAL_PARAMS(internal_name, external_name) \
    .`SVREAL_SIGNIFICAND_WIDTH_PARAM(``internal_name``)(`SVREAL_SIGNIFICAND_WIDTH(``external_name``))

`define DECL_SVREAL_PARAMS(name) \
    parameter integer `SVREAL_SIGNIFICAND_WIDTH_PARAM(``name``) = -1

`define DECL_SVREAL_INPUT(name) \
    input `SVREAL_SIGNIFICAND_TYPE(`SVREAL_SIGNIFICAND_WIDTH_PARAM(``name``)) `SVREAL_SIGNIFICAND(``name``), \
    input `SVREAL_EXPONENT_TYPE `SVREAL_EXPONENT(``name``)

`define DECL_SVREAL_OUTPUT(name) \
    output `SVREAL_SIGNIFICAND_TYPE(`SVREAL_SIGNIFICAND_WIDTH_PARAM(``name``)) `SVREAL_SIGNIFICAND(``name``), \
    input `SVREAL_EXPONENT_TYPE `SVREAL_EXPONENT(``name``)

`define PASS_SVREAL_SIGNALS(internal_name, external_name) \
    .`SVREAL_SIGNIFICAND(``internal_name``)(`SVREAL_SIGNIFICAND(``external_name``)), \
    .`SVREAL_EXPONENT(``internal_name``)(`SVREAL_EXPONENT(``external_name``)) \

// assign one svreal to another

`define SVREAL_ASSIGN(a_name, b_name) \
    svreal_assign_mod #( \
        `PASS_SVREAL_PARAMS(a, ``a_name``), \
        `PASS_SVREAL_PARAMS(b, ``b_name``) \
    ) ``b_name``_mod_i ( \
        `PASS_SVREAL_SIGNALS(a, ``a_name``), \
        `PASS_SVREAL_SIGNALS(b, ``b_name``) \
    )

// negate an svreal

`define SVREAL_NEGATE(a_name, b_name) \
    svreal_negate_mod #( \
        `PASS_SVREAL_PARAMS(a, ``a_name``), \
        `PASS_SVREAL_PARAMS(b, ``b_name``) \
    ) ``b_name``_mod_i ( \
        `PASS_SVREAL_SIGNALS(a, ``a_name``), \
        `PASS_SVREAL_SIGNALS(b, ``b_name``) \
    )

// assign a constant to an svreal (either as a continuous assignment or within a testbench context)

`define SVREAL_SET(name, expr) \
    `SVREAL_SIGNIFICAND(``name``) = `FLOAT_TO_SVREAL(``expr``, ``name``)

// add/sub

`define SVREAL_OPCODE_ADD 0
`define SVREAL_OPCODE_SUB 1

`define SVREAL_ADDSUB(opcode_expr, a_name, b_name, c_name) \
    svreal_addsub_mod #( \
        .opcode(``opcode_expr``), \
        `PASS_SVREAL_PARAMS(a, ``a_name``), \
        `PASS_SVREAL_PARAMS(b, ``b_name``), \
        `PASS_SVREAL_PARAMS(c, ``c_name``) \
    ) ``c_name``_mod_i ( \
        `PASS_SVREAL_SIGNALS(a, ``a_name``), \
        `PASS_SVREAL_SIGNALS(b, ``b_name``), \
        `PASS_SVREAL_SIGNALS(c, ``c_name``) \
    )

`define SVREAL_ADD(a, b, c) `SVREAL_ADDSUB(`SVREAL_OPCODE_ADD, a, b, c)
`define SVREAL_SUB(a, b, c) `SVREAL_ADDSUB(`SVREAL_OPCODE_SUB, a, b, c)

// mul

`define SVREAL_MUL(a_name, b_name, c_name) \
    svreal_mul_mod #( \
        `PASS_SVREAL_PARAMS(a, ``a_name``), \
        `PASS_SVREAL_PARAMS(b, ``b_name``), \
        `PASS_SVREAL_PARAMS(c, ``c_name``) \
    ) ``c_name``_mod_i ( \
        `PASS_SVREAL_SIGNALS(a, ``a_name``), \
        `PASS_SVREAL_SIGNALS(b, ``b_name``), \
        `PASS_SVREAL_SIGNALS(c, ``c_name``) \
    )

// min/max

`define SVREAL_OPCODE_MIN 0
`define SVREAL_OPCODE_MAX 1

`define SVREAL_MINMAX(opcode_expr, a_name, b_name, c_name) \
    svreal_minmax_mod #( \
        .opcode(``opcode_expr``), \
        `PASS_SVREAL_PARAMS(a, ``a_name``), \
        `PASS_SVREAL_PARAMS(b, ``b_name``), \
        `PASS_SVREAL_PARAMS(c, ``c_name``) \
    ) ``c_name``_mod_i ( \
        `PASS_SVREAL_SIGNALS(a, ``a_name``), \
        `PASS_SVREAL_SIGNALS(b, ``b_name``), \
        `PASS_SVREAL_SIGNALS(c, ``c_name``) \
    )

`define SVREAL_MIN(a, b, c) `SVREAL_MINMAX(`SVREAL_OPCODE_MIN, a, b, c)
`define SVREAL_MAX(a, b, c) `SVREAL_MINMAX(`SVREAL_OPCODE_MAX, a, b, c)

// comparisons

`define SVREAL_COMP(opcode_expr, a_name, b_name, c_name) \
    svreal_comp_mod #( \
        .opcode(``opcode_expr``), \
        `PASS_SVREAL_PARAMS(a, ``a_name``), \
        `PASS_SVREAL_PARAMS(b, ``b_name``) \
    ) ``c_name``_mod_i ( \
        `PASS_SVREAL_SIGNALS(a, ``a_name``), \
        `PASS_SVREAL_SIGNALS(b, ``b_name``), \
        .c(``c_name``) \
    )
    
`define SVREAL_OPCODE_GT 0
`define SVREAL_OPCODE_GE 1
`define SVREAL_OPCODE_LT 2
`define SVREAL_OPCODE_LE 3
`define SVREAL_OPCODE_EQ 4
`define SVREAL_OPCODE_NE 5

`define SVREAL_GT(a, b, c) `SVREAL_COMP(`SVREAL_OPCODE_GT, a, b, c)
`define SVREAL_GE(a, b, c) `SVREAL_COMP(`SVREAL_OPCODE_GE, a, b, c)
`define SVREAL_LT(a, b, c) `SVREAL_COMP(`SVREAL_OPCODE_LT, a, b, c)
`define SVREAL_LE(a, b, c) `SVREAL_COMP(`SVREAL_OPCODE_LE, a, b, c)
`define SVREAL_EQ(a, b, c) `SVREAL_COMP(`SVREAL_OPCODE_EQ, a, b, c)
`define SVREAL_NE(a, b, c) `SVREAL_COMP(`SVREAL_OPCODE_NE, a, b, c)

// multiplex between two values

`define SVREAL_MUX(a_name, b_name, c_name, d_name) \
    svreal_mux_mod #( \
        `PASS_SVREAL_PARAMS(b, ``b_name``), \
        `PASS_SVREAL_PARAMS(c, ``c_name``), \
        `PASS_SVREAL_PARAMS(d, ``d_name``) \
    ) ``d_name``_mod_i ( \
        .a(``a_name``), \
        `PASS_SVREAL_SIGNALS(b, ``b_name``), \
        `PASS_SVREAL_SIGNALS(c, ``c_name``), \
        `PASS_SVREAL_SIGNALS(d, ``d_name``) \
    )

// conversion between integer and svreal

`define SVREAL_TO_INT(a_name, b_name) \
    svreal_to_int_mod #( \
        `PASS_SVREAL_PARAMS(a, ``a_name``), \
        .width($size(``b_name``)) \
    ) ``b_name``_mod_i ( \
        `PASS_SVREAL_SIGNALS(a, ``a_name``), \
        .b(``b_name``) \
    )

`define INT_TO_SVREAL(a_name, b_name) \
    int_to_svreal_mod #( \
        .width($size(``a_name``)), \
        `PASS_SVREAL_PARAMS(b, ``b_name``) \
    ) ``b_name``_mod_i ( \
        .a(``a_name``), \
        `PASS_SVREAL_SIGNALS(b, ``b_name``) \
    )

// memory

`define SVREAL_DFF(d_name, q_name, rst_name, clk_name, cke_name, init_name) \
    svreal_dff_mod #( \
        `PASS_SVREAL_PARAMS(d, ``d_name``), \
        `PASS_SVREAL_PARAMS(q, ``q_name``), \
        `PASS_SVREAL_PARAMS(init, ``init_name``) \
    ) ``q_name``_mod_i ( \
        `PASS_SVREAL_SIGNALS(d, ``d_name``), \
        `PASS_SVREAL_SIGNALS(q, ``q_name``), \
        `PASS_SVREAL_SIGNALS(init, ``init_name``), \
        .rst(``rst_name``), \
        .clk(``clk_name``), \
        .cke(``cke_name``) \
    )

// assign one svreal number to another

module svreal_assign_mod #(
    `DECL_SVREAL_PARAMS(a),
    `DECL_SVREAL_PARAMS(b)
) (
    `DECL_SVREAL_INPUT(a),
    `DECL_SVREAL_OUTPUT(b)
);

    `ifndef SVREAL_DEBUG
        assign `SVREAL_SIGNIFICAND(b) = `SVREAL_EXPR_LSHIFT(`SVREAL_SIGNIFICAND(a), `SVREAL_EXPONENT(a) - `SVREAL_EXPONENT(b));
    `else
        assign `SVREAL_SIGNIFICAND(b) = `SVREAL_SIGNIFICAND(a);
    `endif

endmodule

// negate an svreal value

module svreal_negate_mod #(
    `DECL_SVREAL_PARAMS(a),
    `DECL_SVREAL_PARAMS(b)
) (
    `DECL_SVREAL_INPUT(a),
    `DECL_SVREAL_OUTPUT(b)
);

    // assign "a" directly into "b_neg", which has the same representation as "b"
    `SVREAL_COPY_FORMAT(b, b_neg);
    `SVREAL_ASSIGN(a, b_neg);
    
    // assign the negated "b_neg" signal into b.value
    assign `SVREAL_SIGNIFICAND(b) = -`SVREAL_SIGNIFICAND(b_neg);

endmodule

// add/sub two svreal numbers

module svreal_addsub_mod #(
    `DECL_SVREAL_PARAMS(a),
    `DECL_SVREAL_PARAMS(b),
    `DECL_SVREAL_PARAMS(c),
    parameter integer opcode=0
) (
    `DECL_SVREAL_INPUT(a),
    `DECL_SVREAL_INPUT(b),
    `DECL_SVREAL_OUTPUT(c)
);

    `SVREAL_COPY_FORMAT(c, a_aligned);
    `SVREAL_COPY_FORMAT(c, b_aligned);
    
    `SVREAL_ASSIGN(a, a_aligned);
    `SVREAL_ASSIGN(b, b_aligned);
     
    generate   
        if (opcode == `SVREAL_OPCODE_ADD) begin
            assign `SVREAL_SIGNIFICAND(c) = `SVREAL_SIGNIFICAND(a_aligned) + `SVREAL_SIGNIFICAND(b_aligned);
        end else if (opcode == `SVREAL_OPCODE_SUB) begin
            assign `SVREAL_SIGNIFICAND(c) = `SVREAL_SIGNIFICAND(a_aligned) - `SVREAL_SIGNIFICAND(b_aligned);
        end else begin
            `SVREAL_ERROR
        end
    endgenerate
                
endmodule

// multiply two svreal numbers

module svreal_mul_mod #(
    `DECL_SVREAL_PARAMS(a),
    `DECL_SVREAL_PARAMS(b),
    `DECL_SVREAL_PARAMS(c)
) (
    `DECL_SVREAL_INPUT(a),
    `DECL_SVREAL_INPUT(b),
    `DECL_SVREAL_OUTPUT(c)
);

    // determine the width of the intermediate result
    localparam integer __a_significand_width = `SVREAL_SIGNIFICAND_WIDTH(a);
    localparam integer __b_significand_width = `SVREAL_SIGNIFICAND_WIDTH(b);
    localparam integer __prod_significand_width = __a_significand_width + __b_significand_width;

    // determine the exponent of the intermediate result
    `SVREAL_EXPONENT_TYPE __prod_exponent;
    assign __prod_exponent = `SVREAL_EXPONENT(a) + `SVREAL_EXPONENT(b);

    // compute intermediate result
    `MAKE_SVREAL(prod, __prod_significand_width, __prod_exponent);
    assign `SVREAL_SIGNIFICAND(prod) = `SVREAL_SIGNIFICAND(a) * `SVREAL_SIGNIFICAND(b);

    // assign intermediate result to output (with appropriate shifting)
    `SVREAL_ASSIGN(prod, c);
                
endmodule

// min/max of two numbers

module svreal_minmax_mod #(
    `DECL_SVREAL_PARAMS(a),
    `DECL_SVREAL_PARAMS(b),
    `DECL_SVREAL_PARAMS(c),
    parameter integer opcode=0
) (
    `DECL_SVREAL_INPUT(a),
    `DECL_SVREAL_INPUT(b),
    `DECL_SVREAL_OUTPUT(c)
);

    // mux between a and b
    logic sel;
    `SVREAL_MUX(sel, a, b, c);
    
    // pick min or max depending on the opcode
    generate
        if          (opcode == `SVREAL_OPCODE_MIN) begin
            `SVREAL_LT(b, a, sel);
        end else if (opcode == `SVREAL_OPCODE_MAX) begin
            `SVREAL_GT(b, a, sel);
        end else begin
            `SVREAL_ERROR
        end
    endgenerate
                
endmodule

// compare two svreal numbers

module svreal_comp_mod #(
    `DECL_SVREAL_PARAMS(a),
    `DECL_SVREAL_PARAMS(b),
    parameter integer opcode=0
) (
    `DECL_SVREAL_INPUT(a),
    `DECL_SVREAL_INPUT(b),
    output wire logic c
);

    // get widths of "a" and "b" significands
    // seems to be necessary to read into a localparam to
    // avoid a bug specific to Xcelium
    localparam integer __a_significand_width = `SVREAL_SIGNIFICAND_WIDTH(a);
    localparam integer __b_significand_width = `SVREAL_SIGNIFICAND_WIDTH(b);

    // compute the maximum exponent of "a" and "b"
    `SVREAL_EXPONENT_TYPE max_exponent;
    assign max_exponent = `SVREAL_MAX_EXPONENT(a, b);

    // make a versions of "a" and "b" that are aligned to each other
    `MAKE_SVREAL(a_aligned, __a_significand_width, max_exponent);
    `MAKE_SVREAL(b_aligned, __b_significand_width, max_exponent);
    `SVREAL_ASSIGN(a, a_aligned);
    `SVREAL_ASSIGN(b, b_aligned);
    
    // perform the desired comparison
    generate
        if          (opcode == `SVREAL_OPCODE_GT) begin
            assign c = (`SVREAL_SIGNIFICAND(a_aligned) >  `SVREAL_SIGNIFICAND(b_aligned)) ? 1'b1 : 1'b0;
        end else if (opcode == `SVREAL_OPCODE_GE) begin
            assign c = (`SVREAL_SIGNIFICAND(a_aligned) >= `SVREAL_SIGNIFICAND(b_aligned)) ? 1'b1 : 1'b0;
        end else if (opcode == `SVREAL_OPCODE_LT) begin
            assign c = (`SVREAL_SIGNIFICAND(a_aligned) <  `SVREAL_SIGNIFICAND(b_aligned)) ? 1'b1 : 1'b0;
        end else if (opcode == `SVREAL_OPCODE_LE) begin
            assign c = (`SVREAL_SIGNIFICAND(a_aligned) <= `SVREAL_SIGNIFICAND(b_aligned)) ? 1'b1 : 1'b0;
        end else if (opcode == `SVREAL_OPCODE_EQ) begin
            assign c = (`SVREAL_SIGNIFICAND(a_aligned) == `SVREAL_SIGNIFICAND(b_aligned)) ? 1'b1 : 1'b0;
        end else if (opcode == `SVREAL_OPCODE_NE) begin
            assign c = (`SVREAL_SIGNIFICAND(a_aligned) != `SVREAL_SIGNIFICAND(b_aligned)) ? 1'b1 : 1'b0;
        end else begin
            `SVREAL_ERROR
        end
    endgenerate
                        
endmodule

// multiplex between two values

module svreal_mux_mod #(
    `DECL_SVREAL_PARAMS(b),
    `DECL_SVREAL_PARAMS(c),
    `DECL_SVREAL_PARAMS(d)
) (
    input wire logic a,
    `DECL_SVREAL_INPUT(b),
    `DECL_SVREAL_INPUT(c),
    `DECL_SVREAL_OUTPUT(d)
);

    `SVREAL_COPY_FORMAT(d, b_aligned);
    `SVREAL_COPY_FORMAT(d, c_aligned);
    
    `SVREAL_ASSIGN(b, b_aligned);
    `SVREAL_ASSIGN(c, c_aligned);
    
    assign `SVREAL_SIGNIFICAND(d) = (a == 1'b0) ? `SVREAL_SIGNIFICAND(b_aligned) : `SVREAL_SIGNIFICAND(c_aligned);

endmodule

// convert svreal to int

module svreal_to_int_mod #(
    `DECL_SVREAL_PARAMS(a),
    parameter integer width=1
) (
    `DECL_SVREAL_INPUT(a),
    output wire logic signed [(width-1):0] b
);

    `MAKE_SVREAL(a_aligned, width, 0);
    `SVREAL_ASSIGN(a, a_aligned);
    `ifndef SVREAL_DEBUG
        // normal operation
        assign b = `SVREAL_SIGNIFICAND(a_aligned);
    `else
        // debug operation
        assign b = integer'(`SVREAL_SIGNIFICAND(a_aligned));
    `endif

endmodule

// convert int to svreal

module int_to_svreal_mod #(
    parameter integer width=1,
    `DECL_SVREAL_PARAMS(b)
) (
    input wire logic signed [(width-1):0] a,
    `DECL_SVREAL_OUTPUT(b)
);

    `MAKE_SVREAL(a_aligned, width, 0);   
    `ifndef SVREAL_DEBUG
        // normal operation
        assign `SVREAL_SIGNIFICAND(a_aligned) = a;
    `else
        // debug operation
        assign `SVREAL_SIGNIFICAND(a_aligned) = 1.0*a;
    `endif
    `SVREAL_ASSIGN(a_aligned, b);

endmodule

// memory

module svreal_dff_mod #(
    `DECL_SVREAL_PARAMS(d),
    `DECL_SVREAL_PARAMS(q),
    `DECL_SVREAL_PARAMS(init)
) (
    `DECL_SVREAL_INPUT(d),
    `DECL_SVREAL_OUTPUT(q),
    `DECL_SVREAL_INPUT(init),
    input wire logic rst,
    input wire logic clk,
    input wire logic cke
);

    // align input to output
    `SVREAL_COPY_FORMAT(q, d_aligned);
    `SVREAL_ASSIGN(d, d_aligned);
    
    // align initial value to output format
    `SVREAL_COPY_FORMAT(q, init_aligned);
    `SVREAL_ASSIGN(init, init_aligned);
    
    // main DFF logic
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            `SVREAL_SIGNIFICAND(q) <= `SVREAL_SIGNIFICAND(init_aligned);
        end else if (cke == 1'b1) begin
            `SVREAL_SIGNIFICAND(q) <= `SVREAL_SIGNIFICAND(d_aligned);
        end else begin
            `SVREAL_SIGNIFICAND(q) <= `SVREAL_SIGNIFICAND(q);
        end
    end       

endmodule

`endif // `ifndef __SVREAL_SV__
