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

events = require 'events'

class Sync extends events.EventEmitter
  constructor : (@chain) ->
    for i in ['debug','fork']
      if @chain[i]?
        @[i] = @chain[i]
        delete @chain[i]
      else @[i] = false
    require 'colors' if @debug
    @current = Object.keys(@chain).shift()
    @exec @current, []

  exec : (rule,args) ->
    console.log "Executing".yellow, rule, args if @debug
    if @fork
      setTimeout (=>
        @chain[rule].apply this,args
        ), 0
    else @chain[rule].apply this,args

  continue : ->
    if @current is @last()
      args = v for k,v of arguments
      return @emit.apply this, ['done'].concat args
    @current = @next()
    @exec @current, arguments

  insertAfter : (what,name,func) ->
    s = @chain; l = {}
    keys = Object.keys(s)
    keys = keys.concat(name,keys.splice(keys.indexOf(what)+1))
    s[name] = func
    l[k] = s[k] for k in keys
    @chain = l

  next  : ->
    k = Object.keys(@chain)
    i = k.indexOf(@current)
    return k[i+1] if i+1 < k.length

  first : -> return Object.keys(@chain).shift()
  last  : -> return Object.keys(@chain).pop()
  count : -> return Object.keys(@chain).length

module.exports = Sync