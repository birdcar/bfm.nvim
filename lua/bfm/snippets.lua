local M = {}

function M.setup()
  local ls = require("luasnip")
  local s = ls.snippet
  local t = ls.text_node
  local i = ls.insert_node
  local c = ls.choice_node

  ls.add_snippets("markdown", {
    s("@callout", {
      t("@callout type="),
      c(1, {
        t("info"),
        t("warning"),
        t("danger"),
        t("success"),
        t("note"),
      }),
      t({ "", "" }),
      i(2, "Content here"),
      t({ "", "@endcallout" }),
    }),

    s("@embed", {
      t("@embed "),
      i(1, "https://"),
      t({ "", "" }),
      i(2, "Caption"),
      t({ "", "@endembed" }),
    }),

    s("task", {
      t("- ["),
      c(1, {
        t(" "),
        t("x"),
        t(">"),
        t("<"),
        t("-"),
        t("o"),
        t("!"),
      }),
      t("] "),
      i(2, "Task description"),
    }),

    s("//due", {
      t("//due:"),
      i(1, os.date("%Y-%m-%d")),
    }),

    s("//every", {
      t("//every:"),
      c(1, {
        t("daily"),
        t("weekly"),
        t("monthly"),
        t("quarterly"),
        t("yearly"),
      }),
    }),

    s("//cron", {
      t("//cron:"),
      i(1, "0 9 * * 1"),
    }),
  })
end

return M
