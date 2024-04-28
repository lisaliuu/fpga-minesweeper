- edit
  - repo/minesweeper/BOARD.vhd
  - repo/minesweeper/DE2_115_TOP.vhd
  - repo/minesweeper/LCD_Display.vhd
  - repo/minesweeper/logic.vhd
- don't edit
  - repo/minesweeper/VGA_SYNC.VHD
  - repo/minesweeper/video_PLL.vhd

Connect4

- DE2_115_TOP
  - logic
  - VGA_SYNC_module
    - video_PLL
  - board
  - LCD_Display

MineSweeper

- DE2 <- top level
  - logic
    - board_generator
      - lfsr
  - BOARD
  - VGA_SYNC_module
    - video_PLL
