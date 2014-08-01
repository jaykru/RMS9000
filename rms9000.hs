import Data.List
import Network
import System.IO
import System.Exit
import Control.Arrow
import Control.Monad.Reader
import Control.Exception
import Text.Printf
import Text.Regex.Posix

-- Configuration
server  = "irc.someserver.com"
port    = 6667
channel = "#insertchannelhere"
nick    = "obviously_too_lazy_to_edit_bot"

-- The 'Net' monad, a wrapper over IO, carrying the bot's immutable state.
type Net = ReaderT Bot IO
data Bot = Bot { socket :: Handle }

-- Sets up actions to run on start and end, and runs the main loop.
main :: IO ()
main = bracket connect disconnect loop
  where
	disconnect = hClose . socket
	loop st    = runReaderT run st

-- Connects to the server and returns the initial bot state.
connect :: IO Bot
connect = notify $ do
	h <- connectTo server (PortNumber (fromIntegral port))
	hSetBuffering h NoBuffering
	return (Bot h)
  where
	notify a = bracket_
		(printf "Connecting to %s ... " server >> hFlush stdout)
		(putStrLn "done.")
		a

-- Sets IRC nickname, real name along with user mode, and finally joins the 
-- selected channel.
run :: Net ()
run = do
	write "NICK" nick
	write "USER" (nick++" 0 * :Richard Stallman")
	write "JOIN" channel
	asks socket >>= listen

-- Listens to server, replies to PINGs with PONG to remain connected.
listen :: Handle -> Net ()
listen h = forever $ do
	s <- init `fmap` io (hGetLine h)
	io (putStrLn s)
	if ping s then pong s else eval (clean s)
  where
	forever a = a >> forever a
	clean     = drop 1 . dropWhile (/= ':') . drop 1
	ping x    = "PING :" `isPrefixOf` x
	pong x    = write "PONG" (':' : drop 6 x)

-- Command dispatcher. This is where the pasta is made.
eval :: String -> Net ()
eval x
	| x == "!help" = privmsg ("There is no help for those using non-free software.")
	| x =~ "(L|l)(inu|uni|ooni)x" == True = privmsg ("I would like to interject for a moment. What you're refering to as Linux, is in fact, GNU/Linux, or as I've recently taken to calling it, GNU plus Linux. Linux is not an operating system unto itself, but rather another free component of a fully functioning GNU system made useful by the GNU corelibs, shell utilities and vital system components comprising a full OS as defined by POSIX.")
	| otherwise = return()

-- Private message wrapper. Writes to channel publically.
privmsg :: String -> Net ()
privmsg s = write "PRIVMSG" (channel ++ " :" ++ s)

-- Writes a command and argument to server.
write :: String -> String -> Net ()
write s t = do
	h <- asks socket
	io $ hPrintf h "%s %s\r\n" s t
	io $ printf    "> %s %s\n" s t

-- IO wrapper for convenience.
io :: IO a -> Net a
io = liftIO
