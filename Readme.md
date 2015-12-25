## MouseGesture
Capture a gesture from the mouse, trackpad, or pen and classify it; displaying the result ( i.e., the gesture & element name ) to the screen.
I used the following research papers to derive this algorithm:
- [Mouse Gesture Recognition](http://www.bytearray.org/?p=91)
- [Efficient Recognition of Mouse-based Gestures](https://www.ii.pwr.edu.pl/~piasecki/publications/hofman-piasecki-v1-1.pdf)

## Algorithm

- Initialize Model
- Capture phase
    - Start recording points when ctrl key is pressed
    - Stop recording points when ctrl key is lifted up
- Pre-processing phase
    - Remove cluster points
          A cluster point is a point within the gesture points that is too close
          to another point to make a difference in classifying the
          gesture later on.  It is, in effect, a point whose distance
          to another point is less than a specified tolerance.  I've chosen 8 pixels
          in distance based on heuristics from the research papers I'm using
    - Identify Char Points
          A characteristic point is a point p2 within the gesture points whose angle
          computed the previous point p1 and the next point p3 is greater than a specified
          tolerance.  I've chosed 20 degrees based on heuristics cited research papers
    * Convert the points to cartesian coordinates
          Not really necessary but easier on the brain if we convert
          from screen coordinates to cartesian coordinates before implementing the functions
          needed for the classification phase.
- Classification phase
- Display gesture & name of the gesture
