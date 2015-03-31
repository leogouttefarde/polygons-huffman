
with AVL;
with Ada.Containers.Doubly_Linked_Lists;
with Ada.Unchecked_Deallocation;


package Common is

        type SimplePoint is record
                X : Float := 0.0;
                Y : Float := 0.0;
        end record;

        type Segment is array (Positive range 1 .. 2) of SimplePoint;

        package Segment_Lists is new Ada.Containers.Doubly_Linked_Lists ( Segment );
        type pSegment is access Segment;

        procedure Liberer_Segment is new Ada.Unchecked_Deallocation (Object => Segment, Name => pSegment);


        type Point is record
                Pt : SimplePoint;
                InSegs : Segment_Lists.List;
                OutSegs : Segment_Lists.List;
        end record;


        F_Epsilon : constant Float := 0.0001;

        function Egal (F1, F2 : Float) return Boolean;

        function Inf (F1, F2 : Float) return Boolean;
        function InfEgal (F1, F2 : Float) return Boolean;

        function Sup (F1, F2 : Float) return Boolean;
        function SupEgal (F1, F2 : Float) return Boolean;



        function "+" (P1, P2 : SimplePoint) return SimplePoint;
        function "-" (P1, P2 : SimplePoint) return SimplePoint;
        function "*" (P1 : SimplePoint ; Coef : Float) return SimplePoint;
        function "*" (Coef : Float ; P1 : SimplePoint) return SimplePoint;
        function "*" (P1, P2 : SimplePoint) return SimplePoint;


        function "<" (S1, S2 : Segment) return Boolean;
        function ">" (iS1, iS2 : Segment) return Boolean;
        function IsPoint (cSegment : Segment) return Boolean;

        package Arbre_Segments is new AVL(Segment, "<", ">");
        use Arbre_Segments;


        function "=" (P1, P2 : Point) return Boolean;
        function "<" (P1, P2 : Point) return Boolean;
        function ">" (P1, P2 : Point) return Boolean;


        package Point_Lists is new Ada.Containers.Doubly_Linked_Lists ( Point, "=" );
        package Point_Sorting is new Point_Lists.Generic_Sorting( "<" );


        function Intersection(sPoint : SimplePoint ; cSegment : Segment) return SimplePoint;

        procedure Affiche_Point(sPoint : SimplePoint);
        procedure Affiche_Segment(cSegment : Segment);
        procedure Affichage_AVL is new Arbre_Segments.Affichage ( Affiche_Segment );

end Common;


