import unittest

import ../nimskia/sk_stream

import os
import oids
import strformat

const
  pathToImages = "resources"

suite "SkStream tests":

  let tmpDir = joinPath(getCurrentDir(), &"tmp_{genOid()}")
  if not dirExists tmpDir:
    createDir(tmpDir)

  test "Supports non-ASCII characters in path":
    let path = joinPath(pathToImages, "上田雅美.jpg")
    let stream = newSkFileStream(path)
    defer: stream.dispose()
    check(not isNil stream.native)
    check(stream.getLength() > 0)
    check(stream.isValid)

  test "Writeable file stream select correct Stream for ASCII path":
    let path = joinPath(tmpDir, &"{genOid()}.txt")
    let stream = openSkFileWStream(path)
    check(not isNil stream.native)
    defer: stream.dispose()
    check(stream.isValid)

  test "Writeable file stream select correct Stream for ASCII path":
    let path = joinPath(tmpDir, &"{genOid()}-上田雅美.txt")
    let stream = openSkFileWStream(path)
    check(not isNil stream.native)
    defer: stream.dispose()
    check(stream.isValid)

  test "File stream select correct stream for ASCII path":
    let path = joinPath(pathToImages, "color-wheel.png")
    let stream = openSkFileStream(path)
    defer: stream.dispose()
    check(not isNil stream)

  test "File stream select correct stream for non-ASCII path":
    let path = joinPath(pathToImages, "上田雅美.jpg")
    let stream = openSkFileStream(path)
    defer: stream.dispose()
    check(not isNil stream)

  test "File stream for missing file":
    let path = joinPath(pathToImages, "missing-image.png")
    check(isNil openSkFileStream(path))
    let stream = newSkFileStream(path)
    check(stream.getLength() == 0)
    check(stream.isValid == false)

  test "Memory stream can be duplicated":
    let stream = newSkMemoryStream(@[1.byte, 2, 3, 4, 5])
    check(stream.readByte() == 1);
    check(stream.readByte() == 2);
    check(stream.readByte() == 3);

    let dupe = stream.duplicate()
    check(dupe != stream)
    check(1 == dupe.readByte())
    check(4 == stream.readByte())
    check(2 == dupe.readByte())
    check(5 == stream.readByte())
    check(3 == dupe.readByte())

  test "Memory stream can be forked":
    let stream = newSkMemoryStream(@[1.byte, 2, 3, 4, 5])
    check(stream.readByte() == 1);
    check(stream.readByte() == 2);

    let fork = stream.fork()
    check(fork != stream)
    check(3 == fork.readByte())
    check(3 == stream.readByte())
    check(4 == fork.readByte())
    check(4 == stream.readByte())

  removeDir(tmpDir)
  
