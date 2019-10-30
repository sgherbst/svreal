`ifndef __SVREAL_SV__
`define __SVREAL_SV__

// math functions used to compute parameters

`define SVREAL_EXPR_MIN(a, b) \
    (((a) <= (b)) ? (a) : (b))

`define SVREAL_EXPR_MAX(a, b) \
    (((a) >= (b)) ? (a) : (b))

// interface used to represent fixed-point numbers

`define SVREAL_DEF_WIDTH(width_name, width_expr) \
    localparam integer ``width_name`` = ``width_expr``

`define SVREAL_GET_WIDTH(name) \
    $size(``name``.format)

`define SVREAL_DEF_EXPONENT(exp_name, exp_expr) \
    localparam integer ``exp_name`` = ``exp_expr``

`define SVREAL_GET_EXPONENT(name) \
    $low(``name``.format)

`define FLOAT_TO_FIXED(float_val, exponent) \
     ((1.0*``float_val``)*((2.0)**(-(``exponent``))))

`define FIXED_TO_FLOAT(fixed_val, exponent) \
     ((1.0*``fixed_val``)*((2.0)**(+(``exponent``))))

`define SVREAL_TO_FLOAT(svreal_name) \
    `ifndef SVREAL_DEBUG \
        `FIXED_TO_FLOAT(``svreal_name``.value, `SVREAL_GET_EXPONENT(``svreal_name``)) \
    `else \
        ``svreal_name``.value \
    `endif

interface svreal #(
    parameter integer width = 1,
    parameter integer exponent = 0
) (
    input logic signed [(width+exponent-1):exponent] format
);

     // represent real number as an integer or true float
     // depending on the debug mode
    `ifndef SVREAL_DEBUG
        logic signed [(width-1):0] value;
    `else
        real value;
    `endif

    modport in (input value, input format);
    modport out (output value, input format);

endinterface 

// macro to print svreal numbers

`define SVREAL_PRINT(name) \
    `ifndef SVREAL_DEBUG \
        $display(`"``name``=%0f\t{value=%0d, width=%0d, exponent=%0d}`", `SVREAL_TO_FLOAT(``name``), ``name``.value, `SVREAL_GET_WIDTH(``name``), `SVREAL_GET_EXPONENT(``name``)) \
    `else \
        $display(`"``name``=%0f\t{value=%0f, width=%0d, exponent=%0d}`", `SVREAL_TO_FLOAT(``name``), ``name``.value, `SVREAL_GET_WIDTH(``name``), `SVREAL_GET_EXPONENT(``name``)) \
    `endif

// macro to create svreal numbers conveniently

`define MAKE_SVREAL(name, width_expr, exponent_expr) \
    svreal #(.width(``width_expr``), .exponent(``exponent_expr``)) ``name`` (.format(0))

// assign one svreal to another

`define SVREAL_ASSIGN(a_name, b_name) \
    svreal_assign_mod ``b_name``_mod_i ( \
        .a(``a_name``), \
        .b(``b_name``) \
    )

// negate an svreal

`define SVREAL_NEGATE(a_name, b_name) \
    svreal_negate_mod ``b_name``_mod_i ( \
        .a(``a_name``), \
        .b(``b_name``) \
    )

// assign a constant to an svreal (either as a continuous assignment or within a testbench context)

`define SVREAL_SET(name, const_expr) \
    `ifndef SVREAL_DEBUG \
        ``name``.value = `FLOAT_TO_FIXED(``const_expr``, `SVREAL_GET_EXPONENT(``name``)) \
    `else \
        ``name``.value = ``const_expr`` \
    `endif

`define SVREAL_ASSIGN_CONST(name, const_expr) \
    assign `SVREAL_SET(name, const_expr)

// arithmetic functions

`define SVREAL_OPCODE_MUL 0
`define SVREAL_OPCODE_ADD 1
`define SVREAL_OPCODE_SUB 2

`define SVREAL_ARITH(opcode_expr, a_name, b_name, c_name) \
    svreal_arith_mod #( \
        .opcode(``opcode_expr``) \
    ) ``c_name``_mod_i ( \
        .a(``a_name``), \
        .b(``b_name``), \
        .c(``c_name``) \
    )

`define SVREAL_MUL(a, b, c) `SVREAL_ARITH(`SVREAL_OPCODE_MUL, a, b, c)
`define SVREAL_ADD(a, b, c) `SVREAL_ARITH(`SVREAL_OPCODE_ADD, a, b, c)
`define SVREAL_SUB(a, b, c) `SVREAL_ARITH(`SVREAL_OPCODE_SUB, a, b, c)

// comparisons

`define SVREAL_COMP(opcode_expr, a_name, b_name, c_name) \
    svreal_comp_mod #( \
        .opcode(``opcode_expr``) \
    ) ``c_name``_mod_i ( \
        .a(``a_name``), \
        .b(``b_name``), \
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
    svreal_mux_mod ``d_name``_mod_i ( \
        .a(``a_name``), \
        .b(``b_name``), \
        .c(``c_name``), \
        .d(``d_name``) \
    )

// pick min/max of two values

`define SVREAL_OPCODE_MIN 0
`define SVREAL_OPCODE_MAX 1

`define SVREAL_EXTREMA(opcode_expr, a_name, b_name, c_name) \
    svreal_extrema_mod #( \
        .opcode(``opcode_expr``) \
    ) ``c_name``_mod_i ( \
        .a(``a_name``), \
        .b(``b_name``), \
        .c(``c_name``) \
    )

`define SVREAL_MIN(a, b, c) `SVREAL_EXTREMA(`SVREAL_OPCODE_MIN, a, b, c)
`define SVREAL_MAX(a, b, c) `SVREAL_EXTREMA(`SVREAL_OPCODE_MAX, a, b, c)

// conversion between integer and svreal

`define SVREAL_TO_INT(a_name, b_name) \
    svreal_to_int_mod #( \
        .width($size(``b_name``)) \
    ) ``b_name``_mod_i ( \
        .a(``a_name``), \
        .b(``b_name``) \
    )

`define INT_TO_SVREAL(a_name, b_name) \
    int_to_svreal_mod #( \
        .width($size(``a_name``)) \
    ) ``b_name``_mod_i ( \
        .a(``a_name``), \
        .b(``b_name``) \
    )

// memory

`define SVREAL_DFF(d_name, q_name, rst_name, clk_name, en_name, init_expr) \
    svreal_dff_mod #( \
        .init(``init_expr``) \
    ) ``q_name``_mod_i ( \
        .d(``d_name``), \
        .q(``q_name``), \
        .rst(``rst_name``), \
        .clk(``clk_name``), \
        .en(``en_name``) \
    );

// assign one svreal number to another

module svreal_assign_mod (
    svreal.in a,
    svreal.out b
);

    generate
        `ifndef SVREAL_DEBUG
            // normal operation
            `SVREAL_DEF_EXPONENT(lshift, `SVREAL_GET_EXPONENT(a) - `SVREAL_GET_EXPONENT(b));
            assign b.value = (lshift >= 0) ? (a.value <<< (+lshift)) : (a.value >>> (-lshift));
        `else
            // assign real value straight through
            assign b.value = a.value;
            // check that the value of a is within the range that can be represented by b
            real b_min_float, b_max_float;
            always @(a.value) begin
                if (^b.exponent !== 1'bX) begin
                    b_min_float = `FIXED_TO_FLOAT(-(2.0**(b.width-1))-0, b.exponent);
                    b_max_float = `FIXED_TO_FLOAT(+(2.0**(b.width-1))-1, b.exponent);
                    if (!((b_min_float <= a.value) && (a.value <= b_max_float))) begin
                        $display("Real number %0f outside of allowed range [%0f, %0f].", a.value, b_min_float, b_max_float);
                        $fatal;
                    end
                end
            end
        `endif
    endgenerate

endmodule

// negate an svreal value

module svreal_negate_mod (
    svreal.in a,
    svreal.out b
);

    generate
        // assign "a" directly into "b_neg", which has the same representation as "b"
        `SVREAL_DEF_WIDTH(b_width, `SVREAL_GET_WIDTH(b));
        `SVREAL_DEF_EXPONENT(b_exponent, `SVREAL_GET_EXPONENT(b));
        
        `MAKE_SVREAL(b_neg, b_width, b_exponent);
        `SVREAL_ASSIGN(a, b_neg);
        
        // assign the negated "b_neg" signal into b.value
        assign b.value = -b_neg.value;
    endgenerate

endmodule

// add two svreal numbers

module svreal_arith_mod #(
    parameter integer opcode=0
) (
    svreal.in a,
    svreal.in b,
    svreal.out c
);

    generate
        if ((opcode == `SVREAL_OPCODE_ADD) || (opcode == `SVREAL_OPCODE_SUB)) begin
            `SVREAL_DEF_WIDTH(c_width, `SVREAL_GET_WIDTH(c));
            `SVREAL_DEF_EXPONENT(c_exponent, `SVREAL_GET_EXPONENT(c));
        
            `MAKE_SVREAL(a_aligned, c_width, c_exponent);
            `MAKE_SVREAL(b_aligned, c_width, c_exponent);
        
            `SVREAL_ASSIGN(a, a_aligned);
            `SVREAL_ASSIGN(b, b_aligned);
        
            if (opcode == `SVREAL_OPCODE_ADD) begin
                assign c.value = a_aligned.value + b_aligned.value;
            end else if (opcode == `SVREAL_OPCODE_SUB) begin
                assign c.value = a_aligned.value - b_aligned.value;
            end else begin
                initial begin
                    $display("ERROR: Invalid arithmetic opcode: %0d.", opcode);
                    $fatal;
                end
            end
        end else if (opcode == `SVREAL_OPCODE_MUL) begin
            `SVREAL_DEF_WIDTH(prod_width, `SVREAL_GET_WIDTH(a) + `SVREAL_GET_WIDTH(b));
            `SVREAL_DEF_EXPONENT(prod_exponent, `SVREAL_GET_EXPONENT(a) + `SVREAL_GET_EXPONENT(b));
            `MAKE_SVREAL(prod, prod_width, prod_exponent);
            assign prod.value = a.value * b.value;
            `SVREAL_ASSIGN(prod, c);
        end else begin
            initial begin
                $display("ERROR: Invalid arithmetic opcode: %0d.", opcode);
                $fatal;
            end
        end
    endgenerate
                
endmodule

// compare two svreal numbers

module svreal_comp_mod #(
    parameter integer opcode=0
) (
    svreal.in a,
    svreal.in b,
    output wire logic c
);

    generate
        // compute representation of aligned numbers
        `SVREAL_DEF_WIDTH(a_width, `SVREAL_GET_WIDTH(a));
        `SVREAL_DEF_WIDTH(b_width, `SVREAL_GET_WIDTH(b));
        `SVREAL_DEF_EXPONENT(exponent, `SVREAL_EXPR_MAX(`SVREAL_GET_EXPONENT(a), `SVREAL_GET_EXPONENT(b)));

        // create the aligned representations
        `MAKE_SVREAL(a_aligned, a_width, exponent);
        `MAKE_SVREAL(b_aligned, b_width, exponent);
        `SVREAL_ASSIGN(a, a_aligned);
        `SVREAL_ASSIGN(b, b_aligned);

        // perform the desired comparison
        if          (opcode == `SVREAL_OPCODE_GT) begin
            assign c = (a_aligned.value >  b_aligned.value) ? 1'b1 : 1'b0;
        end else if (opcode == `SVREAL_OPCODE_GE) begin
            assign c = (a_aligned.value >= b_aligned.value) ? 1'b1 : 1'b0;
        end else if (opcode == `SVREAL_OPCODE_LT) begin
            assign c = (a_aligned.value <  b_aligned.value) ? 1'b1 : 1'b0;
        end else if (opcode == `SVREAL_OPCODE_LE) begin
            assign c = (a_aligned.value <= b_aligned.value) ? 1'b1 : 1'b0;
        end else if (opcode == `SVREAL_OPCODE_EQ) begin
            assign c = (a_aligned.value == b_aligned.value) ? 1'b1 : 1'b0;
        end else if (opcode == `SVREAL_OPCODE_NE) begin
            assign c = (a_aligned.value != b_aligned.value) ? 1'b1 : 1'b0;
        end else begin
            initial begin
                $display("ERROR: Invalid comparison opcode: %0d.", opcode);
                $fatal;
            end
        end
    endgenerate
                        
endmodule

// multiplex between two values

module svreal_mux_mod (
    input wire logic a,
    svreal.in b,
    svreal.in c,
    svreal.out d
);

    generate
        `SVREAL_DEF_WIDTH(d_width, `SVREAL_GET_WIDTH(d));
        `SVREAL_DEF_EXPONENT(d_exponent, `SVREAL_GET_EXPONENT(d));
        
        `MAKE_SVREAL(b_aligned, d_width, d_exponent);
        `MAKE_SVREAL(c_aligned, d_width, d_exponent);
        
        `SVREAL_ASSIGN(b, b_aligned);
        `SVREAL_ASSIGN(c, c_aligned);
        
        assign d.value = (a == 1'b0) ? b_aligned.value : c_aligned.value;
    endgenerate

endmodule

// convert svreal to int

module svreal_to_int_mod #(
    parameter integer width=1
) (
    svreal.in a,
    output wire logic signed [(width-1):0] b
);

    generate
        `MAKE_SVREAL(a_aligned, width, 0);
        `SVREAL_ASSIGN(a, a_aligned);
        `ifndef SVREAL_DEBUG
            // normal operation
            assign b = a_aligned.value;
        `else
            // debug operation
            assign b = integer'(a_aligned.value);
        `endif
    endgenerate

endmodule

// convert int to svreal

module int_to_svreal_mod #(
    parameter integer width=1
) (
    input wire logic signed [(width-1):0] a,
    svreal.out b
);

    generate
        `MAKE_SVREAL(a_aligned, width, 0);   
        `ifndef SVREAL_DEBUG
            // normal operation
            assign a_aligned.value = a;
        `else
            // debug operation
            assign a_aligned.value = 1.0*a;
        `endif
        `SVREAL_ASSIGN(a_aligned, b);
    endgenerate

endmodule

// min/max operations

module svreal_extrema_mod #(
    parameter integer opcode=0
) (
    svreal.in a,
    svreal.in b,
    svreal.out c
);

    generate
        // mux between a and b
        logic sel;
        `SVREAL_MUX(sel, a, b, c);

        // selection logic depends on the opcode
        if          (opcode == `SVREAL_OPCODE_MIN) begin
            `SVREAL_LT(b, a, sel);
        end else if (opcode == `SVREAL_OPCODE_MAX) begin
            `SVREAL_GT(b, a, sel);
        end else begin
            initial begin
                $display("ERROR: Invalid extrema opcode: %0d.", opcode);
                $fatal;
            end
        end
    endgenerate

endmodule

// memory

module svreal_dff_mod #(
    parameter real init=0
) (
    svreal.in d,
    svreal.out q,
    input wire logic rst,
    input wire logic clk,
    input wire logic en
);

    generate
        // get formatting info for the output
        `SVREAL_DEF_WIDTH(q_width, `SVREAL_GET_WIDTH(q));
        `SVREAL_DEF_EXPONENT(q_exponent, `SVREAL_GET_EXPONENT(q));
        
        // align input to output
        `MAKE_SVREAL(d_aligned, q_width, q_exponent);
        `SVREAL_ASSIGN(d, d_aligned);

        // align initial value to output format
        `MAKE_SVREAL(init_wire, q_width, q_exponent);
        `SVREAL_ASSIGN_CONST(init_wire, init);

        // main DFF logic
        always @(posedge clk) begin
            if (rst == 1'b1) begin
                q.value <= init_wire.value;
            end else if (en == 1'b1) begin
                q.value <= d_aligned.value;
            end else begin
                q.value <= q.value;
            end
        end       
    endgenerate

endmodule

`endif // `ifndef __SVREAL_SV__
