struct Cride::Terminal::Render
  @editor : Cride::Editor
  @color : Color

  def initialize(@editor, @color)
  end

  private def render_cell(x, y, char)
    bg = if y == @editor.position.cursor_y
           # highlight the selected line
           @color.line
         else
           @color.bg
         end
    TermboxBindings.tb_change_cell x, y, char, @color.fg, bg
  end

  def editor
    TermboxBindings.tb_clear
    # Render the cursor and info, and present them to Termbox
    TermboxBindings.tb_set_cursor @editor.cursor_x_with_tabs, @editor.position.cursor_y

    # Render starting at the page_y line until the end of the terminal height
    @editor.file.rows[@editor.position.page_y..@editor.position.page_y + @editor.size.height].each_with_index do |row, y|
      x = 0
      width = @editor.size.width + 1 + @editor.tab_width row
      # Start to render at the page_x until the end of the terminal width
      if row[@editor.position.page_x]?
        row[@editor.position.page_x..@editor.position.page_x + width].each_char do |char|
          # highlight current line
          if char == '\t'
            @editor.tab_spaces.times do
              render_cell x, y, 32
              x += 1
            end
          else
            render_cell x, y, char.ord
            x += 1
          end
        end
      end
      # fill empty cells with spaces
      (x...width).each do |loc|
        render_cell loc, y, 32 # Space
      end
    end
  end
end
