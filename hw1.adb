-------------------------------------------------------------------------------
-- 
-- Eric Laursen, 10 April 2017, CS 442P-003 HW 1
--
-- hw1.adb
--
-------------------------------------------------------------------------------

with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;
with Ada.Text_IO;          use Ada.Text_IO;

with Board;                use Board;

procedure HW1 is
   
   Nr_Rows        : Integer := 0;
   Nr_Columns     : Integer := 0;
   Nr_Squares     : Integer := 0; -- Total nr squares in board
   Nr_Pieces      : Integer := 0; -- Number of pieces given to me
   
   Pieces         : String (1 .. 25); -- List of pieces given to me
   Piece_Tally    : Tally_Type := (others => 0);
   
   Input_Is_Valid : Boolean := True;
   
begin
   
   Get (Nr_Rows);
   Get (Nr_Columns);
   
   Skip_Line;
   
   Nr_Squares := Nr_Rows * Nr_Columns;
   
   Get_Line (Pieces, Nr_Pieces);  
   
   
   -- Initial sanity check:
   --    Is the board greater than 6 tiles in either direction?
   --    Is the size of the board a mulitple of 4?
   --    Were the proper number of puzzle pieces given?
   -- If any of those are true, flag the input as invalid.
   
   if ((Nr_Rows > 10) or (Nr_Columns > 10)) then
      Input_Is_Valid := False;   
   elsif (Nr_Squares mod 4 /= 0) then
      Input_Is_Valid := False;   
   elsif (Nr_Pieces * 4 /= Nr_Squares) then
      Input_Is_Valid := False;   
   end if;
   
   
   -- The board is the correct size and there are the right
   --   nr of pieces. Check to make sure they're valid pieces.
   -- Also tally up the numbers of each type of piece that was input
   
   for I in 1 .. Nr_Pieces loop
      case Pieces(I) is
         when 'I' =>
            Piece_Tally('I') := Piece_Tally('I') + 1;
         when '5' =>
            Piece_Tally('5') := Piece_Tally('5') + 1;
         when '2' =>
            Piece_Tally('2') := Piece_Tally('2') + 1;
         when 'T' =>
            Piece_Tally('T') := Piece_Tally('T') + 1;
         when 'L' =>
            Piece_Tally('L') := Piece_Tally('L') + 1;
         when 'P' => 
            Piece_Tally('P') := Piece_Tally('P') + 1;
         when 'O' =>
            Piece_Tally('O') := Piece_Tally('O') + 1;
         when others =>
            Input_Is_Valid := False;  -- The input wasn't a valid piece.
      end case;
   end loop;
   
   
   -- Check for an odd number of T's. If found, flag the input as invalid.
   --   It's a bit of a misnomer, because it's valid input, just not solvable
   --   due to the T parity problem (if all the T's cover more of one color of
   --   square than the other, then there's no solution).
   
   if (Piece_Tally('T') mod 2 /= 0) then
      Input_Is_Valid := False;
   end if;
   
   
   if (Input_Is_Valid = False) then
      Put_Line ("?");
   else
      Play_Board (Nr_Rows, Nr_Columns, Piece_Tally, Nr_Pieces);
   end if;
   
end HW1;
