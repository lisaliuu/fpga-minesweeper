PACKAGE board_layout_pkg IS
	subtype small_range is natural range 0 to 10;
	subtype smallest_range is natural range 0 to 1;
	type board_size is array (0 to 7, 0 to 7) of small_range;
	type board_bool is array (0 to 7, 0 to 7) of smallest_range;
	type user_pos is array(0 TO 1) of small_range;
END board_layout_pkg;

LIBRARY work;
USE work.ALL;
USE work.board_layout_pkg.ALL;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.ALL;

ENTITY open_cell IS
    PORT(
        cur_sel_cell: IN user_pos;
        cell_status: IN board_size;
        cell_value: IN board_size;
		  
    );
END open_cell;

ARCHITECTURE struct OF open_cell IS
type queue is array (0 to 63) of user_pos;

--signal read_ptr: natural :=0;
signal write_ptr: natural:=0; -- points to next open slot
signal neg: user_pos:=(-1,-1);
signal expl_q: queue;
signal new_cell_pos: user_pos;

BEGIN

open_proc : process(cell_status) -- sensitive to clicked open
    BEGIN
	 
    if cell_value(cur_sel_cell(0), cur_sel_cell(1)) = 0 then
        -- opened blank space

        -- initialize
		  for p in 0 to 63 loop
				expl_q(p)<=neg;
			end loop;
			
        --read_ptr <= 0;
        write_ptr <= 0;

        expl_q(write_ptr) <= cur_sel_cell;
        write_ptr <= write_ptr + 1;
		  
       for l in 0 to 63 loop
			if not (expl_q(l)(0) = -1 and expl_q(l)(1)=-1) then
            for i in -1 to 1 loop
                for j in -1 to 1 loop
						-- for every adjacent cell, check if blank
                    new_cell_pos(0)<=expl_q(l)(0)+i;
                    new_cell_pos(1)<=expl_q(l)(1)+j;

                    if (new_cell_pos(0)>=0 and new_cell_pos(0)<=7) and (new_cell_pos(1)>=0 and new_cell_pos(1)<=7) then -- in range
                        if cell_status(new_cell_pos(0), new_cell_pos(1))=0 then -- it's closed, open it
                            --cell_status(new_cell_pos(0), new_cell_pos(1))<=1;
										null;
                            if cell_value(new_cell_pos(0), new_cell_pos(1)) = 0 then -- blank, enter to queue to open further
                                expl_q(write_ptr) <= cur_sel_cell;
                                write_ptr <= write_ptr+1;
                            else -- guaranteed to be a number, just open it
											null;
                            end if;
								 else
									null;
                        end if;
							else
								null;
                    end if;
                end loop;
            end loop;

            -- read_ptr <= read_ptr+1;
				end if;
        end loop;
        end if;
    end process open_proc;
end struct;
