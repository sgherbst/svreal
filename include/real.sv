// Steven Herbst
// sherbst@stanford.edu

// Library to support interchangeable floating-point 
// or synthesizable fixed-point operations

`ifndef __REAL_SV__
`define __REAL_SV__

    `include "math.sv"

    // fixed-point representation defaults
    
    `ifndef SHORT_WIDTH_REAL
        `define SHORT_WIDTH_REAL 18
    `endif
    
    `ifndef LONG_WIDTH
        `define LONG_WIDTH_REAL 25
    `endif

    // real number parameters
    // width and exponent are only used for the fixed-point
    // representation

    `define RANGE_PARAM_REAL(name) ``name``_range_val

    `define WIDTH_PARAM_REAL(name) ``name``_width_val

    `define EXPONENT_PARAM_REAL(name) ``name``_exponent_val

    `define PRINT_FORMAT_REAL(name) $display(`"name: {width=%0d, exponent=%0d}`", `WIDTH_PARAM_REAL(name), `EXPONENT_PARAM_REAL(name))

    // real number representation type

    `define DATA_TYPE_REAL(width_expr) \
        `ifdef FLOAT_REAL \
            real \
        `else \
            logic signed [((width_expr)-1):0] \
        `endif
            
    // naming prefixes.  "zzz" is used at the beginning so that these
    // variables show up at the end of the waveform viewing list

    `define MINUS_REAL(name) zzz_minus_``name``
    `define TMP_REAL(name) zzz_tmp_``name``

    // module ports

    `define DECL_REAL(port) \
        parameter real `RANGE_PARAM_REAL(port) = 0, \
        parameter integer `WIDTH_PARAM_REAL(port) = 0, \
        parameter integer `EXPONENT_PARAM_REAL(port) = 0

    `define PASS_REAL(port, name) \
        .`RANGE_PARAM_REAL(port)(`RANGE_PARAM_REAL(name)), \
        .`WIDTH_PARAM_REAL(port)(`WIDTH_PARAM_REAL(name)), \
        .`EXPONENT_PARAM_REAL(port)(`EXPONENT_PARAM_REAL(name))

    `define PORT_REAL(port) \
        `ifdef FLOAT_REAL \
            var `DATA_TYPE_REAL(`WIDTH_PARAM_REAL(port)) port \
        `else \
            wire `DATA_TYPE_REAL(`WIDTH_PARAM_REAL(port)) port \
        `endif

    `define INPUT_REAL(port) \
        input `PORT_REAL(port)

    `define OUTPUT_REAL(port) \
        output `PORT_REAL(port)

    // probe real number
    
    `define TO_REAL(name) \
        `ifdef FLOAT_REAL \
            name \
        `else \
            real'(name) * `POW2_MATH(`EXPONENT_PARAM_REAL(name)) \
        `endif

    `define PROBE_NAME_REAL(name) \
        ``name``_probe

    `define PROBE_REAL(name) \
        real `PROBE_NAME_REAL(name); \
        assign `PROBE_NAME_REAL(name) = `TO_REAL(name)

    `define PRINT_REAL(name) $display(`"name = %f`", `TO_REAL(name))

    // force a real number

    `define FROM_REAL(expr, name) \
        `ifdef FLOAT_REAL \
            (expr) \
        `else \
            (int'(1.0*(expr)*`POW2_MATH(-`EXPONENT_PARAM_REAL(name)))) \
        `endif

    `define FORCE_REAL(expr, name) \
        name = `FROM_REAL(expr, name)

    // assert that real number is within specified range

    `define ASSERTION_REAL(in_name) \
        assertion_real #( \
            `PASS_REAL(in, in_name) \
        ) assertion_real_``in_name``_i ( \
            .in(in_name) \
        )

    // creating real numbers
    // the data type declaration comes first so that directives like mark_debug
    // and dont_touch can be used

    `define MAKE_FORMAT_REAL(name, range_expr, width_expr, exponent_expr) \
        `DATA_TYPE_REAL(width_expr) name; \
        localparam real `RANGE_PARAM_REAL(name) = range_expr; \
        localparam integer `WIDTH_PARAM_REAL(name) = width_expr; \
        localparam integer `EXPONENT_PARAM_REAL(name) = exponent_expr \
        `ifdef DEBUG_REAL \
            ; `PROBE_REAL(name) \
            ; `ASSERTION_REAL(name) \
        `endif

    // copying

    `define COPY_FORMAT_REAL(in, out) \
        `MAKE_FORMAT_REAL(out, `RANGE_PARAM_REAL(in), `WIDTH_PARAM_REAL(in), `EXPONENT_PARAM_REAL(in))

    // negation
    // note that since the range of a fixed-point number is defined as +/- |range|, the negation of 
    // the fixed point numbers can always be represented in the original format.

    `define NEGATE_INTO_REAL(in, out) \
        assign out = -(in)

    `define NEGATE_REAL(in, out) \
        `COPY_FORMAT_REAL(in, out); \
        `NEGATE_INTO_REAL(in, out)

    `define MAKE_NEGATIVE_REAL(name) \
        `NEGATE_REAL(name, `MINUS_REAL(name))
    
    // construct real number from range
    
    `define CALC_EXPONENT_REAL(range_expr, width_expr) \
        `CLOG2_MATH(1.0 * (range_expr) / (`POW2_MATH((width_expr) - 1.0) - 1.0))

    `define MAKE_GENERIC_REAL(name, range_expr, width_expr) \
        `MAKE_FORMAT_REAL(name, range_expr, width_expr, `CALC_EXPONENT_REAL(range_expr, width_expr)); \
        `MAKE_NEGATIVE_REAL(name)

    `define MAKE_SHORT_REAL(name, range_expr) \
        `MAKE_GENERIC_REAL(name, range_expr, `SHORT_WIDTH_REAL)

    `define MAKE_LONG_REAL(name, range_expr) \
        `MAKE_GENERIC_REAL(name, range_expr, `LONG_WIDTH_REAL)

    `define MAKE_REAL(name, range_expr) \
        `MAKE_LONG_REAL(name, range_expr)
    
    // assigning real numbers
    // note that the negative version of each number will already have be assigned when
    // out_name was defined

    `define ASSIGN_REAL(in_name, out_name) \
        assign_real #( \
            `PASS_REAL(in, in_name), \
            `PASS_REAL(out, out_name) \
        ) assign_real_``out_name``_i ( \
            .in(in_name), \
            .out(out_name) \
        ) 

    // real constants
    // range is skewed just a bit higher to make sure that the 
    // fixed-point representation falls within the range

    `define ASSIGN_CONST_REAL(const_expr, name) \
        assign name = `FROM_REAL(const_expr, name)

    `define CONST_RANGE_REAL(const_expr) \
        (1.01*`ABS_MATH(const_expr))

    `define MAKE_GENERIC_CONST_REAL(const_expr, name, width_expr) \
        `MAKE_GENERIC_REAL(name, `CONST_RANGE_REAL(const_expr), width_expr); \
        `ASSIGN_CONST_REAL(const_expr, name)

    `define MAKE_SHORT_CONST_REAL(const_expr, name) \
        `MAKE_GENERIC_CONST_REAL(const_expr, name, `SHORT_WIDTH_REAL)

    `define MAKE_LONG_CONST_REAL(const_expr, name) \
        `MAKE_GENERIC_CONST_REAL(const_expr, name, `LONG_WIDTH_REAL)

    `define MAKE_CONST_REAL(const_expr, name) \
        `MAKE_LONG_CONST_REAL(const_expr, name)

    // multiplication of two variables

    `define MUL_INTO_REAL(a_name, b_name, c_name) \
        mul_real #( \
            `PASS_REAL(a, a_name), \
            `PASS_REAL(b, b_name), \
            `PASS_REAL(c, c_name) \
        ) mul_real_``c_name``_i ( \
            .a(a_name), \
            .b(b_name), \
            .c(c_name) \
        )
        
    `define MUL_REAL(a_name, b_name, c_name) \
        `MAKE_REAL(c_name, `RANGE_PARAM_REAL(a_name)*`RANGE_PARAM_REAL(b_name)); \
        `MUL_INTO_REAL(a_name, b_name, c_name)

    // multiplication of a constant and variable

    `define MUL_CONST_INTO_REAL(const_expr, in_name, out_name) \
        `MAKE_SHORT_CONST_REAL(const_expr, `TMP_REAL(out_name)); \
        `MUL_INTO_REAL(`TMP_REAL(out_name), in_name, out_name)

    `define MUL_CONST_REAL(const_expr, in_name, out_name) \
        `MAKE_REAL(out_name, `CONST_RANGE_REAL(const_expr)*`RANGE_PARAM_REAL(in_name)); \
        `MUL_CONST_INTO_REAL(const_expr, in_name, out_name)
    
    // addition of two variables

    `define ADD_INTO_REAL(a_name, b_name, c_name) \
        add_real #( \
            `PASS_REAL(a, a_name), \
            `PASS_REAL(b, b_name), \
            `PASS_REAL(c, c_name) \
        ) add_real_``c_name``_i ( \
            .a(a_name), \
            .b(b_name), \
            .c(c_name) \
        )
    
    `define ADD_REAL(a_name, b_name, c_name) \
        `MAKE_REAL(c_name, `RANGE_PARAM_REAL(a_name) + `RANGE_PARAM_REAL(b_name)); \
        `ADD_INTO_REAL(a_name, b_name, c_name)
    
    // addition of a constant and a variable

    `define ADD_CONST_INTO_REAL(const_expr, in_name, out_name) \
        `MAKE_CONST_REAL(const_expr, `TMP_REAL(out_name)); \
        `ADD_INTO_REAL(`TMP_REAL(out_name), in_name, out_name)

    `define ADD_CONST_REAL(const_expr, in_name, out_name) \
        `MAKE_REAL(out_name, `CONST_RANGE_REAL(const_expr) + `RANGE_PARAM_REAL(in_name)); \
        `ADD_CONST_INTO_REAL(const_expr, in_name, out_name)

    // addition of three variables

    `define ADD3_INTO_REAL(a_name, b_name, c_name, d_name) \
        `ADD_REAL(a_name, b_name, `TMP_REAL(d_name)); \
        `ADD_INTO_REAL(`TMP_REAL(d_name), c_name, d_name)
    
    `define ADD3_REAL(a_name, b_name, c_name, d_name) \
        `MAKE_REAL(d_name, `RANGE_PARAM_REAL(a_name) + `RANGE_PARAM_REAL(b_name) + `RANGE_PARAM_REAL(c_name)); \
        `ADD3_INTO_REAL(a_name, b_name, c_name, d_name)

    // subtraction of two variables

    `define SUB_INTO_REAL(a_name, b_name, c_name) \
        `NEGATE_REAL(b_name, `TMP_REAL(c_name)); \
        `ADD_INTO_REAL(a_name, `TMP_REAL(c_name), c_name)

    `define SUB_REAL(a_name, b_name, c_name) \
        `MAKE_REAL(c_name, `RANGE_PARAM_REAL(a_name) + `RANGE_PARAM_REAL(b_name)); \
        `SUB_INTO_REAL(a_name, b_name, c_name)

    // conditional assignment

    `define ITE_INTO_REAL(cond_name, true_name, false_name, out_name) \
        ite_real #( \
            `PASS_REAL(true, true_name), \
            `PASS_REAL(false, false_name), \
            `PASS_REAL(out, out_name) \
        ) ite_real_``out_name``_i ( \
            .cond(cond_name), \
            .true(true_name), \
            .false(false_name), \
            .out(out_name) \
        )

    `define ITE_REAL(cond_name, true_name, false_name, out_name) \
        `MAKE_REAL(out_name, `MAX_MATH(`RANGE_PARAM_REAL(true_name), `RANGE_PARAM_REAL(false_name))); \
        `ITE_INTO_REAL(cond_name, true_name, false_name, out_name)

    // generic comparison

    `define COMP_INTO_REAL(opcode_value, a_name, b_name, c_name) \
        comp_real #( \
            `PASS_REAL(a, a_name), \
            `PASS_REAL(b, b_name), \
            .opcode(opcode_value) \
        ) comp_real_``c_name``_i ( \
            .a(a_name), \
            .b(b_name), \
            .c(c_name) \
        )

    `define COMP_REAL(opcode, a_name, b_name, c_name) \
        logic c_name; \
        `COMP_INTO_REAL(opcode, a_name, b_name, c_name)

    // greater than
    
    `define GT_OPCODE_REAL 0

    `define GT_INTO_REAL(a_name, b_name, c_name) \
        `COMP_INTO_REAL(`GT_OPCODE_REAL, a_name, b_name, c_name)

    `define GT_REAL(a_name, b_name, c_name) \
        logic c_name; \
        `GT_INTO_REAL(a_name, b_name, c_name)

    // greater than or equal to

    `define GE_OPCODE_REAL 1

    `define GE_INTO_REAL(a_name, b_name, c_name) \
        `COMP_INTO_REAL(`GE_OPCODE_REAL, a_name, b_name, c_name)

    `define GE_REAL(a_name, b_name, c_name) \
        logic c_name; \
        `GE_INTO_REAL(a_name, b_name, c_name)

    // less than

    `define LT_OPCODE_REAL 2

    `define LT_INTO_REAL(a_name, b_name, c_name) \
        `COMP_INTO_REAL(`LT_OPCODE_REAL, a_name, b_name, c_name)

    `define LT_REAL(a_name, b_name, c_name) \
        logic c_name; \
        `LT_INTO_REAL(a_name, b_name, c_name)

    // less than or equal to

    `define LE_OPCODE_REAL 3

    `define LE_INTO_REAL(a_name, b_name, c_name) \
        `COMP_INTO_REAL(`LE_OPCODE_REAL, a_name, b_name, c_name)

    `define LE_REAL(a_name, b_name, c_name) \
        logic c_name; \
        `LE_INTO_REAL(a_name, b_name, c_name)

    // equal to

    `define EQ_OPCODE_REAL 4

    `define EQ_INTO_REAL(a_name, b_name, c_name) \
        `COMP_INTO_REAL(`EQ_OPCODE_REAL, a_name, b_name, c_name)

    `define EQ_REAL(a_name, b_name, c_name) \
        logic c_name; \
        `EQ_INTO_REAL(a_name, b_name, c_name)

    // not equal to

    `define NE_OPCODE_REAL 5

    `define NE_INTO_REAL(a_name, b_name, c_name) \
        `COMP_INTO_REAL(`NE_OPCODE_REAL, a_name, b_name, c_name)

    `define NE_REAL(a_name, b_name, c_name) \
        logic c_name; \
        `NE_INTO_REAL(a_name, b_name, c_name)

    // max of two variables

    `define MAX_INTO_REAL(a_name, b_name, c_name) \
        `GT_REAL(a_name, b_name, `TMP_REAL(c_name)); \
        `ITE_INTO_REAL(`TMP_REAL(c_name), a_name, b_name, c_name)
    
    `define MAX_REAL(a_name, b_name, c_name) \
        `MAKE_REAL(c_name, `MAX_MATH(`RANGE_PARAM_REAL(a_name), `RANGE_PARAM_REAL(b_name))); \
        `MAX_INTO_REAL(a_name, b_name, c_name)

    // min of two variables

    `define MIN_INTO_REAL(a_name, b_name, c_name) \
        `LT_REAL(a_name, b_name, `TMP_REAL(c_name)); \
        `ITE_INTO_REAL(`TMP_REAL(c_name), a_name, b_name, c_name)
   
    `define MIN_REAL(a_name, b_name, c_name) \
        `MAKE_REAL(c_name, `MAX_MATH(`RANGE_PARAM_REAL(a_name), `RANGE_PARAM_REAL(b_name))); \
        `MIN_INTO_REAL(a_name, b_name, c_name)

    // memory
    
    `define MEM_INTO_REAL(in_name, out_name) \
        mem_real #( \
            `PASS_REAL(in, in_name), \
            `PASS_REAL(out, out_name) \
        ) mem_real_``out_name``_i ( \
            .in(in_name), \
            .out(out_name), \
            .clk(clk), \
            .rst(rst) \
        )

    `define MEM_REAL(in_name, out_name) \
        `COPY_FORMAT_REAL(in_name, out_name); \
        `MEM_INTO_REAL(in_name, out_name)
        
    // conversion from real number to integer
    
    `define REAL_TO_INT(in_name, int_width_expr, out_name) \
        `ifdef FLOAT_REAL \
            logic signed[((int_width_expr)-1):0] out_name; \
            assign out_name = integer'(in_name) \
        `else \
            `MAKE_FORMAT_REAL(out_name, `POW2_MATH(int_width_expr-1), int_width_expr, 0); \
            `ASSIGN_REAL(in_name, out_name) \
        `endif
    
    `define REAL_INTO_INT(in_name, int_width_expr, out_name) \
        `REAL_TO_INT(in_name, int_width_expr, `TMP_REAL(out_name)); \
        assign out_name = `TMP_REAL(out_name)
        
    // conversion from integer to real number
    
    `define INT_TO_REAL(in_name, int_width_expr, out_name) \
        `MAKE_FORMAT_REAL(out_name, `POW2_MATH(int_width_expr-1), int_width_expr, 0); \
        `ifdef FLOAT_REAL \
            assign out_name = 1.0*in_name \
        `else \
            assign out_name = in_name \
        `endif
        
    `define INT_INTO_REAL(in_name, int_width_expr, out_name) \
        `INT_TO_REAL(in_name, int_width_expr, `TMP_REAL(out_name)); \
        `ASSIGN_REAL(`TMP_REAL(out_name), out_name)
`endif
