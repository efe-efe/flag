function PrintTable(t, indent, done)
    if type(t) ~= "table" then return end
  
    done = done or {}
    done[t] = true
    indent = indent or 0
    
        local l = {}
        local canCompare = true
        for k, v in pairs(t) do
            table.insert(l, k)
            if type(k) == "table" then
                canCompare = false
            end
        end
    
        if canCompare then
            table.sort(l)
        end
        for k, v in ipairs(l) do
            if v ~= 'FDesc' then
                local value = t[v]
        
                if type(value) == "table" and not done[value] then
                    done [value] = true
                    print(string.rep ("\t", indent)..tostring(v)..":")
                    PrintTable (value, indent + 2, done)
                elseif type(value) == "userdata" and not done[value] then
                    done [value] = true
                    print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                    PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
                else
                    if t.FDesc and t.FDesc[v] then
                        print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
                    else
                        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                    end
                end
            end
        end
  end