> import Prelude hiding (Monad (..))

Some data structures, represent not only values, but context surrounding those values.
For instance, a `Maybe a` isn't just an `a`; we'd lose the conditional nature of the `Maybe`.
`[a]` isn't just an `a`. We lose the plurality that comes with a list.

We already have some tools for working within these contexts, such as `Functor` and `Applicative`.
`Monad` is another.

> class Monad m where
>     (>>=) :: m a -> (a -> m b) -> m b

Monads revolve around the idea of transforming context; when given value(s)
from one context, we can create a new context with new values (i.e. `a -> m b`).
If we can do that, we can take values in one context (`m a`),
and create values in a new context (`m b`). Anything for which this is true can be a Monad.

Monads have also some other functions:

>     -- just like `pure` for Applicatives.
>     return :: a -> m a

>     -- just like `*>` for Applicatives.
>     (>>) :: m a -> m b -> m b
>     x >> y = x >>= \_ -> y

>     -- just `>>=` backwards
>     (=<<) :: (a -> m b) -> m a -> m b
>     x =<< y = y >>= x

> instance Monad Maybe where
>     return = Just

>     -- (>>=) :: Maybe a -> (a -> Maybe b) -> Maybe b
>     (Just x) >>= f = f x
>     Nothing >>= _ = Nothing

So if we have a value to pass, we pass it to the function.
Otherwise, we stay where we are (i.e. with no value).

For example:

> data Prize = Life | Item | Level

> -- This is kind of ugly. Nicer syntax is explained in the "Odds and ends" section.
> prize :: Integer -> Maybe Prize
> prize score = if score < 100
>               then Nothing
>               else if score < 1000
>                    then Just Life
>                    else if score < 10000
>                         then Just Item
>                         else Just Level

> unlocked :: Maybe Integer -> Maybe Prize
> unlocked highScore = highScore >>= prize

In this example, the conditional context changes; whether or not we have a `Prize`
depends not only on whether we have a score, but on the `prize` function,
which conditionally returns a `Prize`.

> instance Monad [] where
>     return x = [x]

>     -- (>>=) :: [a] -> (a -> [b]) -> [b]
>     (x:xs) >>= f = f x ++ (xs >>= f)
>     [] >>= _ = []

So we just stick together all the lists generated by applying the function to the whole list.

Monads are used frequently enough to have their own special syntax:

> -- do { x <- m; ... } = m >>= (\x -> ...)
> -- do { m; ... } = m >> ...

It can also be written on several lines, and then the semicolons and braces can be omitted (which is way more common):

> highScoreDiff :: Maybe Int -> Maybe Int -> Maybe Int
> highScoreDiff score1 score2 = do i <- score1
>                                  j <- score2
>                                  return $ diff i j -- return (diff i j)
>     where diff i j = abs (i - j)

Usually, using `return` inside a `do` notation can be avoided by using `Functor` and `Applicative`,
as we did with the previous `highScoreDiff` function.
