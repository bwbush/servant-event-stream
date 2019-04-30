module Servant.EventStream
  ( ServerSentEvents
  , EventStream
  , EventSource
  , eventSource
  )
where

import Data.Binary.Builder                  (toLazyByteString)
import Network.HTTP.Media                   ((//), (/:))
import Network.Wai.EventSource              (ServerEvent(..))
import Network.Wai.EventSource.EventStream  (eventToBuilder)
import Servant.API
import Servant.Types.SourceT                (SourceT, fromAction)

type ServerSentEvents = StreamGet NoFraming EventStream EventSource

data EventStream

instance Accept EventStream where
  contentType _ = "text" // "event-stream" /: ("charset", "utf-8")

type EventSource = SourceIO ServerEvent

instance MimeRender EventStream ServerEvent where
  mimeRender _ = maybe "" toLazyByteString . eventToBuilder

eventSource :: Functor m => m ServerEvent -> SourceT m ServerEvent
eventSource = fromAction isClose
 where
  isClose CloseEvent = True
  isClose _          = False
