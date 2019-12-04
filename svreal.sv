`ifndef __SVREAL_SV__
`define __SVREAL_SV__

// fixed-point representation defaults
// (can override by defining them externally)

`ifndef SHORT_WIDTH_REAL
    `define SHORT_WIDTH_REAL 18
`endif

`ifndef LONG_WIDTH_REAL
    `define LONG_WIDTH_REAL 25
`endif

// declare a more generic version of $clog2 that supports
// real number inputs, which is needed to automatically
// compute exponents.  the the value returned is
// int(ceil(log2(x)))
`define DECL_CLOG2_MATH \
    function int clog2_math(input real x); \
        clog2_math = 0; \
        if (x > 0) begin \
            while (x < (2.0**(clog2_math))) begin \
                clog2_math = clog2_math - 1; \
            end \
            while (x > (2.0**(clog2_math))) begin \
                clog2_math = clog2_math + 1; \
            end \
        end \
    endfunction

`define CALC_EXP(range, width) \
    (clog2_math((1.0*(``range``))/((2.0**((``width``)-1.0))-1.0)))

`define MAX_MATH(a, b) \
    (((``a``) > (``b``)) ? (``a``) : (``b``))

`define ABS_MATH(x) \
    (((``x``) > 0) ? (``x``) : (-(``x``)))

`define FIXED_TO_FLOAT(significand, exponent) \
    ((1.0*(``significand``))*(2.0**(``exponent``)))

`define FLOAT_TO_FIXED(value, exponent) \
    (longint'((1.0*(``value``))*(2.0**(-(``exponent``)))))

// real number parameters
// width and exponent are only used for the fixed-point
// representation

`define RANGE_PARAM_REAL(name) ``name``_range_val

`define WIDTH_PARAM_REAL(name) ``name``_width_val

`define EXPONENT_PARAM_REAL(name) ``name``_exponent_val

`define PRINT_FORMAT_REAL(name) \
    $display(`"``name``: {width=%0d, exponent=%0d, range=%0f}`", `WIDTH_PARAM_REAL(``name``), `EXPONENT_PARAM_REAL(``name``), `RANGE_PARAM_REAL(``name``))

// real number representation type

`define DATA_TYPE_REAL(width_expr) \
    `ifdef FLOAT_REAL \
        real \
    `else \
        logic signed [((``width_expr``)-1):0] \
    `endif
            
// module ports

`define DECL_REAL(port) \
    parameter real `RANGE_PARAM_REAL(``port``) = 0, \
    parameter integer `WIDTH_PARAM_REAL(``port``) = 0, \
    parameter integer `EXPONENT_PARAM_REAL(``port``) = 0

`define PASS_REAL(port, name) \
    .`RANGE_PARAM_REAL(``port``)(`RANGE_PARAM_REAL(``name``)), \
    .`WIDTH_PARAM_REAL(``port``)(`WIDTH_PARAM_REAL(``name``)), \
    .`EXPONENT_PARAM_REAL(``port``)(`EXPONENT_PARAM_REAL(``name``))

`define PORT_REAL(port) \
    `ifdef FLOAT_REAL \
        `DATA_TYPE_REAL(`WIDTH_PARAM_REAL(``port``)) ``port`` \
    `else \
        wire `DATA_TYPE_REAL(`WIDTH_PARAM_REAL(``port``)) ``port`` \
    `endif

`define INPUT_REAL(port) \
    input `PORT_REAL(``port``)

`define OUTPUT_REAL(port) \
    output `PORT_REAL(``port``)

// Displaying real number signals

`define TO_REAL(name) \
    `ifdef FLOAT_REAL \
        (``name``) \
    `else \
		`FIXED_TO_FLOAT((``name``), (`EXPONENT_PARAM_REAL(``name``))) \
    `endif

`define PRINT_REAL(name) \
    $display(`"``name``=%0f`", `TO_REAL(``name``))

// force a real number

`define FROM_REAL(expr, name) \
    `ifdef FLOAT_REAL \
        (``expr``) \
    `else \
		`FLOAT_TO_FIXED((``expr``), (`EXPONENT_PARAM_REAL(``name``))) \
    `endif

`define FORCE_REAL(expr, name) \
    ``name`` = `FROM_REAL(``expr``, ``name``)

// assert that real number is within specified range

`define ASSERTION_REAL(in_name) \
    assertion_real #( \
        `PASS_REAL(in, ``in_name``), \
        .name(`"``in_name```") \
    ) assertion_real_``in_name``_i ( \
        .in(``in_name``) \
    )

// creating real numbers
// the data type declaration comes first so that directives like mark_debug
// and dont_touch can be used

`define MAKE_FORMAT_REAL(name, range_expr, width_expr, exponent_expr) \
    `DATA_TYPE_REAL(``width_expr``) ``name``; \
    localparam real `RANGE_PARAM_REAL(``name``) = ``range_expr``; \
    localparam integer `WIDTH_PARAM_REAL(``name``) = ``width_expr``; \
    localparam integer `EXPONENT_PARAM_REAL(``name``) = ``exponent_expr`` \
    `ifdef FLOAT_REAL \
        ; `ASSERTION_REAL(``name``) \
    `endif

`define REAL_FROM_WIDTH_EXP(name, width_expr, exponent_expr) \
    `MAKE_FORMAT_REAL(``name``, 2.0**((``width_expr``)+(``exponent_expr``)-1.0), ``width_expr``, ``exponent_expr``)

// copying real number format

`define GET_FORMAT_REAL(in_name) \
    `DATA_TYPE_REAL(`WIDTH_PARAM_REAL(``in_name``))

`define COPY_FORMAT_REAL(in_name, out_name) \
    `MAKE_FORMAT_REAL(``out_name``, `RANGE_PARAM_REAL(``in_name``), `WIDTH_PARAM_REAL(``in_name``), `EXPONENT_PARAM_REAL(``in_name``))

// negation
// note that since the range of a fixed-point number is defined as +/- |range|, the negation of 
// the fixed point numbers can always be represented in the original format.

`define NEGATE_INTO_REAL(in_name, out_name) \
    negate_real #( \
        `PASS_REAL(in, ``in_name``), \
        `PASS_REAL(out, ``out_name``) \
    ) negate_real_``out_name``_i ( \
        .in(``in_name``), \
        .out(``out_name``) \
    ) 

`define NEGATE_REAL(in_name, out_name) \
    `COPY_FORMAT_REAL(``in_name``, ``out_name``); \
    `NEGATE_INTO_REAL(``in_name``, ``out_name``)

// construct real number from range
// the following four macros depend on clog2_math

`define MAKE_GENERIC_REAL(name, range_expr, width_expr) \
    `MAKE_FORMAT_REAL(``name``, ``range_expr``, ``width_expr``, `CALC_EXP(``range_expr``, ``width_expr``))

`define MAKE_SHORT_REAL(name, range_expr) \
    `MAKE_GENERIC_REAL(``name``, ``range_expr``, `SHORT_WIDTH_REAL)

`define MAKE_LONG_REAL(name, range_expr) \
    `MAKE_GENERIC_REAL(``name``, ``range_expr``, `LONG_WIDTH_REAL)

`define MAKE_REAL(name, range_expr) \
    `MAKE_LONG_REAL(``name``, ``range_expr``)
    
// assigning real numbers
// note that the negative version of each number will already have be assigned when
// out_name was defined

`define ASSIGN_REAL(in_name, out_name) \
    assign_real #( \
        `PASS_REAL(in, ``in_name``), \
        `PASS_REAL(out, ``out_name``) \
    ) assign_real_``out_name``_i ( \
        .in(``in_name``), \
        .out(``out_name``) \
    ) 

// real constants
// range is skewed just a bit higher to make sure that the 
// fixed-point representation falls within the range

`define ASSIGN_CONST_REAL(const_expr, name) \
    assign ``name`` = `FROM_REAL(``const_expr``, ``name``)

`define CONST_RANGE_REAL(const_expr) \
    (1.01*`ABS_MATH(``const_expr``))

`define MAKE_GENERIC_CONST_REAL(const_expr, name, width_expr) \
    `MAKE_GENERIC_REAL(``name``, `CONST_RANGE_REAL(``const_expr``), ``width_expr``); \
    `ASSIGN_CONST_REAL(``const_expr``, ``name``)

`define MAKE_SHORT_CONST_REAL(const_expr, name) \
    `MAKE_GENERIC_CONST_REAL(``const_expr``, ``name``, `SHORT_WIDTH_REAL)

`define MAKE_LONG_CONST_REAL(const_expr, name) \
    `MAKE_GENERIC_CONST_REAL(``const_expr``, ``name``, `LONG_WIDTH_REAL)

`define MAKE_CONST_REAL(const_expr, name) \
    `MAKE_LONG_CONST_REAL(``const_expr``, ``name``)

// multiplication of two variables

`define MUL_INTO_REAL(a_name, b_name, c_name) \
    mul_real #( \
        `PASS_REAL(a, ``a_name``), \
        `PASS_REAL(b, ``b_name``), \
        `PASS_REAL(c, ``c_name``) \
    ) mul_real_``c_name``_i ( \
        .a(``a_name``), \
        .b(``b_name``), \
        .c(``c_name``) \
    )
        
`define MUL_REAL(a_name, b_name, c_name) \
    `MAKE_REAL(``c_name``, `RANGE_PARAM_REAL(``a_name``)*`RANGE_PARAM_REAL(``b_name``)); \
    `MUL_INTO_REAL(``a_name``, ``b_name``, ``c_name``)

// multiplication of a constant and variable

`define MUL_CONST_INTO_REAL(const_expr, in_name, out_name) \
    `MAKE_SHORT_CONST_REAL(``const_expr``, zzz_tmp_``out_name``); \
    `MUL_INTO_REAL(zzz_tmp_``out_name``, ``in_name``, ``out_name``)

`define MUL_CONST_REAL(const_expr, in_name, out_name) \
    `MAKE_REAL(``out_name``, `CONST_RANGE_REAL(``const_expr``)*`RANGE_PARAM_REAL(``in_name``)); \
    `MUL_CONST_INTO_REAL(``const_expr``, ``in_name``, ``out_name``)
    
// addition of two variables

`define ADD_OPCODE_REAL 0

`define ADD_INTO_REAL(a_name, b_name, c_name) \
    add_sub_real #( \
        `PASS_REAL(a, ``a_name``), \
        `PASS_REAL(b, ``b_name``), \
        `PASS_REAL(c, ``c_name``), \
		.opcode(`ADD_OPCODE_REAL) \
    ) add_sub_real_``c_name``_i ( \
        .a(``a_name``), \
        .b(``b_name``), \
        .c(``c_name``) \
    )

`define ADD_REAL(a_name, b_name, c_name) \
    `MAKE_REAL(``c_name``, `RANGE_PARAM_REAL(``a_name``) + `RANGE_PARAM_REAL(``b_name``)); \
    `ADD_INTO_REAL(``a_name``, ``b_name``, ``c_name``)
    
// addition of a constant and a variable

`define ADD_CONST_INTO_REAL(const_expr, in_name, out_name) \
    `MAKE_CONST_REAL(``const_expr``, zzz_tmp_``out_name``); \
    `ADD_INTO_REAL(zzz_tmp_``out_name``), ``in_name``, ``out_name``)

`define ADD_CONST_REAL(const_expr, in_name, out_name) \
    `MAKE_REAL(``out_name``, `CONST_RANGE_REAL(``const_expr``) + `RANGE_PARAM_REAL(``in_name``)); \
    `ADD_CONST_INTO_REAL(``const_expr``, ``in_name``, ``out_name``)

// addition of three variables

`define ADD3_INTO_REAL(a_name, b_name, c_name, d_name) \
    `ADD_REAL(``a_name``, ``b_name``, zzz_tmp_``d_name``); \
    `ADD_INTO_REAL(zzz_tmp_``d_name``, ``c_name``, ``d_name``)

`define ADD3_REAL(a_name, b_name, c_name, d_name) \
    `MAKE_REAL(``d_name``, `RANGE_PARAM_REAL(``a_name``) + `RANGE_PARAM_REAL(``b_name``) + `RANGE_PARAM_REAL(``c_name``)); \
    `ADD3_INTO_REAL(``a_name``, ``b_name``, ``c_name``, ``d_name``)

// subtraction of two variables

`define SUB_OPCODE_REAL 1

`define SUB_INTO_REAL(a_name, b_name, c_name) \
    add_sub_real #( \
        `PASS_REAL(a, ``a_name``), \
        `PASS_REAL(b, ``b_name``), \
        `PASS_REAL(c, ``c_name``), \
		.opcode(`SUB_OPCODE_REAL) \
    ) add_sub_real_``c_name``_i ( \
        .a(``a_name``), \
        .b(``b_name``), \
        .c(``c_name``) \
    )

`define SUB_REAL(a_name, b_name, c_name) \
    `MAKE_REAL(``c_name``, `RANGE_PARAM_REAL(``a_name``) + `RANGE_PARAM_REAL(``b_name``)); \
    `SUB_INTO_REAL(``a_name``, ``b_name``, ``c_name``)

// conditional assignment

`define ITE_INTO_REAL(cond_name, true_name, false_name, out_name) \
    ite_real #( \
        `PASS_REAL(true, ``true_name``), \
        `PASS_REAL(false, ``false_name``), \
        `PASS_REAL(out, ``out_name``) \
    ) ite_real_``out_name``_i ( \
        .cond(``cond_name``), \
        .true(``true_name``), \
        .false(``false_name``), \
        .out(``out_name``) \
    )

`define ITE_REAL(cond_name, true_name, false_name, out_name) \
    `MAKE_REAL(``out_name``, `MAX_MATH(`RANGE_PARAM_REAL(``true_name``), `RANGE_PARAM_REAL(``false_name``))); \
    `ITE_INTO_REAL(``cond_name``, ``true_name``, ``false_name``, ``out_name``)

// generic comparison

`define COMP_INTO_REAL(opcode_value, a_name, b_name, c_name) \
    comp_real #( \
        `PASS_REAL(a, ``a_name``), \
        `PASS_REAL(b, ``b_name``), \
        .opcode(``opcode_value``) \
    ) comp_real_``c_name``_i ( \
        .a(``a_name``), \
        .b(``b_name``), \
        .c(``c_name``) \
    )

`define COMP_REAL(opcode, a_name, b_name, c_name) \
    logic ``c_name``; \
    `COMP_INTO_REAL(``opcode``, ``a_name``, ``b_name``, ``c_name``)

// greater than

`define GT_OPCODE_REAL 0

`define GT_INTO_REAL(a_name, b_name, c_name) \
    `COMP_INTO_REAL(`GT_OPCODE_REAL, ``a_name``, ``b_name``, ``c_name``)

`define GT_REAL(a_name, b_name, c_name) \
    logic ``c_name``; \
    `GT_INTO_REAL(``a_name``, ``b_name``, ``c_name``)

// greater than or equal to

`define GE_OPCODE_REAL 1

`define GE_INTO_REAL(a_name, b_name, c_name) \
    `COMP_INTO_REAL(`GE_OPCODE_REAL, ``a_name``, ``b_name``, ``c_name``)

`define GE_REAL(a_name, b_name, c_name) \
    logic ``c_name``; \
    `GE_INTO_REAL(``a_name``, ``b_name``, ``c_name``)

// less than

`define LT_OPCODE_REAL 2

`define LT_INTO_REAL(a_name, b_name, c_name) \
    `COMP_INTO_REAL(`LT_OPCODE_REAL, ``a_name``, ``b_name``, ``c_name``)

`define LT_REAL(a_name, b_name, c_name) \
    logic ``c_name``; \
    `LT_INTO_REAL(``a_name``, ``b_name``, ``c_name``)

// less than or equal to

`define LE_OPCODE_REAL 3

`define LE_INTO_REAL(a_name, b_name, c_name) \
    `COMP_INTO_REAL(`LE_OPCODE_REAL, ``a_name``, ``b_name``, ``c_name``)

`define LE_REAL(a_name, b_name, c_name) \
    logic ``c_name``; \
    `LE_INTO_REAL(``a_name``, ``b_name``, ``c_name``)

// equal to

`define EQ_OPCODE_REAL 4

`define EQ_INTO_REAL(a_name, b_name, c_name) \
    `COMP_INTO_REAL(`EQ_OPCODE_REAL, ``a_name``, ``b_name``, ``c_name``)

`define EQ_REAL(a_name, b_name, c_name) \
    logic ``c_name``; \
    `EQ_INTO_REAL(``a_name``, ``b_name``, ``c_name``)

// not equal to

`define NE_OPCODE_REAL 5

`define NE_INTO_REAL(a_name, b_name, c_name) \
    `COMP_INTO_REAL(`NE_OPCODE_REAL, ``a_name``, ``b_name``, ``c_name``)

`define NE_REAL(a_name, b_name, c_name) \
    logic ``c_name``; \
    `NE_INTO_REAL(``a_name``, ``b_name``, ``c_name``)

// max of two variables

`define MAX_INTO_REAL(a_name, b_name, c_name) \
    `GT_REAL(``a_name``, ``b_name``, zzz_tmp_``c_name``); \
    `ITE_INTO_REAL(zzz_tmp_``c_name``, ``a_name``, ``b_name``, ``c_name``)

`define MAX_REAL(a_name, b_name, c_name) \
    `MAKE_REAL(``c_name``, `MAX_MATH(`RANGE_PARAM_REAL(``a_name``), `RANGE_PARAM_REAL(``b_name``))); \
    `MAX_INTO_REAL(``a_name``, ``b_name``, ``c_name``)

// min of two variables

`define MIN_INTO_REAL(a_name, b_name, c_name) \
    `LT_INTO_REAL(``a_name``, ``b_name``, zzz_tmp_``c_name``); \
    `ITE_INTO_REAL(zzz_tmp_``c_name``, ``a_name``, ``b_name``, ``c_name``)

`define MIN_REAL(a_name, b_name, c_name) \
    `MAKE_REAL(``c_name``, `MAX_MATH(`RANGE_PARAM_REAL(``a_name``), `RANGE_PARAM_REAL(``b_name``))); \
    `MIN_INTO_REAL(``a_name``, ``b_name``, ``c_name``)

// conversion from real number to integer

`define REAL_TO_INT(in_name, int_width_expr, out_name) \
    `ifdef FLOAT_REAL \
        logic signed[((``int_width_expr``)-1):0] ``out_name``; \
        assign ``out_name`` = longint'(``in_name``) \
    `else \
        `REAL_FROM_WIDTH_EXP(``out_name``, ``int_width_expr``, 0); \
        `ASSIGN_REAL(``in_name``, ``out_name``) \
    `endif

`define REAL_INTO_INT(in_name, int_width_expr, out_name) \
    `REAL_TO_INT(``in_name``, ``int_width_expr``, zzz_tmp_``out_name``); \
    assign ``out_name`` = zzz_tmp_``out_name``
    
// conversion from integer to real number

`define INT_TO_REAL(in_name, int_width_expr, out_name) \
    `REAL_FROM_WIDTH_EXP(``out_name``, ``int_width_expr``, 0); \
    `ifdef FLOAT_REAL \
        assign ``out_name`` = 1.0*(``in_name``) \
    `else \
        assign ``out_name`` = ``in_name`` \
    `endif
    
`define INT_INTO_REAL(in_name, int_width_expr, out_name) \
    `INT_TO_REAL(``in_name``, ``int_width_expr``, zzz_tmp_``out_name``); \
    `ASSIGN_REAL(zzz_tmp_``out_name``, ``out_name``)

// memory

`define DFF_INTO_REAL(d_name, q_name, rst_name, clk_name, cke_name, init_expr) \
    dff_real #( \
        `PASS_REAL(d, ``d_name``), \
        `PASS_REAL(q, ``q_name``), \
        .init(``init_expr``) \
    ) dff_real_``q_name``_i ( \
        .d(``d_name``), \
        .q(``q_name``), \
        .rst(``rst_name``), \
        .clk(``clk_name``), \
        .cke(``cke_name``) \
    )

`define DFF_REAL(d_name, q_name, rst_name, clk_name, cke_name, init_expr) \
    `COPY_FORMAT_REAL(``d_name``, ``q_name``); \
    `DFF_INTO_REAL(``d_name``, ``q_name``, ``rst_name``, ``clk_name``, ``cke_name``, ``init_expr``)

// module definitions

module assertion_real #(
    `DECL_REAL(in),
    parameter name = "name"
) (
    `INPUT_REAL(in)
);

    localparam real min = -(`RANGE_PARAM_REAL(in));
    localparam real max = +(`RANGE_PARAM_REAL(in));

    always @(in) begin
        if (!((min <= `TO_REAL(in)) && (`TO_REAL(in) <= max))) begin
            $display("Real number %s with value %f out of range (%f to %f).", name, `TO_REAL(in), min, max);
            $fatal;
        end
    end
                        
endmodule

module assign_real #(
    `DECL_REAL(in),
    `DECL_REAL(out)
) (
    `INPUT_REAL(in),
    `OUTPUT_REAL(out)
);
    `ifdef FLOAT_REAL
        assign out = in;
    `else
        localparam integer lshift = `EXPONENT_PARAM_REAL(in) - `EXPONENT_PARAM_REAL(out);
    
        generate
            if (lshift >= 0) begin
                assign out = in <<< (+lshift);
            end else begin
                assign out = in >>> (-lshift);
            end
        endgenerate
    `endif
endmodule

module add_sub_real #(
    `DECL_REAL(a),
    `DECL_REAL(b),
    `DECL_REAL(c),
	parameter integer opcode=0
) (
    `INPUT_REAL(a),
    `INPUT_REAL(b),
    `OUTPUT_REAL(c)
);
    `COPY_FORMAT_REAL(c, a_aligned);
    `COPY_FORMAT_REAL(c, b_aligned);
    
    `ASSIGN_REAL(a, a_aligned);
    `ASSIGN_REAL(b, b_aligned);
    
    generate
        if          (opcode == `ADD_OPCODE_REAL) begin
    		assign c = a_aligned + b_aligned;
        end else if (opcode == `SUB_OPCODE_REAL) begin
    		assign c = a_aligned - b_aligned;
        end else begin
            initial begin
                $display("ERROR: Invalid opcode.");
                $finish;
            end
        end
    endgenerate
endmodule

module negate_real #(
    `DECL_REAL(in),
    `DECL_REAL(out)
) (
    `INPUT_REAL(in),
    `OUTPUT_REAL(out)
);
    // align the input to the output format
    `COPY_FORMAT_REAL(out, in_aligned);
    `ASSIGN_REAL(in, in_aligned);
    
    // assign the output
    assign out = -in_aligned;
endmodule

module mul_real #(
    `DECL_REAL(a),
    `DECL_REAL(b),
    `DECL_REAL(c)
) (
    `INPUT_REAL(a),
    `INPUT_REAL(b),
    `OUTPUT_REAL(c)
);
    // create wire to hold product result
    `MAKE_FORMAT_REAL(
        prod, 
        `RANGE_PARAM_REAL(a) * `RANGE_PARAM_REAL(b),
        `WIDTH_PARAM_REAL(a) + `WIDTH_PARAM_REAL(b),
        `EXPONENT_PARAM_REAL(a) + `EXPONENT_PARAM_REAL(b)
    );

    // compute product
    assign prod = a * b;
  
    // assign result to output (which will left/right shift if necessary)
    `ASSIGN_REAL(prod, c);
endmodule

module comp_real #(
    `DECL_REAL(a),
    `DECL_REAL(b),
    parameter integer opcode=0
) (
    `INPUT_REAL(a),
    `INPUT_REAL(b),
    output wire logic c
);
    `DECL_CLOG2_MATH

	// compute the maximum range of the two arguments
    localparam real max_range = `MAX_MATH(`RANGE_PARAM_REAL(a), `RANGE_PARAM_REAL(b));

    `MAKE_REAL(a_aligned, max_range);
    `MAKE_REAL(b_aligned, max_range);

    `ASSIGN_REAL(a, a_aligned);
    `ASSIGN_REAL(b, b_aligned);

    generate
        if          (opcode == `GT_OPCODE_REAL) begin
            assign c = (a_aligned >  b_aligned) ? 1'b1 : 1'b0;
        end else if (opcode == `GE_OPCODE_REAL) begin
            assign c = (a_aligned >= b_aligned) ? 1'b1 : 1'b0;
        end else if (opcode == `LT_OPCODE_REAL) begin
            assign c = (a_aligned <  b_aligned) ? 1'b1 : 1'b0;
        end else if (opcode == `LE_OPCODE_REAL) begin
            assign c = (a_aligned <= b_aligned) ? 1'b1 : 1'b0;
        end else if (opcode == `EQ_OPCODE_REAL) begin
            assign c = (a_aligned == b_aligned) ? 1'b1 : 1'b0;
        end else if (opcode == `NE_OPCODE_REAL) begin
            assign c = (a_aligned != b_aligned) ? 1'b1 : 1'b0;
        end else begin
            initial begin
                $display("ERROR: Invalid opcode.");
                $finish;
            end
        end
    endgenerate
endmodule

module ite_real #(
    `DECL_REAL(true),
    `DECL_REAL(false),
    `DECL_REAL(out)
) (
    input wire logic cond,
    `INPUT_REAL(true),
    `INPUT_REAL(false),
    `OUTPUT_REAL(out)
);
    `COPY_FORMAT_REAL(out,  true_aligned);
    `COPY_FORMAT_REAL(out, false_aligned);

    `ASSIGN_REAL(true,   true_aligned);
    `ASSIGN_REAL(false, false_aligned);

    assign out = (cond == 1'b1) ? true_aligned : false_aligned;
endmodule

module dff_real #(
    `DECL_REAL(d),
    `DECL_REAL(q),
	parameter real init=0
) (
    `INPUT_REAL(d),
    `OUTPUT_REAL(q),
    input wire logic rst,
    input wire logic clk,
    input wire logic cke
);
    // "var" for memory is kept internal
    // so that all ports are "wire" type nets
    `COPY_FORMAT_REAL(q, q_mem);
    `ASSIGN_REAL(q_mem, q);

    // align input to output
    `COPY_FORMAT_REAL(q, d_aligned);
    `ASSIGN_REAL(d, d_aligned);
    
    // align initial value to output format
    `COPY_FORMAT_REAL(q, init_aligned);
	`ASSIGN_CONST_REAL(init, init_aligned); 
   
    // main DFF logic
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            q_mem <= init_aligned;
        end else if (cke == 1'b1) begin
            q_mem <= d_aligned;
        end else begin
            q_mem <= q;
        end
    end       
endmodule

`endif // `ifndef __SVREAL_SV__
