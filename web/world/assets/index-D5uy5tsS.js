var _l=Object.defineProperty;var vl=(i,t,e)=>t in i?_l(i,t,{enumerable:!0,configurable:!0,writable:!0,value:e}):i[t]=e;var bo=(i,t,e)=>vl(i,typeof t!="symbol"?t+"":t,e);(function(){const t=document.createElement("link").relList;if(t&&t.supports&&t.supports("modulepreload"))return;for(const r of document.querySelectorAll('link[rel="modulepreload"]'))n(r);new MutationObserver(r=>{for(const s of r)if(s.type==="childList")for(const o of s.addedNodes)o.tagName==="LINK"&&o.rel==="modulepreload"&&n(o)}).observe(document,{childList:!0,subtree:!0});function e(r){const s={};return r.integrity&&(s.integrity=r.integrity),r.referrerPolicy&&(s.referrerPolicy=r.referrerPolicy),r.crossOrigin==="use-credentials"?s.credentials="include":r.crossOrigin==="anonymous"?s.credentials="omit":s.credentials="same-origin",s}function n(r){if(r.ep)return;r.ep=!0;const s=e(r);fetch(r.href,s)}})();/**
 * @license
 * Copyright 2010-2023 Three.js Authors
 * SPDX-License-Identifier: MIT
 */const Qs="160",Yn={ROTATE:0,DOLLY:1,PAN:2},jn={ROTATE:0,PAN:1,DOLLY_PAN:2,DOLLY_ROTATE:3},xl=0,Eo=1,Ml=2,fc=1,pc=2,ln=3,pn=0,Me=1,Ee=2,hn=0,xi=1,Fs=2,wo=3,To=4,yl=5,On=100,Sl=101,bl=102,Ao=103,Ro=104,El=200,wl=201,Tl=202,Al=203,Bs=204,zs=205,Rl=206,Cl=207,Pl=208,Ll=209,Dl=210,Il=211,Ul=212,Nl=213,Ol=214,Fl=0,Bl=1,zl=2,Nr=3,Gl=4,kl=5,Hl=6,Vl=7,mc=0,Xl=1,Wl=2,wn=0,gc=1,_c=2,vc=3,to=4,ql=5,xc=6,Mc=300,yi=301,Si=302,Gs=303,ks=304,Xr=306,bi=1e3,Ve=1001,Hs=1002,Le=1003,Co=1004,ts=1005,He=1006,Yl=1007,qi=1008,Tn=1009,jl=1010,$l=1011,eo=1012,yc=1013,bn=1014,En=1015,dn=1016,Sc=1017,bc=1018,zn=1020,Kl=1021,je=1023,Zl=1024,Jl=1025,Gn=1026,Ei=1027,Ql=1028,Ec=1029,tu=1030,wc=1031,Tc=1033,es=33776,ns=33777,is=33778,rs=33779,Po=35840,Lo=35841,Do=35842,Io=35843,Ac=36196,Uo=37492,No=37496,Oo=37808,Fo=37809,Bo=37810,zo=37811,Go=37812,ko=37813,Ho=37814,Vo=37815,Xo=37816,Wo=37817,qo=37818,Yo=37819,jo=37820,$o=37821,ss=36492,Ko=36494,Zo=36495,eu=36283,Jo=36284,Qo=36285,ta=36286,Rc=3e3,kn=3001,nu=3200,iu=3201,Cc=0,ru=1,Xe="",he="srgb",mn="srgb-linear",no="display-p3",Wr="display-p3-linear",Or="linear",se="srgb",Fr="rec709",Br="p3",$n=7680,ea=519,su=512,ou=513,au=514,Pc=515,cu=516,lu=517,uu=518,hu=519,Vs=35044,na="300 es",Xs=1035,un=2e3,zr=2001;class Vn{addEventListener(t,e){this._listeners===void 0&&(this._listeners={});const n=this._listeners;n[t]===void 0&&(n[t]=[]),n[t].indexOf(e)===-1&&n[t].push(e)}hasEventListener(t,e){if(this._listeners===void 0)return!1;const n=this._listeners;return n[t]!==void 0&&n[t].indexOf(e)!==-1}removeEventListener(t,e){if(this._listeners===void 0)return;const r=this._listeners[t];if(r!==void 0){const s=r.indexOf(e);s!==-1&&r.splice(s,1)}}dispatchEvent(t){if(this._listeners===void 0)return;const n=this._listeners[t.type];if(n!==void 0){t.target=this;const r=n.slice(0);for(let s=0,o=r.length;s<o;s++)r[s].call(this,t);t.target=null}}}const Se=["00","01","02","03","04","05","06","07","08","09","0a","0b","0c","0d","0e","0f","10","11","12","13","14","15","16","17","18","19","1a","1b","1c","1d","1e","1f","20","21","22","23","24","25","26","27","28","29","2a","2b","2c","2d","2e","2f","30","31","32","33","34","35","36","37","38","39","3a","3b","3c","3d","3e","3f","40","41","42","43","44","45","46","47","48","49","4a","4b","4c","4d","4e","4f","50","51","52","53","54","55","56","57","58","59","5a","5b","5c","5d","5e","5f","60","61","62","63","64","65","66","67","68","69","6a","6b","6c","6d","6e","6f","70","71","72","73","74","75","76","77","78","79","7a","7b","7c","7d","7e","7f","80","81","82","83","84","85","86","87","88","89","8a","8b","8c","8d","8e","8f","90","91","92","93","94","95","96","97","98","99","9a","9b","9c","9d","9e","9f","a0","a1","a2","a3","a4","a5","a6","a7","a8","a9","aa","ab","ac","ad","ae","af","b0","b1","b2","b3","b4","b5","b6","b7","b8","b9","ba","bb","bc","bd","be","bf","c0","c1","c2","c3","c4","c5","c6","c7","c8","c9","ca","cb","cc","cd","ce","cf","d0","d1","d2","d3","d4","d5","d6","d7","d8","d9","da","db","dc","dd","de","df","e0","e1","e2","e3","e4","e5","e6","e7","e8","e9","ea","eb","ec","ed","ee","ef","f0","f1","f2","f3","f4","f5","f6","f7","f8","f9","fa","fb","fc","fd","fe","ff"];let ia=1234567;const ki=Math.PI/180,Yi=180/Math.PI;function fn(){const i=Math.random()*4294967295|0,t=Math.random()*4294967295|0,e=Math.random()*4294967295|0,n=Math.random()*4294967295|0;return(Se[i&255]+Se[i>>8&255]+Se[i>>16&255]+Se[i>>24&255]+"-"+Se[t&255]+Se[t>>8&255]+"-"+Se[t>>16&15|64]+Se[t>>24&255]+"-"+Se[e&63|128]+Se[e>>8&255]+"-"+Se[e>>16&255]+Se[e>>24&255]+Se[n&255]+Se[n>>8&255]+Se[n>>16&255]+Se[n>>24&255]).toLowerCase()}function xe(i,t,e){return Math.max(t,Math.min(e,i))}function io(i,t){return(i%t+t)%t}function du(i,t,e,n,r){return n+(i-t)*(r-n)/(e-t)}function fu(i,t,e){return i!==t?(e-i)/(t-i):0}function Hi(i,t,e){return(1-e)*i+e*t}function pu(i,t,e,n){return Hi(i,t,1-Math.exp(-e*n))}function mu(i,t=1){return t-Math.abs(io(i,t*2)-t)}function gu(i,t,e){return i<=t?0:i>=e?1:(i=(i-t)/(e-t),i*i*(3-2*i))}function _u(i,t,e){return i<=t?0:i>=e?1:(i=(i-t)/(e-t),i*i*i*(i*(i*6-15)+10))}function vu(i,t){return i+Math.floor(Math.random()*(t-i+1))}function xu(i,t){return i+Math.random()*(t-i)}function Mu(i){return i*(.5-Math.random())}function yu(i){i!==void 0&&(ia=i);let t=ia+=1831565813;return t=Math.imul(t^t>>>15,t|1),t^=t+Math.imul(t^t>>>7,t|61),((t^t>>>14)>>>0)/4294967296}function Su(i){return i*ki}function bu(i){return i*Yi}function Ws(i){return(i&i-1)===0&&i!==0}function Eu(i){return Math.pow(2,Math.ceil(Math.log(i)/Math.LN2))}function Gr(i){return Math.pow(2,Math.floor(Math.log(i)/Math.LN2))}function wu(i,t,e,n,r){const s=Math.cos,o=Math.sin,a=s(e/2),c=o(e/2),l=s((t+n)/2),h=o((t+n)/2),f=s((t-n)/2),m=o((t-n)/2),p=s((n-t)/2),_=o((n-t)/2);switch(r){case"XYX":i.set(a*h,c*f,c*m,a*l);break;case"YZY":i.set(c*m,a*h,c*f,a*l);break;case"ZXZ":i.set(c*f,c*m,a*h,a*l);break;case"XZX":i.set(a*h,c*_,c*p,a*l);break;case"YXY":i.set(c*p,a*h,c*_,a*l);break;case"ZYZ":i.set(c*_,c*p,a*h,a*l);break;default:console.warn("THREE.MathUtils: .setQuaternionFromProperEuler() encountered an unknown order: "+r)}}function tn(i,t){switch(t.constructor){case Float32Array:return i;case Uint32Array:return i/4294967295;case Uint16Array:return i/65535;case Uint8Array:return i/255;case Int32Array:return Math.max(i/2147483647,-1);case Int16Array:return Math.max(i/32767,-1);case Int8Array:return Math.max(i/127,-1);default:throw new Error("Invalid component type.")}}function ne(i,t){switch(t.constructor){case Float32Array:return i;case Uint32Array:return Math.round(i*4294967295);case Uint16Array:return Math.round(i*65535);case Uint8Array:return Math.round(i*255);case Int32Array:return Math.round(i*2147483647);case Int16Array:return Math.round(i*32767);case Int8Array:return Math.round(i*127);default:throw new Error("Invalid component type.")}}const Lc={DEG2RAD:ki,RAD2DEG:Yi,generateUUID:fn,clamp:xe,euclideanModulo:io,mapLinear:du,inverseLerp:fu,lerp:Hi,damp:pu,pingpong:mu,smoothstep:gu,smootherstep:_u,randInt:vu,randFloat:xu,randFloatSpread:Mu,seededRandom:yu,degToRad:Su,radToDeg:bu,isPowerOfTwo:Ws,ceilPowerOfTwo:Eu,floorPowerOfTwo:Gr,setQuaternionFromProperEuler:wu,normalize:ne,denormalize:tn};class At{constructor(t=0,e=0){At.prototype.isVector2=!0,this.x=t,this.y=e}get width(){return this.x}set width(t){this.x=t}get height(){return this.y}set height(t){this.y=t}set(t,e){return this.x=t,this.y=e,this}setScalar(t){return this.x=t,this.y=t,this}setX(t){return this.x=t,this}setY(t){return this.y=t,this}setComponent(t,e){switch(t){case 0:this.x=e;break;case 1:this.y=e;break;default:throw new Error("index is out of range: "+t)}return this}getComponent(t){switch(t){case 0:return this.x;case 1:return this.y;default:throw new Error("index is out of range: "+t)}}clone(){return new this.constructor(this.x,this.y)}copy(t){return this.x=t.x,this.y=t.y,this}add(t){return this.x+=t.x,this.y+=t.y,this}addScalar(t){return this.x+=t,this.y+=t,this}addVectors(t,e){return this.x=t.x+e.x,this.y=t.y+e.y,this}addScaledVector(t,e){return this.x+=t.x*e,this.y+=t.y*e,this}sub(t){return this.x-=t.x,this.y-=t.y,this}subScalar(t){return this.x-=t,this.y-=t,this}subVectors(t,e){return this.x=t.x-e.x,this.y=t.y-e.y,this}multiply(t){return this.x*=t.x,this.y*=t.y,this}multiplyScalar(t){return this.x*=t,this.y*=t,this}divide(t){return this.x/=t.x,this.y/=t.y,this}divideScalar(t){return this.multiplyScalar(1/t)}applyMatrix3(t){const e=this.x,n=this.y,r=t.elements;return this.x=r[0]*e+r[3]*n+r[6],this.y=r[1]*e+r[4]*n+r[7],this}min(t){return this.x=Math.min(this.x,t.x),this.y=Math.min(this.y,t.y),this}max(t){return this.x=Math.max(this.x,t.x),this.y=Math.max(this.y,t.y),this}clamp(t,e){return this.x=Math.max(t.x,Math.min(e.x,this.x)),this.y=Math.max(t.y,Math.min(e.y,this.y)),this}clampScalar(t,e){return this.x=Math.max(t,Math.min(e,this.x)),this.y=Math.max(t,Math.min(e,this.y)),this}clampLength(t,e){const n=this.length();return this.divideScalar(n||1).multiplyScalar(Math.max(t,Math.min(e,n)))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this}negate(){return this.x=-this.x,this.y=-this.y,this}dot(t){return this.x*t.x+this.y*t.y}cross(t){return this.x*t.y-this.y*t.x}lengthSq(){return this.x*this.x+this.y*this.y}length(){return Math.sqrt(this.x*this.x+this.y*this.y)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)}normalize(){return this.divideScalar(this.length()||1)}angle(){return Math.atan2(-this.y,-this.x)+Math.PI}angleTo(t){const e=Math.sqrt(this.lengthSq()*t.lengthSq());if(e===0)return Math.PI/2;const n=this.dot(t)/e;return Math.acos(xe(n,-1,1))}distanceTo(t){return Math.sqrt(this.distanceToSquared(t))}distanceToSquared(t){const e=this.x-t.x,n=this.y-t.y;return e*e+n*n}manhattanDistanceTo(t){return Math.abs(this.x-t.x)+Math.abs(this.y-t.y)}setLength(t){return this.normalize().multiplyScalar(t)}lerp(t,e){return this.x+=(t.x-this.x)*e,this.y+=(t.y-this.y)*e,this}lerpVectors(t,e,n){return this.x=t.x+(e.x-t.x)*n,this.y=t.y+(e.y-t.y)*n,this}equals(t){return t.x===this.x&&t.y===this.y}fromArray(t,e=0){return this.x=t[e],this.y=t[e+1],this}toArray(t=[],e=0){return t[e]=this.x,t[e+1]=this.y,t}fromBufferAttribute(t,e){return this.x=t.getX(e),this.y=t.getY(e),this}rotateAround(t,e){const n=Math.cos(e),r=Math.sin(e),s=this.x-t.x,o=this.y-t.y;return this.x=s*n-o*r+t.x,this.y=s*r+o*n+t.y,this}random(){return this.x=Math.random(),this.y=Math.random(),this}*[Symbol.iterator](){yield this.x,yield this.y}}class Kt{constructor(t,e,n,r,s,o,a,c,l){Kt.prototype.isMatrix3=!0,this.elements=[1,0,0,0,1,0,0,0,1],t!==void 0&&this.set(t,e,n,r,s,o,a,c,l)}set(t,e,n,r,s,o,a,c,l){const h=this.elements;return h[0]=t,h[1]=r,h[2]=a,h[3]=e,h[4]=s,h[5]=c,h[6]=n,h[7]=o,h[8]=l,this}identity(){return this.set(1,0,0,0,1,0,0,0,1),this}copy(t){const e=this.elements,n=t.elements;return e[0]=n[0],e[1]=n[1],e[2]=n[2],e[3]=n[3],e[4]=n[4],e[5]=n[5],e[6]=n[6],e[7]=n[7],e[8]=n[8],this}extractBasis(t,e,n){return t.setFromMatrix3Column(this,0),e.setFromMatrix3Column(this,1),n.setFromMatrix3Column(this,2),this}setFromMatrix4(t){const e=t.elements;return this.set(e[0],e[4],e[8],e[1],e[5],e[9],e[2],e[6],e[10]),this}multiply(t){return this.multiplyMatrices(this,t)}premultiply(t){return this.multiplyMatrices(t,this)}multiplyMatrices(t,e){const n=t.elements,r=e.elements,s=this.elements,o=n[0],a=n[3],c=n[6],l=n[1],h=n[4],f=n[7],m=n[2],p=n[5],_=n[8],x=r[0],d=r[3],u=r[6],M=r[1],g=r[4],y=r[7],L=r[2],C=r[5],D=r[8];return s[0]=o*x+a*M+c*L,s[3]=o*d+a*g+c*C,s[6]=o*u+a*y+c*D,s[1]=l*x+h*M+f*L,s[4]=l*d+h*g+f*C,s[7]=l*u+h*y+f*D,s[2]=m*x+p*M+_*L,s[5]=m*d+p*g+_*C,s[8]=m*u+p*y+_*D,this}multiplyScalar(t){const e=this.elements;return e[0]*=t,e[3]*=t,e[6]*=t,e[1]*=t,e[4]*=t,e[7]*=t,e[2]*=t,e[5]*=t,e[8]*=t,this}determinant(){const t=this.elements,e=t[0],n=t[1],r=t[2],s=t[3],o=t[4],a=t[5],c=t[6],l=t[7],h=t[8];return e*o*h-e*a*l-n*s*h+n*a*c+r*s*l-r*o*c}invert(){const t=this.elements,e=t[0],n=t[1],r=t[2],s=t[3],o=t[4],a=t[5],c=t[6],l=t[7],h=t[8],f=h*o-a*l,m=a*c-h*s,p=l*s-o*c,_=e*f+n*m+r*p;if(_===0)return this.set(0,0,0,0,0,0,0,0,0);const x=1/_;return t[0]=f*x,t[1]=(r*l-h*n)*x,t[2]=(a*n-r*o)*x,t[3]=m*x,t[4]=(h*e-r*c)*x,t[5]=(r*s-a*e)*x,t[6]=p*x,t[7]=(n*c-l*e)*x,t[8]=(o*e-n*s)*x,this}transpose(){let t;const e=this.elements;return t=e[1],e[1]=e[3],e[3]=t,t=e[2],e[2]=e[6],e[6]=t,t=e[5],e[5]=e[7],e[7]=t,this}getNormalMatrix(t){return this.setFromMatrix4(t).invert().transpose()}transposeIntoArray(t){const e=this.elements;return t[0]=e[0],t[1]=e[3],t[2]=e[6],t[3]=e[1],t[4]=e[4],t[5]=e[7],t[6]=e[2],t[7]=e[5],t[8]=e[8],this}setUvTransform(t,e,n,r,s,o,a){const c=Math.cos(s),l=Math.sin(s);return this.set(n*c,n*l,-n*(c*o+l*a)+o+t,-r*l,r*c,-r*(-l*o+c*a)+a+e,0,0,1),this}scale(t,e){return this.premultiply(os.makeScale(t,e)),this}rotate(t){return this.premultiply(os.makeRotation(-t)),this}translate(t,e){return this.premultiply(os.makeTranslation(t,e)),this}makeTranslation(t,e){return t.isVector2?this.set(1,0,t.x,0,1,t.y,0,0,1):this.set(1,0,t,0,1,e,0,0,1),this}makeRotation(t){const e=Math.cos(t),n=Math.sin(t);return this.set(e,-n,0,n,e,0,0,0,1),this}makeScale(t,e){return this.set(t,0,0,0,e,0,0,0,1),this}equals(t){const e=this.elements,n=t.elements;for(let r=0;r<9;r++)if(e[r]!==n[r])return!1;return!0}fromArray(t,e=0){for(let n=0;n<9;n++)this.elements[n]=t[n+e];return this}toArray(t=[],e=0){const n=this.elements;return t[e]=n[0],t[e+1]=n[1],t[e+2]=n[2],t[e+3]=n[3],t[e+4]=n[4],t[e+5]=n[5],t[e+6]=n[6],t[e+7]=n[7],t[e+8]=n[8],t}clone(){return new this.constructor().fromArray(this.elements)}}const os=new Kt;function Dc(i){for(let t=i.length-1;t>=0;--t)if(i[t]>=65535)return!0;return!1}function kr(i){return document.createElementNS("http://www.w3.org/1999/xhtml",i)}function Tu(){const i=kr("canvas");return i.style.display="block",i}const ra={};function Vi(i){i in ra||(ra[i]=!0,console.warn(i))}const sa=new Kt().set(.8224621,.177538,0,.0331941,.9668058,0,.0170827,.0723974,.9105199),oa=new Kt().set(1.2249401,-.2249404,0,-.0420569,1.0420571,0,-.0196376,-.0786361,1.0982735),tr={[mn]:{transfer:Or,primaries:Fr,toReference:i=>i,fromReference:i=>i},[he]:{transfer:se,primaries:Fr,toReference:i=>i.convertSRGBToLinear(),fromReference:i=>i.convertLinearToSRGB()},[Wr]:{transfer:Or,primaries:Br,toReference:i=>i.applyMatrix3(oa),fromReference:i=>i.applyMatrix3(sa)},[no]:{transfer:se,primaries:Br,toReference:i=>i.convertSRGBToLinear().applyMatrix3(oa),fromReference:i=>i.applyMatrix3(sa).convertLinearToSRGB()}},Au=new Set([mn,Wr]),te={enabled:!0,_workingColorSpace:mn,get workingColorSpace(){return this._workingColorSpace},set workingColorSpace(i){if(!Au.has(i))throw new Error(`Unsupported working color space, "${i}".`);this._workingColorSpace=i},convert:function(i,t,e){if(this.enabled===!1||t===e||!t||!e)return i;const n=tr[t].toReference,r=tr[e].fromReference;return r(n(i))},fromWorkingColorSpace:function(i,t){return this.convert(i,this._workingColorSpace,t)},toWorkingColorSpace:function(i,t){return this.convert(i,t,this._workingColorSpace)},getPrimaries:function(i){return tr[i].primaries},getTransfer:function(i){return i===Xe?Or:tr[i].transfer}};function Mi(i){return i<.04045?i*.0773993808:Math.pow(i*.9478672986+.0521327014,2.4)}function as(i){return i<.0031308?i*12.92:1.055*Math.pow(i,.41666)-.055}let Kn;class Ic{static getDataURL(t){if(/^data:/i.test(t.src)||typeof HTMLCanvasElement>"u")return t.src;let e;if(t instanceof HTMLCanvasElement)e=t;else{Kn===void 0&&(Kn=kr("canvas")),Kn.width=t.width,Kn.height=t.height;const n=Kn.getContext("2d");t instanceof ImageData?n.putImageData(t,0,0):n.drawImage(t,0,0,t.width,t.height),e=Kn}return e.width>2048||e.height>2048?(console.warn("THREE.ImageUtils.getDataURL: Image converted to jpg for performance reasons",t),e.toDataURL("image/jpeg",.6)):e.toDataURL("image/png")}static sRGBToLinear(t){if(typeof HTMLImageElement<"u"&&t instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&t instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&t instanceof ImageBitmap){const e=kr("canvas");e.width=t.width,e.height=t.height;const n=e.getContext("2d");n.drawImage(t,0,0,t.width,t.height);const r=n.getImageData(0,0,t.width,t.height),s=r.data;for(let o=0;o<s.length;o++)s[o]=Mi(s[o]/255)*255;return n.putImageData(r,0,0),e}else if(t.data){const e=t.data.slice(0);for(let n=0;n<e.length;n++)e instanceof Uint8Array||e instanceof Uint8ClampedArray?e[n]=Math.floor(Mi(e[n]/255)*255):e[n]=Mi(e[n]);return{data:e,width:t.width,height:t.height}}else return console.warn("THREE.ImageUtils.sRGBToLinear(): Unsupported image type. No color space conversion applied."),t}}let Ru=0;class Uc{constructor(t=null){this.isSource=!0,Object.defineProperty(this,"id",{value:Ru++}),this.uuid=fn(),this.data=t,this.version=0}set needsUpdate(t){t===!0&&this.version++}toJSON(t){const e=t===void 0||typeof t=="string";if(!e&&t.images[this.uuid]!==void 0)return t.images[this.uuid];const n={uuid:this.uuid,url:""},r=this.data;if(r!==null){let s;if(Array.isArray(r)){s=[];for(let o=0,a=r.length;o<a;o++)r[o].isDataTexture?s.push(cs(r[o].image)):s.push(cs(r[o]))}else s=cs(r);n.url=s}return e||(t.images[this.uuid]=n),n}}function cs(i){return typeof HTMLImageElement<"u"&&i instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&i instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&i instanceof ImageBitmap?Ic.getDataURL(i):i.data?{data:Array.from(i.data),width:i.width,height:i.height,type:i.data.constructor.name}:(console.warn("THREE.Texture: Unable to serialize Texture."),{})}let Cu=0;class Te extends Vn{constructor(t=Te.DEFAULT_IMAGE,e=Te.DEFAULT_MAPPING,n=Ve,r=Ve,s=He,o=qi,a=je,c=Tn,l=Te.DEFAULT_ANISOTROPY,h=Xe){super(),this.isTexture=!0,Object.defineProperty(this,"id",{value:Cu++}),this.uuid=fn(),this.name="",this.source=new Uc(t),this.mipmaps=[],this.mapping=e,this.channel=0,this.wrapS=n,this.wrapT=r,this.magFilter=s,this.minFilter=o,this.anisotropy=l,this.format=a,this.internalFormat=null,this.type=c,this.offset=new At(0,0),this.repeat=new At(1,1),this.center=new At(0,0),this.rotation=0,this.matrixAutoUpdate=!0,this.matrix=new Kt,this.generateMipmaps=!0,this.premultiplyAlpha=!1,this.flipY=!0,this.unpackAlignment=4,typeof h=="string"?this.colorSpace=h:(Vi("THREE.Texture: Property .encoding has been replaced by .colorSpace."),this.colorSpace=h===kn?he:Xe),this.userData={},this.version=0,this.onUpdate=null,this.isRenderTargetTexture=!1,this.needsPMREMUpdate=!1}get image(){return this.source.data}set image(t=null){this.source.data=t}updateMatrix(){this.matrix.setUvTransform(this.offset.x,this.offset.y,this.repeat.x,this.repeat.y,this.rotation,this.center.x,this.center.y)}clone(){return new this.constructor().copy(this)}copy(t){return this.name=t.name,this.source=t.source,this.mipmaps=t.mipmaps.slice(0),this.mapping=t.mapping,this.channel=t.channel,this.wrapS=t.wrapS,this.wrapT=t.wrapT,this.magFilter=t.magFilter,this.minFilter=t.minFilter,this.anisotropy=t.anisotropy,this.format=t.format,this.internalFormat=t.internalFormat,this.type=t.type,this.offset.copy(t.offset),this.repeat.copy(t.repeat),this.center.copy(t.center),this.rotation=t.rotation,this.matrixAutoUpdate=t.matrixAutoUpdate,this.matrix.copy(t.matrix),this.generateMipmaps=t.generateMipmaps,this.premultiplyAlpha=t.premultiplyAlpha,this.flipY=t.flipY,this.unpackAlignment=t.unpackAlignment,this.colorSpace=t.colorSpace,this.userData=JSON.parse(JSON.stringify(t.userData)),this.needsUpdate=!0,this}toJSON(t){const e=t===void 0||typeof t=="string";if(!e&&t.textures[this.uuid]!==void 0)return t.textures[this.uuid];const n={metadata:{version:4.6,type:"Texture",generator:"Texture.toJSON"},uuid:this.uuid,name:this.name,image:this.source.toJSON(t).uuid,mapping:this.mapping,channel:this.channel,repeat:[this.repeat.x,this.repeat.y],offset:[this.offset.x,this.offset.y],center:[this.center.x,this.center.y],rotation:this.rotation,wrap:[this.wrapS,this.wrapT],format:this.format,internalFormat:this.internalFormat,type:this.type,colorSpace:this.colorSpace,minFilter:this.minFilter,magFilter:this.magFilter,anisotropy:this.anisotropy,flipY:this.flipY,generateMipmaps:this.generateMipmaps,premultiplyAlpha:this.premultiplyAlpha,unpackAlignment:this.unpackAlignment};return Object.keys(this.userData).length>0&&(n.userData=this.userData),e||(t.textures[this.uuid]=n),n}dispose(){this.dispatchEvent({type:"dispose"})}transformUv(t){if(this.mapping!==Mc)return t;if(t.applyMatrix3(this.matrix),t.x<0||t.x>1)switch(this.wrapS){case bi:t.x=t.x-Math.floor(t.x);break;case Ve:t.x=t.x<0?0:1;break;case Hs:Math.abs(Math.floor(t.x)%2)===1?t.x=Math.ceil(t.x)-t.x:t.x=t.x-Math.floor(t.x);break}if(t.y<0||t.y>1)switch(this.wrapT){case bi:t.y=t.y-Math.floor(t.y);break;case Ve:t.y=t.y<0?0:1;break;case Hs:Math.abs(Math.floor(t.y)%2)===1?t.y=Math.ceil(t.y)-t.y:t.y=t.y-Math.floor(t.y);break}return this.flipY&&(t.y=1-t.y),t}set needsUpdate(t){t===!0&&(this.version++,this.source.needsUpdate=!0)}get encoding(){return Vi("THREE.Texture: Property .encoding has been replaced by .colorSpace."),this.colorSpace===he?kn:Rc}set encoding(t){Vi("THREE.Texture: Property .encoding has been replaced by .colorSpace."),this.colorSpace=t===kn?he:Xe}}Te.DEFAULT_IMAGE=null;Te.DEFAULT_MAPPING=Mc;Te.DEFAULT_ANISOTROPY=1;class oe{constructor(t=0,e=0,n=0,r=1){oe.prototype.isVector4=!0,this.x=t,this.y=e,this.z=n,this.w=r}get width(){return this.z}set width(t){this.z=t}get height(){return this.w}set height(t){this.w=t}set(t,e,n,r){return this.x=t,this.y=e,this.z=n,this.w=r,this}setScalar(t){return this.x=t,this.y=t,this.z=t,this.w=t,this}setX(t){return this.x=t,this}setY(t){return this.y=t,this}setZ(t){return this.z=t,this}setW(t){return this.w=t,this}setComponent(t,e){switch(t){case 0:this.x=e;break;case 1:this.y=e;break;case 2:this.z=e;break;case 3:this.w=e;break;default:throw new Error("index is out of range: "+t)}return this}getComponent(t){switch(t){case 0:return this.x;case 1:return this.y;case 2:return this.z;case 3:return this.w;default:throw new Error("index is out of range: "+t)}}clone(){return new this.constructor(this.x,this.y,this.z,this.w)}copy(t){return this.x=t.x,this.y=t.y,this.z=t.z,this.w=t.w!==void 0?t.w:1,this}add(t){return this.x+=t.x,this.y+=t.y,this.z+=t.z,this.w+=t.w,this}addScalar(t){return this.x+=t,this.y+=t,this.z+=t,this.w+=t,this}addVectors(t,e){return this.x=t.x+e.x,this.y=t.y+e.y,this.z=t.z+e.z,this.w=t.w+e.w,this}addScaledVector(t,e){return this.x+=t.x*e,this.y+=t.y*e,this.z+=t.z*e,this.w+=t.w*e,this}sub(t){return this.x-=t.x,this.y-=t.y,this.z-=t.z,this.w-=t.w,this}subScalar(t){return this.x-=t,this.y-=t,this.z-=t,this.w-=t,this}subVectors(t,e){return this.x=t.x-e.x,this.y=t.y-e.y,this.z=t.z-e.z,this.w=t.w-e.w,this}multiply(t){return this.x*=t.x,this.y*=t.y,this.z*=t.z,this.w*=t.w,this}multiplyScalar(t){return this.x*=t,this.y*=t,this.z*=t,this.w*=t,this}applyMatrix4(t){const e=this.x,n=this.y,r=this.z,s=this.w,o=t.elements;return this.x=o[0]*e+o[4]*n+o[8]*r+o[12]*s,this.y=o[1]*e+o[5]*n+o[9]*r+o[13]*s,this.z=o[2]*e+o[6]*n+o[10]*r+o[14]*s,this.w=o[3]*e+o[7]*n+o[11]*r+o[15]*s,this}divideScalar(t){return this.multiplyScalar(1/t)}setAxisAngleFromQuaternion(t){this.w=2*Math.acos(t.w);const e=Math.sqrt(1-t.w*t.w);return e<1e-4?(this.x=1,this.y=0,this.z=0):(this.x=t.x/e,this.y=t.y/e,this.z=t.z/e),this}setAxisAngleFromRotationMatrix(t){let e,n,r,s;const c=t.elements,l=c[0],h=c[4],f=c[8],m=c[1],p=c[5],_=c[9],x=c[2],d=c[6],u=c[10];if(Math.abs(h-m)<.01&&Math.abs(f-x)<.01&&Math.abs(_-d)<.01){if(Math.abs(h+m)<.1&&Math.abs(f+x)<.1&&Math.abs(_+d)<.1&&Math.abs(l+p+u-3)<.1)return this.set(1,0,0,0),this;e=Math.PI;const g=(l+1)/2,y=(p+1)/2,L=(u+1)/2,C=(h+m)/4,D=(f+x)/4,F=(_+d)/4;return g>y&&g>L?g<.01?(n=0,r=.707106781,s=.707106781):(n=Math.sqrt(g),r=C/n,s=D/n):y>L?y<.01?(n=.707106781,r=0,s=.707106781):(r=Math.sqrt(y),n=C/r,s=F/r):L<.01?(n=.707106781,r=.707106781,s=0):(s=Math.sqrt(L),n=D/s,r=F/s),this.set(n,r,s,e),this}let M=Math.sqrt((d-_)*(d-_)+(f-x)*(f-x)+(m-h)*(m-h));return Math.abs(M)<.001&&(M=1),this.x=(d-_)/M,this.y=(f-x)/M,this.z=(m-h)/M,this.w=Math.acos((l+p+u-1)/2),this}min(t){return this.x=Math.min(this.x,t.x),this.y=Math.min(this.y,t.y),this.z=Math.min(this.z,t.z),this.w=Math.min(this.w,t.w),this}max(t){return this.x=Math.max(this.x,t.x),this.y=Math.max(this.y,t.y),this.z=Math.max(this.z,t.z),this.w=Math.max(this.w,t.w),this}clamp(t,e){return this.x=Math.max(t.x,Math.min(e.x,this.x)),this.y=Math.max(t.y,Math.min(e.y,this.y)),this.z=Math.max(t.z,Math.min(e.z,this.z)),this.w=Math.max(t.w,Math.min(e.w,this.w)),this}clampScalar(t,e){return this.x=Math.max(t,Math.min(e,this.x)),this.y=Math.max(t,Math.min(e,this.y)),this.z=Math.max(t,Math.min(e,this.z)),this.w=Math.max(t,Math.min(e,this.w)),this}clampLength(t,e){const n=this.length();return this.divideScalar(n||1).multiplyScalar(Math.max(t,Math.min(e,n)))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this.z=Math.floor(this.z),this.w=Math.floor(this.w),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this.z=Math.ceil(this.z),this.w=Math.ceil(this.w),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this.z=Math.round(this.z),this.w=Math.round(this.w),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this.z=Math.trunc(this.z),this.w=Math.trunc(this.w),this}negate(){return this.x=-this.x,this.y=-this.y,this.z=-this.z,this.w=-this.w,this}dot(t){return this.x*t.x+this.y*t.y+this.z*t.z+this.w*t.w}lengthSq(){return this.x*this.x+this.y*this.y+this.z*this.z+this.w*this.w}length(){return Math.sqrt(this.x*this.x+this.y*this.y+this.z*this.z+this.w*this.w)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)+Math.abs(this.z)+Math.abs(this.w)}normalize(){return this.divideScalar(this.length()||1)}setLength(t){return this.normalize().multiplyScalar(t)}lerp(t,e){return this.x+=(t.x-this.x)*e,this.y+=(t.y-this.y)*e,this.z+=(t.z-this.z)*e,this.w+=(t.w-this.w)*e,this}lerpVectors(t,e,n){return this.x=t.x+(e.x-t.x)*n,this.y=t.y+(e.y-t.y)*n,this.z=t.z+(e.z-t.z)*n,this.w=t.w+(e.w-t.w)*n,this}equals(t){return t.x===this.x&&t.y===this.y&&t.z===this.z&&t.w===this.w}fromArray(t,e=0){return this.x=t[e],this.y=t[e+1],this.z=t[e+2],this.w=t[e+3],this}toArray(t=[],e=0){return t[e]=this.x,t[e+1]=this.y,t[e+2]=this.z,t[e+3]=this.w,t}fromBufferAttribute(t,e){return this.x=t.getX(e),this.y=t.getY(e),this.z=t.getZ(e),this.w=t.getW(e),this}random(){return this.x=Math.random(),this.y=Math.random(),this.z=Math.random(),this.w=Math.random(),this}*[Symbol.iterator](){yield this.x,yield this.y,yield this.z,yield this.w}}class Pu extends Vn{constructor(t=1,e=1,n={}){super(),this.isRenderTarget=!0,this.width=t,this.height=e,this.depth=1,this.scissor=new oe(0,0,t,e),this.scissorTest=!1,this.viewport=new oe(0,0,t,e);const r={width:t,height:e,depth:1};n.encoding!==void 0&&(Vi("THREE.WebGLRenderTarget: option.encoding has been replaced by option.colorSpace."),n.colorSpace=n.encoding===kn?he:Xe),n=Object.assign({generateMipmaps:!1,internalFormat:null,minFilter:He,depthBuffer:!0,stencilBuffer:!1,depthTexture:null,samples:0},n),this.texture=new Te(r,n.mapping,n.wrapS,n.wrapT,n.magFilter,n.minFilter,n.format,n.type,n.anisotropy,n.colorSpace),this.texture.isRenderTargetTexture=!0,this.texture.flipY=!1,this.texture.generateMipmaps=n.generateMipmaps,this.texture.internalFormat=n.internalFormat,this.depthBuffer=n.depthBuffer,this.stencilBuffer=n.stencilBuffer,this.depthTexture=n.depthTexture,this.samples=n.samples}setSize(t,e,n=1){(this.width!==t||this.height!==e||this.depth!==n)&&(this.width=t,this.height=e,this.depth=n,this.texture.image.width=t,this.texture.image.height=e,this.texture.image.depth=n,this.dispose()),this.viewport.set(0,0,t,e),this.scissor.set(0,0,t,e)}clone(){return new this.constructor().copy(this)}copy(t){this.width=t.width,this.height=t.height,this.depth=t.depth,this.scissor.copy(t.scissor),this.scissorTest=t.scissorTest,this.viewport.copy(t.viewport),this.texture=t.texture.clone(),this.texture.isRenderTargetTexture=!0;const e=Object.assign({},t.texture.image);return this.texture.source=new Uc(e),this.depthBuffer=t.depthBuffer,this.stencilBuffer=t.stencilBuffer,t.depthTexture!==null&&(this.depthTexture=t.depthTexture.clone()),this.samples=t.samples,this}dispose(){this.dispatchEvent({type:"dispose"})}}class Ke extends Pu{constructor(t=1,e=1,n={}){super(t,e,n),this.isWebGLRenderTarget=!0}}class Nc extends Te{constructor(t=null,e=1,n=1,r=1){super(null),this.isDataArrayTexture=!0,this.image={data:t,width:e,height:n,depth:r},this.magFilter=Le,this.minFilter=Le,this.wrapR=Ve,this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1}}class Lu extends Te{constructor(t=null,e=1,n=1,r=1){super(null),this.isData3DTexture=!0,this.image={data:t,width:e,height:n,depth:r},this.magFilter=Le,this.minFilter=Le,this.wrapR=Ve,this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1}}class An{constructor(t=0,e=0,n=0,r=1){this.isQuaternion=!0,this._x=t,this._y=e,this._z=n,this._w=r}static slerpFlat(t,e,n,r,s,o,a){let c=n[r+0],l=n[r+1],h=n[r+2],f=n[r+3];const m=s[o+0],p=s[o+1],_=s[o+2],x=s[o+3];if(a===0){t[e+0]=c,t[e+1]=l,t[e+2]=h,t[e+3]=f;return}if(a===1){t[e+0]=m,t[e+1]=p,t[e+2]=_,t[e+3]=x;return}if(f!==x||c!==m||l!==p||h!==_){let d=1-a;const u=c*m+l*p+h*_+f*x,M=u>=0?1:-1,g=1-u*u;if(g>Number.EPSILON){const L=Math.sqrt(g),C=Math.atan2(L,u*M);d=Math.sin(d*C)/L,a=Math.sin(a*C)/L}const y=a*M;if(c=c*d+m*y,l=l*d+p*y,h=h*d+_*y,f=f*d+x*y,d===1-a){const L=1/Math.sqrt(c*c+l*l+h*h+f*f);c*=L,l*=L,h*=L,f*=L}}t[e]=c,t[e+1]=l,t[e+2]=h,t[e+3]=f}static multiplyQuaternionsFlat(t,e,n,r,s,o){const a=n[r],c=n[r+1],l=n[r+2],h=n[r+3],f=s[o],m=s[o+1],p=s[o+2],_=s[o+3];return t[e]=a*_+h*f+c*p-l*m,t[e+1]=c*_+h*m+l*f-a*p,t[e+2]=l*_+h*p+a*m-c*f,t[e+3]=h*_-a*f-c*m-l*p,t}get x(){return this._x}set x(t){this._x=t,this._onChangeCallback()}get y(){return this._y}set y(t){this._y=t,this._onChangeCallback()}get z(){return this._z}set z(t){this._z=t,this._onChangeCallback()}get w(){return this._w}set w(t){this._w=t,this._onChangeCallback()}set(t,e,n,r){return this._x=t,this._y=e,this._z=n,this._w=r,this._onChangeCallback(),this}clone(){return new this.constructor(this._x,this._y,this._z,this._w)}copy(t){return this._x=t.x,this._y=t.y,this._z=t.z,this._w=t.w,this._onChangeCallback(),this}setFromEuler(t,e=!0){const n=t._x,r=t._y,s=t._z,o=t._order,a=Math.cos,c=Math.sin,l=a(n/2),h=a(r/2),f=a(s/2),m=c(n/2),p=c(r/2),_=c(s/2);switch(o){case"XYZ":this._x=m*h*f+l*p*_,this._y=l*p*f-m*h*_,this._z=l*h*_+m*p*f,this._w=l*h*f-m*p*_;break;case"YXZ":this._x=m*h*f+l*p*_,this._y=l*p*f-m*h*_,this._z=l*h*_-m*p*f,this._w=l*h*f+m*p*_;break;case"ZXY":this._x=m*h*f-l*p*_,this._y=l*p*f+m*h*_,this._z=l*h*_+m*p*f,this._w=l*h*f-m*p*_;break;case"ZYX":this._x=m*h*f-l*p*_,this._y=l*p*f+m*h*_,this._z=l*h*_-m*p*f,this._w=l*h*f+m*p*_;break;case"YZX":this._x=m*h*f+l*p*_,this._y=l*p*f+m*h*_,this._z=l*h*_-m*p*f,this._w=l*h*f-m*p*_;break;case"XZY":this._x=m*h*f-l*p*_,this._y=l*p*f-m*h*_,this._z=l*h*_+m*p*f,this._w=l*h*f+m*p*_;break;default:console.warn("THREE.Quaternion: .setFromEuler() encountered an unknown order: "+o)}return e===!0&&this._onChangeCallback(),this}setFromAxisAngle(t,e){const n=e/2,r=Math.sin(n);return this._x=t.x*r,this._y=t.y*r,this._z=t.z*r,this._w=Math.cos(n),this._onChangeCallback(),this}setFromRotationMatrix(t){const e=t.elements,n=e[0],r=e[4],s=e[8],o=e[1],a=e[5],c=e[9],l=e[2],h=e[6],f=e[10],m=n+a+f;if(m>0){const p=.5/Math.sqrt(m+1);this._w=.25/p,this._x=(h-c)*p,this._y=(s-l)*p,this._z=(o-r)*p}else if(n>a&&n>f){const p=2*Math.sqrt(1+n-a-f);this._w=(h-c)/p,this._x=.25*p,this._y=(r+o)/p,this._z=(s+l)/p}else if(a>f){const p=2*Math.sqrt(1+a-n-f);this._w=(s-l)/p,this._x=(r+o)/p,this._y=.25*p,this._z=(c+h)/p}else{const p=2*Math.sqrt(1+f-n-a);this._w=(o-r)/p,this._x=(s+l)/p,this._y=(c+h)/p,this._z=.25*p}return this._onChangeCallback(),this}setFromUnitVectors(t,e){let n=t.dot(e)+1;return n<Number.EPSILON?(n=0,Math.abs(t.x)>Math.abs(t.z)?(this._x=-t.y,this._y=t.x,this._z=0,this._w=n):(this._x=0,this._y=-t.z,this._z=t.y,this._w=n)):(this._x=t.y*e.z-t.z*e.y,this._y=t.z*e.x-t.x*e.z,this._z=t.x*e.y-t.y*e.x,this._w=n),this.normalize()}angleTo(t){return 2*Math.acos(Math.abs(xe(this.dot(t),-1,1)))}rotateTowards(t,e){const n=this.angleTo(t);if(n===0)return this;const r=Math.min(1,e/n);return this.slerp(t,r),this}identity(){return this.set(0,0,0,1)}invert(){return this.conjugate()}conjugate(){return this._x*=-1,this._y*=-1,this._z*=-1,this._onChangeCallback(),this}dot(t){return this._x*t._x+this._y*t._y+this._z*t._z+this._w*t._w}lengthSq(){return this._x*this._x+this._y*this._y+this._z*this._z+this._w*this._w}length(){return Math.sqrt(this._x*this._x+this._y*this._y+this._z*this._z+this._w*this._w)}normalize(){let t=this.length();return t===0?(this._x=0,this._y=0,this._z=0,this._w=1):(t=1/t,this._x=this._x*t,this._y=this._y*t,this._z=this._z*t,this._w=this._w*t),this._onChangeCallback(),this}multiply(t){return this.multiplyQuaternions(this,t)}premultiply(t){return this.multiplyQuaternions(t,this)}multiplyQuaternions(t,e){const n=t._x,r=t._y,s=t._z,o=t._w,a=e._x,c=e._y,l=e._z,h=e._w;return this._x=n*h+o*a+r*l-s*c,this._y=r*h+o*c+s*a-n*l,this._z=s*h+o*l+n*c-r*a,this._w=o*h-n*a-r*c-s*l,this._onChangeCallback(),this}slerp(t,e){if(e===0)return this;if(e===1)return this.copy(t);const n=this._x,r=this._y,s=this._z,o=this._w;let a=o*t._w+n*t._x+r*t._y+s*t._z;if(a<0?(this._w=-t._w,this._x=-t._x,this._y=-t._y,this._z=-t._z,a=-a):this.copy(t),a>=1)return this._w=o,this._x=n,this._y=r,this._z=s,this;const c=1-a*a;if(c<=Number.EPSILON){const p=1-e;return this._w=p*o+e*this._w,this._x=p*n+e*this._x,this._y=p*r+e*this._y,this._z=p*s+e*this._z,this.normalize(),this}const l=Math.sqrt(c),h=Math.atan2(l,a),f=Math.sin((1-e)*h)/l,m=Math.sin(e*h)/l;return this._w=o*f+this._w*m,this._x=n*f+this._x*m,this._y=r*f+this._y*m,this._z=s*f+this._z*m,this._onChangeCallback(),this}slerpQuaternions(t,e,n){return this.copy(t).slerp(e,n)}random(){const t=Math.random(),e=Math.sqrt(1-t),n=Math.sqrt(t),r=2*Math.PI*Math.random(),s=2*Math.PI*Math.random();return this.set(e*Math.cos(r),n*Math.sin(s),n*Math.cos(s),e*Math.sin(r))}equals(t){return t._x===this._x&&t._y===this._y&&t._z===this._z&&t._w===this._w}fromArray(t,e=0){return this._x=t[e],this._y=t[e+1],this._z=t[e+2],this._w=t[e+3],this._onChangeCallback(),this}toArray(t=[],e=0){return t[e]=this._x,t[e+1]=this._y,t[e+2]=this._z,t[e+3]=this._w,t}fromBufferAttribute(t,e){return this._x=t.getX(e),this._y=t.getY(e),this._z=t.getZ(e),this._w=t.getW(e),this._onChangeCallback(),this}toJSON(){return this.toArray()}_onChange(t){return this._onChangeCallback=t,this}_onChangeCallback(){}*[Symbol.iterator](){yield this._x,yield this._y,yield this._z,yield this._w}}class H{constructor(t=0,e=0,n=0){H.prototype.isVector3=!0,this.x=t,this.y=e,this.z=n}set(t,e,n){return n===void 0&&(n=this.z),this.x=t,this.y=e,this.z=n,this}setScalar(t){return this.x=t,this.y=t,this.z=t,this}setX(t){return this.x=t,this}setY(t){return this.y=t,this}setZ(t){return this.z=t,this}setComponent(t,e){switch(t){case 0:this.x=e;break;case 1:this.y=e;break;case 2:this.z=e;break;default:throw new Error("index is out of range: "+t)}return this}getComponent(t){switch(t){case 0:return this.x;case 1:return this.y;case 2:return this.z;default:throw new Error("index is out of range: "+t)}}clone(){return new this.constructor(this.x,this.y,this.z)}copy(t){return this.x=t.x,this.y=t.y,this.z=t.z,this}add(t){return this.x+=t.x,this.y+=t.y,this.z+=t.z,this}addScalar(t){return this.x+=t,this.y+=t,this.z+=t,this}addVectors(t,e){return this.x=t.x+e.x,this.y=t.y+e.y,this.z=t.z+e.z,this}addScaledVector(t,e){return this.x+=t.x*e,this.y+=t.y*e,this.z+=t.z*e,this}sub(t){return this.x-=t.x,this.y-=t.y,this.z-=t.z,this}subScalar(t){return this.x-=t,this.y-=t,this.z-=t,this}subVectors(t,e){return this.x=t.x-e.x,this.y=t.y-e.y,this.z=t.z-e.z,this}multiply(t){return this.x*=t.x,this.y*=t.y,this.z*=t.z,this}multiplyScalar(t){return this.x*=t,this.y*=t,this.z*=t,this}multiplyVectors(t,e){return this.x=t.x*e.x,this.y=t.y*e.y,this.z=t.z*e.z,this}applyEuler(t){return this.applyQuaternion(aa.setFromEuler(t))}applyAxisAngle(t,e){return this.applyQuaternion(aa.setFromAxisAngle(t,e))}applyMatrix3(t){const e=this.x,n=this.y,r=this.z,s=t.elements;return this.x=s[0]*e+s[3]*n+s[6]*r,this.y=s[1]*e+s[4]*n+s[7]*r,this.z=s[2]*e+s[5]*n+s[8]*r,this}applyNormalMatrix(t){return this.applyMatrix3(t).normalize()}applyMatrix4(t){const e=this.x,n=this.y,r=this.z,s=t.elements,o=1/(s[3]*e+s[7]*n+s[11]*r+s[15]);return this.x=(s[0]*e+s[4]*n+s[8]*r+s[12])*o,this.y=(s[1]*e+s[5]*n+s[9]*r+s[13])*o,this.z=(s[2]*e+s[6]*n+s[10]*r+s[14])*o,this}applyQuaternion(t){const e=this.x,n=this.y,r=this.z,s=t.x,o=t.y,a=t.z,c=t.w,l=2*(o*r-a*n),h=2*(a*e-s*r),f=2*(s*n-o*e);return this.x=e+c*l+o*f-a*h,this.y=n+c*h+a*l-s*f,this.z=r+c*f+s*h-o*l,this}project(t){return this.applyMatrix4(t.matrixWorldInverse).applyMatrix4(t.projectionMatrix)}unproject(t){return this.applyMatrix4(t.projectionMatrixInverse).applyMatrix4(t.matrixWorld)}transformDirection(t){const e=this.x,n=this.y,r=this.z,s=t.elements;return this.x=s[0]*e+s[4]*n+s[8]*r,this.y=s[1]*e+s[5]*n+s[9]*r,this.z=s[2]*e+s[6]*n+s[10]*r,this.normalize()}divide(t){return this.x/=t.x,this.y/=t.y,this.z/=t.z,this}divideScalar(t){return this.multiplyScalar(1/t)}min(t){return this.x=Math.min(this.x,t.x),this.y=Math.min(this.y,t.y),this.z=Math.min(this.z,t.z),this}max(t){return this.x=Math.max(this.x,t.x),this.y=Math.max(this.y,t.y),this.z=Math.max(this.z,t.z),this}clamp(t,e){return this.x=Math.max(t.x,Math.min(e.x,this.x)),this.y=Math.max(t.y,Math.min(e.y,this.y)),this.z=Math.max(t.z,Math.min(e.z,this.z)),this}clampScalar(t,e){return this.x=Math.max(t,Math.min(e,this.x)),this.y=Math.max(t,Math.min(e,this.y)),this.z=Math.max(t,Math.min(e,this.z)),this}clampLength(t,e){const n=this.length();return this.divideScalar(n||1).multiplyScalar(Math.max(t,Math.min(e,n)))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this.z=Math.floor(this.z),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this.z=Math.ceil(this.z),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this.z=Math.round(this.z),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this.z=Math.trunc(this.z),this}negate(){return this.x=-this.x,this.y=-this.y,this.z=-this.z,this}dot(t){return this.x*t.x+this.y*t.y+this.z*t.z}lengthSq(){return this.x*this.x+this.y*this.y+this.z*this.z}length(){return Math.sqrt(this.x*this.x+this.y*this.y+this.z*this.z)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)+Math.abs(this.z)}normalize(){return this.divideScalar(this.length()||1)}setLength(t){return this.normalize().multiplyScalar(t)}lerp(t,e){return this.x+=(t.x-this.x)*e,this.y+=(t.y-this.y)*e,this.z+=(t.z-this.z)*e,this}lerpVectors(t,e,n){return this.x=t.x+(e.x-t.x)*n,this.y=t.y+(e.y-t.y)*n,this.z=t.z+(e.z-t.z)*n,this}cross(t){return this.crossVectors(this,t)}crossVectors(t,e){const n=t.x,r=t.y,s=t.z,o=e.x,a=e.y,c=e.z;return this.x=r*c-s*a,this.y=s*o-n*c,this.z=n*a-r*o,this}projectOnVector(t){const e=t.lengthSq();if(e===0)return this.set(0,0,0);const n=t.dot(this)/e;return this.copy(t).multiplyScalar(n)}projectOnPlane(t){return ls.copy(this).projectOnVector(t),this.sub(ls)}reflect(t){return this.sub(ls.copy(t).multiplyScalar(2*this.dot(t)))}angleTo(t){const e=Math.sqrt(this.lengthSq()*t.lengthSq());if(e===0)return Math.PI/2;const n=this.dot(t)/e;return Math.acos(xe(n,-1,1))}distanceTo(t){return Math.sqrt(this.distanceToSquared(t))}distanceToSquared(t){const e=this.x-t.x,n=this.y-t.y,r=this.z-t.z;return e*e+n*n+r*r}manhattanDistanceTo(t){return Math.abs(this.x-t.x)+Math.abs(this.y-t.y)+Math.abs(this.z-t.z)}setFromSpherical(t){return this.setFromSphericalCoords(t.radius,t.phi,t.theta)}setFromSphericalCoords(t,e,n){const r=Math.sin(e)*t;return this.x=r*Math.sin(n),this.y=Math.cos(e)*t,this.z=r*Math.cos(n),this}setFromCylindrical(t){return this.setFromCylindricalCoords(t.radius,t.theta,t.y)}setFromCylindricalCoords(t,e,n){return this.x=t*Math.sin(e),this.y=n,this.z=t*Math.cos(e),this}setFromMatrixPosition(t){const e=t.elements;return this.x=e[12],this.y=e[13],this.z=e[14],this}setFromMatrixScale(t){const e=this.setFromMatrixColumn(t,0).length(),n=this.setFromMatrixColumn(t,1).length(),r=this.setFromMatrixColumn(t,2).length();return this.x=e,this.y=n,this.z=r,this}setFromMatrixColumn(t,e){return this.fromArray(t.elements,e*4)}setFromMatrix3Column(t,e){return this.fromArray(t.elements,e*3)}setFromEuler(t){return this.x=t._x,this.y=t._y,this.z=t._z,this}setFromColor(t){return this.x=t.r,this.y=t.g,this.z=t.b,this}equals(t){return t.x===this.x&&t.y===this.y&&t.z===this.z}fromArray(t,e=0){return this.x=t[e],this.y=t[e+1],this.z=t[e+2],this}toArray(t=[],e=0){return t[e]=this.x,t[e+1]=this.y,t[e+2]=this.z,t}fromBufferAttribute(t,e){return this.x=t.getX(e),this.y=t.getY(e),this.z=t.getZ(e),this}random(){return this.x=Math.random(),this.y=Math.random(),this.z=Math.random(),this}randomDirection(){const t=(Math.random()-.5)*2,e=Math.random()*Math.PI*2,n=Math.sqrt(1-t**2);return this.x=n*Math.cos(e),this.y=n*Math.sin(e),this.z=t,this}*[Symbol.iterator](){yield this.x,yield this.y,yield this.z}}const ls=new H,aa=new An;class Xn{constructor(t=new H(1/0,1/0,1/0),e=new H(-1/0,-1/0,-1/0)){this.isBox3=!0,this.min=t,this.max=e}set(t,e){return this.min.copy(t),this.max.copy(e),this}setFromArray(t){this.makeEmpty();for(let e=0,n=t.length;e<n;e+=3)this.expandByPoint(We.fromArray(t,e));return this}setFromBufferAttribute(t){this.makeEmpty();for(let e=0,n=t.count;e<n;e++)this.expandByPoint(We.fromBufferAttribute(t,e));return this}setFromPoints(t){this.makeEmpty();for(let e=0,n=t.length;e<n;e++)this.expandByPoint(t[e]);return this}setFromCenterAndSize(t,e){const n=We.copy(e).multiplyScalar(.5);return this.min.copy(t).sub(n),this.max.copy(t).add(n),this}setFromObject(t,e=!1){return this.makeEmpty(),this.expandByObject(t,e)}clone(){return new this.constructor().copy(this)}copy(t){return this.min.copy(t.min),this.max.copy(t.max),this}makeEmpty(){return this.min.x=this.min.y=this.min.z=1/0,this.max.x=this.max.y=this.max.z=-1/0,this}isEmpty(){return this.max.x<this.min.x||this.max.y<this.min.y||this.max.z<this.min.z}getCenter(t){return this.isEmpty()?t.set(0,0,0):t.addVectors(this.min,this.max).multiplyScalar(.5)}getSize(t){return this.isEmpty()?t.set(0,0,0):t.subVectors(this.max,this.min)}expandByPoint(t){return this.min.min(t),this.max.max(t),this}expandByVector(t){return this.min.sub(t),this.max.add(t),this}expandByScalar(t){return this.min.addScalar(-t),this.max.addScalar(t),this}expandByObject(t,e=!1){t.updateWorldMatrix(!1,!1);const n=t.geometry;if(n!==void 0){const s=n.getAttribute("position");if(e===!0&&s!==void 0&&t.isInstancedMesh!==!0)for(let o=0,a=s.count;o<a;o++)t.isMesh===!0?t.getVertexPosition(o,We):We.fromBufferAttribute(s,o),We.applyMatrix4(t.matrixWorld),this.expandByPoint(We);else t.boundingBox!==void 0?(t.boundingBox===null&&t.computeBoundingBox(),er.copy(t.boundingBox)):(n.boundingBox===null&&n.computeBoundingBox(),er.copy(n.boundingBox)),er.applyMatrix4(t.matrixWorld),this.union(er)}const r=t.children;for(let s=0,o=r.length;s<o;s++)this.expandByObject(r[s],e);return this}containsPoint(t){return!(t.x<this.min.x||t.x>this.max.x||t.y<this.min.y||t.y>this.max.y||t.z<this.min.z||t.z>this.max.z)}containsBox(t){return this.min.x<=t.min.x&&t.max.x<=this.max.x&&this.min.y<=t.min.y&&t.max.y<=this.max.y&&this.min.z<=t.min.z&&t.max.z<=this.max.z}getParameter(t,e){return e.set((t.x-this.min.x)/(this.max.x-this.min.x),(t.y-this.min.y)/(this.max.y-this.min.y),(t.z-this.min.z)/(this.max.z-this.min.z))}intersectsBox(t){return!(t.max.x<this.min.x||t.min.x>this.max.x||t.max.y<this.min.y||t.min.y>this.max.y||t.max.z<this.min.z||t.min.z>this.max.z)}intersectsSphere(t){return this.clampPoint(t.center,We),We.distanceToSquared(t.center)<=t.radius*t.radius}intersectsPlane(t){let e,n;return t.normal.x>0?(e=t.normal.x*this.min.x,n=t.normal.x*this.max.x):(e=t.normal.x*this.max.x,n=t.normal.x*this.min.x),t.normal.y>0?(e+=t.normal.y*this.min.y,n+=t.normal.y*this.max.y):(e+=t.normal.y*this.max.y,n+=t.normal.y*this.min.y),t.normal.z>0?(e+=t.normal.z*this.min.z,n+=t.normal.z*this.max.z):(e+=t.normal.z*this.max.z,n+=t.normal.z*this.min.z),e<=-t.constant&&n>=-t.constant}intersectsTriangle(t){if(this.isEmpty())return!1;this.getCenter(Li),nr.subVectors(this.max,Li),Zn.subVectors(t.a,Li),Jn.subVectors(t.b,Li),Qn.subVectors(t.c,Li),_n.subVectors(Jn,Zn),vn.subVectors(Qn,Jn),Ln.subVectors(Zn,Qn);let e=[0,-_n.z,_n.y,0,-vn.z,vn.y,0,-Ln.z,Ln.y,_n.z,0,-_n.x,vn.z,0,-vn.x,Ln.z,0,-Ln.x,-_n.y,_n.x,0,-vn.y,vn.x,0,-Ln.y,Ln.x,0];return!us(e,Zn,Jn,Qn,nr)||(e=[1,0,0,0,1,0,0,0,1],!us(e,Zn,Jn,Qn,nr))?!1:(ir.crossVectors(_n,vn),e=[ir.x,ir.y,ir.z],us(e,Zn,Jn,Qn,nr))}clampPoint(t,e){return e.copy(t).clamp(this.min,this.max)}distanceToPoint(t){return this.clampPoint(t,We).distanceTo(t)}getBoundingSphere(t){return this.isEmpty()?t.makeEmpty():(this.getCenter(t.center),t.radius=this.getSize(We).length()*.5),t}intersect(t){return this.min.max(t.min),this.max.min(t.max),this.isEmpty()&&this.makeEmpty(),this}union(t){return this.min.min(t.min),this.max.max(t.max),this}applyMatrix4(t){return this.isEmpty()?this:(rn[0].set(this.min.x,this.min.y,this.min.z).applyMatrix4(t),rn[1].set(this.min.x,this.min.y,this.max.z).applyMatrix4(t),rn[2].set(this.min.x,this.max.y,this.min.z).applyMatrix4(t),rn[3].set(this.min.x,this.max.y,this.max.z).applyMatrix4(t),rn[4].set(this.max.x,this.min.y,this.min.z).applyMatrix4(t),rn[5].set(this.max.x,this.min.y,this.max.z).applyMatrix4(t),rn[6].set(this.max.x,this.max.y,this.min.z).applyMatrix4(t),rn[7].set(this.max.x,this.max.y,this.max.z).applyMatrix4(t),this.setFromPoints(rn),this)}translate(t){return this.min.add(t),this.max.add(t),this}equals(t){return t.min.equals(this.min)&&t.max.equals(this.max)}}const rn=[new H,new H,new H,new H,new H,new H,new H,new H],We=new H,er=new Xn,Zn=new H,Jn=new H,Qn=new H,_n=new H,vn=new H,Ln=new H,Li=new H,nr=new H,ir=new H,Dn=new H;function us(i,t,e,n,r){for(let s=0,o=i.length-3;s<=o;s+=3){Dn.fromArray(i,s);const a=r.x*Math.abs(Dn.x)+r.y*Math.abs(Dn.y)+r.z*Math.abs(Dn.z),c=t.dot(Dn),l=e.dot(Dn),h=n.dot(Dn);if(Math.max(-Math.max(c,l,h),Math.min(c,l,h))>a)return!1}return!0}const Du=new Xn,Di=new H,hs=new H;class Wn{constructor(t=new H,e=-1){this.isSphere=!0,this.center=t,this.radius=e}set(t,e){return this.center.copy(t),this.radius=e,this}setFromPoints(t,e){const n=this.center;e!==void 0?n.copy(e):Du.setFromPoints(t).getCenter(n);let r=0;for(let s=0,o=t.length;s<o;s++)r=Math.max(r,n.distanceToSquared(t[s]));return this.radius=Math.sqrt(r),this}copy(t){return this.center.copy(t.center),this.radius=t.radius,this}isEmpty(){return this.radius<0}makeEmpty(){return this.center.set(0,0,0),this.radius=-1,this}containsPoint(t){return t.distanceToSquared(this.center)<=this.radius*this.radius}distanceToPoint(t){return t.distanceTo(this.center)-this.radius}intersectsSphere(t){const e=this.radius+t.radius;return t.center.distanceToSquared(this.center)<=e*e}intersectsBox(t){return t.intersectsSphere(this)}intersectsPlane(t){return Math.abs(t.distanceToPoint(this.center))<=this.radius}clampPoint(t,e){const n=this.center.distanceToSquared(t);return e.copy(t),n>this.radius*this.radius&&(e.sub(this.center).normalize(),e.multiplyScalar(this.radius).add(this.center)),e}getBoundingBox(t){return this.isEmpty()?(t.makeEmpty(),t):(t.set(this.center,this.center),t.expandByScalar(this.radius),t)}applyMatrix4(t){return this.center.applyMatrix4(t),this.radius=this.radius*t.getMaxScaleOnAxis(),this}translate(t){return this.center.add(t),this}expandByPoint(t){if(this.isEmpty())return this.center.copy(t),this.radius=0,this;Di.subVectors(t,this.center);const e=Di.lengthSq();if(e>this.radius*this.radius){const n=Math.sqrt(e),r=(n-this.radius)*.5;this.center.addScaledVector(Di,r/n),this.radius+=r}return this}union(t){return t.isEmpty()?this:this.isEmpty()?(this.copy(t),this):(this.center.equals(t.center)===!0?this.radius=Math.max(this.radius,t.radius):(hs.subVectors(t.center,this.center).setLength(t.radius),this.expandByPoint(Di.copy(t.center).add(hs)),this.expandByPoint(Di.copy(t.center).sub(hs))),this)}equals(t){return t.center.equals(this.center)&&t.radius===this.radius}clone(){return new this.constructor().copy(this)}}const sn=new H,ds=new H,rr=new H,xn=new H,fs=new H,sr=new H,ps=new H;class Hn{constructor(t=new H,e=new H(0,0,-1)){this.origin=t,this.direction=e}set(t,e){return this.origin.copy(t),this.direction.copy(e),this}copy(t){return this.origin.copy(t.origin),this.direction.copy(t.direction),this}at(t,e){return e.copy(this.origin).addScaledVector(this.direction,t)}lookAt(t){return this.direction.copy(t).sub(this.origin).normalize(),this}recast(t){return this.origin.copy(this.at(t,sn)),this}closestPointToPoint(t,e){e.subVectors(t,this.origin);const n=e.dot(this.direction);return n<0?e.copy(this.origin):e.copy(this.origin).addScaledVector(this.direction,n)}distanceToPoint(t){return Math.sqrt(this.distanceSqToPoint(t))}distanceSqToPoint(t){const e=sn.subVectors(t,this.origin).dot(this.direction);return e<0?this.origin.distanceToSquared(t):(sn.copy(this.origin).addScaledVector(this.direction,e),sn.distanceToSquared(t))}distanceSqToSegment(t,e,n,r){ds.copy(t).add(e).multiplyScalar(.5),rr.copy(e).sub(t).normalize(),xn.copy(this.origin).sub(ds);const s=t.distanceTo(e)*.5,o=-this.direction.dot(rr),a=xn.dot(this.direction),c=-xn.dot(rr),l=xn.lengthSq(),h=Math.abs(1-o*o);let f,m,p,_;if(h>0)if(f=o*c-a,m=o*a-c,_=s*h,f>=0)if(m>=-_)if(m<=_){const x=1/h;f*=x,m*=x,p=f*(f+o*m+2*a)+m*(o*f+m+2*c)+l}else m=s,f=Math.max(0,-(o*m+a)),p=-f*f+m*(m+2*c)+l;else m=-s,f=Math.max(0,-(o*m+a)),p=-f*f+m*(m+2*c)+l;else m<=-_?(f=Math.max(0,-(-o*s+a)),m=f>0?-s:Math.min(Math.max(-s,-c),s),p=-f*f+m*(m+2*c)+l):m<=_?(f=0,m=Math.min(Math.max(-s,-c),s),p=m*(m+2*c)+l):(f=Math.max(0,-(o*s+a)),m=f>0?s:Math.min(Math.max(-s,-c),s),p=-f*f+m*(m+2*c)+l);else m=o>0?-s:s,f=Math.max(0,-(o*m+a)),p=-f*f+m*(m+2*c)+l;return n&&n.copy(this.origin).addScaledVector(this.direction,f),r&&r.copy(ds).addScaledVector(rr,m),p}intersectSphere(t,e){sn.subVectors(t.center,this.origin);const n=sn.dot(this.direction),r=sn.dot(sn)-n*n,s=t.radius*t.radius;if(r>s)return null;const o=Math.sqrt(s-r),a=n-o,c=n+o;return c<0?null:a<0?this.at(c,e):this.at(a,e)}intersectsSphere(t){return this.distanceSqToPoint(t.center)<=t.radius*t.radius}distanceToPlane(t){const e=t.normal.dot(this.direction);if(e===0)return t.distanceToPoint(this.origin)===0?0:null;const n=-(this.origin.dot(t.normal)+t.constant)/e;return n>=0?n:null}intersectPlane(t,e){const n=this.distanceToPlane(t);return n===null?null:this.at(n,e)}intersectsPlane(t){const e=t.distanceToPoint(this.origin);return e===0||t.normal.dot(this.direction)*e<0}intersectBox(t,e){let n,r,s,o,a,c;const l=1/this.direction.x,h=1/this.direction.y,f=1/this.direction.z,m=this.origin;return l>=0?(n=(t.min.x-m.x)*l,r=(t.max.x-m.x)*l):(n=(t.max.x-m.x)*l,r=(t.min.x-m.x)*l),h>=0?(s=(t.min.y-m.y)*h,o=(t.max.y-m.y)*h):(s=(t.max.y-m.y)*h,o=(t.min.y-m.y)*h),n>o||s>r||((s>n||isNaN(n))&&(n=s),(o<r||isNaN(r))&&(r=o),f>=0?(a=(t.min.z-m.z)*f,c=(t.max.z-m.z)*f):(a=(t.max.z-m.z)*f,c=(t.min.z-m.z)*f),n>c||a>r)||((a>n||n!==n)&&(n=a),(c<r||r!==r)&&(r=c),r<0)?null:this.at(n>=0?n:r,e)}intersectsBox(t){return this.intersectBox(t,sn)!==null}intersectTriangle(t,e,n,r,s){fs.subVectors(e,t),sr.subVectors(n,t),ps.crossVectors(fs,sr);let o=this.direction.dot(ps),a;if(o>0){if(r)return null;a=1}else if(o<0)a=-1,o=-o;else return null;xn.subVectors(this.origin,t);const c=a*this.direction.dot(sr.crossVectors(xn,sr));if(c<0)return null;const l=a*this.direction.dot(fs.cross(xn));if(l<0||c+l>o)return null;const h=-a*xn.dot(ps);return h<0?null:this.at(h/o,s)}applyMatrix4(t){return this.origin.applyMatrix4(t),this.direction.transformDirection(t),this}equals(t){return t.origin.equals(this.origin)&&t.direction.equals(this.direction)}clone(){return new this.constructor().copy(this)}}class ee{constructor(t,e,n,r,s,o,a,c,l,h,f,m,p,_,x,d){ee.prototype.isMatrix4=!0,this.elements=[1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1],t!==void 0&&this.set(t,e,n,r,s,o,a,c,l,h,f,m,p,_,x,d)}set(t,e,n,r,s,o,a,c,l,h,f,m,p,_,x,d){const u=this.elements;return u[0]=t,u[4]=e,u[8]=n,u[12]=r,u[1]=s,u[5]=o,u[9]=a,u[13]=c,u[2]=l,u[6]=h,u[10]=f,u[14]=m,u[3]=p,u[7]=_,u[11]=x,u[15]=d,this}identity(){return this.set(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1),this}clone(){return new ee().fromArray(this.elements)}copy(t){const e=this.elements,n=t.elements;return e[0]=n[0],e[1]=n[1],e[2]=n[2],e[3]=n[3],e[4]=n[4],e[5]=n[5],e[6]=n[6],e[7]=n[7],e[8]=n[8],e[9]=n[9],e[10]=n[10],e[11]=n[11],e[12]=n[12],e[13]=n[13],e[14]=n[14],e[15]=n[15],this}copyPosition(t){const e=this.elements,n=t.elements;return e[12]=n[12],e[13]=n[13],e[14]=n[14],this}setFromMatrix3(t){const e=t.elements;return this.set(e[0],e[3],e[6],0,e[1],e[4],e[7],0,e[2],e[5],e[8],0,0,0,0,1),this}extractBasis(t,e,n){return t.setFromMatrixColumn(this,0),e.setFromMatrixColumn(this,1),n.setFromMatrixColumn(this,2),this}makeBasis(t,e,n){return this.set(t.x,e.x,n.x,0,t.y,e.y,n.y,0,t.z,e.z,n.z,0,0,0,0,1),this}extractRotation(t){const e=this.elements,n=t.elements,r=1/ti.setFromMatrixColumn(t,0).length(),s=1/ti.setFromMatrixColumn(t,1).length(),o=1/ti.setFromMatrixColumn(t,2).length();return e[0]=n[0]*r,e[1]=n[1]*r,e[2]=n[2]*r,e[3]=0,e[4]=n[4]*s,e[5]=n[5]*s,e[6]=n[6]*s,e[7]=0,e[8]=n[8]*o,e[9]=n[9]*o,e[10]=n[10]*o,e[11]=0,e[12]=0,e[13]=0,e[14]=0,e[15]=1,this}makeRotationFromEuler(t){const e=this.elements,n=t.x,r=t.y,s=t.z,o=Math.cos(n),a=Math.sin(n),c=Math.cos(r),l=Math.sin(r),h=Math.cos(s),f=Math.sin(s);if(t.order==="XYZ"){const m=o*h,p=o*f,_=a*h,x=a*f;e[0]=c*h,e[4]=-c*f,e[8]=l,e[1]=p+_*l,e[5]=m-x*l,e[9]=-a*c,e[2]=x-m*l,e[6]=_+p*l,e[10]=o*c}else if(t.order==="YXZ"){const m=c*h,p=c*f,_=l*h,x=l*f;e[0]=m+x*a,e[4]=_*a-p,e[8]=o*l,e[1]=o*f,e[5]=o*h,e[9]=-a,e[2]=p*a-_,e[6]=x+m*a,e[10]=o*c}else if(t.order==="ZXY"){const m=c*h,p=c*f,_=l*h,x=l*f;e[0]=m-x*a,e[4]=-o*f,e[8]=_+p*a,e[1]=p+_*a,e[5]=o*h,e[9]=x-m*a,e[2]=-o*l,e[6]=a,e[10]=o*c}else if(t.order==="ZYX"){const m=o*h,p=o*f,_=a*h,x=a*f;e[0]=c*h,e[4]=_*l-p,e[8]=m*l+x,e[1]=c*f,e[5]=x*l+m,e[9]=p*l-_,e[2]=-l,e[6]=a*c,e[10]=o*c}else if(t.order==="YZX"){const m=o*c,p=o*l,_=a*c,x=a*l;e[0]=c*h,e[4]=x-m*f,e[8]=_*f+p,e[1]=f,e[5]=o*h,e[9]=-a*h,e[2]=-l*h,e[6]=p*f+_,e[10]=m-x*f}else if(t.order==="XZY"){const m=o*c,p=o*l,_=a*c,x=a*l;e[0]=c*h,e[4]=-f,e[8]=l*h,e[1]=m*f+x,e[5]=o*h,e[9]=p*f-_,e[2]=_*f-p,e[6]=a*h,e[10]=x*f+m}return e[3]=0,e[7]=0,e[11]=0,e[12]=0,e[13]=0,e[14]=0,e[15]=1,this}makeRotationFromQuaternion(t){return this.compose(Iu,t,Uu)}lookAt(t,e,n){const r=this.elements;return Ue.subVectors(t,e),Ue.lengthSq()===0&&(Ue.z=1),Ue.normalize(),Mn.crossVectors(n,Ue),Mn.lengthSq()===0&&(Math.abs(n.z)===1?Ue.x+=1e-4:Ue.z+=1e-4,Ue.normalize(),Mn.crossVectors(n,Ue)),Mn.normalize(),or.crossVectors(Ue,Mn),r[0]=Mn.x,r[4]=or.x,r[8]=Ue.x,r[1]=Mn.y,r[5]=or.y,r[9]=Ue.y,r[2]=Mn.z,r[6]=or.z,r[10]=Ue.z,this}multiply(t){return this.multiplyMatrices(this,t)}premultiply(t){return this.multiplyMatrices(t,this)}multiplyMatrices(t,e){const n=t.elements,r=e.elements,s=this.elements,o=n[0],a=n[4],c=n[8],l=n[12],h=n[1],f=n[5],m=n[9],p=n[13],_=n[2],x=n[6],d=n[10],u=n[14],M=n[3],g=n[7],y=n[11],L=n[15],C=r[0],D=r[4],F=r[8],T=r[12],E=r[1],j=r[5],O=r[9],B=r[13],S=r[2],b=r[6],v=r[10],A=r[14],I=r[3],U=r[7],P=r[11],N=r[15];return s[0]=o*C+a*E+c*S+l*I,s[4]=o*D+a*j+c*b+l*U,s[8]=o*F+a*O+c*v+l*P,s[12]=o*T+a*B+c*A+l*N,s[1]=h*C+f*E+m*S+p*I,s[5]=h*D+f*j+m*b+p*U,s[9]=h*F+f*O+m*v+p*P,s[13]=h*T+f*B+m*A+p*N,s[2]=_*C+x*E+d*S+u*I,s[6]=_*D+x*j+d*b+u*U,s[10]=_*F+x*O+d*v+u*P,s[14]=_*T+x*B+d*A+u*N,s[3]=M*C+g*E+y*S+L*I,s[7]=M*D+g*j+y*b+L*U,s[11]=M*F+g*O+y*v+L*P,s[15]=M*T+g*B+y*A+L*N,this}multiplyScalar(t){const e=this.elements;return e[0]*=t,e[4]*=t,e[8]*=t,e[12]*=t,e[1]*=t,e[5]*=t,e[9]*=t,e[13]*=t,e[2]*=t,e[6]*=t,e[10]*=t,e[14]*=t,e[3]*=t,e[7]*=t,e[11]*=t,e[15]*=t,this}determinant(){const t=this.elements,e=t[0],n=t[4],r=t[8],s=t[12],o=t[1],a=t[5],c=t[9],l=t[13],h=t[2],f=t[6],m=t[10],p=t[14],_=t[3],x=t[7],d=t[11],u=t[15];return _*(+s*c*f-r*l*f-s*a*m+n*l*m+r*a*p-n*c*p)+x*(+e*c*p-e*l*m+s*o*m-r*o*p+r*l*h-s*c*h)+d*(+e*l*f-e*a*p-s*o*f+n*o*p+s*a*h-n*l*h)+u*(-r*a*h-e*c*f+e*a*m+r*o*f-n*o*m+n*c*h)}transpose(){const t=this.elements;let e;return e=t[1],t[1]=t[4],t[4]=e,e=t[2],t[2]=t[8],t[8]=e,e=t[6],t[6]=t[9],t[9]=e,e=t[3],t[3]=t[12],t[12]=e,e=t[7],t[7]=t[13],t[13]=e,e=t[11],t[11]=t[14],t[14]=e,this}setPosition(t,e,n){const r=this.elements;return t.isVector3?(r[12]=t.x,r[13]=t.y,r[14]=t.z):(r[12]=t,r[13]=e,r[14]=n),this}invert(){const t=this.elements,e=t[0],n=t[1],r=t[2],s=t[3],o=t[4],a=t[5],c=t[6],l=t[7],h=t[8],f=t[9],m=t[10],p=t[11],_=t[12],x=t[13],d=t[14],u=t[15],M=f*d*l-x*m*l+x*c*p-a*d*p-f*c*u+a*m*u,g=_*m*l-h*d*l-_*c*p+o*d*p+h*c*u-o*m*u,y=h*x*l-_*f*l+_*a*p-o*x*p-h*a*u+o*f*u,L=_*f*c-h*x*c-_*a*m+o*x*m+h*a*d-o*f*d,C=e*M+n*g+r*y+s*L;if(C===0)return this.set(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);const D=1/C;return t[0]=M*D,t[1]=(x*m*s-f*d*s-x*r*p+n*d*p+f*r*u-n*m*u)*D,t[2]=(a*d*s-x*c*s+x*r*l-n*d*l-a*r*u+n*c*u)*D,t[3]=(f*c*s-a*m*s-f*r*l+n*m*l+a*r*p-n*c*p)*D,t[4]=g*D,t[5]=(h*d*s-_*m*s+_*r*p-e*d*p-h*r*u+e*m*u)*D,t[6]=(_*c*s-o*d*s-_*r*l+e*d*l+o*r*u-e*c*u)*D,t[7]=(o*m*s-h*c*s+h*r*l-e*m*l-o*r*p+e*c*p)*D,t[8]=y*D,t[9]=(_*f*s-h*x*s-_*n*p+e*x*p+h*n*u-e*f*u)*D,t[10]=(o*x*s-_*a*s+_*n*l-e*x*l-o*n*u+e*a*u)*D,t[11]=(h*a*s-o*f*s-h*n*l+e*f*l+o*n*p-e*a*p)*D,t[12]=L*D,t[13]=(h*x*r-_*f*r+_*n*m-e*x*m-h*n*d+e*f*d)*D,t[14]=(_*a*r-o*x*r-_*n*c+e*x*c+o*n*d-e*a*d)*D,t[15]=(o*f*r-h*a*r+h*n*c-e*f*c-o*n*m+e*a*m)*D,this}scale(t){const e=this.elements,n=t.x,r=t.y,s=t.z;return e[0]*=n,e[4]*=r,e[8]*=s,e[1]*=n,e[5]*=r,e[9]*=s,e[2]*=n,e[6]*=r,e[10]*=s,e[3]*=n,e[7]*=r,e[11]*=s,this}getMaxScaleOnAxis(){const t=this.elements,e=t[0]*t[0]+t[1]*t[1]+t[2]*t[2],n=t[4]*t[4]+t[5]*t[5]+t[6]*t[6],r=t[8]*t[8]+t[9]*t[9]+t[10]*t[10];return Math.sqrt(Math.max(e,n,r))}makeTranslation(t,e,n){return t.isVector3?this.set(1,0,0,t.x,0,1,0,t.y,0,0,1,t.z,0,0,0,1):this.set(1,0,0,t,0,1,0,e,0,0,1,n,0,0,0,1),this}makeRotationX(t){const e=Math.cos(t),n=Math.sin(t);return this.set(1,0,0,0,0,e,-n,0,0,n,e,0,0,0,0,1),this}makeRotationY(t){const e=Math.cos(t),n=Math.sin(t);return this.set(e,0,n,0,0,1,0,0,-n,0,e,0,0,0,0,1),this}makeRotationZ(t){const e=Math.cos(t),n=Math.sin(t);return this.set(e,-n,0,0,n,e,0,0,0,0,1,0,0,0,0,1),this}makeRotationAxis(t,e){const n=Math.cos(e),r=Math.sin(e),s=1-n,o=t.x,a=t.y,c=t.z,l=s*o,h=s*a;return this.set(l*o+n,l*a-r*c,l*c+r*a,0,l*a+r*c,h*a+n,h*c-r*o,0,l*c-r*a,h*c+r*o,s*c*c+n,0,0,0,0,1),this}makeScale(t,e,n){return this.set(t,0,0,0,0,e,0,0,0,0,n,0,0,0,0,1),this}makeShear(t,e,n,r,s,o){return this.set(1,n,s,0,t,1,o,0,e,r,1,0,0,0,0,1),this}compose(t,e,n){const r=this.elements,s=e._x,o=e._y,a=e._z,c=e._w,l=s+s,h=o+o,f=a+a,m=s*l,p=s*h,_=s*f,x=o*h,d=o*f,u=a*f,M=c*l,g=c*h,y=c*f,L=n.x,C=n.y,D=n.z;return r[0]=(1-(x+u))*L,r[1]=(p+y)*L,r[2]=(_-g)*L,r[3]=0,r[4]=(p-y)*C,r[5]=(1-(m+u))*C,r[6]=(d+M)*C,r[7]=0,r[8]=(_+g)*D,r[9]=(d-M)*D,r[10]=(1-(m+x))*D,r[11]=0,r[12]=t.x,r[13]=t.y,r[14]=t.z,r[15]=1,this}decompose(t,e,n){const r=this.elements;let s=ti.set(r[0],r[1],r[2]).length();const o=ti.set(r[4],r[5],r[6]).length(),a=ti.set(r[8],r[9],r[10]).length();this.determinant()<0&&(s=-s),t.x=r[12],t.y=r[13],t.z=r[14],qe.copy(this);const l=1/s,h=1/o,f=1/a;return qe.elements[0]*=l,qe.elements[1]*=l,qe.elements[2]*=l,qe.elements[4]*=h,qe.elements[5]*=h,qe.elements[6]*=h,qe.elements[8]*=f,qe.elements[9]*=f,qe.elements[10]*=f,e.setFromRotationMatrix(qe),n.x=s,n.y=o,n.z=a,this}makePerspective(t,e,n,r,s,o,a=un){const c=this.elements,l=2*s/(e-t),h=2*s/(n-r),f=(e+t)/(e-t),m=(n+r)/(n-r);let p,_;if(a===un)p=-(o+s)/(o-s),_=-2*o*s/(o-s);else if(a===zr)p=-o/(o-s),_=-o*s/(o-s);else throw new Error("THREE.Matrix4.makePerspective(): Invalid coordinate system: "+a);return c[0]=l,c[4]=0,c[8]=f,c[12]=0,c[1]=0,c[5]=h,c[9]=m,c[13]=0,c[2]=0,c[6]=0,c[10]=p,c[14]=_,c[3]=0,c[7]=0,c[11]=-1,c[15]=0,this}makeOrthographic(t,e,n,r,s,o,a=un){const c=this.elements,l=1/(e-t),h=1/(n-r),f=1/(o-s),m=(e+t)*l,p=(n+r)*h;let _,x;if(a===un)_=(o+s)*f,x=-2*f;else if(a===zr)_=s*f,x=-1*f;else throw new Error("THREE.Matrix4.makeOrthographic(): Invalid coordinate system: "+a);return c[0]=2*l,c[4]=0,c[8]=0,c[12]=-m,c[1]=0,c[5]=2*h,c[9]=0,c[13]=-p,c[2]=0,c[6]=0,c[10]=x,c[14]=-_,c[3]=0,c[7]=0,c[11]=0,c[15]=1,this}equals(t){const e=this.elements,n=t.elements;for(let r=0;r<16;r++)if(e[r]!==n[r])return!1;return!0}fromArray(t,e=0){for(let n=0;n<16;n++)this.elements[n]=t[n+e];return this}toArray(t=[],e=0){const n=this.elements;return t[e]=n[0],t[e+1]=n[1],t[e+2]=n[2],t[e+3]=n[3],t[e+4]=n[4],t[e+5]=n[5],t[e+6]=n[6],t[e+7]=n[7],t[e+8]=n[8],t[e+9]=n[9],t[e+10]=n[10],t[e+11]=n[11],t[e+12]=n[12],t[e+13]=n[13],t[e+14]=n[14],t[e+15]=n[15],t}}const ti=new H,qe=new ee,Iu=new H(0,0,0),Uu=new H(1,1,1),Mn=new H,or=new H,Ue=new H,ca=new ee,la=new An;class Zi{constructor(t=0,e=0,n=0,r=Zi.DEFAULT_ORDER){this.isEuler=!0,this._x=t,this._y=e,this._z=n,this._order=r}get x(){return this._x}set x(t){this._x=t,this._onChangeCallback()}get y(){return this._y}set y(t){this._y=t,this._onChangeCallback()}get z(){return this._z}set z(t){this._z=t,this._onChangeCallback()}get order(){return this._order}set order(t){this._order=t,this._onChangeCallback()}set(t,e,n,r=this._order){return this._x=t,this._y=e,this._z=n,this._order=r,this._onChangeCallback(),this}clone(){return new this.constructor(this._x,this._y,this._z,this._order)}copy(t){return this._x=t._x,this._y=t._y,this._z=t._z,this._order=t._order,this._onChangeCallback(),this}setFromRotationMatrix(t,e=this._order,n=!0){const r=t.elements,s=r[0],o=r[4],a=r[8],c=r[1],l=r[5],h=r[9],f=r[2],m=r[6],p=r[10];switch(e){case"XYZ":this._y=Math.asin(xe(a,-1,1)),Math.abs(a)<.9999999?(this._x=Math.atan2(-h,p),this._z=Math.atan2(-o,s)):(this._x=Math.atan2(m,l),this._z=0);break;case"YXZ":this._x=Math.asin(-xe(h,-1,1)),Math.abs(h)<.9999999?(this._y=Math.atan2(a,p),this._z=Math.atan2(c,l)):(this._y=Math.atan2(-f,s),this._z=0);break;case"ZXY":this._x=Math.asin(xe(m,-1,1)),Math.abs(m)<.9999999?(this._y=Math.atan2(-f,p),this._z=Math.atan2(-o,l)):(this._y=0,this._z=Math.atan2(c,s));break;case"ZYX":this._y=Math.asin(-xe(f,-1,1)),Math.abs(f)<.9999999?(this._x=Math.atan2(m,p),this._z=Math.atan2(c,s)):(this._x=0,this._z=Math.atan2(-o,l));break;case"YZX":this._z=Math.asin(xe(c,-1,1)),Math.abs(c)<.9999999?(this._x=Math.atan2(-h,l),this._y=Math.atan2(-f,s)):(this._x=0,this._y=Math.atan2(a,p));break;case"XZY":this._z=Math.asin(-xe(o,-1,1)),Math.abs(o)<.9999999?(this._x=Math.atan2(m,l),this._y=Math.atan2(a,s)):(this._x=Math.atan2(-h,p),this._y=0);break;default:console.warn("THREE.Euler: .setFromRotationMatrix() encountered an unknown order: "+e)}return this._order=e,n===!0&&this._onChangeCallback(),this}setFromQuaternion(t,e,n){return ca.makeRotationFromQuaternion(t),this.setFromRotationMatrix(ca,e,n)}setFromVector3(t,e=this._order){return this.set(t.x,t.y,t.z,e)}reorder(t){return la.setFromEuler(this),this.setFromQuaternion(la,t)}equals(t){return t._x===this._x&&t._y===this._y&&t._z===this._z&&t._order===this._order}fromArray(t){return this._x=t[0],this._y=t[1],this._z=t[2],t[3]!==void 0&&(this._order=t[3]),this._onChangeCallback(),this}toArray(t=[],e=0){return t[e]=this._x,t[e+1]=this._y,t[e+2]=this._z,t[e+3]=this._order,t}_onChange(t){return this._onChangeCallback=t,this}_onChangeCallback(){}*[Symbol.iterator](){yield this._x,yield this._y,yield this._z,yield this._order}}Zi.DEFAULT_ORDER="XYZ";class ro{constructor(){this.mask=1}set(t){this.mask=(1<<t|0)>>>0}enable(t){this.mask|=1<<t|0}enableAll(){this.mask=-1}toggle(t){this.mask^=1<<t|0}disable(t){this.mask&=~(1<<t|0)}disableAll(){this.mask=0}test(t){return(this.mask&t.mask)!==0}isEnabled(t){return(this.mask&(1<<t|0))!==0}}let Nu=0;const ua=new H,ei=new An,on=new ee,ar=new H,Ii=new H,Ou=new H,Fu=new An,ha=new H(1,0,0),da=new H(0,1,0),fa=new H(0,0,1),Bu={type:"added"},zu={type:"removed"};class ae extends Vn{constructor(){super(),this.isObject3D=!0,Object.defineProperty(this,"id",{value:Nu++}),this.uuid=fn(),this.name="",this.type="Object3D",this.parent=null,this.children=[],this.up=ae.DEFAULT_UP.clone();const t=new H,e=new Zi,n=new An,r=new H(1,1,1);function s(){n.setFromEuler(e,!1)}function o(){e.setFromQuaternion(n,void 0,!1)}e._onChange(s),n._onChange(o),Object.defineProperties(this,{position:{configurable:!0,enumerable:!0,value:t},rotation:{configurable:!0,enumerable:!0,value:e},quaternion:{configurable:!0,enumerable:!0,value:n},scale:{configurable:!0,enumerable:!0,value:r},modelViewMatrix:{value:new ee},normalMatrix:{value:new Kt}}),this.matrix=new ee,this.matrixWorld=new ee,this.matrixAutoUpdate=ae.DEFAULT_MATRIX_AUTO_UPDATE,this.matrixWorldAutoUpdate=ae.DEFAULT_MATRIX_WORLD_AUTO_UPDATE,this.matrixWorldNeedsUpdate=!1,this.layers=new ro,this.visible=!0,this.castShadow=!1,this.receiveShadow=!1,this.frustumCulled=!0,this.renderOrder=0,this.animations=[],this.userData={}}onBeforeShadow(){}onAfterShadow(){}onBeforeRender(){}onAfterRender(){}applyMatrix4(t){this.matrixAutoUpdate&&this.updateMatrix(),this.matrix.premultiply(t),this.matrix.decompose(this.position,this.quaternion,this.scale)}applyQuaternion(t){return this.quaternion.premultiply(t),this}setRotationFromAxisAngle(t,e){this.quaternion.setFromAxisAngle(t,e)}setRotationFromEuler(t){this.quaternion.setFromEuler(t,!0)}setRotationFromMatrix(t){this.quaternion.setFromRotationMatrix(t)}setRotationFromQuaternion(t){this.quaternion.copy(t)}rotateOnAxis(t,e){return ei.setFromAxisAngle(t,e),this.quaternion.multiply(ei),this}rotateOnWorldAxis(t,e){return ei.setFromAxisAngle(t,e),this.quaternion.premultiply(ei),this}rotateX(t){return this.rotateOnAxis(ha,t)}rotateY(t){return this.rotateOnAxis(da,t)}rotateZ(t){return this.rotateOnAxis(fa,t)}translateOnAxis(t,e){return ua.copy(t).applyQuaternion(this.quaternion),this.position.add(ua.multiplyScalar(e)),this}translateX(t){return this.translateOnAxis(ha,t)}translateY(t){return this.translateOnAxis(da,t)}translateZ(t){return this.translateOnAxis(fa,t)}localToWorld(t){return this.updateWorldMatrix(!0,!1),t.applyMatrix4(this.matrixWorld)}worldToLocal(t){return this.updateWorldMatrix(!0,!1),t.applyMatrix4(on.copy(this.matrixWorld).invert())}lookAt(t,e,n){t.isVector3?ar.copy(t):ar.set(t,e,n);const r=this.parent;this.updateWorldMatrix(!0,!1),Ii.setFromMatrixPosition(this.matrixWorld),this.isCamera||this.isLight?on.lookAt(Ii,ar,this.up):on.lookAt(ar,Ii,this.up),this.quaternion.setFromRotationMatrix(on),r&&(on.extractRotation(r.matrixWorld),ei.setFromRotationMatrix(on),this.quaternion.premultiply(ei.invert()))}add(t){if(arguments.length>1){for(let e=0;e<arguments.length;e++)this.add(arguments[e]);return this}return t===this?(console.error("THREE.Object3D.add: object can't be added as a child of itself.",t),this):(t&&t.isObject3D?(t.parent!==null&&t.parent.remove(t),t.parent=this,this.children.push(t),t.dispatchEvent(Bu)):console.error("THREE.Object3D.add: object not an instance of THREE.Object3D.",t),this)}remove(t){if(arguments.length>1){for(let n=0;n<arguments.length;n++)this.remove(arguments[n]);return this}const e=this.children.indexOf(t);return e!==-1&&(t.parent=null,this.children.splice(e,1),t.dispatchEvent(zu)),this}removeFromParent(){const t=this.parent;return t!==null&&t.remove(this),this}clear(){return this.remove(...this.children)}attach(t){return this.updateWorldMatrix(!0,!1),on.copy(this.matrixWorld).invert(),t.parent!==null&&(t.parent.updateWorldMatrix(!0,!1),on.multiply(t.parent.matrixWorld)),t.applyMatrix4(on),this.add(t),t.updateWorldMatrix(!1,!0),this}getObjectById(t){return this.getObjectByProperty("id",t)}getObjectByName(t){return this.getObjectByProperty("name",t)}getObjectByProperty(t,e){if(this[t]===e)return this;for(let n=0,r=this.children.length;n<r;n++){const o=this.children[n].getObjectByProperty(t,e);if(o!==void 0)return o}}getObjectsByProperty(t,e,n=[]){this[t]===e&&n.push(this);const r=this.children;for(let s=0,o=r.length;s<o;s++)r[s].getObjectsByProperty(t,e,n);return n}getWorldPosition(t){return this.updateWorldMatrix(!0,!1),t.setFromMatrixPosition(this.matrixWorld)}getWorldQuaternion(t){return this.updateWorldMatrix(!0,!1),this.matrixWorld.decompose(Ii,t,Ou),t}getWorldScale(t){return this.updateWorldMatrix(!0,!1),this.matrixWorld.decompose(Ii,Fu,t),t}getWorldDirection(t){this.updateWorldMatrix(!0,!1);const e=this.matrixWorld.elements;return t.set(e[8],e[9],e[10]).normalize()}raycast(){}traverse(t){t(this);const e=this.children;for(let n=0,r=e.length;n<r;n++)e[n].traverse(t)}traverseVisible(t){if(this.visible===!1)return;t(this);const e=this.children;for(let n=0,r=e.length;n<r;n++)e[n].traverseVisible(t)}traverseAncestors(t){const e=this.parent;e!==null&&(t(e),e.traverseAncestors(t))}updateMatrix(){this.matrix.compose(this.position,this.quaternion,this.scale),this.matrixWorldNeedsUpdate=!0}updateMatrixWorld(t){this.matrixAutoUpdate&&this.updateMatrix(),(this.matrixWorldNeedsUpdate||t)&&(this.parent===null?this.matrixWorld.copy(this.matrix):this.matrixWorld.multiplyMatrices(this.parent.matrixWorld,this.matrix),this.matrixWorldNeedsUpdate=!1,t=!0);const e=this.children;for(let n=0,r=e.length;n<r;n++){const s=e[n];(s.matrixWorldAutoUpdate===!0||t===!0)&&s.updateMatrixWorld(t)}}updateWorldMatrix(t,e){const n=this.parent;if(t===!0&&n!==null&&n.matrixWorldAutoUpdate===!0&&n.updateWorldMatrix(!0,!1),this.matrixAutoUpdate&&this.updateMatrix(),this.parent===null?this.matrixWorld.copy(this.matrix):this.matrixWorld.multiplyMatrices(this.parent.matrixWorld,this.matrix),e===!0){const r=this.children;for(let s=0,o=r.length;s<o;s++){const a=r[s];a.matrixWorldAutoUpdate===!0&&a.updateWorldMatrix(!1,!0)}}}toJSON(t){const e=t===void 0||typeof t=="string",n={};e&&(t={geometries:{},materials:{},textures:{},images:{},shapes:{},skeletons:{},animations:{},nodes:{}},n.metadata={version:4.6,type:"Object",generator:"Object3D.toJSON"});const r={};r.uuid=this.uuid,r.type=this.type,this.name!==""&&(r.name=this.name),this.castShadow===!0&&(r.castShadow=!0),this.receiveShadow===!0&&(r.receiveShadow=!0),this.visible===!1&&(r.visible=!1),this.frustumCulled===!1&&(r.frustumCulled=!1),this.renderOrder!==0&&(r.renderOrder=this.renderOrder),Object.keys(this.userData).length>0&&(r.userData=this.userData),r.layers=this.layers.mask,r.matrix=this.matrix.toArray(),r.up=this.up.toArray(),this.matrixAutoUpdate===!1&&(r.matrixAutoUpdate=!1),this.isInstancedMesh&&(r.type="InstancedMesh",r.count=this.count,r.instanceMatrix=this.instanceMatrix.toJSON(),this.instanceColor!==null&&(r.instanceColor=this.instanceColor.toJSON())),this.isBatchedMesh&&(r.type="BatchedMesh",r.perObjectFrustumCulled=this.perObjectFrustumCulled,r.sortObjects=this.sortObjects,r.drawRanges=this._drawRanges,r.reservedRanges=this._reservedRanges,r.visibility=this._visibility,r.active=this._active,r.bounds=this._bounds.map(a=>({boxInitialized:a.boxInitialized,boxMin:a.box.min.toArray(),boxMax:a.box.max.toArray(),sphereInitialized:a.sphereInitialized,sphereRadius:a.sphere.radius,sphereCenter:a.sphere.center.toArray()})),r.maxGeometryCount=this._maxGeometryCount,r.maxVertexCount=this._maxVertexCount,r.maxIndexCount=this._maxIndexCount,r.geometryInitialized=this._geometryInitialized,r.geometryCount=this._geometryCount,r.matricesTexture=this._matricesTexture.toJSON(t),this.boundingSphere!==null&&(r.boundingSphere={center:r.boundingSphere.center.toArray(),radius:r.boundingSphere.radius}),this.boundingBox!==null&&(r.boundingBox={min:r.boundingBox.min.toArray(),max:r.boundingBox.max.toArray()}));function s(a,c){return a[c.uuid]===void 0&&(a[c.uuid]=c.toJSON(t)),c.uuid}if(this.isScene)this.background&&(this.background.isColor?r.background=this.background.toJSON():this.background.isTexture&&(r.background=this.background.toJSON(t).uuid)),this.environment&&this.environment.isTexture&&this.environment.isRenderTargetTexture!==!0&&(r.environment=this.environment.toJSON(t).uuid);else if(this.isMesh||this.isLine||this.isPoints){r.geometry=s(t.geometries,this.geometry);const a=this.geometry.parameters;if(a!==void 0&&a.shapes!==void 0){const c=a.shapes;if(Array.isArray(c))for(let l=0,h=c.length;l<h;l++){const f=c[l];s(t.shapes,f)}else s(t.shapes,c)}}if(this.isSkinnedMesh&&(r.bindMode=this.bindMode,r.bindMatrix=this.bindMatrix.toArray(),this.skeleton!==void 0&&(s(t.skeletons,this.skeleton),r.skeleton=this.skeleton.uuid)),this.material!==void 0)if(Array.isArray(this.material)){const a=[];for(let c=0,l=this.material.length;c<l;c++)a.push(s(t.materials,this.material[c]));r.material=a}else r.material=s(t.materials,this.material);if(this.children.length>0){r.children=[];for(let a=0;a<this.children.length;a++)r.children.push(this.children[a].toJSON(t).object)}if(this.animations.length>0){r.animations=[];for(let a=0;a<this.animations.length;a++){const c=this.animations[a];r.animations.push(s(t.animations,c))}}if(e){const a=o(t.geometries),c=o(t.materials),l=o(t.textures),h=o(t.images),f=o(t.shapes),m=o(t.skeletons),p=o(t.animations),_=o(t.nodes);a.length>0&&(n.geometries=a),c.length>0&&(n.materials=c),l.length>0&&(n.textures=l),h.length>0&&(n.images=h),f.length>0&&(n.shapes=f),m.length>0&&(n.skeletons=m),p.length>0&&(n.animations=p),_.length>0&&(n.nodes=_)}return n.object=r,n;function o(a){const c=[];for(const l in a){const h=a[l];delete h.metadata,c.push(h)}return c}}clone(t){return new this.constructor().copy(this,t)}copy(t,e=!0){if(this.name=t.name,this.up.copy(t.up),this.position.copy(t.position),this.rotation.order=t.rotation.order,this.quaternion.copy(t.quaternion),this.scale.copy(t.scale),this.matrix.copy(t.matrix),this.matrixWorld.copy(t.matrixWorld),this.matrixAutoUpdate=t.matrixAutoUpdate,this.matrixWorldAutoUpdate=t.matrixWorldAutoUpdate,this.matrixWorldNeedsUpdate=t.matrixWorldNeedsUpdate,this.layers.mask=t.layers.mask,this.visible=t.visible,this.castShadow=t.castShadow,this.receiveShadow=t.receiveShadow,this.frustumCulled=t.frustumCulled,this.renderOrder=t.renderOrder,this.animations=t.animations.slice(),this.userData=JSON.parse(JSON.stringify(t.userData)),e===!0)for(let n=0;n<t.children.length;n++){const r=t.children[n];this.add(r.clone())}return this}}ae.DEFAULT_UP=new H(0,1,0);ae.DEFAULT_MATRIX_AUTO_UPDATE=!0;ae.DEFAULT_MATRIX_WORLD_AUTO_UPDATE=!0;const Ye=new H,an=new H,ms=new H,cn=new H,ni=new H,ii=new H,pa=new H,gs=new H,_s=new H,vs=new H;let cr=!1;class Oe{constructor(t=new H,e=new H,n=new H){this.a=t,this.b=e,this.c=n}static getNormal(t,e,n,r){r.subVectors(n,e),Ye.subVectors(t,e),r.cross(Ye);const s=r.lengthSq();return s>0?r.multiplyScalar(1/Math.sqrt(s)):r.set(0,0,0)}static getBarycoord(t,e,n,r,s){Ye.subVectors(r,e),an.subVectors(n,e),ms.subVectors(t,e);const o=Ye.dot(Ye),a=Ye.dot(an),c=Ye.dot(ms),l=an.dot(an),h=an.dot(ms),f=o*l-a*a;if(f===0)return s.set(0,0,0),null;const m=1/f,p=(l*c-a*h)*m,_=(o*h-a*c)*m;return s.set(1-p-_,_,p)}static containsPoint(t,e,n,r){return this.getBarycoord(t,e,n,r,cn)===null?!1:cn.x>=0&&cn.y>=0&&cn.x+cn.y<=1}static getUV(t,e,n,r,s,o,a,c){return cr===!1&&(console.warn("THREE.Triangle.getUV() has been renamed to THREE.Triangle.getInterpolation()."),cr=!0),this.getInterpolation(t,e,n,r,s,o,a,c)}static getInterpolation(t,e,n,r,s,o,a,c){return this.getBarycoord(t,e,n,r,cn)===null?(c.x=0,c.y=0,"z"in c&&(c.z=0),"w"in c&&(c.w=0),null):(c.setScalar(0),c.addScaledVector(s,cn.x),c.addScaledVector(o,cn.y),c.addScaledVector(a,cn.z),c)}static isFrontFacing(t,e,n,r){return Ye.subVectors(n,e),an.subVectors(t,e),Ye.cross(an).dot(r)<0}set(t,e,n){return this.a.copy(t),this.b.copy(e),this.c.copy(n),this}setFromPointsAndIndices(t,e,n,r){return this.a.copy(t[e]),this.b.copy(t[n]),this.c.copy(t[r]),this}setFromAttributeAndIndices(t,e,n,r){return this.a.fromBufferAttribute(t,e),this.b.fromBufferAttribute(t,n),this.c.fromBufferAttribute(t,r),this}clone(){return new this.constructor().copy(this)}copy(t){return this.a.copy(t.a),this.b.copy(t.b),this.c.copy(t.c),this}getArea(){return Ye.subVectors(this.c,this.b),an.subVectors(this.a,this.b),Ye.cross(an).length()*.5}getMidpoint(t){return t.addVectors(this.a,this.b).add(this.c).multiplyScalar(1/3)}getNormal(t){return Oe.getNormal(this.a,this.b,this.c,t)}getPlane(t){return t.setFromCoplanarPoints(this.a,this.b,this.c)}getBarycoord(t,e){return Oe.getBarycoord(t,this.a,this.b,this.c,e)}getUV(t,e,n,r,s){return cr===!1&&(console.warn("THREE.Triangle.getUV() has been renamed to THREE.Triangle.getInterpolation()."),cr=!0),Oe.getInterpolation(t,this.a,this.b,this.c,e,n,r,s)}getInterpolation(t,e,n,r,s){return Oe.getInterpolation(t,this.a,this.b,this.c,e,n,r,s)}containsPoint(t){return Oe.containsPoint(t,this.a,this.b,this.c)}isFrontFacing(t){return Oe.isFrontFacing(this.a,this.b,this.c,t)}intersectsBox(t){return t.intersectsTriangle(this)}closestPointToPoint(t,e){const n=this.a,r=this.b,s=this.c;let o,a;ni.subVectors(r,n),ii.subVectors(s,n),gs.subVectors(t,n);const c=ni.dot(gs),l=ii.dot(gs);if(c<=0&&l<=0)return e.copy(n);_s.subVectors(t,r);const h=ni.dot(_s),f=ii.dot(_s);if(h>=0&&f<=h)return e.copy(r);const m=c*f-h*l;if(m<=0&&c>=0&&h<=0)return o=c/(c-h),e.copy(n).addScaledVector(ni,o);vs.subVectors(t,s);const p=ni.dot(vs),_=ii.dot(vs);if(_>=0&&p<=_)return e.copy(s);const x=p*l-c*_;if(x<=0&&l>=0&&_<=0)return a=l/(l-_),e.copy(n).addScaledVector(ii,a);const d=h*_-p*f;if(d<=0&&f-h>=0&&p-_>=0)return pa.subVectors(s,r),a=(f-h)/(f-h+(p-_)),e.copy(r).addScaledVector(pa,a);const u=1/(d+x+m);return o=x*u,a=m*u,e.copy(n).addScaledVector(ni,o).addScaledVector(ii,a)}equals(t){return t.a.equals(this.a)&&t.b.equals(this.b)&&t.c.equals(this.c)}}const Oc={aliceblue:15792383,antiquewhite:16444375,aqua:65535,aquamarine:8388564,azure:15794175,beige:16119260,bisque:16770244,black:0,blanchedalmond:16772045,blue:255,blueviolet:9055202,brown:10824234,burlywood:14596231,cadetblue:6266528,chartreuse:8388352,chocolate:13789470,coral:16744272,cornflowerblue:6591981,cornsilk:16775388,crimson:14423100,cyan:65535,darkblue:139,darkcyan:35723,darkgoldenrod:12092939,darkgray:11119017,darkgreen:25600,darkgrey:11119017,darkkhaki:12433259,darkmagenta:9109643,darkolivegreen:5597999,darkorange:16747520,darkorchid:10040012,darkred:9109504,darksalmon:15308410,darkseagreen:9419919,darkslateblue:4734347,darkslategray:3100495,darkslategrey:3100495,darkturquoise:52945,darkviolet:9699539,deeppink:16716947,deepskyblue:49151,dimgray:6908265,dimgrey:6908265,dodgerblue:2003199,firebrick:11674146,floralwhite:16775920,forestgreen:2263842,fuchsia:16711935,gainsboro:14474460,ghostwhite:16316671,gold:16766720,goldenrod:14329120,gray:8421504,green:32768,greenyellow:11403055,grey:8421504,honeydew:15794160,hotpink:16738740,indianred:13458524,indigo:4915330,ivory:16777200,khaki:15787660,lavender:15132410,lavenderblush:16773365,lawngreen:8190976,lemonchiffon:16775885,lightblue:11393254,lightcoral:15761536,lightcyan:14745599,lightgoldenrodyellow:16448210,lightgray:13882323,lightgreen:9498256,lightgrey:13882323,lightpink:16758465,lightsalmon:16752762,lightseagreen:2142890,lightskyblue:8900346,lightslategray:7833753,lightslategrey:7833753,lightsteelblue:11584734,lightyellow:16777184,lime:65280,limegreen:3329330,linen:16445670,magenta:16711935,maroon:8388608,mediumaquamarine:6737322,mediumblue:205,mediumorchid:12211667,mediumpurple:9662683,mediumseagreen:3978097,mediumslateblue:8087790,mediumspringgreen:64154,mediumturquoise:4772300,mediumvioletred:13047173,midnightblue:1644912,mintcream:16121850,mistyrose:16770273,moccasin:16770229,navajowhite:16768685,navy:128,oldlace:16643558,olive:8421376,olivedrab:7048739,orange:16753920,orangered:16729344,orchid:14315734,palegoldenrod:15657130,palegreen:10025880,paleturquoise:11529966,palevioletred:14381203,papayawhip:16773077,peachpuff:16767673,peru:13468991,pink:16761035,plum:14524637,powderblue:11591910,purple:8388736,rebeccapurple:6697881,red:16711680,rosybrown:12357519,royalblue:4286945,saddlebrown:9127187,salmon:16416882,sandybrown:16032864,seagreen:3050327,seashell:16774638,sienna:10506797,silver:12632256,skyblue:8900331,slateblue:6970061,slategray:7372944,slategrey:7372944,snow:16775930,springgreen:65407,steelblue:4620980,tan:13808780,teal:32896,thistle:14204888,tomato:16737095,turquoise:4251856,violet:15631086,wheat:16113331,white:16777215,whitesmoke:16119285,yellow:16776960,yellowgreen:10145074},yn={h:0,s:0,l:0},lr={h:0,s:0,l:0};function xs(i,t,e){return e<0&&(e+=1),e>1&&(e-=1),e<1/6?i+(t-i)*6*e:e<1/2?t:e<2/3?i+(t-i)*6*(2/3-e):i}class Dt{constructor(t,e,n){return this.isColor=!0,this.r=1,this.g=1,this.b=1,this.set(t,e,n)}set(t,e,n){if(e===void 0&&n===void 0){const r=t;r&&r.isColor?this.copy(r):typeof r=="number"?this.setHex(r):typeof r=="string"&&this.setStyle(r)}else this.setRGB(t,e,n);return this}setScalar(t){return this.r=t,this.g=t,this.b=t,this}setHex(t,e=he){return t=Math.floor(t),this.r=(t>>16&255)/255,this.g=(t>>8&255)/255,this.b=(t&255)/255,te.toWorkingColorSpace(this,e),this}setRGB(t,e,n,r=te.workingColorSpace){return this.r=t,this.g=e,this.b=n,te.toWorkingColorSpace(this,r),this}setHSL(t,e,n,r=te.workingColorSpace){if(t=io(t,1),e=xe(e,0,1),n=xe(n,0,1),e===0)this.r=this.g=this.b=n;else{const s=n<=.5?n*(1+e):n+e-n*e,o=2*n-s;this.r=xs(o,s,t+1/3),this.g=xs(o,s,t),this.b=xs(o,s,t-1/3)}return te.toWorkingColorSpace(this,r),this}setStyle(t,e=he){function n(s){s!==void 0&&parseFloat(s)<1&&console.warn("THREE.Color: Alpha component of "+t+" will be ignored.")}let r;if(r=/^(\w+)\(([^\)]*)\)/.exec(t)){let s;const o=r[1],a=r[2];switch(o){case"rgb":case"rgba":if(s=/^\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(a))return n(s[4]),this.setRGB(Math.min(255,parseInt(s[1],10))/255,Math.min(255,parseInt(s[2],10))/255,Math.min(255,parseInt(s[3],10))/255,e);if(s=/^\s*(\d+)\%\s*,\s*(\d+)\%\s*,\s*(\d+)\%\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(a))return n(s[4]),this.setRGB(Math.min(100,parseInt(s[1],10))/100,Math.min(100,parseInt(s[2],10))/100,Math.min(100,parseInt(s[3],10))/100,e);break;case"hsl":case"hsla":if(s=/^\s*(\d*\.?\d+)\s*,\s*(\d*\.?\d+)\%\s*,\s*(\d*\.?\d+)\%\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(a))return n(s[4]),this.setHSL(parseFloat(s[1])/360,parseFloat(s[2])/100,parseFloat(s[3])/100,e);break;default:console.warn("THREE.Color: Unknown color model "+t)}}else if(r=/^\#([A-Fa-f\d]+)$/.exec(t)){const s=r[1],o=s.length;if(o===3)return this.setRGB(parseInt(s.charAt(0),16)/15,parseInt(s.charAt(1),16)/15,parseInt(s.charAt(2),16)/15,e);if(o===6)return this.setHex(parseInt(s,16),e);console.warn("THREE.Color: Invalid hex color "+t)}else if(t&&t.length>0)return this.setColorName(t,e);return this}setColorName(t,e=he){const n=Oc[t.toLowerCase()];return n!==void 0?this.setHex(n,e):console.warn("THREE.Color: Unknown color "+t),this}clone(){return new this.constructor(this.r,this.g,this.b)}copy(t){return this.r=t.r,this.g=t.g,this.b=t.b,this}copySRGBToLinear(t){return this.r=Mi(t.r),this.g=Mi(t.g),this.b=Mi(t.b),this}copyLinearToSRGB(t){return this.r=as(t.r),this.g=as(t.g),this.b=as(t.b),this}convertSRGBToLinear(){return this.copySRGBToLinear(this),this}convertLinearToSRGB(){return this.copyLinearToSRGB(this),this}getHex(t=he){return te.fromWorkingColorSpace(be.copy(this),t),Math.round(xe(be.r*255,0,255))*65536+Math.round(xe(be.g*255,0,255))*256+Math.round(xe(be.b*255,0,255))}getHexString(t=he){return("000000"+this.getHex(t).toString(16)).slice(-6)}getHSL(t,e=te.workingColorSpace){te.fromWorkingColorSpace(be.copy(this),e);const n=be.r,r=be.g,s=be.b,o=Math.max(n,r,s),a=Math.min(n,r,s);let c,l;const h=(a+o)/2;if(a===o)c=0,l=0;else{const f=o-a;switch(l=h<=.5?f/(o+a):f/(2-o-a),o){case n:c=(r-s)/f+(r<s?6:0);break;case r:c=(s-n)/f+2;break;case s:c=(n-r)/f+4;break}c/=6}return t.h=c,t.s=l,t.l=h,t}getRGB(t,e=te.workingColorSpace){return te.fromWorkingColorSpace(be.copy(this),e),t.r=be.r,t.g=be.g,t.b=be.b,t}getStyle(t=he){te.fromWorkingColorSpace(be.copy(this),t);const e=be.r,n=be.g,r=be.b;return t!==he?`color(${t} ${e.toFixed(3)} ${n.toFixed(3)} ${r.toFixed(3)})`:`rgb(${Math.round(e*255)},${Math.round(n*255)},${Math.round(r*255)})`}offsetHSL(t,e,n){return this.getHSL(yn),this.setHSL(yn.h+t,yn.s+e,yn.l+n)}add(t){return this.r+=t.r,this.g+=t.g,this.b+=t.b,this}addColors(t,e){return this.r=t.r+e.r,this.g=t.g+e.g,this.b=t.b+e.b,this}addScalar(t){return this.r+=t,this.g+=t,this.b+=t,this}sub(t){return this.r=Math.max(0,this.r-t.r),this.g=Math.max(0,this.g-t.g),this.b=Math.max(0,this.b-t.b),this}multiply(t){return this.r*=t.r,this.g*=t.g,this.b*=t.b,this}multiplyScalar(t){return this.r*=t,this.g*=t,this.b*=t,this}lerp(t,e){return this.r+=(t.r-this.r)*e,this.g+=(t.g-this.g)*e,this.b+=(t.b-this.b)*e,this}lerpColors(t,e,n){return this.r=t.r+(e.r-t.r)*n,this.g=t.g+(e.g-t.g)*n,this.b=t.b+(e.b-t.b)*n,this}lerpHSL(t,e){this.getHSL(yn),t.getHSL(lr);const n=Hi(yn.h,lr.h,e),r=Hi(yn.s,lr.s,e),s=Hi(yn.l,lr.l,e);return this.setHSL(n,r,s),this}setFromVector3(t){return this.r=t.x,this.g=t.y,this.b=t.z,this}applyMatrix3(t){const e=this.r,n=this.g,r=this.b,s=t.elements;return this.r=s[0]*e+s[3]*n+s[6]*r,this.g=s[1]*e+s[4]*n+s[7]*r,this.b=s[2]*e+s[5]*n+s[8]*r,this}equals(t){return t.r===this.r&&t.g===this.g&&t.b===this.b}fromArray(t,e=0){return this.r=t[e],this.g=t[e+1],this.b=t[e+2],this}toArray(t=[],e=0){return t[e]=this.r,t[e+1]=this.g,t[e+2]=this.b,t}fromBufferAttribute(t,e){return this.r=t.getX(e),this.g=t.getY(e),this.b=t.getZ(e),this}toJSON(){return this.getHex()}*[Symbol.iterator](){yield this.r,yield this.g,yield this.b}}const be=new Dt;Dt.NAMES=Oc;let Gu=0;class Rn extends Vn{constructor(){super(),this.isMaterial=!0,Object.defineProperty(this,"id",{value:Gu++}),this.uuid=fn(),this.name="",this.type="Material",this.blending=xi,this.side=pn,this.vertexColors=!1,this.opacity=1,this.transparent=!1,this.alphaHash=!1,this.blendSrc=Bs,this.blendDst=zs,this.blendEquation=On,this.blendSrcAlpha=null,this.blendDstAlpha=null,this.blendEquationAlpha=null,this.blendColor=new Dt(0,0,0),this.blendAlpha=0,this.depthFunc=Nr,this.depthTest=!0,this.depthWrite=!0,this.stencilWriteMask=255,this.stencilFunc=ea,this.stencilRef=0,this.stencilFuncMask=255,this.stencilFail=$n,this.stencilZFail=$n,this.stencilZPass=$n,this.stencilWrite=!1,this.clippingPlanes=null,this.clipIntersection=!1,this.clipShadows=!1,this.shadowSide=null,this.colorWrite=!0,this.precision=null,this.polygonOffset=!1,this.polygonOffsetFactor=0,this.polygonOffsetUnits=0,this.dithering=!1,this.alphaToCoverage=!1,this.premultipliedAlpha=!1,this.forceSinglePass=!1,this.visible=!0,this.toneMapped=!0,this.userData={},this.version=0,this._alphaTest=0}get alphaTest(){return this._alphaTest}set alphaTest(t){this._alphaTest>0!=t>0&&this.version++,this._alphaTest=t}onBuild(){}onBeforeRender(){}onBeforeCompile(){}customProgramCacheKey(){return this.onBeforeCompile.toString()}setValues(t){if(t!==void 0)for(const e in t){const n=t[e];if(n===void 0){console.warn(`THREE.Material: parameter '${e}' has value of undefined.`);continue}const r=this[e];if(r===void 0){console.warn(`THREE.Material: '${e}' is not a property of THREE.${this.type}.`);continue}r&&r.isColor?r.set(n):r&&r.isVector3&&n&&n.isVector3?r.copy(n):this[e]=n}}toJSON(t){const e=t===void 0||typeof t=="string";e&&(t={textures:{},images:{}});const n={metadata:{version:4.6,type:"Material",generator:"Material.toJSON"}};n.uuid=this.uuid,n.type=this.type,this.name!==""&&(n.name=this.name),this.color&&this.color.isColor&&(n.color=this.color.getHex()),this.roughness!==void 0&&(n.roughness=this.roughness),this.metalness!==void 0&&(n.metalness=this.metalness),this.sheen!==void 0&&(n.sheen=this.sheen),this.sheenColor&&this.sheenColor.isColor&&(n.sheenColor=this.sheenColor.getHex()),this.sheenRoughness!==void 0&&(n.sheenRoughness=this.sheenRoughness),this.emissive&&this.emissive.isColor&&(n.emissive=this.emissive.getHex()),this.emissiveIntensity&&this.emissiveIntensity!==1&&(n.emissiveIntensity=this.emissiveIntensity),this.specular&&this.specular.isColor&&(n.specular=this.specular.getHex()),this.specularIntensity!==void 0&&(n.specularIntensity=this.specularIntensity),this.specularColor&&this.specularColor.isColor&&(n.specularColor=this.specularColor.getHex()),this.shininess!==void 0&&(n.shininess=this.shininess),this.clearcoat!==void 0&&(n.clearcoat=this.clearcoat),this.clearcoatRoughness!==void 0&&(n.clearcoatRoughness=this.clearcoatRoughness),this.clearcoatMap&&this.clearcoatMap.isTexture&&(n.clearcoatMap=this.clearcoatMap.toJSON(t).uuid),this.clearcoatRoughnessMap&&this.clearcoatRoughnessMap.isTexture&&(n.clearcoatRoughnessMap=this.clearcoatRoughnessMap.toJSON(t).uuid),this.clearcoatNormalMap&&this.clearcoatNormalMap.isTexture&&(n.clearcoatNormalMap=this.clearcoatNormalMap.toJSON(t).uuid,n.clearcoatNormalScale=this.clearcoatNormalScale.toArray()),this.iridescence!==void 0&&(n.iridescence=this.iridescence),this.iridescenceIOR!==void 0&&(n.iridescenceIOR=this.iridescenceIOR),this.iridescenceThicknessRange!==void 0&&(n.iridescenceThicknessRange=this.iridescenceThicknessRange),this.iridescenceMap&&this.iridescenceMap.isTexture&&(n.iridescenceMap=this.iridescenceMap.toJSON(t).uuid),this.iridescenceThicknessMap&&this.iridescenceThicknessMap.isTexture&&(n.iridescenceThicknessMap=this.iridescenceThicknessMap.toJSON(t).uuid),this.anisotropy!==void 0&&(n.anisotropy=this.anisotropy),this.anisotropyRotation!==void 0&&(n.anisotropyRotation=this.anisotropyRotation),this.anisotropyMap&&this.anisotropyMap.isTexture&&(n.anisotropyMap=this.anisotropyMap.toJSON(t).uuid),this.map&&this.map.isTexture&&(n.map=this.map.toJSON(t).uuid),this.matcap&&this.matcap.isTexture&&(n.matcap=this.matcap.toJSON(t).uuid),this.alphaMap&&this.alphaMap.isTexture&&(n.alphaMap=this.alphaMap.toJSON(t).uuid),this.lightMap&&this.lightMap.isTexture&&(n.lightMap=this.lightMap.toJSON(t).uuid,n.lightMapIntensity=this.lightMapIntensity),this.aoMap&&this.aoMap.isTexture&&(n.aoMap=this.aoMap.toJSON(t).uuid,n.aoMapIntensity=this.aoMapIntensity),this.bumpMap&&this.bumpMap.isTexture&&(n.bumpMap=this.bumpMap.toJSON(t).uuid,n.bumpScale=this.bumpScale),this.normalMap&&this.normalMap.isTexture&&(n.normalMap=this.normalMap.toJSON(t).uuid,n.normalMapType=this.normalMapType,n.normalScale=this.normalScale.toArray()),this.displacementMap&&this.displacementMap.isTexture&&(n.displacementMap=this.displacementMap.toJSON(t).uuid,n.displacementScale=this.displacementScale,n.displacementBias=this.displacementBias),this.roughnessMap&&this.roughnessMap.isTexture&&(n.roughnessMap=this.roughnessMap.toJSON(t).uuid),this.metalnessMap&&this.metalnessMap.isTexture&&(n.metalnessMap=this.metalnessMap.toJSON(t).uuid),this.emissiveMap&&this.emissiveMap.isTexture&&(n.emissiveMap=this.emissiveMap.toJSON(t).uuid),this.specularMap&&this.specularMap.isTexture&&(n.specularMap=this.specularMap.toJSON(t).uuid),this.specularIntensityMap&&this.specularIntensityMap.isTexture&&(n.specularIntensityMap=this.specularIntensityMap.toJSON(t).uuid),this.specularColorMap&&this.specularColorMap.isTexture&&(n.specularColorMap=this.specularColorMap.toJSON(t).uuid),this.envMap&&this.envMap.isTexture&&(n.envMap=this.envMap.toJSON(t).uuid,this.combine!==void 0&&(n.combine=this.combine)),this.envMapIntensity!==void 0&&(n.envMapIntensity=this.envMapIntensity),this.reflectivity!==void 0&&(n.reflectivity=this.reflectivity),this.refractionRatio!==void 0&&(n.refractionRatio=this.refractionRatio),this.gradientMap&&this.gradientMap.isTexture&&(n.gradientMap=this.gradientMap.toJSON(t).uuid),this.transmission!==void 0&&(n.transmission=this.transmission),this.transmissionMap&&this.transmissionMap.isTexture&&(n.transmissionMap=this.transmissionMap.toJSON(t).uuid),this.thickness!==void 0&&(n.thickness=this.thickness),this.thicknessMap&&this.thicknessMap.isTexture&&(n.thicknessMap=this.thicknessMap.toJSON(t).uuid),this.attenuationDistance!==void 0&&this.attenuationDistance!==1/0&&(n.attenuationDistance=this.attenuationDistance),this.attenuationColor!==void 0&&(n.attenuationColor=this.attenuationColor.getHex()),this.size!==void 0&&(n.size=this.size),this.shadowSide!==null&&(n.shadowSide=this.shadowSide),this.sizeAttenuation!==void 0&&(n.sizeAttenuation=this.sizeAttenuation),this.blending!==xi&&(n.blending=this.blending),this.side!==pn&&(n.side=this.side),this.vertexColors===!0&&(n.vertexColors=!0),this.opacity<1&&(n.opacity=this.opacity),this.transparent===!0&&(n.transparent=!0),this.blendSrc!==Bs&&(n.blendSrc=this.blendSrc),this.blendDst!==zs&&(n.blendDst=this.blendDst),this.blendEquation!==On&&(n.blendEquation=this.blendEquation),this.blendSrcAlpha!==null&&(n.blendSrcAlpha=this.blendSrcAlpha),this.blendDstAlpha!==null&&(n.blendDstAlpha=this.blendDstAlpha),this.blendEquationAlpha!==null&&(n.blendEquationAlpha=this.blendEquationAlpha),this.blendColor&&this.blendColor.isColor&&(n.blendColor=this.blendColor.getHex()),this.blendAlpha!==0&&(n.blendAlpha=this.blendAlpha),this.depthFunc!==Nr&&(n.depthFunc=this.depthFunc),this.depthTest===!1&&(n.depthTest=this.depthTest),this.depthWrite===!1&&(n.depthWrite=this.depthWrite),this.colorWrite===!1&&(n.colorWrite=this.colorWrite),this.stencilWriteMask!==255&&(n.stencilWriteMask=this.stencilWriteMask),this.stencilFunc!==ea&&(n.stencilFunc=this.stencilFunc),this.stencilRef!==0&&(n.stencilRef=this.stencilRef),this.stencilFuncMask!==255&&(n.stencilFuncMask=this.stencilFuncMask),this.stencilFail!==$n&&(n.stencilFail=this.stencilFail),this.stencilZFail!==$n&&(n.stencilZFail=this.stencilZFail),this.stencilZPass!==$n&&(n.stencilZPass=this.stencilZPass),this.stencilWrite===!0&&(n.stencilWrite=this.stencilWrite),this.rotation!==void 0&&this.rotation!==0&&(n.rotation=this.rotation),this.polygonOffset===!0&&(n.polygonOffset=!0),this.polygonOffsetFactor!==0&&(n.polygonOffsetFactor=this.polygonOffsetFactor),this.polygonOffsetUnits!==0&&(n.polygonOffsetUnits=this.polygonOffsetUnits),this.linewidth!==void 0&&this.linewidth!==1&&(n.linewidth=this.linewidth),this.dashSize!==void 0&&(n.dashSize=this.dashSize),this.gapSize!==void 0&&(n.gapSize=this.gapSize),this.scale!==void 0&&(n.scale=this.scale),this.dithering===!0&&(n.dithering=!0),this.alphaTest>0&&(n.alphaTest=this.alphaTest),this.alphaHash===!0&&(n.alphaHash=!0),this.alphaToCoverage===!0&&(n.alphaToCoverage=!0),this.premultipliedAlpha===!0&&(n.premultipliedAlpha=!0),this.forceSinglePass===!0&&(n.forceSinglePass=!0),this.wireframe===!0&&(n.wireframe=!0),this.wireframeLinewidth>1&&(n.wireframeLinewidth=this.wireframeLinewidth),this.wireframeLinecap!=="round"&&(n.wireframeLinecap=this.wireframeLinecap),this.wireframeLinejoin!=="round"&&(n.wireframeLinejoin=this.wireframeLinejoin),this.flatShading===!0&&(n.flatShading=!0),this.visible===!1&&(n.visible=!1),this.toneMapped===!1&&(n.toneMapped=!1),this.fog===!1&&(n.fog=!1),Object.keys(this.userData).length>0&&(n.userData=this.userData);function r(s){const o=[];for(const a in s){const c=s[a];delete c.metadata,o.push(c)}return o}if(e){const s=r(t.textures),o=r(t.images);s.length>0&&(n.textures=s),o.length>0&&(n.images=o)}return n}clone(){return new this.constructor().copy(this)}copy(t){this.name=t.name,this.blending=t.blending,this.side=t.side,this.vertexColors=t.vertexColors,this.opacity=t.opacity,this.transparent=t.transparent,this.blendSrc=t.blendSrc,this.blendDst=t.blendDst,this.blendEquation=t.blendEquation,this.blendSrcAlpha=t.blendSrcAlpha,this.blendDstAlpha=t.blendDstAlpha,this.blendEquationAlpha=t.blendEquationAlpha,this.blendColor.copy(t.blendColor),this.blendAlpha=t.blendAlpha,this.depthFunc=t.depthFunc,this.depthTest=t.depthTest,this.depthWrite=t.depthWrite,this.stencilWriteMask=t.stencilWriteMask,this.stencilFunc=t.stencilFunc,this.stencilRef=t.stencilRef,this.stencilFuncMask=t.stencilFuncMask,this.stencilFail=t.stencilFail,this.stencilZFail=t.stencilZFail,this.stencilZPass=t.stencilZPass,this.stencilWrite=t.stencilWrite;const e=t.clippingPlanes;let n=null;if(e!==null){const r=e.length;n=new Array(r);for(let s=0;s!==r;++s)n[s]=e[s].clone()}return this.clippingPlanes=n,this.clipIntersection=t.clipIntersection,this.clipShadows=t.clipShadows,this.shadowSide=t.shadowSide,this.colorWrite=t.colorWrite,this.precision=t.precision,this.polygonOffset=t.polygonOffset,this.polygonOffsetFactor=t.polygonOffsetFactor,this.polygonOffsetUnits=t.polygonOffsetUnits,this.dithering=t.dithering,this.alphaTest=t.alphaTest,this.alphaHash=t.alphaHash,this.alphaToCoverage=t.alphaToCoverage,this.premultipliedAlpha=t.premultipliedAlpha,this.forceSinglePass=t.forceSinglePass,this.visible=t.visible,this.toneMapped=t.toneMapped,this.userData=JSON.parse(JSON.stringify(t.userData)),this}dispose(){this.dispatchEvent({type:"dispose"})}set needsUpdate(t){t===!0&&this.version++}}class De extends Rn{constructor(t){super(),this.isMeshBasicMaterial=!0,this.type="MeshBasicMaterial",this.color=new Dt(16777215),this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.specularMap=null,this.alphaMap=null,this.envMap=null,this.combine=mc,this.reflectivity=1,this.refractionRatio=.98,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.color.copy(t.color),this.map=t.map,this.lightMap=t.lightMap,this.lightMapIntensity=t.lightMapIntensity,this.aoMap=t.aoMap,this.aoMapIntensity=t.aoMapIntensity,this.specularMap=t.specularMap,this.alphaMap=t.alphaMap,this.envMap=t.envMap,this.combine=t.combine,this.reflectivity=t.reflectivity,this.refractionRatio=t.refractionRatio,this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this.wireframeLinecap=t.wireframeLinecap,this.wireframeLinejoin=t.wireframeLinejoin,this.fog=t.fog,this}}const pe=new H,ur=new At;class le{constructor(t,e,n=!1){if(Array.isArray(t))throw new TypeError("THREE.BufferAttribute: array should be a Typed Array.");this.isBufferAttribute=!0,this.name="",this.array=t,this.itemSize=e,this.count=t!==void 0?t.length/e:0,this.normalized=n,this.usage=Vs,this._updateRange={offset:0,count:-1},this.updateRanges=[],this.gpuType=En,this.version=0}onUploadCallback(){}set needsUpdate(t){t===!0&&this.version++}get updateRange(){return console.warn("THREE.BufferAttribute: updateRange() is deprecated and will be removed in r169. Use addUpdateRange() instead."),this._updateRange}setUsage(t){return this.usage=t,this}addUpdateRange(t,e){this.updateRanges.push({start:t,count:e})}clearUpdateRanges(){this.updateRanges.length=0}copy(t){return this.name=t.name,this.array=new t.array.constructor(t.array),this.itemSize=t.itemSize,this.count=t.count,this.normalized=t.normalized,this.usage=t.usage,this.gpuType=t.gpuType,this}copyAt(t,e,n){t*=this.itemSize,n*=e.itemSize;for(let r=0,s=this.itemSize;r<s;r++)this.array[t+r]=e.array[n+r];return this}copyArray(t){return this.array.set(t),this}applyMatrix3(t){if(this.itemSize===2)for(let e=0,n=this.count;e<n;e++)ur.fromBufferAttribute(this,e),ur.applyMatrix3(t),this.setXY(e,ur.x,ur.y);else if(this.itemSize===3)for(let e=0,n=this.count;e<n;e++)pe.fromBufferAttribute(this,e),pe.applyMatrix3(t),this.setXYZ(e,pe.x,pe.y,pe.z);return this}applyMatrix4(t){for(let e=0,n=this.count;e<n;e++)pe.fromBufferAttribute(this,e),pe.applyMatrix4(t),this.setXYZ(e,pe.x,pe.y,pe.z);return this}applyNormalMatrix(t){for(let e=0,n=this.count;e<n;e++)pe.fromBufferAttribute(this,e),pe.applyNormalMatrix(t),this.setXYZ(e,pe.x,pe.y,pe.z);return this}transformDirection(t){for(let e=0,n=this.count;e<n;e++)pe.fromBufferAttribute(this,e),pe.transformDirection(t),this.setXYZ(e,pe.x,pe.y,pe.z);return this}set(t,e=0){return this.array.set(t,e),this}getComponent(t,e){let n=this.array[t*this.itemSize+e];return this.normalized&&(n=tn(n,this.array)),n}setComponent(t,e,n){return this.normalized&&(n=ne(n,this.array)),this.array[t*this.itemSize+e]=n,this}getX(t){let e=this.array[t*this.itemSize];return this.normalized&&(e=tn(e,this.array)),e}setX(t,e){return this.normalized&&(e=ne(e,this.array)),this.array[t*this.itemSize]=e,this}getY(t){let e=this.array[t*this.itemSize+1];return this.normalized&&(e=tn(e,this.array)),e}setY(t,e){return this.normalized&&(e=ne(e,this.array)),this.array[t*this.itemSize+1]=e,this}getZ(t){let e=this.array[t*this.itemSize+2];return this.normalized&&(e=tn(e,this.array)),e}setZ(t,e){return this.normalized&&(e=ne(e,this.array)),this.array[t*this.itemSize+2]=e,this}getW(t){let e=this.array[t*this.itemSize+3];return this.normalized&&(e=tn(e,this.array)),e}setW(t,e){return this.normalized&&(e=ne(e,this.array)),this.array[t*this.itemSize+3]=e,this}setXY(t,e,n){return t*=this.itemSize,this.normalized&&(e=ne(e,this.array),n=ne(n,this.array)),this.array[t+0]=e,this.array[t+1]=n,this}setXYZ(t,e,n,r){return t*=this.itemSize,this.normalized&&(e=ne(e,this.array),n=ne(n,this.array),r=ne(r,this.array)),this.array[t+0]=e,this.array[t+1]=n,this.array[t+2]=r,this}setXYZW(t,e,n,r,s){return t*=this.itemSize,this.normalized&&(e=ne(e,this.array),n=ne(n,this.array),r=ne(r,this.array),s=ne(s,this.array)),this.array[t+0]=e,this.array[t+1]=n,this.array[t+2]=r,this.array[t+3]=s,this}onUpload(t){return this.onUploadCallback=t,this}clone(){return new this.constructor(this.array,this.itemSize).copy(this)}toJSON(){const t={itemSize:this.itemSize,type:this.array.constructor.name,array:Array.from(this.array),normalized:this.normalized};return this.name!==""&&(t.name=this.name),this.usage!==Vs&&(t.usage=this.usage),t}}class Fc extends le{constructor(t,e,n){super(new Uint16Array(t),e,n)}}class Bc extends le{constructor(t,e,n){super(new Uint32Array(t),e,n)}}class Nt extends le{constructor(t,e,n){super(new Float32Array(t),e,n)}}let ku=0;const ke=new ee,Ms=new ae,ri=new H,Ne=new Xn,Ui=new Xn,ve=new H;class Jt extends Vn{constructor(){super(),this.isBufferGeometry=!0,Object.defineProperty(this,"id",{value:ku++}),this.uuid=fn(),this.name="",this.type="BufferGeometry",this.index=null,this.attributes={},this.morphAttributes={},this.morphTargetsRelative=!1,this.groups=[],this.boundingBox=null,this.boundingSphere=null,this.drawRange={start:0,count:1/0},this.userData={}}getIndex(){return this.index}setIndex(t){return Array.isArray(t)?this.index=new(Dc(t)?Bc:Fc)(t,1):this.index=t,this}getAttribute(t){return this.attributes[t]}setAttribute(t,e){return this.attributes[t]=e,this}deleteAttribute(t){return delete this.attributes[t],this}hasAttribute(t){return this.attributes[t]!==void 0}addGroup(t,e,n=0){this.groups.push({start:t,count:e,materialIndex:n})}clearGroups(){this.groups=[]}setDrawRange(t,e){this.drawRange.start=t,this.drawRange.count=e}applyMatrix4(t){const e=this.attributes.position;e!==void 0&&(e.applyMatrix4(t),e.needsUpdate=!0);const n=this.attributes.normal;if(n!==void 0){const s=new Kt().getNormalMatrix(t);n.applyNormalMatrix(s),n.needsUpdate=!0}const r=this.attributes.tangent;return r!==void 0&&(r.transformDirection(t),r.needsUpdate=!0),this.boundingBox!==null&&this.computeBoundingBox(),this.boundingSphere!==null&&this.computeBoundingSphere(),this}applyQuaternion(t){return ke.makeRotationFromQuaternion(t),this.applyMatrix4(ke),this}rotateX(t){return ke.makeRotationX(t),this.applyMatrix4(ke),this}rotateY(t){return ke.makeRotationY(t),this.applyMatrix4(ke),this}rotateZ(t){return ke.makeRotationZ(t),this.applyMatrix4(ke),this}translate(t,e,n){return ke.makeTranslation(t,e,n),this.applyMatrix4(ke),this}scale(t,e,n){return ke.makeScale(t,e,n),this.applyMatrix4(ke),this}lookAt(t){return Ms.lookAt(t),Ms.updateMatrix(),this.applyMatrix4(Ms.matrix),this}center(){return this.computeBoundingBox(),this.boundingBox.getCenter(ri).negate(),this.translate(ri.x,ri.y,ri.z),this}setFromPoints(t){const e=[];for(let n=0,r=t.length;n<r;n++){const s=t[n];e.push(s.x,s.y,s.z||0)}return this.setAttribute("position",new Nt(e,3)),this}computeBoundingBox(){this.boundingBox===null&&(this.boundingBox=new Xn);const t=this.attributes.position,e=this.morphAttributes.position;if(t&&t.isGLBufferAttribute){console.error('THREE.BufferGeometry.computeBoundingBox(): GLBufferAttribute requires a manual bounding box. Alternatively set "mesh.frustumCulled" to "false".',this),this.boundingBox.set(new H(-1/0,-1/0,-1/0),new H(1/0,1/0,1/0));return}if(t!==void 0){if(this.boundingBox.setFromBufferAttribute(t),e)for(let n=0,r=e.length;n<r;n++){const s=e[n];Ne.setFromBufferAttribute(s),this.morphTargetsRelative?(ve.addVectors(this.boundingBox.min,Ne.min),this.boundingBox.expandByPoint(ve),ve.addVectors(this.boundingBox.max,Ne.max),this.boundingBox.expandByPoint(ve)):(this.boundingBox.expandByPoint(Ne.min),this.boundingBox.expandByPoint(Ne.max))}}else this.boundingBox.makeEmpty();(isNaN(this.boundingBox.min.x)||isNaN(this.boundingBox.min.y)||isNaN(this.boundingBox.min.z))&&console.error('THREE.BufferGeometry.computeBoundingBox(): Computed min/max have NaN values. The "position" attribute is likely to have NaN values.',this)}computeBoundingSphere(){this.boundingSphere===null&&(this.boundingSphere=new Wn);const t=this.attributes.position,e=this.morphAttributes.position;if(t&&t.isGLBufferAttribute){console.error('THREE.BufferGeometry.computeBoundingSphere(): GLBufferAttribute requires a manual bounding sphere. Alternatively set "mesh.frustumCulled" to "false".',this),this.boundingSphere.set(new H,1/0);return}if(t){const n=this.boundingSphere.center;if(Ne.setFromBufferAttribute(t),e)for(let s=0,o=e.length;s<o;s++){const a=e[s];Ui.setFromBufferAttribute(a),this.morphTargetsRelative?(ve.addVectors(Ne.min,Ui.min),Ne.expandByPoint(ve),ve.addVectors(Ne.max,Ui.max),Ne.expandByPoint(ve)):(Ne.expandByPoint(Ui.min),Ne.expandByPoint(Ui.max))}Ne.getCenter(n);let r=0;for(let s=0,o=t.count;s<o;s++)ve.fromBufferAttribute(t,s),r=Math.max(r,n.distanceToSquared(ve));if(e)for(let s=0,o=e.length;s<o;s++){const a=e[s],c=this.morphTargetsRelative;for(let l=0,h=a.count;l<h;l++)ve.fromBufferAttribute(a,l),c&&(ri.fromBufferAttribute(t,l),ve.add(ri)),r=Math.max(r,n.distanceToSquared(ve))}this.boundingSphere.radius=Math.sqrt(r),isNaN(this.boundingSphere.radius)&&console.error('THREE.BufferGeometry.computeBoundingSphere(): Computed radius is NaN. The "position" attribute is likely to have NaN values.',this)}}computeTangents(){const t=this.index,e=this.attributes;if(t===null||e.position===void 0||e.normal===void 0||e.uv===void 0){console.error("THREE.BufferGeometry: .computeTangents() failed. Missing required attributes (index, position, normal or uv)");return}const n=t.array,r=e.position.array,s=e.normal.array,o=e.uv.array,a=r.length/3;this.hasAttribute("tangent")===!1&&this.setAttribute("tangent",new le(new Float32Array(4*a),4));const c=this.getAttribute("tangent").array,l=[],h=[];for(let E=0;E<a;E++)l[E]=new H,h[E]=new H;const f=new H,m=new H,p=new H,_=new At,x=new At,d=new At,u=new H,M=new H;function g(E,j,O){f.fromArray(r,E*3),m.fromArray(r,j*3),p.fromArray(r,O*3),_.fromArray(o,E*2),x.fromArray(o,j*2),d.fromArray(o,O*2),m.sub(f),p.sub(f),x.sub(_),d.sub(_);const B=1/(x.x*d.y-d.x*x.y);isFinite(B)&&(u.copy(m).multiplyScalar(d.y).addScaledVector(p,-x.y).multiplyScalar(B),M.copy(p).multiplyScalar(x.x).addScaledVector(m,-d.x).multiplyScalar(B),l[E].add(u),l[j].add(u),l[O].add(u),h[E].add(M),h[j].add(M),h[O].add(M))}let y=this.groups;y.length===0&&(y=[{start:0,count:n.length}]);for(let E=0,j=y.length;E<j;++E){const O=y[E],B=O.start,S=O.count;for(let b=B,v=B+S;b<v;b+=3)g(n[b+0],n[b+1],n[b+2])}const L=new H,C=new H,D=new H,F=new H;function T(E){D.fromArray(s,E*3),F.copy(D);const j=l[E];L.copy(j),L.sub(D.multiplyScalar(D.dot(j))).normalize(),C.crossVectors(F,j);const B=C.dot(h[E])<0?-1:1;c[E*4]=L.x,c[E*4+1]=L.y,c[E*4+2]=L.z,c[E*4+3]=B}for(let E=0,j=y.length;E<j;++E){const O=y[E],B=O.start,S=O.count;for(let b=B,v=B+S;b<v;b+=3)T(n[b+0]),T(n[b+1]),T(n[b+2])}}computeVertexNormals(){const t=this.index,e=this.getAttribute("position");if(e!==void 0){let n=this.getAttribute("normal");if(n===void 0)n=new le(new Float32Array(e.count*3),3),this.setAttribute("normal",n);else for(let m=0,p=n.count;m<p;m++)n.setXYZ(m,0,0,0);const r=new H,s=new H,o=new H,a=new H,c=new H,l=new H,h=new H,f=new H;if(t)for(let m=0,p=t.count;m<p;m+=3){const _=t.getX(m+0),x=t.getX(m+1),d=t.getX(m+2);r.fromBufferAttribute(e,_),s.fromBufferAttribute(e,x),o.fromBufferAttribute(e,d),h.subVectors(o,s),f.subVectors(r,s),h.cross(f),a.fromBufferAttribute(n,_),c.fromBufferAttribute(n,x),l.fromBufferAttribute(n,d),a.add(h),c.add(h),l.add(h),n.setXYZ(_,a.x,a.y,a.z),n.setXYZ(x,c.x,c.y,c.z),n.setXYZ(d,l.x,l.y,l.z)}else for(let m=0,p=e.count;m<p;m+=3)r.fromBufferAttribute(e,m+0),s.fromBufferAttribute(e,m+1),o.fromBufferAttribute(e,m+2),h.subVectors(o,s),f.subVectors(r,s),h.cross(f),n.setXYZ(m+0,h.x,h.y,h.z),n.setXYZ(m+1,h.x,h.y,h.z),n.setXYZ(m+2,h.x,h.y,h.z);this.normalizeNormals(),n.needsUpdate=!0}}normalizeNormals(){const t=this.attributes.normal;for(let e=0,n=t.count;e<n;e++)ve.fromBufferAttribute(t,e),ve.normalize(),t.setXYZ(e,ve.x,ve.y,ve.z)}toNonIndexed(){function t(a,c){const l=a.array,h=a.itemSize,f=a.normalized,m=new l.constructor(c.length*h);let p=0,_=0;for(let x=0,d=c.length;x<d;x++){a.isInterleavedBufferAttribute?p=c[x]*a.data.stride+a.offset:p=c[x]*h;for(let u=0;u<h;u++)m[_++]=l[p++]}return new le(m,h,f)}if(this.index===null)return console.warn("THREE.BufferGeometry.toNonIndexed(): BufferGeometry is already non-indexed."),this;const e=new Jt,n=this.index.array,r=this.attributes;for(const a in r){const c=r[a],l=t(c,n);e.setAttribute(a,l)}const s=this.morphAttributes;for(const a in s){const c=[],l=s[a];for(let h=0,f=l.length;h<f;h++){const m=l[h],p=t(m,n);c.push(p)}e.morphAttributes[a]=c}e.morphTargetsRelative=this.morphTargetsRelative;const o=this.groups;for(let a=0,c=o.length;a<c;a++){const l=o[a];e.addGroup(l.start,l.count,l.materialIndex)}return e}toJSON(){const t={metadata:{version:4.6,type:"BufferGeometry",generator:"BufferGeometry.toJSON"}};if(t.uuid=this.uuid,t.type=this.type,this.name!==""&&(t.name=this.name),Object.keys(this.userData).length>0&&(t.userData=this.userData),this.parameters!==void 0){const c=this.parameters;for(const l in c)c[l]!==void 0&&(t[l]=c[l]);return t}t.data={attributes:{}};const e=this.index;e!==null&&(t.data.index={type:e.array.constructor.name,array:Array.prototype.slice.call(e.array)});const n=this.attributes;for(const c in n){const l=n[c];t.data.attributes[c]=l.toJSON(t.data)}const r={};let s=!1;for(const c in this.morphAttributes){const l=this.morphAttributes[c],h=[];for(let f=0,m=l.length;f<m;f++){const p=l[f];h.push(p.toJSON(t.data))}h.length>0&&(r[c]=h,s=!0)}s&&(t.data.morphAttributes=r,t.data.morphTargetsRelative=this.morphTargetsRelative);const o=this.groups;o.length>0&&(t.data.groups=JSON.parse(JSON.stringify(o)));const a=this.boundingSphere;return a!==null&&(t.data.boundingSphere={center:a.center.toArray(),radius:a.radius}),t}clone(){return new this.constructor().copy(this)}copy(t){this.index=null,this.attributes={},this.morphAttributes={},this.groups=[],this.boundingBox=null,this.boundingSphere=null;const e={};this.name=t.name;const n=t.index;n!==null&&this.setIndex(n.clone(e));const r=t.attributes;for(const l in r){const h=r[l];this.setAttribute(l,h.clone(e))}const s=t.morphAttributes;for(const l in s){const h=[],f=s[l];for(let m=0,p=f.length;m<p;m++)h.push(f[m].clone(e));this.morphAttributes[l]=h}this.morphTargetsRelative=t.morphTargetsRelative;const o=t.groups;for(let l=0,h=o.length;l<h;l++){const f=o[l];this.addGroup(f.start,f.count,f.materialIndex)}const a=t.boundingBox;a!==null&&(this.boundingBox=a.clone());const c=t.boundingSphere;return c!==null&&(this.boundingSphere=c.clone()),this.drawRange.start=t.drawRange.start,this.drawRange.count=t.drawRange.count,this.userData=t.userData,this}dispose(){this.dispatchEvent({type:"dispose"})}}const ma=new ee,In=new Hn,hr=new Wn,ga=new H,si=new H,oi=new H,ai=new H,ys=new H,dr=new H,fr=new At,pr=new At,mr=new At,_a=new H,va=new H,xa=new H,gr=new H,_r=new H;class Bt extends ae{constructor(t=new Jt,e=new De){super(),this.isMesh=!0,this.type="Mesh",this.geometry=t,this.material=e,this.updateMorphTargets()}copy(t,e){return super.copy(t,e),t.morphTargetInfluences!==void 0&&(this.morphTargetInfluences=t.morphTargetInfluences.slice()),t.morphTargetDictionary!==void 0&&(this.morphTargetDictionary=Object.assign({},t.morphTargetDictionary)),this.material=Array.isArray(t.material)?t.material.slice():t.material,this.geometry=t.geometry,this}updateMorphTargets(){const e=this.geometry.morphAttributes,n=Object.keys(e);if(n.length>0){const r=e[n[0]];if(r!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let s=0,o=r.length;s<o;s++){const a=r[s].name||String(s);this.morphTargetInfluences.push(0),this.morphTargetDictionary[a]=s}}}}getVertexPosition(t,e){const n=this.geometry,r=n.attributes.position,s=n.morphAttributes.position,o=n.morphTargetsRelative;e.fromBufferAttribute(r,t);const a=this.morphTargetInfluences;if(s&&a){dr.set(0,0,0);for(let c=0,l=s.length;c<l;c++){const h=a[c],f=s[c];h!==0&&(ys.fromBufferAttribute(f,t),o?dr.addScaledVector(ys,h):dr.addScaledVector(ys.sub(e),h))}e.add(dr)}return e}raycast(t,e){const n=this.geometry,r=this.material,s=this.matrixWorld;r!==void 0&&(n.boundingSphere===null&&n.computeBoundingSphere(),hr.copy(n.boundingSphere),hr.applyMatrix4(s),In.copy(t.ray).recast(t.near),!(hr.containsPoint(In.origin)===!1&&(In.intersectSphere(hr,ga)===null||In.origin.distanceToSquared(ga)>(t.far-t.near)**2))&&(ma.copy(s).invert(),In.copy(t.ray).applyMatrix4(ma),!(n.boundingBox!==null&&In.intersectsBox(n.boundingBox)===!1)&&this._computeIntersections(t,e,In)))}_computeIntersections(t,e,n){let r;const s=this.geometry,o=this.material,a=s.index,c=s.attributes.position,l=s.attributes.uv,h=s.attributes.uv1,f=s.attributes.normal,m=s.groups,p=s.drawRange;if(a!==null)if(Array.isArray(o))for(let _=0,x=m.length;_<x;_++){const d=m[_],u=o[d.materialIndex],M=Math.max(d.start,p.start),g=Math.min(a.count,Math.min(d.start+d.count,p.start+p.count));for(let y=M,L=g;y<L;y+=3){const C=a.getX(y),D=a.getX(y+1),F=a.getX(y+2);r=vr(this,u,t,n,l,h,f,C,D,F),r&&(r.faceIndex=Math.floor(y/3),r.face.materialIndex=d.materialIndex,e.push(r))}}else{const _=Math.max(0,p.start),x=Math.min(a.count,p.start+p.count);for(let d=_,u=x;d<u;d+=3){const M=a.getX(d),g=a.getX(d+1),y=a.getX(d+2);r=vr(this,o,t,n,l,h,f,M,g,y),r&&(r.faceIndex=Math.floor(d/3),e.push(r))}}else if(c!==void 0)if(Array.isArray(o))for(let _=0,x=m.length;_<x;_++){const d=m[_],u=o[d.materialIndex],M=Math.max(d.start,p.start),g=Math.min(c.count,Math.min(d.start+d.count,p.start+p.count));for(let y=M,L=g;y<L;y+=3){const C=y,D=y+1,F=y+2;r=vr(this,u,t,n,l,h,f,C,D,F),r&&(r.faceIndex=Math.floor(y/3),r.face.materialIndex=d.materialIndex,e.push(r))}}else{const _=Math.max(0,p.start),x=Math.min(c.count,p.start+p.count);for(let d=_,u=x;d<u;d+=3){const M=d,g=d+1,y=d+2;r=vr(this,o,t,n,l,h,f,M,g,y),r&&(r.faceIndex=Math.floor(d/3),e.push(r))}}}}function Hu(i,t,e,n,r,s,o,a){let c;if(t.side===Me?c=n.intersectTriangle(o,s,r,!0,a):c=n.intersectTriangle(r,s,o,t.side===pn,a),c===null)return null;_r.copy(a),_r.applyMatrix4(i.matrixWorld);const l=e.ray.origin.distanceTo(_r);return l<e.near||l>e.far?null:{distance:l,point:_r.clone(),object:i}}function vr(i,t,e,n,r,s,o,a,c,l){i.getVertexPosition(a,si),i.getVertexPosition(c,oi),i.getVertexPosition(l,ai);const h=Hu(i,t,e,n,si,oi,ai,gr);if(h){r&&(fr.fromBufferAttribute(r,a),pr.fromBufferAttribute(r,c),mr.fromBufferAttribute(r,l),h.uv=Oe.getInterpolation(gr,si,oi,ai,fr,pr,mr,new At)),s&&(fr.fromBufferAttribute(s,a),pr.fromBufferAttribute(s,c),mr.fromBufferAttribute(s,l),h.uv1=Oe.getInterpolation(gr,si,oi,ai,fr,pr,mr,new At),h.uv2=h.uv1),o&&(_a.fromBufferAttribute(o,a),va.fromBufferAttribute(o,c),xa.fromBufferAttribute(o,l),h.normal=Oe.getInterpolation(gr,si,oi,ai,_a,va,xa,new H),h.normal.dot(n.direction)>0&&h.normal.multiplyScalar(-1));const f={a,b:c,c:l,normal:new H,materialIndex:0};Oe.getNormal(si,oi,ai,f.normal),h.face=f}return h}class $e extends Jt{constructor(t=1,e=1,n=1,r=1,s=1,o=1){super(),this.type="BoxGeometry",this.parameters={width:t,height:e,depth:n,widthSegments:r,heightSegments:s,depthSegments:o};const a=this;r=Math.floor(r),s=Math.floor(s),o=Math.floor(o);const c=[],l=[],h=[],f=[];let m=0,p=0;_("z","y","x",-1,-1,n,e,t,o,s,0),_("z","y","x",1,-1,n,e,-t,o,s,1),_("x","z","y",1,1,t,n,e,r,o,2),_("x","z","y",1,-1,t,n,-e,r,o,3),_("x","y","z",1,-1,t,e,n,r,s,4),_("x","y","z",-1,-1,t,e,-n,r,s,5),this.setIndex(c),this.setAttribute("position",new Nt(l,3)),this.setAttribute("normal",new Nt(h,3)),this.setAttribute("uv",new Nt(f,2));function _(x,d,u,M,g,y,L,C,D,F,T){const E=y/D,j=L/F,O=y/2,B=L/2,S=C/2,b=D+1,v=F+1;let A=0,I=0;const U=new H;for(let P=0;P<v;P++){const N=P*j-B;for(let Y=0;Y<b;Y++){const Z=Y*E-O;U[x]=Z*M,U[d]=N*g,U[u]=S,l.push(U.x,U.y,U.z),U[x]=0,U[d]=0,U[u]=C>0?1:-1,h.push(U.x,U.y,U.z),f.push(Y/D),f.push(1-P/F),A+=1}}for(let P=0;P<F;P++)for(let N=0;N<D;N++){const Y=m+N+b*P,Z=m+N+b*(P+1),nt=m+(N+1)+b*(P+1),ht=m+(N+1)+b*P;c.push(Y,Z,ht),c.push(Z,nt,ht),I+=6}a.addGroup(p,I,T),p+=I,m+=A}}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new $e(t.width,t.height,t.depth,t.widthSegments,t.heightSegments,t.depthSegments)}}function wi(i){const t={};for(const e in i){t[e]={};for(const n in i[e]){const r=i[e][n];r&&(r.isColor||r.isMatrix3||r.isMatrix4||r.isVector2||r.isVector3||r.isVector4||r.isTexture||r.isQuaternion)?r.isRenderTargetTexture?(console.warn("UniformsUtils: Textures of render targets cannot be cloned via cloneUniforms() or mergeUniforms()."),t[e][n]=null):t[e][n]=r.clone():Array.isArray(r)?t[e][n]=r.slice():t[e][n]=r}}return t}function Pe(i){const t={};for(let e=0;e<i.length;e++){const n=wi(i[e]);for(const r in n)t[r]=n[r]}return t}function Vu(i){const t=[];for(let e=0;e<i.length;e++)t.push(i[e].clone());return t}function zc(i){return i.getRenderTarget()===null?i.outputColorSpace:te.workingColorSpace}const ji={clone:wi,merge:Pe};var Xu=`void main() {
	gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}`,Wu=`void main() {
	gl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );
}`;class we extends Rn{constructor(t){super(),this.isShaderMaterial=!0,this.type="ShaderMaterial",this.defines={},this.uniforms={},this.uniformsGroups=[],this.vertexShader=Xu,this.fragmentShader=Wu,this.linewidth=1,this.wireframe=!1,this.wireframeLinewidth=1,this.fog=!1,this.lights=!1,this.clipping=!1,this.forceSinglePass=!0,this.extensions={derivatives:!1,fragDepth:!1,drawBuffers:!1,shaderTextureLOD:!1,clipCullDistance:!1},this.defaultAttributeValues={color:[1,1,1],uv:[0,0],uv1:[0,0]},this.index0AttributeName=void 0,this.uniformsNeedUpdate=!1,this.glslVersion=null,t!==void 0&&this.setValues(t)}copy(t){return super.copy(t),this.fragmentShader=t.fragmentShader,this.vertexShader=t.vertexShader,this.uniforms=wi(t.uniforms),this.uniformsGroups=Vu(t.uniformsGroups),this.defines=Object.assign({},t.defines),this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this.fog=t.fog,this.lights=t.lights,this.clipping=t.clipping,this.extensions=Object.assign({},t.extensions),this.glslVersion=t.glslVersion,this}toJSON(t){const e=super.toJSON(t);e.glslVersion=this.glslVersion,e.uniforms={};for(const r in this.uniforms){const o=this.uniforms[r].value;o&&o.isTexture?e.uniforms[r]={type:"t",value:o.toJSON(t).uuid}:o&&o.isColor?e.uniforms[r]={type:"c",value:o.getHex()}:o&&o.isVector2?e.uniforms[r]={type:"v2",value:o.toArray()}:o&&o.isVector3?e.uniforms[r]={type:"v3",value:o.toArray()}:o&&o.isVector4?e.uniforms[r]={type:"v4",value:o.toArray()}:o&&o.isMatrix3?e.uniforms[r]={type:"m3",value:o.toArray()}:o&&o.isMatrix4?e.uniforms[r]={type:"m4",value:o.toArray()}:e.uniforms[r]={value:o}}Object.keys(this.defines).length>0&&(e.defines=this.defines),e.vertexShader=this.vertexShader,e.fragmentShader=this.fragmentShader,e.lights=this.lights,e.clipping=this.clipping;const n={};for(const r in this.extensions)this.extensions[r]===!0&&(n[r]=!0);return Object.keys(n).length>0&&(e.extensions=n),e}}class Gc extends ae{constructor(){super(),this.isCamera=!0,this.type="Camera",this.matrixWorldInverse=new ee,this.projectionMatrix=new ee,this.projectionMatrixInverse=new ee,this.coordinateSystem=un}copy(t,e){return super.copy(t,e),this.matrixWorldInverse.copy(t.matrixWorldInverse),this.projectionMatrix.copy(t.projectionMatrix),this.projectionMatrixInverse.copy(t.projectionMatrixInverse),this.coordinateSystem=t.coordinateSystem,this}getWorldDirection(t){return super.getWorldDirection(t).negate()}updateMatrixWorld(t){super.updateMatrixWorld(t),this.matrixWorldInverse.copy(this.matrixWorld).invert()}updateWorldMatrix(t,e){super.updateWorldMatrix(t,e),this.matrixWorldInverse.copy(this.matrixWorld).invert()}clone(){return new this.constructor().copy(this)}}class Fe extends Gc{constructor(t=50,e=1,n=.1,r=2e3){super(),this.isPerspectiveCamera=!0,this.type="PerspectiveCamera",this.fov=t,this.zoom=1,this.near=n,this.far=r,this.focus=10,this.aspect=e,this.view=null,this.filmGauge=35,this.filmOffset=0,this.updateProjectionMatrix()}copy(t,e){return super.copy(t,e),this.fov=t.fov,this.zoom=t.zoom,this.near=t.near,this.far=t.far,this.focus=t.focus,this.aspect=t.aspect,this.view=t.view===null?null:Object.assign({},t.view),this.filmGauge=t.filmGauge,this.filmOffset=t.filmOffset,this}setFocalLength(t){const e=.5*this.getFilmHeight()/t;this.fov=Yi*2*Math.atan(e),this.updateProjectionMatrix()}getFocalLength(){const t=Math.tan(ki*.5*this.fov);return .5*this.getFilmHeight()/t}getEffectiveFOV(){return Yi*2*Math.atan(Math.tan(ki*.5*this.fov)/this.zoom)}getFilmWidth(){return this.filmGauge*Math.min(this.aspect,1)}getFilmHeight(){return this.filmGauge/Math.max(this.aspect,1)}setViewOffset(t,e,n,r,s,o){this.aspect=t/e,this.view===null&&(this.view={enabled:!0,fullWidth:1,fullHeight:1,offsetX:0,offsetY:0,width:1,height:1}),this.view.enabled=!0,this.view.fullWidth=t,this.view.fullHeight=e,this.view.offsetX=n,this.view.offsetY=r,this.view.width=s,this.view.height=o,this.updateProjectionMatrix()}clearViewOffset(){this.view!==null&&(this.view.enabled=!1),this.updateProjectionMatrix()}updateProjectionMatrix(){const t=this.near;let e=t*Math.tan(ki*.5*this.fov)/this.zoom,n=2*e,r=this.aspect*n,s=-.5*r;const o=this.view;if(this.view!==null&&this.view.enabled){const c=o.fullWidth,l=o.fullHeight;s+=o.offsetX*r/c,e-=o.offsetY*n/l,r*=o.width/c,n*=o.height/l}const a=this.filmOffset;a!==0&&(s+=t*a/this.getFilmWidth()),this.projectionMatrix.makePerspective(s,s+r,e,e-n,t,this.far,this.coordinateSystem),this.projectionMatrixInverse.copy(this.projectionMatrix).invert()}toJSON(t){const e=super.toJSON(t);return e.object.fov=this.fov,e.object.zoom=this.zoom,e.object.near=this.near,e.object.far=this.far,e.object.focus=this.focus,e.object.aspect=this.aspect,this.view!==null&&(e.object.view=Object.assign({},this.view)),e.object.filmGauge=this.filmGauge,e.object.filmOffset=this.filmOffset,e}}const ci=-90,li=1;class qu extends ae{constructor(t,e,n){super(),this.type="CubeCamera",this.renderTarget=n,this.coordinateSystem=null,this.activeMipmapLevel=0;const r=new Fe(ci,li,t,e);r.layers=this.layers,this.add(r);const s=new Fe(ci,li,t,e);s.layers=this.layers,this.add(s);const o=new Fe(ci,li,t,e);o.layers=this.layers,this.add(o);const a=new Fe(ci,li,t,e);a.layers=this.layers,this.add(a);const c=new Fe(ci,li,t,e);c.layers=this.layers,this.add(c);const l=new Fe(ci,li,t,e);l.layers=this.layers,this.add(l)}updateCoordinateSystem(){const t=this.coordinateSystem,e=this.children.concat(),[n,r,s,o,a,c]=e;for(const l of e)this.remove(l);if(t===un)n.up.set(0,1,0),n.lookAt(1,0,0),r.up.set(0,1,0),r.lookAt(-1,0,0),s.up.set(0,0,-1),s.lookAt(0,1,0),o.up.set(0,0,1),o.lookAt(0,-1,0),a.up.set(0,1,0),a.lookAt(0,0,1),c.up.set(0,1,0),c.lookAt(0,0,-1);else if(t===zr)n.up.set(0,-1,0),n.lookAt(-1,0,0),r.up.set(0,-1,0),r.lookAt(1,0,0),s.up.set(0,0,1),s.lookAt(0,1,0),o.up.set(0,0,-1),o.lookAt(0,-1,0),a.up.set(0,-1,0),a.lookAt(0,0,1),c.up.set(0,-1,0),c.lookAt(0,0,-1);else throw new Error("THREE.CubeCamera.updateCoordinateSystem(): Invalid coordinate system: "+t);for(const l of e)this.add(l),l.updateMatrixWorld()}update(t,e){this.parent===null&&this.updateMatrixWorld();const{renderTarget:n,activeMipmapLevel:r}=this;this.coordinateSystem!==t.coordinateSystem&&(this.coordinateSystem=t.coordinateSystem,this.updateCoordinateSystem());const[s,o,a,c,l,h]=this.children,f=t.getRenderTarget(),m=t.getActiveCubeFace(),p=t.getActiveMipmapLevel(),_=t.xr.enabled;t.xr.enabled=!1;const x=n.texture.generateMipmaps;n.texture.generateMipmaps=!1,t.setRenderTarget(n,0,r),t.render(e,s),t.setRenderTarget(n,1,r),t.render(e,o),t.setRenderTarget(n,2,r),t.render(e,a),t.setRenderTarget(n,3,r),t.render(e,c),t.setRenderTarget(n,4,r),t.render(e,l),n.texture.generateMipmaps=x,t.setRenderTarget(n,5,r),t.render(e,h),t.setRenderTarget(f,m,p),t.xr.enabled=_,n.texture.needsPMREMUpdate=!0}}class kc extends Te{constructor(t,e,n,r,s,o,a,c,l,h){t=t!==void 0?t:[],e=e!==void 0?e:yi,super(t,e,n,r,s,o,a,c,l,h),this.isCubeTexture=!0,this.flipY=!1}get images(){return this.image}set images(t){this.image=t}}class Yu extends Ke{constructor(t=1,e={}){super(t,t,e),this.isWebGLCubeRenderTarget=!0;const n={width:t,height:t,depth:1},r=[n,n,n,n,n,n];e.encoding!==void 0&&(Vi("THREE.WebGLCubeRenderTarget: option.encoding has been replaced by option.colorSpace."),e.colorSpace=e.encoding===kn?he:Xe),this.texture=new kc(r,e.mapping,e.wrapS,e.wrapT,e.magFilter,e.minFilter,e.format,e.type,e.anisotropy,e.colorSpace),this.texture.isRenderTargetTexture=!0,this.texture.generateMipmaps=e.generateMipmaps!==void 0?e.generateMipmaps:!1,this.texture.minFilter=e.minFilter!==void 0?e.minFilter:He}fromEquirectangularTexture(t,e){this.texture.type=e.type,this.texture.colorSpace=e.colorSpace,this.texture.generateMipmaps=e.generateMipmaps,this.texture.minFilter=e.minFilter,this.texture.magFilter=e.magFilter;const n={uniforms:{tEquirect:{value:null}},vertexShader:`

				varying vec3 vWorldDirection;

				vec3 transformDirection( in vec3 dir, in mat4 matrix ) {

					return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );

				}

				void main() {

					vWorldDirection = transformDirection( position, modelMatrix );

					#include <begin_vertex>
					#include <project_vertex>

				}
			`,fragmentShader:`

				uniform sampler2D tEquirect;

				varying vec3 vWorldDirection;

				#include <common>

				void main() {

					vec3 direction = normalize( vWorldDirection );

					vec2 sampleUV = equirectUv( direction );

					gl_FragColor = texture2D( tEquirect, sampleUV );

				}
			`},r=new $e(5,5,5),s=new we({name:"CubemapFromEquirect",uniforms:wi(n.uniforms),vertexShader:n.vertexShader,fragmentShader:n.fragmentShader,side:Me,blending:hn});s.uniforms.tEquirect.value=e;const o=new Bt(r,s),a=e.minFilter;return e.minFilter===qi&&(e.minFilter=He),new qu(1,10,this).update(t,o),e.minFilter=a,o.geometry.dispose(),o.material.dispose(),this}clear(t,e,n,r){const s=t.getRenderTarget();for(let o=0;o<6;o++)t.setRenderTarget(this,o),t.clear(e,n,r);t.setRenderTarget(s)}}const Ss=new H,ju=new H,$u=new Kt;class Sn{constructor(t=new H(1,0,0),e=0){this.isPlane=!0,this.normal=t,this.constant=e}set(t,e){return this.normal.copy(t),this.constant=e,this}setComponents(t,e,n,r){return this.normal.set(t,e,n),this.constant=r,this}setFromNormalAndCoplanarPoint(t,e){return this.normal.copy(t),this.constant=-e.dot(this.normal),this}setFromCoplanarPoints(t,e,n){const r=Ss.subVectors(n,e).cross(ju.subVectors(t,e)).normalize();return this.setFromNormalAndCoplanarPoint(r,t),this}copy(t){return this.normal.copy(t.normal),this.constant=t.constant,this}normalize(){const t=1/this.normal.length();return this.normal.multiplyScalar(t),this.constant*=t,this}negate(){return this.constant*=-1,this.normal.negate(),this}distanceToPoint(t){return this.normal.dot(t)+this.constant}distanceToSphere(t){return this.distanceToPoint(t.center)-t.radius}projectPoint(t,e){return e.copy(t).addScaledVector(this.normal,-this.distanceToPoint(t))}intersectLine(t,e){const n=t.delta(Ss),r=this.normal.dot(n);if(r===0)return this.distanceToPoint(t.start)===0?e.copy(t.start):null;const s=-(t.start.dot(this.normal)+this.constant)/r;return s<0||s>1?null:e.copy(t.start).addScaledVector(n,s)}intersectsLine(t){const e=this.distanceToPoint(t.start),n=this.distanceToPoint(t.end);return e<0&&n>0||n<0&&e>0}intersectsBox(t){return t.intersectsPlane(this)}intersectsSphere(t){return t.intersectsPlane(this)}coplanarPoint(t){return t.copy(this.normal).multiplyScalar(-this.constant)}applyMatrix4(t,e){const n=e||$u.getNormalMatrix(t),r=this.coplanarPoint(Ss).applyMatrix4(t),s=this.normal.applyMatrix3(n).normalize();return this.constant=-r.dot(s),this}translate(t){return this.constant-=t.dot(this.normal),this}equals(t){return t.normal.equals(this.normal)&&t.constant===this.constant}clone(){return new this.constructor().copy(this)}}const Un=new Wn,xr=new H;class so{constructor(t=new Sn,e=new Sn,n=new Sn,r=new Sn,s=new Sn,o=new Sn){this.planes=[t,e,n,r,s,o]}set(t,e,n,r,s,o){const a=this.planes;return a[0].copy(t),a[1].copy(e),a[2].copy(n),a[3].copy(r),a[4].copy(s),a[5].copy(o),this}copy(t){const e=this.planes;for(let n=0;n<6;n++)e[n].copy(t.planes[n]);return this}setFromProjectionMatrix(t,e=un){const n=this.planes,r=t.elements,s=r[0],o=r[1],a=r[2],c=r[3],l=r[4],h=r[5],f=r[6],m=r[7],p=r[8],_=r[9],x=r[10],d=r[11],u=r[12],M=r[13],g=r[14],y=r[15];if(n[0].setComponents(c-s,m-l,d-p,y-u).normalize(),n[1].setComponents(c+s,m+l,d+p,y+u).normalize(),n[2].setComponents(c+o,m+h,d+_,y+M).normalize(),n[3].setComponents(c-o,m-h,d-_,y-M).normalize(),n[4].setComponents(c-a,m-f,d-x,y-g).normalize(),e===un)n[5].setComponents(c+a,m+f,d+x,y+g).normalize();else if(e===zr)n[5].setComponents(a,f,x,g).normalize();else throw new Error("THREE.Frustum.setFromProjectionMatrix(): Invalid coordinate system: "+e);return this}intersectsObject(t){if(t.boundingSphere!==void 0)t.boundingSphere===null&&t.computeBoundingSphere(),Un.copy(t.boundingSphere).applyMatrix4(t.matrixWorld);else{const e=t.geometry;e.boundingSphere===null&&e.computeBoundingSphere(),Un.copy(e.boundingSphere).applyMatrix4(t.matrixWorld)}return this.intersectsSphere(Un)}intersectsSprite(t){return Un.center.set(0,0,0),Un.radius=.7071067811865476,Un.applyMatrix4(t.matrixWorld),this.intersectsSphere(Un)}intersectsSphere(t){const e=this.planes,n=t.center,r=-t.radius;for(let s=0;s<6;s++)if(e[s].distanceToPoint(n)<r)return!1;return!0}intersectsBox(t){const e=this.planes;for(let n=0;n<6;n++){const r=e[n];if(xr.x=r.normal.x>0?t.max.x:t.min.x,xr.y=r.normal.y>0?t.max.y:t.min.y,xr.z=r.normal.z>0?t.max.z:t.min.z,r.distanceToPoint(xr)<0)return!1}return!0}containsPoint(t){const e=this.planes;for(let n=0;n<6;n++)if(e[n].distanceToPoint(t)<0)return!1;return!0}clone(){return new this.constructor().copy(this)}}function Hc(){let i=null,t=!1,e=null,n=null;function r(s,o){e(s,o),n=i.requestAnimationFrame(r)}return{start:function(){t!==!0&&e!==null&&(n=i.requestAnimationFrame(r),t=!0)},stop:function(){i.cancelAnimationFrame(n),t=!1},setAnimationLoop:function(s){e=s},setContext:function(s){i=s}}}function Ku(i,t){const e=t.isWebGL2,n=new WeakMap;function r(l,h){const f=l.array,m=l.usage,p=f.byteLength,_=i.createBuffer();i.bindBuffer(h,_),i.bufferData(h,f,m),l.onUploadCallback();let x;if(f instanceof Float32Array)x=i.FLOAT;else if(f instanceof Uint16Array)if(l.isFloat16BufferAttribute)if(e)x=i.HALF_FLOAT;else throw new Error("THREE.WebGLAttributes: Usage of Float16BufferAttribute requires WebGL2.");else x=i.UNSIGNED_SHORT;else if(f instanceof Int16Array)x=i.SHORT;else if(f instanceof Uint32Array)x=i.UNSIGNED_INT;else if(f instanceof Int32Array)x=i.INT;else if(f instanceof Int8Array)x=i.BYTE;else if(f instanceof Uint8Array)x=i.UNSIGNED_BYTE;else if(f instanceof Uint8ClampedArray)x=i.UNSIGNED_BYTE;else throw new Error("THREE.WebGLAttributes: Unsupported buffer data format: "+f);return{buffer:_,type:x,bytesPerElement:f.BYTES_PER_ELEMENT,version:l.version,size:p}}function s(l,h,f){const m=h.array,p=h._updateRange,_=h.updateRanges;if(i.bindBuffer(f,l),p.count===-1&&_.length===0&&i.bufferSubData(f,0,m),_.length!==0){for(let x=0,d=_.length;x<d;x++){const u=_[x];e?i.bufferSubData(f,u.start*m.BYTES_PER_ELEMENT,m,u.start,u.count):i.bufferSubData(f,u.start*m.BYTES_PER_ELEMENT,m.subarray(u.start,u.start+u.count))}h.clearUpdateRanges()}p.count!==-1&&(e?i.bufferSubData(f,p.offset*m.BYTES_PER_ELEMENT,m,p.offset,p.count):i.bufferSubData(f,p.offset*m.BYTES_PER_ELEMENT,m.subarray(p.offset,p.offset+p.count)),p.count=-1),h.onUploadCallback()}function o(l){return l.isInterleavedBufferAttribute&&(l=l.data),n.get(l)}function a(l){l.isInterleavedBufferAttribute&&(l=l.data);const h=n.get(l);h&&(i.deleteBuffer(h.buffer),n.delete(l))}function c(l,h){if(l.isGLBufferAttribute){const m=n.get(l);(!m||m.version<l.version)&&n.set(l,{buffer:l.buffer,type:l.type,bytesPerElement:l.elementSize,version:l.version});return}l.isInterleavedBufferAttribute&&(l=l.data);const f=n.get(l);if(f===void 0)n.set(l,r(l,h));else if(f.version<l.version){if(f.size!==l.array.byteLength)throw new Error("THREE.WebGLAttributes: The size of the buffer attribute's array buffer does not match the original size. Resizing buffer attributes is not supported.");s(f.buffer,l,h),f.version=l.version}}return{get:o,remove:a,update:c}}class qn extends Jt{constructor(t=1,e=1,n=1,r=1){super(),this.type="PlaneGeometry",this.parameters={width:t,height:e,widthSegments:n,heightSegments:r};const s=t/2,o=e/2,a=Math.floor(n),c=Math.floor(r),l=a+1,h=c+1,f=t/a,m=e/c,p=[],_=[],x=[],d=[];for(let u=0;u<h;u++){const M=u*m-o;for(let g=0;g<l;g++){const y=g*f-s;_.push(y,-M,0),x.push(0,0,1),d.push(g/a),d.push(1-u/c)}}for(let u=0;u<c;u++)for(let M=0;M<a;M++){const g=M+l*u,y=M+l*(u+1),L=M+1+l*(u+1),C=M+1+l*u;p.push(g,y,C),p.push(y,L,C)}this.setIndex(p),this.setAttribute("position",new Nt(_,3)),this.setAttribute("normal",new Nt(x,3)),this.setAttribute("uv",new Nt(d,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new qn(t.width,t.height,t.widthSegments,t.heightSegments)}}var Zu=`#ifdef USE_ALPHAHASH
	if ( diffuseColor.a < getAlphaHashThreshold( vPosition ) ) discard;
#endif`,Ju=`#ifdef USE_ALPHAHASH
	const float ALPHA_HASH_SCALE = 0.05;
	float hash2D( vec2 value ) {
		return fract( 1.0e4 * sin( 17.0 * value.x + 0.1 * value.y ) * ( 0.1 + abs( sin( 13.0 * value.y + value.x ) ) ) );
	}
	float hash3D( vec3 value ) {
		return hash2D( vec2( hash2D( value.xy ), value.z ) );
	}
	float getAlphaHashThreshold( vec3 position ) {
		float maxDeriv = max(
			length( dFdx( position.xyz ) ),
			length( dFdy( position.xyz ) )
		);
		float pixScale = 1.0 / ( ALPHA_HASH_SCALE * maxDeriv );
		vec2 pixScales = vec2(
			exp2( floor( log2( pixScale ) ) ),
			exp2( ceil( log2( pixScale ) ) )
		);
		vec2 alpha = vec2(
			hash3D( floor( pixScales.x * position.xyz ) ),
			hash3D( floor( pixScales.y * position.xyz ) )
		);
		float lerpFactor = fract( log2( pixScale ) );
		float x = ( 1.0 - lerpFactor ) * alpha.x + lerpFactor * alpha.y;
		float a = min( lerpFactor, 1.0 - lerpFactor );
		vec3 cases = vec3(
			x * x / ( 2.0 * a * ( 1.0 - a ) ),
			( x - 0.5 * a ) / ( 1.0 - a ),
			1.0 - ( ( 1.0 - x ) * ( 1.0 - x ) / ( 2.0 * a * ( 1.0 - a ) ) )
		);
		float threshold = ( x < ( 1.0 - a ) )
			? ( ( x < a ) ? cases.x : cases.y )
			: cases.z;
		return clamp( threshold , 1.0e-6, 1.0 );
	}
#endif`,Qu=`#ifdef USE_ALPHAMAP
	diffuseColor.a *= texture2D( alphaMap, vAlphaMapUv ).g;
#endif`,th=`#ifdef USE_ALPHAMAP
	uniform sampler2D alphaMap;
#endif`,eh=`#ifdef USE_ALPHATEST
	if ( diffuseColor.a < alphaTest ) discard;
#endif`,nh=`#ifdef USE_ALPHATEST
	uniform float alphaTest;
#endif`,ih=`#ifdef USE_AOMAP
	float ambientOcclusion = ( texture2D( aoMap, vAoMapUv ).r - 1.0 ) * aoMapIntensity + 1.0;
	reflectedLight.indirectDiffuse *= ambientOcclusion;
	#if defined( USE_CLEARCOAT ) 
		clearcoatSpecularIndirect *= ambientOcclusion;
	#endif
	#if defined( USE_SHEEN ) 
		sheenSpecularIndirect *= ambientOcclusion;
	#endif
	#if defined( USE_ENVMAP ) && defined( STANDARD )
		float dotNV = saturate( dot( geometryNormal, geometryViewDir ) );
		reflectedLight.indirectSpecular *= computeSpecularOcclusion( dotNV, ambientOcclusion, material.roughness );
	#endif
#endif`,rh=`#ifdef USE_AOMAP
	uniform sampler2D aoMap;
	uniform float aoMapIntensity;
#endif`,sh=`#ifdef USE_BATCHING
	attribute float batchId;
	uniform highp sampler2D batchingTexture;
	mat4 getBatchingMatrix( const in float i ) {
		int size = textureSize( batchingTexture, 0 ).x;
		int j = int( i ) * 4;
		int x = j % size;
		int y = j / size;
		vec4 v1 = texelFetch( batchingTexture, ivec2( x, y ), 0 );
		vec4 v2 = texelFetch( batchingTexture, ivec2( x + 1, y ), 0 );
		vec4 v3 = texelFetch( batchingTexture, ivec2( x + 2, y ), 0 );
		vec4 v4 = texelFetch( batchingTexture, ivec2( x + 3, y ), 0 );
		return mat4( v1, v2, v3, v4 );
	}
#endif`,oh=`#ifdef USE_BATCHING
	mat4 batchingMatrix = getBatchingMatrix( batchId );
#endif`,ah=`vec3 transformed = vec3( position );
#ifdef USE_ALPHAHASH
	vPosition = vec3( position );
#endif`,ch=`vec3 objectNormal = vec3( normal );
#ifdef USE_TANGENT
	vec3 objectTangent = vec3( tangent.xyz );
#endif`,lh=`float G_BlinnPhong_Implicit( ) {
	return 0.25;
}
float D_BlinnPhong( const in float shininess, const in float dotNH ) {
	return RECIPROCAL_PI * ( shininess * 0.5 + 1.0 ) * pow( dotNH, shininess );
}
vec3 BRDF_BlinnPhong( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in vec3 specularColor, const in float shininess ) {
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNH = saturate( dot( normal, halfDir ) );
	float dotVH = saturate( dot( viewDir, halfDir ) );
	vec3 F = F_Schlick( specularColor, 1.0, dotVH );
	float G = G_BlinnPhong_Implicit( );
	float D = D_BlinnPhong( shininess, dotNH );
	return F * ( G * D );
} // validated`,uh=`#ifdef USE_IRIDESCENCE
	const mat3 XYZ_TO_REC709 = mat3(
		 3.2404542, -0.9692660,  0.0556434,
		-1.5371385,  1.8760108, -0.2040259,
		-0.4985314,  0.0415560,  1.0572252
	);
	vec3 Fresnel0ToIor( vec3 fresnel0 ) {
		vec3 sqrtF0 = sqrt( fresnel0 );
		return ( vec3( 1.0 ) + sqrtF0 ) / ( vec3( 1.0 ) - sqrtF0 );
	}
	vec3 IorToFresnel0( vec3 transmittedIor, float incidentIor ) {
		return pow2( ( transmittedIor - vec3( incidentIor ) ) / ( transmittedIor + vec3( incidentIor ) ) );
	}
	float IorToFresnel0( float transmittedIor, float incidentIor ) {
		return pow2( ( transmittedIor - incidentIor ) / ( transmittedIor + incidentIor ));
	}
	vec3 evalSensitivity( float OPD, vec3 shift ) {
		float phase = 2.0 * PI * OPD * 1.0e-9;
		vec3 val = vec3( 5.4856e-13, 4.4201e-13, 5.2481e-13 );
		vec3 pos = vec3( 1.6810e+06, 1.7953e+06, 2.2084e+06 );
		vec3 var = vec3( 4.3278e+09, 9.3046e+09, 6.6121e+09 );
		vec3 xyz = val * sqrt( 2.0 * PI * var ) * cos( pos * phase + shift ) * exp( - pow2( phase ) * var );
		xyz.x += 9.7470e-14 * sqrt( 2.0 * PI * 4.5282e+09 ) * cos( 2.2399e+06 * phase + shift[ 0 ] ) * exp( - 4.5282e+09 * pow2( phase ) );
		xyz /= 1.0685e-7;
		vec3 rgb = XYZ_TO_REC709 * xyz;
		return rgb;
	}
	vec3 evalIridescence( float outsideIOR, float eta2, float cosTheta1, float thinFilmThickness, vec3 baseF0 ) {
		vec3 I;
		float iridescenceIOR = mix( outsideIOR, eta2, smoothstep( 0.0, 0.03, thinFilmThickness ) );
		float sinTheta2Sq = pow2( outsideIOR / iridescenceIOR ) * ( 1.0 - pow2( cosTheta1 ) );
		float cosTheta2Sq = 1.0 - sinTheta2Sq;
		if ( cosTheta2Sq < 0.0 ) {
			return vec3( 1.0 );
		}
		float cosTheta2 = sqrt( cosTheta2Sq );
		float R0 = IorToFresnel0( iridescenceIOR, outsideIOR );
		float R12 = F_Schlick( R0, 1.0, cosTheta1 );
		float T121 = 1.0 - R12;
		float phi12 = 0.0;
		if ( iridescenceIOR < outsideIOR ) phi12 = PI;
		float phi21 = PI - phi12;
		vec3 baseIOR = Fresnel0ToIor( clamp( baseF0, 0.0, 0.9999 ) );		vec3 R1 = IorToFresnel0( baseIOR, iridescenceIOR );
		vec3 R23 = F_Schlick( R1, 1.0, cosTheta2 );
		vec3 phi23 = vec3( 0.0 );
		if ( baseIOR[ 0 ] < iridescenceIOR ) phi23[ 0 ] = PI;
		if ( baseIOR[ 1 ] < iridescenceIOR ) phi23[ 1 ] = PI;
		if ( baseIOR[ 2 ] < iridescenceIOR ) phi23[ 2 ] = PI;
		float OPD = 2.0 * iridescenceIOR * thinFilmThickness * cosTheta2;
		vec3 phi = vec3( phi21 ) + phi23;
		vec3 R123 = clamp( R12 * R23, 1e-5, 0.9999 );
		vec3 r123 = sqrt( R123 );
		vec3 Rs = pow2( T121 ) * R23 / ( vec3( 1.0 ) - R123 );
		vec3 C0 = R12 + Rs;
		I = C0;
		vec3 Cm = Rs - T121;
		for ( int m = 1; m <= 2; ++ m ) {
			Cm *= r123;
			vec3 Sm = 2.0 * evalSensitivity( float( m ) * OPD, float( m ) * phi );
			I += Cm * Sm;
		}
		return max( I, vec3( 0.0 ) );
	}
#endif`,hh=`#ifdef USE_BUMPMAP
	uniform sampler2D bumpMap;
	uniform float bumpScale;
	vec2 dHdxy_fwd() {
		vec2 dSTdx = dFdx( vBumpMapUv );
		vec2 dSTdy = dFdy( vBumpMapUv );
		float Hll = bumpScale * texture2D( bumpMap, vBumpMapUv ).x;
		float dBx = bumpScale * texture2D( bumpMap, vBumpMapUv + dSTdx ).x - Hll;
		float dBy = bumpScale * texture2D( bumpMap, vBumpMapUv + dSTdy ).x - Hll;
		return vec2( dBx, dBy );
	}
	vec3 perturbNormalArb( vec3 surf_pos, vec3 surf_norm, vec2 dHdxy, float faceDirection ) {
		vec3 vSigmaX = normalize( dFdx( surf_pos.xyz ) );
		vec3 vSigmaY = normalize( dFdy( surf_pos.xyz ) );
		vec3 vN = surf_norm;
		vec3 R1 = cross( vSigmaY, vN );
		vec3 R2 = cross( vN, vSigmaX );
		float fDet = dot( vSigmaX, R1 ) * faceDirection;
		vec3 vGrad = sign( fDet ) * ( dHdxy.x * R1 + dHdxy.y * R2 );
		return normalize( abs( fDet ) * surf_norm - vGrad );
	}
#endif`,dh=`#if NUM_CLIPPING_PLANES > 0
	vec4 plane;
	#pragma unroll_loop_start
	for ( int i = 0; i < UNION_CLIPPING_PLANES; i ++ ) {
		plane = clippingPlanes[ i ];
		if ( dot( vClipPosition, plane.xyz ) > plane.w ) discard;
	}
	#pragma unroll_loop_end
	#if UNION_CLIPPING_PLANES < NUM_CLIPPING_PLANES
		bool clipped = true;
		#pragma unroll_loop_start
		for ( int i = UNION_CLIPPING_PLANES; i < NUM_CLIPPING_PLANES; i ++ ) {
			plane = clippingPlanes[ i ];
			clipped = ( dot( vClipPosition, plane.xyz ) > plane.w ) && clipped;
		}
		#pragma unroll_loop_end
		if ( clipped ) discard;
	#endif
#endif`,fh=`#if NUM_CLIPPING_PLANES > 0
	varying vec3 vClipPosition;
	uniform vec4 clippingPlanes[ NUM_CLIPPING_PLANES ];
#endif`,ph=`#if NUM_CLIPPING_PLANES > 0
	varying vec3 vClipPosition;
#endif`,mh=`#if NUM_CLIPPING_PLANES > 0
	vClipPosition = - mvPosition.xyz;
#endif`,gh=`#if defined( USE_COLOR_ALPHA )
	diffuseColor *= vColor;
#elif defined( USE_COLOR )
	diffuseColor.rgb *= vColor;
#endif`,_h=`#if defined( USE_COLOR_ALPHA )
	varying vec4 vColor;
#elif defined( USE_COLOR )
	varying vec3 vColor;
#endif`,vh=`#if defined( USE_COLOR_ALPHA )
	varying vec4 vColor;
#elif defined( USE_COLOR ) || defined( USE_INSTANCING_COLOR )
	varying vec3 vColor;
#endif`,xh=`#if defined( USE_COLOR_ALPHA )
	vColor = vec4( 1.0 );
#elif defined( USE_COLOR ) || defined( USE_INSTANCING_COLOR )
	vColor = vec3( 1.0 );
#endif
#ifdef USE_COLOR
	vColor *= color;
#endif
#ifdef USE_INSTANCING_COLOR
	vColor.xyz *= instanceColor.xyz;
#endif`,Mh=`#define PI 3.141592653589793
#define PI2 6.283185307179586
#define PI_HALF 1.5707963267948966
#define RECIPROCAL_PI 0.3183098861837907
#define RECIPROCAL_PI2 0.15915494309189535
#define EPSILON 1e-6
#ifndef saturate
#define saturate( a ) clamp( a, 0.0, 1.0 )
#endif
#define whiteComplement( a ) ( 1.0 - saturate( a ) )
float pow2( const in float x ) { return x*x; }
vec3 pow2( const in vec3 x ) { return x*x; }
float pow3( const in float x ) { return x*x*x; }
float pow4( const in float x ) { float x2 = x*x; return x2*x2; }
float max3( const in vec3 v ) { return max( max( v.x, v.y ), v.z ); }
float average( const in vec3 v ) { return dot( v, vec3( 0.3333333 ) ); }
highp float rand( const in vec2 uv ) {
	const highp float a = 12.9898, b = 78.233, c = 43758.5453;
	highp float dt = dot( uv.xy, vec2( a,b ) ), sn = mod( dt, PI );
	return fract( sin( sn ) * c );
}
#ifdef HIGH_PRECISION
	float precisionSafeLength( vec3 v ) { return length( v ); }
#else
	float precisionSafeLength( vec3 v ) {
		float maxComponent = max3( abs( v ) );
		return length( v / maxComponent ) * maxComponent;
	}
#endif
struct IncidentLight {
	vec3 color;
	vec3 direction;
	bool visible;
};
struct ReflectedLight {
	vec3 directDiffuse;
	vec3 directSpecular;
	vec3 indirectDiffuse;
	vec3 indirectSpecular;
};
#ifdef USE_ALPHAHASH
	varying vec3 vPosition;
#endif
vec3 transformDirection( in vec3 dir, in mat4 matrix ) {
	return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );
}
vec3 inverseTransformDirection( in vec3 dir, in mat4 matrix ) {
	return normalize( ( vec4( dir, 0.0 ) * matrix ).xyz );
}
mat3 transposeMat3( const in mat3 m ) {
	mat3 tmp;
	tmp[ 0 ] = vec3( m[ 0 ].x, m[ 1 ].x, m[ 2 ].x );
	tmp[ 1 ] = vec3( m[ 0 ].y, m[ 1 ].y, m[ 2 ].y );
	tmp[ 2 ] = vec3( m[ 0 ].z, m[ 1 ].z, m[ 2 ].z );
	return tmp;
}
float luminance( const in vec3 rgb ) {
	const vec3 weights = vec3( 0.2126729, 0.7151522, 0.0721750 );
	return dot( weights, rgb );
}
bool isPerspectiveMatrix( mat4 m ) {
	return m[ 2 ][ 3 ] == - 1.0;
}
vec2 equirectUv( in vec3 dir ) {
	float u = atan( dir.z, dir.x ) * RECIPROCAL_PI2 + 0.5;
	float v = asin( clamp( dir.y, - 1.0, 1.0 ) ) * RECIPROCAL_PI + 0.5;
	return vec2( u, v );
}
vec3 BRDF_Lambert( const in vec3 diffuseColor ) {
	return RECIPROCAL_PI * diffuseColor;
}
vec3 F_Schlick( const in vec3 f0, const in float f90, const in float dotVH ) {
	float fresnel = exp2( ( - 5.55473 * dotVH - 6.98316 ) * dotVH );
	return f0 * ( 1.0 - fresnel ) + ( f90 * fresnel );
}
float F_Schlick( const in float f0, const in float f90, const in float dotVH ) {
	float fresnel = exp2( ( - 5.55473 * dotVH - 6.98316 ) * dotVH );
	return f0 * ( 1.0 - fresnel ) + ( f90 * fresnel );
} // validated`,yh=`#ifdef ENVMAP_TYPE_CUBE_UV
	#define cubeUV_minMipLevel 4.0
	#define cubeUV_minTileSize 16.0
	float getFace( vec3 direction ) {
		vec3 absDirection = abs( direction );
		float face = - 1.0;
		if ( absDirection.x > absDirection.z ) {
			if ( absDirection.x > absDirection.y )
				face = direction.x > 0.0 ? 0.0 : 3.0;
			else
				face = direction.y > 0.0 ? 1.0 : 4.0;
		} else {
			if ( absDirection.z > absDirection.y )
				face = direction.z > 0.0 ? 2.0 : 5.0;
			else
				face = direction.y > 0.0 ? 1.0 : 4.0;
		}
		return face;
	}
	vec2 getUV( vec3 direction, float face ) {
		vec2 uv;
		if ( face == 0.0 ) {
			uv = vec2( direction.z, direction.y ) / abs( direction.x );
		} else if ( face == 1.0 ) {
			uv = vec2( - direction.x, - direction.z ) / abs( direction.y );
		} else if ( face == 2.0 ) {
			uv = vec2( - direction.x, direction.y ) / abs( direction.z );
		} else if ( face == 3.0 ) {
			uv = vec2( - direction.z, direction.y ) / abs( direction.x );
		} else if ( face == 4.0 ) {
			uv = vec2( - direction.x, direction.z ) / abs( direction.y );
		} else {
			uv = vec2( direction.x, direction.y ) / abs( direction.z );
		}
		return 0.5 * ( uv + 1.0 );
	}
	vec3 bilinearCubeUV( sampler2D envMap, vec3 direction, float mipInt ) {
		float face = getFace( direction );
		float filterInt = max( cubeUV_minMipLevel - mipInt, 0.0 );
		mipInt = max( mipInt, cubeUV_minMipLevel );
		float faceSize = exp2( mipInt );
		highp vec2 uv = getUV( direction, face ) * ( faceSize - 2.0 ) + 1.0;
		if ( face > 2.0 ) {
			uv.y += faceSize;
			face -= 3.0;
		}
		uv.x += face * faceSize;
		uv.x += filterInt * 3.0 * cubeUV_minTileSize;
		uv.y += 4.0 * ( exp2( CUBEUV_MAX_MIP ) - faceSize );
		uv.x *= CUBEUV_TEXEL_WIDTH;
		uv.y *= CUBEUV_TEXEL_HEIGHT;
		#ifdef texture2DGradEXT
			return texture2DGradEXT( envMap, uv, vec2( 0.0 ), vec2( 0.0 ) ).rgb;
		#else
			return texture2D( envMap, uv ).rgb;
		#endif
	}
	#define cubeUV_r0 1.0
	#define cubeUV_m0 - 2.0
	#define cubeUV_r1 0.8
	#define cubeUV_m1 - 1.0
	#define cubeUV_r4 0.4
	#define cubeUV_m4 2.0
	#define cubeUV_r5 0.305
	#define cubeUV_m5 3.0
	#define cubeUV_r6 0.21
	#define cubeUV_m6 4.0
	float roughnessToMip( float roughness ) {
		float mip = 0.0;
		if ( roughness >= cubeUV_r1 ) {
			mip = ( cubeUV_r0 - roughness ) * ( cubeUV_m1 - cubeUV_m0 ) / ( cubeUV_r0 - cubeUV_r1 ) + cubeUV_m0;
		} else if ( roughness >= cubeUV_r4 ) {
			mip = ( cubeUV_r1 - roughness ) * ( cubeUV_m4 - cubeUV_m1 ) / ( cubeUV_r1 - cubeUV_r4 ) + cubeUV_m1;
		} else if ( roughness >= cubeUV_r5 ) {
			mip = ( cubeUV_r4 - roughness ) * ( cubeUV_m5 - cubeUV_m4 ) / ( cubeUV_r4 - cubeUV_r5 ) + cubeUV_m4;
		} else if ( roughness >= cubeUV_r6 ) {
			mip = ( cubeUV_r5 - roughness ) * ( cubeUV_m6 - cubeUV_m5 ) / ( cubeUV_r5 - cubeUV_r6 ) + cubeUV_m5;
		} else {
			mip = - 2.0 * log2( 1.16 * roughness );		}
		return mip;
	}
	vec4 textureCubeUV( sampler2D envMap, vec3 sampleDir, float roughness ) {
		float mip = clamp( roughnessToMip( roughness ), cubeUV_m0, CUBEUV_MAX_MIP );
		float mipF = fract( mip );
		float mipInt = floor( mip );
		vec3 color0 = bilinearCubeUV( envMap, sampleDir, mipInt );
		if ( mipF == 0.0 ) {
			return vec4( color0, 1.0 );
		} else {
			vec3 color1 = bilinearCubeUV( envMap, sampleDir, mipInt + 1.0 );
			return vec4( mix( color0, color1, mipF ), 1.0 );
		}
	}
#endif`,Sh=`vec3 transformedNormal = objectNormal;
#ifdef USE_TANGENT
	vec3 transformedTangent = objectTangent;
#endif
#ifdef USE_BATCHING
	mat3 bm = mat3( batchingMatrix );
	transformedNormal /= vec3( dot( bm[ 0 ], bm[ 0 ] ), dot( bm[ 1 ], bm[ 1 ] ), dot( bm[ 2 ], bm[ 2 ] ) );
	transformedNormal = bm * transformedNormal;
	#ifdef USE_TANGENT
		transformedTangent = bm * transformedTangent;
	#endif
#endif
#ifdef USE_INSTANCING
	mat3 im = mat3( instanceMatrix );
	transformedNormal /= vec3( dot( im[ 0 ], im[ 0 ] ), dot( im[ 1 ], im[ 1 ] ), dot( im[ 2 ], im[ 2 ] ) );
	transformedNormal = im * transformedNormal;
	#ifdef USE_TANGENT
		transformedTangent = im * transformedTangent;
	#endif
#endif
transformedNormal = normalMatrix * transformedNormal;
#ifdef FLIP_SIDED
	transformedNormal = - transformedNormal;
#endif
#ifdef USE_TANGENT
	transformedTangent = ( modelViewMatrix * vec4( transformedTangent, 0.0 ) ).xyz;
	#ifdef FLIP_SIDED
		transformedTangent = - transformedTangent;
	#endif
#endif`,bh=`#ifdef USE_DISPLACEMENTMAP
	uniform sampler2D displacementMap;
	uniform float displacementScale;
	uniform float displacementBias;
#endif`,Eh=`#ifdef USE_DISPLACEMENTMAP
	transformed += normalize( objectNormal ) * ( texture2D( displacementMap, vDisplacementMapUv ).x * displacementScale + displacementBias );
#endif`,wh=`#ifdef USE_EMISSIVEMAP
	vec4 emissiveColor = texture2D( emissiveMap, vEmissiveMapUv );
	totalEmissiveRadiance *= emissiveColor.rgb;
#endif`,Th=`#ifdef USE_EMISSIVEMAP
	uniform sampler2D emissiveMap;
#endif`,Ah="gl_FragColor = linearToOutputTexel( gl_FragColor );",Rh=`
const mat3 LINEAR_SRGB_TO_LINEAR_DISPLAY_P3 = mat3(
	vec3( 0.8224621, 0.177538, 0.0 ),
	vec3( 0.0331941, 0.9668058, 0.0 ),
	vec3( 0.0170827, 0.0723974, 0.9105199 )
);
const mat3 LINEAR_DISPLAY_P3_TO_LINEAR_SRGB = mat3(
	vec3( 1.2249401, - 0.2249404, 0.0 ),
	vec3( - 0.0420569, 1.0420571, 0.0 ),
	vec3( - 0.0196376, - 0.0786361, 1.0982735 )
);
vec4 LinearSRGBToLinearDisplayP3( in vec4 value ) {
	return vec4( value.rgb * LINEAR_SRGB_TO_LINEAR_DISPLAY_P3, value.a );
}
vec4 LinearDisplayP3ToLinearSRGB( in vec4 value ) {
	return vec4( value.rgb * LINEAR_DISPLAY_P3_TO_LINEAR_SRGB, value.a );
}
vec4 LinearTransferOETF( in vec4 value ) {
	return value;
}
vec4 sRGBTransferOETF( in vec4 value ) {
	return vec4( mix( pow( value.rgb, vec3( 0.41666 ) ) * 1.055 - vec3( 0.055 ), value.rgb * 12.92, vec3( lessThanEqual( value.rgb, vec3( 0.0031308 ) ) ) ), value.a );
}
vec4 LinearToLinear( in vec4 value ) {
	return value;
}
vec4 LinearTosRGB( in vec4 value ) {
	return sRGBTransferOETF( value );
}`,Ch=`#ifdef USE_ENVMAP
	#ifdef ENV_WORLDPOS
		vec3 cameraToFrag;
		if ( isOrthographic ) {
			cameraToFrag = normalize( vec3( - viewMatrix[ 0 ][ 2 ], - viewMatrix[ 1 ][ 2 ], - viewMatrix[ 2 ][ 2 ] ) );
		} else {
			cameraToFrag = normalize( vWorldPosition - cameraPosition );
		}
		vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );
		#ifdef ENVMAP_MODE_REFLECTION
			vec3 reflectVec = reflect( cameraToFrag, worldNormal );
		#else
			vec3 reflectVec = refract( cameraToFrag, worldNormal, refractionRatio );
		#endif
	#else
		vec3 reflectVec = vReflect;
	#endif
	#ifdef ENVMAP_TYPE_CUBE
		vec4 envColor = textureCube( envMap, vec3( flipEnvMap * reflectVec.x, reflectVec.yz ) );
	#else
		vec4 envColor = vec4( 0.0 );
	#endif
	#ifdef ENVMAP_BLENDING_MULTIPLY
		outgoingLight = mix( outgoingLight, outgoingLight * envColor.xyz, specularStrength * reflectivity );
	#elif defined( ENVMAP_BLENDING_MIX )
		outgoingLight = mix( outgoingLight, envColor.xyz, specularStrength * reflectivity );
	#elif defined( ENVMAP_BLENDING_ADD )
		outgoingLight += envColor.xyz * specularStrength * reflectivity;
	#endif
#endif`,Ph=`#ifdef USE_ENVMAP
	uniform float envMapIntensity;
	uniform float flipEnvMap;
	#ifdef ENVMAP_TYPE_CUBE
		uniform samplerCube envMap;
	#else
		uniform sampler2D envMap;
	#endif
	
#endif`,Lh=`#ifdef USE_ENVMAP
	uniform float reflectivity;
	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( LAMBERT )
		#define ENV_WORLDPOS
	#endif
	#ifdef ENV_WORLDPOS
		varying vec3 vWorldPosition;
		uniform float refractionRatio;
	#else
		varying vec3 vReflect;
	#endif
#endif`,Dh=`#ifdef USE_ENVMAP
	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( LAMBERT )
		#define ENV_WORLDPOS
	#endif
	#ifdef ENV_WORLDPOS
		
		varying vec3 vWorldPosition;
	#else
		varying vec3 vReflect;
		uniform float refractionRatio;
	#endif
#endif`,Ih=`#ifdef USE_ENVMAP
	#ifdef ENV_WORLDPOS
		vWorldPosition = worldPosition.xyz;
	#else
		vec3 cameraToVertex;
		if ( isOrthographic ) {
			cameraToVertex = normalize( vec3( - viewMatrix[ 0 ][ 2 ], - viewMatrix[ 1 ][ 2 ], - viewMatrix[ 2 ][ 2 ] ) );
		} else {
			cameraToVertex = normalize( worldPosition.xyz - cameraPosition );
		}
		vec3 worldNormal = inverseTransformDirection( transformedNormal, viewMatrix );
		#ifdef ENVMAP_MODE_REFLECTION
			vReflect = reflect( cameraToVertex, worldNormal );
		#else
			vReflect = refract( cameraToVertex, worldNormal, refractionRatio );
		#endif
	#endif
#endif`,Uh=`#ifdef USE_FOG
	vFogDepth = - mvPosition.z;
#endif`,Nh=`#ifdef USE_FOG
	varying float vFogDepth;
#endif`,Oh=`#ifdef USE_FOG
	#ifdef FOG_EXP2
		float fogFactor = 1.0 - exp( - fogDensity * fogDensity * vFogDepth * vFogDepth );
	#else
		float fogFactor = smoothstep( fogNear, fogFar, vFogDepth );
	#endif
	gl_FragColor.rgb = mix( gl_FragColor.rgb, fogColor, fogFactor );
#endif`,Fh=`#ifdef USE_FOG
	uniform vec3 fogColor;
	varying float vFogDepth;
	#ifdef FOG_EXP2
		uniform float fogDensity;
	#else
		uniform float fogNear;
		uniform float fogFar;
	#endif
#endif`,Bh=`#ifdef USE_GRADIENTMAP
	uniform sampler2D gradientMap;
#endif
vec3 getGradientIrradiance( vec3 normal, vec3 lightDirection ) {
	float dotNL = dot( normal, lightDirection );
	vec2 coord = vec2( dotNL * 0.5 + 0.5, 0.0 );
	#ifdef USE_GRADIENTMAP
		return vec3( texture2D( gradientMap, coord ).r );
	#else
		vec2 fw = fwidth( coord ) * 0.5;
		return mix( vec3( 0.7 ), vec3( 1.0 ), smoothstep( 0.7 - fw.x, 0.7 + fw.x, coord.x ) );
	#endif
}`,zh=`#ifdef USE_LIGHTMAP
	vec4 lightMapTexel = texture2D( lightMap, vLightMapUv );
	vec3 lightMapIrradiance = lightMapTexel.rgb * lightMapIntensity;
	reflectedLight.indirectDiffuse += lightMapIrradiance;
#endif`,Gh=`#ifdef USE_LIGHTMAP
	uniform sampler2D lightMap;
	uniform float lightMapIntensity;
#endif`,kh=`LambertMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.specularStrength = specularStrength;`,Hh=`varying vec3 vViewPosition;
struct LambertMaterial {
	vec3 diffuseColor;
	float specularStrength;
};
void RE_Direct_Lambert( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in LambertMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectDiffuse_Lambert( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in LambertMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_Lambert
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Lambert`,Vh=`uniform bool receiveShadow;
uniform vec3 ambientLightColor;
#if defined( USE_LIGHT_PROBES )
	uniform vec3 lightProbe[ 9 ];
#endif
vec3 shGetIrradianceAt( in vec3 normal, in vec3 shCoefficients[ 9 ] ) {
	float x = normal.x, y = normal.y, z = normal.z;
	vec3 result = shCoefficients[ 0 ] * 0.886227;
	result += shCoefficients[ 1 ] * 2.0 * 0.511664 * y;
	result += shCoefficients[ 2 ] * 2.0 * 0.511664 * z;
	result += shCoefficients[ 3 ] * 2.0 * 0.511664 * x;
	result += shCoefficients[ 4 ] * 2.0 * 0.429043 * x * y;
	result += shCoefficients[ 5 ] * 2.0 * 0.429043 * y * z;
	result += shCoefficients[ 6 ] * ( 0.743125 * z * z - 0.247708 );
	result += shCoefficients[ 7 ] * 2.0 * 0.429043 * x * z;
	result += shCoefficients[ 8 ] * 0.429043 * ( x * x - y * y );
	return result;
}
vec3 getLightProbeIrradiance( const in vec3 lightProbe[ 9 ], const in vec3 normal ) {
	vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );
	vec3 irradiance = shGetIrradianceAt( worldNormal, lightProbe );
	return irradiance;
}
vec3 getAmbientLightIrradiance( const in vec3 ambientLightColor ) {
	vec3 irradiance = ambientLightColor;
	return irradiance;
}
float getDistanceAttenuation( const in float lightDistance, const in float cutoffDistance, const in float decayExponent ) {
	#if defined ( LEGACY_LIGHTS )
		if ( cutoffDistance > 0.0 && decayExponent > 0.0 ) {
			return pow( saturate( - lightDistance / cutoffDistance + 1.0 ), decayExponent );
		}
		return 1.0;
	#else
		float distanceFalloff = 1.0 / max( pow( lightDistance, decayExponent ), 0.01 );
		if ( cutoffDistance > 0.0 ) {
			distanceFalloff *= pow2( saturate( 1.0 - pow4( lightDistance / cutoffDistance ) ) );
		}
		return distanceFalloff;
	#endif
}
float getSpotAttenuation( const in float coneCosine, const in float penumbraCosine, const in float angleCosine ) {
	return smoothstep( coneCosine, penumbraCosine, angleCosine );
}
#if NUM_DIR_LIGHTS > 0
	struct DirectionalLight {
		vec3 direction;
		vec3 color;
	};
	uniform DirectionalLight directionalLights[ NUM_DIR_LIGHTS ];
	void getDirectionalLightInfo( const in DirectionalLight directionalLight, out IncidentLight light ) {
		light.color = directionalLight.color;
		light.direction = directionalLight.direction;
		light.visible = true;
	}
#endif
#if NUM_POINT_LIGHTS > 0
	struct PointLight {
		vec3 position;
		vec3 color;
		float distance;
		float decay;
	};
	uniform PointLight pointLights[ NUM_POINT_LIGHTS ];
	void getPointLightInfo( const in PointLight pointLight, const in vec3 geometryPosition, out IncidentLight light ) {
		vec3 lVector = pointLight.position - geometryPosition;
		light.direction = normalize( lVector );
		float lightDistance = length( lVector );
		light.color = pointLight.color;
		light.color *= getDistanceAttenuation( lightDistance, pointLight.distance, pointLight.decay );
		light.visible = ( light.color != vec3( 0.0 ) );
	}
#endif
#if NUM_SPOT_LIGHTS > 0
	struct SpotLight {
		vec3 position;
		vec3 direction;
		vec3 color;
		float distance;
		float decay;
		float coneCos;
		float penumbraCos;
	};
	uniform SpotLight spotLights[ NUM_SPOT_LIGHTS ];
	void getSpotLightInfo( const in SpotLight spotLight, const in vec3 geometryPosition, out IncidentLight light ) {
		vec3 lVector = spotLight.position - geometryPosition;
		light.direction = normalize( lVector );
		float angleCos = dot( light.direction, spotLight.direction );
		float spotAttenuation = getSpotAttenuation( spotLight.coneCos, spotLight.penumbraCos, angleCos );
		if ( spotAttenuation > 0.0 ) {
			float lightDistance = length( lVector );
			light.color = spotLight.color * spotAttenuation;
			light.color *= getDistanceAttenuation( lightDistance, spotLight.distance, spotLight.decay );
			light.visible = ( light.color != vec3( 0.0 ) );
		} else {
			light.color = vec3( 0.0 );
			light.visible = false;
		}
	}
#endif
#if NUM_RECT_AREA_LIGHTS > 0
	struct RectAreaLight {
		vec3 color;
		vec3 position;
		vec3 halfWidth;
		vec3 halfHeight;
	};
	uniform sampler2D ltc_1;	uniform sampler2D ltc_2;
	uniform RectAreaLight rectAreaLights[ NUM_RECT_AREA_LIGHTS ];
#endif
#if NUM_HEMI_LIGHTS > 0
	struct HemisphereLight {
		vec3 direction;
		vec3 skyColor;
		vec3 groundColor;
	};
	uniform HemisphereLight hemisphereLights[ NUM_HEMI_LIGHTS ];
	vec3 getHemisphereLightIrradiance( const in HemisphereLight hemiLight, const in vec3 normal ) {
		float dotNL = dot( normal, hemiLight.direction );
		float hemiDiffuseWeight = 0.5 * dotNL + 0.5;
		vec3 irradiance = mix( hemiLight.groundColor, hemiLight.skyColor, hemiDiffuseWeight );
		return irradiance;
	}
#endif`,Xh=`#ifdef USE_ENVMAP
	vec3 getIBLIrradiance( const in vec3 normal ) {
		#ifdef ENVMAP_TYPE_CUBE_UV
			vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );
			vec4 envMapColor = textureCubeUV( envMap, worldNormal, 1.0 );
			return PI * envMapColor.rgb * envMapIntensity;
		#else
			return vec3( 0.0 );
		#endif
	}
	vec3 getIBLRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness ) {
		#ifdef ENVMAP_TYPE_CUBE_UV
			vec3 reflectVec = reflect( - viewDir, normal );
			reflectVec = normalize( mix( reflectVec, normal, roughness * roughness) );
			reflectVec = inverseTransformDirection( reflectVec, viewMatrix );
			vec4 envMapColor = textureCubeUV( envMap, reflectVec, roughness );
			return envMapColor.rgb * envMapIntensity;
		#else
			return vec3( 0.0 );
		#endif
	}
	#ifdef USE_ANISOTROPY
		vec3 getIBLAnisotropyRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness, const in vec3 bitangent, const in float anisotropy ) {
			#ifdef ENVMAP_TYPE_CUBE_UV
				vec3 bentNormal = cross( bitangent, viewDir );
				bentNormal = normalize( cross( bentNormal, bitangent ) );
				bentNormal = normalize( mix( bentNormal, normal, pow2( pow2( 1.0 - anisotropy * ( 1.0 - roughness ) ) ) ) );
				return getIBLRadiance( viewDir, bentNormal, roughness );
			#else
				return vec3( 0.0 );
			#endif
		}
	#endif
#endif`,Wh=`ToonMaterial material;
material.diffuseColor = diffuseColor.rgb;`,qh=`varying vec3 vViewPosition;
struct ToonMaterial {
	vec3 diffuseColor;
};
void RE_Direct_Toon( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in ToonMaterial material, inout ReflectedLight reflectedLight ) {
	vec3 irradiance = getGradientIrradiance( geometryNormal, directLight.direction ) * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectDiffuse_Toon( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in ToonMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_Toon
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Toon`,Yh=`BlinnPhongMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.specularColor = specular;
material.specularShininess = shininess;
material.specularStrength = specularStrength;`,jh=`varying vec3 vViewPosition;
struct BlinnPhongMaterial {
	vec3 diffuseColor;
	vec3 specularColor;
	float specularShininess;
	float specularStrength;
};
void RE_Direct_BlinnPhong( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in BlinnPhongMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
	reflectedLight.directSpecular += irradiance * BRDF_BlinnPhong( directLight.direction, geometryViewDir, geometryNormal, material.specularColor, material.specularShininess ) * material.specularStrength;
}
void RE_IndirectDiffuse_BlinnPhong( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in BlinnPhongMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_BlinnPhong
#define RE_IndirectDiffuse		RE_IndirectDiffuse_BlinnPhong`,$h=`PhysicalMaterial material;
material.diffuseColor = diffuseColor.rgb * ( 1.0 - metalnessFactor );
vec3 dxy = max( abs( dFdx( nonPerturbedNormal ) ), abs( dFdy( nonPerturbedNormal ) ) );
float geometryRoughness = max( max( dxy.x, dxy.y ), dxy.z );
material.roughness = max( roughnessFactor, 0.0525 );material.roughness += geometryRoughness;
material.roughness = min( material.roughness, 1.0 );
#ifdef IOR
	material.ior = ior;
	#ifdef USE_SPECULAR
		float specularIntensityFactor = specularIntensity;
		vec3 specularColorFactor = specularColor;
		#ifdef USE_SPECULAR_COLORMAP
			specularColorFactor *= texture2D( specularColorMap, vSpecularColorMapUv ).rgb;
		#endif
		#ifdef USE_SPECULAR_INTENSITYMAP
			specularIntensityFactor *= texture2D( specularIntensityMap, vSpecularIntensityMapUv ).a;
		#endif
		material.specularF90 = mix( specularIntensityFactor, 1.0, metalnessFactor );
	#else
		float specularIntensityFactor = 1.0;
		vec3 specularColorFactor = vec3( 1.0 );
		material.specularF90 = 1.0;
	#endif
	material.specularColor = mix( min( pow2( ( material.ior - 1.0 ) / ( material.ior + 1.0 ) ) * specularColorFactor, vec3( 1.0 ) ) * specularIntensityFactor, diffuseColor.rgb, metalnessFactor );
#else
	material.specularColor = mix( vec3( 0.04 ), diffuseColor.rgb, metalnessFactor );
	material.specularF90 = 1.0;
#endif
#ifdef USE_CLEARCOAT
	material.clearcoat = clearcoat;
	material.clearcoatRoughness = clearcoatRoughness;
	material.clearcoatF0 = vec3( 0.04 );
	material.clearcoatF90 = 1.0;
	#ifdef USE_CLEARCOATMAP
		material.clearcoat *= texture2D( clearcoatMap, vClearcoatMapUv ).x;
	#endif
	#ifdef USE_CLEARCOAT_ROUGHNESSMAP
		material.clearcoatRoughness *= texture2D( clearcoatRoughnessMap, vClearcoatRoughnessMapUv ).y;
	#endif
	material.clearcoat = saturate( material.clearcoat );	material.clearcoatRoughness = max( material.clearcoatRoughness, 0.0525 );
	material.clearcoatRoughness += geometryRoughness;
	material.clearcoatRoughness = min( material.clearcoatRoughness, 1.0 );
#endif
#ifdef USE_IRIDESCENCE
	material.iridescence = iridescence;
	material.iridescenceIOR = iridescenceIOR;
	#ifdef USE_IRIDESCENCEMAP
		material.iridescence *= texture2D( iridescenceMap, vIridescenceMapUv ).r;
	#endif
	#ifdef USE_IRIDESCENCE_THICKNESSMAP
		material.iridescenceThickness = (iridescenceThicknessMaximum - iridescenceThicknessMinimum) * texture2D( iridescenceThicknessMap, vIridescenceThicknessMapUv ).g + iridescenceThicknessMinimum;
	#else
		material.iridescenceThickness = iridescenceThicknessMaximum;
	#endif
#endif
#ifdef USE_SHEEN
	material.sheenColor = sheenColor;
	#ifdef USE_SHEEN_COLORMAP
		material.sheenColor *= texture2D( sheenColorMap, vSheenColorMapUv ).rgb;
	#endif
	material.sheenRoughness = clamp( sheenRoughness, 0.07, 1.0 );
	#ifdef USE_SHEEN_ROUGHNESSMAP
		material.sheenRoughness *= texture2D( sheenRoughnessMap, vSheenRoughnessMapUv ).a;
	#endif
#endif
#ifdef USE_ANISOTROPY
	#ifdef USE_ANISOTROPYMAP
		mat2 anisotropyMat = mat2( anisotropyVector.x, anisotropyVector.y, - anisotropyVector.y, anisotropyVector.x );
		vec3 anisotropyPolar = texture2D( anisotropyMap, vAnisotropyMapUv ).rgb;
		vec2 anisotropyV = anisotropyMat * normalize( 2.0 * anisotropyPolar.rg - vec2( 1.0 ) ) * anisotropyPolar.b;
	#else
		vec2 anisotropyV = anisotropyVector;
	#endif
	material.anisotropy = length( anisotropyV );
	if( material.anisotropy == 0.0 ) {
		anisotropyV = vec2( 1.0, 0.0 );
	} else {
		anisotropyV /= material.anisotropy;
		material.anisotropy = saturate( material.anisotropy );
	}
	material.alphaT = mix( pow2( material.roughness ), 1.0, pow2( material.anisotropy ) );
	material.anisotropyT = tbn[ 0 ] * anisotropyV.x + tbn[ 1 ] * anisotropyV.y;
	material.anisotropyB = tbn[ 1 ] * anisotropyV.x - tbn[ 0 ] * anisotropyV.y;
#endif`,Kh=`struct PhysicalMaterial {
	vec3 diffuseColor;
	float roughness;
	vec3 specularColor;
	float specularF90;
	#ifdef USE_CLEARCOAT
		float clearcoat;
		float clearcoatRoughness;
		vec3 clearcoatF0;
		float clearcoatF90;
	#endif
	#ifdef USE_IRIDESCENCE
		float iridescence;
		float iridescenceIOR;
		float iridescenceThickness;
		vec3 iridescenceFresnel;
		vec3 iridescenceF0;
	#endif
	#ifdef USE_SHEEN
		vec3 sheenColor;
		float sheenRoughness;
	#endif
	#ifdef IOR
		float ior;
	#endif
	#ifdef USE_TRANSMISSION
		float transmission;
		float transmissionAlpha;
		float thickness;
		float attenuationDistance;
		vec3 attenuationColor;
	#endif
	#ifdef USE_ANISOTROPY
		float anisotropy;
		float alphaT;
		vec3 anisotropyT;
		vec3 anisotropyB;
	#endif
};
vec3 clearcoatSpecularDirect = vec3( 0.0 );
vec3 clearcoatSpecularIndirect = vec3( 0.0 );
vec3 sheenSpecularDirect = vec3( 0.0 );
vec3 sheenSpecularIndirect = vec3(0.0 );
vec3 Schlick_to_F0( const in vec3 f, const in float f90, const in float dotVH ) {
    float x = clamp( 1.0 - dotVH, 0.0, 1.0 );
    float x2 = x * x;
    float x5 = clamp( x * x2 * x2, 0.0, 0.9999 );
    return ( f - vec3( f90 ) * x5 ) / ( 1.0 - x5 );
}
float V_GGX_SmithCorrelated( const in float alpha, const in float dotNL, const in float dotNV ) {
	float a2 = pow2( alpha );
	float gv = dotNL * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNV ) );
	float gl = dotNV * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNL ) );
	return 0.5 / max( gv + gl, EPSILON );
}
float D_GGX( const in float alpha, const in float dotNH ) {
	float a2 = pow2( alpha );
	float denom = pow2( dotNH ) * ( a2 - 1.0 ) + 1.0;
	return RECIPROCAL_PI * a2 / pow2( denom );
}
#ifdef USE_ANISOTROPY
	float V_GGX_SmithCorrelated_Anisotropic( const in float alphaT, const in float alphaB, const in float dotTV, const in float dotBV, const in float dotTL, const in float dotBL, const in float dotNV, const in float dotNL ) {
		float gv = dotNL * length( vec3( alphaT * dotTV, alphaB * dotBV, dotNV ) );
		float gl = dotNV * length( vec3( alphaT * dotTL, alphaB * dotBL, dotNL ) );
		float v = 0.5 / ( gv + gl );
		return saturate(v);
	}
	float D_GGX_Anisotropic( const in float alphaT, const in float alphaB, const in float dotNH, const in float dotTH, const in float dotBH ) {
		float a2 = alphaT * alphaB;
		highp vec3 v = vec3( alphaB * dotTH, alphaT * dotBH, a2 * dotNH );
		highp float v2 = dot( v, v );
		float w2 = a2 / v2;
		return RECIPROCAL_PI * a2 * pow2 ( w2 );
	}
#endif
#ifdef USE_CLEARCOAT
	vec3 BRDF_GGX_Clearcoat( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in PhysicalMaterial material) {
		vec3 f0 = material.clearcoatF0;
		float f90 = material.clearcoatF90;
		float roughness = material.clearcoatRoughness;
		float alpha = pow2( roughness );
		vec3 halfDir = normalize( lightDir + viewDir );
		float dotNL = saturate( dot( normal, lightDir ) );
		float dotNV = saturate( dot( normal, viewDir ) );
		float dotNH = saturate( dot( normal, halfDir ) );
		float dotVH = saturate( dot( viewDir, halfDir ) );
		vec3 F = F_Schlick( f0, f90, dotVH );
		float V = V_GGX_SmithCorrelated( alpha, dotNL, dotNV );
		float D = D_GGX( alpha, dotNH );
		return F * ( V * D );
	}
#endif
vec3 BRDF_GGX( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in PhysicalMaterial material ) {
	vec3 f0 = material.specularColor;
	float f90 = material.specularF90;
	float roughness = material.roughness;
	float alpha = pow2( roughness );
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNL = saturate( dot( normal, lightDir ) );
	float dotNV = saturate( dot( normal, viewDir ) );
	float dotNH = saturate( dot( normal, halfDir ) );
	float dotVH = saturate( dot( viewDir, halfDir ) );
	vec3 F = F_Schlick( f0, f90, dotVH );
	#ifdef USE_IRIDESCENCE
		F = mix( F, material.iridescenceFresnel, material.iridescence );
	#endif
	#ifdef USE_ANISOTROPY
		float dotTL = dot( material.anisotropyT, lightDir );
		float dotTV = dot( material.anisotropyT, viewDir );
		float dotTH = dot( material.anisotropyT, halfDir );
		float dotBL = dot( material.anisotropyB, lightDir );
		float dotBV = dot( material.anisotropyB, viewDir );
		float dotBH = dot( material.anisotropyB, halfDir );
		float V = V_GGX_SmithCorrelated_Anisotropic( material.alphaT, alpha, dotTV, dotBV, dotTL, dotBL, dotNV, dotNL );
		float D = D_GGX_Anisotropic( material.alphaT, alpha, dotNH, dotTH, dotBH );
	#else
		float V = V_GGX_SmithCorrelated( alpha, dotNL, dotNV );
		float D = D_GGX( alpha, dotNH );
	#endif
	return F * ( V * D );
}
vec2 LTC_Uv( const in vec3 N, const in vec3 V, const in float roughness ) {
	const float LUT_SIZE = 64.0;
	const float LUT_SCALE = ( LUT_SIZE - 1.0 ) / LUT_SIZE;
	const float LUT_BIAS = 0.5 / LUT_SIZE;
	float dotNV = saturate( dot( N, V ) );
	vec2 uv = vec2( roughness, sqrt( 1.0 - dotNV ) );
	uv = uv * LUT_SCALE + LUT_BIAS;
	return uv;
}
float LTC_ClippedSphereFormFactor( const in vec3 f ) {
	float l = length( f );
	return max( ( l * l + f.z ) / ( l + 1.0 ), 0.0 );
}
vec3 LTC_EdgeVectorFormFactor( const in vec3 v1, const in vec3 v2 ) {
	float x = dot( v1, v2 );
	float y = abs( x );
	float a = 0.8543985 + ( 0.4965155 + 0.0145206 * y ) * y;
	float b = 3.4175940 + ( 4.1616724 + y ) * y;
	float v = a / b;
	float theta_sintheta = ( x > 0.0 ) ? v : 0.5 * inversesqrt( max( 1.0 - x * x, 1e-7 ) ) - v;
	return cross( v1, v2 ) * theta_sintheta;
}
vec3 LTC_Evaluate( const in vec3 N, const in vec3 V, const in vec3 P, const in mat3 mInv, const in vec3 rectCoords[ 4 ] ) {
	vec3 v1 = rectCoords[ 1 ] - rectCoords[ 0 ];
	vec3 v2 = rectCoords[ 3 ] - rectCoords[ 0 ];
	vec3 lightNormal = cross( v1, v2 );
	if( dot( lightNormal, P - rectCoords[ 0 ] ) < 0.0 ) return vec3( 0.0 );
	vec3 T1, T2;
	T1 = normalize( V - N * dot( V, N ) );
	T2 = - cross( N, T1 );
	mat3 mat = mInv * transposeMat3( mat3( T1, T2, N ) );
	vec3 coords[ 4 ];
	coords[ 0 ] = mat * ( rectCoords[ 0 ] - P );
	coords[ 1 ] = mat * ( rectCoords[ 1 ] - P );
	coords[ 2 ] = mat * ( rectCoords[ 2 ] - P );
	coords[ 3 ] = mat * ( rectCoords[ 3 ] - P );
	coords[ 0 ] = normalize( coords[ 0 ] );
	coords[ 1 ] = normalize( coords[ 1 ] );
	coords[ 2 ] = normalize( coords[ 2 ] );
	coords[ 3 ] = normalize( coords[ 3 ] );
	vec3 vectorFormFactor = vec3( 0.0 );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 0 ], coords[ 1 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 1 ], coords[ 2 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 2 ], coords[ 3 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 3 ], coords[ 0 ] );
	float result = LTC_ClippedSphereFormFactor( vectorFormFactor );
	return vec3( result );
}
#if defined( USE_SHEEN )
float D_Charlie( float roughness, float dotNH ) {
	float alpha = pow2( roughness );
	float invAlpha = 1.0 / alpha;
	float cos2h = dotNH * dotNH;
	float sin2h = max( 1.0 - cos2h, 0.0078125 );
	return ( 2.0 + invAlpha ) * pow( sin2h, invAlpha * 0.5 ) / ( 2.0 * PI );
}
float V_Neubelt( float dotNV, float dotNL ) {
	return saturate( 1.0 / ( 4.0 * ( dotNL + dotNV - dotNL * dotNV ) ) );
}
vec3 BRDF_Sheen( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, vec3 sheenColor, const in float sheenRoughness ) {
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNL = saturate( dot( normal, lightDir ) );
	float dotNV = saturate( dot( normal, viewDir ) );
	float dotNH = saturate( dot( normal, halfDir ) );
	float D = D_Charlie( sheenRoughness, dotNH );
	float V = V_Neubelt( dotNV, dotNL );
	return sheenColor * ( D * V );
}
#endif
float IBLSheenBRDF( const in vec3 normal, const in vec3 viewDir, const in float roughness ) {
	float dotNV = saturate( dot( normal, viewDir ) );
	float r2 = roughness * roughness;
	float a = roughness < 0.25 ? -339.2 * r2 + 161.4 * roughness - 25.9 : -8.48 * r2 + 14.3 * roughness - 9.95;
	float b = roughness < 0.25 ? 44.0 * r2 - 23.7 * roughness + 3.26 : 1.97 * r2 - 3.27 * roughness + 0.72;
	float DG = exp( a * dotNV + b ) + ( roughness < 0.25 ? 0.0 : 0.1 * ( roughness - 0.25 ) );
	return saturate( DG * RECIPROCAL_PI );
}
vec2 DFGApprox( const in vec3 normal, const in vec3 viewDir, const in float roughness ) {
	float dotNV = saturate( dot( normal, viewDir ) );
	const vec4 c0 = vec4( - 1, - 0.0275, - 0.572, 0.022 );
	const vec4 c1 = vec4( 1, 0.0425, 1.04, - 0.04 );
	vec4 r = roughness * c0 + c1;
	float a004 = min( r.x * r.x, exp2( - 9.28 * dotNV ) ) * r.x + r.y;
	vec2 fab = vec2( - 1.04, 1.04 ) * a004 + r.zw;
	return fab;
}
vec3 EnvironmentBRDF( const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float roughness ) {
	vec2 fab = DFGApprox( normal, viewDir, roughness );
	return specularColor * fab.x + specularF90 * fab.y;
}
#ifdef USE_IRIDESCENCE
void computeMultiscatteringIridescence( const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float iridescence, const in vec3 iridescenceF0, const in float roughness, inout vec3 singleScatter, inout vec3 multiScatter ) {
#else
void computeMultiscattering( const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float roughness, inout vec3 singleScatter, inout vec3 multiScatter ) {
#endif
	vec2 fab = DFGApprox( normal, viewDir, roughness );
	#ifdef USE_IRIDESCENCE
		vec3 Fr = mix( specularColor, iridescenceF0, iridescence );
	#else
		vec3 Fr = specularColor;
	#endif
	vec3 FssEss = Fr * fab.x + specularF90 * fab.y;
	float Ess = fab.x + fab.y;
	float Ems = 1.0 - Ess;
	vec3 Favg = Fr + ( 1.0 - Fr ) * 0.047619;	vec3 Fms = FssEss * Favg / ( 1.0 - Ems * Favg );
	singleScatter += FssEss;
	multiScatter += Fms * Ems;
}
#if NUM_RECT_AREA_LIGHTS > 0
	void RE_Direct_RectArea_Physical( const in RectAreaLight rectAreaLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
		vec3 normal = geometryNormal;
		vec3 viewDir = geometryViewDir;
		vec3 position = geometryPosition;
		vec3 lightPos = rectAreaLight.position;
		vec3 halfWidth = rectAreaLight.halfWidth;
		vec3 halfHeight = rectAreaLight.halfHeight;
		vec3 lightColor = rectAreaLight.color;
		float roughness = material.roughness;
		vec3 rectCoords[ 4 ];
		rectCoords[ 0 ] = lightPos + halfWidth - halfHeight;		rectCoords[ 1 ] = lightPos - halfWidth - halfHeight;
		rectCoords[ 2 ] = lightPos - halfWidth + halfHeight;
		rectCoords[ 3 ] = lightPos + halfWidth + halfHeight;
		vec2 uv = LTC_Uv( normal, viewDir, roughness );
		vec4 t1 = texture2D( ltc_1, uv );
		vec4 t2 = texture2D( ltc_2, uv );
		mat3 mInv = mat3(
			vec3( t1.x, 0, t1.y ),
			vec3(    0, 1,    0 ),
			vec3( t1.z, 0, t1.w )
		);
		vec3 fresnel = ( material.specularColor * t2.x + ( vec3( 1.0 ) - material.specularColor ) * t2.y );
		reflectedLight.directSpecular += lightColor * fresnel * LTC_Evaluate( normal, viewDir, position, mInv, rectCoords );
		reflectedLight.directDiffuse += lightColor * material.diffuseColor * LTC_Evaluate( normal, viewDir, position, mat3( 1.0 ), rectCoords );
	}
#endif
void RE_Direct_Physical( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	#ifdef USE_CLEARCOAT
		float dotNLcc = saturate( dot( geometryClearcoatNormal, directLight.direction ) );
		vec3 ccIrradiance = dotNLcc * directLight.color;
		clearcoatSpecularDirect += ccIrradiance * BRDF_GGX_Clearcoat( directLight.direction, geometryViewDir, geometryClearcoatNormal, material );
	#endif
	#ifdef USE_SHEEN
		sheenSpecularDirect += irradiance * BRDF_Sheen( directLight.direction, geometryViewDir, geometryNormal, material.sheenColor, material.sheenRoughness );
	#endif
	reflectedLight.directSpecular += irradiance * BRDF_GGX( directLight.direction, geometryViewDir, geometryNormal, material );
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectDiffuse_Physical( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectSpecular_Physical( const in vec3 radiance, const in vec3 irradiance, const in vec3 clearcoatRadiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight) {
	#ifdef USE_CLEARCOAT
		clearcoatSpecularIndirect += clearcoatRadiance * EnvironmentBRDF( geometryClearcoatNormal, geometryViewDir, material.clearcoatF0, material.clearcoatF90, material.clearcoatRoughness );
	#endif
	#ifdef USE_SHEEN
		sheenSpecularIndirect += irradiance * material.sheenColor * IBLSheenBRDF( geometryNormal, geometryViewDir, material.sheenRoughness );
	#endif
	vec3 singleScattering = vec3( 0.0 );
	vec3 multiScattering = vec3( 0.0 );
	vec3 cosineWeightedIrradiance = irradiance * RECIPROCAL_PI;
	#ifdef USE_IRIDESCENCE
		computeMultiscatteringIridescence( geometryNormal, geometryViewDir, material.specularColor, material.specularF90, material.iridescence, material.iridescenceFresnel, material.roughness, singleScattering, multiScattering );
	#else
		computeMultiscattering( geometryNormal, geometryViewDir, material.specularColor, material.specularF90, material.roughness, singleScattering, multiScattering );
	#endif
	vec3 totalScattering = singleScattering + multiScattering;
	vec3 diffuse = material.diffuseColor * ( 1.0 - max( max( totalScattering.r, totalScattering.g ), totalScattering.b ) );
	reflectedLight.indirectSpecular += radiance * singleScattering;
	reflectedLight.indirectSpecular += multiScattering * cosineWeightedIrradiance;
	reflectedLight.indirectDiffuse += diffuse * cosineWeightedIrradiance;
}
#define RE_Direct				RE_Direct_Physical
#define RE_Direct_RectArea		RE_Direct_RectArea_Physical
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Physical
#define RE_IndirectSpecular		RE_IndirectSpecular_Physical
float computeSpecularOcclusion( const in float dotNV, const in float ambientOcclusion, const in float roughness ) {
	return saturate( pow( dotNV + ambientOcclusion, exp2( - 16.0 * roughness - 1.0 ) ) - 1.0 + ambientOcclusion );
}`,Zh=`
vec3 geometryPosition = - vViewPosition;
vec3 geometryNormal = normal;
vec3 geometryViewDir = ( isOrthographic ) ? vec3( 0, 0, 1 ) : normalize( vViewPosition );
vec3 geometryClearcoatNormal = vec3( 0.0 );
#ifdef USE_CLEARCOAT
	geometryClearcoatNormal = clearcoatNormal;
#endif
#ifdef USE_IRIDESCENCE
	float dotNVi = saturate( dot( normal, geometryViewDir ) );
	if ( material.iridescenceThickness == 0.0 ) {
		material.iridescence = 0.0;
	} else {
		material.iridescence = saturate( material.iridescence );
	}
	if ( material.iridescence > 0.0 ) {
		material.iridescenceFresnel = evalIridescence( 1.0, material.iridescenceIOR, dotNVi, material.iridescenceThickness, material.specularColor );
		material.iridescenceF0 = Schlick_to_F0( material.iridescenceFresnel, 1.0, dotNVi );
	}
#endif
IncidentLight directLight;
#if ( NUM_POINT_LIGHTS > 0 ) && defined( RE_Direct )
	PointLight pointLight;
	#if defined( USE_SHADOWMAP ) && NUM_POINT_LIGHT_SHADOWS > 0
	PointLightShadow pointLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_POINT_LIGHTS; i ++ ) {
		pointLight = pointLights[ i ];
		getPointLightInfo( pointLight, geometryPosition, directLight );
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_POINT_LIGHT_SHADOWS )
		pointLightShadow = pointLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getPointShadow( pointShadowMap[ i ], pointLightShadow.shadowMapSize, pointLightShadow.shadowBias, pointLightShadow.shadowRadius, vPointShadowCoord[ i ], pointLightShadow.shadowCameraNear, pointLightShadow.shadowCameraFar ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_SPOT_LIGHTS > 0 ) && defined( RE_Direct )
	SpotLight spotLight;
	vec4 spotColor;
	vec3 spotLightCoord;
	bool inSpotLightMap;
	#if defined( USE_SHADOWMAP ) && NUM_SPOT_LIGHT_SHADOWS > 0
	SpotLightShadow spotLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHTS; i ++ ) {
		spotLight = spotLights[ i ];
		getSpotLightInfo( spotLight, geometryPosition, directLight );
		#if ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS )
		#define SPOT_LIGHT_MAP_INDEX UNROLLED_LOOP_INDEX
		#elif ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
		#define SPOT_LIGHT_MAP_INDEX NUM_SPOT_LIGHT_MAPS
		#else
		#define SPOT_LIGHT_MAP_INDEX ( UNROLLED_LOOP_INDEX - NUM_SPOT_LIGHT_SHADOWS + NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS )
		#endif
		#if ( SPOT_LIGHT_MAP_INDEX < NUM_SPOT_LIGHT_MAPS )
			spotLightCoord = vSpotLightCoord[ i ].xyz / vSpotLightCoord[ i ].w;
			inSpotLightMap = all( lessThan( abs( spotLightCoord * 2. - 1. ), vec3( 1.0 ) ) );
			spotColor = texture2D( spotLightMap[ SPOT_LIGHT_MAP_INDEX ], spotLightCoord.xy );
			directLight.color = inSpotLightMap ? directLight.color * spotColor.rgb : directLight.color;
		#endif
		#undef SPOT_LIGHT_MAP_INDEX
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
		spotLightShadow = spotLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getShadow( spotShadowMap[ i ], spotLightShadow.shadowMapSize, spotLightShadow.shadowBias, spotLightShadow.shadowRadius, vSpotLightCoord[ i ] ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_DIR_LIGHTS > 0 ) && defined( RE_Direct )
	DirectionalLight directionalLight;
	#if defined( USE_SHADOWMAP ) && NUM_DIR_LIGHT_SHADOWS > 0
	DirectionalLightShadow directionalLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_DIR_LIGHTS; i ++ ) {
		directionalLight = directionalLights[ i ];
		getDirectionalLightInfo( directionalLight, directLight );
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_DIR_LIGHT_SHADOWS )
		directionalLightShadow = directionalLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getShadow( directionalShadowMap[ i ], directionalLightShadow.shadowMapSize, directionalLightShadow.shadowBias, directionalLightShadow.shadowRadius, vDirectionalShadowCoord[ i ] ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_RECT_AREA_LIGHTS > 0 ) && defined( RE_Direct_RectArea )
	RectAreaLight rectAreaLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_RECT_AREA_LIGHTS; i ++ ) {
		rectAreaLight = rectAreaLights[ i ];
		RE_Direct_RectArea( rectAreaLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if defined( RE_IndirectDiffuse )
	vec3 iblIrradiance = vec3( 0.0 );
	vec3 irradiance = getAmbientLightIrradiance( ambientLightColor );
	#if defined( USE_LIGHT_PROBES )
		irradiance += getLightProbeIrradiance( lightProbe, geometryNormal );
	#endif
	#if ( NUM_HEMI_LIGHTS > 0 )
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_HEMI_LIGHTS; i ++ ) {
			irradiance += getHemisphereLightIrradiance( hemisphereLights[ i ], geometryNormal );
		}
		#pragma unroll_loop_end
	#endif
#endif
#if defined( RE_IndirectSpecular )
	vec3 radiance = vec3( 0.0 );
	vec3 clearcoatRadiance = vec3( 0.0 );
#endif`,Jh=`#if defined( RE_IndirectDiffuse )
	#ifdef USE_LIGHTMAP
		vec4 lightMapTexel = texture2D( lightMap, vLightMapUv );
		vec3 lightMapIrradiance = lightMapTexel.rgb * lightMapIntensity;
		irradiance += lightMapIrradiance;
	#endif
	#if defined( USE_ENVMAP ) && defined( STANDARD ) && defined( ENVMAP_TYPE_CUBE_UV )
		iblIrradiance += getIBLIrradiance( geometryNormal );
	#endif
#endif
#if defined( USE_ENVMAP ) && defined( RE_IndirectSpecular )
	#ifdef USE_ANISOTROPY
		radiance += getIBLAnisotropyRadiance( geometryViewDir, geometryNormal, material.roughness, material.anisotropyB, material.anisotropy );
	#else
		radiance += getIBLRadiance( geometryViewDir, geometryNormal, material.roughness );
	#endif
	#ifdef USE_CLEARCOAT
		clearcoatRadiance += getIBLRadiance( geometryViewDir, geometryClearcoatNormal, material.clearcoatRoughness );
	#endif
#endif`,Qh=`#if defined( RE_IndirectDiffuse )
	RE_IndirectDiffuse( irradiance, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
#endif
#if defined( RE_IndirectSpecular )
	RE_IndirectSpecular( radiance, iblIrradiance, clearcoatRadiance, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
#endif`,td=`#if defined( USE_LOGDEPTHBUF ) && defined( USE_LOGDEPTHBUF_EXT )
	gl_FragDepthEXT = vIsPerspective == 0.0 ? gl_FragCoord.z : log2( vFragDepth ) * logDepthBufFC * 0.5;
#endif`,ed=`#if defined( USE_LOGDEPTHBUF ) && defined( USE_LOGDEPTHBUF_EXT )
	uniform float logDepthBufFC;
	varying float vFragDepth;
	varying float vIsPerspective;
#endif`,nd=`#ifdef USE_LOGDEPTHBUF
	#ifdef USE_LOGDEPTHBUF_EXT
		varying float vFragDepth;
		varying float vIsPerspective;
	#else
		uniform float logDepthBufFC;
	#endif
#endif`,id=`#ifdef USE_LOGDEPTHBUF
	#ifdef USE_LOGDEPTHBUF_EXT
		vFragDepth = 1.0 + gl_Position.w;
		vIsPerspective = float( isPerspectiveMatrix( projectionMatrix ) );
	#else
		if ( isPerspectiveMatrix( projectionMatrix ) ) {
			gl_Position.z = log2( max( EPSILON, gl_Position.w + 1.0 ) ) * logDepthBufFC - 1.0;
			gl_Position.z *= gl_Position.w;
		}
	#endif
#endif`,rd=`#ifdef USE_MAP
	vec4 sampledDiffuseColor = texture2D( map, vMapUv );
	#ifdef DECODE_VIDEO_TEXTURE
		sampledDiffuseColor = vec4( mix( pow( sampledDiffuseColor.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), sampledDiffuseColor.rgb * 0.0773993808, vec3( lessThanEqual( sampledDiffuseColor.rgb, vec3( 0.04045 ) ) ) ), sampledDiffuseColor.w );
	
	#endif
	diffuseColor *= sampledDiffuseColor;
#endif`,sd=`#ifdef USE_MAP
	uniform sampler2D map;
#endif`,od=`#if defined( USE_MAP ) || defined( USE_ALPHAMAP )
	#if defined( USE_POINTS_UV )
		vec2 uv = vUv;
	#else
		vec2 uv = ( uvTransform * vec3( gl_PointCoord.x, 1.0 - gl_PointCoord.y, 1 ) ).xy;
	#endif
#endif
#ifdef USE_MAP
	diffuseColor *= texture2D( map, uv );
#endif
#ifdef USE_ALPHAMAP
	diffuseColor.a *= texture2D( alphaMap, uv ).g;
#endif`,ad=`#if defined( USE_POINTS_UV )
	varying vec2 vUv;
#else
	#if defined( USE_MAP ) || defined( USE_ALPHAMAP )
		uniform mat3 uvTransform;
	#endif
#endif
#ifdef USE_MAP
	uniform sampler2D map;
#endif
#ifdef USE_ALPHAMAP
	uniform sampler2D alphaMap;
#endif`,cd=`float metalnessFactor = metalness;
#ifdef USE_METALNESSMAP
	vec4 texelMetalness = texture2D( metalnessMap, vMetalnessMapUv );
	metalnessFactor *= texelMetalness.b;
#endif`,ld=`#ifdef USE_METALNESSMAP
	uniform sampler2D metalnessMap;
#endif`,ud=`#if defined( USE_MORPHCOLORS ) && defined( MORPHTARGETS_TEXTURE )
	vColor *= morphTargetBaseInfluence;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		#if defined( USE_COLOR_ALPHA )
			if ( morphTargetInfluences[ i ] != 0.0 ) vColor += getMorph( gl_VertexID, i, 2 ) * morphTargetInfluences[ i ];
		#elif defined( USE_COLOR )
			if ( morphTargetInfluences[ i ] != 0.0 ) vColor += getMorph( gl_VertexID, i, 2 ).rgb * morphTargetInfluences[ i ];
		#endif
	}
#endif`,hd=`#ifdef USE_MORPHNORMALS
	objectNormal *= morphTargetBaseInfluence;
	#ifdef MORPHTARGETS_TEXTURE
		for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
			if ( morphTargetInfluences[ i ] != 0.0 ) objectNormal += getMorph( gl_VertexID, i, 1 ).xyz * morphTargetInfluences[ i ];
		}
	#else
		objectNormal += morphNormal0 * morphTargetInfluences[ 0 ];
		objectNormal += morphNormal1 * morphTargetInfluences[ 1 ];
		objectNormal += morphNormal2 * morphTargetInfluences[ 2 ];
		objectNormal += morphNormal3 * morphTargetInfluences[ 3 ];
	#endif
#endif`,dd=`#ifdef USE_MORPHTARGETS
	uniform float morphTargetBaseInfluence;
	#ifdef MORPHTARGETS_TEXTURE
		uniform float morphTargetInfluences[ MORPHTARGETS_COUNT ];
		uniform sampler2DArray morphTargetsTexture;
		uniform ivec2 morphTargetsTextureSize;
		vec4 getMorph( const in int vertexIndex, const in int morphTargetIndex, const in int offset ) {
			int texelIndex = vertexIndex * MORPHTARGETS_TEXTURE_STRIDE + offset;
			int y = texelIndex / morphTargetsTextureSize.x;
			int x = texelIndex - y * morphTargetsTextureSize.x;
			ivec3 morphUV = ivec3( x, y, morphTargetIndex );
			return texelFetch( morphTargetsTexture, morphUV, 0 );
		}
	#else
		#ifndef USE_MORPHNORMALS
			uniform float morphTargetInfluences[ 8 ];
		#else
			uniform float morphTargetInfluences[ 4 ];
		#endif
	#endif
#endif`,fd=`#ifdef USE_MORPHTARGETS
	transformed *= morphTargetBaseInfluence;
	#ifdef MORPHTARGETS_TEXTURE
		for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
			if ( morphTargetInfluences[ i ] != 0.0 ) transformed += getMorph( gl_VertexID, i, 0 ).xyz * morphTargetInfluences[ i ];
		}
	#else
		transformed += morphTarget0 * morphTargetInfluences[ 0 ];
		transformed += morphTarget1 * morphTargetInfluences[ 1 ];
		transformed += morphTarget2 * morphTargetInfluences[ 2 ];
		transformed += morphTarget3 * morphTargetInfluences[ 3 ];
		#ifndef USE_MORPHNORMALS
			transformed += morphTarget4 * morphTargetInfluences[ 4 ];
			transformed += morphTarget5 * morphTargetInfluences[ 5 ];
			transformed += morphTarget6 * morphTargetInfluences[ 6 ];
			transformed += morphTarget7 * morphTargetInfluences[ 7 ];
		#endif
	#endif
#endif`,pd=`float faceDirection = gl_FrontFacing ? 1.0 : - 1.0;
#ifdef FLAT_SHADED
	vec3 fdx = dFdx( vViewPosition );
	vec3 fdy = dFdy( vViewPosition );
	vec3 normal = normalize( cross( fdx, fdy ) );
#else
	vec3 normal = normalize( vNormal );
	#ifdef DOUBLE_SIDED
		normal *= faceDirection;
	#endif
#endif
#if defined( USE_NORMALMAP_TANGENTSPACE ) || defined( USE_CLEARCOAT_NORMALMAP ) || defined( USE_ANISOTROPY )
	#ifdef USE_TANGENT
		mat3 tbn = mat3( normalize( vTangent ), normalize( vBitangent ), normal );
	#else
		mat3 tbn = getTangentFrame( - vViewPosition, normal,
		#if defined( USE_NORMALMAP )
			vNormalMapUv
		#elif defined( USE_CLEARCOAT_NORMALMAP )
			vClearcoatNormalMapUv
		#else
			vUv
		#endif
		);
	#endif
	#if defined( DOUBLE_SIDED ) && ! defined( FLAT_SHADED )
		tbn[0] *= faceDirection;
		tbn[1] *= faceDirection;
	#endif
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	#ifdef USE_TANGENT
		mat3 tbn2 = mat3( normalize( vTangent ), normalize( vBitangent ), normal );
	#else
		mat3 tbn2 = getTangentFrame( - vViewPosition, normal, vClearcoatNormalMapUv );
	#endif
	#if defined( DOUBLE_SIDED ) && ! defined( FLAT_SHADED )
		tbn2[0] *= faceDirection;
		tbn2[1] *= faceDirection;
	#endif
#endif
vec3 nonPerturbedNormal = normal;`,md=`#ifdef USE_NORMALMAP_OBJECTSPACE
	normal = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0;
	#ifdef FLIP_SIDED
		normal = - normal;
	#endif
	#ifdef DOUBLE_SIDED
		normal = normal * faceDirection;
	#endif
	normal = normalize( normalMatrix * normal );
#elif defined( USE_NORMALMAP_TANGENTSPACE )
	vec3 mapN = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0;
	mapN.xy *= normalScale;
	normal = normalize( tbn * mapN );
#elif defined( USE_BUMPMAP )
	normal = perturbNormalArb( - vViewPosition, normal, dHdxy_fwd(), faceDirection );
#endif`,gd=`#ifndef FLAT_SHADED
	varying vec3 vNormal;
	#ifdef USE_TANGENT
		varying vec3 vTangent;
		varying vec3 vBitangent;
	#endif
#endif`,_d=`#ifndef FLAT_SHADED
	varying vec3 vNormal;
	#ifdef USE_TANGENT
		varying vec3 vTangent;
		varying vec3 vBitangent;
	#endif
#endif`,vd=`#ifndef FLAT_SHADED
	vNormal = normalize( transformedNormal );
	#ifdef USE_TANGENT
		vTangent = normalize( transformedTangent );
		vBitangent = normalize( cross( vNormal, vTangent ) * tangent.w );
	#endif
#endif`,xd=`#ifdef USE_NORMALMAP
	uniform sampler2D normalMap;
	uniform vec2 normalScale;
#endif
#ifdef USE_NORMALMAP_OBJECTSPACE
	uniform mat3 normalMatrix;
#endif
#if ! defined ( USE_TANGENT ) && ( defined ( USE_NORMALMAP_TANGENTSPACE ) || defined ( USE_CLEARCOAT_NORMALMAP ) || defined( USE_ANISOTROPY ) )
	mat3 getTangentFrame( vec3 eye_pos, vec3 surf_norm, vec2 uv ) {
		vec3 q0 = dFdx( eye_pos.xyz );
		vec3 q1 = dFdy( eye_pos.xyz );
		vec2 st0 = dFdx( uv.st );
		vec2 st1 = dFdy( uv.st );
		vec3 N = surf_norm;
		vec3 q1perp = cross( q1, N );
		vec3 q0perp = cross( N, q0 );
		vec3 T = q1perp * st0.x + q0perp * st1.x;
		vec3 B = q1perp * st0.y + q0perp * st1.y;
		float det = max( dot( T, T ), dot( B, B ) );
		float scale = ( det == 0.0 ) ? 0.0 : inversesqrt( det );
		return mat3( T * scale, B * scale, N );
	}
#endif`,Md=`#ifdef USE_CLEARCOAT
	vec3 clearcoatNormal = nonPerturbedNormal;
#endif`,yd=`#ifdef USE_CLEARCOAT_NORMALMAP
	vec3 clearcoatMapN = texture2D( clearcoatNormalMap, vClearcoatNormalMapUv ).xyz * 2.0 - 1.0;
	clearcoatMapN.xy *= clearcoatNormalScale;
	clearcoatNormal = normalize( tbn2 * clearcoatMapN );
#endif`,Sd=`#ifdef USE_CLEARCOATMAP
	uniform sampler2D clearcoatMap;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	uniform sampler2D clearcoatNormalMap;
	uniform vec2 clearcoatNormalScale;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	uniform sampler2D clearcoatRoughnessMap;
#endif`,bd=`#ifdef USE_IRIDESCENCEMAP
	uniform sampler2D iridescenceMap;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	uniform sampler2D iridescenceThicknessMap;
#endif`,Ed=`#ifdef OPAQUE
diffuseColor.a = 1.0;
#endif
#ifdef USE_TRANSMISSION
diffuseColor.a *= material.transmissionAlpha;
#endif
gl_FragColor = vec4( outgoingLight, diffuseColor.a );`,wd=`vec3 packNormalToRGB( const in vec3 normal ) {
	return normalize( normal ) * 0.5 + 0.5;
}
vec3 unpackRGBToNormal( const in vec3 rgb ) {
	return 2.0 * rgb.xyz - 1.0;
}
const float PackUpscale = 256. / 255.;const float UnpackDownscale = 255. / 256.;
const vec3 PackFactors = vec3( 256. * 256. * 256., 256. * 256., 256. );
const vec4 UnpackFactors = UnpackDownscale / vec4( PackFactors, 1. );
const float ShiftRight8 = 1. / 256.;
vec4 packDepthToRGBA( const in float v ) {
	vec4 r = vec4( fract( v * PackFactors ), v );
	r.yzw -= r.xyz * ShiftRight8;	return r * PackUpscale;
}
float unpackRGBAToDepth( const in vec4 v ) {
	return dot( v, UnpackFactors );
}
vec2 packDepthToRG( in highp float v ) {
	return packDepthToRGBA( v ).yx;
}
float unpackRGToDepth( const in highp vec2 v ) {
	return unpackRGBAToDepth( vec4( v.xy, 0.0, 0.0 ) );
}
vec4 pack2HalfToRGBA( vec2 v ) {
	vec4 r = vec4( v.x, fract( v.x * 255.0 ), v.y, fract( v.y * 255.0 ) );
	return vec4( r.x - r.y / 255.0, r.y, r.z - r.w / 255.0, r.w );
}
vec2 unpackRGBATo2Half( vec4 v ) {
	return vec2( v.x + ( v.y / 255.0 ), v.z + ( v.w / 255.0 ) );
}
float viewZToOrthographicDepth( const in float viewZ, const in float near, const in float far ) {
	return ( viewZ + near ) / ( near - far );
}
float orthographicDepthToViewZ( const in float depth, const in float near, const in float far ) {
	return depth * ( near - far ) - near;
}
float viewZToPerspectiveDepth( const in float viewZ, const in float near, const in float far ) {
	return ( ( near + viewZ ) * far ) / ( ( far - near ) * viewZ );
}
float perspectiveDepthToViewZ( const in float depth, const in float near, const in float far ) {
	return ( near * far ) / ( ( far - near ) * depth - far );
}`,Td=`#ifdef PREMULTIPLIED_ALPHA
	gl_FragColor.rgb *= gl_FragColor.a;
#endif`,Ad=`vec4 mvPosition = vec4( transformed, 1.0 );
#ifdef USE_BATCHING
	mvPosition = batchingMatrix * mvPosition;
#endif
#ifdef USE_INSTANCING
	mvPosition = instanceMatrix * mvPosition;
#endif
mvPosition = modelViewMatrix * mvPosition;
gl_Position = projectionMatrix * mvPosition;`,Rd=`#ifdef DITHERING
	gl_FragColor.rgb = dithering( gl_FragColor.rgb );
#endif`,Cd=`#ifdef DITHERING
	vec3 dithering( vec3 color ) {
		float grid_position = rand( gl_FragCoord.xy );
		vec3 dither_shift_RGB = vec3( 0.25 / 255.0, -0.25 / 255.0, 0.25 / 255.0 );
		dither_shift_RGB = mix( 2.0 * dither_shift_RGB, -2.0 * dither_shift_RGB, grid_position );
		return color + dither_shift_RGB;
	}
#endif`,Pd=`float roughnessFactor = roughness;
#ifdef USE_ROUGHNESSMAP
	vec4 texelRoughness = texture2D( roughnessMap, vRoughnessMapUv );
	roughnessFactor *= texelRoughness.g;
#endif`,Ld=`#ifdef USE_ROUGHNESSMAP
	uniform sampler2D roughnessMap;
#endif`,Dd=`#if NUM_SPOT_LIGHT_COORDS > 0
	varying vec4 vSpotLightCoord[ NUM_SPOT_LIGHT_COORDS ];
#endif
#if NUM_SPOT_LIGHT_MAPS > 0
	uniform sampler2D spotLightMap[ NUM_SPOT_LIGHT_MAPS ];
#endif
#ifdef USE_SHADOWMAP
	#if NUM_DIR_LIGHT_SHADOWS > 0
		uniform sampler2D directionalShadowMap[ NUM_DIR_LIGHT_SHADOWS ];
		varying vec4 vDirectionalShadowCoord[ NUM_DIR_LIGHT_SHADOWS ];
		struct DirectionalLightShadow {
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform DirectionalLightShadow directionalLightShadows[ NUM_DIR_LIGHT_SHADOWS ];
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
		uniform sampler2D spotShadowMap[ NUM_SPOT_LIGHT_SHADOWS ];
		struct SpotLightShadow {
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform SpotLightShadow spotLightShadows[ NUM_SPOT_LIGHT_SHADOWS ];
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		uniform sampler2D pointShadowMap[ NUM_POINT_LIGHT_SHADOWS ];
		varying vec4 vPointShadowCoord[ NUM_POINT_LIGHT_SHADOWS ];
		struct PointLightShadow {
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
			float shadowCameraNear;
			float shadowCameraFar;
		};
		uniform PointLightShadow pointLightShadows[ NUM_POINT_LIGHT_SHADOWS ];
	#endif
	float texture2DCompare( sampler2D depths, vec2 uv, float compare ) {
		return step( compare, unpackRGBAToDepth( texture2D( depths, uv ) ) );
	}
	vec2 texture2DDistribution( sampler2D shadow, vec2 uv ) {
		return unpackRGBATo2Half( texture2D( shadow, uv ) );
	}
	float VSMShadow (sampler2D shadow, vec2 uv, float compare ){
		float occlusion = 1.0;
		vec2 distribution = texture2DDistribution( shadow, uv );
		float hard_shadow = step( compare , distribution.x );
		if (hard_shadow != 1.0 ) {
			float distance = compare - distribution.x ;
			float variance = max( 0.00000, distribution.y * distribution.y );
			float softness_probability = variance / (variance + distance * distance );			softness_probability = clamp( ( softness_probability - 0.3 ) / ( 0.95 - 0.3 ), 0.0, 1.0 );			occlusion = clamp( max( hard_shadow, softness_probability ), 0.0, 1.0 );
		}
		return occlusion;
	}
	float getShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowBias, float shadowRadius, vec4 shadowCoord ) {
		float shadow = 1.0;
		shadowCoord.xyz /= shadowCoord.w;
		shadowCoord.z += shadowBias;
		bool inFrustum = shadowCoord.x >= 0.0 && shadowCoord.x <= 1.0 && shadowCoord.y >= 0.0 && shadowCoord.y <= 1.0;
		bool frustumTest = inFrustum && shadowCoord.z <= 1.0;
		if ( frustumTest ) {
		#if defined( SHADOWMAP_TYPE_PCF )
			vec2 texelSize = vec2( 1.0 ) / shadowMapSize;
			float dx0 = - texelSize.x * shadowRadius;
			float dy0 = - texelSize.y * shadowRadius;
			float dx1 = + texelSize.x * shadowRadius;
			float dy1 = + texelSize.y * shadowRadius;
			float dx2 = dx0 / 2.0;
			float dy2 = dy0 / 2.0;
			float dx3 = dx1 / 2.0;
			float dy3 = dy1 / 2.0;
			shadow = (
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, dy0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, dy0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx2, dy2 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy2 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx3, dy2 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx2, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy, shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx3, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx2, dy3 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy3 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx3, dy3 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, dy1 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy1 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, dy1 ), shadowCoord.z )
			) * ( 1.0 / 17.0 );
		#elif defined( SHADOWMAP_TYPE_PCF_SOFT )
			vec2 texelSize = vec2( 1.0 ) / shadowMapSize;
			float dx = texelSize.x;
			float dy = texelSize.y;
			vec2 uv = shadowCoord.xy;
			vec2 f = fract( uv * shadowMapSize + 0.5 );
			uv -= f * texelSize;
			shadow = (
				texture2DCompare( shadowMap, uv, shadowCoord.z ) +
				texture2DCompare( shadowMap, uv + vec2( dx, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, uv + vec2( 0.0, dy ), shadowCoord.z ) +
				texture2DCompare( shadowMap, uv + texelSize, shadowCoord.z ) +
				mix( texture2DCompare( shadowMap, uv + vec2( -dx, 0.0 ), shadowCoord.z ),
					 texture2DCompare( shadowMap, uv + vec2( 2.0 * dx, 0.0 ), shadowCoord.z ),
					 f.x ) +
				mix( texture2DCompare( shadowMap, uv + vec2( -dx, dy ), shadowCoord.z ),
					 texture2DCompare( shadowMap, uv + vec2( 2.0 * dx, dy ), shadowCoord.z ),
					 f.x ) +
				mix( texture2DCompare( shadowMap, uv + vec2( 0.0, -dy ), shadowCoord.z ),
					 texture2DCompare( shadowMap, uv + vec2( 0.0, 2.0 * dy ), shadowCoord.z ),
					 f.y ) +
				mix( texture2DCompare( shadowMap, uv + vec2( dx, -dy ), shadowCoord.z ),
					 texture2DCompare( shadowMap, uv + vec2( dx, 2.0 * dy ), shadowCoord.z ),
					 f.y ) +
				mix( mix( texture2DCompare( shadowMap, uv + vec2( -dx, -dy ), shadowCoord.z ),
						  texture2DCompare( shadowMap, uv + vec2( 2.0 * dx, -dy ), shadowCoord.z ),
						  f.x ),
					 mix( texture2DCompare( shadowMap, uv + vec2( -dx, 2.0 * dy ), shadowCoord.z ),
						  texture2DCompare( shadowMap, uv + vec2( 2.0 * dx, 2.0 * dy ), shadowCoord.z ),
						  f.x ),
					 f.y )
			) * ( 1.0 / 9.0 );
		#elif defined( SHADOWMAP_TYPE_VSM )
			shadow = VSMShadow( shadowMap, shadowCoord.xy, shadowCoord.z );
		#else
			shadow = texture2DCompare( shadowMap, shadowCoord.xy, shadowCoord.z );
		#endif
		}
		return shadow;
	}
	vec2 cubeToUV( vec3 v, float texelSizeY ) {
		vec3 absV = abs( v );
		float scaleToCube = 1.0 / max( absV.x, max( absV.y, absV.z ) );
		absV *= scaleToCube;
		v *= scaleToCube * ( 1.0 - 2.0 * texelSizeY );
		vec2 planar = v.xy;
		float almostATexel = 1.5 * texelSizeY;
		float almostOne = 1.0 - almostATexel;
		if ( absV.z >= almostOne ) {
			if ( v.z > 0.0 )
				planar.x = 4.0 - v.x;
		} else if ( absV.x >= almostOne ) {
			float signX = sign( v.x );
			planar.x = v.z * signX + 2.0 * signX;
		} else if ( absV.y >= almostOne ) {
			float signY = sign( v.y );
			planar.x = v.x + 2.0 * signY + 2.0;
			planar.y = v.z * signY - 2.0;
		}
		return vec2( 0.125, 0.25 ) * planar + vec2( 0.375, 0.75 );
	}
	float getPointShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowBias, float shadowRadius, vec4 shadowCoord, float shadowCameraNear, float shadowCameraFar ) {
		vec2 texelSize = vec2( 1.0 ) / ( shadowMapSize * vec2( 4.0, 2.0 ) );
		vec3 lightToPosition = shadowCoord.xyz;
		float dp = ( length( lightToPosition ) - shadowCameraNear ) / ( shadowCameraFar - shadowCameraNear );		dp += shadowBias;
		vec3 bd3D = normalize( lightToPosition );
		#if defined( SHADOWMAP_TYPE_PCF ) || defined( SHADOWMAP_TYPE_PCF_SOFT ) || defined( SHADOWMAP_TYPE_VSM )
			vec2 offset = vec2( - 1, 1 ) * shadowRadius * texelSize.y;
			return (
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xyy, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yyy, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xyx, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yyx, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xxy, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yxy, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xxx, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yxx, texelSize.y ), dp )
			) * ( 1.0 / 9.0 );
		#else
			return texture2DCompare( shadowMap, cubeToUV( bd3D, texelSize.y ), dp );
		#endif
	}
#endif`,Id=`#if NUM_SPOT_LIGHT_COORDS > 0
	uniform mat4 spotLightMatrix[ NUM_SPOT_LIGHT_COORDS ];
	varying vec4 vSpotLightCoord[ NUM_SPOT_LIGHT_COORDS ];
#endif
#ifdef USE_SHADOWMAP
	#if NUM_DIR_LIGHT_SHADOWS > 0
		uniform mat4 directionalShadowMatrix[ NUM_DIR_LIGHT_SHADOWS ];
		varying vec4 vDirectionalShadowCoord[ NUM_DIR_LIGHT_SHADOWS ];
		struct DirectionalLightShadow {
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform DirectionalLightShadow directionalLightShadows[ NUM_DIR_LIGHT_SHADOWS ];
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
		struct SpotLightShadow {
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform SpotLightShadow spotLightShadows[ NUM_SPOT_LIGHT_SHADOWS ];
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		uniform mat4 pointShadowMatrix[ NUM_POINT_LIGHT_SHADOWS ];
		varying vec4 vPointShadowCoord[ NUM_POINT_LIGHT_SHADOWS ];
		struct PointLightShadow {
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
			float shadowCameraNear;
			float shadowCameraFar;
		};
		uniform PointLightShadow pointLightShadows[ NUM_POINT_LIGHT_SHADOWS ];
	#endif
#endif`,Ud=`#if ( defined( USE_SHADOWMAP ) && ( NUM_DIR_LIGHT_SHADOWS > 0 || NUM_POINT_LIGHT_SHADOWS > 0 ) ) || ( NUM_SPOT_LIGHT_COORDS > 0 )
	vec3 shadowWorldNormal = inverseTransformDirection( transformedNormal, viewMatrix );
	vec4 shadowWorldPosition;
#endif
#if defined( USE_SHADOWMAP )
	#if NUM_DIR_LIGHT_SHADOWS > 0
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_DIR_LIGHT_SHADOWS; i ++ ) {
			shadowWorldPosition = worldPosition + vec4( shadowWorldNormal * directionalLightShadows[ i ].shadowNormalBias, 0 );
			vDirectionalShadowCoord[ i ] = directionalShadowMatrix[ i ] * shadowWorldPosition;
		}
		#pragma unroll_loop_end
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_POINT_LIGHT_SHADOWS; i ++ ) {
			shadowWorldPosition = worldPosition + vec4( shadowWorldNormal * pointLightShadows[ i ].shadowNormalBias, 0 );
			vPointShadowCoord[ i ] = pointShadowMatrix[ i ] * shadowWorldPosition;
		}
		#pragma unroll_loop_end
	#endif
#endif
#if NUM_SPOT_LIGHT_COORDS > 0
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHT_COORDS; i ++ ) {
		shadowWorldPosition = worldPosition;
		#if ( defined( USE_SHADOWMAP ) && UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
			shadowWorldPosition.xyz += shadowWorldNormal * spotLightShadows[ i ].shadowNormalBias;
		#endif
		vSpotLightCoord[ i ] = spotLightMatrix[ i ] * shadowWorldPosition;
	}
	#pragma unroll_loop_end
#endif`,Nd=`float getShadowMask() {
	float shadow = 1.0;
	#ifdef USE_SHADOWMAP
	#if NUM_DIR_LIGHT_SHADOWS > 0
	DirectionalLightShadow directionalLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_DIR_LIGHT_SHADOWS; i ++ ) {
		directionalLight = directionalLightShadows[ i ];
		shadow *= receiveShadow ? getShadow( directionalShadowMap[ i ], directionalLight.shadowMapSize, directionalLight.shadowBias, directionalLight.shadowRadius, vDirectionalShadowCoord[ i ] ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
	SpotLightShadow spotLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHT_SHADOWS; i ++ ) {
		spotLight = spotLightShadows[ i ];
		shadow *= receiveShadow ? getShadow( spotShadowMap[ i ], spotLight.shadowMapSize, spotLight.shadowBias, spotLight.shadowRadius, vSpotLightCoord[ i ] ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
	PointLightShadow pointLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_POINT_LIGHT_SHADOWS; i ++ ) {
		pointLight = pointLightShadows[ i ];
		shadow *= receiveShadow ? getPointShadow( pointShadowMap[ i ], pointLight.shadowMapSize, pointLight.shadowBias, pointLight.shadowRadius, vPointShadowCoord[ i ], pointLight.shadowCameraNear, pointLight.shadowCameraFar ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#endif
	return shadow;
}`,Od=`#ifdef USE_SKINNING
	mat4 boneMatX = getBoneMatrix( skinIndex.x );
	mat4 boneMatY = getBoneMatrix( skinIndex.y );
	mat4 boneMatZ = getBoneMatrix( skinIndex.z );
	mat4 boneMatW = getBoneMatrix( skinIndex.w );
#endif`,Fd=`#ifdef USE_SKINNING
	uniform mat4 bindMatrix;
	uniform mat4 bindMatrixInverse;
	uniform highp sampler2D boneTexture;
	mat4 getBoneMatrix( const in float i ) {
		int size = textureSize( boneTexture, 0 ).x;
		int j = int( i ) * 4;
		int x = j % size;
		int y = j / size;
		vec4 v1 = texelFetch( boneTexture, ivec2( x, y ), 0 );
		vec4 v2 = texelFetch( boneTexture, ivec2( x + 1, y ), 0 );
		vec4 v3 = texelFetch( boneTexture, ivec2( x + 2, y ), 0 );
		vec4 v4 = texelFetch( boneTexture, ivec2( x + 3, y ), 0 );
		return mat4( v1, v2, v3, v4 );
	}
#endif`,Bd=`#ifdef USE_SKINNING
	vec4 skinVertex = bindMatrix * vec4( transformed, 1.0 );
	vec4 skinned = vec4( 0.0 );
	skinned += boneMatX * skinVertex * skinWeight.x;
	skinned += boneMatY * skinVertex * skinWeight.y;
	skinned += boneMatZ * skinVertex * skinWeight.z;
	skinned += boneMatW * skinVertex * skinWeight.w;
	transformed = ( bindMatrixInverse * skinned ).xyz;
#endif`,zd=`#ifdef USE_SKINNING
	mat4 skinMatrix = mat4( 0.0 );
	skinMatrix += skinWeight.x * boneMatX;
	skinMatrix += skinWeight.y * boneMatY;
	skinMatrix += skinWeight.z * boneMatZ;
	skinMatrix += skinWeight.w * boneMatW;
	skinMatrix = bindMatrixInverse * skinMatrix * bindMatrix;
	objectNormal = vec4( skinMatrix * vec4( objectNormal, 0.0 ) ).xyz;
	#ifdef USE_TANGENT
		objectTangent = vec4( skinMatrix * vec4( objectTangent, 0.0 ) ).xyz;
	#endif
#endif`,Gd=`float specularStrength;
#ifdef USE_SPECULARMAP
	vec4 texelSpecular = texture2D( specularMap, vSpecularMapUv );
	specularStrength = texelSpecular.r;
#else
	specularStrength = 1.0;
#endif`,kd=`#ifdef USE_SPECULARMAP
	uniform sampler2D specularMap;
#endif`,Hd=`#if defined( TONE_MAPPING )
	gl_FragColor.rgb = toneMapping( gl_FragColor.rgb );
#endif`,Vd=`#ifndef saturate
#define saturate( a ) clamp( a, 0.0, 1.0 )
#endif
uniform float toneMappingExposure;
vec3 LinearToneMapping( vec3 color ) {
	return saturate( toneMappingExposure * color );
}
vec3 ReinhardToneMapping( vec3 color ) {
	color *= toneMappingExposure;
	return saturate( color / ( vec3( 1.0 ) + color ) );
}
vec3 OptimizedCineonToneMapping( vec3 color ) {
	color *= toneMappingExposure;
	color = max( vec3( 0.0 ), color - 0.004 );
	return pow( ( color * ( 6.2 * color + 0.5 ) ) / ( color * ( 6.2 * color + 1.7 ) + 0.06 ), vec3( 2.2 ) );
}
vec3 RRTAndODTFit( vec3 v ) {
	vec3 a = v * ( v + 0.0245786 ) - 0.000090537;
	vec3 b = v * ( 0.983729 * v + 0.4329510 ) + 0.238081;
	return a / b;
}
vec3 ACESFilmicToneMapping( vec3 color ) {
	const mat3 ACESInputMat = mat3(
		vec3( 0.59719, 0.07600, 0.02840 ),		vec3( 0.35458, 0.90834, 0.13383 ),
		vec3( 0.04823, 0.01566, 0.83777 )
	);
	const mat3 ACESOutputMat = mat3(
		vec3(  1.60475, -0.10208, -0.00327 ),		vec3( -0.53108,  1.10813, -0.07276 ),
		vec3( -0.07367, -0.00605,  1.07602 )
	);
	color *= toneMappingExposure / 0.6;
	color = ACESInputMat * color;
	color = RRTAndODTFit( color );
	color = ACESOutputMat * color;
	return saturate( color );
}
const mat3 LINEAR_REC2020_TO_LINEAR_SRGB = mat3(
	vec3( 1.6605, - 0.1246, - 0.0182 ),
	vec3( - 0.5876, 1.1329, - 0.1006 ),
	vec3( - 0.0728, - 0.0083, 1.1187 )
);
const mat3 LINEAR_SRGB_TO_LINEAR_REC2020 = mat3(
	vec3( 0.6274, 0.0691, 0.0164 ),
	vec3( 0.3293, 0.9195, 0.0880 ),
	vec3( 0.0433, 0.0113, 0.8956 )
);
vec3 agxDefaultContrastApprox( vec3 x ) {
	vec3 x2 = x * x;
	vec3 x4 = x2 * x2;
	return + 15.5 * x4 * x2
		- 40.14 * x4 * x
		+ 31.96 * x4
		- 6.868 * x2 * x
		+ 0.4298 * x2
		+ 0.1191 * x
		- 0.00232;
}
vec3 AgXToneMapping( vec3 color ) {
	const mat3 AgXInsetMatrix = mat3(
		vec3( 0.856627153315983, 0.137318972929847, 0.11189821299995 ),
		vec3( 0.0951212405381588, 0.761241990602591, 0.0767994186031903 ),
		vec3( 0.0482516061458583, 0.101439036467562, 0.811302368396859 )
	);
	const mat3 AgXOutsetMatrix = mat3(
		vec3( 1.1271005818144368, - 0.1413297634984383, - 0.14132976349843826 ),
		vec3( - 0.11060664309660323, 1.157823702216272, - 0.11060664309660294 ),
		vec3( - 0.016493938717834573, - 0.016493938717834257, 1.2519364065950405 )
	);
	const float AgxMinEv = - 12.47393;	const float AgxMaxEv = 4.026069;
	color = LINEAR_SRGB_TO_LINEAR_REC2020 * color;
	color *= toneMappingExposure;
	color = AgXInsetMatrix * color;
	color = max( color, 1e-10 );	color = log2( color );
	color = ( color - AgxMinEv ) / ( AgxMaxEv - AgxMinEv );
	color = clamp( color, 0.0, 1.0 );
	color = agxDefaultContrastApprox( color );
	color = AgXOutsetMatrix * color;
	color = pow( max( vec3( 0.0 ), color ), vec3( 2.2 ) );
	color = LINEAR_REC2020_TO_LINEAR_SRGB * color;
	return color;
}
vec3 CustomToneMapping( vec3 color ) { return color; }`,Xd=`#ifdef USE_TRANSMISSION
	material.transmission = transmission;
	material.transmissionAlpha = 1.0;
	material.thickness = thickness;
	material.attenuationDistance = attenuationDistance;
	material.attenuationColor = attenuationColor;
	#ifdef USE_TRANSMISSIONMAP
		material.transmission *= texture2D( transmissionMap, vTransmissionMapUv ).r;
	#endif
	#ifdef USE_THICKNESSMAP
		material.thickness *= texture2D( thicknessMap, vThicknessMapUv ).g;
	#endif
	vec3 pos = vWorldPosition;
	vec3 v = normalize( cameraPosition - pos );
	vec3 n = inverseTransformDirection( normal, viewMatrix );
	vec4 transmitted = getIBLVolumeRefraction(
		n, v, material.roughness, material.diffuseColor, material.specularColor, material.specularF90,
		pos, modelMatrix, viewMatrix, projectionMatrix, material.ior, material.thickness,
		material.attenuationColor, material.attenuationDistance );
	material.transmissionAlpha = mix( material.transmissionAlpha, transmitted.a, material.transmission );
	totalDiffuse = mix( totalDiffuse, transmitted.rgb, material.transmission );
#endif`,Wd=`#ifdef USE_TRANSMISSION
	uniform float transmission;
	uniform float thickness;
	uniform float attenuationDistance;
	uniform vec3 attenuationColor;
	#ifdef USE_TRANSMISSIONMAP
		uniform sampler2D transmissionMap;
	#endif
	#ifdef USE_THICKNESSMAP
		uniform sampler2D thicknessMap;
	#endif
	uniform vec2 transmissionSamplerSize;
	uniform sampler2D transmissionSamplerMap;
	uniform mat4 modelMatrix;
	uniform mat4 projectionMatrix;
	varying vec3 vWorldPosition;
	float w0( float a ) {
		return ( 1.0 / 6.0 ) * ( a * ( a * ( - a + 3.0 ) - 3.0 ) + 1.0 );
	}
	float w1( float a ) {
		return ( 1.0 / 6.0 ) * ( a *  a * ( 3.0 * a - 6.0 ) + 4.0 );
	}
	float w2( float a ){
		return ( 1.0 / 6.0 ) * ( a * ( a * ( - 3.0 * a + 3.0 ) + 3.0 ) + 1.0 );
	}
	float w3( float a ) {
		return ( 1.0 / 6.0 ) * ( a * a * a );
	}
	float g0( float a ) {
		return w0( a ) + w1( a );
	}
	float g1( float a ) {
		return w2( a ) + w3( a );
	}
	float h0( float a ) {
		return - 1.0 + w1( a ) / ( w0( a ) + w1( a ) );
	}
	float h1( float a ) {
		return 1.0 + w3( a ) / ( w2( a ) + w3( a ) );
	}
	vec4 bicubic( sampler2D tex, vec2 uv, vec4 texelSize, float lod ) {
		uv = uv * texelSize.zw + 0.5;
		vec2 iuv = floor( uv );
		vec2 fuv = fract( uv );
		float g0x = g0( fuv.x );
		float g1x = g1( fuv.x );
		float h0x = h0( fuv.x );
		float h1x = h1( fuv.x );
		float h0y = h0( fuv.y );
		float h1y = h1( fuv.y );
		vec2 p0 = ( vec2( iuv.x + h0x, iuv.y + h0y ) - 0.5 ) * texelSize.xy;
		vec2 p1 = ( vec2( iuv.x + h1x, iuv.y + h0y ) - 0.5 ) * texelSize.xy;
		vec2 p2 = ( vec2( iuv.x + h0x, iuv.y + h1y ) - 0.5 ) * texelSize.xy;
		vec2 p3 = ( vec2( iuv.x + h1x, iuv.y + h1y ) - 0.5 ) * texelSize.xy;
		return g0( fuv.y ) * ( g0x * textureLod( tex, p0, lod ) + g1x * textureLod( tex, p1, lod ) ) +
			g1( fuv.y ) * ( g0x * textureLod( tex, p2, lod ) + g1x * textureLod( tex, p3, lod ) );
	}
	vec4 textureBicubic( sampler2D sampler, vec2 uv, float lod ) {
		vec2 fLodSize = vec2( textureSize( sampler, int( lod ) ) );
		vec2 cLodSize = vec2( textureSize( sampler, int( lod + 1.0 ) ) );
		vec2 fLodSizeInv = 1.0 / fLodSize;
		vec2 cLodSizeInv = 1.0 / cLodSize;
		vec4 fSample = bicubic( sampler, uv, vec4( fLodSizeInv, fLodSize ), floor( lod ) );
		vec4 cSample = bicubic( sampler, uv, vec4( cLodSizeInv, cLodSize ), ceil( lod ) );
		return mix( fSample, cSample, fract( lod ) );
	}
	vec3 getVolumeTransmissionRay( const in vec3 n, const in vec3 v, const in float thickness, const in float ior, const in mat4 modelMatrix ) {
		vec3 refractionVector = refract( - v, normalize( n ), 1.0 / ior );
		vec3 modelScale;
		modelScale.x = length( vec3( modelMatrix[ 0 ].xyz ) );
		modelScale.y = length( vec3( modelMatrix[ 1 ].xyz ) );
		modelScale.z = length( vec3( modelMatrix[ 2 ].xyz ) );
		return normalize( refractionVector ) * thickness * modelScale;
	}
	float applyIorToRoughness( const in float roughness, const in float ior ) {
		return roughness * clamp( ior * 2.0 - 2.0, 0.0, 1.0 );
	}
	vec4 getTransmissionSample( const in vec2 fragCoord, const in float roughness, const in float ior ) {
		float lod = log2( transmissionSamplerSize.x ) * applyIorToRoughness( roughness, ior );
		return textureBicubic( transmissionSamplerMap, fragCoord.xy, lod );
	}
	vec3 volumeAttenuation( const in float transmissionDistance, const in vec3 attenuationColor, const in float attenuationDistance ) {
		if ( isinf( attenuationDistance ) ) {
			return vec3( 1.0 );
		} else {
			vec3 attenuationCoefficient = -log( attenuationColor ) / attenuationDistance;
			vec3 transmittance = exp( - attenuationCoefficient * transmissionDistance );			return transmittance;
		}
	}
	vec4 getIBLVolumeRefraction( const in vec3 n, const in vec3 v, const in float roughness, const in vec3 diffuseColor,
		const in vec3 specularColor, const in float specularF90, const in vec3 position, const in mat4 modelMatrix,
		const in mat4 viewMatrix, const in mat4 projMatrix, const in float ior, const in float thickness,
		const in vec3 attenuationColor, const in float attenuationDistance ) {
		vec3 transmissionRay = getVolumeTransmissionRay( n, v, thickness, ior, modelMatrix );
		vec3 refractedRayExit = position + transmissionRay;
		vec4 ndcPos = projMatrix * viewMatrix * vec4( refractedRayExit, 1.0 );
		vec2 refractionCoords = ndcPos.xy / ndcPos.w;
		refractionCoords += 1.0;
		refractionCoords /= 2.0;
		vec4 transmittedLight = getTransmissionSample( refractionCoords, roughness, ior );
		vec3 transmittance = diffuseColor * volumeAttenuation( length( transmissionRay ), attenuationColor, attenuationDistance );
		vec3 attenuatedColor = transmittance * transmittedLight.rgb;
		vec3 F = EnvironmentBRDF( n, v, specularColor, specularF90, roughness );
		float transmittanceFactor = ( transmittance.r + transmittance.g + transmittance.b ) / 3.0;
		return vec4( ( 1.0 - F ) * attenuatedColor, 1.0 - ( 1.0 - transmittedLight.a ) * transmittanceFactor );
	}
#endif`,qd=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	varying vec2 vUv;
#endif
#ifdef USE_MAP
	varying vec2 vMapUv;
#endif
#ifdef USE_ALPHAMAP
	varying vec2 vAlphaMapUv;
#endif
#ifdef USE_LIGHTMAP
	varying vec2 vLightMapUv;
#endif
#ifdef USE_AOMAP
	varying vec2 vAoMapUv;
#endif
#ifdef USE_BUMPMAP
	varying vec2 vBumpMapUv;
#endif
#ifdef USE_NORMALMAP
	varying vec2 vNormalMapUv;
#endif
#ifdef USE_EMISSIVEMAP
	varying vec2 vEmissiveMapUv;
#endif
#ifdef USE_METALNESSMAP
	varying vec2 vMetalnessMapUv;
#endif
#ifdef USE_ROUGHNESSMAP
	varying vec2 vRoughnessMapUv;
#endif
#ifdef USE_ANISOTROPYMAP
	varying vec2 vAnisotropyMapUv;
#endif
#ifdef USE_CLEARCOATMAP
	varying vec2 vClearcoatMapUv;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	varying vec2 vClearcoatNormalMapUv;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	varying vec2 vClearcoatRoughnessMapUv;
#endif
#ifdef USE_IRIDESCENCEMAP
	varying vec2 vIridescenceMapUv;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	varying vec2 vIridescenceThicknessMapUv;
#endif
#ifdef USE_SHEEN_COLORMAP
	varying vec2 vSheenColorMapUv;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	varying vec2 vSheenRoughnessMapUv;
#endif
#ifdef USE_SPECULARMAP
	varying vec2 vSpecularMapUv;
#endif
#ifdef USE_SPECULAR_COLORMAP
	varying vec2 vSpecularColorMapUv;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	varying vec2 vSpecularIntensityMapUv;
#endif
#ifdef USE_TRANSMISSIONMAP
	uniform mat3 transmissionMapTransform;
	varying vec2 vTransmissionMapUv;
#endif
#ifdef USE_THICKNESSMAP
	uniform mat3 thicknessMapTransform;
	varying vec2 vThicknessMapUv;
#endif`,Yd=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	varying vec2 vUv;
#endif
#ifdef USE_MAP
	uniform mat3 mapTransform;
	varying vec2 vMapUv;
#endif
#ifdef USE_ALPHAMAP
	uniform mat3 alphaMapTransform;
	varying vec2 vAlphaMapUv;
#endif
#ifdef USE_LIGHTMAP
	uniform mat3 lightMapTransform;
	varying vec2 vLightMapUv;
#endif
#ifdef USE_AOMAP
	uniform mat3 aoMapTransform;
	varying vec2 vAoMapUv;
#endif
#ifdef USE_BUMPMAP
	uniform mat3 bumpMapTransform;
	varying vec2 vBumpMapUv;
#endif
#ifdef USE_NORMALMAP
	uniform mat3 normalMapTransform;
	varying vec2 vNormalMapUv;
#endif
#ifdef USE_DISPLACEMENTMAP
	uniform mat3 displacementMapTransform;
	varying vec2 vDisplacementMapUv;
#endif
#ifdef USE_EMISSIVEMAP
	uniform mat3 emissiveMapTransform;
	varying vec2 vEmissiveMapUv;
#endif
#ifdef USE_METALNESSMAP
	uniform mat3 metalnessMapTransform;
	varying vec2 vMetalnessMapUv;
#endif
#ifdef USE_ROUGHNESSMAP
	uniform mat3 roughnessMapTransform;
	varying vec2 vRoughnessMapUv;
#endif
#ifdef USE_ANISOTROPYMAP
	uniform mat3 anisotropyMapTransform;
	varying vec2 vAnisotropyMapUv;
#endif
#ifdef USE_CLEARCOATMAP
	uniform mat3 clearcoatMapTransform;
	varying vec2 vClearcoatMapUv;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	uniform mat3 clearcoatNormalMapTransform;
	varying vec2 vClearcoatNormalMapUv;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	uniform mat3 clearcoatRoughnessMapTransform;
	varying vec2 vClearcoatRoughnessMapUv;
#endif
#ifdef USE_SHEEN_COLORMAP
	uniform mat3 sheenColorMapTransform;
	varying vec2 vSheenColorMapUv;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	uniform mat3 sheenRoughnessMapTransform;
	varying vec2 vSheenRoughnessMapUv;
#endif
#ifdef USE_IRIDESCENCEMAP
	uniform mat3 iridescenceMapTransform;
	varying vec2 vIridescenceMapUv;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	uniform mat3 iridescenceThicknessMapTransform;
	varying vec2 vIridescenceThicknessMapUv;
#endif
#ifdef USE_SPECULARMAP
	uniform mat3 specularMapTransform;
	varying vec2 vSpecularMapUv;
#endif
#ifdef USE_SPECULAR_COLORMAP
	uniform mat3 specularColorMapTransform;
	varying vec2 vSpecularColorMapUv;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	uniform mat3 specularIntensityMapTransform;
	varying vec2 vSpecularIntensityMapUv;
#endif
#ifdef USE_TRANSMISSIONMAP
	uniform mat3 transmissionMapTransform;
	varying vec2 vTransmissionMapUv;
#endif
#ifdef USE_THICKNESSMAP
	uniform mat3 thicknessMapTransform;
	varying vec2 vThicknessMapUv;
#endif`,jd=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	vUv = vec3( uv, 1 ).xy;
#endif
#ifdef USE_MAP
	vMapUv = ( mapTransform * vec3( MAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ALPHAMAP
	vAlphaMapUv = ( alphaMapTransform * vec3( ALPHAMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_LIGHTMAP
	vLightMapUv = ( lightMapTransform * vec3( LIGHTMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_AOMAP
	vAoMapUv = ( aoMapTransform * vec3( AOMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_BUMPMAP
	vBumpMapUv = ( bumpMapTransform * vec3( BUMPMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_NORMALMAP
	vNormalMapUv = ( normalMapTransform * vec3( NORMALMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_DISPLACEMENTMAP
	vDisplacementMapUv = ( displacementMapTransform * vec3( DISPLACEMENTMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_EMISSIVEMAP
	vEmissiveMapUv = ( emissiveMapTransform * vec3( EMISSIVEMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_METALNESSMAP
	vMetalnessMapUv = ( metalnessMapTransform * vec3( METALNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ROUGHNESSMAP
	vRoughnessMapUv = ( roughnessMapTransform * vec3( ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ANISOTROPYMAP
	vAnisotropyMapUv = ( anisotropyMapTransform * vec3( ANISOTROPYMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOATMAP
	vClearcoatMapUv = ( clearcoatMapTransform * vec3( CLEARCOATMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	vClearcoatNormalMapUv = ( clearcoatNormalMapTransform * vec3( CLEARCOAT_NORMALMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	vClearcoatRoughnessMapUv = ( clearcoatRoughnessMapTransform * vec3( CLEARCOAT_ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_IRIDESCENCEMAP
	vIridescenceMapUv = ( iridescenceMapTransform * vec3( IRIDESCENCEMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	vIridescenceThicknessMapUv = ( iridescenceThicknessMapTransform * vec3( IRIDESCENCE_THICKNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SHEEN_COLORMAP
	vSheenColorMapUv = ( sheenColorMapTransform * vec3( SHEEN_COLORMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	vSheenRoughnessMapUv = ( sheenRoughnessMapTransform * vec3( SHEEN_ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULARMAP
	vSpecularMapUv = ( specularMapTransform * vec3( SPECULARMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULAR_COLORMAP
	vSpecularColorMapUv = ( specularColorMapTransform * vec3( SPECULAR_COLORMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	vSpecularIntensityMapUv = ( specularIntensityMapTransform * vec3( SPECULAR_INTENSITYMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_TRANSMISSIONMAP
	vTransmissionMapUv = ( transmissionMapTransform * vec3( TRANSMISSIONMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_THICKNESSMAP
	vThicknessMapUv = ( thicknessMapTransform * vec3( THICKNESSMAP_UV, 1 ) ).xy;
#endif`,$d=`#if defined( USE_ENVMAP ) || defined( DISTANCE ) || defined ( USE_SHADOWMAP ) || defined ( USE_TRANSMISSION ) || NUM_SPOT_LIGHT_COORDS > 0
	vec4 worldPosition = vec4( transformed, 1.0 );
	#ifdef USE_BATCHING
		worldPosition = batchingMatrix * worldPosition;
	#endif
	#ifdef USE_INSTANCING
		worldPosition = instanceMatrix * worldPosition;
	#endif
	worldPosition = modelMatrix * worldPosition;
#endif`;const Kd=`varying vec2 vUv;
uniform mat3 uvTransform;
void main() {
	vUv = ( uvTransform * vec3( uv, 1 ) ).xy;
	gl_Position = vec4( position.xy, 1.0, 1.0 );
}`,Zd=`uniform sampler2D t2D;
uniform float backgroundIntensity;
varying vec2 vUv;
void main() {
	vec4 texColor = texture2D( t2D, vUv );
	#ifdef DECODE_VIDEO_TEXTURE
		texColor = vec4( mix( pow( texColor.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), texColor.rgb * 0.0773993808, vec3( lessThanEqual( texColor.rgb, vec3( 0.04045 ) ) ) ), texColor.w );
	#endif
	texColor.rgb *= backgroundIntensity;
	gl_FragColor = texColor;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,Jd=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
	gl_Position.z = gl_Position.w;
}`,Qd=`#ifdef ENVMAP_TYPE_CUBE
	uniform samplerCube envMap;
#elif defined( ENVMAP_TYPE_CUBE_UV )
	uniform sampler2D envMap;
#endif
uniform float flipEnvMap;
uniform float backgroundBlurriness;
uniform float backgroundIntensity;
varying vec3 vWorldDirection;
#include <cube_uv_reflection_fragment>
void main() {
	#ifdef ENVMAP_TYPE_CUBE
		vec4 texColor = textureCube( envMap, vec3( flipEnvMap * vWorldDirection.x, vWorldDirection.yz ) );
	#elif defined( ENVMAP_TYPE_CUBE_UV )
		vec4 texColor = textureCubeUV( envMap, vWorldDirection, backgroundBlurriness );
	#else
		vec4 texColor = vec4( 0.0, 0.0, 0.0, 1.0 );
	#endif
	texColor.rgb *= backgroundIntensity;
	gl_FragColor = texColor;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,tf=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
	gl_Position.z = gl_Position.w;
}`,ef=`uniform samplerCube tCube;
uniform float tFlip;
uniform float opacity;
varying vec3 vWorldDirection;
void main() {
	vec4 texColor = textureCube( tCube, vec3( tFlip * vWorldDirection.x, vWorldDirection.yz ) );
	gl_FragColor = texColor;
	gl_FragColor.a *= opacity;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,nf=`#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
varying vec2 vHighPrecisionZW;
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <skinbase_vertex>
	#ifdef USE_DISPLACEMENTMAP
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vHighPrecisionZW = gl_Position.zw;
}`,rf=`#if DEPTH_PACKING == 3200
	uniform float opacity;
#endif
#include <common>
#include <packing>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
varying vec2 vHighPrecisionZW;
void main() {
	#include <clipping_planes_fragment>
	vec4 diffuseColor = vec4( 1.0 );
	#if DEPTH_PACKING == 3200
		diffuseColor.a = opacity;
	#endif
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <logdepthbuf_fragment>
	float fragCoordZ = 0.5 * vHighPrecisionZW[0] / vHighPrecisionZW[1] + 0.5;
	#if DEPTH_PACKING == 3200
		gl_FragColor = vec4( vec3( 1.0 - fragCoordZ ), opacity );
	#elif DEPTH_PACKING == 3201
		gl_FragColor = packDepthToRGBA( fragCoordZ );
	#endif
}`,sf=`#define DISTANCE
varying vec3 vWorldPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <skinbase_vertex>
	#ifdef USE_DISPLACEMENTMAP
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <worldpos_vertex>
	#include <clipping_planes_vertex>
	vWorldPosition = worldPosition.xyz;
}`,of=`#define DISTANCE
uniform vec3 referencePosition;
uniform float nearDistance;
uniform float farDistance;
varying vec3 vWorldPosition;
#include <common>
#include <packing>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <clipping_planes_pars_fragment>
void main () {
	#include <clipping_planes_fragment>
	vec4 diffuseColor = vec4( 1.0 );
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	float dist = length( vWorldPosition - referencePosition );
	dist = ( dist - nearDistance ) / ( farDistance - nearDistance );
	dist = saturate( dist );
	gl_FragColor = packDepthToRGBA( dist );
}`,af=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
}`,cf=`uniform sampler2D tEquirect;
varying vec3 vWorldDirection;
#include <common>
void main() {
	vec3 direction = normalize( vWorldDirection );
	vec2 sampleUV = equirectUv( direction );
	gl_FragColor = texture2D( tEquirect, sampleUV );
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,lf=`uniform float scale;
attribute float lineDistance;
varying float vLineDistance;
#include <common>
#include <uv_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	vLineDistance = scale * lineDistance;
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
}`,uf=`uniform vec3 diffuse;
uniform float opacity;
uniform float dashSize;
uniform float totalSize;
varying float vLineDistance;
#include <common>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	if ( mod( vLineDistance, totalSize ) > dashSize ) {
		discard;
	}
	vec3 outgoingLight = vec3( 0.0 );
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
}`,hf=`#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#if defined ( USE_ENVMAP ) || defined ( USE_SKINNING )
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinbase_vertex>
		#include <skinnormal_vertex>
		#include <defaultnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <fog_vertex>
}`,df=`uniform vec3 diffuse;
uniform float opacity;
#ifndef FLAT_SHADED
	varying vec3 vNormal;
#endif
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	#ifdef USE_LIGHTMAP
		vec4 lightMapTexel = texture2D( lightMap, vLightMapUv );
		reflectedLight.indirectDiffuse += lightMapTexel.rgb * lightMapIntensity * RECIPROCAL_PI;
	#else
		reflectedLight.indirectDiffuse += vec3( 1.0 );
	#endif
	#include <aomap_fragment>
	reflectedLight.indirectDiffuse *= diffuseColor.rgb;
	vec3 outgoingLight = reflectedLight.indirectDiffuse;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,ff=`#define LAMBERT
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,pf=`#define LAMBERT
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float opacity;
#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_lambert_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	vec4 diffuseColor = vec4( diffuse, opacity );
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_lambert_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + totalEmissiveRadiance;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,mf=`#define MATCAP
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <color_pars_vertex>
#include <displacementmap_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
	vViewPosition = - mvPosition.xyz;
}`,gf=`#define MATCAP
uniform vec3 diffuse;
uniform float opacity;
uniform sampler2D matcap;
varying vec3 vViewPosition;
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <normal_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	vec3 viewDir = normalize( vViewPosition );
	vec3 x = normalize( vec3( viewDir.z, 0.0, - viewDir.x ) );
	vec3 y = cross( viewDir, x );
	vec2 uv = vec2( dot( x, normal ), dot( y, normal ) ) * 0.495 + 0.5;
	#ifdef USE_MATCAP
		vec4 matcapColor = texture2D( matcap, uv );
	#else
		vec4 matcapColor = vec4( vec3( mix( 0.2, 0.8, uv.y ) ), 1.0 );
	#endif
	vec3 outgoingLight = diffuseColor.rgb * matcapColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,_f=`#define NORMAL
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	varying vec3 vViewPosition;
#endif
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	vViewPosition = - mvPosition.xyz;
#endif
}`,vf=`#define NORMAL
uniform float opacity;
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	varying vec3 vViewPosition;
#endif
#include <packing>
#include <uv_pars_fragment>
#include <normal_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	#include <logdepthbuf_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	gl_FragColor = vec4( packNormalToRGB( normal ), opacity );
	#ifdef OPAQUE
		gl_FragColor.a = 1.0;
	#endif
}`,xf=`#define PHONG
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,Mf=`#define PHONG
uniform vec3 diffuse;
uniform vec3 emissive;
uniform vec3 specular;
uniform float shininess;
uniform float opacity;
#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_phong_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	vec4 diffuseColor = vec4( diffuse, opacity );
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_phong_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + reflectedLight.directSpecular + reflectedLight.indirectSpecular + totalEmissiveRadiance;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,yf=`#define STANDARD
varying vec3 vViewPosition;
#ifdef USE_TRANSMISSION
	varying vec3 vWorldPosition;
#endif
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
#ifdef USE_TRANSMISSION
	vWorldPosition = worldPosition.xyz;
#endif
}`,Sf=`#define STANDARD
#ifdef PHYSICAL
	#define IOR
	#define USE_SPECULAR
#endif
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float roughness;
uniform float metalness;
uniform float opacity;
#ifdef IOR
	uniform float ior;
#endif
#ifdef USE_SPECULAR
	uniform float specularIntensity;
	uniform vec3 specularColor;
	#ifdef USE_SPECULAR_COLORMAP
		uniform sampler2D specularColorMap;
	#endif
	#ifdef USE_SPECULAR_INTENSITYMAP
		uniform sampler2D specularIntensityMap;
	#endif
#endif
#ifdef USE_CLEARCOAT
	uniform float clearcoat;
	uniform float clearcoatRoughness;
#endif
#ifdef USE_IRIDESCENCE
	uniform float iridescence;
	uniform float iridescenceIOR;
	uniform float iridescenceThicknessMinimum;
	uniform float iridescenceThicknessMaximum;
#endif
#ifdef USE_SHEEN
	uniform vec3 sheenColor;
	uniform float sheenRoughness;
	#ifdef USE_SHEEN_COLORMAP
		uniform sampler2D sheenColorMap;
	#endif
	#ifdef USE_SHEEN_ROUGHNESSMAP
		uniform sampler2D sheenRoughnessMap;
	#endif
#endif
#ifdef USE_ANISOTROPY
	uniform vec2 anisotropyVector;
	#ifdef USE_ANISOTROPYMAP
		uniform sampler2D anisotropyMap;
	#endif
#endif
varying vec3 vViewPosition;
#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <iridescence_fragment>
#include <cube_uv_reflection_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_physical_pars_fragment>
#include <fog_pars_fragment>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_physical_pars_fragment>
#include <transmission_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <clearcoat_pars_fragment>
#include <iridescence_pars_fragment>
#include <roughnessmap_pars_fragment>
#include <metalnessmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	vec4 diffuseColor = vec4( diffuse, opacity );
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <roughnessmap_fragment>
	#include <metalnessmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <clearcoat_normal_fragment_begin>
	#include <clearcoat_normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_physical_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 totalDiffuse = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse;
	vec3 totalSpecular = reflectedLight.directSpecular + reflectedLight.indirectSpecular;
	#include <transmission_fragment>
	vec3 outgoingLight = totalDiffuse + totalSpecular + totalEmissiveRadiance;
	#ifdef USE_SHEEN
		float sheenEnergyComp = 1.0 - 0.157 * max3( material.sheenColor );
		outgoingLight = outgoingLight * sheenEnergyComp + sheenSpecularDirect + sheenSpecularIndirect;
	#endif
	#ifdef USE_CLEARCOAT
		float dotNVcc = saturate( dot( geometryClearcoatNormal, geometryViewDir ) );
		vec3 Fcc = F_Schlick( material.clearcoatF0, material.clearcoatF90, dotNVcc );
		outgoingLight = outgoingLight * ( 1.0 - material.clearcoat * Fcc ) + ( clearcoatSpecularDirect + clearcoatSpecularIndirect ) * material.clearcoat;
	#endif
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,bf=`#define TOON
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,Ef=`#define TOON
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float opacity;
#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <gradientmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_toon_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	vec4 diffuseColor = vec4( diffuse, opacity );
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_toon_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + totalEmissiveRadiance;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,wf=`uniform float size;
uniform float scale;
#include <common>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
#ifdef USE_POINTS_UV
	varying vec2 vUv;
	uniform mat3 uvTransform;
#endif
void main() {
	#ifdef USE_POINTS_UV
		vUv = ( uvTransform * vec3( uv, 1 ) ).xy;
	#endif
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <project_vertex>
	gl_PointSize = size;
	#ifdef USE_SIZEATTENUATION
		bool isPerspective = isPerspectiveMatrix( projectionMatrix );
		if ( isPerspective ) gl_PointSize *= ( scale / - mvPosition.z );
	#endif
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <worldpos_vertex>
	#include <fog_vertex>
}`,Tf=`uniform vec3 diffuse;
uniform float opacity;
#include <common>
#include <color_pars_fragment>
#include <map_particle_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	vec3 outgoingLight = vec3( 0.0 );
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <logdepthbuf_fragment>
	#include <map_particle_fragment>
	#include <color_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
}`,Af=`#include <common>
#include <batching_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <shadowmap_pars_vertex>
void main() {
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,Rf=`uniform vec3 color;
uniform float opacity;
#include <common>
#include <packing>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <logdepthbuf_pars_fragment>
#include <shadowmap_pars_fragment>
#include <shadowmask_pars_fragment>
void main() {
	#include <logdepthbuf_fragment>
	gl_FragColor = vec4( color, opacity * ( 1.0 - getShadowMask() ) );
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
}`,Cf=`uniform float rotation;
uniform vec2 center;
#include <common>
#include <uv_pars_vertex>
#include <fog_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	vec4 mvPosition = modelViewMatrix * vec4( 0.0, 0.0, 0.0, 1.0 );
	vec2 scale;
	scale.x = length( vec3( modelMatrix[ 0 ].x, modelMatrix[ 0 ].y, modelMatrix[ 0 ].z ) );
	scale.y = length( vec3( modelMatrix[ 1 ].x, modelMatrix[ 1 ].y, modelMatrix[ 1 ].z ) );
	#ifndef USE_SIZEATTENUATION
		bool isPerspective = isPerspectiveMatrix( projectionMatrix );
		if ( isPerspective ) scale *= - mvPosition.z;
	#endif
	vec2 alignedPosition = ( position.xy - ( center - vec2( 0.5 ) ) ) * scale;
	vec2 rotatedPosition;
	rotatedPosition.x = cos( rotation ) * alignedPosition.x - sin( rotation ) * alignedPosition.y;
	rotatedPosition.y = sin( rotation ) * alignedPosition.x + cos( rotation ) * alignedPosition.y;
	mvPosition.xy += rotatedPosition;
	gl_Position = projectionMatrix * mvPosition;
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
}`,Pf=`uniform vec3 diffuse;
uniform float opacity;
#include <common>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	vec3 outgoingLight = vec3( 0.0 );
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
}`,Yt={alphahash_fragment:Zu,alphahash_pars_fragment:Ju,alphamap_fragment:Qu,alphamap_pars_fragment:th,alphatest_fragment:eh,alphatest_pars_fragment:nh,aomap_fragment:ih,aomap_pars_fragment:rh,batching_pars_vertex:sh,batching_vertex:oh,begin_vertex:ah,beginnormal_vertex:ch,bsdfs:lh,iridescence_fragment:uh,bumpmap_pars_fragment:hh,clipping_planes_fragment:dh,clipping_planes_pars_fragment:fh,clipping_planes_pars_vertex:ph,clipping_planes_vertex:mh,color_fragment:gh,color_pars_fragment:_h,color_pars_vertex:vh,color_vertex:xh,common:Mh,cube_uv_reflection_fragment:yh,defaultnormal_vertex:Sh,displacementmap_pars_vertex:bh,displacementmap_vertex:Eh,emissivemap_fragment:wh,emissivemap_pars_fragment:Th,colorspace_fragment:Ah,colorspace_pars_fragment:Rh,envmap_fragment:Ch,envmap_common_pars_fragment:Ph,envmap_pars_fragment:Lh,envmap_pars_vertex:Dh,envmap_physical_pars_fragment:Xh,envmap_vertex:Ih,fog_vertex:Uh,fog_pars_vertex:Nh,fog_fragment:Oh,fog_pars_fragment:Fh,gradientmap_pars_fragment:Bh,lightmap_fragment:zh,lightmap_pars_fragment:Gh,lights_lambert_fragment:kh,lights_lambert_pars_fragment:Hh,lights_pars_begin:Vh,lights_toon_fragment:Wh,lights_toon_pars_fragment:qh,lights_phong_fragment:Yh,lights_phong_pars_fragment:jh,lights_physical_fragment:$h,lights_physical_pars_fragment:Kh,lights_fragment_begin:Zh,lights_fragment_maps:Jh,lights_fragment_end:Qh,logdepthbuf_fragment:td,logdepthbuf_pars_fragment:ed,logdepthbuf_pars_vertex:nd,logdepthbuf_vertex:id,map_fragment:rd,map_pars_fragment:sd,map_particle_fragment:od,map_particle_pars_fragment:ad,metalnessmap_fragment:cd,metalnessmap_pars_fragment:ld,morphcolor_vertex:ud,morphnormal_vertex:hd,morphtarget_pars_vertex:dd,morphtarget_vertex:fd,normal_fragment_begin:pd,normal_fragment_maps:md,normal_pars_fragment:gd,normal_pars_vertex:_d,normal_vertex:vd,normalmap_pars_fragment:xd,clearcoat_normal_fragment_begin:Md,clearcoat_normal_fragment_maps:yd,clearcoat_pars_fragment:Sd,iridescence_pars_fragment:bd,opaque_fragment:Ed,packing:wd,premultiplied_alpha_fragment:Td,project_vertex:Ad,dithering_fragment:Rd,dithering_pars_fragment:Cd,roughnessmap_fragment:Pd,roughnessmap_pars_fragment:Ld,shadowmap_pars_fragment:Dd,shadowmap_pars_vertex:Id,shadowmap_vertex:Ud,shadowmask_pars_fragment:Nd,skinbase_vertex:Od,skinning_pars_vertex:Fd,skinning_vertex:Bd,skinnormal_vertex:zd,specularmap_fragment:Gd,specularmap_pars_fragment:kd,tonemapping_fragment:Hd,tonemapping_pars_fragment:Vd,transmission_fragment:Xd,transmission_pars_fragment:Wd,uv_pars_fragment:qd,uv_pars_vertex:Yd,uv_vertex:jd,worldpos_vertex:$d,background_vert:Kd,background_frag:Zd,backgroundCube_vert:Jd,backgroundCube_frag:Qd,cube_vert:tf,cube_frag:ef,depth_vert:nf,depth_frag:rf,distanceRGBA_vert:sf,distanceRGBA_frag:of,equirect_vert:af,equirect_frag:cf,linedashed_vert:lf,linedashed_frag:uf,meshbasic_vert:hf,meshbasic_frag:df,meshlambert_vert:ff,meshlambert_frag:pf,meshmatcap_vert:mf,meshmatcap_frag:gf,meshnormal_vert:_f,meshnormal_frag:vf,meshphong_vert:xf,meshphong_frag:Mf,meshphysical_vert:yf,meshphysical_frag:Sf,meshtoon_vert:bf,meshtoon_frag:Ef,points_vert:wf,points_frag:Tf,shadow_vert:Af,shadow_frag:Rf,sprite_vert:Cf,sprite_frag:Pf},Ct={common:{diffuse:{value:new Dt(16777215)},opacity:{value:1},map:{value:null},mapTransform:{value:new Kt},alphaMap:{value:null},alphaMapTransform:{value:new Kt},alphaTest:{value:0}},specularmap:{specularMap:{value:null},specularMapTransform:{value:new Kt}},envmap:{envMap:{value:null},flipEnvMap:{value:-1},reflectivity:{value:1},ior:{value:1.5},refractionRatio:{value:.98}},aomap:{aoMap:{value:null},aoMapIntensity:{value:1},aoMapTransform:{value:new Kt}},lightmap:{lightMap:{value:null},lightMapIntensity:{value:1},lightMapTransform:{value:new Kt}},bumpmap:{bumpMap:{value:null},bumpMapTransform:{value:new Kt},bumpScale:{value:1}},normalmap:{normalMap:{value:null},normalMapTransform:{value:new Kt},normalScale:{value:new At(1,1)}},displacementmap:{displacementMap:{value:null},displacementMapTransform:{value:new Kt},displacementScale:{value:1},displacementBias:{value:0}},emissivemap:{emissiveMap:{value:null},emissiveMapTransform:{value:new Kt}},metalnessmap:{metalnessMap:{value:null},metalnessMapTransform:{value:new Kt}},roughnessmap:{roughnessMap:{value:null},roughnessMapTransform:{value:new Kt}},gradientmap:{gradientMap:{value:null}},fog:{fogDensity:{value:25e-5},fogNear:{value:1},fogFar:{value:2e3},fogColor:{value:new Dt(16777215)}},lights:{ambientLightColor:{value:[]},lightProbe:{value:[]},directionalLights:{value:[],properties:{direction:{},color:{}}},directionalLightShadows:{value:[],properties:{shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{}}},directionalShadowMap:{value:[]},directionalShadowMatrix:{value:[]},spotLights:{value:[],properties:{color:{},position:{},direction:{},distance:{},coneCos:{},penumbraCos:{},decay:{}}},spotLightShadows:{value:[],properties:{shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{}}},spotLightMap:{value:[]},spotShadowMap:{value:[]},spotLightMatrix:{value:[]},pointLights:{value:[],properties:{color:{},position:{},decay:{},distance:{}}},pointLightShadows:{value:[],properties:{shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{},shadowCameraNear:{},shadowCameraFar:{}}},pointShadowMap:{value:[]},pointShadowMatrix:{value:[]},hemisphereLights:{value:[],properties:{direction:{},skyColor:{},groundColor:{}}},rectAreaLights:{value:[],properties:{color:{},position:{},width:{},height:{}}},ltc_1:{value:null},ltc_2:{value:null}},points:{diffuse:{value:new Dt(16777215)},opacity:{value:1},size:{value:1},scale:{value:1},map:{value:null},alphaMap:{value:null},alphaMapTransform:{value:new Kt},alphaTest:{value:0},uvTransform:{value:new Kt}},sprite:{diffuse:{value:new Dt(16777215)},opacity:{value:1},center:{value:new At(.5,.5)},rotation:{value:0},map:{value:null},mapTransform:{value:new Kt},alphaMap:{value:null},alphaMapTransform:{value:new Kt},alphaTest:{value:0}}},Qe={basic:{uniforms:Pe([Ct.common,Ct.specularmap,Ct.envmap,Ct.aomap,Ct.lightmap,Ct.fog]),vertexShader:Yt.meshbasic_vert,fragmentShader:Yt.meshbasic_frag},lambert:{uniforms:Pe([Ct.common,Ct.specularmap,Ct.envmap,Ct.aomap,Ct.lightmap,Ct.emissivemap,Ct.bumpmap,Ct.normalmap,Ct.displacementmap,Ct.fog,Ct.lights,{emissive:{value:new Dt(0)}}]),vertexShader:Yt.meshlambert_vert,fragmentShader:Yt.meshlambert_frag},phong:{uniforms:Pe([Ct.common,Ct.specularmap,Ct.envmap,Ct.aomap,Ct.lightmap,Ct.emissivemap,Ct.bumpmap,Ct.normalmap,Ct.displacementmap,Ct.fog,Ct.lights,{emissive:{value:new Dt(0)},specular:{value:new Dt(1118481)},shininess:{value:30}}]),vertexShader:Yt.meshphong_vert,fragmentShader:Yt.meshphong_frag},standard:{uniforms:Pe([Ct.common,Ct.envmap,Ct.aomap,Ct.lightmap,Ct.emissivemap,Ct.bumpmap,Ct.normalmap,Ct.displacementmap,Ct.roughnessmap,Ct.metalnessmap,Ct.fog,Ct.lights,{emissive:{value:new Dt(0)},roughness:{value:1},metalness:{value:0},envMapIntensity:{value:1}}]),vertexShader:Yt.meshphysical_vert,fragmentShader:Yt.meshphysical_frag},toon:{uniforms:Pe([Ct.common,Ct.aomap,Ct.lightmap,Ct.emissivemap,Ct.bumpmap,Ct.normalmap,Ct.displacementmap,Ct.gradientmap,Ct.fog,Ct.lights,{emissive:{value:new Dt(0)}}]),vertexShader:Yt.meshtoon_vert,fragmentShader:Yt.meshtoon_frag},matcap:{uniforms:Pe([Ct.common,Ct.bumpmap,Ct.normalmap,Ct.displacementmap,Ct.fog,{matcap:{value:null}}]),vertexShader:Yt.meshmatcap_vert,fragmentShader:Yt.meshmatcap_frag},points:{uniforms:Pe([Ct.points,Ct.fog]),vertexShader:Yt.points_vert,fragmentShader:Yt.points_frag},dashed:{uniforms:Pe([Ct.common,Ct.fog,{scale:{value:1},dashSize:{value:1},totalSize:{value:2}}]),vertexShader:Yt.linedashed_vert,fragmentShader:Yt.linedashed_frag},depth:{uniforms:Pe([Ct.common,Ct.displacementmap]),vertexShader:Yt.depth_vert,fragmentShader:Yt.depth_frag},normal:{uniforms:Pe([Ct.common,Ct.bumpmap,Ct.normalmap,Ct.displacementmap,{opacity:{value:1}}]),vertexShader:Yt.meshnormal_vert,fragmentShader:Yt.meshnormal_frag},sprite:{uniforms:Pe([Ct.sprite,Ct.fog]),vertexShader:Yt.sprite_vert,fragmentShader:Yt.sprite_frag},background:{uniforms:{uvTransform:{value:new Kt},t2D:{value:null},backgroundIntensity:{value:1}},vertexShader:Yt.background_vert,fragmentShader:Yt.background_frag},backgroundCube:{uniforms:{envMap:{value:null},flipEnvMap:{value:-1},backgroundBlurriness:{value:0},backgroundIntensity:{value:1}},vertexShader:Yt.backgroundCube_vert,fragmentShader:Yt.backgroundCube_frag},cube:{uniforms:{tCube:{value:null},tFlip:{value:-1},opacity:{value:1}},vertexShader:Yt.cube_vert,fragmentShader:Yt.cube_frag},equirect:{uniforms:{tEquirect:{value:null}},vertexShader:Yt.equirect_vert,fragmentShader:Yt.equirect_frag},distanceRGBA:{uniforms:Pe([Ct.common,Ct.displacementmap,{referencePosition:{value:new H},nearDistance:{value:1},farDistance:{value:1e3}}]),vertexShader:Yt.distanceRGBA_vert,fragmentShader:Yt.distanceRGBA_frag},shadow:{uniforms:Pe([Ct.lights,Ct.fog,{color:{value:new Dt(0)},opacity:{value:1}}]),vertexShader:Yt.shadow_vert,fragmentShader:Yt.shadow_frag}};Qe.physical={uniforms:Pe([Qe.standard.uniforms,{clearcoat:{value:0},clearcoatMap:{value:null},clearcoatMapTransform:{value:new Kt},clearcoatNormalMap:{value:null},clearcoatNormalMapTransform:{value:new Kt},clearcoatNormalScale:{value:new At(1,1)},clearcoatRoughness:{value:0},clearcoatRoughnessMap:{value:null},clearcoatRoughnessMapTransform:{value:new Kt},iridescence:{value:0},iridescenceMap:{value:null},iridescenceMapTransform:{value:new Kt},iridescenceIOR:{value:1.3},iridescenceThicknessMinimum:{value:100},iridescenceThicknessMaximum:{value:400},iridescenceThicknessMap:{value:null},iridescenceThicknessMapTransform:{value:new Kt},sheen:{value:0},sheenColor:{value:new Dt(0)},sheenColorMap:{value:null},sheenColorMapTransform:{value:new Kt},sheenRoughness:{value:1},sheenRoughnessMap:{value:null},sheenRoughnessMapTransform:{value:new Kt},transmission:{value:0},transmissionMap:{value:null},transmissionMapTransform:{value:new Kt},transmissionSamplerSize:{value:new At},transmissionSamplerMap:{value:null},thickness:{value:0},thicknessMap:{value:null},thicknessMapTransform:{value:new Kt},attenuationDistance:{value:0},attenuationColor:{value:new Dt(0)},specularColor:{value:new Dt(1,1,1)},specularColorMap:{value:null},specularColorMapTransform:{value:new Kt},specularIntensity:{value:1},specularIntensityMap:{value:null},specularIntensityMapTransform:{value:new Kt},anisotropyVector:{value:new At},anisotropyMap:{value:null},anisotropyMapTransform:{value:new Kt}}]),vertexShader:Yt.meshphysical_vert,fragmentShader:Yt.meshphysical_frag};const Mr={r:0,b:0,g:0};function Lf(i,t,e,n,r,s,o){const a=new Dt(0);let c=s===!0?0:1,l,h,f=null,m=0,p=null;function _(d,u){let M=!1,g=u.isScene===!0?u.background:null;g&&g.isTexture&&(g=(u.backgroundBlurriness>0?e:t).get(g)),g===null?x(a,c):g&&g.isColor&&(x(g,1),M=!0);const y=i.xr.getEnvironmentBlendMode();y==="additive"?n.buffers.color.setClear(0,0,0,1,o):y==="alpha-blend"&&n.buffers.color.setClear(0,0,0,0,o),(i.autoClear||M)&&i.clear(i.autoClearColor,i.autoClearDepth,i.autoClearStencil),g&&(g.isCubeTexture||g.mapping===Xr)?(h===void 0&&(h=new Bt(new $e(1,1,1),new we({name:"BackgroundCubeMaterial",uniforms:wi(Qe.backgroundCube.uniforms),vertexShader:Qe.backgroundCube.vertexShader,fragmentShader:Qe.backgroundCube.fragmentShader,side:Me,depthTest:!1,depthWrite:!1,fog:!1})),h.geometry.deleteAttribute("normal"),h.geometry.deleteAttribute("uv"),h.onBeforeRender=function(L,C,D){this.matrixWorld.copyPosition(D.matrixWorld)},Object.defineProperty(h.material,"envMap",{get:function(){return this.uniforms.envMap.value}}),r.update(h)),h.material.uniforms.envMap.value=g,h.material.uniforms.flipEnvMap.value=g.isCubeTexture&&g.isRenderTargetTexture===!1?-1:1,h.material.uniforms.backgroundBlurriness.value=u.backgroundBlurriness,h.material.uniforms.backgroundIntensity.value=u.backgroundIntensity,h.material.toneMapped=te.getTransfer(g.colorSpace)!==se,(f!==g||m!==g.version||p!==i.toneMapping)&&(h.material.needsUpdate=!0,f=g,m=g.version,p=i.toneMapping),h.layers.enableAll(),d.unshift(h,h.geometry,h.material,0,0,null)):g&&g.isTexture&&(l===void 0&&(l=new Bt(new qn(2,2),new we({name:"BackgroundMaterial",uniforms:wi(Qe.background.uniforms),vertexShader:Qe.background.vertexShader,fragmentShader:Qe.background.fragmentShader,side:pn,depthTest:!1,depthWrite:!1,fog:!1})),l.geometry.deleteAttribute("normal"),Object.defineProperty(l.material,"map",{get:function(){return this.uniforms.t2D.value}}),r.update(l)),l.material.uniforms.t2D.value=g,l.material.uniforms.backgroundIntensity.value=u.backgroundIntensity,l.material.toneMapped=te.getTransfer(g.colorSpace)!==se,g.matrixAutoUpdate===!0&&g.updateMatrix(),l.material.uniforms.uvTransform.value.copy(g.matrix),(f!==g||m!==g.version||p!==i.toneMapping)&&(l.material.needsUpdate=!0,f=g,m=g.version,p=i.toneMapping),l.layers.enableAll(),d.unshift(l,l.geometry,l.material,0,0,null))}function x(d,u){d.getRGB(Mr,zc(i)),n.buffers.color.setClear(Mr.r,Mr.g,Mr.b,u,o)}return{getClearColor:function(){return a},setClearColor:function(d,u=1){a.set(d),c=u,x(a,c)},getClearAlpha:function(){return c},setClearAlpha:function(d){c=d,x(a,c)},render:_}}function Df(i,t,e,n){const r=i.getParameter(i.MAX_VERTEX_ATTRIBS),s=n.isWebGL2?null:t.get("OES_vertex_array_object"),o=n.isWebGL2||s!==null,a={},c=d(null);let l=c,h=!1;function f(S,b,v,A,I){let U=!1;if(o){const P=x(A,v,b);l!==P&&(l=P,p(l.object)),U=u(S,A,v,I),U&&M(S,A,v,I)}else{const P=b.wireframe===!0;(l.geometry!==A.id||l.program!==v.id||l.wireframe!==P)&&(l.geometry=A.id,l.program=v.id,l.wireframe=P,U=!0)}I!==null&&e.update(I,i.ELEMENT_ARRAY_BUFFER),(U||h)&&(h=!1,F(S,b,v,A),I!==null&&i.bindBuffer(i.ELEMENT_ARRAY_BUFFER,e.get(I).buffer))}function m(){return n.isWebGL2?i.createVertexArray():s.createVertexArrayOES()}function p(S){return n.isWebGL2?i.bindVertexArray(S):s.bindVertexArrayOES(S)}function _(S){return n.isWebGL2?i.deleteVertexArray(S):s.deleteVertexArrayOES(S)}function x(S,b,v){const A=v.wireframe===!0;let I=a[S.id];I===void 0&&(I={},a[S.id]=I);let U=I[b.id];U===void 0&&(U={},I[b.id]=U);let P=U[A];return P===void 0&&(P=d(m()),U[A]=P),P}function d(S){const b=[],v=[],A=[];for(let I=0;I<r;I++)b[I]=0,v[I]=0,A[I]=0;return{geometry:null,program:null,wireframe:!1,newAttributes:b,enabledAttributes:v,attributeDivisors:A,object:S,attributes:{},index:null}}function u(S,b,v,A){const I=l.attributes,U=b.attributes;let P=0;const N=v.getAttributes();for(const Y in N)if(N[Y].location>=0){const nt=I[Y];let ht=U[Y];if(ht===void 0&&(Y==="instanceMatrix"&&S.instanceMatrix&&(ht=S.instanceMatrix),Y==="instanceColor"&&S.instanceColor&&(ht=S.instanceColor)),nt===void 0||nt.attribute!==ht||ht&&nt.data!==ht.data)return!0;P++}return l.attributesNum!==P||l.index!==A}function M(S,b,v,A){const I={},U=b.attributes;let P=0;const N=v.getAttributes();for(const Y in N)if(N[Y].location>=0){let nt=U[Y];nt===void 0&&(Y==="instanceMatrix"&&S.instanceMatrix&&(nt=S.instanceMatrix),Y==="instanceColor"&&S.instanceColor&&(nt=S.instanceColor));const ht={};ht.attribute=nt,nt&&nt.data&&(ht.data=nt.data),I[Y]=ht,P++}l.attributes=I,l.attributesNum=P,l.index=A}function g(){const S=l.newAttributes;for(let b=0,v=S.length;b<v;b++)S[b]=0}function y(S){L(S,0)}function L(S,b){const v=l.newAttributes,A=l.enabledAttributes,I=l.attributeDivisors;v[S]=1,A[S]===0&&(i.enableVertexAttribArray(S),A[S]=1),I[S]!==b&&((n.isWebGL2?i:t.get("ANGLE_instanced_arrays"))[n.isWebGL2?"vertexAttribDivisor":"vertexAttribDivisorANGLE"](S,b),I[S]=b)}function C(){const S=l.newAttributes,b=l.enabledAttributes;for(let v=0,A=b.length;v<A;v++)b[v]!==S[v]&&(i.disableVertexAttribArray(v),b[v]=0)}function D(S,b,v,A,I,U,P){P===!0?i.vertexAttribIPointer(S,b,v,I,U):i.vertexAttribPointer(S,b,v,A,I,U)}function F(S,b,v,A){if(n.isWebGL2===!1&&(S.isInstancedMesh||A.isInstancedBufferGeometry)&&t.get("ANGLE_instanced_arrays")===null)return;g();const I=A.attributes,U=v.getAttributes(),P=b.defaultAttributeValues;for(const N in U){const Y=U[N];if(Y.location>=0){let Z=I[N];if(Z===void 0&&(N==="instanceMatrix"&&S.instanceMatrix&&(Z=S.instanceMatrix),N==="instanceColor"&&S.instanceColor&&(Z=S.instanceColor)),Z!==void 0){const nt=Z.normalized,ht=Z.itemSize,gt=e.get(Z);if(gt===void 0)continue;const xt=gt.buffer,Et=gt.type,ct=gt.bytesPerElement,ut=n.isWebGL2===!0&&(Et===i.INT||Et===i.UNSIGNED_INT||Z.gpuType===yc);if(Z.isInterleavedBufferAttribute){const Mt=Z.data,k=Mt.stride,tt=Z.offset;if(Mt.isInstancedInterleavedBuffer){for(let G=0;G<Y.locationSize;G++)L(Y.location+G,Mt.meshPerAttribute);S.isInstancedMesh!==!0&&A._maxInstanceCount===void 0&&(A._maxInstanceCount=Mt.meshPerAttribute*Mt.count)}else for(let G=0;G<Y.locationSize;G++)y(Y.location+G);i.bindBuffer(i.ARRAY_BUFFER,xt);for(let G=0;G<Y.locationSize;G++)D(Y.location+G,ht/Y.locationSize,Et,nt,k*ct,(tt+ht/Y.locationSize*G)*ct,ut)}else{if(Z.isInstancedBufferAttribute){for(let Mt=0;Mt<Y.locationSize;Mt++)L(Y.location+Mt,Z.meshPerAttribute);S.isInstancedMesh!==!0&&A._maxInstanceCount===void 0&&(A._maxInstanceCount=Z.meshPerAttribute*Z.count)}else for(let Mt=0;Mt<Y.locationSize;Mt++)y(Y.location+Mt);i.bindBuffer(i.ARRAY_BUFFER,xt);for(let Mt=0;Mt<Y.locationSize;Mt++)D(Y.location+Mt,ht/Y.locationSize,Et,nt,ht*ct,ht/Y.locationSize*Mt*ct,ut)}}else if(P!==void 0){const nt=P[N];if(nt!==void 0)switch(nt.length){case 2:i.vertexAttrib2fv(Y.location,nt);break;case 3:i.vertexAttrib3fv(Y.location,nt);break;case 4:i.vertexAttrib4fv(Y.location,nt);break;default:i.vertexAttrib1fv(Y.location,nt)}}}}C()}function T(){O();for(const S in a){const b=a[S];for(const v in b){const A=b[v];for(const I in A)_(A[I].object),delete A[I];delete b[v]}delete a[S]}}function E(S){if(a[S.id]===void 0)return;const b=a[S.id];for(const v in b){const A=b[v];for(const I in A)_(A[I].object),delete A[I];delete b[v]}delete a[S.id]}function j(S){for(const b in a){const v=a[b];if(v[S.id]===void 0)continue;const A=v[S.id];for(const I in A)_(A[I].object),delete A[I];delete v[S.id]}}function O(){B(),h=!0,l!==c&&(l=c,p(l.object))}function B(){c.geometry=null,c.program=null,c.wireframe=!1}return{setup:f,reset:O,resetDefaultState:B,dispose:T,releaseStatesOfGeometry:E,releaseStatesOfProgram:j,initAttributes:g,enableAttribute:y,disableUnusedAttributes:C}}function If(i,t,e,n){const r=n.isWebGL2;let s;function o(h){s=h}function a(h,f){i.drawArrays(s,h,f),e.update(f,s,1)}function c(h,f,m){if(m===0)return;let p,_;if(r)p=i,_="drawArraysInstanced";else if(p=t.get("ANGLE_instanced_arrays"),_="drawArraysInstancedANGLE",p===null){console.error("THREE.WebGLBufferRenderer: using THREE.InstancedBufferGeometry but hardware does not support extension ANGLE_instanced_arrays.");return}p[_](s,h,f,m),e.update(f,s,m)}function l(h,f,m){if(m===0)return;const p=t.get("WEBGL_multi_draw");if(p===null)for(let _=0;_<m;_++)this.render(h[_],f[_]);else{p.multiDrawArraysWEBGL(s,h,0,f,0,m);let _=0;for(let x=0;x<m;x++)_+=f[x];e.update(_,s,1)}}this.setMode=o,this.render=a,this.renderInstances=c,this.renderMultiDraw=l}function Uf(i,t,e){let n;function r(){if(n!==void 0)return n;if(t.has("EXT_texture_filter_anisotropic")===!0){const D=t.get("EXT_texture_filter_anisotropic");n=i.getParameter(D.MAX_TEXTURE_MAX_ANISOTROPY_EXT)}else n=0;return n}function s(D){if(D==="highp"){if(i.getShaderPrecisionFormat(i.VERTEX_SHADER,i.HIGH_FLOAT).precision>0&&i.getShaderPrecisionFormat(i.FRAGMENT_SHADER,i.HIGH_FLOAT).precision>0)return"highp";D="mediump"}return D==="mediump"&&i.getShaderPrecisionFormat(i.VERTEX_SHADER,i.MEDIUM_FLOAT).precision>0&&i.getShaderPrecisionFormat(i.FRAGMENT_SHADER,i.MEDIUM_FLOAT).precision>0?"mediump":"lowp"}const o=typeof WebGL2RenderingContext<"u"&&i.constructor.name==="WebGL2RenderingContext";let a=e.precision!==void 0?e.precision:"highp";const c=s(a);c!==a&&(console.warn("THREE.WebGLRenderer:",a,"not supported, using",c,"instead."),a=c);const l=o||t.has("WEBGL_draw_buffers"),h=e.logarithmicDepthBuffer===!0,f=i.getParameter(i.MAX_TEXTURE_IMAGE_UNITS),m=i.getParameter(i.MAX_VERTEX_TEXTURE_IMAGE_UNITS),p=i.getParameter(i.MAX_TEXTURE_SIZE),_=i.getParameter(i.MAX_CUBE_MAP_TEXTURE_SIZE),x=i.getParameter(i.MAX_VERTEX_ATTRIBS),d=i.getParameter(i.MAX_VERTEX_UNIFORM_VECTORS),u=i.getParameter(i.MAX_VARYING_VECTORS),M=i.getParameter(i.MAX_FRAGMENT_UNIFORM_VECTORS),g=m>0,y=o||t.has("OES_texture_float"),L=g&&y,C=o?i.getParameter(i.MAX_SAMPLES):0;return{isWebGL2:o,drawBuffers:l,getMaxAnisotropy:r,getMaxPrecision:s,precision:a,logarithmicDepthBuffer:h,maxTextures:f,maxVertexTextures:m,maxTextureSize:p,maxCubemapSize:_,maxAttributes:x,maxVertexUniforms:d,maxVaryings:u,maxFragmentUniforms:M,vertexTextures:g,floatFragmentTextures:y,floatVertexTextures:L,maxSamples:C}}function Nf(i){const t=this;let e=null,n=0,r=!1,s=!1;const o=new Sn,a=new Kt,c={value:null,needsUpdate:!1};this.uniform=c,this.numPlanes=0,this.numIntersection=0,this.init=function(f,m){const p=f.length!==0||m||n!==0||r;return r=m,n=f.length,p},this.beginShadows=function(){s=!0,h(null)},this.endShadows=function(){s=!1},this.setGlobalState=function(f,m){e=h(f,m,0)},this.setState=function(f,m,p){const _=f.clippingPlanes,x=f.clipIntersection,d=f.clipShadows,u=i.get(f);if(!r||_===null||_.length===0||s&&!d)s?h(null):l();else{const M=s?0:n,g=M*4;let y=u.clippingState||null;c.value=y,y=h(_,m,g,p);for(let L=0;L!==g;++L)y[L]=e[L];u.clippingState=y,this.numIntersection=x?this.numPlanes:0,this.numPlanes+=M}};function l(){c.value!==e&&(c.value=e,c.needsUpdate=n>0),t.numPlanes=n,t.numIntersection=0}function h(f,m,p,_){const x=f!==null?f.length:0;let d=null;if(x!==0){if(d=c.value,_!==!0||d===null){const u=p+x*4,M=m.matrixWorldInverse;a.getNormalMatrix(M),(d===null||d.length<u)&&(d=new Float32Array(u));for(let g=0,y=p;g!==x;++g,y+=4)o.copy(f[g]).applyMatrix4(M,a),o.normal.toArray(d,y),d[y+3]=o.constant}c.value=d,c.needsUpdate=!0}return t.numPlanes=x,t.numIntersection=0,d}}function Of(i){let t=new WeakMap;function e(o,a){return a===Gs?o.mapping=yi:a===ks&&(o.mapping=Si),o}function n(o){if(o&&o.isTexture){const a=o.mapping;if(a===Gs||a===ks)if(t.has(o)){const c=t.get(o).texture;return e(c,o.mapping)}else{const c=o.image;if(c&&c.height>0){const l=new Yu(c.height/2);return l.fromEquirectangularTexture(i,o),t.set(o,l),o.addEventListener("dispose",r),e(l.texture,o.mapping)}else return null}}return o}function r(o){const a=o.target;a.removeEventListener("dispose",r);const c=t.get(a);c!==void 0&&(t.delete(a),c.dispose())}function s(){t=new WeakMap}return{get:n,dispose:s}}class oo extends Gc{constructor(t=-1,e=1,n=1,r=-1,s=.1,o=2e3){super(),this.isOrthographicCamera=!0,this.type="OrthographicCamera",this.zoom=1,this.view=null,this.left=t,this.right=e,this.top=n,this.bottom=r,this.near=s,this.far=o,this.updateProjectionMatrix()}copy(t,e){return super.copy(t,e),this.left=t.left,this.right=t.right,this.top=t.top,this.bottom=t.bottom,this.near=t.near,this.far=t.far,this.zoom=t.zoom,this.view=t.view===null?null:Object.assign({},t.view),this}setViewOffset(t,e,n,r,s,o){this.view===null&&(this.view={enabled:!0,fullWidth:1,fullHeight:1,offsetX:0,offsetY:0,width:1,height:1}),this.view.enabled=!0,this.view.fullWidth=t,this.view.fullHeight=e,this.view.offsetX=n,this.view.offsetY=r,this.view.width=s,this.view.height=o,this.updateProjectionMatrix()}clearViewOffset(){this.view!==null&&(this.view.enabled=!1),this.updateProjectionMatrix()}updateProjectionMatrix(){const t=(this.right-this.left)/(2*this.zoom),e=(this.top-this.bottom)/(2*this.zoom),n=(this.right+this.left)/2,r=(this.top+this.bottom)/2;let s=n-t,o=n+t,a=r+e,c=r-e;if(this.view!==null&&this.view.enabled){const l=(this.right-this.left)/this.view.fullWidth/this.zoom,h=(this.top-this.bottom)/this.view.fullHeight/this.zoom;s+=l*this.view.offsetX,o=s+l*this.view.width,a-=h*this.view.offsetY,c=a-h*this.view.height}this.projectionMatrix.makeOrthographic(s,o,a,c,this.near,this.far,this.coordinateSystem),this.projectionMatrixInverse.copy(this.projectionMatrix).invert()}toJSON(t){const e=super.toJSON(t);return e.object.zoom=this.zoom,e.object.left=this.left,e.object.right=this.right,e.object.top=this.top,e.object.bottom=this.bottom,e.object.near=this.near,e.object.far=this.far,this.view!==null&&(e.object.view=Object.assign({},this.view)),e}}const gi=4,Ma=[.125,.215,.35,.446,.526,.582],Fn=20,bs=new oo,ya=new Dt;let Es=null,ws=0,Ts=0;const Nn=(1+Math.sqrt(5))/2,ui=1/Nn,Sa=[new H(1,1,1),new H(-1,1,1),new H(1,1,-1),new H(-1,1,-1),new H(0,Nn,ui),new H(0,Nn,-ui),new H(ui,0,Nn),new H(-ui,0,Nn),new H(Nn,ui,0),new H(-Nn,ui,0)];class qs{constructor(t){this._renderer=t,this._pingPongRenderTarget=null,this._lodMax=0,this._cubeSize=0,this._lodPlanes=[],this._sizeLods=[],this._sigmas=[],this._blurMaterial=null,this._cubemapMaterial=null,this._equirectMaterial=null,this._compileMaterial(this._blurMaterial)}fromScene(t,e=0,n=.1,r=100){Es=this._renderer.getRenderTarget(),ws=this._renderer.getActiveCubeFace(),Ts=this._renderer.getActiveMipmapLevel(),this._setSize(256);const s=this._allocateTargets();return s.depthBuffer=!0,this._sceneToCubeUV(t,n,r,s),e>0&&this._blur(s,0,0,e),this._applyPMREM(s),this._cleanup(s),s}fromEquirectangular(t,e=null){return this._fromTexture(t,e)}fromCubemap(t,e=null){return this._fromTexture(t,e)}compileCubemapShader(){this._cubemapMaterial===null&&(this._cubemapMaterial=wa(),this._compileMaterial(this._cubemapMaterial))}compileEquirectangularShader(){this._equirectMaterial===null&&(this._equirectMaterial=Ea(),this._compileMaterial(this._equirectMaterial))}dispose(){this._dispose(),this._cubemapMaterial!==null&&this._cubemapMaterial.dispose(),this._equirectMaterial!==null&&this._equirectMaterial.dispose()}_setSize(t){this._lodMax=Math.floor(Math.log2(t)),this._cubeSize=Math.pow(2,this._lodMax)}_dispose(){this._blurMaterial!==null&&this._blurMaterial.dispose(),this._pingPongRenderTarget!==null&&this._pingPongRenderTarget.dispose();for(let t=0;t<this._lodPlanes.length;t++)this._lodPlanes[t].dispose()}_cleanup(t){this._renderer.setRenderTarget(Es,ws,Ts),t.scissorTest=!1,yr(t,0,0,t.width,t.height)}_fromTexture(t,e){t.mapping===yi||t.mapping===Si?this._setSize(t.image.length===0?16:t.image[0].width||t.image[0].image.width):this._setSize(t.image.width/4),Es=this._renderer.getRenderTarget(),ws=this._renderer.getActiveCubeFace(),Ts=this._renderer.getActiveMipmapLevel();const n=e||this._allocateTargets();return this._textureToCubeUV(t,n),this._applyPMREM(n),this._cleanup(n),n}_allocateTargets(){const t=3*Math.max(this._cubeSize,112),e=4*this._cubeSize,n={magFilter:He,minFilter:He,generateMipmaps:!1,type:dn,format:je,colorSpace:mn,depthBuffer:!1},r=ba(t,e,n);if(this._pingPongRenderTarget===null||this._pingPongRenderTarget.width!==t||this._pingPongRenderTarget.height!==e){this._pingPongRenderTarget!==null&&this._dispose(),this._pingPongRenderTarget=ba(t,e,n);const{_lodMax:s}=this;({sizeLods:this._sizeLods,lodPlanes:this._lodPlanes,sigmas:this._sigmas}=Ff(s)),this._blurMaterial=Bf(s,t,e)}return r}_compileMaterial(t){const e=new Bt(this._lodPlanes[0],t);this._renderer.compile(e,bs)}_sceneToCubeUV(t,e,n,r){const a=new Fe(90,1,e,n),c=[1,-1,1,1,1,1],l=[1,1,1,-1,-1,-1],h=this._renderer,f=h.autoClear,m=h.toneMapping;h.getClearColor(ya),h.toneMapping=wn,h.autoClear=!1;const p=new De({name:"PMREM.Background",side:Me,depthWrite:!1,depthTest:!1}),_=new Bt(new $e,p);let x=!1;const d=t.background;d?d.isColor&&(p.color.copy(d),t.background=null,x=!0):(p.color.copy(ya),x=!0);for(let u=0;u<6;u++){const M=u%3;M===0?(a.up.set(0,c[u],0),a.lookAt(l[u],0,0)):M===1?(a.up.set(0,0,c[u]),a.lookAt(0,l[u],0)):(a.up.set(0,c[u],0),a.lookAt(0,0,l[u]));const g=this._cubeSize;yr(r,M*g,u>2?g:0,g,g),h.setRenderTarget(r),x&&h.render(_,a),h.render(t,a)}_.geometry.dispose(),_.material.dispose(),h.toneMapping=m,h.autoClear=f,t.background=d}_textureToCubeUV(t,e){const n=this._renderer,r=t.mapping===yi||t.mapping===Si;r?(this._cubemapMaterial===null&&(this._cubemapMaterial=wa()),this._cubemapMaterial.uniforms.flipEnvMap.value=t.isRenderTargetTexture===!1?-1:1):this._equirectMaterial===null&&(this._equirectMaterial=Ea());const s=r?this._cubemapMaterial:this._equirectMaterial,o=new Bt(this._lodPlanes[0],s),a=s.uniforms;a.envMap.value=t;const c=this._cubeSize;yr(e,0,0,3*c,2*c),n.setRenderTarget(e),n.render(o,bs)}_applyPMREM(t){const e=this._renderer,n=e.autoClear;e.autoClear=!1;for(let r=1;r<this._lodPlanes.length;r++){const s=Math.sqrt(this._sigmas[r]*this._sigmas[r]-this._sigmas[r-1]*this._sigmas[r-1]),o=Sa[(r-1)%Sa.length];this._blur(t,r-1,r,s,o)}e.autoClear=n}_blur(t,e,n,r,s){const o=this._pingPongRenderTarget;this._halfBlur(t,o,e,n,r,"latitudinal",s),this._halfBlur(o,t,n,n,r,"longitudinal",s)}_halfBlur(t,e,n,r,s,o,a){const c=this._renderer,l=this._blurMaterial;o!=="latitudinal"&&o!=="longitudinal"&&console.error("blur direction must be either latitudinal or longitudinal!");const h=3,f=new Bt(this._lodPlanes[r],l),m=l.uniforms,p=this._sizeLods[n]-1,_=isFinite(s)?Math.PI/(2*p):2*Math.PI/(2*Fn-1),x=s/_,d=isFinite(s)?1+Math.floor(h*x):Fn;d>Fn&&console.warn(`sigmaRadians, ${s}, is too large and will clip, as it requested ${d} samples when the maximum is set to ${Fn}`);const u=[];let M=0;for(let D=0;D<Fn;++D){const F=D/x,T=Math.exp(-F*F/2);u.push(T),D===0?M+=T:D<d&&(M+=2*T)}for(let D=0;D<u.length;D++)u[D]=u[D]/M;m.envMap.value=t.texture,m.samples.value=d,m.weights.value=u,m.latitudinal.value=o==="latitudinal",a&&(m.poleAxis.value=a);const{_lodMax:g}=this;m.dTheta.value=_,m.mipInt.value=g-n;const y=this._sizeLods[r],L=3*y*(r>g-gi?r-g+gi:0),C=4*(this._cubeSize-y);yr(e,L,C,3*y,2*y),c.setRenderTarget(e),c.render(f,bs)}}function Ff(i){const t=[],e=[],n=[];let r=i;const s=i-gi+1+Ma.length;for(let o=0;o<s;o++){const a=Math.pow(2,r);e.push(a);let c=1/a;o>i-gi?c=Ma[o-i+gi-1]:o===0&&(c=0),n.push(c);const l=1/(a-2),h=-l,f=1+l,m=[h,h,f,h,f,f,h,h,f,f,h,f],p=6,_=6,x=3,d=2,u=1,M=new Float32Array(x*_*p),g=new Float32Array(d*_*p),y=new Float32Array(u*_*p);for(let C=0;C<p;C++){const D=C%3*2/3-1,F=C>2?0:-1,T=[D,F,0,D+2/3,F,0,D+2/3,F+1,0,D,F,0,D+2/3,F+1,0,D,F+1,0];M.set(T,x*_*C),g.set(m,d*_*C);const E=[C,C,C,C,C,C];y.set(E,u*_*C)}const L=new Jt;L.setAttribute("position",new le(M,x)),L.setAttribute("uv",new le(g,d)),L.setAttribute("faceIndex",new le(y,u)),t.push(L),r>gi&&r--}return{lodPlanes:t,sizeLods:e,sigmas:n}}function ba(i,t,e){const n=new Ke(i,t,e);return n.texture.mapping=Xr,n.texture.name="PMREM.cubeUv",n.scissorTest=!0,n}function yr(i,t,e,n,r){i.viewport.set(t,e,n,r),i.scissor.set(t,e,n,r)}function Bf(i,t,e){const n=new Float32Array(Fn),r=new H(0,1,0);return new we({name:"SphericalGaussianBlur",defines:{n:Fn,CUBEUV_TEXEL_WIDTH:1/t,CUBEUV_TEXEL_HEIGHT:1/e,CUBEUV_MAX_MIP:`${i}.0`},uniforms:{envMap:{value:null},samples:{value:1},weights:{value:n},latitudinal:{value:!1},dTheta:{value:0},mipInt:{value:0},poleAxis:{value:r}},vertexShader:ao(),fragmentShader:`

			precision mediump float;
			precision mediump int;

			varying vec3 vOutputDirection;

			uniform sampler2D envMap;
			uniform int samples;
			uniform float weights[ n ];
			uniform bool latitudinal;
			uniform float dTheta;
			uniform float mipInt;
			uniform vec3 poleAxis;

			#define ENVMAP_TYPE_CUBE_UV
			#include <cube_uv_reflection_fragment>

			vec3 getSample( float theta, vec3 axis ) {

				float cosTheta = cos( theta );
				// Rodrigues' axis-angle rotation
				vec3 sampleDirection = vOutputDirection * cosTheta
					+ cross( axis, vOutputDirection ) * sin( theta )
					+ axis * dot( axis, vOutputDirection ) * ( 1.0 - cosTheta );

				return bilinearCubeUV( envMap, sampleDirection, mipInt );

			}

			void main() {

				vec3 axis = latitudinal ? poleAxis : cross( poleAxis, vOutputDirection );

				if ( all( equal( axis, vec3( 0.0 ) ) ) ) {

					axis = vec3( vOutputDirection.z, 0.0, - vOutputDirection.x );

				}

				axis = normalize( axis );

				gl_FragColor = vec4( 0.0, 0.0, 0.0, 1.0 );
				gl_FragColor.rgb += weights[ 0 ] * getSample( 0.0, axis );

				for ( int i = 1; i < n; i++ ) {

					if ( i >= samples ) {

						break;

					}

					float theta = dTheta * float( i );
					gl_FragColor.rgb += weights[ i ] * getSample( -1.0 * theta, axis );
					gl_FragColor.rgb += weights[ i ] * getSample( theta, axis );

				}

			}
		`,blending:hn,depthTest:!1,depthWrite:!1})}function Ea(){return new we({name:"EquirectangularToCubeUV",uniforms:{envMap:{value:null}},vertexShader:ao(),fragmentShader:`

			precision mediump float;
			precision mediump int;

			varying vec3 vOutputDirection;

			uniform sampler2D envMap;

			#include <common>

			void main() {

				vec3 outputDirection = normalize( vOutputDirection );
				vec2 uv = equirectUv( outputDirection );

				gl_FragColor = vec4( texture2D ( envMap, uv ).rgb, 1.0 );

			}
		`,blending:hn,depthTest:!1,depthWrite:!1})}function wa(){return new we({name:"CubemapToCubeUV",uniforms:{envMap:{value:null},flipEnvMap:{value:-1}},vertexShader:ao(),fragmentShader:`

			precision mediump float;
			precision mediump int;

			uniform float flipEnvMap;

			varying vec3 vOutputDirection;

			uniform samplerCube envMap;

			void main() {

				gl_FragColor = textureCube( envMap, vec3( flipEnvMap * vOutputDirection.x, vOutputDirection.yz ) );

			}
		`,blending:hn,depthTest:!1,depthWrite:!1})}function ao(){return`

		precision mediump float;
		precision mediump int;

		attribute float faceIndex;

		varying vec3 vOutputDirection;

		// RH coordinate system; PMREM face-indexing convention
		vec3 getDirection( vec2 uv, float face ) {

			uv = 2.0 * uv - 1.0;

			vec3 direction = vec3( uv, 1.0 );

			if ( face == 0.0 ) {

				direction = direction.zyx; // ( 1, v, u ) pos x

			} else if ( face == 1.0 ) {

				direction = direction.xzy;
				direction.xz *= -1.0; // ( -u, 1, -v ) pos y

			} else if ( face == 2.0 ) {

				direction.x *= -1.0; // ( -u, v, 1 ) pos z

			} else if ( face == 3.0 ) {

				direction = direction.zyx;
				direction.xz *= -1.0; // ( -1, v, -u ) neg x

			} else if ( face == 4.0 ) {

				direction = direction.xzy;
				direction.xy *= -1.0; // ( -u, -1, v ) neg y

			} else if ( face == 5.0 ) {

				direction.z *= -1.0; // ( u, v, -1 ) neg z

			}

			return direction;

		}

		void main() {

			vOutputDirection = getDirection( uv, faceIndex );
			gl_Position = vec4( position, 1.0 );

		}
	`}function zf(i){let t=new WeakMap,e=null;function n(a){if(a&&a.isTexture){const c=a.mapping,l=c===Gs||c===ks,h=c===yi||c===Si;if(l||h)if(a.isRenderTargetTexture&&a.needsPMREMUpdate===!0){a.needsPMREMUpdate=!1;let f=t.get(a);return e===null&&(e=new qs(i)),f=l?e.fromEquirectangular(a,f):e.fromCubemap(a,f),t.set(a,f),f.texture}else{if(t.has(a))return t.get(a).texture;{const f=a.image;if(l&&f&&f.height>0||h&&f&&r(f)){e===null&&(e=new qs(i));const m=l?e.fromEquirectangular(a):e.fromCubemap(a);return t.set(a,m),a.addEventListener("dispose",s),m.texture}else return null}}}return a}function r(a){let c=0;const l=6;for(let h=0;h<l;h++)a[h]!==void 0&&c++;return c===l}function s(a){const c=a.target;c.removeEventListener("dispose",s);const l=t.get(c);l!==void 0&&(t.delete(c),l.dispose())}function o(){t=new WeakMap,e!==null&&(e.dispose(),e=null)}return{get:n,dispose:o}}function Gf(i){const t={};function e(n){if(t[n]!==void 0)return t[n];let r;switch(n){case"WEBGL_depth_texture":r=i.getExtension("WEBGL_depth_texture")||i.getExtension("MOZ_WEBGL_depth_texture")||i.getExtension("WEBKIT_WEBGL_depth_texture");break;case"EXT_texture_filter_anisotropic":r=i.getExtension("EXT_texture_filter_anisotropic")||i.getExtension("MOZ_EXT_texture_filter_anisotropic")||i.getExtension("WEBKIT_EXT_texture_filter_anisotropic");break;case"WEBGL_compressed_texture_s3tc":r=i.getExtension("WEBGL_compressed_texture_s3tc")||i.getExtension("MOZ_WEBGL_compressed_texture_s3tc")||i.getExtension("WEBKIT_WEBGL_compressed_texture_s3tc");break;case"WEBGL_compressed_texture_pvrtc":r=i.getExtension("WEBGL_compressed_texture_pvrtc")||i.getExtension("WEBKIT_WEBGL_compressed_texture_pvrtc");break;default:r=i.getExtension(n)}return t[n]=r,r}return{has:function(n){return e(n)!==null},init:function(n){n.isWebGL2?(e("EXT_color_buffer_float"),e("WEBGL_clip_cull_distance")):(e("WEBGL_depth_texture"),e("OES_texture_float"),e("OES_texture_half_float"),e("OES_texture_half_float_linear"),e("OES_standard_derivatives"),e("OES_element_index_uint"),e("OES_vertex_array_object"),e("ANGLE_instanced_arrays")),e("OES_texture_float_linear"),e("EXT_color_buffer_half_float"),e("WEBGL_multisampled_render_to_texture")},get:function(n){const r=e(n);return r===null&&console.warn("THREE.WebGLRenderer: "+n+" extension not supported."),r}}}function kf(i,t,e,n){const r={},s=new WeakMap;function o(f){const m=f.target;m.index!==null&&t.remove(m.index);for(const _ in m.attributes)t.remove(m.attributes[_]);for(const _ in m.morphAttributes){const x=m.morphAttributes[_];for(let d=0,u=x.length;d<u;d++)t.remove(x[d])}m.removeEventListener("dispose",o),delete r[m.id];const p=s.get(m);p&&(t.remove(p),s.delete(m)),n.releaseStatesOfGeometry(m),m.isInstancedBufferGeometry===!0&&delete m._maxInstanceCount,e.memory.geometries--}function a(f,m){return r[m.id]===!0||(m.addEventListener("dispose",o),r[m.id]=!0,e.memory.geometries++),m}function c(f){const m=f.attributes;for(const _ in m)t.update(m[_],i.ARRAY_BUFFER);const p=f.morphAttributes;for(const _ in p){const x=p[_];for(let d=0,u=x.length;d<u;d++)t.update(x[d],i.ARRAY_BUFFER)}}function l(f){const m=[],p=f.index,_=f.attributes.position;let x=0;if(p!==null){const M=p.array;x=p.version;for(let g=0,y=M.length;g<y;g+=3){const L=M[g+0],C=M[g+1],D=M[g+2];m.push(L,C,C,D,D,L)}}else if(_!==void 0){const M=_.array;x=_.version;for(let g=0,y=M.length/3-1;g<y;g+=3){const L=g+0,C=g+1,D=g+2;m.push(L,C,C,D,D,L)}}else return;const d=new(Dc(m)?Bc:Fc)(m,1);d.version=x;const u=s.get(f);u&&t.remove(u),s.set(f,d)}function h(f){const m=s.get(f);if(m){const p=f.index;p!==null&&m.version<p.version&&l(f)}else l(f);return s.get(f)}return{get:a,update:c,getWireframeAttribute:h}}function Hf(i,t,e,n){const r=n.isWebGL2;let s;function o(p){s=p}let a,c;function l(p){a=p.type,c=p.bytesPerElement}function h(p,_){i.drawElements(s,_,a,p*c),e.update(_,s,1)}function f(p,_,x){if(x===0)return;let d,u;if(r)d=i,u="drawElementsInstanced";else if(d=t.get("ANGLE_instanced_arrays"),u="drawElementsInstancedANGLE",d===null){console.error("THREE.WebGLIndexedBufferRenderer: using THREE.InstancedBufferGeometry but hardware does not support extension ANGLE_instanced_arrays.");return}d[u](s,_,a,p*c,x),e.update(_,s,x)}function m(p,_,x){if(x===0)return;const d=t.get("WEBGL_multi_draw");if(d===null)for(let u=0;u<x;u++)this.render(p[u]/c,_[u]);else{d.multiDrawElementsWEBGL(s,_,0,a,p,0,x);let u=0;for(let M=0;M<x;M++)u+=_[M];e.update(u,s,1)}}this.setMode=o,this.setIndex=l,this.render=h,this.renderInstances=f,this.renderMultiDraw=m}function Vf(i){const t={geometries:0,textures:0},e={frame:0,calls:0,triangles:0,points:0,lines:0};function n(s,o,a){switch(e.calls++,o){case i.TRIANGLES:e.triangles+=a*(s/3);break;case i.LINES:e.lines+=a*(s/2);break;case i.LINE_STRIP:e.lines+=a*(s-1);break;case i.LINE_LOOP:e.lines+=a*s;break;case i.POINTS:e.points+=a*s;break;default:console.error("THREE.WebGLInfo: Unknown draw mode:",o);break}}function r(){e.calls=0,e.triangles=0,e.points=0,e.lines=0}return{memory:t,render:e,programs:null,autoReset:!0,reset:r,update:n}}function Xf(i,t){return i[0]-t[0]}function Wf(i,t){return Math.abs(t[1])-Math.abs(i[1])}function qf(i,t,e){const n={},r=new Float32Array(8),s=new WeakMap,o=new oe,a=[];for(let l=0;l<8;l++)a[l]=[l,0];function c(l,h,f){const m=l.morphTargetInfluences;if(t.isWebGL2===!0){const _=h.morphAttributes.position||h.morphAttributes.normal||h.morphAttributes.color,x=_!==void 0?_.length:0;let d=s.get(h);if(d===void 0||d.count!==x){let b=function(){B.dispose(),s.delete(h),h.removeEventListener("dispose",b)};var p=b;d!==void 0&&d.texture.dispose();const g=h.morphAttributes.position!==void 0,y=h.morphAttributes.normal!==void 0,L=h.morphAttributes.color!==void 0,C=h.morphAttributes.position||[],D=h.morphAttributes.normal||[],F=h.morphAttributes.color||[];let T=0;g===!0&&(T=1),y===!0&&(T=2),L===!0&&(T=3);let E=h.attributes.position.count*T,j=1;E>t.maxTextureSize&&(j=Math.ceil(E/t.maxTextureSize),E=t.maxTextureSize);const O=new Float32Array(E*j*4*x),B=new Nc(O,E,j,x);B.type=En,B.needsUpdate=!0;const S=T*4;for(let v=0;v<x;v++){const A=C[v],I=D[v],U=F[v],P=E*j*4*v;for(let N=0;N<A.count;N++){const Y=N*S;g===!0&&(o.fromBufferAttribute(A,N),O[P+Y+0]=o.x,O[P+Y+1]=o.y,O[P+Y+2]=o.z,O[P+Y+3]=0),y===!0&&(o.fromBufferAttribute(I,N),O[P+Y+4]=o.x,O[P+Y+5]=o.y,O[P+Y+6]=o.z,O[P+Y+7]=0),L===!0&&(o.fromBufferAttribute(U,N),O[P+Y+8]=o.x,O[P+Y+9]=o.y,O[P+Y+10]=o.z,O[P+Y+11]=U.itemSize===4?o.w:1)}}d={count:x,texture:B,size:new At(E,j)},s.set(h,d),h.addEventListener("dispose",b)}let u=0;for(let g=0;g<m.length;g++)u+=m[g];const M=h.morphTargetsRelative?1:1-u;f.getUniforms().setValue(i,"morphTargetBaseInfluence",M),f.getUniforms().setValue(i,"morphTargetInfluences",m),f.getUniforms().setValue(i,"morphTargetsTexture",d.texture,e),f.getUniforms().setValue(i,"morphTargetsTextureSize",d.size)}else{const _=m===void 0?0:m.length;let x=n[h.id];if(x===void 0||x.length!==_){x=[];for(let y=0;y<_;y++)x[y]=[y,0];n[h.id]=x}for(let y=0;y<_;y++){const L=x[y];L[0]=y,L[1]=m[y]}x.sort(Wf);for(let y=0;y<8;y++)y<_&&x[y][1]?(a[y][0]=x[y][0],a[y][1]=x[y][1]):(a[y][0]=Number.MAX_SAFE_INTEGER,a[y][1]=0);a.sort(Xf);const d=h.morphAttributes.position,u=h.morphAttributes.normal;let M=0;for(let y=0;y<8;y++){const L=a[y],C=L[0],D=L[1];C!==Number.MAX_SAFE_INTEGER&&D?(d&&h.getAttribute("morphTarget"+y)!==d[C]&&h.setAttribute("morphTarget"+y,d[C]),u&&h.getAttribute("morphNormal"+y)!==u[C]&&h.setAttribute("morphNormal"+y,u[C]),r[y]=D,M+=D):(d&&h.hasAttribute("morphTarget"+y)===!0&&h.deleteAttribute("morphTarget"+y),u&&h.hasAttribute("morphNormal"+y)===!0&&h.deleteAttribute("morphNormal"+y),r[y]=0)}const g=h.morphTargetsRelative?1:1-M;f.getUniforms().setValue(i,"morphTargetBaseInfluence",g),f.getUniforms().setValue(i,"morphTargetInfluences",r)}}return{update:c}}function Yf(i,t,e,n){let r=new WeakMap;function s(c){const l=n.render.frame,h=c.geometry,f=t.get(c,h);if(r.get(f)!==l&&(t.update(f),r.set(f,l)),c.isInstancedMesh&&(c.hasEventListener("dispose",a)===!1&&c.addEventListener("dispose",a),r.get(c)!==l&&(e.update(c.instanceMatrix,i.ARRAY_BUFFER),c.instanceColor!==null&&e.update(c.instanceColor,i.ARRAY_BUFFER),r.set(c,l))),c.isSkinnedMesh){const m=c.skeleton;r.get(m)!==l&&(m.update(),r.set(m,l))}return f}function o(){r=new WeakMap}function a(c){const l=c.target;l.removeEventListener("dispose",a),e.remove(l.instanceMatrix),l.instanceColor!==null&&e.remove(l.instanceColor)}return{update:s,dispose:o}}class Vc extends Te{constructor(t,e,n,r,s,o,a,c,l,h){if(h=h!==void 0?h:Gn,h!==Gn&&h!==Ei)throw new Error("DepthTexture format must be either THREE.DepthFormat or THREE.DepthStencilFormat");n===void 0&&h===Gn&&(n=bn),n===void 0&&h===Ei&&(n=zn),super(null,r,s,o,a,c,h,n,l),this.isDepthTexture=!0,this.image={width:t,height:e},this.magFilter=a!==void 0?a:Le,this.minFilter=c!==void 0?c:Le,this.flipY=!1,this.generateMipmaps=!1,this.compareFunction=null}copy(t){return super.copy(t),this.compareFunction=t.compareFunction,this}toJSON(t){const e=super.toJSON(t);return this.compareFunction!==null&&(e.compareFunction=this.compareFunction),e}}const Xc=new Te,Wc=new Vc(1,1);Wc.compareFunction=Pc;const qc=new Nc,Yc=new Lu,jc=new kc,Ta=[],Aa=[],Ra=new Float32Array(16),Ca=new Float32Array(9),Pa=new Float32Array(4);function Ri(i,t,e){const n=i[0];if(n<=0||n>0)return i;const r=t*e;let s=Ta[r];if(s===void 0&&(s=new Float32Array(r),Ta[r]=s),t!==0){n.toArray(s,0);for(let o=1,a=0;o!==t;++o)a+=e,i[o].toArray(s,a)}return s}function me(i,t){if(i.length!==t.length)return!1;for(let e=0,n=i.length;e<n;e++)if(i[e]!==t[e])return!1;return!0}function ge(i,t){for(let e=0,n=t.length;e<n;e++)i[e]=t[e]}function qr(i,t){let e=Aa[t];e===void 0&&(e=new Int32Array(t),Aa[t]=e);for(let n=0;n!==t;++n)e[n]=i.allocateTextureUnit();return e}function jf(i,t){const e=this.cache;e[0]!==t&&(i.uniform1f(this.addr,t),e[0]=t)}function $f(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y)&&(i.uniform2f(this.addr,t.x,t.y),e[0]=t.x,e[1]=t.y);else{if(me(e,t))return;i.uniform2fv(this.addr,t),ge(e,t)}}function Kf(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z)&&(i.uniform3f(this.addr,t.x,t.y,t.z),e[0]=t.x,e[1]=t.y,e[2]=t.z);else if(t.r!==void 0)(e[0]!==t.r||e[1]!==t.g||e[2]!==t.b)&&(i.uniform3f(this.addr,t.r,t.g,t.b),e[0]=t.r,e[1]=t.g,e[2]=t.b);else{if(me(e,t))return;i.uniform3fv(this.addr,t),ge(e,t)}}function Zf(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z||e[3]!==t.w)&&(i.uniform4f(this.addr,t.x,t.y,t.z,t.w),e[0]=t.x,e[1]=t.y,e[2]=t.z,e[3]=t.w);else{if(me(e,t))return;i.uniform4fv(this.addr,t),ge(e,t)}}function Jf(i,t){const e=this.cache,n=t.elements;if(n===void 0){if(me(e,t))return;i.uniformMatrix2fv(this.addr,!1,t),ge(e,t)}else{if(me(e,n))return;Pa.set(n),i.uniformMatrix2fv(this.addr,!1,Pa),ge(e,n)}}function Qf(i,t){const e=this.cache,n=t.elements;if(n===void 0){if(me(e,t))return;i.uniformMatrix3fv(this.addr,!1,t),ge(e,t)}else{if(me(e,n))return;Ca.set(n),i.uniformMatrix3fv(this.addr,!1,Ca),ge(e,n)}}function tp(i,t){const e=this.cache,n=t.elements;if(n===void 0){if(me(e,t))return;i.uniformMatrix4fv(this.addr,!1,t),ge(e,t)}else{if(me(e,n))return;Ra.set(n),i.uniformMatrix4fv(this.addr,!1,Ra),ge(e,n)}}function ep(i,t){const e=this.cache;e[0]!==t&&(i.uniform1i(this.addr,t),e[0]=t)}function np(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y)&&(i.uniform2i(this.addr,t.x,t.y),e[0]=t.x,e[1]=t.y);else{if(me(e,t))return;i.uniform2iv(this.addr,t),ge(e,t)}}function ip(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z)&&(i.uniform3i(this.addr,t.x,t.y,t.z),e[0]=t.x,e[1]=t.y,e[2]=t.z);else{if(me(e,t))return;i.uniform3iv(this.addr,t),ge(e,t)}}function rp(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z||e[3]!==t.w)&&(i.uniform4i(this.addr,t.x,t.y,t.z,t.w),e[0]=t.x,e[1]=t.y,e[2]=t.z,e[3]=t.w);else{if(me(e,t))return;i.uniform4iv(this.addr,t),ge(e,t)}}function sp(i,t){const e=this.cache;e[0]!==t&&(i.uniform1ui(this.addr,t),e[0]=t)}function op(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y)&&(i.uniform2ui(this.addr,t.x,t.y),e[0]=t.x,e[1]=t.y);else{if(me(e,t))return;i.uniform2uiv(this.addr,t),ge(e,t)}}function ap(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z)&&(i.uniform3ui(this.addr,t.x,t.y,t.z),e[0]=t.x,e[1]=t.y,e[2]=t.z);else{if(me(e,t))return;i.uniform3uiv(this.addr,t),ge(e,t)}}function cp(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z||e[3]!==t.w)&&(i.uniform4ui(this.addr,t.x,t.y,t.z,t.w),e[0]=t.x,e[1]=t.y,e[2]=t.z,e[3]=t.w);else{if(me(e,t))return;i.uniform4uiv(this.addr,t),ge(e,t)}}function lp(i,t,e){const n=this.cache,r=e.allocateTextureUnit();n[0]!==r&&(i.uniform1i(this.addr,r),n[0]=r);const s=this.type===i.SAMPLER_2D_SHADOW?Wc:Xc;e.setTexture2D(t||s,r)}function up(i,t,e){const n=this.cache,r=e.allocateTextureUnit();n[0]!==r&&(i.uniform1i(this.addr,r),n[0]=r),e.setTexture3D(t||Yc,r)}function hp(i,t,e){const n=this.cache,r=e.allocateTextureUnit();n[0]!==r&&(i.uniform1i(this.addr,r),n[0]=r),e.setTextureCube(t||jc,r)}function dp(i,t,e){const n=this.cache,r=e.allocateTextureUnit();n[0]!==r&&(i.uniform1i(this.addr,r),n[0]=r),e.setTexture2DArray(t||qc,r)}function fp(i){switch(i){case 5126:return jf;case 35664:return $f;case 35665:return Kf;case 35666:return Zf;case 35674:return Jf;case 35675:return Qf;case 35676:return tp;case 5124:case 35670:return ep;case 35667:case 35671:return np;case 35668:case 35672:return ip;case 35669:case 35673:return rp;case 5125:return sp;case 36294:return op;case 36295:return ap;case 36296:return cp;case 35678:case 36198:case 36298:case 36306:case 35682:return lp;case 35679:case 36299:case 36307:return up;case 35680:case 36300:case 36308:case 36293:return hp;case 36289:case 36303:case 36311:case 36292:return dp}}function pp(i,t){i.uniform1fv(this.addr,t)}function mp(i,t){const e=Ri(t,this.size,2);i.uniform2fv(this.addr,e)}function gp(i,t){const e=Ri(t,this.size,3);i.uniform3fv(this.addr,e)}function _p(i,t){const e=Ri(t,this.size,4);i.uniform4fv(this.addr,e)}function vp(i,t){const e=Ri(t,this.size,4);i.uniformMatrix2fv(this.addr,!1,e)}function xp(i,t){const e=Ri(t,this.size,9);i.uniformMatrix3fv(this.addr,!1,e)}function Mp(i,t){const e=Ri(t,this.size,16);i.uniformMatrix4fv(this.addr,!1,e)}function yp(i,t){i.uniform1iv(this.addr,t)}function Sp(i,t){i.uniform2iv(this.addr,t)}function bp(i,t){i.uniform3iv(this.addr,t)}function Ep(i,t){i.uniform4iv(this.addr,t)}function wp(i,t){i.uniform1uiv(this.addr,t)}function Tp(i,t){i.uniform2uiv(this.addr,t)}function Ap(i,t){i.uniform3uiv(this.addr,t)}function Rp(i,t){i.uniform4uiv(this.addr,t)}function Cp(i,t,e){const n=this.cache,r=t.length,s=qr(e,r);me(n,s)||(i.uniform1iv(this.addr,s),ge(n,s));for(let o=0;o!==r;++o)e.setTexture2D(t[o]||Xc,s[o])}function Pp(i,t,e){const n=this.cache,r=t.length,s=qr(e,r);me(n,s)||(i.uniform1iv(this.addr,s),ge(n,s));for(let o=0;o!==r;++o)e.setTexture3D(t[o]||Yc,s[o])}function Lp(i,t,e){const n=this.cache,r=t.length,s=qr(e,r);me(n,s)||(i.uniform1iv(this.addr,s),ge(n,s));for(let o=0;o!==r;++o)e.setTextureCube(t[o]||jc,s[o])}function Dp(i,t,e){const n=this.cache,r=t.length,s=qr(e,r);me(n,s)||(i.uniform1iv(this.addr,s),ge(n,s));for(let o=0;o!==r;++o)e.setTexture2DArray(t[o]||qc,s[o])}function Ip(i){switch(i){case 5126:return pp;case 35664:return mp;case 35665:return gp;case 35666:return _p;case 35674:return vp;case 35675:return xp;case 35676:return Mp;case 5124:case 35670:return yp;case 35667:case 35671:return Sp;case 35668:case 35672:return bp;case 35669:case 35673:return Ep;case 5125:return wp;case 36294:return Tp;case 36295:return Ap;case 36296:return Rp;case 35678:case 36198:case 36298:case 36306:case 35682:return Cp;case 35679:case 36299:case 36307:return Pp;case 35680:case 36300:case 36308:case 36293:return Lp;case 36289:case 36303:case 36311:case 36292:return Dp}}class Up{constructor(t,e,n){this.id=t,this.addr=n,this.cache=[],this.type=e.type,this.setValue=fp(e.type)}}class Np{constructor(t,e,n){this.id=t,this.addr=n,this.cache=[],this.type=e.type,this.size=e.size,this.setValue=Ip(e.type)}}class Op{constructor(t){this.id=t,this.seq=[],this.map={}}setValue(t,e,n){const r=this.seq;for(let s=0,o=r.length;s!==o;++s){const a=r[s];a.setValue(t,e[a.id],n)}}}const As=/(\w+)(\])?(\[|\.)?/g;function La(i,t){i.seq.push(t),i.map[t.id]=t}function Fp(i,t,e){const n=i.name,r=n.length;for(As.lastIndex=0;;){const s=As.exec(n),o=As.lastIndex;let a=s[1];const c=s[2]==="]",l=s[3];if(c&&(a=a|0),l===void 0||l==="["&&o+2===r){La(e,l===void 0?new Up(a,i,t):new Np(a,i,t));break}else{let f=e.map[a];f===void 0&&(f=new Op(a),La(e,f)),e=f}}}class Dr{constructor(t,e){this.seq=[],this.map={};const n=t.getProgramParameter(e,t.ACTIVE_UNIFORMS);for(let r=0;r<n;++r){const s=t.getActiveUniform(e,r),o=t.getUniformLocation(e,s.name);Fp(s,o,this)}}setValue(t,e,n,r){const s=this.map[e];s!==void 0&&s.setValue(t,n,r)}setOptional(t,e,n){const r=e[n];r!==void 0&&this.setValue(t,n,r)}static upload(t,e,n,r){for(let s=0,o=e.length;s!==o;++s){const a=e[s],c=n[a.id];c.needsUpdate!==!1&&a.setValue(t,c.value,r)}}static seqWithValue(t,e){const n=[];for(let r=0,s=t.length;r!==s;++r){const o=t[r];o.id in e&&n.push(o)}return n}}function Da(i,t,e){const n=i.createShader(t);return i.shaderSource(n,e),i.compileShader(n),n}const Bp=37297;let zp=0;function Gp(i,t){const e=i.split(`
`),n=[],r=Math.max(t-6,0),s=Math.min(t+6,e.length);for(let o=r;o<s;o++){const a=o+1;n.push(`${a===t?">":" "} ${a}: ${e[o]}`)}return n.join(`
`)}function kp(i){const t=te.getPrimaries(te.workingColorSpace),e=te.getPrimaries(i);let n;switch(t===e?n="":t===Br&&e===Fr?n="LinearDisplayP3ToLinearSRGB":t===Fr&&e===Br&&(n="LinearSRGBToLinearDisplayP3"),i){case mn:case Wr:return[n,"LinearTransferOETF"];case he:case no:return[n,"sRGBTransferOETF"];default:return console.warn("THREE.WebGLProgram: Unsupported color space:",i),[n,"LinearTransferOETF"]}}function Ia(i,t,e){const n=i.getShaderParameter(t,i.COMPILE_STATUS),r=i.getShaderInfoLog(t).trim();if(n&&r==="")return"";const s=/ERROR: 0:(\d+)/.exec(r);if(s){const o=parseInt(s[1]);return e.toUpperCase()+`

`+r+`

`+Gp(i.getShaderSource(t),o)}else return r}function Hp(i,t){const e=kp(t);return`vec4 ${i}( vec4 value ) { return ${e[0]}( ${e[1]}( value ) ); }`}function Vp(i,t){let e;switch(t){case gc:e="Linear";break;case _c:e="Reinhard";break;case vc:e="OptimizedCineon";break;case to:e="ACESFilmic";break;case xc:e="AgX";break;case ql:e="Custom";break;default:console.warn("THREE.WebGLProgram: Unsupported toneMapping:",t),e="Linear"}return"vec3 "+i+"( vec3 color ) { return "+e+"ToneMapping( color ); }"}function Xp(i){return[i.extensionDerivatives||i.envMapCubeUVHeight||i.bumpMap||i.normalMapTangentSpace||i.clearcoatNormalMap||i.flatShading||i.shaderID==="physical"?"#extension GL_OES_standard_derivatives : enable":"",(i.extensionFragDepth||i.logarithmicDepthBuffer)&&i.rendererExtensionFragDepth?"#extension GL_EXT_frag_depth : enable":"",i.extensionDrawBuffers&&i.rendererExtensionDrawBuffers?"#extension GL_EXT_draw_buffers : require":"",(i.extensionShaderTextureLOD||i.envMap||i.transmission)&&i.rendererExtensionShaderTextureLod?"#extension GL_EXT_shader_texture_lod : enable":""].filter(_i).join(`
`)}function Wp(i){return[i.extensionClipCullDistance?"#extension GL_ANGLE_clip_cull_distance : require":""].filter(_i).join(`
`)}function qp(i){const t=[];for(const e in i){const n=i[e];n!==!1&&t.push("#define "+e+" "+n)}return t.join(`
`)}function Yp(i,t){const e={},n=i.getProgramParameter(t,i.ACTIVE_ATTRIBUTES);for(let r=0;r<n;r++){const s=i.getActiveAttrib(t,r),o=s.name;let a=1;s.type===i.FLOAT_MAT2&&(a=2),s.type===i.FLOAT_MAT3&&(a=3),s.type===i.FLOAT_MAT4&&(a=4),e[o]={type:s.type,location:i.getAttribLocation(t,o),locationSize:a}}return e}function _i(i){return i!==""}function Ua(i,t){const e=t.numSpotLightShadows+t.numSpotLightMaps-t.numSpotLightShadowsWithMaps;return i.replace(/NUM_DIR_LIGHTS/g,t.numDirLights).replace(/NUM_SPOT_LIGHTS/g,t.numSpotLights).replace(/NUM_SPOT_LIGHT_MAPS/g,t.numSpotLightMaps).replace(/NUM_SPOT_LIGHT_COORDS/g,e).replace(/NUM_RECT_AREA_LIGHTS/g,t.numRectAreaLights).replace(/NUM_POINT_LIGHTS/g,t.numPointLights).replace(/NUM_HEMI_LIGHTS/g,t.numHemiLights).replace(/NUM_DIR_LIGHT_SHADOWS/g,t.numDirLightShadows).replace(/NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS/g,t.numSpotLightShadowsWithMaps).replace(/NUM_SPOT_LIGHT_SHADOWS/g,t.numSpotLightShadows).replace(/NUM_POINT_LIGHT_SHADOWS/g,t.numPointLightShadows)}function Na(i,t){return i.replace(/NUM_CLIPPING_PLANES/g,t.numClippingPlanes).replace(/UNION_CLIPPING_PLANES/g,t.numClippingPlanes-t.numClipIntersection)}const jp=/^[ \t]*#include +<([\w\d./]+)>/gm;function Ys(i){return i.replace(jp,Kp)}const $p=new Map([["encodings_fragment","colorspace_fragment"],["encodings_pars_fragment","colorspace_pars_fragment"],["output_fragment","opaque_fragment"]]);function Kp(i,t){let e=Yt[t];if(e===void 0){const n=$p.get(t);if(n!==void 0)e=Yt[n],console.warn('THREE.WebGLRenderer: Shader chunk "%s" has been deprecated. Use "%s" instead.',t,n);else throw new Error("Can not resolve #include <"+t+">")}return Ys(e)}const Zp=/#pragma unroll_loop_start\s+for\s*\(\s*int\s+i\s*=\s*(\d+)\s*;\s*i\s*<\s*(\d+)\s*;\s*i\s*\+\+\s*\)\s*{([\s\S]+?)}\s+#pragma unroll_loop_end/g;function Oa(i){return i.replace(Zp,Jp)}function Jp(i,t,e,n){let r="";for(let s=parseInt(t);s<parseInt(e);s++)r+=n.replace(/\[\s*i\s*\]/g,"[ "+s+" ]").replace(/UNROLLED_LOOP_INDEX/g,s);return r}function Fa(i){let t="precision "+i.precision+` float;
precision `+i.precision+" int;";return i.precision==="highp"?t+=`
#define HIGH_PRECISION`:i.precision==="mediump"?t+=`
#define MEDIUM_PRECISION`:i.precision==="lowp"&&(t+=`
#define LOW_PRECISION`),t}function Qp(i){let t="SHADOWMAP_TYPE_BASIC";return i.shadowMapType===fc?t="SHADOWMAP_TYPE_PCF":i.shadowMapType===pc?t="SHADOWMAP_TYPE_PCF_SOFT":i.shadowMapType===ln&&(t="SHADOWMAP_TYPE_VSM"),t}function tm(i){let t="ENVMAP_TYPE_CUBE";if(i.envMap)switch(i.envMapMode){case yi:case Si:t="ENVMAP_TYPE_CUBE";break;case Xr:t="ENVMAP_TYPE_CUBE_UV";break}return t}function em(i){let t="ENVMAP_MODE_REFLECTION";if(i.envMap)switch(i.envMapMode){case Si:t="ENVMAP_MODE_REFRACTION";break}return t}function nm(i){let t="ENVMAP_BLENDING_NONE";if(i.envMap)switch(i.combine){case mc:t="ENVMAP_BLENDING_MULTIPLY";break;case Xl:t="ENVMAP_BLENDING_MIX";break;case Wl:t="ENVMAP_BLENDING_ADD";break}return t}function im(i){const t=i.envMapCubeUVHeight;if(t===null)return null;const e=Math.log2(t)-2,n=1/t;return{texelWidth:1/(3*Math.max(Math.pow(2,e),7*16)),texelHeight:n,maxMip:e}}function rm(i,t,e,n){const r=i.getContext(),s=e.defines;let o=e.vertexShader,a=e.fragmentShader;const c=Qp(e),l=tm(e),h=em(e),f=nm(e),m=im(e),p=e.isWebGL2?"":Xp(e),_=Wp(e),x=qp(s),d=r.createProgram();let u,M,g=e.glslVersion?"#version "+e.glslVersion+`
`:"";e.isRawShaderMaterial?(u=["#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,x].filter(_i).join(`
`),u.length>0&&(u+=`
`),M=[p,"#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,x].filter(_i).join(`
`),M.length>0&&(M+=`
`)):(u=[Fa(e),"#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,x,e.extensionClipCullDistance?"#define USE_CLIP_DISTANCE":"",e.batching?"#define USE_BATCHING":"",e.instancing?"#define USE_INSTANCING":"",e.instancingColor?"#define USE_INSTANCING_COLOR":"",e.useFog&&e.fog?"#define USE_FOG":"",e.useFog&&e.fogExp2?"#define FOG_EXP2":"",e.map?"#define USE_MAP":"",e.envMap?"#define USE_ENVMAP":"",e.envMap?"#define "+h:"",e.lightMap?"#define USE_LIGHTMAP":"",e.aoMap?"#define USE_AOMAP":"",e.bumpMap?"#define USE_BUMPMAP":"",e.normalMap?"#define USE_NORMALMAP":"",e.normalMapObjectSpace?"#define USE_NORMALMAP_OBJECTSPACE":"",e.normalMapTangentSpace?"#define USE_NORMALMAP_TANGENTSPACE":"",e.displacementMap?"#define USE_DISPLACEMENTMAP":"",e.emissiveMap?"#define USE_EMISSIVEMAP":"",e.anisotropy?"#define USE_ANISOTROPY":"",e.anisotropyMap?"#define USE_ANISOTROPYMAP":"",e.clearcoatMap?"#define USE_CLEARCOATMAP":"",e.clearcoatRoughnessMap?"#define USE_CLEARCOAT_ROUGHNESSMAP":"",e.clearcoatNormalMap?"#define USE_CLEARCOAT_NORMALMAP":"",e.iridescenceMap?"#define USE_IRIDESCENCEMAP":"",e.iridescenceThicknessMap?"#define USE_IRIDESCENCE_THICKNESSMAP":"",e.specularMap?"#define USE_SPECULARMAP":"",e.specularColorMap?"#define USE_SPECULAR_COLORMAP":"",e.specularIntensityMap?"#define USE_SPECULAR_INTENSITYMAP":"",e.roughnessMap?"#define USE_ROUGHNESSMAP":"",e.metalnessMap?"#define USE_METALNESSMAP":"",e.alphaMap?"#define USE_ALPHAMAP":"",e.alphaHash?"#define USE_ALPHAHASH":"",e.transmission?"#define USE_TRANSMISSION":"",e.transmissionMap?"#define USE_TRANSMISSIONMAP":"",e.thicknessMap?"#define USE_THICKNESSMAP":"",e.sheenColorMap?"#define USE_SHEEN_COLORMAP":"",e.sheenRoughnessMap?"#define USE_SHEEN_ROUGHNESSMAP":"",e.mapUv?"#define MAP_UV "+e.mapUv:"",e.alphaMapUv?"#define ALPHAMAP_UV "+e.alphaMapUv:"",e.lightMapUv?"#define LIGHTMAP_UV "+e.lightMapUv:"",e.aoMapUv?"#define AOMAP_UV "+e.aoMapUv:"",e.emissiveMapUv?"#define EMISSIVEMAP_UV "+e.emissiveMapUv:"",e.bumpMapUv?"#define BUMPMAP_UV "+e.bumpMapUv:"",e.normalMapUv?"#define NORMALMAP_UV "+e.normalMapUv:"",e.displacementMapUv?"#define DISPLACEMENTMAP_UV "+e.displacementMapUv:"",e.metalnessMapUv?"#define METALNESSMAP_UV "+e.metalnessMapUv:"",e.roughnessMapUv?"#define ROUGHNESSMAP_UV "+e.roughnessMapUv:"",e.anisotropyMapUv?"#define ANISOTROPYMAP_UV "+e.anisotropyMapUv:"",e.clearcoatMapUv?"#define CLEARCOATMAP_UV "+e.clearcoatMapUv:"",e.clearcoatNormalMapUv?"#define CLEARCOAT_NORMALMAP_UV "+e.clearcoatNormalMapUv:"",e.clearcoatRoughnessMapUv?"#define CLEARCOAT_ROUGHNESSMAP_UV "+e.clearcoatRoughnessMapUv:"",e.iridescenceMapUv?"#define IRIDESCENCEMAP_UV "+e.iridescenceMapUv:"",e.iridescenceThicknessMapUv?"#define IRIDESCENCE_THICKNESSMAP_UV "+e.iridescenceThicknessMapUv:"",e.sheenColorMapUv?"#define SHEEN_COLORMAP_UV "+e.sheenColorMapUv:"",e.sheenRoughnessMapUv?"#define SHEEN_ROUGHNESSMAP_UV "+e.sheenRoughnessMapUv:"",e.specularMapUv?"#define SPECULARMAP_UV "+e.specularMapUv:"",e.specularColorMapUv?"#define SPECULAR_COLORMAP_UV "+e.specularColorMapUv:"",e.specularIntensityMapUv?"#define SPECULAR_INTENSITYMAP_UV "+e.specularIntensityMapUv:"",e.transmissionMapUv?"#define TRANSMISSIONMAP_UV "+e.transmissionMapUv:"",e.thicknessMapUv?"#define THICKNESSMAP_UV "+e.thicknessMapUv:"",e.vertexTangents&&e.flatShading===!1?"#define USE_TANGENT":"",e.vertexColors?"#define USE_COLOR":"",e.vertexAlphas?"#define USE_COLOR_ALPHA":"",e.vertexUv1s?"#define USE_UV1":"",e.vertexUv2s?"#define USE_UV2":"",e.vertexUv3s?"#define USE_UV3":"",e.pointsUvs?"#define USE_POINTS_UV":"",e.flatShading?"#define FLAT_SHADED":"",e.skinning?"#define USE_SKINNING":"",e.morphTargets?"#define USE_MORPHTARGETS":"",e.morphNormals&&e.flatShading===!1?"#define USE_MORPHNORMALS":"",e.morphColors&&e.isWebGL2?"#define USE_MORPHCOLORS":"",e.morphTargetsCount>0&&e.isWebGL2?"#define MORPHTARGETS_TEXTURE":"",e.morphTargetsCount>0&&e.isWebGL2?"#define MORPHTARGETS_TEXTURE_STRIDE "+e.morphTextureStride:"",e.morphTargetsCount>0&&e.isWebGL2?"#define MORPHTARGETS_COUNT "+e.morphTargetsCount:"",e.doubleSided?"#define DOUBLE_SIDED":"",e.flipSided?"#define FLIP_SIDED":"",e.shadowMapEnabled?"#define USE_SHADOWMAP":"",e.shadowMapEnabled?"#define "+c:"",e.sizeAttenuation?"#define USE_SIZEATTENUATION":"",e.numLightProbes>0?"#define USE_LIGHT_PROBES":"",e.useLegacyLights?"#define LEGACY_LIGHTS":"",e.logarithmicDepthBuffer?"#define USE_LOGDEPTHBUF":"",e.logarithmicDepthBuffer&&e.rendererExtensionFragDepth?"#define USE_LOGDEPTHBUF_EXT":"","uniform mat4 modelMatrix;","uniform mat4 modelViewMatrix;","uniform mat4 projectionMatrix;","uniform mat4 viewMatrix;","uniform mat3 normalMatrix;","uniform vec3 cameraPosition;","uniform bool isOrthographic;","#ifdef USE_INSTANCING","	attribute mat4 instanceMatrix;","#endif","#ifdef USE_INSTANCING_COLOR","	attribute vec3 instanceColor;","#endif","attribute vec3 position;","attribute vec3 normal;","attribute vec2 uv;","#ifdef USE_UV1","	attribute vec2 uv1;","#endif","#ifdef USE_UV2","	attribute vec2 uv2;","#endif","#ifdef USE_UV3","	attribute vec2 uv3;","#endif","#ifdef USE_TANGENT","	attribute vec4 tangent;","#endif","#if defined( USE_COLOR_ALPHA )","	attribute vec4 color;","#elif defined( USE_COLOR )","	attribute vec3 color;","#endif","#if ( defined( USE_MORPHTARGETS ) && ! defined( MORPHTARGETS_TEXTURE ) )","	attribute vec3 morphTarget0;","	attribute vec3 morphTarget1;","	attribute vec3 morphTarget2;","	attribute vec3 morphTarget3;","	#ifdef USE_MORPHNORMALS","		attribute vec3 morphNormal0;","		attribute vec3 morphNormal1;","		attribute vec3 morphNormal2;","		attribute vec3 morphNormal3;","	#else","		attribute vec3 morphTarget4;","		attribute vec3 morphTarget5;","		attribute vec3 morphTarget6;","		attribute vec3 morphTarget7;","	#endif","#endif","#ifdef USE_SKINNING","	attribute vec4 skinIndex;","	attribute vec4 skinWeight;","#endif",`
`].filter(_i).join(`
`),M=[p,Fa(e),"#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,x,e.useFog&&e.fog?"#define USE_FOG":"",e.useFog&&e.fogExp2?"#define FOG_EXP2":"",e.map?"#define USE_MAP":"",e.matcap?"#define USE_MATCAP":"",e.envMap?"#define USE_ENVMAP":"",e.envMap?"#define "+l:"",e.envMap?"#define "+h:"",e.envMap?"#define "+f:"",m?"#define CUBEUV_TEXEL_WIDTH "+m.texelWidth:"",m?"#define CUBEUV_TEXEL_HEIGHT "+m.texelHeight:"",m?"#define CUBEUV_MAX_MIP "+m.maxMip+".0":"",e.lightMap?"#define USE_LIGHTMAP":"",e.aoMap?"#define USE_AOMAP":"",e.bumpMap?"#define USE_BUMPMAP":"",e.normalMap?"#define USE_NORMALMAP":"",e.normalMapObjectSpace?"#define USE_NORMALMAP_OBJECTSPACE":"",e.normalMapTangentSpace?"#define USE_NORMALMAP_TANGENTSPACE":"",e.emissiveMap?"#define USE_EMISSIVEMAP":"",e.anisotropy?"#define USE_ANISOTROPY":"",e.anisotropyMap?"#define USE_ANISOTROPYMAP":"",e.clearcoat?"#define USE_CLEARCOAT":"",e.clearcoatMap?"#define USE_CLEARCOATMAP":"",e.clearcoatRoughnessMap?"#define USE_CLEARCOAT_ROUGHNESSMAP":"",e.clearcoatNormalMap?"#define USE_CLEARCOAT_NORMALMAP":"",e.iridescence?"#define USE_IRIDESCENCE":"",e.iridescenceMap?"#define USE_IRIDESCENCEMAP":"",e.iridescenceThicknessMap?"#define USE_IRIDESCENCE_THICKNESSMAP":"",e.specularMap?"#define USE_SPECULARMAP":"",e.specularColorMap?"#define USE_SPECULAR_COLORMAP":"",e.specularIntensityMap?"#define USE_SPECULAR_INTENSITYMAP":"",e.roughnessMap?"#define USE_ROUGHNESSMAP":"",e.metalnessMap?"#define USE_METALNESSMAP":"",e.alphaMap?"#define USE_ALPHAMAP":"",e.alphaTest?"#define USE_ALPHATEST":"",e.alphaHash?"#define USE_ALPHAHASH":"",e.sheen?"#define USE_SHEEN":"",e.sheenColorMap?"#define USE_SHEEN_COLORMAP":"",e.sheenRoughnessMap?"#define USE_SHEEN_ROUGHNESSMAP":"",e.transmission?"#define USE_TRANSMISSION":"",e.transmissionMap?"#define USE_TRANSMISSIONMAP":"",e.thicknessMap?"#define USE_THICKNESSMAP":"",e.vertexTangents&&e.flatShading===!1?"#define USE_TANGENT":"",e.vertexColors||e.instancingColor?"#define USE_COLOR":"",e.vertexAlphas?"#define USE_COLOR_ALPHA":"",e.vertexUv1s?"#define USE_UV1":"",e.vertexUv2s?"#define USE_UV2":"",e.vertexUv3s?"#define USE_UV3":"",e.pointsUvs?"#define USE_POINTS_UV":"",e.gradientMap?"#define USE_GRADIENTMAP":"",e.flatShading?"#define FLAT_SHADED":"",e.doubleSided?"#define DOUBLE_SIDED":"",e.flipSided?"#define FLIP_SIDED":"",e.shadowMapEnabled?"#define USE_SHADOWMAP":"",e.shadowMapEnabled?"#define "+c:"",e.premultipliedAlpha?"#define PREMULTIPLIED_ALPHA":"",e.numLightProbes>0?"#define USE_LIGHT_PROBES":"",e.useLegacyLights?"#define LEGACY_LIGHTS":"",e.decodeVideoTexture?"#define DECODE_VIDEO_TEXTURE":"",e.logarithmicDepthBuffer?"#define USE_LOGDEPTHBUF":"",e.logarithmicDepthBuffer&&e.rendererExtensionFragDepth?"#define USE_LOGDEPTHBUF_EXT":"","uniform mat4 viewMatrix;","uniform vec3 cameraPosition;","uniform bool isOrthographic;",e.toneMapping!==wn?"#define TONE_MAPPING":"",e.toneMapping!==wn?Yt.tonemapping_pars_fragment:"",e.toneMapping!==wn?Vp("toneMapping",e.toneMapping):"",e.dithering?"#define DITHERING":"",e.opaque?"#define OPAQUE":"",Yt.colorspace_pars_fragment,Hp("linearToOutputTexel",e.outputColorSpace),e.useDepthPacking?"#define DEPTH_PACKING "+e.depthPacking:"",`
`].filter(_i).join(`
`)),o=Ys(o),o=Ua(o,e),o=Na(o,e),a=Ys(a),a=Ua(a,e),a=Na(a,e),o=Oa(o),a=Oa(a),e.isWebGL2&&e.isRawShaderMaterial!==!0&&(g=`#version 300 es
`,u=[_,"precision mediump sampler2DArray;","#define attribute in","#define varying out","#define texture2D texture"].join(`
`)+`
`+u,M=["precision mediump sampler2DArray;","#define varying in",e.glslVersion===na?"":"layout(location = 0) out highp vec4 pc_fragColor;",e.glslVersion===na?"":"#define gl_FragColor pc_fragColor","#define gl_FragDepthEXT gl_FragDepth","#define texture2D texture","#define textureCube texture","#define texture2DProj textureProj","#define texture2DLodEXT textureLod","#define texture2DProjLodEXT textureProjLod","#define textureCubeLodEXT textureLod","#define texture2DGradEXT textureGrad","#define texture2DProjGradEXT textureProjGrad","#define textureCubeGradEXT textureGrad"].join(`
`)+`
`+M);const y=g+u+o,L=g+M+a,C=Da(r,r.VERTEX_SHADER,y),D=Da(r,r.FRAGMENT_SHADER,L);r.attachShader(d,C),r.attachShader(d,D),e.index0AttributeName!==void 0?r.bindAttribLocation(d,0,e.index0AttributeName):e.morphTargets===!0&&r.bindAttribLocation(d,0,"position"),r.linkProgram(d);function F(O){if(i.debug.checkShaderErrors){const B=r.getProgramInfoLog(d).trim(),S=r.getShaderInfoLog(C).trim(),b=r.getShaderInfoLog(D).trim();let v=!0,A=!0;if(r.getProgramParameter(d,r.LINK_STATUS)===!1)if(v=!1,typeof i.debug.onShaderError=="function")i.debug.onShaderError(r,d,C,D);else{const I=Ia(r,C,"vertex"),U=Ia(r,D,"fragment");console.error("THREE.WebGLProgram: Shader Error "+r.getError()+" - VALIDATE_STATUS "+r.getProgramParameter(d,r.VALIDATE_STATUS)+`

Program Info Log: `+B+`
`+I+`
`+U)}else B!==""?console.warn("THREE.WebGLProgram: Program Info Log:",B):(S===""||b==="")&&(A=!1);A&&(O.diagnostics={runnable:v,programLog:B,vertexShader:{log:S,prefix:u},fragmentShader:{log:b,prefix:M}})}r.deleteShader(C),r.deleteShader(D),T=new Dr(r,d),E=Yp(r,d)}let T;this.getUniforms=function(){return T===void 0&&F(this),T};let E;this.getAttributes=function(){return E===void 0&&F(this),E};let j=e.rendererExtensionParallelShaderCompile===!1;return this.isReady=function(){return j===!1&&(j=r.getProgramParameter(d,Bp)),j},this.destroy=function(){n.releaseStatesOfProgram(this),r.deleteProgram(d),this.program=void 0},this.type=e.shaderType,this.name=e.shaderName,this.id=zp++,this.cacheKey=t,this.usedTimes=1,this.program=d,this.vertexShader=C,this.fragmentShader=D,this}let sm=0;class om{constructor(){this.shaderCache=new Map,this.materialCache=new Map}update(t){const e=t.vertexShader,n=t.fragmentShader,r=this._getShaderStage(e),s=this._getShaderStage(n),o=this._getShaderCacheForMaterial(t);return o.has(r)===!1&&(o.add(r),r.usedTimes++),o.has(s)===!1&&(o.add(s),s.usedTimes++),this}remove(t){const e=this.materialCache.get(t);for(const n of e)n.usedTimes--,n.usedTimes===0&&this.shaderCache.delete(n.code);return this.materialCache.delete(t),this}getVertexShaderID(t){return this._getShaderStage(t.vertexShader).id}getFragmentShaderID(t){return this._getShaderStage(t.fragmentShader).id}dispose(){this.shaderCache.clear(),this.materialCache.clear()}_getShaderCacheForMaterial(t){const e=this.materialCache;let n=e.get(t);return n===void 0&&(n=new Set,e.set(t,n)),n}_getShaderStage(t){const e=this.shaderCache;let n=e.get(t);return n===void 0&&(n=new am(t),e.set(t,n)),n}}class am{constructor(t){this.id=sm++,this.code=t,this.usedTimes=0}}function cm(i,t,e,n,r,s,o){const a=new ro,c=new om,l=[],h=r.isWebGL2,f=r.logarithmicDepthBuffer,m=r.vertexTextures;let p=r.precision;const _={MeshDepthMaterial:"depth",MeshDistanceMaterial:"distanceRGBA",MeshNormalMaterial:"normal",MeshBasicMaterial:"basic",MeshLambertMaterial:"lambert",MeshPhongMaterial:"phong",MeshToonMaterial:"toon",MeshStandardMaterial:"physical",MeshPhysicalMaterial:"physical",MeshMatcapMaterial:"matcap",LineBasicMaterial:"basic",LineDashedMaterial:"dashed",PointsMaterial:"points",ShadowMaterial:"shadow",SpriteMaterial:"sprite"};function x(T){return T===0?"uv":`uv${T}`}function d(T,E,j,O,B){const S=O.fog,b=B.geometry,v=T.isMeshStandardMaterial?O.environment:null,A=(T.isMeshStandardMaterial?e:t).get(T.envMap||v),I=A&&A.mapping===Xr?A.image.height:null,U=_[T.type];T.precision!==null&&(p=r.getMaxPrecision(T.precision),p!==T.precision&&console.warn("THREE.WebGLProgram.getParameters:",T.precision,"not supported, using",p,"instead."));const P=b.morphAttributes.position||b.morphAttributes.normal||b.morphAttributes.color,N=P!==void 0?P.length:0;let Y=0;b.morphAttributes.position!==void 0&&(Y=1),b.morphAttributes.normal!==void 0&&(Y=2),b.morphAttributes.color!==void 0&&(Y=3);let Z,nt,ht,gt;if(U){const Ae=Qe[U];Z=Ae.vertexShader,nt=Ae.fragmentShader}else Z=T.vertexShader,nt=T.fragmentShader,c.update(T),ht=c.getVertexShaderID(T),gt=c.getFragmentShaderID(T);const xt=i.getRenderTarget(),Et=B.isInstancedMesh===!0,ct=B.isBatchedMesh===!0,ut=!!T.map,Mt=!!T.matcap,k=!!A,tt=!!T.aoMap,G=!!T.lightMap,X=!!T.bumpMap,W=!!T.normalMap,et=!!T.displacementMap,it=!!T.emissiveMap,R=!!T.metalnessMap,w=!!T.roughnessMap,$=T.anisotropy>0,st=T.clearcoat>0,J=T.iridescence>0,q=T.sheen>0,Q=T.transmission>0,rt=$&&!!T.anisotropyMap,at=st&&!!T.clearcoatMap,yt=st&&!!T.clearcoatNormalMap,Tt=st&&!!T.clearcoatRoughnessMap,lt=J&&!!T.iridescenceMap,Rt=J&&!!T.iridescenceThicknessMap,V=q&&!!T.sheenColorMap,pt=q&&!!T.sheenRoughnessMap,wt=!!T.specularMap,St=!!T.specularColorMap,Pt=!!T.specularIntensityMap,Ft=Q&&!!T.transmissionMap,Ht=Q&&!!T.thicknessMap,Gt=!!T.gradientMap,_t=!!T.alphaMap,K=T.alphaTest>0,vt=!!T.alphaHash,bt=!!T.extensions,Ut=!!b.attributes.uv1,It=!!b.attributes.uv2,Xt=!!b.attributes.uv3;let Zt=wn;return T.toneMapped&&(xt===null||xt.isXRRenderTarget===!0)&&(Zt=i.toneMapping),{isWebGL2:h,shaderID:U,shaderType:T.type,shaderName:T.name,vertexShader:Z,fragmentShader:nt,defines:T.defines,customVertexShaderID:ht,customFragmentShaderID:gt,isRawShaderMaterial:T.isRawShaderMaterial===!0,glslVersion:T.glslVersion,precision:p,batching:ct,instancing:Et,instancingColor:Et&&B.instanceColor!==null,supportsVertexTextures:m,outputColorSpace:xt===null?i.outputColorSpace:xt.isXRRenderTarget===!0?xt.texture.colorSpace:mn,map:ut,matcap:Mt,envMap:k,envMapMode:k&&A.mapping,envMapCubeUVHeight:I,aoMap:tt,lightMap:G,bumpMap:X,normalMap:W,displacementMap:m&&et,emissiveMap:it,normalMapObjectSpace:W&&T.normalMapType===ru,normalMapTangentSpace:W&&T.normalMapType===Cc,metalnessMap:R,roughnessMap:w,anisotropy:$,anisotropyMap:rt,clearcoat:st,clearcoatMap:at,clearcoatNormalMap:yt,clearcoatRoughnessMap:Tt,iridescence:J,iridescenceMap:lt,iridescenceThicknessMap:Rt,sheen:q,sheenColorMap:V,sheenRoughnessMap:pt,specularMap:wt,specularColorMap:St,specularIntensityMap:Pt,transmission:Q,transmissionMap:Ft,thicknessMap:Ht,gradientMap:Gt,opaque:T.transparent===!1&&T.blending===xi,alphaMap:_t,alphaTest:K,alphaHash:vt,combine:T.combine,mapUv:ut&&x(T.map.channel),aoMapUv:tt&&x(T.aoMap.channel),lightMapUv:G&&x(T.lightMap.channel),bumpMapUv:X&&x(T.bumpMap.channel),normalMapUv:W&&x(T.normalMap.channel),displacementMapUv:et&&x(T.displacementMap.channel),emissiveMapUv:it&&x(T.emissiveMap.channel),metalnessMapUv:R&&x(T.metalnessMap.channel),roughnessMapUv:w&&x(T.roughnessMap.channel),anisotropyMapUv:rt&&x(T.anisotropyMap.channel),clearcoatMapUv:at&&x(T.clearcoatMap.channel),clearcoatNormalMapUv:yt&&x(T.clearcoatNormalMap.channel),clearcoatRoughnessMapUv:Tt&&x(T.clearcoatRoughnessMap.channel),iridescenceMapUv:lt&&x(T.iridescenceMap.channel),iridescenceThicknessMapUv:Rt&&x(T.iridescenceThicknessMap.channel),sheenColorMapUv:V&&x(T.sheenColorMap.channel),sheenRoughnessMapUv:pt&&x(T.sheenRoughnessMap.channel),specularMapUv:wt&&x(T.specularMap.channel),specularColorMapUv:St&&x(T.specularColorMap.channel),specularIntensityMapUv:Pt&&x(T.specularIntensityMap.channel),transmissionMapUv:Ft&&x(T.transmissionMap.channel),thicknessMapUv:Ht&&x(T.thicknessMap.channel),alphaMapUv:_t&&x(T.alphaMap.channel),vertexTangents:!!b.attributes.tangent&&(W||$),vertexColors:T.vertexColors,vertexAlphas:T.vertexColors===!0&&!!b.attributes.color&&b.attributes.color.itemSize===4,vertexUv1s:Ut,vertexUv2s:It,vertexUv3s:Xt,pointsUvs:B.isPoints===!0&&!!b.attributes.uv&&(ut||_t),fog:!!S,useFog:T.fog===!0,fogExp2:S&&S.isFogExp2,flatShading:T.flatShading===!0,sizeAttenuation:T.sizeAttenuation===!0,logarithmicDepthBuffer:f,skinning:B.isSkinnedMesh===!0,morphTargets:b.morphAttributes.position!==void 0,morphNormals:b.morphAttributes.normal!==void 0,morphColors:b.morphAttributes.color!==void 0,morphTargetsCount:N,morphTextureStride:Y,numDirLights:E.directional.length,numPointLights:E.point.length,numSpotLights:E.spot.length,numSpotLightMaps:E.spotLightMap.length,numRectAreaLights:E.rectArea.length,numHemiLights:E.hemi.length,numDirLightShadows:E.directionalShadowMap.length,numPointLightShadows:E.pointShadowMap.length,numSpotLightShadows:E.spotShadowMap.length,numSpotLightShadowsWithMaps:E.numSpotLightShadowsWithMaps,numLightProbes:E.numLightProbes,numClippingPlanes:o.numPlanes,numClipIntersection:o.numIntersection,dithering:T.dithering,shadowMapEnabled:i.shadowMap.enabled&&j.length>0,shadowMapType:i.shadowMap.type,toneMapping:Zt,useLegacyLights:i._useLegacyLights,decodeVideoTexture:ut&&T.map.isVideoTexture===!0&&te.getTransfer(T.map.colorSpace)===se,premultipliedAlpha:T.premultipliedAlpha,doubleSided:T.side===Ee,flipSided:T.side===Me,useDepthPacking:T.depthPacking>=0,depthPacking:T.depthPacking||0,index0AttributeName:T.index0AttributeName,extensionDerivatives:bt&&T.extensions.derivatives===!0,extensionFragDepth:bt&&T.extensions.fragDepth===!0,extensionDrawBuffers:bt&&T.extensions.drawBuffers===!0,extensionShaderTextureLOD:bt&&T.extensions.shaderTextureLOD===!0,extensionClipCullDistance:bt&&T.extensions.clipCullDistance&&n.has("WEBGL_clip_cull_distance"),rendererExtensionFragDepth:h||n.has("EXT_frag_depth"),rendererExtensionDrawBuffers:h||n.has("WEBGL_draw_buffers"),rendererExtensionShaderTextureLod:h||n.has("EXT_shader_texture_lod"),rendererExtensionParallelShaderCompile:n.has("KHR_parallel_shader_compile"),customProgramCacheKey:T.customProgramCacheKey()}}function u(T){const E=[];if(T.shaderID?E.push(T.shaderID):(E.push(T.customVertexShaderID),E.push(T.customFragmentShaderID)),T.defines!==void 0)for(const j in T.defines)E.push(j),E.push(T.defines[j]);return T.isRawShaderMaterial===!1&&(M(E,T),g(E,T),E.push(i.outputColorSpace)),E.push(T.customProgramCacheKey),E.join()}function M(T,E){T.push(E.precision),T.push(E.outputColorSpace),T.push(E.envMapMode),T.push(E.envMapCubeUVHeight),T.push(E.mapUv),T.push(E.alphaMapUv),T.push(E.lightMapUv),T.push(E.aoMapUv),T.push(E.bumpMapUv),T.push(E.normalMapUv),T.push(E.displacementMapUv),T.push(E.emissiveMapUv),T.push(E.metalnessMapUv),T.push(E.roughnessMapUv),T.push(E.anisotropyMapUv),T.push(E.clearcoatMapUv),T.push(E.clearcoatNormalMapUv),T.push(E.clearcoatRoughnessMapUv),T.push(E.iridescenceMapUv),T.push(E.iridescenceThicknessMapUv),T.push(E.sheenColorMapUv),T.push(E.sheenRoughnessMapUv),T.push(E.specularMapUv),T.push(E.specularColorMapUv),T.push(E.specularIntensityMapUv),T.push(E.transmissionMapUv),T.push(E.thicknessMapUv),T.push(E.combine),T.push(E.fogExp2),T.push(E.sizeAttenuation),T.push(E.morphTargetsCount),T.push(E.morphAttributeCount),T.push(E.numDirLights),T.push(E.numPointLights),T.push(E.numSpotLights),T.push(E.numSpotLightMaps),T.push(E.numHemiLights),T.push(E.numRectAreaLights),T.push(E.numDirLightShadows),T.push(E.numPointLightShadows),T.push(E.numSpotLightShadows),T.push(E.numSpotLightShadowsWithMaps),T.push(E.numLightProbes),T.push(E.shadowMapType),T.push(E.toneMapping),T.push(E.numClippingPlanes),T.push(E.numClipIntersection),T.push(E.depthPacking)}function g(T,E){a.disableAll(),E.isWebGL2&&a.enable(0),E.supportsVertexTextures&&a.enable(1),E.instancing&&a.enable(2),E.instancingColor&&a.enable(3),E.matcap&&a.enable(4),E.envMap&&a.enable(5),E.normalMapObjectSpace&&a.enable(6),E.normalMapTangentSpace&&a.enable(7),E.clearcoat&&a.enable(8),E.iridescence&&a.enable(9),E.alphaTest&&a.enable(10),E.vertexColors&&a.enable(11),E.vertexAlphas&&a.enable(12),E.vertexUv1s&&a.enable(13),E.vertexUv2s&&a.enable(14),E.vertexUv3s&&a.enable(15),E.vertexTangents&&a.enable(16),E.anisotropy&&a.enable(17),E.alphaHash&&a.enable(18),E.batching&&a.enable(19),T.push(a.mask),a.disableAll(),E.fog&&a.enable(0),E.useFog&&a.enable(1),E.flatShading&&a.enable(2),E.logarithmicDepthBuffer&&a.enable(3),E.skinning&&a.enable(4),E.morphTargets&&a.enable(5),E.morphNormals&&a.enable(6),E.morphColors&&a.enable(7),E.premultipliedAlpha&&a.enable(8),E.shadowMapEnabled&&a.enable(9),E.useLegacyLights&&a.enable(10),E.doubleSided&&a.enable(11),E.flipSided&&a.enable(12),E.useDepthPacking&&a.enable(13),E.dithering&&a.enable(14),E.transmission&&a.enable(15),E.sheen&&a.enable(16),E.opaque&&a.enable(17),E.pointsUvs&&a.enable(18),E.decodeVideoTexture&&a.enable(19),T.push(a.mask)}function y(T){const E=_[T.type];let j;if(E){const O=Qe[E];j=ji.clone(O.uniforms)}else j=T.uniforms;return j}function L(T,E){let j;for(let O=0,B=l.length;O<B;O++){const S=l[O];if(S.cacheKey===E){j=S,++j.usedTimes;break}}return j===void 0&&(j=new rm(i,E,T,s),l.push(j)),j}function C(T){if(--T.usedTimes===0){const E=l.indexOf(T);l[E]=l[l.length-1],l.pop(),T.destroy()}}function D(T){c.remove(T)}function F(){c.dispose()}return{getParameters:d,getProgramCacheKey:u,getUniforms:y,acquireProgram:L,releaseProgram:C,releaseShaderCache:D,programs:l,dispose:F}}function lm(){let i=new WeakMap;function t(s){let o=i.get(s);return o===void 0&&(o={},i.set(s,o)),o}function e(s){i.delete(s)}function n(s,o,a){i.get(s)[o]=a}function r(){i=new WeakMap}return{get:t,remove:e,update:n,dispose:r}}function um(i,t){return i.groupOrder!==t.groupOrder?i.groupOrder-t.groupOrder:i.renderOrder!==t.renderOrder?i.renderOrder-t.renderOrder:i.material.id!==t.material.id?i.material.id-t.material.id:i.z!==t.z?i.z-t.z:i.id-t.id}function Ba(i,t){return i.groupOrder!==t.groupOrder?i.groupOrder-t.groupOrder:i.renderOrder!==t.renderOrder?i.renderOrder-t.renderOrder:i.z!==t.z?t.z-i.z:i.id-t.id}function za(){const i=[];let t=0;const e=[],n=[],r=[];function s(){t=0,e.length=0,n.length=0,r.length=0}function o(f,m,p,_,x,d){let u=i[t];return u===void 0?(u={id:f.id,object:f,geometry:m,material:p,groupOrder:_,renderOrder:f.renderOrder,z:x,group:d},i[t]=u):(u.id=f.id,u.object=f,u.geometry=m,u.material=p,u.groupOrder=_,u.renderOrder=f.renderOrder,u.z=x,u.group=d),t++,u}function a(f,m,p,_,x,d){const u=o(f,m,p,_,x,d);p.transmission>0?n.push(u):p.transparent===!0?r.push(u):e.push(u)}function c(f,m,p,_,x,d){const u=o(f,m,p,_,x,d);p.transmission>0?n.unshift(u):p.transparent===!0?r.unshift(u):e.unshift(u)}function l(f,m){e.length>1&&e.sort(f||um),n.length>1&&n.sort(m||Ba),r.length>1&&r.sort(m||Ba)}function h(){for(let f=t,m=i.length;f<m;f++){const p=i[f];if(p.id===null)break;p.id=null,p.object=null,p.geometry=null,p.material=null,p.group=null}}return{opaque:e,transmissive:n,transparent:r,init:s,push:a,unshift:c,finish:h,sort:l}}function hm(){let i=new WeakMap;function t(n,r){const s=i.get(n);let o;return s===void 0?(o=new za,i.set(n,[o])):r>=s.length?(o=new za,s.push(o)):o=s[r],o}function e(){i=new WeakMap}return{get:t,dispose:e}}function dm(){const i={};return{get:function(t){if(i[t.id]!==void 0)return i[t.id];let e;switch(t.type){case"DirectionalLight":e={direction:new H,color:new Dt};break;case"SpotLight":e={position:new H,direction:new H,color:new Dt,distance:0,coneCos:0,penumbraCos:0,decay:0};break;case"PointLight":e={position:new H,color:new Dt,distance:0,decay:0};break;case"HemisphereLight":e={direction:new H,skyColor:new Dt,groundColor:new Dt};break;case"RectAreaLight":e={color:new Dt,position:new H,halfWidth:new H,halfHeight:new H};break}return i[t.id]=e,e}}}function fm(){const i={};return{get:function(t){if(i[t.id]!==void 0)return i[t.id];let e;switch(t.type){case"DirectionalLight":e={shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new At};break;case"SpotLight":e={shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new At};break;case"PointLight":e={shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new At,shadowCameraNear:1,shadowCameraFar:1e3};break}return i[t.id]=e,e}}}let pm=0;function mm(i,t){return(t.castShadow?2:0)-(i.castShadow?2:0)+(t.map?1:0)-(i.map?1:0)}function gm(i,t){const e=new dm,n=fm(),r={version:0,hash:{directionalLength:-1,pointLength:-1,spotLength:-1,rectAreaLength:-1,hemiLength:-1,numDirectionalShadows:-1,numPointShadows:-1,numSpotShadows:-1,numSpotMaps:-1,numLightProbes:-1},ambient:[0,0,0],probe:[],directional:[],directionalShadow:[],directionalShadowMap:[],directionalShadowMatrix:[],spot:[],spotLightMap:[],spotShadow:[],spotShadowMap:[],spotLightMatrix:[],rectArea:[],rectAreaLTC1:null,rectAreaLTC2:null,point:[],pointShadow:[],pointShadowMap:[],pointShadowMatrix:[],hemi:[],numSpotLightShadowsWithMaps:0,numLightProbes:0};for(let h=0;h<9;h++)r.probe.push(new H);const s=new H,o=new ee,a=new ee;function c(h,f){let m=0,p=0,_=0;for(let O=0;O<9;O++)r.probe[O].set(0,0,0);let x=0,d=0,u=0,M=0,g=0,y=0,L=0,C=0,D=0,F=0,T=0;h.sort(mm);const E=f===!0?Math.PI:1;for(let O=0,B=h.length;O<B;O++){const S=h[O],b=S.color,v=S.intensity,A=S.distance,I=S.shadow&&S.shadow.map?S.shadow.map.texture:null;if(S.isAmbientLight)m+=b.r*v*E,p+=b.g*v*E,_+=b.b*v*E;else if(S.isLightProbe){for(let U=0;U<9;U++)r.probe[U].addScaledVector(S.sh.coefficients[U],v);T++}else if(S.isDirectionalLight){const U=e.get(S);if(U.color.copy(S.color).multiplyScalar(S.intensity*E),S.castShadow){const P=S.shadow,N=n.get(S);N.shadowBias=P.bias,N.shadowNormalBias=P.normalBias,N.shadowRadius=P.radius,N.shadowMapSize=P.mapSize,r.directionalShadow[x]=N,r.directionalShadowMap[x]=I,r.directionalShadowMatrix[x]=S.shadow.matrix,y++}r.directional[x]=U,x++}else if(S.isSpotLight){const U=e.get(S);U.position.setFromMatrixPosition(S.matrixWorld),U.color.copy(b).multiplyScalar(v*E),U.distance=A,U.coneCos=Math.cos(S.angle),U.penumbraCos=Math.cos(S.angle*(1-S.penumbra)),U.decay=S.decay,r.spot[u]=U;const P=S.shadow;if(S.map&&(r.spotLightMap[D]=S.map,D++,P.updateMatrices(S),S.castShadow&&F++),r.spotLightMatrix[u]=P.matrix,S.castShadow){const N=n.get(S);N.shadowBias=P.bias,N.shadowNormalBias=P.normalBias,N.shadowRadius=P.radius,N.shadowMapSize=P.mapSize,r.spotShadow[u]=N,r.spotShadowMap[u]=I,C++}u++}else if(S.isRectAreaLight){const U=e.get(S);U.color.copy(b).multiplyScalar(v),U.halfWidth.set(S.width*.5,0,0),U.halfHeight.set(0,S.height*.5,0),r.rectArea[M]=U,M++}else if(S.isPointLight){const U=e.get(S);if(U.color.copy(S.color).multiplyScalar(S.intensity*E),U.distance=S.distance,U.decay=S.decay,S.castShadow){const P=S.shadow,N=n.get(S);N.shadowBias=P.bias,N.shadowNormalBias=P.normalBias,N.shadowRadius=P.radius,N.shadowMapSize=P.mapSize,N.shadowCameraNear=P.camera.near,N.shadowCameraFar=P.camera.far,r.pointShadow[d]=N,r.pointShadowMap[d]=I,r.pointShadowMatrix[d]=S.shadow.matrix,L++}r.point[d]=U,d++}else if(S.isHemisphereLight){const U=e.get(S);U.skyColor.copy(S.color).multiplyScalar(v*E),U.groundColor.copy(S.groundColor).multiplyScalar(v*E),r.hemi[g]=U,g++}}M>0&&(t.isWebGL2?i.has("OES_texture_float_linear")===!0?(r.rectAreaLTC1=Ct.LTC_FLOAT_1,r.rectAreaLTC2=Ct.LTC_FLOAT_2):(r.rectAreaLTC1=Ct.LTC_HALF_1,r.rectAreaLTC2=Ct.LTC_HALF_2):i.has("OES_texture_float_linear")===!0?(r.rectAreaLTC1=Ct.LTC_FLOAT_1,r.rectAreaLTC2=Ct.LTC_FLOAT_2):i.has("OES_texture_half_float_linear")===!0?(r.rectAreaLTC1=Ct.LTC_HALF_1,r.rectAreaLTC2=Ct.LTC_HALF_2):console.error("THREE.WebGLRenderer: Unable to use RectAreaLight. Missing WebGL extensions.")),r.ambient[0]=m,r.ambient[1]=p,r.ambient[2]=_;const j=r.hash;(j.directionalLength!==x||j.pointLength!==d||j.spotLength!==u||j.rectAreaLength!==M||j.hemiLength!==g||j.numDirectionalShadows!==y||j.numPointShadows!==L||j.numSpotShadows!==C||j.numSpotMaps!==D||j.numLightProbes!==T)&&(r.directional.length=x,r.spot.length=u,r.rectArea.length=M,r.point.length=d,r.hemi.length=g,r.directionalShadow.length=y,r.directionalShadowMap.length=y,r.pointShadow.length=L,r.pointShadowMap.length=L,r.spotShadow.length=C,r.spotShadowMap.length=C,r.directionalShadowMatrix.length=y,r.pointShadowMatrix.length=L,r.spotLightMatrix.length=C+D-F,r.spotLightMap.length=D,r.numSpotLightShadowsWithMaps=F,r.numLightProbes=T,j.directionalLength=x,j.pointLength=d,j.spotLength=u,j.rectAreaLength=M,j.hemiLength=g,j.numDirectionalShadows=y,j.numPointShadows=L,j.numSpotShadows=C,j.numSpotMaps=D,j.numLightProbes=T,r.version=pm++)}function l(h,f){let m=0,p=0,_=0,x=0,d=0;const u=f.matrixWorldInverse;for(let M=0,g=h.length;M<g;M++){const y=h[M];if(y.isDirectionalLight){const L=r.directional[m];L.direction.setFromMatrixPosition(y.matrixWorld),s.setFromMatrixPosition(y.target.matrixWorld),L.direction.sub(s),L.direction.transformDirection(u),m++}else if(y.isSpotLight){const L=r.spot[_];L.position.setFromMatrixPosition(y.matrixWorld),L.position.applyMatrix4(u),L.direction.setFromMatrixPosition(y.matrixWorld),s.setFromMatrixPosition(y.target.matrixWorld),L.direction.sub(s),L.direction.transformDirection(u),_++}else if(y.isRectAreaLight){const L=r.rectArea[x];L.position.setFromMatrixPosition(y.matrixWorld),L.position.applyMatrix4(u),a.identity(),o.copy(y.matrixWorld),o.premultiply(u),a.extractRotation(o),L.halfWidth.set(y.width*.5,0,0),L.halfHeight.set(0,y.height*.5,0),L.halfWidth.applyMatrix4(a),L.halfHeight.applyMatrix4(a),x++}else if(y.isPointLight){const L=r.point[p];L.position.setFromMatrixPosition(y.matrixWorld),L.position.applyMatrix4(u),p++}else if(y.isHemisphereLight){const L=r.hemi[d];L.direction.setFromMatrixPosition(y.matrixWorld),L.direction.transformDirection(u),d++}}}return{setup:c,setupView:l,state:r}}function Ga(i,t){const e=new gm(i,t),n=[],r=[];function s(){n.length=0,r.length=0}function o(f){n.push(f)}function a(f){r.push(f)}function c(f){e.setup(n,f)}function l(f){e.setupView(n,f)}return{init:s,state:{lightsArray:n,shadowsArray:r,lights:e},setupLights:c,setupLightsView:l,pushLight:o,pushShadow:a}}function _m(i,t){let e=new WeakMap;function n(s,o=0){const a=e.get(s);let c;return a===void 0?(c=new Ga(i,t),e.set(s,[c])):o>=a.length?(c=new Ga(i,t),a.push(c)):c=a[o],c}function r(){e=new WeakMap}return{get:n,dispose:r}}class vm extends Rn{constructor(t){super(),this.isMeshDepthMaterial=!0,this.type="MeshDepthMaterial",this.depthPacking=nu,this.map=null,this.alphaMap=null,this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.wireframe=!1,this.wireframeLinewidth=1,this.setValues(t)}copy(t){return super.copy(t),this.depthPacking=t.depthPacking,this.map=t.map,this.alphaMap=t.alphaMap,this.displacementMap=t.displacementMap,this.displacementScale=t.displacementScale,this.displacementBias=t.displacementBias,this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this}}class xm extends Rn{constructor(t){super(),this.isMeshDistanceMaterial=!0,this.type="MeshDistanceMaterial",this.map=null,this.alphaMap=null,this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.setValues(t)}copy(t){return super.copy(t),this.map=t.map,this.alphaMap=t.alphaMap,this.displacementMap=t.displacementMap,this.displacementScale=t.displacementScale,this.displacementBias=t.displacementBias,this}}const Mm=`void main() {
	gl_Position = vec4( position, 1.0 );
}`,ym=`uniform sampler2D shadow_pass;
uniform vec2 resolution;
uniform float radius;
#include <packing>
void main() {
	const float samples = float( VSM_SAMPLES );
	float mean = 0.0;
	float squared_mean = 0.0;
	float uvStride = samples <= 1.0 ? 0.0 : 2.0 / ( samples - 1.0 );
	float uvStart = samples <= 1.0 ? 0.0 : - 1.0;
	for ( float i = 0.0; i < samples; i ++ ) {
		float uvOffset = uvStart + i * uvStride;
		#ifdef HORIZONTAL_PASS
			vec2 distribution = unpackRGBATo2Half( texture2D( shadow_pass, ( gl_FragCoord.xy + vec2( uvOffset, 0.0 ) * radius ) / resolution ) );
			mean += distribution.x;
			squared_mean += distribution.y * distribution.y + distribution.x * distribution.x;
		#else
			float depth = unpackRGBAToDepth( texture2D( shadow_pass, ( gl_FragCoord.xy + vec2( 0.0, uvOffset ) * radius ) / resolution ) );
			mean += depth;
			squared_mean += depth * depth;
		#endif
	}
	mean = mean / samples;
	squared_mean = squared_mean / samples;
	float std_dev = sqrt( squared_mean - mean * mean );
	gl_FragColor = pack2HalfToRGBA( vec2( mean, std_dev ) );
}`;function Sm(i,t,e){let n=new so;const r=new At,s=new At,o=new oe,a=new vm({depthPacking:iu}),c=new xm,l={},h=e.maxTextureSize,f={[pn]:Me,[Me]:pn,[Ee]:Ee},m=new we({defines:{VSM_SAMPLES:8},uniforms:{shadow_pass:{value:null},resolution:{value:new At},radius:{value:4}},vertexShader:Mm,fragmentShader:ym}),p=m.clone();p.defines.HORIZONTAL_PASS=1;const _=new Jt;_.setAttribute("position",new le(new Float32Array([-1,-1,.5,3,-1,.5,-1,3,.5]),3));const x=new Bt(_,m),d=this;this.enabled=!1,this.autoUpdate=!0,this.needsUpdate=!1,this.type=fc;let u=this.type;this.render=function(C,D,F){if(d.enabled===!1||d.autoUpdate===!1&&d.needsUpdate===!1||C.length===0)return;const T=i.getRenderTarget(),E=i.getActiveCubeFace(),j=i.getActiveMipmapLevel(),O=i.state;O.setBlending(hn),O.buffers.color.setClear(1,1,1,1),O.buffers.depth.setTest(!0),O.setScissorTest(!1);const B=u!==ln&&this.type===ln,S=u===ln&&this.type!==ln;for(let b=0,v=C.length;b<v;b++){const A=C[b],I=A.shadow;if(I===void 0){console.warn("THREE.WebGLShadowMap:",A,"has no shadow.");continue}if(I.autoUpdate===!1&&I.needsUpdate===!1)continue;r.copy(I.mapSize);const U=I.getFrameExtents();if(r.multiply(U),s.copy(I.mapSize),(r.x>h||r.y>h)&&(r.x>h&&(s.x=Math.floor(h/U.x),r.x=s.x*U.x,I.mapSize.x=s.x),r.y>h&&(s.y=Math.floor(h/U.y),r.y=s.y*U.y,I.mapSize.y=s.y)),I.map===null||B===!0||S===!0){const N=this.type!==ln?{minFilter:Le,magFilter:Le}:{};I.map!==null&&I.map.dispose(),I.map=new Ke(r.x,r.y,N),I.map.texture.name=A.name+".shadowMap",I.camera.updateProjectionMatrix()}i.setRenderTarget(I.map),i.clear();const P=I.getViewportCount();for(let N=0;N<P;N++){const Y=I.getViewport(N);o.set(s.x*Y.x,s.y*Y.y,s.x*Y.z,s.y*Y.w),O.viewport(o),I.updateMatrices(A,N),n=I.getFrustum(),y(D,F,I.camera,A,this.type)}I.isPointLightShadow!==!0&&this.type===ln&&M(I,F),I.needsUpdate=!1}u=this.type,d.needsUpdate=!1,i.setRenderTarget(T,E,j)};function M(C,D){const F=t.update(x);m.defines.VSM_SAMPLES!==C.blurSamples&&(m.defines.VSM_SAMPLES=C.blurSamples,p.defines.VSM_SAMPLES=C.blurSamples,m.needsUpdate=!0,p.needsUpdate=!0),C.mapPass===null&&(C.mapPass=new Ke(r.x,r.y)),m.uniforms.shadow_pass.value=C.map.texture,m.uniforms.resolution.value=C.mapSize,m.uniforms.radius.value=C.radius,i.setRenderTarget(C.mapPass),i.clear(),i.renderBufferDirect(D,null,F,m,x,null),p.uniforms.shadow_pass.value=C.mapPass.texture,p.uniforms.resolution.value=C.mapSize,p.uniforms.radius.value=C.radius,i.setRenderTarget(C.map),i.clear(),i.renderBufferDirect(D,null,F,p,x,null)}function g(C,D,F,T){let E=null;const j=F.isPointLight===!0?C.customDistanceMaterial:C.customDepthMaterial;if(j!==void 0)E=j;else if(E=F.isPointLight===!0?c:a,i.localClippingEnabled&&D.clipShadows===!0&&Array.isArray(D.clippingPlanes)&&D.clippingPlanes.length!==0||D.displacementMap&&D.displacementScale!==0||D.alphaMap&&D.alphaTest>0||D.map&&D.alphaTest>0){const O=E.uuid,B=D.uuid;let S=l[O];S===void 0&&(S={},l[O]=S);let b=S[B];b===void 0&&(b=E.clone(),S[B]=b,D.addEventListener("dispose",L)),E=b}if(E.visible=D.visible,E.wireframe=D.wireframe,T===ln?E.side=D.shadowSide!==null?D.shadowSide:D.side:E.side=D.shadowSide!==null?D.shadowSide:f[D.side],E.alphaMap=D.alphaMap,E.alphaTest=D.alphaTest,E.map=D.map,E.clipShadows=D.clipShadows,E.clippingPlanes=D.clippingPlanes,E.clipIntersection=D.clipIntersection,E.displacementMap=D.displacementMap,E.displacementScale=D.displacementScale,E.displacementBias=D.displacementBias,E.wireframeLinewidth=D.wireframeLinewidth,E.linewidth=D.linewidth,F.isPointLight===!0&&E.isMeshDistanceMaterial===!0){const O=i.properties.get(E);O.light=F}return E}function y(C,D,F,T,E){if(C.visible===!1)return;if(C.layers.test(D.layers)&&(C.isMesh||C.isLine||C.isPoints)&&(C.castShadow||C.receiveShadow&&E===ln)&&(!C.frustumCulled||n.intersectsObject(C))){C.modelViewMatrix.multiplyMatrices(F.matrixWorldInverse,C.matrixWorld);const B=t.update(C),S=C.material;if(Array.isArray(S)){const b=B.groups;for(let v=0,A=b.length;v<A;v++){const I=b[v],U=S[I.materialIndex];if(U&&U.visible){const P=g(C,U,T,E);C.onBeforeShadow(i,C,D,F,B,P,I),i.renderBufferDirect(F,null,B,P,C,I),C.onAfterShadow(i,C,D,F,B,P,I)}}}else if(S.visible){const b=g(C,S,T,E);C.onBeforeShadow(i,C,D,F,B,b,null),i.renderBufferDirect(F,null,B,b,C,null),C.onAfterShadow(i,C,D,F,B,b,null)}}const O=C.children;for(let B=0,S=O.length;B<S;B++)y(O[B],D,F,T,E)}function L(C){C.target.removeEventListener("dispose",L);for(const F in l){const T=l[F],E=C.target.uuid;E in T&&(T[E].dispose(),delete T[E])}}}function bm(i,t,e){const n=e.isWebGL2;function r(){let K=!1;const vt=new oe;let bt=null;const Ut=new oe(0,0,0,0);return{setMask:function(It){bt!==It&&!K&&(i.colorMask(It,It,It,It),bt=It)},setLocked:function(It){K=It},setClear:function(It,Xt,Zt,de,Ae){Ae===!0&&(It*=de,Xt*=de,Zt*=de),vt.set(It,Xt,Zt,de),Ut.equals(vt)===!1&&(i.clearColor(It,Xt,Zt,de),Ut.copy(vt))},reset:function(){K=!1,bt=null,Ut.set(-1,0,0,0)}}}function s(){let K=!1,vt=null,bt=null,Ut=null;return{setTest:function(It){It?ct(i.DEPTH_TEST):ut(i.DEPTH_TEST)},setMask:function(It){vt!==It&&!K&&(i.depthMask(It),vt=It)},setFunc:function(It){if(bt!==It){switch(It){case Fl:i.depthFunc(i.NEVER);break;case Bl:i.depthFunc(i.ALWAYS);break;case zl:i.depthFunc(i.LESS);break;case Nr:i.depthFunc(i.LEQUAL);break;case Gl:i.depthFunc(i.EQUAL);break;case kl:i.depthFunc(i.GEQUAL);break;case Hl:i.depthFunc(i.GREATER);break;case Vl:i.depthFunc(i.NOTEQUAL);break;default:i.depthFunc(i.LEQUAL)}bt=It}},setLocked:function(It){K=It},setClear:function(It){Ut!==It&&(i.clearDepth(It),Ut=It)},reset:function(){K=!1,vt=null,bt=null,Ut=null}}}function o(){let K=!1,vt=null,bt=null,Ut=null,It=null,Xt=null,Zt=null,de=null,Ae=null;return{setTest:function(re){K||(re?ct(i.STENCIL_TEST):ut(i.STENCIL_TEST))},setMask:function(re){vt!==re&&!K&&(i.stencilMask(re),vt=re)},setFunc:function(re,Re,Je){(bt!==re||Ut!==Re||It!==Je)&&(i.stencilFunc(re,Re,Je),bt=re,Ut=Re,It=Je)},setOp:function(re,Re,Je){(Xt!==re||Zt!==Re||de!==Je)&&(i.stencilOp(re,Re,Je),Xt=re,Zt=Re,de=Je)},setLocked:function(re){K=re},setClear:function(re){Ae!==re&&(i.clearStencil(re),Ae=re)},reset:function(){K=!1,vt=null,bt=null,Ut=null,It=null,Xt=null,Zt=null,de=null,Ae=null}}}const a=new r,c=new s,l=new o,h=new WeakMap,f=new WeakMap;let m={},p={},_=new WeakMap,x=[],d=null,u=!1,M=null,g=null,y=null,L=null,C=null,D=null,F=null,T=new Dt(0,0,0),E=0,j=!1,O=null,B=null,S=null,b=null,v=null;const A=i.getParameter(i.MAX_COMBINED_TEXTURE_IMAGE_UNITS);let I=!1,U=0;const P=i.getParameter(i.VERSION);P.indexOf("WebGL")!==-1?(U=parseFloat(/^WebGL (\d)/.exec(P)[1]),I=U>=1):P.indexOf("OpenGL ES")!==-1&&(U=parseFloat(/^OpenGL ES (\d)/.exec(P)[1]),I=U>=2);let N=null,Y={};const Z=i.getParameter(i.SCISSOR_BOX),nt=i.getParameter(i.VIEWPORT),ht=new oe().fromArray(Z),gt=new oe().fromArray(nt);function xt(K,vt,bt,Ut){const It=new Uint8Array(4),Xt=i.createTexture();i.bindTexture(K,Xt),i.texParameteri(K,i.TEXTURE_MIN_FILTER,i.NEAREST),i.texParameteri(K,i.TEXTURE_MAG_FILTER,i.NEAREST);for(let Zt=0;Zt<bt;Zt++)n&&(K===i.TEXTURE_3D||K===i.TEXTURE_2D_ARRAY)?i.texImage3D(vt,0,i.RGBA,1,1,Ut,0,i.RGBA,i.UNSIGNED_BYTE,It):i.texImage2D(vt+Zt,0,i.RGBA,1,1,0,i.RGBA,i.UNSIGNED_BYTE,It);return Xt}const Et={};Et[i.TEXTURE_2D]=xt(i.TEXTURE_2D,i.TEXTURE_2D,1),Et[i.TEXTURE_CUBE_MAP]=xt(i.TEXTURE_CUBE_MAP,i.TEXTURE_CUBE_MAP_POSITIVE_X,6),n&&(Et[i.TEXTURE_2D_ARRAY]=xt(i.TEXTURE_2D_ARRAY,i.TEXTURE_2D_ARRAY,1,1),Et[i.TEXTURE_3D]=xt(i.TEXTURE_3D,i.TEXTURE_3D,1,1)),a.setClear(0,0,0,1),c.setClear(1),l.setClear(0),ct(i.DEPTH_TEST),c.setFunc(Nr),it(!1),R(Eo),ct(i.CULL_FACE),W(hn);function ct(K){m[K]!==!0&&(i.enable(K),m[K]=!0)}function ut(K){m[K]!==!1&&(i.disable(K),m[K]=!1)}function Mt(K,vt){return p[K]!==vt?(i.bindFramebuffer(K,vt),p[K]=vt,n&&(K===i.DRAW_FRAMEBUFFER&&(p[i.FRAMEBUFFER]=vt),K===i.FRAMEBUFFER&&(p[i.DRAW_FRAMEBUFFER]=vt)),!0):!1}function k(K,vt){let bt=x,Ut=!1;if(K)if(bt=_.get(vt),bt===void 0&&(bt=[],_.set(vt,bt)),K.isWebGLMultipleRenderTargets){const It=K.texture;if(bt.length!==It.length||bt[0]!==i.COLOR_ATTACHMENT0){for(let Xt=0,Zt=It.length;Xt<Zt;Xt++)bt[Xt]=i.COLOR_ATTACHMENT0+Xt;bt.length=It.length,Ut=!0}}else bt[0]!==i.COLOR_ATTACHMENT0&&(bt[0]=i.COLOR_ATTACHMENT0,Ut=!0);else bt[0]!==i.BACK&&(bt[0]=i.BACK,Ut=!0);Ut&&(e.isWebGL2?i.drawBuffers(bt):t.get("WEBGL_draw_buffers").drawBuffersWEBGL(bt))}function tt(K){return d!==K?(i.useProgram(K),d=K,!0):!1}const G={[On]:i.FUNC_ADD,[Sl]:i.FUNC_SUBTRACT,[bl]:i.FUNC_REVERSE_SUBTRACT};if(n)G[Ao]=i.MIN,G[Ro]=i.MAX;else{const K=t.get("EXT_blend_minmax");K!==null&&(G[Ao]=K.MIN_EXT,G[Ro]=K.MAX_EXT)}const X={[El]:i.ZERO,[wl]:i.ONE,[Tl]:i.SRC_COLOR,[Bs]:i.SRC_ALPHA,[Dl]:i.SRC_ALPHA_SATURATE,[Pl]:i.DST_COLOR,[Rl]:i.DST_ALPHA,[Al]:i.ONE_MINUS_SRC_COLOR,[zs]:i.ONE_MINUS_SRC_ALPHA,[Ll]:i.ONE_MINUS_DST_COLOR,[Cl]:i.ONE_MINUS_DST_ALPHA,[Il]:i.CONSTANT_COLOR,[Ul]:i.ONE_MINUS_CONSTANT_COLOR,[Nl]:i.CONSTANT_ALPHA,[Ol]:i.ONE_MINUS_CONSTANT_ALPHA};function W(K,vt,bt,Ut,It,Xt,Zt,de,Ae,re){if(K===hn){u===!0&&(ut(i.BLEND),u=!1);return}if(u===!1&&(ct(i.BLEND),u=!0),K!==yl){if(K!==M||re!==j){if((g!==On||C!==On)&&(i.blendEquation(i.FUNC_ADD),g=On,C=On),re)switch(K){case xi:i.blendFuncSeparate(i.ONE,i.ONE_MINUS_SRC_ALPHA,i.ONE,i.ONE_MINUS_SRC_ALPHA);break;case Fs:i.blendFunc(i.ONE,i.ONE);break;case wo:i.blendFuncSeparate(i.ZERO,i.ONE_MINUS_SRC_COLOR,i.ZERO,i.ONE);break;case To:i.blendFuncSeparate(i.ZERO,i.SRC_COLOR,i.ZERO,i.SRC_ALPHA);break;default:console.error("THREE.WebGLState: Invalid blending: ",K);break}else switch(K){case xi:i.blendFuncSeparate(i.SRC_ALPHA,i.ONE_MINUS_SRC_ALPHA,i.ONE,i.ONE_MINUS_SRC_ALPHA);break;case Fs:i.blendFunc(i.SRC_ALPHA,i.ONE);break;case wo:i.blendFuncSeparate(i.ZERO,i.ONE_MINUS_SRC_COLOR,i.ZERO,i.ONE);break;case To:i.blendFunc(i.ZERO,i.SRC_COLOR);break;default:console.error("THREE.WebGLState: Invalid blending: ",K);break}y=null,L=null,D=null,F=null,T.set(0,0,0),E=0,M=K,j=re}return}It=It||vt,Xt=Xt||bt,Zt=Zt||Ut,(vt!==g||It!==C)&&(i.blendEquationSeparate(G[vt],G[It]),g=vt,C=It),(bt!==y||Ut!==L||Xt!==D||Zt!==F)&&(i.blendFuncSeparate(X[bt],X[Ut],X[Xt],X[Zt]),y=bt,L=Ut,D=Xt,F=Zt),(de.equals(T)===!1||Ae!==E)&&(i.blendColor(de.r,de.g,de.b,Ae),T.copy(de),E=Ae),M=K,j=!1}function et(K,vt){K.side===Ee?ut(i.CULL_FACE):ct(i.CULL_FACE);let bt=K.side===Me;vt&&(bt=!bt),it(bt),K.blending===xi&&K.transparent===!1?W(hn):W(K.blending,K.blendEquation,K.blendSrc,K.blendDst,K.blendEquationAlpha,K.blendSrcAlpha,K.blendDstAlpha,K.blendColor,K.blendAlpha,K.premultipliedAlpha),c.setFunc(K.depthFunc),c.setTest(K.depthTest),c.setMask(K.depthWrite),a.setMask(K.colorWrite);const Ut=K.stencilWrite;l.setTest(Ut),Ut&&(l.setMask(K.stencilWriteMask),l.setFunc(K.stencilFunc,K.stencilRef,K.stencilFuncMask),l.setOp(K.stencilFail,K.stencilZFail,K.stencilZPass)),$(K.polygonOffset,K.polygonOffsetFactor,K.polygonOffsetUnits),K.alphaToCoverage===!0?ct(i.SAMPLE_ALPHA_TO_COVERAGE):ut(i.SAMPLE_ALPHA_TO_COVERAGE)}function it(K){O!==K&&(K?i.frontFace(i.CW):i.frontFace(i.CCW),O=K)}function R(K){K!==xl?(ct(i.CULL_FACE),K!==B&&(K===Eo?i.cullFace(i.BACK):K===Ml?i.cullFace(i.FRONT):i.cullFace(i.FRONT_AND_BACK))):ut(i.CULL_FACE),B=K}function w(K){K!==S&&(I&&i.lineWidth(K),S=K)}function $(K,vt,bt){K?(ct(i.POLYGON_OFFSET_FILL),(b!==vt||v!==bt)&&(i.polygonOffset(vt,bt),b=vt,v=bt)):ut(i.POLYGON_OFFSET_FILL)}function st(K){K?ct(i.SCISSOR_TEST):ut(i.SCISSOR_TEST)}function J(K){K===void 0&&(K=i.TEXTURE0+A-1),N!==K&&(i.activeTexture(K),N=K)}function q(K,vt,bt){bt===void 0&&(N===null?bt=i.TEXTURE0+A-1:bt=N);let Ut=Y[bt];Ut===void 0&&(Ut={type:void 0,texture:void 0},Y[bt]=Ut),(Ut.type!==K||Ut.texture!==vt)&&(N!==bt&&(i.activeTexture(bt),N=bt),i.bindTexture(K,vt||Et[K]),Ut.type=K,Ut.texture=vt)}function Q(){const K=Y[N];K!==void 0&&K.type!==void 0&&(i.bindTexture(K.type,null),K.type=void 0,K.texture=void 0)}function rt(){try{i.compressedTexImage2D.apply(i,arguments)}catch(K){console.error("THREE.WebGLState:",K)}}function at(){try{i.compressedTexImage3D.apply(i,arguments)}catch(K){console.error("THREE.WebGLState:",K)}}function yt(){try{i.texSubImage2D.apply(i,arguments)}catch(K){console.error("THREE.WebGLState:",K)}}function Tt(){try{i.texSubImage3D.apply(i,arguments)}catch(K){console.error("THREE.WebGLState:",K)}}function lt(){try{i.compressedTexSubImage2D.apply(i,arguments)}catch(K){console.error("THREE.WebGLState:",K)}}function Rt(){try{i.compressedTexSubImage3D.apply(i,arguments)}catch(K){console.error("THREE.WebGLState:",K)}}function V(){try{i.texStorage2D.apply(i,arguments)}catch(K){console.error("THREE.WebGLState:",K)}}function pt(){try{i.texStorage3D.apply(i,arguments)}catch(K){console.error("THREE.WebGLState:",K)}}function wt(){try{i.texImage2D.apply(i,arguments)}catch(K){console.error("THREE.WebGLState:",K)}}function St(){try{i.texImage3D.apply(i,arguments)}catch(K){console.error("THREE.WebGLState:",K)}}function Pt(K){ht.equals(K)===!1&&(i.scissor(K.x,K.y,K.z,K.w),ht.copy(K))}function Ft(K){gt.equals(K)===!1&&(i.viewport(K.x,K.y,K.z,K.w),gt.copy(K))}function Ht(K,vt){let bt=f.get(vt);bt===void 0&&(bt=new WeakMap,f.set(vt,bt));let Ut=bt.get(K);Ut===void 0&&(Ut=i.getUniformBlockIndex(vt,K.name),bt.set(K,Ut))}function Gt(K,vt){const Ut=f.get(vt).get(K);h.get(vt)!==Ut&&(i.uniformBlockBinding(vt,Ut,K.__bindingPointIndex),h.set(vt,Ut))}function _t(){i.disable(i.BLEND),i.disable(i.CULL_FACE),i.disable(i.DEPTH_TEST),i.disable(i.POLYGON_OFFSET_FILL),i.disable(i.SCISSOR_TEST),i.disable(i.STENCIL_TEST),i.disable(i.SAMPLE_ALPHA_TO_COVERAGE),i.blendEquation(i.FUNC_ADD),i.blendFunc(i.ONE,i.ZERO),i.blendFuncSeparate(i.ONE,i.ZERO,i.ONE,i.ZERO),i.blendColor(0,0,0,0),i.colorMask(!0,!0,!0,!0),i.clearColor(0,0,0,0),i.depthMask(!0),i.depthFunc(i.LESS),i.clearDepth(1),i.stencilMask(4294967295),i.stencilFunc(i.ALWAYS,0,4294967295),i.stencilOp(i.KEEP,i.KEEP,i.KEEP),i.clearStencil(0),i.cullFace(i.BACK),i.frontFace(i.CCW),i.polygonOffset(0,0),i.activeTexture(i.TEXTURE0),i.bindFramebuffer(i.FRAMEBUFFER,null),n===!0&&(i.bindFramebuffer(i.DRAW_FRAMEBUFFER,null),i.bindFramebuffer(i.READ_FRAMEBUFFER,null)),i.useProgram(null),i.lineWidth(1),i.scissor(0,0,i.canvas.width,i.canvas.height),i.viewport(0,0,i.canvas.width,i.canvas.height),m={},N=null,Y={},p={},_=new WeakMap,x=[],d=null,u=!1,M=null,g=null,y=null,L=null,C=null,D=null,F=null,T=new Dt(0,0,0),E=0,j=!1,O=null,B=null,S=null,b=null,v=null,ht.set(0,0,i.canvas.width,i.canvas.height),gt.set(0,0,i.canvas.width,i.canvas.height),a.reset(),c.reset(),l.reset()}return{buffers:{color:a,depth:c,stencil:l},enable:ct,disable:ut,bindFramebuffer:Mt,drawBuffers:k,useProgram:tt,setBlending:W,setMaterial:et,setFlipSided:it,setCullFace:R,setLineWidth:w,setPolygonOffset:$,setScissorTest:st,activeTexture:J,bindTexture:q,unbindTexture:Q,compressedTexImage2D:rt,compressedTexImage3D:at,texImage2D:wt,texImage3D:St,updateUBOMapping:Ht,uniformBlockBinding:Gt,texStorage2D:V,texStorage3D:pt,texSubImage2D:yt,texSubImage3D:Tt,compressedTexSubImage2D:lt,compressedTexSubImage3D:Rt,scissor:Pt,viewport:Ft,reset:_t}}function Em(i,t,e,n,r,s,o){const a=r.isWebGL2,c=t.has("WEBGL_multisampled_render_to_texture")?t.get("WEBGL_multisampled_render_to_texture"):null,l=typeof navigator>"u"?!1:/OculusBrowser/g.test(navigator.userAgent),h=new WeakMap;let f;const m=new WeakMap;let p=!1;try{p=typeof OffscreenCanvas<"u"&&new OffscreenCanvas(1,1).getContext("2d")!==null}catch{}function _(R,w){return p?new OffscreenCanvas(R,w):kr("canvas")}function x(R,w,$,st){let J=1;if((R.width>st||R.height>st)&&(J=st/Math.max(R.width,R.height)),J<1||w===!0)if(typeof HTMLImageElement<"u"&&R instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&R instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&R instanceof ImageBitmap){const q=w?Gr:Math.floor,Q=q(J*R.width),rt=q(J*R.height);f===void 0&&(f=_(Q,rt));const at=$?_(Q,rt):f;return at.width=Q,at.height=rt,at.getContext("2d").drawImage(R,0,0,Q,rt),console.warn("THREE.WebGLRenderer: Texture has been resized from ("+R.width+"x"+R.height+") to ("+Q+"x"+rt+")."),at}else return"data"in R&&console.warn("THREE.WebGLRenderer: Image in DataTexture is too big ("+R.width+"x"+R.height+")."),R;return R}function d(R){return Ws(R.width)&&Ws(R.height)}function u(R){return a?!1:R.wrapS!==Ve||R.wrapT!==Ve||R.minFilter!==Le&&R.minFilter!==He}function M(R,w){return R.generateMipmaps&&w&&R.minFilter!==Le&&R.minFilter!==He}function g(R){i.generateMipmap(R)}function y(R,w,$,st,J=!1){if(a===!1)return w;if(R!==null){if(i[R]!==void 0)return i[R];console.warn("THREE.WebGLRenderer: Attempt to use non-existing WebGL internal format '"+R+"'")}let q=w;if(w===i.RED&&($===i.FLOAT&&(q=i.R32F),$===i.HALF_FLOAT&&(q=i.R16F),$===i.UNSIGNED_BYTE&&(q=i.R8)),w===i.RED_INTEGER&&($===i.UNSIGNED_BYTE&&(q=i.R8UI),$===i.UNSIGNED_SHORT&&(q=i.R16UI),$===i.UNSIGNED_INT&&(q=i.R32UI),$===i.BYTE&&(q=i.R8I),$===i.SHORT&&(q=i.R16I),$===i.INT&&(q=i.R32I)),w===i.RG&&($===i.FLOAT&&(q=i.RG32F),$===i.HALF_FLOAT&&(q=i.RG16F),$===i.UNSIGNED_BYTE&&(q=i.RG8)),w===i.RGBA){const Q=J?Or:te.getTransfer(st);$===i.FLOAT&&(q=i.RGBA32F),$===i.HALF_FLOAT&&(q=i.RGBA16F),$===i.UNSIGNED_BYTE&&(q=Q===se?i.SRGB8_ALPHA8:i.RGBA8),$===i.UNSIGNED_SHORT_4_4_4_4&&(q=i.RGBA4),$===i.UNSIGNED_SHORT_5_5_5_1&&(q=i.RGB5_A1)}return(q===i.R16F||q===i.R32F||q===i.RG16F||q===i.RG32F||q===i.RGBA16F||q===i.RGBA32F)&&t.get("EXT_color_buffer_float"),q}function L(R,w,$){return M(R,$)===!0||R.isFramebufferTexture&&R.minFilter!==Le&&R.minFilter!==He?Math.log2(Math.max(w.width,w.height))+1:R.mipmaps!==void 0&&R.mipmaps.length>0?R.mipmaps.length:R.isCompressedTexture&&Array.isArray(R.image)?w.mipmaps.length:1}function C(R){return R===Le||R===Co||R===ts?i.NEAREST:i.LINEAR}function D(R){const w=R.target;w.removeEventListener("dispose",D),T(w),w.isVideoTexture&&h.delete(w)}function F(R){const w=R.target;w.removeEventListener("dispose",F),j(w)}function T(R){const w=n.get(R);if(w.__webglInit===void 0)return;const $=R.source,st=m.get($);if(st){const J=st[w.__cacheKey];J.usedTimes--,J.usedTimes===0&&E(R),Object.keys(st).length===0&&m.delete($)}n.remove(R)}function E(R){const w=n.get(R);i.deleteTexture(w.__webglTexture);const $=R.source,st=m.get($);delete st[w.__cacheKey],o.memory.textures--}function j(R){const w=R.texture,$=n.get(R),st=n.get(w);if(st.__webglTexture!==void 0&&(i.deleteTexture(st.__webglTexture),o.memory.textures--),R.depthTexture&&R.depthTexture.dispose(),R.isWebGLCubeRenderTarget)for(let J=0;J<6;J++){if(Array.isArray($.__webglFramebuffer[J]))for(let q=0;q<$.__webglFramebuffer[J].length;q++)i.deleteFramebuffer($.__webglFramebuffer[J][q]);else i.deleteFramebuffer($.__webglFramebuffer[J]);$.__webglDepthbuffer&&i.deleteRenderbuffer($.__webglDepthbuffer[J])}else{if(Array.isArray($.__webglFramebuffer))for(let J=0;J<$.__webglFramebuffer.length;J++)i.deleteFramebuffer($.__webglFramebuffer[J]);else i.deleteFramebuffer($.__webglFramebuffer);if($.__webglDepthbuffer&&i.deleteRenderbuffer($.__webglDepthbuffer),$.__webglMultisampledFramebuffer&&i.deleteFramebuffer($.__webglMultisampledFramebuffer),$.__webglColorRenderbuffer)for(let J=0;J<$.__webglColorRenderbuffer.length;J++)$.__webglColorRenderbuffer[J]&&i.deleteRenderbuffer($.__webglColorRenderbuffer[J]);$.__webglDepthRenderbuffer&&i.deleteRenderbuffer($.__webglDepthRenderbuffer)}if(R.isWebGLMultipleRenderTargets)for(let J=0,q=w.length;J<q;J++){const Q=n.get(w[J]);Q.__webglTexture&&(i.deleteTexture(Q.__webglTexture),o.memory.textures--),n.remove(w[J])}n.remove(w),n.remove(R)}let O=0;function B(){O=0}function S(){const R=O;return R>=r.maxTextures&&console.warn("THREE.WebGLTextures: Trying to use "+R+" texture units while this GPU supports only "+r.maxTextures),O+=1,R}function b(R){const w=[];return w.push(R.wrapS),w.push(R.wrapT),w.push(R.wrapR||0),w.push(R.magFilter),w.push(R.minFilter),w.push(R.anisotropy),w.push(R.internalFormat),w.push(R.format),w.push(R.type),w.push(R.generateMipmaps),w.push(R.premultiplyAlpha),w.push(R.flipY),w.push(R.unpackAlignment),w.push(R.colorSpace),w.join()}function v(R,w){const $=n.get(R);if(R.isVideoTexture&&et(R),R.isRenderTargetTexture===!1&&R.version>0&&$.__version!==R.version){const st=R.image;if(st===null)console.warn("THREE.WebGLRenderer: Texture marked for update but no image data found.");else if(st.complete===!1)console.warn("THREE.WebGLRenderer: Texture marked for update but image is incomplete");else{ht($,R,w);return}}e.bindTexture(i.TEXTURE_2D,$.__webglTexture,i.TEXTURE0+w)}function A(R,w){const $=n.get(R);if(R.version>0&&$.__version!==R.version){ht($,R,w);return}e.bindTexture(i.TEXTURE_2D_ARRAY,$.__webglTexture,i.TEXTURE0+w)}function I(R,w){const $=n.get(R);if(R.version>0&&$.__version!==R.version){ht($,R,w);return}e.bindTexture(i.TEXTURE_3D,$.__webglTexture,i.TEXTURE0+w)}function U(R,w){const $=n.get(R);if(R.version>0&&$.__version!==R.version){gt($,R,w);return}e.bindTexture(i.TEXTURE_CUBE_MAP,$.__webglTexture,i.TEXTURE0+w)}const P={[bi]:i.REPEAT,[Ve]:i.CLAMP_TO_EDGE,[Hs]:i.MIRRORED_REPEAT},N={[Le]:i.NEAREST,[Co]:i.NEAREST_MIPMAP_NEAREST,[ts]:i.NEAREST_MIPMAP_LINEAR,[He]:i.LINEAR,[Yl]:i.LINEAR_MIPMAP_NEAREST,[qi]:i.LINEAR_MIPMAP_LINEAR},Y={[su]:i.NEVER,[hu]:i.ALWAYS,[ou]:i.LESS,[Pc]:i.LEQUAL,[au]:i.EQUAL,[uu]:i.GEQUAL,[cu]:i.GREATER,[lu]:i.NOTEQUAL};function Z(R,w,$){if($?(i.texParameteri(R,i.TEXTURE_WRAP_S,P[w.wrapS]),i.texParameteri(R,i.TEXTURE_WRAP_T,P[w.wrapT]),(R===i.TEXTURE_3D||R===i.TEXTURE_2D_ARRAY)&&i.texParameteri(R,i.TEXTURE_WRAP_R,P[w.wrapR]),i.texParameteri(R,i.TEXTURE_MAG_FILTER,N[w.magFilter]),i.texParameteri(R,i.TEXTURE_MIN_FILTER,N[w.minFilter])):(i.texParameteri(R,i.TEXTURE_WRAP_S,i.CLAMP_TO_EDGE),i.texParameteri(R,i.TEXTURE_WRAP_T,i.CLAMP_TO_EDGE),(R===i.TEXTURE_3D||R===i.TEXTURE_2D_ARRAY)&&i.texParameteri(R,i.TEXTURE_WRAP_R,i.CLAMP_TO_EDGE),(w.wrapS!==Ve||w.wrapT!==Ve)&&console.warn("THREE.WebGLRenderer: Texture is not power of two. Texture.wrapS and Texture.wrapT should be set to THREE.ClampToEdgeWrapping."),i.texParameteri(R,i.TEXTURE_MAG_FILTER,C(w.magFilter)),i.texParameteri(R,i.TEXTURE_MIN_FILTER,C(w.minFilter)),w.minFilter!==Le&&w.minFilter!==He&&console.warn("THREE.WebGLRenderer: Texture is not power of two. Texture.minFilter should be set to THREE.NearestFilter or THREE.LinearFilter.")),w.compareFunction&&(i.texParameteri(R,i.TEXTURE_COMPARE_MODE,i.COMPARE_REF_TO_TEXTURE),i.texParameteri(R,i.TEXTURE_COMPARE_FUNC,Y[w.compareFunction])),t.has("EXT_texture_filter_anisotropic")===!0){const st=t.get("EXT_texture_filter_anisotropic");if(w.magFilter===Le||w.minFilter!==ts&&w.minFilter!==qi||w.type===En&&t.has("OES_texture_float_linear")===!1||a===!1&&w.type===dn&&t.has("OES_texture_half_float_linear")===!1)return;(w.anisotropy>1||n.get(w).__currentAnisotropy)&&(i.texParameterf(R,st.TEXTURE_MAX_ANISOTROPY_EXT,Math.min(w.anisotropy,r.getMaxAnisotropy())),n.get(w).__currentAnisotropy=w.anisotropy)}}function nt(R,w){let $=!1;R.__webglInit===void 0&&(R.__webglInit=!0,w.addEventListener("dispose",D));const st=w.source;let J=m.get(st);J===void 0&&(J={},m.set(st,J));const q=b(w);if(q!==R.__cacheKey){J[q]===void 0&&(J[q]={texture:i.createTexture(),usedTimes:0},o.memory.textures++,$=!0),J[q].usedTimes++;const Q=J[R.__cacheKey];Q!==void 0&&(J[R.__cacheKey].usedTimes--,Q.usedTimes===0&&E(w)),R.__cacheKey=q,R.__webglTexture=J[q].texture}return $}function ht(R,w,$){let st=i.TEXTURE_2D;(w.isDataArrayTexture||w.isCompressedArrayTexture)&&(st=i.TEXTURE_2D_ARRAY),w.isData3DTexture&&(st=i.TEXTURE_3D);const J=nt(R,w),q=w.source;e.bindTexture(st,R.__webglTexture,i.TEXTURE0+$);const Q=n.get(q);if(q.version!==Q.__version||J===!0){e.activeTexture(i.TEXTURE0+$);const rt=te.getPrimaries(te.workingColorSpace),at=w.colorSpace===Xe?null:te.getPrimaries(w.colorSpace),yt=w.colorSpace===Xe||rt===at?i.NONE:i.BROWSER_DEFAULT_WEBGL;i.pixelStorei(i.UNPACK_FLIP_Y_WEBGL,w.flipY),i.pixelStorei(i.UNPACK_PREMULTIPLY_ALPHA_WEBGL,w.premultiplyAlpha),i.pixelStorei(i.UNPACK_ALIGNMENT,w.unpackAlignment),i.pixelStorei(i.UNPACK_COLORSPACE_CONVERSION_WEBGL,yt);const Tt=u(w)&&d(w.image)===!1;let lt=x(w.image,Tt,!1,r.maxTextureSize);lt=it(w,lt);const Rt=d(lt)||a,V=s.convert(w.format,w.colorSpace);let pt=s.convert(w.type),wt=y(w.internalFormat,V,pt,w.colorSpace,w.isVideoTexture);Z(st,w,Rt);let St;const Pt=w.mipmaps,Ft=a&&w.isVideoTexture!==!0&&wt!==Ac,Ht=Q.__version===void 0||J===!0,Gt=L(w,lt,Rt);if(w.isDepthTexture)wt=i.DEPTH_COMPONENT,a?w.type===En?wt=i.DEPTH_COMPONENT32F:w.type===bn?wt=i.DEPTH_COMPONENT24:w.type===zn?wt=i.DEPTH24_STENCIL8:wt=i.DEPTH_COMPONENT16:w.type===En&&console.error("WebGLRenderer: Floating point depth texture requires WebGL2."),w.format===Gn&&wt===i.DEPTH_COMPONENT&&w.type!==eo&&w.type!==bn&&(console.warn("THREE.WebGLRenderer: Use UnsignedShortType or UnsignedIntType for DepthFormat DepthTexture."),w.type=bn,pt=s.convert(w.type)),w.format===Ei&&wt===i.DEPTH_COMPONENT&&(wt=i.DEPTH_STENCIL,w.type!==zn&&(console.warn("THREE.WebGLRenderer: Use UnsignedInt248Type for DepthStencilFormat DepthTexture."),w.type=zn,pt=s.convert(w.type))),Ht&&(Ft?e.texStorage2D(i.TEXTURE_2D,1,wt,lt.width,lt.height):e.texImage2D(i.TEXTURE_2D,0,wt,lt.width,lt.height,0,V,pt,null));else if(w.isDataTexture)if(Pt.length>0&&Rt){Ft&&Ht&&e.texStorage2D(i.TEXTURE_2D,Gt,wt,Pt[0].width,Pt[0].height);for(let _t=0,K=Pt.length;_t<K;_t++)St=Pt[_t],Ft?e.texSubImage2D(i.TEXTURE_2D,_t,0,0,St.width,St.height,V,pt,St.data):e.texImage2D(i.TEXTURE_2D,_t,wt,St.width,St.height,0,V,pt,St.data);w.generateMipmaps=!1}else Ft?(Ht&&e.texStorage2D(i.TEXTURE_2D,Gt,wt,lt.width,lt.height),e.texSubImage2D(i.TEXTURE_2D,0,0,0,lt.width,lt.height,V,pt,lt.data)):e.texImage2D(i.TEXTURE_2D,0,wt,lt.width,lt.height,0,V,pt,lt.data);else if(w.isCompressedTexture)if(w.isCompressedArrayTexture){Ft&&Ht&&e.texStorage3D(i.TEXTURE_2D_ARRAY,Gt,wt,Pt[0].width,Pt[0].height,lt.depth);for(let _t=0,K=Pt.length;_t<K;_t++)St=Pt[_t],w.format!==je?V!==null?Ft?e.compressedTexSubImage3D(i.TEXTURE_2D_ARRAY,_t,0,0,0,St.width,St.height,lt.depth,V,St.data,0,0):e.compressedTexImage3D(i.TEXTURE_2D_ARRAY,_t,wt,St.width,St.height,lt.depth,0,St.data,0,0):console.warn("THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()"):Ft?e.texSubImage3D(i.TEXTURE_2D_ARRAY,_t,0,0,0,St.width,St.height,lt.depth,V,pt,St.data):e.texImage3D(i.TEXTURE_2D_ARRAY,_t,wt,St.width,St.height,lt.depth,0,V,pt,St.data)}else{Ft&&Ht&&e.texStorage2D(i.TEXTURE_2D,Gt,wt,Pt[0].width,Pt[0].height);for(let _t=0,K=Pt.length;_t<K;_t++)St=Pt[_t],w.format!==je?V!==null?Ft?e.compressedTexSubImage2D(i.TEXTURE_2D,_t,0,0,St.width,St.height,V,St.data):e.compressedTexImage2D(i.TEXTURE_2D,_t,wt,St.width,St.height,0,St.data):console.warn("THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()"):Ft?e.texSubImage2D(i.TEXTURE_2D,_t,0,0,St.width,St.height,V,pt,St.data):e.texImage2D(i.TEXTURE_2D,_t,wt,St.width,St.height,0,V,pt,St.data)}else if(w.isDataArrayTexture)Ft?(Ht&&e.texStorage3D(i.TEXTURE_2D_ARRAY,Gt,wt,lt.width,lt.height,lt.depth),e.texSubImage3D(i.TEXTURE_2D_ARRAY,0,0,0,0,lt.width,lt.height,lt.depth,V,pt,lt.data)):e.texImage3D(i.TEXTURE_2D_ARRAY,0,wt,lt.width,lt.height,lt.depth,0,V,pt,lt.data);else if(w.isData3DTexture)Ft?(Ht&&e.texStorage3D(i.TEXTURE_3D,Gt,wt,lt.width,lt.height,lt.depth),e.texSubImage3D(i.TEXTURE_3D,0,0,0,0,lt.width,lt.height,lt.depth,V,pt,lt.data)):e.texImage3D(i.TEXTURE_3D,0,wt,lt.width,lt.height,lt.depth,0,V,pt,lt.data);else if(w.isFramebufferTexture){if(Ht)if(Ft)e.texStorage2D(i.TEXTURE_2D,Gt,wt,lt.width,lt.height);else{let _t=lt.width,K=lt.height;for(let vt=0;vt<Gt;vt++)e.texImage2D(i.TEXTURE_2D,vt,wt,_t,K,0,V,pt,null),_t>>=1,K>>=1}}else if(Pt.length>0&&Rt){Ft&&Ht&&e.texStorage2D(i.TEXTURE_2D,Gt,wt,Pt[0].width,Pt[0].height);for(let _t=0,K=Pt.length;_t<K;_t++)St=Pt[_t],Ft?e.texSubImage2D(i.TEXTURE_2D,_t,0,0,V,pt,St):e.texImage2D(i.TEXTURE_2D,_t,wt,V,pt,St);w.generateMipmaps=!1}else Ft?(Ht&&e.texStorage2D(i.TEXTURE_2D,Gt,wt,lt.width,lt.height),e.texSubImage2D(i.TEXTURE_2D,0,0,0,V,pt,lt)):e.texImage2D(i.TEXTURE_2D,0,wt,V,pt,lt);M(w,Rt)&&g(st),Q.__version=q.version,w.onUpdate&&w.onUpdate(w)}R.__version=w.version}function gt(R,w,$){if(w.image.length!==6)return;const st=nt(R,w),J=w.source;e.bindTexture(i.TEXTURE_CUBE_MAP,R.__webglTexture,i.TEXTURE0+$);const q=n.get(J);if(J.version!==q.__version||st===!0){e.activeTexture(i.TEXTURE0+$);const Q=te.getPrimaries(te.workingColorSpace),rt=w.colorSpace===Xe?null:te.getPrimaries(w.colorSpace),at=w.colorSpace===Xe||Q===rt?i.NONE:i.BROWSER_DEFAULT_WEBGL;i.pixelStorei(i.UNPACK_FLIP_Y_WEBGL,w.flipY),i.pixelStorei(i.UNPACK_PREMULTIPLY_ALPHA_WEBGL,w.premultiplyAlpha),i.pixelStorei(i.UNPACK_ALIGNMENT,w.unpackAlignment),i.pixelStorei(i.UNPACK_COLORSPACE_CONVERSION_WEBGL,at);const yt=w.isCompressedTexture||w.image[0].isCompressedTexture,Tt=w.image[0]&&w.image[0].isDataTexture,lt=[];for(let _t=0;_t<6;_t++)!yt&&!Tt?lt[_t]=x(w.image[_t],!1,!0,r.maxCubemapSize):lt[_t]=Tt?w.image[_t].image:w.image[_t],lt[_t]=it(w,lt[_t]);const Rt=lt[0],V=d(Rt)||a,pt=s.convert(w.format,w.colorSpace),wt=s.convert(w.type),St=y(w.internalFormat,pt,wt,w.colorSpace),Pt=a&&w.isVideoTexture!==!0,Ft=q.__version===void 0||st===!0;let Ht=L(w,Rt,V);Z(i.TEXTURE_CUBE_MAP,w,V);let Gt;if(yt){Pt&&Ft&&e.texStorage2D(i.TEXTURE_CUBE_MAP,Ht,St,Rt.width,Rt.height);for(let _t=0;_t<6;_t++){Gt=lt[_t].mipmaps;for(let K=0;K<Gt.length;K++){const vt=Gt[K];w.format!==je?pt!==null?Pt?e.compressedTexSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,K,0,0,vt.width,vt.height,pt,vt.data):e.compressedTexImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,K,St,vt.width,vt.height,0,vt.data):console.warn("THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .setTextureCube()"):Pt?e.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,K,0,0,vt.width,vt.height,pt,wt,vt.data):e.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,K,St,vt.width,vt.height,0,pt,wt,vt.data)}}}else{Gt=w.mipmaps,Pt&&Ft&&(Gt.length>0&&Ht++,e.texStorage2D(i.TEXTURE_CUBE_MAP,Ht,St,lt[0].width,lt[0].height));for(let _t=0;_t<6;_t++)if(Tt){Pt?e.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,0,0,0,lt[_t].width,lt[_t].height,pt,wt,lt[_t].data):e.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,0,St,lt[_t].width,lt[_t].height,0,pt,wt,lt[_t].data);for(let K=0;K<Gt.length;K++){const bt=Gt[K].image[_t].image;Pt?e.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,K+1,0,0,bt.width,bt.height,pt,wt,bt.data):e.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,K+1,St,bt.width,bt.height,0,pt,wt,bt.data)}}else{Pt?e.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,0,0,0,pt,wt,lt[_t]):e.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,0,St,pt,wt,lt[_t]);for(let K=0;K<Gt.length;K++){const vt=Gt[K];Pt?e.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,K+1,0,0,pt,wt,vt.image[_t]):e.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,K+1,St,pt,wt,vt.image[_t])}}}M(w,V)&&g(i.TEXTURE_CUBE_MAP),q.__version=J.version,w.onUpdate&&w.onUpdate(w)}R.__version=w.version}function xt(R,w,$,st,J,q){const Q=s.convert($.format,$.colorSpace),rt=s.convert($.type),at=y($.internalFormat,Q,rt,$.colorSpace);if(!n.get(w).__hasExternalTextures){const Tt=Math.max(1,w.width>>q),lt=Math.max(1,w.height>>q);J===i.TEXTURE_3D||J===i.TEXTURE_2D_ARRAY?e.texImage3D(J,q,at,Tt,lt,w.depth,0,Q,rt,null):e.texImage2D(J,q,at,Tt,lt,0,Q,rt,null)}e.bindFramebuffer(i.FRAMEBUFFER,R),W(w)?c.framebufferTexture2DMultisampleEXT(i.FRAMEBUFFER,st,J,n.get($).__webglTexture,0,X(w)):(J===i.TEXTURE_2D||J>=i.TEXTURE_CUBE_MAP_POSITIVE_X&&J<=i.TEXTURE_CUBE_MAP_NEGATIVE_Z)&&i.framebufferTexture2D(i.FRAMEBUFFER,st,J,n.get($).__webglTexture,q),e.bindFramebuffer(i.FRAMEBUFFER,null)}function Et(R,w,$){if(i.bindRenderbuffer(i.RENDERBUFFER,R),w.depthBuffer&&!w.stencilBuffer){let st=a===!0?i.DEPTH_COMPONENT24:i.DEPTH_COMPONENT16;if($||W(w)){const J=w.depthTexture;J&&J.isDepthTexture&&(J.type===En?st=i.DEPTH_COMPONENT32F:J.type===bn&&(st=i.DEPTH_COMPONENT24));const q=X(w);W(w)?c.renderbufferStorageMultisampleEXT(i.RENDERBUFFER,q,st,w.width,w.height):i.renderbufferStorageMultisample(i.RENDERBUFFER,q,st,w.width,w.height)}else i.renderbufferStorage(i.RENDERBUFFER,st,w.width,w.height);i.framebufferRenderbuffer(i.FRAMEBUFFER,i.DEPTH_ATTACHMENT,i.RENDERBUFFER,R)}else if(w.depthBuffer&&w.stencilBuffer){const st=X(w);$&&W(w)===!1?i.renderbufferStorageMultisample(i.RENDERBUFFER,st,i.DEPTH24_STENCIL8,w.width,w.height):W(w)?c.renderbufferStorageMultisampleEXT(i.RENDERBUFFER,st,i.DEPTH24_STENCIL8,w.width,w.height):i.renderbufferStorage(i.RENDERBUFFER,i.DEPTH_STENCIL,w.width,w.height),i.framebufferRenderbuffer(i.FRAMEBUFFER,i.DEPTH_STENCIL_ATTACHMENT,i.RENDERBUFFER,R)}else{const st=w.isWebGLMultipleRenderTargets===!0?w.texture:[w.texture];for(let J=0;J<st.length;J++){const q=st[J],Q=s.convert(q.format,q.colorSpace),rt=s.convert(q.type),at=y(q.internalFormat,Q,rt,q.colorSpace),yt=X(w);$&&W(w)===!1?i.renderbufferStorageMultisample(i.RENDERBUFFER,yt,at,w.width,w.height):W(w)?c.renderbufferStorageMultisampleEXT(i.RENDERBUFFER,yt,at,w.width,w.height):i.renderbufferStorage(i.RENDERBUFFER,at,w.width,w.height)}}i.bindRenderbuffer(i.RENDERBUFFER,null)}function ct(R,w){if(w&&w.isWebGLCubeRenderTarget)throw new Error("Depth Texture with cube render targets is not supported");if(e.bindFramebuffer(i.FRAMEBUFFER,R),!(w.depthTexture&&w.depthTexture.isDepthTexture))throw new Error("renderTarget.depthTexture must be an instance of THREE.DepthTexture");(!n.get(w.depthTexture).__webglTexture||w.depthTexture.image.width!==w.width||w.depthTexture.image.height!==w.height)&&(w.depthTexture.image.width=w.width,w.depthTexture.image.height=w.height,w.depthTexture.needsUpdate=!0),v(w.depthTexture,0);const st=n.get(w.depthTexture).__webglTexture,J=X(w);if(w.depthTexture.format===Gn)W(w)?c.framebufferTexture2DMultisampleEXT(i.FRAMEBUFFER,i.DEPTH_ATTACHMENT,i.TEXTURE_2D,st,0,J):i.framebufferTexture2D(i.FRAMEBUFFER,i.DEPTH_ATTACHMENT,i.TEXTURE_2D,st,0);else if(w.depthTexture.format===Ei)W(w)?c.framebufferTexture2DMultisampleEXT(i.FRAMEBUFFER,i.DEPTH_STENCIL_ATTACHMENT,i.TEXTURE_2D,st,0,J):i.framebufferTexture2D(i.FRAMEBUFFER,i.DEPTH_STENCIL_ATTACHMENT,i.TEXTURE_2D,st,0);else throw new Error("Unknown depthTexture format")}function ut(R){const w=n.get(R),$=R.isWebGLCubeRenderTarget===!0;if(R.depthTexture&&!w.__autoAllocateDepthBuffer){if($)throw new Error("target.depthTexture not supported in Cube render targets");ct(w.__webglFramebuffer,R)}else if($){w.__webglDepthbuffer=[];for(let st=0;st<6;st++)e.bindFramebuffer(i.FRAMEBUFFER,w.__webglFramebuffer[st]),w.__webglDepthbuffer[st]=i.createRenderbuffer(),Et(w.__webglDepthbuffer[st],R,!1)}else e.bindFramebuffer(i.FRAMEBUFFER,w.__webglFramebuffer),w.__webglDepthbuffer=i.createRenderbuffer(),Et(w.__webglDepthbuffer,R,!1);e.bindFramebuffer(i.FRAMEBUFFER,null)}function Mt(R,w,$){const st=n.get(R);w!==void 0&&xt(st.__webglFramebuffer,R,R.texture,i.COLOR_ATTACHMENT0,i.TEXTURE_2D,0),$!==void 0&&ut(R)}function k(R){const w=R.texture,$=n.get(R),st=n.get(w);R.addEventListener("dispose",F),R.isWebGLMultipleRenderTargets!==!0&&(st.__webglTexture===void 0&&(st.__webglTexture=i.createTexture()),st.__version=w.version,o.memory.textures++);const J=R.isWebGLCubeRenderTarget===!0,q=R.isWebGLMultipleRenderTargets===!0,Q=d(R)||a;if(J){$.__webglFramebuffer=[];for(let rt=0;rt<6;rt++)if(a&&w.mipmaps&&w.mipmaps.length>0){$.__webglFramebuffer[rt]=[];for(let at=0;at<w.mipmaps.length;at++)$.__webglFramebuffer[rt][at]=i.createFramebuffer()}else $.__webglFramebuffer[rt]=i.createFramebuffer()}else{if(a&&w.mipmaps&&w.mipmaps.length>0){$.__webglFramebuffer=[];for(let rt=0;rt<w.mipmaps.length;rt++)$.__webglFramebuffer[rt]=i.createFramebuffer()}else $.__webglFramebuffer=i.createFramebuffer();if(q)if(r.drawBuffers){const rt=R.texture;for(let at=0,yt=rt.length;at<yt;at++){const Tt=n.get(rt[at]);Tt.__webglTexture===void 0&&(Tt.__webglTexture=i.createTexture(),o.memory.textures++)}}else console.warn("THREE.WebGLRenderer: WebGLMultipleRenderTargets can only be used with WebGL2 or WEBGL_draw_buffers extension.");if(a&&R.samples>0&&W(R)===!1){const rt=q?w:[w];$.__webglMultisampledFramebuffer=i.createFramebuffer(),$.__webglColorRenderbuffer=[],e.bindFramebuffer(i.FRAMEBUFFER,$.__webglMultisampledFramebuffer);for(let at=0;at<rt.length;at++){const yt=rt[at];$.__webglColorRenderbuffer[at]=i.createRenderbuffer(),i.bindRenderbuffer(i.RENDERBUFFER,$.__webglColorRenderbuffer[at]);const Tt=s.convert(yt.format,yt.colorSpace),lt=s.convert(yt.type),Rt=y(yt.internalFormat,Tt,lt,yt.colorSpace,R.isXRRenderTarget===!0),V=X(R);i.renderbufferStorageMultisample(i.RENDERBUFFER,V,Rt,R.width,R.height),i.framebufferRenderbuffer(i.FRAMEBUFFER,i.COLOR_ATTACHMENT0+at,i.RENDERBUFFER,$.__webglColorRenderbuffer[at])}i.bindRenderbuffer(i.RENDERBUFFER,null),R.depthBuffer&&($.__webglDepthRenderbuffer=i.createRenderbuffer(),Et($.__webglDepthRenderbuffer,R,!0)),e.bindFramebuffer(i.FRAMEBUFFER,null)}}if(J){e.bindTexture(i.TEXTURE_CUBE_MAP,st.__webglTexture),Z(i.TEXTURE_CUBE_MAP,w,Q);for(let rt=0;rt<6;rt++)if(a&&w.mipmaps&&w.mipmaps.length>0)for(let at=0;at<w.mipmaps.length;at++)xt($.__webglFramebuffer[rt][at],R,w,i.COLOR_ATTACHMENT0,i.TEXTURE_CUBE_MAP_POSITIVE_X+rt,at);else xt($.__webglFramebuffer[rt],R,w,i.COLOR_ATTACHMENT0,i.TEXTURE_CUBE_MAP_POSITIVE_X+rt,0);M(w,Q)&&g(i.TEXTURE_CUBE_MAP),e.unbindTexture()}else if(q){const rt=R.texture;for(let at=0,yt=rt.length;at<yt;at++){const Tt=rt[at],lt=n.get(Tt);e.bindTexture(i.TEXTURE_2D,lt.__webglTexture),Z(i.TEXTURE_2D,Tt,Q),xt($.__webglFramebuffer,R,Tt,i.COLOR_ATTACHMENT0+at,i.TEXTURE_2D,0),M(Tt,Q)&&g(i.TEXTURE_2D)}e.unbindTexture()}else{let rt=i.TEXTURE_2D;if((R.isWebGL3DRenderTarget||R.isWebGLArrayRenderTarget)&&(a?rt=R.isWebGL3DRenderTarget?i.TEXTURE_3D:i.TEXTURE_2D_ARRAY:console.error("THREE.WebGLTextures: THREE.Data3DTexture and THREE.DataArrayTexture only supported with WebGL2.")),e.bindTexture(rt,st.__webglTexture),Z(rt,w,Q),a&&w.mipmaps&&w.mipmaps.length>0)for(let at=0;at<w.mipmaps.length;at++)xt($.__webglFramebuffer[at],R,w,i.COLOR_ATTACHMENT0,rt,at);else xt($.__webglFramebuffer,R,w,i.COLOR_ATTACHMENT0,rt,0);M(w,Q)&&g(rt),e.unbindTexture()}R.depthBuffer&&ut(R)}function tt(R){const w=d(R)||a,$=R.isWebGLMultipleRenderTargets===!0?R.texture:[R.texture];for(let st=0,J=$.length;st<J;st++){const q=$[st];if(M(q,w)){const Q=R.isWebGLCubeRenderTarget?i.TEXTURE_CUBE_MAP:i.TEXTURE_2D,rt=n.get(q).__webglTexture;e.bindTexture(Q,rt),g(Q),e.unbindTexture()}}}function G(R){if(a&&R.samples>0&&W(R)===!1){const w=R.isWebGLMultipleRenderTargets?R.texture:[R.texture],$=R.width,st=R.height;let J=i.COLOR_BUFFER_BIT;const q=[],Q=R.stencilBuffer?i.DEPTH_STENCIL_ATTACHMENT:i.DEPTH_ATTACHMENT,rt=n.get(R),at=R.isWebGLMultipleRenderTargets===!0;if(at)for(let yt=0;yt<w.length;yt++)e.bindFramebuffer(i.FRAMEBUFFER,rt.__webglMultisampledFramebuffer),i.framebufferRenderbuffer(i.FRAMEBUFFER,i.COLOR_ATTACHMENT0+yt,i.RENDERBUFFER,null),e.bindFramebuffer(i.FRAMEBUFFER,rt.__webglFramebuffer),i.framebufferTexture2D(i.DRAW_FRAMEBUFFER,i.COLOR_ATTACHMENT0+yt,i.TEXTURE_2D,null,0);e.bindFramebuffer(i.READ_FRAMEBUFFER,rt.__webglMultisampledFramebuffer),e.bindFramebuffer(i.DRAW_FRAMEBUFFER,rt.__webglFramebuffer);for(let yt=0;yt<w.length;yt++){q.push(i.COLOR_ATTACHMENT0+yt),R.depthBuffer&&q.push(Q);const Tt=rt.__ignoreDepthValues!==void 0?rt.__ignoreDepthValues:!1;if(Tt===!1&&(R.depthBuffer&&(J|=i.DEPTH_BUFFER_BIT),R.stencilBuffer&&(J|=i.STENCIL_BUFFER_BIT)),at&&i.framebufferRenderbuffer(i.READ_FRAMEBUFFER,i.COLOR_ATTACHMENT0,i.RENDERBUFFER,rt.__webglColorRenderbuffer[yt]),Tt===!0&&(i.invalidateFramebuffer(i.READ_FRAMEBUFFER,[Q]),i.invalidateFramebuffer(i.DRAW_FRAMEBUFFER,[Q])),at){const lt=n.get(w[yt]).__webglTexture;i.framebufferTexture2D(i.DRAW_FRAMEBUFFER,i.COLOR_ATTACHMENT0,i.TEXTURE_2D,lt,0)}i.blitFramebuffer(0,0,$,st,0,0,$,st,J,i.NEAREST),l&&i.invalidateFramebuffer(i.READ_FRAMEBUFFER,q)}if(e.bindFramebuffer(i.READ_FRAMEBUFFER,null),e.bindFramebuffer(i.DRAW_FRAMEBUFFER,null),at)for(let yt=0;yt<w.length;yt++){e.bindFramebuffer(i.FRAMEBUFFER,rt.__webglMultisampledFramebuffer),i.framebufferRenderbuffer(i.FRAMEBUFFER,i.COLOR_ATTACHMENT0+yt,i.RENDERBUFFER,rt.__webglColorRenderbuffer[yt]);const Tt=n.get(w[yt]).__webglTexture;e.bindFramebuffer(i.FRAMEBUFFER,rt.__webglFramebuffer),i.framebufferTexture2D(i.DRAW_FRAMEBUFFER,i.COLOR_ATTACHMENT0+yt,i.TEXTURE_2D,Tt,0)}e.bindFramebuffer(i.DRAW_FRAMEBUFFER,rt.__webglMultisampledFramebuffer)}}function X(R){return Math.min(r.maxSamples,R.samples)}function W(R){const w=n.get(R);return a&&R.samples>0&&t.has("WEBGL_multisampled_render_to_texture")===!0&&w.__useRenderToTexture!==!1}function et(R){const w=o.render.frame;h.get(R)!==w&&(h.set(R,w),R.update())}function it(R,w){const $=R.colorSpace,st=R.format,J=R.type;return R.isCompressedTexture===!0||R.isVideoTexture===!0||R.format===Xs||$!==mn&&$!==Xe&&(te.getTransfer($)===se?a===!1?t.has("EXT_sRGB")===!0&&st===je?(R.format=Xs,R.minFilter=He,R.generateMipmaps=!1):w=Ic.sRGBToLinear(w):(st!==je||J!==Tn)&&console.warn("THREE.WebGLTextures: sRGB encoded textures have to use RGBAFormat and UnsignedByteType."):console.error("THREE.WebGLTextures: Unsupported texture color space:",$)),w}this.allocateTextureUnit=S,this.resetTextureUnits=B,this.setTexture2D=v,this.setTexture2DArray=A,this.setTexture3D=I,this.setTextureCube=U,this.rebindTextures=Mt,this.setupRenderTarget=k,this.updateRenderTargetMipmap=tt,this.updateMultisampleRenderTarget=G,this.setupDepthRenderbuffer=ut,this.setupFrameBufferTexture=xt,this.useMultisampledRTT=W}function wm(i,t,e){const n=e.isWebGL2;function r(s,o=Xe){let a;const c=te.getTransfer(o);if(s===Tn)return i.UNSIGNED_BYTE;if(s===Sc)return i.UNSIGNED_SHORT_4_4_4_4;if(s===bc)return i.UNSIGNED_SHORT_5_5_5_1;if(s===jl)return i.BYTE;if(s===$l)return i.SHORT;if(s===eo)return i.UNSIGNED_SHORT;if(s===yc)return i.INT;if(s===bn)return i.UNSIGNED_INT;if(s===En)return i.FLOAT;if(s===dn)return n?i.HALF_FLOAT:(a=t.get("OES_texture_half_float"),a!==null?a.HALF_FLOAT_OES:null);if(s===Kl)return i.ALPHA;if(s===je)return i.RGBA;if(s===Zl)return i.LUMINANCE;if(s===Jl)return i.LUMINANCE_ALPHA;if(s===Gn)return i.DEPTH_COMPONENT;if(s===Ei)return i.DEPTH_STENCIL;if(s===Xs)return a=t.get("EXT_sRGB"),a!==null?a.SRGB_ALPHA_EXT:null;if(s===Ql)return i.RED;if(s===Ec)return i.RED_INTEGER;if(s===tu)return i.RG;if(s===wc)return i.RG_INTEGER;if(s===Tc)return i.RGBA_INTEGER;if(s===es||s===ns||s===is||s===rs)if(c===se)if(a=t.get("WEBGL_compressed_texture_s3tc_srgb"),a!==null){if(s===es)return a.COMPRESSED_SRGB_S3TC_DXT1_EXT;if(s===ns)return a.COMPRESSED_SRGB_ALPHA_S3TC_DXT1_EXT;if(s===is)return a.COMPRESSED_SRGB_ALPHA_S3TC_DXT3_EXT;if(s===rs)return a.COMPRESSED_SRGB_ALPHA_S3TC_DXT5_EXT}else return null;else if(a=t.get("WEBGL_compressed_texture_s3tc"),a!==null){if(s===es)return a.COMPRESSED_RGB_S3TC_DXT1_EXT;if(s===ns)return a.COMPRESSED_RGBA_S3TC_DXT1_EXT;if(s===is)return a.COMPRESSED_RGBA_S3TC_DXT3_EXT;if(s===rs)return a.COMPRESSED_RGBA_S3TC_DXT5_EXT}else return null;if(s===Po||s===Lo||s===Do||s===Io)if(a=t.get("WEBGL_compressed_texture_pvrtc"),a!==null){if(s===Po)return a.COMPRESSED_RGB_PVRTC_4BPPV1_IMG;if(s===Lo)return a.COMPRESSED_RGB_PVRTC_2BPPV1_IMG;if(s===Do)return a.COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;if(s===Io)return a.COMPRESSED_RGBA_PVRTC_2BPPV1_IMG}else return null;if(s===Ac)return a=t.get("WEBGL_compressed_texture_etc1"),a!==null?a.COMPRESSED_RGB_ETC1_WEBGL:null;if(s===Uo||s===No)if(a=t.get("WEBGL_compressed_texture_etc"),a!==null){if(s===Uo)return c===se?a.COMPRESSED_SRGB8_ETC2:a.COMPRESSED_RGB8_ETC2;if(s===No)return c===se?a.COMPRESSED_SRGB8_ALPHA8_ETC2_EAC:a.COMPRESSED_RGBA8_ETC2_EAC}else return null;if(s===Oo||s===Fo||s===Bo||s===zo||s===Go||s===ko||s===Ho||s===Vo||s===Xo||s===Wo||s===qo||s===Yo||s===jo||s===$o)if(a=t.get("WEBGL_compressed_texture_astc"),a!==null){if(s===Oo)return c===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_4x4_KHR:a.COMPRESSED_RGBA_ASTC_4x4_KHR;if(s===Fo)return c===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_5x4_KHR:a.COMPRESSED_RGBA_ASTC_5x4_KHR;if(s===Bo)return c===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_5x5_KHR:a.COMPRESSED_RGBA_ASTC_5x5_KHR;if(s===zo)return c===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_6x5_KHR:a.COMPRESSED_RGBA_ASTC_6x5_KHR;if(s===Go)return c===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_6x6_KHR:a.COMPRESSED_RGBA_ASTC_6x6_KHR;if(s===ko)return c===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_8x5_KHR:a.COMPRESSED_RGBA_ASTC_8x5_KHR;if(s===Ho)return c===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_8x6_KHR:a.COMPRESSED_RGBA_ASTC_8x6_KHR;if(s===Vo)return c===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_8x8_KHR:a.COMPRESSED_RGBA_ASTC_8x8_KHR;if(s===Xo)return c===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_10x5_KHR:a.COMPRESSED_RGBA_ASTC_10x5_KHR;if(s===Wo)return c===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_10x6_KHR:a.COMPRESSED_RGBA_ASTC_10x6_KHR;if(s===qo)return c===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_10x8_KHR:a.COMPRESSED_RGBA_ASTC_10x8_KHR;if(s===Yo)return c===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_10x10_KHR:a.COMPRESSED_RGBA_ASTC_10x10_KHR;if(s===jo)return c===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_12x10_KHR:a.COMPRESSED_RGBA_ASTC_12x10_KHR;if(s===$o)return c===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_12x12_KHR:a.COMPRESSED_RGBA_ASTC_12x12_KHR}else return null;if(s===ss||s===Ko||s===Zo)if(a=t.get("EXT_texture_compression_bptc"),a!==null){if(s===ss)return c===se?a.COMPRESSED_SRGB_ALPHA_BPTC_UNORM_EXT:a.COMPRESSED_RGBA_BPTC_UNORM_EXT;if(s===Ko)return a.COMPRESSED_RGB_BPTC_SIGNED_FLOAT_EXT;if(s===Zo)return a.COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT_EXT}else return null;if(s===eu||s===Jo||s===Qo||s===ta)if(a=t.get("EXT_texture_compression_rgtc"),a!==null){if(s===ss)return a.COMPRESSED_RED_RGTC1_EXT;if(s===Jo)return a.COMPRESSED_SIGNED_RED_RGTC1_EXT;if(s===Qo)return a.COMPRESSED_RED_GREEN_RGTC2_EXT;if(s===ta)return a.COMPRESSED_SIGNED_RED_GREEN_RGTC2_EXT}else return null;return s===zn?n?i.UNSIGNED_INT_24_8:(a=t.get("WEBGL_depth_texture"),a!==null?a.UNSIGNED_INT_24_8_WEBGL:null):i[s]!==void 0?i[s]:null}return{convert:r}}class Tm extends Fe{constructor(t=[]){super(),this.isArrayCamera=!0,this.cameras=t}}class Qt extends ae{constructor(){super(),this.isGroup=!0,this.type="Group"}}const Am={type:"move"};class Rs{constructor(){this._targetRay=null,this._grip=null,this._hand=null}getHandSpace(){return this._hand===null&&(this._hand=new Qt,this._hand.matrixAutoUpdate=!1,this._hand.visible=!1,this._hand.joints={},this._hand.inputState={pinching:!1}),this._hand}getTargetRaySpace(){return this._targetRay===null&&(this._targetRay=new Qt,this._targetRay.matrixAutoUpdate=!1,this._targetRay.visible=!1,this._targetRay.hasLinearVelocity=!1,this._targetRay.linearVelocity=new H,this._targetRay.hasAngularVelocity=!1,this._targetRay.angularVelocity=new H),this._targetRay}getGripSpace(){return this._grip===null&&(this._grip=new Qt,this._grip.matrixAutoUpdate=!1,this._grip.visible=!1,this._grip.hasLinearVelocity=!1,this._grip.linearVelocity=new H,this._grip.hasAngularVelocity=!1,this._grip.angularVelocity=new H),this._grip}dispatchEvent(t){return this._targetRay!==null&&this._targetRay.dispatchEvent(t),this._grip!==null&&this._grip.dispatchEvent(t),this._hand!==null&&this._hand.dispatchEvent(t),this}connect(t){if(t&&t.hand){const e=this._hand;if(e)for(const n of t.hand.values())this._getHandJoint(e,n)}return this.dispatchEvent({type:"connected",data:t}),this}disconnect(t){return this.dispatchEvent({type:"disconnected",data:t}),this._targetRay!==null&&(this._targetRay.visible=!1),this._grip!==null&&(this._grip.visible=!1),this._hand!==null&&(this._hand.visible=!1),this}update(t,e,n){let r=null,s=null,o=null;const a=this._targetRay,c=this._grip,l=this._hand;if(t&&e.session.visibilityState!=="visible-blurred"){if(l&&t.hand){o=!0;for(const x of t.hand.values()){const d=e.getJointPose(x,n),u=this._getHandJoint(l,x);d!==null&&(u.matrix.fromArray(d.transform.matrix),u.matrix.decompose(u.position,u.rotation,u.scale),u.matrixWorldNeedsUpdate=!0,u.jointRadius=d.radius),u.visible=d!==null}const h=l.joints["index-finger-tip"],f=l.joints["thumb-tip"],m=h.position.distanceTo(f.position),p=.02,_=.005;l.inputState.pinching&&m>p+_?(l.inputState.pinching=!1,this.dispatchEvent({type:"pinchend",handedness:t.handedness,target:this})):!l.inputState.pinching&&m<=p-_&&(l.inputState.pinching=!0,this.dispatchEvent({type:"pinchstart",handedness:t.handedness,target:this}))}else c!==null&&t.gripSpace&&(s=e.getPose(t.gripSpace,n),s!==null&&(c.matrix.fromArray(s.transform.matrix),c.matrix.decompose(c.position,c.rotation,c.scale),c.matrixWorldNeedsUpdate=!0,s.linearVelocity?(c.hasLinearVelocity=!0,c.linearVelocity.copy(s.linearVelocity)):c.hasLinearVelocity=!1,s.angularVelocity?(c.hasAngularVelocity=!0,c.angularVelocity.copy(s.angularVelocity)):c.hasAngularVelocity=!1));a!==null&&(r=e.getPose(t.targetRaySpace,n),r===null&&s!==null&&(r=s),r!==null&&(a.matrix.fromArray(r.transform.matrix),a.matrix.decompose(a.position,a.rotation,a.scale),a.matrixWorldNeedsUpdate=!0,r.linearVelocity?(a.hasLinearVelocity=!0,a.linearVelocity.copy(r.linearVelocity)):a.hasLinearVelocity=!1,r.angularVelocity?(a.hasAngularVelocity=!0,a.angularVelocity.copy(r.angularVelocity)):a.hasAngularVelocity=!1,this.dispatchEvent(Am)))}return a!==null&&(a.visible=r!==null),c!==null&&(c.visible=s!==null),l!==null&&(l.visible=o!==null),this}_getHandJoint(t,e){if(t.joints[e.jointName]===void 0){const n=new Qt;n.matrixAutoUpdate=!1,n.visible=!1,t.joints[e.jointName]=n,t.add(n)}return t.joints[e.jointName]}}class Rm extends Vn{constructor(t,e){super();const n=this;let r=null,s=1,o=null,a="local-floor",c=1,l=null,h=null,f=null,m=null,p=null,_=null;const x=e.getContextAttributes();let d=null,u=null;const M=[],g=[],y=new At;let L=null;const C=new Fe;C.layers.enable(1),C.viewport=new oe;const D=new Fe;D.layers.enable(2),D.viewport=new oe;const F=[C,D],T=new Tm;T.layers.enable(1),T.layers.enable(2);let E=null,j=null;this.cameraAutoUpdate=!0,this.enabled=!1,this.isPresenting=!1,this.getController=function(Z){let nt=M[Z];return nt===void 0&&(nt=new Rs,M[Z]=nt),nt.getTargetRaySpace()},this.getControllerGrip=function(Z){let nt=M[Z];return nt===void 0&&(nt=new Rs,M[Z]=nt),nt.getGripSpace()},this.getHand=function(Z){let nt=M[Z];return nt===void 0&&(nt=new Rs,M[Z]=nt),nt.getHandSpace()};function O(Z){const nt=g.indexOf(Z.inputSource);if(nt===-1)return;const ht=M[nt];ht!==void 0&&(ht.update(Z.inputSource,Z.frame,l||o),ht.dispatchEvent({type:Z.type,data:Z.inputSource}))}function B(){r.removeEventListener("select",O),r.removeEventListener("selectstart",O),r.removeEventListener("selectend",O),r.removeEventListener("squeeze",O),r.removeEventListener("squeezestart",O),r.removeEventListener("squeezeend",O),r.removeEventListener("end",B),r.removeEventListener("inputsourceschange",S);for(let Z=0;Z<M.length;Z++){const nt=g[Z];nt!==null&&(g[Z]=null,M[Z].disconnect(nt))}E=null,j=null,t.setRenderTarget(d),p=null,m=null,f=null,r=null,u=null,Y.stop(),n.isPresenting=!1,t.setPixelRatio(L),t.setSize(y.width,y.height,!1),n.dispatchEvent({type:"sessionend"})}this.setFramebufferScaleFactor=function(Z){s=Z,n.isPresenting===!0&&console.warn("THREE.WebXRManager: Cannot change framebuffer scale while presenting.")},this.setReferenceSpaceType=function(Z){a=Z,n.isPresenting===!0&&console.warn("THREE.WebXRManager: Cannot change reference space type while presenting.")},this.getReferenceSpace=function(){return l||o},this.setReferenceSpace=function(Z){l=Z},this.getBaseLayer=function(){return m!==null?m:p},this.getBinding=function(){return f},this.getFrame=function(){return _},this.getSession=function(){return r},this.setSession=async function(Z){if(r=Z,r!==null){if(d=t.getRenderTarget(),r.addEventListener("select",O),r.addEventListener("selectstart",O),r.addEventListener("selectend",O),r.addEventListener("squeeze",O),r.addEventListener("squeezestart",O),r.addEventListener("squeezeend",O),r.addEventListener("end",B),r.addEventListener("inputsourceschange",S),x.xrCompatible!==!0&&await e.makeXRCompatible(),L=t.getPixelRatio(),t.getSize(y),r.renderState.layers===void 0||t.capabilities.isWebGL2===!1){const nt={antialias:r.renderState.layers===void 0?x.antialias:!0,alpha:!0,depth:x.depth,stencil:x.stencil,framebufferScaleFactor:s};p=new XRWebGLLayer(r,e,nt),r.updateRenderState({baseLayer:p}),t.setPixelRatio(1),t.setSize(p.framebufferWidth,p.framebufferHeight,!1),u=new Ke(p.framebufferWidth,p.framebufferHeight,{format:je,type:Tn,colorSpace:t.outputColorSpace,stencilBuffer:x.stencil})}else{let nt=null,ht=null,gt=null;x.depth&&(gt=x.stencil?e.DEPTH24_STENCIL8:e.DEPTH_COMPONENT24,nt=x.stencil?Ei:Gn,ht=x.stencil?zn:bn);const xt={colorFormat:e.RGBA8,depthFormat:gt,scaleFactor:s};f=new XRWebGLBinding(r,e),m=f.createProjectionLayer(xt),r.updateRenderState({layers:[m]}),t.setPixelRatio(1),t.setSize(m.textureWidth,m.textureHeight,!1),u=new Ke(m.textureWidth,m.textureHeight,{format:je,type:Tn,depthTexture:new Vc(m.textureWidth,m.textureHeight,ht,void 0,void 0,void 0,void 0,void 0,void 0,nt),stencilBuffer:x.stencil,colorSpace:t.outputColorSpace,samples:x.antialias?4:0});const Et=t.properties.get(u);Et.__ignoreDepthValues=m.ignoreDepthValues}u.isXRRenderTarget=!0,this.setFoveation(c),l=null,o=await r.requestReferenceSpace(a),Y.setContext(r),Y.start(),n.isPresenting=!0,n.dispatchEvent({type:"sessionstart"})}},this.getEnvironmentBlendMode=function(){if(r!==null)return r.environmentBlendMode};function S(Z){for(let nt=0;nt<Z.removed.length;nt++){const ht=Z.removed[nt],gt=g.indexOf(ht);gt>=0&&(g[gt]=null,M[gt].disconnect(ht))}for(let nt=0;nt<Z.added.length;nt++){const ht=Z.added[nt];let gt=g.indexOf(ht);if(gt===-1){for(let Et=0;Et<M.length;Et++)if(Et>=g.length){g.push(ht),gt=Et;break}else if(g[Et]===null){g[Et]=ht,gt=Et;break}if(gt===-1)break}const xt=M[gt];xt&&xt.connect(ht)}}const b=new H,v=new H;function A(Z,nt,ht){b.setFromMatrixPosition(nt.matrixWorld),v.setFromMatrixPosition(ht.matrixWorld);const gt=b.distanceTo(v),xt=nt.projectionMatrix.elements,Et=ht.projectionMatrix.elements,ct=xt[14]/(xt[10]-1),ut=xt[14]/(xt[10]+1),Mt=(xt[9]+1)/xt[5],k=(xt[9]-1)/xt[5],tt=(xt[8]-1)/xt[0],G=(Et[8]+1)/Et[0],X=ct*tt,W=ct*G,et=gt/(-tt+G),it=et*-tt;nt.matrixWorld.decompose(Z.position,Z.quaternion,Z.scale),Z.translateX(it),Z.translateZ(et),Z.matrixWorld.compose(Z.position,Z.quaternion,Z.scale),Z.matrixWorldInverse.copy(Z.matrixWorld).invert();const R=ct+et,w=ut+et,$=X-it,st=W+(gt-it),J=Mt*ut/w*R,q=k*ut/w*R;Z.projectionMatrix.makePerspective($,st,J,q,R,w),Z.projectionMatrixInverse.copy(Z.projectionMatrix).invert()}function I(Z,nt){nt===null?Z.matrixWorld.copy(Z.matrix):Z.matrixWorld.multiplyMatrices(nt.matrixWorld,Z.matrix),Z.matrixWorldInverse.copy(Z.matrixWorld).invert()}this.updateCamera=function(Z){if(r===null)return;T.near=D.near=C.near=Z.near,T.far=D.far=C.far=Z.far,(E!==T.near||j!==T.far)&&(r.updateRenderState({depthNear:T.near,depthFar:T.far}),E=T.near,j=T.far);const nt=Z.parent,ht=T.cameras;I(T,nt);for(let gt=0;gt<ht.length;gt++)I(ht[gt],nt);ht.length===2?A(T,C,D):T.projectionMatrix.copy(C.projectionMatrix),U(Z,T,nt)};function U(Z,nt,ht){ht===null?Z.matrix.copy(nt.matrixWorld):(Z.matrix.copy(ht.matrixWorld),Z.matrix.invert(),Z.matrix.multiply(nt.matrixWorld)),Z.matrix.decompose(Z.position,Z.quaternion,Z.scale),Z.updateMatrixWorld(!0),Z.projectionMatrix.copy(nt.projectionMatrix),Z.projectionMatrixInverse.copy(nt.projectionMatrixInverse),Z.isPerspectiveCamera&&(Z.fov=Yi*2*Math.atan(1/Z.projectionMatrix.elements[5]),Z.zoom=1)}this.getCamera=function(){return T},this.getFoveation=function(){if(!(m===null&&p===null))return c},this.setFoveation=function(Z){c=Z,m!==null&&(m.fixedFoveation=Z),p!==null&&p.fixedFoveation!==void 0&&(p.fixedFoveation=Z)};let P=null;function N(Z,nt){if(h=nt.getViewerPose(l||o),_=nt,h!==null){const ht=h.views;p!==null&&(t.setRenderTargetFramebuffer(u,p.framebuffer),t.setRenderTarget(u));let gt=!1;ht.length!==T.cameras.length&&(T.cameras.length=0,gt=!0);for(let xt=0;xt<ht.length;xt++){const Et=ht[xt];let ct=null;if(p!==null)ct=p.getViewport(Et);else{const Mt=f.getViewSubImage(m,Et);ct=Mt.viewport,xt===0&&(t.setRenderTargetTextures(u,Mt.colorTexture,m.ignoreDepthValues?void 0:Mt.depthStencilTexture),t.setRenderTarget(u))}let ut=F[xt];ut===void 0&&(ut=new Fe,ut.layers.enable(xt),ut.viewport=new oe,F[xt]=ut),ut.matrix.fromArray(Et.transform.matrix),ut.matrix.decompose(ut.position,ut.quaternion,ut.scale),ut.projectionMatrix.fromArray(Et.projectionMatrix),ut.projectionMatrixInverse.copy(ut.projectionMatrix).invert(),ut.viewport.set(ct.x,ct.y,ct.width,ct.height),xt===0&&(T.matrix.copy(ut.matrix),T.matrix.decompose(T.position,T.quaternion,T.scale)),gt===!0&&T.cameras.push(ut)}}for(let ht=0;ht<M.length;ht++){const gt=g[ht],xt=M[ht];gt!==null&&xt!==void 0&&xt.update(gt,nt,l||o)}P&&P(Z,nt),nt.detectedPlanes&&n.dispatchEvent({type:"planesdetected",data:nt}),_=null}const Y=new Hc;Y.setAnimationLoop(N),this.setAnimationLoop=function(Z){P=Z},this.dispose=function(){}}}function Cm(i,t){function e(d,u){d.matrixAutoUpdate===!0&&d.updateMatrix(),u.value.copy(d.matrix)}function n(d,u){u.color.getRGB(d.fogColor.value,zc(i)),u.isFog?(d.fogNear.value=u.near,d.fogFar.value=u.far):u.isFogExp2&&(d.fogDensity.value=u.density)}function r(d,u,M,g,y){u.isMeshBasicMaterial||u.isMeshLambertMaterial?s(d,u):u.isMeshToonMaterial?(s(d,u),f(d,u)):u.isMeshPhongMaterial?(s(d,u),h(d,u)):u.isMeshStandardMaterial?(s(d,u),m(d,u),u.isMeshPhysicalMaterial&&p(d,u,y)):u.isMeshMatcapMaterial?(s(d,u),_(d,u)):u.isMeshDepthMaterial?s(d,u):u.isMeshDistanceMaterial?(s(d,u),x(d,u)):u.isMeshNormalMaterial?s(d,u):u.isLineBasicMaterial?(o(d,u),u.isLineDashedMaterial&&a(d,u)):u.isPointsMaterial?c(d,u,M,g):u.isSpriteMaterial?l(d,u):u.isShadowMaterial?(d.color.value.copy(u.color),d.opacity.value=u.opacity):u.isShaderMaterial&&(u.uniformsNeedUpdate=!1)}function s(d,u){d.opacity.value=u.opacity,u.color&&d.diffuse.value.copy(u.color),u.emissive&&d.emissive.value.copy(u.emissive).multiplyScalar(u.emissiveIntensity),u.map&&(d.map.value=u.map,e(u.map,d.mapTransform)),u.alphaMap&&(d.alphaMap.value=u.alphaMap,e(u.alphaMap,d.alphaMapTransform)),u.bumpMap&&(d.bumpMap.value=u.bumpMap,e(u.bumpMap,d.bumpMapTransform),d.bumpScale.value=u.bumpScale,u.side===Me&&(d.bumpScale.value*=-1)),u.normalMap&&(d.normalMap.value=u.normalMap,e(u.normalMap,d.normalMapTransform),d.normalScale.value.copy(u.normalScale),u.side===Me&&d.normalScale.value.negate()),u.displacementMap&&(d.displacementMap.value=u.displacementMap,e(u.displacementMap,d.displacementMapTransform),d.displacementScale.value=u.displacementScale,d.displacementBias.value=u.displacementBias),u.emissiveMap&&(d.emissiveMap.value=u.emissiveMap,e(u.emissiveMap,d.emissiveMapTransform)),u.specularMap&&(d.specularMap.value=u.specularMap,e(u.specularMap,d.specularMapTransform)),u.alphaTest>0&&(d.alphaTest.value=u.alphaTest);const M=t.get(u).envMap;if(M&&(d.envMap.value=M,d.flipEnvMap.value=M.isCubeTexture&&M.isRenderTargetTexture===!1?-1:1,d.reflectivity.value=u.reflectivity,d.ior.value=u.ior,d.refractionRatio.value=u.refractionRatio),u.lightMap){d.lightMap.value=u.lightMap;const g=i._useLegacyLights===!0?Math.PI:1;d.lightMapIntensity.value=u.lightMapIntensity*g,e(u.lightMap,d.lightMapTransform)}u.aoMap&&(d.aoMap.value=u.aoMap,d.aoMapIntensity.value=u.aoMapIntensity,e(u.aoMap,d.aoMapTransform))}function o(d,u){d.diffuse.value.copy(u.color),d.opacity.value=u.opacity,u.map&&(d.map.value=u.map,e(u.map,d.mapTransform))}function a(d,u){d.dashSize.value=u.dashSize,d.totalSize.value=u.dashSize+u.gapSize,d.scale.value=u.scale}function c(d,u,M,g){d.diffuse.value.copy(u.color),d.opacity.value=u.opacity,d.size.value=u.size*M,d.scale.value=g*.5,u.map&&(d.map.value=u.map,e(u.map,d.uvTransform)),u.alphaMap&&(d.alphaMap.value=u.alphaMap,e(u.alphaMap,d.alphaMapTransform)),u.alphaTest>0&&(d.alphaTest.value=u.alphaTest)}function l(d,u){d.diffuse.value.copy(u.color),d.opacity.value=u.opacity,d.rotation.value=u.rotation,u.map&&(d.map.value=u.map,e(u.map,d.mapTransform)),u.alphaMap&&(d.alphaMap.value=u.alphaMap,e(u.alphaMap,d.alphaMapTransform)),u.alphaTest>0&&(d.alphaTest.value=u.alphaTest)}function h(d,u){d.specular.value.copy(u.specular),d.shininess.value=Math.max(u.shininess,1e-4)}function f(d,u){u.gradientMap&&(d.gradientMap.value=u.gradientMap)}function m(d,u){d.metalness.value=u.metalness,u.metalnessMap&&(d.metalnessMap.value=u.metalnessMap,e(u.metalnessMap,d.metalnessMapTransform)),d.roughness.value=u.roughness,u.roughnessMap&&(d.roughnessMap.value=u.roughnessMap,e(u.roughnessMap,d.roughnessMapTransform)),t.get(u).envMap&&(d.envMapIntensity.value=u.envMapIntensity)}function p(d,u,M){d.ior.value=u.ior,u.sheen>0&&(d.sheenColor.value.copy(u.sheenColor).multiplyScalar(u.sheen),d.sheenRoughness.value=u.sheenRoughness,u.sheenColorMap&&(d.sheenColorMap.value=u.sheenColorMap,e(u.sheenColorMap,d.sheenColorMapTransform)),u.sheenRoughnessMap&&(d.sheenRoughnessMap.value=u.sheenRoughnessMap,e(u.sheenRoughnessMap,d.sheenRoughnessMapTransform))),u.clearcoat>0&&(d.clearcoat.value=u.clearcoat,d.clearcoatRoughness.value=u.clearcoatRoughness,u.clearcoatMap&&(d.clearcoatMap.value=u.clearcoatMap,e(u.clearcoatMap,d.clearcoatMapTransform)),u.clearcoatRoughnessMap&&(d.clearcoatRoughnessMap.value=u.clearcoatRoughnessMap,e(u.clearcoatRoughnessMap,d.clearcoatRoughnessMapTransform)),u.clearcoatNormalMap&&(d.clearcoatNormalMap.value=u.clearcoatNormalMap,e(u.clearcoatNormalMap,d.clearcoatNormalMapTransform),d.clearcoatNormalScale.value.copy(u.clearcoatNormalScale),u.side===Me&&d.clearcoatNormalScale.value.negate())),u.iridescence>0&&(d.iridescence.value=u.iridescence,d.iridescenceIOR.value=u.iridescenceIOR,d.iridescenceThicknessMinimum.value=u.iridescenceThicknessRange[0],d.iridescenceThicknessMaximum.value=u.iridescenceThicknessRange[1],u.iridescenceMap&&(d.iridescenceMap.value=u.iridescenceMap,e(u.iridescenceMap,d.iridescenceMapTransform)),u.iridescenceThicknessMap&&(d.iridescenceThicknessMap.value=u.iridescenceThicknessMap,e(u.iridescenceThicknessMap,d.iridescenceThicknessMapTransform))),u.transmission>0&&(d.transmission.value=u.transmission,d.transmissionSamplerMap.value=M.texture,d.transmissionSamplerSize.value.set(M.width,M.height),u.transmissionMap&&(d.transmissionMap.value=u.transmissionMap,e(u.transmissionMap,d.transmissionMapTransform)),d.thickness.value=u.thickness,u.thicknessMap&&(d.thicknessMap.value=u.thicknessMap,e(u.thicknessMap,d.thicknessMapTransform)),d.attenuationDistance.value=u.attenuationDistance,d.attenuationColor.value.copy(u.attenuationColor)),u.anisotropy>0&&(d.anisotropyVector.value.set(u.anisotropy*Math.cos(u.anisotropyRotation),u.anisotropy*Math.sin(u.anisotropyRotation)),u.anisotropyMap&&(d.anisotropyMap.value=u.anisotropyMap,e(u.anisotropyMap,d.anisotropyMapTransform))),d.specularIntensity.value=u.specularIntensity,d.specularColor.value.copy(u.specularColor),u.specularColorMap&&(d.specularColorMap.value=u.specularColorMap,e(u.specularColorMap,d.specularColorMapTransform)),u.specularIntensityMap&&(d.specularIntensityMap.value=u.specularIntensityMap,e(u.specularIntensityMap,d.specularIntensityMapTransform))}function _(d,u){u.matcap&&(d.matcap.value=u.matcap)}function x(d,u){const M=t.get(u).light;d.referencePosition.value.setFromMatrixPosition(M.matrixWorld),d.nearDistance.value=M.shadow.camera.near,d.farDistance.value=M.shadow.camera.far}return{refreshFogUniforms:n,refreshMaterialUniforms:r}}function Pm(i,t,e,n){let r={},s={},o=[];const a=e.isWebGL2?i.getParameter(i.MAX_UNIFORM_BUFFER_BINDINGS):0;function c(M,g){const y=g.program;n.uniformBlockBinding(M,y)}function l(M,g){let y=r[M.id];y===void 0&&(_(M),y=h(M),r[M.id]=y,M.addEventListener("dispose",d));const L=g.program;n.updateUBOMapping(M,L);const C=t.render.frame;s[M.id]!==C&&(m(M),s[M.id]=C)}function h(M){const g=f();M.__bindingPointIndex=g;const y=i.createBuffer(),L=M.__size,C=M.usage;return i.bindBuffer(i.UNIFORM_BUFFER,y),i.bufferData(i.UNIFORM_BUFFER,L,C),i.bindBuffer(i.UNIFORM_BUFFER,null),i.bindBufferBase(i.UNIFORM_BUFFER,g,y),y}function f(){for(let M=0;M<a;M++)if(o.indexOf(M)===-1)return o.push(M),M;return console.error("THREE.WebGLRenderer: Maximum number of simultaneously usable uniforms groups reached."),0}function m(M){const g=r[M.id],y=M.uniforms,L=M.__cache;i.bindBuffer(i.UNIFORM_BUFFER,g);for(let C=0,D=y.length;C<D;C++){const F=Array.isArray(y[C])?y[C]:[y[C]];for(let T=0,E=F.length;T<E;T++){const j=F[T];if(p(j,C,T,L)===!0){const O=j.__offset,B=Array.isArray(j.value)?j.value:[j.value];let S=0;for(let b=0;b<B.length;b++){const v=B[b],A=x(v);typeof v=="number"||typeof v=="boolean"?(j.__data[0]=v,i.bufferSubData(i.UNIFORM_BUFFER,O+S,j.__data)):v.isMatrix3?(j.__data[0]=v.elements[0],j.__data[1]=v.elements[1],j.__data[2]=v.elements[2],j.__data[3]=0,j.__data[4]=v.elements[3],j.__data[5]=v.elements[4],j.__data[6]=v.elements[5],j.__data[7]=0,j.__data[8]=v.elements[6],j.__data[9]=v.elements[7],j.__data[10]=v.elements[8],j.__data[11]=0):(v.toArray(j.__data,S),S+=A.storage/Float32Array.BYTES_PER_ELEMENT)}i.bufferSubData(i.UNIFORM_BUFFER,O,j.__data)}}}i.bindBuffer(i.UNIFORM_BUFFER,null)}function p(M,g,y,L){const C=M.value,D=g+"_"+y;if(L[D]===void 0)return typeof C=="number"||typeof C=="boolean"?L[D]=C:L[D]=C.clone(),!0;{const F=L[D];if(typeof C=="number"||typeof C=="boolean"){if(F!==C)return L[D]=C,!0}else if(F.equals(C)===!1)return F.copy(C),!0}return!1}function _(M){const g=M.uniforms;let y=0;const L=16;for(let D=0,F=g.length;D<F;D++){const T=Array.isArray(g[D])?g[D]:[g[D]];for(let E=0,j=T.length;E<j;E++){const O=T[E],B=Array.isArray(O.value)?O.value:[O.value];for(let S=0,b=B.length;S<b;S++){const v=B[S],A=x(v),I=y%L;I!==0&&L-I<A.boundary&&(y+=L-I),O.__data=new Float32Array(A.storage/Float32Array.BYTES_PER_ELEMENT),O.__offset=y,y+=A.storage}}}const C=y%L;return C>0&&(y+=L-C),M.__size=y,M.__cache={},this}function x(M){const g={boundary:0,storage:0};return typeof M=="number"||typeof M=="boolean"?(g.boundary=4,g.storage=4):M.isVector2?(g.boundary=8,g.storage=8):M.isVector3||M.isColor?(g.boundary=16,g.storage=12):M.isVector4?(g.boundary=16,g.storage=16):M.isMatrix3?(g.boundary=48,g.storage=48):M.isMatrix4?(g.boundary=64,g.storage=64):M.isTexture?console.warn("THREE.WebGLRenderer: Texture samplers can not be part of an uniforms group."):console.warn("THREE.WebGLRenderer: Unsupported uniform value type.",M),g}function d(M){const g=M.target;g.removeEventListener("dispose",d);const y=o.indexOf(g.__bindingPointIndex);o.splice(y,1),i.deleteBuffer(r[g.id]),delete r[g.id],delete s[g.id]}function u(){for(const M in r)i.deleteBuffer(r[M]);o=[],r={},s={}}return{bind:c,update:l,dispose:u}}class $c{constructor(t={}){const{canvas:e=Tu(),context:n=null,depth:r=!0,stencil:s=!0,alpha:o=!1,antialias:a=!1,premultipliedAlpha:c=!0,preserveDrawingBuffer:l=!1,powerPreference:h="default",failIfMajorPerformanceCaveat:f=!1}=t;this.isWebGLRenderer=!0;let m;n!==null?m=n.getContextAttributes().alpha:m=o;const p=new Uint32Array(4),_=new Int32Array(4);let x=null,d=null;const u=[],M=[];this.domElement=e,this.debug={checkShaderErrors:!0,onShaderError:null},this.autoClear=!0,this.autoClearColor=!0,this.autoClearDepth=!0,this.autoClearStencil=!0,this.sortObjects=!0,this.clippingPlanes=[],this.localClippingEnabled=!1,this._outputColorSpace=he,this._useLegacyLights=!1,this.toneMapping=wn,this.toneMappingExposure=1;const g=this;let y=!1,L=0,C=0,D=null,F=-1,T=null;const E=new oe,j=new oe;let O=null;const B=new Dt(0);let S=0,b=e.width,v=e.height,A=1,I=null,U=null;const P=new oe(0,0,b,v),N=new oe(0,0,b,v);let Y=!1;const Z=new so;let nt=!1,ht=!1,gt=null;const xt=new ee,Et=new At,ct=new H,ut={background:null,fog:null,environment:null,overrideMaterial:null,isScene:!0};function Mt(){return D===null?A:1}let k=n;function tt(z,ot){for(let ft=0;ft<z.length;ft++){const mt=z[ft],dt=e.getContext(mt,ot);if(dt!==null)return dt}return null}try{const z={alpha:!0,depth:r,stencil:s,antialias:a,premultipliedAlpha:c,preserveDrawingBuffer:l,powerPreference:h,failIfMajorPerformanceCaveat:f};if("setAttribute"in e&&e.setAttribute("data-engine",`three.js r${Qs}`),e.addEventListener("webglcontextlost",_t,!1),e.addEventListener("webglcontextrestored",K,!1),e.addEventListener("webglcontextcreationerror",vt,!1),k===null){const ot=["webgl2","webgl","experimental-webgl"];if(g.isWebGL1Renderer===!0&&ot.shift(),k=tt(ot,z),k===null)throw tt(ot)?new Error("Error creating WebGL context with your selected attributes."):new Error("Error creating WebGL context.")}typeof WebGLRenderingContext<"u"&&k instanceof WebGLRenderingContext&&console.warn("THREE.WebGLRenderer: WebGL 1 support was deprecated in r153 and will be removed in r163."),k.getShaderPrecisionFormat===void 0&&(k.getShaderPrecisionFormat=function(){return{rangeMin:1,rangeMax:1,precision:1}})}catch(z){throw console.error("THREE.WebGLRenderer: "+z.message),z}let G,X,W,et,it,R,w,$,st,J,q,Q,rt,at,yt,Tt,lt,Rt,V,pt,wt,St,Pt,Ft;function Ht(){G=new Gf(k),X=new Uf(k,G,t),G.init(X),St=new wm(k,G,X),W=new bm(k,G,X),et=new Vf(k),it=new lm,R=new Em(k,G,W,it,X,St,et),w=new Of(g),$=new zf(g),st=new Ku(k,X),Pt=new Df(k,G,st,X),J=new kf(k,st,et,Pt),q=new Yf(k,J,st,et),V=new qf(k,X,R),Tt=new Nf(it),Q=new cm(g,w,$,G,X,Pt,Tt),rt=new Cm(g,it),at=new hm,yt=new _m(G,X),Rt=new Lf(g,w,$,W,q,m,c),lt=new Sm(g,q,X),Ft=new Pm(k,et,X,W),pt=new If(k,G,et,X),wt=new Hf(k,G,et,X),et.programs=Q.programs,g.capabilities=X,g.extensions=G,g.properties=it,g.renderLists=at,g.shadowMap=lt,g.state=W,g.info=et}Ht();const Gt=new Rm(g,k);this.xr=Gt,this.getContext=function(){return k},this.getContextAttributes=function(){return k.getContextAttributes()},this.forceContextLoss=function(){const z=G.get("WEBGL_lose_context");z&&z.loseContext()},this.forceContextRestore=function(){const z=G.get("WEBGL_lose_context");z&&z.restoreContext()},this.getPixelRatio=function(){return A},this.setPixelRatio=function(z){z!==void 0&&(A=z,this.setSize(b,v,!1))},this.getSize=function(z){return z.set(b,v)},this.setSize=function(z,ot,ft=!0){if(Gt.isPresenting){console.warn("THREE.WebGLRenderer: Can't change size while VR device is presenting.");return}b=z,v=ot,e.width=Math.floor(z*A),e.height=Math.floor(ot*A),ft===!0&&(e.style.width=z+"px",e.style.height=ot+"px"),this.setViewport(0,0,z,ot)},this.getDrawingBufferSize=function(z){return z.set(b*A,v*A).floor()},this.setDrawingBufferSize=function(z,ot,ft){b=z,v=ot,A=ft,e.width=Math.floor(z*ft),e.height=Math.floor(ot*ft),this.setViewport(0,0,z,ot)},this.getCurrentViewport=function(z){return z.copy(E)},this.getViewport=function(z){return z.copy(P)},this.setViewport=function(z,ot,ft,mt){z.isVector4?P.set(z.x,z.y,z.z,z.w):P.set(z,ot,ft,mt),W.viewport(E.copy(P).multiplyScalar(A).floor())},this.getScissor=function(z){return z.copy(N)},this.setScissor=function(z,ot,ft,mt){z.isVector4?N.set(z.x,z.y,z.z,z.w):N.set(z,ot,ft,mt),W.scissor(j.copy(N).multiplyScalar(A).floor())},this.getScissorTest=function(){return Y},this.setScissorTest=function(z){W.setScissorTest(Y=z)},this.setOpaqueSort=function(z){I=z},this.setTransparentSort=function(z){U=z},this.getClearColor=function(z){return z.copy(Rt.getClearColor())},this.setClearColor=function(){Rt.setClearColor.apply(Rt,arguments)},this.getClearAlpha=function(){return Rt.getClearAlpha()},this.setClearAlpha=function(){Rt.setClearAlpha.apply(Rt,arguments)},this.clear=function(z=!0,ot=!0,ft=!0){let mt=0;if(z){let dt=!1;if(D!==null){const Lt=D.texture.format;dt=Lt===Tc||Lt===wc||Lt===Ec}if(dt){const Lt=D.texture.type,Ot=Lt===Tn||Lt===bn||Lt===eo||Lt===zn||Lt===Sc||Lt===bc,zt=Rt.getClearColor(),kt=Rt.getClearAlpha(),jt=zt.r,Vt=zt.g,Wt=zt.b;Ot?(p[0]=jt,p[1]=Vt,p[2]=Wt,p[3]=kt,k.clearBufferuiv(k.COLOR,0,p)):(_[0]=jt,_[1]=Vt,_[2]=Wt,_[3]=kt,k.clearBufferiv(k.COLOR,0,_))}else mt|=k.COLOR_BUFFER_BIT}ot&&(mt|=k.DEPTH_BUFFER_BIT),ft&&(mt|=k.STENCIL_BUFFER_BIT,this.state.buffers.stencil.setMask(4294967295)),k.clear(mt)},this.clearColor=function(){this.clear(!0,!1,!1)},this.clearDepth=function(){this.clear(!1,!0,!1)},this.clearStencil=function(){this.clear(!1,!1,!0)},this.dispose=function(){e.removeEventListener("webglcontextlost",_t,!1),e.removeEventListener("webglcontextrestored",K,!1),e.removeEventListener("webglcontextcreationerror",vt,!1),at.dispose(),yt.dispose(),it.dispose(),w.dispose(),$.dispose(),q.dispose(),Pt.dispose(),Ft.dispose(),Q.dispose(),Gt.dispose(),Gt.removeEventListener("sessionstart",Ae),Gt.removeEventListener("sessionend",re),gt&&(gt.dispose(),gt=null),Re.stop()};function _t(z){z.preventDefault(),console.log("THREE.WebGLRenderer: Context Lost."),y=!0}function K(){console.log("THREE.WebGLRenderer: Context Restored."),y=!1;const z=et.autoReset,ot=lt.enabled,ft=lt.autoUpdate,mt=lt.needsUpdate,dt=lt.type;Ht(),et.autoReset=z,lt.enabled=ot,lt.autoUpdate=ft,lt.needsUpdate=mt,lt.type=dt}function vt(z){console.error("THREE.WebGLRenderer: A WebGL context could not be created. Reason: ",z.statusMessage)}function bt(z){const ot=z.target;ot.removeEventListener("dispose",bt),Ut(ot)}function Ut(z){It(z),it.remove(z)}function It(z){const ot=it.get(z).programs;ot!==void 0&&(ot.forEach(function(ft){Q.releaseProgram(ft)}),z.isShaderMaterial&&Q.releaseShaderCache(z))}this.renderBufferDirect=function(z,ot,ft,mt,dt,Lt){ot===null&&(ot=ut);const Ot=dt.isMesh&&dt.matrixWorld.determinant()<0,zt=fl(z,ot,ft,mt,dt);W.setMaterial(mt,Ot);let kt=ft.index,jt=1;if(mt.wireframe===!0){if(kt=J.getWireframeAttribute(ft),kt===void 0)return;jt=2}const Vt=ft.drawRange,Wt=ft.attributes.position;let fe=Vt.start*jt,Ie=(Vt.start+Vt.count)*jt;Lt!==null&&(fe=Math.max(fe,Lt.start*jt),Ie=Math.min(Ie,(Lt.start+Lt.count)*jt)),kt!==null?(fe=Math.max(fe,0),Ie=Math.min(Ie,kt.count)):Wt!=null&&(fe=Math.max(fe,0),Ie=Math.min(Ie,Wt.count));const _e=Ie-fe;if(_e<0||_e===1/0)return;Pt.setup(dt,mt,zt,ft,kt);let nn,ce=pt;if(kt!==null&&(nn=st.get(kt),ce=wt,ce.setIndex(nn)),dt.isMesh)mt.wireframe===!0?(W.setLineWidth(mt.wireframeLinewidth*Mt()),ce.setMode(k.LINES)):ce.setMode(k.TRIANGLES);else if(dt.isLine){let $t=mt.linewidth;$t===void 0&&($t=1),W.setLineWidth($t*Mt()),dt.isLineSegments?ce.setMode(k.LINES):dt.isLineLoop?ce.setMode(k.LINE_LOOP):ce.setMode(k.LINE_STRIP)}else dt.isPoints?ce.setMode(k.POINTS):dt.isSprite&&ce.setMode(k.TRIANGLES);if(dt.isBatchedMesh)ce.renderMultiDraw(dt._multiDrawStarts,dt._multiDrawCounts,dt._multiDrawCount);else if(dt.isInstancedMesh)ce.renderInstances(fe,_e,dt.count);else if(ft.isInstancedBufferGeometry){const $t=ft._maxInstanceCount!==void 0?ft._maxInstanceCount:1/0,Kr=Math.min(ft.instanceCount,$t);ce.renderInstances(fe,_e,Kr)}else ce.render(fe,_e)};function Xt(z,ot,ft){z.transparent===!0&&z.side===Ee&&z.forceSinglePass===!1?(z.side=Me,z.needsUpdate=!0,Qi(z,ot,ft),z.side=pn,z.needsUpdate=!0,Qi(z,ot,ft),z.side=Ee):Qi(z,ot,ft)}this.compile=function(z,ot,ft=null){ft===null&&(ft=z),d=yt.get(ft),d.init(),M.push(d),ft.traverseVisible(function(dt){dt.isLight&&dt.layers.test(ot.layers)&&(d.pushLight(dt),dt.castShadow&&d.pushShadow(dt))}),z!==ft&&z.traverseVisible(function(dt){dt.isLight&&dt.layers.test(ot.layers)&&(d.pushLight(dt),dt.castShadow&&d.pushShadow(dt))}),d.setupLights(g._useLegacyLights);const mt=new Set;return z.traverse(function(dt){const Lt=dt.material;if(Lt)if(Array.isArray(Lt))for(let Ot=0;Ot<Lt.length;Ot++){const zt=Lt[Ot];Xt(zt,ft,dt),mt.add(zt)}else Xt(Lt,ft,dt),mt.add(Lt)}),M.pop(),d=null,mt},this.compileAsync=function(z,ot,ft=null){const mt=this.compile(z,ot,ft);return new Promise(dt=>{function Lt(){if(mt.forEach(function(Ot){it.get(Ot).currentProgram.isReady()&&mt.delete(Ot)}),mt.size===0){dt(z);return}setTimeout(Lt,10)}G.get("KHR_parallel_shader_compile")!==null?Lt():setTimeout(Lt,10)})};let Zt=null;function de(z){Zt&&Zt(z)}function Ae(){Re.stop()}function re(){Re.start()}const Re=new Hc;Re.setAnimationLoop(de),typeof self<"u"&&Re.setContext(self),this.setAnimationLoop=function(z){Zt=z,Gt.setAnimationLoop(z),z===null?Re.stop():Re.start()},Gt.addEventListener("sessionstart",Ae),Gt.addEventListener("sessionend",re),this.render=function(z,ot){if(ot!==void 0&&ot.isCamera!==!0){console.error("THREE.WebGLRenderer.render: camera is not an instance of THREE.Camera.");return}if(y===!0)return;z.matrixWorldAutoUpdate===!0&&z.updateMatrixWorld(),ot.parent===null&&ot.matrixWorldAutoUpdate===!0&&ot.updateMatrixWorld(),Gt.enabled===!0&&Gt.isPresenting===!0&&(Gt.cameraAutoUpdate===!0&&Gt.updateCamera(ot),ot=Gt.getCamera()),z.isScene===!0&&z.onBeforeRender(g,z,ot,D),d=yt.get(z,M.length),d.init(),M.push(d),xt.multiplyMatrices(ot.projectionMatrix,ot.matrixWorldInverse),Z.setFromProjectionMatrix(xt),ht=this.localClippingEnabled,nt=Tt.init(this.clippingPlanes,ht),x=at.get(z,u.length),x.init(),u.push(x),Je(z,ot,0,g.sortObjects),x.finish(),g.sortObjects===!0&&x.sort(I,U),this.info.render.frame++,nt===!0&&Tt.beginShadows();const ft=d.state.shadowsArray;if(lt.render(ft,z,ot),nt===!0&&Tt.endShadows(),this.info.autoReset===!0&&this.info.reset(),Rt.render(x,z),d.setupLights(g._useLegacyLights),ot.isArrayCamera){const mt=ot.cameras;for(let dt=0,Lt=mt.length;dt<Lt;dt++){const Ot=mt[dt];_o(x,z,Ot,Ot.viewport)}}else _o(x,z,ot);D!==null&&(R.updateMultisampleRenderTarget(D),R.updateRenderTargetMipmap(D)),z.isScene===!0&&z.onAfterRender(g,z,ot),Pt.resetDefaultState(),F=-1,T=null,M.pop(),M.length>0?d=M[M.length-1]:d=null,u.pop(),u.length>0?x=u[u.length-1]:x=null};function Je(z,ot,ft,mt){if(z.visible===!1)return;if(z.layers.test(ot.layers)){if(z.isGroup)ft=z.renderOrder;else if(z.isLOD)z.autoUpdate===!0&&z.update(ot);else if(z.isLight)d.pushLight(z),z.castShadow&&d.pushShadow(z);else if(z.isSprite){if(!z.frustumCulled||Z.intersectsSprite(z)){mt&&ct.setFromMatrixPosition(z.matrixWorld).applyMatrix4(xt);const Ot=q.update(z),zt=z.material;zt.visible&&x.push(z,Ot,zt,ft,ct.z,null)}}else if((z.isMesh||z.isLine||z.isPoints)&&(!z.frustumCulled||Z.intersectsObject(z))){const Ot=q.update(z),zt=z.material;if(mt&&(z.boundingSphere!==void 0?(z.boundingSphere===null&&z.computeBoundingSphere(),ct.copy(z.boundingSphere.center)):(Ot.boundingSphere===null&&Ot.computeBoundingSphere(),ct.copy(Ot.boundingSphere.center)),ct.applyMatrix4(z.matrixWorld).applyMatrix4(xt)),Array.isArray(zt)){const kt=Ot.groups;for(let jt=0,Vt=kt.length;jt<Vt;jt++){const Wt=kt[jt],fe=zt[Wt.materialIndex];fe&&fe.visible&&x.push(z,Ot,fe,ft,ct.z,Wt)}}else zt.visible&&x.push(z,Ot,zt,ft,ct.z,null)}}const Lt=z.children;for(let Ot=0,zt=Lt.length;Ot<zt;Ot++)Je(Lt[Ot],ot,ft,mt)}function _o(z,ot,ft,mt){const dt=z.opaque,Lt=z.transmissive,Ot=z.transparent;d.setupLightsView(ft),nt===!0&&Tt.setGlobalState(g.clippingPlanes,ft),Lt.length>0&&dl(dt,Lt,ot,ft),mt&&W.viewport(E.copy(mt)),dt.length>0&&Ji(dt,ot,ft),Lt.length>0&&Ji(Lt,ot,ft),Ot.length>0&&Ji(Ot,ot,ft),W.buffers.depth.setTest(!0),W.buffers.depth.setMask(!0),W.buffers.color.setMask(!0),W.setPolygonOffset(!1)}function dl(z,ot,ft,mt){if((ft.isScene===!0?ft.overrideMaterial:null)!==null)return;const Lt=X.isWebGL2;gt===null&&(gt=new Ke(1,1,{generateMipmaps:!0,type:G.has("EXT_color_buffer_half_float")?dn:Tn,minFilter:qi,samples:Lt?4:0})),g.getDrawingBufferSize(Et),Lt?gt.setSize(Et.x,Et.y):gt.setSize(Gr(Et.x),Gr(Et.y));const Ot=g.getRenderTarget();g.setRenderTarget(gt),g.getClearColor(B),S=g.getClearAlpha(),S<1&&g.setClearColor(16777215,.5),g.clear();const zt=g.toneMapping;g.toneMapping=wn,Ji(z,ft,mt),R.updateMultisampleRenderTarget(gt),R.updateRenderTargetMipmap(gt);let kt=!1;for(let jt=0,Vt=ot.length;jt<Vt;jt++){const Wt=ot[jt],fe=Wt.object,Ie=Wt.geometry,_e=Wt.material,nn=Wt.group;if(_e.side===Ee&&fe.layers.test(mt.layers)){const ce=_e.side;_e.side=Me,_e.needsUpdate=!0,vo(fe,ft,mt,Ie,_e,nn),_e.side=ce,_e.needsUpdate=!0,kt=!0}}kt===!0&&(R.updateMultisampleRenderTarget(gt),R.updateRenderTargetMipmap(gt)),g.setRenderTarget(Ot),g.setClearColor(B,S),g.toneMapping=zt}function Ji(z,ot,ft){const mt=ot.isScene===!0?ot.overrideMaterial:null;for(let dt=0,Lt=z.length;dt<Lt;dt++){const Ot=z[dt],zt=Ot.object,kt=Ot.geometry,jt=mt===null?Ot.material:mt,Vt=Ot.group;zt.layers.test(ft.layers)&&vo(zt,ot,ft,kt,jt,Vt)}}function vo(z,ot,ft,mt,dt,Lt){z.onBeforeRender(g,ot,ft,mt,dt,Lt),z.modelViewMatrix.multiplyMatrices(ft.matrixWorldInverse,z.matrixWorld),z.normalMatrix.getNormalMatrix(z.modelViewMatrix),dt.onBeforeRender(g,ot,ft,mt,z,Lt),dt.transparent===!0&&dt.side===Ee&&dt.forceSinglePass===!1?(dt.side=Me,dt.needsUpdate=!0,g.renderBufferDirect(ft,ot,mt,dt,z,Lt),dt.side=pn,dt.needsUpdate=!0,g.renderBufferDirect(ft,ot,mt,dt,z,Lt),dt.side=Ee):g.renderBufferDirect(ft,ot,mt,dt,z,Lt),z.onAfterRender(g,ot,ft,mt,dt,Lt)}function Qi(z,ot,ft){ot.isScene!==!0&&(ot=ut);const mt=it.get(z),dt=d.state.lights,Lt=d.state.shadowsArray,Ot=dt.state.version,zt=Q.getParameters(z,dt.state,Lt,ot,ft),kt=Q.getProgramCacheKey(zt);let jt=mt.programs;mt.environment=z.isMeshStandardMaterial?ot.environment:null,mt.fog=ot.fog,mt.envMap=(z.isMeshStandardMaterial?$:w).get(z.envMap||mt.environment),jt===void 0&&(z.addEventListener("dispose",bt),jt=new Map,mt.programs=jt);let Vt=jt.get(kt);if(Vt!==void 0){if(mt.currentProgram===Vt&&mt.lightsStateVersion===Ot)return Mo(z,zt),Vt}else zt.uniforms=Q.getUniforms(z),z.onBuild(ft,zt,g),z.onBeforeCompile(zt,g),Vt=Q.acquireProgram(zt,kt),jt.set(kt,Vt),mt.uniforms=zt.uniforms;const Wt=mt.uniforms;return(!z.isShaderMaterial&&!z.isRawShaderMaterial||z.clipping===!0)&&(Wt.clippingPlanes=Tt.uniform),Mo(z,zt),mt.needsLights=ml(z),mt.lightsStateVersion=Ot,mt.needsLights&&(Wt.ambientLightColor.value=dt.state.ambient,Wt.lightProbe.value=dt.state.probe,Wt.directionalLights.value=dt.state.directional,Wt.directionalLightShadows.value=dt.state.directionalShadow,Wt.spotLights.value=dt.state.spot,Wt.spotLightShadows.value=dt.state.spotShadow,Wt.rectAreaLights.value=dt.state.rectArea,Wt.ltc_1.value=dt.state.rectAreaLTC1,Wt.ltc_2.value=dt.state.rectAreaLTC2,Wt.pointLights.value=dt.state.point,Wt.pointLightShadows.value=dt.state.pointShadow,Wt.hemisphereLights.value=dt.state.hemi,Wt.directionalShadowMap.value=dt.state.directionalShadowMap,Wt.directionalShadowMatrix.value=dt.state.directionalShadowMatrix,Wt.spotShadowMap.value=dt.state.spotShadowMap,Wt.spotLightMatrix.value=dt.state.spotLightMatrix,Wt.spotLightMap.value=dt.state.spotLightMap,Wt.pointShadowMap.value=dt.state.pointShadowMap,Wt.pointShadowMatrix.value=dt.state.pointShadowMatrix),mt.currentProgram=Vt,mt.uniformsList=null,Vt}function xo(z){if(z.uniformsList===null){const ot=z.currentProgram.getUniforms();z.uniformsList=Dr.seqWithValue(ot.seq,z.uniforms)}return z.uniformsList}function Mo(z,ot){const ft=it.get(z);ft.outputColorSpace=ot.outputColorSpace,ft.batching=ot.batching,ft.instancing=ot.instancing,ft.instancingColor=ot.instancingColor,ft.skinning=ot.skinning,ft.morphTargets=ot.morphTargets,ft.morphNormals=ot.morphNormals,ft.morphColors=ot.morphColors,ft.morphTargetsCount=ot.morphTargetsCount,ft.numClippingPlanes=ot.numClippingPlanes,ft.numIntersection=ot.numClipIntersection,ft.vertexAlphas=ot.vertexAlphas,ft.vertexTangents=ot.vertexTangents,ft.toneMapping=ot.toneMapping}function fl(z,ot,ft,mt,dt){ot.isScene!==!0&&(ot=ut),R.resetTextureUnits();const Lt=ot.fog,Ot=mt.isMeshStandardMaterial?ot.environment:null,zt=D===null?g.outputColorSpace:D.isXRRenderTarget===!0?D.texture.colorSpace:mn,kt=(mt.isMeshStandardMaterial?$:w).get(mt.envMap||Ot),jt=mt.vertexColors===!0&&!!ft.attributes.color&&ft.attributes.color.itemSize===4,Vt=!!ft.attributes.tangent&&(!!mt.normalMap||mt.anisotropy>0),Wt=!!ft.morphAttributes.position,fe=!!ft.morphAttributes.normal,Ie=!!ft.morphAttributes.color;let _e=wn;mt.toneMapped&&(D===null||D.isXRRenderTarget===!0)&&(_e=g.toneMapping);const nn=ft.morphAttributes.position||ft.morphAttributes.normal||ft.morphAttributes.color,ce=nn!==void 0?nn.length:0,$t=it.get(mt),Kr=d.state.lights;if(nt===!0&&(ht===!0||z!==T)){const Ge=z===T&&mt.id===F;Tt.setState(mt,z,Ge)}let ue=!1;mt.version===$t.__version?($t.needsLights&&$t.lightsStateVersion!==Kr.state.version||$t.outputColorSpace!==zt||dt.isBatchedMesh&&$t.batching===!1||!dt.isBatchedMesh&&$t.batching===!0||dt.isInstancedMesh&&$t.instancing===!1||!dt.isInstancedMesh&&$t.instancing===!0||dt.isSkinnedMesh&&$t.skinning===!1||!dt.isSkinnedMesh&&$t.skinning===!0||dt.isInstancedMesh&&$t.instancingColor===!0&&dt.instanceColor===null||dt.isInstancedMesh&&$t.instancingColor===!1&&dt.instanceColor!==null||$t.envMap!==kt||mt.fog===!0&&$t.fog!==Lt||$t.numClippingPlanes!==void 0&&($t.numClippingPlanes!==Tt.numPlanes||$t.numIntersection!==Tt.numIntersection)||$t.vertexAlphas!==jt||$t.vertexTangents!==Vt||$t.morphTargets!==Wt||$t.morphNormals!==fe||$t.morphColors!==Ie||$t.toneMapping!==_e||X.isWebGL2===!0&&$t.morphTargetsCount!==ce)&&(ue=!0):(ue=!0,$t.__version=mt.version);let Cn=$t.currentProgram;ue===!0&&(Cn=Qi(mt,ot,dt));let yo=!1,Pi=!1,Zr=!1;const ye=Cn.getUniforms(),Pn=$t.uniforms;if(W.useProgram(Cn.program)&&(yo=!0,Pi=!0,Zr=!0),mt.id!==F&&(F=mt.id,Pi=!0),yo||T!==z){ye.setValue(k,"projectionMatrix",z.projectionMatrix),ye.setValue(k,"viewMatrix",z.matrixWorldInverse);const Ge=ye.map.cameraPosition;Ge!==void 0&&Ge.setValue(k,ct.setFromMatrixPosition(z.matrixWorld)),X.logarithmicDepthBuffer&&ye.setValue(k,"logDepthBufFC",2/(Math.log(z.far+1)/Math.LN2)),(mt.isMeshPhongMaterial||mt.isMeshToonMaterial||mt.isMeshLambertMaterial||mt.isMeshBasicMaterial||mt.isMeshStandardMaterial||mt.isShaderMaterial)&&ye.setValue(k,"isOrthographic",z.isOrthographicCamera===!0),T!==z&&(T=z,Pi=!0,Zr=!0)}if(dt.isSkinnedMesh){ye.setOptional(k,dt,"bindMatrix"),ye.setOptional(k,dt,"bindMatrixInverse");const Ge=dt.skeleton;Ge&&(X.floatVertexTextures?(Ge.boneTexture===null&&Ge.computeBoneTexture(),ye.setValue(k,"boneTexture",Ge.boneTexture,R)):console.warn("THREE.WebGLRenderer: SkinnedMesh can only be used with WebGL 2. With WebGL 1 OES_texture_float and vertex textures support is required."))}dt.isBatchedMesh&&(ye.setOptional(k,dt,"batchingTexture"),ye.setValue(k,"batchingTexture",dt._matricesTexture,R));const Jr=ft.morphAttributes;if((Jr.position!==void 0||Jr.normal!==void 0||Jr.color!==void 0&&X.isWebGL2===!0)&&V.update(dt,ft,Cn),(Pi||$t.receiveShadow!==dt.receiveShadow)&&($t.receiveShadow=dt.receiveShadow,ye.setValue(k,"receiveShadow",dt.receiveShadow)),mt.isMeshGouraudMaterial&&mt.envMap!==null&&(Pn.envMap.value=kt,Pn.flipEnvMap.value=kt.isCubeTexture&&kt.isRenderTargetTexture===!1?-1:1),Pi&&(ye.setValue(k,"toneMappingExposure",g.toneMappingExposure),$t.needsLights&&pl(Pn,Zr),Lt&&mt.fog===!0&&rt.refreshFogUniforms(Pn,Lt),rt.refreshMaterialUniforms(Pn,mt,A,v,gt),Dr.upload(k,xo($t),Pn,R)),mt.isShaderMaterial&&mt.uniformsNeedUpdate===!0&&(Dr.upload(k,xo($t),Pn,R),mt.uniformsNeedUpdate=!1),mt.isSpriteMaterial&&ye.setValue(k,"center",dt.center),ye.setValue(k,"modelViewMatrix",dt.modelViewMatrix),ye.setValue(k,"normalMatrix",dt.normalMatrix),ye.setValue(k,"modelMatrix",dt.matrixWorld),mt.isShaderMaterial||mt.isRawShaderMaterial){const Ge=mt.uniformsGroups;for(let Qr=0,gl=Ge.length;Qr<gl;Qr++)if(X.isWebGL2){const So=Ge[Qr];Ft.update(So,Cn),Ft.bind(So,Cn)}else console.warn("THREE.WebGLRenderer: Uniform Buffer Objects can only be used with WebGL 2.")}return Cn}function pl(z,ot){z.ambientLightColor.needsUpdate=ot,z.lightProbe.needsUpdate=ot,z.directionalLights.needsUpdate=ot,z.directionalLightShadows.needsUpdate=ot,z.pointLights.needsUpdate=ot,z.pointLightShadows.needsUpdate=ot,z.spotLights.needsUpdate=ot,z.spotLightShadows.needsUpdate=ot,z.rectAreaLights.needsUpdate=ot,z.hemisphereLights.needsUpdate=ot}function ml(z){return z.isMeshLambertMaterial||z.isMeshToonMaterial||z.isMeshPhongMaterial||z.isMeshStandardMaterial||z.isShadowMaterial||z.isShaderMaterial&&z.lights===!0}this.getActiveCubeFace=function(){return L},this.getActiveMipmapLevel=function(){return C},this.getRenderTarget=function(){return D},this.setRenderTargetTextures=function(z,ot,ft){it.get(z.texture).__webglTexture=ot,it.get(z.depthTexture).__webglTexture=ft;const mt=it.get(z);mt.__hasExternalTextures=!0,mt.__hasExternalTextures&&(mt.__autoAllocateDepthBuffer=ft===void 0,mt.__autoAllocateDepthBuffer||G.has("WEBGL_multisampled_render_to_texture")===!0&&(console.warn("THREE.WebGLRenderer: Render-to-texture extension was disabled because an external texture was provided"),mt.__useRenderToTexture=!1))},this.setRenderTargetFramebuffer=function(z,ot){const ft=it.get(z);ft.__webglFramebuffer=ot,ft.__useDefaultFramebuffer=ot===void 0},this.setRenderTarget=function(z,ot=0,ft=0){D=z,L=ot,C=ft;let mt=!0,dt=null,Lt=!1,Ot=!1;if(z){const kt=it.get(z);kt.__useDefaultFramebuffer!==void 0?(W.bindFramebuffer(k.FRAMEBUFFER,null),mt=!1):kt.__webglFramebuffer===void 0?R.setupRenderTarget(z):kt.__hasExternalTextures&&R.rebindTextures(z,it.get(z.texture).__webglTexture,it.get(z.depthTexture).__webglTexture);const jt=z.texture;(jt.isData3DTexture||jt.isDataArrayTexture||jt.isCompressedArrayTexture)&&(Ot=!0);const Vt=it.get(z).__webglFramebuffer;z.isWebGLCubeRenderTarget?(Array.isArray(Vt[ot])?dt=Vt[ot][ft]:dt=Vt[ot],Lt=!0):X.isWebGL2&&z.samples>0&&R.useMultisampledRTT(z)===!1?dt=it.get(z).__webglMultisampledFramebuffer:Array.isArray(Vt)?dt=Vt[ft]:dt=Vt,E.copy(z.viewport),j.copy(z.scissor),O=z.scissorTest}else E.copy(P).multiplyScalar(A).floor(),j.copy(N).multiplyScalar(A).floor(),O=Y;if(W.bindFramebuffer(k.FRAMEBUFFER,dt)&&X.drawBuffers&&mt&&W.drawBuffers(z,dt),W.viewport(E),W.scissor(j),W.setScissorTest(O),Lt){const kt=it.get(z.texture);k.framebufferTexture2D(k.FRAMEBUFFER,k.COLOR_ATTACHMENT0,k.TEXTURE_CUBE_MAP_POSITIVE_X+ot,kt.__webglTexture,ft)}else if(Ot){const kt=it.get(z.texture),jt=ot||0;k.framebufferTextureLayer(k.FRAMEBUFFER,k.COLOR_ATTACHMENT0,kt.__webglTexture,ft||0,jt)}F=-1},this.readRenderTargetPixels=function(z,ot,ft,mt,dt,Lt,Ot){if(!(z&&z.isWebGLRenderTarget)){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not THREE.WebGLRenderTarget.");return}let zt=it.get(z).__webglFramebuffer;if(z.isWebGLCubeRenderTarget&&Ot!==void 0&&(zt=zt[Ot]),zt){W.bindFramebuffer(k.FRAMEBUFFER,zt);try{const kt=z.texture,jt=kt.format,Vt=kt.type;if(jt!==je&&St.convert(jt)!==k.getParameter(k.IMPLEMENTATION_COLOR_READ_FORMAT)){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not in RGBA or implementation defined format.");return}const Wt=Vt===dn&&(G.has("EXT_color_buffer_half_float")||X.isWebGL2&&G.has("EXT_color_buffer_float"));if(Vt!==Tn&&St.convert(Vt)!==k.getParameter(k.IMPLEMENTATION_COLOR_READ_TYPE)&&!(Vt===En&&(X.isWebGL2||G.has("OES_texture_float")||G.has("WEBGL_color_buffer_float")))&&!Wt){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not in UnsignedByteType or implementation defined type.");return}ot>=0&&ot<=z.width-mt&&ft>=0&&ft<=z.height-dt&&k.readPixels(ot,ft,mt,dt,St.convert(jt),St.convert(Vt),Lt)}finally{const kt=D!==null?it.get(D).__webglFramebuffer:null;W.bindFramebuffer(k.FRAMEBUFFER,kt)}}},this.copyFramebufferToTexture=function(z,ot,ft=0){const mt=Math.pow(2,-ft),dt=Math.floor(ot.image.width*mt),Lt=Math.floor(ot.image.height*mt);R.setTexture2D(ot,0),k.copyTexSubImage2D(k.TEXTURE_2D,ft,0,0,z.x,z.y,dt,Lt),W.unbindTexture()},this.copyTextureToTexture=function(z,ot,ft,mt=0){const dt=ot.image.width,Lt=ot.image.height,Ot=St.convert(ft.format),zt=St.convert(ft.type);R.setTexture2D(ft,0),k.pixelStorei(k.UNPACK_FLIP_Y_WEBGL,ft.flipY),k.pixelStorei(k.UNPACK_PREMULTIPLY_ALPHA_WEBGL,ft.premultiplyAlpha),k.pixelStorei(k.UNPACK_ALIGNMENT,ft.unpackAlignment),ot.isDataTexture?k.texSubImage2D(k.TEXTURE_2D,mt,z.x,z.y,dt,Lt,Ot,zt,ot.image.data):ot.isCompressedTexture?k.compressedTexSubImage2D(k.TEXTURE_2D,mt,z.x,z.y,ot.mipmaps[0].width,ot.mipmaps[0].height,Ot,ot.mipmaps[0].data):k.texSubImage2D(k.TEXTURE_2D,mt,z.x,z.y,Ot,zt,ot.image),mt===0&&ft.generateMipmaps&&k.generateMipmap(k.TEXTURE_2D),W.unbindTexture()},this.copyTextureToTexture3D=function(z,ot,ft,mt,dt=0){if(g.isWebGL1Renderer){console.warn("THREE.WebGLRenderer.copyTextureToTexture3D: can only be used with WebGL2.");return}const Lt=z.max.x-z.min.x+1,Ot=z.max.y-z.min.y+1,zt=z.max.z-z.min.z+1,kt=St.convert(mt.format),jt=St.convert(mt.type);let Vt;if(mt.isData3DTexture)R.setTexture3D(mt,0),Vt=k.TEXTURE_3D;else if(mt.isDataArrayTexture||mt.isCompressedArrayTexture)R.setTexture2DArray(mt,0),Vt=k.TEXTURE_2D_ARRAY;else{console.warn("THREE.WebGLRenderer.copyTextureToTexture3D: only supports THREE.DataTexture3D and THREE.DataTexture2DArray.");return}k.pixelStorei(k.UNPACK_FLIP_Y_WEBGL,mt.flipY),k.pixelStorei(k.UNPACK_PREMULTIPLY_ALPHA_WEBGL,mt.premultiplyAlpha),k.pixelStorei(k.UNPACK_ALIGNMENT,mt.unpackAlignment);const Wt=k.getParameter(k.UNPACK_ROW_LENGTH),fe=k.getParameter(k.UNPACK_IMAGE_HEIGHT),Ie=k.getParameter(k.UNPACK_SKIP_PIXELS),_e=k.getParameter(k.UNPACK_SKIP_ROWS),nn=k.getParameter(k.UNPACK_SKIP_IMAGES),ce=ft.isCompressedTexture?ft.mipmaps[dt]:ft.image;k.pixelStorei(k.UNPACK_ROW_LENGTH,ce.width),k.pixelStorei(k.UNPACK_IMAGE_HEIGHT,ce.height),k.pixelStorei(k.UNPACK_SKIP_PIXELS,z.min.x),k.pixelStorei(k.UNPACK_SKIP_ROWS,z.min.y),k.pixelStorei(k.UNPACK_SKIP_IMAGES,z.min.z),ft.isDataTexture||ft.isData3DTexture?k.texSubImage3D(Vt,dt,ot.x,ot.y,ot.z,Lt,Ot,zt,kt,jt,ce.data):ft.isCompressedArrayTexture?(console.warn("THREE.WebGLRenderer.copyTextureToTexture3D: untested support for compressed srcTexture."),k.compressedTexSubImage3D(Vt,dt,ot.x,ot.y,ot.z,Lt,Ot,zt,kt,ce.data)):k.texSubImage3D(Vt,dt,ot.x,ot.y,ot.z,Lt,Ot,zt,kt,jt,ce),k.pixelStorei(k.UNPACK_ROW_LENGTH,Wt),k.pixelStorei(k.UNPACK_IMAGE_HEIGHT,fe),k.pixelStorei(k.UNPACK_SKIP_PIXELS,Ie),k.pixelStorei(k.UNPACK_SKIP_ROWS,_e),k.pixelStorei(k.UNPACK_SKIP_IMAGES,nn),dt===0&&mt.generateMipmaps&&k.generateMipmap(Vt),W.unbindTexture()},this.initTexture=function(z){z.isCubeTexture?R.setTextureCube(z,0):z.isData3DTexture?R.setTexture3D(z,0):z.isDataArrayTexture||z.isCompressedArrayTexture?R.setTexture2DArray(z,0):R.setTexture2D(z,0),W.unbindTexture()},this.resetState=function(){L=0,C=0,D=null,W.reset(),Pt.reset()},typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("observe",{detail:this}))}get coordinateSystem(){return un}get outputColorSpace(){return this._outputColorSpace}set outputColorSpace(t){this._outputColorSpace=t;const e=this.getContext();e.drawingBufferColorSpace=t===no?"display-p3":"srgb",e.unpackColorSpace=te.workingColorSpace===Wr?"display-p3":"srgb"}get outputEncoding(){return console.warn("THREE.WebGLRenderer: Property .outputEncoding has been removed. Use .outputColorSpace instead."),this.outputColorSpace===he?kn:Rc}set outputEncoding(t){console.warn("THREE.WebGLRenderer: Property .outputEncoding has been removed. Use .outputColorSpace instead."),this.outputColorSpace=t===kn?he:mn}get useLegacyLights(){return console.warn("THREE.WebGLRenderer: The property .useLegacyLights has been deprecated. Migrate your lighting according to the following guide: https://discourse.threejs.org/t/updates-to-lighting-in-three-js-r155/53733."),this._useLegacyLights}set useLegacyLights(t){console.warn("THREE.WebGLRenderer: The property .useLegacyLights has been deprecated. Migrate your lighting according to the following guide: https://discourse.threejs.org/t/updates-to-lighting-in-three-js-r155/53733."),this._useLegacyLights=t}}class Lm extends $c{}Lm.prototype.isWebGL1Renderer=!0;class co{constructor(t,e=1,n=1e3){this.isFog=!0,this.name="",this.color=new Dt(t),this.near=e,this.far=n}clone(){return new co(this.color,this.near,this.far)}toJSON(){return{type:"Fog",name:this.name,color:this.color.getHex(),near:this.near,far:this.far}}}class Kc extends ae{constructor(){super(),this.isScene=!0,this.type="Scene",this.background=null,this.environment=null,this.fog=null,this.backgroundBlurriness=0,this.backgroundIntensity=1,this.overrideMaterial=null,typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("observe",{detail:this}))}copy(t,e){return super.copy(t,e),t.background!==null&&(this.background=t.background.clone()),t.environment!==null&&(this.environment=t.environment.clone()),t.fog!==null&&(this.fog=t.fog.clone()),this.backgroundBlurriness=t.backgroundBlurriness,this.backgroundIntensity=t.backgroundIntensity,t.overrideMaterial!==null&&(this.overrideMaterial=t.overrideMaterial.clone()),this.matrixAutoUpdate=t.matrixAutoUpdate,this}toJSON(t){const e=super.toJSON(t);return this.fog!==null&&(e.object.fog=this.fog.toJSON()),this.backgroundBlurriness>0&&(e.object.backgroundBlurriness=this.backgroundBlurriness),this.backgroundIntensity!==1&&(e.object.backgroundIntensity=this.backgroundIntensity),e}}class Dm{constructor(t,e){this.isInterleavedBuffer=!0,this.array=t,this.stride=e,this.count=t!==void 0?t.length/e:0,this.usage=Vs,this._updateRange={offset:0,count:-1},this.updateRanges=[],this.version=0,this.uuid=fn()}onUploadCallback(){}set needsUpdate(t){t===!0&&this.version++}get updateRange(){return console.warn("THREE.InterleavedBuffer: updateRange() is deprecated and will be removed in r169. Use addUpdateRange() instead."),this._updateRange}setUsage(t){return this.usage=t,this}addUpdateRange(t,e){this.updateRanges.push({start:t,count:e})}clearUpdateRanges(){this.updateRanges.length=0}copy(t){return this.array=new t.array.constructor(t.array),this.count=t.count,this.stride=t.stride,this.usage=t.usage,this}copyAt(t,e,n){t*=this.stride,n*=e.stride;for(let r=0,s=this.stride;r<s;r++)this.array[t+r]=e.array[n+r];return this}set(t,e=0){return this.array.set(t,e),this}clone(t){t.arrayBuffers===void 0&&(t.arrayBuffers={}),this.array.buffer._uuid===void 0&&(this.array.buffer._uuid=fn()),t.arrayBuffers[this.array.buffer._uuid]===void 0&&(t.arrayBuffers[this.array.buffer._uuid]=this.array.slice(0).buffer);const e=new this.array.constructor(t.arrayBuffers[this.array.buffer._uuid]),n=new this.constructor(e,this.stride);return n.setUsage(this.usage),n}onUpload(t){return this.onUploadCallback=t,this}toJSON(t){return t.arrayBuffers===void 0&&(t.arrayBuffers={}),this.array.buffer._uuid===void 0&&(this.array.buffer._uuid=fn()),t.arrayBuffers[this.array.buffer._uuid]===void 0&&(t.arrayBuffers[this.array.buffer._uuid]=Array.from(new Uint32Array(this.array.buffer))),{uuid:this.uuid,buffer:this.array.buffer._uuid,type:this.array.constructor.name,stride:this.stride}}}const Ce=new H;class Hr{constructor(t,e,n,r=!1){this.isInterleavedBufferAttribute=!0,this.name="",this.data=t,this.itemSize=e,this.offset=n,this.normalized=r}get count(){return this.data.count}get array(){return this.data.array}set needsUpdate(t){this.data.needsUpdate=t}applyMatrix4(t){for(let e=0,n=this.data.count;e<n;e++)Ce.fromBufferAttribute(this,e),Ce.applyMatrix4(t),this.setXYZ(e,Ce.x,Ce.y,Ce.z);return this}applyNormalMatrix(t){for(let e=0,n=this.count;e<n;e++)Ce.fromBufferAttribute(this,e),Ce.applyNormalMatrix(t),this.setXYZ(e,Ce.x,Ce.y,Ce.z);return this}transformDirection(t){for(let e=0,n=this.count;e<n;e++)Ce.fromBufferAttribute(this,e),Ce.transformDirection(t),this.setXYZ(e,Ce.x,Ce.y,Ce.z);return this}setX(t,e){return this.normalized&&(e=ne(e,this.array)),this.data.array[t*this.data.stride+this.offset]=e,this}setY(t,e){return this.normalized&&(e=ne(e,this.array)),this.data.array[t*this.data.stride+this.offset+1]=e,this}setZ(t,e){return this.normalized&&(e=ne(e,this.array)),this.data.array[t*this.data.stride+this.offset+2]=e,this}setW(t,e){return this.normalized&&(e=ne(e,this.array)),this.data.array[t*this.data.stride+this.offset+3]=e,this}getX(t){let e=this.data.array[t*this.data.stride+this.offset];return this.normalized&&(e=tn(e,this.array)),e}getY(t){let e=this.data.array[t*this.data.stride+this.offset+1];return this.normalized&&(e=tn(e,this.array)),e}getZ(t){let e=this.data.array[t*this.data.stride+this.offset+2];return this.normalized&&(e=tn(e,this.array)),e}getW(t){let e=this.data.array[t*this.data.stride+this.offset+3];return this.normalized&&(e=tn(e,this.array)),e}setXY(t,e,n){return t=t*this.data.stride+this.offset,this.normalized&&(e=ne(e,this.array),n=ne(n,this.array)),this.data.array[t+0]=e,this.data.array[t+1]=n,this}setXYZ(t,e,n,r){return t=t*this.data.stride+this.offset,this.normalized&&(e=ne(e,this.array),n=ne(n,this.array),r=ne(r,this.array)),this.data.array[t+0]=e,this.data.array[t+1]=n,this.data.array[t+2]=r,this}setXYZW(t,e,n,r,s){return t=t*this.data.stride+this.offset,this.normalized&&(e=ne(e,this.array),n=ne(n,this.array),r=ne(r,this.array),s=ne(s,this.array)),this.data.array[t+0]=e,this.data.array[t+1]=n,this.data.array[t+2]=r,this.data.array[t+3]=s,this}clone(t){if(t===void 0){console.log("THREE.InterleavedBufferAttribute.clone(): Cloning an interleaved buffer attribute will de-interleave buffer data.");const e=[];for(let n=0;n<this.count;n++){const r=n*this.data.stride+this.offset;for(let s=0;s<this.itemSize;s++)e.push(this.data.array[r+s])}return new le(new this.array.constructor(e),this.itemSize,this.normalized)}else return t.interleavedBuffers===void 0&&(t.interleavedBuffers={}),t.interleavedBuffers[this.data.uuid]===void 0&&(t.interleavedBuffers[this.data.uuid]=this.data.clone(t)),new Hr(t.interleavedBuffers[this.data.uuid],this.itemSize,this.offset,this.normalized)}toJSON(t){if(t===void 0){console.log("THREE.InterleavedBufferAttribute.toJSON(): Serializing an interleaved buffer attribute will de-interleave buffer data.");const e=[];for(let n=0;n<this.count;n++){const r=n*this.data.stride+this.offset;for(let s=0;s<this.itemSize;s++)e.push(this.data.array[r+s])}return{itemSize:this.itemSize,type:this.array.constructor.name,array:e,normalized:this.normalized}}else return t.interleavedBuffers===void 0&&(t.interleavedBuffers={}),t.interleavedBuffers[this.data.uuid]===void 0&&(t.interleavedBuffers[this.data.uuid]=this.data.toJSON(t)),{isInterleavedBufferAttribute:!0,itemSize:this.itemSize,data:this.data.uuid,offset:this.offset,normalized:this.normalized}}}class $i extends Rn{constructor(t){super(),this.isSpriteMaterial=!0,this.type="SpriteMaterial",this.color=new Dt(16777215),this.map=null,this.alphaMap=null,this.rotation=0,this.sizeAttenuation=!0,this.transparent=!0,this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.color.copy(t.color),this.map=t.map,this.alphaMap=t.alphaMap,this.rotation=t.rotation,this.sizeAttenuation=t.sizeAttenuation,this.fog=t.fog,this}}let hi;const Ni=new H,di=new H,fi=new H,pi=new At,Oi=new At,Zc=new ee,Sr=new H,Fi=new H,br=new H,ka=new At,Cs=new At,Ha=new At;class Vr extends ae{constructor(t=new $i){if(super(),this.isSprite=!0,this.type="Sprite",hi===void 0){hi=new Jt;const e=new Float32Array([-.5,-.5,0,0,0,.5,-.5,0,1,0,.5,.5,0,1,1,-.5,.5,0,0,1]),n=new Dm(e,5);hi.setIndex([0,1,2,0,2,3]),hi.setAttribute("position",new Hr(n,3,0,!1)),hi.setAttribute("uv",new Hr(n,2,3,!1))}this.geometry=hi,this.material=t,this.center=new At(.5,.5)}raycast(t,e){t.camera===null&&console.error('THREE.Sprite: "Raycaster.camera" needs to be set in order to raycast against sprites.'),di.setFromMatrixScale(this.matrixWorld),Zc.copy(t.camera.matrixWorld),this.modelViewMatrix.multiplyMatrices(t.camera.matrixWorldInverse,this.matrixWorld),fi.setFromMatrixPosition(this.modelViewMatrix),t.camera.isPerspectiveCamera&&this.material.sizeAttenuation===!1&&di.multiplyScalar(-fi.z);const n=this.material.rotation;let r,s;n!==0&&(s=Math.cos(n),r=Math.sin(n));const o=this.center;Er(Sr.set(-.5,-.5,0),fi,o,di,r,s),Er(Fi.set(.5,-.5,0),fi,o,di,r,s),Er(br.set(.5,.5,0),fi,o,di,r,s),ka.set(0,0),Cs.set(1,0),Ha.set(1,1);let a=t.ray.intersectTriangle(Sr,Fi,br,!1,Ni);if(a===null&&(Er(Fi.set(-.5,.5,0),fi,o,di,r,s),Cs.set(0,1),a=t.ray.intersectTriangle(Sr,br,Fi,!1,Ni),a===null))return;const c=t.ray.origin.distanceTo(Ni);c<t.near||c>t.far||e.push({distance:c,point:Ni.clone(),uv:Oe.getInterpolation(Ni,Sr,Fi,br,ka,Cs,Ha,new At),face:null,object:this})}copy(t,e){return super.copy(t,e),t.center!==void 0&&this.center.copy(t.center),this.material=t.material,this}}function Er(i,t,e,n,r,s){pi.subVectors(i,e).addScalar(.5).multiply(n),r!==void 0?(Oi.x=s*pi.x-r*pi.y,Oi.y=r*pi.x+s*pi.y):Oi.copy(pi),i.copy(t),i.x+=Oi.x,i.y+=Oi.y,i.applyMatrix4(Zc)}class Va extends le{constructor(t,e,n,r=1){super(t,e,n),this.isInstancedBufferAttribute=!0,this.meshPerAttribute=r}copy(t){return super.copy(t),this.meshPerAttribute=t.meshPerAttribute,this}toJSON(){const t=super.toJSON();return t.meshPerAttribute=this.meshPerAttribute,t.isInstancedBufferAttribute=!0,t}}const mi=new ee,Xa=new ee,wr=[],Wa=new Xn,Im=new ee,Bi=new Bt,zi=new Wn;class Um extends Bt{constructor(t,e,n){super(t,e),this.isInstancedMesh=!0,this.instanceMatrix=new Va(new Float32Array(n*16),16),this.instanceColor=null,this.count=n,this.boundingBox=null,this.boundingSphere=null;for(let r=0;r<n;r++)this.setMatrixAt(r,Im)}computeBoundingBox(){const t=this.geometry,e=this.count;this.boundingBox===null&&(this.boundingBox=new Xn),t.boundingBox===null&&t.computeBoundingBox(),this.boundingBox.makeEmpty();for(let n=0;n<e;n++)this.getMatrixAt(n,mi),Wa.copy(t.boundingBox).applyMatrix4(mi),this.boundingBox.union(Wa)}computeBoundingSphere(){const t=this.geometry,e=this.count;this.boundingSphere===null&&(this.boundingSphere=new Wn),t.boundingSphere===null&&t.computeBoundingSphere(),this.boundingSphere.makeEmpty();for(let n=0;n<e;n++)this.getMatrixAt(n,mi),zi.copy(t.boundingSphere).applyMatrix4(mi),this.boundingSphere.union(zi)}copy(t,e){return super.copy(t,e),this.instanceMatrix.copy(t.instanceMatrix),t.instanceColor!==null&&(this.instanceColor=t.instanceColor.clone()),this.count=t.count,t.boundingBox!==null&&(this.boundingBox=t.boundingBox.clone()),t.boundingSphere!==null&&(this.boundingSphere=t.boundingSphere.clone()),this}getColorAt(t,e){e.fromArray(this.instanceColor.array,t*3)}getMatrixAt(t,e){e.fromArray(this.instanceMatrix.array,t*16)}raycast(t,e){const n=this.matrixWorld,r=this.count;if(Bi.geometry=this.geometry,Bi.material=this.material,Bi.material!==void 0&&(this.boundingSphere===null&&this.computeBoundingSphere(),zi.copy(this.boundingSphere),zi.applyMatrix4(n),t.ray.intersectsSphere(zi)!==!1))for(let s=0;s<r;s++){this.getMatrixAt(s,mi),Xa.multiplyMatrices(n,mi),Bi.matrixWorld=Xa,Bi.raycast(t,wr);for(let o=0,a=wr.length;o<a;o++){const c=wr[o];c.instanceId=s,c.object=this,e.push(c)}wr.length=0}}setColorAt(t,e){this.instanceColor===null&&(this.instanceColor=new Va(new Float32Array(this.instanceMatrix.count*3),3)),e.toArray(this.instanceColor.array,t*3)}setMatrixAt(t,e){e.toArray(this.instanceMatrix.array,t*16)}updateMorphTargets(){}dispose(){this.dispatchEvent({type:"dispose"})}}class Jc extends Rn{constructor(t){super(),this.isLineBasicMaterial=!0,this.type="LineBasicMaterial",this.color=new Dt(16777215),this.map=null,this.linewidth=1,this.linecap="round",this.linejoin="round",this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.color.copy(t.color),this.map=t.map,this.linewidth=t.linewidth,this.linecap=t.linecap,this.linejoin=t.linejoin,this.fog=t.fog,this}}const qa=new H,Ya=new H,ja=new ee,Ps=new Hn,Tr=new Wn;class Nm extends ae{constructor(t=new Jt,e=new Jc){super(),this.isLine=!0,this.type="Line",this.geometry=t,this.material=e,this.updateMorphTargets()}copy(t,e){return super.copy(t,e),this.material=Array.isArray(t.material)?t.material.slice():t.material,this.geometry=t.geometry,this}computeLineDistances(){const t=this.geometry;if(t.index===null){const e=t.attributes.position,n=[0];for(let r=1,s=e.count;r<s;r++)qa.fromBufferAttribute(e,r-1),Ya.fromBufferAttribute(e,r),n[r]=n[r-1],n[r]+=qa.distanceTo(Ya);t.setAttribute("lineDistance",new Nt(n,1))}else console.warn("THREE.Line.computeLineDistances(): Computation only possible with non-indexed BufferGeometry.");return this}raycast(t,e){const n=this.geometry,r=this.matrixWorld,s=t.params.Line.threshold,o=n.drawRange;if(n.boundingSphere===null&&n.computeBoundingSphere(),Tr.copy(n.boundingSphere),Tr.applyMatrix4(r),Tr.radius+=s,t.ray.intersectsSphere(Tr)===!1)return;ja.copy(r).invert(),Ps.copy(t.ray).applyMatrix4(ja);const a=s/((this.scale.x+this.scale.y+this.scale.z)/3),c=a*a,l=new H,h=new H,f=new H,m=new H,p=this.isLineSegments?2:1,_=n.index,d=n.attributes.position;if(_!==null){const u=Math.max(0,o.start),M=Math.min(_.count,o.start+o.count);for(let g=u,y=M-1;g<y;g+=p){const L=_.getX(g),C=_.getX(g+1);if(l.fromBufferAttribute(d,L),h.fromBufferAttribute(d,C),Ps.distanceSqToSegment(l,h,m,f)>c)continue;m.applyMatrix4(this.matrixWorld);const F=t.ray.origin.distanceTo(m);F<t.near||F>t.far||e.push({distance:F,point:f.clone().applyMatrix4(this.matrixWorld),index:g,face:null,faceIndex:null,object:this})}}else{const u=Math.max(0,o.start),M=Math.min(d.count,o.start+o.count);for(let g=u,y=M-1;g<y;g+=p){if(l.fromBufferAttribute(d,g),h.fromBufferAttribute(d,g+1),Ps.distanceSqToSegment(l,h,m,f)>c)continue;m.applyMatrix4(this.matrixWorld);const C=t.ray.origin.distanceTo(m);C<t.near||C>t.far||e.push({distance:C,point:f.clone().applyMatrix4(this.matrixWorld),index:g,face:null,faceIndex:null,object:this})}}}updateMorphTargets(){const e=this.geometry.morphAttributes,n=Object.keys(e);if(n.length>0){const r=e[n[0]];if(r!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let s=0,o=r.length;s<o;s++){const a=r[s].name||String(s);this.morphTargetInfluences.push(0),this.morphTargetDictionary[a]=s}}}}}const $a=new H,Ka=new H;class Om extends Nm{constructor(t,e){super(t,e),this.isLineSegments=!0,this.type="LineSegments"}computeLineDistances(){const t=this.geometry;if(t.index===null){const e=t.attributes.position,n=[];for(let r=0,s=e.count;r<s;r+=2)$a.fromBufferAttribute(e,r),Ka.fromBufferAttribute(e,r+1),n[r]=r===0?0:n[r-1],n[r+1]=n[r]+$a.distanceTo(Ka);t.setAttribute("lineDistance",new Nt(n,1))}else console.warn("THREE.LineSegments.computeLineDistances(): Computation only possible with non-indexed BufferGeometry.");return this}}class Yr extends Rn{constructor(t){super(),this.isPointsMaterial=!0,this.type="PointsMaterial",this.color=new Dt(16777215),this.map=null,this.alphaMap=null,this.size=1,this.sizeAttenuation=!0,this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.color.copy(t.color),this.map=t.map,this.alphaMap=t.alphaMap,this.size=t.size,this.sizeAttenuation=t.sizeAttenuation,this.fog=t.fog,this}}const Za=new ee,js=new Hn,Ar=new Wn,Rr=new H;class lo extends ae{constructor(t=new Jt,e=new Yr){super(),this.isPoints=!0,this.type="Points",this.geometry=t,this.material=e,this.updateMorphTargets()}copy(t,e){return super.copy(t,e),this.material=Array.isArray(t.material)?t.material.slice():t.material,this.geometry=t.geometry,this}raycast(t,e){const n=this.geometry,r=this.matrixWorld,s=t.params.Points.threshold,o=n.drawRange;if(n.boundingSphere===null&&n.computeBoundingSphere(),Ar.copy(n.boundingSphere),Ar.applyMatrix4(r),Ar.radius+=s,t.ray.intersectsSphere(Ar)===!1)return;Za.copy(r).invert(),js.copy(t.ray).applyMatrix4(Za);const a=s/((this.scale.x+this.scale.y+this.scale.z)/3),c=a*a,l=n.index,f=n.attributes.position;if(l!==null){const m=Math.max(0,o.start),p=Math.min(l.count,o.start+o.count);for(let _=m,x=p;_<x;_++){const d=l.getX(_);Rr.fromBufferAttribute(f,d),Ja(Rr,d,c,r,t,e,this)}}else{const m=Math.max(0,o.start),p=Math.min(f.count,o.start+o.count);for(let _=m,x=p;_<x;_++)Rr.fromBufferAttribute(f,_),Ja(Rr,_,c,r,t,e,this)}}updateMorphTargets(){const e=this.geometry.morphAttributes,n=Object.keys(e);if(n.length>0){const r=e[n[0]];if(r!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let s=0,o=r.length;s<o;s++){const a=r[s].name||String(s);this.morphTargetInfluences.push(0),this.morphTargetDictionary[a]=s}}}}}function Ja(i,t,e,n,r,s,o){const a=js.distanceSqToPoint(i);if(a<e){const c=new H;js.closestPointToPoint(i,c),c.applyMatrix4(n);const l=r.ray.origin.distanceTo(c);if(l<r.near||l>r.far)return;s.push({distance:l,distanceToRay:Math.sqrt(a),point:c,index:t,face:null,object:o})}}class Ze extends Te{constructor(t,e,n,r,s,o,a,c,l){super(t,e,n,r,s,o,a,c,l),this.isCanvasTexture=!0,this.needsUpdate=!0}}class gn{constructor(){this.type="Curve",this.arcLengthDivisions=200}getPoint(){return console.warn("THREE.Curve: .getPoint() not implemented."),null}getPointAt(t,e){const n=this.getUtoTmapping(t);return this.getPoint(n,e)}getPoints(t=5){const e=[];for(let n=0;n<=t;n++)e.push(this.getPoint(n/t));return e}getSpacedPoints(t=5){const e=[];for(let n=0;n<=t;n++)e.push(this.getPointAt(n/t));return e}getLength(){const t=this.getLengths();return t[t.length-1]}getLengths(t=this.arcLengthDivisions){if(this.cacheArcLengths&&this.cacheArcLengths.length===t+1&&!this.needsUpdate)return this.cacheArcLengths;this.needsUpdate=!1;const e=[];let n,r=this.getPoint(0),s=0;e.push(0);for(let o=1;o<=t;o++)n=this.getPoint(o/t),s+=n.distanceTo(r),e.push(s),r=n;return this.cacheArcLengths=e,e}updateArcLengths(){this.needsUpdate=!0,this.getLengths()}getUtoTmapping(t,e){const n=this.getLengths();let r=0;const s=n.length;let o;e?o=e:o=t*n[s-1];let a=0,c=s-1,l;for(;a<=c;)if(r=Math.floor(a+(c-a)/2),l=n[r]-o,l<0)a=r+1;else if(l>0)c=r-1;else{c=r;break}if(r=c,n[r]===o)return r/(s-1);const h=n[r],m=n[r+1]-h,p=(o-h)/m;return(r+p)/(s-1)}getTangent(t,e){let r=t-1e-4,s=t+1e-4;r<0&&(r=0),s>1&&(s=1);const o=this.getPoint(r),a=this.getPoint(s),c=e||(o.isVector2?new At:new H);return c.copy(a).sub(o).normalize(),c}getTangentAt(t,e){const n=this.getUtoTmapping(t);return this.getTangent(n,e)}computeFrenetFrames(t,e){const n=new H,r=[],s=[],o=[],a=new H,c=new ee;for(let p=0;p<=t;p++){const _=p/t;r[p]=this.getTangentAt(_,new H)}s[0]=new H,o[0]=new H;let l=Number.MAX_VALUE;const h=Math.abs(r[0].x),f=Math.abs(r[0].y),m=Math.abs(r[0].z);h<=l&&(l=h,n.set(1,0,0)),f<=l&&(l=f,n.set(0,1,0)),m<=l&&n.set(0,0,1),a.crossVectors(r[0],n).normalize(),s[0].crossVectors(r[0],a),o[0].crossVectors(r[0],s[0]);for(let p=1;p<=t;p++){if(s[p]=s[p-1].clone(),o[p]=o[p-1].clone(),a.crossVectors(r[p-1],r[p]),a.length()>Number.EPSILON){a.normalize();const _=Math.acos(xe(r[p-1].dot(r[p]),-1,1));s[p].applyMatrix4(c.makeRotationAxis(a,_))}o[p].crossVectors(r[p],s[p])}if(e===!0){let p=Math.acos(xe(s[0].dot(s[t]),-1,1));p/=t,r[0].dot(a.crossVectors(s[0],s[t]))>0&&(p=-p);for(let _=1;_<=t;_++)s[_].applyMatrix4(c.makeRotationAxis(r[_],p*_)),o[_].crossVectors(r[_],s[_])}return{tangents:r,normals:s,binormals:o}}clone(){return new this.constructor().copy(this)}copy(t){return this.arcLengthDivisions=t.arcLengthDivisions,this}toJSON(){const t={metadata:{version:4.6,type:"Curve",generator:"Curve.toJSON"}};return t.arcLengthDivisions=this.arcLengthDivisions,t.type=this.type,t}fromJSON(t){return this.arcLengthDivisions=t.arcLengthDivisions,this}}class Qc extends gn{constructor(t=0,e=0,n=1,r=1,s=0,o=Math.PI*2,a=!1,c=0){super(),this.isEllipseCurve=!0,this.type="EllipseCurve",this.aX=t,this.aY=e,this.xRadius=n,this.yRadius=r,this.aStartAngle=s,this.aEndAngle=o,this.aClockwise=a,this.aRotation=c}getPoint(t,e){const n=e||new At,r=Math.PI*2;let s=this.aEndAngle-this.aStartAngle;const o=Math.abs(s)<Number.EPSILON;for(;s<0;)s+=r;for(;s>r;)s-=r;s<Number.EPSILON&&(o?s=0:s=r),this.aClockwise===!0&&!o&&(s===r?s=-r:s=s-r);const a=this.aStartAngle+t*s;let c=this.aX+this.xRadius*Math.cos(a),l=this.aY+this.yRadius*Math.sin(a);if(this.aRotation!==0){const h=Math.cos(this.aRotation),f=Math.sin(this.aRotation),m=c-this.aX,p=l-this.aY;c=m*h-p*f+this.aX,l=m*f+p*h+this.aY}return n.set(c,l)}copy(t){return super.copy(t),this.aX=t.aX,this.aY=t.aY,this.xRadius=t.xRadius,this.yRadius=t.yRadius,this.aStartAngle=t.aStartAngle,this.aEndAngle=t.aEndAngle,this.aClockwise=t.aClockwise,this.aRotation=t.aRotation,this}toJSON(){const t=super.toJSON();return t.aX=this.aX,t.aY=this.aY,t.xRadius=this.xRadius,t.yRadius=this.yRadius,t.aStartAngle=this.aStartAngle,t.aEndAngle=this.aEndAngle,t.aClockwise=this.aClockwise,t.aRotation=this.aRotation,t}fromJSON(t){return super.fromJSON(t),this.aX=t.aX,this.aY=t.aY,this.xRadius=t.xRadius,this.yRadius=t.yRadius,this.aStartAngle=t.aStartAngle,this.aEndAngle=t.aEndAngle,this.aClockwise=t.aClockwise,this.aRotation=t.aRotation,this}}class Fm extends Qc{constructor(t,e,n,r,s,o){super(t,e,n,n,r,s,o),this.isArcCurve=!0,this.type="ArcCurve"}}function uo(){let i=0,t=0,e=0,n=0;function r(s,o,a,c){i=s,t=a,e=-3*s+3*o-2*a-c,n=2*s-2*o+a+c}return{initCatmullRom:function(s,o,a,c,l){r(o,a,l*(a-s),l*(c-o))},initNonuniformCatmullRom:function(s,o,a,c,l,h,f){let m=(o-s)/l-(a-s)/(l+h)+(a-o)/h,p=(a-o)/h-(c-o)/(h+f)+(c-a)/f;m*=h,p*=h,r(o,a,m,p)},calc:function(s){const o=s*s,a=o*s;return i+t*s+e*o+n*a}}}const Cr=new H,Ls=new uo,Ds=new uo,Is=new uo;class en extends gn{constructor(t=[],e=!1,n="centripetal",r=.5){super(),this.isCatmullRomCurve3=!0,this.type="CatmullRomCurve3",this.points=t,this.closed=e,this.curveType=n,this.tension=r}getPoint(t,e=new H){const n=e,r=this.points,s=r.length,o=(s-(this.closed?0:1))*t;let a=Math.floor(o),c=o-a;this.closed?a+=a>0?0:(Math.floor(Math.abs(a)/s)+1)*s:c===0&&a===s-1&&(a=s-2,c=1);let l,h;this.closed||a>0?l=r[(a-1)%s]:(Cr.subVectors(r[0],r[1]).add(r[0]),l=Cr);const f=r[a%s],m=r[(a+1)%s];if(this.closed||a+2<s?h=r[(a+2)%s]:(Cr.subVectors(r[s-1],r[s-2]).add(r[s-1]),h=Cr),this.curveType==="centripetal"||this.curveType==="chordal"){const p=this.curveType==="chordal"?.5:.25;let _=Math.pow(l.distanceToSquared(f),p),x=Math.pow(f.distanceToSquared(m),p),d=Math.pow(m.distanceToSquared(h),p);x<1e-4&&(x=1),_<1e-4&&(_=x),d<1e-4&&(d=x),Ls.initNonuniformCatmullRom(l.x,f.x,m.x,h.x,_,x,d),Ds.initNonuniformCatmullRom(l.y,f.y,m.y,h.y,_,x,d),Is.initNonuniformCatmullRom(l.z,f.z,m.z,h.z,_,x,d)}else this.curveType==="catmullrom"&&(Ls.initCatmullRom(l.x,f.x,m.x,h.x,this.tension),Ds.initCatmullRom(l.y,f.y,m.y,h.y,this.tension),Is.initCatmullRom(l.z,f.z,m.z,h.z,this.tension));return n.set(Ls.calc(c),Ds.calc(c),Is.calc(c)),n}copy(t){super.copy(t),this.points=[];for(let e=0,n=t.points.length;e<n;e++){const r=t.points[e];this.points.push(r.clone())}return this.closed=t.closed,this.curveType=t.curveType,this.tension=t.tension,this}toJSON(){const t=super.toJSON();t.points=[];for(let e=0,n=this.points.length;e<n;e++){const r=this.points[e];t.points.push(r.toArray())}return t.closed=this.closed,t.curveType=this.curveType,t.tension=this.tension,t}fromJSON(t){super.fromJSON(t),this.points=[];for(let e=0,n=t.points.length;e<n;e++){const r=t.points[e];this.points.push(new H().fromArray(r))}return this.closed=t.closed,this.curveType=t.curveType,this.tension=t.tension,this}}function Qa(i,t,e,n,r){const s=(n-t)*.5,o=(r-e)*.5,a=i*i,c=i*a;return(2*e-2*n+s+o)*c+(-3*e+3*n-2*s-o)*a+s*i+e}function Bm(i,t){const e=1-i;return e*e*t}function zm(i,t){return 2*(1-i)*i*t}function Gm(i,t){return i*i*t}function Xi(i,t,e,n){return Bm(i,t)+zm(i,e)+Gm(i,n)}function km(i,t){const e=1-i;return e*e*e*t}function Hm(i,t){const e=1-i;return 3*e*e*i*t}function Vm(i,t){return 3*(1-i)*i*i*t}function Xm(i,t){return i*i*i*t}function Wi(i,t,e,n,r){return km(i,t)+Hm(i,e)+Vm(i,n)+Xm(i,r)}class Wm extends gn{constructor(t=new At,e=new At,n=new At,r=new At){super(),this.isCubicBezierCurve=!0,this.type="CubicBezierCurve",this.v0=t,this.v1=e,this.v2=n,this.v3=r}getPoint(t,e=new At){const n=e,r=this.v0,s=this.v1,o=this.v2,a=this.v3;return n.set(Wi(t,r.x,s.x,o.x,a.x),Wi(t,r.y,s.y,o.y,a.y)),n}copy(t){return super.copy(t),this.v0.copy(t.v0),this.v1.copy(t.v1),this.v2.copy(t.v2),this.v3.copy(t.v3),this}toJSON(){const t=super.toJSON();return t.v0=this.v0.toArray(),t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t.v3=this.v3.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v0.fromArray(t.v0),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this.v3.fromArray(t.v3),this}}class qm extends gn{constructor(t=new H,e=new H,n=new H,r=new H){super(),this.isCubicBezierCurve3=!0,this.type="CubicBezierCurve3",this.v0=t,this.v1=e,this.v2=n,this.v3=r}getPoint(t,e=new H){const n=e,r=this.v0,s=this.v1,o=this.v2,a=this.v3;return n.set(Wi(t,r.x,s.x,o.x,a.x),Wi(t,r.y,s.y,o.y,a.y),Wi(t,r.z,s.z,o.z,a.z)),n}copy(t){return super.copy(t),this.v0.copy(t.v0),this.v1.copy(t.v1),this.v2.copy(t.v2),this.v3.copy(t.v3),this}toJSON(){const t=super.toJSON();return t.v0=this.v0.toArray(),t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t.v3=this.v3.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v0.fromArray(t.v0),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this.v3.fromArray(t.v3),this}}class Ym extends gn{constructor(t=new At,e=new At){super(),this.isLineCurve=!0,this.type="LineCurve",this.v1=t,this.v2=e}getPoint(t,e=new At){const n=e;return t===1?n.copy(this.v2):(n.copy(this.v2).sub(this.v1),n.multiplyScalar(t).add(this.v1)),n}getPointAt(t,e){return this.getPoint(t,e)}getTangent(t,e=new At){return e.subVectors(this.v2,this.v1).normalize()}getTangentAt(t,e){return this.getTangent(t,e)}copy(t){return super.copy(t),this.v1.copy(t.v1),this.v2.copy(t.v2),this}toJSON(){const t=super.toJSON();return t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this}}class jm extends gn{constructor(t=new H,e=new H){super(),this.isLineCurve3=!0,this.type="LineCurve3",this.v1=t,this.v2=e}getPoint(t,e=new H){const n=e;return t===1?n.copy(this.v2):(n.copy(this.v2).sub(this.v1),n.multiplyScalar(t).add(this.v1)),n}getPointAt(t,e){return this.getPoint(t,e)}getTangent(t,e=new H){return e.subVectors(this.v2,this.v1).normalize()}getTangentAt(t,e){return this.getTangent(t,e)}copy(t){return super.copy(t),this.v1.copy(t.v1),this.v2.copy(t.v2),this}toJSON(){const t=super.toJSON();return t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this}}class tl extends gn{constructor(t=new At,e=new At,n=new At){super(),this.isQuadraticBezierCurve=!0,this.type="QuadraticBezierCurve",this.v0=t,this.v1=e,this.v2=n}getPoint(t,e=new At){const n=e,r=this.v0,s=this.v1,o=this.v2;return n.set(Xi(t,r.x,s.x,o.x),Xi(t,r.y,s.y,o.y)),n}copy(t){return super.copy(t),this.v0.copy(t.v0),this.v1.copy(t.v1),this.v2.copy(t.v2),this}toJSON(){const t=super.toJSON();return t.v0=this.v0.toArray(),t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v0.fromArray(t.v0),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this}}class el extends gn{constructor(t=new H,e=new H,n=new H){super(),this.isQuadraticBezierCurve3=!0,this.type="QuadraticBezierCurve3",this.v0=t,this.v1=e,this.v2=n}getPoint(t,e=new H){const n=e,r=this.v0,s=this.v1,o=this.v2;return n.set(Xi(t,r.x,s.x,o.x),Xi(t,r.y,s.y,o.y),Xi(t,r.z,s.z,o.z)),n}copy(t){return super.copy(t),this.v0.copy(t.v0),this.v1.copy(t.v1),this.v2.copy(t.v2),this}toJSON(){const t=super.toJSON();return t.v0=this.v0.toArray(),t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v0.fromArray(t.v0),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this}}class $m extends gn{constructor(t=[]){super(),this.isSplineCurve=!0,this.type="SplineCurve",this.points=t}getPoint(t,e=new At){const n=e,r=this.points,s=(r.length-1)*t,o=Math.floor(s),a=s-o,c=r[o===0?o:o-1],l=r[o],h=r[o>r.length-2?r.length-1:o+1],f=r[o>r.length-3?r.length-1:o+2];return n.set(Qa(a,c.x,l.x,h.x,f.x),Qa(a,c.y,l.y,h.y,f.y)),n}copy(t){super.copy(t),this.points=[];for(let e=0,n=t.points.length;e<n;e++){const r=t.points[e];this.points.push(r.clone())}return this}toJSON(){const t=super.toJSON();t.points=[];for(let e=0,n=this.points.length;e<n;e++){const r=this.points[e];t.points.push(r.toArray())}return t}fromJSON(t){super.fromJSON(t),this.points=[];for(let e=0,n=t.points.length;e<n;e++){const r=t.points[e];this.points.push(new At().fromArray(r))}return this}}var Km=Object.freeze({__proto__:null,ArcCurve:Fm,CatmullRomCurve3:en,CubicBezierCurve:Wm,CubicBezierCurve3:qm,EllipseCurve:Qc,LineCurve:Ym,LineCurve3:jm,QuadraticBezierCurve:tl,QuadraticBezierCurve3:el,SplineCurve:$m});class jr extends Jt{constructor(t=1,e=32,n=0,r=Math.PI*2){super(),this.type="CircleGeometry",this.parameters={radius:t,segments:e,thetaStart:n,thetaLength:r},e=Math.max(3,e);const s=[],o=[],a=[],c=[],l=new H,h=new At;o.push(0,0,0),a.push(0,0,1),c.push(.5,.5);for(let f=0,m=3;f<=e;f++,m+=3){const p=n+f/e*r;l.x=t*Math.cos(p),l.y=t*Math.sin(p),o.push(l.x,l.y,l.z),a.push(0,0,1),h.x=(o[m]/t+1)/2,h.y=(o[m+1]/t+1)/2,c.push(h.x,h.y)}for(let f=1;f<=e;f++)s.push(f,f+1,0);this.setIndex(s),this.setAttribute("position",new Nt(o,3)),this.setAttribute("normal",new Nt(a,3)),this.setAttribute("uv",new Nt(c,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new jr(t.radius,t.segments,t.thetaStart,t.thetaLength)}}class qt extends Jt{constructor(t=1,e=1,n=1,r=32,s=1,o=!1,a=0,c=Math.PI*2){super(),this.type="CylinderGeometry",this.parameters={radiusTop:t,radiusBottom:e,height:n,radialSegments:r,heightSegments:s,openEnded:o,thetaStart:a,thetaLength:c};const l=this;r=Math.floor(r),s=Math.floor(s);const h=[],f=[],m=[],p=[];let _=0;const x=[],d=n/2;let u=0;M(),o===!1&&(t>0&&g(!0),e>0&&g(!1)),this.setIndex(h),this.setAttribute("position",new Nt(f,3)),this.setAttribute("normal",new Nt(m,3)),this.setAttribute("uv",new Nt(p,2));function M(){const y=new H,L=new H;let C=0;const D=(e-t)/n;for(let F=0;F<=s;F++){const T=[],E=F/s,j=E*(e-t)+t;for(let O=0;O<=r;O++){const B=O/r,S=B*c+a,b=Math.sin(S),v=Math.cos(S);L.x=j*b,L.y=-E*n+d,L.z=j*v,f.push(L.x,L.y,L.z),y.set(b,D,v).normalize(),m.push(y.x,y.y,y.z),p.push(B,1-E),T.push(_++)}x.push(T)}for(let F=0;F<r;F++)for(let T=0;T<s;T++){const E=x[T][F],j=x[T+1][F],O=x[T+1][F+1],B=x[T][F+1];h.push(E,j,B),h.push(j,O,B),C+=6}l.addGroup(u,C,0),u+=C}function g(y){const L=_,C=new At,D=new H;let F=0;const T=y===!0?t:e,E=y===!0?1:-1;for(let O=1;O<=r;O++)f.push(0,d*E,0),m.push(0,E,0),p.push(.5,.5),_++;const j=_;for(let O=0;O<=r;O++){const S=O/r*c+a,b=Math.cos(S),v=Math.sin(S);D.x=T*v,D.y=d*E,D.z=T*b,f.push(D.x,D.y,D.z),m.push(0,E,0),C.x=b*.5+.5,C.y=v*.5*E+.5,p.push(C.x,C.y),_++}for(let O=0;O<r;O++){const B=L+O,S=j+O;y===!0?h.push(S,S+1,B):h.push(S+1,S,B),F+=3}l.addGroup(u,F,y===!0?1:2),u+=F}}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new qt(t.radiusTop,t.radiusBottom,t.height,t.radialSegments,t.heightSegments,t.openEnded,t.thetaStart,t.thetaLength)}}class Be extends qt{constructor(t=1,e=1,n=32,r=1,s=!1,o=0,a=Math.PI*2){super(0,t,e,n,r,s,o,a),this.type="ConeGeometry",this.parameters={radius:t,height:e,radialSegments:n,heightSegments:r,openEnded:s,thetaStart:o,thetaLength:a}}static fromJSON(t){return new Be(t.radius,t.height,t.radialSegments,t.heightSegments,t.openEnded,t.thetaStart,t.thetaLength)}}class $r extends Jt{constructor(t=[],e=[],n=1,r=0){super(),this.type="PolyhedronGeometry",this.parameters={vertices:t,indices:e,radius:n,detail:r};const s=[],o=[];a(r),l(n),h(),this.setAttribute("position",new Nt(s,3)),this.setAttribute("normal",new Nt(s.slice(),3)),this.setAttribute("uv",new Nt(o,2)),r===0?this.computeVertexNormals():this.normalizeNormals();function a(M){const g=new H,y=new H,L=new H;for(let C=0;C<e.length;C+=3)p(e[C+0],g),p(e[C+1],y),p(e[C+2],L),c(g,y,L,M)}function c(M,g,y,L){const C=L+1,D=[];for(let F=0;F<=C;F++){D[F]=[];const T=M.clone().lerp(y,F/C),E=g.clone().lerp(y,F/C),j=C-F;for(let O=0;O<=j;O++)O===0&&F===C?D[F][O]=T:D[F][O]=T.clone().lerp(E,O/j)}for(let F=0;F<C;F++)for(let T=0;T<2*(C-F)-1;T++){const E=Math.floor(T/2);T%2===0?(m(D[F][E+1]),m(D[F+1][E]),m(D[F][E])):(m(D[F][E+1]),m(D[F+1][E+1]),m(D[F+1][E]))}}function l(M){const g=new H;for(let y=0;y<s.length;y+=3)g.x=s[y+0],g.y=s[y+1],g.z=s[y+2],g.normalize().multiplyScalar(M),s[y+0]=g.x,s[y+1]=g.y,s[y+2]=g.z}function h(){const M=new H;for(let g=0;g<s.length;g+=3){M.x=s[g+0],M.y=s[g+1],M.z=s[g+2];const y=d(M)/2/Math.PI+.5,L=u(M)/Math.PI+.5;o.push(y,1-L)}_(),f()}function f(){for(let M=0;M<o.length;M+=6){const g=o[M+0],y=o[M+2],L=o[M+4],C=Math.max(g,y,L),D=Math.min(g,y,L);C>.9&&D<.1&&(g<.2&&(o[M+0]+=1),y<.2&&(o[M+2]+=1),L<.2&&(o[M+4]+=1))}}function m(M){s.push(M.x,M.y,M.z)}function p(M,g){const y=M*3;g.x=t[y+0],g.y=t[y+1],g.z=t[y+2]}function _(){const M=new H,g=new H,y=new H,L=new H,C=new At,D=new At,F=new At;for(let T=0,E=0;T<s.length;T+=9,E+=6){M.set(s[T+0],s[T+1],s[T+2]),g.set(s[T+3],s[T+4],s[T+5]),y.set(s[T+6],s[T+7],s[T+8]),C.set(o[E+0],o[E+1]),D.set(o[E+2],o[E+3]),F.set(o[E+4],o[E+5]),L.copy(M).add(g).add(y).divideScalar(3);const j=d(L);x(C,E+0,M,j),x(D,E+2,g,j),x(F,E+4,y,j)}}function x(M,g,y,L){L<0&&M.x===1&&(o[g]=M.x-1),y.x===0&&y.z===0&&(o[g]=L/2/Math.PI+.5)}function d(M){return Math.atan2(M.z,-M.x)}function u(M){return Math.atan2(-M.y,Math.sqrt(M.x*M.x+M.z*M.z))}}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new $r(t.vertices,t.indices,t.radius,t.details)}}class ho extends $r{constructor(t=1,e=0){const n=(1+Math.sqrt(5))/2,r=1/n,s=[-1,-1,-1,-1,-1,1,-1,1,-1,-1,1,1,1,-1,-1,1,-1,1,1,1,-1,1,1,1,0,-r,-n,0,-r,n,0,r,-n,0,r,n,-r,-n,0,-r,n,0,r,-n,0,r,n,0,-n,0,-r,n,0,-r,-n,0,r,n,0,r],o=[3,11,7,3,7,15,3,15,13,7,19,17,7,17,6,7,6,15,17,4,8,17,8,10,17,10,6,8,0,16,8,16,2,8,2,10,0,12,1,0,1,18,0,18,16,6,10,2,6,2,13,6,13,15,2,16,18,2,18,3,2,3,13,18,1,9,18,9,11,18,11,3,4,14,12,4,12,0,4,0,8,11,9,5,11,5,19,11,19,7,19,5,14,19,14,4,19,4,17,1,12,14,1,14,5,1,5,9];super(s,o,t,e),this.type="DodecahedronGeometry",this.parameters={radius:t,detail:e}}static fromJSON(t){return new ho(t.radius,t.detail)}}class fo extends $r{constructor(t=1,e=0){const n=(1+Math.sqrt(5))/2,r=[-1,n,0,1,n,0,-1,-n,0,1,-n,0,0,-1,n,0,1,n,0,-1,-n,0,1,-n,n,0,-1,n,0,1,-n,0,-1,-n,0,1],s=[0,11,5,0,5,1,0,1,7,0,7,10,0,10,11,1,5,9,5,11,4,11,10,2,10,7,6,7,1,8,3,9,4,3,4,2,3,2,6,3,6,8,3,8,9,4,9,5,2,4,11,6,2,10,8,6,7,9,8,1];super(r,s,t,e),this.type="IcosahedronGeometry",this.parameters={radius:t,detail:e}}static fromJSON(t){return new fo(t.radius,t.detail)}}class Ki extends Jt{constructor(t=.5,e=1,n=32,r=1,s=0,o=Math.PI*2){super(),this.type="RingGeometry",this.parameters={innerRadius:t,outerRadius:e,thetaSegments:n,phiSegments:r,thetaStart:s,thetaLength:o},n=Math.max(3,n),r=Math.max(1,r);const a=[],c=[],l=[],h=[];let f=t;const m=(e-t)/r,p=new H,_=new At;for(let x=0;x<=r;x++){for(let d=0;d<=n;d++){const u=s+d/n*o;p.x=f*Math.cos(u),p.y=f*Math.sin(u),c.push(p.x,p.y,p.z),l.push(0,0,1),_.x=(p.x/e+1)/2,_.y=(p.y/e+1)/2,h.push(_.x,_.y)}f+=m}for(let x=0;x<r;x++){const d=x*(n+1);for(let u=0;u<n;u++){const M=u+d,g=M,y=M+n+1,L=M+n+2,C=M+1;a.push(g,y,C),a.push(y,L,C)}}this.setIndex(a),this.setAttribute("position",new Nt(c,3)),this.setAttribute("normal",new Nt(l,3)),this.setAttribute("uv",new Nt(h,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new Ki(t.innerRadius,t.outerRadius,t.thetaSegments,t.phiSegments,t.thetaStart,t.thetaLength)}}class ie extends Jt{constructor(t=1,e=32,n=16,r=0,s=Math.PI*2,o=0,a=Math.PI){super(),this.type="SphereGeometry",this.parameters={radius:t,widthSegments:e,heightSegments:n,phiStart:r,phiLength:s,thetaStart:o,thetaLength:a},e=Math.max(3,Math.floor(e)),n=Math.max(2,Math.floor(n));const c=Math.min(o+a,Math.PI);let l=0;const h=[],f=new H,m=new H,p=[],_=[],x=[],d=[];for(let u=0;u<=n;u++){const M=[],g=u/n;let y=0;u===0&&o===0?y=.5/e:u===n&&c===Math.PI&&(y=-.5/e);for(let L=0;L<=e;L++){const C=L/e;f.x=-t*Math.cos(r+C*s)*Math.sin(o+g*a),f.y=t*Math.cos(o+g*a),f.z=t*Math.sin(r+C*s)*Math.sin(o+g*a),_.push(f.x,f.y,f.z),m.copy(f).normalize(),x.push(m.x,m.y,m.z),d.push(C+y,1-g),M.push(l++)}h.push(M)}for(let u=0;u<n;u++)for(let M=0;M<e;M++){const g=h[u][M+1],y=h[u][M],L=h[u+1][M],C=h[u+1][M+1];(u!==0||o>0)&&p.push(g,y,C),(u!==n-1||c<Math.PI)&&p.push(y,L,C)}this.setIndex(p),this.setAttribute("position",new Nt(_,3)),this.setAttribute("normal",new Nt(x,3)),this.setAttribute("uv",new Nt(d,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new ie(t.radius,t.widthSegments,t.heightSegments,t.phiStart,t.phiLength,t.thetaStart,t.thetaLength)}}class Ti extends Jt{constructor(t=1,e=.4,n=12,r=48,s=Math.PI*2){super(),this.type="TorusGeometry",this.parameters={radius:t,tube:e,radialSegments:n,tubularSegments:r,arc:s},n=Math.floor(n),r=Math.floor(r);const o=[],a=[],c=[],l=[],h=new H,f=new H,m=new H;for(let p=0;p<=n;p++)for(let _=0;_<=r;_++){const x=_/r*s,d=p/n*Math.PI*2;f.x=(t+e*Math.cos(d))*Math.cos(x),f.y=(t+e*Math.cos(d))*Math.sin(x),f.z=e*Math.sin(d),a.push(f.x,f.y,f.z),h.x=t*Math.cos(x),h.y=t*Math.sin(x),m.subVectors(f,h).normalize(),c.push(m.x,m.y,m.z),l.push(_/r),l.push(p/n)}for(let p=1;p<=n;p++)for(let _=1;_<=r;_++){const x=(r+1)*p+_-1,d=(r+1)*(p-1)+_-1,u=(r+1)*(p-1)+_,M=(r+1)*p+_;o.push(x,d,M),o.push(d,u,M)}this.setIndex(o),this.setAttribute("position",new Nt(a,3)),this.setAttribute("normal",new Nt(c,3)),this.setAttribute("uv",new Nt(l,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new Ti(t.radius,t.tube,t.radialSegments,t.tubularSegments,t.arc)}}class vi extends Jt{constructor(t=new el(new H(-1,-1,0),new H(-1,1,0),new H(1,1,0)),e=64,n=1,r=8,s=!1){super(),this.type="TubeGeometry",this.parameters={path:t,tubularSegments:e,radius:n,radialSegments:r,closed:s};const o=t.computeFrenetFrames(e,s);this.tangents=o.tangents,this.normals=o.normals,this.binormals=o.binormals;const a=new H,c=new H,l=new At;let h=new H;const f=[],m=[],p=[],_=[];x(),this.setIndex(_),this.setAttribute("position",new Nt(f,3)),this.setAttribute("normal",new Nt(m,3)),this.setAttribute("uv",new Nt(p,2));function x(){for(let g=0;g<e;g++)d(g);d(s===!1?e:0),M(),u()}function d(g){h=t.getPointAt(g/e,h);const y=o.normals[g],L=o.binormals[g];for(let C=0;C<=r;C++){const D=C/r*Math.PI*2,F=Math.sin(D),T=-Math.cos(D);c.x=T*y.x+F*L.x,c.y=T*y.y+F*L.y,c.z=T*y.z+F*L.z,c.normalize(),m.push(c.x,c.y,c.z),a.x=h.x+n*c.x,a.y=h.y+n*c.y,a.z=h.z+n*c.z,f.push(a.x,a.y,a.z)}}function u(){for(let g=1;g<=e;g++)for(let y=1;y<=r;y++){const L=(r+1)*(g-1)+(y-1),C=(r+1)*g+(y-1),D=(r+1)*g+y,F=(r+1)*(g-1)+y;_.push(L,C,F),_.push(C,D,F)}}function M(){for(let g=0;g<=e;g++)for(let y=0;y<=r;y++)l.x=g/e,l.y=y/r,p.push(l.x,l.y)}}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}toJSON(){const t=super.toJSON();return t.path=this.parameters.path.toJSON(),t}static fromJSON(t){return new vi(new Km[t.path.type]().fromJSON(t.path),t.tubularSegments,t.radius,t.radialSegments,t.closed)}}class Zm extends we{constructor(t){super(t),this.isRawShaderMaterial=!0,this.type="RawShaderMaterial"}}class ze extends Rn{constructor(t){super(),this.isMeshStandardMaterial=!0,this.defines={STANDARD:""},this.type="MeshStandardMaterial",this.color=new Dt(16777215),this.roughness=1,this.metalness=0,this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.emissive=new Dt(0),this.emissiveIntensity=1,this.emissiveMap=null,this.bumpMap=null,this.bumpScale=1,this.normalMap=null,this.normalMapType=Cc,this.normalScale=new At(1,1),this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.roughnessMap=null,this.metalnessMap=null,this.alphaMap=null,this.envMap=null,this.envMapIntensity=1,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.flatShading=!1,this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.defines={STANDARD:""},this.color.copy(t.color),this.roughness=t.roughness,this.metalness=t.metalness,this.map=t.map,this.lightMap=t.lightMap,this.lightMapIntensity=t.lightMapIntensity,this.aoMap=t.aoMap,this.aoMapIntensity=t.aoMapIntensity,this.emissive.copy(t.emissive),this.emissiveMap=t.emissiveMap,this.emissiveIntensity=t.emissiveIntensity,this.bumpMap=t.bumpMap,this.bumpScale=t.bumpScale,this.normalMap=t.normalMap,this.normalMapType=t.normalMapType,this.normalScale.copy(t.normalScale),this.displacementMap=t.displacementMap,this.displacementScale=t.displacementScale,this.displacementBias=t.displacementBias,this.roughnessMap=t.roughnessMap,this.metalnessMap=t.metalnessMap,this.alphaMap=t.alphaMap,this.envMap=t.envMap,this.envMapIntensity=t.envMapIntensity,this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this.wireframeLinecap=t.wireframeLinecap,this.wireframeLinejoin=t.wireframeLinejoin,this.flatShading=t.flatShading,this.fog=t.fog,this}}class po extends ae{constructor(t,e=1){super(),this.isLight=!0,this.type="Light",this.color=new Dt(t),this.intensity=e}dispose(){}copy(t,e){return super.copy(t,e),this.color.copy(t.color),this.intensity=t.intensity,this}toJSON(t){const e=super.toJSON(t);return e.object.color=this.color.getHex(),e.object.intensity=this.intensity,this.groundColor!==void 0&&(e.object.groundColor=this.groundColor.getHex()),this.distance!==void 0&&(e.object.distance=this.distance),this.angle!==void 0&&(e.object.angle=this.angle),this.decay!==void 0&&(e.object.decay=this.decay),this.penumbra!==void 0&&(e.object.penumbra=this.penumbra),this.shadow!==void 0&&(e.object.shadow=this.shadow.toJSON()),e}}class Jm extends po{constructor(t,e,n){super(t,n),this.isHemisphereLight=!0,this.type="HemisphereLight",this.position.copy(ae.DEFAULT_UP),this.updateMatrix(),this.groundColor=new Dt(e)}copy(t,e){return super.copy(t,e),this.groundColor.copy(t.groundColor),this}}const Us=new ee,tc=new H,ec=new H;class nl{constructor(t){this.camera=t,this.bias=0,this.normalBias=0,this.radius=1,this.blurSamples=8,this.mapSize=new At(512,512),this.map=null,this.mapPass=null,this.matrix=new ee,this.autoUpdate=!0,this.needsUpdate=!1,this._frustum=new so,this._frameExtents=new At(1,1),this._viewportCount=1,this._viewports=[new oe(0,0,1,1)]}getViewportCount(){return this._viewportCount}getFrustum(){return this._frustum}updateMatrices(t){const e=this.camera,n=this.matrix;tc.setFromMatrixPosition(t.matrixWorld),e.position.copy(tc),ec.setFromMatrixPosition(t.target.matrixWorld),e.lookAt(ec),e.updateMatrixWorld(),Us.multiplyMatrices(e.projectionMatrix,e.matrixWorldInverse),this._frustum.setFromProjectionMatrix(Us),n.set(.5,0,0,.5,0,.5,0,.5,0,0,.5,.5,0,0,0,1),n.multiply(Us)}getViewport(t){return this._viewports[t]}getFrameExtents(){return this._frameExtents}dispose(){this.map&&this.map.dispose(),this.mapPass&&this.mapPass.dispose()}copy(t){return this.camera=t.camera.clone(),this.bias=t.bias,this.radius=t.radius,this.mapSize.copy(t.mapSize),this}clone(){return new this.constructor().copy(this)}toJSON(){const t={};return this.bias!==0&&(t.bias=this.bias),this.normalBias!==0&&(t.normalBias=this.normalBias),this.radius!==1&&(t.radius=this.radius),(this.mapSize.x!==512||this.mapSize.y!==512)&&(t.mapSize=this.mapSize.toArray()),t.camera=this.camera.toJSON(!1).object,delete t.camera.matrix,t}}const nc=new ee,Gi=new H,Ns=new H;class Qm extends nl{constructor(){super(new Fe(90,1,.5,500)),this.isPointLightShadow=!0,this._frameExtents=new At(4,2),this._viewportCount=6,this._viewports=[new oe(2,1,1,1),new oe(0,1,1,1),new oe(3,1,1,1),new oe(1,1,1,1),new oe(3,0,1,1),new oe(1,0,1,1)],this._cubeDirections=[new H(1,0,0),new H(-1,0,0),new H(0,0,1),new H(0,0,-1),new H(0,1,0),new H(0,-1,0)],this._cubeUps=[new H(0,1,0),new H(0,1,0),new H(0,1,0),new H(0,1,0),new H(0,0,1),new H(0,0,-1)]}updateMatrices(t,e=0){const n=this.camera,r=this.matrix,s=t.distance||n.far;s!==n.far&&(n.far=s,n.updateProjectionMatrix()),Gi.setFromMatrixPosition(t.matrixWorld),n.position.copy(Gi),Ns.copy(n.position),Ns.add(this._cubeDirections[e]),n.up.copy(this._cubeUps[e]),n.lookAt(Ns),n.updateMatrixWorld(),r.makeTranslation(-Gi.x,-Gi.y,-Gi.z),nc.multiplyMatrices(n.projectionMatrix,n.matrixWorldInverse),this._frustum.setFromProjectionMatrix(nc)}}class il extends po{constructor(t,e,n=0,r=2){super(t,e),this.isPointLight=!0,this.type="PointLight",this.distance=n,this.decay=r,this.shadow=new Qm}get power(){return this.intensity*4*Math.PI}set power(t){this.intensity=t/(4*Math.PI)}dispose(){this.shadow.dispose()}copy(t,e){return super.copy(t,e),this.distance=t.distance,this.decay=t.decay,this.shadow=t.shadow.clone(),this}}class t0 extends nl{constructor(){super(new oo(-5,5,5,-5,.5,500)),this.isDirectionalLightShadow=!0}}class e0 extends po{constructor(t,e){super(t,e),this.isDirectionalLight=!0,this.type="DirectionalLight",this.position.copy(ae.DEFAULT_UP),this.updateMatrix(),this.target=new ae,this.shadow=new t0}dispose(){this.shadow.dispose()}copy(t){return super.copy(t),this.target=t.target.clone(),this.shadow=t.shadow.clone(),this}}class rl{constructor(t=!0){this.autoStart=t,this.startTime=0,this.oldTime=0,this.elapsedTime=0,this.running=!1}start(){this.startTime=ic(),this.oldTime=this.startTime,this.elapsedTime=0,this.running=!0}stop(){this.getElapsedTime(),this.running=!1,this.autoStart=!1}getElapsedTime(){return this.getDelta(),this.elapsedTime}getDelta(){let t=0;if(this.autoStart&&!this.running)return this.start(),0;if(this.running){const e=ic();t=(e-this.oldTime)/1e3,this.oldTime=e,this.elapsedTime+=t}return t}}function ic(){return(typeof performance>"u"?Date:performance).now()}class n0{constructor(t,e,n=0,r=1/0){this.ray=new Hn(t,e),this.near=n,this.far=r,this.camera=null,this.layers=new ro,this.params={Mesh:{},Line:{threshold:1},LOD:{},Points:{threshold:1},Sprite:{}}}set(t,e){this.ray.set(t,e)}setFromCamera(t,e){e.isPerspectiveCamera?(this.ray.origin.setFromMatrixPosition(e.matrixWorld),this.ray.direction.set(t.x,t.y,.5).unproject(e).sub(this.ray.origin).normalize(),this.camera=e):e.isOrthographicCamera?(this.ray.origin.set(t.x,t.y,(e.near+e.far)/(e.near-e.far)).unproject(e),this.ray.direction.set(0,0,-1).transformDirection(e.matrixWorld),this.camera=e):console.error("THREE.Raycaster: Unsupported camera type: "+e.type)}intersectObject(t,e=!0,n=[]){return $s(t,this,n,e),n.sort(rc),n}intersectObjects(t,e=!0,n=[]){for(let r=0,s=t.length;r<s;r++)$s(t[r],this,n,e);return n.sort(rc),n}}function rc(i,t){return i.distance-t.distance}function $s(i,t,e,n){if(i.layers.test(t.layers)&&i.raycast(t,e),n===!0){const r=i.children;for(let s=0,o=r.length;s<o;s++)$s(r[s],t,e,!0)}}class sc{constructor(t=1,e=0,n=0){return this.radius=t,this.phi=e,this.theta=n,this}set(t,e,n){return this.radius=t,this.phi=e,this.theta=n,this}copy(t){return this.radius=t.radius,this.phi=t.phi,this.theta=t.theta,this}makeSafe(){return this.phi=Math.max(1e-6,Math.min(Math.PI-1e-6,this.phi)),this}setFromVector3(t){return this.setFromCartesianCoords(t.x,t.y,t.z)}setFromCartesianCoords(t,e,n){return this.radius=Math.sqrt(t*t+e*e+n*n),this.radius===0?(this.theta=0,this.phi=0):(this.theta=Math.atan2(t,n),this.phi=Math.acos(xe(e/this.radius,-1,1))),this}clone(){return new this.constructor().copy(this)}}typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("register",{detail:{revision:Qs}}));typeof window<"u"&&(window.__THREE__?console.warn("WARNING: Multiple instances of Three.js being imported."):window.__THREE__=Qs);function i0(i){const t={sinhLuc:{label:"Sinh lực",v:74,decay:.07,src:"Giấc ngủ, vận động",tower:"center"},nganKho:{label:"Ngân khố",v:58,decay:.03,src:"Ngân sách tháng còn lại",tower:"nghisu"},triThuc:{label:"Tri thức",v:41,decay:.05,src:"Kế hoạch đọc năm",tower:"tangkinh"},kyNang:{label:"Kỹ năng",v:66,decay:.05,src:"Tiếng Anh ở Trà Đình",tower:"tradinh"},heThong:{label:"Hệ thống",v:96,decay:0,src:"Pi 5, amber-brain, webhook",tower:"kieulau"}};i.STATS=t;const e=25;i.CRIT=e;const n=i.opts.lite;i.LITE=n;const r={kieulau:{name:"Kiều Lâu",role:"Nhà trên cầu nối Âm–Dương · trung tâm thông báo · tin RSS tạm",pos:[0,0,0],acts:[["Kiểm tra hệ thống",{heThong:40},"Đã kiểm tra: mọi dịch vụ ổn"],["Đánh dấu đã đọc",null,null,"readAll"]]},tangkinh:{name:"Tàng Kinh Các",role:"Sách, kế hoạch đọc năm, tài liệu cá nhân",pos:[-2.2,0,-6.6],acts:[["Đọc 20 trang",{triThuc:9},"Đã ghi 20 trang vào nhật ký đọc"],["Lưu ghi chú",{triThuc:3},"Đã lưu ghi chú mới"]]},tradinh:{name:"Trà Đình",role:"Gia sư tiếng Anh · theo dõi kỹ năng",pos:[5.2,0,4.6],acts:[["Học 1 bài",{kyNang:10},"Hoàn thành 1 bài học"],["Luyện nói 5 phút",{kyNang:5},"Đã luyện nói 5 phút"]]},nghisu:{name:"Nghị Sự Đường",role:"Thu chi · việc cần quyết (tạm gán)",pos:[-6.4,0,-2.6],acts:[["Ghi thu nhập",{nganKho:15},"Đã ghi một khoản thu"],["Ghi chi tiêu",{nganKho:-5},"Đã ghi một khoản chi"]]},center:{name:"Amber",role:"Tâm điểm · trạng thái tổng",pos:[0,0,0],acts:[["Nghỉ ngơi",{sinhLuc:20},"Đã nạp lại sinh lực"],["Đổi Âm/Dương",null,null,"toggle"]]}};if(i.TOWERS=r,!i.opts.demo){for(const c of Object.values(t))c.v=null;const a=(c,l)=>[c,null,l,"nav"];r.kieulau.acts=[a("Mở Kiều Lâu","/kieu-lau"),["Đánh dấu đã đọc",null,null,"readAll"]],r.tangkinh.acts=[a("Sách","/tang-kinh-cac/sach"),a("Kế hoạch đọc","/tang-kinh-cac/ke-hoach-doc"),a("Mở Tàng Kinh Các","/tang-kinh-cac")],r.tradinh.acts=[a("Học hôm nay","/tra-dinh"),a("Ôn thẻ","/tra-dinh/hoc-tap/the/on")],r.nghisu.acts=[a("Tài chính","/finance"),a("Việc & dự án","/nghi-su-duong")],r.nghisu.role="Thu chi · việc cần quyết",r.center.acts=[a("Ghi giấc ngủ","/sinh-luc"),["Đổi Âm/Dương",null,null,"toggle"]]}const s=[{from:"tangkinh",lvl:"info",text:"Còn 3 cuốn trong kế hoạch đọc quý này"},{from:"kieulau",lvl:"info",text:"Nhật Báo Các: 12 tin RSS mới"},{from:"tradinh",lvl:"ok",text:"Chuỗi học 6 ngày, giữ phong độ nhé",effect:{kyNang:2}},{from:"nghisu",lvl:"warn",text:"Chi Ăn uống tuần này vượt 20%",effect:{nganKho:-6}},{from:"center",lvl:"warn",text:"Webhook: amber-brain phản hồi chậm (2.4s)",effect:{heThong:-14}},{from:"center",lvl:"bad",text:"Webhook: Pi 5 nhiệt độ 78°C",effect:{heThong:-30}},{from:"tangkinh",lvl:"ok",text:"Đã đồng bộ 4 tài liệu mới"}];i.RANDOM_EVENTS=s;const o={info:"#8ab4ff",ok:"#7fd4a0",warn:"#ffcf5c",bad:"#ff6b6b"};i.LVL=o}const sl={name:"CopyShader",uniforms:{tDiffuse:{value:null},opacity:{value:1}},vertexShader:`

		varying vec2 vUv;

		void main() {

			vUv = uv;
			gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );

		}`,fragmentShader:`

		uniform float opacity;

		uniform sampler2D tDiffuse;

		varying vec2 vUv;

		void main() {

			vec4 texel = texture2D( tDiffuse, vUv );
			gl_FragColor = opacity * texel;


		}`};class Ci{constructor(){this.isPass=!0,this.enabled=!0,this.needsSwap=!0,this.clear=!1,this.renderToScreen=!1}setSize(){}render(){console.error("THREE.Pass: .render() must be implemented in derived pass.")}dispose(){}}const r0=new oo(-1,1,1,-1,0,1);class s0 extends Jt{constructor(){super(),this.setAttribute("position",new Nt([-1,3,0,-1,-1,0,3,-1,0],3)),this.setAttribute("uv",new Nt([0,2,0,0,2,0],2))}}const o0=new s0;class mo{constructor(t){this._mesh=new Bt(o0,t)}dispose(){this._mesh.geometry.dispose()}render(t){t.render(this._mesh,r0)}get material(){return this._mesh.material}set material(t){this._mesh.material=t}}class a0 extends Ci{constructor(t,e){super(),this.textureID=e!==void 0?e:"tDiffuse",t instanceof we?(this.uniforms=t.uniforms,this.material=t):t&&(this.uniforms=ji.clone(t.uniforms),this.material=new we({name:t.name!==void 0?t.name:"unspecified",defines:Object.assign({},t.defines),uniforms:this.uniforms,vertexShader:t.vertexShader,fragmentShader:t.fragmentShader})),this.fsQuad=new mo(this.material)}render(t,e,n){this.uniforms[this.textureID]&&(this.uniforms[this.textureID].value=n.texture),this.fsQuad.material=this.material,this.renderToScreen?(t.setRenderTarget(null),this.fsQuad.render(t)):(t.setRenderTarget(e),this.clear&&t.clear(t.autoClearColor,t.autoClearDepth,t.autoClearStencil),this.fsQuad.render(t))}dispose(){this.material.dispose(),this.fsQuad.dispose()}}class oc extends Ci{constructor(t,e){super(),this.scene=t,this.camera=e,this.clear=!0,this.needsSwap=!1,this.inverse=!1}render(t,e,n){const r=t.getContext(),s=t.state;s.buffers.color.setMask(!1),s.buffers.depth.setMask(!1),s.buffers.color.setLocked(!0),s.buffers.depth.setLocked(!0);let o,a;this.inverse?(o=0,a=1):(o=1,a=0),s.buffers.stencil.setTest(!0),s.buffers.stencil.setOp(r.REPLACE,r.REPLACE,r.REPLACE),s.buffers.stencil.setFunc(r.ALWAYS,o,4294967295),s.buffers.stencil.setClear(a),s.buffers.stencil.setLocked(!0),t.setRenderTarget(n),this.clear&&t.clear(),t.render(this.scene,this.camera),t.setRenderTarget(e),this.clear&&t.clear(),t.render(this.scene,this.camera),s.buffers.color.setLocked(!1),s.buffers.depth.setLocked(!1),s.buffers.color.setMask(!0),s.buffers.depth.setMask(!0),s.buffers.stencil.setLocked(!1),s.buffers.stencil.setFunc(r.EQUAL,1,4294967295),s.buffers.stencil.setOp(r.KEEP,r.KEEP,r.KEEP),s.buffers.stencil.setLocked(!0)}}class c0 extends Ci{constructor(){super(),this.needsSwap=!1}render(t){t.state.buffers.stencil.setLocked(!1),t.state.buffers.stencil.setTest(!1)}}class l0{constructor(t,e){if(this.renderer=t,this._pixelRatio=t.getPixelRatio(),e===void 0){const n=t.getSize(new At);this._width=n.width,this._height=n.height,e=new Ke(this._width*this._pixelRatio,this._height*this._pixelRatio,{type:dn}),e.texture.name="EffectComposer.rt1"}else this._width=e.width,this._height=e.height;this.renderTarget1=e,this.renderTarget2=e.clone(),this.renderTarget2.texture.name="EffectComposer.rt2",this.writeBuffer=this.renderTarget1,this.readBuffer=this.renderTarget2,this.renderToScreen=!0,this.passes=[],this.copyPass=new a0(sl),this.copyPass.material.blending=hn,this.clock=new rl}swapBuffers(){const t=this.readBuffer;this.readBuffer=this.writeBuffer,this.writeBuffer=t}addPass(t){this.passes.push(t),t.setSize(this._width*this._pixelRatio,this._height*this._pixelRatio)}insertPass(t,e){this.passes.splice(e,0,t),t.setSize(this._width*this._pixelRatio,this._height*this._pixelRatio)}removePass(t){const e=this.passes.indexOf(t);e!==-1&&this.passes.splice(e,1)}isLastEnabledPass(t){for(let e=t+1;e<this.passes.length;e++)if(this.passes[e].enabled)return!1;return!0}render(t){t===void 0&&(t=this.clock.getDelta());const e=this.renderer.getRenderTarget();let n=!1;for(let r=0,s=this.passes.length;r<s;r++){const o=this.passes[r];if(o.enabled!==!1){if(o.renderToScreen=this.renderToScreen&&this.isLastEnabledPass(r),o.render(this.renderer,this.writeBuffer,this.readBuffer,t,n),o.needsSwap){if(n){const a=this.renderer.getContext(),c=this.renderer.state.buffers.stencil;c.setFunc(a.NOTEQUAL,1,4294967295),this.copyPass.render(this.renderer,this.writeBuffer,this.readBuffer,t),c.setFunc(a.EQUAL,1,4294967295)}this.swapBuffers()}oc!==void 0&&(o instanceof oc?n=!0:o instanceof c0&&(n=!1))}}this.renderer.setRenderTarget(e)}reset(t){if(t===void 0){const e=this.renderer.getSize(new At);this._pixelRatio=this.renderer.getPixelRatio(),this._width=e.width,this._height=e.height,t=this.renderTarget1.clone(),t.setSize(this._width*this._pixelRatio,this._height*this._pixelRatio)}this.renderTarget1.dispose(),this.renderTarget2.dispose(),this.renderTarget1=t,this.renderTarget2=t.clone(),this.writeBuffer=this.renderTarget1,this.readBuffer=this.renderTarget2}setSize(t,e){this._width=t,this._height=e;const n=this._width*this._pixelRatio,r=this._height*this._pixelRatio;this.renderTarget1.setSize(n,r),this.renderTarget2.setSize(n,r);for(let s=0;s<this.passes.length;s++)this.passes[s].setSize(n,r)}setPixelRatio(t){this._pixelRatio=t,this.setSize(this._width,this._height)}dispose(){this.renderTarget1.dispose(),this.renderTarget2.dispose(),this.copyPass.dispose()}}const ac={type:"change"},Os={type:"start"},cc={type:"end"},Pr=new Hn,lc=new Sn,u0=Math.cos(70*Lc.DEG2RAD);class h0 extends Vn{constructor(t,e){super(),this.object=t,this.domElement=e,this.domElement.style.touchAction="none",this.enabled=!0,this.target=new H,this.cursor=new H,this.minDistance=0,this.maxDistance=1/0,this.minZoom=0,this.maxZoom=1/0,this.minTargetRadius=0,this.maxTargetRadius=1/0,this.minPolarAngle=0,this.maxPolarAngle=Math.PI,this.minAzimuthAngle=-1/0,this.maxAzimuthAngle=1/0,this.enableDamping=!1,this.dampingFactor=.05,this.enableZoom=!0,this.zoomSpeed=1,this.enableRotate=!0,this.rotateSpeed=1,this.enablePan=!0,this.panSpeed=1,this.screenSpacePanning=!0,this.keyPanSpeed=7,this.zoomToCursor=!1,this.autoRotate=!1,this.autoRotateSpeed=2,this.keys={LEFT:"ArrowLeft",UP:"ArrowUp",RIGHT:"ArrowRight",BOTTOM:"ArrowDown"},this.mouseButtons={LEFT:Yn.ROTATE,MIDDLE:Yn.DOLLY,RIGHT:Yn.PAN},this.touches={ONE:jn.ROTATE,TWO:jn.DOLLY_PAN},this.target0=this.target.clone(),this.position0=this.object.position.clone(),this.zoom0=this.object.zoom,this._domElementKeyEvents=null,this.getPolarAngle=function(){return a.phi},this.getAzimuthalAngle=function(){return a.theta},this.getDistance=function(){return this.object.position.distanceTo(this.target)},this.listenToKeyEvents=function(V){V.addEventListener("keydown",q),this._domElementKeyEvents=V},this.stopListenToKeyEvents=function(){this._domElementKeyEvents.removeEventListener("keydown",q),this._domElementKeyEvents=null},this.saveState=function(){n.target0.copy(n.target),n.position0.copy(n.object.position),n.zoom0=n.object.zoom},this.reset=function(){n.target.copy(n.target0),n.object.position.copy(n.position0),n.object.zoom=n.zoom0,n.object.updateProjectionMatrix(),n.dispatchEvent(ac),n.update(),s=r.NONE},this.update=function(){const V=new H,pt=new An().setFromUnitVectors(t.up,new H(0,1,0)),wt=pt.clone().invert(),St=new H,Pt=new An,Ft=new H,Ht=2*Math.PI;return function(_t=null){const K=n.object.position;V.copy(K).sub(n.target),V.applyQuaternion(pt),a.setFromVector3(V),n.autoRotate&&s===r.NONE&&j(T(_t)),n.enableDamping?(a.theta+=c.theta*n.dampingFactor,a.phi+=c.phi*n.dampingFactor):(a.theta+=c.theta,a.phi+=c.phi);let vt=n.minAzimuthAngle,bt=n.maxAzimuthAngle;isFinite(vt)&&isFinite(bt)&&(vt<-Math.PI?vt+=Ht:vt>Math.PI&&(vt-=Ht),bt<-Math.PI?bt+=Ht:bt>Math.PI&&(bt-=Ht),vt<=bt?a.theta=Math.max(vt,Math.min(bt,a.theta)):a.theta=a.theta>(vt+bt)/2?Math.max(vt,a.theta):Math.min(bt,a.theta)),a.phi=Math.max(n.minPolarAngle,Math.min(n.maxPolarAngle,a.phi)),a.makeSafe(),n.enableDamping===!0?n.target.addScaledVector(h,n.dampingFactor):n.target.add(h),n.target.sub(n.cursor),n.target.clampLength(n.minTargetRadius,n.maxTargetRadius),n.target.add(n.cursor),n.zoomToCursor&&C||n.object.isOrthographicCamera?a.radius=U(a.radius):a.radius=U(a.radius*l),V.setFromSpherical(a),V.applyQuaternion(wt),K.copy(n.target).add(V),n.object.lookAt(n.target),n.enableDamping===!0?(c.theta*=1-n.dampingFactor,c.phi*=1-n.dampingFactor,h.multiplyScalar(1-n.dampingFactor)):(c.set(0,0,0),h.set(0,0,0));let Ut=!1;if(n.zoomToCursor&&C){let It=null;if(n.object.isPerspectiveCamera){const Xt=V.length();It=U(Xt*l);const Zt=Xt-It;n.object.position.addScaledVector(y,Zt),n.object.updateMatrixWorld()}else if(n.object.isOrthographicCamera){const Xt=new H(L.x,L.y,0);Xt.unproject(n.object),n.object.zoom=Math.max(n.minZoom,Math.min(n.maxZoom,n.object.zoom/l)),n.object.updateProjectionMatrix(),Ut=!0;const Zt=new H(L.x,L.y,0);Zt.unproject(n.object),n.object.position.sub(Zt).add(Xt),n.object.updateMatrixWorld(),It=V.length()}else console.warn("WARNING: OrbitControls.js encountered an unknown camera type - zoom to cursor disabled."),n.zoomToCursor=!1;It!==null&&(this.screenSpacePanning?n.target.set(0,0,-1).transformDirection(n.object.matrix).multiplyScalar(It).add(n.object.position):(Pr.origin.copy(n.object.position),Pr.direction.set(0,0,-1).transformDirection(n.object.matrix),Math.abs(n.object.up.dot(Pr.direction))<u0?t.lookAt(n.target):(lc.setFromNormalAndCoplanarPoint(n.object.up,n.target),Pr.intersectPlane(lc,n.target))))}else n.object.isOrthographicCamera&&(n.object.zoom=Math.max(n.minZoom,Math.min(n.maxZoom,n.object.zoom/l)),n.object.updateProjectionMatrix(),Ut=!0);return l=1,C=!1,Ut||St.distanceToSquared(n.object.position)>o||8*(1-Pt.dot(n.object.quaternion))>o||Ft.distanceToSquared(n.target)>0?(n.dispatchEvent(ac),St.copy(n.object.position),Pt.copy(n.object.quaternion),Ft.copy(n.target),!0):!1}}(),this.dispose=function(){n.domElement.removeEventListener("contextmenu",at),n.domElement.removeEventListener("pointerdown",it),n.domElement.removeEventListener("pointercancel",w),n.domElement.removeEventListener("wheel",J),n.domElement.removeEventListener("pointermove",R),n.domElement.removeEventListener("pointerup",w),n._domElementKeyEvents!==null&&(n._domElementKeyEvents.removeEventListener("keydown",q),n._domElementKeyEvents=null)};const n=this,r={NONE:-1,ROTATE:0,DOLLY:1,PAN:2,TOUCH_ROTATE:3,TOUCH_PAN:4,TOUCH_DOLLY_PAN:5,TOUCH_DOLLY_ROTATE:6};let s=r.NONE;const o=1e-6,a=new sc,c=new sc;let l=1;const h=new H,f=new At,m=new At,p=new At,_=new At,x=new At,d=new At,u=new At,M=new At,g=new At,y=new H,L=new At;let C=!1;const D=[],F={};function T(V){return V!==null?2*Math.PI/60*n.autoRotateSpeed*V:2*Math.PI/60/60*n.autoRotateSpeed}function E(V){const pt=Math.abs(V)/(100*(window.devicePixelRatio|0));return Math.pow(.95,n.zoomSpeed*pt)}function j(V){c.theta-=V}function O(V){c.phi-=V}const B=function(){const V=new H;return function(wt,St){V.setFromMatrixColumn(St,0),V.multiplyScalar(-wt),h.add(V)}}(),S=function(){const V=new H;return function(wt,St){n.screenSpacePanning===!0?V.setFromMatrixColumn(St,1):(V.setFromMatrixColumn(St,0),V.crossVectors(n.object.up,V)),V.multiplyScalar(wt),h.add(V)}}(),b=function(){const V=new H;return function(wt,St){const Pt=n.domElement;if(n.object.isPerspectiveCamera){const Ft=n.object.position;V.copy(Ft).sub(n.target);let Ht=V.length();Ht*=Math.tan(n.object.fov/2*Math.PI/180),B(2*wt*Ht/Pt.clientHeight,n.object.matrix),S(2*St*Ht/Pt.clientHeight,n.object.matrix)}else n.object.isOrthographicCamera?(B(wt*(n.object.right-n.object.left)/n.object.zoom/Pt.clientWidth,n.object.matrix),S(St*(n.object.top-n.object.bottom)/n.object.zoom/Pt.clientHeight,n.object.matrix)):(console.warn("WARNING: OrbitControls.js encountered an unknown camera type - pan disabled."),n.enablePan=!1)}}();function v(V){n.object.isPerspectiveCamera||n.object.isOrthographicCamera?l/=V:(console.warn("WARNING: OrbitControls.js encountered an unknown camera type - dolly/zoom disabled."),n.enableZoom=!1)}function A(V){n.object.isPerspectiveCamera||n.object.isOrthographicCamera?l*=V:(console.warn("WARNING: OrbitControls.js encountered an unknown camera type - dolly/zoom disabled."),n.enableZoom=!1)}function I(V,pt){if(!n.zoomToCursor)return;C=!0;const wt=n.domElement.getBoundingClientRect(),St=V-wt.left,Pt=pt-wt.top,Ft=wt.width,Ht=wt.height;L.x=St/Ft*2-1,L.y=-(Pt/Ht)*2+1,y.set(L.x,L.y,1).unproject(n.object).sub(n.object.position).normalize()}function U(V){return Math.max(n.minDistance,Math.min(n.maxDistance,V))}function P(V){f.set(V.clientX,V.clientY)}function N(V){I(V.clientX,V.clientX),u.set(V.clientX,V.clientY)}function Y(V){_.set(V.clientX,V.clientY)}function Z(V){m.set(V.clientX,V.clientY),p.subVectors(m,f).multiplyScalar(n.rotateSpeed);const pt=n.domElement;j(2*Math.PI*p.x/pt.clientHeight),O(2*Math.PI*p.y/pt.clientHeight),f.copy(m),n.update()}function nt(V){M.set(V.clientX,V.clientY),g.subVectors(M,u),g.y>0?v(E(g.y)):g.y<0&&A(E(g.y)),u.copy(M),n.update()}function ht(V){x.set(V.clientX,V.clientY),d.subVectors(x,_).multiplyScalar(n.panSpeed),b(d.x,d.y),_.copy(x),n.update()}function gt(V){I(V.clientX,V.clientY),V.deltaY<0?A(E(V.deltaY)):V.deltaY>0&&v(E(V.deltaY)),n.update()}function xt(V){let pt=!1;switch(V.code){case n.keys.UP:V.ctrlKey||V.metaKey||V.shiftKey?O(2*Math.PI*n.rotateSpeed/n.domElement.clientHeight):b(0,n.keyPanSpeed),pt=!0;break;case n.keys.BOTTOM:V.ctrlKey||V.metaKey||V.shiftKey?O(-2*Math.PI*n.rotateSpeed/n.domElement.clientHeight):b(0,-n.keyPanSpeed),pt=!0;break;case n.keys.LEFT:V.ctrlKey||V.metaKey||V.shiftKey?j(2*Math.PI*n.rotateSpeed/n.domElement.clientHeight):b(n.keyPanSpeed,0),pt=!0;break;case n.keys.RIGHT:V.ctrlKey||V.metaKey||V.shiftKey?j(-2*Math.PI*n.rotateSpeed/n.domElement.clientHeight):b(-n.keyPanSpeed,0),pt=!0;break}pt&&(V.preventDefault(),n.update())}function Et(V){if(D.length===1)f.set(V.pageX,V.pageY);else{const pt=Rt(V),wt=.5*(V.pageX+pt.x),St=.5*(V.pageY+pt.y);f.set(wt,St)}}function ct(V){if(D.length===1)_.set(V.pageX,V.pageY);else{const pt=Rt(V),wt=.5*(V.pageX+pt.x),St=.5*(V.pageY+pt.y);_.set(wt,St)}}function ut(V){const pt=Rt(V),wt=V.pageX-pt.x,St=V.pageY-pt.y,Pt=Math.sqrt(wt*wt+St*St);u.set(0,Pt)}function Mt(V){n.enableZoom&&ut(V),n.enablePan&&ct(V)}function k(V){n.enableZoom&&ut(V),n.enableRotate&&Et(V)}function tt(V){if(D.length==1)m.set(V.pageX,V.pageY);else{const wt=Rt(V),St=.5*(V.pageX+wt.x),Pt=.5*(V.pageY+wt.y);m.set(St,Pt)}p.subVectors(m,f).multiplyScalar(n.rotateSpeed);const pt=n.domElement;j(2*Math.PI*p.x/pt.clientHeight),O(2*Math.PI*p.y/pt.clientHeight),f.copy(m)}function G(V){if(D.length===1)x.set(V.pageX,V.pageY);else{const pt=Rt(V),wt=.5*(V.pageX+pt.x),St=.5*(V.pageY+pt.y);x.set(wt,St)}d.subVectors(x,_).multiplyScalar(n.panSpeed),b(d.x,d.y),_.copy(x)}function X(V){const pt=Rt(V),wt=V.pageX-pt.x,St=V.pageY-pt.y,Pt=Math.sqrt(wt*wt+St*St);M.set(0,Pt),g.set(0,Math.pow(M.y/u.y,n.zoomSpeed)),v(g.y),u.copy(M);const Ft=(V.pageX+pt.x)*.5,Ht=(V.pageY+pt.y)*.5;I(Ft,Ht)}function W(V){n.enableZoom&&X(V),n.enablePan&&G(V)}function et(V){n.enableZoom&&X(V),n.enableRotate&&tt(V)}function it(V){n.enabled!==!1&&(D.length===0&&(n.domElement.setPointerCapture(V.pointerId),n.domElement.addEventListener("pointermove",R),n.domElement.addEventListener("pointerup",w)),yt(V),V.pointerType==="touch"?Q(V):$(V))}function R(V){n.enabled!==!1&&(V.pointerType==="touch"?rt(V):st(V))}function w(V){Tt(V),D.length===0&&(n.domElement.releasePointerCapture(V.pointerId),n.domElement.removeEventListener("pointermove",R),n.domElement.removeEventListener("pointerup",w)),n.dispatchEvent(cc),s=r.NONE}function $(V){let pt;switch(V.button){case 0:pt=n.mouseButtons.LEFT;break;case 1:pt=n.mouseButtons.MIDDLE;break;case 2:pt=n.mouseButtons.RIGHT;break;default:pt=-1}switch(pt){case Yn.DOLLY:if(n.enableZoom===!1)return;N(V),s=r.DOLLY;break;case Yn.ROTATE:if(V.ctrlKey||V.metaKey||V.shiftKey){if(n.enablePan===!1)return;Y(V),s=r.PAN}else{if(n.enableRotate===!1)return;P(V),s=r.ROTATE}break;case Yn.PAN:if(V.ctrlKey||V.metaKey||V.shiftKey){if(n.enableRotate===!1)return;P(V),s=r.ROTATE}else{if(n.enablePan===!1)return;Y(V),s=r.PAN}break;default:s=r.NONE}s!==r.NONE&&n.dispatchEvent(Os)}function st(V){switch(s){case r.ROTATE:if(n.enableRotate===!1)return;Z(V);break;case r.DOLLY:if(n.enableZoom===!1)return;nt(V);break;case r.PAN:if(n.enablePan===!1)return;ht(V);break}}function J(V){n.enabled===!1||n.enableZoom===!1||s!==r.NONE||(V.preventDefault(),n.dispatchEvent(Os),gt(V),n.dispatchEvent(cc))}function q(V){n.enabled===!1||n.enablePan===!1||xt(V)}function Q(V){switch(lt(V),D.length){case 1:switch(n.touches.ONE){case jn.ROTATE:if(n.enableRotate===!1)return;Et(V),s=r.TOUCH_ROTATE;break;case jn.PAN:if(n.enablePan===!1)return;ct(V),s=r.TOUCH_PAN;break;default:s=r.NONE}break;case 2:switch(n.touches.TWO){case jn.DOLLY_PAN:if(n.enableZoom===!1&&n.enablePan===!1)return;Mt(V),s=r.TOUCH_DOLLY_PAN;break;case jn.DOLLY_ROTATE:if(n.enableZoom===!1&&n.enableRotate===!1)return;k(V),s=r.TOUCH_DOLLY_ROTATE;break;default:s=r.NONE}break;default:s=r.NONE}s!==r.NONE&&n.dispatchEvent(Os)}function rt(V){switch(lt(V),s){case r.TOUCH_ROTATE:if(n.enableRotate===!1)return;tt(V),n.update();break;case r.TOUCH_PAN:if(n.enablePan===!1)return;G(V),n.update();break;case r.TOUCH_DOLLY_PAN:if(n.enableZoom===!1&&n.enablePan===!1)return;W(V),n.update();break;case r.TOUCH_DOLLY_ROTATE:if(n.enableZoom===!1&&n.enableRotate===!1)return;et(V),n.update();break;default:s=r.NONE}}function at(V){n.enabled!==!1&&V.preventDefault()}function yt(V){D.push(V.pointerId)}function Tt(V){delete F[V.pointerId];for(let pt=0;pt<D.length;pt++)if(D[pt]==V.pointerId){D.splice(pt,1);return}}function lt(V){let pt=F[V.pointerId];pt===void 0&&(pt=new At,F[V.pointerId]=pt),pt.set(V.pageX,V.pageY)}function Rt(V){const pt=V.pointerId===D[0]?D[1]:D[0];return F[pt]}n.domElement.addEventListener("contextmenu",at),n.domElement.addEventListener("pointerdown",it),n.domElement.addEventListener("pointercancel",w),n.domElement.addEventListener("wheel",J,{passive:!1}),this.update()}}const d0={name:"OutputShader",uniforms:{tDiffuse:{value:null},toneMappingExposure:{value:1}},vertexShader:`
		precision highp float;

		uniform mat4 modelViewMatrix;
		uniform mat4 projectionMatrix;

		attribute vec3 position;
		attribute vec2 uv;

		varying vec2 vUv;

		void main() {

			vUv = uv;
			gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );

		}`,fragmentShader:`
	
		precision highp float;

		uniform sampler2D tDiffuse;

		#include <tonemapping_pars_fragment>
		#include <colorspace_pars_fragment>

		varying vec2 vUv;

		void main() {

			gl_FragColor = texture2D( tDiffuse, vUv );

			// tone mapping

			#ifdef LINEAR_TONE_MAPPING

				gl_FragColor.rgb = LinearToneMapping( gl_FragColor.rgb );

			#elif defined( REINHARD_TONE_MAPPING )

				gl_FragColor.rgb = ReinhardToneMapping( gl_FragColor.rgb );

			#elif defined( CINEON_TONE_MAPPING )

				gl_FragColor.rgb = OptimizedCineonToneMapping( gl_FragColor.rgb );

			#elif defined( ACES_FILMIC_TONE_MAPPING )

				gl_FragColor.rgb = ACESFilmicToneMapping( gl_FragColor.rgb );

			#elif defined( AGX_TONE_MAPPING )

				gl_FragColor.rgb = AgXToneMapping( gl_FragColor.rgb );

			#endif

			// color space

			#ifdef SRGB_TRANSFER

				gl_FragColor = sRGBTransferOETF( gl_FragColor );

			#endif

		}`};class f0 extends Ci{constructor(){super();const t=d0;this.uniforms=ji.clone(t.uniforms),this.material=new Zm({name:t.name,uniforms:this.uniforms,vertexShader:t.vertexShader,fragmentShader:t.fragmentShader}),this.fsQuad=new mo(this.material),this._outputColorSpace=null,this._toneMapping=null}render(t,e,n){this.uniforms.tDiffuse.value=n.texture,this.uniforms.toneMappingExposure.value=t.toneMappingExposure,(this._outputColorSpace!==t.outputColorSpace||this._toneMapping!==t.toneMapping)&&(this._outputColorSpace=t.outputColorSpace,this._toneMapping=t.toneMapping,this.material.defines={},te.getTransfer(this._outputColorSpace)===se&&(this.material.defines.SRGB_TRANSFER=""),this._toneMapping===gc?this.material.defines.LINEAR_TONE_MAPPING="":this._toneMapping===_c?this.material.defines.REINHARD_TONE_MAPPING="":this._toneMapping===vc?this.material.defines.CINEON_TONE_MAPPING="":this._toneMapping===to?this.material.defines.ACES_FILMIC_TONE_MAPPING="":this._toneMapping===xc&&(this.material.defines.AGX_TONE_MAPPING=""),this.material.needsUpdate=!0),this.renderToScreen===!0?(t.setRenderTarget(null),this.fsQuad.render(t)):(t.setRenderTarget(e),this.clear&&t.clear(t.autoClearColor,t.autoClearDepth,t.autoClearStencil),this.fsQuad.render(t))}dispose(){this.material.dispose(),this.fsQuad.dispose()}}class p0 extends Ci{constructor(t,e,n=null,r=null,s=null){super(),this.scene=t,this.camera=e,this.overrideMaterial=n,this.clearColor=r,this.clearAlpha=s,this.clear=!0,this.clearDepth=!1,this.needsSwap=!1,this._oldClearColor=new Dt}render(t,e,n){const r=t.autoClear;t.autoClear=!1;let s,o;this.overrideMaterial!==null&&(o=this.scene.overrideMaterial,this.scene.overrideMaterial=this.overrideMaterial),this.clearColor!==null&&(t.getClearColor(this._oldClearColor),t.setClearColor(this.clearColor)),this.clearAlpha!==null&&(s=t.getClearAlpha(),t.setClearAlpha(this.clearAlpha)),this.clearDepth==!0&&t.clearDepth(),t.setRenderTarget(this.renderToScreen?null:n),this.clear===!0&&t.clear(t.autoClearColor,t.autoClearDepth,t.autoClearStencil),t.render(this.scene,this.camera),this.clearColor!==null&&t.setClearColor(this._oldClearColor),this.clearAlpha!==null&&t.setClearAlpha(s),this.overrideMaterial!==null&&(this.scene.overrideMaterial=o),t.autoClear=r}}const m0={uniforms:{tDiffuse:{value:null},luminosityThreshold:{value:1},smoothWidth:{value:1},defaultColor:{value:new Dt(0)},defaultOpacity:{value:0}},vertexShader:`

		varying vec2 vUv;

		void main() {

			vUv = uv;

			gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );

		}`,fragmentShader:`

		uniform sampler2D tDiffuse;
		uniform vec3 defaultColor;
		uniform float defaultOpacity;
		uniform float luminosityThreshold;
		uniform float smoothWidth;

		varying vec2 vUv;

		void main() {

			vec4 texel = texture2D( tDiffuse, vUv );

			vec3 luma = vec3( 0.299, 0.587, 0.114 );

			float v = dot( texel.xyz, luma );

			vec4 outputColor = vec4( defaultColor.rgb, defaultOpacity );

			float alpha = smoothstep( luminosityThreshold, luminosityThreshold + smoothWidth, v );

			gl_FragColor = mix( outputColor, texel, alpha );

		}`};class Ai extends Ci{constructor(t,e,n,r){super(),this.strength=e!==void 0?e:1,this.radius=n,this.threshold=r,this.resolution=t!==void 0?new At(t.x,t.y):new At(256,256),this.clearColor=new Dt(0,0,0),this.renderTargetsHorizontal=[],this.renderTargetsVertical=[],this.nMips=5;let s=Math.round(this.resolution.x/2),o=Math.round(this.resolution.y/2);this.renderTargetBright=new Ke(s,o,{type:dn}),this.renderTargetBright.texture.name="UnrealBloomPass.bright",this.renderTargetBright.texture.generateMipmaps=!1;for(let f=0;f<this.nMips;f++){const m=new Ke(s,o,{type:dn});m.texture.name="UnrealBloomPass.h"+f,m.texture.generateMipmaps=!1,this.renderTargetsHorizontal.push(m);const p=new Ke(s,o,{type:dn});p.texture.name="UnrealBloomPass.v"+f,p.texture.generateMipmaps=!1,this.renderTargetsVertical.push(p),s=Math.round(s/2),o=Math.round(o/2)}const a=m0;this.highPassUniforms=ji.clone(a.uniforms),this.highPassUniforms.luminosityThreshold.value=r,this.highPassUniforms.smoothWidth.value=.01,this.materialHighPassFilter=new we({uniforms:this.highPassUniforms,vertexShader:a.vertexShader,fragmentShader:a.fragmentShader}),this.separableBlurMaterials=[];const c=[3,5,7,9,11];s=Math.round(this.resolution.x/2),o=Math.round(this.resolution.y/2);for(let f=0;f<this.nMips;f++)this.separableBlurMaterials.push(this.getSeperableBlurMaterial(c[f])),this.separableBlurMaterials[f].uniforms.invSize.value=new At(1/s,1/o),s=Math.round(s/2),o=Math.round(o/2);this.compositeMaterial=this.getCompositeMaterial(this.nMips),this.compositeMaterial.uniforms.blurTexture1.value=this.renderTargetsVertical[0].texture,this.compositeMaterial.uniforms.blurTexture2.value=this.renderTargetsVertical[1].texture,this.compositeMaterial.uniforms.blurTexture3.value=this.renderTargetsVertical[2].texture,this.compositeMaterial.uniforms.blurTexture4.value=this.renderTargetsVertical[3].texture,this.compositeMaterial.uniforms.blurTexture5.value=this.renderTargetsVertical[4].texture,this.compositeMaterial.uniforms.bloomStrength.value=e,this.compositeMaterial.uniforms.bloomRadius.value=.1;const l=[1,.8,.6,.4,.2];this.compositeMaterial.uniforms.bloomFactors.value=l,this.bloomTintColors=[new H(1,1,1),new H(1,1,1),new H(1,1,1),new H(1,1,1),new H(1,1,1)],this.compositeMaterial.uniforms.bloomTintColors.value=this.bloomTintColors;const h=sl;this.copyUniforms=ji.clone(h.uniforms),this.blendMaterial=new we({uniforms:this.copyUniforms,vertexShader:h.vertexShader,fragmentShader:h.fragmentShader,blending:Fs,depthTest:!1,depthWrite:!1,transparent:!0}),this.enabled=!0,this.needsSwap=!1,this._oldClearColor=new Dt,this.oldClearAlpha=1,this.basic=new De,this.fsQuad=new mo(null)}dispose(){for(let t=0;t<this.renderTargetsHorizontal.length;t++)this.renderTargetsHorizontal[t].dispose();for(let t=0;t<this.renderTargetsVertical.length;t++)this.renderTargetsVertical[t].dispose();this.renderTargetBright.dispose();for(let t=0;t<this.separableBlurMaterials.length;t++)this.separableBlurMaterials[t].dispose();this.compositeMaterial.dispose(),this.blendMaterial.dispose(),this.basic.dispose(),this.fsQuad.dispose()}setSize(t,e){let n=Math.round(t/2),r=Math.round(e/2);this.renderTargetBright.setSize(n,r);for(let s=0;s<this.nMips;s++)this.renderTargetsHorizontal[s].setSize(n,r),this.renderTargetsVertical[s].setSize(n,r),this.separableBlurMaterials[s].uniforms.invSize.value=new At(1/n,1/r),n=Math.round(n/2),r=Math.round(r/2)}render(t,e,n,r,s){t.getClearColor(this._oldClearColor),this.oldClearAlpha=t.getClearAlpha();const o=t.autoClear;t.autoClear=!1,t.setClearColor(this.clearColor,0),s&&t.state.buffers.stencil.setTest(!1),this.renderToScreen&&(this.fsQuad.material=this.basic,this.basic.map=n.texture,t.setRenderTarget(null),t.clear(),this.fsQuad.render(t)),this.highPassUniforms.tDiffuse.value=n.texture,this.highPassUniforms.luminosityThreshold.value=this.threshold,this.fsQuad.material=this.materialHighPassFilter,t.setRenderTarget(this.renderTargetBright),t.clear(),this.fsQuad.render(t);let a=this.renderTargetBright;for(let c=0;c<this.nMips;c++)this.fsQuad.material=this.separableBlurMaterials[c],this.separableBlurMaterials[c].uniforms.colorTexture.value=a.texture,this.separableBlurMaterials[c].uniforms.direction.value=Ai.BlurDirectionX,t.setRenderTarget(this.renderTargetsHorizontal[c]),t.clear(),this.fsQuad.render(t),this.separableBlurMaterials[c].uniforms.colorTexture.value=this.renderTargetsHorizontal[c].texture,this.separableBlurMaterials[c].uniforms.direction.value=Ai.BlurDirectionY,t.setRenderTarget(this.renderTargetsVertical[c]),t.clear(),this.fsQuad.render(t),a=this.renderTargetsVertical[c];this.fsQuad.material=this.compositeMaterial,this.compositeMaterial.uniforms.bloomStrength.value=this.strength,this.compositeMaterial.uniforms.bloomRadius.value=this.radius,this.compositeMaterial.uniforms.bloomTintColors.value=this.bloomTintColors,t.setRenderTarget(this.renderTargetsHorizontal[0]),t.clear(),this.fsQuad.render(t),this.fsQuad.material=this.blendMaterial,this.copyUniforms.tDiffuse.value=this.renderTargetsHorizontal[0].texture,s&&t.state.buffers.stencil.setTest(!0),this.renderToScreen?(t.setRenderTarget(null),this.fsQuad.render(t)):(t.setRenderTarget(n),this.fsQuad.render(t)),t.setClearColor(this._oldClearColor,this.oldClearAlpha),t.autoClear=o}getSeperableBlurMaterial(t){const e=[];for(let n=0;n<t;n++)e.push(.39894*Math.exp(-.5*n*n/(t*t))/t);return new we({defines:{KERNEL_RADIUS:t},uniforms:{colorTexture:{value:null},invSize:{value:new At(.5,.5)},direction:{value:new At(.5,.5)},gaussianCoefficients:{value:e}},vertexShader:`varying vec2 vUv;
				void main() {
					vUv = uv;
					gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
				}`,fragmentShader:`#include <common>
				varying vec2 vUv;
				uniform sampler2D colorTexture;
				uniform vec2 invSize;
				uniform vec2 direction;
				uniform float gaussianCoefficients[KERNEL_RADIUS];

				void main() {
					float weightSum = gaussianCoefficients[0];
					vec3 diffuseSum = texture2D( colorTexture, vUv ).rgb * weightSum;
					for( int i = 1; i < KERNEL_RADIUS; i ++ ) {
						float x = float(i);
						float w = gaussianCoefficients[i];
						vec2 uvOffset = direction * invSize * x;
						vec3 sample1 = texture2D( colorTexture, vUv + uvOffset ).rgb;
						vec3 sample2 = texture2D( colorTexture, vUv - uvOffset ).rgb;
						diffuseSum += (sample1 + sample2) * w;
						weightSum += 2.0 * w;
					}
					gl_FragColor = vec4(diffuseSum/weightSum, 1.0);
				}`})}getCompositeMaterial(t){return new we({defines:{NUM_MIPS:t},uniforms:{blurTexture1:{value:null},blurTexture2:{value:null},blurTexture3:{value:null},blurTexture4:{value:null},blurTexture5:{value:null},bloomStrength:{value:1},bloomFactors:{value:null},bloomTintColors:{value:null},bloomRadius:{value:0}},vertexShader:`varying vec2 vUv;
				void main() {
					vUv = uv;
					gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
				}`,fragmentShader:`varying vec2 vUv;
				uniform sampler2D blurTexture1;
				uniform sampler2D blurTexture2;
				uniform sampler2D blurTexture3;
				uniform sampler2D blurTexture4;
				uniform sampler2D blurTexture5;
				uniform float bloomStrength;
				uniform float bloomRadius;
				uniform float bloomFactors[NUM_MIPS];
				uniform vec3 bloomTintColors[NUM_MIPS];

				float lerpBloomFactor(const in float factor) {
					float mirrorFactor = 1.2 - factor;
					return mix(factor, mirrorFactor, bloomRadius);
				}

				void main() {
					gl_FragColor = bloomStrength * ( lerpBloomFactor(bloomFactors[0]) * vec4(bloomTintColors[0], 1.0) * texture2D(blurTexture1, vUv) +
						lerpBloomFactor(bloomFactors[1]) * vec4(bloomTintColors[1], 1.0) * texture2D(blurTexture2, vUv) +
						lerpBloomFactor(bloomFactors[2]) * vec4(bloomTintColors[2], 1.0) * texture2D(blurTexture3, vUv) +
						lerpBloomFactor(bloomFactors[3]) * vec4(bloomTintColors[3], 1.0) * texture2D(blurTexture4, vUv) +
						lerpBloomFactor(bloomFactors[4]) * vec4(bloomTintColors[4], 1.0) * texture2D(blurTexture5, vUv) );
				}`})}}Ai.BlurDirectionX=new At(1,0);Ai.BlurDirectionY=new At(0,1);function g0(i){const{LITE:t}=i,e=new $c({antialias:!0});i.renderer=e,e.setPixelRatio(Math.min(devicePixelRatio,i.Q.dpr)),e.setSize(innerWidth,innerHeight),e.shadowMap.enabled=!0,e.shadowMap.type=pc,e.outputColorSpace=he,e.toneMapping=to,e.toneMappingExposure=1.1,i.root.prepend(e.domElement);const n=new Kc;i.scene=n,n.fog=new co(10471398,50,120);const r=new Fe(45,innerWidth/innerHeight,.1,200);i.camera=r;const s=new h0(r,e.domElement);i.controls=s,s.enableDamping=!0,s.dampingFactor=.08,s.minDistance=7,s.maxDistance=75,s.maxPolarAngle=1.38,s.enablePan=!1;const o=new l0(e);i.composer=o,o.setPixelRatio(Math.min(devicePixelRatio,i.Q.dpr)),o.setSize(innerWidth,innerHeight),o.addPass(new p0(n,r));const a=new Ai(new At(innerWidth/2,innerHeight/2),.4,.55,.85);i.bloom=a,o.addPass(a),o.addPass(new f0)}function _0(i){const{LITE:t,renderer:e,scene:n}=i,r={gain:{value:1},cloud:{value:0},storm:{value:0},flash:{value:0},top:{value:new Dt},hor:{value:new Dt},sunDir:{value:new H(12,20,8).normalize()},night:{value:0},time:{value:0}};i.skyU=r;const s=new Bt(new ie(95,48,24),new we({side:Me,depthWrite:!1,fog:!1,uniforms:r,vertexShader:"varying vec3 vDir; void main(){ vDir = normalize(position); gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.); }",fragmentShader:`uniform vec3 top, hor, sunDir; uniform float night, time, cloud, flash, storm, gain; varying vec3 vDir;
    float hash(vec3 p){ return fract(sin(dot(p, vec3(12.9898,78.233,45.164))) * 43758.5453); }
    float h2(vec2 p){ return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453); }
    float n2(vec2 p){ vec2 i = floor(p), f = fract(p); f = f*f*(3. - 2.*f);
      return mix(mix(h2(i), h2(i + vec2(1.,0.)), f.x), mix(h2(i + vec2(0.,1.)), h2(i + vec2(1.,1.)), f.x), f.y); }
    float fbm(vec2 p){ float a = .5, s = 0.; for(int i=0;i<5;i++){ s += a*n2(p); p = p*2.02 + 11.3; a *= .5; } return s; }
    void main(){
      vec3 d = normalize(vDir); float h = clamp(d.y*.5 + .5, 0., 1.);
      vec3 col = mix(hor, top, smoothstep(.3, .95, h));
      col = mix(col, hor * 1.12, smoothstep(.52, .5, h) * .5); // dải sáng nhẹ quanh chân trời
      float s = max(dot(d, sunDir), 0.);
      vec3 sunCol = mix(vec3(1., .82, .55), vec3(.8, .88, 1.), night);
      col += sunCol * (pow(s, 1200.) * mix(6., 2.5, night) + pow(s, 90.) * mix(.5, .12, night) + pow(s, 10.) * mix(.3, .08, night)) * (1. - cloud*.9);
      vec3 c = floor(d * 170.); float st = step(.9972, hash(c)) * night * smoothstep(.5, .7, h) * (1. - cloud);
      col += st * (.55 + .45 * sin(time * 2. + hash(c + 1.) * 30.));
      // mây thật trên vòm trời: nhiễu fbm chiếu lên mặt phẳng, trôi chậm, dày theo độ che phủ
      if(d.y > -.02){
        vec2 cp = d.xz / (d.y + .22) * 1.15 + vec2(time*.006, time*.0025);
        float n = fbm(cp) + (n2(cp*4.3 - time*.012) - .5) * .1;
        float cover = mix(.64, .3, cloud);
        float dens = smoothstep(cover, cover + .26, n) * smoothstep(-.02, .17, d.y);
        float thin = smoothstep(cover + .42, cover, n);                       // rìa mỏng sáng, lõi dày tối
        vec3 cDay = mix(vec3(.6, .64, .7), vec3(1.), thin);
        vec3 cc = mix(vec3(.022, .03, .055) + sunCol*thin*.035, cDay, 1. - night);
        cc = mix(cc, cc * hor * 1.7, .38);                                    // nhuốm màu chân trời (bình minh, hoàng hôn)
        cc += sunCol * pow(s, 5.) * thin * mix(.4, .12, night);               // viền sáng quanh mặt trời / trăng
        cc *= 1. - storm*.5 - cloud*.16;
        col = mix(col, cc, dens * .93);
      }
      col += flash * vec3(.55, .6, .75);
      gl_FragColor = vec4(col * gain, 1.);
    }`}));s.renderOrder=-1,n.add(s);const o=new Kc;i.envScene=o,o.add(new Bt(s.geometry,s.material));const a=new qs(e);i.pmrem=a,i.envRT=null,i.envKey="",i.envAcc=9;const c=new Jm(14412031,4866100,.4);i.hemi=c,n.add(c);const l=new e0(16773590,1.6);i.sun=l,l.position.set(12,20,8),l.castShadow=!0,l.shadow.mapSize.set(i.Q.shadow,i.Q.shadow),l.shadow.bias=-5e-4,l.shadow.normalBias=.035,Object.assign(l.shadow.camera,{left:-13,right:13,top:13,bottom:-13,near:1,far:60}),n.add(l)}function v0(i){i.fbm3=s,i.detail=l,i.smooth=p,i.streak=T;const t=(E,j,O)=>{const B=Math.min(1,Math.max(0,(O-E)/(j-E)));return B*B*(3-2*B)};i.sst=t;const e=(E,j,O)=>{const B=Math.sin(E*127.1+j*311.7+O*74.7)*43758.5453;return B-Math.floor(B)},n=(E,j,O)=>E+(j-E)*O;function r(E,j,O){const B=Math.floor(E),S=Math.floor(j),b=Math.floor(O),v=E-B,A=j-S,I=O-b,U=v*v*(3-2*v),P=A*A*(3-2*A),N=I*I*(3-2*I);return n(n(n(e(B,S,b),e(B+1,S,b),U),n(e(B,S+1,b),e(B+1,S+1,b),U),P),n(n(e(B,S,b+1),e(B+1,S,b+1),U),n(e(B,S+1,b+1),e(B+1,S+1,b+1),U),P),N)}function s(E,j,O,B=4){let S=.5,b=0,v=0;for(let A=0;A<B;A++)b+=S*r(E,j,O),v+=S,E=E*2.03+1.7,j=j*2.03+4.1,O=O*2.03+2.9,S*=.5;return b/v}const o=`
  float dh(vec3 p){ return fract(sin(dot(p, vec3(127.1,311.7,74.7))) * 43758.5453); }
  float dn(vec3 p){ vec3 i = floor(p), f = fract(p); f = f*f*(3. - 2.*f);
    return mix(mix(mix(dh(i), dh(i+vec3(1.,0.,0.)), f.x), mix(dh(i+vec3(0.,1.,0.)), dh(i+vec3(1.,1.,0.)), f.x), f.y),
               mix(mix(dh(i+vec3(0.,0.,1.)), dh(i+vec3(1.,0.,1.)), f.x), mix(dh(i+vec3(0.,1.,1.)), dh(i+vec3(1.,1.,1.)), f.x), f.y), f.z); }
  float dfbm(vec3 p){ return dn(p)*.55 + dn(p*2.3 + 7.1)*.3 + dn(p*5.1 + 3.3)*.15; }`,a=new WeakMap,c=new WeakMap;function l(E,j={}){const{s:O=[6,6,6],bump:B=.012,vary:S=.16,rock:b=!1}=j,v=U=>U.toFixed(4),A=U=>Number(v(U)),I={uDS:{value:new H(...O.map(A))},uDVary:{value:A(S*2)},uDBump:{value:A(B)}};return E.onBeforeCompile=U=>{Object.assign(U.uniforms,I),U.vertexShader=U.vertexShader.replace("#include <common>",`#include <common>
attribute vec3 aLocalPos; varying vec3 vDP, vWN, vWPd;`).replace("#include <begin_vertex>",`#include <begin_vertex>
vDP = aLocalPos;`+(b?" vWN = normalize(mat3(modelMatrix) * objectNormal); vWPd = (modelMatrix * vec4(position, 1.)).xyz;":"")),U.fragmentShader=U.fragmentShader.replace("#include <common>",`#include <common>
uniform vec3 uDS; uniform float uDVary, uDBump; varying vec3 vDP, vWN, vWPd;`+o).replace("#include <color_fragment>",`#include <color_fragment>
        vec3 dP = vDP * uDS;
        float dFade = clamp(1.3 - length(fwidth(dP))*1.1, 0., 1.);            // xa thì tắt vân → không nhấp nháy
        float dH = mix(.5, dfbm(dP), dFade);
        diffuseColor.rgb *= 1. + (dH - .5) * uDVary;
        float rWet = 0.;
        ${b?`float rS = dn(vec3(vDP.y*9. + dn(vDP*1.3)*5., 3., 7.));                       // thớ đá nằm ngang
        diffuseColor.rgb *= .8 + .34*rS;
        float rC = abs(dn(vDP*vec3(10., 2.2, 10.) + 11.) - .5) + smoothstep(.35, .6, dn(vDP*2.1 + 5.))*.1;   // chỉ nứt ở vài vùng                                   // khe nứt dọc
        diffuseColor.rgb *= mix(.62, 1., smoothstep(0., .035, rC) * dFade + 1. - dFade);
        float mN = dfbm(vWPd*3.1), moss = smoothstep(.42, .78, vWN.y) * smoothstep(.34, .6, mN); // rêu phủ mặt ngửa, loang lổ
        diffuseColor.rgb = mix(diffuseColor.rgb, vec3(.1, .155, .055)*(.65 + mN), moss);
        diffuseColor.rgb = mix(diffuseColor.rgb, vec3(.5, .52, .42), smoothstep(.72, .8, dn(vWPd*9.))*.35*(1. - moss)); // địa y
        rWet = smoothstep(1.15, .45, length((vWPd.xz - vec2(7.2, -.45))*vec2(1., .5))) * step(.3, vWPd.y); // đá ướt quanh thác
        diffuseColor.rgb *= mix(1., .5, rWet);`:""}`).replace("#include <roughnessmap_fragment>",`#include <roughnessmap_fragment>
 roughnessFactor = mix(roughnessFactor, .28, rWet);`).replace("#include <normal_fragment_maps>",`#include <normal_fragment_maps>
        { vec3 dpx = dFdx(-vViewPosition), dpy = dFdy(-vViewPosition);
          vec3 r1 = cross(dpy, normal), r2 = cross(normal, dpx); float det = dot(dpx, r1);
          vec3 grad = sign(det) * (dFdx(dH)*r1 + dFdy(dH)*r2);
          normal = normalize(abs(det)*normal - uDBump*grad); }`)},E.userData.detail=!0,E.customProgramCacheKey=()=>"detail"+b,a.set(E,j),E}const h=[];i.unlit=h;const f=E=>(h.push([E,E.color.clone()]),E);i.U=f;const m=(E,j={})=>{const{d:O,...B}=j,S=new ze({color:E,roughness:.85,flatShading:!0,...B});return O===!1?S:l(S,O)};i.M=m;function p(E){if(!E.flatShading)return E;let j=c.get(E);return j||(j=E.clone(),j.flatShading=!1,a.has(E)&&l(j,a.get(E)),c.set(E,j)),j}const _=E=>{const j=E.parameters??{};return/Sphere|Torus|Tube/.test(E.type)||/Cylinder|Cone/.test(E.type)&&j.radialSegments>=8||E.type==="IcosahedronGeometry"&&j.detail>=1},x=(E,j)=>j.isMaterial&&j.flatShading&&_(E)?p(j):j;i.fit=x;const d={stone:m(11774098,{roughness:.92,d:{s:[5,5,5],bump:.022,vary:.22}}),wood:m(9383716,{roughness:.55,d:{s:[16,5,16],bump:.004,vary:.14}}),gold:m(14263361,{metalness:.85,roughness:.32,d:!1}),rock:m(5984071,{roughness:.95,d:{s:[3.5,3.5,3.5],bump:.04,vary:.3}}),trunk:m(4863014,{roughness:.95,d:{s:[14,3,14],bump:.02,vary:.35}}),paper:m(15327176,{roughness:.9,d:{s:[7,7,7],bump:.003,vary:.07}})};i.MAT=d;const u=l(new ze({vertexColors:!0,roughness:.95}),{s:[7,7,7],bump:.07,vary:.3,rock:!0});i.rockMat=u;const M=[];i.lanternMats=M;const g=[],y=[],L=[];i.trees=g,i.reeds=y,i.blossomSpots=L;const C=()=>{const E=m(16742973,{emissive:16734751,emissiveIntensity:.4,flatShading:!1,d:!1});return M.push(E),E};i.lanternMat=C;const D=(E,j,O=0,B=0,S=0)=>{const b=new Bt(E,x(E,j));return b.position.set(O,B,S),b.castShadow=b.receiveShadow=!0,b};i.mesh=D;const F=(E,j,O,B,S,b,v)=>D(new $e(E,j,O),B,S,b,v);i.box=F;function T(E,j,O,B,S,b){const v=E.createLinearGradient(0,O,0,O+S);v.addColorStop(0,"rgba(255,255,255,0)"),v.addColorStop(.5,`rgba(255,255,255,${b})`),v.addColorStop(1,"rgba(255,255,255,0)"),E.fillStyle=v,E.fillRect(j,O,B,S)}}function x0(i){const{TOWERS:t,detail:e,fbm3:n,rockMat:r,scene:s,sst:o,trees:a}=i;i.frontXZ=g,i.riverDist=L,i.freeGround=E;const c=10,l=.6,h=1.7,f=7.2;i.R=c,i.TOP=l,i.AMBER_Y=f;const m=[7.25,-1.85],p=1.25;i.POOL=m,i.POOL_R=p;const _=(()=>{const S=c*440/512/2,b=[],v=1,A=new At(S+S*Math.cos(v),-S*Math.sin(v)),I=new At(-Math.sin(v),-Math.cos(v)),U=new tl(new At(m[0],m[1]),A.clone().addScaledVector(I,-.9),A);for(let P=0;P<8;P++)b.push(U.getPoint(P/8));for(let P=0;P<=30;P++){const N=v+P/30*(Math.PI-v);b.push(new At(S+S*Math.cos(N),-S*Math.sin(N)))}for(let P=1;P<=40;P++){const N=P/40*Math.PI;b.push(new At(-S+S*Math.cos(N),S*Math.sin(N)))}return b.push(new At(-c-.06,0)),b})();i.RIVER=_;const x=(()=>{let S=0;return _.map((b,v)=>{const A=_[Math.max(0,v-1)],U=_[Math.min(_.length-1,v+1)].clone().sub(A).normalize(),P=new At(-U.y,U.x);return v&&(S+=b.distanceTo(_[v-1])),{p:b,n:P,d:S,w:h/2*(1+.17*Math.sin(S*1.15+1)+.09*Math.sin(S*2.7+.4))}})})();i.RIVER_EDGES=x;const d={nghisu:{d:2.4,side:-1},tangkinh:{d:3,side:-1},tradinh:{d:3.2,side:1}};i.PATHS=d;const u=3.7,M=3.05;i.PLAZA_X=u,i.BRIDGE_END=M;function g(S){const[b,,v]=t[S].pos,A=Math.hypot(b,v),I=d[S].d;return[b-b/A*I,v-v/A*I]}const y=l-.08;i.WY=y;function L(S,b){let v=1e9;for(let A=0;A<x.length-1;A++){const I=x[A],U=x[A+1],P=U.p.x-I.p.x,N=U.p.y-I.p.y,Y=Math.max(0,Math.min(1,((S-I.p.x)*P+(b-I.p.y)*N)/(P*P+N*N))),Z=Math.hypot(S-I.p.x-P*Y,b-I.p.y-N*Y)-(I.w+(U.w-I.w)*Y);Z<v&&(v=Z)}return Math.min(v,Math.hypot(S-m[0],b-m[1])-p)}const C=(S,b)=>l-.42*o(.3,-.45,L(S,b));i.groundY=C;const D=(S,b)=>{const v=c*440/512/2;return Math.hypot(S-v,b)<v||b>0&&Math.hypot(S+v,b)>v};i.isYin=D;const F=(S,b,v,A,I,U)=>{const P=I-v,N=U-A,Y=Math.max(0,Math.min(1,((S-v)*P+(b-A)*N)/(P*P+N*N)));return Math.hypot(S-v-P*Y,b-A-N*Y)},T=Object.keys(d).flatMap(S=>{const[b,v]=g(S),A=d[S].side;return[[b,v,A*u,0],[A*u,0,A*M,0]]});function E(S,b,v=!1){if(Math.hypot(S,b)>(v?9.6:8.9))return!1;for(const[A,I]of Object.entries(t)){if(A==="center")continue;if(A==="kieulau"&&v){if(Math.abs(S)<3.7&&Math.abs(b)<1.15)return!1;continue}const U=v?A==="nghisu"?3.25:A==="tangkinh"?2.85:2.35:A==="nghisu"?3.6:A==="kieulau"?3.4:2.7;if(Math.hypot(S-I.pos[0],b-I.pos[2])<U)return!1}if(Math.hypot(S-7.2,b-1)<(v?2.55:3.1)||L(S,b)<(v?.1:.45))return!1;for(const A of T)if(F(S,b,...A)<(v?.6:.75))return!1;for(const A of[-1,1])if(Math.hypot(S-A*u,b)<(v?1.33:1.5))return!1;if(!v){for(const A of a)if(Math.hypot(S-A.g.position.x,b-A.g.position.z)<.9)return!1}return!0}function j(){const b=document.createElement("canvas");b.width=b.height=2048;const v=b.getContext("2d"),A=2048/2/c,I=(tt,G)=>[2048/2+G*A,2048/2-tt*A],U=c*440/512/2,P=i.rng;v.fillStyle="#7f9a52",v.fillRect(0,0,2048,2048),v.fillStyle="#3d5843",v.fillRect(2048/2,0,2048/2,2048);let[N,Y]=I(-U,0);v.fillStyle="#7f9a52",v.beginPath(),v.arc(N,Y,U*A,0,7),v.fill(),[N,Y]=I(U,0),v.fillStyle="#3d5843",v.beginPath(),v.arc(N,Y,U*A,0,7),v.fill();const Z=["#93ab58","#6e8f44","#a3b266","#b0a86a","#86a44f","#5f8440"],nt=["#324d3a","#4a6549","#2a4034","#56704e","#4f5d4c","#3a5a52"];for(let tt=0;tt<7500;tt++){const G=P()*7,X=Math.sqrt(P())*c,W=Math.cos(G)*X,et=Math.sin(G)*X,[it,R]=I(W,et),w=8+P()*46,$=D(W,et)?nt:Z,st=$[Math.floor(P()*$.length)],J=v.createRadialGradient(it,R,0,it,R,w);J.addColorStop(0,st),J.addColorStop(1,st+"00"),v.globalAlpha=.12+P()*.3,v.fillStyle=J,v.fillRect(it-w,R-w,w*2,w*2)}v.globalAlpha=1;for(const[tt,G]of Object.entries(t)){if(tt==="center"||tt==="kieulau")continue;const[X,W]=I(G.pos[0],G.pos[2]),et=(tt==="nghisu"?4:3.1)*A,it=v.createRadialGradient(X,W,et*.55,X,W,et);it.addColorStop(0,"rgba(128,118,96,.75)"),it.addColorStop(1,"rgba(128,118,96,0)"),v.fillStyle=it,v.fillRect(X-et,W-et,2*et,2*et)}{const[tt,G]=I(7.2,1),X=3.8*A,W=v.createRadialGradient(tt,G,X*.5,tt,G,X);W.addColorStop(0,"rgba(96,90,80,.9)"),W.addColorStop(1,"rgba(96,90,80,0)"),v.fillStyle=W,v.fillRect(tt-X,G-X,2*X,2*X);for(let et=0;et<260;et++){const it=P()*7,R=1.9+P()*1.9,[w,$]=I(7.2+Math.cos(it)*R,1+Math.sin(it)*R),st=90+P()*80|0;v.fillStyle=`rgba(${st},${st-4},${st-12},${.4+P()*.5})`,v.beginPath(),v.ellipse(w,$,2+P()*7,2+P()*5,P()*3,0,7),v.fill()}}v.lineCap=v.lineJoin="round";const ht=tt=>{v.beginPath(),x.forEach(({p:G,n:X,w:W},et)=>{const[it,R]=I(G.x+X.x*(W+tt),G.y+X.y*(W+tt));et?v.lineTo(it,R):v.moveTo(it,R)});for(let G=x.length-1;G>=0;G--){const{p:X,n:W,w:et}=x[G],[it,R]=I(X.x-W.x*(et+tt),X.y-W.y*(et+tt));v.lineTo(it,R)}v.closePath()},gt=I(m[0],m[1]);for(const[tt,G]of[["rgba(104,94,72,.22)",.7],["rgba(112,100,76,.4)",.5],["rgba(124,112,88,.7)",.32],["#6d6452",.16],["#3c4a42",0],["#243636",-.3]])v.fillStyle=tt,ht(G),v.fill(),v.beginPath(),v.arc(gt[0],gt[1],Math.max(0,p+G)*A,0,7),v.fill();x.forEach(({p:tt,n:G,w:X})=>{for(let W=0;W<16;W++){const et=(X+(P()-.62)*.6)*(P()<.5?-1:1),[it,R]=I(tt.x+G.x*et+(P()-.5)*.3,tt.y+G.y*et+(P()-.5)*.3),w=105+P()*95|0;v.fillStyle=`rgba(${w},${w-6},${w-18},${.45+P()*.4})`,v.beginPath(),v.ellipse(it,R,2+P()*5,1.5+P()*3.5,P()*3,0,7),v.fill()}});const xt=Object.keys(d).map(tt=>{const[G,X]=g(tt),W=d[tt].side;return[[G,X],[W*u,0],[W*M,0]]}),Et=(tt,G,X)=>{v.strokeStyle=X,v.lineWidth=G*A,v.beginPath(),tt.forEach(([W,et],it)=>{const[R,w]=I(W,et);it?v.lineTo(R,w):v.moveTo(R,w)}),v.stroke()};xt.forEach(tt=>{Et(tt,1.45,"rgba(98,90,70,.3)"),Et(tt,1.15,"rgba(92,84,66,.6)"),Et(tt,.95,"#5f594b")});const ct=(tt,G=24)=>{const X=(P()-.5)*G;return`rgb(${tt[0]+X|0},${tt[1]+X|0},${tt[2]+X*.8|0})`},ut=(tt,G,X,W,et,it)=>{const[R,w]=I(tt,G);v.save(),v.translate(R,w),v.rotate(X+(P()-.5)*.08),v.fillStyle=it,v.beginPath(),v.roundRect?v.roundRect(-W*A/2,-et*A/2,W*A,et*A,4):v.rect(-W*A/2,-et*A/2,W*A,et*A),v.fill(),v.restore()};xt.forEach(tt=>{for(let G=0;G<tt.length-1;G++){const[X,W]=tt[G],[et,it]=tt[G+1],R=Math.hypot(et-X,it-W),w=(et-X)/R,$=(it-W)/R,st=Math.atan2(-w,$);for(let J=.12,q=0;J<R;J+=.3,q++){const Q=q%2?2:3;for(let rt=0;rt<Q;rt++){const at=(rt-(Q-1)/2)*(.86/Q);ut(X+w*J-$*at,W+$*J+w*at,st,.26,.86/Q-.04,ct([176,168,150]))}}}});for(const tt of[-1,1]){const G=tt<0?[74,76,84]:[214,206,188],[X,W]=I(tt*u,0);v.fillStyle=tt<0?"#33353b":"#8f8672",v.beginPath(),v.arc(X,W,1.28*A,0,7),v.fill(),v.fillStyle=ct(G),v.beginPath(),v.arc(X,W,.2*A,0,7),v.fill();for(let et=.24;et<1.2;et+=.24){const it=Math.round(2*Math.PI*(et+.12)/.3),R=P()*7;for(let w=0;w<it;w++){const $=R+w/it*2*Math.PI,st=$+2*Math.PI/it-.035/(et+.12);v.fillStyle=ct(G),v.beginPath(),v.arc(X,W,(et+.02)*A,$,st),v.arc(X,W,(et+.22)*A,st,$,!0),v.closePath(),v.fill()}}}const Mt=v.createRadialGradient(2048/2,2048/2,c*A*.93,2048/2,2048/2,c*A);Mt.addColorStop(0,"rgba(70,60,48,0)"),Mt.addColorStop(1,"rgba(70,60,48,.6)"),v.fillStyle=Mt,v.fillRect(0,0,2048,2048);const k=new Ze(b);return k.colorSpace=he,k.anisotropy=8,k}const O=new Dt,B=(S,b,v,A)=>(S.setHSL(.075+A*.02,.11,.19+A*.16+.03*Math.sin(b*7+A*9)),S.lerp(O.setHSL(.24+A*.04,.3,.15+A*.09),o(.5,.85,v)*o(.12,.5,b)*o(.3,.55,A)*.85));i.rockTint=B,(()=>{const v=[],A=[],I=[];for(let Et=0;Et<=64;Et++){const ct=c*Et/64;for(let ut=0;ut<300;ut++){const Mt=ut/300*Math.PI*2,k=Math.cos(Mt)*ct,tt=Math.sin(Mt)*ct;v.push(k,C(k,tt),tt),A.push(.5+tt/c/2,.5+k/c/2)}}for(let Et=0;Et<64;Et++)for(let ct=0;ct<300;ct++){const ut=Et*300+ct,Mt=Et*300+(ct+1)%300,k=ut+300,tt=Mt+300;I.push(ut,Mt,k,k,Mt,tt)}const U=new Jt;U.setAttribute("position",new Nt(v,3)),U.setAttribute("uv",new Nt(A,2)),U.setIndex(I),U.computeVertexNormals();const P=new Bt(U,e(new ze({map:j(),roughness:1}),{s:[11,11,11],bump:.018,vary:.3}));P.receiveShadow=!0,s.add(P);const N=36,Y=[],Z=[],nt=[],ht=new Dt;for(let Et=0;Et<=N;Et++){const ct=Et/N;for(let ut=0;ut<300;ut++){const Mt=ut/300*Math.PI*2,k=Math.cos(Mt),tt=Math.sin(Mt),G=C(k*c,tt*c);let X,W;if(ct<.14){const w=ct/.14;X=c*(1-.07*w),W=G+(-.7-G)*w}else{const w=(ct-.14)/.86;X=c*.93*Math.pow(1-w,.6),W=-.7-7.4*Math.pow(w,1.1)}const et=n(k*X*.32+3,W*.5,tt*X*.32+9,4),it=n(k*X*1.3,W*1.6+5,tt*X*1.3,3),R=o(0,.08,ct);X*=1+R*((et-.5)*.55+(it-.5)*.16),W+=R*(it-.5)*.5-(ct>.14?R*Math.max(0,n(k*X*.55+20,1,tt*X*.55+4,3)-.5)*5.5:0),Y.push(k*X,W,tt*X),B(ht,0,0,et*.6+it*.4),ct<.05&&ht.lerp(O.setRGB(.2,.17,.12),1-ct/.05),ht.multiplyScalar(1-.35*o(.1,.9,ct)),Z.push(ht.r,ht.g,ht.b)}}for(let Et=0;Et<N;Et++)for(let ct=0;ct<300;ct++){const ut=Et*300+ct,Mt=Et*300+(ct+1)%300,k=ut+300,tt=Mt+300;nt.push(ut,Mt,k,k,Mt,tt)}const gt=new Jt;gt.setAttribute("position",new Nt(Y,3)),gt.setAttribute("color",new Nt(Z,3)),gt.setIndex(nt),gt.computeVertexNormals();const xt=new Bt(gt,r);return xt.receiveShadow=!0,s.add(xt),P})()}function M0(i){const{POOL:t,POOL_R:e,R:n,RIVER_EDGES:r,U:s,WY:o,scene:a,streak:c}=i;i.animateRiver=D;function l(O,B,S,b="rgba(255,255,255,0)"){const v=document.createElement("canvas");v.width=O,v.height=B;const A=v.getContext("2d");A.fillStyle=b,A.fillRect(0,0,O,B);for(let U=0;U<S;U++)c(A,i.rng()*O,i.rng()*B,1+i.rng()*2.5,16+i.rng()*50,.15+i.rng()*.35);const I=new Ze(v);return I.wrapS=I.wrapT=bi,I}const h=l(64,256,70,"#c6c6c6");i.waterTex=h;const f={uTime:{value:0},uImpact:{value:new At(7.2,-1.2)},uIn:{value:new At(6.4,1.1)},uOut:{value:new At(7.2,0)}};i.waterU=f;function m(O,B){O.onBeforeCompile=S=>{S.uniforms.uTime=f.uTime,S.uniforms.uImpact=f.uImpact,S.uniforms.uIn=f.uIn,S.uniforms.uOut=f.uOut,S.vertexShader=S.vertexShader.replace("#include <common>",`#include <common>
attribute float aEdge; varying float vEdge; varying vec3 vWPos;`).replace("#include <project_vertex>",`#include <project_vertex>
vWPos = (modelMatrix * vec4(transformed, 1.)).xyz; vEdge = aEdge;`),S.fragmentShader=S.fragmentShader.replace("#include <common>",`#include <common>
varying vec3 vWPos; varying float vEdge; uniform float uTime; uniform vec2 uImpact, uIn, uOut;`).replace("#include <color_fragment>",`#include <color_fragment>
        float wFoam = 0.;
        ${B==="lake"?`float dIn = distance(vWPos.xz, uIn);                                // hồ trên núi
        float lf = sin(vWPos.x*21. + uTime*3.3) * sin(vWPos.z*23. - uTime*2.9);
        wFoam = smoothstep(.42, .08, dIn + lf*.08) * .9;                                    // bọt sủi chỗ dòng nguồn rơi xuống
        float sO = smoothstep(.85, .1, distance(vWPos.xz, uOut));                           // gần cửa tràn: nước tăng tốc, nổi vệt trắng dần
        float stN = sin(vWPos.x*40. + sin(vWPos.z*7. + uTime*5.)*1.6)*.5 + .5;
        wFoam = max(wFoam, sO*sO*(.15 + .6*stN));
        diffuseColor.rgb = mix(diffuseColor.rgb, vec3(1.), wFoam*.7);
        diffuseColor.rgb = mix(vec3(.5, .82, .76), diffuseColor.rgb, .3 + .7*smoothstep(0., .22, vEdge)); // ven bờ nông, nước nhạt màu`:B?`float edge = min(vMapUv.x, 1. - vMapUv.x);
        float fz = sin(vWPos.x*11. + uTime*2.) * sin(vWPos.z*13. - uTime*1.7);
        wFoam = smoothstep(.115, .055, edge + fz*.02);
        diffuseColor.rgb = mix(diffuseColor.rgb, vec3(1.), wFoam*.3);`:`float dI = distance(vWPos.xz, uImpact);            // hồ: bọt sủi quanh chỗ thác đổ
        float pf = sin(vWPos.x*17. + uTime*3.) * sin(vWPos.z*19. - uTime*2.6);
        wFoam = smoothstep(.85, .15, dI + pf*.14) * .95;
        diffuseColor.rgb = mix(diffuseColor.rgb, vec3(1.), wFoam*.75);`}`).replace("#include <normal_fragment_maps>",`#include <normal_fragment_maps>
        vec2 wp = vWPos.xz;
        float w1 = sin(wp.x*3.1 + uTime*1.7) * cos(wp.y*2.7 - uTime*1.3);
        float w2 = sin((wp.x + wp.y)*5.3 - uTime*2.4);
        float w3 = sin(wp.x*9.7 - wp.y*8.3 + uTime*3.1);
        vec3 pn = vec3(w1*.16 + w2*.07 + w3*.05, 0., cos(wp.y*3.3 + uTime*1.5)*.14 + w3*.05);
        ${B==="lake"?"float dL = distance(wp, uIn); pn.xz += normalize(wp - uIn + 1e-4) * sin(dL*22. - uTime*8.) * .24 * exp(-dL*2.);":B?"":"float dR = distance(wp, uImpact); pn.xz += normalize(wp - uImpact + 1e-4) * sin(dR*15. - uTime*7.) * .3 * exp(-dR*1.1);  // sóng vòng lan từ chân thác"}
        normal = normalize(normal + (viewMatrix * vec4(pn, 0.)).xyz);
        float wFr = pow(1. - clamp(dot(normalize(vViewPosition), normal), 0., 1.), 3.);
        diffuseColor.a = max(wFoam*.75, mix(.62, .96, wFr));
        ${B==="lake"?"diffuseColor.a *= smoothstep(0., .1, vEdge);   // mép hồ tan dần vào đá":""}`)},O.customProgramCacheKey=()=>"water"+B}const p={color:2784392,map:h,transparent:!0,opacity:.9,roughness:.06,metalness:.3,emissive:734544,emissiveIntensity:.08,depthWrite:!1,envMapIntensity:2.4},_=new ze(p);i.waterMat=_,m(_,!0);const x=new ze(p);i.poolMat=x,m(x,!1);const d=new ze(p);i.lakeMat=d,m(d,"lake");const u={value:1};i.fallLum=u;const M=(O,B,S=0,b=0)=>new we({transparent:!0,depthWrite:!1,side:Ee,uniforms:{uTime:f.uTime,uLum:u,uSpeed:{value:O},uSy:{value:B},uW:{value:S},uFade:{value:b}},vertexShader:"attribute float aWhite; varying vec2 vUv; varying float vW; void main(){ vUv = uv; vW = aWhite; gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.); }",fragmentShader:`uniform float uTime, uLum, uSpeed, uSy, uW, uFade; varying vec2 vUv; varying float vW;
    float h2(vec2 p){ return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453); }
    float n2(vec2 p){ vec2 i = floor(p), f = fract(p); f = f*f*(3. - 2.*f);
      return mix(mix(h2(i), h2(i + vec2(1.,0.)), f.x), mix(h2(i + vec2(0.,1.)), h2(i + vec2(1.,1.)), f.x), f.y); }
    void main(){
      float x = vUv.x, y = vUv.y*uSy, t = uTime*uSpeed, w = clamp(vW + uW, 0., 1.);
      float edge = smoothstep(0., .22, x) * smoothstep(1., .78, x);
      float a = n2(vec2(x*5., y*1.1 - t*1.0)), b = n2(vec2(x*23. + a*1.5, y*2.1 - t*1.9)), c = n2(vec2(x*64., y*5. - t*3.1));
      float dens = a*.42 + b*.4 + c*.18;
      float alpha = edge * smoothstep(.3, .62, dens + edge*.2 + w*.14);
      float white = clamp(b*.8 + c*.6 + w*.45 - .62, 0., 1.);
      vec3 col = mix(vec3(.3, .56, .68), vec3(1.), white);
      if(uFade > 0.) alpha *= smoothstep(0., uFade, vUv.y);                               // hiện dần ở đầu dòng
      gl_FragColor = vec4(col * uLum, clamp(alpha * (.42 + .6*white), 0., .94));
    }`});i.fallMaterial=M;const g=(()=>{const O=document.createElement("canvas");O.width=O.height=128;const B=O.getContext("2d");for(let S=0;S<7;S++){const b=40+i.rng()*48,v=44+i.rng()*40,A=20+i.rng()*22,I=B.createRadialGradient(b,v,0,b,v,A);I.addColorStop(0,"rgba(255,255,255,.45)"),I.addColorStop(1,"rgba(255,255,255,0)"),B.fillStyle=I,B.fillRect(0,0,128,128)}return new Ze(O)})();i.mistTex=g;const y=6,L=new Jt,C=[];{const O=[],B=[],S=[];r.forEach(({p:A,n:I,w:U,d:P},N)=>{for(let Y=0;Y<=y;Y++){const Z=Y/y,nt=(U+.1)*(1-2*Z);O.push(A.x+I.x*nt,o,A.y+I.y*nt),B.push(Z,P/2.5),C.push(P,Z)}if(N){const Y=(N-1)*(y+1),Z=N*(y+1);for(let nt=0;nt<y;nt++)S.push(Y+nt,Z+nt,Y+nt+1,Y+nt+1,Z+nt,Z+nt+1)}}),L.setAttribute("position",new Nt(O,3)),L.setAttribute("uv",new Nt(B,2)),L.setIndex(S),L.computeVertexNormals();const b=new Bt(L,_);b.receiveShadow=!0,b.renderOrder=1,a.add(b);const v=new Bt(new jr(e,32),x);v.rotation.x=-Math.PI/2,v.position.set(t[0],o-.005,t[1]),v.renderOrder=1,a.add(v)}function D(O){const B=L.attributes.position;for(let S=0;S<B.count;S++){const b=C[S*2],v=C[S*2+1],A=Math.sin(v*Math.PI),I=1+2.5*Math.exp(-b*.8);B.setY(S,o+.005+A*I*(.03*Math.sin(b*2.3-O*2.6+v*2.5)+.018*Math.sin(b*5.7+O*3.3-v*4))+A*i.cur.r*.022*Math.sin(b*13+O*9+v*11))}B.needsUpdate=!0,L.computeVertexNormals()}const F=l(64,256,120,"rgba(170,220,242,.45)");i.fallTex=F,F.repeat.set(1,2);const T=M(-1,4.5,.35),E=new Bt(new qn(r.at(-1).w*2,7.5),T);E.rotation.y=-Math.PI/2,E.position.set(-n-.08,o-3.75,0),a.add(E);const j=new Qt;i.mist=j,a.add(j);for(let O=0;O<7;O++)j.add(new Vr(s(new $i({map:g,color:16777215,transparent:!0,opacity:.35,depthWrite:!1}))))}function ol(i,t=!1){const e=i[0].index!==null,n=new Set(Object.keys(i[0].attributes)),r=new Set(Object.keys(i[0].morphAttributes)),s={},o={},a=i[0].morphTargetsRelative,c=new Jt;let l=0;for(let h=0;h<i.length;++h){const f=i[h];let m=0;if(e!==(f.index!==null))return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+h+". All geometries must have compatible attributes; make sure index attribute exists among all geometries, or in none of them."),null;for(const p in f.attributes){if(!n.has(p))return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+h+'. All geometries must have compatible attributes; make sure "'+p+'" attribute exists among all geometries, or in none of them.'),null;s[p]===void 0&&(s[p]=[]),s[p].push(f.attributes[p]),m++}if(m!==n.size)return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+h+". Make sure all geometries have the same number of attributes."),null;if(a!==f.morphTargetsRelative)return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+h+". .morphTargetsRelative must be consistent throughout all geometries."),null;for(const p in f.morphAttributes){if(!r.has(p))return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+h+".  .morphAttributes must be consistent throughout all geometries."),null;o[p]===void 0&&(o[p]=[]),o[p].push(f.morphAttributes[p])}if(t){let p;if(e)p=f.index.count;else if(f.attributes.position!==void 0)p=f.attributes.position.count;else return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+h+". The geometry must have either an index or a position attribute"),null;c.addGroup(l,p,h),l+=p}}if(e){let h=0;const f=[];for(let m=0;m<i.length;++m){const p=i[m].index;for(let _=0;_<p.count;++_)f.push(p.getX(_)+h);h+=i[m].attributes.position.count}c.setIndex(f)}for(const h in s){const f=uc(s[h]);if(!f)return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed while trying to merge the "+h+" attribute."),null;c.setAttribute(h,f)}for(const h in o){const f=o[h][0].length;if(f===0)break;c.morphAttributes=c.morphAttributes||{},c.morphAttributes[h]=[];for(let m=0;m<f;++m){const p=[];for(let x=0;x<o[h].length;++x)p.push(o[h][x][m]);const _=uc(p);if(!_)return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed while trying to merge the "+h+" morphAttribute."),null;c.morphAttributes[h].push(_)}}return c}function uc(i){let t,e,n,r=-1,s=0;for(let l=0;l<i.length;++l){const h=i[l];if(h.isInterleavedBufferAttribute)return console.error("THREE.BufferGeometryUtils: .mergeAttributes() failed. InterleavedBufferAttributes are not supported."),null;if(t===void 0&&(t=h.array.constructor),t!==h.array.constructor)return console.error("THREE.BufferGeometryUtils: .mergeAttributes() failed. BufferAttribute.array must be of consistent array types across matching attributes."),null;if(e===void 0&&(e=h.itemSize),e!==h.itemSize)return console.error("THREE.BufferGeometryUtils: .mergeAttributes() failed. BufferAttribute.itemSize must be consistent across matching attributes."),null;if(n===void 0&&(n=h.normalized),n!==h.normalized)return console.error("THREE.BufferGeometryUtils: .mergeAttributes() failed. BufferAttribute.normalized must be consistent across matching attributes."),null;if(r===-1&&(r=h.gpuType),r!==h.gpuType)return console.error("THREE.BufferGeometryUtils: .mergeAttributes() failed. BufferAttribute.gpuType must be consistent across matching attributes."),null;s+=h.array.length}const o=new t(s);let a=0;for(let l=0;l<i.length;++l)o.set(i[l].array,a),a+=i[l].array.length;const c=new le(o,e,n);return r!==void 0&&(c.gpuType=r),c}function y0(i,t=1e-4){t=Math.max(t,Number.EPSILON);const e={},n=i.getIndex(),r=i.getAttribute("position"),s=n?n.count:r.count;let o=0;const a=Object.keys(i.attributes),c={},l={},h=[],f=["getX","getY","getZ","getW"],m=["setX","setY","setZ","setW"];for(let M=0,g=a.length;M<g;M++){const y=a[M],L=i.attributes[y];c[y]=new le(new L.array.constructor(L.count*L.itemSize),L.itemSize,L.normalized);const C=i.morphAttributes[y];C&&(l[y]=new le(new C.array.constructor(C.count*C.itemSize),C.itemSize,C.normalized))}const p=t*.5,_=Math.log10(1/t),x=Math.pow(10,_),d=p*x;for(let M=0;M<s;M++){const g=n?n.getX(M):M;let y="";for(let L=0,C=a.length;L<C;L++){const D=a[L],F=i.getAttribute(D),T=F.itemSize;for(let E=0;E<T;E++)y+=`${~~(F[f[E]](g)*x+d)},`}if(y in e)h.push(e[y]);else{for(let L=0,C=a.length;L<C;L++){const D=a[L],F=i.getAttribute(D),T=i.morphAttributes[D],E=F.itemSize,j=c[D],O=l[D];for(let B=0;B<E;B++){const S=f[B],b=m[B];if(j[b](o,F[S](g)),T)for(let v=0,A=T.length;v<A;v++)O[v][b](o,T[v][S](g))}}e[y]=o,h.push(o),o++}}const u=i.clone();for(const M in i.attributes){const g=c[M];if(u.setAttribute(M,new le(g.array.slice(0,o*g.itemSize),g.itemSize,g.normalized)),M in l)for(let y=0;y<l[M].length;y++){const L=l[M][y];u.morphAttributes[M][y]=new le(L.array.slice(0,o*L.itemSize),L.itemSize,L.normalized)}}return u.setIndex(h),u}const S0={x:["y","z"],y:["x","z"],z:["x","y"]};function Ks(i,t,e=.06){const[n,r]=S0[t],s=(d,u)=>d*100003+u,o=new H,a=new H,c=new H,l=[];for(const d of i){const u=d;if(!u.isMesh||Array.isArray(u.material))throw new Error("axisRaycaster: chỉ hỗ trợ Mesh một vật liệu");u.updateWorldMatrix(!0,!1);const M=u.geometry,g=M.attributes.position,y=M.index?M.index.count:g.count,L=new Uint32Array(y);for(let D=0;D<y;D++)L[D]=M.index?M.index.getX(D):D;const C=new Map;for(let D=0;D<y/3;D++){o.fromBufferAttribute(g,L[D*3]).applyMatrix4(u.matrixWorld),a.fromBufferAttribute(g,L[D*3+1]).applyMatrix4(u.matrixWorld),c.fromBufferAttribute(g,L[D*3+2]).applyMatrix4(u.matrixWorld);const F=Math.floor(Math.min(o[n],a[n],c[n])/e),T=Math.floor(Math.max(o[n],a[n],c[n])/e),E=Math.floor(Math.min(o[r],a[r],c[r])/e),j=Math.floor(Math.max(o[r],a[r],c[r])/e);for(let O=F;O<=T;O++)for(let B=E;B<=j;B++){const S=s(O,B);let b=C.get(S);b||C.set(S,b=[]),b.push(D)}}l.push({mesh:u,inv:u.matrixWorld.clone().invert(),side:u.material.side,pos:g,tri:L,cells:C})}const h=new Hn,f=new Hn,m=new H,p=new H,_=new H,x=new H;return function(u,M){h.set(u,M);const g=s(Math.floor(u[n]/e),Math.floor(u[r]/e));let y;for(const L of l){const C=L.cells.get(g);if(C){f.copy(h).applyMatrix4(L.inv);for(const D of C){const F=L.tri[D*3],T=L.tri[D*3+1],E=L.tri[D*3+2];if(m.fromBufferAttribute(L.pos,F),p.fromBufferAttribute(L.pos,T),_.fromBufferAttribute(L.pos,E),!(L.side===Me?f.intersectTriangle(_,p,m,!0,x):f.intersectTriangle(m,p,_,L.side===pn,x)))continue;const O=x.clone().applyMatrix4(L.mesh.matrixWorld),B=h.origin.distanceTo(O);if(y&&B>=y.distance)continue;const S=new H;Oe.getNormal(m,p,_,S),y={point:O,distance:B,object:L.mesh,face:{a:F,b:T,c:E,normal:S,materialIndex:0},faceIndex:D}}}}return y}}function b0(i){const{M:t,POOL:e,POOL_R:n,TOP:r,U:s,WY:o,fallMaterial:a,fbm3:c,lakeMat:l,mesh:h,mistTex:f,poolMat:m,riverDist:p,rockMat:_,rockTint:x,scene:d,sst:u,streak:M,waterU:g}=i;i.boulder=v,i.animateSplash=Mt;function y(k,tt){let G=new fo(1,k);G.deleteAttribute("normal"),G.deleteAttribute("uv"),G=y0(G,1e-4);const X=G.attributes.position,W=new H,et=[];for(let it=0;it<X.count;it++)W.fromBufferAttribute(X,it),et.push(tt(W)??1),X.setXYZ(it,W.x,W.y,W.z);return G.computeVertexNormals(),G.userData.ao=et,G}function L(k,tt){const G=k.attributes.position,X=[],W=new Dt,et=k.userData.ao;for(let it=0;it<G.count;it++)x(W,G.getY(it),0,c(G.getX(it)*2.2+tt,G.getY(it)*2.2,G.getZ(it)*2.2,3)).multiplyScalar(et[it]),X.push(W.r,W.g,W.b);return k.setAttribute("color",new Nt(X,3)),k}function C(k,tt,G){const X=y(18,et=>{const it=et.x,R=et.y,w=et.z,$=(R+1)/2,st=1-Math.pow($,1.3)*.75,J=c(it*1.5+G*7.3,R*1.2,w*1.5+G*3.1,4),q=c(it*6+G,R*1.2,w*6,3),Q=c(it*14,R*9+G,w*14,2),rt=Math.pow(1-Math.abs(2*q-1),4),at=($*tt*1.9+J*2.2)%1,yt=at<.78?at/.78:(1-at)/.22,Tt=(.6+J*.7+(q-.5)*.4+(Q-.5)*.1-rt*.14+(yt-.5)*.1*(1-$*.5))*st;return et.set(it*k*Tt+(q-.5)*.2*k,Math.max($*tt*(.82+J*.36),0),w*k*Tt+(J-.5)*.2*k),1-rt*.4-(at>.78?.22:0)}),W=new Bt(L(X,G),_);return W.castShadow=W.receiveShadow=!0,W}const D=new Qt;D.position.y=r-.35,d.add(D);const F={x:7.2,z:1.05,r:.9,y:r+3.62};i.LAKE=F;function T(k,tt){const G=F.y-(r-.35)+.13,X=y(22,et=>{const it=et.x,R=et.y,w=et.z,$=(R+1)/2,st=c(it*1.5+tt*7.3,R*1.2,w*1.5+tt*3.1,4),J=c(it*6+tt,R*1.2,w*6,3),q=c(it*11,R*11+tt,w*11,2),Q=Math.pow(1-Math.abs(2*J-1),4),rt=($*G*1.9+st*2.2)%1,at=rt<.78?rt/.78:(1-rt)/.22,yt=(1+(st-.5)*.4+(J-.5)*.25-Q*.1+(at-.5)*.08)*(1-$*$*.12),Tt=it*k*yt,lt=w*k*yt,Rt=Math.hypot(Tt,lt)/F.r;let V=Math.pow($,.75)*G*1.25,pt=1-Q*.4-(rt>.78?.22:0);return V>=G&&(V=G+(q-.5)*.14-.55*(1-u(.78,1.02,Rt)),pt=.75+.25*u(.5,1,Rt),lt<-.45&&Math.abs(Tt)<.36&&(V=Math.min(V,G-.2))),et.set(Tt,Math.max(V,0),lt),pt}),W=new Bt(L(X,tt),_);return W.castShadow=W.receiveShadow=!0,W}{const k=T(1.3,11);k.position.set(F.x,0,F.z),D.add(k)}for(const[k,tt,G,X,W]of[[5.7,.95,1.05,6,1],[8.75,.7,.9,5.2,2],[6.05,-.25,.6,4.6,3],[6.4,2.35,.7,4.3,4],[8,2.45,.65,4.1,5],[7.2,2.8,.55,3.6,6],[8.9,-.35,.45,2.4,7],[6.1,-1.75,.38,.7,8]]){const et=C(G,X,W);et.position.set(k,0,tt),et.rotation.y=W*1.7,D.add(et)}const E=[[5.7,.95,.42],[8.75,.7,.36],[6.05,-.25,.3],[6.4,2.35,.3],[8,2.45,.3],[7.2,2.8,.28],[8.9,-.35,.26]];i.BONSAI=E;for(let k=0;k<22;k++){const tt=i.rng()*Math.PI*2,G=2.3+i.rng()*1.2,X=7.2+Math.cos(tt)*G,W=1+Math.sin(tt)*G*.95,et=.1+i.rng()*.22;if(Math.hypot(X,W)>9.5||p(X,W)<.25)continue;const it=v(et*1.2,et*.75,et,40+k);it.position.set(X,r+et*.2,W),it.rotation.y=tt*3,d.add(it)}for(const[k,tt]of[[155,.3],[185,.24],[212,.2],[20,.3],[-12,.34],[-40,.26],[-62,.2],[48,.22]]){const G=k*Math.PI/180,X=v(tt*1.25,tt*.8,tt,70+k);X.position.set(e[0]+Math.cos(G)*(n+.12),r-.02+tt*.2,e[1]+Math.sin(G)*(n+.12)),X.rotation.y=k,d.add(X)}function j(k,tt,G=[10,40]){const X=document.createElement("canvas");X.width=128,X.height=256;const W=X.getContext("2d");W.fillStyle=`rgba(255,255,255,${tt})`,W.fillRect(0,0,128,256);for(let R=0;R<k;R++)M(W,i.rng()*128,i.rng()*256,1+i.rng()*3,(G[0]+i.rng()*G[1])*1.8,.3+i.rng()*.6);W.globalCompositeOperation="destination-in";const et=W.createLinearGradient(0,0,128,0);et.addColorStop(0,"rgba(0,0,0,0)"),et.addColorStop(.2,"rgba(0,0,0,1)"),et.addColorStop(.8,"rgba(0,0,0,1)"),et.addColorStop(1,"rgba(0,0,0,0)"),W.fillStyle=et,W.fillRect(0,0,128,256);const it=new Ze(X);return it.wrapS=Ve,it.wrapT=bi,it}const O=j(70,.55,[6,24]),B=j(110,0,[20,60]);i.fallBaseTex=O,i.fallHiTex=B;const S=new De({map:O,vertexColors:!0,transparent:!0,side:Ee,depthWrite:!1}),b=new De({map:B,color:16777215,transparent:!0,opacity:.85,side:Ee,depthWrite:!1});s(S),s(b);function v(k,tt,G,X){const W=y(8,it=>{const R=.72+c(it.x*1.4+X*5.1,it.y*1.4+X,it.z*1.4,3)*.55+(c(it.x*4+X,it.y*4,it.z*4,2)-.5)*.12;it.set(it.x*R*k,it.y*R*tt,it.z*R*G)}),et=new Bt(L(W,X),_);return et.castShadow=et.receiveShadow=!0,et}for(const[k,tt,G,X,W,et,it]of[[7.2,2.4,-.1,1,.9,.9,21],[7.05,2.25,-.1,1.1,.85,.95,22],[7.35,1.5,-.6,1.15,.85,1,23],[7.1,.75,-1.05,1.3,.8,1,24],[7.4,.12,-1.45,1.15,.5,.8,25],[6.45,1.3,-.45,.8,1.15,.8,26],[7.95,1.6,-.3,.8,1.2,.8,27]]){const R=v(X,W,et,it);R.position.set(k,tt+.35,G),R.rotation.y=it*.9,D.add(R)}const A=D.children.slice();i.rockMeshes=A;function I({x:k,w0:tt,w1:G,yTop:X,rows:W=30,cols:et=8,seed:it=0}){d.updateMatrixWorld(!0);const R=Ks(A,"z"),w=new H(0,0,1),$=[];for(let _t=0;_t<=W;_t++){const K=_t/W,vt=r+X+(o-r+.03-X)*K,bt=tt+(G-tt)*Math.pow(K,.8),Ut=[];for(let It=0;It<=et;It++){const Xt=It/et,Zt=k+(Xt-.5)*bt+Math.sin(K*6+it)*.07*K,de=R(new H(Zt,vt,-6),w);Ut.push(de?new H(Zt,vt,de.point.z-.07):new H(Zt,vt,NaN))}$.push(Ut)}for(let _t=0;_t<=W;_t++)for(let K=0;K<=et;K++)if(isNaN($[_t][K].z)){let vt=NaN;for(let bt=1;bt<=et&&isNaN(vt);bt++)for(const Ut of[K-bt,K+bt])if($[_t][Ut]&&!isNaN($[_t][Ut].z)){vt=$[_t][Ut].z;break}isNaN(vt)&&_t&&(vt=$[_t-1][K].z),$[_t][K].z=isNaN(vt)?0:vt}const st=$.map(_t=>_t.map(K=>K.z));for(let _t=0;_t<7;_t++){const K=$.map(vt=>vt.map(bt=>bt.z));for(let vt=1;vt<W;vt++)for(let bt=0;bt<=et;bt++){const Ut=[K[vt-1][bt],K[vt+1][bt],K[vt][Math.max(0,bt-1)],K[vt][Math.min(et,bt+1)],K[vt][bt]*2];$[vt][bt].z=Math.min(Ut.reduce((It,Xt)=>It+Xt,0)/6,st[vt][bt])}}$.push($[W].map(_t=>new H(_t.x+(_t.x-k)*.3,o+.005,_t.z-.35)));const J=[],q=[],Q=[],rt=[],at=new Dt(8178154),yt=new Dt(16055295),Tt=new Dt,lt=new Array(et+1).fill(0),Rt=[];$.forEach((_t,K)=>_t.forEach((vt,bt)=>{if(K){const Zt=$[K-1][bt];lt[bt]+=vt.distanceTo(Zt)}const Ut=$[Math.max(0,K-1)][bt],It=$[Math.min($.length-1,K+1)][bt],Xt=Math.min(1,Math.abs(It.y-Ut.y)/(It.distanceTo(Ut)+1e-4));Tt.copy(at).lerp(yt,Math.pow(Xt,1.5)*.85+(K===$.length-1?.5:0)),J.push(vt.x,vt.y,vt.z-Xt*Xt*.12),q.push(bt/et,lt[bt]/1.4),Q.push(Tt.r,Tt.g,Tt.b),Rt.push(Math.pow(Xt,1.5)+(K===$.length-1?.6:0))}));const V=et+1;for(let _t=0;_t<$.length-1;_t++)for(let K=0;K<et;K++){const vt=_t*V+K;rt.push(vt,vt+V,vt+1,vt+1,vt+V,vt+V+1)}const pt=new Jt;pt.setAttribute("position",new Nt(J,3)),pt.setAttribute("uv",new Nt(q,2)),pt.setAttribute("aWhite",new Nt(Rt,1)),pt.setIndex(rt);const wt=new Bt(pt,a(1,1));wt.renderOrder=2,d.add(wt);const St=et>>1,Pt=_t=>{const K=$[Math.max(0,_t-2)][St],vt=$[Math.min($.length-1,_t+2)][St];return Math.abs(vt.y-K.y)/(vt.distanceTo(K)+1e-4)},Ft=[];for(let _t=4;_t<W-5;_t++)Pt(_t-2)>.8&&Pt(_t+2)<.64&&(!Ft.length||_t-Ft.at(-1).r>6)&&Ft.push({r:_t,x:$[_t][St].x,y:$[_t][St].y,z:$[_t][St].z-.12});const Ht=$[W],Gt=$[0];return{bx:k,bz:Ht.reduce((_t,K)=>_t+K.z,0)/Ht.length,tz:Gt.reduce((_t,K)=>_t+K.z,0)/Gt.length,ledges:Ft}}const P=I({x:7.2,w0:.7,w1:1.5,yTop:3.6-.22,rows:48,cols:10,seed:1});i.mainFall=P;const N=new Bt(new qn(.7,.9),m);N.rotation.x=-Math.PI/2,N.position.set(7.2,F.y,P.tz+.5),g.uImpact.value.set(P.bx,P.bz-.3);{const k=P.tz,tt=F.r+.05,G=Math.asin(.42/tt),X=48,W=[F.x,F.y,F.z],et=[1],it=[],R=[];for(let lt=0;lt<=X;lt++){const Rt=-Math.PI/2+G+(2*Math.PI-2*G)*lt/X;R.push([F.x+Math.cos(Rt)*tt,F.z+Math.sin(Rt)*tt,0])}R.push([7.2-.4,k+.34,0],[7.2-.35,k+.1,.45],[7.2+.35,k+.1,.45],[7.2+.4,k+.34,0]),R.forEach(([lt,Rt,V],pt)=>{W.push(lt,F.y,Rt),et.push(V),it.push(0,1+(pt+1)%R.length,1+pt)});const w=new Jt;w.setAttribute("position",new Nt(W,3)),w.setAttribute("aEdge",new Nt(et,1)),w.setAttribute("uv",new Nt(W.filter((lt,Rt)=>Rt%3!==1).map(lt=>lt*.5),2)),w.setIndex(it),w.computeVertexNormals();const $=new Bt(w,l);$.renderOrder=1,d.add($),g.uOut.value.set(7.2,k+.1);const st=[[k+.34,0,.39,0],[k+.18,-.006,.365,.1],[k+.06,-.035,.35,.3],[k-.03,-.11,.345,.55],[k-.07,-.2,.35,.75],[k-.085,-.31,.36,.85]],J=[],q=[],Q=[],rt=[];let at=0;st.forEach(([lt,Rt,V,pt],wt)=>{wt&&(at+=Math.hypot(lt-st[wt-1][0],Rt-st[wt-1][1]));for(const St of[0,1])J.push(7.2+(St-.5)*2*V,F.y+Rt+.006,lt),q.push(St,at/1),Q.push(pt);wt&&rt.push((wt-1)*2,wt*2,(wt-1)*2+1,(wt-1)*2+1,wt*2,wt*2+1)});const yt=new Jt;yt.setAttribute("position",new Nt(J,3)),yt.setAttribute("uv",new Nt(q,2)),yt.setAttribute("aWhite",new Nt(Q,1)),yt.setIndex(rt);const Tt=new Bt(yt,a(1,1,0,.22));Tt.renderOrder=3,d.add(Tt);for(const[lt,Rt,V,pt,wt,St]of[[-.52,.12,.24,.3,.26,101],[.5,.1,.22,.34,.24,102],[-.5,.42,.16,.16,.2,103],[.52,.4,.17,.2,.18,104],[-.2,.02,.07,.05,.08,105]]){const Pt=v(V,pt,wt,St);Pt.position.set(7.2+lt,F.y+(St===105?-.06:0),k+Rt),Pt.rotation.y=St,d.add(Pt)}for(const[lt,Rt,V]of[[2.4,.5,.1],[4.1,.62,.07],[.6,.66,.08]]){const pt=v(V*1.3,V,V*1.1,90+lt*10);pt.position.set(F.x+Math.cos(lt)*Rt,F.y-.02,F.z+Math.sin(lt)*Rt),d.add(pt)}for(const[lt,Rt]of[[1.2,.45],[3.3,.3],[5.2,.5]]){const V=h(new qt(.11,.11,.012,9),t(5212746),F.x+Math.cos(lt)*Rt,F.y+.012,F.z+Math.sin(lt)*Rt);V.castShadow=!1,d.add(V)}}const Y=(()=>{d.updateMatrixWorld(!0);const k=Ks(A,"x"),tt=new H(-1,0,0),G=14,X=[],W=[],et=[],it=[];let R=F.x-F.r,w=0,$=null,st=null;for(let Q=0;Q<=G;Q++){const rt=F.y+1.75*(1-Q/G),at=k(new H(F.x,rt,F.z+.1),tt);if(!at&&!$)continue;const yt=Math.min(at?at.point.x+.06:R,$?$[0]+.25:99),Tt=X.length/6;R=yt,$&&(w+=Math.hypot(yt-$[0],rt-$[1])),$=[yt,rt],st||(st=[yt,rt]);for(const lt of[0,1])X.push(yt,rt,F.z+.1+(lt-.5)*(.1+.26*Q/G)),W.push(lt,w/1.1),et.push(Tt?Q>=G-1?.85:.3:.9);Tt&&it.push((Tt-1)*2,(Tt-1)*2+1,Tt*2,(Tt-1)*2+1,Tt*2+1,Tt*2)}const J=new Jt;J.setAttribute("position",new Nt(X,3)),J.setAttribute("uv",new Nt(W,2)),J.setAttribute("aWhite",new Nt(et,1)),J.setIndex(it);const q=new Bt(J,a(1,1));if(q.renderOrder=2,d.add(q),st){const[Q,rt]=st,at=F.z+.1,yt=new Bt(new ie(.15,14,10),new De({color:461321}));yt.scale.set(.55,.9,1.05),yt.position.set(Q-.04,rt+.03,at),d.add(yt);for(const[Tt,lt,Rt,V,pt,wt,St]of[[0,.2,0,.2,.12,.26,111],[.02,-.02,.19,.11,.17,.11,112],[.02,-.03,-.19,.11,.16,.12,113],[.08,-.2,.02,.16,.07,.2,114]]){const Pt=v(V,pt,wt,St);Pt.position.set(Q+Tt,rt+lt,at+Rt),Pt.rotation.y=St,d.add(Pt)}}{const Q=$?$[0]:R,rt=F.z+.1;g.uIn.value.set(Q+.12,rt);for(const[at,yt,Tt]of[[.27,.09,121],[-.26,.08,122]]){const lt=v(yt*1.2,yt*.9,yt,Tt);lt.position.set(Q+.08,F.y,rt+at),d.add(lt)}}return{x:($?$[0]:R)+.14,y:F.y+.02,z:F.z+.1,src:st&&{x:st[0],y:st[1],z:F.z+.1}}})();i.feeder=Y;const Z=new Qt;i.foam=Z,d.add(Z);for(const k of[{x:P.bx,y:o+.03,z:P.bz-.3,s:1,n:22},...P.ledges.map(tt=>({...tt,s:.5,n:5})),{...Y,s:.42,n:9},{x:7.2,y:F.y-.24,z:P.tz-.14,s:.38,n:6},...Y.src?[{x:Y.src.x+.1,y:Y.src.y-.12,z:Y.src.z,s:.2,n:3}]:[]])for(let tt=0;tt<k.n;tt++){const G=new Vr(s(new $i({map:f,color:16777215,transparent:!0,opacity:.5,depthWrite:!1})));G.userData={ph:i.rng(),x:k.x+(i.rng()-.5)*1.2*k.s,y:k.y,z:k.z+(i.rng()-.5)*.35,s:k.s*(.7+i.rng()*.6)},G.renderOrder=4,Z.add(G)}const nt=160,ht=new Float32Array(nt*3),gt=[];for(let k=0;k<nt;k++){const tt=1.1+i.rng()*1.9;gt.push({ph:i.rng(),a:i.rng()*Math.PI*2,sp:.3+i.rng()*.9,up:tt,life:tt/4.5,ox:(i.rng()-.5)*1.1})}const xt=new Jt;xt.setAttribute("position",new le(ht,3));const Et=(()=>{const k=document.createElement("canvas");k.width=k.height=32;const tt=k.getContext("2d"),G=tt.createRadialGradient(16,16,0,16,16,16);return G.addColorStop(0,"rgba(255,255,255,1)"),G.addColorStop(1,"rgba(255,255,255,0)"),tt.fillStyle=G,tt.fillRect(0,0,32,32),new Ze(k)})(),ct=new lo(xt,s(new Yr({map:Et,size:.055,color:16777215,transparent:!0,opacity:.6,depthWrite:!1})));ct.frustumCulled=!1,ct.renderOrder=4,d.add(ct);const ut=[[5.9,5,.9],[8.6,4.3,.8],[7.2,3.9,1.2],[6.2,2.6,2.4],[8.4,2.6,2.5],[7.3,4.3,2.2]].map(([k,tt,G],X)=>{const W=new Vr(s(new $i({map:f,color:16777215,transparent:!0,opacity:.3,depthWrite:!1})));return W.userData={x:k,y:r+tt,z:G,ph:X*1.7},W.scale.set(3.4,1.5,1),d.add(W),W});function Mt(k){for(let tt=0;tt<nt;tt++){const G=gt[tt],X=(k/G.life*.6+G.ph)%1*G.life;ht[tt*3]=P.bx+G.ox+Math.cos(G.a)*G.sp*X,ht[tt*3+1]=o+.04+G.up*X-4.5*X*X,ht[tt*3+2]=P.bz-.3+Math.sin(G.a)*G.sp*X*.6-X*.5}xt.attributes.position.needsUpdate=!0;for(const tt of ut){const G=tt.userData;tt.position.set(G.x+Math.sin(k*.06+G.ph)*1.3,G.y+Math.sin(k*.11+G.ph*2)*.2,G.z+Math.cos(k*.05+G.ph)*.9),tt.material.opacity=.2+.12*Math.sin(k*.09+G.ph*3)}}}function E0(i){const{M:t,MAT:e,R:n,RIVER:r,RIVER_EDGES:s,TOP:o,WY:a,boulder:c,mesh:l,scene:h}=i;{const d=new en(r.map(u=>new H(u.x,0,u.y)));for(const[u,M,g]of[[.15,.55,.16],[.26,-.6,.12],[.42,.5,.14],[.73,-.55,.15],[.86,.4,.12]]){const y=d.getPointAt(u),L=d.getTangentAt(u),C=c(g*1.25,g*.85,g*1.25,u*37);C.position.set(y.x-L.z*M,a+.01,y.z+L.x*M),C.rotation.y=u*20,h.add(C)}}{const d=s.at(-1).w,u=-n;for(const g of[-1,1])for(const[y,L,C,D,F,T]of[[.26,o+.1,d+.3,.36,.25,.32],[.2,o+.38,d+.34,.25,.18,.23],[.25,o+.61,d+.3,.15,.12,.15],[.1,o-.1,d+.03,.21,.2,.2],[.55,o+.02,d+.26,.21,.14,.23],[.32,o+.06,d+.78,.19,.13,.21],[.62,o+.22,d+.3,.13,.1,.13],[-.04,o-.48,d+.14,.23,.3,.22],[0,o-1,d-.04,.19,.24,.2]]){const E=c(D,F,T,130+y*40+L*7+g*3);E.position.set(u+y,L,g*C),E.rotation.y=(y+L)*9*g,h.add(E)}const M=(g,y,L,C,D,F)=>{for(let T=0;T<g;T++){const E=g>1?T/(g-1):.5,j=(E*2-1)*D+Math.sin(T*2.3+F)*.05,O=C*(.85+.3*Math.abs(Math.sin(T*1.7+F))),B=c(O*1.15,O*.8,O*1.05,F+T);B.position.set(u+y+Math.sin(T*3.1+F)*.05,L+(O-C)*.4,j),B.rotation.y=T*1.9+F,h.add(B)}};M(6,.14,a+.02,.25,d-.08,150),M(5,.2,a+.27,.2,d-.28,160),M(3,.17,a+.46,.15,d-.62,170),M(4,.46,a-.02,.13,d-.2,180)}const f=new en(r.map(d=>new H(d.x,o+.02,d.y)));i.riverCurve=f;const m=t(5212746),p=t(16033472),_=[];i.lotus=_;for(const[d,u]of[[.12,.5],[.2,-.55],[.34,.45],[.47,-.5],[.6,.55],[.68,-.45],[.8,.5]]){const M=f.getPointAt(d),g=f.getTangentAt(d),y=new H(-g.z,0,g.x).multiplyScalar(u),L=l(new qt(.24,.24,.02,9),m,M.x+y.x,a+.03,M.z+y.z);if(h.add(L),_.push(L),d*10%2<1){const C=new Qt;C.position.set(M.x+y.x,a+.05,M.z+y.z);for(let D=0;D<11;D++){const F=D>=7,T=D/(F?4:7)*Math.PI*2+(F?.4:0),E=new Qt;E.rotation.y=T;const j=l(new ie(.05,8,6),p,F?.025:.05,F?.06:.04,0);j.scale.set(.55,1.15,.32),j.rotation.z=F?-.25:-.75,E.add(j),C.add(E)}C.add(l(new ie(.022,8,6),e.gold,0,.05,0)),h.add(C),_.push(C)}}const x=[16742959,16777215,16731453,16763210,3354670].map((d,u)=>{const M=new Qt;M.add(new Bt(new ie(.1,14,10),t(d,{emissive:d,emissiveIntensity:.05,flatShading:!1,roughness:.35,d:{s:[30,30,30],bump:0,vary:.2}})).translateZ(0)),M.children[0].scale.set(1,.6,2.6);const g=new Bt(new Be(.08,.2,4),t(d));return g.rotation.x=Math.PI/2,g.position.z=-.32,M.add(g),M.userData={u:u/5,side:(u-2)*.2,speed:.011+u%3*.003,tail:g,jt:-1},h.add(M),M});i.koi=x}function w0(i){const{M:t,MAT:e,box:n,fit:r,lanternMat:s,mesh:o}=i;i.curvedRoof=_,i.dougong=M,i.hexRoof=g,i.column=y,i.lattice=L,i.door=C,i.plaque=F,i.steps=T,i.railing=E,i.hangLantern=j,i.windBell=O,i.stoneLantern=B,i.urn=S,i.spire=b,Object.assign(e,{woodDark:t(5710619,{roughness:.6,d:{s:[16,5,16],bump:.004,vary:.14}}),stoneDark:t(8616553,{roughness:.92,d:{s:[5,5,5],bump:.025,vary:.22}}),tileTrim:t(2046518,{roughness:.5}),leather:t(14732704,{roughness:.7}),cushion:t(10828328,{roughness:.95}),jade:t(4165483,{roughness:.25}),bronze:t(8018992,{metalness:.8,roughness:.4}),bamboo:t(12755029,{roughness:.6,d:{s:[.5,55,.5],bump:.006,vary:.3}}),ceramic:t(14937320,{roughness:.18,d:!1}),flag:new ze({color:14723374,side:Ee,roughness:.9})});const a=[];i.windowMats=a;const c=()=>{const v=t(16115396,{emissive:16757069,emissiveIntensity:.1,d:!1});return a.push(v),v},l=(v,A,I=0,U=0,P=0)=>{const N=new Bt(v,r(v,A));return N.position.set(I,U,P),N};i.dm=l;const h=(v,A,I,U,P,N,Y)=>l(new $e(v,A,I),U,P,N,Y);i.dbox=h;const[f,m]=(()=>{const v=()=>{const nt=document.createElement("canvas");return nt.width=nt.height=256,[nt,nt.getContext("2d")]},[A,I]=v(),[U,P]=v(),N=32,Y=64;for(let nt=0;nt<4;nt++)for(let ht=0;ht<8;ht++){const gt=ht*N,xt=nt*Y,Et=(i.rng()-.5)*14,ct=tt=>`rgb(${38+Et+tt*30|0},${78+Et+tt*42|0},${72+Et+tt*38|0})`,ut=I.createLinearGradient(gt,0,gt+N,0);ut.addColorStop(0,ct(-.75)),ut.addColorStop(.22,ct(0)),ut.addColorStop(.5,ct(.55)),ut.addColorStop(.78,ct(0)),ut.addColorStop(1,ct(-.75)),I.fillStyle=ut,I.fillRect(gt,xt,N,Y),I.fillStyle="rgba(0,0,0,.28)",I.fillRect(gt,xt,N,3),I.fillStyle="rgba(255,255,255,.08)",I.fillRect(gt+6,xt+3,N-12,2);const Mt=P.createLinearGradient(gt,0,gt+N,0);Mt.addColorStop(0,"#000"),Mt.addColorStop(.5,"#fff"),Mt.addColorStop(1,"#000"),P.fillStyle=Mt,P.fillRect(gt,xt,N,Y),P.fillStyle="rgba(0,0,0,.5)",P.fillRect(gt,xt,N,4);const k=P.createLinearGradient(0,xt,0,xt+Y);k.addColorStop(0,"rgba(0,0,0,.25)"),k.addColorStop(1,"rgba(0,0,0,0)"),P.fillStyle=k,P.fillRect(gt,xt,N,Y)}for(let nt=0;nt<260;nt++)I.fillStyle=`rgba(${i.rng()<.5?"20,30,24":"120,140,110"},${i.rng()*.12})`,I.fillRect(i.rng()*256,i.rng()*256,2+i.rng()*10,6+i.rng()*40);const Z=(nt,ht)=>{const gt=new Ze(nt);return gt.wrapS=gt.wrapT=bi,ht&&(gt.colorSpace=he),gt.anisotropy=8,gt};return[Z(A,!0),Z(U,!1)]})(),p=(v,A)=>{const I=f.clone(),U=m.clone();return I.needsUpdate=U.needsUpdate=!0,I.repeat.set(v,A),U.repeat.set(v,A),new ze({map:I,bumpMap:U,bumpScale:1.6,roughness:.5,side:Ee})};function _(v,A,I,U=.3,P=22){const N=new qn(v*2,A*2,P,P);N.rotateX(-Math.PI/2);const Y=N.attributes.position,Z=Math.max(v-A,0),nt=(tt,G)=>{const X=Math.min(1,Math.max(Math.max(Math.abs(tt)-Z,0)/A,Math.abs(G)/A)),W=Math.abs(tt)/v,et=Math.abs(G)/A;return I*Math.pow(1-X,1.6)+U*Math.pow(W*et,5)+U*.25*Math.pow(X,5)};for(let tt=0;tt<Y.count;tt++)Y.setY(tt,nt(Y.getX(tt),Y.getZ(tt)));N.computeVertexNormals();const ht=new Qt,gt=new Bt(N,p(v*1.4,A*1.4));gt.castShadow=gt.receiveShadow=!0,ht.add(gt);for(const[tt,G]of[[1,1],[1,-1],[-1,1],[-1,-1]]){const X=[];for(let W=0;W<=14;W++){const et=W/14,it=tt*(v+(Z-v)*et),R=G*A*(1-et);X.push(new H(it,nt(it*.999,R*.999)+.035,R))}ht.add(l(new vi(new en(X),16,.035,5),e.tileTrim))}const xt=[],Et=10;for(const[tt,G,X,W]of[[v,A,-v,A],[-v,A,-v,-A],[-v,-A,v,-A],[v,-A,v,A]])for(let et=0;et<Et;et++){const it=et/Et,R=(tt+(X-tt)*it)*.995,w=(G+(W-G)*it)*.995;xt.push(new H(R,nt(R,w)-.01,w))}if(ht.add(l(new vi(new en(xt,!0),80,.028,4,!0),e.woodDark)),Z>.05){ht.add(h(Z*2+.25,.09,.11,e.tileTrim,0,I+.03,0));for(const tt of[-1,1]){const G=l(new Be(.05,.22,5),e.tileTrim,tt*(Z+.14),I+.13,0);G.rotation.z=-tt*.5,ht.add(G)}}for(const[tt,G]of[[1,1],[1,-1],[-1,1],[-1,-1]]){const X=l(new Be(.05,.3,5),e.tileTrim,tt*v,U*1.25+.08,G*A);X.rotation.set(G*.6,0,-tt*.6),ht.add(X)}ht.userData.corners=[[v,A],[v,-A],[-v,A],[-v,-A]].map(([tt,G])=>[tt,U*1.25,G]);const ct=new Bt(N,u);ct.position.y=-.03,ht.add(ct);const ut=new d,Mt=new d,k=(tt,G,X)=>new H(tt,nt(tt,G)+X,G);for(const[tt,G,X,W,et,it]of[[-v,A,v,A,0,1],[v,A,v,-A,1,0],[v,-A,-v,-A,0,-1],[-v,-A,-v,A,-1,0]]){const R=Math.hypot(X-tt,W-G),w=Math.round(R/.17),$=Math.min(v,A)*.5,st=Math.round(R/.1);for(let J=1;J<w;J++){const q=J/w,Q=(tt+(X-tt)*q)*.97,rt=(G+(W-G)*q)*.97;for(const[at,yt]of[[1,.62],[.62,.3],[.3,0]])ut.beam(k(Q-et*$*at,rt-it*$*at,-.06),k(Q-et*$*yt,rt-it*$*yt,-.06),.035,.045)}for(let J=0;J<st;J++){const q=J/st,Q=tt+(X-tt)*q,rt=G+(W-G)*q;Mt.put(new qt(.032,.032,.03,8),Q,nt(Q*.995,rt*.995)+.012,rt,Math.atan2(et,it),Math.PI/2)}}return ht.add(ut.mesh(e.woodDark,!1),Mt.mesh(e.tileTrim,!1)),ht}const x=new ae;class d{constructor(){bo(this,"list");this.list=[]}put(A,I,U,P,N=0,Y=0){return x.position.set(I,U,P),x.rotation.set(Y,N,0,"YXZ"),x.updateMatrix(),A.applyMatrix4(x.matrix),this.list.push(A),this}box(A,I,U,P,N,Y,Z=0){return this.put(new $e(A,I,U),P,N,Y,Z)}beam(A,I,U,P){const N=new $e(U,P,A.distanceTo(I));return x.position.copy(A).add(I).multiplyScalar(.5),x.lookAt(I),x.updateMatrix(),N.applyMatrix4(x.matrix),this.list.push(N),this}mesh(A,I=!0){if(!this.list.length)return new Qt;const U=new Bt(ol(this.list),A);return U.castShadow=I,U.receiveShadow=!0,U}}i.Batch=d;const u=t(5907484,{side:Me,flatShading:!1,roughness:.7});function M(v,A,I,U,P,N,Y=1){const Z=Math.cos(N),nt=Math.sin(N),ht=(gt,xt,Et,ct,ut,Mt,k)=>gt.box(xt*Y,Et*Y,ct*Y,I+(ut*Z+k*nt)*Y,U+Mt*Y,P+(-ut*nt+k*Z)*Y,N);ht(A,.1,.05,.1,0,.025,.02),ht(v,.3,.045,.055,0,.072,.02),ht(v,.055,.045,.3,0,.072,.1);for(const gt of[-.125,.125])ht(A,.06,.035,.06,gt,.112,.02);ht(A,.06,.035,.06,0,.112,.22),ht(v,.4,.04,.05,0,.15,.22),ht(v,.05,.04,.36,0,.15,.12)}function g(v,A,I=.35,U=10,P=48){const N=[],Y=[],Z=[],nt=Math.cos(Math.PI/6),ht=Math.PI/3;for(let X=0;X<=U;X++){const W=X/U;for(let et=0;et<=P;et++){const it=et/P*Math.PI*2,R=nt/Math.cos((it%ht+ht)%ht-ht/2),w=Math.pow((R-nt)/(1-nt),3);N.push(Math.cos(it)*W*v*R,A*Math.pow(1-W,1.6)+I*Math.pow(W,4)*w+I*.2*Math.pow(W,5),Math.sin(it)*W*v*R),Y.push(et/P*10,W*3)}}for(let X=0;X<U;X++)for(let W=0;W<P;W++){const et=X*(P+1)+W,it=et+P+1;Z.push(et,it,et+1,it,it+1,et+1)}const gt=new Jt;gt.setAttribute("position",new Nt(N,3)),gt.setAttribute("uv",new Nt(Y,2)),gt.setIndex(Z),gt.computeVertexNormals();const xt=new Qt,Et=new Bt(gt,p(1,1));Et.castShadow=!0,xt.add(Et);const ct=X=>A*Math.pow(1-X,1.6)+I*Math.pow(X,4)+I*.2*Math.pow(X,5);for(let X=0;X<6;X++){const W=X*ht,et=[];for(let it=0;it<=12;it++){const R=1-it/12;et.push(new H(Math.cos(W)*R*v,ct(R)+.035,Math.sin(W)*R*v))}xt.add(l(new vi(new en(et),14,.035,5),e.tileTrim))}const ut=[];for(let X=0;X<P;X++){const W=(U+0)*(P+1)+X;ut.push(new H(N[W*3]*.995,N[W*3+1]-.01,N[W*3+2]*.995))}xt.add(l(new vi(new en(ut,!0),96,.028,4,!0),e.woodDark));const Mt=(X,W,et)=>{const it=nt/Math.cos((X%ht+ht)%ht-ht/2),R=Math.pow((it-nt)/(1-nt),3);return new H(Math.cos(X)*W*v*it,A*Math.pow(1-W,1.6)+I*Math.pow(W,4)*R+I*.2*Math.pow(W,5)+et,Math.sin(X)*W*v*it)},k=new d,tt=new d;for(let X=0;X<42;X++){const W=(X+.5)/42*Math.PI*2;for(const[et,it]of[[.55,.72],[.72,.86],[.86,.97]])k.beam(Mt(W,et,-.06),Mt(W,it,-.06),.035,.045)}for(let X=0;X<110;X++){const W=X/110*Math.PI*2,et=Mt(W,1,.012);tt.put(new qt(.032,.032,.03,8),et.x,et.y,et.z,Math.atan2(et.x,et.z),Math.PI/2)}const G=new Bt(gt,u);G.position.y=-.03,xt.add(G,k.mesh(e.woodDark,!1),tt.mesh(e.tileTrim,!1)),xt.userData.corners=[];for(let X=0;X<6;X++){const W=X*ht,et=new Qt;et.position.set(Math.cos(W)*v,I*1.2+.06,Math.sin(W)*v),et.rotation.y=-W;const it=l(new Be(.05,.3,5),e.tileTrim);it.rotation.z=-.6,et.add(it),xt.add(et),xt.userData.corners.push([Math.cos(W)*v,I*1.2,Math.sin(W)*v])}return xt}function y(v,A,I,U,P=0,N=.08){v.add(l(new qt(N*1.9,N*2.2,.1,8),e.stoneDark,A,P+.05,I)),v.add(o(new qt(N,N*1.1,U,8),e.wood,A,P+.1+U/2,I)),v.add(h(N*2.6,.07,N*2.6,e.woodDark,A,P+.07+U,I))}function L(v,A){const I=new Qt;I.add(h(v,A,.03,c(),0,0,0)),I.add(h(v+.08,.05,.06,e.woodDark,0,A/2,0),h(v+.08,.05,.06,e.woodDark,0,-A/2,0),h(.05,A,.06,e.woodDark,v/2,0,0),h(.05,A,.06,e.woodDark,-v/2,0,0));for(let U=1;U<4;U++)I.add(h(.022,A,.045,e.woodDark,-v/2+v*U/4,0,0));for(let U=1;U<3;U++)I.add(h(v,.022,.045,e.woodDark,0,-A/2+A*U/3,0));return I}function C(v,A){const I=new Qt;I.add(h(v+.12,A+.1,.04,e.woodDark,0,0,0));for(const U of[-1,1])I.add(h(v/2-.02,A,.05,e.wood,U*v/4,0,.015)),I.add(h(v/2-.14,A*.32,.02,e.woodDark,U*v/4,A*.2,.045),h(v/2-.14,A*.32,.02,e.woodDark,U*v/4,-A*.2,.045)),I.add(l(new ie(.025,6,4),e.gold,U*.05,0,.055));return I}const D=[];function F(v,A=1.1){const I=document.createElement("canvas");I.width=512,I.height=128;const U=()=>{const Y=I.getContext("2d");Y.fillStyle="#7a1d16",Y.fillRect(0,0,512,128),Y.strokeStyle="#d9a441",Y.lineWidth=10,Y.strokeRect(8,8,496,112),Y.lineWidth=3,Y.strokeRect(22,22,468,84),Y.fillStyle="#f1c45c",Y.font='700 50px "Gelasio", Georgia, serif',Y.textAlign="center",Y.textBaseline="middle",Y.fillText(v,256,68)};U();const P=new Ze(I);P.colorSpace=he,D.push([U,P]);const N=e.woodDark;return new Bt(new $e(A,A/4,.04),[N,N,N,N,new ze({map:P,roughness:.6}),N])}document.fonts?.load('700 50px "Gelasio"',"ĐƯỜNGÀỊ").then(()=>D.forEach(([v,A])=>{v(),A.needsUpdate=!0}));function T(v,A,I,U,P,N,Y=e.stone){for(let Z=0;Z<I;Z++)v.add(n(A,U*(I-Z),P,Y,0,U*(I-Z)/2,N+Z*P+P/2))}function E(v,A,I,U,P,N,Y=.3,Z=4){const nt=Math.hypot(U-A,P-I),ht=Math.atan2(U-A,P-I),gt=(A+U)/2,xt=(I+P)/2;for(const[Et,ct]of[[Y,.05],[Y*.45,.03]]){const ut=h(ct,ct,nt,e.woodDark,gt,N+Et,xt);ut.rotation.y=ht,v.add(ut)}for(let Et=0;Et<=Z;Et++){const ct=Et/Z;v.add(h(.055,Y,.055,e.woodDark,A+(U-A)*ct,N+Y/2,I+(P-I)*ct))}}function j(v,A,I,U,P=1){v.add(l(new qt(.006,.006,.14*P,3),e.trunk,A,I-.07*P,U));const N=l(new ie(.1*P,10,8),s(),A,I-.24*P,U);N.scale.y=1.25,v.add(N),v.add(l(new qt(.05*P,.05*P,.03,8),e.gold,A,I-.12*P,U),l(new qt(.05*P,.05*P,.03,8),e.gold,A,I-.37*P,U)),v.add(l(new qt(.008,.008,.12*P,3),e.cushion,A,I-.44*P,U))}function O(v,A,I,U){v.add(l(new qt(.005,.005,.12,3),e.trunk,A,I-.06,U),l(new qt(.025,.05,.08,8),e.gold,A,I-.15,U))}function B(v,A,I,U=1){const P=new Qt;P.position.set(A,0,I),P.scale.setScalar(U);const N=l(new Be(.24,.18,4),e.stone,0,.86,0);N.rotation.y=Math.PI/4,P.add(l(new qt(.18,.22,.1,6),e.stoneDark,0,.05,0),l(new qt(.06,.07,.45,6),e.stone,0,.32,0),h(.26,.06,.26,e.stone,0,.57,0),h(.16,.16,.16,s(),0,.68,0),N,l(new ie(.04,6,4),e.stone,0,.97,0)),P.children.forEach(Y=>Y.castShadow=!0),v.add(P)}function S(v,A,I){const U=new Qt;U.position.set(A,0,I),U.add(l(new qt(.22,.16,.22,10),e.bronze,0,.28,0),l(new Ti(.22,.02,5,14),e.bronze,0,.39,0),l(new qt(.12,.19,.12,10),e.bronze,0,.46,0),l(new ie(.05,6,4),e.gold,0,.55,0)),U.children[1].rotation.x=Math.PI/2;for(let P=0;P<3;P++){const N=P/3*Math.PI*2;U.add(l(new qt(.025,.02,.2,5),e.bronze,Math.cos(N)*.13,.1,Math.sin(N)*.13))}for(const P of[-1,1]){const N=l(new Ti(.05,.015,4,8,Math.PI),e.bronze,P*.24,.38,0);N.rotation.y=Math.PI/2,U.add(N)}v.add(U)}function b(v,A){v.add(l(new qt(.05,.07,.22,8),e.gold,0,A+.11,0));for(let I=0;I<3;I++)v.add(l(new qt(.15-I*.035,.15-I*.035,.035,12),e.gold,0,A+.28+I*.13,0));return v.add(l(new ie(.07,10,8),e.gold,0,A+.7,0),l(new Be(.03,.14,6),e.gold,0,A+.82,0)),A+.9}}function T0(i){const{Batch:t,MAT:e,box:n,column:r,curvedRoof:s,dbox:o,dm:a,door:c,dougong:l,hangLantern:h,lattice:f,mesh:m,plaque:p,stoneLantern:_}=i;i.kieuLau=x;function x(){const d=new Qt,u=5.8,M=1,g=1.4,y=16,L=b=>M*(1-(2*b/u)**2);for(let b=0;b<y;b++){const v=-u/2+b*u/y,A=v+u/y,I=(v+A)/2,U=L(v),P=L(A),N=Math.hypot(A-v,P-U),Y=Math.atan2(P-U,A-v),Z=n(g,.14,N+.02,e.wood,0,(U+P)/2,I);Z.rotation.x=-Y,d.add(Z);for(const nt of[-1,1]){if(Math.abs(I)>1.05)for(const[ht,gt]of[[.5,.07],[.25,.04]]){const xt=o(gt,gt,N+.02,e.woodDark,nt*(g/2-.04),(U+P)/2+ht,I);xt.rotation.x=-Y,d.add(xt)}d.add(o(.08,.55,.08,e.woodDark,nt*(g/2-.04),U+.28,v)),d.add(a(new ie(.05,6,4),e.gold,nt*(g/2-.04),U+.58,v))}}for(const b of[-1,1]){d.add(n(g+.5,.35,.9,e.stone,0,.17,b*(u/2+.2)));for(const v of[-1,1])_(d,v*1.3,b*(u/2+.3),.85)}for(const b of[-1,1])for(let v=0;v<y;v++){const A=-u/2+v*u/y,I=A+u/y,U=L(A)-.2,P=L(I)-.2,N=n(.12,.14,Math.hypot(I-A,P-U)+.02,e.trunk,b*(g/2-.1),(U+P)/2,(A+I)/2);N.rotation.x=-Math.atan2(P-U,I-A),d.add(N)}const C=M+.07;d.add(n(g+.35,.1,2.2,e.woodDark,0,C,0));for(const[b,v]of[[-.8,-1.02],[.8,-1.02],[-.8,1.02],[.8,1.02]])r(d,b,v,1.05,C,.065);d.add(n(1.4,1,1.8,e.paper,0,C+.55,0)),d.add(o(1.44,.1,1.84,e.wood,0,C+.1,0),o(1.75,.09,2.2,e.wood,0,C+1.1,0));for(const b of[-1,1])for(const v of[-.45,.45]){const A=f(.55,.42);A.position.set(b*.715,C+.55,v),A.rotation.y=b*Math.PI/2,d.add(A)}for(const b of[-1,1]){const v=c(.62,.78);v.position.set(0,C+.5,b*.915),v.rotation.y=b>0?0:Math.PI,d.add(v)}const D=p("KIỀU LÂU",.85);D.position.set(.74,C+.92,0),D.rotation.y=Math.PI/2,d.add(D);const F=new t,T=new t,E=new t,j=C+1.27;d.add(n(1.5,.13,1.9,e.woodDark,0,C+1.2,0));for(let b=0;b<4;b++)for(const v of[-1,1])l(F,T,v*.82,C+1.15,-1.02+b*.68,v*Math.PI/2,.7);for(let b=0;b<3;b++)for(const v of[-1,1])l(F,T,-.8+b*.8,C+1.15,v*1.04,v>0?0:Math.PI,.7);const O=s(1.05,1.35,.55,.3);O.position.y=j,d.add(O),d.add(n(.9,.24,1.15,e.woodDark,0,j+.32,0)),E.box(1,.06,1.25,0,j+.26,0),d.add(n(.7,.28,.95,e.woodDark,0,j+.54,0));for(const b of[-1,1]){const v=f(.4,.16);v.position.set(b*.355,j+.54,0),v.rotation.y=b*Math.PI/2,d.add(v);for(const A of[-1,1])F.box(.06,.3,.06,b*.33,j+.54,A*.45)}d.add(n(.68,.08,.93,e.woodDark,0,j+.72,0));for(const b of[-.4,0,.4])for(const v of[-1,1])l(F,T,v*.35,j+.67,b,v*Math.PI/2,.5);for(const b of[-.25,.25])for(const v of[-1,1])l(F,T,b,j+.67,v*.475,v>0?0:Math.PI,.5);const B=s(.58,.75,.4,.22);B.position.y=j+.76,d.add(B),d.add(a(new ie(.08,8,6),e.gold,0,j+1.23,0),a(new ie(.055,8,6),e.gold,0,j+1.35,0));for(const[b,,v]of O.userData.corners)h(d,b*.92,j+.3,v*.92,.9);d.add(F.mesh(e.wood),T.mesh(e.woodDark),E.mesh(e.tileTrim));const S=new Qt;return S.position.set(1,j+.04,.55),S.add(a(new qt(.008,.008,.3,4),e.trunk,0,-.15,0)),S.add(m(new qt(.07,.14,.22,10),e.gold,0,-.4,0),a(new ie(.03,6,4),e.bronze,0,-.53,0)),d.add(S),d.userData={bell:S,top:C+2.75},d}}function A0(i){const{Batch:t,MAT:e,box:n,column:r,curvedRoof:s,dbox:o,door:a,dougong:c,lattice:l,plaque:h,spire:f,steps:m,stoneLantern:p,urn:_,windBell:x}=i;i.tangKinh=d;function d(){const u=new Qt,M=new t,g=new t,y=new t,L=new t,C=.14;u.add(n(3.6,.3,3.6,e.stoneDark,0,.15,0),n(3,.3,3,e.stone,0,.45,0)),y.box(3.7,.06,3.7,0,.29,0).box(3.1,.06,3.1,0,.59,0),m(u,1,3,.2,.22,1.5);for(const B of[-1,1])u.add(n(.16,.5,.7,e.stoneDark,B*.58,.25,1.85)),p(u,B*1.35,2.15,.9);_(u,0,2.75);const D=(B,S,b,v,A,I,U,P)=>{const N=S*Math.PI/2,Y=Math.cos(N),Z=Math.sin(N);B.box(b,v,A,I*Y+P*Z,U,-I*Z+P*Y,N)},F=(B,S,b,v)=>{for(let A=0;A<4;A++){const I=A*Math.PI/2,U=Math.cos(I),P=Math.sin(I);for(let N=0;N<b;N++){const Y=-S+2*S*N/(b-1);c(M,g,Y*U+S*P,B,-Y*P+S*U,I,v)}}},T=(B,S)=>{for(let b=0;b<4;b++){D(g,b,S*2,.04,.05,0,B+.25,S),D(g,b,S*2,.03,.035,0,B+.14,S),D(g,b,S*2,.03,.035,0,B+.035,S),D(M,b,S*2-.04,.09,.014,0,B+.088,S);for(let v=0;v<=4;v++){const A=-S+2*S*v/4;D(g,b,.06,.3,.06,A,B+.15,S),D(g,b,.08,.03,.08,A,B+.31,S)}}};let E=.6;const j=[2.2,1.7,1.25],O=[1,.82,.7];return j.forEach((B,S)=>{const b=O[S],v=B*.46;u.add(n(B*.92,b,B*.92,e.paper,0,E+b/2,0));for(const[U,P]of[[1,1],[1,-1],[-1,1],[-1,-1]])r(u,U*v,P*v,b-.12,E,.06);u.add(o(B*.98,.09,B*.98,e.wood,0,E+b-.04,0),o(B*.96,.07,B*.96,e.wood,0,E+.04,0));for(let U=0;U<4;U++){const P=U*Math.PI/2,N=S===0&&U===0,Y=N?a(.62,.62):l(B*.4,b*.48);Y.position.set(Math.sin(P)*(v+.01),E+(N?.4:b*.52),Math.cos(P)*(v+.01)),Y.rotation.y=P,u.add(Y);for(const Z of[-1,1])D(M,U,.05,b-.1,.03,Z*B*.29,E+b/2,v+.005);N||D(M,U,B*.9,.04,.03,0,E+b*.2,v+.005),D(g,U,B*.9,.04,.03,0,E+b*.84,v+.005)}if(S===0){const U=h("TÀNG KINH CÁC",1.15);U.position.set(0,E+.86,v+.06),u.add(U)}E+=b,u.add(n(B*.9,C,B*.9,e.woodDark,0,E+C/2,0)),F(E+.005,v,S===0?5:4,.8),E+=C;const A=B*.5+.42,I=s(A,A,.5,.28);I.position.y=E,u.add(I);for(const[U,P,N]of I.userData.corners)x(u,U*.97,E+P+.02,N*.97);if(E+=.42,S<2){const U=j[S+1],P=U*.6,N=E-.42;L.box(U*1.14,.07,U*1.14,0,N+.12,0),u.add(n(U*1.04,.34,U*1.04,e.woodDark,0,N+.22,0));for(let Y=0;Y<4;Y++)for(const Z of[-.3,0,.3])D(M,Y,U*.24,.15,.02,Z*U,N+.25,U*.52+.004);F(E-.125,U*.52,4,.55),u.add(n(P*2+.12,.05,P*2+.12,e.woodDark,0,E+.01,0)),T(E+.035,P)}}),u.add(M.mesh(e.wood),g.mesh(e.woodDark),y.mesh(e.stone),L.mesh(e.tileTrim)),u.userData={top:f(u,E)+.1},u}}function R0(i){const{Batch:t,M:e,MAT:n,column:r,dbox:s,dm:o,dougong:a,hangLantern:c,hexRoof:l,mesh:h,railing:f,steps:m,windBell:p}=i;i.traDinh=_;function _(){const x=new Qt,d=1.6,u=.4,M=1.45,g=Math.cos(Math.PI/6),y=h(new qt(d+.3,d+.4,.2,6),n.stoneDark,0,.1,0),L=h(new qt(d,d+.1,.2,6),n.stone,0,.3,0);y.rotation.y=L.rotation.y=Math.PI/6,x.add(y,L),m(x,.8,2,.2,.24,d*g);const C=[];for(let S=0;S<6;S++){const b=Math.PI/6+S*Math.PI/3;C.push([Math.sin(b)*(d-.15),Math.cos(b)*(d-.15)])}C.forEach(([S,b])=>r(x,S,b,M,u,.07));for(let S=0;S<6;S++){const[b,v]=C[S],[A,I]=C[(S+1)%6],U=Math.hypot(A-b,I-v),P=Math.atan2(A-b,I-v),N=(b+A)/2,Y=(v+I)/2,Z=s(.09,.12,U,n.wood,N,u+M+.02,Y);Z.rotation.y=P,x.add(Z);const nt=s(.03,.12,U*.85,n.woodDark,N,u+M-.14,Y);if(nt.rotation.y=P,x.add(nt),S!==5&&(f(x,b,v,A,I,u,.32,3),S>=1&&S<=3)){const ht=o(new qt(.04,.04,U*.88,6),n.bamboo,N,u+M-.25,Y);if(ht.rotation.order="YXZ",ht.rotation.set(Math.PI/2,P,0),x.add(ht),S===2){const gt=s(.02,.5,U*.85,n.bamboo,N,u+M-.52,Y);gt.rotation.y=P,x.add(gt)}}}const D=u+M+.2,F=new t,T=new t;C.forEach(([S,b],v)=>{const A=Math.PI/6+v*Math.PI/3,[I,U]=C[(v+1)%6];a(F,T,S,u+M+.09,b,A,.8),a(F,T,(S+I)/2,u+M+.09,(b+U)/2,A+Math.PI/6,.7)}),x.add(F.mesh(n.wood),T.mesh(n.woodDark));const E=l(d+.55,.95,.35);E.position.y=D,x.add(E);for(const[S,b,v]of E.userData.corners)p(x,S*.96,D+b+.02,v*.96);const j=D+.95;x.add(o(new ie(.12,10,8),n.gold,0,j+.08,0),o(new ie(.08,10,8),n.gold,0,j+.25,0),o(new Be(.03,.14,6),n.gold,0,j+.37,0)),c(x,0,u+M+.05,0,1.1),x.add(h(new qt(.45,.45,.06,12),n.wood,0,u+.36,0),o(new qt(.07,.1,.33,8),n.woodDark,0,u+.17,0)),x.add(o(new ie(.08,10,8),n.ceramic,0,u+.46,0),o(new ie(.03,6,4),n.ceramic,0,u+.54,0));const O=o(new qt(.012,.02,.1,5),n.ceramic,.09,u+.47,0);O.rotation.z=-.9,x.add(O);for(let S=0;S<3;S++){const b=S/3*Math.PI*2+.5;x.add(o(new qt(.03,.022,.04,8),n.ceramic,Math.cos(b)*.24,u+.41,Math.sin(b)*.24))}for(const S of[Math.PI/2,-Math.PI/2,Math.PI])x.add(o(new qt(.2,.2,.07,10),n.cushion,Math.sin(S)*.8,u+.04,Math.cos(S)*.8));const B=e(16738858,{emissive:16730640,emissiveIntensity:1.2});x.add(h(new qt(.16,.2,.3,8),n.stoneDark,1.75,.15,-1),o(new qt(.11,.11,.03,8),B,1.75,.31,-1));for(let S=0;S<4;S++){const b=o(new ho(.26,0),n.stone,S%2?.15:-.15,.02,d*g+.7+S*.5);b.scale.y=.2,x.add(b)}return x.userData={top:j+.5},x}}function C0(i){const{Batch:t,M:e,MAT:n,box:r,column:s,curvedRoof:o,dbox:a,dm:c,door:l,dougong:h,hangLantern:f,lattice:m,mesh:p,plaque:_,smooth:x,steps:d,stoneLantern:u}=i;i.nghiSu=M;function M(){const g=new Qt,y=new t,L=new t,C=new t,D=new t,F=.55,T=1.35,E=.14,j=F+T+E;g.add(r(5.2,.25,3.6,n.stoneDark,0,.125,0),r(4.8,.3,3.2,n.stone,0,.4,0)),C.box(5.3,.05,3.7,0,.245,0).box(4.9,.05,3.3,0,.545,0),d(g,1.6,3,.18,.2,1.6);for(const N of[-1,1])g.add(r(.14,.45,.62,n.stoneDark,N*.87,.25,1.9)),u(g,N*1.35,2.1,.9);g.add(r(4,T,1.9,n.paper,0,F+T/2,-.45)),g.add(a(4.04,.1,1.94,n.wood,0,F+.05,-.45),a(4.04,.1,1.94,n.wood,0,F+T-.05,-.45));for(let N=0;N<6;N++)s(g,-1.9+N*.76,.85,T-.08,F,.075);for(const N of[-1,1])s(g,N*1.9,-1.35,T-.08,F,.075);g.add(a(4.3,.13,.13,n.wood,0,F+T-.03,.85));for(let N=0;N<5;N++){const Y=a(.03,.18,.36,n.woodDark,-1.52+N*.76,F+T-.18,.68);g.add(Y)}for(const N of[-.9,0,.9]){const Y=l(.62,.92);Y.position.set(N,F+.52,.53),g.add(Y)}for(const N of[-1.6,1.6]){const Y=m(.48,.5);Y.position.set(N,F+.72,.52),g.add(Y)}for(const N of[-1,1])for(const Y of[-.85,-.05]){const Z=m(.5,.45);Z.position.set(N*2.01,F+.72,Y),Z.rotation.y=N*Math.PI/2,g.add(Z)}for(const N of[-1.3,-.45,.45,1.3])y.box(.06,T-.1,.04,N,F+T/2,.51),y.box(.06,T-.1,.04,N,F+T/2,-1.41);y.box(3.95,.04,.03,0,F+T*.25,-1.41);for(const N of[-1,1])y.box(.04,T-.1,.06,N*2.005,F+T/2,-.45),y.box(.03,.04,1.85,N*2.005,F+T*.25,-.45);const O=_("NGHỊ SỰ ĐƯỜNG",1.45);O.position.set(0,F+1.17,.56),g.add(O),g.add(r(4,E,1.9,n.woodDark,0,F+T+E/2,-.45)),L.box(4.3,.19,.08,0,F+T+.2,.8);for(let N=0;N<6;N++)h(y,L,-1.9+N*.76,F+T+.03,.85,0,.8),h(y,L,-1.9+N*.76,F+T+.005,-1.4,Math.PI,.8);for(let N=0;N<4;N++)for(const Y of[-1,1])h(y,L,Y*2,F+T+.005,-1.35+N*.73,Y*Math.PI/2,.8);const B=o(2.8,1.9,.55,.32);B.position.set(0,j,-.1),g.add(B);for(const[N,,Y]of B.userData.corners)f(g,N*.94,j+.3,Y*.94-.1,1);g.add(r(3.25,.28,1.6,n.woodDark,0,j+.34,-.1)),D.box(3.4,.07,1.75,0,j+.27,-.1),g.add(r(3,.32,1.35,n.woodDark,0,j+.6,-.1));for(const N of[-.9,0,.9])for(const Y of[-1,1]){const Z=m(.5,.18);Z.position.set(N,j+.6,-.1+Y*.68),Y<0&&(Z.rotation.y=Math.PI),g.add(Z)}for(const N of[-1,1]){const Y=m(.6,.18);Y.position.set(N*1.505,j+.6,-.1),Y.rotation.y=N*Math.PI/2,g.add(Y)}for(const N of[-1.47,-.45,.45,1.47])for(const Y of[-1,1])y.box(.07,.34,.07,N,j+.6,-.1+Y*.66);const S=j+.76,b=.11;g.add(r(2.96,b,1.31,n.woodDark,0,S+b/2,-.1));for(let N=0;N<6;N++)for(const Y of[-1,1])h(y,L,-1.5+N*.6,S-.02,-.1+Y*.675,Y>0?0:Math.PI,.65);for(let N=0;N<3;N++)for(const Y of[-1,1])h(y,L,Y*1.5,S-.02,-.775+N*.675,Y*Math.PI/2,.65);const v=o(2,1.15,.6,.3);v.position.set(0,S+b,-.1),g.add(v);const A=S+b+.6;g.add(c(new ie(.1,10,8),n.gold,0,A+.18,-.1));const I=c(new Be(.05,.16,6),e(16747069,{emissive:16734751,emissiveIntensity:.8}),0,A+.33,-.1);g.add(I);for(const N of[-1,1]){const Y=c(new Ti(.2,.04,6,14,Math.PI),n.jade,N*.42,A+.05,-.1);g.add(Y);const Z=c(new Be(.06,.16,5),n.jade,N*.2,A+.12,-.1);Z.rotation.z=N*1.2,g.add(Z);const nt=c(new Be(.04,.22,5),n.jade,N*.68,A+.14,-.1);nt.rotation.z=-N*.5,g.add(nt)}const U=new Bt(new qt(.22,.22,.3,14),[x(n.wood),n.leather,n.leather]);U.rotation.z=Math.PI/2,U.position.set(-2.05,F+.62,1.3),U.castShadow=!0,g.add(U);for(const N of[-1,1])g.add(a(.05,.85,.05,n.woodDark,-2.05+N*.21,F+.42,1.3));g.add(a(.5,.05,.06,n.woodDark,-2.05,F+.86,1.3));const P=[];for(const N of[-1,1]){g.add(p(new qt(.03,.04,2.6,6),n.woodDark,N*2.4,1.3,1.75),c(new ie(.05,6,4),n.gold,N*2.4,2.63,1.75));const Y=new Bt(new qn(.6,.4,8,1),n.flag);Y.position.set(N*2.4-N*.32,2.3,1.75),Y.rotation.y=N>0?Math.PI:0,g.add(Y),P.push(Y)}return g.add(y.mesh(n.wood),L.mesh(n.woodDark),C.mesh(n.stone),D.mesh(n.tileTrim)),g.userData={top:A+.45,flags:P},g}}function P0(i){const{AMBER_Y:t,TOP:e,TOWERS:n,kieuLau:r,nghiSu:s,scene:o,tangKinh:a,traDinh:c}=i,l={kieulau:r,tangkinh:a,tradinh:c,nghisu:s},h=[];i.hitTargets=h;for(const[f,m]of Object.entries(n)){const p=new H(...m.pos).setY(e);if(m.vec=p,f==="center"){m.top=t-e;continue}const _=l[f]();_.position.copy(p),f==="kieulau"?_.rotation.y=Math.PI/2:_.lookAt(0,e,0),o.add(_),m.group=_,m.top=_.userData.top;const x=new Bt(f==="kieulau"?new Ki(3.1,3.4,56):new Ki(2.3,2.6,56),new De({color:16757575,transparent:!0,opacity:.35,depthWrite:!1}));x.rotation.x=-Math.PI/2,x.position.set(p.x,e+.02,p.z),o.add(x),m.aura=x;const d=f==="kieulau"?3:2.2,u=new Bt(new qt(d,d,m.top,8),new De({visible:!1}));u.position.set(p.x,e+m.top/2,p.z),u.userData.id=f,o.add(u),h.push(u)}}function L0(i){const{AMBER_Y:t,hitTargets:e,scene:n}=i,r=new Qt;i.amber=r,r.position.set(0,t,0),n.add(r);const s=new ze({color:16762219,emissive:16751918,emissiveIntensity:1.4,roughness:.3});i.coreMat=s,r.add(new Bt(new ie(.5,32,20),s));const o=new Bt(new ie(.82,40,24),new ze({color:16753978,transparent:!0,opacity:.3,roughness:.04,metalness:.1,depthWrite:!1,envMapIntensity:1.6}));i.shell=o,r.add(o);const a=new ze({color:14856794,metalness:.9,roughness:.25,emissive:9067024,emissiveIntensity:.5}),c=[0,1].map(f=>{const m=new Bt(new Ti(1.25+f*.3,.022,8,96),a);return r.add(m),m});i.halos=c;const l=new il(16754240,10,11,1.6);i.amberLight=l,r.add(l);const h=new Bt(new ie(1.6,8,6),new De({visible:!1}));h.userData.id="center",r.add(h),e.push(h)}function D0(i){const{BONSAI:t,LAKE:e,MAT:n,TOP:r,blossomSpots:s,feeder:o,mainFall:a,mesh:c,rockMeshes:l,scene:h,trees:f}=i;i.leafTexture=m,i.leafCloud=L;function m(O){const B=document.createElement("canvas");B.width=B.height=128,O(B.getContext("2d"));const S=new Ze(B);return S.colorSpace=he,S}const p=(O,B)=>O+i.rng()*(B-O);i.rr=p;const _=m(O=>{O.lineCap="round";for(let B=0;B<46;B++){const S=p(12,116),b=p(12,116),v=p(0,7);for(let A=0;A<15;A++){const I=v+A/15*Math.PI*1.5,U=p(9,19);O.strokeStyle=`hsl(${p(112,150)},${p(30,48)}%,${p(22,44)}%)`,O.lineWidth=2.6,O.beginPath(),O.moveTo(S,b),O.lineTo(S+Math.cos(I)*U,b+Math.sin(I)*U),O.stroke()}}}),x=m(O=>{for(let B=0;B<14;B++)O.fillStyle=`hsl(${p(85,115)},${p(30,45)}%,${p(28,40)}%)`,O.beginPath(),O.ellipse(p(14,114),p(14,114),p(6,10),p(3,5),p(0,3),0,7),O.fill();for(let B=0;B<64;B++){const S=p(12,116),b=p(12,116),v=p(4,7),A=p(332,352),I=p(74,92);for(let U=0;U<5;U++){const P=U/5*Math.PI*2+B;O.fillStyle=`hsl(${A},${p(70,92)}%,${I}%)`,O.beginPath(),O.arc(S+Math.cos(P)*v*.75,b+Math.sin(P)*v*.75,v*.72,0,7),O.fill()}O.fillStyle=`hsl(${A-6},70%,${I-26}%)`,O.beginPath(),O.arc(S,b,v*.3,0,7),O.fill()}}),d=m(O=>{for(let B=0;B<90;B++)O.fillStyle=`hsl(${p(88,128)},${p(32,52)}%,${p(20,42)}%)`,O.beginPath(),O.ellipse(p(12,116),p(12,116),p(7,12),p(3.5,6),p(0,3.2),0,7),O.fill()}),u=(O,B)=>{const S=new ze({map:O,color:B,alphaTest:.3,side:Ee,roughness:.9});return S.onBeforeCompile=b=>{b.fragmentShader=b.fragmentShader.replace("#include <normal_fragment_begin>",`#include <normal_fragment_begin>
#ifdef DOUBLE_SIDED
  normal *= faceDirection;
#endif`)},S.customProgramCacheKey=()=>"leaf",S};i.leafMat=u;const M=[16777215,14478296,12900548].map(O=>u(_,O)),g=[16777215,16770798,16766690].map(O=>u(x,O)),y=[16777215,14674120,13163712].map(O=>u(d,O));i.bushLeaf=y;function L(O,B,S,b,v=!1){const A=[],I=[],U=[],P=[],N=new An,Y=new Zi,Z=new H,nt=new H,ht=[[-1,-1,0,0],[1,-1,1,0],[1,1,1,1],[-1,1,0,1]];for(const[Et,ct,ut,Mt,k=Mt]of O)for(let tt=0;tt<B;tt++){const G=p(0,Math.PI*2),X=p(-1,1),W=Math.sqrt(1-X*X),et=p(.5,1),it=Math.cos(G)*W,R=Math.sin(G)*W;v?Y.set(-Math.PI/2+p(-.5,.5),p(-.5,.5),p(0,6.3)):Y.set(p(0,6.3),p(0,6.3),p(0,6.3)),N.setFromEuler(Y),nt.set(it,X+.4,R).normalize();const w=S*p(.7,1.3),$=A.length/3;for(const[st,J,q,Q]of ht)Z.set(st*w/2,J*w/2,0).applyQuaternion(N),A.push(Et+it*Mt*et+Z.x,ct+X*k*et+Z.y,ut+R*Mt*et+Z.z),I.push(nt.x,nt.y,nt.z),U.push(q,Q);P.push($,$+1,$+2,$,$+2,$+3)}const gt=new Jt;gt.setAttribute("position",new Nt(A,3)),gt.setAttribute("normal",new Nt(I,3)),gt.setAttribute("uv",new Nt(U,2)),gt.setIndex(P);const xt=new Bt(gt,b);return xt.castShadow=!0,xt}const C=(O,B,S)=>new H(O,B,S),D=C(0,1,0);function F(O,B,S,b,v){const A=S.clone().sub(B),I=A.length(),U=c(new qt(v,b,I,8),n.trunk);U.position.copy(B).addScaledVector(A,.5),U.quaternion.setFromUnitVectors(D,A.normalize()),O.add(U)}function T(){const O=new Qt,B=p(-.5,.5),S=p(0,6.3),b=[C(0,0,0),C(B*.25,.6,.05),C(B*.1,1.2,-.05),C(B*.5,1.8,.05),C(B*.35,2.3,0)];for(let I=0;I<4;I++)F(O,b[I],b[I+1],.13-I*.026,.13-(I+1)*.026);const v=new en(b),A=[];return[[.8,.85,.62],[1.25,.7,.55],[1.7,.55,.46],[2.08,.42,.36]].forEach(([I,U,P],N)=>{const Y=S+N*2.3,Z=v.getPoint(I/2.3),nt=C(Z.x+Math.cos(Y)*U*.6,I+.08,Z.z+Math.sin(Y)*U*.6);F(O,Z,nt,.035,.014),A.push([nt.x,nt.y+.06,nt.z,P,P*.3])}),A.push([b[4].x,2.42,0,.38,.2]),O.add(L(A,18,.5,M[Math.floor(p(0,3))],!0)),O}function E(O,B,S=1){const b=T();b.position.set(O,r,B),b.scale.setScalar(S),h.add(b),f.push({g:b,ph:p(0,6),amp:.02})}function j(O,B,S=1){const b=new Qt,v=C(0,0,0),A=C(.07,.55,.03),I=C(-.04,1,-.02);F(b,v,A,.13,.1),F(b,A,I,.1,.075);const U=[C(.5,1.45,.15),C(-.48,1.5,-.12),C(.12,1.5,-.5),C(-.1,1.85,.22),C(.28,1.8,-.2),C(0,1.6,.45)];U.forEach(N=>F(b,I,N,.05,.014));const P=U.map((N,Y)=>[N.x,N.y+.08,N.z,.4+Y%3*.06,.3]);P.push([0,1.75,0,.48,.34]),b.add(L(P,13,.42,g[Math.floor(p(0,3))])),b.position.set(O,r,B),b.scale.setScalar(S),b.rotation.y=p(0,6.3),h.add(b),f.push({g:b,ph:p(0,6),amp:.03}),s.push(new H(O,r+1.5*S,B))}[[2.2,5.8],[.8,8.4],[3.2,8.2],[-1.5,6.2],[-4,8]].forEach(([O,B],S)=>E(O,B,.9+S%3*.15)),[[-5,1],[-5.6,-6.4],[.6,-8.6],[1.8,-6.6],[.4,-4.4],[7.2,-6]].forEach(([O,B],S)=>j(O,B,.85+S%3*.15));{h.updateMatrixWorld(!0);const O=Ks(l,"y"),B=C(0,-1,0);for(const[b,v,A]of t){const I=O(C(b,20,v),B);if(!I)continue;const U=T();U.position.set(b,I.point.y-.04,v),U.scale.setScalar(A*.75),h.add(U),f.push({g:U,ph:p(0,6),amp:.012})}for(let b=0,v=0;b<20&&v<500;v++){const A=p(4.9,9.5),I=p(-1.6,3.4);if(Math.abs(A-7.2)<.75&&I<.3||Math.hypot(A-e.x,I-e.z)<e.r+.05)continue;const U=O(C(A,20,I),B);if(!U||U.face.normal.y<.72||U.point.y<r+.45)continue;const P=p(.7,1.5),N=L([[0,.1*P,0,.2*P,.12*P],[p(-.15,.15)*P,.08*P,p(-.15,.15)*P,.14*P,.09*P]],8,.2*P,y[b%3]);N.position.copy(U.point),N.position.y-=.02,h.add(N),b++}const S=(b,v,A,I)=>{const U=L([[0,.07*I,0,.16*I,.09*I]],7,.2*I,y[Math.floor(p(0,3))]);U.position.set(b,v,A),h.add(U)};if(o.src){const{x:b,y:v,z:A}=o.src;S(b+.02,v+.3,A+.08,1.1),S(b+.04,v+.02,A+.3,.8),S(b+.04,v,A-.3,.9),S(b+.12,v-.18,A+.2,.6)}S(7.2-.62,e.y+.22,a.tz+.2,1),S(7.2+.6,e.y+.26,a.tz+.18,.9),S(7.2-.6,e.y+.12,a.tz+.55,.7),S(7.2+.62,e.y+.14,a.tz+.5,.7)}}function I0(i){const{LITE:t,M:e,PLAZA_X:n,RIVER_EDGES:r,TOP:s,U:o,WY:a,blossomSpots:c,bushLeaf:l,dm:h,freeGround:f,groundY:m,isYin:p,leafCloud:_,leafMat:x,leafTexture:d,lotus:u,mesh:M,reeds:g,riverCurve:y,rr:L,scene:C,stoneLantern:D,trees:F,waterU:T}=i;i.ripple=nt,i.animateNature=Et;const E=e(7311162),j=e(8823370),O=e(7029541);r.forEach(({p:ct,n:ut,w:Mt},k)=>{if(!(k%3))for(const tt of[-1,1]){if(i.rng()<.35)continue;const G=ct.x+ut.x*(Mt+.12)*tt,X=ct.y+ut.y*(Mt+.12)*tt;if(Math.hypot(G,X)>9.2||Math.abs(G)<1.9&&Math.abs(X)<1.6||Math.hypot(Math.abs(G)-n,X)<1.5||G<-8.6||Math.hypot(G-7.2,X+.5)<1.3)continue;const W=new Qt;W.position.set(G,m(G,X),X);for(let et=0,it=3+Math.floor(i.rng()*3);et<it;et++){const R=.35+i.rng()*.35,w=M(new Be(.018,R,4),et%2?E:j,(i.rng()-.5)*.18,R/2,(i.rng()-.5)*.18);w.rotation.set((i.rng()-.5)*.3,0,(i.rng()-.5)*.3),W.add(w),et===0&&i.rng()<.5&&W.add(M(new qt(.025,.025,.1,5),O,w.position.x,R+.03,w.position.z))}C.add(W),g.push({g:W,ph:i.rng()*6})}});{const ct=[16777215,16765773,15221594,12160240,16751444].map(ut=>e(ut,{emissive:ut,emissiveIntensity:.06,flatShading:!1,d:!1}));for(let ut=0,Mt=0;ut<34&&Mt<700;Mt++){const k=i.rng()*Math.PI*2,tt=2+i.rng()*7,G=Math.cos(k)*tt,X=Math.sin(k)*tt;if(!f(G,X))continue;const W=new Qt;if(W.position.set(G,m(G,X),X),ut%3===0)W.add(_([[0,.17,0,.27,.17],[L(-.2,.2),.13,L(-.2,.2),.19,.13]],10,.24,l[ut%3+Math.floor(L(0,3))]??l[0]));else{const et=ct[Math.floor(i.rng()*ct.length)];for(let it=0;it<9;it++){const R=(i.rng()-.5)*.45,w=(i.rng()-.5)*.45,$=.08+i.rng()*.1;W.add(h(new qt(.008,.008,$,3),E,R,$/2,w),h(new ie(.026,8,6),et,R,$+.015,w))}}C.add(W),g.push({g:W,ph:i.rng()*6,small:!0}),ut++}}const B={value:1};{const ct=d(st=>{st.lineCap="round";for(let J=0;J<36;J++){const q=L(8,120),Q=L(-24,24),rt=L(50,122);st.strokeStyle=`hsl(${L(76,108)},${L(36,56)}%,${L(50,80)}%)`,st.lineWidth=L(2.5,5),st.beginPath(),st.moveTo(q,128),st.quadraticCurveTo(q,128-rt*.6,q+Q,128-rt),st.stroke()}}),ut=[],Mt=[],k=[],tt=[];for(const st of[0,Math.PI/2]){const J=Math.cos(st)*.13,q=Math.sin(st)*.13,Q=ut.length/3;ut.push(-J,0,-q,J,0,q,J,.13,q,-J,.13,-q),Mt.push(0,1,0,0,1,0,0,1,0,0,1,0),k.push(0,0,1,0,1,1,0,1),tt.push(Q,Q+1,Q+2,Q,Q+2,Q+3)}const G=new Jt;G.setAttribute("position",new Nt(ut,3)),G.setAttribute("normal",new Nt(Mt,3)),G.setAttribute("uv",new Nt(k,2)),G.setIndex(tt);const X=x(ct,16777215),W=X.onBeforeCompile;X.alphaTest=.35,X.onBeforeCompile=st=>{W(st),st.uniforms.uTime=T.uTime,st.uniforms.uWind=B,st.vertexShader=st.vertexShader.replace("#include <common>",`#include <common>
uniform float uTime, uWind;`).replace("#include <begin_vertex>",`#include <begin_vertex>
        #ifdef USE_INSTANCING
          float gph = instanceMatrix[3].x*1.7 + instanceMatrix[3].z*1.3;
          transformed.x += sin(uTime*1.9 + gph) * .022 * uWind * uv.y; transformed.z += cos(uTime*1.4 + gph*1.3) * .015 * uWind * uv.y;
        #endif`)},X.customProgramCacheKey=()=>"grass";const et=i.Q.grassBuild,it=new Um(G,X,et),R=new ae,w=new Dt;let $=0;for(let st=0;$<et&&st<et*4;st++){const J=L(0,Math.PI*2),q=Math.sqrt(i.rng())*9.6,Q=Math.cos(J)*q,rt=Math.sin(J)*q;f(Q,rt,!0)&&(R.position.set(Q,m(Q,rt)-.01,rt),R.rotation.y=L(0,6.3),R.scale.set(L(.7,1.5),L(.55,1.5),L(.7,1.5)),R.updateMatrix(),it.setMatrixAt($,R.matrix),p(Q,rt)?w.setHSL(L(.33,.4),.32,L(.15,.25)):i.rng()<.12?w.setHSL(L(.12,.16),.42,L(.4,.5)):w.setHSL(L(.21,.28),.46,L(.3,.44)),it.setColorAt($++,w))}it.count=$,i.grass=it,i.grassBuilt=$,it.receiveShadow=!0,it.frustumCulled=!1,C.add(it)}const S=(()=>{const ct=document.createElement("canvas");ct.width=ct.height=32;const ut=ct.getContext("2d"),Mt=ut.createRadialGradient(16,16,2,16,16,15);return Mt.addColorStop(0,"rgba(255,255,255,1)"),Mt.addColorStop(1,"rgba(255,255,255,0)"),ut.fillStyle=Mt,ut.beginPath(),ut.ellipse(16,16,14,8,.5,0,Math.PI*2),ut.fill(),new Ze(ct)})(),b=140,v=new Float32Array(b*3),A=[];function I(ct,ut){const Mt=c[Math.floor(i.rng()*c.length)];v[ct*3]=Mt.x+(i.rng()-.5)*1.2,v[ct*3+2]=Mt.z+(i.rng()-.5)*1.2,v[ct*3+1]=ut?s+i.rng()*(Mt.y-s+.4):Mt.y+(i.rng()-.3)*.5,A[ct]={vy:.22+i.rng()*.25,ph:i.rng()*6}}for(let ct=0;ct<b;ct++)I(ct,!0);const U=new Jt;U.setAttribute("position",new le(v,3));const P=new Yr({map:S,color:16233414,size:.13,transparent:!0,depthWrite:!1});o(P),C.add(new lo(U,P));const N=o(new De({color:16367823,side:Ee})),Y=[];i.floatPetals=Y;for(let ct=0;ct<26;ct++){const ut=new Bt(new jr(.05,6),N);ut.rotation.x=-Math.PI/2,ut.userData={u:i.rng()*.97,side:(i.rng()-.5)*1.1,sp:.005+i.rng()*.006,ph:i.rng()*6},C.add(ut),Y.push(ut)}const Z=[];i.ripples=Z;for(let ct=0;ct<22;ct++){const ut=new Bt(new Ki(.06,.085,24),o(new De({color:16777215,transparent:!0,opacity:0,depthWrite:!1})));ut.rotation.x=-Math.PI/2,ut.userData.life=-1,C.add(ut),Z.push(ut)}function nt(ct,ut){const Mt=Z.find(k=>k.userData.life<0);Mt&&(Mt.position.set(ct,a+.03,ut),Mt.userData.life=0)}let ht=0;i.nextJump=7;const gt=[];i.dflies=gt;for(let ct=0;ct<3;ct++){const ut=new Qt,Mt=h(new qt(.012,.008,.22,5),e(3127208,{emissive:1006162,emissiveIntensity:.4}));Mt.rotation.x=Math.PI/2,ut.add(Mt);const k=new De({color:15267583,transparent:!0,opacity:.55,depthWrite:!1}),tt=[];for(const G of[-1,1])for(const X of[.035,-.015]){const W=h(new $e(.17,.003,.035),k,G*.085,.01,X);ut.add(W),tt.push([W,G])}ut.userData={wings:tt,target:new H,timer:0},ut.position.copy(y.getPointAt(.2+ct*.25)).setY(s+.6),C.add(ut),gt.push(ut)}const xt=new H;function Et(ct,ut){const Mt=.6+i.ENV.wind/12+i.cur.storm*1.6;B.value=Mt;for(const G of F)G.g.rotation.z=Math.sin(ut*1.3+G.ph)*G.amp*Mt,G.g.rotation.x=Math.cos(ut*1.05+G.ph*1.3)*G.amp*.6*Mt;for(const G of g)G.g.rotation.z=Math.sin(ut*2.1+G.ph)*(G.small?.04:.1)*Mt,G.g.rotation.x=Math.cos(ut*1.7+G.ph)*.04*Mt;P.opacity=.95-.45*i.modeT;const k=i.ENV.wind*.02+i.cur.storm*.5;for(let G=0;G<b;G++){const X=A[G],W=G*3;v[W+1]-=X.vy*ct*(1+i.cur.r*2.5),v[W]+=(Math.sin(ut*1.5+X.ph)*.25+k)*ct,v[W+2]+=Math.cos(ut*1.2+X.ph)*.2*ct,v[W+1]<s+.03&&I(G,!1)}U.attributes.position.needsUpdate=!0;for(const G of Y){const X=G.userData;X.u=(X.u+ct*X.sp*(1+i.cur.r))%.97;const W=y.getPointAt(X.u),et=y.getTangentAt(X.u);G.position.set(W.x-et.z*X.side,a+.025+Math.sin(ut*2+X.ph)*.008,W.z+et.x*X.side),G.rotation.z+=ct*.3}for(u.forEach((G,X)=>{var W;(W=G.userData).y0??(W.y0=G.position.y),G.position.y=G.userData.y0+Math.sin(ut*1.3+X)*.012,G.rotation.y+=ct*.05*(X%2?1:-1)}),ht+=ct*(.9+i.cur.r*14);ht>1;){ht--;const G=.03+i.rng()*.94,X=y.getPointAt(G),W=y.getTangentAt(G),et=(i.rng()-.5)*1.1;nt(X.x-W.z*et,X.z+W.x*et)}for(const G of Z){const X=G.userData;if(!(X.life<0)){if(X.life+=ct/1.6,X.life>=1){X.life=-1,G.material.opacity=0;continue}G.scale.setScalar(1+X.life*6),G.material.opacity=.45*(1-X.life)}}const tt=i.modeT<.5&&i.cur.r<.15;for(const G of gt){if(G.visible=tt,!tt)continue;const X=G.userData;if(X.timer-=ct,X.timer<0){const W=y.getPointAt(.05+i.rng()*.9);X.target.set(W.x+(i.rng()-.5)*1.5,s+.35+i.rng()*.6,W.z+(i.rng()-.5)*1.5),X.timer=1.2+i.rng()*2.5}xt.copy(G.position),G.position.lerp(X.target,Math.min(1,ct*2.2)),G.position.y+=Math.sin(ut*7+X.timer)*.002,G.position.distanceToSquared(xt)>1e-7&&G.lookAt(G.position.x*2-xt.x,G.position.y,G.position.z*2-xt.z);for(const[W,et]of X.wings)W.rotation.z=et*Math.sin(ut*55+et)*.45}}for(let ct=0;ct<12;ct++){const ut=ct/12*Math.PI*2+.26,Mt=Math.cos(ut)*9.1,k=Math.sin(ut)*9.1;if(Math.abs(k)<1.7||Mt>7&&Math.abs(k)<3.4)continue;const tt=new Qt;tt.position.y=s,C.add(tt),D(tt,Mt,k,.95)}}function U0(i){const{scene:t}=i,e=new Qt;i.clouds=e,t.add(e);const n=(()=>{const f=document.createElement("canvas");f.width=f.height=128;const m=f.getContext("2d");for(let p=0;p<8;p++){const _=36+i.rng()*56,x=46+i.rng()*36,d=20+i.rng()*24,u=m.createRadialGradient(_,x,0,_,x,d);u.addColorStop(0,"rgba(255,255,255,.5)"),u.addColorStop(1,"rgba(255,255,255,0)"),m.fillStyle=u,m.fillRect(0,0,128,128)}return new Ze(f)})(),r=new $i({map:n,color:16777215,transparent:!0,opacity:.8,depthWrite:!1});i.cloudMat=r;for(let f=0;f<80;f++){const m=f<14,p=i.rng()*Math.PI*2,_=m?i.rng()*12:13+Math.pow(i.rng(),.8)*30,x=8+i.rng()*10,d=new Vr(r);d.scale.set(x*1.8,x*.6,1),d.position.set(Math.cos(p)*_,(m?-15:-7)-i.rng()*5,Math.sin(p)*_),e.add(d)}const s=180,o=new Float32Array(s*3),a=[];i.N=s,i.fp=o,i.seeds=a;for(let f=0;f<s;f++){const m=i.rng()*Math.PI*2,p=i.rng()*11;a.push([Math.cos(m)*p,1+i.rng()*5,Math.sin(m)*p,i.rng()*10])}const c=new Jt;i.fGeo=c,c.setAttribute("position",new le(o,3));const l=(()=>{const f=document.createElement("canvas");f.width=f.height=32;const m=f.getContext("2d"),p=m.createRadialGradient(16,16,0,16,16,16);return p.addColorStop(0,"rgba(255,255,255,1)"),p.addColorStop(.35,"rgba(255,255,255,.7)"),p.addColorStop(1,"rgba(255,255,255,0)"),m.fillStyle=p,m.fillRect(0,0,32,32),new Ze(f)})(),h=new Yr({map:l,size:.16,color:16769440,transparent:!0,opacity:.8,depthWrite:!1});i.fMat=h,t.add(new lo(c,h))}function N0(i){const{bloom:t,cloudMat:e,envScene:n,fMat:r,fallLum:s,hemi:o,lanternMats:a,pmrem:c,renderer:l,scene:h,skyU:f,sun:m,unlit:p,windowMats:_}=i;i.phaseName=O,i.updateEnv=U;const x={nang:{name:"Nắng",icon:"☀",c:0,r:0,f:0,storm:0},itmay:{name:"Có mây",icon:"⛅",c:.45,r:0,f:0,storm:0},amu:{name:"Âm u",icon:"☁",c:.9,r:0,f:.15,storm:0},muaphun:{name:"Mưa phùn",icon:"🌦",c:.8,r:.3,f:.2,storm:0},mua:{name:"Mưa",icon:"🌧",c:.95,r:.75,f:.25,storm:0},giong:{name:"Giông",icon:"⛈",c:1,r:1,f:.3,storm:1},suong:{name:"Sương mù",icon:"🌫",c:.5,r:0,f:1,storm:0}};i.WEATHER=x;const d=P=>P===0?"nang":P<=2?"itmay":P===3?"amu":P===45||P===48?"suong":P>=51&&P<=57?"muaphun":P>=95?"giong":P>=61&&P<=67||P>=80&&P<=82?"mua":"amu";i.wmoToWeather=d;const u={weather:"nang",temp:31,source:"Giả lập",sunrise:5.75,sunset:17.75,hourOverride:null,wind:8};i.ENV=u;const M={c:0,r:0,f:0,storm:0};i.cur=M;let g=0,y=6;i.mode="duong",i.modeT=0;const L={dayTop:new Dt(3111116),dayHor:new Dt(8830182),nightTop:new Dt(395800),nightHor:new Dt(1779527),goldTop:new Dt(4610191),goldHor:new Dt(15768158),grayDay:new Dt(9148067),grayNight:new Dt(1448742),fog:new Dt(13226714),sunLow:new Dt(16753242),sunHigh:new Dt(16773590),moon:new Dt(11123942)},C=new Dt,D=new H,F=()=>{const P=new Date;return P.getHours()+P.getMinutes()/60},T=()=>u.hourOverride??F();i.hourNow=T;const E=P=>`${String(Math.floor(P)%24).padStart(2,"0")}:${String(Math.round(P%1*60)%60).padStart(2,"0")}`;i.fmtH=E;function j(P){const N=u.sunrise,Y=u.sunset,Z=(P-N)/(Y-N);if(Z>=0&&Z<=1)return{e:Math.sin(Math.PI*Z),f:Z,day:!0};const nt=((P<N?P+24:P)-Y)/(24-(Y-N));return{e:-Math.sin(Math.PI*nt),f:nt,day:!1}}function O(P){const N=u.sunrise,Y=u.sunset;return Math.abs(P-N)<.6?"Bình minh":Math.abs(P-Y)<.6?"Hoàng hôn":P>N&&P<10.5?"Buổi sáng":P>=10.5&&P<13.5?"Buổi trưa":P>=13.5&&P<Y?"Buổi chiều":P>=Y&&P<22?"Buổi tối":"Đêm khuya"}const B=(P,N,Y)=>{const Z=Math.min(1,Math.max(0,(Y-P)/(N-P)));return Z*Z*(3-2*Z)},S=1600,b=new Float32Array(S*6),v=new Float32Array(S);for(let P=0;P<S;P++){const N=i.rng()*Math.PI*2,Y=Math.sqrt(i.rng())*14,Z=i.rng()*20-2;b.set([Math.cos(N)*Y,Z,Math.sin(N)*Y,Math.cos(N)*Y+.06,Z+.55,Math.sin(N)*Y],P*6),v[P]=15+i.rng()*6}const A=new Jt;A.setAttribute("position",new le(b,3));const I=new Om(A,new Jc({color:12375788,transparent:!0,opacity:.5,depthWrite:!1}));I.frustumCulled=!1,h.add(I);function U(P,N){const Y=x[u.weather],Z=T(),{e:nt,f:ht,day:gt}=j(Z);for(const W of["c","r","f","storm"])M[W]+=(Y[W]-M[W])*Math.min(1,P*.8);const xt=B(-.05,.3,nt),Et=1-xt,ct=Math.exp(-Math.pow((nt-.04)/.13,2))*(1-M.c*.8);i.modeT=Et;const ut=Et>.5?"am":"duong";ut!==i.mode&&(i.mode=ut),f.top.value.copy(L.nightTop).lerp(L.dayTop,xt).lerp(L.goldTop,ct*.5).lerp(C.copy(L.grayNight).lerp(L.grayDay,xt),M.c*.75),f.hor.value.copy(L.nightHor).lerp(L.dayHor,xt).lerp(L.goldHor,ct*.85).lerp(C.copy(L.grayNight).lerp(L.grayDay,xt),M.c*.7),f.night.value=Et,f.cloud.value=M.c,f.time.value=N,f.flash.value=g,f.storm.value=M.storm,gt?D.set(Math.cos(Math.PI*ht)*.9,Math.max(nt,.05),.35):D.set(Math.cos(Math.PI*ht)*.9,Math.max(-nt,.12),-.3),D.normalize(),f.sunDir.value.copy(D),m.position.set(D.x,Math.max(D.y,.32),D.z).normalize().multiplyScalar(30);const Mt=B(-.14,.2,nt);gt?(m.color.copy(L.sunLow).lerp(L.sunHigh,B(.05,.45,nt)),m.intensity=3*(.45+.55*B(0,.5,nt))*Mt*(1-M.c*.7)):(m.color.copy(L.moon),m.intensity=.5*(1-M.c*.8)),o.intensity=(.32+.68*Mt)*(1-M.c*.2)*.5+ct*.5+g*2.2,o.color.set(14412031).lerp(L.goldHor,ct*.45);const k=Math.max(M.f,M.r*.5);h.fog.near=50-44*k,h.fog.far=120-82*k,h.fog.color.copy(f.hor.value).lerp(C.copy(L.fog).multiplyScalar(.2+.8*xt),M.f*.6);const tt=Math.max(Et,M.c*.55);a.forEach(W=>W.emissiveIntensity=.35+2.05*tt),_.forEach(W=>W.emissiveIntensity=.08+1.02*tt),t.strength=.18+.72*Et,l.toneMappingExposure=(.88+.1*Et)*(1-.1*M.c),r.opacity=(.04+.86*Et)*(1-M.r),r.color.setRGB(1,1-.18*Et,1-.52*Et),e.color.setScalar((1-.9*Et)*(1-.3*M.c)).lerp(f.hor.value,.3);const G=(.2+.8*xt)*(1-.25*M.c)+g;s.value=G;for(const[W,et]of p)W.color.copy(et).multiplyScalar(G);i.envAcc+=P;const X=[xt,ct,M.c,M.storm,ht].map(W=>Math.round(W*16)).join();if(X!==i.envKey&&i.envAcc>.5){i.envKey=X,i.envAcc=0,f.gain.value=.5+.45*ct+.2*Et;const W=c.fromScene(n,0,.1,200);f.gain.value=1,h.environment=W.texture,i.envRT?.dispose(),i.envRT=W}if(I.visible=M.r>.02,I.material.opacity=.25+.4*M.r,I.visible){const W=Math.floor(S*M.r);A.setDrawRange(0,W*2);for(let et=0;et<W;et++){const it=et*6,R=v[et]*P*(1+M.storm*.4);b[it+1]-=R,b[it+4]-=R,b[it+1]<-3&&(b[it+1]+=21,b[it+4]+=21)}A.attributes.position.needsUpdate=!0}g*=Math.pow(.004,P),M.storm>.5&&(y-=P,y<0&&(g=1,i.setTimeout(()=>g=.7,120),y=5+i.rng()*9,i.Sound.thunder(.4+i.rng()*1.5)))}}function O0(i){const{ENV:t,WEATHER:e,fmtH:n,hourNow:r,phaseName:s,renderer:o,wmoToWeather:a}=i;i.renderWx=f,i.setMode=m,i.setWeather=p;const c=document.getElementById("wxBtn"),l=document.getElementById("wxPanel"),h=document.getElementById("wxHour");function f(){const _=e[t.weather],x=r();c.textContent=`${_.icon} ${t.temp!=null?Math.round(t.temp)+"°":""} · ${s(x)}`,document.getElementById("wxIcon").textContent=_.icon,document.getElementById("wxTitle").textContent=`${_.name}${t.temp!=null?" · "+Math.round(t.temp)+"°C":""}`,document.getElementById("wxSub").textContent=`${s(x)} · ${n(x)} · nguồn: ${t.source}`,document.getElementById("wxHourLbl").textContent=n(x),document.activeElement!==h&&(h.value=x),document.getElementById("wxTime").innerHTML=[["real","Theo giờ thực"],[t.sunrise,"Bình minh"],[12,"Trưa"],[t.sunset,"Hoàng hôn"],[21,"Tối"],[2,"Khuya"]].map(([d,u])=>`<button class="wx-chip ${(d==="real"?t.hourOverride==null:t.hourOverride===d)?"on":""}" data-h="${d}">${u}</button>`).join(""),document.getElementById("wxChips").innerHTML=Object.entries(e).map(([d,u])=>`<button class="wx-chip ${d===t.weather?"on":""}" data-w="${d}">${u.icon} ${u.name}</button>`).join(""),document.getElementById("wxNote").textContent=`Bình minh ${n(t.sunrise)} · Hoàng hôn ${n(t.sunset)}. Bản thật lấy thời tiết từ Open-Meteo qua server; prototype đang giả lập.`,l.querySelectorAll("[data-h]").forEach(d=>d.onclick=()=>{t.hourOverride=d.dataset.h==="real"?null:+d.dataset.h,f()}),l.querySelectorAll("[data-w]").forEach(d=>d.onclick=()=>{t.weather=d.dataset.w,t.source="Xem thử",f()})}h.oninput=()=>{t.hourOverride=+h.value,f()},c.onclick=_=>{_.stopPropagation(),document.getElementById("musicPanel").classList.remove("on"),l.classList.toggle("on")},l.addEventListener("pointerdown",_=>_.stopPropagation()),o.domElement.addEventListener("pointerdown",()=>l.classList.remove("on")),i.setInterval(f,2e4);function m(_){t.hourOverride=_==="am"?21:10,f()}function p(_={}){_.code!=null&&(t.weather=a(_.code)),_.weather&&e[_.weather]&&(t.weather=_.weather),_.temp!=null&&(t.temp=_.temp),_.wind!=null&&(t.wind=_.wind);const x=d=>typeof d=="number"?d:(u=>u.getHours()+u.getMinutes()/60)(new Date(d));_.sunrise&&(t.sunrise=x(_.sunrise)),_.sunset&&(t.sunset=x(_.sunset)),t.source=_.source??"Open-Meteo",f()}}function F0(i){const{CRIT:t,LVL:e,STATS:n,TOWERS:r}=i;i.renderStats=a,i.checkCrit=l,i.push=x;const s=document.getElementById("stats");for(const[d,u]of Object.entries(n)){const M=document.createElement("div");M.className="stat glass",M.innerHTML=`<div class="row">${u.label}<b>0</b></div><div class="bar"><i></i></div>`,M.onclick=()=>i.select(u.tower),s.appendChild(M),u.el=M,u.wasCrit=!1}const o=d=>d==null?"var(--mut)":d<t?"var(--bad)":d<50?"var(--warn)":"var(--ok)";i.statColor=o;function a(){for(const d of Object.values(n)){const u=Math.round(d.v);d.el.querySelector("b").textContent=d.v==null?"–":String(u);const M=d.el.querySelector("i");M.style.width=u+"%",M.style.background=o(u),d.el.classList.toggle("crit",d.v!=null&&d.v<t)}}function c(d){if(d){for(const[u,M]of Object.entries(d))n[u]&&(n[u].v=Lc.clamp(n[u].v+M,0,100));l(),a(),i.current&&i.renderSheet(i.current)}}function l(){for(const d of Object.values(n)){const u=d.v!=null&&d.v<t;u&&!d.wasCrit&&x({from:d.tower,lvl:"bad",text:`${d.label} xuống thấp (${Math.round(d.v)}). Cần xử lý.`}),d.wasCrit=u}}const h=d=>Object.values(n).some(u=>u.tower===d&&u.v!=null&&u.v<t);i.towerCrit=h;const f=[];i.notifs=f;let m=0;const p=document.getElementById("toasts");function _(d){const u=document.createElement("div");for(u.className="toast glass",u.innerHTML=`<span class="dot" style="background:${e[d.lvl]}"></span><div>${d.text}<small>${r[d.from]?.name??"Hệ thống"} · vừa xong</small></div>`,u.onclick=()=>i.select("kieulau"),p.prepend(u);p.children.length>2;)p.lastChild.remove();i.setTimeout(()=>{u.classList.add("out"),i.setTimeout(()=>u.remove(),350)},3600)}function x(d){const u={id:++m,from:d.from??"center",lvl:d.lvl??"info",text:d.text,time:new Date,read:!1};c(d.effect),_(u);const M=()=>{i.Sound.chime(u.lvl),f.unshift(u),f.length>60&&f.pop(),i.bellKick=1,i.updateLabels(),i.current&&i.renderSheet(i.current)};u.from==="kieulau"?M():i.fly(u.from,M,e[u.lvl])}}function B0(i){const{AMBER_Y:t,BRIDGE_END:e,PATHS:n,PLAZA_X:r,TOP:s,amber:o,frontXZ:a,scene:c,stoneLantern:l}=i;i.fly=p;const h=[];i.flights=h;const f=(_,x,d)=>new H(_,s+x,d);function m(_){if(!n[_])return new en([o.position.clone(),f(.8,t-s-1.6,.4),f(0,3,0)]);const[x,d]=a(_),u=n[_].side;return new en([f(x,.35,d),f(u*r,.35,0),f(u*e,.5,0),f(u*1.5,1.2,0),f(0,2.1,0)])}function p(_,x,d){const u=new Bt(new ie(.16,10,8),new De({color:d})),M=new Bt(new ie(.32,10,8),new De({color:d,transparent:!0,opacity:.25,depthWrite:!1}));u.add(M),c.add(u);const g=m(_);h.push({m:u,curve:g,t:0,speed:4.2/g.getLength(),done:x})}for(const _ of Object.keys(n)){const[x,d]=a(_),u=n[_].side,M=(x+u*r)/2,g=d/2,y=Math.hypot(u*r-x,-d),L=d/y*.75,C=(u*r-x)/y*.75,D=new Qt;D.position.y=s,c.add(D),l(D,M+L,g-C,.6)}}function z0(i){const{TOP:t,TOWERS:e,amber:n,camera:r,notifs:s,towerCrit:o}=i;i.updateLabels=c,i.placeLabels=h;const a={};for(const[f,m]of Object.entries(e)){const p=document.createElement("div");p.className="lbl glass",p.innerHTML=`<span class="w"></span>${m.name}<span class="b"></span>`,p.onclick=()=>i.select(f),i.root.appendChild(p),a[f]=p}function c(){const f=s.filter(p=>!p.read).length,m=a.kieulau.querySelector(".b");m.textContent=f>99?"99+":f,m.classList.toggle("on",f>0);for(const p in a)a[p].classList.toggle("crit",o(p))}const l=new H;function h(){for(const[f,m]of Object.entries(e)){l.copy(m.vec),l.y=f==="center"?n.position.y+1.7:t+m.top+.35,l.project(r);const p=a[f];if(l.z>1){p.style.display="none";continue}p.style.display="flex",p.style.transform=`translate(${(l.x*.5+.5)*innerWidth}px, ${(-l.y*.5+.5)*innerHeight}px) translate(-50%,-100%)`}}}function G0(i){const{LVL:t,STATS:e,TOP:n,TOWERS:r,amber:s,camera:o,controls:a,hitTargets:c,notifs:l,push:h,renderer:f,setMode:m,statColor:p,updateLabels:_}=i;i.renderSheet=M,i.select=g,i.home=y;const x=document.getElementById("sheet"),d=document.getElementById("sheetBody");i.current=null,i.camGoal=null;const u=F=>F.toLocaleTimeString("vi-VN",{hour:"2-digit",minute:"2-digit"});function M(F){const T=r[F],E=Object.entries(e).filter(([,B])=>B.tower===F);let j=`<h2>${T.name}</h2><div class="role">${T.role}</div>`;for(const[,B]of E)j+=`<div class="kv"><span>${B.label} · ${B.src}</span><b style="color:${p(B.v)}">${B.v==null?"–":Math.round(B.v)+"/100"}</b></div>`;if(F==="center"){const B=Object.values(e).filter(b=>b.v!=null),S=B.length?B.reduce((b,v)=>b.v<v.v?b:v):null;S&&(j+=`<div class="kv"><span>Chỉ số thấp nhất</span><b style="color:${p(S.v)}">${S.label} ${Math.round(S.v)}</b></div>`),j+=`<div class="kv"><span>Chế độ</span><b>${i.mode==="duong"?"Dương (ngày)":"Âm (đêm)"}</b></div>`}j+=`<div class="acts">${T.acts.map((B,S)=>`<button class="btn" data-i="${S}">${B[0]}</button>`).join("")}</div>`;const O=F==="kieulau"?l:l.filter(B=>B.from===F);j+=`<div class="sec">${F==="kieulau"?"Thông báo":"Hoạt động gần đây"}</div>`,j+=O.length?O.slice(0,20).map(B=>`<div class="item ${B.read?"read":""}"><span class="dot" style="background:${t[B.lvl]}"></span><div>${B.text}<small>${r[B.from]?.name} · ${u(B.time)}</small></div></div>`).join(""):'<div class="empty">Chưa có gì.</div>',d.innerHTML=j,d.querySelectorAll(".btn").forEach(B=>B.onclick=()=>{const[S,b,v,A]=T.acts[+B.dataset.i];if(A==="readAll"){l.forEach(I=>I.read=!0),_(),M(F);return}if(A==="nav"){i.opts.onNavigate?.(v);return}if(A==="toggle"){m(i.mode==="duong"?"am":"duong"),M(F);return}h({from:F,lvl:"ok",text:v,effect:b})})}function g(F){if(!r[F])return;i.current=F,M(F),x.classList.add("on"),i.hint.style.opacity=0;const T=r[F],E=F==="center"?s.position.clone():T.vec.clone().setY(n+T.top*.45),j=F==="center"?new H(0,0,1):F==="kieulau"?new H(.45,0,-1).normalize():T.vec.clone().setY(0).normalize().negate().applyAxisAngle(new H(0,1,0),F==="nghisu"?-.85:.85),O=(innerWidth<innerHeight?13:9)*(F==="nghisu"?.95:1);i.camGoal={pos:E.clone().add(j.multiplyScalar(O)).add(new H(0,O*.4,0)),target:E.clone().add(new H(0,innerWidth<innerHeight?-1.8:0,0))}}function y(){const F=innerWidth<innerHeight?1.8:1;i.camGoal={pos:new H(14,15,20).multiplyScalar(F),target:new H(0,innerWidth<innerHeight?-.5:1,0)}}document.getElementById("close").onclick=()=>{x.classList.remove("on"),i.current=null,y()},a.addEventListener("start",()=>i.camGoal=null);const L=new n0,C=new At;let D=null;f.domElement.addEventListener("pointerdown",F=>D=[F.clientX,F.clientY]),f.domElement.addEventListener("pointerup",F=>{if(!D||Math.hypot(F.clientX-D[0],F.clientY-D[1])>8)return;C.set(F.clientX/innerWidth*2-1,-(F.clientY/innerHeight)*2+1),L.setFromCamera(C,o);const T=L.intersectObjects(c,!1)[0];T&&g(T.object.userData.id)})}function k0(i){const{AMBER_Y:t,CRIT:e,ENV:n,N:r,R:s,RANDOM_EVENTS:o,STATS:a,TOP:c,TOWERS:l,WY:h,amber:f,amberLight:m,animateNature:p,animateRiver:_,animateSplash:x,camera:d,checkCrit:u,clouds:M,composer:g,controls:y,coreMat:L,fGeo:C,fallBaseTex:D,fallHiTex:F,fallTex:T,flights:E,foam:j,fp:O,halos:B,home:S,koi:b,mist:v,placeLabels:A,poolMat:I,push:U,renderStats:P,renderer:N,ripple:Y,riverCurve:Z,scene:nt,seeds:ht,shell:gt,towerCrit:xt,updateEnv:Et,waterMat:ct,waterTex:ut,waterU:Mt}=i;i.loop=w;const k=new rl;let tt=0,G=4;i.bellKick=0;const X=document.getElementById("clock"),W=document.getElementById("hint");i.hint=W;const et=new Dt,it=new Dt(16757575),R=new Dt(16731469);S(),d.position.copy(i.camGoal.pos),y.target.copy(i.camGoal.target),d.position.multiplyScalar(1.25);function w(){const $=Math.min(k.getDelta(),.05),st=k.elapsedTime;if(Et($,st),i.opts.demo){if(tt+=$,tt>1){tt=0;for(const q of Object.values(a))q.v=Math.max(0,q.v-q.decay);u(),P()}G-=$,G<0&&(G=7+i.rng()*6,U(o[Math.floor(i.rng()*o.length)]))}const J=Object.values(a).some(q=>q.v!=null&&q.v<e);f.position.y=t+Math.sin(st*1.4)*.18,gt.rotation.y+=$*.4,gt.rotation.x+=$*.2,B[0].rotation.set(Math.PI/2+Math.sin(st*.7)*.3,st*.5,0),B[1].rotation.set(Math.PI/2.4,-st*.35,Math.cos(st*.6)*.3),L.emissive.copy(J?R:new Dt(16751918)),L.emissiveIntensity=1.2+Math.sin(st*(J?6:2))*.35,m.color.copy(L.emissive);for(const[q,Q]of Object.entries(l)){if(!Q.aura)continue;const rt=xt(q),at=i.current===q;et.copy(rt?R:it),Q.aura.material.color.lerp(et,.1),Q.aura.material.opacity=(at?.7:.28)+Math.sin(st*(rt?6:1.5))*(rt?.25:.08)}i.bellKick*=.985,l.kieulau.group.userData.bell.rotation.z=Math.sin(st*9)*.45*i.bellKick;for(let q=E.length-1;q>=0;q--){const Q=E[q];Q.t+=$*Q.speed,Q.m.position.copy(Q.curve.getPoint(Math.min(Q.t,1))),Q.m.scale.setScalar(1+Math.sin(Q.t*Math.PI)*.6),Q.t>=1&&(nt.remove(Q.m),Q.m.traverse(rt=>{rt.geometry?.dispose(),rt.material?.dispose()}),E.splice(q,1),Q.done())}for(let q=0;q<r;q++){const Q=ht[q];O[q*3]=Q[0]+Math.sin(st*.3+Q[3])*.6,O[q*3+1]=Q[1]+Math.sin(st*.8+Q[3]*2)*.4,O[q*3+2]=Q[2]+Math.cos(st*.25+Q[3])*.6}if(C.attributes.position.needsUpdate=!0,M.rotation.y+=$*.01,ut.offset.y-=$*.35,T.offset.y+=$*1.4,D.offset.y-=$*.9,F.offset.y-=$*1.9,_(st),x(st),j.children.forEach(q=>{const Q=q.userData,rt=(st*.7+Q.ph)%1,at=Q.s*(.35+rt*1);q.position.set(Q.x,Q.y+rt*.55*Q.s,Q.z-rt*.3),q.scale.set(at,at*.75,1),q.material.opacity=.55*(1-rt)*(1-rt)}),v.children.forEach((q,Q)=>{const rt=(st*.25+Q/7)%1;q.position.set(-s-.4-rt*1.2,c-7.2+rt*.8,Math.sin(Q*2.1)*.8),q.material.opacity=.4*(1-rt),q.scale.set(2+rt*3,1.4+rt*2,1)}),i.nextJump-=$,i.nextJump<0){const q=b[Math.floor(i.rng()*b.length)];q.userData.jt<0&&(q.userData.jt=0,Y(q.position.x,q.position.z)),i.nextJump=8+i.rng()*10}for(const q of b){const Q=q.userData;Q.u=(Q.u+$*Q.speed)%.97;const rt=Z.getPointAt(Q.u),at=Z.getTangentAt(Q.u),yt=Math.sin(st*3+Q.side*9)*.12;if(q.position.set(rt.x-at.z*(Q.side+yt),h-.1,rt.z+at.x*(Q.side+yt)),q.lookAt(q.position.x+at.x,q.position.y,q.position.z+at.z),Q.tail.rotation.y=Math.sin(st*8+Q.side*5)*.5,Q.jt>=0){Q.jt+=$*1.4;const Tt=Math.min(Q.jt,1);if(q.position.y=h-.1+Math.sin(Math.PI*Tt)*.6,q.rotateX(-Math.cos(Math.PI*Tt)*.9),Q.jt>=1){Q.jt=-1;for(let lt=0;lt<3;lt++)Y(q.position.x+(i.rng()-.5)*.2,q.position.z+(i.rng()-.5)*.2)}}}p($,st),Mt.uTime.value=st,ct.emissiveIntensity=I.emissiveIntensity=.05+i.modeT*.2;for(const q of l.nghisu.group.userData.flags){const Q=q.geometry.attributes.position;for(let rt=0;rt<Q.count;rt++){const at=Q.getX(rt)+.3;Q.setZ(rt,Math.sin(st*(2.5+n.wind*.2)-at*7)*(.03+n.wind*.005)*at)}Q.needsUpdate=!0}i.camGoal&&(d.position.lerp(i.camGoal.pos,.06),y.target.lerp(i.camGoal.target,.06),d.position.distanceTo(i.camGoal.pos)<.05&&(i.camGoal=null)),y.update(),g.render(),A(),X.textContent="Amber · "+new Date().toLocaleTimeString("vi-VN",{hour:"2-digit",minute:"2-digit"}),!i.disposed&&!i.paused&&(i.raf=requestAnimationFrame(w))}i.listen(window,"resize",()=>{d.aspect=innerWidth/innerHeight,d.updateProjectionMatrix(),N.setSize(innerWidth,innerHeight),g.setSize(innerWidth,innerHeight),i.current||S()})}function H0(i){const{ENV:t,camera:e,cur:n,renderer:r}=i,s=(()=>{let o=null,a,c,l,h,f,m,p,_,x,d=null,u=null,M=null,g=!1,y=0,L=0,C=5,D=8,F=0,T=0,E=null;const j={duong:{steps:[0,2,5,7,9],root:293.66,beat:.42},am:{steps:[0,3,5,7,10],root:261.63,beat:.62}},O=[{name:"Đàn tranh",sub:"Tự sinh theo Âm/Dương",type:"gen",style:"tranh"},{name:"Sáo trúc",sub:"Tự sinh theo Âm/Dương",type:"gen",style:"sao"},{name:"Chỉ thiên nhiên",sub:"Thác, gió, chim, dế",type:"none"}],B=(()=>{try{return JSON.parse(localStorage.getItem("amber-music")||"{}")}catch{return{}}})(),S=()=>{try{localStorage.setItem("amber-music",JSON.stringify({vol:I.value,nat:U.value,chime:P.checked,idx:O[y]?.type==="file"?0:y}))}catch{}},b=J=>document.getElementById(J),v=b("musicPanel"),A=b("musicBtn"),I=b("mpVol"),U=b("mpNat"),P=b("mpChime"),N=b("mpList");B.vol!=null&&(I.value=B.vol),B.nat!=null&&(U.value=B.nat),B.chime!=null&&(P.checked=B.chime),B.idx&&(y=B.idx);function Y(){if(o)return;o=new(window.AudioContext||window.webkitAudioContext),a=o.createGain(),a.connect(o.destination),l=o.createGain(),h=o.createGain(),f=o.createGain(),f.gain.value=.5,[l,h,f].forEach(Ft=>Ft.connect(a)),c=o.createGain(),c.connect(l);const J=o.createBuffer(2,o.sampleRate*3,o.sampleRate);for(let Ft=0;Ft<2;Ft++){const Ht=J.getChannelData(Ft);for(let Gt=0;Gt<Ht.length;Gt++)Ht[Gt]=(Math.random()*2-1)*Math.pow(1-Gt/Ht.length,3)}const q=o.createConvolver();q.buffer=J;const Q=o.createGain();Q.gain.value=.38,c.connect(q),q.connect(Q),Q.connect(l),f.connect(q),x=o.createBuffer(1,o.sampleRate*2,o.sampleRate);const rt=x.getChannelData(0);for(let Ft=0;Ft<rt.length;Ft++)rt[Ft]=Math.random()*2-1;const at=Z(),yt=o.createBiquadFilter(),Tt=o.createBiquadFilter();yt.type="lowpass",yt.frequency.value=1400,Tt.type="highpass",Tt.frequency.value=180,m=o.createGain(),at.connect(Tt),Tt.connect(yt),yt.connect(m),m.connect(h);const lt=Z(),Rt=o.createBiquadFilter();Rt.type="bandpass",Rt.frequency.value=420,Rt.Q.value=.6,p=o.createGain(),p.gain.value=.12;const V=o.createOscillator(),pt=o.createGain();V.frequency.value=.07,pt.gain.value=.1,V.connect(pt),pt.connect(p.gain),V.start(),lt.connect(Rt),Rt.connect(p),p.connect(h);const wt=Z(),St=o.createBiquadFilter(),Pt=o.createBiquadFilter();St.type="highpass",St.frequency.value=900,Pt.type="lowpass",Pt.frequency.value=7e3,_=o.createGain(),_.gain.value=0,wt.connect(St),St.connect(Pt),Pt.connect(_),_.connect(h),M||(M=new Audio,M.crossOrigin="anonymous",M.onended=()=>R()),o.createMediaElementSource(M).connect(l),nt(),i.setInterval(ht,250)}function Z(){const J=o.createBufferSource();return J.buffer=x,J.loop=!0,J.start(),J}function nt(){if(!o)return;const J=o.currentTime;l.gain.setTargetAtTime((+I.value/100)**2*.9,J,.1),h.gain.setTargetAtTime((+U.value/100)**2,J,.1)}function ht(){const J=e.position.distanceTo(new H(7.2,2,-1));m.gain.setTargetAtTime(.05+.55*Math.max(0,1-J/38)**2,o.currentTime,.3),_.gain.setTargetAtTime(n.r*.55,o.currentTime,.8),p.gain.setTargetAtTime(.1+t.wind*.006+n.storm*.12,o.currentTime,1)}const gt=(J,q)=>J.root*Math.pow(2,(J.steps[(q%5+5)%5]+12*Math.floor(q/5)-12)/12);function xt(J,q,Q=.32,rt=!1){const at=o.createOscillator(),yt=o.createOscillator(),Tt=o.createGain(),lt=o.createGain(),Rt=o.createBiquadFilter(),V=o.createOscillator(),pt=o.createGain();at.type="triangle",yt.type="sine",yt.frequency.value=J*2,lt.gain.value=.22,at.frequency.setValueAtTime(rt?J*1.06:J,q),rt&&at.frequency.exponentialRampToValueAtTime(J,q+.22),V.frequency.value=5.2,pt.gain.setValueAtTime(0,q),pt.gain.linearRampToValueAtTime(J*.012,q+.8),V.connect(pt),pt.connect(at.frequency),Rt.type="lowpass",Rt.frequency.setValueAtTime(J*9,q),Rt.frequency.exponentialRampToValueAtTime(J*1.6,q+1.4),Tt.gain.setValueAtTime(0,q),Tt.gain.linearRampToValueAtTime(Q,q+.006),Tt.gain.exponentialRampToValueAtTime(8e-4,q+2.8),at.connect(Rt),yt.connect(lt),lt.connect(Rt),Rt.connect(Tt),Tt.connect(c);for(const wt of[at,yt,V])wt.start(q),wt.stop(q+2.9)}function Et(J,q,Q,rt=.13){const at=o.createOscillator(),yt=o.createGain(),Tt=o.createOscillator(),lt=o.createGain();at.type="sine",at.frequency.setValueAtTime(J*.985,q),at.frequency.linearRampToValueAtTime(J,q+.12),Tt.frequency.value=4.8,lt.gain.setValueAtTime(0,q),lt.gain.linearRampToValueAtTime(J*.009,q+Math.min(.5,Q*.6)),Tt.connect(lt),lt.connect(at.frequency),yt.gain.setValueAtTime(0,q),yt.gain.linearRampToValueAtTime(rt,q+.18),yt.gain.setValueAtTime(rt,q+Q-.1),yt.gain.exponentialRampToValueAtTime(8e-4,q+Q+.5);const Rt=o.createBufferSource(),V=o.createBiquadFilter(),pt=o.createGain();Rt.buffer=x,V.type="bandpass",V.frequency.value=J*2,V.Q.value=4,pt.gain.setValueAtTime(0,q),pt.gain.linearRampToValueAtTime(rt*.25,q+.1),pt.gain.exponentialRampToValueAtTime(5e-4,q+Q+.3),Rt.connect(V),V.connect(pt),pt.connect(c),at.connect(yt),yt.connect(c);for(const wt of[at,Tt,Rt])wt.start(q),wt.stop(q+Q+.6)}function ct(J){if(!o)return;const q=o.currentTime;if(J&&!d){const Q=j[i.mode];d=[1,1.5].map((rt,at)=>{const yt=o.createOscillator(),Tt=o.createGain();return yt.type="sine",yt.frequency.value=Q.root/2*rt,Tt.gain.setValueAtTime(0,q),Tt.gain.linearRampToValueAtTime(at?.025:.05,q+3),yt.connect(Tt),Tt.connect(c),yt.start(),{o:yt,g:Tt,m:rt}})}!J&&d&&(d.forEach(({o:Q,g:rt})=>{rt.gain.setTargetAtTime(0,q,.5),Q.stop(q+3)}),d=null)}function ut(J){const q=o.createOscillator(),Q=o.createGain(),rt=2+Math.floor(Math.random()*3),at=2400+Math.random()*900;q.type="sine",Q.gain.value=0;for(let yt=0;yt<rt;yt++){const Tt=J+yt*.11;q.frequency.setValueAtTime(at,Tt),q.frequency.exponentialRampToValueAtTime(at*1.5,Tt+.07),Q.gain.setValueAtTime(0,Tt),Q.gain.linearRampToValueAtTime(.05,Tt+.01),Q.gain.linearRampToValueAtTime(0,Tt+.08)}q.connect(Q),Q.connect(h),q.start(J),q.stop(J+rt*.11+.1)}function Mt(J){const q=o.createOscillator(),Q=o.createGain();q.frequency.value=4300+Math.random()*300,Q.gain.value=0;for(let rt=0;rt<4;rt++){const at=J+rt*.045;Q.gain.setValueAtTime(0,at),Q.gain.linearRampToValueAtTime(.022,at+.008),Q.gain.linearRampToValueAtTime(0,at+.03)}q.connect(Q),Q.connect(h),q.start(J),q.stop(J+.25)}function k(J){const q=O[y],Q=j[i.mode];if(Math.random()<(i.mode==="duong"?.05:0)&&ut(J+Math.random()*.3),Math.random()<(i.mode==="am"?.22:0)&&Mt(J+Math.random()*.3),q.type==="gen"){if(F>0){F--;return}if(D<=0){D=6+Math.floor(Math.random()*6),F=2+Math.floor(Math.random()*4),C=Math.random()<.5?5:7;return}if(C=Math.max(2,Math.min(11,C+[-2,-1,-1,0,1,1,2][Math.floor(Math.random()*7)])),q.style==="tranh")Math.random()<.78&&(xt(gt(Q,C),J,.26+Math.random()*.1,Math.random()<.25),D--),Math.random()<.14&&xt(gt(Q,C-5),J+.02,.14);else{if(T>0){T--;return}const rt=[1,2,2,3][Math.floor(Math.random()*4)];T=rt-1,Et(gt(Q,C+2),J,rt*Q.beat*.95),D--,Math.random()<.3&&xt(gt(Q,C-5),J,.12)}}}function tt(){if(E!==i.mode&&d){const J=j[i.mode];d.forEach(q=>q.o.frequency.setTargetAtTime(J.root/2*q.m,o.currentTime,1.5))}for(E=i.mode;L<o.currentTime+.3;)k(L),L+=j[i.mode].beat}function G(){const J=O[y];M.pause(),ct(J.type==="gen"),J.type==="file"&&(M.src=J.url,M.play().catch(()=>{})),L=o.currentTime+.1,D=4,F=0,$()}async function X(){Y(),await o.resume(),g=!0,a.gain.cancelScheduledValues(o.currentTime),a.gain.setTargetAtTime(1,o.currentTime,.3),G(),clearInterval(u),u=i.setInterval(tt,90)}function W(){g=!1,clearInterval(u),M?.pause(),ct(!1),o&&(a.gain.setTargetAtTime(0,o.currentTime,.2),i.setTimeout(()=>!g&&o.suspend(),900)),$()}function et(J){const q=O[y];for(let at=O.length-1;at>=0;at--)O[at].lib&&O.splice(at,1);const Q=(Array.isArray(J)?J:[]).filter(at=>at&&typeof at.url=="string").map(at=>({name:String(at.title||"Không tên"),sub:at.artist?String(at.artist):"Kiều Lâu",type:"file",url:at.url,lib:!0}));O.splice(3,0,...Q);const rt=q&&O.findIndex(at=>at===q||q.lib&&at.lib&&at.name===q.name);y=rt!=null&&rt>=0?rt:Math.min(y,O.length-1),$()}function it(J){y=(J+O.length)%O.length,S(),g?G():$()}const R=()=>it(y+1);function w(J){if(!o||!g||!P.checked)return;const q=o.currentTime+.02,Q=J==="bad"?587:J==="warn"?698:880,rt=J==="bad"?2:1;for(let at=0;at<rt;at++)[[1,1],[2.76,.45],[5.4,.22],[8.93,.1]].forEach(([yt,Tt])=>{const lt=o.createOscillator(),Rt=o.createGain(),V=q+at*.35;lt.frequency.value=Q*yt,Rt.gain.setValueAtTime(0,V),Rt.gain.linearRampToValueAtTime(.16*Tt,V+.004),Rt.gain.exponentialRampToValueAtTime(5e-4,V+2.4/yt**.3),lt.connect(Rt),Rt.connect(f),lt.start(V),lt.stop(V+2.6)})}function $(){const J=O[y];b("mpTitle").textContent=J.name,b("mpSub").textContent=J.sub,b("mpPlayIcon").setAttribute("d",g?"M7 5h4v14H7zM13 5h4v14h-4z":"M8 5v14l11-7z"),A.classList.toggle("playing",g),N.innerHTML=O.map((q,Q)=>`<div class="mp-item ${Q===y?"on":""}" data-i="${Q}">${Q===y&&g?"♫":"·"} ${q.name}<small>${q.lib?"Kiều Lâu":q.type==="file"?"File":q.type==="gen"?"Tự sinh":"Môi trường"}</small></div>`).join(""),N.querySelectorAll(".mp-item").forEach(q=>q.onclick=()=>{it(+q.dataset.i),g||X()})}A.onclick=J=>{J.stopPropagation(),document.getElementById("wxPanel").classList.remove("on"),v.classList.toggle("on")},v.addEventListener("pointerdown",J=>J.stopPropagation()),r.domElement.addEventListener("pointerdown",()=>v.classList.remove("on")),b("mpPlay").onclick=()=>g?W():X(),b("mpNext").onclick=R,b("mpPrev").onclick=()=>it(y-1),I.oninput=()=>{nt(),S()},U.oninput=()=>{nt(),S()},P.onchange=S,b("mpFile").onchange=J=>{const q=O.length;for(const Q of J.target.files)O.push({name:Q.name.replace(/\.[^.]+$/,""),sub:"Nhạc của bạn",type:"file",url:URL.createObjectURL(Q)});J.target.value="",O.length>q&&(it(q),g||X())},$();function st(J){if(!o||!g)return;const q=o.currentTime+J,Q=o.createBufferSource(),rt=o.createBiquadFilter(),at=o.createGain();Q.buffer=x,Q.loop=!0,rt.type="lowpass",rt.frequency.setValueAtTime(900,q),rt.frequency.exponentialRampToValueAtTime(120,q+2.5),at.gain.setValueAtTime(0,q),at.gain.linearRampToValueAtTime(.9,q+.05),at.gain.exponentialRampToValueAtTime(.3,q+.6),at.gain.exponentialRampToValueAtTime(.001,q+3.5),Q.connect(rt),rt.connect(at),at.connect(h),Q.start(q),Q.stop(q+3.6)}return i.disposeAudio=()=>{g=!1,clearInterval(u),M&&(M.pause(),M.removeAttribute("src")),O.forEach(J=>J.type==="file"&&URL.revokeObjectURL(J.url)),o?.close()},{chime:w,play:X,pause:W,go:it,thunder:st,setLibrary:et}})();i.Sound=s}function V0(i){const{STATS:t,Sound:e,checkCrit:n,loop:r,push:s,renderStats:o,renderWx:a,select:c,setMode:l,setWeather:h,updateLabels:f}=i;i.api={push:s,setStat:(m,p)=>{t[m]&&(t[m].v=p,n(),o())},setStats:m=>{for(const[p,_]of Object.entries(m??{})){const x=t[p];!x||!_||(x.v=_.v==null?null:Math.max(0,Math.min(100,+_.v)),_.src&&(x.src=_.src))}n(),o(),i.current&&i.renderSheet(i.current)},setPaused:m=>{m=!!m,m!==!!i.paused&&(i.paused=m,m?(cancelAnimationFrame(i.raf),i.raf=0):i.loopStarted&&r())},select:c,setMode:l,setWeather:h,music:e},o(),f(),a(),i.startLoop=()=>{i.loopStarted=!0,i.paused||r()},i.setTimeout(()=>s({from:"kieulau",lvl:"info",text:"Chào mừng về Âm Dương Giới"}),1200)}const X0=[["config",i0],["core/scene",g0],["sky",_0],["materials",v0],["terrain",x0],["water",M0],["mountain",b0],["river-life",E0],["buildings/common",w0],["buildings/kieu-lau",T0],["buildings/tang-kinh",A0],["buildings/tra-dinh",R0],["buildings/nghi-su",C0],["buildings/index",P0],["amber",L0],["flora/trees",D0],["flora/nature",I0],["flora/atmosphere",U0],["weather",N0],["ui/weather-panel",O0],["state",F0],["flights",B0],["ui/labels",z0],["ui/sheet",G0],["loop",k0],["audio",H0],["api",V0]];function W0(i){let t=i>>>0;return()=>{t=t+1831565813>>>0;let e=t;return e=Math.imul(e^e>>>15,e|1),e^=e+Math.imul(e^e>>>7,e|61),((e^e>>>14)>>>0)/4294967296}}const q0=20261115;function Y0(i,t={}){const e=new Set,n=new Set,r=[],s={lite:t.lite??!1,seed:t.seed??q0,demo:t.demo??!1,onNavigate:t.onNavigate??(()=>{}),quality:t.quality??null,onQuality:t.onQuality??(()=>{})},o={root:i,opts:s,rng:W0(s.seed),disposed:!1,raf:0,setTimeout(a,c){const l=window.setTimeout(()=>{e.delete(l),o.disposed||a()},c);return e.add(l),l},setInterval(a,c){const l=window.setInterval(()=>{o.disposed||a()},c);return n.add(l),l},listen(a,c,l,h){a.addEventListener(c,l,h),r.push([a,c,l,h])},_clearTimers(){e.forEach(a=>clearTimeout(a)),n.forEach(a=>clearInterval(a)),e.clear(),n.clear();for(const[a,c,l,h]of r)a.removeEventListener(c,l,h);r.length=0}};return o}const j0=`
<div id="hud">
  <div id="topbar">
    <div id="title">Âm Dương Giới<small id="clock">Amber</small></div>
    <button id="musicBtn" class="glass"><span class="eq"><i></i><i></i><i></i></span>Nhạc</button>
    <button id="wxBtn" class="glass">☀ --°</button>
  </div>
  <div id="stats"></div>
  <div id="toasts"></div>
</div>
<div id="musicPanel" class="glass">
  <div class="mp-now"><div class="mp-art">♫</div><div><b id="mpTitle">Đàn tranh</b><small id="mpSub">Tự sinh theo Âm/Dương</small></div></div>
  <div class="mp-ctrl">
    <button id="mpPrev" aria-label="Bài trước"><svg viewBox="0 0 24 24"><path d="M6 5h2v14H6zM20 5v14L9 12z"/></svg></button>
    <button id="mpPlay" class="big" aria-label="Phát"><svg viewBox="0 0 24 24"><path id="mpPlayIcon" d="M8 5v14l11-7z"/></svg></button>
    <button id="mpNext" aria-label="Bài sau"><svg viewBox="0 0 24 24"><path d="M16 5h2v14h-2zM4 5v14l11-7z"/></svg></button>
  </div>
  <label class="mp-row">Nhạc<input type="range" id="mpVol" min="0" max="100" value="60"></label>
  <label class="mp-row">Thiên nhiên<input type="range" id="mpNat" min="0" max="100" value="45"></label>
  <label class="mp-row">Chuông thông báo<input type="checkbox" id="mpChime" checked></label>
  <div class="sec">Danh sách</div>
  <div id="mpList"></div>
  <label class="btn mp-add">+ Thêm nhạc của bạn<input type="file" id="mpFile" accept="audio/*" multiple hidden></label>
</div>
<div id="wxPanel" class="glass">
  <div class="wx-head"><div class="wx-icon" id="wxIcon">☀</div><div><b id="wxTitle">Nắng</b><small id="wxSub">Buổi trưa</small></div></div>
  <div class="sec">Giờ trong ngày</div>
  <label class="mp-row"><span id="wxHourLbl">12:00</span><input type="range" id="wxHour" min="0" max="24" step=".25" value="12"></label>
  <div class="wx-chips" id="wxTime"></div>
  <div class="sec">Thời tiết</div>
  <div class="wx-chips" id="wxChips"></div>
  <div class="sec">Đồ hoạ</div>
  <div class="wx-chips" id="wxQuality"></div>
  <div class="wx-note" id="wxNote"></div>
</div>
<div id="sheet" class="glass"><button id="close">×</button><div id="sheetBody"></div></div>
<div id="hint" class="glass">Chạm vào toà nhà · kéo để xoay · chụm để zoom</div>
`,$0=["position","normal","uv","color","aLocalPos"];function K0(i){const t=new Set,e=n=>{n instanceof ae&&t.add(n)};for(const n of i.trees??[])e(n.g);for(const n of i.reeds??[])e(n.g);for(const n of[...i.lotus??[],...i.floatPetals??[],...i.ripples??[]])e(n);for(const n of i.dflies??[]){e(n);for(const[r]of n.userData?.wings??[])e(r)}for(const n of i.koi??[])e(n),e(n.userData?.tail);e(i.amber),e(i.shell);for(const n of i.halos??[])e(n);for(const n of Object.values(i.TOWERS??{})){e(n.aura),e(n.group?.userData?.bell);for(const r of n.group?.userData?.flags??[])e(r)}for(const n of i.hitTargets??[])e(n);return e(i.sky),t}function Z0(i){!i.attributes.aLocalPos&&i.attributes.position&&i.setAttribute("aLocalPos",i.attributes.position)}const hc=i=>(Array.isArray(i.material)?i.material:[i.material]).some(t=>!!t?.userData?.detail);function J0(i,t){if(!i.isMesh||i.isInstancedMesh||i.isSkinnedMesh||t.has(i)||Array.isArray(i.material))return!1;const e=i.material;if(e.transparent||!e.visible||e.type==="ShaderMaterial"||e.type==="RawShaderMaterial")return!1;const n=i.geometry;if(!n.attributes.position||Object.keys(n.morphAttributes).length)return!1;for(const r of Object.keys(n.attributes))if(!$0.includes(r))return!1;for(let r=i;r;r=r.parent)if(!r.visible)return!1;return!0}function Q0(i,t,e){for(let n=i.parent;n;n=n.parent)if(t.has(n))return n;return e}function tg(i,t,e){const n=i.geometry.clone();if(n.clearGroups(),e&&n.setAttribute("aLocalPos",n.attributes.position.clone()),n.applyMatrix4(t),!n.index){const r=n.attributes.position.count,s=new(r>65535?Uint32Array:Uint16Array)(r);for(let o=0;o<r;o++)s[o]=o;n.setIndex(new le(s,1))}if(t.determinant()<0){const r=n.index.array;for(let s=0;s<r.length;s+=3){const o=r[s+1];r[s+1]=r[s+2],r[s+2]=o}}return n}function eg(i){const t=new Set;for(const e of i)for(const n of Object.keys(e.attributes))t.add(n);for(const e of t){const n=i.find(r=>r.attributes[e]).attributes[e];for(const r of i)r.attributes[e]||r.setAttribute(e,new le(new Float32Array(r.attributes.position.count*n.itemSize),n.itemSize,n.normalized))}}function ng(i){const t=i.scene;t.updateMatrixWorld(!0);const e=K0(i),n=new Map;let r=0;t.traverse(p=>{const _=p;if(!_.isMesh||(r++,!J0(_,e)))return;const x=Q0(_,e,t),d=`${x.id}|${_.material.uuid}|${+_.castShadow}${+_.receiveShadow}|${_.renderOrder}`;let u=n.get(d);u||n.set(d,u={anchor:x,meshes:[]}),u.meshes.push(_)});const s=new ee,o=new ee;let a=0,c=0;for(const{anchor:p,meshes:_}of n.values()){if(_.length<2)continue;s.copy(p.matrixWorld).invert();const x=hc(_[0]),d=_.map(y=>tg(y,o.multiplyMatrices(s,y.matrixWorld),x));eg(d);const u=ol(d,!1);if(d.forEach(y=>y.dispose()),!u)continue;u.computeBoundingSphere();const M=_[0],g=new Bt(u,M.material);g.castShadow=M.castShadow,g.receiveShadow=M.receiveShadow,g.renderOrder=M.renderOrder,g.name=`merged:${M.material.type}`,p.add(g);for(const y of _)y.removeFromParent();a++,c+=_.length}t.traverse(p=>{const _=p;_.isMesh&&hc(_)&&Z0(_.geometry)});const l=new Set(e);for(const p of Object.values(i))p instanceof ae&&l.add(p);for(const p of Object.values(i.TOWERS??{}))p.group&&l.add(p.group);let h=0;for(let p=!0;p;){p=!1;const _=[];t.traverse(x=>{x!==t&&!x.children.length&&(x.type==="Group"||x.type==="Object3D")&&!l.has(x)&&_.push(x)});for(const x of _)x.removeFromParent(),h++,p=!0}let f=0;t.traverse(p=>{const _=p;!_.isMesh||e.has(_)||(_.updateMatrix(),_.matrixAutoUpdate=!1,f++)});let m=0;return t.traverse(p=>{p.isMesh&&m++}),{meshesBefore:r,meshesAfter:m,groups:a,emptyGroupsRemoved:h,frozenMeshes:f}}const Ir={high:{dpr:2,shadow:2048,grassBuild:13e3,grassDraw:13e3,label:"Cao"},medium:{dpr:1.5,shadow:1536,grassBuild:13e3,grassDraw:9e3,label:"Vừa"},low:{dpr:1.25,shadow:1024,grassBuild:5e3,grassDraw:5e3,label:"Thấp",shadowSlow:!0}},Lr=["high","medium","low"],ig=["dpr1","shadowSlow","noBloom"];function al(i){const t=navigator.userAgent,e=/iPad/.test(t)||navigator.platform==="MacIntel"&&navigator.maxTouchPoints>1,n=/iPhone|iPod/.test(t)||e,r=/Android/.test(t),s=e||r&&!/Mobile/.test(t),o=n||r;let a="";try{const l=i??document.createElement("canvas").getContext("webgl2"),h=l?.getExtension("WEBGL_debug_renderer_info");a=l?String(h?l.getParameter(h.UNMASKED_RENDERER_WEBGL):l.getParameter(l.RENDERER)):"",i||l?.getExtension("WEBGL_lose_context")?.loseContext()}catch{}const c=navigator;return{mobile:o,tablet:s,ios:n,gpu:a,software:/SwiftShader|llvmpipe|softpipe|Software|Microsoft Basic/i.test(a),memory:c.deviceMemory,cores:navigator.hardwareConcurrency}}function cl(i){return i.software?null:i.mobile?i.tablet?"medium":"low":i.memory&&i.memory<=4||i.cores&&i.cores<=4?"medium":"high"}const Zs="amber-world.quality";function rg(){try{const i=JSON.parse(localStorage.getItem(Zs)??"null");return i&&typeof i=="object"?i:null}catch{return null}}function Ur(i){try{i?localStorage.setItem(Zs,JSON.stringify(i)):localStorage.removeItem(Zs)}catch{}}const sg=26,og=15,ag=3e3,cg=4e3;function lg(i,t,e){const n=i.renderer,r=i.sun,s={...t};let o=0,a=null,c=!1;function l(){const g=Ir[s.tier],y=Math.min(devicePixelRatio,s.extra>=1?1:g.dpr);n.getPixelRatio()!==y&&(n.setPixelRatio(y),i.composer.setPixelRatio(y),n.setSize(innerWidth,innerHeight),i.composer.setSize(innerWidth,innerHeight)),r.shadow.mapSize.x!==g.shadow&&(r.shadow.mapSize.set(g.shadow,g.shadow),r.shadow.map?.dispose(),r.shadow.map=null),i.grass&&(i.grass.count=Math.min(g.grassDraw,i.grassBuilt??g.grassDraw));const L=!!g.shadowSlow||s.extra>=2;n.shadowMap.autoUpdate=!L,L&&!o&&(o=i.setInterval(()=>{n.shadowMap.needsUpdate=!0},1e3)),!L&&o&&(clearInterval(o),o=0),n.shadowMap.needsUpdate=!0,i.bloom&&(i.bloom.enabled=s.extra<3),u()}function h(){e({...s,fps:a,tooSlow:c})}function f(){const g=Lr.indexOf(s.tier);if(g<Lr.length-1)s.tier=Lr[g+1];else if(s.extra<ig.length)s.extra++;else return!1;return l(),s.choice==="auto"&&Ur({choice:"auto",tier:s.tier,extra:s.extra}),!0}let m=0,p=0,_=0;const x=g=>{if(!i.disposed){if(requestAnimationFrame(x),!i.loopStarted||i.paused||document.hidden){m=0;return}if(_||(_=g+ag),!(g<_)){if(!m){m=g,p=0;return}if(p++,!(g-m<cg)&&(a=Math.round(p*1e3/(g-m)*10)/10,m=0,s.choice==="auto"&&a<sg)){if(f()){_=g+2e3,h();return}a<og&&!c&&(c=!0,h())}}}};requestAnimationFrame(x);const d=document.getElementById("wxQuality");function u(){if(!d)return;const g=s.choice==="auto"?`Tự động · ${Ir[s.tier].label}${s.extra?` (−${s.extra})`:""}`:"";d.innerHTML=["auto",...Lr].map(y=>`<button class="wx-chip ${y===s.choice?"on":""}" data-q="${y}">${y==="auto"?g||"Tự động":Ir[y].label}</button>`).join(""),d.querySelectorAll("[data-q]").forEach(y=>y.onclick=()=>M(y.dataset.q))}function M(g){s.choice=g,c=!1,g==="auto"?(s.tier=i.detectedTier??s.tier,s.extra=0,Ur(null)):(s.tier=g,s.extra=0,Ur({choice:g})),_=0,m=0,l(),h()}return l(),h(),{state:s,choose:M,apply:l,get fps(){return a}}}function ll(i,t={}){i.innerHTML=j0;const e=Y0(i,t),n=rg();e.device=al(),e.detectedTier=cl(e.device)??"low";const r=t.lite?"low":t.quality??n?.choice??"auto",s=r==="auto"&&n?.choice==="auto",o={choice:r,tier:r==="auto"?s&&n.tier||e.detectedTier:r,extra:s?n.extra??0:0};e.Q=Ir[o.tier],e.buildTimes={};const a=new Set(["mountain","buildings/index","flora/trees"]);let c=null;const l=new il(16777215,0),h=()=>new Promise(M=>{const g=e.renderer;g.setRenderTarget(e.composer.readBuffer),g.compile(e.scene,e.camera),g.setRenderTarget(null);const y=()=>{(g.info.programs??[]).every(C=>C.isReady())?M():e.setTimeout(y,10)};y()});for(const[M,g]of X0){const y=performance.now();g(e),M==="sky"&&(c=e.pmrem.fromScene(e.envScene,0,.1,200),e.scene.environment=c.texture,e.scene.add(l)),M==="amber"&&(l.removeFromParent(),l.dispose()),a.has(M)&&h(),e.buildTimes[M]=Math.round(performance.now()-y)}let f=performance.now();e.mergeStats=ng(e),e.buildTimes["perf/merge"]=Math.round(performance.now()-f),f=performance.now();const m=()=>{e.disposed||(e.buildTimes["perf/compile"]=Math.round(performance.now()-f),e.startLoop(),e.quality=lg(e,o,M=>e.opts.onQuality(M)))};e.updateEnv(0,0),c?.dispose(),h().then(m);let p=e.api;const _=M=>(...g)=>p?.[M]?.(...g),x=M=>(...g)=>p?.music[M]?.(...g),u={api:{push:_("push"),setStat:_("setStat"),setStats:_("setStats"),setPaused:_("setPaused"),select:_("select"),setMode:_("setMode"),setWeather:_("setWeather"),music:{play:x("play"),pause:x("pause"),go:x("go"),chime:x("chime"),thunder:x("thunder"),setLibrary:x("setLibrary")}},dispose:()=>{p=null,ug(e),u.ctx=null},ctx:e};return u}function Js(i,t){if(t.has(i))return;t.add(i);for(const n of Object.values(i))n instanceof Te&&!t.has(n)&&(t.add(n),n.dispose());const e=i.uniforms;if(e)for(const n of Object.values(e))n?.value instanceof Te&&!t.has(n.value)&&(t.add(n.value),n.value.dispose());i.dispose()}function dc(i,t){i.traverse(e=>{const n=e;n.geometry&&!t.has(n.geometry)&&(t.add(n.geometry),n.geometry.dispose());const r=n.material;Array.isArray(r)?r.forEach(s=>Js(s,t)):r&&Js(r,t),e.isInstancedMesh&&e.dispose(),e.isLight&&e.dispose()})}function ug(i){if(i.disposed)return;i.disposed=!0,cancelAnimationFrame(i.raf),i._clearTimers(),i.disposeAudio?.(),i.controls?.dispose();const t=new Set;i.scene&&(dc(i.scene,t),i.scene.environment=null),i.envScene&&dc(i.envScene,t);for(const e of Object.values(i.MAT??{}))Js(e,t);if(i.envRT?.dispose(),i.pmrem?.dispose(),i.bloom?.dispose(),i.composer?.dispose(),i.renderer){const e=i.renderer;e.dispose(),e.forceContextLoss(),e.domElement.remove()}i.root.innerHTML="";for(const e of Object.keys(i))e!=="disposed"&&e!=="root"&&delete i[e]}function hg(i){if(window.parent===window)return()=>{};const t=location.origin,e=a=>window.parent.postMessage({source:"amber-world",...a},t),n=a=>{if(a.origin!==t||a.source!==window.parent)return;const c=a.data;if(!c||c.source!=="amber-flutter"||c.type!=="call"||typeof c.method!="string")return;const l=Array.isArray(c.args)?c.args:[],[h,f]=c.method.split("."),p=(f?i.api[h]:i.api)?.[f??h];typeof p=="function"&&p(...l)};window.addEventListener("message",n);const r=document.getElementById("sheet");let s=!1;const o=new MutationObserver(()=>{const a=!!r?.classList.contains("on");a!==s&&(s=a,e({type:"sheet",open:a,id:a?i.ctx?.current??null:null}))});return r&&o.observe(r,{attributes:!0,attributeFilter:["class"]}),e({type:"ready"}),()=>{o.disconnect(),window.removeEventListener("message",n)}}function ul(i){window.parent!==window&&window.parent.postMessage({source:"amber-world",...i},location.origin)}function dg(i){window.parent!==window&&window.parent.postMessage({source:"amber-world",type:"navigate",path:i},location.origin)}const Bn=new URLSearchParams(location.search),hl=Bn.get("q");Bn.has("retry")&&Ur(null);if(!hl&&!Bn.has("lite")&&cl(al())===null)throw ul({type:"unsupported",reason:"software_webgl"}),document.getElementById("world").innerHTML='<p style="padding:24px;font-family:Gelasio,serif">Thiết bị không có tăng tốc đồ hoạ — dùng giao diện 2D.</p>',new Error("amber-world: software WebGL");const go=ll(document.getElementById("world"),{lite:Bn.has("lite"),seed:Bn.has("seed")?Number(Bn.get("seed")):void 0,demo:Bn.has("demo"),onNavigate:dg,quality:hl,onQuality:i=>ul({type:"quality",tier:i.tier,extra:i.extra,choice:i.choice,fps:i.fps,tooSlow:i.tooSlow})});window.AmberWorld=go.api;window.__world=go;hg(go);window.__createWorld=ll;
