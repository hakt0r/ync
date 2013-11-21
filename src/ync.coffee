###

  (S)ync - simply serialize, defer, and join async calls
  
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

if module? and module.exports?
  { EventEmitter } = require 'events'
else EventEmitter = class

Object.merge    = (t,d) -> t[k] = d[k] for k,v of d ; t
Object.defaults = (t,d) -> t[k] = d[k] for k,v of d when not t[k]?; t
Object.snatch   = (o,k) ->
  return if Array.isArray k then ( for f in k
    t = o[f]; delete o[f]; t )
  else ( t = o[k]; delete o[k]; t )

class Sync extends EventEmitter
  @count : 0

  constructor : (@chain) ->
    @id = Sync.count++
    @chain = Object.defaults @chain, debug : false, fork : false, run : true, title : "Sync-" + @id
    [ @debug, @fork, run, @title, @onexec, @end ] = Object.snatch @chain, ['debug','fork','run','title','onexec', 'end' ]
    if @debug
      require 'colors'
      console.log "new".yellow, "Sync".blue, @title.red, Object.keys @chain 
    @current = Object.keys(@chain).shift()
    @exec @current, [] if run

  run : (rule) =>
    @current = rule if rule?
    @exec @current, []

  exec : (rule,args) =>
    console.log "Executing".yellow, rule, args if @debug
    @onexec rule, @chain[rule] if @onexec
    if @fork then setTimeout (=> @chain[rule].apply this,args), 0
    else @chain[rule].apply this, args
    @end() if @end? and @current is Object.keys(@chain).pop()

  proceed : =>
    if @current is @last()
      args = v for k,v of arguments
      return @emit.apply this, ['done'].concat args
    @current = @next()
    @exec @current, arguments

  insertBefore : (what,name,func) =>
    s = @chain; l = {}
    keys = Object.keys(s)
    keys = keys.concat(name,keys.splice(keys.indexOf(what)))
    s[name] = func
    l[k] = s[k] for k in keys
    @chain = l

  insertAfter : (what,name,func) =>
    s = @chain; l = {}
    keys = Object.keys(s)
    keys = keys.concat(name,keys.splice(keys.indexOf(what)+1))
    s[name] = func
    l[k] = s[k] for k in keys
    @chain = l

  next  : =>
    k = Object.keys(@chain)
    i = k.indexOf(@current)
    return k[i+1] if i+1 < k.length

  first : => return Object.keys(@chain).shift()
  last  : => return Object.keys(@chain).pop()
  count : => return Object.keys(@chain).length

class Join
  @ids : 0
  constructor : (@block, @done) ->
    @done = @block if typeof @block is 'function'
    @block = false unless typeof @block is 'boolean'
    @id = Join.ids++
    @count = 0
    @part() if @block
  part : (arg) =>
    @count++
    setTimeout arg, 0 if typeof arg is 'function'
  join : => if --@count is 0 then @done() 
  end : (@done) => @join()

if window?
  window.Sync = Sync
  window.Join = Join

if module? and module.exports?
  module.exports.Sync = Sync
  module.exports.Join = Join