
# Whether to use conform.nvim or none-ls.nvim

Lazyvim doesn't install it by default since [10.x](https://www.lazyvim.org/news#10x)
- conform.nvim is now the default formatter
- nvim-lint is now the default linter

## AI answer

I recommend conform.nvim over none-ls.nvim for code formatting for several key reasons:

1. conform.nvim is actively maintained and has a clearer future, while none-ls.nvim (formerly null-ls) is in maintenance mode since its original author stepped down

2. conform.nvim has better performance because it:
   - Uses Neovim's built-in LSP client
   - Runs formatters in parallel
   - Formats code asynchronously

3. conform.nvim has simpler configuration since it focuses solely on formatting, while none-ls handles multiple concerns (formatting, diagnostics, code actions)

4. It works seamlessly with LSP formatting and allows you to chain multiple formatters together

However, if you specifically need diagnostics or code actions that aren't available through regular LSP servers, none-ls.nvim might still be useful as part of your setup. But for pure formatting needs, conform.nvim is the better choice.


