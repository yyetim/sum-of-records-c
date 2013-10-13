sum-of-records-c
================
this library provides a simple way of creating new types in C, which
would simulate the sum of records type. when using this type, the
type-checking can be done dynamically for testing and it can be
disabled for performance.

an example usage: assume functions P1, P2 and C, where function C
consumes the output of functions P1 and P2. now, P1 may be producing
two integers, and P2 may be producing two floats. the function C, as a
callee, needs to differentiate these types as a user.
i.e.,
p1output_t P1();
p2output_t P2();
void C(cinput_t cinput);

we would want to have
struct p1output_t {...};
struct p2output_t {...};
enum cinput_t { struct p1output_t p1; struct p2output_t p2 };

now many bugs come after this point. when C() wants to use cinput, it
needs to cast it either to p1output_t or p2output_t. for a complicated
software, this operation is very error-prone.

furthermore, if you want to have P3() to feed into C(), then you need
to change many things.

this simple library provides a way of creating this abstraction
automatically (so less error-prone) and optionally enables dynamic
type-checking of the casting operations during run-time, mainly for
testing stage.

i) what is a sum type?
an instance of a sum type is an object that can be one of many things
(similar to enum in C, or an object of an abstract class with many
subclasses in OO). this instance may only represent one of these
many things.
e.g.:
data IntFloat = IntS Int | FloatS Float -- define the sum type
x = IntS 3
y = FloatS 7.0
-- in this example x and y have the same type, IntFloat, while
   themselves being different types
ii) what is a record type?
a collection of several objects (similar to struct in C, or members of
a class in OO)
e.g.:
data IntFloat = IntFloat { intR :: Int, floatR :: Float }
let x = IntFloat { intR = 3, floatR = 7.0 }
-- in this example, x contains both the integer value and the float
   value

example usage
=============
import SumOfRecordsC

data PrimitiveType = BOOL | UINT

instance Show PrimitiveType where
    show BOOL = "bool"
    show UINT = "uinteger_t"

wordsForType = ["sum", "of", "records"]

myTypeStrings = [
  ("NONE", []),
  ("PUSH", [("is_edge", BOOL), ("what", UINT)])
  ]

main = do
  printAll wordsForType myTypeStrings True
  
===============================================================================
running the code above in haskell produces the C code at the end of this README. now we
can put this in an include file and use in C as follows:
i) create a new type:
sum_of_records_t sorn = NONE_C();		// create NONE instance
sum_of_records_t sorp = PUSH_C(true, 4);	// create PUSH instance

ii) act on depending type
switch (TYPE(sorp)) { 		     		// act on type
       case NONE_E: // wouldn't be here
       	    break;
       case PUSH_E:
       	    printf("%d", PUSH_D(sorp).what);    // deconstruct sorp as a PUSH
	    break;
       }
iii) catch bugs: above, in the haskell code, we called "printAll" with
True. this enables dynamic type checking of the casting operation. so
the code below would fail at the assertion inside the PUSH_D():

int a = PUSH_D(sorn).what; // deconstruct sorn as a PUSH

REMARKS: always use x_C() to create an item, TYPE() to check the type,
x_D() to deconstruct the item. this hopefully will make sure that
nothing will go wrong
===============================================================================
// GENERATED C CODE:

#include <assert.h>
#define TYPE(x) ((x).e)
enum SumOfRecords {
        NONE_E,
        PUSH_E
};
typedef void * NONE_T;
struct PUSH_str {
        bool is_edge;
        uinteger_t what;
};
typedef struct PUSH_str PUSH_T;
union sum_of_records_uni {
        NONE_T NONE_U;
        PUSH_T PUSH_U;
};
struct sum_of_records_str {
        enum SumOfRecords e;
        union sum_of_records_uni u;
};
typedef struct sum_of_records_str sum_of_records_t;
__attribute__((unused)) static sum_of_records_t
NONE_C() {
        sum_of_records_t sum_of_records;
        sum_of_records.e = NONE_E;
        sum_of_records.u.NONE_U = (NONE_T *)NULL;
        return sum_of_records;
}
__attribute__((unused)) static sum_of_records_t
PUSH_C(bool is_edge, uinteger_t what) {
        sum_of_records_t sum_of_records;
        sum_of_records.e = PUSH_E;
        sum_of_records.u.PUSH_U.is_edge = is_edge;
        sum_of_records.u.PUSH_U.what = what;
        return sum_of_records;
}
__attribute__((unused)) static NONE_T
NONE_D(sum_of_records_t sum_of_records) {
        assert(sum_of_records.e == NONE_E);
        return sum_of_records.u.NONE_U;
}
__attribute__((unused)) static PUSH_T
PUSH_D(sum_of_records_t sum_of_records) {
        assert(sum_of_records.e == PUSH_E);
        return sum_of_records.u.PUSH_U;
}