module Main where

import Control.Lens
import Data.Foldable
import Linear
import Linear.Metric
import Linear.V2
import Linear.V3

type F = Float
type L2 = V2 F
type L3 = V3 F

resolution :: L3
resolution = let s = 10 in V3 s s s

pixels :: [L3]
pixels = V3 <$> [0 .. resolution ^. _x] <*> [0 .. resolution ^. _y] <*> [0 .. resolution ^. _z]

sdSphere :: L3 -> L3 -> Float -> Float
sdSphere p offset radius = (norm (offset - p) - radius)

-- orthographic, 0,0,0 at the middle of data set
camera :: L3 -> L3
camera v = (v - resolution ^/ 2.0) ^/ ((resolution ^. _y) * 0.5)

render :: L3 -> L3
render v =
  let v' = camera v
   in normalize $ v' ^* sdSphere v' (pure 0) 1

pointify :: (L3, L3) -> String
pointify (fx, coord) =
  let str (V3 x y z) = show x ++ " " ++ show y ++ " " ++ show z
   in str coord ++ " " ++ str fx

main = traverse_ putStrLn . fmap (pointify . ((,) =<< render)) $ pixels
