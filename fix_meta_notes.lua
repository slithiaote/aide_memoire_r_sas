notes = 0

return {
  {
    Note = function (el)
      notes = notes + 1
      if notes >=  7 then
        return el
      else
        return ""
      end
    end,
  }
}