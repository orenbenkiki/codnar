(function(h,o,f){var u=!+"\v1";var y=function(){return null;};var m=0;var q="plaintext";var l=function(A){function z(){}z.prototype=A;return new z();};var p=false;var i=function(A,C,z){for(var B=0;B<A.length;B++){if(A[B]===C){return true;}if(z&&typeof(A[B])==="string"&&typeof(C)==="string"&&A[B].toUpperCase()===C.toUpperCase()){return true;}}return false;};var e=function(z,A){if(!A){return z;}for(var B in A){z[B]=A[B];}return z;};var x=function(z){return z.replace(/[-\/\\^$*+?.()|[\]{}]/g,"\\$&");};var j=function(C,B,A,z){return function(G){var F=C;if(B===1){A.reverse();}for(var D=0,E,H;D<A.length;D++){H=G[F+(D*B)];E=A[A.length-1-D];if(H===f){if(E.optional!==f&&E.optional){F-=B;}else{return false;}}else{if(H.name===E.token&&(E.values===f||i(E.values,H.value,z))){continue;}else{if(E.optional!==f&&E.optional){F-=B;}else{return false;}}}}return true;};};var c=function(B,A,C,z){return function(F){var D=B,E;var G=false;while((E=F[--D])!==f){if(E.name===C.token&&i(C.values,E.value)){if(E.name===A.token&&i(A.values,E.value,z)){G=true;break;}return false;}if(E.name===A.token&&i(A.values,E.value,z)){G=true;break;}}if(!G){return false;}D=B;while((E=F[++D])!==f){if(E.name===A.token&&i(A.values,E.value,z)){if(E.name===C.token&&i(C.values,E.value,z)){G=true;break;}return false;}if(E.name===C.token&&i(C.values,E.value,z)){G=true;break;}}return G;};};var w=function(){var z=function(A){return function(C){var B=o.createElement("span");B.className="sunlight-"+A;B.appendChild(C.createTextNode(C.tokens[C.index].value));return C.addNode(B)||true;};};return{handleToken:function(A){return z(A.tokens[A.index].name)(A);},handle_default:function(A){return A.addNode(A.createTextNode(A.tokens[A.index].value));},handle_ident:function(A){var B=function(D,E){D=D||[];for(var C=0;C<D.length;C++){if(typeof(D[C])==="function"){if(D[C](A)){return z("named-ident")(A);}}else{if(E&&E(D[C])(A.tokens)){return z("named-ident")(A);}}}return false;};return B(A.language.namedIdentRules.custom)||B(A.language.namedIdentRules.follows,function(C){return j(A.index-1,-1,C.slice(0),A.language.caseInsensitive);})||B(A.language.namedIdentRules.precedes,function(C){return j(A.index+1,1,C.slice(0),A.language.caseInsensitive);})||B(A.language.namedIdentRules.between,function(C){return c(A.index,C.opener,C.closer,A.language.caseInsensitive);})||z("ident")(A);}};}();var r=function(E){E=E.replace(/\r\n/g,"\n").replace(/\r/g,"\n");var C=0;var H=1;var A=1;var z=E.length;var B=f;var G=z>0?E.charAt(0):B;var F=false;var D=function(J){if(J===0){return"";}J=J||1;var K="",I=1;while(I<=J&&E.charAt(C+I)!==""){K+=E.charAt(C+I++);}return K===""?B:K;};return{toString:function(){return"length: "+z+", index: "+C+", line: "+H+", column: "+A+", current: ["+G+"]";},peek:function(I){return D(I);},read:function(I){var K=D(I);if(K!==B){C+=K.length;A+=K.length;if(F){H++;A=1;F=false;}var J=K.substring(0,K.length-1).replace(/[^\n]/g,"").length;if(J>0){H+=J;A=1;}if(K.charAt(K.length-1)==="\n"){F=true;}G=K.charAt(K.length-1);}else{C=z;G=B;}return K;},getLine:function(){return H;},getColumn:function(){return A;},isEof:function(){return C>=z;},EOF:B,current:function(){return G;}};};var b=function(B,G,C,z){G=G||[];var F=B.reader.current();if(B.language.caseInsensitive){F=F.toUpperCase();}if(!G[F]){return null;}G=G[F];for(var E=0,A,H;E<G.length;E++){A=G[E].value;H=F+B.reader.peek(A.length);if(A===H||G[E].regex.test(H)){var I=B.reader.getLine(),D=B.reader.getColumn();return B.createToken(C,B.reader.current()+B.reader[z?"peek":"read"](A.length-1),I,D);}}return null;};var v=function(){var z=function(I,J){var G=I[2]||[];var F=I[1].length;var K=typeof(I[1])==="string"?new RegExp(x(I[1])):I[1].regex;var H=I[3]||false;return function(P,L,N,M,R,O){var Q=false,N=N||"";O=O?1:0;var S=function(V){var T;var W=P.reader.current();for(var U=0;U<G.length;U++){T=(V?W:"")+P.reader.peek(G[U].length-V);if(T===G[U]){N+=P.reader.read(T.length-V);return true;}}T=(V?W:"")+P.reader.peek(F-V);if(K.test(T)){Q=true;return false;}N+=V?W:P.reader.read();return true;};if(!O||S(true)){while(P.reader.peek()!==P.reader.EOF&&S(false)){}}if(O){N+=P.reader.current();P.reader.read();}else{N+=H||P.reader.peek()===P.reader.EOF?"":P.reader.read(F);}if(!Q){P.continuation=L;}return P.createToken(J,N,M,R);};};var D=function(H){var N=function(){return H.language.identFirstLetter&&H.language.identFirstLetter.test(H.reader.current());};var J=function(){return b(H,H.language.keywords,"keyword");};var O=function(){if(H.language.customTokens===f){return null;}for(var R in H.language.customTokens){var Q=b(H,H.language.customTokens[R],R);if(Q!==null){return Q;}}return null;};var M=function(){return b(H,H.language.operators,"operator");};var I=function(){var Q=H.reader.current();if(H.language.punctuation.test(x(Q))){return H.createToken("punctuation",Q,H.reader.getLine(),H.reader.getColumn());}return null;};var G=function(S){if(!N()){return null;}var U=H.reader.current();var R=H.reader.peek();var Q=H.reader.getLine(),T=H.reader.getColumn();while(R!==H.reader.EOF){if(!H.language.identAfterFirstLetter.test(R)){break;}U+=H.reader.read();R=H.reader.peek();}return H.createToken(S?"namedIdent":"ident",U,Q,T);};var P=function(){if(H.defaultData.text===""){H.defaultData.line=H.reader.getLine();H.defaultData.column=H.reader.getColumn();}H.defaultData.text+=H.reader.current();return null;};var F=function(){var X=H.reader.current();for(var W in H.language.scopes){var R=H.language.scopes[W];for(var T=0,V,S,U,Q;T<R.length;T++){V=R[T][0];if(V!==X+H.reader.peek(V.length-1)){continue;}S=H.reader.getLine(),U=H.reader.getColumn();H.reader.read(V.length-1);Q=z(R[T],W);return Q(H,Q,V,S,U);}}return null;};var K=function(){return H.language.numberParser(H);};var L=function(){var S=H.language.customParseRules;if(S===f){return null;}for(var R=0,Q;R<S.length;R++){Q=S[R](H);if(Q!==null){return Q;}}return null;};return L()||O()||J()||F()||G()||K()||M()||I()||P();};var E=function(I,K,F){var J=[];var H={reader:r(I),language:K,token:function(L){return J[L];},getAllTokens:function(){return J.slice(0);},count:function(){return J.length;},defaultData:{text:"",line:1,column:1},createToken:function(M,O,L,N){return{name:M,line:L,value:u?O.replace(/\n/g,"\r"):O,column:N};}};if(F){J.push(F(H,F,"",H.reader.getLine(),H.reader.getColumn(),true));}while(!H.reader.isEof()){var G=D(H);if(G!==null){if(H.defaultData.text!==""){J.push(H.createToken("default",H.defaultData.text,H.defaultData.line,H.defaultData.column));H.defaultData.text="";}if(G[0]!==f){J=J.concat(G);}else{J.push(G);}}H.reader.read();}if(H.defaultData.text!==""){J.push(H.createToken("default",H.defaultData.text,H.defaultData.line,H.defaultData.column));}return{tokens:J,continuation:H.continuation};};var B=function(I,L,J,H){var F=[];var G=E(I,L,J.continuation);var K=function(){var M=String.fromCharCode(160);var N=new Array(H.tabWidth+1).join(M);return function(O){return O.split(" ").join(M).split("\t").join(N);};}();return{tokens:(J.tokens||[]).concat(G.tokens),index:J.index?J.index+1:0,language:L,continuation:G.continuation,addNode:function(M){F.push(M);},createTextNode:function(M){return o.createTextNode(K(M));},getNodes:function(){return F;}};};var C=function(N,G,M){if(!p){p=function(){var P=null;if(o.defaultView&&o.defaultView.getComputedStyle){P=o.defaultView.getComputedStyle;}else{if(typeof(o.body.currentStyle)!=="undefined"){P=function(R,Q){return R.currentStyle;};}else{P=y;}}return function(Q,R){return P(Q,null)[R];};}();}M=M||{};var J=k[G];if(J===f){J=k[q];}var O=B(N,J,M,this.options);var L=J.analyzer;for(var K=M.index?M.index+1:0,I,H,F;K<O.tokens.length;K++){O.index=K;I=O.tokens[K].name;H="handle_"+I;L[H]?L[H](O):L.handleToken(O);}return O;};return{highlight:function(G,F){return C.call(this,G,F);},highlightNode:function A(Q){var J;if((J=Q.className.match(/(?:\s|^)sunlight-highlight-(\S+)(?:\s|$)/))===null||/(?:\s|^)sunlight-highlighted(?:\s|$)/.test(Q.className)){return;}var V=J[1];var K=0;for(var S=0,T,O,R,L;S<Q.childNodes.length;S++){if(Q.childNodes[S].nodeType===3){T=o.createElement("span");T.className="sunlight-highlighted sunlight-"+V;L=C.call(this,Q.childNodes[S].nodeValue,V,L);m++;K=K||m;O=L.getNodes();for(R=0;R<O.length;R++){T.appendChild(O[R]);}Q.replaceChild(T,Q.childNodes[S]);}else{A.call(this,Q.childNodes[S]);}}Q.className+=" sunlight-highlighted";if(this.options.lineNumbers===true||(p&&this.options.lineNumbers==="automatic"&&p(Q,"display")==="block")){var M=o.createElement("div"),F=o.createElement("pre");var P=Q.innerHTML.replace(/[^\n]/g,"").length-/\n$/.test(Q.lastChild.innerHTML);var G,W,N=this.options.lineHighlight.length>0;if(N){G=o.createElement("div");G.className="sunlight-line-highlight-overlay";}M.className="sunlight-container";F.className="sunlight-line-number-margin";for(var U=this.options.lineNumberStart,I=o.createTextNode(u?"\r":"\n"),H,X;U<=this.options.lineNumberStart+P;U++){H=o.createElement("a");X=(Q.id?Q.id:"sunlight-"+K)+"-line-"+U;H.setAttribute("name",X);H.setAttribute("href","#"+X);H.appendChild(o.createTextNode(U));F.appendChild(H);F.appendChild(I.cloneNode(false));if(N){W=o.createElement("div");if(i(this.options.lineHighlight,U)){W.className="sunlight-line-highlight-active";}G.appendChild(W);}}M.appendChild(F);Q.parentNode.insertBefore(M,Q);Q.parentNode.removeChild(Q);M.appendChild(Q);if(N){M.appendChild(G);}}}};}();var g=function(z){this.options=e(e({},a),z);};g.prototype=v;var d=function(C,z,B){B=B||1;var A=C[z+B];if(A!==f&&A.name==="default"){A=C[z+(B*2)];}return A;};var s=function(F,E,z){var A={};for(var B=0,D,C;B<F.length;B++){D=z?F[B].toUpperCase():F[B];C=D.charAt(0);if(!A[C]){A[C]=[];}A[C].push({value:D,regex:new RegExp(x(D)+E,z?"i":"")});}return A;};var t=function(C){var F=C.reader.current(),E,A=C.reader.getLine(),D=C.reader.getColumn();if(!/\d/.test(F)){if(F!=="."||!/\d/.test(C.reader.peek())){return null;}E=F+C.reader.read();}else{E=F;}var B,z=false;while((B=C.reader.peek())!==C.reader.EOF){if(!/[A-Za-z0-9]/.test(B)){if(B==="."&&!z){E+=C.reader.read();z=true;continue;}break;}E+=C.reader.read();}return C.createToken("number",E,A,D);};var a={tabWidth:4,lineNumbers:"automatic",lineNumberStart:1,lineHighlight:[]};var k={};var n={analyzer:l(w),customTokens:[],namedIdentRules:{},punctuation:/[^\w\s]/,numberParser:t,caseInsensitive:false};h.Sunlight={version:"1.3",Highlighter:g,createAnalyzer:function(){return l(w);},globalOptions:a,highlightAll:function(B){var A=new g(B);var z=o.getElementsByTagName("*");for(var C=0;C<z.length;C++){A.highlightNode(z[C]);}},registerLanguage:function(z,B){if(!z){throw'Languages must be registered with an identifier, e.g. "php" for PHP';}B=e(e({},n),B);B.name=z;B.keywords=s(B.keywords||[],"\\b",B.caseInsensitive);B.operators=s(B.operators||[],"",B.caseInsensitive);for(var A in B.customTokens){B.customTokens[A]=s(B.customTokens[A].values,B.customTokens[A].boundary,B.caseInsensitive);}k[B.name]=B;},util:{escapeSequences:["\\n","\\t","\\r","\\\\","\\v","\\f"],contains:i,matchWord:b,createHashMap:s,createBetweenRule:c,createProceduralRule:j,getNextNonWsToken:function(A,z){return d(A,z,1);},getPreviousNonWsToken:function(A,z){return d(A,z,-1);},whitespace:{token:"default",optional:true}}};h.Sunlight.registerLanguage(q,{punctuation:/(?!x)x/,numberParser:y});}(window,document));