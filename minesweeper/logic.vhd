-- TYPE board_status IS ARRAY(0 TO 7, 0 TO 7); -- bool
-- TYPE board_value IS ARRAY(0 TO 7, 0 TO 7); -- int from 0 to 8, 9 (bomb), 10 (flag)

-- determine the status of the cell
-- input: IN ports <- user input (buttons, switches)
---- output
--PACKAGE board_layout_pkg IS
--	subtype small_range is natural range 0 to 10;
--	subtype smallest_range is natural range 0 to 1;
--	type board_size is array (0 to 7, 0 to 7) of small_range;
--	type board_bool is array (0 to 7, 0 to 7) of smallest_range;
--	type user_pos is array(0 TO 1) of small_range;
--END board_layout_pkg;

LIBRARY work;
USE work.ALL;
USE work.board_layout_pkg.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY logic IS
	PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		-- user input
		buttons : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		switches : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		
		VGA_UPDATE : OUT STD_LOGIC;
		cell_status : INOUT board_bool;
		cell_flagged : INOUT board_bool;
		cell_value : INOUT board_size;
		cur_sel_cell : INOUT user_pos;
		T_one : OUT std_logic_vector(3 downto 0);
		T_two : OUT std_logic_vector(3 downto 0)
	);
END logic;



ARCHITECTURE struct OF logic IS
-- SINGAL cell_status_signal
	COMPONENT board_generator
			
		PORT(	CLOCK_50, start_randomizer 	: in std_logic;
				banned_position 					: in user_pos;
				board_output 						: out board_size;
				completed							: inout std_logic);

	END COMPONENT;

	SIGNAL game_over : STD_LOGIC := '0';
	SIGNAL first_pressed : STD_LOGIC := '0';
	signal start_gen : STD_LOGIC := '0';
	SIGNAL check_win : STD_LOGIC := '1';
	signal finished_gen : STD_LOGIC := '0';
	signal ban_position : user_pos;
	--signal counter : unsigned(29 downto 0) := "000000000000000000000000000000";
	signal button_state : std_logic_vector(3 downto 0) := "1111";
	signal switch_state : std_logic := '0';
	
	type queue is array (0 to 20) of user_pos;

	--signal neg_pos: user_pos := (-1, -1);
	signal write_ptr: natural:=0; -- points to next open slot
	signal expl_q: queue;
	signal new_cell_pos: user_pos;

BEGIN
	
	U1: board_generator PORT MAP
		(CLOCK_50				=>	clk,
		 start_randomizer		=> start_gen,
		 banned_position		=> ban_position,
		 board_output 			=> cell_value,
		 completed				=> finished_gen
		);

	
	user_input: PROCESS (clk, buttons, finished_gen)
	-- switch 0 == 0 for playing
	-- switch 0 == 1 for game over/reset
	BEGIN
	-- generate a new board when sw = 1
		T_one		<= std_logic_vector(to_unsigned(cur_sel_cell(0), 4));
		T_two		<= std_logic_vector(to_unsigned(cur_sel_cell(1), 4));
	-- start the game when sw=0	
	-- initialize blank board
		if finished_gen = '1' then
			start_gen <='0';
		end if;
		
		VGA_UPDATE <= '1';
		IF (switches(0) = '1') THEN
			first_pressed <= '0';
			cur_sel_cell <= (0, 0);
			FOR i IN 0 TO 7 LOOP -- Column
				FOR j IN 0 TO 7 LOOP -- Row
					cell_status(i, j) <= 0;
					cell_flagged(i, j) <= 0;
				END LOOP;
			END LOOP;
		ENd IF;
			
		
		-- ←↑↓→
		if(rising_edge(CLK)) then
			--counter <= counter + 1;
			IF (buttons(0)='0' and button_state(0) = '1') THEN
			-- go left
				--button_state(0) <= buttons(0);
				IF (cur_sel_cell(0) > 0) THEN
					cur_sel_cell(0) <= cur_sel_cell(0) - 1;
				ELSE 
					cur_sel_cell(0) <= 7;
				END IF;
				
			-- go right
			ELSIF (buttons(1)='0' and button_state(1) = '1') THEN
				--button_state(1) <= buttons(1);
				IF (cur_sel_cell(0) < 7) THEN
					cur_sel_cell(0) <= cur_sel_cell(0) + 1;
				ELSE 
					cur_sel_cell(0) <= 0;
				END IF;
				
			-- go down
			ELSIF (buttons(2)='0' and button_state(2) = '1') THEN
				--button_state(2) <= buttons(2);
				IF (cur_sel_cell(1) < 7) THEN
					cur_sel_cell(1) <= cur_sel_cell(1) + 1;
				ELSE 
					cur_sel_cell(1) <= 0;
				END IF;
				
			-- go up
			ELSIF (buttons(3)='0' and button_state(3) = '1') THEN
				--button_state(3) <= buttons(3);
				IF (cur_sel_cell(1) > 0) THEN
					cur_sel_cell(1) <= cur_sel_cell(1) - 1;
				ELSE 
					cur_sel_cell(1) <= 7;
				END IF;
			end if;
			button_state(0) <= buttons(0);
			button_state(1) <= buttons(1);
			button_state(2) <= buttons(2);
			button_state(3) <= buttons(3);
		else
			cur_sel_cell <= cur_sel_cell;
		end if;
		
		

		
			IF (switches(1)='1') THEN
				-- click (closed -> open)
				IF (first_pressed='0') THEN
					--first press
					ban_position <= cur_sel_cell;
					-- board is now partially open
					first_pressed <= '1';
					start_gen <='1';
				-- ELSE 
				elsif finished_gen = '1' then
					cell_status(cur_sel_cell(0), cur_sel_cell(1)) <= 1;
					IF (cell_value(cur_sel_cell(0), cur_sel_cell(1)) = 9) THEN -- hit a bomb
						game_over <= '1'; -- lost
					ELSIF (cell_value(cur_sel_cell(0), cur_sel_cell(1)) = 0) THEN -- space
					-- initialize
					  write_ptr <= 0;
						--for l in 0 to 63 loop
							--expl_q(l) <= neg_pos;
						--end loop;
					  expl_q(write_ptr) <= cur_sel_cell;
					  write_ptr <= write_ptr + 1;
					  
					  
					  for l in 0 to 20 loop
						  if l<write_ptr then
								for i in -1 to 1 loop
									 for j in -1 to 1 loop
										-- for every adjacent cell, check if blank
										if (expl_q(l)(0)+i>=0 and expl_q(l)(0)+i<=7) and (expl_q(l)(1)+j>=0 and expl_q(l)(1)+j<=7) then -- in range
											  new_cell_pos(0)<=expl_q(l)(0)+i;
											  new_cell_pos(1)<=expl_q(l)(1)+j;

												if cell_status(new_cell_pos(0), new_cell_pos(1))=0 then -- it's closed, open it
													 cell_status(new_cell_pos(0), new_cell_pos(1))<=1;

													 if cell_value(new_cell_pos(0), new_cell_pos(1)) = 0 then -- blank, enter to queue to open further
														  expl_q(write_ptr) <= cur_sel_cell;
														  write_ptr <= write_ptr+1;
													 else -- guaranteed to be a number, just open it
															expl_q(write_ptr) <= expl_q(write_ptr);
													 end if;
												 else
													null;
												end if;
											else
												null;
										  end if;
									 end loop;
								end loop;
							end if;
					  end loop;
		  
					END IF;

					FOR i IN 0 TO 7 LOOP -- Column
						FOR j IN 0 TO 7 LOOP -- Row
							IF (NOT (cell_status(i, j)=1 or cell_flagged(i, j)=1)) THEN
								check_win <= '0';
							END IF;
						END LOOP;
					END LOOP;
					IF (check_win='1') then
						game_over <= '1'; -- won
					END IF;
				end if;
			end if;
			if(rising_edge(clk)) then
				if (switches(2)='1' and switch_state='0') THEN
					-- flag
					IF(cell_flagged(cur_sel_cell(0), cur_sel_cell(1))=0) THEN
						cell_flagged(cur_sel_cell(0), cur_sel_cell(1)) <= 1;
					ELSE
						cell_flagged(cur_sel_cell(0), cur_sel_cell(1)) <= 0;
					END IF;
				END IF;
			switch_state <= switches(2);
			else
				cell_flagged <= cell_flagged;
		end if;
	END PROCESS user_input;
END struct;