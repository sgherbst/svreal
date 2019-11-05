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

`define SVREAL_SIGNIFICAND_WIDTH(name) ``name``_significand_width

`define FLOAT_TO_FIXED(float_val, exponent) \
     ((1.0*(``float_val``))*((2.0)**(-(``exponent``))))

`define FIXED_TO_FLOAT(fixed_val, exponent) \
     ((1.0*(``fixed_val``))*((2.0)**(+(``exponent``))))

`define SVREAL_TO_FLOAT(name) \
    `ifndef SVREAL_DEBUG \
        `FIXED_TO_FLOAT(`SVREAL_SIGNIFICAND(``name``), `SVREAL_EXPONENT(``name``)) \
    `else \
        `SVREAL_SIGNIFICAND(``name``) \
    `endif

`define FLOAT_TO_SVREAL(value, name) \
    `ifndef SVREAL_DEBUG \
        `FLOAT_TO_FIXED(``value``, `SVREAL_EXPONENT(``name``)) \
    `else \
        ``value`` \
    `endif

// macro to print svreal numbers

`define SVREAL_PRINT(name) \
    $display(`"``name``=%0f`", `SVREAL_TO_FLOAT(``name``))

// macro to create svreal numbers conveniently

`define DECL_SVREAL_TYPE(name, width) \
    `SVREAL_SIGNIFICAND_TYPE(``width``) `SVREAL_SIGNIFICAND(``name``); \
    `SVREAL_EXPONENT_TYPE `SVREAL_EXPONENT(``name``)

`define MAKE_SVREAL(name, width, exponent) \
    `DECL_SVREAL_TYPE(``name``, ``width``); \
    localparam integer `SVREAL_SIGNIFICAND_WIDTH(``name``) = ``width``; \
    assign `SVREAL_EXPONENT(``name``) = ``exponent``

`define SVREAL_COPY_FORMAT(in, out) \
    `MAKE_SVREAL(``out``, `SVREAL_SIGNIFICAND_WIDTH(``in``), `SVREAL_EXPONENT(``in``))

`define PASS_SVREAL_PARAMS(internal_name, external_name) \
    .`SVREAL_SIGNIFICAND_WIDTH(``internal_name``)(`SVREAL_SIGNIFICAND_WIDTH(``external_name``))

`define DECL_SVREAL_PARAMS(name) \
    parameter integer `SVREAL_SIGNIFICAND_WIDTH(``name``) = -1

`define DECL_SVREAL_INPUT(name) \
    input `SVREAL_SIGNIFICAND_TYPE(`SVREAL_SIGNIFICAND_WIDTH(``name``)) `SVREAL_SIGNIFICAND(``name``), \
    input `SVREAL_EXPONENT_TYPE `SVREAL_EXPONENT(``name``)

`define DECL_SVREAL_OUTPUT(name) \
    output `SVREAL_SIGNIFICAND_TYPE(`SVREAL_SIGNIFICAND_WIDTH(``name``)) `SVREAL_SIGNIFICAND(``name``), \
    input `SVREAL_EXPONENT_TYPE `SVREAL_EXPONENT(``name``)

`define PASS_SVREAL_SIGNALS(internal_name, external_name) \
    .`SVREAL_SIGNIFICAND(``internal_name``)(`SVREAL_SIGNIFICAND(``external_name``)), \
    .`SVREAL_EXPONENT(``internal_name``)(`SVREAL_EXPONENT(``external_name``)) \

// macros for working with svreal types in interfaces

`define SVREAL_MODPORT_IN(name) \
    input `SVREAL_SIGNIFICAND(``name``), \
    input `SVREAL_EXPONENT(``name``)

`define SVREAL_MODPORT_OUT(name) \
    output `SVREAL_SIGNIFICAND(``name``), \
    input `SVREAL_EXPONENT(``name``)

`define SVREAL_ALIAS_FORMAT(port_name, local_name) \
    `ifndef SVREAL_DEBUG \
        `MAKE_SVREAL(local_name, $size(`SVREAL_SIGNIFICAND(``port_name``)), `SVREAL_EXPONENT(``port_name``)); \
    `else \
        `MAKE_SVREAL(local_name, -1, `SVREAL_EXPONENT(``port_name``)); \
    `endif

`define SVREAL_ALIAS_INPUT(port_name, local_name) \
    `SVREAL_ALIAS_FORMAT(``port_name``, ``local_name``); \
    assign `SVREAL_SIGNIFICAND(``local_name``) = `SVREAL_SIGNIFICAND(``port_name``)

`define SVREAL_ALIAS_OUTPUT(port_name, local_name) \
    `SVREAL_ALIAS_FORMAT(``port_name``, ``local_name``); \
    assign `SVREAL_SIGNIFICAND(``port_name``) = `SVREAL_SIGNIFICAND(``local_name``)

// as a convenience, an implementation of an interface with one svreal value is provided
// this could also serve as a reference for more complex interfaces including multiple
// svreals and other signals

interface svreal #(
    `DECL_SVREAL_PARAMS(value)
);
    `DECL_SVREAL_TYPE(value, `SVREAL_SIGNIFICAND_WIDTH(value));
    modport in (
        `SVREAL_MODPORT_IN(value)
    );
    modport out (
        `SVREAL_MODPORT_OUT(value)
    );
endinterface

`define MAKE_SVREAL_INTF(name, value_width_expr, value_exponent_expr) \
    svreal #( \
        .`SVREAL_SIGNIFICAND_WIDTH(value)(``value_width_expr``) \
    ) ``name`` (); \
    assign `SVREAL_EXPONENT(``name``.value) = ``value_exponent_expr`` \

// assign one svreal to another

`define SVREAL_NAMED_ASSIGN(in_name, out_name, inst_name) \
    svreal_assign_mod #( \
        `PASS_SVREAL_PARAMS(in, ``in_name``), \
        `PASS_SVREAL_PARAMS(out, ``out_name``) \
    ) ``inst_name`` ( \
        `PASS_SVREAL_SIGNALS(in, ``in_name``), \
        `PASS_SVREAL_SIGNALS(out, ``out_name``) \
    )

`define SVREAL_ASSIGN(in_name, out_name) \
    `SVREAL_NAMED_ASSIGN(in_name, out_name, ``out_name``_assign_i)

// negate an svreal

`define SVREAL_NAMED_NEGATE(in_name, out_name, inst_name) \
    svreal_negate_mod #( \
        `PASS_SVREAL_PARAMS(in, ``in_name``), \
        `PASS_SVREAL_PARAMS(out, ``out_name``) \
    ) ``inst_name`` ( \
        `PASS_SVREAL_SIGNALS(in, ``in_name``), \
        `PASS_SVREAL_SIGNALS(out, ``out_name``) \
    )

`define SVREAL_NEGATE(in_name, out_name) \
    `SVREAL_NAMED_NEGATE(in_name, out_name, ``out_name``_negate_i)

// assign a constant to an svreal (either as a continuous assignment or within a testbench context)

`define SVREAL_SET(name, expr) \
    `SVREAL_SIGNIFICAND(``name``) = `FLOAT_TO_SVREAL(``expr``, ``name``)

// add/sub

`define SVREAL_OPCODE_ADD 0
`define SVREAL_OPCODE_SUB 1

`define SVREAL_NAMED_ADDSUB(opcode_expr, a_name, b_name, c_name, inst_name) \
    svreal_addsub_mod #( \
        .opcode(``opcode_expr``), \
        `PASS_SVREAL_PARAMS(a, ``a_name``), \
        `PASS_SVREAL_PARAMS(b, ``b_name``), \
        `PASS_SVREAL_PARAMS(c, ``c_name``) \
    ) ``inst_name`` ( \
        `PASS_SVREAL_SIGNALS(a, ``a_name``), \
        `PASS_SVREAL_SIGNALS(b, ``b_name``), \
        `PASS_SVREAL_SIGNALS(c, ``c_name``) \
    )

`define SVREAL_NAMED_ADD(a, b, c, inst_name) \
    `SVREAL_NAMED_ADDSUB(`SVREAL_OPCODE_ADD, a, b, c, inst_name)

`define SVREAL_ADD(a, b, c) \
    `SVREAL_NAMED_ADD(a, b, c, ``c``_add_i)

`define SVREAL_NAMED_SUB(a, b, c, inst_name) \
    `SVREAL_NAMED_ADDSUB(`SVREAL_OPCODE_SUB, a, b, c, inst_name)

`define SVREAL_SUB(a, b, c) \
    `SVREAL_NAMED_SUB(a, b, c, ``c``_sub_i)

// mul

`define SVREAL_NAMED_MUL(a_name, b_name, c_name, inst_name) \
    svreal_mul_mod #( \
        `PASS_SVREAL_PARAMS(a, ``a_name``), \
        `PASS_SVREAL_PARAMS(b, ``b_name``), \
        `PASS_SVREAL_PARAMS(c, ``c_name``) \
    ) ``inst_name`` ( \
        `PASS_SVREAL_SIGNALS(a, ``a_name``), \
        `PASS_SVREAL_SIGNALS(b, ``b_name``), \
        `PASS_SVREAL_SIGNALS(c, ``c_name``) \
    )

`define SVREAL_MUL(a, b, c) \
    `SVREAL_NAMED_MUL(a, b, c, ``c``_mul_i)

// min/max

`define SVREAL_OPCODE_MIN 0
`define SVREAL_OPCODE_MAX 1

`define SVREAL_NAMED_MINMAX(opcode_expr, a_name, b_name, c_name, inst_name) \
    svreal_minmax_mod #( \
        .opcode(``opcode_expr``), \
        `PASS_SVREAL_PARAMS(a, ``a_name``), \
        `PASS_SVREAL_PARAMS(b, ``b_name``), \
        `PASS_SVREAL_PARAMS(c, ``c_name``) \
    ) ``inst_name`` ( \
        `PASS_SVREAL_SIGNALS(a, ``a_name``), \
        `PASS_SVREAL_SIGNALS(b, ``b_name``), \
        `PASS_SVREAL_SIGNALS(c, ``c_name``) \
    )

`define SVREAL_NAMED_MIN(a, b, c, inst_name) \
    `SVREAL_NAMED_MINMAX(`SVREAL_OPCODE_MIN, a, b, c, inst_name)

`define SVREAL_MIN(a, b, c) \
    `SVREAL_NAMED_MIN(a, b, c, ``c``_min_i)

`define SVREAL_NAMED_MAX(a, b, c, inst_name) \
    `SVREAL_NAMED_MINMAX(`SVREAL_OPCODE_MAX, a, b, c, inst_name)

`define SVREAL_MAX(a, b, c) \
    `SVREAL_NAMED_MAX(a, b, c, ``c``_max_i)

// comparisons

`define SVREAL_NAMED_COMP(opcode_expr, a_name, b_name, c_name, inst_name) \
    svreal_comp_mod #( \
        .opcode(``opcode_expr``), \
        `PASS_SVREAL_PARAMS(a, ``a_name``), \
        `PASS_SVREAL_PARAMS(b, ``b_name``) \
    ) ``inst_name`` ( \
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

`define SVREAL_NAMED_GT(a, b, c, inst_name) \
    `SVREAL_NAMED_COMP(`SVREAL_OPCODE_GT, a, b, c, inst_name)

`define SVREAL_GT(a, b, c) \
    `SVREAL_NAMED_GT(a, b, c, ``c``_gt_i)

`define SVREAL_NAMED_GE(a, b, c, inst_name) \
    `SVREAL_NAMED_COMP(`SVREAL_OPCODE_GE, a, b, c, inst_name)

`define SVREAL_GE(a, b, c) \
    `SVREAL_NAMED_GE(a, b, c, ``c``_ge_i)

`define SVREAL_NAMED_LT(a, b, c, inst_name) \
    `SVREAL_NAMED_COMP(`SVREAL_OPCODE_LT, a, b, c, inst_name)

`define SVREAL_LT(a, b, c) \
    `SVREAL_NAMED_LT(a, b, c, ``c``_lt_i)

`define SVREAL_NAMED_LE(a, b, c, inst_name) \
    `SVREAL_NAMED_COMP(`SVREAL_OPCODE_LE, a, b, c, inst_name)

`define SVREAL_LE(a, b, c) \
    `SVREAL_NAMED_LE(a, b, c, ``c``_le_i)

`define SVREAL_NAMED_EQ(a, b, c, inst_name) \
    `SVREAL_NAMED_COMP(`SVREAL_OPCODE_EQ, a, b, c, inst_name)

`define SVREAL_EQ(a, b, c) \
    `SVREAL_NAMED_EQ(a, b, c, ``c``_eq_i)

`define SVREAL_NAMED_NE(a, b, c, inst_name) \
    `SVREAL_NAMED_COMP(`SVREAL_OPCODE_NE, a, b, c, inst_name)

`define SVREAL_NE(a, b, c) \
    `SVREAL_NAMED_NE(a, b, c, ``c``_ne_i)

// multiplex between two values

`define SVREAL_NAMED_MUX(sel_name, in0_name, in1_name, out_name, inst_name) \
    svreal_mux_mod #( \
        `PASS_SVREAL_PARAMS(in0, ``in0_name``), \
        `PASS_SVREAL_PARAMS(in1, ``in1_name``), \
        `PASS_SVREAL_PARAMS(out, ``out_name``) \
    ) ``inst_name`` ( \
        .sel(``sel_name``), \
        `PASS_SVREAL_SIGNALS(in0, ``in0_name``), \
        `PASS_SVREAL_SIGNALS(in1, ``in1_name``), \
        `PASS_SVREAL_SIGNALS(out, ``out_name``) \
    )

`define SVREAL_MUX(sel_name, in0_name, in1_name, out_name) \
    `SVREAL_NAMED_MUX(sel_name, in0_name, in1_name, out_name, ``out_name``_mux_i)

// conversion between integer and svreal

`define SVREAL_TO_INT_NAMED(in_name, out_name, out_width_expr, inst_name) \
    svreal_to_int_mod #( \
        `PASS_SVREAL_PARAMS(in, ``in_name``), \
        .out_width(``out_width_expr``) \
    ) ``inst_name`` ( \
        `PASS_SVREAL_SIGNALS(in, ``in_name``), \
        .out(``out_name``) \
    )

`define SVREAL_TO_INT(in_name, out_name, out_width_expr) \
    `SVREAL_TO_INT_NAMED(``in_name``, ``out_name``, ``out_width_expr``, ``out_name``_r2i_i)

`define INT_TO_SVREAL_NAMED(in_name, out_name, in_width_expr, inst_name) \
    int_to_svreal_mod #( \
        .in_width(``in_width_expr``), \
        `PASS_SVREAL_PARAMS(out, ``out_name``) \
    ) ``inst_name`` ( \
        .in(``in_name``), \
        `PASS_SVREAL_SIGNALS(out, ``out_name``) \
    )

`define INT_TO_SVREAL(in_name, out_name, in_width_expr) \
    `INT_TO_SVREAL_NAMED(``in_name``, ``out_name``, ``in_width_expr``, ``out_name``_i2r_i)

// memory

`define SVREAL_NAMED_DFF(d_name, q_name, rst_name, clk_name, cke_name, init_name, inst_name) \
    svreal_dff_mod #( \
        `PASS_SVREAL_PARAMS(d, ``d_name``), \
        `PASS_SVREAL_PARAMS(q, ``q_name``), \
        `PASS_SVREAL_PARAMS(init, ``init_name``) \
    ) ``inst_name`` ( \
        `PASS_SVREAL_SIGNALS(d, ``d_name``), \
        `PASS_SVREAL_SIGNALS(q, ``q_name``), \
        `PASS_SVREAL_SIGNALS(init, ``init_name``), \
        .rst(``rst_name``), \
        .clk(``clk_name``), \
        .cke(``cke_name``) \
    )

`define SVREAL_DFF(d_name, q_name, rst_name, clk_name, cke_name, init_name) \
    `SVREAL_NAMED_DFF(d_name, q_name, rst_name, clk_name, cke_name, init_name, ``q_name``_dff_i)

// assign one svreal number to another

module svreal_assign_mod #(
    `DECL_SVREAL_PARAMS(in),
    `DECL_SVREAL_PARAMS(out)
) (
    `DECL_SVREAL_INPUT(in),
    `DECL_SVREAL_OUTPUT(out)
);
    `ifndef SVREAL_DEBUG
        `SVREAL_EXPONENT_TYPE lshift;
        assign lshift = `SVREAL_EXPONENT(in) - `SVREAL_EXPONENT(out);
        assign `SVREAL_SIGNIFICAND(out) = `SVREAL_EXPR_LSHIFT(`SVREAL_SIGNIFICAND(in), lshift);
    `else
        assign `SVREAL_SIGNIFICAND(out) = `SVREAL_SIGNIFICAND(in);
    `endif
endmodule

// negate an svreal value

module svreal_negate_mod #(
    `DECL_SVREAL_PARAMS(in),
    `DECL_SVREAL_PARAMS(out)
) (
    `DECL_SVREAL_INPUT(in),
    `DECL_SVREAL_OUTPUT(out)
);
    // assign "in" directly into "out_neg", which has the same representation as "out"
    `SVREAL_COPY_FORMAT(out, out_neg);
    `SVREAL_ASSIGN(in, out_neg);
    
    // assign the negated "out_neg" signal into out
    assign `SVREAL_SIGNIFICAND(out) = -`SVREAL_SIGNIFICAND(out_neg);
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
    
    // add or subtract "a" and "b"
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
    // determine the exponent of the intermediate result
    `SVREAL_EXPONENT_TYPE prod_exponent_value;
    assign prod_exponent_value = `SVREAL_EXPONENT(a) + `SVREAL_EXPONENT(b);
    
    // compute intermediate result
    `MAKE_SVREAL(prod, (`SVREAL_SIGNIFICAND_WIDTH(a) + `SVREAL_SIGNIFICAND_WIDTH(b)), prod_exponent_value);
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
    
    // pick either the larger or smaller of "a" and "b"
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
    // compute the maximum exponent of "a" and "b"
    `SVREAL_EXPONENT_TYPE max_exponent;
    assign max_exponent = `SVREAL_MAX_EXPONENT(a, b);
    
    // make a versions of "a" and "b" that are aligned to each other
    `MAKE_SVREAL(a_aligned, `SVREAL_SIGNIFICAND_WIDTH(a), max_exponent);
    `MAKE_SVREAL(b_aligned, `SVREAL_SIGNIFICAND_WIDTH(b), max_exponent);
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
    `DECL_SVREAL_PARAMS(in0),
    `DECL_SVREAL_PARAMS(in1),
    `DECL_SVREAL_PARAMS(out)
) (
    input wire logic sel,
    `DECL_SVREAL_INPUT(in0),
    `DECL_SVREAL_INPUT(in1),
    `DECL_SVREAL_OUTPUT(out)
);
    `SVREAL_COPY_FORMAT(out, in0_aligned);
    `SVREAL_COPY_FORMAT(out, in1_aligned);
    
    `SVREAL_ASSIGN(in0, in0_aligned);
    `SVREAL_ASSIGN(in1, in1_aligned);
    
    assign `SVREAL_SIGNIFICAND(out) = (sel == 1'b0) ? `SVREAL_SIGNIFICAND(in0_aligned) : `SVREAL_SIGNIFICAND(in1_aligned);
endmodule

// convert svreal to int

module svreal_to_int_mod #(
    `DECL_SVREAL_PARAMS(in),
    parameter integer out_width=1
) (
    `DECL_SVREAL_INPUT(in),
    output wire logic signed [(out_width-1):0] out
);
    `MAKE_SVREAL(in_aligned, out_width, 0);
    `SVREAL_ASSIGN(in, in_aligned);
    `ifndef SVREAL_DEBUG
        // normal operation
        assign out = `SVREAL_SIGNIFICAND(in_aligned);
    `else
        // debug operation
        assign out = integer'(`SVREAL_SIGNIFICAND(in_aligned));
    `endif
endmodule

// convert int to svreal

module int_to_svreal_mod #(
    parameter integer in_width=1,
    `DECL_SVREAL_PARAMS(out)
) (
    input wire logic signed [(in_width-1):0] in,
    `DECL_SVREAL_OUTPUT(out)
);
    `MAKE_SVREAL(in_aligned, in_width, 0);   
    `ifndef SVREAL_DEBUG
        // normal operation
        assign `SVREAL_SIGNIFICAND(in_aligned) = in;
    `else
        // debug operation
        assign `SVREAL_SIGNIFICAND(in_aligned) = 1.0*in;
    `endif
    `SVREAL_ASSIGN(in_aligned, out);
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
