`ifndef __SVREAL_SV__
`define __SVREAL_SV__

// math functions used to compute parameters

`define SVREAL_PARAM_MIN(a, b) \
    (((a) <= (b)) ? (a) : (b))

`define SVREAL_PARAM_MAX(a, b) \
    (((a) >= (b)) ? (a) : (b))

// interface used to represent fixed-point numbers

interface svreal #(
    parameter integer width = 1,
    parameter integer exponent = 1
);

    `ifndef SVREAL_DEBUG
        // normal operation
        logic signed [(width-1):0] value;
        function real to_float();
            to_float = (1.0*value)*((2.0)**(exponent));
        endfunction
        function integer to_fixed(input real x);
            to_fixed = (1.0*x)*((2.0)**(-exponent));
        endfunction
    `else
        // debug operation
        real value;
        function real to_float();
            to_float = value;
        endfunction
        function integer to_fixed(input real x);
            to_fixed = x;
        endfunction
    `endif

    // compute bounds of the representation
    function real min_float();
        min_float = -(2.0**(width-1))*(2.0**(exponent));
    endfunction
    function real max_float();
        max_float = ((2.0**(width-1))-1)*(2.0**(exponent));
    endfunction

    // modport definition
    modport in (input value);
    modport out (output value);

endinterface 

// macro to print svreal numbers

`define SVREAL_PRINT(name) $display(`"``name``=%0f`", ``name``.to_float())

// macro to create svreal numbers conveniently

`define MAKE_SVREAL(name, width_expr, exponent_expr) \
    svreal #(.width(``width_expr``), .exponent(``exponent_expr``)) ``name`` ()

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
    ``name``.value = ``name``.to_fixed(const_expr)

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

`define SVREAL_TO_INT(a, b) \
    svreal_to_int_mod #( \
        .width($bits(``b``)) \
    ) ``b``_mod_i ( \
        .a(a), \
        .b(b) \
    )

`define INT_TO_SVREAL(a, b) \
    int_to_svreal_mod #( \
        .width($bits(``a``)) \
    ) ``b``_mod_i ( \
        .a(a), \
        .b(b) \
    )

// assign one svreal number to another

module svreal_assign_mod (
    svreal.in a,
    svreal.out b
);

    generate
        `ifndef SVREAL_DEBUG
            // normal operation
            localparam integer lshift = a.exponent - b.exponent;
            if (lshift >= 0) begin
                assign b.value = a.value <<< (+lshift);
            end else begin
                assign b.value = a.value >>> (-lshift);
            end
        `else
            // debug operation includes a range check
            assign b.value = a.value;
            always @(a.value) begin
                if (!((b.min_float() <= a.to_float()) && (a.to_float() <= b.max_float()))) begin
                    $display("Real number %0f outside of allowed range [%0f, %0f].", a.to_float(), b.min_float(), b.max_float());
                    $fatal;
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
        localparam integer b_width = b.width;
        localparam integer b_exponent = b.exponent;
        
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
            localparam integer c_width = c.width;
            localparam integer c_exponent = c.exponent;
        
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
            localparam integer prod_width = a.width + b.width;
            localparam integer prod_exponent = a.exponent + b.exponent;
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
        localparam integer exponent = `SVREAL_PARAM_MAX(a.exponent, b.exponent);
        localparam integer a_aligned_width = a.width - (exponent - a.exponent);
        localparam integer b_aligned_width = b.width - (exponent - b.exponent);

        // create the aligned representations
        `MAKE_SVREAL(a_aligned, a_aligned_width, exponent);
        `MAKE_SVREAL(b_aligned, b_aligned_width, exponent);
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
        localparam integer d_width = d.width;
        localparam integer d_exponent = d.exponent;
        
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

`endif // `ifndef __SVREAL_SV__
