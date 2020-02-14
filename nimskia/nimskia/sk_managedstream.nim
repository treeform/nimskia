import ../wrapper/sk_managedstream
import ../wrapper/sk_stream as sk_stream_bindings
import ../wrapper/sk_types
import internals/exceptions

import sk_stream

import system
import streams
import system

type

  SKManagedStreamObj* = object of SKStreamAsset
    onReadImpl*: proc(s: SKManagedStream, buff: pointer, size: int): int
    onPeekImpl*: proc(s: SKManagedStream, buff: pointer, size: int): int
    onIsAtEndImpl*: proc(s: SKManagedStream): bool
    onHasPositionImpl*: proc(s: SKManagedStream): bool
    onHasLengthImpl*: proc(s: SKManagedStream): bool
    onRewindImpl*: proc(s: SKManagedStream): bool
    onGetPositionImpl*: proc(s: SKManagedStream): int
    onGetLengthImpl*: proc(s: SKManagedStream): int
    onSeekImpl*: proc(s: SKManagedStream, position: int): bool
    onMoveImpl*: proc(s: SKManagedStream, offset: int): bool
    onCreateNewImpl*: proc(s: SKManagedStream): SKManagedStream
    onDuplicateImpl*: proc(s: SKManagedStream): SKManagedStream
    onForkImpl*: proc(s: SKManagedStream): SKManagedStream

  SKManagedStream* = ref object of SKManagedStreamObj
    parent: SKManagedStream
    child: SKManagedStream
    wasCopied*: bool
    disposeUnderlyingStream: bool
    stream: Stream

discard """
proc onFork(s: SKManagedStream): SKManagedStream =
  var stream = s.onCreateNewImpl(s)
  discard sk_stream_seek(
    cast[ptr sk_stream_t](stream.native), 
    sk_stream_get_position(s.native)  
  )
  stream
"""

proc disposeInternal(s: SKManagedStream) =
  if (not isNil s.child) and (not isNil s.parent):
    s.child.parent = s.parent
    s.parent.child = s.child
  elif not isNil s.child:
    s.child.parent = nil
  elif not isNil s.parent:
    s.parent.child = nil
    s.parent.wasCopied = false
    s.parent.disposeUnderlyingStream = s.disposeUnderlyingStream
    s.disposeUnderlyingStream = false
  
  s.parent = nil
  s.child = nil
  
  if s.disposeUnderlyingStream and (not isNil s.stream):
    s.stream.close()
    s.stream = nil


proc dispose*(s: SKManagedStream) =
  sk_managedstream_destroy(cast[ptr sk_stream_managedstream_t](s.native))

proc getStreamFromCtx(context: pointer): SKManagedStream =
  cast[ref SKManagedStream](context)[]

proc readProc(s: ptr sk_stream_managedstream_t, context: pointer, buffer: pointer, size: int): int {.cdecl.} =
  var stream = getStreamFromCtx(context)
  stream.onReadImpl(stream, buffer, size)

proc peekProc(s: ptr sk_stream_managedstream_t;context: pointer; buffer: pointer; size: int): int {.cdecl.} =
  var stream = getStreamFromCtx(context)
  stream.onPeekImpl(stream, buffer, size)

proc isAtEndProc(s: ptr sk_stream_managedstream_t;context: pointer): bool {.cdecl.} =
  var stream = getStreamFromCtx(context)
  stream.onIsAtEndImpl(stream)

proc hasPositionProc(s: ptr sk_stream_managedstream_t;context: pointer): bool {.cdecl.} =
  var stream = getStreamFromCtx(context)
  stream.onHasPositionImpl(stream)

proc hasLengthProc(s: ptr sk_stream_managedstream_t;context: pointer): bool {.cdecl.} =
  var stream = getStreamFromCtx(context)
  stream.onHasLengthImpl(stream)

proc rewindProc(s: ptr sk_stream_managedstream_t;context: pointer): bool {.cdecl.} =
  var stream = getStreamFromCtx(context)
  stream.onRewindImpl(stream)

proc getPositionProc(s: ptr sk_stream_managedstream_t;context: pointer): int {.cdecl.} =
  var stream = getStreamFromCtx(context)
  stream.onGetPositionImpl(stream)

proc seekProc(s: ptr sk_stream_managedstream_t;context: pointer, position: int): bool {.cdecl.} =
  var stream = getStreamFromCtx(context)
  stream.onSeekImpl(stream, position)

proc moveProc(s: ptr sk_stream_managedstream_t;context: pointer, offset: int): bool {.cdecl.} =
  var stream = getStreamFromCtx(context)
  stream.onMoveImpl(stream, offset)

proc getLengthProc(s: ptr sk_stream_managedstream_t;context: pointer): int {.cdecl.} =
  var stream = getStreamFromCtx(context)
  stream.onGetLengthImpl(stream)

proc duplicateProc(s: ptr sk_stream_managedstream_t;context: pointer): ptr sk_stream_managedstream_t {.cdecl.} =
  var stream = getStreamFromCtx(context)
  cast[ptr sk_stream_managedstream_t](stream.onDuplicateImpl(stream).native)

proc forkProc(s: ptr sk_stream_managedstream_t;context: pointer): ptr sk_stream_managedstream_t {.cdecl.} =
  var stream = getStreamFromCtx(context)
  cast[ptr sk_stream_managedstream_t](stream.onForkImpl(stream).native)

proc destroyProc(s: ptr sk_stream_managedstream_t;context: pointer) {.cdecl.} =
  var stream = getStreamFromCtx(context)
  disposeInternal(stream)
  dealloc(context)

system.once:
  var procs = new sk_managedstream_procs_t
  procs.fRead = readProc
  procs.fPeek = peekProc
  procs.fIsAtEnd = isAtEndProc
  procs.fDestroy = destroyProc
  procs.fIsAtEnd = isAtEndProc
  procs.fHasPosition = hasPositionProc
  procs.fHasLength = hasLengthProc
  procs.fRewind = rewindProc
  procs.fGetPosition = getPositionProc
  procs.fSeek = seekProc
  procs.fMove = moveProc
  procs.fGetLength = getLengthProc
  procs.fDuplicate = duplicateProc
  procs.fFork = forkProc
  procs.fDestroy = destroyProc
  sk_managedstream_set_procs(procs[])

proc newSKManagedStreamInternal*(): SKManagedStream = 
  var x = cast[ptr SKManagedStream](alloc(sizeof(SKManagedStream)))
  x[] = SKManagedStream(
    native: cast[ptr sk_stream_t](sk_managedstream_new(x)))
  x[]

template canSeek(s: SKManagedStream): bool = 
  not isNil s.stream.setPositionImpl

template verifyNative(s: SKManagedStream) =
  if s.wasCopied: raise newException(
    InvalidOperationError,
    "This stream was duplicated or forked and cannot be read anymore."
  )

proc read(s: SKManagedStream, buff: pointer, length: int): int =
  s.verifyNative
  s.stream.readData(buff, length)

proc atEnd(s: SKManagedStream): bool = 
  s.verifyNative
  s.atEnd()

proc peek(s: SKManagedStream, buff: pointer, length: int): int =
  s.verifyNative
  s.stream.peekData(buff, length)

proc hasPosition(s: SKManagedStream): bool = 
  s.verifyNative
  s.canSeek

proc hasLength(s: SKManagedStream): bool = false

proc rewind(s: SKManagedStream): bool =
  s.verifyNative
  if not s.canSeek: return false
  s.stream.setPosition(0)
  return true

proc getPosition(s: SKManagedStream): int =
  s.verifyNative
  if not s.canSeek: return 0
  return s.stream.getPosition()

proc getLength(s: SKManagedStream): int = 0

proc seek(s: SKManagedStream, position: int): bool =
  s.verifyNative
  if not s.canSeek: return false
  s.stream.setPosition(position)
  return true

proc move(s: SKManagedStream, offset: int): bool =
  s.verifyNative
  if isNil s.stream.setPositionImpl:
    return false
  let currPos = s.stream.getPosition()
  s.stream.setPosition(currPos + offset)
  return true

proc newSKManagedStream*(stream: Stream, disposeUnderlyingStream: bool = false): SKManagedStream =
  result = newSKManagedStreamInternal()

  result.wasCopied = false
  result.disposeUnderlyingStream = disposeUnderlyingStream
  result.stream = stream

  result.onReadImpl = read
  result.onIsAtEndImpl = atEnd
  result.onPeekImpl = peek
  result.onHasPositionImpl = hasPosition
  result.onHasLengthImpl = hasLength
  result.onRewindImpl = rewind
  result.onGetPositionImpl = getPosition
  result.onGetLengthImpl = getLength
  result.onSeekImpl = seek
  result.onMoveImpl = move

  proc duplicate(s: SKManagedStream): SKManagedStream =
    s.verifyNative
    
    if not s.canSeek: return nil
    
    var newStream = newSKManagedStream(
      s.stream, s.disposeUnderlyingStream
    )
    newStream.parent = s

    s.wasCopied = true
    s.disposeUnderlyingStream = false
    s.child = newStream

    s.stream.setPosition(0)

    return newStream
  
  proc fork(s: SKManagedStream): SKManagedStream =
    s.verifyNative

    var newStream = newSKManagedStream(
      s.stream, s.disposeUnderlyingStream
    )
    
    s.wasCopied = true
    s.disposeUnderlyingStream = false

    return newStream
  
  result.onDuplicateImpl = duplicate
  result.onForkImpl = fork

