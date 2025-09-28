extends Node
var current_level=0
var unlocked_levels=0
var levels = [{
	"name": "TO REPAIR: INPUT/OUTPUT SELF-TEST",
	"description": "TODO:\nOutput twice the value of the input. See 'Help' for how to get started. 'Help' will have useful advice for every level.",
	"input": [4, 8, 33, 124, 56, 75, 14, 24, 57, 73, 90, 32, 1, 0, 6],
	"expected_output": [8, 16, 66, 248, 112, 150, 28, 48, 114, 146, 180, 64, 2, 0, 12],
	"manual": "
WELCOME TO K&S MICROCOMPUTERS REPAIR MANUAL.
If you are reading this, chances are, something's wrong with your computer, and you/your employer has chosen against purchasing the K&S MIRACLE REPAIR DISK available at ANY K&S SERVICING STORE for ONLY $59.99. Fret not, dear consumer- this manual exists to help sorry, miserly souls such as yourself.
-REGISTERS-
For now, it is recommended you familiarize yourself with EAX, EBX, ECX, and EDX. Each of these is a general purpose data register, capable of holding 32 bits of information. For our current purposes, they are functionally identical to one another. Data storage isn't particularly useful without data to store, though, so we'll move to...
-BASIC OPERATIONS-
IN {DEST} will move information from input (given from the computer) into the given register.
ADD {DEST}, {SRC} will add SRC to DEST, leaving SRC the same. (note- DEST and SRC can be the same register- they can also be constant values such as 5!)
SUB {DEST}, {SRC} will do the same, but for subtraction.
OUT {SRC} will move information to the output buffer to be tested by the computer- this should almost always be some modified version of the input.
NOTE- Until output meets the expected size, any code block written will loop endlessly.
EXAMPLE-
IN EAX
OUT EAX
This will move input to ouput with no changes, until output meets a certain size."
},
{
	"name": "TO REPAIR: AUXILIARY OPERATION UNIT",
	"description": "TODO:\nOutput four times the input plus three. See 'Help' to begin.",
	"input": [74, 23, 84, 9, 13, 24, 8, 987, 35, 736, 23, 617 ,2],
	"expected_output": [299, 95, 339, 39, 55, 99, 35, 3951, 143, 2947, 95, 2471, 11],
	"manual":"A BIT ON BITS:
Registers (and data in general!) are expressed in bits, with each sequential bit being either zero or one representing a power of two. 001 is 1, while 100 is 4. (0*2^0 + 0*2^1 + 1*2^2). Beyond understanding how computers represent data, this is important to know for a few key operations-
AND {DEST}, {SRC}- Output of two binary sequences, 1 if both inputs are 1- 01001011 & 01100110 = 01000010 A number and itself is unchanged.
OR {DEST}, {SRC}- Output of two binary sequences, 1 if either input is 1- 01101011 | 11011011 = 11111011 A number or itself is unchanged.
XOR {DEST}, {SRC}- Output of two binary sequences, 1 if each input bit is different- 01101101 ^ 10111010 = 11010111. A number xor itself is 0.
SHL {DEST}, {SRC}- Shifts {DEST} {SRC} bits to the left. (SHL 00100101, 2) becomes 10010100. (note- the greatest bit is on the left. 100 is greater than 010.)
SHR {DEST}, {SRC}- Shifts DEST SRC bits to the right.
Note- the \"plus three\" part of this problem can be solved quite easily with ADD {DEST}, 3. Bitwise operations tend to be quicker than their arithmetic counterparts, though- try to use them where possible!"
},
{
	"name": "TO REPAIR: SIGNAL NORMALIZER",
	"description": "TODO:\nOutput the input minus the previous input, so long as the difference is positive. If not, output the input plus the previous input. The first input can remain unchanged.",
	"input": [75, 32, 1, 35, 67, 200, 400, 36, 76, 24, 1, 34, 56, 98],
	"expected_output": [75, 107, 33, 34, 32, 133, 200, 436, 40, 100, 25, 33, 22, 42],
	"manual":"CONDITIONAL LOVE:
K&S MICROCOMPUTERS possess 4 general-purpose registers- for simple usage, these are enough. But you're beyond simple usage. And so, there's two others you should know about.
FLAGS- The FLAGS register is modified automatically during any operation that changes any register's value (so, most of them.) The FLAGS register contains the ZERO flag, which is set when the output of an operation is 0, and the CARRY flag, which is set when the output of an operation underflows below zero (like 10 minus 20) or overflows above the 32 bit limit.
IP- IP stands for INSTRUCTION POINTER, which is incremented at the end of every operation and tells the processor what instruction to execute next. At the end of your code block, it automatically is set back to 0. Before, these were working in the background- but you can make use of them. And you should, because they allow for...
--CONDITIONAL LOGIC--
LABELS- Begin a line with any word/non-spaced description followed by a colon.
THIS_IS_A_LABEL:
Congrats! You just made a label. Why is this important?
JMP {THIS_IS_A_LABEL}- This operation will automatically set IP to the address of your label, jumping forward or backwards in execution!
Example-

INFINITE_LOOP:
JMP INFINITE_LOOP

This will run endlessly. But what if we didn't want it to?
CONDITIONAL JUMPS:
JZ {LABEL}- Jumps only if ZERO flag is set.
JNZ {LABEL}- Jumps if ZERO flag is not set.
JC {LABEL}- Jumps if CARRY flag is set.
JNC{LABEL}- Jumps if CARRY flag is not set.
Also, to make setting these flags more convenient-
CMP {DEST}, {SRC}- Acts like SUB (does DEST-SRC), but does not change DEST, only uses the difference to set flags. (Note- if SRC is greater than DEST, CARRY will be set)
EXAMPLE:

BEGIN:
IN EAX
CMP EAX, 1000
JC IS_BIG_NUMBER
OUT 0
JMP BEGIN
IS_BIG_NUMBER:
OUT 1

And, to throw just a bit more on you-
INC {DEST}, DEC {DEST}- these will increment/decrement DEST by 1. Why do we bring this up now? Try and find out."
},
{
	"name":"TO REPAIR: GENERAL-PURPOSE DATA MANIP UNIT",
	"description":"TODO:\nGiven a series of inputs, output the reverse. Each series is terminated by a zero. Note that the zero should be output, but not reversed. EXAMPLE: [1, 2, 3, 0, 4, 5, 0] becomes [3, 2, 1, 0, 5, 4, 0].",
	"input":[2, 45, 24, 66, 313, 62, 7, 0, 22, 45, 234, 7452, 76, 23, 123, 0, 76, 0, 87, 78, 0],
	"expected_output":[ 7, 62, 313, 66, 24, 45, 2, 0, 123, 23, 76, 7452, 234, 45, 22, 0, 76, 0, 78, 87, 0],
	"manual":"If you've reached this point, you've demonstrated sufficient proficiency at handling K&S MICROCOMPUTER architecture. So, allow us at K&S to introduce you to a new hardware component-
--MEMORY--
As a K&S customer, you are blessed to be in possession of an astounding 4 KiB, or 4096 bytes, of memory. Note that each register is 4 bytes, and memory is only directly addressable at 4 byte intervals, from [0] to [1023].  Memory can be read and written to with the MOV operand, using brackets around a value to address that index of memory. This index can be static, as in [5], or a register, like [EAX]. Memory cannot be operated on beyond MOV.
EXAMPLE-
MOV EBX, 7
MOV [EBX], 4
MOV EAX, [7]
EAX is now equal to 4.
NOTE-
Maybe you've figured this out yourself, but jumping backwards in your code allows for iterative logic- what some might call \"loops\"."
},
{
	"name":"TO REPAIR: MEMORY PARTITIONING UNIT",
	"description":"TODO:\nGiven an input, mark the index of the input in memory as reserved. If the input is greater than a valid index (0-1023), take the remainder of index/1024 and free the index. Return 0 upon successful reservation/free, or 1 if a reservation is attempted on a reserved index or a free on a free one.",
	"input":[24, 57, 100, 4, 1728, 12, 24, 1048, 24, 168, 84, 1124, 90, 100, 65, 57, 4100, 90, 4, 65],
	"expected_output":[0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1],
	"manual":"--REVIEW--
This module doesn't require anything except what you've already learned. But, in case you need a refresher-
MEMORY- addressable from [0] to [1023], also takes indices from registers like [EAX]. Each address stores 4 bytes, the same as a register.
BINARY NUMBERS- Each number is stored as binary digits, with digits on the left representing sequential powers of 2, starting from 2^0, or 1. 100101 is 37. OR 37, 3 results in 39, while AND 37, 7 results in 5. If you're unsure how to find the remainder of something without a division operation, look here.
CONDITIONAL JUMPS- When the result of an operation is 0, ZF is set. When it underflows/overflows (such as when a larger number is subtracted from a smaller one), CF is set. These can be used with JZ, JNZ, JC, and JNC, which will only jump if their respective condition is met."
},
{
	"name":"TO REPAIR: SELECTIVE SIGNAL PROCESSOR",
	"description":"TODO:\nOutput 0 on the first appearance of an input, or 1 if the value has already appeared.",
	"input":[23, 53, 64, 23, 645, 53, 645, 12, 98, 34, 29, 14, 15, 98, 41, 567, 53, 12, 29, 274, 29, 4, 9, 0, 34],
	"expected_output":[0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1],
	"manual":"This isn't too different from what you've done already. We at K&S MICROCOMPUTERS believe in you!"
}
]
