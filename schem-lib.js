/* Shared schematic symbol library + lesson renderer */
var DC='</'+'div>';
function wrap(w,h,i){return '<svg viewBox="0 0 '+w+' '+h+'" xmlns="http://www.w3.org/2000/svg" role="img" font-family="system-ui,sans-serif" stroke-linecap="round">'+i+'</svg>';}
function ttl(x,y,t){return '<text x="'+x+'" y="'+y+'" font-size="13" font-weight="700" fill="#16202E">'+t+'</text>';}
function W(p){return '<polyline points="'+p+'" fill="none" stroke="#222" stroke-width="2"/>';}
function dot(x,y){return '<circle cx="'+x+'" cy="'+y+'" r="3" fill="#222"/>';}
function term(x,y,l,a){return '<circle cx="'+x+'" cy="'+y+'" r="4" fill="#fff" stroke="#222" stroke-width="2"/><text x="'+(a==="end"?x-9:x+9)+'" y="'+(y+4)+'" text-anchor="'+a+'" font-size="12" font-weight="700" fill="#16202E">'+l+'</text>';}
function termB(x,y,l){return '<circle cx="'+x+'" cy="'+y+'" r="4" fill="#fff" stroke="#222" stroke-width="2"/><text x="'+x+'" y="'+(y+18)+'" text-anchor="middle" font-size="11.5" font-weight="700" fill="#16202E">'+l+'</text>';}
function res(x,y,l){return '<path d="M'+x+' '+y+' l6 0 l3 -7 l6 14 l6 -14 l6 14 l6 -14 l6 14 l3 -7 l6 0" fill="none" stroke="#222" stroke-width="2"/>'+(l?'<text x="'+(x+22)+'" y="'+(y-11)+'" text-anchor="middle" font-size="10.5" fill="#16202E">'+l+'</text>':'');}
function resV(x,y,l){return '<path d="M'+x+' '+y+' l0 6 l-7 3 l14 6 l-14 6 l14 6 l-14 6 l14 6 l-7 3 l0 6" fill="none" stroke="#222" stroke-width="2"/>'+(l?'<text x="'+(x+12)+'" y="'+(y+26)+'" font-size="10.5" fill="#16202E">'+l+'</text>':'');}
function ledH(x,y,l){var c=x+16;return '<polygon points="'+x+','+(y-8)+' '+x+','+(y+8)+' '+c+','+y+'" fill="#E5392B" stroke="#A82318"/><line x1="'+c+'" y1="'+(y-8)+'" x2="'+c+'" y2="'+(y+8)+'" stroke="#A82318" stroke-width="2.5"/><line x1="'+(x+3)+'" y1="'+(y-11)+'" x2="'+(x+11)+'" y2="'+(y-19)+'" stroke="#A82318" stroke-width="1.5"/><line x1="'+(x+9)+'" y1="'+(y-11)+'" x2="'+(x+17)+'" y2="'+(y-19)+'" stroke="#A82318" stroke-width="1.5"/>'+(l?'<text x="'+(x+8)+'" y="'+(y+22)+'" text-anchor="middle" font-size="10.5" fill="#16202E">'+l+'</text>':'');}
function ledV(x,y){var c=y+16;return '<polygon points="'+(x-8)+','+y+' '+(x+8)+','+y+' '+x+','+c+'" fill="#E5392B" stroke="#A82318"/><line x1="'+(x-8)+'" y1="'+c+'" x2="'+(x+8)+'" y2="'+c+'" stroke="#A82318" stroke-width="2.5"/><line x1="'+(x+11)+'" y1="'+(y+2)+'" x2="'+(x+19)+'" y2="'+(y-6)+'" stroke="#A82318" stroke-width="1.5"/><line x1="'+(x+11)+'" y1="'+(y+8)+'" x2="'+(x+19)+'" y2="'+y+'" stroke="#A82318" stroke-width="1.5"/>';}
function gnd(x,y){return '<line x1="'+x+'" y1="'+y+'" x2="'+x+'" y2="'+(y+10)+'" stroke="#222" stroke-width="2"/><line x1="'+(x-9)+'" y1="'+(y+10)+'" x2="'+(x+9)+'" y2="'+(y+10)+'" stroke="#222" stroke-width="2"/><line x1="'+(x-5)+'" y1="'+(y+14)+'" x2="'+(x+5)+'" y2="'+(y+14)+'" stroke="#222" stroke-width="2"/><line x1="'+(x-2)+'" y1="'+(y+18)+'" x2="'+(x+2)+'" y2="'+(y+18)+'" stroke="#222" stroke-width="2"/>';}
function vcc(x,y,l){return '<line x1="'+x+'" y1="'+y+'" x2="'+x+'" y2="'+(y-10)+'" stroke="#222" stroke-width="2"/><line x1="'+(x-11)+'" y1="'+(y-10)+'" x2="'+(x+11)+'" y2="'+(y-10)+'" stroke="#C51A4A" stroke-width="2.5"/><text x="'+x+'" y="'+(y-15)+'" text-anchor="middle" font-size="11" font-weight="700" fill="#C51A4A">'+l+'</text>';}
function ic(x,y,w,h,t){return '<rect x="'+x+'" y="'+y+'" width="'+w+'" height="'+h+'" rx="5" fill="#F7FAFF" stroke="#16202E" stroke-width="1.5"/><text x="'+(x+w/2)+'" y="'+(y+16)+'" text-anchor="middle" font-size="11.5" font-weight="700" fill="#16202E">'+t+'</text>';}
function lpin(x,y,l){return '<line x1="'+(x-12)+'" y1="'+y+'" x2="'+x+'" y2="'+y+'" stroke="#222" stroke-width="2"/><text x="'+(x+5)+'" y="'+(y+4)+'" font-size="10.5" fill="#16202E">'+l+'</text>';}
function rpin(x,y,l){return '<line x1="'+x+'" y1="'+y+'" x2="'+(x+12)+'" y2="'+y+'" stroke="#222" stroke-width="2"/><text x="'+(x-5)+'" y="'+(y+4)+'" text-anchor="end" font-size="10.5" fill="#16202E">'+l+'</text>';}
function escc(s){return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
function copyCode(b){var t=b.parentNode.querySelector('code').textContent;navigator.clipboard.writeText(t).then(function(){var o=b.textContent;b.textContent='Copied';setTimeout(function(){b.textContent=o;},1300);});}
var LEGEND='<div class="legend"><b>Legend:</b> zig-zag = resistor; triangle+bar = LED; striped earth = ground (GND pin or minus rail); flag = 3V3/5V supply; circle = a Pi GPIO pin.</div>';
var KEYBOX='<div class="keybox"><b>Breadboard positions</b><ul>'
 +'<li>Columns <code>a b c d e</code> (left half) and <code>f g h i j</code> (right half); holes in the same row and half are joined.</li>'
 +'<li>Extension-board pins: left column at hole <b>e</b> (use free holes <b>a-d</b>); right column at hole <b>f</b> (use <b>g-j</b>). Find a pin by its printed label.</li>'
 +'<li>Build rows ~<b>21+</b> (below the board) have no pins; use them for component legs.</li>'
 +'<li>Rails: jumper a <code>GND</code> pin to the blue minus rail and a <code>3V3/5V</code> pin to the red plus rail.</li></ul></div>';
function noteHTML(t,cls){return '<div class="note '+cls+'">'+t+DC;}
function rowsTable(head,body){return '<table>'+head+body+'</table>';}
function renderLesson(d){
 var pr=d.rows.map(function(r){return '<tr><td><code>'+r[0]+'</code></td><td>'+r[1]+'</td><td>'+r[2]+'</td></tr>';}).join('');
 var h='<p class="bc"><a href="schematics.html">All lesson schematics</a></p>';
 h+='<div class="kick">'+d.sess+'</div><h1 class="title">'+d.title+'</h1>';
 h+='<figure>'+d.svg+'</figure>'+LEGEND;
 if(d.fig) h+=d.fig;
 if(d.code){
  h+='<div class="tt">Python - paste into PyCharm and Run</div>';
  var btn='<button class="cp" onclick="copyCode(this)">Copy</button>';
  h+='<div class="codewrap">'+btn+'<pre><code>'+escc(d.code)+'</code></pre>'+DC;
  if(d.run) h+=noteHTML(d.run,'runnote');
 }
 h+='<div class="tt">Pins and board holes</div>';
 h+=rowsTable('<tr><th>Pi pin</th><th>Board hole</th><th>Connects to</th></tr>',pr);
 if(d.place&&d.place.length){
  var p2=d.place.map(function(p){return '<tr><td>'+p[0]+'</td><td>'+p[1]+'</td><td>'+p[2]+'</td></tr>';}).join('');
  h+='<div class="tt">Breadboard placement (exact holes)</div>';
  h+=rowsTable('<tr><th>Part</th><th>End A</th><th>End B</th></tr>',p2);
 }
 if(d.note) h+=noteHTML(d.note,'');
 h+=KEYBOX;
 document.title='Schematic - '+d.title;
 document.getElementById('app').innerHTML=h;
}
