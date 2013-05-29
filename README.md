## ync - simply serialize async calls

### Installation
    $ sudo npm ync (TODO: publish)
    $ sudo npm install -g git://github.com/hakt0r/ync.git

### Node.JS Usage:
    var Sync = require('ync');

    var s = new Sync({
      step1 : function(value){
        this.proceed(123)
      },
      step2 : function(value){
        this.proceed(value+1)
      }
    })

    s.insertAfter("step1","step_in",function(value){
      this.proceed(value+1)
    })

    s.on('done', function(value){
      console.log(value)
    })

### Coffee Usage:

    Sync = require("ync")

    s = new Sync
      step1 : (value) -> @proceed 123
      step2 : (value) -> @proceed value + 1

    s.insertAfter "step1", "step_in", (value) -> @proceed value + 1

    s.on "done", (value) -> console.log value

### Copyrights
  * c) 2013 Sebastian Glaser <anx@ulzq.de>

### Licensed under GNU GPLv3

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