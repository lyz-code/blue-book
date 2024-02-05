
Moving around vim can be done in many ways, which an lead to being lost on how to do it well.

LazyVim has [a very nice way to deal with buffers](https://www.lazyvim.org/configuration/tips#navigating-around-multiple-buffers)
- Use `H` and `L` if the buffer you want to go to is visually close to where you are.
- Otherwise, if the buffer is open, use `<leader>,`
- For other files, use `<leader><space>`
- Close buffers you no longer need with `<leader>bd`
- `<leader>ss` to quickly jump to a function in the buffer you're on
- Using the [jump list](#Using-the-jump-list) with `<c-o>`, `<c-i>` and `gd` to navigate the code
- You can pin buffers with `<leader>bp` and delete all non pinned buffers with `<leader>bP`

# [Using the jump list](https://www.programmerhat.com/vim-ctrl-o/)

Vim has a feature called the “Jump List”, which saves all the locations you’ve recently visited, including their line number, column number, and what else not in the `.viminfo` file, to help you get exactly the position you were last in. Not only does it save the locations in your current buffer, but also previous buffers you may have edited in other Vim sessions. Which means, if you’re currently working on a file, and there aren’t many last-location saves in this one, you’ll be redirected to the previous file you had edited. But how do you do that? Simply press `Ctrl + O`, and it’ll get you back to the previous location you were in, or more specifically, your cursor was in.

If you want to go back to the newer positions, after you’re done with what you wanted to do, you can then press `Ctrl + i` to go back to the newer position. This is exceptionally useful when you’re working with a lot of project files at a time, and you need to go back and forth between multiple blocks in different files. This could instantly give you a boost, as you won’t need to have separate buffers opened up or windows to be setted up, you can simply jump between the files and edit them.

Ctrl + O is probably not meant for a single task, as far as Vim’s philosophy is concerned. The jumping mentioned in the previous section only works when you’re in Normal Mode, and not when you’re in Insert Mode. When you press Ctrl + O in Insert Mode, what happens instead is that you’ll enter Normal Mode, and be able to execute a single command, after which Vim will automatically switch back to Insert Mode.


