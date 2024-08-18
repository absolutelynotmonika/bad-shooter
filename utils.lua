utils = {
   float_precision = 10^6
}

function utils.randomfloat(min, max)
   return min + (math.random(utils.float_precision) / utils.float_precision) * (max-min)
end

function utils.tableIndexByValue(user_table, value)
   for i in ipairs(user_table) do
      if i == value  then return i end
   end

   return nil
end

return utils
