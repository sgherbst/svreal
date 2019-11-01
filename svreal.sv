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

`define SVREAL_EXPONENT(name) \
    ``name``_exponent

`define SVREAL_EXPONENT_WIDTH 16

`define SVREAL_EXPONENT_TYPE \
    logic signed [((`SVREAL_EXPONENT_WIDTH)-1):0]

`define SVREAL_MIN_EXPONENT(a, b) \
    `SVREAL_EXPR_MIN(`SVREAL_EXPONENT(``a``), `SVREAL_EXPONENT(``b``))

`define SVREAL_MAX_EXPONENT(a, b) \
    `SVREAL_EXPR_MAX(`SVREAL_EXPONENT(``a``), `SVREAL_EXPONENT(``b``))

// significand format

`define SVREAL_SIGNIFICAND(name) \
    ``name``_significand

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
    `SVREAL_SIGNIFICAND_TYPE(``width``) ``SVREAL_SIGNIFICAND(``name``); \
    `SVREAL_EXPONENT_TYPE ``SVREAL_EXPONENT(``name``) \
    `ifndef SVREAL_DEBUG \
        ; assign `SVREAL_EXPONENT(``name``) = ``exponent`` \
    `else \
        ; assign `SVREAL_EXPONENT(``name``) = 0 \
    `endif

`define SVREAL_COPY_FORMAT(in, out) \
    `MAKE_SVREAL(``out``, `SVREAL_SIGNIFICAND_WIDTH(``in``), `SVREAL_EXPONENT(``in``))

`define SVREAL_SIGNIFICAND_WIDTH_PARAM(name) \
    `SVREAL_SIGNIFICAND(``name``)_width

`define PASS_SVREAL_PARAMS(internal_name, external_name) \
    .`SVREAL_SIGNIFICAND_WIDTH_PARAM(``internal_name``)(`SVREAL_SIGNIFICAND_WIDTH(``external_name``))

`define DECL_SVREAL_PARAMS(name) \
    parameter integer `SVREAL_SIGNIFICAND_WIDTH_PARAM(``name``)=-1

`define DECL_SVREAL_INPUT(name) \
    input `SVREAL_SIGNIFICAND_TYPE(`SVREAL_SIGNIFICAND_WIDTH_PARAM(``name``)) `SVREAL_SIGNIFICAND(``name``), \
    input `SVREAL_EXPONENT_TYPE `SVREAL_EXPONENT(``name``)

`define DECL_SVREAL_OUTPUT(pin_name) \
    output `SVREAL_SIGNIFICAND_TYPE(`SVREAL_SIGNIFICAND_WIDTH_PARAM(``name``)) `SVREAL_SIGNIFICAND(``name``), \
    input `SVREAL_EXPONENT_TYPE `SVREAL_EXPONENT(``name``)

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
    svreal_negate_mod #(
        `PASS_SVREAL_PARAMS(a, ``a_name``), \
        `PASS_SVREAL_PARAMS(b, ``b_name``) \
    ) ``b_name``_mod_i ( \
        `PASS_SVREAL_SIGNALS(a, ``a_name``), \
        `PASS_SVREAL_SIGNALS(b, ``b_name``) \
    )

// assign a constant to an svreal (either as a continuous assignment or within a testbench context)

`define SVREAL_SET(name, expr) \
    ``name`` = `FLOAT_TO_SVREAL(``expr``, ``name``)

// arithmetic functions

`define SVREAL_OPCODE_MUL 0
`define SVREAL_OPCODE_ADD 1
`define SVREAL_OPCODE_SUB 2
`define SVREAL_OPCODE_MIN 3
`define SVREAL_OPCODE_MAX 4

`define SVREAL_ARITH(opcode_expr, a_name, b_name, c_name) \
    svreal_arith_mod #( \
        .opcode(``opcode_expr``), \
        `PASS_SVREAL_PARAMS(a, ``a_name``), \
        `PASS_SVREAL_PARAMS(b, ``b_name``), \
        `PASS_SVREAL_PARAMS(c, ``c_name``) \
    ) ``c_name``_mod_i ( \
        `PASS_SVREAL_SIGNALS(a, ``a_name``), \
        `PASS_SVREAL_SIGNALS(b, ``b_name``), \
        `PASS_SVREAL_SIGNALS(c, ``c_name``) \
    )

`define SVREAL_MUL(a, b, c) `SVREAL_ARITH(`SVREAL_OPCODE_MUL, a, b, c)
`define SVREAL_ADD(a, b, c) `SVREAL_ARITH(`SVREAL_OPCODE_ADD, a, b, c)
`define SVREAL_SUB(a, b, c) `SVREAL_ARITH(`SVREAL_OPCODE_SUB, a, b, c)
`define SVREAL_MIN(a, b, c) `SVREAL_ARITH(`SVREAL_OPCODE_MIN, a, b, c)
`define SVREAL_MAX(a, b, c) `SVREAL_ARITH(`SVREAL_OPCODE_MAX, a, b, c)

// comparisons

`define SVREAL_COMP(opcode_expr, a_name, b_name, c_name) \
    svreal_comp_mod #( \
        .opcode(``opcode_expr``) \
        `PASS_SVREAL_PARAMS(a, ``a_name``), \
        `PASS_SVREAL_PARAMS(b, ``b_name``), \
        `PASS_SVREAL_PARAMS(c, ``c_name``) \
    ) ``c_name``_mod_i ( \
        `PASS_SVREAL_SIGNALS(a, ``a_name``), \
        `PASS_SVREAL_SIGNALS(b, ``b_name``), \
        `PASS_SVREAL_SIGNALS(c, ``c_name``) \
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
        `PASS_SVREAL_PARAMS(a, ``a_name``), \
        `PASS_SVREAL_PARAMS(b, ``b_name``), \
        `PASS_SVREAL_PARAMS(c, ``c_name``), \
        `PASS_SVREAL_PARAMS(d, ``d_name``) \
    ) ``d_name``_mod_i ( \
        `PASS_SVREAL_SIGNALS(a, ``a_name``), \
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

    generate
        `ifndef SVREAL_DEBUG
            assign `SVREAL_SIGNIFICAND(b) = `SVREAL_EXPR_LSHIFT(`SVREAL_SIGNIFICAND(a), `SVREAL_EXPONENT(a) - `SVREAL_EXPONENT(b));
        `else
            assign `SVREAL_SIGNIFICAND(b) = `SVREAL_SIGNIFICAND(a);
        `endif
    endgenerate

endmodule

// negate an svreal value

module svreal_negate_mod #(
    `DECL_SVREAL_PARAMS(a),
    `DECL_SVREAL_PARAMS(b)
) (
    `DECL_SVREAL_INPUT(a),
    `DECL_SVREAL_OUTPUT(b)
);

    generate
        // assign "a" directly into "b_neg", which has the same representation as "b"
        `SVREAL_COPY_FORMAT(b, b_neg);
        `SVREAL_ASSIGN(a, b_neg);
        
        // assign the negated "b_neg" signal into b.value
        assign `SVREAL_SIGNIFICAND(b) = -`SVREAL_SIGNIFICAND(b_neg);
    endgenerate

endmodule

// add two svreal numbers

module svreal_arith_mod #(
    `DECL_SVREAL_PARAMS(a),
    `DECL_SVREAL_PARAMS(b),
    `DECL_SVREAL_PARAMS(c),
    parameter integer opcode=0
) (
    `SVREAL_DECL_INPUT(a),
    `SVREAL_DECL_INPUT(b),
    `SVREAL_DECL_OUTPUT(c)
);

    generate
        if ((opcode == `SVREAL_OPCODE_ADD) || (opcode == `SVREAL_OPCODE_SUB)) begin
            `SVREAL_COPY_FORMAT(c, a_aligned);
            `SVREAL_COPY_FORMAT(c, b_aligned);
        
            `SVREAL_ASSIGN(a, a_aligned);
            `SVREAL_ASSIGN(b, b_aligned);
        
            if (opcode == `SVREAL_OPCODE_ADD) begin
                assign `SVREAL_SIGNIFICAND(c) = `SVREAL_SIGNIFICAND(a_aligned) + `SVREAL_SIGNIFICAND(b_aligned);
            end else if (opcode == `SVREAL_OPCODE_SUB) begin
                assign `SVREAL_SIGNIFICAND(c) = `SVREAL_SIGNIFICAND(a_aligned) - `SVREAL_SIGNIFICAND(b_aligned);
            end else begin
                `SVREAL_ERROR
            end
        end else if (opcode == `SVREAL_OPCODE_MUL) begin
            `MAKE_SVREAL(prod, `SVREAL_SIGNIFICAND_WIDTH(a) + `SVREAL_SIGNIFICAND_WIDTH(b), `SVREAL_EXPONENT(a) + `SVREAL_EXPONENT(b));
            assign `SVREAL_SIGNIFICAND(prod) = `SVREAL_SIGNIFICAND(a) * `SVREAL_SIGNIFICAND(b);
            `SVREAL_ASSIGN(prod, c);
        end else if ((opcode == `SVREAL_OPCODE_MIN) || (opcode == `SVREAL_OPCODE_MAX)) begin
            // mux between a and b
            logic sel;
            `SVREAL_MUX(sel, a, b, c);
    
            // selection logic depends on the opcode
            if          (opcode == `SVREAL_OPCODE_MIN) begin
                `SVREAL_LT(b, a, sel);
            end else if (opcode == `SVREAL_OPCODE_MAX) begin
                `SVREAL_GT(b, a, sel);
            end else begin
                `SVREAL_ERROR
            end
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
    `SVREAL_DECL_INPUT(a),
    `SVREAL_DECL_INPUT(b),
    output wire logic c
);

    generate
        // create the aligned representations
        `MAKE_SVREAL(a_aligned, `SVREAL_GET_WIDTH(a), `SVREAL_MAX_EXPONENT(a, b));
        `MAKE_SVREAL(a_aligned, `SVREAL_GET_WIDTH(b), `SVREAL_MAX_EXPONENT(a, b));
        `SVREAL_ASSIGN(a, a_aligned);
        `SVREAL_ASSIGN(b, b_aligned);

        // perform the desired comparison
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
    `SVREAL_DECL_INPUT(b),
    `SVREAL_DECL_INPUT(c),
    `SVREAL_DECL_OUTPUT(d)
);

    generate
        `SVREAL_COPY_FORMAT(d, b_aligned);
        `SVREAL_COPY_FORMAT(d, c_aligned);

        `SVREAL_ASSIGN(b, b_aligned);
        `SVREAL_ASSIGN(c, c_aligned);
        
        assign `SVREAL_SIGNIFICAND(d) = (a == 1'b0) ? `SVREAL_SIGNIFICAND(b_aligned) : `SVREAL_SIGNIFICAND(c_aligned);
    endgenerate

endmodule

// convert svreal to int

module svreal_to_int_mod #(
    `DECL_SVREAL_PARAMS(a),
    parameter integer width=1
) (
    `SVREAL_DECL_INPUT(a),
    output wire logic signed [(width-1):0] b
);

    generate
        `MAKE_SVREAL(a_aligned, width, 0);
        `SVREAL_ASSIGN(a, a_aligned);
        `ifndef SVREAL_DEBUG
            // normal operation
            assign b = `SVREAL_SIGNIFICAND(a_aligned);
        `else
            // debug operation
            assign b = integer'(`SVREAL_SIGNIFICAND(a_aligned));
        `endif
    endgenerate

endmodule

// convert int to svreal

module int_to_svreal_mod #(
    parameter integer width=1,
    `DECL_SVREAL_PARAMS(b)
) (
    input wire logic signed [(width-1):0] a,
    `SVREAL_DECL_OUTPUT(b)
);

    generate
        `MAKE_SVREAL(a_aligned, width, 0);   
        `ifndef SVREAL_DEBUG
            // normal operation
            assign `SVREAL_SIGNIFICAND(a_aligned) = a;
        `else
            // debug operation
            assign `SVREAL_SIGNIFICAND(a_aligned) = 1.0*a;
        `endif
        `SVREAL_ASSIGN(a_aligned, b);
    endgenerate

endmodule

// memory

module svreal_dff_mod #(
    `DECL_SVREAL_PARAMS(d),
    `DECL_SVREAL_PARAMS(q),
    `DECL_SVREAL_PARAMS(init)
) (
    `SVREAL_DECL_INPUT(d),
    `SVREAL_DECL_OUTPUT(q),
    `SVREAL_DECL_INPUT(init),
    input wire logic rst,
    input wire logic clk,
    input wire logic cke
);

    generate
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
    endgenerate

endmodule

`endif // `ifndef __SVREAL_SV__
