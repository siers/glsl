module Convergence where

import Data.Foldable (traverse_)
import Text.Printf (printf)

gradient x = 100 - x

f :: (String, Float) -> (String, Float)
f (_, a) =
  (printf "%0.2f → %0.2f" a b, b)
 where
  b = (1 + (gradient a * 0.01)) * a

main = traverse_ (putStrLn . fst) . take 30 . drop 1 $ iterate f ("", 1)
