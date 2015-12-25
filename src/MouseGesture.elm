module MouseGesture where
{-
 Determining Characteristic points came from:
   "Efficient Recognition of Mouse-based Gestures"
   https://www.ii.pwr.edu.pl/~piasecki/publications/hofman-piasecki-v1-1.pdf
-}

import Color exposing ( .. )
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import GraphicUtils exposing ( toCollagePoint )
import PreProcessPoints exposing ( removeClusters, identifyCharPoints )
import Mouse
import Keyboard
import Window
import Time
import Debug

type alias Point = ( Float, Float )
type alias Points =
     List Point

type alias Model =
    { mousePoints : Points
    , lastPosition : Point
    , mousePressed : Bool
    , charPoints : Points
    , elementName : String
    }

-- Model

initialModel : Model
initialModel =
    { mousePoints = [ ]
    , lastPosition = ( -1.0, -1.0 )
    , mousePressed = False
    , charPoints = [ ]
    , elementName = ""
    }

-- View

drawGesture : Point -> Point -> Point -> Points -> Form
drawGesture window viewport offset charPoints
  =  List.map ( toCollagePoint window viewport offset ) charPoints 
  |> path
  |> traced { defaultLine
            | color = red
            , width = 5
            }
             

showElementName : Float -> Point -> String -> Form
showElementName scale' offset elementName
  =  toForm ( show elementName )
  |> scale scale'
  |> move offset


view : ( Int, Int ) -> Model -> Element
view ( w, h ) model =
  let
    w' = toFloat w
    h' = toFloat h
    window = ( w', h')
    viewport = ( 400.0, 400.0 )
    offset = ( 0.0, 0.0)
    scale = 2.0
  in
    collage 400 400
      [ drawGesture window viewport offset model.charPoints
      , showElementName scale offset model.elementName
      ]
    
-- Update

type Action
  = NoOp
  | MouseUp
  | MouseDown ( Int, Int )


update : Action -> Model -> Model
update action model =
    case action of
      NoOp ->
        model

      MouseUp ->
         if model.mousePressed
           then
             { model
             | mousePoints = [  ]
             , mousePressed = False
             , charPoints
                 =  model.mousePoints
                 |> List.reverse
                 |> Debug.log "Mouse Points: "
                 |> removeClusters
                 |> Debug.log "No Clusters: "
                 |> identifyCharPoints
                 |> Debug.log "CharPoints: "
             }
            else model

      MouseDown ( x, y ) ->
          let 
            position =
                (toFloat x, toFloat y  )
          in
            { model
            | mousePressed = True
            , mousePoints =
                if position == model.lastPosition then
                  model.mousePoints
                else
                  position :: model.mousePoints
            , lastPosition = position
            }


-- Signals

mouseUpDown : Signal Action
mouseUpDown =
    let
      delta = Time.fps 30
      
      toAction n pos =
          case n of
            False -> MouseUp
            True -> MouseDown pos

      actions = Signal.map2 toAction Keyboard.ctrl Mouse.position

      in
        Signal.sampleOn delta actions


input : Signal Action
input =
    mouseUpDown
    

model : Signal Model
model =
    Signal.foldp update initialModel input


main : Signal Element
main =
    Signal.map2 view Window.dimensions model
