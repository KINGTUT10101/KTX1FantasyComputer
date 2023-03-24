-- Declares / initializes the local variables
local lastUpdate = 0
local tickSpeed = 1/8
local showPmemory = true

local input = {false, false, false, false, false, false, false, false}

local dmemory = {} -- Data memory
local pmemory = {} -- Program memory
local vmemory = {} -- Video memory
local display = 0 -- The value to display to the screen

local accumulator = {false, false, false, false, false, false, false, false} -- Holds values that the CPU will operate on
local programCounter = {false, false, false, false, false, false, false, false} -- Holds the return address and the address of the next instruction in memory
local bankRegister = {false, false, false, false, false, false, false, false} -- Holds the bank numbers for data and program memory

-- Holds 8 bits that determine the states of various CPU functions
-- [7]: PC/bank setting, [8]: execute mode
local stateRegister = {false, false, false, false, false, false, false, false}

local instructions = {
    -- Ends the current program if one is currently executing
    [0] = function ()
        -- Sets the memory bank numbers
        bankRegister = {false, false, false, false, false, false, false, false}

        -- Sets the program counter
        programCounter = {false, false, false, false, false, false, false, false}

        -- Sets the input
        input = {false, false, false, false, false, false, false, false}

        -- Sets execute mode
        stateRegister[8] = false

        print ("0: End program")
    end,
    
    -- Loads the upper half of the accumulator with a 4-bit value
    function ()
        accumulator[1] = input[5]
        accumulator[2] = input[6]
        accumulator[3] = input[7]
        accumulator[4] = input[8]

        print ("1: Set upper accumulator")
    end,

    -- Loads the lower half of the accumulator with a 4-bit value
    function ()
        accumulator[5] = input[5]
        accumulator[6] = input[6]
        accumulator[7] = input[7]
        accumulator[8] = input[8]

        print ("2: Set lower accumulator")
    end,

    -- Copies the accumulator's value into the specified memory address
    function ()
        local address = 0
        local dbank = 0

        -- Finds the address
        for i = 0, 3 do
            if input[8 - i] == true then
                address = address + 2 ^ i
            end
        end

        -- Loads the dbank number from the bank register
        for i = 0, 3 do
            if bankRegister[4 - i] == true then
                dbank = dbank + 2 ^ i
            end
        end

        -- Copies the data into memory
        for i = 1, 8 do
            dmemory[dbank][address][i] = accumulator[i]
        end

        print ("3: Copy to memory")
    end,

    -- Copies a value at the specified memory address into the accumulator
    function ()
        local address = 0
        local dbank = 0

        -- Finds the address
        for i = 0, 3 do
            if input[8 - i] == true then
                address = address + 2 ^ i
            end
        end

        -- Loads the dbank number from the bank register
        for i = 0, 3 do
            if bankRegister[4 - i] == true then
                dbank = dbank + 2 ^ i
            end
        end

        -- Copies the data into the accumulator
        for i = 1, 8 do
            accumulator[i] = dmemory[dbank][address][i]
        end

        print ("4: Copy to accumulator")
    end,

    -- Takes the sum of the accumulator and the specified memory address and stores it in the accumulator
    function ()
        local value = 0
        local address = 0
        local dbank = 0

        -- Gets the value stored in the accumulator
        for i = 0, 7 do
            if accumulator[8 - i] == true then
                value = value + 2 ^ i
            end
        end

        -- Finds the address
        for i = 0, 3 do
            if input[8 - i] == true then
                address = address + 2 ^ i
            end
        end

        -- Loads the dbank number from the bank register
        for i = 0, 3 do
            if bankRegister[4 - i] == true then
                dbank = dbank + 2 ^ i
            end
        end

        -- Adds the value stored at the memory address
        for i = 0, 7 do
            if dmemory[dbank][address][8 - i] == true then
                value = value + 2 ^ i
            end
        end

        -- Converts the value back into a binary value
        for i = 8, 1, -1 do
            accumulator[i] = value % 2 == 1
            value = math.floor (value / 2)
        end

        print ("5: Add")
    end,

    -- Takes the difference of the accumulator and the specified memory address and stores it in the accumulator
    function ()
        local value = 0
        local address = 0
        local dbank = 0

        -- Gets the value stored in the accumulator
        for i = 0, 7 do
            if accumulator[8 - i] == true then
                value = value + 2 ^ i
            end
        end

        -- Finds the address
        for i = 0, 3 do
            if input[8 - i] == true then
                address = address + 2 ^ i
            end
        end

        -- Loads the dbank number from the bank register
        for i = 0, 3 do
            if bankRegister[4 - i] == true then
                dbank = dbank + 2 ^ i
            end
        end

        -- Subtracts the value stored at the memory address
        for i = 0, 7 do
            if dmemory[dbank][address][8 - i] == true then
                value = value - 2 ^ i
            end
        end

        -- Converts the value back into a binary value
        for i = 8, 1, -1 do
            accumulator[i] = value % 2 == 1
            value = math.floor (value / 2)
        end

        print ("6: Subtract")
    end,

    -- ANDs the value of the accumulator and the specified memory address and stores it in the accumulator
    function ()
        local address = 0
        local dbank = 0

        -- Finds the address
        for i = 0, 3 do
            if input[8 - i] == true then
                address = address + 2 ^ i
            end
        end

        -- Loads the dbank number from the bank register
        for i = 0, 3 do
            if bankRegister[4 - i] == true then
                dbank = dbank + 2 ^ i
            end
        end

        -- Copies the data into the accumulator
        for i = 1, 8 do
            accumulator[i] = accumulator[i] and dmemory[dbank][address][i]
        end

        print ("7: AND")
    end,

    -- ORs the value of the accumulator and the specified memory address and stores it in the accumulator
    function ()
        local address = 0
        local dbank = 0

        -- Finds the address
        for i = 0, 3 do
            if input[8 - i] == true then
                address = address + 2 ^ i
            end
        end

        -- Loads the dbank number from the bank register
        for i = 0, 3 do
            if bankRegister[4 - i] == true then
                dbank = dbank + 2 ^ i
            end
        end

        -- Copies the data into the accumulator
        for i = 1, 8 do
            accumulator[i] = accumulator[i] or dmemory[dbank][address][i]
        end

        print ("8: OR")
    end,

    -- NOTs the value of the accumulator
    function ()
        -- Copies the data into the accumulator
        for i = 1, 8 do
            accumulator[i] = not accumulator[i]
        end

        print ("9: NOT")
    end,

    -- Branches to the specified location in program memory if the accumulator does not equal 0
    function ()
        local value = 0

        -- Gets the value stored in the accumulator
        for i = 0, 7 do
            if accumulator[8 - i] == true then
                value = value + 2 ^ i
            end
        end

        -- Checks if the accumulator does not equal 0
        if value ~= 0 then
            -- Copies the lower half of the PC into the upper half and copies the specified memory address into the lower half
            for i = 1, 4 do
                programCounter[i] = programCounter[i + 4]
                programCounter[i + 4] = input[i + 4]
            end
        else
            local address = 0

            -- Gets the address in the program counter
            for i = 0, 3 do
                if programCounter[8 - i] == true then
                    address = address + 2 ^ i
                end
            end
            
            -- Increments the program counter
            address = address + 1
            for i = 8, 5, -1 do
                programCounter[i] = address % 2 == 1
                address = math.floor (address / 2)
            end
        end

        print ("10: Branch if not 0")
    end,

    -- Returns to the location stored in the upper half of the program counter
    function ()
        -- Copies the upper half of the PC into the lower half and zeros the upper half
        for i = 1, 4 do
            programCounter[i + 4] = programCounter[i]
            programCounter[i] = false
        end

        print ("11: Branch return")
    end,

    -- Copies a value from the specified memory address into the display
    function ()
        local address = 0
        local dbank = 0

        -- Finds the address
        for i = 0, 3 do
            if input[8 - i] == true then
                address = address + 2 ^ i
            end
        end

        -- Loads the dbank number from the bank register
        for i = 0, 3 do
            if bankRegister[4 - i] == true then
                dbank = dbank + 2 ^ i
            end
        end

        display = 0

        -- Gets the value stored in the accumulator
        for i = 0, 7 do
            if dmemory[dbank][address][8 - i] == true then
                display = display + 2 ^ i
            end
        end

        print ("12: Set display")
    end,

    -- Toggles a pixel referenced by the specified memory address
    function ()
        local address = 0
        local dbank = 0
        local x, y = 0, 0

        -- Finds the address
        for i = 0, 3 do
            if input[8 - i] == true then
                address = address + 2 ^ i
            end
        end

        -- Loads the dbank number from the bank register
        for i = 0, 3 do
            if bankRegister[4 - i] == true then
                dbank = dbank + 2 ^ i
            end
        end

        -- Gets the value from dmemory
        for i = 0, 3 do
            if dmemory[dbank][address][4 - i] == true then
                x = x + 2 ^ i
            end
        end

        for i = 0, 3 do
            if dmemory[dbank][address][8 - i] == true then
                y = y + 2 ^ i
            end
        end

        vmemory[x][y] = not vmemory[x][y]

        print ("13: Toggle pixel")
    end,

    -- Switches the data and program memory banks referenced by the upper and lower halves of the accumulator, respectively
    -- Sets the program counter to the specified address
    function ()
        -- Sets the bank register
        for i = 1, 8 do
            bankRegister[i] = accumulator[i]
        end

        -- Sets the program counter
        for i = 5, 8 do
            programCounter[i] = input[i]
        end

        print ("14: Switch memory banks")
    end,

    -- Meta instruction. Used for editing and running code
    -- The first half of the operand is used to select a meta operation
    function ()
        -- Runs the program starting at B0P$0 using data bank D0
        if input[5] == false and input[6] == false then
            -- Sets the memory bank numbers
            bankRegister = {false, false, false, false, false, false, false, false}
            -- Sets the program counter
            programCounter = {false, false, false, false, false, false, false, false}
            -- Sets execute mode
            stateRegister[8] = true

            print ()
            print ("Program start")

        -- Swaps between set PC mode and set bank register mode
        elseif input[5] == false and input[6] == true then
            stateRegister[7] = not stateRegister[7]

            print ("Meta: switch set mode")
        
        -- Sets the 3rd quadrant of the PC / bank register
        elseif input[5] == true and input[6] == false then
            if stateRegister[7] == true then
                programCounter[5] = input[7]
                programCounter[6] = input[8]
            else
                bankRegister[5] = input[7]
                bankRegister[6] = input[8]
            end

            for i = 5, 8 do
                programCounter[i] = false
            end

            print ("Meta: set 3rd quadrant")

        -- Sets the 4th quadrant of the PC / bank register
        else
            if stateRegister[7] == true then
                programCounter[7] = input[7]
                programCounter[8] = input[8]
            else
                bankRegister[7] = input[7]
                bankRegister[8] = input[8]
            end

            for i = 5, 8 do
                programCounter[i] = false
            end

            print ("Meta: set 4th quadrant")
        end
    end,
}


-- Defines the functions
function dmemory:clear ()
    for i = 0, 15 do
        dmemory[i] = {}
        for j = 0, 15 do
            dmemory[i][j] = {false, false, false, false, false, false, false, false}
        end
    end
end

function pmemory:clear ()
    for i = 0, 15 do
        pmemory[i] = {}
        for j = 0, 15 do
            pmemory[i][j] = {false, false, false, false, false, false, false, false}
        end
    end
end

function vmemory:clear ()
    for i = 0, 15 do
        vmemory[i] = {}
        for j = 0, 15 do
            vmemory[i][j] = false
        end
    end
end


function love.load ()
	-- Initializes memory
    dmemory:clear ()
    pmemory:clear ()
    vmemory:clear ()
end


function love.update (dt)
	if stateRegister[8] == true then
        -- Executes instructions every tick
        lastUpdate = lastUpdate + dt
        if lastUpdate >= tickSpeed then
            local address = 0
            local pbank = 0
            local inst = 0
            
            -- Gets the address in the program counter
            for i = 0, 3 do
                if programCounter[8 - i] == true then
                    address = address + 2 ^ i
                end
            end

            -- Loads the pbank number from the bank register
            for i = 0, 3 do
                if bankRegister[8 - i] == true then
                    pbank = pbank + 2 ^ i
                end
            end

            -- Loads the input
            for i = 1, 8 do
                input[i] = pmemory[pbank][address][i]
            end

            -- Finds and executes the instruction
            for i = 0, 3 do
                if pmemory[pbank][address][4 - i] == true then
                    inst = inst + 2 ^ i
                end
            end
            instructions[inst] ()

            -- Increments the program counter if necessary
            if inst ~= 10 and inst ~= 15 and inst ~= 14 and inst ~= 0 then
                -- Converts the value back into a binary value
                address = address + 1
                for i = 8, 5, -1 do
                    programCounter[i] = address % 2 == 1
                    address = math.floor (address / 2)
                end
            end

            lastUpdate = 0
        end
    end
end


function love.draw ()
    local pbank = 0
    local dbank = 0
    local address = 0

    -- Draws the screen border
    love.graphics.setColor (0.25, 0.25, 0.25, 1)
    love.graphics.rectangle ("fill", 0, 0, 20, 360)
    love.graphics.rectangle ("fill", 0, 0, 360, 20)
    love.graphics.rectangle ("fill", 340, 0, 20, 360)
    love.graphics.rectangle ("fill", 0, 340, 360, 20)

    love.graphics.setColor (0.10, 0.10, 0.10, 1)
    love.graphics.rectangle ("fill", 20, 20, 320, 320)
    
    -- Draws the pixels on the screen
    love.graphics.setColor (1, 1, 1, 1)
    for i = 0, 15 do
        for j = 0, 15 do
            if vmemory[j][i] == true then
                love.graphics.rectangle ("fill", i * 20 + 20, j * 20 + 20, 20, 20)
            end
        end
    end

    -- Draws the display value
    love.graphics.setColor (0.10, 0.10, 0.10, 1)
    love.graphics.rectangle ("fill", 360, 320, 40, 40)
    love.graphics.setColor (1, 1, 1, 1)
    love.graphics.print (display, 375, 335)

    -- Draws the input switches
    for i = 1, 8 do
        if input[i] == true then
            love.graphics.setColor (1, 0, 0, 1)
        else
            love.graphics.setColor (1, 1, 1, 1)
        end

        love.graphics.rectangle ("fill", i * 60 + 120, 500, 40, 40)
    end

    love.graphics.setColor (1, 1, 1, 1)
    for i = 1, 8 do
        love.graphics.print (tostring (input[i]), i * 60 + 120, 550)
    end

    -- Prints the execution mode status
    love.graphics.setColor (1, 1, 1, 1)
    love.graphics.print ("Execute: " .. tostring (stateRegister[8]), 700, 25)

    -- Prints the set mode status
    if stateRegister[7] == true then
        love.graphics.print ("Set: PC", 700, 50)
    else
        love.graphics.print ("Set: MB", 700, 50)
    end

    -- Prints the dbank value
    for i = 0, 3 do
        if bankRegister[4 - i] == true then
            dbank = dbank + 2 ^ i
        end
    end

    love.graphics.print ("Dbank: " .. dbank, 700, 75)

    -- Prints the pbank value
    for i = 0, 3 do
        if bankRegister[8 - i] == true then
            pbank = pbank + 2 ^ i
        end
    end

    love.graphics.print ("Pbank: " .. pbank, 700, 100)

    -- Prints the program counter value
    for i = 0, 3 do
        if programCounter[8 - i] == true then
            address = address + 2 ^ i
        end
    end

    love.graphics.print ("PC: " .. address, 700, 125)

    -- Prints the contents of memory
    if showPmemory == true then
        love.graphics.print ("Program Memory", 370, 25)

        for i = 0, 15 do
            if pbank == i then
                love.graphics.setColor (1, 0, 0, 1)
            else
                love.graphics.setColor (1, 1, 1, 1)
            end
            
            love.graphics.print ("B" .. i .. ":", 370, i * 15 + 50)

            for j = 0, 15 do
                local value = 0

                for k = 0, 3 do
                    if pmemory[i][j][4 - k] == true then
                        value = value + 2 ^ k
                    end
                end

                love.graphics.print (value, j * 18 + 410, i * 15 + 50)
            end
        end
    else
        love.graphics.print ("Data Memory", 610, 25)

        for i = 0, 15 do
            if dbank == i then
                love.graphics.setColor (1, 0, 0, 1)
            else
                love.graphics.setColor (1, 1, 1, 1)
            end
            
            love.graphics.print ("B" .. i .. ":", 370, i * 15 + 50)

            for j = 0, 15 do
                local value = 0

                for k = 0, 7 do
                    if dmemory[i][j][8 - k] == true then
                        value = value + 2 ^ k
                    end
                end

                love.graphics.print (value, j * 18 + 410, i * 15 + 50)
            end
        end
    end

    -- Prints the accumulator's value
    love.graphics.print ("Accumulator", 420, 300)

    for i = 1, 8 do
        if accumulator[i] == true then
            love.graphics.print (1, i * 15 + 405, 320)
        else
            love.graphics.print (0, i * 15 + 405, 320)
        end
    end
end


function love.keypressed (key)
	-- Resets the computer
    if key == "r" then
        dmemory:clear ()
        pmemory:clear ()
        vmemory:clear ()

        display = 0
        accumulator = {false, false, false, false, false, false, false, false}
        programCounter = {false, false, false, false, false, false, false, false}
        bankRegister = {false, false, false, false, false, false, false, false}
        stateRegister = {false, false, false, false, false, false, false, false}

    -- Changes the tick speed
    elseif key == "q" then
        if tickSpeed ~= 1/8 then
            tickSpeed = 1/8
        else
            tickSpeed = 1/64
        end

    -- Pauses the simulator
    elseif key == "space" then
        if tickSpeed ~= math.huge then
            tickSpeed = math.huge
        else
            tickSpeed = 1/8
        end
    
    -- Stops execution
    elseif key == "l" then
        if stateRegister[8] == true then
            instructions[0] ()
        end
    
    -- Swaps between showing dmemory and pmemory
    elseif key == "s" then
        showPmemory = not showPmemory
    
    -- Debug tool
    elseif key == "i" then
        for i = 1, 8 do
            print (pmemory[0][0][i])
        end
        print ()
    
    -- Toggles the input bits
    elseif type (tonumber(key)) == "number" and tonumber (key) > 0 then
        if stateRegister[8] == false then
            input[tonumber (key)] = not input[tonumber (key)]
        end

    -- Enters instructions into pmemory if the computer isn't executing anything
    elseif key == "return" then
        if stateRegister[8] == false then
            local address = 0
            local pbank = 0
            local meta = true
            
            -- Gets the address in the program counter
            for i = 0, 3 do
                if programCounter[8 - i] == true then
                    address = address + 2 ^ i
                end
            end

            -- Loads the pbank number from the bank register
            for i = 0, 3 do
                if bankRegister[8 - i] == true then
                    pbank = pbank + 2 ^ i
                end
            end

            -- Checks if the user inputted a meta instruction
            for i = 1, 4 do
                meta = meta and input[i]
            end

            if meta == true then
                instructions[15] ()
            else
                -- Adds the instruction to pmemory
                for i = 1, 8 do
                    pmemory[pbank][address][i] = input[i]
                end

                -- Increments the program counter
                -- Converts the value back into a binary value
                address = address + 1
                for i = 8, 5, -1 do
                    programCounter[i] = address % 2 == 1
                    address = math.floor (address / 2)
                end
            end

            -- Resets input
            for i = 1, 8 do
                input[i] = false
            end
        end
    end
end


function love.filedropped (file)
    love.keypressed ("r")
    
    file:open ("r")
    local iterator = file:lines ()

    -- Reads the file line by line
    for line in iterator do
        -- Checks if the line actually contains something
        -- I sure do love nested code!
        if line ~= "" then
            -- Checks the subheader to see which bank and address the following code should be placed into
            if string.sub (line, 1, 1) == "%" then
                local stub = string.sub (line, 2, 5)
                
                -- The upper half of the header holds the bank number
                for i = 1, 4 do
                    local bit = false

                    if string.sub (stub, i, i) == "1" then
                        bit = true
                    end
                    
                    bankRegister[i + 4] = bit
                end

                -- The lower half of the header holds the program counter value
                stub = string.sub (line, 6, 9)
                for i = 1, 4 do
                    local bit = false

                    if string.sub (stub, i, i) == "1" then
                        bit = true
                    end
                    
                    programCounter[i + 4] = bit
                end

            -- Translates and copies the code to pmemory
            else
                -- Copies the value into the input
                for i = 1, 8 do
                    local bit = false

                    if string.sub (line, i, i) == "1" then
                        bit = true
                    end

                    input[i] = bit
                end

                -- Simulates an enter keypress because I'm too lazy to put that code in a function
                love.keypressed ("return")
            end
        end
    end
end