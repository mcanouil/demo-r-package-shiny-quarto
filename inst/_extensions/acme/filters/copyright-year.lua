-- Inject the current year into copyright.statement.
function Meta(meta)
  if meta.copyright == nil or meta.copyright.statement == nil then
    return meta
  end

  local statement = pandoc.utils.stringify(meta.copyright.statement)
  local year = os.date("%Y")

  if not statement:find(year, 1, true) then
    statement = statement:gsub("Copyright%s*", "Copyright " .. year .. " ", 1)
  end

  meta.copyright.statement = pandoc.Inlines({ pandoc.Str(statement) })
  return meta
end
