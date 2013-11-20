###

  (S)ync - simply serialize async calls
  
  c) 2013 Sebastian Glaser <anx@ulzq.de>

  This file is part of the ync project.

  ync is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2, or (at your option)
  any later version.

  ync is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this software; see the file COPYING.  If not, write to
  the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA 02111-1307 USA

  http://www.gnu.org/licenses/gpl.html

###

{ Sync, Join } = require './ync'
cp = require 'child_process'
require 'colors'

sequence = -> new Sync
  fork  : yes

  list_dir : ->
    cp.exec "echo SECRET_CODE", (e,s,m) =>
      @proceed(s)
  sleep : (data) ->
    cp.exec "sleep 0.5", =>
      @proceed(data)
  output : (data) ->
    @proceed data

tests = new Sync
  fork  : yes

  start : ->
    @count = 0; @success = 0
    @proceed()

  chain : ->
    stack = sequence()
    stack.on 'done', (data) ->
      tests.count++
      if data.trim() is "SECRET_CODE"
        tests.success++
        return console.log "Test success:".green,"simple_chain"
      else return console.log "Test fail:".red,"simple_chain"
    @proceed()

  insertion : ->
    stack = sequence()
    stack.insertAfter "sleep", "inject", (data) -> @proceed data + " and stuff"
    tests.count++
    stack.on 'done', (data) =>
      if data.trim() is "SECRET_CODE\n and stuff"
        tests.success++
        console.log "Test success:".green,"insertion"
      else console.log "Test fail:".red,"insertion"
      @proceed()

  done : ->
    @count++; @success++
    console.log "Test success:".green,"nesting"
    if @count is @success
      console.log "All tests succeeded:".yellow,
        @success.toString().green,'/',
        @count.toString().yellow
      process.exit(0)
    else
      console.log "Some tests failed:".yellow,
        @success.toString().red,'/',
        @count.toString().yellow
      process.exit(1)