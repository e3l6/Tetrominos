-------------------------------------------------------------------------------
-- 
-- Eric Laursen, 10 April 2017, CS 442P-003 HW 1
--
-- board.ads
--
-------------------------------------------------------------------------------

package Board is
   
   type Marker_Type is array (Positive range <>) of Character;
   
   type Point is array (1 .. 2) of Integer;  -- Ordered pairs of X, Y
   
   type Piece_Type is array (1 .. 4) of Point;  -- Four squares to make a
                                                -- tetromino
   
   type Piece_Name_Type is ('I', '5', '2', 'T', 'L', 'P', 'O');
   
   type Piece_Rotation_Type is array (Positive range <>) of Piece_Type;
   
   type Tally_Type is array (Piece_Name_Type'Range) of Integer;
   
   type Board_Type is
     array (Positive range <>, Positive range <>) of Character;
   
   procedure Play_Board (Nr_Rows     : in Integer;
                         Nr_Columns  : in Integer;
                         Piece_Tally : in Tally_Type;
                         Nr_Pieces   : in Integer);
   
   procedure Print_Board (Board_Array : access Board_Type);
   
   function  Play_Piece (Piece_Tally     : in Tally_Type;
                         Piece_Count     : in Integer;
                         Current_Move_Nr : in Integer) return Boolean;
   
end Board;
