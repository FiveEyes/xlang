data Val = I Int | S String | L [Val] | F Func | E Expr | ST State | Nil deriving (Show)

data Proto = FP [String] Expr deriving (Show)

data Func = NF NativeFunc | MF Proto State

data Expr = Var String | Value Val | Call Expr [Expr] deriving (Show)

type State = [(String, Val)]

type NativeFunc = (State, Expr) -> (State, Expr)

instance Show Func where
	show (NF _) = "NF"
	show (MF p s) = show p


getVal :: State -> String -> Val
getVal [] _ = Nil
getVal ((k, v):xs) t = if t == k then v else getVal xs t

add :: (State, Expr) -> (State, Expr)
add (s, (Call _ (x:y:[]))) = (s, Value (I (x0 + y0)))
	where
		(I x0) = exec2Val s x
		(I y0) = exec2Val s y

def :: (State, Expr) -> (State, Expr)
def (s, (Call _ (x:y:[]))) = (ns, (Value value))
	where 
		(S name) = (exec2Val ns x)
		value = (exec2Val ns y)
		ns = (name, value):s
def _ = undefined

--ifel :: (State, Expr) -> (State, Expr)
--ifel (s, (Call _ (x:y:z[]))) = 
--	where
--		(I ret) = 

lmd :: (State, Expr) -> (State, Expr)
lmd (s, (Call _ (x:y:[]))) = undefined
		
exec2Val :: State -> Expr -> Val
exec2Val s e = let (_, (Value ret)) = exec (s, e) in ret


exec :: (State, Expr) -> (State, Expr)
exec (s, (Value v)) = case v of
	(E e) -> exec (s, e)
	v -> (s, (Value v))
exec (s, (Var name)) = (s, Value $ getVal s name)
exec (s, Call e l) = case (exec2Val s e) of
	(F (NF f)) -> f (s, (Call e l))
	(F (MF (FP argv body) ps)) -> (s, ret)
		where
			ts = (zip argv (map (exec2Val s) l)) ++ ps
			(_, ret) = exec (ts, body)
		

		
fststr :: String -> (String, String)
fststr [] = ([], [])
fststr ('(':xs) = ("(", xs)
fststr (')':xs) = (")", xs)
fststr (' ':xs) = ([], xs)
fststr (x:xs) = let (y, ys) = fststr xs in
	if y == [] then (x:y, ys)
	else if (last y) == ')' then (x:(init y), ')':ys)
	else (x:y, ys)

str2lst :: String -> [String]
str2lst [] = []
str2lst s = if x == [] then ys else x:ys
	where
		(x, xs) = fststr s
		ys = str2lst xs
		
str2Val :: String -> Val
str2Val s = I (read s)

str2expr :: [String] -> (Expr, [String])
str2expr (x:xs) = 
	if (elem (head x) "0123456789") then (Value (str2Val x), xs)
	else if x == "(" then undefined
	else if x == ")" then undefined
	else (Var x, xs)
	

lst2expr :: [String] -> [Expr]
lst2expr (x:xs) = undefined
		
parser :: String -> [Expr]
parser = undefined
		

func0 = MF (FP ["a", "b"] (Call (Var "+") [Var "a", Var "b"])) state
state = [("a", I 1), ("b", I 2), ("c", I 3), ("d", I 4), ("+", F (NF add)), ("def", F (NF def)), ("func0", F func0)] :: State

expr0 = Call (Var "+") [Value (I 1), Var "b"]
expr1 = Call (Var "def") [Value (S "a"), Value (I 3)]
expr2 = Call (Var "func0") [Var "c", Var "d"]

originStr = "(def f (lambda (x y) (+ x Y)))"
