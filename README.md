[![](https://github.com/KINGTUT10101/KTX1FantasyComputer/blob/main/thumbnail.png)](http://https://github.com/KINGTUT10101/KTX1FantasyComputer/blob/main/thumbnail.png)
# KTX1 Fantasy Computer
The KTX1 is an 8-bit fantasy computer made in LOVE2D.


### Features
- 8-bit instruction set (4-bit opcode and 4-bit operand)
- 256 bytes of data memory and 256 bytes of program memory (broken into 16 byte memory banks)
- Includes an accumulator, program counter, and state register
- 16x16p display
- 1 byte numerical display
- Custom assembly language with external assembler
- Drag and drop binary programs to load them automatically
- Includes several example programs written in both assembly and binary

### Instructions
- 0000 (END): Ends the program
- 0001 (LDU): Copies the operand into the upper half of the accumulator
- 0010 (LDL): Copies the operand into the lower half of the accumulator
- 0011 (ATM): Copies the accumulator to the data memory location referenced by the operand
- 0100 (MTA): Copies the data memory location referenced by the operand into the accumulator
- 0101 (ADD): Adds the data memory location referenced by the operand to the accumulator
- 0110 (SUB): Subtracts the data memory location referenced by the operand from the accumulator
- 0111 (AND): Performs a bitwise AND on the accumulator using the data memory location referenced by the operand
- 1000 (ORR): Performs a bitwise OR on the accumulator using the data memory location referenced by the operand
- 1001 (NOT): Performs a bitwise NOT on the accumulator
- 1010 (BNZ): Branches to the program memory location referenced by the operand if the accumulator equals 0. The return address will also be set if the branch is successful
- 1011 (BRT): Branches to the program memory location referenced by the return address (set by BNZ)
- 1100 (SDD): Copies the value in the data memory location referenced by the operand into the numerical display
- 1101 (SVM): Toggles the pixel referenced by the value inside the data address referenced by the operand. The upper half of the byte determines the y position and the lower half of the byte determines the x position
- 1110 (SMB): Switches to the data memory bank referenced by the upper half of the accumulator, switches to the program memory bank referenced by the lower half of the accumulator, and sets the program counter to the value of the operand
- 1111: A meta instruction that is used to edit and run programs. It is not intended to be used in programs. The upper half of the operand determines what action to perform (see below)

### Meta instructions
- 111100: Sets the program counter, data bank, and program bank to 0 and begins executing the program
- 111101: Swaps between *set program counter* mode and *set program bank register* mode
- 111110: Sets the upper 2 bits of the program counter / program bank value
- 111111: Sets the lower 2 bits of the program counter / program bank value

### Final Notes:
- To use the external assembler, drag an assembly file onto the window. This will copy the binary program onto your keyboard. Simply paste this text into a new file and drag that into the simulator to run the program
- Add "% A B" before a block of code to change where it appears in program memory. A is the program bank number and B is the location within that bank
- You can create an edit programs directly in the simulator. Just set the input bits and push enter. This will copy the input into the program memory location referenced by the program counter
- After you've input the program, you can run it by entering 11110000
- Press keys 1-8 to set the input bits
- Press R to reset the computer
- Press L to stop the execution of the current program
- Press S to toggle a view of data memory
- Press Q to toggle turbo mode
- Press SPACE to toggle pause mode
