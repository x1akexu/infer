(*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)
open! IStd

let rename ~src ~dst = Caml_unix.rename src dst

let mkdir_p ?(perm = 0o777) name =
  let mkdir_idempotent ~perm dirname =
    try Caml_unix.mkdir dirname perm
    with
    (* [mkdir] on MacOSX returns [EISDIR] instead of [EEXIST] if the directory already
        exists. *)
    | Caml_unix.Unix_error ((EEXIST | EISDIR), _, _) ->
      ()
  in
  let rec mkdir_p ~perm dir =
    try mkdir_idempotent ~perm dir
    with Caml_unix.Unix_error (ENOENT, _, _) as exn ->
      let parent = Filename.dirname dir in
      if Filename.equal parent dir then raise exn
      else (
        mkdir_p ~perm parent ;
        mkdir_idempotent ~perm dir )
  in
  mkdir_p name ~perm
