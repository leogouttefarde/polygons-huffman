
with Ada.Text_IO;
use Ada.Text_IO;

package body Decompose is

        -- requires Prev(2) = cPoint = Next(1)
        procedure Finish_Point (cPoint : in out Point ; Prev, Next : Segment) is
        begin
                if InfEgal(Prev(1).X, cPoint.Pt.X) then
                        Segment_Lists.Append(cPoint.InSegs, Prev);
                elsif Sup(Prev(1).X, cPoint.Pt.X) then
                        Segment_Lists.Append(cPoint.OutSegs, Prev);
                end if;

                if Inf(Next(2).X, cPoint.Pt.X) then
                        Segment_Lists.Append(cPoint.InSegs, Next);
                elsif SupEgal(Next(2).X, cPoint.Pt.X) then
                        Segment_Lists.Append(cPoint.OutSegs, Next);
                end if;
        end;

        procedure Finish_Points (Points : in out Point_Lists.List ; Segments : Segment_Lists.List) is
                Point_Pos, FirstPos : Point_Lists.Cursor;
                Segment_Pos : Segment_Lists.Cursor;
                cPoint, First : Point;
                s1, sPrev, cSegment : Segment;
        begin
                FirstPos := Point_Lists.First( Points );
                Point_Pos := FirstPos;
                First := Point_Lists.Element( FirstPos );
                Segment_Pos := Segment_Lists.First( Segments );
                s1 := Segment_Lists.Element( Segment_Pos );
                sPrev := s1;

                loop
                        Point_Lists.Next( Point_Pos );
                        Segment_Lists.Next( Segment_Pos );

                        exit when not (Point_Lists.Has_Element( Point_Pos )
                                and Segment_Lists.Has_Element( Segment_Pos ));


                        cSegment := Segment_Lists.Element( Segment_Pos );

                        cPoint := Point_Lists.Element( Point_Pos );

                        Finish_Point(cPoint, sPrev, cSegment);
                        Point_Lists.Replace_Element(Points, Point_Pos, cPoint);

                        sPrev := cSegment;
                end loop;

                Finish_Point(First, sPrev, s1);
                Point_Lists.Replace_Element(Points, FirstPos, First);
        end;

        function Generate_Segments (Points : in Point_Lists.List) return Segment_Lists.List is
                Segments : Segment_Lists.List;
                Point_Pos : Point_Lists.Cursor;
                cPoint : Point;
                First, Prev, Last : SimplePoint;
                sPoint : SimplePoint;
                cSegment : Segment;
        begin
                Point_Pos := Point_Lists.First( Points );
                cPoint := Point_Lists.Element( Point_Pos );
                sPoint := cPoint.Pt;
                First := sPoint;
                Prev := First;

                loop
                        Point_Lists.Next( Point_Pos );
                        exit when not Point_Lists.Has_Element( Point_Pos );

                        cPoint := Point_Lists.Element( Point_Pos );
                        sPoint := cPoint.Pt;

                        cSegment(1) := Prev;
                        cSegment(2) := sPoint;

                        Segment_Lists.Append( Segments, cSegment );

                        Prev := sPoint;
                end loop;

                Last := sPoint;


                cSegment(1) := Last;
                cSegment(2) := First;

                Segment_Lists.Append( Segments, cSegment );

                return Segments;
        end;

        procedure Reconnexion(P1 : SimplePoint ; cSegment : pSegment) is
                P2 : SimplePoint;
        begin
                if cSegment /= null then
                        P2 := Intersection(P1, cSegment.all);

                        if not IsPoint((P1, P2)) then
                                Svg_Line(P1, P2, Blue);
                        end if;
                end if;
        end;

        function Impair(Nombre : Natural) return Boolean is
        begin
                if (Nombre mod 2) = 1 then
                        return True;
                end if;

                return False;
        end;

        -- Libération sécurisée
        procedure Liberation(cSegment : in out pSegment) is
        begin
                if cSegment /= null then
                        Liberer_Segment(cSegment);
                        cSegment := null;
                end if;
        end;

        procedure Copie(Dest : in out pSegment ; pNoeud : in out Arbre) is
        begin
                if pNoeud /= null then

                        if Dest = null then
                                Dest := new Segment;
                        end if;

                        Dest.all := pNoeud.C;
                else
                        Liberation(Dest);
                end if;
        end;


        --DotIndex : Natural := 0;

        procedure Decomposition(cPoint : Point ; cAVL : in out Arbre) is
                Rebroussement : Boolean := False;
                cSegment : Segment;
                sPoint : SimplePoint := cPoint.Pt;
                pNoeud : Arbre;
                V_petit : Arbre := null;
                V_Grand : Arbre := null;
                S_petit : pSegment := null;
                S_Grand : pSegment := null;
                C_petits : Natural := 0;
                C_Grands : Natural := 0;
                Segment_Pos : Segment_Lists.Cursor;
        begin

                -- One regarde si on est sur un point de rebroussement
                if Segment_Lists.Length(cPoint.OutSegs) = 2 then
                        Rebroussement := True;
                        cSegment := ( sPoint, sPoint );

                        pNoeud := Inserer(cAVL, cSegment);

                        Noeuds_Voisins(pNoeud, V_petit, V_Grand);
                        Compte_Position(pNoeud, C_petits, C_Grands);

                        -- On copie les segments voisins car la suppression
                        -- d'en-dessous peut invalider leurs pointeurs
                        Copie(S_petit, V_petit);
                        Copie(S_Grand, V_Grand);


                        cAVL := Supprimer_Noeud(cAVL, cSegment);

                end if;


                -- On retire de l'AVL les segments qui finissent au point courant
                Segment_Pos := Segment_Lists.First( cPoint.InSegs );
                while Segment_Lists.Has_Element( Segment_Pos ) loop

                        cSegment := Segment_Lists.Element( Segment_Pos );
                        cAVL := Supprimer_Noeud(cAVL, cSegment);

                        Segment_Lists.Next( Segment_Pos );

                end loop;


                -- On ajoute à l'AVL les segments qui commencent au point courant
                Segment_Pos := Segment_Lists.First( cPoint.OutSegs );
                while Segment_Lists.Has_Element( Segment_Pos ) loop

                        cSegment := Segment_Lists.Element( Segment_Pos );
                        pNoeud := Inserer(cAVL, cSegment);

                        Segment_Lists.Next( Segment_Pos );

                end loop;


                --AVL_Disp.Export("dots/AVL" & Natural'Image(DotIndex) & ".dot", cAVL);
                --DotIndex := DotIndex + 1;


                if Segment_Lists.Length(cPoint.InSegs) = 2 then
                        Rebroussement := True;
                        cSegment := ( sPoint, sPoint );
                        pNoeud := Inserer(cAVL, cSegment);

                        Noeuds_Voisins(pNoeud, V_petit, V_Grand);
                        Compte_Position(pNoeud, C_petits, C_Grands);

                        -- On copie les segments voisins car la suppression
                        -- d'en-dessous peut invalider leurs pointeurs
                        Copie(S_petit, V_petit);
                        Copie(S_Grand, V_Grand);


                        cAVL := Supprimer_Noeud(cAVL, cSegment);

                end if;


                -- On traite l'éventuel point de rebroussement
                if Rebroussement and (Impair(C_petits) or Impair(C_Grands)) then

                        Reconnexion(sPoint, S_petit);
                        Reconnexion(sPoint, S_Grand);

                end if;

                Liberation(S_petit);
                Liberation(S_Grand);

        end;

end Decompose;


