-------------------------------------------------------------------------------
-- 
-- Eric Laursen, 10 April 2017, CS 442P-003 HW 1
--
-- board.adb
--
-------------------------------------------------------------------------------

with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

package body Board is
   
   Board_Array  : access Board_Type;
   
   Piece_Layout : array (Piece_Name_Type'Range) of Access Piece_Rotation_Type;
   
   Marker_Array : constant Marker_Type := ('a', 'b', 'c', 'd', 'e', 
                                           'f', 'g', 'h', 'i', 'j',
                                           'k', 'l', 'm', 'n', 'o',
                                           'p', 'q', 'r', 's', 't',
                                           'u', 'v', 'w', 'x', 'y',
                                           'z'); 
   
   ----------------------------------------------------------------------------
   procedure Play_Board (Nr_Rows     : in Integer;
                         Nr_Columns  : in Integer;
                         Piece_Tally : in Tally_Type;
                         Nr_Pieces   : in integer) is
      
   begin
      -- Initialize the board array
      
      Board_Array := new Board_Type (1 .. Nr_Rows, 1 .. Nr_Columns);
      
      for I in 1 .. Board_Array'Length(1) loop
         for J in 1 .. Board_Array'Length(2) loop
            Board_Array(I, J) := '.';  -- '.' for empty square
         end loop;
      end loop;
      
      
      -- Initialize the piece layout lookup table. The pieces are aligned so
      --   that the first square at the top is position (1, 1)
      
      Piece_Layout('O')    := new Piece_Rotation_Type (1 .. 1);
      Piece_Layout('O')(1) := ((1, 1), (1, 2), (2, 1), (2, 2));
      
      Piece_Layout('I')    := new Piece_Rotation_Type (1 .. 2);
      Piece_Layout('I')(1) := ((1, 1), (2, 1), (3, 1), (4, 1));
      Piece_Layout('I')(2) := ((1, 1), (1, 2), (1, 3), (1, 4));

      Piece_Layout('5')    := new Piece_Rotation_Type (1 .. 2);
      Piece_Layout('5')(1) := ((1, 1), (1, 2), (2, 0), (2, 1));
      Piece_Layout('5')(2) := ((1, 1), (2, 1), (2, 2), (3, 2));

      Piece_Layout('2')    := new Piece_Rotation_Type (1 .. 2);
      Piece_Layout('2')(1) := ((1, 1), (1, 2), (2, 1), (2, 3));
      Piece_Layout('2')(2) := ((1, 1), (2, 0), (2, 1), (3, 0));
      
      Piece_Layout('T')    := new Piece_Rotation_Type (1 .. 4);
      Piece_Layout('T')(1) := ((1, 1), (1, 2), (1, 3), (2, 2));
      Piece_Layout('T')(2) := ((1, 1), (2, 0), (2, 1), (3, 1));
      Piece_Layout('T')(3) := ((1, 1), (2, 0), (2, 1), (2, 2));
      Piece_Layout('T')(4) := ((1, 1), (2, 1), (2, 2), (3, 1));

      Piece_Layout('L')    := new Piece_Rotation_Type (1 .. 4);
      Piece_Layout('L')(1) := ((1, 1), (2, 1), (3, 1), (3, 2));
      Piece_Layout('L')(2) := ((1, 1), (2, -1), (2, 0), (2, 1));
      Piece_Layout('L')(3) := ((1, 1), (1, 2), (2, 2), (3, 2));
      Piece_Layout('L')(4) := ((1, 1), (1, 2), (1, 3), (2, 1));

      Piece_Layout('P')    := new Piece_Rotation_Type (1 .. 4);
      Piece_Layout('P')(1) := ((1, 1), (1, 2), (2, 1), (3, 1));
      Piece_Layout('P')(2) := ((1, 1), (1, 2), (1, 3), (2, 3));
      Piece_Layout('P')(3) := ((1, 1), (2, 1), (3, 0), (3, 1));
      Piece_Layout('P')(4) := ((1, 1), (2, 1), (2, 2), (2, 3));      
      
      if (Play_Piece (Piece_Tally, Nr_Pieces, 1) = True) then
         Print_Board (Board_Array);
      else
         Put_Line ("?");
      end if;
      
   end Play_Board;
   
   
   
   ----------------------------------------------------------------------------
   procedure Print_Board (Board_Array : access Board_Type) is
      
   begin
      for I in 1 .. Board_Array'Length(1) loop
         for J in 1 .. Board_Array'Length(2) loop
            Put (Board_Array(I, J));
         end loop;
         New_Line;
      end loop;
      
      New_Line (Standard_Error);
   end Print_Board;
   
   
   
   ----------------------------------------------------------------------------
   function Play_Piece (Piece_Tally     : in Tally_Type;
                        Piece_Count     : in Integer;
                        Current_Move_Nr : in integer) return Boolean is
      
      X, Y            : Positive := 1;
      Current_Piece   : Piece_Type;
      Current_Tally   : Tally_Type;
      Piece_In_Bounds : Boolean := True;
      No_Overlap      : Boolean := True;
      
   begin
      -- There are no pieces left to place, so it must be a solution...
      -- Send the "true" back up the pipeline
      
      if (Piece_Count = 0) then
         return True;
      end if;
      
      
      -- There's still at least one piece left, so try to place it
      
      
      -- Fill our working copy of the tally
      
      Current_Tally := Piece_Tally;
      
      
      -- Find the first empty (top to bottom, left to right) square
      
  Row_Loop:
      for I in 1 .. Board_Array'Length(1) loop
         
     Column_Loop:
         for J in 1 .. Board_Array'Length(2) loop
            if (Board_Array(I, J) = '.') then
               X := I;
               Y := J;
               
               exit Row_Loop;
            end if;
         end loop Column_Loop;
      end loop Row_Loop;

      
      -- Find the first playing piece and try to fit it on the board
      -- The logic is a bit squirrely... first, start iterating through
      --   the tally array, looking for the first non-zero tally (first
      --   piece still in play.
      --   Second, loop through each rotation of the piece and check if placing
      --   it at (X, Y) both keeps it fully on the board and doesn't overlap
      --   anything else on the board. If the placement is valid, then put it
      --   on the board, decrement the tally for that piece, and call myself
      --   again with the reduced tally and a decremented piece count.
      --   If it isn't valid, exit the inner loop and try the next rotation.
      --   Once the rotations are exhausted, try the next non-zero tally (this
      --   ensures that we don't try the same type of piece over again). If we
      --   hit the end of the tally list, return failure.
      
  Tally_Loop:
      for I in Piece_Name_Type'Range loop
         if (Piece_Tally(I) > 0) then
               
           Placement_Loop:
               for K in Piece_Layout(I)'Range loop
                  Current_Piece    := Piece_Layout(I)(K);
                  Current_Piece(1) := (Current_Piece(1)(1) + X - 1,
                                       Current_Piece(1)(2) + Y - 1);
                  Current_Piece(2) := (Current_Piece(2)(1) + X - 1,
                                       Current_Piece(2)(2) + Y - 1);
                  Current_Piece(3) := (Current_Piece(3)(1) + X - 1,
                                       Current_Piece(3)(2) + Y - 1);
                  Current_Piece(4) := (Current_Piece(4)(1) + X - 1,
                                       Current_Piece(4)(2) + Y - 1);
                  
                  
                  -- Check to see if offsetting the new piece makes it fall off
                  --   the board
                  
                  Piece_In_Bounds := True;  -- Reset in bounds flag
                  
                  for L in Piece_Type'Range loop
                     if (not ((Current_Piece(L)(1) in Board_Array'Range(1)) and
                              (Current_Piece(L)(2) in Board_Array'Range(2))))
                     then
                        Piece_In_Bounds := False;
                     end if;
                  end loop;
                  
                  
                  -- If the piece is fully on the board, then check for overlap
                  
                  if (Piece_In_Bounds) then
                     No_Overlap := True;
                     
                     for L in Piece_Type'Range loop
                        if (Board_Array(Current_Piece(L)(1),
                                        Current_Piece(L)(2)) /= '.') then
                           No_Overlap := False;
                        end if;
                     end loop;
                     
                     
                     -- The piece is on the board, if there's no overlap, then
                     --   place the new piece on the board
                     
                     if (No_Overlap) then
                        for L in Piece_Type'Range loop
                           -- The piece is in bounds and there's no overlap
                           --   so mark the board with the next letter
                           
                           Board_Array(Current_Piece(L)(1),
                                       Current_Piece(L)(2)) := 
                             Marker_Array(Current_Move_Nr);
                        end loop;
                        
                        
                        -- Decrement the tally for the piece we just placed
                        
                        Current_Tally(I) := Current_Tally(I) - 1;
                        
                        Print_Board (Board_Array);
                        
                        -- Try to place the next piece, if that fails, undo
                        --   what we did here and try the next rotation/piece
                        
                        if (Play_Piece (Current_Tally,
                                        Piece_Count - 1,
                                        Current_Move_Nr + 1)) then
                           return True;
                        else
                           -- Restore our tally
                           Current_Tally(I) := Current_Tally(I) + 1;
                           
                           
                           -- Clear our piece off the board
                           for L in Piece_Type'Range loop
                              Board_Array(Current_Piece(L)(1),
                                          Current_Piece(L)(2)) := '.';
                           end loop;
                           
                        end if; -- Play_Piece
                        
                     else
                        
                        Put (Standard_Error, "Overlap, depth ");
                        Put (Standard_Error, Current_Move_Nr, 0);
                        New_Line (Standard_Error, 2);
                        
                        Print_Board (Board_Array);
                        
                     end if;  -- No_Overlap
                     
                  else
                     
                     Put (Standard_Error, "Out of bounds, depth ");
                     Put (Standard_Error, Current_Move_Nr, 0);
                     New_Line (Standard_Error, 2);
                     
                     Print_Board (Board_Array);

                  end if;  -- Piece_in_Bounds
                  
               end loop Placement_Loop;
               
         end if; -- Piece_Tally(I) > 0
         
      end loop Tally_Loop;
      
      
      -- Couldn't place a piece.
      
      return False;
      
   end Play_Piece;
   
end Board;
