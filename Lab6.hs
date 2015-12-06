------------------------------------------------------------------------------------------------------------------------------
-- ROSE TREES, FUNCTORS, MONOIDS, FOLDABLES
------------------------------------------------------------------------------------------------------------------------------

import Data.Foldable

data Rose a = a :> [Rose a] deriving Show

-- ===================================
-- Ex. 0-2
-- ===================================

root :: Rose a -> a
root (x :> _) = x

children :: Rose a -> [Rose a]
children (_ :> xs) = xs

xs = 0 :> [1 :> [2 :> [3 :> [4 :> [], 5 :> []]]], 6 :> [], 7 :> [8 :> [9 :> [10 :> []], 11 :> []], 12 :> [13 :> []]]]

ex2 = root . head . children . head . children . head . drop 2 $ children xs

-- ===================================
-- Ex. 3-7
-- ===================================

size :: Rose a -> Int
size (_ :> []) = 1
size (x :> xs) = 1 + (foldl1 (+) $ map size xs)

leaves :: Rose a -> Int
leaves (_ :> []) = 1
leaves (x :> xs) = foldl1 (+) $ map leaves xs

ex7 = (*) (leaves . head . children . head . children $ xs) (product . map size . children . head . drop 2 . children $ xs)

-- ===================================
-- Ex. 8-10
-- ===================================

instance Functor Rose where
  fmap f (x :> xs) = (f x) :> ((fmap $ fmap f) xs)

ex10 = round . root . head . children . fmap (\x -> if x > 0.5 then x else 0) $ fmap (\x -> sin(fromIntegral x)) xs

-- ===================================
-- Ex. 11-13
-- ===================================

newtype Sum a = Sum a
newtype Product a = Product a

instance Num a => Monoid (Sum a) where
  mempty = Sum 0
  mappend a b = Sum $ unSum a + unSum b

instance Num a => Monoid (Product a) where
  mempty = Product 1
  mappend a b = Product $ unProduct a * unProduct b

unSum :: Sum a -> a
unSum (Sum a) = a
unProduct :: Product a -> a
unProduct (Product a) = a

num1 = mappend (mappend (Sum 2) (mappend (mappend mempty (Sum 1)) mempty)) (mappend (Sum 2) (Sum 1))

num2 = mappend (Sum 3) (mappend mempty (mappend (mappend (mappend (Sum 2) mempty) (Sum (-1))) (Sum 3)))

ex13 = unSum (mappend (Sum 5) (Sum (unProduct (mappend (Product (unSum num2)) (mappend (Product (unSum num1)) (mappend mempty (mappend (Product 2) (Product 3))))))))

-- ===================================
-- Ex. 14-15
-- ===================================
instance Foldable Rose where
  foldMap f (x :> []) = f x
  foldMap f (x :> xs) = f x `mappend` foldr1 mappend (fmap (foldMap f) xs)

sumxs = Sum 0 :> [Sum 13 :> [Sum 26 :> [Sum (-31) :> [Sum (-45) :> [], Sum 23 :> []]]], Sum 27 :> [], Sum 9 :> [Sum 15 :> [Sum 3 :> [Sum (-113) :> []], Sum 1 :> []], Sum 71 :> [Sum 55 :> []]]]

ex15 = unSum (mappend (mappend (fold sumxs) (mappend (fold . head . drop 2 . children $ sumxs) (Sum 30))) (fold . head . children $ sumxs))
-- ex15 = unSum (mappend (mappend (foldl sumxs) (mappend (foldl . head . drop 2 . children $ sumxs) (Sum 30))) (foldl . head . children $ sumxs))

-- ===================================
-- Ex. 16-18
-- ===================================

ex17 = unSum (mappend (mappend (foldMap (\x -> Sum x) xs) (mappend (foldMap (\x -> Sum x) . head . drop 2 . children $ xs) (Sum 30))) (foldMap (\x -> Sum x) . head . children $ xs))

ex18 = unSum (mappend (mappend (foldMap (\x -> Sum x) xs) (Sum (unProduct (mappend (foldMap (\x -> Product x) . head . drop 2 . children $ xs) (Product 3))))) (foldMap (\x -> Sum x) . head . children $ xs))

-- ===================================
-- Ex. 19-21
-- ===================================

fproduct, fsum :: (Foldable f, Num a) => f a -> a
fsum = unSum . foldMap (\x -> Sum x)
fproduct = unProduct . foldMap (\x -> Product x)

ex21 = ((fsum . head . drop 1 . children $ xs) + (fproduct . head . children . head . children . head . drop 2 . children $ xs)) - (fsum . head . children . head . children $ xs)
