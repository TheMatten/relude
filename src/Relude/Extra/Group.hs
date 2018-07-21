{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies        #-}

{-
Copyright: (c) 2017-2018 Serokelll
           (c) 2018 Kowainik
License: MIT
-}

module Relude.Extra.Group
       ( groupBy
       , groupOneBy
       ) where

import Relude
import Relude.Extra.Map

import Data.List.NonEmpty ((<|))

{- | Groups elements using results of the given function as keys.

>>> groupBy even [1..6] :: HashMap Bool (NonEmpty Int)
fromList [(False,5 :| [3,1]),(True,6 :| [4,2])]
-}
groupBy :: forall f t a . (Foldable f, DynamicMap t, Val t ~ NonEmpty a, Monoid t)
        => (a -> Key t) -> f a -> t
groupBy f = flipfoldl' hmGroup mempty
  where
    hmGroup :: a -> t -> t
    hmGroup x =
        let val :: Maybe (NonEmpty a) -> NonEmpty a
            val Nothing   = one x
            val (Just xs) = x <| xs
        in alter (Just . val) (f x)

{- | Similar to 'groupBy' but keeps only one element as value.

>>> groupOneBy even [1 .. 6] :: HashMap Bool Int
fromList [(False,1),(True,2)]
-}
groupOneBy :: forall f t a . (Foldable f, DynamicMap t, Val t ~ a, Monoid t)
           => (a -> Key t) -> f a -> t
groupOneBy f = flipfoldl' hmGroup mempty
  where
    hmGroup :: a -> t -> t
    hmGroup val m = let key = f val in
        case lookup key m of
            Nothing -> insert key val m
            Just _  -> m