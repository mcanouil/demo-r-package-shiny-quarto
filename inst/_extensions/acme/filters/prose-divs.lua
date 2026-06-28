-- Style fenced divs as branded callouts in HTML output.
-- Usage in a document:
--   ::: prose-context
--   Background a reader needs before the result.
--   :::
--   ::: prose-interpret
--   What the result means.
--   :::
-- The classes are styled by acme.scss. On non-HTML output the divs pass
-- through unchanged.

local known = {
  ["prose-context"] = true,
  ["prose-interpret"] = true,
}

function Div(el)
  if not quarto.doc.is_format("html:js") then
    return el
  end
  for _, class in ipairs(el.classes) do
    if known[class] then
      return el
    end
  end
  return el
end
