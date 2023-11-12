module Main where

import Control.Lens
import Data.Foldable
import Linear
import System.IO (hPutStrLn, stderr, stdout)

type F = Float
type L2 = V2 F
type L3 = V3 F

resolution :: L2
resolution = V2 100 100

pixels :: [L2]
pixels = V2 <$> [0 .. resolution ^. _x - 1] <*> [0 .. resolution ^. _y - 1]

camera :: L2 -> L3
camera uv =
  toL3 ((uv - resolution ^/ 2.0) ^/ (r * 0.5)) 2 -- 1.2
 where
  r = resolution ^. _y
  toL3 (V2 x y) = V3 x y

sdSphere :: L3 -> L3 -> Float -> Float
-- sdSphere p offset radius = -(norm (offset - p) - radius)
sdSphere p offset radius = norm (offset - p) - radius

sphereOrigin = V3 0 0 3
sphereRadius = 0.75

sdSphere' p = sdSphere p sphereOrigin sphereRadius

render :: Int -> L2 -> L3
render param xy =
  let
    uv = camera xy
    multVec uv@(V3 x y z) f = uv ^* (1 + f * 0.01)
    uvMult = iterate (\uv -> multVec uv (sdSphere' uv)) uv !! 1000
    plusVec = V3 0 0
    uvPlus = iterate (\uv -> uv + plusVec (sdSphere' uv)) uv !! 100
    plusVecN uv f = f *^ normalize uv
    uvPlusN = iterate (\uv -> uv + plusVecN uv (sdSphere' uv)) uv !! 200
    deZ orig@(V3 x y _) p@(V3 x' y' z) = let z' = 1 / z in V3 (V3 z' 0 0) (V3 0 z' 0) (V3 0 0 1) !* p
    reZ orig@(V3 x y _) p@(V3 x' _ _) = p ^* (x / x')
    f 0 = uvMult
    f 1 = uvPlusN
   in
    f param

pointify :: (L3, L2) -> Maybe String
-- pointify (V3 _ _ z, V2 x y) = show x ++ " " ++ show y ++ " " ++ show z
-- pointify (p@(V3 x y z), V2 _ _) | norm p < 100 = Just $ show x ++ " " ++ show y ++ " " ++ show z
pointify (p@(V3 x y z), V2 _ _) | sdSphere' p < 0.1 = Just $ show x ++ " " ++ show y ++ " " ++ show z
pointify _ = Nothing

-- % ./notes/run-plot notes/Shader.hs
main = print stdout 0 >> print stderr 1
 where
  print to param = traverse_ (traverse_ (hPutStrLn to)) . fmap (pointify . ((,) =<< render param)) $ pixels
