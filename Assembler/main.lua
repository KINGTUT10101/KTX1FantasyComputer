--[[
    - This program takes text files written in KTX1 assembly
        and translates them into machine language
    - Errors and warnings will be printed to the console
    - The result of the conversion will be copied to the clipboard
    - The user will need to paste the result into a file themselves

    FILE FORMAT:
    - Each section includes a subheader that indicates the
        bank and instruction numbers, separated by spaces
    - The subheaders are proceded by "%"
    - Each line of code includes a three-character instruction name,
        followed by an integer
    - Whitespace is ignored
]]


-- Declares / initializes the local variables
output = ""


-- Declares / initializes the local variables
local instructions = {
    END = "0000",
    LDU = "0001",
    LDL = "0010",
    ATM = "0011",
    MTA = "0100",
    ADD = "0101",
    SUB = "0110",
    AND = "0111",
    ORR = "1000",
    NOT = "1001",
    BNZ = "1010",
    BRT = "1011",
    SDD = "1100",
    SVM = "1101",
    SMB = "1110",
}


-- Defines the functions
local function convertToBinary (n)
    local bits = {false, false, false, false}
    local result = ""

    -- Converts the value back into a binary value
    for i = 4, 1, -1 do
        bits[i] = n % 2 == 1
        n = math.floor (n / 2)
    end

    for i = 1, 4 do
        if bits[i] == true then
            result = result .. 1
        else
            result = result .. 0
        end
    end

    return result
end

local function findNthNumber (str, n)
    local currentNumber = ""
    local foundNumbers = 0
  
    for i = 1, #str do
      local char = str:sub(i,i)
  
      if tonumber(char) then
        currentNumber = currentNumber .. char
      elseif currentNumber ~= "" then
        foundNumbers = foundNumbers + 1
        if foundNumbers == n then
          -- Return the binary string
          return convertToBinary (currentNumber)
        end
        currentNumber = ""
      end
    end
  
    if currentNumber ~= "" and foundNumbers + 1 == n then
      -- Convert the number to a 4-bit binary string
      return convertToBinary (currentNumber)
    end
  
    return nil
end

local function findFirstWord (str)
    for word in str:gmatch("%a+") do -- match only words containing letters
        if #word == 3 then -- check if the word has exactly 3 letters
            return word
        end
    end

    return nil -- if no matching word found, return nil
end
  

local function readSubheader (line)
    local binaryVals = {}
    
    output = output .. "%"

    -- Reads the numbers from the file and appends them to the output as binary values
    binaryVals[1] = findNthNumber (line, 1)
    binaryVals[2] = findNthNumber (line, 2)

    if binaryVals[1] ~= nil and binaryVals[2] ~= nil then
        output = output .. binaryVals[1]
        output = output .. binaryVals[2]
        output = output .. "\n"

    else
        print ("ERROR: Unable to find subheader values in '" .. line .. "'")
    end
end

local function readInstruction (line)
    local inst = findFirstWord (line)
    local value = findNthNumber (line, 1)
    local opcode

    if inst ~= nil then
        string.upper (inst)
        opcode = instructions[inst]
    end

    if value ~= nil and opcode ~= nil then
        output = output .. opcode
        output = output .. value
        output = output .. "\n"

    else
        print ("ERROR: Invalid instruction in '" .. line .. "'")
    end
end


function love.load ()
	
end


function love.update (dt)
	
end


function love.draw ()
    love.graphics.print ("Drop files here!", 65, 90)
end


function love.keypressed (key)
	
end


function love.filedropped (file)
    output = ""
    
    print (file:getFilename ())
    
    file:open ("r")

    local iterator = file:lines ()

    -- Reads each line in the file
    for line in iterator do
        -- Ignores blank lines
        if line ~= "" then
            local done = false
            local i = 1

            -- Reads the first character in the line
            while done == false do
                local char = string.sub (line, i, i)
                
                -- Ignores whitespace
                if char ~= "" then
                    -- Subheader
                    if char == "%" then
                        readSubheader (line)
                    
                    -- Opcode
                    elseif type (tonumber (char)) ~= "number" then
                        readInstruction (line)

                    else
                        print ("ERROR: Invalid character at '" .. char .. "' in '" .. line .. "'")
                    end

                    done = true
                end

                i = i + 1
            end
        end
    end

    love.system.setClipboardText (output)

    print ("Conversion finished. Result copied to clipboard")
    print ()
end