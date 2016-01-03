## MouseGesture
Capture a gesture from the mouse, trackpad, or pen and classify it; displaying the result ( i.e., the gesture & element name ) to the screen.
I used the following research papers to derive this algorithm:
- [Mouse Gesture Recognition](http://www.bytearray.org/?p=91)
- [Efficient Recognition of Mouse-based Gestures](https://www.ii.pwr.edu.pl/~piasecki/publications/hofman-piasecki-v1-1.pdf)

## Algorithm

- Initialize Model
- Capture the mousepoints
    - Start recording points when ctrl key is pressed
    - Stop recording points when ctrl key is lifted up
- Pre-process the mouse points
     - Convert the mouse points from screen to cartesian coordinates
          - Needed because Identify Characteristic Points and the Classification phase assume points
            are in cartesian coordiantes
     - Remove cluster points
          - A cluster point is a point within the gesture points that is too close
          to another point to make a difference in classifying the
          gesture later on.  It is, in effect, a point whose distance to another point is less than a specified tolerance.
          I've chosen 8-10 pixels in distance based on heuristics from the research papers cited above
     - Identify Char Points
          - A characteristic point is a point p2 within the gesture points whose angle
          computed the previous point p1 and the next point p3 is greater than a specified
          tolerance.  I have chosen 20-22 degrees based on heuristics from cited research papers
- Classification phase
  - Initialize the list of elements that you wish to match against a mouse gesture
  - Convert the mouse gesture to a sequence of numbers ( '0'..'7' ) that map to the direction of each line segment. We assign North = '6', South = '2', East = '0', etc. ( see Mouse Gesture Recognition reference given above )
    1. For each line segment in the mouse gesture, compute the angle between the direction vector & unit vector along the x axis. 
    2. Using the angle, assign the direction of the line segment to the nearest of the 8 directions given above. For example, a vertical line segment in positive Y direction would be 90 degrees and therefore it would assigned a '6'
    3. Once all of the line segments have been processed, we obtain a sequence associated with the mouse gesture
  - With each element in the list, compute the Levenstein cost of matching the mouse gesture's sequence computed above
  - Return the element that has the lowest Leventein cost

- Display gesture & name of the gesture

## Data Structures
Components are characters to match with a user gesture.  


```
type alias Sequence =
     List Char

type alias Component =
    { name : String
    , sequence : Sequence
    }

initComponent : Component
    { name = ""
    , sequence = [ ]
    }
```

You will need to create your own Components.elm file and place it into the source directory.  Besides declaring the above data structre, it
will contain a Component for each character that you want to match. For example, take a look
at [Mouse Gesture Recognition](http://www.bytearray.org/?p=91). The Component for the letter 'A' would be the following:
```
letterA : Component
{ name = 'A'
, sequence = [ '7', '1' ]
}
```

## Installation & Compilation
1. Install [Elm 0.16](http://elm-lang.org/install) 
2. elm-make ./src/MouseGesture.elm --output index.html

## Unit Testing
All tests are in Tests.elm

Usage:
```
elm-test TestRunner.elm  # Runs the tests
```
See [node-elm-test](https://github.com/rtfeldman/node-elm-test) for further info on creating your own unit tests