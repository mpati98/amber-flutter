var oc=Object.defineProperty;var ac=(i,t,e)=>t in i?oc(i,t,{enumerable:!0,configurable:!0,writable:!0,value:e}):i[t]=e;var xo=(i,t,e)=>ac(i,typeof t!="symbol"?t+"":t,e);(function(){const t=document.createElement("link").relList;if(t&&t.supports&&t.supports("modulepreload"))return;for(const r of document.querySelectorAll('link[rel="modulepreload"]'))n(r);new MutationObserver(r=>{for(const s of r)if(s.type==="childList")for(const o of s.addedNodes)o.tagName==="LINK"&&o.rel==="modulepreload"&&n(o)}).observe(document,{childList:!0,subtree:!0});function e(r){const s={};return r.integrity&&(s.integrity=r.integrity),r.referrerPolicy&&(s.referrerPolicy=r.referrerPolicy),r.crossOrigin==="use-credentials"?s.credentials="include":r.crossOrigin==="anonymous"?s.credentials="omit":s.credentials="same-origin",s}function n(r){if(r.ep)return;r.ep=!0;const s=e(r);fetch(r.href,s)}})();/**
 * @license
 * Copyright 2010-2023 Three.js Authors
 * SPDX-License-Identifier: MIT
 */const $s="160",Xn={ROTATE:0,DOLLY:1,PAN:2},qn={ROTATE:0,PAN:1,DOLLY_PAN:2,DOLLY_ROTATE:3},lc=0,Mo=1,cc=2,ll=1,cl=2,cn=3,wn=0,Te=1,be=2,hn=0,_i=1,Ns=2,yo=3,So=4,uc=5,On=100,hc=101,dc=102,bo=103,Eo=104,fc=200,pc=201,mc=202,gc=203,Os=204,Fs=205,_c=206,vc=207,xc=208,Mc=209,yc=210,Sc=211,bc=212,Ec=213,Tc=214,wc=0,Ac=1,Rc=2,Lr=3,Cc=4,Pc=5,Lc=6,Dc=7,ul=0,Ic=1,Uc=2,En=0,hl=1,dl=2,fl=3,Ks=4,Nc=5,pl=6,ml=300,xi=301,Mi=302,Bs=303,zs=304,kr=306,yi=1e3,Ve=1001,Gs=1002,Le=1003,To=1004,Zr=1005,ke=1006,Oc=1007,Wi=1008,Tn=1009,Fc=1010,Bc=1011,Zs=1012,gl=1013,Sn=1014,bn=1015,dn=1016,_l=1017,vl=1018,Bn=1020,zc=1021,je=1023,Gc=1024,kc=1025,zn=1026,Si=1027,Hc=1028,xl=1029,Vc=1030,Ml=1031,yl=1033,Jr=33776,Qr=33777,ts=33778,es=33779,wo=35840,Ao=35841,Ro=35842,Co=35843,Sl=36196,Po=37492,Lo=37496,Do=37808,Io=37809,Uo=37810,No=37811,Oo=37812,Fo=37813,Bo=37814,zo=37815,Go=37816,ko=37817,Ho=37818,Vo=37819,Wo=37820,Xo=37821,ns=36492,qo=36494,Yo=36495,Wc=36283,jo=36284,$o=36285,Ko=36286,bl=3e3,Gn=3001,Xc=3200,qc=3201,El=0,Yc=1,We="",ce="srgb",pn="srgb-linear",Js="display-p3",Hr="display-p3-linear",Dr="linear",se="srgb",Ir="rec709",Ur="p3",Yn=7680,Zo=519,jc=512,$c=513,Kc=514,Tl=515,Zc=516,Jc=517,Qc=518,tu=519,ks=35044,Jo="300 es",Hs=1035,un=2e3,Nr=2001;class kn{addEventListener(t,e){this._listeners===void 0&&(this._listeners={});const n=this._listeners;n[t]===void 0&&(n[t]=[]),n[t].indexOf(e)===-1&&n[t].push(e)}hasEventListener(t,e){if(this._listeners===void 0)return!1;const n=this._listeners;return n[t]!==void 0&&n[t].indexOf(e)!==-1}removeEventListener(t,e){if(this._listeners===void 0)return;const r=this._listeners[t];if(r!==void 0){const s=r.indexOf(e);s!==-1&&r.splice(s,1)}}dispatchEvent(t){if(this._listeners===void 0)return;const n=this._listeners[t.type];if(n!==void 0){t.target=this;const r=n.slice(0);for(let s=0,o=r.length;s<o;s++)r[s].call(this,t);t.target=null}}}const ye=["00","01","02","03","04","05","06","07","08","09","0a","0b","0c","0d","0e","0f","10","11","12","13","14","15","16","17","18","19","1a","1b","1c","1d","1e","1f","20","21","22","23","24","25","26","27","28","29","2a","2b","2c","2d","2e","2f","30","31","32","33","34","35","36","37","38","39","3a","3b","3c","3d","3e","3f","40","41","42","43","44","45","46","47","48","49","4a","4b","4c","4d","4e","4f","50","51","52","53","54","55","56","57","58","59","5a","5b","5c","5d","5e","5f","60","61","62","63","64","65","66","67","68","69","6a","6b","6c","6d","6e","6f","70","71","72","73","74","75","76","77","78","79","7a","7b","7c","7d","7e","7f","80","81","82","83","84","85","86","87","88","89","8a","8b","8c","8d","8e","8f","90","91","92","93","94","95","96","97","98","99","9a","9b","9c","9d","9e","9f","a0","a1","a2","a3","a4","a5","a6","a7","a8","a9","aa","ab","ac","ad","ae","af","b0","b1","b2","b3","b4","b5","b6","b7","b8","b9","ba","bb","bc","bd","be","bf","c0","c1","c2","c3","c4","c5","c6","c7","c8","c9","ca","cb","cc","cd","ce","cf","d0","d1","d2","d3","d4","d5","d6","d7","d8","d9","da","db","dc","dd","de","df","e0","e1","e2","e3","e4","e5","e6","e7","e8","e9","ea","eb","ec","ed","ee","ef","f0","f1","f2","f3","f4","f5","f6","f7","f8","f9","fa","fb","fc","fd","fe","ff"];let Qo=1234567;const zi=Math.PI/180,Xi=180/Math.PI;function fn(){const i=Math.random()*4294967295|0,t=Math.random()*4294967295|0,e=Math.random()*4294967295|0,n=Math.random()*4294967295|0;return(ye[i&255]+ye[i>>8&255]+ye[i>>16&255]+ye[i>>24&255]+"-"+ye[t&255]+ye[t>>8&255]+"-"+ye[t>>16&15|64]+ye[t>>24&255]+"-"+ye[e&63|128]+ye[e>>8&255]+"-"+ye[e>>16&255]+ye[e>>24&255]+ye[n&255]+ye[n>>8&255]+ye[n>>16&255]+ye[n>>24&255]).toLowerCase()}function xe(i,t,e){return Math.max(t,Math.min(e,i))}function Qs(i,t){return(i%t+t)%t}function eu(i,t,e,n,r){return n+(i-t)*(r-n)/(e-t)}function nu(i,t,e){return i!==t?(e-i)/(t-i):0}function Gi(i,t,e){return(1-e)*i+e*t}function iu(i,t,e,n){return Gi(i,t,1-Math.exp(-e*n))}function ru(i,t=1){return t-Math.abs(Qs(i,t*2)-t)}function su(i,t,e){return i<=t?0:i>=e?1:(i=(i-t)/(e-t),i*i*(3-2*i))}function ou(i,t,e){return i<=t?0:i>=e?1:(i=(i-t)/(e-t),i*i*i*(i*(i*6-15)+10))}function au(i,t){return i+Math.floor(Math.random()*(t-i+1))}function lu(i,t){return i+Math.random()*(t-i)}function cu(i){return i*(.5-Math.random())}function uu(i){i!==void 0&&(Qo=i);let t=Qo+=1831565813;return t=Math.imul(t^t>>>15,t|1),t^=t+Math.imul(t^t>>>7,t|61),((t^t>>>14)>>>0)/4294967296}function hu(i){return i*zi}function du(i){return i*Xi}function Vs(i){return(i&i-1)===0&&i!==0}function fu(i){return Math.pow(2,Math.ceil(Math.log(i)/Math.LN2))}function Or(i){return Math.pow(2,Math.floor(Math.log(i)/Math.LN2))}function pu(i,t,e,n,r){const s=Math.cos,o=Math.sin,a=s(e/2),l=o(e/2),c=s((t+n)/2),u=o((t+n)/2),f=s((t-n)/2),m=o((t-n)/2),p=s((n-t)/2),v=o((n-t)/2);switch(r){case"XYX":i.set(a*u,l*f,l*m,a*c);break;case"YZY":i.set(l*m,a*u,l*f,a*c);break;case"ZXZ":i.set(l*f,l*m,a*u,a*c);break;case"XZX":i.set(a*u,l*v,l*p,a*c);break;case"YXY":i.set(l*p,a*u,l*v,a*c);break;case"ZYZ":i.set(l*v,l*p,a*u,a*c);break;default:console.warn("THREE.MathUtils: .setQuaternionFromProperEuler() encountered an unknown order: "+r)}}function tn(i,t){switch(t.constructor){case Float32Array:return i;case Uint32Array:return i/4294967295;case Uint16Array:return i/65535;case Uint8Array:return i/255;case Int32Array:return Math.max(i/2147483647,-1);case Int16Array:return Math.max(i/32767,-1);case Int8Array:return Math.max(i/127,-1);default:throw new Error("Invalid component type.")}}function ee(i,t){switch(t.constructor){case Float32Array:return i;case Uint32Array:return Math.round(i*4294967295);case Uint16Array:return Math.round(i*65535);case Uint8Array:return Math.round(i*255);case Int32Array:return Math.round(i*2147483647);case Int16Array:return Math.round(i*32767);case Int8Array:return Math.round(i*127);default:throw new Error("Invalid component type.")}}const wl={DEG2RAD:zi,RAD2DEG:Xi,generateUUID:fn,clamp:xe,euclideanModulo:Qs,mapLinear:eu,inverseLerp:nu,lerp:Gi,damp:iu,pingpong:ru,smoothstep:su,smootherstep:ou,randInt:au,randFloat:lu,randFloatSpread:cu,seededRandom:uu,degToRad:hu,radToDeg:du,isPowerOfTwo:Vs,ceilPowerOfTwo:fu,floorPowerOfTwo:Or,setQuaternionFromProperEuler:pu,normalize:ee,denormalize:tn};class wt{constructor(t=0,e=0){wt.prototype.isVector2=!0,this.x=t,this.y=e}get width(){return this.x}set width(t){this.x=t}get height(){return this.y}set height(t){this.y=t}set(t,e){return this.x=t,this.y=e,this}setScalar(t){return this.x=t,this.y=t,this}setX(t){return this.x=t,this}setY(t){return this.y=t,this}setComponent(t,e){switch(t){case 0:this.x=e;break;case 1:this.y=e;break;default:throw new Error("index is out of range: "+t)}return this}getComponent(t){switch(t){case 0:return this.x;case 1:return this.y;default:throw new Error("index is out of range: "+t)}}clone(){return new this.constructor(this.x,this.y)}copy(t){return this.x=t.x,this.y=t.y,this}add(t){return this.x+=t.x,this.y+=t.y,this}addScalar(t){return this.x+=t,this.y+=t,this}addVectors(t,e){return this.x=t.x+e.x,this.y=t.y+e.y,this}addScaledVector(t,e){return this.x+=t.x*e,this.y+=t.y*e,this}sub(t){return this.x-=t.x,this.y-=t.y,this}subScalar(t){return this.x-=t,this.y-=t,this}subVectors(t,e){return this.x=t.x-e.x,this.y=t.y-e.y,this}multiply(t){return this.x*=t.x,this.y*=t.y,this}multiplyScalar(t){return this.x*=t,this.y*=t,this}divide(t){return this.x/=t.x,this.y/=t.y,this}divideScalar(t){return this.multiplyScalar(1/t)}applyMatrix3(t){const e=this.x,n=this.y,r=t.elements;return this.x=r[0]*e+r[3]*n+r[6],this.y=r[1]*e+r[4]*n+r[7],this}min(t){return this.x=Math.min(this.x,t.x),this.y=Math.min(this.y,t.y),this}max(t){return this.x=Math.max(this.x,t.x),this.y=Math.max(this.y,t.y),this}clamp(t,e){return this.x=Math.max(t.x,Math.min(e.x,this.x)),this.y=Math.max(t.y,Math.min(e.y,this.y)),this}clampScalar(t,e){return this.x=Math.max(t,Math.min(e,this.x)),this.y=Math.max(t,Math.min(e,this.y)),this}clampLength(t,e){const n=this.length();return this.divideScalar(n||1).multiplyScalar(Math.max(t,Math.min(e,n)))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this}negate(){return this.x=-this.x,this.y=-this.y,this}dot(t){return this.x*t.x+this.y*t.y}cross(t){return this.x*t.y-this.y*t.x}lengthSq(){return this.x*this.x+this.y*this.y}length(){return Math.sqrt(this.x*this.x+this.y*this.y)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)}normalize(){return this.divideScalar(this.length()||1)}angle(){return Math.atan2(-this.y,-this.x)+Math.PI}angleTo(t){const e=Math.sqrt(this.lengthSq()*t.lengthSq());if(e===0)return Math.PI/2;const n=this.dot(t)/e;return Math.acos(xe(n,-1,1))}distanceTo(t){return Math.sqrt(this.distanceToSquared(t))}distanceToSquared(t){const e=this.x-t.x,n=this.y-t.y;return e*e+n*n}manhattanDistanceTo(t){return Math.abs(this.x-t.x)+Math.abs(this.y-t.y)}setLength(t){return this.normalize().multiplyScalar(t)}lerp(t,e){return this.x+=(t.x-this.x)*e,this.y+=(t.y-this.y)*e,this}lerpVectors(t,e,n){return this.x=t.x+(e.x-t.x)*n,this.y=t.y+(e.y-t.y)*n,this}equals(t){return t.x===this.x&&t.y===this.y}fromArray(t,e=0){return this.x=t[e],this.y=t[e+1],this}toArray(t=[],e=0){return t[e]=this.x,t[e+1]=this.y,t}fromBufferAttribute(t,e){return this.x=t.getX(e),this.y=t.getY(e),this}rotateAround(t,e){const n=Math.cos(e),r=Math.sin(e),s=this.x-t.x,o=this.y-t.y;return this.x=s*n-o*r+t.x,this.y=s*r+o*n+t.y,this}random(){return this.x=Math.random(),this.y=Math.random(),this}*[Symbol.iterator](){yield this.x,yield this.y}}class Kt{constructor(t,e,n,r,s,o,a,l,c){Kt.prototype.isMatrix3=!0,this.elements=[1,0,0,0,1,0,0,0,1],t!==void 0&&this.set(t,e,n,r,s,o,a,l,c)}set(t,e,n,r,s,o,a,l,c){const u=this.elements;return u[0]=t,u[1]=r,u[2]=a,u[3]=e,u[4]=s,u[5]=l,u[6]=n,u[7]=o,u[8]=c,this}identity(){return this.set(1,0,0,0,1,0,0,0,1),this}copy(t){const e=this.elements,n=t.elements;return e[0]=n[0],e[1]=n[1],e[2]=n[2],e[3]=n[3],e[4]=n[4],e[5]=n[5],e[6]=n[6],e[7]=n[7],e[8]=n[8],this}extractBasis(t,e,n){return t.setFromMatrix3Column(this,0),e.setFromMatrix3Column(this,1),n.setFromMatrix3Column(this,2),this}setFromMatrix4(t){const e=t.elements;return this.set(e[0],e[4],e[8],e[1],e[5],e[9],e[2],e[6],e[10]),this}multiply(t){return this.multiplyMatrices(this,t)}premultiply(t){return this.multiplyMatrices(t,this)}multiplyMatrices(t,e){const n=t.elements,r=e.elements,s=this.elements,o=n[0],a=n[3],l=n[6],c=n[1],u=n[4],f=n[7],m=n[2],p=n[5],v=n[8],x=r[0],d=r[3],h=r[6],y=r[1],_=r[4],w=r[7],D=r[2],P=r[5],I=r[8];return s[0]=o*x+a*y+l*D,s[3]=o*d+a*_+l*P,s[6]=o*h+a*w+l*I,s[1]=c*x+u*y+f*D,s[4]=c*d+u*_+f*P,s[7]=c*h+u*w+f*I,s[2]=m*x+p*y+v*D,s[5]=m*d+p*_+v*P,s[8]=m*h+p*w+v*I,this}multiplyScalar(t){const e=this.elements;return e[0]*=t,e[3]*=t,e[6]*=t,e[1]*=t,e[4]*=t,e[7]*=t,e[2]*=t,e[5]*=t,e[8]*=t,this}determinant(){const t=this.elements,e=t[0],n=t[1],r=t[2],s=t[3],o=t[4],a=t[5],l=t[6],c=t[7],u=t[8];return e*o*u-e*a*c-n*s*u+n*a*l+r*s*c-r*o*l}invert(){const t=this.elements,e=t[0],n=t[1],r=t[2],s=t[3],o=t[4],a=t[5],l=t[6],c=t[7],u=t[8],f=u*o-a*c,m=a*l-u*s,p=c*s-o*l,v=e*f+n*m+r*p;if(v===0)return this.set(0,0,0,0,0,0,0,0,0);const x=1/v;return t[0]=f*x,t[1]=(r*c-u*n)*x,t[2]=(a*n-r*o)*x,t[3]=m*x,t[4]=(u*e-r*l)*x,t[5]=(r*s-a*e)*x,t[6]=p*x,t[7]=(n*l-c*e)*x,t[8]=(o*e-n*s)*x,this}transpose(){let t;const e=this.elements;return t=e[1],e[1]=e[3],e[3]=t,t=e[2],e[2]=e[6],e[6]=t,t=e[5],e[5]=e[7],e[7]=t,this}getNormalMatrix(t){return this.setFromMatrix4(t).invert().transpose()}transposeIntoArray(t){const e=this.elements;return t[0]=e[0],t[1]=e[3],t[2]=e[6],t[3]=e[1],t[4]=e[4],t[5]=e[7],t[6]=e[2],t[7]=e[5],t[8]=e[8],this}setUvTransform(t,e,n,r,s,o,a){const l=Math.cos(s),c=Math.sin(s);return this.set(n*l,n*c,-n*(l*o+c*a)+o+t,-r*c,r*l,-r*(-c*o+l*a)+a+e,0,0,1),this}scale(t,e){return this.premultiply(is.makeScale(t,e)),this}rotate(t){return this.premultiply(is.makeRotation(-t)),this}translate(t,e){return this.premultiply(is.makeTranslation(t,e)),this}makeTranslation(t,e){return t.isVector2?this.set(1,0,t.x,0,1,t.y,0,0,1):this.set(1,0,t,0,1,e,0,0,1),this}makeRotation(t){const e=Math.cos(t),n=Math.sin(t);return this.set(e,-n,0,n,e,0,0,0,1),this}makeScale(t,e){return this.set(t,0,0,0,e,0,0,0,1),this}equals(t){const e=this.elements,n=t.elements;for(let r=0;r<9;r++)if(e[r]!==n[r])return!1;return!0}fromArray(t,e=0){for(let n=0;n<9;n++)this.elements[n]=t[n+e];return this}toArray(t=[],e=0){const n=this.elements;return t[e]=n[0],t[e+1]=n[1],t[e+2]=n[2],t[e+3]=n[3],t[e+4]=n[4],t[e+5]=n[5],t[e+6]=n[6],t[e+7]=n[7],t[e+8]=n[8],t}clone(){return new this.constructor().fromArray(this.elements)}}const is=new Kt;function Al(i){for(let t=i.length-1;t>=0;--t)if(i[t]>=65535)return!0;return!1}function Fr(i){return document.createElementNS("http://www.w3.org/1999/xhtml",i)}function mu(){const i=Fr("canvas");return i.style.display="block",i}const ta={};function ki(i){i in ta||(ta[i]=!0,console.warn(i))}const ea=new Kt().set(.8224621,.177538,0,.0331941,.9668058,0,.0170827,.0723974,.9105199),na=new Kt().set(1.2249401,-.2249404,0,-.0420569,1.0420571,0,-.0196376,-.0786361,1.0982735),Qi={[pn]:{transfer:Dr,primaries:Ir,toReference:i=>i,fromReference:i=>i},[ce]:{transfer:se,primaries:Ir,toReference:i=>i.convertSRGBToLinear(),fromReference:i=>i.convertLinearToSRGB()},[Hr]:{transfer:Dr,primaries:Ur,toReference:i=>i.applyMatrix3(na),fromReference:i=>i.applyMatrix3(ea)},[Js]:{transfer:se,primaries:Ur,toReference:i=>i.convertSRGBToLinear().applyMatrix3(na),fromReference:i=>i.applyMatrix3(ea).convertLinearToSRGB()}},gu=new Set([pn,Hr]),te={enabled:!0,_workingColorSpace:pn,get workingColorSpace(){return this._workingColorSpace},set workingColorSpace(i){if(!gu.has(i))throw new Error(`Unsupported working color space, "${i}".`);this._workingColorSpace=i},convert:function(i,t,e){if(this.enabled===!1||t===e||!t||!e)return i;const n=Qi[t].toReference,r=Qi[e].fromReference;return r(n(i))},fromWorkingColorSpace:function(i,t){return this.convert(i,this._workingColorSpace,t)},toWorkingColorSpace:function(i,t){return this.convert(i,t,this._workingColorSpace)},getPrimaries:function(i){return Qi[i].primaries},getTransfer:function(i){return i===We?Dr:Qi[i].transfer}};function vi(i){return i<.04045?i*.0773993808:Math.pow(i*.9478672986+.0521327014,2.4)}function rs(i){return i<.0031308?i*12.92:1.055*Math.pow(i,.41666)-.055}let jn;class Rl{static getDataURL(t){if(/^data:/i.test(t.src)||typeof HTMLCanvasElement>"u")return t.src;let e;if(t instanceof HTMLCanvasElement)e=t;else{jn===void 0&&(jn=Fr("canvas")),jn.width=t.width,jn.height=t.height;const n=jn.getContext("2d");t instanceof ImageData?n.putImageData(t,0,0):n.drawImage(t,0,0,t.width,t.height),e=jn}return e.width>2048||e.height>2048?(console.warn("THREE.ImageUtils.getDataURL: Image converted to jpg for performance reasons",t),e.toDataURL("image/jpeg",.6)):e.toDataURL("image/png")}static sRGBToLinear(t){if(typeof HTMLImageElement<"u"&&t instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&t instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&t instanceof ImageBitmap){const e=Fr("canvas");e.width=t.width,e.height=t.height;const n=e.getContext("2d");n.drawImage(t,0,0,t.width,t.height);const r=n.getImageData(0,0,t.width,t.height),s=r.data;for(let o=0;o<s.length;o++)s[o]=vi(s[o]/255)*255;return n.putImageData(r,0,0),e}else if(t.data){const e=t.data.slice(0);for(let n=0;n<e.length;n++)e instanceof Uint8Array||e instanceof Uint8ClampedArray?e[n]=Math.floor(vi(e[n]/255)*255):e[n]=vi(e[n]);return{data:e,width:t.width,height:t.height}}else return console.warn("THREE.ImageUtils.sRGBToLinear(): Unsupported image type. No color space conversion applied."),t}}let _u=0;class Cl{constructor(t=null){this.isSource=!0,Object.defineProperty(this,"id",{value:_u++}),this.uuid=fn(),this.data=t,this.version=0}set needsUpdate(t){t===!0&&this.version++}toJSON(t){const e=t===void 0||typeof t=="string";if(!e&&t.images[this.uuid]!==void 0)return t.images[this.uuid];const n={uuid:this.uuid,url:""},r=this.data;if(r!==null){let s;if(Array.isArray(r)){s=[];for(let o=0,a=r.length;o<a;o++)r[o].isDataTexture?s.push(ss(r[o].image)):s.push(ss(r[o]))}else s=ss(r);n.url=s}return e||(t.images[this.uuid]=n),n}}function ss(i){return typeof HTMLImageElement<"u"&&i instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&i instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&i instanceof ImageBitmap?Rl.getDataURL(i):i.data?{data:Array.from(i.data),width:i.width,height:i.height,type:i.data.constructor.name}:(console.warn("THREE.Texture: Unable to serialize Texture."),{})}let vu=0;class we extends kn{constructor(t=we.DEFAULT_IMAGE,e=we.DEFAULT_MAPPING,n=Ve,r=Ve,s=ke,o=Wi,a=je,l=Tn,c=we.DEFAULT_ANISOTROPY,u=We){super(),this.isTexture=!0,Object.defineProperty(this,"id",{value:vu++}),this.uuid=fn(),this.name="",this.source=new Cl(t),this.mipmaps=[],this.mapping=e,this.channel=0,this.wrapS=n,this.wrapT=r,this.magFilter=s,this.minFilter=o,this.anisotropy=c,this.format=a,this.internalFormat=null,this.type=l,this.offset=new wt(0,0),this.repeat=new wt(1,1),this.center=new wt(0,0),this.rotation=0,this.matrixAutoUpdate=!0,this.matrix=new Kt,this.generateMipmaps=!0,this.premultiplyAlpha=!1,this.flipY=!0,this.unpackAlignment=4,typeof u=="string"?this.colorSpace=u:(ki("THREE.Texture: Property .encoding has been replaced by .colorSpace."),this.colorSpace=u===Gn?ce:We),this.userData={},this.version=0,this.onUpdate=null,this.isRenderTargetTexture=!1,this.needsPMREMUpdate=!1}get image(){return this.source.data}set image(t=null){this.source.data=t}updateMatrix(){this.matrix.setUvTransform(this.offset.x,this.offset.y,this.repeat.x,this.repeat.y,this.rotation,this.center.x,this.center.y)}clone(){return new this.constructor().copy(this)}copy(t){return this.name=t.name,this.source=t.source,this.mipmaps=t.mipmaps.slice(0),this.mapping=t.mapping,this.channel=t.channel,this.wrapS=t.wrapS,this.wrapT=t.wrapT,this.magFilter=t.magFilter,this.minFilter=t.minFilter,this.anisotropy=t.anisotropy,this.format=t.format,this.internalFormat=t.internalFormat,this.type=t.type,this.offset.copy(t.offset),this.repeat.copy(t.repeat),this.center.copy(t.center),this.rotation=t.rotation,this.matrixAutoUpdate=t.matrixAutoUpdate,this.matrix.copy(t.matrix),this.generateMipmaps=t.generateMipmaps,this.premultiplyAlpha=t.premultiplyAlpha,this.flipY=t.flipY,this.unpackAlignment=t.unpackAlignment,this.colorSpace=t.colorSpace,this.userData=JSON.parse(JSON.stringify(t.userData)),this.needsUpdate=!0,this}toJSON(t){const e=t===void 0||typeof t=="string";if(!e&&t.textures[this.uuid]!==void 0)return t.textures[this.uuid];const n={metadata:{version:4.6,type:"Texture",generator:"Texture.toJSON"},uuid:this.uuid,name:this.name,image:this.source.toJSON(t).uuid,mapping:this.mapping,channel:this.channel,repeat:[this.repeat.x,this.repeat.y],offset:[this.offset.x,this.offset.y],center:[this.center.x,this.center.y],rotation:this.rotation,wrap:[this.wrapS,this.wrapT],format:this.format,internalFormat:this.internalFormat,type:this.type,colorSpace:this.colorSpace,minFilter:this.minFilter,magFilter:this.magFilter,anisotropy:this.anisotropy,flipY:this.flipY,generateMipmaps:this.generateMipmaps,premultiplyAlpha:this.premultiplyAlpha,unpackAlignment:this.unpackAlignment};return Object.keys(this.userData).length>0&&(n.userData=this.userData),e||(t.textures[this.uuid]=n),n}dispose(){this.dispatchEvent({type:"dispose"})}transformUv(t){if(this.mapping!==ml)return t;if(t.applyMatrix3(this.matrix),t.x<0||t.x>1)switch(this.wrapS){case yi:t.x=t.x-Math.floor(t.x);break;case Ve:t.x=t.x<0?0:1;break;case Gs:Math.abs(Math.floor(t.x)%2)===1?t.x=Math.ceil(t.x)-t.x:t.x=t.x-Math.floor(t.x);break}if(t.y<0||t.y>1)switch(this.wrapT){case yi:t.y=t.y-Math.floor(t.y);break;case Ve:t.y=t.y<0?0:1;break;case Gs:Math.abs(Math.floor(t.y)%2)===1?t.y=Math.ceil(t.y)-t.y:t.y=t.y-Math.floor(t.y);break}return this.flipY&&(t.y=1-t.y),t}set needsUpdate(t){t===!0&&(this.version++,this.source.needsUpdate=!0)}get encoding(){return ki("THREE.Texture: Property .encoding has been replaced by .colorSpace."),this.colorSpace===ce?Gn:bl}set encoding(t){ki("THREE.Texture: Property .encoding has been replaced by .colorSpace."),this.colorSpace=t===Gn?ce:We}}we.DEFAULT_IMAGE=null;we.DEFAULT_MAPPING=ml;we.DEFAULT_ANISOTROPY=1;class oe{constructor(t=0,e=0,n=0,r=1){oe.prototype.isVector4=!0,this.x=t,this.y=e,this.z=n,this.w=r}get width(){return this.z}set width(t){this.z=t}get height(){return this.w}set height(t){this.w=t}set(t,e,n,r){return this.x=t,this.y=e,this.z=n,this.w=r,this}setScalar(t){return this.x=t,this.y=t,this.z=t,this.w=t,this}setX(t){return this.x=t,this}setY(t){return this.y=t,this}setZ(t){return this.z=t,this}setW(t){return this.w=t,this}setComponent(t,e){switch(t){case 0:this.x=e;break;case 1:this.y=e;break;case 2:this.z=e;break;case 3:this.w=e;break;default:throw new Error("index is out of range: "+t)}return this}getComponent(t){switch(t){case 0:return this.x;case 1:return this.y;case 2:return this.z;case 3:return this.w;default:throw new Error("index is out of range: "+t)}}clone(){return new this.constructor(this.x,this.y,this.z,this.w)}copy(t){return this.x=t.x,this.y=t.y,this.z=t.z,this.w=t.w!==void 0?t.w:1,this}add(t){return this.x+=t.x,this.y+=t.y,this.z+=t.z,this.w+=t.w,this}addScalar(t){return this.x+=t,this.y+=t,this.z+=t,this.w+=t,this}addVectors(t,e){return this.x=t.x+e.x,this.y=t.y+e.y,this.z=t.z+e.z,this.w=t.w+e.w,this}addScaledVector(t,e){return this.x+=t.x*e,this.y+=t.y*e,this.z+=t.z*e,this.w+=t.w*e,this}sub(t){return this.x-=t.x,this.y-=t.y,this.z-=t.z,this.w-=t.w,this}subScalar(t){return this.x-=t,this.y-=t,this.z-=t,this.w-=t,this}subVectors(t,e){return this.x=t.x-e.x,this.y=t.y-e.y,this.z=t.z-e.z,this.w=t.w-e.w,this}multiply(t){return this.x*=t.x,this.y*=t.y,this.z*=t.z,this.w*=t.w,this}multiplyScalar(t){return this.x*=t,this.y*=t,this.z*=t,this.w*=t,this}applyMatrix4(t){const e=this.x,n=this.y,r=this.z,s=this.w,o=t.elements;return this.x=o[0]*e+o[4]*n+o[8]*r+o[12]*s,this.y=o[1]*e+o[5]*n+o[9]*r+o[13]*s,this.z=o[2]*e+o[6]*n+o[10]*r+o[14]*s,this.w=o[3]*e+o[7]*n+o[11]*r+o[15]*s,this}divideScalar(t){return this.multiplyScalar(1/t)}setAxisAngleFromQuaternion(t){this.w=2*Math.acos(t.w);const e=Math.sqrt(1-t.w*t.w);return e<1e-4?(this.x=1,this.y=0,this.z=0):(this.x=t.x/e,this.y=t.y/e,this.z=t.z/e),this}setAxisAngleFromRotationMatrix(t){let e,n,r,s;const l=t.elements,c=l[0],u=l[4],f=l[8],m=l[1],p=l[5],v=l[9],x=l[2],d=l[6],h=l[10];if(Math.abs(u-m)<.01&&Math.abs(f-x)<.01&&Math.abs(v-d)<.01){if(Math.abs(u+m)<.1&&Math.abs(f+x)<.1&&Math.abs(v+d)<.1&&Math.abs(c+p+h-3)<.1)return this.set(1,0,0,0),this;e=Math.PI;const _=(c+1)/2,w=(p+1)/2,D=(h+1)/2,P=(u+m)/4,I=(f+x)/4,F=(v+d)/4;return _>w&&_>D?_<.01?(n=0,r=.707106781,s=.707106781):(n=Math.sqrt(_),r=P/n,s=I/n):w>D?w<.01?(n=.707106781,r=0,s=.707106781):(r=Math.sqrt(w),n=P/r,s=F/r):D<.01?(n=.707106781,r=.707106781,s=0):(s=Math.sqrt(D),n=I/s,r=F/s),this.set(n,r,s,e),this}let y=Math.sqrt((d-v)*(d-v)+(f-x)*(f-x)+(m-u)*(m-u));return Math.abs(y)<.001&&(y=1),this.x=(d-v)/y,this.y=(f-x)/y,this.z=(m-u)/y,this.w=Math.acos((c+p+h-1)/2),this}min(t){return this.x=Math.min(this.x,t.x),this.y=Math.min(this.y,t.y),this.z=Math.min(this.z,t.z),this.w=Math.min(this.w,t.w),this}max(t){return this.x=Math.max(this.x,t.x),this.y=Math.max(this.y,t.y),this.z=Math.max(this.z,t.z),this.w=Math.max(this.w,t.w),this}clamp(t,e){return this.x=Math.max(t.x,Math.min(e.x,this.x)),this.y=Math.max(t.y,Math.min(e.y,this.y)),this.z=Math.max(t.z,Math.min(e.z,this.z)),this.w=Math.max(t.w,Math.min(e.w,this.w)),this}clampScalar(t,e){return this.x=Math.max(t,Math.min(e,this.x)),this.y=Math.max(t,Math.min(e,this.y)),this.z=Math.max(t,Math.min(e,this.z)),this.w=Math.max(t,Math.min(e,this.w)),this}clampLength(t,e){const n=this.length();return this.divideScalar(n||1).multiplyScalar(Math.max(t,Math.min(e,n)))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this.z=Math.floor(this.z),this.w=Math.floor(this.w),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this.z=Math.ceil(this.z),this.w=Math.ceil(this.w),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this.z=Math.round(this.z),this.w=Math.round(this.w),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this.z=Math.trunc(this.z),this.w=Math.trunc(this.w),this}negate(){return this.x=-this.x,this.y=-this.y,this.z=-this.z,this.w=-this.w,this}dot(t){return this.x*t.x+this.y*t.y+this.z*t.z+this.w*t.w}lengthSq(){return this.x*this.x+this.y*this.y+this.z*this.z+this.w*this.w}length(){return Math.sqrt(this.x*this.x+this.y*this.y+this.z*this.z+this.w*this.w)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)+Math.abs(this.z)+Math.abs(this.w)}normalize(){return this.divideScalar(this.length()||1)}setLength(t){return this.normalize().multiplyScalar(t)}lerp(t,e){return this.x+=(t.x-this.x)*e,this.y+=(t.y-this.y)*e,this.z+=(t.z-this.z)*e,this.w+=(t.w-this.w)*e,this}lerpVectors(t,e,n){return this.x=t.x+(e.x-t.x)*n,this.y=t.y+(e.y-t.y)*n,this.z=t.z+(e.z-t.z)*n,this.w=t.w+(e.w-t.w)*n,this}equals(t){return t.x===this.x&&t.y===this.y&&t.z===this.z&&t.w===this.w}fromArray(t,e=0){return this.x=t[e],this.y=t[e+1],this.z=t[e+2],this.w=t[e+3],this}toArray(t=[],e=0){return t[e]=this.x,t[e+1]=this.y,t[e+2]=this.z,t[e+3]=this.w,t}fromBufferAttribute(t,e){return this.x=t.getX(e),this.y=t.getY(e),this.z=t.getZ(e),this.w=t.getW(e),this}random(){return this.x=Math.random(),this.y=Math.random(),this.z=Math.random(),this.w=Math.random(),this}*[Symbol.iterator](){yield this.x,yield this.y,yield this.z,yield this.w}}class xu extends kn{constructor(t=1,e=1,n={}){super(),this.isRenderTarget=!0,this.width=t,this.height=e,this.depth=1,this.scissor=new oe(0,0,t,e),this.scissorTest=!1,this.viewport=new oe(0,0,t,e);const r={width:t,height:e,depth:1};n.encoding!==void 0&&(ki("THREE.WebGLRenderTarget: option.encoding has been replaced by option.colorSpace."),n.colorSpace=n.encoding===Gn?ce:We),n=Object.assign({generateMipmaps:!1,internalFormat:null,minFilter:ke,depthBuffer:!0,stencilBuffer:!1,depthTexture:null,samples:0},n),this.texture=new we(r,n.mapping,n.wrapS,n.wrapT,n.magFilter,n.minFilter,n.format,n.type,n.anisotropy,n.colorSpace),this.texture.isRenderTargetTexture=!0,this.texture.flipY=!1,this.texture.generateMipmaps=n.generateMipmaps,this.texture.internalFormat=n.internalFormat,this.depthBuffer=n.depthBuffer,this.stencilBuffer=n.stencilBuffer,this.depthTexture=n.depthTexture,this.samples=n.samples}setSize(t,e,n=1){(this.width!==t||this.height!==e||this.depth!==n)&&(this.width=t,this.height=e,this.depth=n,this.texture.image.width=t,this.texture.image.height=e,this.texture.image.depth=n,this.dispose()),this.viewport.set(0,0,t,e),this.scissor.set(0,0,t,e)}clone(){return new this.constructor().copy(this)}copy(t){this.width=t.width,this.height=t.height,this.depth=t.depth,this.scissor.copy(t.scissor),this.scissorTest=t.scissorTest,this.viewport.copy(t.viewport),this.texture=t.texture.clone(),this.texture.isRenderTargetTexture=!0;const e=Object.assign({},t.texture.image);return this.texture.source=new Cl(e),this.depthBuffer=t.depthBuffer,this.stencilBuffer=t.stencilBuffer,t.depthTexture!==null&&(this.depthTexture=t.depthTexture.clone()),this.samples=t.samples,this}dispose(){this.dispatchEvent({type:"dispose"})}}class Ke extends xu{constructor(t=1,e=1,n={}){super(t,e,n),this.isWebGLRenderTarget=!0}}class Pl extends we{constructor(t=null,e=1,n=1,r=1){super(null),this.isDataArrayTexture=!0,this.image={data:t,width:e,height:n,depth:r},this.magFilter=Le,this.minFilter=Le,this.wrapR=Ve,this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1}}class Mu extends we{constructor(t=null,e=1,n=1,r=1){super(null),this.isData3DTexture=!0,this.image={data:t,width:e,height:n,depth:r},this.magFilter=Le,this.minFilter=Le,this.wrapR=Ve,this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1}}class An{constructor(t=0,e=0,n=0,r=1){this.isQuaternion=!0,this._x=t,this._y=e,this._z=n,this._w=r}static slerpFlat(t,e,n,r,s,o,a){let l=n[r+0],c=n[r+1],u=n[r+2],f=n[r+3];const m=s[o+0],p=s[o+1],v=s[o+2],x=s[o+3];if(a===0){t[e+0]=l,t[e+1]=c,t[e+2]=u,t[e+3]=f;return}if(a===1){t[e+0]=m,t[e+1]=p,t[e+2]=v,t[e+3]=x;return}if(f!==x||l!==m||c!==p||u!==v){let d=1-a;const h=l*m+c*p+u*v+f*x,y=h>=0?1:-1,_=1-h*h;if(_>Number.EPSILON){const D=Math.sqrt(_),P=Math.atan2(D,h*y);d=Math.sin(d*P)/D,a=Math.sin(a*P)/D}const w=a*y;if(l=l*d+m*w,c=c*d+p*w,u=u*d+v*w,f=f*d+x*w,d===1-a){const D=1/Math.sqrt(l*l+c*c+u*u+f*f);l*=D,c*=D,u*=D,f*=D}}t[e]=l,t[e+1]=c,t[e+2]=u,t[e+3]=f}static multiplyQuaternionsFlat(t,e,n,r,s,o){const a=n[r],l=n[r+1],c=n[r+2],u=n[r+3],f=s[o],m=s[o+1],p=s[o+2],v=s[o+3];return t[e]=a*v+u*f+l*p-c*m,t[e+1]=l*v+u*m+c*f-a*p,t[e+2]=c*v+u*p+a*m-l*f,t[e+3]=u*v-a*f-l*m-c*p,t}get x(){return this._x}set x(t){this._x=t,this._onChangeCallback()}get y(){return this._y}set y(t){this._y=t,this._onChangeCallback()}get z(){return this._z}set z(t){this._z=t,this._onChangeCallback()}get w(){return this._w}set w(t){this._w=t,this._onChangeCallback()}set(t,e,n,r){return this._x=t,this._y=e,this._z=n,this._w=r,this._onChangeCallback(),this}clone(){return new this.constructor(this._x,this._y,this._z,this._w)}copy(t){return this._x=t.x,this._y=t.y,this._z=t.z,this._w=t.w,this._onChangeCallback(),this}setFromEuler(t,e=!0){const n=t._x,r=t._y,s=t._z,o=t._order,a=Math.cos,l=Math.sin,c=a(n/2),u=a(r/2),f=a(s/2),m=l(n/2),p=l(r/2),v=l(s/2);switch(o){case"XYZ":this._x=m*u*f+c*p*v,this._y=c*p*f-m*u*v,this._z=c*u*v+m*p*f,this._w=c*u*f-m*p*v;break;case"YXZ":this._x=m*u*f+c*p*v,this._y=c*p*f-m*u*v,this._z=c*u*v-m*p*f,this._w=c*u*f+m*p*v;break;case"ZXY":this._x=m*u*f-c*p*v,this._y=c*p*f+m*u*v,this._z=c*u*v+m*p*f,this._w=c*u*f-m*p*v;break;case"ZYX":this._x=m*u*f-c*p*v,this._y=c*p*f+m*u*v,this._z=c*u*v-m*p*f,this._w=c*u*f+m*p*v;break;case"YZX":this._x=m*u*f+c*p*v,this._y=c*p*f+m*u*v,this._z=c*u*v-m*p*f,this._w=c*u*f-m*p*v;break;case"XZY":this._x=m*u*f-c*p*v,this._y=c*p*f-m*u*v,this._z=c*u*v+m*p*f,this._w=c*u*f+m*p*v;break;default:console.warn("THREE.Quaternion: .setFromEuler() encountered an unknown order: "+o)}return e===!0&&this._onChangeCallback(),this}setFromAxisAngle(t,e){const n=e/2,r=Math.sin(n);return this._x=t.x*r,this._y=t.y*r,this._z=t.z*r,this._w=Math.cos(n),this._onChangeCallback(),this}setFromRotationMatrix(t){const e=t.elements,n=e[0],r=e[4],s=e[8],o=e[1],a=e[5],l=e[9],c=e[2],u=e[6],f=e[10],m=n+a+f;if(m>0){const p=.5/Math.sqrt(m+1);this._w=.25/p,this._x=(u-l)*p,this._y=(s-c)*p,this._z=(o-r)*p}else if(n>a&&n>f){const p=2*Math.sqrt(1+n-a-f);this._w=(u-l)/p,this._x=.25*p,this._y=(r+o)/p,this._z=(s+c)/p}else if(a>f){const p=2*Math.sqrt(1+a-n-f);this._w=(s-c)/p,this._x=(r+o)/p,this._y=.25*p,this._z=(l+u)/p}else{const p=2*Math.sqrt(1+f-n-a);this._w=(o-r)/p,this._x=(s+c)/p,this._y=(l+u)/p,this._z=.25*p}return this._onChangeCallback(),this}setFromUnitVectors(t,e){let n=t.dot(e)+1;return n<Number.EPSILON?(n=0,Math.abs(t.x)>Math.abs(t.z)?(this._x=-t.y,this._y=t.x,this._z=0,this._w=n):(this._x=0,this._y=-t.z,this._z=t.y,this._w=n)):(this._x=t.y*e.z-t.z*e.y,this._y=t.z*e.x-t.x*e.z,this._z=t.x*e.y-t.y*e.x,this._w=n),this.normalize()}angleTo(t){return 2*Math.acos(Math.abs(xe(this.dot(t),-1,1)))}rotateTowards(t,e){const n=this.angleTo(t);if(n===0)return this;const r=Math.min(1,e/n);return this.slerp(t,r),this}identity(){return this.set(0,0,0,1)}invert(){return this.conjugate()}conjugate(){return this._x*=-1,this._y*=-1,this._z*=-1,this._onChangeCallback(),this}dot(t){return this._x*t._x+this._y*t._y+this._z*t._z+this._w*t._w}lengthSq(){return this._x*this._x+this._y*this._y+this._z*this._z+this._w*this._w}length(){return Math.sqrt(this._x*this._x+this._y*this._y+this._z*this._z+this._w*this._w)}normalize(){let t=this.length();return t===0?(this._x=0,this._y=0,this._z=0,this._w=1):(t=1/t,this._x=this._x*t,this._y=this._y*t,this._z=this._z*t,this._w=this._w*t),this._onChangeCallback(),this}multiply(t){return this.multiplyQuaternions(this,t)}premultiply(t){return this.multiplyQuaternions(t,this)}multiplyQuaternions(t,e){const n=t._x,r=t._y,s=t._z,o=t._w,a=e._x,l=e._y,c=e._z,u=e._w;return this._x=n*u+o*a+r*c-s*l,this._y=r*u+o*l+s*a-n*c,this._z=s*u+o*c+n*l-r*a,this._w=o*u-n*a-r*l-s*c,this._onChangeCallback(),this}slerp(t,e){if(e===0)return this;if(e===1)return this.copy(t);const n=this._x,r=this._y,s=this._z,o=this._w;let a=o*t._w+n*t._x+r*t._y+s*t._z;if(a<0?(this._w=-t._w,this._x=-t._x,this._y=-t._y,this._z=-t._z,a=-a):this.copy(t),a>=1)return this._w=o,this._x=n,this._y=r,this._z=s,this;const l=1-a*a;if(l<=Number.EPSILON){const p=1-e;return this._w=p*o+e*this._w,this._x=p*n+e*this._x,this._y=p*r+e*this._y,this._z=p*s+e*this._z,this.normalize(),this}const c=Math.sqrt(l),u=Math.atan2(c,a),f=Math.sin((1-e)*u)/c,m=Math.sin(e*u)/c;return this._w=o*f+this._w*m,this._x=n*f+this._x*m,this._y=r*f+this._y*m,this._z=s*f+this._z*m,this._onChangeCallback(),this}slerpQuaternions(t,e,n){return this.copy(t).slerp(e,n)}random(){const t=Math.random(),e=Math.sqrt(1-t),n=Math.sqrt(t),r=2*Math.PI*Math.random(),s=2*Math.PI*Math.random();return this.set(e*Math.cos(r),n*Math.sin(s),n*Math.cos(s),e*Math.sin(r))}equals(t){return t._x===this._x&&t._y===this._y&&t._z===this._z&&t._w===this._w}fromArray(t,e=0){return this._x=t[e],this._y=t[e+1],this._z=t[e+2],this._w=t[e+3],this._onChangeCallback(),this}toArray(t=[],e=0){return t[e]=this._x,t[e+1]=this._y,t[e+2]=this._z,t[e+3]=this._w,t}fromBufferAttribute(t,e){return this._x=t.getX(e),this._y=t.getY(e),this._z=t.getZ(e),this._w=t.getW(e),this._onChangeCallback(),this}toJSON(){return this.toArray()}_onChange(t){return this._onChangeCallback=t,this}_onChangeCallback(){}*[Symbol.iterator](){yield this._x,yield this._y,yield this._z,yield this._w}}class W{constructor(t=0,e=0,n=0){W.prototype.isVector3=!0,this.x=t,this.y=e,this.z=n}set(t,e,n){return n===void 0&&(n=this.z),this.x=t,this.y=e,this.z=n,this}setScalar(t){return this.x=t,this.y=t,this.z=t,this}setX(t){return this.x=t,this}setY(t){return this.y=t,this}setZ(t){return this.z=t,this}setComponent(t,e){switch(t){case 0:this.x=e;break;case 1:this.y=e;break;case 2:this.z=e;break;default:throw new Error("index is out of range: "+t)}return this}getComponent(t){switch(t){case 0:return this.x;case 1:return this.y;case 2:return this.z;default:throw new Error("index is out of range: "+t)}}clone(){return new this.constructor(this.x,this.y,this.z)}copy(t){return this.x=t.x,this.y=t.y,this.z=t.z,this}add(t){return this.x+=t.x,this.y+=t.y,this.z+=t.z,this}addScalar(t){return this.x+=t,this.y+=t,this.z+=t,this}addVectors(t,e){return this.x=t.x+e.x,this.y=t.y+e.y,this.z=t.z+e.z,this}addScaledVector(t,e){return this.x+=t.x*e,this.y+=t.y*e,this.z+=t.z*e,this}sub(t){return this.x-=t.x,this.y-=t.y,this.z-=t.z,this}subScalar(t){return this.x-=t,this.y-=t,this.z-=t,this}subVectors(t,e){return this.x=t.x-e.x,this.y=t.y-e.y,this.z=t.z-e.z,this}multiply(t){return this.x*=t.x,this.y*=t.y,this.z*=t.z,this}multiplyScalar(t){return this.x*=t,this.y*=t,this.z*=t,this}multiplyVectors(t,e){return this.x=t.x*e.x,this.y=t.y*e.y,this.z=t.z*e.z,this}applyEuler(t){return this.applyQuaternion(ia.setFromEuler(t))}applyAxisAngle(t,e){return this.applyQuaternion(ia.setFromAxisAngle(t,e))}applyMatrix3(t){const e=this.x,n=this.y,r=this.z,s=t.elements;return this.x=s[0]*e+s[3]*n+s[6]*r,this.y=s[1]*e+s[4]*n+s[7]*r,this.z=s[2]*e+s[5]*n+s[8]*r,this}applyNormalMatrix(t){return this.applyMatrix3(t).normalize()}applyMatrix4(t){const e=this.x,n=this.y,r=this.z,s=t.elements,o=1/(s[3]*e+s[7]*n+s[11]*r+s[15]);return this.x=(s[0]*e+s[4]*n+s[8]*r+s[12])*o,this.y=(s[1]*e+s[5]*n+s[9]*r+s[13])*o,this.z=(s[2]*e+s[6]*n+s[10]*r+s[14])*o,this}applyQuaternion(t){const e=this.x,n=this.y,r=this.z,s=t.x,o=t.y,a=t.z,l=t.w,c=2*(o*r-a*n),u=2*(a*e-s*r),f=2*(s*n-o*e);return this.x=e+l*c+o*f-a*u,this.y=n+l*u+a*c-s*f,this.z=r+l*f+s*u-o*c,this}project(t){return this.applyMatrix4(t.matrixWorldInverse).applyMatrix4(t.projectionMatrix)}unproject(t){return this.applyMatrix4(t.projectionMatrixInverse).applyMatrix4(t.matrixWorld)}transformDirection(t){const e=this.x,n=this.y,r=this.z,s=t.elements;return this.x=s[0]*e+s[4]*n+s[8]*r,this.y=s[1]*e+s[5]*n+s[9]*r,this.z=s[2]*e+s[6]*n+s[10]*r,this.normalize()}divide(t){return this.x/=t.x,this.y/=t.y,this.z/=t.z,this}divideScalar(t){return this.multiplyScalar(1/t)}min(t){return this.x=Math.min(this.x,t.x),this.y=Math.min(this.y,t.y),this.z=Math.min(this.z,t.z),this}max(t){return this.x=Math.max(this.x,t.x),this.y=Math.max(this.y,t.y),this.z=Math.max(this.z,t.z),this}clamp(t,e){return this.x=Math.max(t.x,Math.min(e.x,this.x)),this.y=Math.max(t.y,Math.min(e.y,this.y)),this.z=Math.max(t.z,Math.min(e.z,this.z)),this}clampScalar(t,e){return this.x=Math.max(t,Math.min(e,this.x)),this.y=Math.max(t,Math.min(e,this.y)),this.z=Math.max(t,Math.min(e,this.z)),this}clampLength(t,e){const n=this.length();return this.divideScalar(n||1).multiplyScalar(Math.max(t,Math.min(e,n)))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this.z=Math.floor(this.z),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this.z=Math.ceil(this.z),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this.z=Math.round(this.z),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this.z=Math.trunc(this.z),this}negate(){return this.x=-this.x,this.y=-this.y,this.z=-this.z,this}dot(t){return this.x*t.x+this.y*t.y+this.z*t.z}lengthSq(){return this.x*this.x+this.y*this.y+this.z*this.z}length(){return Math.sqrt(this.x*this.x+this.y*this.y+this.z*this.z)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)+Math.abs(this.z)}normalize(){return this.divideScalar(this.length()||1)}setLength(t){return this.normalize().multiplyScalar(t)}lerp(t,e){return this.x+=(t.x-this.x)*e,this.y+=(t.y-this.y)*e,this.z+=(t.z-this.z)*e,this}lerpVectors(t,e,n){return this.x=t.x+(e.x-t.x)*n,this.y=t.y+(e.y-t.y)*n,this.z=t.z+(e.z-t.z)*n,this}cross(t){return this.crossVectors(this,t)}crossVectors(t,e){const n=t.x,r=t.y,s=t.z,o=e.x,a=e.y,l=e.z;return this.x=r*l-s*a,this.y=s*o-n*l,this.z=n*a-r*o,this}projectOnVector(t){const e=t.lengthSq();if(e===0)return this.set(0,0,0);const n=t.dot(this)/e;return this.copy(t).multiplyScalar(n)}projectOnPlane(t){return os.copy(this).projectOnVector(t),this.sub(os)}reflect(t){return this.sub(os.copy(t).multiplyScalar(2*this.dot(t)))}angleTo(t){const e=Math.sqrt(this.lengthSq()*t.lengthSq());if(e===0)return Math.PI/2;const n=this.dot(t)/e;return Math.acos(xe(n,-1,1))}distanceTo(t){return Math.sqrt(this.distanceToSquared(t))}distanceToSquared(t){const e=this.x-t.x,n=this.y-t.y,r=this.z-t.z;return e*e+n*n+r*r}manhattanDistanceTo(t){return Math.abs(this.x-t.x)+Math.abs(this.y-t.y)+Math.abs(this.z-t.z)}setFromSpherical(t){return this.setFromSphericalCoords(t.radius,t.phi,t.theta)}setFromSphericalCoords(t,e,n){const r=Math.sin(e)*t;return this.x=r*Math.sin(n),this.y=Math.cos(e)*t,this.z=r*Math.cos(n),this}setFromCylindrical(t){return this.setFromCylindricalCoords(t.radius,t.theta,t.y)}setFromCylindricalCoords(t,e,n){return this.x=t*Math.sin(e),this.y=n,this.z=t*Math.cos(e),this}setFromMatrixPosition(t){const e=t.elements;return this.x=e[12],this.y=e[13],this.z=e[14],this}setFromMatrixScale(t){const e=this.setFromMatrixColumn(t,0).length(),n=this.setFromMatrixColumn(t,1).length(),r=this.setFromMatrixColumn(t,2).length();return this.x=e,this.y=n,this.z=r,this}setFromMatrixColumn(t,e){return this.fromArray(t.elements,e*4)}setFromMatrix3Column(t,e){return this.fromArray(t.elements,e*3)}setFromEuler(t){return this.x=t._x,this.y=t._y,this.z=t._z,this}setFromColor(t){return this.x=t.r,this.y=t.g,this.z=t.b,this}equals(t){return t.x===this.x&&t.y===this.y&&t.z===this.z}fromArray(t,e=0){return this.x=t[e],this.y=t[e+1],this.z=t[e+2],this}toArray(t=[],e=0){return t[e]=this.x,t[e+1]=this.y,t[e+2]=this.z,t}fromBufferAttribute(t,e){return this.x=t.getX(e),this.y=t.getY(e),this.z=t.getZ(e),this}random(){return this.x=Math.random(),this.y=Math.random(),this.z=Math.random(),this}randomDirection(){const t=(Math.random()-.5)*2,e=Math.random()*Math.PI*2,n=Math.sqrt(1-t**2);return this.x=n*Math.cos(e),this.y=n*Math.sin(e),this.z=t,this}*[Symbol.iterator](){yield this.x,yield this.y,yield this.z}}const os=new W,ia=new An;class Hn{constructor(t=new W(1/0,1/0,1/0),e=new W(-1/0,-1/0,-1/0)){this.isBox3=!0,this.min=t,this.max=e}set(t,e){return this.min.copy(t),this.max.copy(e),this}setFromArray(t){this.makeEmpty();for(let e=0,n=t.length;e<n;e+=3)this.expandByPoint(Xe.fromArray(t,e));return this}setFromBufferAttribute(t){this.makeEmpty();for(let e=0,n=t.count;e<n;e++)this.expandByPoint(Xe.fromBufferAttribute(t,e));return this}setFromPoints(t){this.makeEmpty();for(let e=0,n=t.length;e<n;e++)this.expandByPoint(t[e]);return this}setFromCenterAndSize(t,e){const n=Xe.copy(e).multiplyScalar(.5);return this.min.copy(t).sub(n),this.max.copy(t).add(n),this}setFromObject(t,e=!1){return this.makeEmpty(),this.expandByObject(t,e)}clone(){return new this.constructor().copy(this)}copy(t){return this.min.copy(t.min),this.max.copy(t.max),this}makeEmpty(){return this.min.x=this.min.y=this.min.z=1/0,this.max.x=this.max.y=this.max.z=-1/0,this}isEmpty(){return this.max.x<this.min.x||this.max.y<this.min.y||this.max.z<this.min.z}getCenter(t){return this.isEmpty()?t.set(0,0,0):t.addVectors(this.min,this.max).multiplyScalar(.5)}getSize(t){return this.isEmpty()?t.set(0,0,0):t.subVectors(this.max,this.min)}expandByPoint(t){return this.min.min(t),this.max.max(t),this}expandByVector(t){return this.min.sub(t),this.max.add(t),this}expandByScalar(t){return this.min.addScalar(-t),this.max.addScalar(t),this}expandByObject(t,e=!1){t.updateWorldMatrix(!1,!1);const n=t.geometry;if(n!==void 0){const s=n.getAttribute("position");if(e===!0&&s!==void 0&&t.isInstancedMesh!==!0)for(let o=0,a=s.count;o<a;o++)t.isMesh===!0?t.getVertexPosition(o,Xe):Xe.fromBufferAttribute(s,o),Xe.applyMatrix4(t.matrixWorld),this.expandByPoint(Xe);else t.boundingBox!==void 0?(t.boundingBox===null&&t.computeBoundingBox(),tr.copy(t.boundingBox)):(n.boundingBox===null&&n.computeBoundingBox(),tr.copy(n.boundingBox)),tr.applyMatrix4(t.matrixWorld),this.union(tr)}const r=t.children;for(let s=0,o=r.length;s<o;s++)this.expandByObject(r[s],e);return this}containsPoint(t){return!(t.x<this.min.x||t.x>this.max.x||t.y<this.min.y||t.y>this.max.y||t.z<this.min.z||t.z>this.max.z)}containsBox(t){return this.min.x<=t.min.x&&t.max.x<=this.max.x&&this.min.y<=t.min.y&&t.max.y<=this.max.y&&this.min.z<=t.min.z&&t.max.z<=this.max.z}getParameter(t,e){return e.set((t.x-this.min.x)/(this.max.x-this.min.x),(t.y-this.min.y)/(this.max.y-this.min.y),(t.z-this.min.z)/(this.max.z-this.min.z))}intersectsBox(t){return!(t.max.x<this.min.x||t.min.x>this.max.x||t.max.y<this.min.y||t.min.y>this.max.y||t.max.z<this.min.z||t.min.z>this.max.z)}intersectsSphere(t){return this.clampPoint(t.center,Xe),Xe.distanceToSquared(t.center)<=t.radius*t.radius}intersectsPlane(t){let e,n;return t.normal.x>0?(e=t.normal.x*this.min.x,n=t.normal.x*this.max.x):(e=t.normal.x*this.max.x,n=t.normal.x*this.min.x),t.normal.y>0?(e+=t.normal.y*this.min.y,n+=t.normal.y*this.max.y):(e+=t.normal.y*this.max.y,n+=t.normal.y*this.min.y),t.normal.z>0?(e+=t.normal.z*this.min.z,n+=t.normal.z*this.max.z):(e+=t.normal.z*this.max.z,n+=t.normal.z*this.min.z),e<=-t.constant&&n>=-t.constant}intersectsTriangle(t){if(this.isEmpty())return!1;this.getCenter(Ci),er.subVectors(this.max,Ci),$n.subVectors(t.a,Ci),Kn.subVectors(t.b,Ci),Zn.subVectors(t.c,Ci),gn.subVectors(Kn,$n),_n.subVectors(Zn,Kn),Ln.subVectors($n,Zn);let e=[0,-gn.z,gn.y,0,-_n.z,_n.y,0,-Ln.z,Ln.y,gn.z,0,-gn.x,_n.z,0,-_n.x,Ln.z,0,-Ln.x,-gn.y,gn.x,0,-_n.y,_n.x,0,-Ln.y,Ln.x,0];return!as(e,$n,Kn,Zn,er)||(e=[1,0,0,0,1,0,0,0,1],!as(e,$n,Kn,Zn,er))?!1:(nr.crossVectors(gn,_n),e=[nr.x,nr.y,nr.z],as(e,$n,Kn,Zn,er))}clampPoint(t,e){return e.copy(t).clamp(this.min,this.max)}distanceToPoint(t){return this.clampPoint(t,Xe).distanceTo(t)}getBoundingSphere(t){return this.isEmpty()?t.makeEmpty():(this.getCenter(t.center),t.radius=this.getSize(Xe).length()*.5),t}intersect(t){return this.min.max(t.min),this.max.min(t.max),this.isEmpty()&&this.makeEmpty(),this}union(t){return this.min.min(t.min),this.max.max(t.max),this}applyMatrix4(t){return this.isEmpty()?this:(rn[0].set(this.min.x,this.min.y,this.min.z).applyMatrix4(t),rn[1].set(this.min.x,this.min.y,this.max.z).applyMatrix4(t),rn[2].set(this.min.x,this.max.y,this.min.z).applyMatrix4(t),rn[3].set(this.min.x,this.max.y,this.max.z).applyMatrix4(t),rn[4].set(this.max.x,this.min.y,this.min.z).applyMatrix4(t),rn[5].set(this.max.x,this.min.y,this.max.z).applyMatrix4(t),rn[6].set(this.max.x,this.max.y,this.min.z).applyMatrix4(t),rn[7].set(this.max.x,this.max.y,this.max.z).applyMatrix4(t),this.setFromPoints(rn),this)}translate(t){return this.min.add(t),this.max.add(t),this}equals(t){return t.min.equals(this.min)&&t.max.equals(this.max)}}const rn=[new W,new W,new W,new W,new W,new W,new W,new W],Xe=new W,tr=new Hn,$n=new W,Kn=new W,Zn=new W,gn=new W,_n=new W,Ln=new W,Ci=new W,er=new W,nr=new W,Dn=new W;function as(i,t,e,n,r){for(let s=0,o=i.length-3;s<=o;s+=3){Dn.fromArray(i,s);const a=r.x*Math.abs(Dn.x)+r.y*Math.abs(Dn.y)+r.z*Math.abs(Dn.z),l=t.dot(Dn),c=e.dot(Dn),u=n.dot(Dn);if(Math.max(-Math.max(l,c,u),Math.min(l,c,u))>a)return!1}return!0}const yu=new Hn,Pi=new W,ls=new W;class Vn{constructor(t=new W,e=-1){this.isSphere=!0,this.center=t,this.radius=e}set(t,e){return this.center.copy(t),this.radius=e,this}setFromPoints(t,e){const n=this.center;e!==void 0?n.copy(e):yu.setFromPoints(t).getCenter(n);let r=0;for(let s=0,o=t.length;s<o;s++)r=Math.max(r,n.distanceToSquared(t[s]));return this.radius=Math.sqrt(r),this}copy(t){return this.center.copy(t.center),this.radius=t.radius,this}isEmpty(){return this.radius<0}makeEmpty(){return this.center.set(0,0,0),this.radius=-1,this}containsPoint(t){return t.distanceToSquared(this.center)<=this.radius*this.radius}distanceToPoint(t){return t.distanceTo(this.center)-this.radius}intersectsSphere(t){const e=this.radius+t.radius;return t.center.distanceToSquared(this.center)<=e*e}intersectsBox(t){return t.intersectsSphere(this)}intersectsPlane(t){return Math.abs(t.distanceToPoint(this.center))<=this.radius}clampPoint(t,e){const n=this.center.distanceToSquared(t);return e.copy(t),n>this.radius*this.radius&&(e.sub(this.center).normalize(),e.multiplyScalar(this.radius).add(this.center)),e}getBoundingBox(t){return this.isEmpty()?(t.makeEmpty(),t):(t.set(this.center,this.center),t.expandByScalar(this.radius),t)}applyMatrix4(t){return this.center.applyMatrix4(t),this.radius=this.radius*t.getMaxScaleOnAxis(),this}translate(t){return this.center.add(t),this}expandByPoint(t){if(this.isEmpty())return this.center.copy(t),this.radius=0,this;Pi.subVectors(t,this.center);const e=Pi.lengthSq();if(e>this.radius*this.radius){const n=Math.sqrt(e),r=(n-this.radius)*.5;this.center.addScaledVector(Pi,r/n),this.radius+=r}return this}union(t){return t.isEmpty()?this:this.isEmpty()?(this.copy(t),this):(this.center.equals(t.center)===!0?this.radius=Math.max(this.radius,t.radius):(ls.subVectors(t.center,this.center).setLength(t.radius),this.expandByPoint(Pi.copy(t.center).add(ls)),this.expandByPoint(Pi.copy(t.center).sub(ls))),this)}equals(t){return t.center.equals(this.center)&&t.radius===this.radius}clone(){return new this.constructor().copy(this)}}const sn=new W,cs=new W,ir=new W,vn=new W,us=new W,rr=new W,hs=new W;class $i{constructor(t=new W,e=new W(0,0,-1)){this.origin=t,this.direction=e}set(t,e){return this.origin.copy(t),this.direction.copy(e),this}copy(t){return this.origin.copy(t.origin),this.direction.copy(t.direction),this}at(t,e){return e.copy(this.origin).addScaledVector(this.direction,t)}lookAt(t){return this.direction.copy(t).sub(this.origin).normalize(),this}recast(t){return this.origin.copy(this.at(t,sn)),this}closestPointToPoint(t,e){e.subVectors(t,this.origin);const n=e.dot(this.direction);return n<0?e.copy(this.origin):e.copy(this.origin).addScaledVector(this.direction,n)}distanceToPoint(t){return Math.sqrt(this.distanceSqToPoint(t))}distanceSqToPoint(t){const e=sn.subVectors(t,this.origin).dot(this.direction);return e<0?this.origin.distanceToSquared(t):(sn.copy(this.origin).addScaledVector(this.direction,e),sn.distanceToSquared(t))}distanceSqToSegment(t,e,n,r){cs.copy(t).add(e).multiplyScalar(.5),ir.copy(e).sub(t).normalize(),vn.copy(this.origin).sub(cs);const s=t.distanceTo(e)*.5,o=-this.direction.dot(ir),a=vn.dot(this.direction),l=-vn.dot(ir),c=vn.lengthSq(),u=Math.abs(1-o*o);let f,m,p,v;if(u>0)if(f=o*l-a,m=o*a-l,v=s*u,f>=0)if(m>=-v)if(m<=v){const x=1/u;f*=x,m*=x,p=f*(f+o*m+2*a)+m*(o*f+m+2*l)+c}else m=s,f=Math.max(0,-(o*m+a)),p=-f*f+m*(m+2*l)+c;else m=-s,f=Math.max(0,-(o*m+a)),p=-f*f+m*(m+2*l)+c;else m<=-v?(f=Math.max(0,-(-o*s+a)),m=f>0?-s:Math.min(Math.max(-s,-l),s),p=-f*f+m*(m+2*l)+c):m<=v?(f=0,m=Math.min(Math.max(-s,-l),s),p=m*(m+2*l)+c):(f=Math.max(0,-(o*s+a)),m=f>0?s:Math.min(Math.max(-s,-l),s),p=-f*f+m*(m+2*l)+c);else m=o>0?-s:s,f=Math.max(0,-(o*m+a)),p=-f*f+m*(m+2*l)+c;return n&&n.copy(this.origin).addScaledVector(this.direction,f),r&&r.copy(cs).addScaledVector(ir,m),p}intersectSphere(t,e){sn.subVectors(t.center,this.origin);const n=sn.dot(this.direction),r=sn.dot(sn)-n*n,s=t.radius*t.radius;if(r>s)return null;const o=Math.sqrt(s-r),a=n-o,l=n+o;return l<0?null:a<0?this.at(l,e):this.at(a,e)}intersectsSphere(t){return this.distanceSqToPoint(t.center)<=t.radius*t.radius}distanceToPlane(t){const e=t.normal.dot(this.direction);if(e===0)return t.distanceToPoint(this.origin)===0?0:null;const n=-(this.origin.dot(t.normal)+t.constant)/e;return n>=0?n:null}intersectPlane(t,e){const n=this.distanceToPlane(t);return n===null?null:this.at(n,e)}intersectsPlane(t){const e=t.distanceToPoint(this.origin);return e===0||t.normal.dot(this.direction)*e<0}intersectBox(t,e){let n,r,s,o,a,l;const c=1/this.direction.x,u=1/this.direction.y,f=1/this.direction.z,m=this.origin;return c>=0?(n=(t.min.x-m.x)*c,r=(t.max.x-m.x)*c):(n=(t.max.x-m.x)*c,r=(t.min.x-m.x)*c),u>=0?(s=(t.min.y-m.y)*u,o=(t.max.y-m.y)*u):(s=(t.max.y-m.y)*u,o=(t.min.y-m.y)*u),n>o||s>r||((s>n||isNaN(n))&&(n=s),(o<r||isNaN(r))&&(r=o),f>=0?(a=(t.min.z-m.z)*f,l=(t.max.z-m.z)*f):(a=(t.max.z-m.z)*f,l=(t.min.z-m.z)*f),n>l||a>r)||((a>n||n!==n)&&(n=a),(l<r||r!==r)&&(r=l),r<0)?null:this.at(n>=0?n:r,e)}intersectsBox(t){return this.intersectBox(t,sn)!==null}intersectTriangle(t,e,n,r,s){us.subVectors(e,t),rr.subVectors(n,t),hs.crossVectors(us,rr);let o=this.direction.dot(hs),a;if(o>0){if(r)return null;a=1}else if(o<0)a=-1,o=-o;else return null;vn.subVectors(this.origin,t);const l=a*this.direction.dot(rr.crossVectors(vn,rr));if(l<0)return null;const c=a*this.direction.dot(us.cross(vn));if(c<0||l+c>o)return null;const u=-a*vn.dot(hs);return u<0?null:this.at(u/o,s)}applyMatrix4(t){return this.origin.applyMatrix4(t),this.direction.transformDirection(t),this}equals(t){return t.origin.equals(this.origin)&&t.direction.equals(this.direction)}clone(){return new this.constructor().copy(this)}}class ie{constructor(t,e,n,r,s,o,a,l,c,u,f,m,p,v,x,d){ie.prototype.isMatrix4=!0,this.elements=[1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1],t!==void 0&&this.set(t,e,n,r,s,o,a,l,c,u,f,m,p,v,x,d)}set(t,e,n,r,s,o,a,l,c,u,f,m,p,v,x,d){const h=this.elements;return h[0]=t,h[4]=e,h[8]=n,h[12]=r,h[1]=s,h[5]=o,h[9]=a,h[13]=l,h[2]=c,h[6]=u,h[10]=f,h[14]=m,h[3]=p,h[7]=v,h[11]=x,h[15]=d,this}identity(){return this.set(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1),this}clone(){return new ie().fromArray(this.elements)}copy(t){const e=this.elements,n=t.elements;return e[0]=n[0],e[1]=n[1],e[2]=n[2],e[3]=n[3],e[4]=n[4],e[5]=n[5],e[6]=n[6],e[7]=n[7],e[8]=n[8],e[9]=n[9],e[10]=n[10],e[11]=n[11],e[12]=n[12],e[13]=n[13],e[14]=n[14],e[15]=n[15],this}copyPosition(t){const e=this.elements,n=t.elements;return e[12]=n[12],e[13]=n[13],e[14]=n[14],this}setFromMatrix3(t){const e=t.elements;return this.set(e[0],e[3],e[6],0,e[1],e[4],e[7],0,e[2],e[5],e[8],0,0,0,0,1),this}extractBasis(t,e,n){return t.setFromMatrixColumn(this,0),e.setFromMatrixColumn(this,1),n.setFromMatrixColumn(this,2),this}makeBasis(t,e,n){return this.set(t.x,e.x,n.x,0,t.y,e.y,n.y,0,t.z,e.z,n.z,0,0,0,0,1),this}extractRotation(t){const e=this.elements,n=t.elements,r=1/Jn.setFromMatrixColumn(t,0).length(),s=1/Jn.setFromMatrixColumn(t,1).length(),o=1/Jn.setFromMatrixColumn(t,2).length();return e[0]=n[0]*r,e[1]=n[1]*r,e[2]=n[2]*r,e[3]=0,e[4]=n[4]*s,e[5]=n[5]*s,e[6]=n[6]*s,e[7]=0,e[8]=n[8]*o,e[9]=n[9]*o,e[10]=n[10]*o,e[11]=0,e[12]=0,e[13]=0,e[14]=0,e[15]=1,this}makeRotationFromEuler(t){const e=this.elements,n=t.x,r=t.y,s=t.z,o=Math.cos(n),a=Math.sin(n),l=Math.cos(r),c=Math.sin(r),u=Math.cos(s),f=Math.sin(s);if(t.order==="XYZ"){const m=o*u,p=o*f,v=a*u,x=a*f;e[0]=l*u,e[4]=-l*f,e[8]=c,e[1]=p+v*c,e[5]=m-x*c,e[9]=-a*l,e[2]=x-m*c,e[6]=v+p*c,e[10]=o*l}else if(t.order==="YXZ"){const m=l*u,p=l*f,v=c*u,x=c*f;e[0]=m+x*a,e[4]=v*a-p,e[8]=o*c,e[1]=o*f,e[5]=o*u,e[9]=-a,e[2]=p*a-v,e[6]=x+m*a,e[10]=o*l}else if(t.order==="ZXY"){const m=l*u,p=l*f,v=c*u,x=c*f;e[0]=m-x*a,e[4]=-o*f,e[8]=v+p*a,e[1]=p+v*a,e[5]=o*u,e[9]=x-m*a,e[2]=-o*c,e[6]=a,e[10]=o*l}else if(t.order==="ZYX"){const m=o*u,p=o*f,v=a*u,x=a*f;e[0]=l*u,e[4]=v*c-p,e[8]=m*c+x,e[1]=l*f,e[5]=x*c+m,e[9]=p*c-v,e[2]=-c,e[6]=a*l,e[10]=o*l}else if(t.order==="YZX"){const m=o*l,p=o*c,v=a*l,x=a*c;e[0]=l*u,e[4]=x-m*f,e[8]=v*f+p,e[1]=f,e[5]=o*u,e[9]=-a*u,e[2]=-c*u,e[6]=p*f+v,e[10]=m-x*f}else if(t.order==="XZY"){const m=o*l,p=o*c,v=a*l,x=a*c;e[0]=l*u,e[4]=-f,e[8]=c*u,e[1]=m*f+x,e[5]=o*u,e[9]=p*f-v,e[2]=v*f-p,e[6]=a*u,e[10]=x*f+m}return e[3]=0,e[7]=0,e[11]=0,e[12]=0,e[13]=0,e[14]=0,e[15]=1,this}makeRotationFromQuaternion(t){return this.compose(Su,t,bu)}lookAt(t,e,n){const r=this.elements;return Ue.subVectors(t,e),Ue.lengthSq()===0&&(Ue.z=1),Ue.normalize(),xn.crossVectors(n,Ue),xn.lengthSq()===0&&(Math.abs(n.z)===1?Ue.x+=1e-4:Ue.z+=1e-4,Ue.normalize(),xn.crossVectors(n,Ue)),xn.normalize(),sr.crossVectors(Ue,xn),r[0]=xn.x,r[4]=sr.x,r[8]=Ue.x,r[1]=xn.y,r[5]=sr.y,r[9]=Ue.y,r[2]=xn.z,r[6]=sr.z,r[10]=Ue.z,this}multiply(t){return this.multiplyMatrices(this,t)}premultiply(t){return this.multiplyMatrices(t,this)}multiplyMatrices(t,e){const n=t.elements,r=e.elements,s=this.elements,o=n[0],a=n[4],l=n[8],c=n[12],u=n[1],f=n[5],m=n[9],p=n[13],v=n[2],x=n[6],d=n[10],h=n[14],y=n[3],_=n[7],w=n[11],D=n[15],P=r[0],I=r[4],F=r[8],M=r[12],A=r[1],K=r[5],O=r[9],z=r[13],S=r[2],E=r[6],g=r[10],T=r[14],L=r[3],N=r[7],C=r[11],U=r[15];return s[0]=o*P+a*A+l*S+c*L,s[4]=o*I+a*K+l*E+c*N,s[8]=o*F+a*O+l*g+c*C,s[12]=o*M+a*z+l*T+c*U,s[1]=u*P+f*A+m*S+p*L,s[5]=u*I+f*K+m*E+p*N,s[9]=u*F+f*O+m*g+p*C,s[13]=u*M+f*z+m*T+p*U,s[2]=v*P+x*A+d*S+h*L,s[6]=v*I+x*K+d*E+h*N,s[10]=v*F+x*O+d*g+h*C,s[14]=v*M+x*z+d*T+h*U,s[3]=y*P+_*A+w*S+D*L,s[7]=y*I+_*K+w*E+D*N,s[11]=y*F+_*O+w*g+D*C,s[15]=y*M+_*z+w*T+D*U,this}multiplyScalar(t){const e=this.elements;return e[0]*=t,e[4]*=t,e[8]*=t,e[12]*=t,e[1]*=t,e[5]*=t,e[9]*=t,e[13]*=t,e[2]*=t,e[6]*=t,e[10]*=t,e[14]*=t,e[3]*=t,e[7]*=t,e[11]*=t,e[15]*=t,this}determinant(){const t=this.elements,e=t[0],n=t[4],r=t[8],s=t[12],o=t[1],a=t[5],l=t[9],c=t[13],u=t[2],f=t[6],m=t[10],p=t[14],v=t[3],x=t[7],d=t[11],h=t[15];return v*(+s*l*f-r*c*f-s*a*m+n*c*m+r*a*p-n*l*p)+x*(+e*l*p-e*c*m+s*o*m-r*o*p+r*c*u-s*l*u)+d*(+e*c*f-e*a*p-s*o*f+n*o*p+s*a*u-n*c*u)+h*(-r*a*u-e*l*f+e*a*m+r*o*f-n*o*m+n*l*u)}transpose(){const t=this.elements;let e;return e=t[1],t[1]=t[4],t[4]=e,e=t[2],t[2]=t[8],t[8]=e,e=t[6],t[6]=t[9],t[9]=e,e=t[3],t[3]=t[12],t[12]=e,e=t[7],t[7]=t[13],t[13]=e,e=t[11],t[11]=t[14],t[14]=e,this}setPosition(t,e,n){const r=this.elements;return t.isVector3?(r[12]=t.x,r[13]=t.y,r[14]=t.z):(r[12]=t,r[13]=e,r[14]=n),this}invert(){const t=this.elements,e=t[0],n=t[1],r=t[2],s=t[3],o=t[4],a=t[5],l=t[6],c=t[7],u=t[8],f=t[9],m=t[10],p=t[11],v=t[12],x=t[13],d=t[14],h=t[15],y=f*d*c-x*m*c+x*l*p-a*d*p-f*l*h+a*m*h,_=v*m*c-u*d*c-v*l*p+o*d*p+u*l*h-o*m*h,w=u*x*c-v*f*c+v*a*p-o*x*p-u*a*h+o*f*h,D=v*f*l-u*x*l-v*a*m+o*x*m+u*a*d-o*f*d,P=e*y+n*_+r*w+s*D;if(P===0)return this.set(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);const I=1/P;return t[0]=y*I,t[1]=(x*m*s-f*d*s-x*r*p+n*d*p+f*r*h-n*m*h)*I,t[2]=(a*d*s-x*l*s+x*r*c-n*d*c-a*r*h+n*l*h)*I,t[3]=(f*l*s-a*m*s-f*r*c+n*m*c+a*r*p-n*l*p)*I,t[4]=_*I,t[5]=(u*d*s-v*m*s+v*r*p-e*d*p-u*r*h+e*m*h)*I,t[6]=(v*l*s-o*d*s-v*r*c+e*d*c+o*r*h-e*l*h)*I,t[7]=(o*m*s-u*l*s+u*r*c-e*m*c-o*r*p+e*l*p)*I,t[8]=w*I,t[9]=(v*f*s-u*x*s-v*n*p+e*x*p+u*n*h-e*f*h)*I,t[10]=(o*x*s-v*a*s+v*n*c-e*x*c-o*n*h+e*a*h)*I,t[11]=(u*a*s-o*f*s-u*n*c+e*f*c+o*n*p-e*a*p)*I,t[12]=D*I,t[13]=(u*x*r-v*f*r+v*n*m-e*x*m-u*n*d+e*f*d)*I,t[14]=(v*a*r-o*x*r-v*n*l+e*x*l+o*n*d-e*a*d)*I,t[15]=(o*f*r-u*a*r+u*n*l-e*f*l-o*n*m+e*a*m)*I,this}scale(t){const e=this.elements,n=t.x,r=t.y,s=t.z;return e[0]*=n,e[4]*=r,e[8]*=s,e[1]*=n,e[5]*=r,e[9]*=s,e[2]*=n,e[6]*=r,e[10]*=s,e[3]*=n,e[7]*=r,e[11]*=s,this}getMaxScaleOnAxis(){const t=this.elements,e=t[0]*t[0]+t[1]*t[1]+t[2]*t[2],n=t[4]*t[4]+t[5]*t[5]+t[6]*t[6],r=t[8]*t[8]+t[9]*t[9]+t[10]*t[10];return Math.sqrt(Math.max(e,n,r))}makeTranslation(t,e,n){return t.isVector3?this.set(1,0,0,t.x,0,1,0,t.y,0,0,1,t.z,0,0,0,1):this.set(1,0,0,t,0,1,0,e,0,0,1,n,0,0,0,1),this}makeRotationX(t){const e=Math.cos(t),n=Math.sin(t);return this.set(1,0,0,0,0,e,-n,0,0,n,e,0,0,0,0,1),this}makeRotationY(t){const e=Math.cos(t),n=Math.sin(t);return this.set(e,0,n,0,0,1,0,0,-n,0,e,0,0,0,0,1),this}makeRotationZ(t){const e=Math.cos(t),n=Math.sin(t);return this.set(e,-n,0,0,n,e,0,0,0,0,1,0,0,0,0,1),this}makeRotationAxis(t,e){const n=Math.cos(e),r=Math.sin(e),s=1-n,o=t.x,a=t.y,l=t.z,c=s*o,u=s*a;return this.set(c*o+n,c*a-r*l,c*l+r*a,0,c*a+r*l,u*a+n,u*l-r*o,0,c*l-r*a,u*l+r*o,s*l*l+n,0,0,0,0,1),this}makeScale(t,e,n){return this.set(t,0,0,0,0,e,0,0,0,0,n,0,0,0,0,1),this}makeShear(t,e,n,r,s,o){return this.set(1,n,s,0,t,1,o,0,e,r,1,0,0,0,0,1),this}compose(t,e,n){const r=this.elements,s=e._x,o=e._y,a=e._z,l=e._w,c=s+s,u=o+o,f=a+a,m=s*c,p=s*u,v=s*f,x=o*u,d=o*f,h=a*f,y=l*c,_=l*u,w=l*f,D=n.x,P=n.y,I=n.z;return r[0]=(1-(x+h))*D,r[1]=(p+w)*D,r[2]=(v-_)*D,r[3]=0,r[4]=(p-w)*P,r[5]=(1-(m+h))*P,r[6]=(d+y)*P,r[7]=0,r[8]=(v+_)*I,r[9]=(d-y)*I,r[10]=(1-(m+x))*I,r[11]=0,r[12]=t.x,r[13]=t.y,r[14]=t.z,r[15]=1,this}decompose(t,e,n){const r=this.elements;let s=Jn.set(r[0],r[1],r[2]).length();const o=Jn.set(r[4],r[5],r[6]).length(),a=Jn.set(r[8],r[9],r[10]).length();this.determinant()<0&&(s=-s),t.x=r[12],t.y=r[13],t.z=r[14],qe.copy(this);const c=1/s,u=1/o,f=1/a;return qe.elements[0]*=c,qe.elements[1]*=c,qe.elements[2]*=c,qe.elements[4]*=u,qe.elements[5]*=u,qe.elements[6]*=u,qe.elements[8]*=f,qe.elements[9]*=f,qe.elements[10]*=f,e.setFromRotationMatrix(qe),n.x=s,n.y=o,n.z=a,this}makePerspective(t,e,n,r,s,o,a=un){const l=this.elements,c=2*s/(e-t),u=2*s/(n-r),f=(e+t)/(e-t),m=(n+r)/(n-r);let p,v;if(a===un)p=-(o+s)/(o-s),v=-2*o*s/(o-s);else if(a===Nr)p=-o/(o-s),v=-o*s/(o-s);else throw new Error("THREE.Matrix4.makePerspective(): Invalid coordinate system: "+a);return l[0]=c,l[4]=0,l[8]=f,l[12]=0,l[1]=0,l[5]=u,l[9]=m,l[13]=0,l[2]=0,l[6]=0,l[10]=p,l[14]=v,l[3]=0,l[7]=0,l[11]=-1,l[15]=0,this}makeOrthographic(t,e,n,r,s,o,a=un){const l=this.elements,c=1/(e-t),u=1/(n-r),f=1/(o-s),m=(e+t)*c,p=(n+r)*u;let v,x;if(a===un)v=(o+s)*f,x=-2*f;else if(a===Nr)v=s*f,x=-1*f;else throw new Error("THREE.Matrix4.makeOrthographic(): Invalid coordinate system: "+a);return l[0]=2*c,l[4]=0,l[8]=0,l[12]=-m,l[1]=0,l[5]=2*u,l[9]=0,l[13]=-p,l[2]=0,l[6]=0,l[10]=x,l[14]=-v,l[3]=0,l[7]=0,l[11]=0,l[15]=1,this}equals(t){const e=this.elements,n=t.elements;for(let r=0;r<16;r++)if(e[r]!==n[r])return!1;return!0}fromArray(t,e=0){for(let n=0;n<16;n++)this.elements[n]=t[n+e];return this}toArray(t=[],e=0){const n=this.elements;return t[e]=n[0],t[e+1]=n[1],t[e+2]=n[2],t[e+3]=n[3],t[e+4]=n[4],t[e+5]=n[5],t[e+6]=n[6],t[e+7]=n[7],t[e+8]=n[8],t[e+9]=n[9],t[e+10]=n[10],t[e+11]=n[11],t[e+12]=n[12],t[e+13]=n[13],t[e+14]=n[14],t[e+15]=n[15],t}}const Jn=new W,qe=new ie,Su=new W(0,0,0),bu=new W(1,1,1),xn=new W,sr=new W,Ue=new W,ra=new ie,sa=new An;class Ki{constructor(t=0,e=0,n=0,r=Ki.DEFAULT_ORDER){this.isEuler=!0,this._x=t,this._y=e,this._z=n,this._order=r}get x(){return this._x}set x(t){this._x=t,this._onChangeCallback()}get y(){return this._y}set y(t){this._y=t,this._onChangeCallback()}get z(){return this._z}set z(t){this._z=t,this._onChangeCallback()}get order(){return this._order}set order(t){this._order=t,this._onChangeCallback()}set(t,e,n,r=this._order){return this._x=t,this._y=e,this._z=n,this._order=r,this._onChangeCallback(),this}clone(){return new this.constructor(this._x,this._y,this._z,this._order)}copy(t){return this._x=t._x,this._y=t._y,this._z=t._z,this._order=t._order,this._onChangeCallback(),this}setFromRotationMatrix(t,e=this._order,n=!0){const r=t.elements,s=r[0],o=r[4],a=r[8],l=r[1],c=r[5],u=r[9],f=r[2],m=r[6],p=r[10];switch(e){case"XYZ":this._y=Math.asin(xe(a,-1,1)),Math.abs(a)<.9999999?(this._x=Math.atan2(-u,p),this._z=Math.atan2(-o,s)):(this._x=Math.atan2(m,c),this._z=0);break;case"YXZ":this._x=Math.asin(-xe(u,-1,1)),Math.abs(u)<.9999999?(this._y=Math.atan2(a,p),this._z=Math.atan2(l,c)):(this._y=Math.atan2(-f,s),this._z=0);break;case"ZXY":this._x=Math.asin(xe(m,-1,1)),Math.abs(m)<.9999999?(this._y=Math.atan2(-f,p),this._z=Math.atan2(-o,c)):(this._y=0,this._z=Math.atan2(l,s));break;case"ZYX":this._y=Math.asin(-xe(f,-1,1)),Math.abs(f)<.9999999?(this._x=Math.atan2(m,p),this._z=Math.atan2(l,s)):(this._x=0,this._z=Math.atan2(-o,c));break;case"YZX":this._z=Math.asin(xe(l,-1,1)),Math.abs(l)<.9999999?(this._x=Math.atan2(-u,c),this._y=Math.atan2(-f,s)):(this._x=0,this._y=Math.atan2(a,p));break;case"XZY":this._z=Math.asin(-xe(o,-1,1)),Math.abs(o)<.9999999?(this._x=Math.atan2(m,c),this._y=Math.atan2(a,s)):(this._x=Math.atan2(-u,p),this._y=0);break;default:console.warn("THREE.Euler: .setFromRotationMatrix() encountered an unknown order: "+e)}return this._order=e,n===!0&&this._onChangeCallback(),this}setFromQuaternion(t,e,n){return ra.makeRotationFromQuaternion(t),this.setFromRotationMatrix(ra,e,n)}setFromVector3(t,e=this._order){return this.set(t.x,t.y,t.z,e)}reorder(t){return sa.setFromEuler(this),this.setFromQuaternion(sa,t)}equals(t){return t._x===this._x&&t._y===this._y&&t._z===this._z&&t._order===this._order}fromArray(t){return this._x=t[0],this._y=t[1],this._z=t[2],t[3]!==void 0&&(this._order=t[3]),this._onChangeCallback(),this}toArray(t=[],e=0){return t[e]=this._x,t[e+1]=this._y,t[e+2]=this._z,t[e+3]=this._order,t}_onChange(t){return this._onChangeCallback=t,this}_onChangeCallback(){}*[Symbol.iterator](){yield this._x,yield this._y,yield this._z,yield this._order}}Ki.DEFAULT_ORDER="XYZ";class to{constructor(){this.mask=1}set(t){this.mask=(1<<t|0)>>>0}enable(t){this.mask|=1<<t|0}enableAll(){this.mask=-1}toggle(t){this.mask^=1<<t|0}disable(t){this.mask&=~(1<<t|0)}disableAll(){this.mask=0}test(t){return(this.mask&t.mask)!==0}isEnabled(t){return(this.mask&(1<<t|0))!==0}}let Eu=0;const oa=new W,Qn=new An,on=new ie,or=new W,Li=new W,Tu=new W,wu=new An,aa=new W(1,0,0),la=new W(0,1,0),ca=new W(0,0,1),Au={type:"added"},Ru={type:"removed"};class ue extends kn{constructor(){super(),this.isObject3D=!0,Object.defineProperty(this,"id",{value:Eu++}),this.uuid=fn(),this.name="",this.type="Object3D",this.parent=null,this.children=[],this.up=ue.DEFAULT_UP.clone();const t=new W,e=new Ki,n=new An,r=new W(1,1,1);function s(){n.setFromEuler(e,!1)}function o(){e.setFromQuaternion(n,void 0,!1)}e._onChange(s),n._onChange(o),Object.defineProperties(this,{position:{configurable:!0,enumerable:!0,value:t},rotation:{configurable:!0,enumerable:!0,value:e},quaternion:{configurable:!0,enumerable:!0,value:n},scale:{configurable:!0,enumerable:!0,value:r},modelViewMatrix:{value:new ie},normalMatrix:{value:new Kt}}),this.matrix=new ie,this.matrixWorld=new ie,this.matrixAutoUpdate=ue.DEFAULT_MATRIX_AUTO_UPDATE,this.matrixWorldAutoUpdate=ue.DEFAULT_MATRIX_WORLD_AUTO_UPDATE,this.matrixWorldNeedsUpdate=!1,this.layers=new to,this.visible=!0,this.castShadow=!1,this.receiveShadow=!1,this.frustumCulled=!0,this.renderOrder=0,this.animations=[],this.userData={}}onBeforeShadow(){}onAfterShadow(){}onBeforeRender(){}onAfterRender(){}applyMatrix4(t){this.matrixAutoUpdate&&this.updateMatrix(),this.matrix.premultiply(t),this.matrix.decompose(this.position,this.quaternion,this.scale)}applyQuaternion(t){return this.quaternion.premultiply(t),this}setRotationFromAxisAngle(t,e){this.quaternion.setFromAxisAngle(t,e)}setRotationFromEuler(t){this.quaternion.setFromEuler(t,!0)}setRotationFromMatrix(t){this.quaternion.setFromRotationMatrix(t)}setRotationFromQuaternion(t){this.quaternion.copy(t)}rotateOnAxis(t,e){return Qn.setFromAxisAngle(t,e),this.quaternion.multiply(Qn),this}rotateOnWorldAxis(t,e){return Qn.setFromAxisAngle(t,e),this.quaternion.premultiply(Qn),this}rotateX(t){return this.rotateOnAxis(aa,t)}rotateY(t){return this.rotateOnAxis(la,t)}rotateZ(t){return this.rotateOnAxis(ca,t)}translateOnAxis(t,e){return oa.copy(t).applyQuaternion(this.quaternion),this.position.add(oa.multiplyScalar(e)),this}translateX(t){return this.translateOnAxis(aa,t)}translateY(t){return this.translateOnAxis(la,t)}translateZ(t){return this.translateOnAxis(ca,t)}localToWorld(t){return this.updateWorldMatrix(!0,!1),t.applyMatrix4(this.matrixWorld)}worldToLocal(t){return this.updateWorldMatrix(!0,!1),t.applyMatrix4(on.copy(this.matrixWorld).invert())}lookAt(t,e,n){t.isVector3?or.copy(t):or.set(t,e,n);const r=this.parent;this.updateWorldMatrix(!0,!1),Li.setFromMatrixPosition(this.matrixWorld),this.isCamera||this.isLight?on.lookAt(Li,or,this.up):on.lookAt(or,Li,this.up),this.quaternion.setFromRotationMatrix(on),r&&(on.extractRotation(r.matrixWorld),Qn.setFromRotationMatrix(on),this.quaternion.premultiply(Qn.invert()))}add(t){if(arguments.length>1){for(let e=0;e<arguments.length;e++)this.add(arguments[e]);return this}return t===this?(console.error("THREE.Object3D.add: object can't be added as a child of itself.",t),this):(t&&t.isObject3D?(t.parent!==null&&t.parent.remove(t),t.parent=this,this.children.push(t),t.dispatchEvent(Au)):console.error("THREE.Object3D.add: object not an instance of THREE.Object3D.",t),this)}remove(t){if(arguments.length>1){for(let n=0;n<arguments.length;n++)this.remove(arguments[n]);return this}const e=this.children.indexOf(t);return e!==-1&&(t.parent=null,this.children.splice(e,1),t.dispatchEvent(Ru)),this}removeFromParent(){const t=this.parent;return t!==null&&t.remove(this),this}clear(){return this.remove(...this.children)}attach(t){return this.updateWorldMatrix(!0,!1),on.copy(this.matrixWorld).invert(),t.parent!==null&&(t.parent.updateWorldMatrix(!0,!1),on.multiply(t.parent.matrixWorld)),t.applyMatrix4(on),this.add(t),t.updateWorldMatrix(!1,!0),this}getObjectById(t){return this.getObjectByProperty("id",t)}getObjectByName(t){return this.getObjectByProperty("name",t)}getObjectByProperty(t,e){if(this[t]===e)return this;for(let n=0,r=this.children.length;n<r;n++){const o=this.children[n].getObjectByProperty(t,e);if(o!==void 0)return o}}getObjectsByProperty(t,e,n=[]){this[t]===e&&n.push(this);const r=this.children;for(let s=0,o=r.length;s<o;s++)r[s].getObjectsByProperty(t,e,n);return n}getWorldPosition(t){return this.updateWorldMatrix(!0,!1),t.setFromMatrixPosition(this.matrixWorld)}getWorldQuaternion(t){return this.updateWorldMatrix(!0,!1),this.matrixWorld.decompose(Li,t,Tu),t}getWorldScale(t){return this.updateWorldMatrix(!0,!1),this.matrixWorld.decompose(Li,wu,t),t}getWorldDirection(t){this.updateWorldMatrix(!0,!1);const e=this.matrixWorld.elements;return t.set(e[8],e[9],e[10]).normalize()}raycast(){}traverse(t){t(this);const e=this.children;for(let n=0,r=e.length;n<r;n++)e[n].traverse(t)}traverseVisible(t){if(this.visible===!1)return;t(this);const e=this.children;for(let n=0,r=e.length;n<r;n++)e[n].traverseVisible(t)}traverseAncestors(t){const e=this.parent;e!==null&&(t(e),e.traverseAncestors(t))}updateMatrix(){this.matrix.compose(this.position,this.quaternion,this.scale),this.matrixWorldNeedsUpdate=!0}updateMatrixWorld(t){this.matrixAutoUpdate&&this.updateMatrix(),(this.matrixWorldNeedsUpdate||t)&&(this.parent===null?this.matrixWorld.copy(this.matrix):this.matrixWorld.multiplyMatrices(this.parent.matrixWorld,this.matrix),this.matrixWorldNeedsUpdate=!1,t=!0);const e=this.children;for(let n=0,r=e.length;n<r;n++){const s=e[n];(s.matrixWorldAutoUpdate===!0||t===!0)&&s.updateMatrixWorld(t)}}updateWorldMatrix(t,e){const n=this.parent;if(t===!0&&n!==null&&n.matrixWorldAutoUpdate===!0&&n.updateWorldMatrix(!0,!1),this.matrixAutoUpdate&&this.updateMatrix(),this.parent===null?this.matrixWorld.copy(this.matrix):this.matrixWorld.multiplyMatrices(this.parent.matrixWorld,this.matrix),e===!0){const r=this.children;for(let s=0,o=r.length;s<o;s++){const a=r[s];a.matrixWorldAutoUpdate===!0&&a.updateWorldMatrix(!1,!0)}}}toJSON(t){const e=t===void 0||typeof t=="string",n={};e&&(t={geometries:{},materials:{},textures:{},images:{},shapes:{},skeletons:{},animations:{},nodes:{}},n.metadata={version:4.6,type:"Object",generator:"Object3D.toJSON"});const r={};r.uuid=this.uuid,r.type=this.type,this.name!==""&&(r.name=this.name),this.castShadow===!0&&(r.castShadow=!0),this.receiveShadow===!0&&(r.receiveShadow=!0),this.visible===!1&&(r.visible=!1),this.frustumCulled===!1&&(r.frustumCulled=!1),this.renderOrder!==0&&(r.renderOrder=this.renderOrder),Object.keys(this.userData).length>0&&(r.userData=this.userData),r.layers=this.layers.mask,r.matrix=this.matrix.toArray(),r.up=this.up.toArray(),this.matrixAutoUpdate===!1&&(r.matrixAutoUpdate=!1),this.isInstancedMesh&&(r.type="InstancedMesh",r.count=this.count,r.instanceMatrix=this.instanceMatrix.toJSON(),this.instanceColor!==null&&(r.instanceColor=this.instanceColor.toJSON())),this.isBatchedMesh&&(r.type="BatchedMesh",r.perObjectFrustumCulled=this.perObjectFrustumCulled,r.sortObjects=this.sortObjects,r.drawRanges=this._drawRanges,r.reservedRanges=this._reservedRanges,r.visibility=this._visibility,r.active=this._active,r.bounds=this._bounds.map(a=>({boxInitialized:a.boxInitialized,boxMin:a.box.min.toArray(),boxMax:a.box.max.toArray(),sphereInitialized:a.sphereInitialized,sphereRadius:a.sphere.radius,sphereCenter:a.sphere.center.toArray()})),r.maxGeometryCount=this._maxGeometryCount,r.maxVertexCount=this._maxVertexCount,r.maxIndexCount=this._maxIndexCount,r.geometryInitialized=this._geometryInitialized,r.geometryCount=this._geometryCount,r.matricesTexture=this._matricesTexture.toJSON(t),this.boundingSphere!==null&&(r.boundingSphere={center:r.boundingSphere.center.toArray(),radius:r.boundingSphere.radius}),this.boundingBox!==null&&(r.boundingBox={min:r.boundingBox.min.toArray(),max:r.boundingBox.max.toArray()}));function s(a,l){return a[l.uuid]===void 0&&(a[l.uuid]=l.toJSON(t)),l.uuid}if(this.isScene)this.background&&(this.background.isColor?r.background=this.background.toJSON():this.background.isTexture&&(r.background=this.background.toJSON(t).uuid)),this.environment&&this.environment.isTexture&&this.environment.isRenderTargetTexture!==!0&&(r.environment=this.environment.toJSON(t).uuid);else if(this.isMesh||this.isLine||this.isPoints){r.geometry=s(t.geometries,this.geometry);const a=this.geometry.parameters;if(a!==void 0&&a.shapes!==void 0){const l=a.shapes;if(Array.isArray(l))for(let c=0,u=l.length;c<u;c++){const f=l[c];s(t.shapes,f)}else s(t.shapes,l)}}if(this.isSkinnedMesh&&(r.bindMode=this.bindMode,r.bindMatrix=this.bindMatrix.toArray(),this.skeleton!==void 0&&(s(t.skeletons,this.skeleton),r.skeleton=this.skeleton.uuid)),this.material!==void 0)if(Array.isArray(this.material)){const a=[];for(let l=0,c=this.material.length;l<c;l++)a.push(s(t.materials,this.material[l]));r.material=a}else r.material=s(t.materials,this.material);if(this.children.length>0){r.children=[];for(let a=0;a<this.children.length;a++)r.children.push(this.children[a].toJSON(t).object)}if(this.animations.length>0){r.animations=[];for(let a=0;a<this.animations.length;a++){const l=this.animations[a];r.animations.push(s(t.animations,l))}}if(e){const a=o(t.geometries),l=o(t.materials),c=o(t.textures),u=o(t.images),f=o(t.shapes),m=o(t.skeletons),p=o(t.animations),v=o(t.nodes);a.length>0&&(n.geometries=a),l.length>0&&(n.materials=l),c.length>0&&(n.textures=c),u.length>0&&(n.images=u),f.length>0&&(n.shapes=f),m.length>0&&(n.skeletons=m),p.length>0&&(n.animations=p),v.length>0&&(n.nodes=v)}return n.object=r,n;function o(a){const l=[];for(const c in a){const u=a[c];delete u.metadata,l.push(u)}return l}}clone(t){return new this.constructor().copy(this,t)}copy(t,e=!0){if(this.name=t.name,this.up.copy(t.up),this.position.copy(t.position),this.rotation.order=t.rotation.order,this.quaternion.copy(t.quaternion),this.scale.copy(t.scale),this.matrix.copy(t.matrix),this.matrixWorld.copy(t.matrixWorld),this.matrixAutoUpdate=t.matrixAutoUpdate,this.matrixWorldAutoUpdate=t.matrixWorldAutoUpdate,this.matrixWorldNeedsUpdate=t.matrixWorldNeedsUpdate,this.layers.mask=t.layers.mask,this.visible=t.visible,this.castShadow=t.castShadow,this.receiveShadow=t.receiveShadow,this.frustumCulled=t.frustumCulled,this.renderOrder=t.renderOrder,this.animations=t.animations.slice(),this.userData=JSON.parse(JSON.stringify(t.userData)),e===!0)for(let n=0;n<t.children.length;n++){const r=t.children[n];this.add(r.clone())}return this}}ue.DEFAULT_UP=new W(0,1,0);ue.DEFAULT_MATRIX_AUTO_UPDATE=!0;ue.DEFAULT_MATRIX_WORLD_AUTO_UPDATE=!0;const Ye=new W,an=new W,ds=new W,ln=new W,ti=new W,ei=new W,ua=new W,fs=new W,ps=new W,ms=new W;let ar=!1;class He{constructor(t=new W,e=new W,n=new W){this.a=t,this.b=e,this.c=n}static getNormal(t,e,n,r){r.subVectors(n,e),Ye.subVectors(t,e),r.cross(Ye);const s=r.lengthSq();return s>0?r.multiplyScalar(1/Math.sqrt(s)):r.set(0,0,0)}static getBarycoord(t,e,n,r,s){Ye.subVectors(r,e),an.subVectors(n,e),ds.subVectors(t,e);const o=Ye.dot(Ye),a=Ye.dot(an),l=Ye.dot(ds),c=an.dot(an),u=an.dot(ds),f=o*c-a*a;if(f===0)return s.set(0,0,0),null;const m=1/f,p=(c*l-a*u)*m,v=(o*u-a*l)*m;return s.set(1-p-v,v,p)}static containsPoint(t,e,n,r){return this.getBarycoord(t,e,n,r,ln)===null?!1:ln.x>=0&&ln.y>=0&&ln.x+ln.y<=1}static getUV(t,e,n,r,s,o,a,l){return ar===!1&&(console.warn("THREE.Triangle.getUV() has been renamed to THREE.Triangle.getInterpolation()."),ar=!0),this.getInterpolation(t,e,n,r,s,o,a,l)}static getInterpolation(t,e,n,r,s,o,a,l){return this.getBarycoord(t,e,n,r,ln)===null?(l.x=0,l.y=0,"z"in l&&(l.z=0),"w"in l&&(l.w=0),null):(l.setScalar(0),l.addScaledVector(s,ln.x),l.addScaledVector(o,ln.y),l.addScaledVector(a,ln.z),l)}static isFrontFacing(t,e,n,r){return Ye.subVectors(n,e),an.subVectors(t,e),Ye.cross(an).dot(r)<0}set(t,e,n){return this.a.copy(t),this.b.copy(e),this.c.copy(n),this}setFromPointsAndIndices(t,e,n,r){return this.a.copy(t[e]),this.b.copy(t[n]),this.c.copy(t[r]),this}setFromAttributeAndIndices(t,e,n,r){return this.a.fromBufferAttribute(t,e),this.b.fromBufferAttribute(t,n),this.c.fromBufferAttribute(t,r),this}clone(){return new this.constructor().copy(this)}copy(t){return this.a.copy(t.a),this.b.copy(t.b),this.c.copy(t.c),this}getArea(){return Ye.subVectors(this.c,this.b),an.subVectors(this.a,this.b),Ye.cross(an).length()*.5}getMidpoint(t){return t.addVectors(this.a,this.b).add(this.c).multiplyScalar(1/3)}getNormal(t){return He.getNormal(this.a,this.b,this.c,t)}getPlane(t){return t.setFromCoplanarPoints(this.a,this.b,this.c)}getBarycoord(t,e){return He.getBarycoord(t,this.a,this.b,this.c,e)}getUV(t,e,n,r,s){return ar===!1&&(console.warn("THREE.Triangle.getUV() has been renamed to THREE.Triangle.getInterpolation()."),ar=!0),He.getInterpolation(t,this.a,this.b,this.c,e,n,r,s)}getInterpolation(t,e,n,r,s){return He.getInterpolation(t,this.a,this.b,this.c,e,n,r,s)}containsPoint(t){return He.containsPoint(t,this.a,this.b,this.c)}isFrontFacing(t){return He.isFrontFacing(this.a,this.b,this.c,t)}intersectsBox(t){return t.intersectsTriangle(this)}closestPointToPoint(t,e){const n=this.a,r=this.b,s=this.c;let o,a;ti.subVectors(r,n),ei.subVectors(s,n),fs.subVectors(t,n);const l=ti.dot(fs),c=ei.dot(fs);if(l<=0&&c<=0)return e.copy(n);ps.subVectors(t,r);const u=ti.dot(ps),f=ei.dot(ps);if(u>=0&&f<=u)return e.copy(r);const m=l*f-u*c;if(m<=0&&l>=0&&u<=0)return o=l/(l-u),e.copy(n).addScaledVector(ti,o);ms.subVectors(t,s);const p=ti.dot(ms),v=ei.dot(ms);if(v>=0&&p<=v)return e.copy(s);const x=p*c-l*v;if(x<=0&&c>=0&&v<=0)return a=c/(c-v),e.copy(n).addScaledVector(ei,a);const d=u*v-p*f;if(d<=0&&f-u>=0&&p-v>=0)return ua.subVectors(s,r),a=(f-u)/(f-u+(p-v)),e.copy(r).addScaledVector(ua,a);const h=1/(d+x+m);return o=x*h,a=m*h,e.copy(n).addScaledVector(ti,o).addScaledVector(ei,a)}equals(t){return t.a.equals(this.a)&&t.b.equals(this.b)&&t.c.equals(this.c)}}const Ll={aliceblue:15792383,antiquewhite:16444375,aqua:65535,aquamarine:8388564,azure:15794175,beige:16119260,bisque:16770244,black:0,blanchedalmond:16772045,blue:255,blueviolet:9055202,brown:10824234,burlywood:14596231,cadetblue:6266528,chartreuse:8388352,chocolate:13789470,coral:16744272,cornflowerblue:6591981,cornsilk:16775388,crimson:14423100,cyan:65535,darkblue:139,darkcyan:35723,darkgoldenrod:12092939,darkgray:11119017,darkgreen:25600,darkgrey:11119017,darkkhaki:12433259,darkmagenta:9109643,darkolivegreen:5597999,darkorange:16747520,darkorchid:10040012,darkred:9109504,darksalmon:15308410,darkseagreen:9419919,darkslateblue:4734347,darkslategray:3100495,darkslategrey:3100495,darkturquoise:52945,darkviolet:9699539,deeppink:16716947,deepskyblue:49151,dimgray:6908265,dimgrey:6908265,dodgerblue:2003199,firebrick:11674146,floralwhite:16775920,forestgreen:2263842,fuchsia:16711935,gainsboro:14474460,ghostwhite:16316671,gold:16766720,goldenrod:14329120,gray:8421504,green:32768,greenyellow:11403055,grey:8421504,honeydew:15794160,hotpink:16738740,indianred:13458524,indigo:4915330,ivory:16777200,khaki:15787660,lavender:15132410,lavenderblush:16773365,lawngreen:8190976,lemonchiffon:16775885,lightblue:11393254,lightcoral:15761536,lightcyan:14745599,lightgoldenrodyellow:16448210,lightgray:13882323,lightgreen:9498256,lightgrey:13882323,lightpink:16758465,lightsalmon:16752762,lightseagreen:2142890,lightskyblue:8900346,lightslategray:7833753,lightslategrey:7833753,lightsteelblue:11584734,lightyellow:16777184,lime:65280,limegreen:3329330,linen:16445670,magenta:16711935,maroon:8388608,mediumaquamarine:6737322,mediumblue:205,mediumorchid:12211667,mediumpurple:9662683,mediumseagreen:3978097,mediumslateblue:8087790,mediumspringgreen:64154,mediumturquoise:4772300,mediumvioletred:13047173,midnightblue:1644912,mintcream:16121850,mistyrose:16770273,moccasin:16770229,navajowhite:16768685,navy:128,oldlace:16643558,olive:8421376,olivedrab:7048739,orange:16753920,orangered:16729344,orchid:14315734,palegoldenrod:15657130,palegreen:10025880,paleturquoise:11529966,palevioletred:14381203,papayawhip:16773077,peachpuff:16767673,peru:13468991,pink:16761035,plum:14524637,powderblue:11591910,purple:8388736,rebeccapurple:6697881,red:16711680,rosybrown:12357519,royalblue:4286945,saddlebrown:9127187,salmon:16416882,sandybrown:16032864,seagreen:3050327,seashell:16774638,sienna:10506797,silver:12632256,skyblue:8900331,slateblue:6970061,slategray:7372944,slategrey:7372944,snow:16775930,springgreen:65407,steelblue:4620980,tan:13808780,teal:32896,thistle:14204888,tomato:16737095,turquoise:4251856,violet:15631086,wheat:16113331,white:16777215,whitesmoke:16119285,yellow:16776960,yellowgreen:10145074},Mn={h:0,s:0,l:0},lr={h:0,s:0,l:0};function gs(i,t,e){return e<0&&(e+=1),e>1&&(e-=1),e<1/6?i+(t-i)*6*e:e<1/2?t:e<2/3?i+(t-i)*6*(2/3-e):i}class Dt{constructor(t,e,n){return this.isColor=!0,this.r=1,this.g=1,this.b=1,this.set(t,e,n)}set(t,e,n){if(e===void 0&&n===void 0){const r=t;r&&r.isColor?this.copy(r):typeof r=="number"?this.setHex(r):typeof r=="string"&&this.setStyle(r)}else this.setRGB(t,e,n);return this}setScalar(t){return this.r=t,this.g=t,this.b=t,this}setHex(t,e=ce){return t=Math.floor(t),this.r=(t>>16&255)/255,this.g=(t>>8&255)/255,this.b=(t&255)/255,te.toWorkingColorSpace(this,e),this}setRGB(t,e,n,r=te.workingColorSpace){return this.r=t,this.g=e,this.b=n,te.toWorkingColorSpace(this,r),this}setHSL(t,e,n,r=te.workingColorSpace){if(t=Qs(t,1),e=xe(e,0,1),n=xe(n,0,1),e===0)this.r=this.g=this.b=n;else{const s=n<=.5?n*(1+e):n+e-n*e,o=2*n-s;this.r=gs(o,s,t+1/3),this.g=gs(o,s,t),this.b=gs(o,s,t-1/3)}return te.toWorkingColorSpace(this,r),this}setStyle(t,e=ce){function n(s){s!==void 0&&parseFloat(s)<1&&console.warn("THREE.Color: Alpha component of "+t+" will be ignored.")}let r;if(r=/^(\w+)\(([^\)]*)\)/.exec(t)){let s;const o=r[1],a=r[2];switch(o){case"rgb":case"rgba":if(s=/^\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(a))return n(s[4]),this.setRGB(Math.min(255,parseInt(s[1],10))/255,Math.min(255,parseInt(s[2],10))/255,Math.min(255,parseInt(s[3],10))/255,e);if(s=/^\s*(\d+)\%\s*,\s*(\d+)\%\s*,\s*(\d+)\%\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(a))return n(s[4]),this.setRGB(Math.min(100,parseInt(s[1],10))/100,Math.min(100,parseInt(s[2],10))/100,Math.min(100,parseInt(s[3],10))/100,e);break;case"hsl":case"hsla":if(s=/^\s*(\d*\.?\d+)\s*,\s*(\d*\.?\d+)\%\s*,\s*(\d*\.?\d+)\%\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(a))return n(s[4]),this.setHSL(parseFloat(s[1])/360,parseFloat(s[2])/100,parseFloat(s[3])/100,e);break;default:console.warn("THREE.Color: Unknown color model "+t)}}else if(r=/^\#([A-Fa-f\d]+)$/.exec(t)){const s=r[1],o=s.length;if(o===3)return this.setRGB(parseInt(s.charAt(0),16)/15,parseInt(s.charAt(1),16)/15,parseInt(s.charAt(2),16)/15,e);if(o===6)return this.setHex(parseInt(s,16),e);console.warn("THREE.Color: Invalid hex color "+t)}else if(t&&t.length>0)return this.setColorName(t,e);return this}setColorName(t,e=ce){const n=Ll[t.toLowerCase()];return n!==void 0?this.setHex(n,e):console.warn("THREE.Color: Unknown color "+t),this}clone(){return new this.constructor(this.r,this.g,this.b)}copy(t){return this.r=t.r,this.g=t.g,this.b=t.b,this}copySRGBToLinear(t){return this.r=vi(t.r),this.g=vi(t.g),this.b=vi(t.b),this}copyLinearToSRGB(t){return this.r=rs(t.r),this.g=rs(t.g),this.b=rs(t.b),this}convertSRGBToLinear(){return this.copySRGBToLinear(this),this}convertLinearToSRGB(){return this.copyLinearToSRGB(this),this}getHex(t=ce){return te.fromWorkingColorSpace(Se.copy(this),t),Math.round(xe(Se.r*255,0,255))*65536+Math.round(xe(Se.g*255,0,255))*256+Math.round(xe(Se.b*255,0,255))}getHexString(t=ce){return("000000"+this.getHex(t).toString(16)).slice(-6)}getHSL(t,e=te.workingColorSpace){te.fromWorkingColorSpace(Se.copy(this),e);const n=Se.r,r=Se.g,s=Se.b,o=Math.max(n,r,s),a=Math.min(n,r,s);let l,c;const u=(a+o)/2;if(a===o)l=0,c=0;else{const f=o-a;switch(c=u<=.5?f/(o+a):f/(2-o-a),o){case n:l=(r-s)/f+(r<s?6:0);break;case r:l=(s-n)/f+2;break;case s:l=(n-r)/f+4;break}l/=6}return t.h=l,t.s=c,t.l=u,t}getRGB(t,e=te.workingColorSpace){return te.fromWorkingColorSpace(Se.copy(this),e),t.r=Se.r,t.g=Se.g,t.b=Se.b,t}getStyle(t=ce){te.fromWorkingColorSpace(Se.copy(this),t);const e=Se.r,n=Se.g,r=Se.b;return t!==ce?`color(${t} ${e.toFixed(3)} ${n.toFixed(3)} ${r.toFixed(3)})`:`rgb(${Math.round(e*255)},${Math.round(n*255)},${Math.round(r*255)})`}offsetHSL(t,e,n){return this.getHSL(Mn),this.setHSL(Mn.h+t,Mn.s+e,Mn.l+n)}add(t){return this.r+=t.r,this.g+=t.g,this.b+=t.b,this}addColors(t,e){return this.r=t.r+e.r,this.g=t.g+e.g,this.b=t.b+e.b,this}addScalar(t){return this.r+=t,this.g+=t,this.b+=t,this}sub(t){return this.r=Math.max(0,this.r-t.r),this.g=Math.max(0,this.g-t.g),this.b=Math.max(0,this.b-t.b),this}multiply(t){return this.r*=t.r,this.g*=t.g,this.b*=t.b,this}multiplyScalar(t){return this.r*=t,this.g*=t,this.b*=t,this}lerp(t,e){return this.r+=(t.r-this.r)*e,this.g+=(t.g-this.g)*e,this.b+=(t.b-this.b)*e,this}lerpColors(t,e,n){return this.r=t.r+(e.r-t.r)*n,this.g=t.g+(e.g-t.g)*n,this.b=t.b+(e.b-t.b)*n,this}lerpHSL(t,e){this.getHSL(Mn),t.getHSL(lr);const n=Gi(Mn.h,lr.h,e),r=Gi(Mn.s,lr.s,e),s=Gi(Mn.l,lr.l,e);return this.setHSL(n,r,s),this}setFromVector3(t){return this.r=t.x,this.g=t.y,this.b=t.z,this}applyMatrix3(t){const e=this.r,n=this.g,r=this.b,s=t.elements;return this.r=s[0]*e+s[3]*n+s[6]*r,this.g=s[1]*e+s[4]*n+s[7]*r,this.b=s[2]*e+s[5]*n+s[8]*r,this}equals(t){return t.r===this.r&&t.g===this.g&&t.b===this.b}fromArray(t,e=0){return this.r=t[e],this.g=t[e+1],this.b=t[e+2],this}toArray(t=[],e=0){return t[e]=this.r,t[e+1]=this.g,t[e+2]=this.b,t}fromBufferAttribute(t,e){return this.r=t.getX(e),this.g=t.getY(e),this.b=t.getZ(e),this}toJSON(){return this.getHex()}*[Symbol.iterator](){yield this.r,yield this.g,yield this.b}}const Se=new Dt;Dt.NAMES=Ll;let Cu=0;class Rn extends kn{constructor(){super(),this.isMaterial=!0,Object.defineProperty(this,"id",{value:Cu++}),this.uuid=fn(),this.name="",this.type="Material",this.blending=_i,this.side=wn,this.vertexColors=!1,this.opacity=1,this.transparent=!1,this.alphaHash=!1,this.blendSrc=Os,this.blendDst=Fs,this.blendEquation=On,this.blendSrcAlpha=null,this.blendDstAlpha=null,this.blendEquationAlpha=null,this.blendColor=new Dt(0,0,0),this.blendAlpha=0,this.depthFunc=Lr,this.depthTest=!0,this.depthWrite=!0,this.stencilWriteMask=255,this.stencilFunc=Zo,this.stencilRef=0,this.stencilFuncMask=255,this.stencilFail=Yn,this.stencilZFail=Yn,this.stencilZPass=Yn,this.stencilWrite=!1,this.clippingPlanes=null,this.clipIntersection=!1,this.clipShadows=!1,this.shadowSide=null,this.colorWrite=!0,this.precision=null,this.polygonOffset=!1,this.polygonOffsetFactor=0,this.polygonOffsetUnits=0,this.dithering=!1,this.alphaToCoverage=!1,this.premultipliedAlpha=!1,this.forceSinglePass=!1,this.visible=!0,this.toneMapped=!0,this.userData={},this.version=0,this._alphaTest=0}get alphaTest(){return this._alphaTest}set alphaTest(t){this._alphaTest>0!=t>0&&this.version++,this._alphaTest=t}onBuild(){}onBeforeRender(){}onBeforeCompile(){}customProgramCacheKey(){return this.onBeforeCompile.toString()}setValues(t){if(t!==void 0)for(const e in t){const n=t[e];if(n===void 0){console.warn(`THREE.Material: parameter '${e}' has value of undefined.`);continue}const r=this[e];if(r===void 0){console.warn(`THREE.Material: '${e}' is not a property of THREE.${this.type}.`);continue}r&&r.isColor?r.set(n):r&&r.isVector3&&n&&n.isVector3?r.copy(n):this[e]=n}}toJSON(t){const e=t===void 0||typeof t=="string";e&&(t={textures:{},images:{}});const n={metadata:{version:4.6,type:"Material",generator:"Material.toJSON"}};n.uuid=this.uuid,n.type=this.type,this.name!==""&&(n.name=this.name),this.color&&this.color.isColor&&(n.color=this.color.getHex()),this.roughness!==void 0&&(n.roughness=this.roughness),this.metalness!==void 0&&(n.metalness=this.metalness),this.sheen!==void 0&&(n.sheen=this.sheen),this.sheenColor&&this.sheenColor.isColor&&(n.sheenColor=this.sheenColor.getHex()),this.sheenRoughness!==void 0&&(n.sheenRoughness=this.sheenRoughness),this.emissive&&this.emissive.isColor&&(n.emissive=this.emissive.getHex()),this.emissiveIntensity&&this.emissiveIntensity!==1&&(n.emissiveIntensity=this.emissiveIntensity),this.specular&&this.specular.isColor&&(n.specular=this.specular.getHex()),this.specularIntensity!==void 0&&(n.specularIntensity=this.specularIntensity),this.specularColor&&this.specularColor.isColor&&(n.specularColor=this.specularColor.getHex()),this.shininess!==void 0&&(n.shininess=this.shininess),this.clearcoat!==void 0&&(n.clearcoat=this.clearcoat),this.clearcoatRoughness!==void 0&&(n.clearcoatRoughness=this.clearcoatRoughness),this.clearcoatMap&&this.clearcoatMap.isTexture&&(n.clearcoatMap=this.clearcoatMap.toJSON(t).uuid),this.clearcoatRoughnessMap&&this.clearcoatRoughnessMap.isTexture&&(n.clearcoatRoughnessMap=this.clearcoatRoughnessMap.toJSON(t).uuid),this.clearcoatNormalMap&&this.clearcoatNormalMap.isTexture&&(n.clearcoatNormalMap=this.clearcoatNormalMap.toJSON(t).uuid,n.clearcoatNormalScale=this.clearcoatNormalScale.toArray()),this.iridescence!==void 0&&(n.iridescence=this.iridescence),this.iridescenceIOR!==void 0&&(n.iridescenceIOR=this.iridescenceIOR),this.iridescenceThicknessRange!==void 0&&(n.iridescenceThicknessRange=this.iridescenceThicknessRange),this.iridescenceMap&&this.iridescenceMap.isTexture&&(n.iridescenceMap=this.iridescenceMap.toJSON(t).uuid),this.iridescenceThicknessMap&&this.iridescenceThicknessMap.isTexture&&(n.iridescenceThicknessMap=this.iridescenceThicknessMap.toJSON(t).uuid),this.anisotropy!==void 0&&(n.anisotropy=this.anisotropy),this.anisotropyRotation!==void 0&&(n.anisotropyRotation=this.anisotropyRotation),this.anisotropyMap&&this.anisotropyMap.isTexture&&(n.anisotropyMap=this.anisotropyMap.toJSON(t).uuid),this.map&&this.map.isTexture&&(n.map=this.map.toJSON(t).uuid),this.matcap&&this.matcap.isTexture&&(n.matcap=this.matcap.toJSON(t).uuid),this.alphaMap&&this.alphaMap.isTexture&&(n.alphaMap=this.alphaMap.toJSON(t).uuid),this.lightMap&&this.lightMap.isTexture&&(n.lightMap=this.lightMap.toJSON(t).uuid,n.lightMapIntensity=this.lightMapIntensity),this.aoMap&&this.aoMap.isTexture&&(n.aoMap=this.aoMap.toJSON(t).uuid,n.aoMapIntensity=this.aoMapIntensity),this.bumpMap&&this.bumpMap.isTexture&&(n.bumpMap=this.bumpMap.toJSON(t).uuid,n.bumpScale=this.bumpScale),this.normalMap&&this.normalMap.isTexture&&(n.normalMap=this.normalMap.toJSON(t).uuid,n.normalMapType=this.normalMapType,n.normalScale=this.normalScale.toArray()),this.displacementMap&&this.displacementMap.isTexture&&(n.displacementMap=this.displacementMap.toJSON(t).uuid,n.displacementScale=this.displacementScale,n.displacementBias=this.displacementBias),this.roughnessMap&&this.roughnessMap.isTexture&&(n.roughnessMap=this.roughnessMap.toJSON(t).uuid),this.metalnessMap&&this.metalnessMap.isTexture&&(n.metalnessMap=this.metalnessMap.toJSON(t).uuid),this.emissiveMap&&this.emissiveMap.isTexture&&(n.emissiveMap=this.emissiveMap.toJSON(t).uuid),this.specularMap&&this.specularMap.isTexture&&(n.specularMap=this.specularMap.toJSON(t).uuid),this.specularIntensityMap&&this.specularIntensityMap.isTexture&&(n.specularIntensityMap=this.specularIntensityMap.toJSON(t).uuid),this.specularColorMap&&this.specularColorMap.isTexture&&(n.specularColorMap=this.specularColorMap.toJSON(t).uuid),this.envMap&&this.envMap.isTexture&&(n.envMap=this.envMap.toJSON(t).uuid,this.combine!==void 0&&(n.combine=this.combine)),this.envMapIntensity!==void 0&&(n.envMapIntensity=this.envMapIntensity),this.reflectivity!==void 0&&(n.reflectivity=this.reflectivity),this.refractionRatio!==void 0&&(n.refractionRatio=this.refractionRatio),this.gradientMap&&this.gradientMap.isTexture&&(n.gradientMap=this.gradientMap.toJSON(t).uuid),this.transmission!==void 0&&(n.transmission=this.transmission),this.transmissionMap&&this.transmissionMap.isTexture&&(n.transmissionMap=this.transmissionMap.toJSON(t).uuid),this.thickness!==void 0&&(n.thickness=this.thickness),this.thicknessMap&&this.thicknessMap.isTexture&&(n.thicknessMap=this.thicknessMap.toJSON(t).uuid),this.attenuationDistance!==void 0&&this.attenuationDistance!==1/0&&(n.attenuationDistance=this.attenuationDistance),this.attenuationColor!==void 0&&(n.attenuationColor=this.attenuationColor.getHex()),this.size!==void 0&&(n.size=this.size),this.shadowSide!==null&&(n.shadowSide=this.shadowSide),this.sizeAttenuation!==void 0&&(n.sizeAttenuation=this.sizeAttenuation),this.blending!==_i&&(n.blending=this.blending),this.side!==wn&&(n.side=this.side),this.vertexColors===!0&&(n.vertexColors=!0),this.opacity<1&&(n.opacity=this.opacity),this.transparent===!0&&(n.transparent=!0),this.blendSrc!==Os&&(n.blendSrc=this.blendSrc),this.blendDst!==Fs&&(n.blendDst=this.blendDst),this.blendEquation!==On&&(n.blendEquation=this.blendEquation),this.blendSrcAlpha!==null&&(n.blendSrcAlpha=this.blendSrcAlpha),this.blendDstAlpha!==null&&(n.blendDstAlpha=this.blendDstAlpha),this.blendEquationAlpha!==null&&(n.blendEquationAlpha=this.blendEquationAlpha),this.blendColor&&this.blendColor.isColor&&(n.blendColor=this.blendColor.getHex()),this.blendAlpha!==0&&(n.blendAlpha=this.blendAlpha),this.depthFunc!==Lr&&(n.depthFunc=this.depthFunc),this.depthTest===!1&&(n.depthTest=this.depthTest),this.depthWrite===!1&&(n.depthWrite=this.depthWrite),this.colorWrite===!1&&(n.colorWrite=this.colorWrite),this.stencilWriteMask!==255&&(n.stencilWriteMask=this.stencilWriteMask),this.stencilFunc!==Zo&&(n.stencilFunc=this.stencilFunc),this.stencilRef!==0&&(n.stencilRef=this.stencilRef),this.stencilFuncMask!==255&&(n.stencilFuncMask=this.stencilFuncMask),this.stencilFail!==Yn&&(n.stencilFail=this.stencilFail),this.stencilZFail!==Yn&&(n.stencilZFail=this.stencilZFail),this.stencilZPass!==Yn&&(n.stencilZPass=this.stencilZPass),this.stencilWrite===!0&&(n.stencilWrite=this.stencilWrite),this.rotation!==void 0&&this.rotation!==0&&(n.rotation=this.rotation),this.polygonOffset===!0&&(n.polygonOffset=!0),this.polygonOffsetFactor!==0&&(n.polygonOffsetFactor=this.polygonOffsetFactor),this.polygonOffsetUnits!==0&&(n.polygonOffsetUnits=this.polygonOffsetUnits),this.linewidth!==void 0&&this.linewidth!==1&&(n.linewidth=this.linewidth),this.dashSize!==void 0&&(n.dashSize=this.dashSize),this.gapSize!==void 0&&(n.gapSize=this.gapSize),this.scale!==void 0&&(n.scale=this.scale),this.dithering===!0&&(n.dithering=!0),this.alphaTest>0&&(n.alphaTest=this.alphaTest),this.alphaHash===!0&&(n.alphaHash=!0),this.alphaToCoverage===!0&&(n.alphaToCoverage=!0),this.premultipliedAlpha===!0&&(n.premultipliedAlpha=!0),this.forceSinglePass===!0&&(n.forceSinglePass=!0),this.wireframe===!0&&(n.wireframe=!0),this.wireframeLinewidth>1&&(n.wireframeLinewidth=this.wireframeLinewidth),this.wireframeLinecap!=="round"&&(n.wireframeLinecap=this.wireframeLinecap),this.wireframeLinejoin!=="round"&&(n.wireframeLinejoin=this.wireframeLinejoin),this.flatShading===!0&&(n.flatShading=!0),this.visible===!1&&(n.visible=!1),this.toneMapped===!1&&(n.toneMapped=!1),this.fog===!1&&(n.fog=!1),Object.keys(this.userData).length>0&&(n.userData=this.userData);function r(s){const o=[];for(const a in s){const l=s[a];delete l.metadata,o.push(l)}return o}if(e){const s=r(t.textures),o=r(t.images);s.length>0&&(n.textures=s),o.length>0&&(n.images=o)}return n}clone(){return new this.constructor().copy(this)}copy(t){this.name=t.name,this.blending=t.blending,this.side=t.side,this.vertexColors=t.vertexColors,this.opacity=t.opacity,this.transparent=t.transparent,this.blendSrc=t.blendSrc,this.blendDst=t.blendDst,this.blendEquation=t.blendEquation,this.blendSrcAlpha=t.blendSrcAlpha,this.blendDstAlpha=t.blendDstAlpha,this.blendEquationAlpha=t.blendEquationAlpha,this.blendColor.copy(t.blendColor),this.blendAlpha=t.blendAlpha,this.depthFunc=t.depthFunc,this.depthTest=t.depthTest,this.depthWrite=t.depthWrite,this.stencilWriteMask=t.stencilWriteMask,this.stencilFunc=t.stencilFunc,this.stencilRef=t.stencilRef,this.stencilFuncMask=t.stencilFuncMask,this.stencilFail=t.stencilFail,this.stencilZFail=t.stencilZFail,this.stencilZPass=t.stencilZPass,this.stencilWrite=t.stencilWrite;const e=t.clippingPlanes;let n=null;if(e!==null){const r=e.length;n=new Array(r);for(let s=0;s!==r;++s)n[s]=e[s].clone()}return this.clippingPlanes=n,this.clipIntersection=t.clipIntersection,this.clipShadows=t.clipShadows,this.shadowSide=t.shadowSide,this.colorWrite=t.colorWrite,this.precision=t.precision,this.polygonOffset=t.polygonOffset,this.polygonOffsetFactor=t.polygonOffsetFactor,this.polygonOffsetUnits=t.polygonOffsetUnits,this.dithering=t.dithering,this.alphaTest=t.alphaTest,this.alphaHash=t.alphaHash,this.alphaToCoverage=t.alphaToCoverage,this.premultipliedAlpha=t.premultipliedAlpha,this.forceSinglePass=t.forceSinglePass,this.visible=t.visible,this.toneMapped=t.toneMapped,this.userData=JSON.parse(JSON.stringify(t.userData)),this}dispose(){this.dispatchEvent({type:"dispose"})}set needsUpdate(t){t===!0&&this.version++}}class De extends Rn{constructor(t){super(),this.isMeshBasicMaterial=!0,this.type="MeshBasicMaterial",this.color=new Dt(16777215),this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.specularMap=null,this.alphaMap=null,this.envMap=null,this.combine=ul,this.reflectivity=1,this.refractionRatio=.98,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.color.copy(t.color),this.map=t.map,this.lightMap=t.lightMap,this.lightMapIntensity=t.lightMapIntensity,this.aoMap=t.aoMap,this.aoMapIntensity=t.aoMapIntensity,this.specularMap=t.specularMap,this.alphaMap=t.alphaMap,this.envMap=t.envMap,this.combine=t.combine,this.reflectivity=t.reflectivity,this.refractionRatio=t.refractionRatio,this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this.wireframeLinecap=t.wireframeLinecap,this.wireframeLinejoin=t.wireframeLinejoin,this.fog=t.fog,this}}const pe=new W,cr=new wt;class fe{constructor(t,e,n=!1){if(Array.isArray(t))throw new TypeError("THREE.BufferAttribute: array should be a Typed Array.");this.isBufferAttribute=!0,this.name="",this.array=t,this.itemSize=e,this.count=t!==void 0?t.length/e:0,this.normalized=n,this.usage=ks,this._updateRange={offset:0,count:-1},this.updateRanges=[],this.gpuType=bn,this.version=0}onUploadCallback(){}set needsUpdate(t){t===!0&&this.version++}get updateRange(){return console.warn("THREE.BufferAttribute: updateRange() is deprecated and will be removed in r169. Use addUpdateRange() instead."),this._updateRange}setUsage(t){return this.usage=t,this}addUpdateRange(t,e){this.updateRanges.push({start:t,count:e})}clearUpdateRanges(){this.updateRanges.length=0}copy(t){return this.name=t.name,this.array=new t.array.constructor(t.array),this.itemSize=t.itemSize,this.count=t.count,this.normalized=t.normalized,this.usage=t.usage,this.gpuType=t.gpuType,this}copyAt(t,e,n){t*=this.itemSize,n*=e.itemSize;for(let r=0,s=this.itemSize;r<s;r++)this.array[t+r]=e.array[n+r];return this}copyArray(t){return this.array.set(t),this}applyMatrix3(t){if(this.itemSize===2)for(let e=0,n=this.count;e<n;e++)cr.fromBufferAttribute(this,e),cr.applyMatrix3(t),this.setXY(e,cr.x,cr.y);else if(this.itemSize===3)for(let e=0,n=this.count;e<n;e++)pe.fromBufferAttribute(this,e),pe.applyMatrix3(t),this.setXYZ(e,pe.x,pe.y,pe.z);return this}applyMatrix4(t){for(let e=0,n=this.count;e<n;e++)pe.fromBufferAttribute(this,e),pe.applyMatrix4(t),this.setXYZ(e,pe.x,pe.y,pe.z);return this}applyNormalMatrix(t){for(let e=0,n=this.count;e<n;e++)pe.fromBufferAttribute(this,e),pe.applyNormalMatrix(t),this.setXYZ(e,pe.x,pe.y,pe.z);return this}transformDirection(t){for(let e=0,n=this.count;e<n;e++)pe.fromBufferAttribute(this,e),pe.transformDirection(t),this.setXYZ(e,pe.x,pe.y,pe.z);return this}set(t,e=0){return this.array.set(t,e),this}getComponent(t,e){let n=this.array[t*this.itemSize+e];return this.normalized&&(n=tn(n,this.array)),n}setComponent(t,e,n){return this.normalized&&(n=ee(n,this.array)),this.array[t*this.itemSize+e]=n,this}getX(t){let e=this.array[t*this.itemSize];return this.normalized&&(e=tn(e,this.array)),e}setX(t,e){return this.normalized&&(e=ee(e,this.array)),this.array[t*this.itemSize]=e,this}getY(t){let e=this.array[t*this.itemSize+1];return this.normalized&&(e=tn(e,this.array)),e}setY(t,e){return this.normalized&&(e=ee(e,this.array)),this.array[t*this.itemSize+1]=e,this}getZ(t){let e=this.array[t*this.itemSize+2];return this.normalized&&(e=tn(e,this.array)),e}setZ(t,e){return this.normalized&&(e=ee(e,this.array)),this.array[t*this.itemSize+2]=e,this}getW(t){let e=this.array[t*this.itemSize+3];return this.normalized&&(e=tn(e,this.array)),e}setW(t,e){return this.normalized&&(e=ee(e,this.array)),this.array[t*this.itemSize+3]=e,this}setXY(t,e,n){return t*=this.itemSize,this.normalized&&(e=ee(e,this.array),n=ee(n,this.array)),this.array[t+0]=e,this.array[t+1]=n,this}setXYZ(t,e,n,r){return t*=this.itemSize,this.normalized&&(e=ee(e,this.array),n=ee(n,this.array),r=ee(r,this.array)),this.array[t+0]=e,this.array[t+1]=n,this.array[t+2]=r,this}setXYZW(t,e,n,r,s){return t*=this.itemSize,this.normalized&&(e=ee(e,this.array),n=ee(n,this.array),r=ee(r,this.array),s=ee(s,this.array)),this.array[t+0]=e,this.array[t+1]=n,this.array[t+2]=r,this.array[t+3]=s,this}onUpload(t){return this.onUploadCallback=t,this}clone(){return new this.constructor(this.array,this.itemSize).copy(this)}toJSON(){const t={itemSize:this.itemSize,type:this.array.constructor.name,array:Array.from(this.array),normalized:this.normalized};return this.name!==""&&(t.name=this.name),this.usage!==ks&&(t.usage=this.usage),t}}class Dl extends fe{constructor(t,e,n){super(new Uint16Array(t),e,n)}}class Il extends fe{constructor(t,e,n){super(new Uint32Array(t),e,n)}}class Nt extends fe{constructor(t,e,n){super(new Float32Array(t),e,n)}}let Pu=0;const Ge=new ie,_s=new ue,ni=new W,Ne=new Hn,Di=new Hn,ve=new W;class Jt extends kn{constructor(){super(),this.isBufferGeometry=!0,Object.defineProperty(this,"id",{value:Pu++}),this.uuid=fn(),this.name="",this.type="BufferGeometry",this.index=null,this.attributes={},this.morphAttributes={},this.morphTargetsRelative=!1,this.groups=[],this.boundingBox=null,this.boundingSphere=null,this.drawRange={start:0,count:1/0},this.userData={}}getIndex(){return this.index}setIndex(t){return Array.isArray(t)?this.index=new(Al(t)?Il:Dl)(t,1):this.index=t,this}getAttribute(t){return this.attributes[t]}setAttribute(t,e){return this.attributes[t]=e,this}deleteAttribute(t){return delete this.attributes[t],this}hasAttribute(t){return this.attributes[t]!==void 0}addGroup(t,e,n=0){this.groups.push({start:t,count:e,materialIndex:n})}clearGroups(){this.groups=[]}setDrawRange(t,e){this.drawRange.start=t,this.drawRange.count=e}applyMatrix4(t){const e=this.attributes.position;e!==void 0&&(e.applyMatrix4(t),e.needsUpdate=!0);const n=this.attributes.normal;if(n!==void 0){const s=new Kt().getNormalMatrix(t);n.applyNormalMatrix(s),n.needsUpdate=!0}const r=this.attributes.tangent;return r!==void 0&&(r.transformDirection(t),r.needsUpdate=!0),this.boundingBox!==null&&this.computeBoundingBox(),this.boundingSphere!==null&&this.computeBoundingSphere(),this}applyQuaternion(t){return Ge.makeRotationFromQuaternion(t),this.applyMatrix4(Ge),this}rotateX(t){return Ge.makeRotationX(t),this.applyMatrix4(Ge),this}rotateY(t){return Ge.makeRotationY(t),this.applyMatrix4(Ge),this}rotateZ(t){return Ge.makeRotationZ(t),this.applyMatrix4(Ge),this}translate(t,e,n){return Ge.makeTranslation(t,e,n),this.applyMatrix4(Ge),this}scale(t,e,n){return Ge.makeScale(t,e,n),this.applyMatrix4(Ge),this}lookAt(t){return _s.lookAt(t),_s.updateMatrix(),this.applyMatrix4(_s.matrix),this}center(){return this.computeBoundingBox(),this.boundingBox.getCenter(ni).negate(),this.translate(ni.x,ni.y,ni.z),this}setFromPoints(t){const e=[];for(let n=0,r=t.length;n<r;n++){const s=t[n];e.push(s.x,s.y,s.z||0)}return this.setAttribute("position",new Nt(e,3)),this}computeBoundingBox(){this.boundingBox===null&&(this.boundingBox=new Hn);const t=this.attributes.position,e=this.morphAttributes.position;if(t&&t.isGLBufferAttribute){console.error('THREE.BufferGeometry.computeBoundingBox(): GLBufferAttribute requires a manual bounding box. Alternatively set "mesh.frustumCulled" to "false".',this),this.boundingBox.set(new W(-1/0,-1/0,-1/0),new W(1/0,1/0,1/0));return}if(t!==void 0){if(this.boundingBox.setFromBufferAttribute(t),e)for(let n=0,r=e.length;n<r;n++){const s=e[n];Ne.setFromBufferAttribute(s),this.morphTargetsRelative?(ve.addVectors(this.boundingBox.min,Ne.min),this.boundingBox.expandByPoint(ve),ve.addVectors(this.boundingBox.max,Ne.max),this.boundingBox.expandByPoint(ve)):(this.boundingBox.expandByPoint(Ne.min),this.boundingBox.expandByPoint(Ne.max))}}else this.boundingBox.makeEmpty();(isNaN(this.boundingBox.min.x)||isNaN(this.boundingBox.min.y)||isNaN(this.boundingBox.min.z))&&console.error('THREE.BufferGeometry.computeBoundingBox(): Computed min/max have NaN values. The "position" attribute is likely to have NaN values.',this)}computeBoundingSphere(){this.boundingSphere===null&&(this.boundingSphere=new Vn);const t=this.attributes.position,e=this.morphAttributes.position;if(t&&t.isGLBufferAttribute){console.error('THREE.BufferGeometry.computeBoundingSphere(): GLBufferAttribute requires a manual bounding sphere. Alternatively set "mesh.frustumCulled" to "false".',this),this.boundingSphere.set(new W,1/0);return}if(t){const n=this.boundingSphere.center;if(Ne.setFromBufferAttribute(t),e)for(let s=0,o=e.length;s<o;s++){const a=e[s];Di.setFromBufferAttribute(a),this.morphTargetsRelative?(ve.addVectors(Ne.min,Di.min),Ne.expandByPoint(ve),ve.addVectors(Ne.max,Di.max),Ne.expandByPoint(ve)):(Ne.expandByPoint(Di.min),Ne.expandByPoint(Di.max))}Ne.getCenter(n);let r=0;for(let s=0,o=t.count;s<o;s++)ve.fromBufferAttribute(t,s),r=Math.max(r,n.distanceToSquared(ve));if(e)for(let s=0,o=e.length;s<o;s++){const a=e[s],l=this.morphTargetsRelative;for(let c=0,u=a.count;c<u;c++)ve.fromBufferAttribute(a,c),l&&(ni.fromBufferAttribute(t,c),ve.add(ni)),r=Math.max(r,n.distanceToSquared(ve))}this.boundingSphere.radius=Math.sqrt(r),isNaN(this.boundingSphere.radius)&&console.error('THREE.BufferGeometry.computeBoundingSphere(): Computed radius is NaN. The "position" attribute is likely to have NaN values.',this)}}computeTangents(){const t=this.index,e=this.attributes;if(t===null||e.position===void 0||e.normal===void 0||e.uv===void 0){console.error("THREE.BufferGeometry: .computeTangents() failed. Missing required attributes (index, position, normal or uv)");return}const n=t.array,r=e.position.array,s=e.normal.array,o=e.uv.array,a=r.length/3;this.hasAttribute("tangent")===!1&&this.setAttribute("tangent",new fe(new Float32Array(4*a),4));const l=this.getAttribute("tangent").array,c=[],u=[];for(let A=0;A<a;A++)c[A]=new W,u[A]=new W;const f=new W,m=new W,p=new W,v=new wt,x=new wt,d=new wt,h=new W,y=new W;function _(A,K,O){f.fromArray(r,A*3),m.fromArray(r,K*3),p.fromArray(r,O*3),v.fromArray(o,A*2),x.fromArray(o,K*2),d.fromArray(o,O*2),m.sub(f),p.sub(f),x.sub(v),d.sub(v);const z=1/(x.x*d.y-d.x*x.y);isFinite(z)&&(h.copy(m).multiplyScalar(d.y).addScaledVector(p,-x.y).multiplyScalar(z),y.copy(p).multiplyScalar(x.x).addScaledVector(m,-d.x).multiplyScalar(z),c[A].add(h),c[K].add(h),c[O].add(h),u[A].add(y),u[K].add(y),u[O].add(y))}let w=this.groups;w.length===0&&(w=[{start:0,count:n.length}]);for(let A=0,K=w.length;A<K;++A){const O=w[A],z=O.start,S=O.count;for(let E=z,g=z+S;E<g;E+=3)_(n[E+0],n[E+1],n[E+2])}const D=new W,P=new W,I=new W,F=new W;function M(A){I.fromArray(s,A*3),F.copy(I);const K=c[A];D.copy(K),D.sub(I.multiplyScalar(I.dot(K))).normalize(),P.crossVectors(F,K);const z=P.dot(u[A])<0?-1:1;l[A*4]=D.x,l[A*4+1]=D.y,l[A*4+2]=D.z,l[A*4+3]=z}for(let A=0,K=w.length;A<K;++A){const O=w[A],z=O.start,S=O.count;for(let E=z,g=z+S;E<g;E+=3)M(n[E+0]),M(n[E+1]),M(n[E+2])}}computeVertexNormals(){const t=this.index,e=this.getAttribute("position");if(e!==void 0){let n=this.getAttribute("normal");if(n===void 0)n=new fe(new Float32Array(e.count*3),3),this.setAttribute("normal",n);else for(let m=0,p=n.count;m<p;m++)n.setXYZ(m,0,0,0);const r=new W,s=new W,o=new W,a=new W,l=new W,c=new W,u=new W,f=new W;if(t)for(let m=0,p=t.count;m<p;m+=3){const v=t.getX(m+0),x=t.getX(m+1),d=t.getX(m+2);r.fromBufferAttribute(e,v),s.fromBufferAttribute(e,x),o.fromBufferAttribute(e,d),u.subVectors(o,s),f.subVectors(r,s),u.cross(f),a.fromBufferAttribute(n,v),l.fromBufferAttribute(n,x),c.fromBufferAttribute(n,d),a.add(u),l.add(u),c.add(u),n.setXYZ(v,a.x,a.y,a.z),n.setXYZ(x,l.x,l.y,l.z),n.setXYZ(d,c.x,c.y,c.z)}else for(let m=0,p=e.count;m<p;m+=3)r.fromBufferAttribute(e,m+0),s.fromBufferAttribute(e,m+1),o.fromBufferAttribute(e,m+2),u.subVectors(o,s),f.subVectors(r,s),u.cross(f),n.setXYZ(m+0,u.x,u.y,u.z),n.setXYZ(m+1,u.x,u.y,u.z),n.setXYZ(m+2,u.x,u.y,u.z);this.normalizeNormals(),n.needsUpdate=!0}}normalizeNormals(){const t=this.attributes.normal;for(let e=0,n=t.count;e<n;e++)ve.fromBufferAttribute(t,e),ve.normalize(),t.setXYZ(e,ve.x,ve.y,ve.z)}toNonIndexed(){function t(a,l){const c=a.array,u=a.itemSize,f=a.normalized,m=new c.constructor(l.length*u);let p=0,v=0;for(let x=0,d=l.length;x<d;x++){a.isInterleavedBufferAttribute?p=l[x]*a.data.stride+a.offset:p=l[x]*u;for(let h=0;h<u;h++)m[v++]=c[p++]}return new fe(m,u,f)}if(this.index===null)return console.warn("THREE.BufferGeometry.toNonIndexed(): BufferGeometry is already non-indexed."),this;const e=new Jt,n=this.index.array,r=this.attributes;for(const a in r){const l=r[a],c=t(l,n);e.setAttribute(a,c)}const s=this.morphAttributes;for(const a in s){const l=[],c=s[a];for(let u=0,f=c.length;u<f;u++){const m=c[u],p=t(m,n);l.push(p)}e.morphAttributes[a]=l}e.morphTargetsRelative=this.morphTargetsRelative;const o=this.groups;for(let a=0,l=o.length;a<l;a++){const c=o[a];e.addGroup(c.start,c.count,c.materialIndex)}return e}toJSON(){const t={metadata:{version:4.6,type:"BufferGeometry",generator:"BufferGeometry.toJSON"}};if(t.uuid=this.uuid,t.type=this.type,this.name!==""&&(t.name=this.name),Object.keys(this.userData).length>0&&(t.userData=this.userData),this.parameters!==void 0){const l=this.parameters;for(const c in l)l[c]!==void 0&&(t[c]=l[c]);return t}t.data={attributes:{}};const e=this.index;e!==null&&(t.data.index={type:e.array.constructor.name,array:Array.prototype.slice.call(e.array)});const n=this.attributes;for(const l in n){const c=n[l];t.data.attributes[l]=c.toJSON(t.data)}const r={};let s=!1;for(const l in this.morphAttributes){const c=this.morphAttributes[l],u=[];for(let f=0,m=c.length;f<m;f++){const p=c[f];u.push(p.toJSON(t.data))}u.length>0&&(r[l]=u,s=!0)}s&&(t.data.morphAttributes=r,t.data.morphTargetsRelative=this.morphTargetsRelative);const o=this.groups;o.length>0&&(t.data.groups=JSON.parse(JSON.stringify(o)));const a=this.boundingSphere;return a!==null&&(t.data.boundingSphere={center:a.center.toArray(),radius:a.radius}),t}clone(){return new this.constructor().copy(this)}copy(t){this.index=null,this.attributes={},this.morphAttributes={},this.groups=[],this.boundingBox=null,this.boundingSphere=null;const e={};this.name=t.name;const n=t.index;n!==null&&this.setIndex(n.clone(e));const r=t.attributes;for(const c in r){const u=r[c];this.setAttribute(c,u.clone(e))}const s=t.morphAttributes;for(const c in s){const u=[],f=s[c];for(let m=0,p=f.length;m<p;m++)u.push(f[m].clone(e));this.morphAttributes[c]=u}this.morphTargetsRelative=t.morphTargetsRelative;const o=t.groups;for(let c=0,u=o.length;c<u;c++){const f=o[c];this.addGroup(f.start,f.count,f.materialIndex)}const a=t.boundingBox;a!==null&&(this.boundingBox=a.clone());const l=t.boundingSphere;return l!==null&&(this.boundingSphere=l.clone()),this.drawRange.start=t.drawRange.start,this.drawRange.count=t.drawRange.count,this.userData=t.userData,this}dispose(){this.dispatchEvent({type:"dispose"})}}const ha=new ie,In=new $i,ur=new Vn,da=new W,ii=new W,ri=new W,si=new W,vs=new W,hr=new W,dr=new wt,fr=new wt,pr=new wt,fa=new W,pa=new W,ma=new W,mr=new W,gr=new W;class Ft extends ue{constructor(t=new Jt,e=new De){super(),this.isMesh=!0,this.type="Mesh",this.geometry=t,this.material=e,this.updateMorphTargets()}copy(t,e){return super.copy(t,e),t.morphTargetInfluences!==void 0&&(this.morphTargetInfluences=t.morphTargetInfluences.slice()),t.morphTargetDictionary!==void 0&&(this.morphTargetDictionary=Object.assign({},t.morphTargetDictionary)),this.material=Array.isArray(t.material)?t.material.slice():t.material,this.geometry=t.geometry,this}updateMorphTargets(){const e=this.geometry.morphAttributes,n=Object.keys(e);if(n.length>0){const r=e[n[0]];if(r!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let s=0,o=r.length;s<o;s++){const a=r[s].name||String(s);this.morphTargetInfluences.push(0),this.morphTargetDictionary[a]=s}}}}getVertexPosition(t,e){const n=this.geometry,r=n.attributes.position,s=n.morphAttributes.position,o=n.morphTargetsRelative;e.fromBufferAttribute(r,t);const a=this.morphTargetInfluences;if(s&&a){hr.set(0,0,0);for(let l=0,c=s.length;l<c;l++){const u=a[l],f=s[l];u!==0&&(vs.fromBufferAttribute(f,t),o?hr.addScaledVector(vs,u):hr.addScaledVector(vs.sub(e),u))}e.add(hr)}return e}raycast(t,e){const n=this.geometry,r=this.material,s=this.matrixWorld;r!==void 0&&(n.boundingSphere===null&&n.computeBoundingSphere(),ur.copy(n.boundingSphere),ur.applyMatrix4(s),In.copy(t.ray).recast(t.near),!(ur.containsPoint(In.origin)===!1&&(In.intersectSphere(ur,da)===null||In.origin.distanceToSquared(da)>(t.far-t.near)**2))&&(ha.copy(s).invert(),In.copy(t.ray).applyMatrix4(ha),!(n.boundingBox!==null&&In.intersectsBox(n.boundingBox)===!1)&&this._computeIntersections(t,e,In)))}_computeIntersections(t,e,n){let r;const s=this.geometry,o=this.material,a=s.index,l=s.attributes.position,c=s.attributes.uv,u=s.attributes.uv1,f=s.attributes.normal,m=s.groups,p=s.drawRange;if(a!==null)if(Array.isArray(o))for(let v=0,x=m.length;v<x;v++){const d=m[v],h=o[d.materialIndex],y=Math.max(d.start,p.start),_=Math.min(a.count,Math.min(d.start+d.count,p.start+p.count));for(let w=y,D=_;w<D;w+=3){const P=a.getX(w),I=a.getX(w+1),F=a.getX(w+2);r=_r(this,h,t,n,c,u,f,P,I,F),r&&(r.faceIndex=Math.floor(w/3),r.face.materialIndex=d.materialIndex,e.push(r))}}else{const v=Math.max(0,p.start),x=Math.min(a.count,p.start+p.count);for(let d=v,h=x;d<h;d+=3){const y=a.getX(d),_=a.getX(d+1),w=a.getX(d+2);r=_r(this,o,t,n,c,u,f,y,_,w),r&&(r.faceIndex=Math.floor(d/3),e.push(r))}}else if(l!==void 0)if(Array.isArray(o))for(let v=0,x=m.length;v<x;v++){const d=m[v],h=o[d.materialIndex],y=Math.max(d.start,p.start),_=Math.min(l.count,Math.min(d.start+d.count,p.start+p.count));for(let w=y,D=_;w<D;w+=3){const P=w,I=w+1,F=w+2;r=_r(this,h,t,n,c,u,f,P,I,F),r&&(r.faceIndex=Math.floor(w/3),r.face.materialIndex=d.materialIndex,e.push(r))}}else{const v=Math.max(0,p.start),x=Math.min(l.count,p.start+p.count);for(let d=v,h=x;d<h;d+=3){const y=d,_=d+1,w=d+2;r=_r(this,o,t,n,c,u,f,y,_,w),r&&(r.faceIndex=Math.floor(d/3),e.push(r))}}}}function Lu(i,t,e,n,r,s,o,a){let l;if(t.side===Te?l=n.intersectTriangle(o,s,r,!0,a):l=n.intersectTriangle(r,s,o,t.side===wn,a),l===null)return null;gr.copy(a),gr.applyMatrix4(i.matrixWorld);const c=e.ray.origin.distanceTo(gr);return c<e.near||c>e.far?null:{distance:c,point:gr.clone(),object:i}}function _r(i,t,e,n,r,s,o,a,l,c){i.getVertexPosition(a,ii),i.getVertexPosition(l,ri),i.getVertexPosition(c,si);const u=Lu(i,t,e,n,ii,ri,si,mr);if(u){r&&(dr.fromBufferAttribute(r,a),fr.fromBufferAttribute(r,l),pr.fromBufferAttribute(r,c),u.uv=He.getInterpolation(mr,ii,ri,si,dr,fr,pr,new wt)),s&&(dr.fromBufferAttribute(s,a),fr.fromBufferAttribute(s,l),pr.fromBufferAttribute(s,c),u.uv1=He.getInterpolation(mr,ii,ri,si,dr,fr,pr,new wt),u.uv2=u.uv1),o&&(fa.fromBufferAttribute(o,a),pa.fromBufferAttribute(o,l),ma.fromBufferAttribute(o,c),u.normal=He.getInterpolation(mr,ii,ri,si,fa,pa,ma,new W),u.normal.dot(n.direction)>0&&u.normal.multiplyScalar(-1));const f={a,b:l,c,normal:new W,materialIndex:0};He.getNormal(ii,ri,si,f.normal),u.face=f}return u}class $e extends Jt{constructor(t=1,e=1,n=1,r=1,s=1,o=1){super(),this.type="BoxGeometry",this.parameters={width:t,height:e,depth:n,widthSegments:r,heightSegments:s,depthSegments:o};const a=this;r=Math.floor(r),s=Math.floor(s),o=Math.floor(o);const l=[],c=[],u=[],f=[];let m=0,p=0;v("z","y","x",-1,-1,n,e,t,o,s,0),v("z","y","x",1,-1,n,e,-t,o,s,1),v("x","z","y",1,1,t,n,e,r,o,2),v("x","z","y",1,-1,t,n,-e,r,o,3),v("x","y","z",1,-1,t,e,n,r,s,4),v("x","y","z",-1,-1,t,e,-n,r,s,5),this.setIndex(l),this.setAttribute("position",new Nt(c,3)),this.setAttribute("normal",new Nt(u,3)),this.setAttribute("uv",new Nt(f,2));function v(x,d,h,y,_,w,D,P,I,F,M){const A=w/I,K=D/F,O=w/2,z=D/2,S=P/2,E=I+1,g=F+1;let T=0,L=0;const N=new W;for(let C=0;C<g;C++){const U=C*K-z;for(let q=0;q<E;q++){const Z=q*A-O;N[x]=Z*y,N[d]=U*_,N[h]=S,c.push(N.x,N.y,N.z),N[x]=0,N[d]=0,N[h]=P>0?1:-1,u.push(N.x,N.y,N.z),f.push(q/I),f.push(1-C/F),T+=1}}for(let C=0;C<F;C++)for(let U=0;U<I;U++){const q=m+U+E*C,Z=m+U+E*(C+1),it=m+(U+1)+E*(C+1),ut=m+(U+1)+E*C;l.push(q,Z,ut),l.push(Z,it,ut),L+=6}a.addGroup(p,L,M),p+=L,m+=T}}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new $e(t.width,t.height,t.depth,t.widthSegments,t.heightSegments,t.depthSegments)}}function bi(i){const t={};for(const e in i){t[e]={};for(const n in i[e]){const r=i[e][n];r&&(r.isColor||r.isMatrix3||r.isMatrix4||r.isVector2||r.isVector3||r.isVector4||r.isTexture||r.isQuaternion)?r.isRenderTargetTexture?(console.warn("UniformsUtils: Textures of render targets cannot be cloned via cloneUniforms() or mergeUniforms()."),t[e][n]=null):t[e][n]=r.clone():Array.isArray(r)?t[e][n]=r.slice():t[e][n]=r}}return t}function Pe(i){const t={};for(let e=0;e<i.length;e++){const n=bi(i[e]);for(const r in n)t[r]=n[r]}return t}function Du(i){const t=[];for(let e=0;e<i.length;e++)t.push(i[e].clone());return t}function Ul(i){return i.getRenderTarget()===null?i.outputColorSpace:te.workingColorSpace}const qi={clone:bi,merge:Pe};var Iu=`void main() {
	gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}`,Uu=`void main() {
	gl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );
}`;class Ee extends Rn{constructor(t){super(),this.isShaderMaterial=!0,this.type="ShaderMaterial",this.defines={},this.uniforms={},this.uniformsGroups=[],this.vertexShader=Iu,this.fragmentShader=Uu,this.linewidth=1,this.wireframe=!1,this.wireframeLinewidth=1,this.fog=!1,this.lights=!1,this.clipping=!1,this.forceSinglePass=!0,this.extensions={derivatives:!1,fragDepth:!1,drawBuffers:!1,shaderTextureLOD:!1,clipCullDistance:!1},this.defaultAttributeValues={color:[1,1,1],uv:[0,0],uv1:[0,0]},this.index0AttributeName=void 0,this.uniformsNeedUpdate=!1,this.glslVersion=null,t!==void 0&&this.setValues(t)}copy(t){return super.copy(t),this.fragmentShader=t.fragmentShader,this.vertexShader=t.vertexShader,this.uniforms=bi(t.uniforms),this.uniformsGroups=Du(t.uniformsGroups),this.defines=Object.assign({},t.defines),this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this.fog=t.fog,this.lights=t.lights,this.clipping=t.clipping,this.extensions=Object.assign({},t.extensions),this.glslVersion=t.glslVersion,this}toJSON(t){const e=super.toJSON(t);e.glslVersion=this.glslVersion,e.uniforms={};for(const r in this.uniforms){const o=this.uniforms[r].value;o&&o.isTexture?e.uniforms[r]={type:"t",value:o.toJSON(t).uuid}:o&&o.isColor?e.uniforms[r]={type:"c",value:o.getHex()}:o&&o.isVector2?e.uniforms[r]={type:"v2",value:o.toArray()}:o&&o.isVector3?e.uniforms[r]={type:"v3",value:o.toArray()}:o&&o.isVector4?e.uniforms[r]={type:"v4",value:o.toArray()}:o&&o.isMatrix3?e.uniforms[r]={type:"m3",value:o.toArray()}:o&&o.isMatrix4?e.uniforms[r]={type:"m4",value:o.toArray()}:e.uniforms[r]={value:o}}Object.keys(this.defines).length>0&&(e.defines=this.defines),e.vertexShader=this.vertexShader,e.fragmentShader=this.fragmentShader,e.lights=this.lights,e.clipping=this.clipping;const n={};for(const r in this.extensions)this.extensions[r]===!0&&(n[r]=!0);return Object.keys(n).length>0&&(e.extensions=n),e}}class Nl extends ue{constructor(){super(),this.isCamera=!0,this.type="Camera",this.matrixWorldInverse=new ie,this.projectionMatrix=new ie,this.projectionMatrixInverse=new ie,this.coordinateSystem=un}copy(t,e){return super.copy(t,e),this.matrixWorldInverse.copy(t.matrixWorldInverse),this.projectionMatrix.copy(t.projectionMatrix),this.projectionMatrixInverse.copy(t.projectionMatrixInverse),this.coordinateSystem=t.coordinateSystem,this}getWorldDirection(t){return super.getWorldDirection(t).negate()}updateMatrixWorld(t){super.updateMatrixWorld(t),this.matrixWorldInverse.copy(this.matrixWorld).invert()}updateWorldMatrix(t,e){super.updateWorldMatrix(t,e),this.matrixWorldInverse.copy(this.matrixWorld).invert()}clone(){return new this.constructor().copy(this)}}class Oe extends Nl{constructor(t=50,e=1,n=.1,r=2e3){super(),this.isPerspectiveCamera=!0,this.type="PerspectiveCamera",this.fov=t,this.zoom=1,this.near=n,this.far=r,this.focus=10,this.aspect=e,this.view=null,this.filmGauge=35,this.filmOffset=0,this.updateProjectionMatrix()}copy(t,e){return super.copy(t,e),this.fov=t.fov,this.zoom=t.zoom,this.near=t.near,this.far=t.far,this.focus=t.focus,this.aspect=t.aspect,this.view=t.view===null?null:Object.assign({},t.view),this.filmGauge=t.filmGauge,this.filmOffset=t.filmOffset,this}setFocalLength(t){const e=.5*this.getFilmHeight()/t;this.fov=Xi*2*Math.atan(e),this.updateProjectionMatrix()}getFocalLength(){const t=Math.tan(zi*.5*this.fov);return .5*this.getFilmHeight()/t}getEffectiveFOV(){return Xi*2*Math.atan(Math.tan(zi*.5*this.fov)/this.zoom)}getFilmWidth(){return this.filmGauge*Math.min(this.aspect,1)}getFilmHeight(){return this.filmGauge/Math.max(this.aspect,1)}setViewOffset(t,e,n,r,s,o){this.aspect=t/e,this.view===null&&(this.view={enabled:!0,fullWidth:1,fullHeight:1,offsetX:0,offsetY:0,width:1,height:1}),this.view.enabled=!0,this.view.fullWidth=t,this.view.fullHeight=e,this.view.offsetX=n,this.view.offsetY=r,this.view.width=s,this.view.height=o,this.updateProjectionMatrix()}clearViewOffset(){this.view!==null&&(this.view.enabled=!1),this.updateProjectionMatrix()}updateProjectionMatrix(){const t=this.near;let e=t*Math.tan(zi*.5*this.fov)/this.zoom,n=2*e,r=this.aspect*n,s=-.5*r;const o=this.view;if(this.view!==null&&this.view.enabled){const l=o.fullWidth,c=o.fullHeight;s+=o.offsetX*r/l,e-=o.offsetY*n/c,r*=o.width/l,n*=o.height/c}const a=this.filmOffset;a!==0&&(s+=t*a/this.getFilmWidth()),this.projectionMatrix.makePerspective(s,s+r,e,e-n,t,this.far,this.coordinateSystem),this.projectionMatrixInverse.copy(this.projectionMatrix).invert()}toJSON(t){const e=super.toJSON(t);return e.object.fov=this.fov,e.object.zoom=this.zoom,e.object.near=this.near,e.object.far=this.far,e.object.focus=this.focus,e.object.aspect=this.aspect,this.view!==null&&(e.object.view=Object.assign({},this.view)),e.object.filmGauge=this.filmGauge,e.object.filmOffset=this.filmOffset,e}}const oi=-90,ai=1;class Nu extends ue{constructor(t,e,n){super(),this.type="CubeCamera",this.renderTarget=n,this.coordinateSystem=null,this.activeMipmapLevel=0;const r=new Oe(oi,ai,t,e);r.layers=this.layers,this.add(r);const s=new Oe(oi,ai,t,e);s.layers=this.layers,this.add(s);const o=new Oe(oi,ai,t,e);o.layers=this.layers,this.add(o);const a=new Oe(oi,ai,t,e);a.layers=this.layers,this.add(a);const l=new Oe(oi,ai,t,e);l.layers=this.layers,this.add(l);const c=new Oe(oi,ai,t,e);c.layers=this.layers,this.add(c)}updateCoordinateSystem(){const t=this.coordinateSystem,e=this.children.concat(),[n,r,s,o,a,l]=e;for(const c of e)this.remove(c);if(t===un)n.up.set(0,1,0),n.lookAt(1,0,0),r.up.set(0,1,0),r.lookAt(-1,0,0),s.up.set(0,0,-1),s.lookAt(0,1,0),o.up.set(0,0,1),o.lookAt(0,-1,0),a.up.set(0,1,0),a.lookAt(0,0,1),l.up.set(0,1,0),l.lookAt(0,0,-1);else if(t===Nr)n.up.set(0,-1,0),n.lookAt(-1,0,0),r.up.set(0,-1,0),r.lookAt(1,0,0),s.up.set(0,0,1),s.lookAt(0,1,0),o.up.set(0,0,-1),o.lookAt(0,-1,0),a.up.set(0,-1,0),a.lookAt(0,0,1),l.up.set(0,-1,0),l.lookAt(0,0,-1);else throw new Error("THREE.CubeCamera.updateCoordinateSystem(): Invalid coordinate system: "+t);for(const c of e)this.add(c),c.updateMatrixWorld()}update(t,e){this.parent===null&&this.updateMatrixWorld();const{renderTarget:n,activeMipmapLevel:r}=this;this.coordinateSystem!==t.coordinateSystem&&(this.coordinateSystem=t.coordinateSystem,this.updateCoordinateSystem());const[s,o,a,l,c,u]=this.children,f=t.getRenderTarget(),m=t.getActiveCubeFace(),p=t.getActiveMipmapLevel(),v=t.xr.enabled;t.xr.enabled=!1;const x=n.texture.generateMipmaps;n.texture.generateMipmaps=!1,t.setRenderTarget(n,0,r),t.render(e,s),t.setRenderTarget(n,1,r),t.render(e,o),t.setRenderTarget(n,2,r),t.render(e,a),t.setRenderTarget(n,3,r),t.render(e,l),t.setRenderTarget(n,4,r),t.render(e,c),n.texture.generateMipmaps=x,t.setRenderTarget(n,5,r),t.render(e,u),t.setRenderTarget(f,m,p),t.xr.enabled=v,n.texture.needsPMREMUpdate=!0}}class Ol extends we{constructor(t,e,n,r,s,o,a,l,c,u){t=t!==void 0?t:[],e=e!==void 0?e:xi,super(t,e,n,r,s,o,a,l,c,u),this.isCubeTexture=!0,this.flipY=!1}get images(){return this.image}set images(t){this.image=t}}class Ou extends Ke{constructor(t=1,e={}){super(t,t,e),this.isWebGLCubeRenderTarget=!0;const n={width:t,height:t,depth:1},r=[n,n,n,n,n,n];e.encoding!==void 0&&(ki("THREE.WebGLCubeRenderTarget: option.encoding has been replaced by option.colorSpace."),e.colorSpace=e.encoding===Gn?ce:We),this.texture=new Ol(r,e.mapping,e.wrapS,e.wrapT,e.magFilter,e.minFilter,e.format,e.type,e.anisotropy,e.colorSpace),this.texture.isRenderTargetTexture=!0,this.texture.generateMipmaps=e.generateMipmaps!==void 0?e.generateMipmaps:!1,this.texture.minFilter=e.minFilter!==void 0?e.minFilter:ke}fromEquirectangularTexture(t,e){this.texture.type=e.type,this.texture.colorSpace=e.colorSpace,this.texture.generateMipmaps=e.generateMipmaps,this.texture.minFilter=e.minFilter,this.texture.magFilter=e.magFilter;const n={uniforms:{tEquirect:{value:null}},vertexShader:`

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
			`},r=new $e(5,5,5),s=new Ee({name:"CubemapFromEquirect",uniforms:bi(n.uniforms),vertexShader:n.vertexShader,fragmentShader:n.fragmentShader,side:Te,blending:hn});s.uniforms.tEquirect.value=e;const o=new Ft(r,s),a=e.minFilter;return e.minFilter===Wi&&(e.minFilter=ke),new Nu(1,10,this).update(t,o),e.minFilter=a,o.geometry.dispose(),o.material.dispose(),this}clear(t,e,n,r){const s=t.getRenderTarget();for(let o=0;o<6;o++)t.setRenderTarget(this,o),t.clear(e,n,r);t.setRenderTarget(s)}}const xs=new W,Fu=new W,Bu=new Kt;class yn{constructor(t=new W(1,0,0),e=0){this.isPlane=!0,this.normal=t,this.constant=e}set(t,e){return this.normal.copy(t),this.constant=e,this}setComponents(t,e,n,r){return this.normal.set(t,e,n),this.constant=r,this}setFromNormalAndCoplanarPoint(t,e){return this.normal.copy(t),this.constant=-e.dot(this.normal),this}setFromCoplanarPoints(t,e,n){const r=xs.subVectors(n,e).cross(Fu.subVectors(t,e)).normalize();return this.setFromNormalAndCoplanarPoint(r,t),this}copy(t){return this.normal.copy(t.normal),this.constant=t.constant,this}normalize(){const t=1/this.normal.length();return this.normal.multiplyScalar(t),this.constant*=t,this}negate(){return this.constant*=-1,this.normal.negate(),this}distanceToPoint(t){return this.normal.dot(t)+this.constant}distanceToSphere(t){return this.distanceToPoint(t.center)-t.radius}projectPoint(t,e){return e.copy(t).addScaledVector(this.normal,-this.distanceToPoint(t))}intersectLine(t,e){const n=t.delta(xs),r=this.normal.dot(n);if(r===0)return this.distanceToPoint(t.start)===0?e.copy(t.start):null;const s=-(t.start.dot(this.normal)+this.constant)/r;return s<0||s>1?null:e.copy(t.start).addScaledVector(n,s)}intersectsLine(t){const e=this.distanceToPoint(t.start),n=this.distanceToPoint(t.end);return e<0&&n>0||n<0&&e>0}intersectsBox(t){return t.intersectsPlane(this)}intersectsSphere(t){return t.intersectsPlane(this)}coplanarPoint(t){return t.copy(this.normal).multiplyScalar(-this.constant)}applyMatrix4(t,e){const n=e||Bu.getNormalMatrix(t),r=this.coplanarPoint(xs).applyMatrix4(t),s=this.normal.applyMatrix3(n).normalize();return this.constant=-r.dot(s),this}translate(t){return this.constant-=t.dot(this.normal),this}equals(t){return t.normal.equals(this.normal)&&t.constant===this.constant}clone(){return new this.constructor().copy(this)}}const Un=new Vn,vr=new W;class eo{constructor(t=new yn,e=new yn,n=new yn,r=new yn,s=new yn,o=new yn){this.planes=[t,e,n,r,s,o]}set(t,e,n,r,s,o){const a=this.planes;return a[0].copy(t),a[1].copy(e),a[2].copy(n),a[3].copy(r),a[4].copy(s),a[5].copy(o),this}copy(t){const e=this.planes;for(let n=0;n<6;n++)e[n].copy(t.planes[n]);return this}setFromProjectionMatrix(t,e=un){const n=this.planes,r=t.elements,s=r[0],o=r[1],a=r[2],l=r[3],c=r[4],u=r[5],f=r[6],m=r[7],p=r[8],v=r[9],x=r[10],d=r[11],h=r[12],y=r[13],_=r[14],w=r[15];if(n[0].setComponents(l-s,m-c,d-p,w-h).normalize(),n[1].setComponents(l+s,m+c,d+p,w+h).normalize(),n[2].setComponents(l+o,m+u,d+v,w+y).normalize(),n[3].setComponents(l-o,m-u,d-v,w-y).normalize(),n[4].setComponents(l-a,m-f,d-x,w-_).normalize(),e===un)n[5].setComponents(l+a,m+f,d+x,w+_).normalize();else if(e===Nr)n[5].setComponents(a,f,x,_).normalize();else throw new Error("THREE.Frustum.setFromProjectionMatrix(): Invalid coordinate system: "+e);return this}intersectsObject(t){if(t.boundingSphere!==void 0)t.boundingSphere===null&&t.computeBoundingSphere(),Un.copy(t.boundingSphere).applyMatrix4(t.matrixWorld);else{const e=t.geometry;e.boundingSphere===null&&e.computeBoundingSphere(),Un.copy(e.boundingSphere).applyMatrix4(t.matrixWorld)}return this.intersectsSphere(Un)}intersectsSprite(t){return Un.center.set(0,0,0),Un.radius=.7071067811865476,Un.applyMatrix4(t.matrixWorld),this.intersectsSphere(Un)}intersectsSphere(t){const e=this.planes,n=t.center,r=-t.radius;for(let s=0;s<6;s++)if(e[s].distanceToPoint(n)<r)return!1;return!0}intersectsBox(t){const e=this.planes;for(let n=0;n<6;n++){const r=e[n];if(vr.x=r.normal.x>0?t.max.x:t.min.x,vr.y=r.normal.y>0?t.max.y:t.min.y,vr.z=r.normal.z>0?t.max.z:t.min.z,r.distanceToPoint(vr)<0)return!1}return!0}containsPoint(t){const e=this.planes;for(let n=0;n<6;n++)if(e[n].distanceToPoint(t)<0)return!1;return!0}clone(){return new this.constructor().copy(this)}}function Fl(){let i=null,t=!1,e=null,n=null;function r(s,o){e(s,o),n=i.requestAnimationFrame(r)}return{start:function(){t!==!0&&e!==null&&(n=i.requestAnimationFrame(r),t=!0)},stop:function(){i.cancelAnimationFrame(n),t=!1},setAnimationLoop:function(s){e=s},setContext:function(s){i=s}}}function zu(i,t){const e=t.isWebGL2,n=new WeakMap;function r(c,u){const f=c.array,m=c.usage,p=f.byteLength,v=i.createBuffer();i.bindBuffer(u,v),i.bufferData(u,f,m),c.onUploadCallback();let x;if(f instanceof Float32Array)x=i.FLOAT;else if(f instanceof Uint16Array)if(c.isFloat16BufferAttribute)if(e)x=i.HALF_FLOAT;else throw new Error("THREE.WebGLAttributes: Usage of Float16BufferAttribute requires WebGL2.");else x=i.UNSIGNED_SHORT;else if(f instanceof Int16Array)x=i.SHORT;else if(f instanceof Uint32Array)x=i.UNSIGNED_INT;else if(f instanceof Int32Array)x=i.INT;else if(f instanceof Int8Array)x=i.BYTE;else if(f instanceof Uint8Array)x=i.UNSIGNED_BYTE;else if(f instanceof Uint8ClampedArray)x=i.UNSIGNED_BYTE;else throw new Error("THREE.WebGLAttributes: Unsupported buffer data format: "+f);return{buffer:v,type:x,bytesPerElement:f.BYTES_PER_ELEMENT,version:c.version,size:p}}function s(c,u,f){const m=u.array,p=u._updateRange,v=u.updateRanges;if(i.bindBuffer(f,c),p.count===-1&&v.length===0&&i.bufferSubData(f,0,m),v.length!==0){for(let x=0,d=v.length;x<d;x++){const h=v[x];e?i.bufferSubData(f,h.start*m.BYTES_PER_ELEMENT,m,h.start,h.count):i.bufferSubData(f,h.start*m.BYTES_PER_ELEMENT,m.subarray(h.start,h.start+h.count))}u.clearUpdateRanges()}p.count!==-1&&(e?i.bufferSubData(f,p.offset*m.BYTES_PER_ELEMENT,m,p.offset,p.count):i.bufferSubData(f,p.offset*m.BYTES_PER_ELEMENT,m.subarray(p.offset,p.offset+p.count)),p.count=-1),u.onUploadCallback()}function o(c){return c.isInterleavedBufferAttribute&&(c=c.data),n.get(c)}function a(c){c.isInterleavedBufferAttribute&&(c=c.data);const u=n.get(c);u&&(i.deleteBuffer(u.buffer),n.delete(c))}function l(c,u){if(c.isGLBufferAttribute){const m=n.get(c);(!m||m.version<c.version)&&n.set(c,{buffer:c.buffer,type:c.type,bytesPerElement:c.elementSize,version:c.version});return}c.isInterleavedBufferAttribute&&(c=c.data);const f=n.get(c);if(f===void 0)n.set(c,r(c,u));else if(f.version<c.version){if(f.size!==c.array.byteLength)throw new Error("THREE.WebGLAttributes: The size of the buffer attribute's array buffer does not match the original size. Resizing buffer attributes is not supported.");s(f.buffer,c,u),f.version=c.version}}return{get:o,remove:a,update:l}}class Wn extends Jt{constructor(t=1,e=1,n=1,r=1){super(),this.type="PlaneGeometry",this.parameters={width:t,height:e,widthSegments:n,heightSegments:r};const s=t/2,o=e/2,a=Math.floor(n),l=Math.floor(r),c=a+1,u=l+1,f=t/a,m=e/l,p=[],v=[],x=[],d=[];for(let h=0;h<u;h++){const y=h*m-o;for(let _=0;_<c;_++){const w=_*f-s;v.push(w,-y,0),x.push(0,0,1),d.push(_/a),d.push(1-h/l)}}for(let h=0;h<l;h++)for(let y=0;y<a;y++){const _=y+c*h,w=y+c*(h+1),D=y+1+c*(h+1),P=y+1+c*h;p.push(_,w,P),p.push(w,D,P)}this.setIndex(p),this.setAttribute("position",new Nt(v,3)),this.setAttribute("normal",new Nt(x,3)),this.setAttribute("uv",new Nt(d,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new Wn(t.width,t.height,t.widthSegments,t.heightSegments)}}var Gu=`#ifdef USE_ALPHAHASH
	if ( diffuseColor.a < getAlphaHashThreshold( vPosition ) ) discard;
#endif`,ku=`#ifdef USE_ALPHAHASH
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
#endif`,Hu=`#ifdef USE_ALPHAMAP
	diffuseColor.a *= texture2D( alphaMap, vAlphaMapUv ).g;
#endif`,Vu=`#ifdef USE_ALPHAMAP
	uniform sampler2D alphaMap;
#endif`,Wu=`#ifdef USE_ALPHATEST
	if ( diffuseColor.a < alphaTest ) discard;
#endif`,Xu=`#ifdef USE_ALPHATEST
	uniform float alphaTest;
#endif`,qu=`#ifdef USE_AOMAP
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
#endif`,Yu=`#ifdef USE_AOMAP
	uniform sampler2D aoMap;
	uniform float aoMapIntensity;
#endif`,ju=`#ifdef USE_BATCHING
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
#endif`,$u=`#ifdef USE_BATCHING
	mat4 batchingMatrix = getBatchingMatrix( batchId );
#endif`,Ku=`vec3 transformed = vec3( position );
#ifdef USE_ALPHAHASH
	vPosition = vec3( position );
#endif`,Zu=`vec3 objectNormal = vec3( normal );
#ifdef USE_TANGENT
	vec3 objectTangent = vec3( tangent.xyz );
#endif`,Ju=`float G_BlinnPhong_Implicit( ) {
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
} // validated`,Qu=`#ifdef USE_IRIDESCENCE
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
#endif`,th=`#ifdef USE_BUMPMAP
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
#endif`,eh=`#if NUM_CLIPPING_PLANES > 0
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
#endif`,nh=`#if NUM_CLIPPING_PLANES > 0
	varying vec3 vClipPosition;
	uniform vec4 clippingPlanes[ NUM_CLIPPING_PLANES ];
#endif`,ih=`#if NUM_CLIPPING_PLANES > 0
	varying vec3 vClipPosition;
#endif`,rh=`#if NUM_CLIPPING_PLANES > 0
	vClipPosition = - mvPosition.xyz;
#endif`,sh=`#if defined( USE_COLOR_ALPHA )
	diffuseColor *= vColor;
#elif defined( USE_COLOR )
	diffuseColor.rgb *= vColor;
#endif`,oh=`#if defined( USE_COLOR_ALPHA )
	varying vec4 vColor;
#elif defined( USE_COLOR )
	varying vec3 vColor;
#endif`,ah=`#if defined( USE_COLOR_ALPHA )
	varying vec4 vColor;
#elif defined( USE_COLOR ) || defined( USE_INSTANCING_COLOR )
	varying vec3 vColor;
#endif`,lh=`#if defined( USE_COLOR_ALPHA )
	vColor = vec4( 1.0 );
#elif defined( USE_COLOR ) || defined( USE_INSTANCING_COLOR )
	vColor = vec3( 1.0 );
#endif
#ifdef USE_COLOR
	vColor *= color;
#endif
#ifdef USE_INSTANCING_COLOR
	vColor.xyz *= instanceColor.xyz;
#endif`,ch=`#define PI 3.141592653589793
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
} // validated`,uh=`#ifdef ENVMAP_TYPE_CUBE_UV
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
#endif`,hh=`vec3 transformedNormal = objectNormal;
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
#endif`,dh=`#ifdef USE_DISPLACEMENTMAP
	uniform sampler2D displacementMap;
	uniform float displacementScale;
	uniform float displacementBias;
#endif`,fh=`#ifdef USE_DISPLACEMENTMAP
	transformed += normalize( objectNormal ) * ( texture2D( displacementMap, vDisplacementMapUv ).x * displacementScale + displacementBias );
#endif`,ph=`#ifdef USE_EMISSIVEMAP
	vec4 emissiveColor = texture2D( emissiveMap, vEmissiveMapUv );
	totalEmissiveRadiance *= emissiveColor.rgb;
#endif`,mh=`#ifdef USE_EMISSIVEMAP
	uniform sampler2D emissiveMap;
#endif`,gh="gl_FragColor = linearToOutputTexel( gl_FragColor );",_h=`
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
}`,vh=`#ifdef USE_ENVMAP
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
#endif`,xh=`#ifdef USE_ENVMAP
	uniform float envMapIntensity;
	uniform float flipEnvMap;
	#ifdef ENVMAP_TYPE_CUBE
		uniform samplerCube envMap;
	#else
		uniform sampler2D envMap;
	#endif
	
#endif`,Mh=`#ifdef USE_ENVMAP
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
#endif`,yh=`#ifdef USE_ENVMAP
	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( LAMBERT )
		#define ENV_WORLDPOS
	#endif
	#ifdef ENV_WORLDPOS
		
		varying vec3 vWorldPosition;
	#else
		varying vec3 vReflect;
		uniform float refractionRatio;
	#endif
#endif`,Sh=`#ifdef USE_ENVMAP
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
#endif`,bh=`#ifdef USE_FOG
	vFogDepth = - mvPosition.z;
#endif`,Eh=`#ifdef USE_FOG
	varying float vFogDepth;
#endif`,Th=`#ifdef USE_FOG
	#ifdef FOG_EXP2
		float fogFactor = 1.0 - exp( - fogDensity * fogDensity * vFogDepth * vFogDepth );
	#else
		float fogFactor = smoothstep( fogNear, fogFar, vFogDepth );
	#endif
	gl_FragColor.rgb = mix( gl_FragColor.rgb, fogColor, fogFactor );
#endif`,wh=`#ifdef USE_FOG
	uniform vec3 fogColor;
	varying float vFogDepth;
	#ifdef FOG_EXP2
		uniform float fogDensity;
	#else
		uniform float fogNear;
		uniform float fogFar;
	#endif
#endif`,Ah=`#ifdef USE_GRADIENTMAP
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
}`,Rh=`#ifdef USE_LIGHTMAP
	vec4 lightMapTexel = texture2D( lightMap, vLightMapUv );
	vec3 lightMapIrradiance = lightMapTexel.rgb * lightMapIntensity;
	reflectedLight.indirectDiffuse += lightMapIrradiance;
#endif`,Ch=`#ifdef USE_LIGHTMAP
	uniform sampler2D lightMap;
	uniform float lightMapIntensity;
#endif`,Ph=`LambertMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.specularStrength = specularStrength;`,Lh=`varying vec3 vViewPosition;
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
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Lambert`,Dh=`uniform bool receiveShadow;
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
#endif`,Ih=`#ifdef USE_ENVMAP
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
#endif`,Uh=`ToonMaterial material;
material.diffuseColor = diffuseColor.rgb;`,Nh=`varying vec3 vViewPosition;
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
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Toon`,Oh=`BlinnPhongMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.specularColor = specular;
material.specularShininess = shininess;
material.specularStrength = specularStrength;`,Fh=`varying vec3 vViewPosition;
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
#define RE_IndirectDiffuse		RE_IndirectDiffuse_BlinnPhong`,Bh=`PhysicalMaterial material;
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
#endif`,zh=`struct PhysicalMaterial {
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
}`,Gh=`
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
#endif`,kh=`#if defined( RE_IndirectDiffuse )
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
#endif`,Hh=`#if defined( RE_IndirectDiffuse )
	RE_IndirectDiffuse( irradiance, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
#endif
#if defined( RE_IndirectSpecular )
	RE_IndirectSpecular( radiance, iblIrradiance, clearcoatRadiance, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
#endif`,Vh=`#if defined( USE_LOGDEPTHBUF ) && defined( USE_LOGDEPTHBUF_EXT )
	gl_FragDepthEXT = vIsPerspective == 0.0 ? gl_FragCoord.z : log2( vFragDepth ) * logDepthBufFC * 0.5;
#endif`,Wh=`#if defined( USE_LOGDEPTHBUF ) && defined( USE_LOGDEPTHBUF_EXT )
	uniform float logDepthBufFC;
	varying float vFragDepth;
	varying float vIsPerspective;
#endif`,Xh=`#ifdef USE_LOGDEPTHBUF
	#ifdef USE_LOGDEPTHBUF_EXT
		varying float vFragDepth;
		varying float vIsPerspective;
	#else
		uniform float logDepthBufFC;
	#endif
#endif`,qh=`#ifdef USE_LOGDEPTHBUF
	#ifdef USE_LOGDEPTHBUF_EXT
		vFragDepth = 1.0 + gl_Position.w;
		vIsPerspective = float( isPerspectiveMatrix( projectionMatrix ) );
	#else
		if ( isPerspectiveMatrix( projectionMatrix ) ) {
			gl_Position.z = log2( max( EPSILON, gl_Position.w + 1.0 ) ) * logDepthBufFC - 1.0;
			gl_Position.z *= gl_Position.w;
		}
	#endif
#endif`,Yh=`#ifdef USE_MAP
	vec4 sampledDiffuseColor = texture2D( map, vMapUv );
	#ifdef DECODE_VIDEO_TEXTURE
		sampledDiffuseColor = vec4( mix( pow( sampledDiffuseColor.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), sampledDiffuseColor.rgb * 0.0773993808, vec3( lessThanEqual( sampledDiffuseColor.rgb, vec3( 0.04045 ) ) ) ), sampledDiffuseColor.w );
	
	#endif
	diffuseColor *= sampledDiffuseColor;
#endif`,jh=`#ifdef USE_MAP
	uniform sampler2D map;
#endif`,$h=`#if defined( USE_MAP ) || defined( USE_ALPHAMAP )
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
#endif`,Kh=`#if defined( USE_POINTS_UV )
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
#endif`,Zh=`float metalnessFactor = metalness;
#ifdef USE_METALNESSMAP
	vec4 texelMetalness = texture2D( metalnessMap, vMetalnessMapUv );
	metalnessFactor *= texelMetalness.b;
#endif`,Jh=`#ifdef USE_METALNESSMAP
	uniform sampler2D metalnessMap;
#endif`,Qh=`#if defined( USE_MORPHCOLORS ) && defined( MORPHTARGETS_TEXTURE )
	vColor *= morphTargetBaseInfluence;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		#if defined( USE_COLOR_ALPHA )
			if ( morphTargetInfluences[ i ] != 0.0 ) vColor += getMorph( gl_VertexID, i, 2 ) * morphTargetInfluences[ i ];
		#elif defined( USE_COLOR )
			if ( morphTargetInfluences[ i ] != 0.0 ) vColor += getMorph( gl_VertexID, i, 2 ).rgb * morphTargetInfluences[ i ];
		#endif
	}
#endif`,td=`#ifdef USE_MORPHNORMALS
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
#endif`,ed=`#ifdef USE_MORPHTARGETS
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
#endif`,nd=`#ifdef USE_MORPHTARGETS
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
#endif`,id=`float faceDirection = gl_FrontFacing ? 1.0 : - 1.0;
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
vec3 nonPerturbedNormal = normal;`,rd=`#ifdef USE_NORMALMAP_OBJECTSPACE
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
#endif`,sd=`#ifndef FLAT_SHADED
	varying vec3 vNormal;
	#ifdef USE_TANGENT
		varying vec3 vTangent;
		varying vec3 vBitangent;
	#endif
#endif`,od=`#ifndef FLAT_SHADED
	varying vec3 vNormal;
	#ifdef USE_TANGENT
		varying vec3 vTangent;
		varying vec3 vBitangent;
	#endif
#endif`,ad=`#ifndef FLAT_SHADED
	vNormal = normalize( transformedNormal );
	#ifdef USE_TANGENT
		vTangent = normalize( transformedTangent );
		vBitangent = normalize( cross( vNormal, vTangent ) * tangent.w );
	#endif
#endif`,ld=`#ifdef USE_NORMALMAP
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
#endif`,cd=`#ifdef USE_CLEARCOAT
	vec3 clearcoatNormal = nonPerturbedNormal;
#endif`,ud=`#ifdef USE_CLEARCOAT_NORMALMAP
	vec3 clearcoatMapN = texture2D( clearcoatNormalMap, vClearcoatNormalMapUv ).xyz * 2.0 - 1.0;
	clearcoatMapN.xy *= clearcoatNormalScale;
	clearcoatNormal = normalize( tbn2 * clearcoatMapN );
#endif`,hd=`#ifdef USE_CLEARCOATMAP
	uniform sampler2D clearcoatMap;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	uniform sampler2D clearcoatNormalMap;
	uniform vec2 clearcoatNormalScale;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	uniform sampler2D clearcoatRoughnessMap;
#endif`,dd=`#ifdef USE_IRIDESCENCEMAP
	uniform sampler2D iridescenceMap;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	uniform sampler2D iridescenceThicknessMap;
#endif`,fd=`#ifdef OPAQUE
diffuseColor.a = 1.0;
#endif
#ifdef USE_TRANSMISSION
diffuseColor.a *= material.transmissionAlpha;
#endif
gl_FragColor = vec4( outgoingLight, diffuseColor.a );`,pd=`vec3 packNormalToRGB( const in vec3 normal ) {
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
}`,md=`#ifdef PREMULTIPLIED_ALPHA
	gl_FragColor.rgb *= gl_FragColor.a;
#endif`,gd=`vec4 mvPosition = vec4( transformed, 1.0 );
#ifdef USE_BATCHING
	mvPosition = batchingMatrix * mvPosition;
#endif
#ifdef USE_INSTANCING
	mvPosition = instanceMatrix * mvPosition;
#endif
mvPosition = modelViewMatrix * mvPosition;
gl_Position = projectionMatrix * mvPosition;`,_d=`#ifdef DITHERING
	gl_FragColor.rgb = dithering( gl_FragColor.rgb );
#endif`,vd=`#ifdef DITHERING
	vec3 dithering( vec3 color ) {
		float grid_position = rand( gl_FragCoord.xy );
		vec3 dither_shift_RGB = vec3( 0.25 / 255.0, -0.25 / 255.0, 0.25 / 255.0 );
		dither_shift_RGB = mix( 2.0 * dither_shift_RGB, -2.0 * dither_shift_RGB, grid_position );
		return color + dither_shift_RGB;
	}
#endif`,xd=`float roughnessFactor = roughness;
#ifdef USE_ROUGHNESSMAP
	vec4 texelRoughness = texture2D( roughnessMap, vRoughnessMapUv );
	roughnessFactor *= texelRoughness.g;
#endif`,Md=`#ifdef USE_ROUGHNESSMAP
	uniform sampler2D roughnessMap;
#endif`,yd=`#if NUM_SPOT_LIGHT_COORDS > 0
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
#endif`,Sd=`#if NUM_SPOT_LIGHT_COORDS > 0
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
#endif`,bd=`#if ( defined( USE_SHADOWMAP ) && ( NUM_DIR_LIGHT_SHADOWS > 0 || NUM_POINT_LIGHT_SHADOWS > 0 ) ) || ( NUM_SPOT_LIGHT_COORDS > 0 )
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
#endif`,Ed=`float getShadowMask() {
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
}`,Td=`#ifdef USE_SKINNING
	mat4 boneMatX = getBoneMatrix( skinIndex.x );
	mat4 boneMatY = getBoneMatrix( skinIndex.y );
	mat4 boneMatZ = getBoneMatrix( skinIndex.z );
	mat4 boneMatW = getBoneMatrix( skinIndex.w );
#endif`,wd=`#ifdef USE_SKINNING
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
#endif`,Ad=`#ifdef USE_SKINNING
	vec4 skinVertex = bindMatrix * vec4( transformed, 1.0 );
	vec4 skinned = vec4( 0.0 );
	skinned += boneMatX * skinVertex * skinWeight.x;
	skinned += boneMatY * skinVertex * skinWeight.y;
	skinned += boneMatZ * skinVertex * skinWeight.z;
	skinned += boneMatW * skinVertex * skinWeight.w;
	transformed = ( bindMatrixInverse * skinned ).xyz;
#endif`,Rd=`#ifdef USE_SKINNING
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
#endif`,Cd=`float specularStrength;
#ifdef USE_SPECULARMAP
	vec4 texelSpecular = texture2D( specularMap, vSpecularMapUv );
	specularStrength = texelSpecular.r;
#else
	specularStrength = 1.0;
#endif`,Pd=`#ifdef USE_SPECULARMAP
	uniform sampler2D specularMap;
#endif`,Ld=`#if defined( TONE_MAPPING )
	gl_FragColor.rgb = toneMapping( gl_FragColor.rgb );
#endif`,Dd=`#ifndef saturate
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
vec3 CustomToneMapping( vec3 color ) { return color; }`,Id=`#ifdef USE_TRANSMISSION
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
#endif`,Ud=`#ifdef USE_TRANSMISSION
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
#endif`,Nd=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
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
#endif`,Od=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
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
#endif`,Fd=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
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
#endif`,Bd=`#if defined( USE_ENVMAP ) || defined( DISTANCE ) || defined ( USE_SHADOWMAP ) || defined ( USE_TRANSMISSION ) || NUM_SPOT_LIGHT_COORDS > 0
	vec4 worldPosition = vec4( transformed, 1.0 );
	#ifdef USE_BATCHING
		worldPosition = batchingMatrix * worldPosition;
	#endif
	#ifdef USE_INSTANCING
		worldPosition = instanceMatrix * worldPosition;
	#endif
	worldPosition = modelMatrix * worldPosition;
#endif`;const zd=`varying vec2 vUv;
uniform mat3 uvTransform;
void main() {
	vUv = ( uvTransform * vec3( uv, 1 ) ).xy;
	gl_Position = vec4( position.xy, 1.0, 1.0 );
}`,Gd=`uniform sampler2D t2D;
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
}`,kd=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
	gl_Position.z = gl_Position.w;
}`,Hd=`#ifdef ENVMAP_TYPE_CUBE
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
}`,Vd=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
	gl_Position.z = gl_Position.w;
}`,Wd=`uniform samplerCube tCube;
uniform float tFlip;
uniform float opacity;
varying vec3 vWorldDirection;
void main() {
	vec4 texColor = textureCube( tCube, vec3( tFlip * vWorldDirection.x, vWorldDirection.yz ) );
	gl_FragColor = texColor;
	gl_FragColor.a *= opacity;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,Xd=`#include <common>
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
}`,qd=`#if DEPTH_PACKING == 3200
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
}`,Yd=`#define DISTANCE
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
}`,jd=`#define DISTANCE
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
}`,$d=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
}`,Kd=`uniform sampler2D tEquirect;
varying vec3 vWorldDirection;
#include <common>
void main() {
	vec3 direction = normalize( vWorldDirection );
	vec2 sampleUV = equirectUv( direction );
	gl_FragColor = texture2D( tEquirect, sampleUV );
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,Zd=`uniform float scale;
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
}`,Jd=`uniform vec3 diffuse;
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
}`,Qd=`#include <common>
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
}`,tf=`uniform vec3 diffuse;
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
}`,ef=`#define LAMBERT
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
}`,nf=`#define LAMBERT
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
}`,rf=`#define MATCAP
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
}`,sf=`#define MATCAP
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
}`,of=`#define NORMAL
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
}`,af=`#define NORMAL
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
}`,lf=`#define PHONG
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
}`,cf=`#define PHONG
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
}`,uf=`#define STANDARD
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
}`,hf=`#define STANDARD
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
}`,df=`#define TOON
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
}`,ff=`#define TOON
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
}`,pf=`uniform float size;
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
}`,mf=`uniform vec3 diffuse;
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
}`,gf=`#include <common>
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
}`,_f=`uniform vec3 color;
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
}`,vf=`uniform float rotation;
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
}`,xf=`uniform vec3 diffuse;
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
}`,Yt={alphahash_fragment:Gu,alphahash_pars_fragment:ku,alphamap_fragment:Hu,alphamap_pars_fragment:Vu,alphatest_fragment:Wu,alphatest_pars_fragment:Xu,aomap_fragment:qu,aomap_pars_fragment:Yu,batching_pars_vertex:ju,batching_vertex:$u,begin_vertex:Ku,beginnormal_vertex:Zu,bsdfs:Ju,iridescence_fragment:Qu,bumpmap_pars_fragment:th,clipping_planes_fragment:eh,clipping_planes_pars_fragment:nh,clipping_planes_pars_vertex:ih,clipping_planes_vertex:rh,color_fragment:sh,color_pars_fragment:oh,color_pars_vertex:ah,color_vertex:lh,common:ch,cube_uv_reflection_fragment:uh,defaultnormal_vertex:hh,displacementmap_pars_vertex:dh,displacementmap_vertex:fh,emissivemap_fragment:ph,emissivemap_pars_fragment:mh,colorspace_fragment:gh,colorspace_pars_fragment:_h,envmap_fragment:vh,envmap_common_pars_fragment:xh,envmap_pars_fragment:Mh,envmap_pars_vertex:yh,envmap_physical_pars_fragment:Ih,envmap_vertex:Sh,fog_vertex:bh,fog_pars_vertex:Eh,fog_fragment:Th,fog_pars_fragment:wh,gradientmap_pars_fragment:Ah,lightmap_fragment:Rh,lightmap_pars_fragment:Ch,lights_lambert_fragment:Ph,lights_lambert_pars_fragment:Lh,lights_pars_begin:Dh,lights_toon_fragment:Uh,lights_toon_pars_fragment:Nh,lights_phong_fragment:Oh,lights_phong_pars_fragment:Fh,lights_physical_fragment:Bh,lights_physical_pars_fragment:zh,lights_fragment_begin:Gh,lights_fragment_maps:kh,lights_fragment_end:Hh,logdepthbuf_fragment:Vh,logdepthbuf_pars_fragment:Wh,logdepthbuf_pars_vertex:Xh,logdepthbuf_vertex:qh,map_fragment:Yh,map_pars_fragment:jh,map_particle_fragment:$h,map_particle_pars_fragment:Kh,metalnessmap_fragment:Zh,metalnessmap_pars_fragment:Jh,morphcolor_vertex:Qh,morphnormal_vertex:td,morphtarget_pars_vertex:ed,morphtarget_vertex:nd,normal_fragment_begin:id,normal_fragment_maps:rd,normal_pars_fragment:sd,normal_pars_vertex:od,normal_vertex:ad,normalmap_pars_fragment:ld,clearcoat_normal_fragment_begin:cd,clearcoat_normal_fragment_maps:ud,clearcoat_pars_fragment:hd,iridescence_pars_fragment:dd,opaque_fragment:fd,packing:pd,premultiplied_alpha_fragment:md,project_vertex:gd,dithering_fragment:_d,dithering_pars_fragment:vd,roughnessmap_fragment:xd,roughnessmap_pars_fragment:Md,shadowmap_pars_fragment:yd,shadowmap_pars_vertex:Sd,shadowmap_vertex:bd,shadowmask_pars_fragment:Ed,skinbase_vertex:Td,skinning_pars_vertex:wd,skinning_vertex:Ad,skinnormal_vertex:Rd,specularmap_fragment:Cd,specularmap_pars_fragment:Pd,tonemapping_fragment:Ld,tonemapping_pars_fragment:Dd,transmission_fragment:Id,transmission_pars_fragment:Ud,uv_pars_fragment:Nd,uv_pars_vertex:Od,uv_vertex:Fd,worldpos_vertex:Bd,background_vert:zd,background_frag:Gd,backgroundCube_vert:kd,backgroundCube_frag:Hd,cube_vert:Vd,cube_frag:Wd,depth_vert:Xd,depth_frag:qd,distanceRGBA_vert:Yd,distanceRGBA_frag:jd,equirect_vert:$d,equirect_frag:Kd,linedashed_vert:Zd,linedashed_frag:Jd,meshbasic_vert:Qd,meshbasic_frag:tf,meshlambert_vert:ef,meshlambert_frag:nf,meshmatcap_vert:rf,meshmatcap_frag:sf,meshnormal_vert:of,meshnormal_frag:af,meshphong_vert:lf,meshphong_frag:cf,meshphysical_vert:uf,meshphysical_frag:hf,meshtoon_vert:df,meshtoon_frag:ff,points_vert:pf,points_frag:mf,shadow_vert:gf,shadow_frag:_f,sprite_vert:vf,sprite_frag:xf},Ct={common:{diffuse:{value:new Dt(16777215)},opacity:{value:1},map:{value:null},mapTransform:{value:new Kt},alphaMap:{value:null},alphaMapTransform:{value:new Kt},alphaTest:{value:0}},specularmap:{specularMap:{value:null},specularMapTransform:{value:new Kt}},envmap:{envMap:{value:null},flipEnvMap:{value:-1},reflectivity:{value:1},ior:{value:1.5},refractionRatio:{value:.98}},aomap:{aoMap:{value:null},aoMapIntensity:{value:1},aoMapTransform:{value:new Kt}},lightmap:{lightMap:{value:null},lightMapIntensity:{value:1},lightMapTransform:{value:new Kt}},bumpmap:{bumpMap:{value:null},bumpMapTransform:{value:new Kt},bumpScale:{value:1}},normalmap:{normalMap:{value:null},normalMapTransform:{value:new Kt},normalScale:{value:new wt(1,1)}},displacementmap:{displacementMap:{value:null},displacementMapTransform:{value:new Kt},displacementScale:{value:1},displacementBias:{value:0}},emissivemap:{emissiveMap:{value:null},emissiveMapTransform:{value:new Kt}},metalnessmap:{metalnessMap:{value:null},metalnessMapTransform:{value:new Kt}},roughnessmap:{roughnessMap:{value:null},roughnessMapTransform:{value:new Kt}},gradientmap:{gradientMap:{value:null}},fog:{fogDensity:{value:25e-5},fogNear:{value:1},fogFar:{value:2e3},fogColor:{value:new Dt(16777215)}},lights:{ambientLightColor:{value:[]},lightProbe:{value:[]},directionalLights:{value:[],properties:{direction:{},color:{}}},directionalLightShadows:{value:[],properties:{shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{}}},directionalShadowMap:{value:[]},directionalShadowMatrix:{value:[]},spotLights:{value:[],properties:{color:{},position:{},direction:{},distance:{},coneCos:{},penumbraCos:{},decay:{}}},spotLightShadows:{value:[],properties:{shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{}}},spotLightMap:{value:[]},spotShadowMap:{value:[]},spotLightMatrix:{value:[]},pointLights:{value:[],properties:{color:{},position:{},decay:{},distance:{}}},pointLightShadows:{value:[],properties:{shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{},shadowCameraNear:{},shadowCameraFar:{}}},pointShadowMap:{value:[]},pointShadowMatrix:{value:[]},hemisphereLights:{value:[],properties:{direction:{},skyColor:{},groundColor:{}}},rectAreaLights:{value:[],properties:{color:{},position:{},width:{},height:{}}},ltc_1:{value:null},ltc_2:{value:null}},points:{diffuse:{value:new Dt(16777215)},opacity:{value:1},size:{value:1},scale:{value:1},map:{value:null},alphaMap:{value:null},alphaMapTransform:{value:new Kt},alphaTest:{value:0},uvTransform:{value:new Kt}},sprite:{diffuse:{value:new Dt(16777215)},opacity:{value:1},center:{value:new wt(.5,.5)},rotation:{value:0},map:{value:null},mapTransform:{value:new Kt},alphaMap:{value:null},alphaMapTransform:{value:new Kt},alphaTest:{value:0}}},Qe={basic:{uniforms:Pe([Ct.common,Ct.specularmap,Ct.envmap,Ct.aomap,Ct.lightmap,Ct.fog]),vertexShader:Yt.meshbasic_vert,fragmentShader:Yt.meshbasic_frag},lambert:{uniforms:Pe([Ct.common,Ct.specularmap,Ct.envmap,Ct.aomap,Ct.lightmap,Ct.emissivemap,Ct.bumpmap,Ct.normalmap,Ct.displacementmap,Ct.fog,Ct.lights,{emissive:{value:new Dt(0)}}]),vertexShader:Yt.meshlambert_vert,fragmentShader:Yt.meshlambert_frag},phong:{uniforms:Pe([Ct.common,Ct.specularmap,Ct.envmap,Ct.aomap,Ct.lightmap,Ct.emissivemap,Ct.bumpmap,Ct.normalmap,Ct.displacementmap,Ct.fog,Ct.lights,{emissive:{value:new Dt(0)},specular:{value:new Dt(1118481)},shininess:{value:30}}]),vertexShader:Yt.meshphong_vert,fragmentShader:Yt.meshphong_frag},standard:{uniforms:Pe([Ct.common,Ct.envmap,Ct.aomap,Ct.lightmap,Ct.emissivemap,Ct.bumpmap,Ct.normalmap,Ct.displacementmap,Ct.roughnessmap,Ct.metalnessmap,Ct.fog,Ct.lights,{emissive:{value:new Dt(0)},roughness:{value:1},metalness:{value:0},envMapIntensity:{value:1}}]),vertexShader:Yt.meshphysical_vert,fragmentShader:Yt.meshphysical_frag},toon:{uniforms:Pe([Ct.common,Ct.aomap,Ct.lightmap,Ct.emissivemap,Ct.bumpmap,Ct.normalmap,Ct.displacementmap,Ct.gradientmap,Ct.fog,Ct.lights,{emissive:{value:new Dt(0)}}]),vertexShader:Yt.meshtoon_vert,fragmentShader:Yt.meshtoon_frag},matcap:{uniforms:Pe([Ct.common,Ct.bumpmap,Ct.normalmap,Ct.displacementmap,Ct.fog,{matcap:{value:null}}]),vertexShader:Yt.meshmatcap_vert,fragmentShader:Yt.meshmatcap_frag},points:{uniforms:Pe([Ct.points,Ct.fog]),vertexShader:Yt.points_vert,fragmentShader:Yt.points_frag},dashed:{uniforms:Pe([Ct.common,Ct.fog,{scale:{value:1},dashSize:{value:1},totalSize:{value:2}}]),vertexShader:Yt.linedashed_vert,fragmentShader:Yt.linedashed_frag},depth:{uniforms:Pe([Ct.common,Ct.displacementmap]),vertexShader:Yt.depth_vert,fragmentShader:Yt.depth_frag},normal:{uniforms:Pe([Ct.common,Ct.bumpmap,Ct.normalmap,Ct.displacementmap,{opacity:{value:1}}]),vertexShader:Yt.meshnormal_vert,fragmentShader:Yt.meshnormal_frag},sprite:{uniforms:Pe([Ct.sprite,Ct.fog]),vertexShader:Yt.sprite_vert,fragmentShader:Yt.sprite_frag},background:{uniforms:{uvTransform:{value:new Kt},t2D:{value:null},backgroundIntensity:{value:1}},vertexShader:Yt.background_vert,fragmentShader:Yt.background_frag},backgroundCube:{uniforms:{envMap:{value:null},flipEnvMap:{value:-1},backgroundBlurriness:{value:0},backgroundIntensity:{value:1}},vertexShader:Yt.backgroundCube_vert,fragmentShader:Yt.backgroundCube_frag},cube:{uniforms:{tCube:{value:null},tFlip:{value:-1},opacity:{value:1}},vertexShader:Yt.cube_vert,fragmentShader:Yt.cube_frag},equirect:{uniforms:{tEquirect:{value:null}},vertexShader:Yt.equirect_vert,fragmentShader:Yt.equirect_frag},distanceRGBA:{uniforms:Pe([Ct.common,Ct.displacementmap,{referencePosition:{value:new W},nearDistance:{value:1},farDistance:{value:1e3}}]),vertexShader:Yt.distanceRGBA_vert,fragmentShader:Yt.distanceRGBA_frag},shadow:{uniforms:Pe([Ct.lights,Ct.fog,{color:{value:new Dt(0)},opacity:{value:1}}]),vertexShader:Yt.shadow_vert,fragmentShader:Yt.shadow_frag}};Qe.physical={uniforms:Pe([Qe.standard.uniforms,{clearcoat:{value:0},clearcoatMap:{value:null},clearcoatMapTransform:{value:new Kt},clearcoatNormalMap:{value:null},clearcoatNormalMapTransform:{value:new Kt},clearcoatNormalScale:{value:new wt(1,1)},clearcoatRoughness:{value:0},clearcoatRoughnessMap:{value:null},clearcoatRoughnessMapTransform:{value:new Kt},iridescence:{value:0},iridescenceMap:{value:null},iridescenceMapTransform:{value:new Kt},iridescenceIOR:{value:1.3},iridescenceThicknessMinimum:{value:100},iridescenceThicknessMaximum:{value:400},iridescenceThicknessMap:{value:null},iridescenceThicknessMapTransform:{value:new Kt},sheen:{value:0},sheenColor:{value:new Dt(0)},sheenColorMap:{value:null},sheenColorMapTransform:{value:new Kt},sheenRoughness:{value:1},sheenRoughnessMap:{value:null},sheenRoughnessMapTransform:{value:new Kt},transmission:{value:0},transmissionMap:{value:null},transmissionMapTransform:{value:new Kt},transmissionSamplerSize:{value:new wt},transmissionSamplerMap:{value:null},thickness:{value:0},thicknessMap:{value:null},thicknessMapTransform:{value:new Kt},attenuationDistance:{value:0},attenuationColor:{value:new Dt(0)},specularColor:{value:new Dt(1,1,1)},specularColorMap:{value:null},specularColorMapTransform:{value:new Kt},specularIntensity:{value:1},specularIntensityMap:{value:null},specularIntensityMapTransform:{value:new Kt},anisotropyVector:{value:new wt},anisotropyMap:{value:null},anisotropyMapTransform:{value:new Kt}}]),vertexShader:Yt.meshphysical_vert,fragmentShader:Yt.meshphysical_frag};const xr={r:0,b:0,g:0};function Mf(i,t,e,n,r,s,o){const a=new Dt(0);let l=s===!0?0:1,c,u,f=null,m=0,p=null;function v(d,h){let y=!1,_=h.isScene===!0?h.background:null;_&&_.isTexture&&(_=(h.backgroundBlurriness>0?e:t).get(_)),_===null?x(a,l):_&&_.isColor&&(x(_,1),y=!0);const w=i.xr.getEnvironmentBlendMode();w==="additive"?n.buffers.color.setClear(0,0,0,1,o):w==="alpha-blend"&&n.buffers.color.setClear(0,0,0,0,o),(i.autoClear||y)&&i.clear(i.autoClearColor,i.autoClearDepth,i.autoClearStencil),_&&(_.isCubeTexture||_.mapping===kr)?(u===void 0&&(u=new Ft(new $e(1,1,1),new Ee({name:"BackgroundCubeMaterial",uniforms:bi(Qe.backgroundCube.uniforms),vertexShader:Qe.backgroundCube.vertexShader,fragmentShader:Qe.backgroundCube.fragmentShader,side:Te,depthTest:!1,depthWrite:!1,fog:!1})),u.geometry.deleteAttribute("normal"),u.geometry.deleteAttribute("uv"),u.onBeforeRender=function(D,P,I){this.matrixWorld.copyPosition(I.matrixWorld)},Object.defineProperty(u.material,"envMap",{get:function(){return this.uniforms.envMap.value}}),r.update(u)),u.material.uniforms.envMap.value=_,u.material.uniforms.flipEnvMap.value=_.isCubeTexture&&_.isRenderTargetTexture===!1?-1:1,u.material.uniforms.backgroundBlurriness.value=h.backgroundBlurriness,u.material.uniforms.backgroundIntensity.value=h.backgroundIntensity,u.material.toneMapped=te.getTransfer(_.colorSpace)!==se,(f!==_||m!==_.version||p!==i.toneMapping)&&(u.material.needsUpdate=!0,f=_,m=_.version,p=i.toneMapping),u.layers.enableAll(),d.unshift(u,u.geometry,u.material,0,0,null)):_&&_.isTexture&&(c===void 0&&(c=new Ft(new Wn(2,2),new Ee({name:"BackgroundMaterial",uniforms:bi(Qe.background.uniforms),vertexShader:Qe.background.vertexShader,fragmentShader:Qe.background.fragmentShader,side:wn,depthTest:!1,depthWrite:!1,fog:!1})),c.geometry.deleteAttribute("normal"),Object.defineProperty(c.material,"map",{get:function(){return this.uniforms.t2D.value}}),r.update(c)),c.material.uniforms.t2D.value=_,c.material.uniforms.backgroundIntensity.value=h.backgroundIntensity,c.material.toneMapped=te.getTransfer(_.colorSpace)!==se,_.matrixAutoUpdate===!0&&_.updateMatrix(),c.material.uniforms.uvTransform.value.copy(_.matrix),(f!==_||m!==_.version||p!==i.toneMapping)&&(c.material.needsUpdate=!0,f=_,m=_.version,p=i.toneMapping),c.layers.enableAll(),d.unshift(c,c.geometry,c.material,0,0,null))}function x(d,h){d.getRGB(xr,Ul(i)),n.buffers.color.setClear(xr.r,xr.g,xr.b,h,o)}return{getClearColor:function(){return a},setClearColor:function(d,h=1){a.set(d),l=h,x(a,l)},getClearAlpha:function(){return l},setClearAlpha:function(d){l=d,x(a,l)},render:v}}function yf(i,t,e,n){const r=i.getParameter(i.MAX_VERTEX_ATTRIBS),s=n.isWebGL2?null:t.get("OES_vertex_array_object"),o=n.isWebGL2||s!==null,a={},l=d(null);let c=l,u=!1;function f(S,E,g,T,L){let N=!1;if(o){const C=x(T,g,E);c!==C&&(c=C,p(c.object)),N=h(S,T,g,L),N&&y(S,T,g,L)}else{const C=E.wireframe===!0;(c.geometry!==T.id||c.program!==g.id||c.wireframe!==C)&&(c.geometry=T.id,c.program=g.id,c.wireframe=C,N=!0)}L!==null&&e.update(L,i.ELEMENT_ARRAY_BUFFER),(N||u)&&(u=!1,F(S,E,g,T),L!==null&&i.bindBuffer(i.ELEMENT_ARRAY_BUFFER,e.get(L).buffer))}function m(){return n.isWebGL2?i.createVertexArray():s.createVertexArrayOES()}function p(S){return n.isWebGL2?i.bindVertexArray(S):s.bindVertexArrayOES(S)}function v(S){return n.isWebGL2?i.deleteVertexArray(S):s.deleteVertexArrayOES(S)}function x(S,E,g){const T=g.wireframe===!0;let L=a[S.id];L===void 0&&(L={},a[S.id]=L);let N=L[E.id];N===void 0&&(N={},L[E.id]=N);let C=N[T];return C===void 0&&(C=d(m()),N[T]=C),C}function d(S){const E=[],g=[],T=[];for(let L=0;L<r;L++)E[L]=0,g[L]=0,T[L]=0;return{geometry:null,program:null,wireframe:!1,newAttributes:E,enabledAttributes:g,attributeDivisors:T,object:S,attributes:{},index:null}}function h(S,E,g,T){const L=c.attributes,N=E.attributes;let C=0;const U=g.getAttributes();for(const q in U)if(U[q].location>=0){const it=L[q];let ut=N[q];if(ut===void 0&&(q==="instanceMatrix"&&S.instanceMatrix&&(ut=S.instanceMatrix),q==="instanceColor"&&S.instanceColor&&(ut=S.instanceColor)),it===void 0||it.attribute!==ut||ut&&it.data!==ut.data)return!0;C++}return c.attributesNum!==C||c.index!==T}function y(S,E,g,T){const L={},N=E.attributes;let C=0;const U=g.getAttributes();for(const q in U)if(U[q].location>=0){let it=N[q];it===void 0&&(q==="instanceMatrix"&&S.instanceMatrix&&(it=S.instanceMatrix),q==="instanceColor"&&S.instanceColor&&(it=S.instanceColor));const ut={};ut.attribute=it,it&&it.data&&(ut.data=it.data),L[q]=ut,C++}c.attributes=L,c.attributesNum=C,c.index=T}function _(){const S=c.newAttributes;for(let E=0,g=S.length;E<g;E++)S[E]=0}function w(S){D(S,0)}function D(S,E){const g=c.newAttributes,T=c.enabledAttributes,L=c.attributeDivisors;g[S]=1,T[S]===0&&(i.enableVertexAttribArray(S),T[S]=1),L[S]!==E&&((n.isWebGL2?i:t.get("ANGLE_instanced_arrays"))[n.isWebGL2?"vertexAttribDivisor":"vertexAttribDivisorANGLE"](S,E),L[S]=E)}function P(){const S=c.newAttributes,E=c.enabledAttributes;for(let g=0,T=E.length;g<T;g++)E[g]!==S[g]&&(i.disableVertexAttribArray(g),E[g]=0)}function I(S,E,g,T,L,N,C){C===!0?i.vertexAttribIPointer(S,E,g,L,N):i.vertexAttribPointer(S,E,g,T,L,N)}function F(S,E,g,T){if(n.isWebGL2===!1&&(S.isInstancedMesh||T.isInstancedBufferGeometry)&&t.get("ANGLE_instanced_arrays")===null)return;_();const L=T.attributes,N=g.getAttributes(),C=E.defaultAttributeValues;for(const U in N){const q=N[U];if(q.location>=0){let Z=L[U];if(Z===void 0&&(U==="instanceMatrix"&&S.instanceMatrix&&(Z=S.instanceMatrix),U==="instanceColor"&&S.instanceColor&&(Z=S.instanceColor)),Z!==void 0){const it=Z.normalized,ut=Z.itemSize,gt=e.get(Z);if(gt===void 0)continue;const xt=gt.buffer,Et=gt.type,lt=gt.bytesPerElement,ct=n.isWebGL2===!0&&(Et===i.INT||Et===i.UNSIGNED_INT||Z.gpuType===gl);if(Z.isInterleavedBufferAttribute){const Mt=Z.data,k=Mt.stride,tt=Z.offset;if(Mt.isInstancedInterleavedBuffer){for(let G=0;G<q.locationSize;G++)D(q.location+G,Mt.meshPerAttribute);S.isInstancedMesh!==!0&&T._maxInstanceCount===void 0&&(T._maxInstanceCount=Mt.meshPerAttribute*Mt.count)}else for(let G=0;G<q.locationSize;G++)w(q.location+G);i.bindBuffer(i.ARRAY_BUFFER,xt);for(let G=0;G<q.locationSize;G++)I(q.location+G,ut/q.locationSize,Et,it,k*lt,(tt+ut/q.locationSize*G)*lt,ct)}else{if(Z.isInstancedBufferAttribute){for(let Mt=0;Mt<q.locationSize;Mt++)D(q.location+Mt,Z.meshPerAttribute);S.isInstancedMesh!==!0&&T._maxInstanceCount===void 0&&(T._maxInstanceCount=Z.meshPerAttribute*Z.count)}else for(let Mt=0;Mt<q.locationSize;Mt++)w(q.location+Mt);i.bindBuffer(i.ARRAY_BUFFER,xt);for(let Mt=0;Mt<q.locationSize;Mt++)I(q.location+Mt,ut/q.locationSize,Et,it,ut*lt,ut/q.locationSize*Mt*lt,ct)}}else if(C!==void 0){const it=C[U];if(it!==void 0)switch(it.length){case 2:i.vertexAttrib2fv(q.location,it);break;case 3:i.vertexAttrib3fv(q.location,it);break;case 4:i.vertexAttrib4fv(q.location,it);break;default:i.vertexAttrib1fv(q.location,it)}}}}P()}function M(){O();for(const S in a){const E=a[S];for(const g in E){const T=E[g];for(const L in T)v(T[L].object),delete T[L];delete E[g]}delete a[S]}}function A(S){if(a[S.id]===void 0)return;const E=a[S.id];for(const g in E){const T=E[g];for(const L in T)v(T[L].object),delete T[L];delete E[g]}delete a[S.id]}function K(S){for(const E in a){const g=a[E];if(g[S.id]===void 0)continue;const T=g[S.id];for(const L in T)v(T[L].object),delete T[L];delete g[S.id]}}function O(){z(),u=!0,c!==l&&(c=l,p(c.object))}function z(){l.geometry=null,l.program=null,l.wireframe=!1}return{setup:f,reset:O,resetDefaultState:z,dispose:M,releaseStatesOfGeometry:A,releaseStatesOfProgram:K,initAttributes:_,enableAttribute:w,disableUnusedAttributes:P}}function Sf(i,t,e,n){const r=n.isWebGL2;let s;function o(u){s=u}function a(u,f){i.drawArrays(s,u,f),e.update(f,s,1)}function l(u,f,m){if(m===0)return;let p,v;if(r)p=i,v="drawArraysInstanced";else if(p=t.get("ANGLE_instanced_arrays"),v="drawArraysInstancedANGLE",p===null){console.error("THREE.WebGLBufferRenderer: using THREE.InstancedBufferGeometry but hardware does not support extension ANGLE_instanced_arrays.");return}p[v](s,u,f,m),e.update(f,s,m)}function c(u,f,m){if(m===0)return;const p=t.get("WEBGL_multi_draw");if(p===null)for(let v=0;v<m;v++)this.render(u[v],f[v]);else{p.multiDrawArraysWEBGL(s,u,0,f,0,m);let v=0;for(let x=0;x<m;x++)v+=f[x];e.update(v,s,1)}}this.setMode=o,this.render=a,this.renderInstances=l,this.renderMultiDraw=c}function bf(i,t,e){let n;function r(){if(n!==void 0)return n;if(t.has("EXT_texture_filter_anisotropic")===!0){const I=t.get("EXT_texture_filter_anisotropic");n=i.getParameter(I.MAX_TEXTURE_MAX_ANISOTROPY_EXT)}else n=0;return n}function s(I){if(I==="highp"){if(i.getShaderPrecisionFormat(i.VERTEX_SHADER,i.HIGH_FLOAT).precision>0&&i.getShaderPrecisionFormat(i.FRAGMENT_SHADER,i.HIGH_FLOAT).precision>0)return"highp";I="mediump"}return I==="mediump"&&i.getShaderPrecisionFormat(i.VERTEX_SHADER,i.MEDIUM_FLOAT).precision>0&&i.getShaderPrecisionFormat(i.FRAGMENT_SHADER,i.MEDIUM_FLOAT).precision>0?"mediump":"lowp"}const o=typeof WebGL2RenderingContext<"u"&&i.constructor.name==="WebGL2RenderingContext";let a=e.precision!==void 0?e.precision:"highp";const l=s(a);l!==a&&(console.warn("THREE.WebGLRenderer:",a,"not supported, using",l,"instead."),a=l);const c=o||t.has("WEBGL_draw_buffers"),u=e.logarithmicDepthBuffer===!0,f=i.getParameter(i.MAX_TEXTURE_IMAGE_UNITS),m=i.getParameter(i.MAX_VERTEX_TEXTURE_IMAGE_UNITS),p=i.getParameter(i.MAX_TEXTURE_SIZE),v=i.getParameter(i.MAX_CUBE_MAP_TEXTURE_SIZE),x=i.getParameter(i.MAX_VERTEX_ATTRIBS),d=i.getParameter(i.MAX_VERTEX_UNIFORM_VECTORS),h=i.getParameter(i.MAX_VARYING_VECTORS),y=i.getParameter(i.MAX_FRAGMENT_UNIFORM_VECTORS),_=m>0,w=o||t.has("OES_texture_float"),D=_&&w,P=o?i.getParameter(i.MAX_SAMPLES):0;return{isWebGL2:o,drawBuffers:c,getMaxAnisotropy:r,getMaxPrecision:s,precision:a,logarithmicDepthBuffer:u,maxTextures:f,maxVertexTextures:m,maxTextureSize:p,maxCubemapSize:v,maxAttributes:x,maxVertexUniforms:d,maxVaryings:h,maxFragmentUniforms:y,vertexTextures:_,floatFragmentTextures:w,floatVertexTextures:D,maxSamples:P}}function Ef(i){const t=this;let e=null,n=0,r=!1,s=!1;const o=new yn,a=new Kt,l={value:null,needsUpdate:!1};this.uniform=l,this.numPlanes=0,this.numIntersection=0,this.init=function(f,m){const p=f.length!==0||m||n!==0||r;return r=m,n=f.length,p},this.beginShadows=function(){s=!0,u(null)},this.endShadows=function(){s=!1},this.setGlobalState=function(f,m){e=u(f,m,0)},this.setState=function(f,m,p){const v=f.clippingPlanes,x=f.clipIntersection,d=f.clipShadows,h=i.get(f);if(!r||v===null||v.length===0||s&&!d)s?u(null):c();else{const y=s?0:n,_=y*4;let w=h.clippingState||null;l.value=w,w=u(v,m,_,p);for(let D=0;D!==_;++D)w[D]=e[D];h.clippingState=w,this.numIntersection=x?this.numPlanes:0,this.numPlanes+=y}};function c(){l.value!==e&&(l.value=e,l.needsUpdate=n>0),t.numPlanes=n,t.numIntersection=0}function u(f,m,p,v){const x=f!==null?f.length:0;let d=null;if(x!==0){if(d=l.value,v!==!0||d===null){const h=p+x*4,y=m.matrixWorldInverse;a.getNormalMatrix(y),(d===null||d.length<h)&&(d=new Float32Array(h));for(let _=0,w=p;_!==x;++_,w+=4)o.copy(f[_]).applyMatrix4(y,a),o.normal.toArray(d,w),d[w+3]=o.constant}l.value=d,l.needsUpdate=!0}return t.numPlanes=x,t.numIntersection=0,d}}function Tf(i){let t=new WeakMap;function e(o,a){return a===Bs?o.mapping=xi:a===zs&&(o.mapping=Mi),o}function n(o){if(o&&o.isTexture){const a=o.mapping;if(a===Bs||a===zs)if(t.has(o)){const l=t.get(o).texture;return e(l,o.mapping)}else{const l=o.image;if(l&&l.height>0){const c=new Ou(l.height/2);return c.fromEquirectangularTexture(i,o),t.set(o,c),o.addEventListener("dispose",r),e(c.texture,o.mapping)}else return null}}return o}function r(o){const a=o.target;a.removeEventListener("dispose",r);const l=t.get(a);l!==void 0&&(t.delete(a),l.dispose())}function s(){t=new WeakMap}return{get:n,dispose:s}}class no extends Nl{constructor(t=-1,e=1,n=1,r=-1,s=.1,o=2e3){super(),this.isOrthographicCamera=!0,this.type="OrthographicCamera",this.zoom=1,this.view=null,this.left=t,this.right=e,this.top=n,this.bottom=r,this.near=s,this.far=o,this.updateProjectionMatrix()}copy(t,e){return super.copy(t,e),this.left=t.left,this.right=t.right,this.top=t.top,this.bottom=t.bottom,this.near=t.near,this.far=t.far,this.zoom=t.zoom,this.view=t.view===null?null:Object.assign({},t.view),this}setViewOffset(t,e,n,r,s,o){this.view===null&&(this.view={enabled:!0,fullWidth:1,fullHeight:1,offsetX:0,offsetY:0,width:1,height:1}),this.view.enabled=!0,this.view.fullWidth=t,this.view.fullHeight=e,this.view.offsetX=n,this.view.offsetY=r,this.view.width=s,this.view.height=o,this.updateProjectionMatrix()}clearViewOffset(){this.view!==null&&(this.view.enabled=!1),this.updateProjectionMatrix()}updateProjectionMatrix(){const t=(this.right-this.left)/(2*this.zoom),e=(this.top-this.bottom)/(2*this.zoom),n=(this.right+this.left)/2,r=(this.top+this.bottom)/2;let s=n-t,o=n+t,a=r+e,l=r-e;if(this.view!==null&&this.view.enabled){const c=(this.right-this.left)/this.view.fullWidth/this.zoom,u=(this.top-this.bottom)/this.view.fullHeight/this.zoom;s+=c*this.view.offsetX,o=s+c*this.view.width,a-=u*this.view.offsetY,l=a-u*this.view.height}this.projectionMatrix.makeOrthographic(s,o,a,l,this.near,this.far,this.coordinateSystem),this.projectionMatrixInverse.copy(this.projectionMatrix).invert()}toJSON(t){const e=super.toJSON(t);return e.object.zoom=this.zoom,e.object.left=this.left,e.object.right=this.right,e.object.top=this.top,e.object.bottom=this.bottom,e.object.near=this.near,e.object.far=this.far,this.view!==null&&(e.object.view=Object.assign({},this.view)),e}}const pi=4,ga=[.125,.215,.35,.446,.526,.582],Fn=20,Ms=new no,_a=new Dt;let ys=null,Ss=0,bs=0;const Nn=(1+Math.sqrt(5))/2,li=1/Nn,va=[new W(1,1,1),new W(-1,1,1),new W(1,1,-1),new W(-1,1,-1),new W(0,Nn,li),new W(0,Nn,-li),new W(li,0,Nn),new W(-li,0,Nn),new W(Nn,li,0),new W(-Nn,li,0)];class Ws{constructor(t){this._renderer=t,this._pingPongRenderTarget=null,this._lodMax=0,this._cubeSize=0,this._lodPlanes=[],this._sizeLods=[],this._sigmas=[],this._blurMaterial=null,this._cubemapMaterial=null,this._equirectMaterial=null,this._compileMaterial(this._blurMaterial)}fromScene(t,e=0,n=.1,r=100){ys=this._renderer.getRenderTarget(),Ss=this._renderer.getActiveCubeFace(),bs=this._renderer.getActiveMipmapLevel(),this._setSize(256);const s=this._allocateTargets();return s.depthBuffer=!0,this._sceneToCubeUV(t,n,r,s),e>0&&this._blur(s,0,0,e),this._applyPMREM(s),this._cleanup(s),s}fromEquirectangular(t,e=null){return this._fromTexture(t,e)}fromCubemap(t,e=null){return this._fromTexture(t,e)}compileCubemapShader(){this._cubemapMaterial===null&&(this._cubemapMaterial=ya(),this._compileMaterial(this._cubemapMaterial))}compileEquirectangularShader(){this._equirectMaterial===null&&(this._equirectMaterial=Ma(),this._compileMaterial(this._equirectMaterial))}dispose(){this._dispose(),this._cubemapMaterial!==null&&this._cubemapMaterial.dispose(),this._equirectMaterial!==null&&this._equirectMaterial.dispose()}_setSize(t){this._lodMax=Math.floor(Math.log2(t)),this._cubeSize=Math.pow(2,this._lodMax)}_dispose(){this._blurMaterial!==null&&this._blurMaterial.dispose(),this._pingPongRenderTarget!==null&&this._pingPongRenderTarget.dispose();for(let t=0;t<this._lodPlanes.length;t++)this._lodPlanes[t].dispose()}_cleanup(t){this._renderer.setRenderTarget(ys,Ss,bs),t.scissorTest=!1,Mr(t,0,0,t.width,t.height)}_fromTexture(t,e){t.mapping===xi||t.mapping===Mi?this._setSize(t.image.length===0?16:t.image[0].width||t.image[0].image.width):this._setSize(t.image.width/4),ys=this._renderer.getRenderTarget(),Ss=this._renderer.getActiveCubeFace(),bs=this._renderer.getActiveMipmapLevel();const n=e||this._allocateTargets();return this._textureToCubeUV(t,n),this._applyPMREM(n),this._cleanup(n),n}_allocateTargets(){const t=3*Math.max(this._cubeSize,112),e=4*this._cubeSize,n={magFilter:ke,minFilter:ke,generateMipmaps:!1,type:dn,format:je,colorSpace:pn,depthBuffer:!1},r=xa(t,e,n);if(this._pingPongRenderTarget===null||this._pingPongRenderTarget.width!==t||this._pingPongRenderTarget.height!==e){this._pingPongRenderTarget!==null&&this._dispose(),this._pingPongRenderTarget=xa(t,e,n);const{_lodMax:s}=this;({sizeLods:this._sizeLods,lodPlanes:this._lodPlanes,sigmas:this._sigmas}=wf(s)),this._blurMaterial=Af(s,t,e)}return r}_compileMaterial(t){const e=new Ft(this._lodPlanes[0],t);this._renderer.compile(e,Ms)}_sceneToCubeUV(t,e,n,r){const a=new Oe(90,1,e,n),l=[1,-1,1,1,1,1],c=[1,1,1,-1,-1,-1],u=this._renderer,f=u.autoClear,m=u.toneMapping;u.getClearColor(_a),u.toneMapping=En,u.autoClear=!1;const p=new De({name:"PMREM.Background",side:Te,depthWrite:!1,depthTest:!1}),v=new Ft(new $e,p);let x=!1;const d=t.background;d?d.isColor&&(p.color.copy(d),t.background=null,x=!0):(p.color.copy(_a),x=!0);for(let h=0;h<6;h++){const y=h%3;y===0?(a.up.set(0,l[h],0),a.lookAt(c[h],0,0)):y===1?(a.up.set(0,0,l[h]),a.lookAt(0,c[h],0)):(a.up.set(0,l[h],0),a.lookAt(0,0,c[h]));const _=this._cubeSize;Mr(r,y*_,h>2?_:0,_,_),u.setRenderTarget(r),x&&u.render(v,a),u.render(t,a)}v.geometry.dispose(),v.material.dispose(),u.toneMapping=m,u.autoClear=f,t.background=d}_textureToCubeUV(t,e){const n=this._renderer,r=t.mapping===xi||t.mapping===Mi;r?(this._cubemapMaterial===null&&(this._cubemapMaterial=ya()),this._cubemapMaterial.uniforms.flipEnvMap.value=t.isRenderTargetTexture===!1?-1:1):this._equirectMaterial===null&&(this._equirectMaterial=Ma());const s=r?this._cubemapMaterial:this._equirectMaterial,o=new Ft(this._lodPlanes[0],s),a=s.uniforms;a.envMap.value=t;const l=this._cubeSize;Mr(e,0,0,3*l,2*l),n.setRenderTarget(e),n.render(o,Ms)}_applyPMREM(t){const e=this._renderer,n=e.autoClear;e.autoClear=!1;for(let r=1;r<this._lodPlanes.length;r++){const s=Math.sqrt(this._sigmas[r]*this._sigmas[r]-this._sigmas[r-1]*this._sigmas[r-1]),o=va[(r-1)%va.length];this._blur(t,r-1,r,s,o)}e.autoClear=n}_blur(t,e,n,r,s){const o=this._pingPongRenderTarget;this._halfBlur(t,o,e,n,r,"latitudinal",s),this._halfBlur(o,t,n,n,r,"longitudinal",s)}_halfBlur(t,e,n,r,s,o,a){const l=this._renderer,c=this._blurMaterial;o!=="latitudinal"&&o!=="longitudinal"&&console.error("blur direction must be either latitudinal or longitudinal!");const u=3,f=new Ft(this._lodPlanes[r],c),m=c.uniforms,p=this._sizeLods[n]-1,v=isFinite(s)?Math.PI/(2*p):2*Math.PI/(2*Fn-1),x=s/v,d=isFinite(s)?1+Math.floor(u*x):Fn;d>Fn&&console.warn(`sigmaRadians, ${s}, is too large and will clip, as it requested ${d} samples when the maximum is set to ${Fn}`);const h=[];let y=0;for(let I=0;I<Fn;++I){const F=I/x,M=Math.exp(-F*F/2);h.push(M),I===0?y+=M:I<d&&(y+=2*M)}for(let I=0;I<h.length;I++)h[I]=h[I]/y;m.envMap.value=t.texture,m.samples.value=d,m.weights.value=h,m.latitudinal.value=o==="latitudinal",a&&(m.poleAxis.value=a);const{_lodMax:_}=this;m.dTheta.value=v,m.mipInt.value=_-n;const w=this._sizeLods[r],D=3*w*(r>_-pi?r-_+pi:0),P=4*(this._cubeSize-w);Mr(e,D,P,3*w,2*w),l.setRenderTarget(e),l.render(f,Ms)}}function wf(i){const t=[],e=[],n=[];let r=i;const s=i-pi+1+ga.length;for(let o=0;o<s;o++){const a=Math.pow(2,r);e.push(a);let l=1/a;o>i-pi?l=ga[o-i+pi-1]:o===0&&(l=0),n.push(l);const c=1/(a-2),u=-c,f=1+c,m=[u,u,f,u,f,f,u,u,f,f,u,f],p=6,v=6,x=3,d=2,h=1,y=new Float32Array(x*v*p),_=new Float32Array(d*v*p),w=new Float32Array(h*v*p);for(let P=0;P<p;P++){const I=P%3*2/3-1,F=P>2?0:-1,M=[I,F,0,I+2/3,F,0,I+2/3,F+1,0,I,F,0,I+2/3,F+1,0,I,F+1,0];y.set(M,x*v*P),_.set(m,d*v*P);const A=[P,P,P,P,P,P];w.set(A,h*v*P)}const D=new Jt;D.setAttribute("position",new fe(y,x)),D.setAttribute("uv",new fe(_,d)),D.setAttribute("faceIndex",new fe(w,h)),t.push(D),r>pi&&r--}return{lodPlanes:t,sizeLods:e,sigmas:n}}function xa(i,t,e){const n=new Ke(i,t,e);return n.texture.mapping=kr,n.texture.name="PMREM.cubeUv",n.scissorTest=!0,n}function Mr(i,t,e,n,r){i.viewport.set(t,e,n,r),i.scissor.set(t,e,n,r)}function Af(i,t,e){const n=new Float32Array(Fn),r=new W(0,1,0);return new Ee({name:"SphericalGaussianBlur",defines:{n:Fn,CUBEUV_TEXEL_WIDTH:1/t,CUBEUV_TEXEL_HEIGHT:1/e,CUBEUV_MAX_MIP:`${i}.0`},uniforms:{envMap:{value:null},samples:{value:1},weights:{value:n},latitudinal:{value:!1},dTheta:{value:0},mipInt:{value:0},poleAxis:{value:r}},vertexShader:io(),fragmentShader:`

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
		`,blending:hn,depthTest:!1,depthWrite:!1})}function Ma(){return new Ee({name:"EquirectangularToCubeUV",uniforms:{envMap:{value:null}},vertexShader:io(),fragmentShader:`

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
		`,blending:hn,depthTest:!1,depthWrite:!1})}function ya(){return new Ee({name:"CubemapToCubeUV",uniforms:{envMap:{value:null},flipEnvMap:{value:-1}},vertexShader:io(),fragmentShader:`

			precision mediump float;
			precision mediump int;

			uniform float flipEnvMap;

			varying vec3 vOutputDirection;

			uniform samplerCube envMap;

			void main() {

				gl_FragColor = textureCube( envMap, vec3( flipEnvMap * vOutputDirection.x, vOutputDirection.yz ) );

			}
		`,blending:hn,depthTest:!1,depthWrite:!1})}function io(){return`

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
	`}function Rf(i){let t=new WeakMap,e=null;function n(a){if(a&&a.isTexture){const l=a.mapping,c=l===Bs||l===zs,u=l===xi||l===Mi;if(c||u)if(a.isRenderTargetTexture&&a.needsPMREMUpdate===!0){a.needsPMREMUpdate=!1;let f=t.get(a);return e===null&&(e=new Ws(i)),f=c?e.fromEquirectangular(a,f):e.fromCubemap(a,f),t.set(a,f),f.texture}else{if(t.has(a))return t.get(a).texture;{const f=a.image;if(c&&f&&f.height>0||u&&f&&r(f)){e===null&&(e=new Ws(i));const m=c?e.fromEquirectangular(a):e.fromCubemap(a);return t.set(a,m),a.addEventListener("dispose",s),m.texture}else return null}}}return a}function r(a){let l=0;const c=6;for(let u=0;u<c;u++)a[u]!==void 0&&l++;return l===c}function s(a){const l=a.target;l.removeEventListener("dispose",s);const c=t.get(l);c!==void 0&&(t.delete(l),c.dispose())}function o(){t=new WeakMap,e!==null&&(e.dispose(),e=null)}return{get:n,dispose:o}}function Cf(i){const t={};function e(n){if(t[n]!==void 0)return t[n];let r;switch(n){case"WEBGL_depth_texture":r=i.getExtension("WEBGL_depth_texture")||i.getExtension("MOZ_WEBGL_depth_texture")||i.getExtension("WEBKIT_WEBGL_depth_texture");break;case"EXT_texture_filter_anisotropic":r=i.getExtension("EXT_texture_filter_anisotropic")||i.getExtension("MOZ_EXT_texture_filter_anisotropic")||i.getExtension("WEBKIT_EXT_texture_filter_anisotropic");break;case"WEBGL_compressed_texture_s3tc":r=i.getExtension("WEBGL_compressed_texture_s3tc")||i.getExtension("MOZ_WEBGL_compressed_texture_s3tc")||i.getExtension("WEBKIT_WEBGL_compressed_texture_s3tc");break;case"WEBGL_compressed_texture_pvrtc":r=i.getExtension("WEBGL_compressed_texture_pvrtc")||i.getExtension("WEBKIT_WEBGL_compressed_texture_pvrtc");break;default:r=i.getExtension(n)}return t[n]=r,r}return{has:function(n){return e(n)!==null},init:function(n){n.isWebGL2?(e("EXT_color_buffer_float"),e("WEBGL_clip_cull_distance")):(e("WEBGL_depth_texture"),e("OES_texture_float"),e("OES_texture_half_float"),e("OES_texture_half_float_linear"),e("OES_standard_derivatives"),e("OES_element_index_uint"),e("OES_vertex_array_object"),e("ANGLE_instanced_arrays")),e("OES_texture_float_linear"),e("EXT_color_buffer_half_float"),e("WEBGL_multisampled_render_to_texture")},get:function(n){const r=e(n);return r===null&&console.warn("THREE.WebGLRenderer: "+n+" extension not supported."),r}}}function Pf(i,t,e,n){const r={},s=new WeakMap;function o(f){const m=f.target;m.index!==null&&t.remove(m.index);for(const v in m.attributes)t.remove(m.attributes[v]);for(const v in m.morphAttributes){const x=m.morphAttributes[v];for(let d=0,h=x.length;d<h;d++)t.remove(x[d])}m.removeEventListener("dispose",o),delete r[m.id];const p=s.get(m);p&&(t.remove(p),s.delete(m)),n.releaseStatesOfGeometry(m),m.isInstancedBufferGeometry===!0&&delete m._maxInstanceCount,e.memory.geometries--}function a(f,m){return r[m.id]===!0||(m.addEventListener("dispose",o),r[m.id]=!0,e.memory.geometries++),m}function l(f){const m=f.attributes;for(const v in m)t.update(m[v],i.ARRAY_BUFFER);const p=f.morphAttributes;for(const v in p){const x=p[v];for(let d=0,h=x.length;d<h;d++)t.update(x[d],i.ARRAY_BUFFER)}}function c(f){const m=[],p=f.index,v=f.attributes.position;let x=0;if(p!==null){const y=p.array;x=p.version;for(let _=0,w=y.length;_<w;_+=3){const D=y[_+0],P=y[_+1],I=y[_+2];m.push(D,P,P,I,I,D)}}else if(v!==void 0){const y=v.array;x=v.version;for(let _=0,w=y.length/3-1;_<w;_+=3){const D=_+0,P=_+1,I=_+2;m.push(D,P,P,I,I,D)}}else return;const d=new(Al(m)?Il:Dl)(m,1);d.version=x;const h=s.get(f);h&&t.remove(h),s.set(f,d)}function u(f){const m=s.get(f);if(m){const p=f.index;p!==null&&m.version<p.version&&c(f)}else c(f);return s.get(f)}return{get:a,update:l,getWireframeAttribute:u}}function Lf(i,t,e,n){const r=n.isWebGL2;let s;function o(p){s=p}let a,l;function c(p){a=p.type,l=p.bytesPerElement}function u(p,v){i.drawElements(s,v,a,p*l),e.update(v,s,1)}function f(p,v,x){if(x===0)return;let d,h;if(r)d=i,h="drawElementsInstanced";else if(d=t.get("ANGLE_instanced_arrays"),h="drawElementsInstancedANGLE",d===null){console.error("THREE.WebGLIndexedBufferRenderer: using THREE.InstancedBufferGeometry but hardware does not support extension ANGLE_instanced_arrays.");return}d[h](s,v,a,p*l,x),e.update(v,s,x)}function m(p,v,x){if(x===0)return;const d=t.get("WEBGL_multi_draw");if(d===null)for(let h=0;h<x;h++)this.render(p[h]/l,v[h]);else{d.multiDrawElementsWEBGL(s,v,0,a,p,0,x);let h=0;for(let y=0;y<x;y++)h+=v[y];e.update(h,s,1)}}this.setMode=o,this.setIndex=c,this.render=u,this.renderInstances=f,this.renderMultiDraw=m}function Df(i){const t={geometries:0,textures:0},e={frame:0,calls:0,triangles:0,points:0,lines:0};function n(s,o,a){switch(e.calls++,o){case i.TRIANGLES:e.triangles+=a*(s/3);break;case i.LINES:e.lines+=a*(s/2);break;case i.LINE_STRIP:e.lines+=a*(s-1);break;case i.LINE_LOOP:e.lines+=a*s;break;case i.POINTS:e.points+=a*s;break;default:console.error("THREE.WebGLInfo: Unknown draw mode:",o);break}}function r(){e.calls=0,e.triangles=0,e.points=0,e.lines=0}return{memory:t,render:e,programs:null,autoReset:!0,reset:r,update:n}}function If(i,t){return i[0]-t[0]}function Uf(i,t){return Math.abs(t[1])-Math.abs(i[1])}function Nf(i,t,e){const n={},r=new Float32Array(8),s=new WeakMap,o=new oe,a=[];for(let c=0;c<8;c++)a[c]=[c,0];function l(c,u,f){const m=c.morphTargetInfluences;if(t.isWebGL2===!0){const v=u.morphAttributes.position||u.morphAttributes.normal||u.morphAttributes.color,x=v!==void 0?v.length:0;let d=s.get(u);if(d===void 0||d.count!==x){let E=function(){z.dispose(),s.delete(u),u.removeEventListener("dispose",E)};var p=E;d!==void 0&&d.texture.dispose();const _=u.morphAttributes.position!==void 0,w=u.morphAttributes.normal!==void 0,D=u.morphAttributes.color!==void 0,P=u.morphAttributes.position||[],I=u.morphAttributes.normal||[],F=u.morphAttributes.color||[];let M=0;_===!0&&(M=1),w===!0&&(M=2),D===!0&&(M=3);let A=u.attributes.position.count*M,K=1;A>t.maxTextureSize&&(K=Math.ceil(A/t.maxTextureSize),A=t.maxTextureSize);const O=new Float32Array(A*K*4*x),z=new Pl(O,A,K,x);z.type=bn,z.needsUpdate=!0;const S=M*4;for(let g=0;g<x;g++){const T=P[g],L=I[g],N=F[g],C=A*K*4*g;for(let U=0;U<T.count;U++){const q=U*S;_===!0&&(o.fromBufferAttribute(T,U),O[C+q+0]=o.x,O[C+q+1]=o.y,O[C+q+2]=o.z,O[C+q+3]=0),w===!0&&(o.fromBufferAttribute(L,U),O[C+q+4]=o.x,O[C+q+5]=o.y,O[C+q+6]=o.z,O[C+q+7]=0),D===!0&&(o.fromBufferAttribute(N,U),O[C+q+8]=o.x,O[C+q+9]=o.y,O[C+q+10]=o.z,O[C+q+11]=N.itemSize===4?o.w:1)}}d={count:x,texture:z,size:new wt(A,K)},s.set(u,d),u.addEventListener("dispose",E)}let h=0;for(let _=0;_<m.length;_++)h+=m[_];const y=u.morphTargetsRelative?1:1-h;f.getUniforms().setValue(i,"morphTargetBaseInfluence",y),f.getUniforms().setValue(i,"morphTargetInfluences",m),f.getUniforms().setValue(i,"morphTargetsTexture",d.texture,e),f.getUniforms().setValue(i,"morphTargetsTextureSize",d.size)}else{const v=m===void 0?0:m.length;let x=n[u.id];if(x===void 0||x.length!==v){x=[];for(let w=0;w<v;w++)x[w]=[w,0];n[u.id]=x}for(let w=0;w<v;w++){const D=x[w];D[0]=w,D[1]=m[w]}x.sort(Uf);for(let w=0;w<8;w++)w<v&&x[w][1]?(a[w][0]=x[w][0],a[w][1]=x[w][1]):(a[w][0]=Number.MAX_SAFE_INTEGER,a[w][1]=0);a.sort(If);const d=u.morphAttributes.position,h=u.morphAttributes.normal;let y=0;for(let w=0;w<8;w++){const D=a[w],P=D[0],I=D[1];P!==Number.MAX_SAFE_INTEGER&&I?(d&&u.getAttribute("morphTarget"+w)!==d[P]&&u.setAttribute("morphTarget"+w,d[P]),h&&u.getAttribute("morphNormal"+w)!==h[P]&&u.setAttribute("morphNormal"+w,h[P]),r[w]=I,y+=I):(d&&u.hasAttribute("morphTarget"+w)===!0&&u.deleteAttribute("morphTarget"+w),h&&u.hasAttribute("morphNormal"+w)===!0&&u.deleteAttribute("morphNormal"+w),r[w]=0)}const _=u.morphTargetsRelative?1:1-y;f.getUniforms().setValue(i,"morphTargetBaseInfluence",_),f.getUniforms().setValue(i,"morphTargetInfluences",r)}}return{update:l}}function Of(i,t,e,n){let r=new WeakMap;function s(l){const c=n.render.frame,u=l.geometry,f=t.get(l,u);if(r.get(f)!==c&&(t.update(f),r.set(f,c)),l.isInstancedMesh&&(l.hasEventListener("dispose",a)===!1&&l.addEventListener("dispose",a),r.get(l)!==c&&(e.update(l.instanceMatrix,i.ARRAY_BUFFER),l.instanceColor!==null&&e.update(l.instanceColor,i.ARRAY_BUFFER),r.set(l,c))),l.isSkinnedMesh){const m=l.skeleton;r.get(m)!==c&&(m.update(),r.set(m,c))}return f}function o(){r=new WeakMap}function a(l){const c=l.target;c.removeEventListener("dispose",a),e.remove(c.instanceMatrix),c.instanceColor!==null&&e.remove(c.instanceColor)}return{update:s,dispose:o}}class Bl extends we{constructor(t,e,n,r,s,o,a,l,c,u){if(u=u!==void 0?u:zn,u!==zn&&u!==Si)throw new Error("DepthTexture format must be either THREE.DepthFormat or THREE.DepthStencilFormat");n===void 0&&u===zn&&(n=Sn),n===void 0&&u===Si&&(n=Bn),super(null,r,s,o,a,l,u,n,c),this.isDepthTexture=!0,this.image={width:t,height:e},this.magFilter=a!==void 0?a:Le,this.minFilter=l!==void 0?l:Le,this.flipY=!1,this.generateMipmaps=!1,this.compareFunction=null}copy(t){return super.copy(t),this.compareFunction=t.compareFunction,this}toJSON(t){const e=super.toJSON(t);return this.compareFunction!==null&&(e.compareFunction=this.compareFunction),e}}const zl=new we,Gl=new Bl(1,1);Gl.compareFunction=Tl;const kl=new Pl,Hl=new Mu,Vl=new Ol,Sa=[],ba=[],Ea=new Float32Array(16),Ta=new Float32Array(9),wa=new Float32Array(4);function wi(i,t,e){const n=i[0];if(n<=0||n>0)return i;const r=t*e;let s=Sa[r];if(s===void 0&&(s=new Float32Array(r),Sa[r]=s),t!==0){n.toArray(s,0);for(let o=1,a=0;o!==t;++o)a+=e,i[o].toArray(s,a)}return s}function me(i,t){if(i.length!==t.length)return!1;for(let e=0,n=i.length;e<n;e++)if(i[e]!==t[e])return!1;return!0}function ge(i,t){for(let e=0,n=t.length;e<n;e++)i[e]=t[e]}function Vr(i,t){let e=ba[t];e===void 0&&(e=new Int32Array(t),ba[t]=e);for(let n=0;n!==t;++n)e[n]=i.allocateTextureUnit();return e}function Ff(i,t){const e=this.cache;e[0]!==t&&(i.uniform1f(this.addr,t),e[0]=t)}function Bf(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y)&&(i.uniform2f(this.addr,t.x,t.y),e[0]=t.x,e[1]=t.y);else{if(me(e,t))return;i.uniform2fv(this.addr,t),ge(e,t)}}function zf(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z)&&(i.uniform3f(this.addr,t.x,t.y,t.z),e[0]=t.x,e[1]=t.y,e[2]=t.z);else if(t.r!==void 0)(e[0]!==t.r||e[1]!==t.g||e[2]!==t.b)&&(i.uniform3f(this.addr,t.r,t.g,t.b),e[0]=t.r,e[1]=t.g,e[2]=t.b);else{if(me(e,t))return;i.uniform3fv(this.addr,t),ge(e,t)}}function Gf(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z||e[3]!==t.w)&&(i.uniform4f(this.addr,t.x,t.y,t.z,t.w),e[0]=t.x,e[1]=t.y,e[2]=t.z,e[3]=t.w);else{if(me(e,t))return;i.uniform4fv(this.addr,t),ge(e,t)}}function kf(i,t){const e=this.cache,n=t.elements;if(n===void 0){if(me(e,t))return;i.uniformMatrix2fv(this.addr,!1,t),ge(e,t)}else{if(me(e,n))return;wa.set(n),i.uniformMatrix2fv(this.addr,!1,wa),ge(e,n)}}function Hf(i,t){const e=this.cache,n=t.elements;if(n===void 0){if(me(e,t))return;i.uniformMatrix3fv(this.addr,!1,t),ge(e,t)}else{if(me(e,n))return;Ta.set(n),i.uniformMatrix3fv(this.addr,!1,Ta),ge(e,n)}}function Vf(i,t){const e=this.cache,n=t.elements;if(n===void 0){if(me(e,t))return;i.uniformMatrix4fv(this.addr,!1,t),ge(e,t)}else{if(me(e,n))return;Ea.set(n),i.uniformMatrix4fv(this.addr,!1,Ea),ge(e,n)}}function Wf(i,t){const e=this.cache;e[0]!==t&&(i.uniform1i(this.addr,t),e[0]=t)}function Xf(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y)&&(i.uniform2i(this.addr,t.x,t.y),e[0]=t.x,e[1]=t.y);else{if(me(e,t))return;i.uniform2iv(this.addr,t),ge(e,t)}}function qf(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z)&&(i.uniform3i(this.addr,t.x,t.y,t.z),e[0]=t.x,e[1]=t.y,e[2]=t.z);else{if(me(e,t))return;i.uniform3iv(this.addr,t),ge(e,t)}}function Yf(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z||e[3]!==t.w)&&(i.uniform4i(this.addr,t.x,t.y,t.z,t.w),e[0]=t.x,e[1]=t.y,e[2]=t.z,e[3]=t.w);else{if(me(e,t))return;i.uniform4iv(this.addr,t),ge(e,t)}}function jf(i,t){const e=this.cache;e[0]!==t&&(i.uniform1ui(this.addr,t),e[0]=t)}function $f(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y)&&(i.uniform2ui(this.addr,t.x,t.y),e[0]=t.x,e[1]=t.y);else{if(me(e,t))return;i.uniform2uiv(this.addr,t),ge(e,t)}}function Kf(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z)&&(i.uniform3ui(this.addr,t.x,t.y,t.z),e[0]=t.x,e[1]=t.y,e[2]=t.z);else{if(me(e,t))return;i.uniform3uiv(this.addr,t),ge(e,t)}}function Zf(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z||e[3]!==t.w)&&(i.uniform4ui(this.addr,t.x,t.y,t.z,t.w),e[0]=t.x,e[1]=t.y,e[2]=t.z,e[3]=t.w);else{if(me(e,t))return;i.uniform4uiv(this.addr,t),ge(e,t)}}function Jf(i,t,e){const n=this.cache,r=e.allocateTextureUnit();n[0]!==r&&(i.uniform1i(this.addr,r),n[0]=r);const s=this.type===i.SAMPLER_2D_SHADOW?Gl:zl;e.setTexture2D(t||s,r)}function Qf(i,t,e){const n=this.cache,r=e.allocateTextureUnit();n[0]!==r&&(i.uniform1i(this.addr,r),n[0]=r),e.setTexture3D(t||Hl,r)}function tp(i,t,e){const n=this.cache,r=e.allocateTextureUnit();n[0]!==r&&(i.uniform1i(this.addr,r),n[0]=r),e.setTextureCube(t||Vl,r)}function ep(i,t,e){const n=this.cache,r=e.allocateTextureUnit();n[0]!==r&&(i.uniform1i(this.addr,r),n[0]=r),e.setTexture2DArray(t||kl,r)}function np(i){switch(i){case 5126:return Ff;case 35664:return Bf;case 35665:return zf;case 35666:return Gf;case 35674:return kf;case 35675:return Hf;case 35676:return Vf;case 5124:case 35670:return Wf;case 35667:case 35671:return Xf;case 35668:case 35672:return qf;case 35669:case 35673:return Yf;case 5125:return jf;case 36294:return $f;case 36295:return Kf;case 36296:return Zf;case 35678:case 36198:case 36298:case 36306:case 35682:return Jf;case 35679:case 36299:case 36307:return Qf;case 35680:case 36300:case 36308:case 36293:return tp;case 36289:case 36303:case 36311:case 36292:return ep}}function ip(i,t){i.uniform1fv(this.addr,t)}function rp(i,t){const e=wi(t,this.size,2);i.uniform2fv(this.addr,e)}function sp(i,t){const e=wi(t,this.size,3);i.uniform3fv(this.addr,e)}function op(i,t){const e=wi(t,this.size,4);i.uniform4fv(this.addr,e)}function ap(i,t){const e=wi(t,this.size,4);i.uniformMatrix2fv(this.addr,!1,e)}function lp(i,t){const e=wi(t,this.size,9);i.uniformMatrix3fv(this.addr,!1,e)}function cp(i,t){const e=wi(t,this.size,16);i.uniformMatrix4fv(this.addr,!1,e)}function up(i,t){i.uniform1iv(this.addr,t)}function hp(i,t){i.uniform2iv(this.addr,t)}function dp(i,t){i.uniform3iv(this.addr,t)}function fp(i,t){i.uniform4iv(this.addr,t)}function pp(i,t){i.uniform1uiv(this.addr,t)}function mp(i,t){i.uniform2uiv(this.addr,t)}function gp(i,t){i.uniform3uiv(this.addr,t)}function _p(i,t){i.uniform4uiv(this.addr,t)}function vp(i,t,e){const n=this.cache,r=t.length,s=Vr(e,r);me(n,s)||(i.uniform1iv(this.addr,s),ge(n,s));for(let o=0;o!==r;++o)e.setTexture2D(t[o]||zl,s[o])}function xp(i,t,e){const n=this.cache,r=t.length,s=Vr(e,r);me(n,s)||(i.uniform1iv(this.addr,s),ge(n,s));for(let o=0;o!==r;++o)e.setTexture3D(t[o]||Hl,s[o])}function Mp(i,t,e){const n=this.cache,r=t.length,s=Vr(e,r);me(n,s)||(i.uniform1iv(this.addr,s),ge(n,s));for(let o=0;o!==r;++o)e.setTextureCube(t[o]||Vl,s[o])}function yp(i,t,e){const n=this.cache,r=t.length,s=Vr(e,r);me(n,s)||(i.uniform1iv(this.addr,s),ge(n,s));for(let o=0;o!==r;++o)e.setTexture2DArray(t[o]||kl,s[o])}function Sp(i){switch(i){case 5126:return ip;case 35664:return rp;case 35665:return sp;case 35666:return op;case 35674:return ap;case 35675:return lp;case 35676:return cp;case 5124:case 35670:return up;case 35667:case 35671:return hp;case 35668:case 35672:return dp;case 35669:case 35673:return fp;case 5125:return pp;case 36294:return mp;case 36295:return gp;case 36296:return _p;case 35678:case 36198:case 36298:case 36306:case 35682:return vp;case 35679:case 36299:case 36307:return xp;case 35680:case 36300:case 36308:case 36293:return Mp;case 36289:case 36303:case 36311:case 36292:return yp}}class bp{constructor(t,e,n){this.id=t,this.addr=n,this.cache=[],this.type=e.type,this.setValue=np(e.type)}}class Ep{constructor(t,e,n){this.id=t,this.addr=n,this.cache=[],this.type=e.type,this.size=e.size,this.setValue=Sp(e.type)}}class Tp{constructor(t){this.id=t,this.seq=[],this.map={}}setValue(t,e,n){const r=this.seq;for(let s=0,o=r.length;s!==o;++s){const a=r[s];a.setValue(t,e[a.id],n)}}}const Es=/(\w+)(\])?(\[|\.)?/g;function Aa(i,t){i.seq.push(t),i.map[t.id]=t}function wp(i,t,e){const n=i.name,r=n.length;for(Es.lastIndex=0;;){const s=Es.exec(n),o=Es.lastIndex;let a=s[1];const l=s[2]==="]",c=s[3];if(l&&(a=a|0),c===void 0||c==="["&&o+2===r){Aa(e,c===void 0?new bp(a,i,t):new Ep(a,i,t));break}else{let f=e.map[a];f===void 0&&(f=new Tp(a),Aa(e,f)),e=f}}}class Pr{constructor(t,e){this.seq=[],this.map={};const n=t.getProgramParameter(e,t.ACTIVE_UNIFORMS);for(let r=0;r<n;++r){const s=t.getActiveUniform(e,r),o=t.getUniformLocation(e,s.name);wp(s,o,this)}}setValue(t,e,n,r){const s=this.map[e];s!==void 0&&s.setValue(t,n,r)}setOptional(t,e,n){const r=e[n];r!==void 0&&this.setValue(t,n,r)}static upload(t,e,n,r){for(let s=0,o=e.length;s!==o;++s){const a=e[s],l=n[a.id];l.needsUpdate!==!1&&a.setValue(t,l.value,r)}}static seqWithValue(t,e){const n=[];for(let r=0,s=t.length;r!==s;++r){const o=t[r];o.id in e&&n.push(o)}return n}}function Ra(i,t,e){const n=i.createShader(t);return i.shaderSource(n,e),i.compileShader(n),n}const Ap=37297;let Rp=0;function Cp(i,t){const e=i.split(`
`),n=[],r=Math.max(t-6,0),s=Math.min(t+6,e.length);for(let o=r;o<s;o++){const a=o+1;n.push(`${a===t?">":" "} ${a}: ${e[o]}`)}return n.join(`
`)}function Pp(i){const t=te.getPrimaries(te.workingColorSpace),e=te.getPrimaries(i);let n;switch(t===e?n="":t===Ur&&e===Ir?n="LinearDisplayP3ToLinearSRGB":t===Ir&&e===Ur&&(n="LinearSRGBToLinearDisplayP3"),i){case pn:case Hr:return[n,"LinearTransferOETF"];case ce:case Js:return[n,"sRGBTransferOETF"];default:return console.warn("THREE.WebGLProgram: Unsupported color space:",i),[n,"LinearTransferOETF"]}}function Ca(i,t,e){const n=i.getShaderParameter(t,i.COMPILE_STATUS),r=i.getShaderInfoLog(t).trim();if(n&&r==="")return"";const s=/ERROR: 0:(\d+)/.exec(r);if(s){const o=parseInt(s[1]);return e.toUpperCase()+`

`+r+`

`+Cp(i.getShaderSource(t),o)}else return r}function Lp(i,t){const e=Pp(t);return`vec4 ${i}( vec4 value ) { return ${e[0]}( ${e[1]}( value ) ); }`}function Dp(i,t){let e;switch(t){case hl:e="Linear";break;case dl:e="Reinhard";break;case fl:e="OptimizedCineon";break;case Ks:e="ACESFilmic";break;case pl:e="AgX";break;case Nc:e="Custom";break;default:console.warn("THREE.WebGLProgram: Unsupported toneMapping:",t),e="Linear"}return"vec3 "+i+"( vec3 color ) { return "+e+"ToneMapping( color ); }"}function Ip(i){return[i.extensionDerivatives||i.envMapCubeUVHeight||i.bumpMap||i.normalMapTangentSpace||i.clearcoatNormalMap||i.flatShading||i.shaderID==="physical"?"#extension GL_OES_standard_derivatives : enable":"",(i.extensionFragDepth||i.logarithmicDepthBuffer)&&i.rendererExtensionFragDepth?"#extension GL_EXT_frag_depth : enable":"",i.extensionDrawBuffers&&i.rendererExtensionDrawBuffers?"#extension GL_EXT_draw_buffers : require":"",(i.extensionShaderTextureLOD||i.envMap||i.transmission)&&i.rendererExtensionShaderTextureLod?"#extension GL_EXT_shader_texture_lod : enable":""].filter(mi).join(`
`)}function Up(i){return[i.extensionClipCullDistance?"#extension GL_ANGLE_clip_cull_distance : require":""].filter(mi).join(`
`)}function Np(i){const t=[];for(const e in i){const n=i[e];n!==!1&&t.push("#define "+e+" "+n)}return t.join(`
`)}function Op(i,t){const e={},n=i.getProgramParameter(t,i.ACTIVE_ATTRIBUTES);for(let r=0;r<n;r++){const s=i.getActiveAttrib(t,r),o=s.name;let a=1;s.type===i.FLOAT_MAT2&&(a=2),s.type===i.FLOAT_MAT3&&(a=3),s.type===i.FLOAT_MAT4&&(a=4),e[o]={type:s.type,location:i.getAttribLocation(t,o),locationSize:a}}return e}function mi(i){return i!==""}function Pa(i,t){const e=t.numSpotLightShadows+t.numSpotLightMaps-t.numSpotLightShadowsWithMaps;return i.replace(/NUM_DIR_LIGHTS/g,t.numDirLights).replace(/NUM_SPOT_LIGHTS/g,t.numSpotLights).replace(/NUM_SPOT_LIGHT_MAPS/g,t.numSpotLightMaps).replace(/NUM_SPOT_LIGHT_COORDS/g,e).replace(/NUM_RECT_AREA_LIGHTS/g,t.numRectAreaLights).replace(/NUM_POINT_LIGHTS/g,t.numPointLights).replace(/NUM_HEMI_LIGHTS/g,t.numHemiLights).replace(/NUM_DIR_LIGHT_SHADOWS/g,t.numDirLightShadows).replace(/NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS/g,t.numSpotLightShadowsWithMaps).replace(/NUM_SPOT_LIGHT_SHADOWS/g,t.numSpotLightShadows).replace(/NUM_POINT_LIGHT_SHADOWS/g,t.numPointLightShadows)}function La(i,t){return i.replace(/NUM_CLIPPING_PLANES/g,t.numClippingPlanes).replace(/UNION_CLIPPING_PLANES/g,t.numClippingPlanes-t.numClipIntersection)}const Fp=/^[ \t]*#include +<([\w\d./]+)>/gm;function Xs(i){return i.replace(Fp,zp)}const Bp=new Map([["encodings_fragment","colorspace_fragment"],["encodings_pars_fragment","colorspace_pars_fragment"],["output_fragment","opaque_fragment"]]);function zp(i,t){let e=Yt[t];if(e===void 0){const n=Bp.get(t);if(n!==void 0)e=Yt[n],console.warn('THREE.WebGLRenderer: Shader chunk "%s" has been deprecated. Use "%s" instead.',t,n);else throw new Error("Can not resolve #include <"+t+">")}return Xs(e)}const Gp=/#pragma unroll_loop_start\s+for\s*\(\s*int\s+i\s*=\s*(\d+)\s*;\s*i\s*<\s*(\d+)\s*;\s*i\s*\+\+\s*\)\s*{([\s\S]+?)}\s+#pragma unroll_loop_end/g;function Da(i){return i.replace(Gp,kp)}function kp(i,t,e,n){let r="";for(let s=parseInt(t);s<parseInt(e);s++)r+=n.replace(/\[\s*i\s*\]/g,"[ "+s+" ]").replace(/UNROLLED_LOOP_INDEX/g,s);return r}function Ia(i){let t="precision "+i.precision+` float;
precision `+i.precision+" int;";return i.precision==="highp"?t+=`
#define HIGH_PRECISION`:i.precision==="mediump"?t+=`
#define MEDIUM_PRECISION`:i.precision==="lowp"&&(t+=`
#define LOW_PRECISION`),t}function Hp(i){let t="SHADOWMAP_TYPE_BASIC";return i.shadowMapType===ll?t="SHADOWMAP_TYPE_PCF":i.shadowMapType===cl?t="SHADOWMAP_TYPE_PCF_SOFT":i.shadowMapType===cn&&(t="SHADOWMAP_TYPE_VSM"),t}function Vp(i){let t="ENVMAP_TYPE_CUBE";if(i.envMap)switch(i.envMapMode){case xi:case Mi:t="ENVMAP_TYPE_CUBE";break;case kr:t="ENVMAP_TYPE_CUBE_UV";break}return t}function Wp(i){let t="ENVMAP_MODE_REFLECTION";if(i.envMap)switch(i.envMapMode){case Mi:t="ENVMAP_MODE_REFRACTION";break}return t}function Xp(i){let t="ENVMAP_BLENDING_NONE";if(i.envMap)switch(i.combine){case ul:t="ENVMAP_BLENDING_MULTIPLY";break;case Ic:t="ENVMAP_BLENDING_MIX";break;case Uc:t="ENVMAP_BLENDING_ADD";break}return t}function qp(i){const t=i.envMapCubeUVHeight;if(t===null)return null;const e=Math.log2(t)-2,n=1/t;return{texelWidth:1/(3*Math.max(Math.pow(2,e),7*16)),texelHeight:n,maxMip:e}}function Yp(i,t,e,n){const r=i.getContext(),s=e.defines;let o=e.vertexShader,a=e.fragmentShader;const l=Hp(e),c=Vp(e),u=Wp(e),f=Xp(e),m=qp(e),p=e.isWebGL2?"":Ip(e),v=Up(e),x=Np(s),d=r.createProgram();let h,y,_=e.glslVersion?"#version "+e.glslVersion+`
`:"";e.isRawShaderMaterial?(h=["#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,x].filter(mi).join(`
`),h.length>0&&(h+=`
`),y=[p,"#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,x].filter(mi).join(`
`),y.length>0&&(y+=`
`)):(h=[Ia(e),"#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,x,e.extensionClipCullDistance?"#define USE_CLIP_DISTANCE":"",e.batching?"#define USE_BATCHING":"",e.instancing?"#define USE_INSTANCING":"",e.instancingColor?"#define USE_INSTANCING_COLOR":"",e.useFog&&e.fog?"#define USE_FOG":"",e.useFog&&e.fogExp2?"#define FOG_EXP2":"",e.map?"#define USE_MAP":"",e.envMap?"#define USE_ENVMAP":"",e.envMap?"#define "+u:"",e.lightMap?"#define USE_LIGHTMAP":"",e.aoMap?"#define USE_AOMAP":"",e.bumpMap?"#define USE_BUMPMAP":"",e.normalMap?"#define USE_NORMALMAP":"",e.normalMapObjectSpace?"#define USE_NORMALMAP_OBJECTSPACE":"",e.normalMapTangentSpace?"#define USE_NORMALMAP_TANGENTSPACE":"",e.displacementMap?"#define USE_DISPLACEMENTMAP":"",e.emissiveMap?"#define USE_EMISSIVEMAP":"",e.anisotropy?"#define USE_ANISOTROPY":"",e.anisotropyMap?"#define USE_ANISOTROPYMAP":"",e.clearcoatMap?"#define USE_CLEARCOATMAP":"",e.clearcoatRoughnessMap?"#define USE_CLEARCOAT_ROUGHNESSMAP":"",e.clearcoatNormalMap?"#define USE_CLEARCOAT_NORMALMAP":"",e.iridescenceMap?"#define USE_IRIDESCENCEMAP":"",e.iridescenceThicknessMap?"#define USE_IRIDESCENCE_THICKNESSMAP":"",e.specularMap?"#define USE_SPECULARMAP":"",e.specularColorMap?"#define USE_SPECULAR_COLORMAP":"",e.specularIntensityMap?"#define USE_SPECULAR_INTENSITYMAP":"",e.roughnessMap?"#define USE_ROUGHNESSMAP":"",e.metalnessMap?"#define USE_METALNESSMAP":"",e.alphaMap?"#define USE_ALPHAMAP":"",e.alphaHash?"#define USE_ALPHAHASH":"",e.transmission?"#define USE_TRANSMISSION":"",e.transmissionMap?"#define USE_TRANSMISSIONMAP":"",e.thicknessMap?"#define USE_THICKNESSMAP":"",e.sheenColorMap?"#define USE_SHEEN_COLORMAP":"",e.sheenRoughnessMap?"#define USE_SHEEN_ROUGHNESSMAP":"",e.mapUv?"#define MAP_UV "+e.mapUv:"",e.alphaMapUv?"#define ALPHAMAP_UV "+e.alphaMapUv:"",e.lightMapUv?"#define LIGHTMAP_UV "+e.lightMapUv:"",e.aoMapUv?"#define AOMAP_UV "+e.aoMapUv:"",e.emissiveMapUv?"#define EMISSIVEMAP_UV "+e.emissiveMapUv:"",e.bumpMapUv?"#define BUMPMAP_UV "+e.bumpMapUv:"",e.normalMapUv?"#define NORMALMAP_UV "+e.normalMapUv:"",e.displacementMapUv?"#define DISPLACEMENTMAP_UV "+e.displacementMapUv:"",e.metalnessMapUv?"#define METALNESSMAP_UV "+e.metalnessMapUv:"",e.roughnessMapUv?"#define ROUGHNESSMAP_UV "+e.roughnessMapUv:"",e.anisotropyMapUv?"#define ANISOTROPYMAP_UV "+e.anisotropyMapUv:"",e.clearcoatMapUv?"#define CLEARCOATMAP_UV "+e.clearcoatMapUv:"",e.clearcoatNormalMapUv?"#define CLEARCOAT_NORMALMAP_UV "+e.clearcoatNormalMapUv:"",e.clearcoatRoughnessMapUv?"#define CLEARCOAT_ROUGHNESSMAP_UV "+e.clearcoatRoughnessMapUv:"",e.iridescenceMapUv?"#define IRIDESCENCEMAP_UV "+e.iridescenceMapUv:"",e.iridescenceThicknessMapUv?"#define IRIDESCENCE_THICKNESSMAP_UV "+e.iridescenceThicknessMapUv:"",e.sheenColorMapUv?"#define SHEEN_COLORMAP_UV "+e.sheenColorMapUv:"",e.sheenRoughnessMapUv?"#define SHEEN_ROUGHNESSMAP_UV "+e.sheenRoughnessMapUv:"",e.specularMapUv?"#define SPECULARMAP_UV "+e.specularMapUv:"",e.specularColorMapUv?"#define SPECULAR_COLORMAP_UV "+e.specularColorMapUv:"",e.specularIntensityMapUv?"#define SPECULAR_INTENSITYMAP_UV "+e.specularIntensityMapUv:"",e.transmissionMapUv?"#define TRANSMISSIONMAP_UV "+e.transmissionMapUv:"",e.thicknessMapUv?"#define THICKNESSMAP_UV "+e.thicknessMapUv:"",e.vertexTangents&&e.flatShading===!1?"#define USE_TANGENT":"",e.vertexColors?"#define USE_COLOR":"",e.vertexAlphas?"#define USE_COLOR_ALPHA":"",e.vertexUv1s?"#define USE_UV1":"",e.vertexUv2s?"#define USE_UV2":"",e.vertexUv3s?"#define USE_UV3":"",e.pointsUvs?"#define USE_POINTS_UV":"",e.flatShading?"#define FLAT_SHADED":"",e.skinning?"#define USE_SKINNING":"",e.morphTargets?"#define USE_MORPHTARGETS":"",e.morphNormals&&e.flatShading===!1?"#define USE_MORPHNORMALS":"",e.morphColors&&e.isWebGL2?"#define USE_MORPHCOLORS":"",e.morphTargetsCount>0&&e.isWebGL2?"#define MORPHTARGETS_TEXTURE":"",e.morphTargetsCount>0&&e.isWebGL2?"#define MORPHTARGETS_TEXTURE_STRIDE "+e.morphTextureStride:"",e.morphTargetsCount>0&&e.isWebGL2?"#define MORPHTARGETS_COUNT "+e.morphTargetsCount:"",e.doubleSided?"#define DOUBLE_SIDED":"",e.flipSided?"#define FLIP_SIDED":"",e.shadowMapEnabled?"#define USE_SHADOWMAP":"",e.shadowMapEnabled?"#define "+l:"",e.sizeAttenuation?"#define USE_SIZEATTENUATION":"",e.numLightProbes>0?"#define USE_LIGHT_PROBES":"",e.useLegacyLights?"#define LEGACY_LIGHTS":"",e.logarithmicDepthBuffer?"#define USE_LOGDEPTHBUF":"",e.logarithmicDepthBuffer&&e.rendererExtensionFragDepth?"#define USE_LOGDEPTHBUF_EXT":"","uniform mat4 modelMatrix;","uniform mat4 modelViewMatrix;","uniform mat4 projectionMatrix;","uniform mat4 viewMatrix;","uniform mat3 normalMatrix;","uniform vec3 cameraPosition;","uniform bool isOrthographic;","#ifdef USE_INSTANCING","	attribute mat4 instanceMatrix;","#endif","#ifdef USE_INSTANCING_COLOR","	attribute vec3 instanceColor;","#endif","attribute vec3 position;","attribute vec3 normal;","attribute vec2 uv;","#ifdef USE_UV1","	attribute vec2 uv1;","#endif","#ifdef USE_UV2","	attribute vec2 uv2;","#endif","#ifdef USE_UV3","	attribute vec2 uv3;","#endif","#ifdef USE_TANGENT","	attribute vec4 tangent;","#endif","#if defined( USE_COLOR_ALPHA )","	attribute vec4 color;","#elif defined( USE_COLOR )","	attribute vec3 color;","#endif","#if ( defined( USE_MORPHTARGETS ) && ! defined( MORPHTARGETS_TEXTURE ) )","	attribute vec3 morphTarget0;","	attribute vec3 morphTarget1;","	attribute vec3 morphTarget2;","	attribute vec3 morphTarget3;","	#ifdef USE_MORPHNORMALS","		attribute vec3 morphNormal0;","		attribute vec3 morphNormal1;","		attribute vec3 morphNormal2;","		attribute vec3 morphNormal3;","	#else","		attribute vec3 morphTarget4;","		attribute vec3 morphTarget5;","		attribute vec3 morphTarget6;","		attribute vec3 morphTarget7;","	#endif","#endif","#ifdef USE_SKINNING","	attribute vec4 skinIndex;","	attribute vec4 skinWeight;","#endif",`
`].filter(mi).join(`
`),y=[p,Ia(e),"#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,x,e.useFog&&e.fog?"#define USE_FOG":"",e.useFog&&e.fogExp2?"#define FOG_EXP2":"",e.map?"#define USE_MAP":"",e.matcap?"#define USE_MATCAP":"",e.envMap?"#define USE_ENVMAP":"",e.envMap?"#define "+c:"",e.envMap?"#define "+u:"",e.envMap?"#define "+f:"",m?"#define CUBEUV_TEXEL_WIDTH "+m.texelWidth:"",m?"#define CUBEUV_TEXEL_HEIGHT "+m.texelHeight:"",m?"#define CUBEUV_MAX_MIP "+m.maxMip+".0":"",e.lightMap?"#define USE_LIGHTMAP":"",e.aoMap?"#define USE_AOMAP":"",e.bumpMap?"#define USE_BUMPMAP":"",e.normalMap?"#define USE_NORMALMAP":"",e.normalMapObjectSpace?"#define USE_NORMALMAP_OBJECTSPACE":"",e.normalMapTangentSpace?"#define USE_NORMALMAP_TANGENTSPACE":"",e.emissiveMap?"#define USE_EMISSIVEMAP":"",e.anisotropy?"#define USE_ANISOTROPY":"",e.anisotropyMap?"#define USE_ANISOTROPYMAP":"",e.clearcoat?"#define USE_CLEARCOAT":"",e.clearcoatMap?"#define USE_CLEARCOATMAP":"",e.clearcoatRoughnessMap?"#define USE_CLEARCOAT_ROUGHNESSMAP":"",e.clearcoatNormalMap?"#define USE_CLEARCOAT_NORMALMAP":"",e.iridescence?"#define USE_IRIDESCENCE":"",e.iridescenceMap?"#define USE_IRIDESCENCEMAP":"",e.iridescenceThicknessMap?"#define USE_IRIDESCENCE_THICKNESSMAP":"",e.specularMap?"#define USE_SPECULARMAP":"",e.specularColorMap?"#define USE_SPECULAR_COLORMAP":"",e.specularIntensityMap?"#define USE_SPECULAR_INTENSITYMAP":"",e.roughnessMap?"#define USE_ROUGHNESSMAP":"",e.metalnessMap?"#define USE_METALNESSMAP":"",e.alphaMap?"#define USE_ALPHAMAP":"",e.alphaTest?"#define USE_ALPHATEST":"",e.alphaHash?"#define USE_ALPHAHASH":"",e.sheen?"#define USE_SHEEN":"",e.sheenColorMap?"#define USE_SHEEN_COLORMAP":"",e.sheenRoughnessMap?"#define USE_SHEEN_ROUGHNESSMAP":"",e.transmission?"#define USE_TRANSMISSION":"",e.transmissionMap?"#define USE_TRANSMISSIONMAP":"",e.thicknessMap?"#define USE_THICKNESSMAP":"",e.vertexTangents&&e.flatShading===!1?"#define USE_TANGENT":"",e.vertexColors||e.instancingColor?"#define USE_COLOR":"",e.vertexAlphas?"#define USE_COLOR_ALPHA":"",e.vertexUv1s?"#define USE_UV1":"",e.vertexUv2s?"#define USE_UV2":"",e.vertexUv3s?"#define USE_UV3":"",e.pointsUvs?"#define USE_POINTS_UV":"",e.gradientMap?"#define USE_GRADIENTMAP":"",e.flatShading?"#define FLAT_SHADED":"",e.doubleSided?"#define DOUBLE_SIDED":"",e.flipSided?"#define FLIP_SIDED":"",e.shadowMapEnabled?"#define USE_SHADOWMAP":"",e.shadowMapEnabled?"#define "+l:"",e.premultipliedAlpha?"#define PREMULTIPLIED_ALPHA":"",e.numLightProbes>0?"#define USE_LIGHT_PROBES":"",e.useLegacyLights?"#define LEGACY_LIGHTS":"",e.decodeVideoTexture?"#define DECODE_VIDEO_TEXTURE":"",e.logarithmicDepthBuffer?"#define USE_LOGDEPTHBUF":"",e.logarithmicDepthBuffer&&e.rendererExtensionFragDepth?"#define USE_LOGDEPTHBUF_EXT":"","uniform mat4 viewMatrix;","uniform vec3 cameraPosition;","uniform bool isOrthographic;",e.toneMapping!==En?"#define TONE_MAPPING":"",e.toneMapping!==En?Yt.tonemapping_pars_fragment:"",e.toneMapping!==En?Dp("toneMapping",e.toneMapping):"",e.dithering?"#define DITHERING":"",e.opaque?"#define OPAQUE":"",Yt.colorspace_pars_fragment,Lp("linearToOutputTexel",e.outputColorSpace),e.useDepthPacking?"#define DEPTH_PACKING "+e.depthPacking:"",`
`].filter(mi).join(`
`)),o=Xs(o),o=Pa(o,e),o=La(o,e),a=Xs(a),a=Pa(a,e),a=La(a,e),o=Da(o),a=Da(a),e.isWebGL2&&e.isRawShaderMaterial!==!0&&(_=`#version 300 es
`,h=[v,"precision mediump sampler2DArray;","#define attribute in","#define varying out","#define texture2D texture"].join(`
`)+`
`+h,y=["precision mediump sampler2DArray;","#define varying in",e.glslVersion===Jo?"":"layout(location = 0) out highp vec4 pc_fragColor;",e.glslVersion===Jo?"":"#define gl_FragColor pc_fragColor","#define gl_FragDepthEXT gl_FragDepth","#define texture2D texture","#define textureCube texture","#define texture2DProj textureProj","#define texture2DLodEXT textureLod","#define texture2DProjLodEXT textureProjLod","#define textureCubeLodEXT textureLod","#define texture2DGradEXT textureGrad","#define texture2DProjGradEXT textureProjGrad","#define textureCubeGradEXT textureGrad"].join(`
`)+`
`+y);const w=_+h+o,D=_+y+a,P=Ra(r,r.VERTEX_SHADER,w),I=Ra(r,r.FRAGMENT_SHADER,D);r.attachShader(d,P),r.attachShader(d,I),e.index0AttributeName!==void 0?r.bindAttribLocation(d,0,e.index0AttributeName):e.morphTargets===!0&&r.bindAttribLocation(d,0,"position"),r.linkProgram(d);function F(O){if(i.debug.checkShaderErrors){const z=r.getProgramInfoLog(d).trim(),S=r.getShaderInfoLog(P).trim(),E=r.getShaderInfoLog(I).trim();let g=!0,T=!0;if(r.getProgramParameter(d,r.LINK_STATUS)===!1)if(g=!1,typeof i.debug.onShaderError=="function")i.debug.onShaderError(r,d,P,I);else{const L=Ca(r,P,"vertex"),N=Ca(r,I,"fragment");console.error("THREE.WebGLProgram: Shader Error "+r.getError()+" - VALIDATE_STATUS "+r.getProgramParameter(d,r.VALIDATE_STATUS)+`

Program Info Log: `+z+`
`+L+`
`+N)}else z!==""?console.warn("THREE.WebGLProgram: Program Info Log:",z):(S===""||E==="")&&(T=!1);T&&(O.diagnostics={runnable:g,programLog:z,vertexShader:{log:S,prefix:h},fragmentShader:{log:E,prefix:y}})}r.deleteShader(P),r.deleteShader(I),M=new Pr(r,d),A=Op(r,d)}let M;this.getUniforms=function(){return M===void 0&&F(this),M};let A;this.getAttributes=function(){return A===void 0&&F(this),A};let K=e.rendererExtensionParallelShaderCompile===!1;return this.isReady=function(){return K===!1&&(K=r.getProgramParameter(d,Ap)),K},this.destroy=function(){n.releaseStatesOfProgram(this),r.deleteProgram(d),this.program=void 0},this.type=e.shaderType,this.name=e.shaderName,this.id=Rp++,this.cacheKey=t,this.usedTimes=1,this.program=d,this.vertexShader=P,this.fragmentShader=I,this}let jp=0;class $p{constructor(){this.shaderCache=new Map,this.materialCache=new Map}update(t){const e=t.vertexShader,n=t.fragmentShader,r=this._getShaderStage(e),s=this._getShaderStage(n),o=this._getShaderCacheForMaterial(t);return o.has(r)===!1&&(o.add(r),r.usedTimes++),o.has(s)===!1&&(o.add(s),s.usedTimes++),this}remove(t){const e=this.materialCache.get(t);for(const n of e)n.usedTimes--,n.usedTimes===0&&this.shaderCache.delete(n.code);return this.materialCache.delete(t),this}getVertexShaderID(t){return this._getShaderStage(t.vertexShader).id}getFragmentShaderID(t){return this._getShaderStage(t.fragmentShader).id}dispose(){this.shaderCache.clear(),this.materialCache.clear()}_getShaderCacheForMaterial(t){const e=this.materialCache;let n=e.get(t);return n===void 0&&(n=new Set,e.set(t,n)),n}_getShaderStage(t){const e=this.shaderCache;let n=e.get(t);return n===void 0&&(n=new Kp(t),e.set(t,n)),n}}class Kp{constructor(t){this.id=jp++,this.code=t,this.usedTimes=0}}function Zp(i,t,e,n,r,s,o){const a=new to,l=new $p,c=[],u=r.isWebGL2,f=r.logarithmicDepthBuffer,m=r.vertexTextures;let p=r.precision;const v={MeshDepthMaterial:"depth",MeshDistanceMaterial:"distanceRGBA",MeshNormalMaterial:"normal",MeshBasicMaterial:"basic",MeshLambertMaterial:"lambert",MeshPhongMaterial:"phong",MeshToonMaterial:"toon",MeshStandardMaterial:"physical",MeshPhysicalMaterial:"physical",MeshMatcapMaterial:"matcap",LineBasicMaterial:"basic",LineDashedMaterial:"dashed",PointsMaterial:"points",ShadowMaterial:"shadow",SpriteMaterial:"sprite"};function x(M){return M===0?"uv":`uv${M}`}function d(M,A,K,O,z){const S=O.fog,E=z.geometry,g=M.isMeshStandardMaterial?O.environment:null,T=(M.isMeshStandardMaterial?e:t).get(M.envMap||g),L=T&&T.mapping===kr?T.image.height:null,N=v[M.type];M.precision!==null&&(p=r.getMaxPrecision(M.precision),p!==M.precision&&console.warn("THREE.WebGLProgram.getParameters:",M.precision,"not supported, using",p,"instead."));const C=E.morphAttributes.position||E.morphAttributes.normal||E.morphAttributes.color,U=C!==void 0?C.length:0;let q=0;E.morphAttributes.position!==void 0&&(q=1),E.morphAttributes.normal!==void 0&&(q=2),E.morphAttributes.color!==void 0&&(q=3);let Z,it,ut,gt;if(N){const Ae=Qe[N];Z=Ae.vertexShader,it=Ae.fragmentShader}else Z=M.vertexShader,it=M.fragmentShader,l.update(M),ut=l.getVertexShaderID(M),gt=l.getFragmentShaderID(M);const xt=i.getRenderTarget(),Et=z.isInstancedMesh===!0,lt=z.isBatchedMesh===!0,ct=!!M.map,Mt=!!M.matcap,k=!!T,tt=!!M.aoMap,G=!!M.lightMap,H=!!M.bumpMap,V=!!M.normalMap,et=!!M.displacementMap,rt=!!M.emissiveMap,R=!!M.metalnessMap,b=!!M.roughnessMap,Y=M.anisotropy>0,j=M.clearcoat>0,Q=M.iridescence>0,J=M.sheen>0,nt=M.transmission>0,st=Y&&!!M.anisotropyMap,ft=j&&!!M.clearcoatMap,yt=j&&!!M.clearcoatNormalMap,At=j&&!!M.clearcoatRoughnessMap,at=Q&&!!M.iridescenceMap,Rt=Q&&!!M.iridescenceThicknessMap,X=J&&!!M.sheenColorMap,mt=J&&!!M.sheenRoughnessMap,Tt=!!M.specularMap,St=!!M.specularColorMap,Pt=!!M.specularIntensityMap,zt=nt&&!!M.transmissionMap,kt=nt&&!!M.thicknessMap,Ht=!!M.gradientMap,_t=!!M.alphaMap,$=M.alphaTest>0,vt=!!M.alphaHash,bt=!!M.extensions,Ut=!!E.attributes.uv1,It=!!E.attributes.uv2,Wt=!!E.attributes.uv3;let Zt=En;return M.toneMapped&&(xt===null||xt.isXRRenderTarget===!0)&&(Zt=i.toneMapping),{isWebGL2:u,shaderID:N,shaderType:M.type,shaderName:M.name,vertexShader:Z,fragmentShader:it,defines:M.defines,customVertexShaderID:ut,customFragmentShaderID:gt,isRawShaderMaterial:M.isRawShaderMaterial===!0,glslVersion:M.glslVersion,precision:p,batching:lt,instancing:Et,instancingColor:Et&&z.instanceColor!==null,supportsVertexTextures:m,outputColorSpace:xt===null?i.outputColorSpace:xt.isXRRenderTarget===!0?xt.texture.colorSpace:pn,map:ct,matcap:Mt,envMap:k,envMapMode:k&&T.mapping,envMapCubeUVHeight:L,aoMap:tt,lightMap:G,bumpMap:H,normalMap:V,displacementMap:m&&et,emissiveMap:rt,normalMapObjectSpace:V&&M.normalMapType===Yc,normalMapTangentSpace:V&&M.normalMapType===El,metalnessMap:R,roughnessMap:b,anisotropy:Y,anisotropyMap:st,clearcoat:j,clearcoatMap:ft,clearcoatNormalMap:yt,clearcoatRoughnessMap:At,iridescence:Q,iridescenceMap:at,iridescenceThicknessMap:Rt,sheen:J,sheenColorMap:X,sheenRoughnessMap:mt,specularMap:Tt,specularColorMap:St,specularIntensityMap:Pt,transmission:nt,transmissionMap:zt,thicknessMap:kt,gradientMap:Ht,opaque:M.transparent===!1&&M.blending===_i,alphaMap:_t,alphaTest:$,alphaHash:vt,combine:M.combine,mapUv:ct&&x(M.map.channel),aoMapUv:tt&&x(M.aoMap.channel),lightMapUv:G&&x(M.lightMap.channel),bumpMapUv:H&&x(M.bumpMap.channel),normalMapUv:V&&x(M.normalMap.channel),displacementMapUv:et&&x(M.displacementMap.channel),emissiveMapUv:rt&&x(M.emissiveMap.channel),metalnessMapUv:R&&x(M.metalnessMap.channel),roughnessMapUv:b&&x(M.roughnessMap.channel),anisotropyMapUv:st&&x(M.anisotropyMap.channel),clearcoatMapUv:ft&&x(M.clearcoatMap.channel),clearcoatNormalMapUv:yt&&x(M.clearcoatNormalMap.channel),clearcoatRoughnessMapUv:At&&x(M.clearcoatRoughnessMap.channel),iridescenceMapUv:at&&x(M.iridescenceMap.channel),iridescenceThicknessMapUv:Rt&&x(M.iridescenceThicknessMap.channel),sheenColorMapUv:X&&x(M.sheenColorMap.channel),sheenRoughnessMapUv:mt&&x(M.sheenRoughnessMap.channel),specularMapUv:Tt&&x(M.specularMap.channel),specularColorMapUv:St&&x(M.specularColorMap.channel),specularIntensityMapUv:Pt&&x(M.specularIntensityMap.channel),transmissionMapUv:zt&&x(M.transmissionMap.channel),thicknessMapUv:kt&&x(M.thicknessMap.channel),alphaMapUv:_t&&x(M.alphaMap.channel),vertexTangents:!!E.attributes.tangent&&(V||Y),vertexColors:M.vertexColors,vertexAlphas:M.vertexColors===!0&&!!E.attributes.color&&E.attributes.color.itemSize===4,vertexUv1s:Ut,vertexUv2s:It,vertexUv3s:Wt,pointsUvs:z.isPoints===!0&&!!E.attributes.uv&&(ct||_t),fog:!!S,useFog:M.fog===!0,fogExp2:S&&S.isFogExp2,flatShading:M.flatShading===!0,sizeAttenuation:M.sizeAttenuation===!0,logarithmicDepthBuffer:f,skinning:z.isSkinnedMesh===!0,morphTargets:E.morphAttributes.position!==void 0,morphNormals:E.morphAttributes.normal!==void 0,morphColors:E.morphAttributes.color!==void 0,morphTargetsCount:U,morphTextureStride:q,numDirLights:A.directional.length,numPointLights:A.point.length,numSpotLights:A.spot.length,numSpotLightMaps:A.spotLightMap.length,numRectAreaLights:A.rectArea.length,numHemiLights:A.hemi.length,numDirLightShadows:A.directionalShadowMap.length,numPointLightShadows:A.pointShadowMap.length,numSpotLightShadows:A.spotShadowMap.length,numSpotLightShadowsWithMaps:A.numSpotLightShadowsWithMaps,numLightProbes:A.numLightProbes,numClippingPlanes:o.numPlanes,numClipIntersection:o.numIntersection,dithering:M.dithering,shadowMapEnabled:i.shadowMap.enabled&&K.length>0,shadowMapType:i.shadowMap.type,toneMapping:Zt,useLegacyLights:i._useLegacyLights,decodeVideoTexture:ct&&M.map.isVideoTexture===!0&&te.getTransfer(M.map.colorSpace)===se,premultipliedAlpha:M.premultipliedAlpha,doubleSided:M.side===be,flipSided:M.side===Te,useDepthPacking:M.depthPacking>=0,depthPacking:M.depthPacking||0,index0AttributeName:M.index0AttributeName,extensionDerivatives:bt&&M.extensions.derivatives===!0,extensionFragDepth:bt&&M.extensions.fragDepth===!0,extensionDrawBuffers:bt&&M.extensions.drawBuffers===!0,extensionShaderTextureLOD:bt&&M.extensions.shaderTextureLOD===!0,extensionClipCullDistance:bt&&M.extensions.clipCullDistance&&n.has("WEBGL_clip_cull_distance"),rendererExtensionFragDepth:u||n.has("EXT_frag_depth"),rendererExtensionDrawBuffers:u||n.has("WEBGL_draw_buffers"),rendererExtensionShaderTextureLod:u||n.has("EXT_shader_texture_lod"),rendererExtensionParallelShaderCompile:n.has("KHR_parallel_shader_compile"),customProgramCacheKey:M.customProgramCacheKey()}}function h(M){const A=[];if(M.shaderID?A.push(M.shaderID):(A.push(M.customVertexShaderID),A.push(M.customFragmentShaderID)),M.defines!==void 0)for(const K in M.defines)A.push(K),A.push(M.defines[K]);return M.isRawShaderMaterial===!1&&(y(A,M),_(A,M),A.push(i.outputColorSpace)),A.push(M.customProgramCacheKey),A.join()}function y(M,A){M.push(A.precision),M.push(A.outputColorSpace),M.push(A.envMapMode),M.push(A.envMapCubeUVHeight),M.push(A.mapUv),M.push(A.alphaMapUv),M.push(A.lightMapUv),M.push(A.aoMapUv),M.push(A.bumpMapUv),M.push(A.normalMapUv),M.push(A.displacementMapUv),M.push(A.emissiveMapUv),M.push(A.metalnessMapUv),M.push(A.roughnessMapUv),M.push(A.anisotropyMapUv),M.push(A.clearcoatMapUv),M.push(A.clearcoatNormalMapUv),M.push(A.clearcoatRoughnessMapUv),M.push(A.iridescenceMapUv),M.push(A.iridescenceThicknessMapUv),M.push(A.sheenColorMapUv),M.push(A.sheenRoughnessMapUv),M.push(A.specularMapUv),M.push(A.specularColorMapUv),M.push(A.specularIntensityMapUv),M.push(A.transmissionMapUv),M.push(A.thicknessMapUv),M.push(A.combine),M.push(A.fogExp2),M.push(A.sizeAttenuation),M.push(A.morphTargetsCount),M.push(A.morphAttributeCount),M.push(A.numDirLights),M.push(A.numPointLights),M.push(A.numSpotLights),M.push(A.numSpotLightMaps),M.push(A.numHemiLights),M.push(A.numRectAreaLights),M.push(A.numDirLightShadows),M.push(A.numPointLightShadows),M.push(A.numSpotLightShadows),M.push(A.numSpotLightShadowsWithMaps),M.push(A.numLightProbes),M.push(A.shadowMapType),M.push(A.toneMapping),M.push(A.numClippingPlanes),M.push(A.numClipIntersection),M.push(A.depthPacking)}function _(M,A){a.disableAll(),A.isWebGL2&&a.enable(0),A.supportsVertexTextures&&a.enable(1),A.instancing&&a.enable(2),A.instancingColor&&a.enable(3),A.matcap&&a.enable(4),A.envMap&&a.enable(5),A.normalMapObjectSpace&&a.enable(6),A.normalMapTangentSpace&&a.enable(7),A.clearcoat&&a.enable(8),A.iridescence&&a.enable(9),A.alphaTest&&a.enable(10),A.vertexColors&&a.enable(11),A.vertexAlphas&&a.enable(12),A.vertexUv1s&&a.enable(13),A.vertexUv2s&&a.enable(14),A.vertexUv3s&&a.enable(15),A.vertexTangents&&a.enable(16),A.anisotropy&&a.enable(17),A.alphaHash&&a.enable(18),A.batching&&a.enable(19),M.push(a.mask),a.disableAll(),A.fog&&a.enable(0),A.useFog&&a.enable(1),A.flatShading&&a.enable(2),A.logarithmicDepthBuffer&&a.enable(3),A.skinning&&a.enable(4),A.morphTargets&&a.enable(5),A.morphNormals&&a.enable(6),A.morphColors&&a.enable(7),A.premultipliedAlpha&&a.enable(8),A.shadowMapEnabled&&a.enable(9),A.useLegacyLights&&a.enable(10),A.doubleSided&&a.enable(11),A.flipSided&&a.enable(12),A.useDepthPacking&&a.enable(13),A.dithering&&a.enable(14),A.transmission&&a.enable(15),A.sheen&&a.enable(16),A.opaque&&a.enable(17),A.pointsUvs&&a.enable(18),A.decodeVideoTexture&&a.enable(19),M.push(a.mask)}function w(M){const A=v[M.type];let K;if(A){const O=Qe[A];K=qi.clone(O.uniforms)}else K=M.uniforms;return K}function D(M,A){let K;for(let O=0,z=c.length;O<z;O++){const S=c[O];if(S.cacheKey===A){K=S,++K.usedTimes;break}}return K===void 0&&(K=new Yp(i,A,M,s),c.push(K)),K}function P(M){if(--M.usedTimes===0){const A=c.indexOf(M);c[A]=c[c.length-1],c.pop(),M.destroy()}}function I(M){l.remove(M)}function F(){l.dispose()}return{getParameters:d,getProgramCacheKey:h,getUniforms:w,acquireProgram:D,releaseProgram:P,releaseShaderCache:I,programs:c,dispose:F}}function Jp(){let i=new WeakMap;function t(s){let o=i.get(s);return o===void 0&&(o={},i.set(s,o)),o}function e(s){i.delete(s)}function n(s,o,a){i.get(s)[o]=a}function r(){i=new WeakMap}return{get:t,remove:e,update:n,dispose:r}}function Qp(i,t){return i.groupOrder!==t.groupOrder?i.groupOrder-t.groupOrder:i.renderOrder!==t.renderOrder?i.renderOrder-t.renderOrder:i.material.id!==t.material.id?i.material.id-t.material.id:i.z!==t.z?i.z-t.z:i.id-t.id}function Ua(i,t){return i.groupOrder!==t.groupOrder?i.groupOrder-t.groupOrder:i.renderOrder!==t.renderOrder?i.renderOrder-t.renderOrder:i.z!==t.z?t.z-i.z:i.id-t.id}function Na(){const i=[];let t=0;const e=[],n=[],r=[];function s(){t=0,e.length=0,n.length=0,r.length=0}function o(f,m,p,v,x,d){let h=i[t];return h===void 0?(h={id:f.id,object:f,geometry:m,material:p,groupOrder:v,renderOrder:f.renderOrder,z:x,group:d},i[t]=h):(h.id=f.id,h.object=f,h.geometry=m,h.material=p,h.groupOrder=v,h.renderOrder=f.renderOrder,h.z=x,h.group=d),t++,h}function a(f,m,p,v,x,d){const h=o(f,m,p,v,x,d);p.transmission>0?n.push(h):p.transparent===!0?r.push(h):e.push(h)}function l(f,m,p,v,x,d){const h=o(f,m,p,v,x,d);p.transmission>0?n.unshift(h):p.transparent===!0?r.unshift(h):e.unshift(h)}function c(f,m){e.length>1&&e.sort(f||Qp),n.length>1&&n.sort(m||Ua),r.length>1&&r.sort(m||Ua)}function u(){for(let f=t,m=i.length;f<m;f++){const p=i[f];if(p.id===null)break;p.id=null,p.object=null,p.geometry=null,p.material=null,p.group=null}}return{opaque:e,transmissive:n,transparent:r,init:s,push:a,unshift:l,finish:u,sort:c}}function tm(){let i=new WeakMap;function t(n,r){const s=i.get(n);let o;return s===void 0?(o=new Na,i.set(n,[o])):r>=s.length?(o=new Na,s.push(o)):o=s[r],o}function e(){i=new WeakMap}return{get:t,dispose:e}}function em(){const i={};return{get:function(t){if(i[t.id]!==void 0)return i[t.id];let e;switch(t.type){case"DirectionalLight":e={direction:new W,color:new Dt};break;case"SpotLight":e={position:new W,direction:new W,color:new Dt,distance:0,coneCos:0,penumbraCos:0,decay:0};break;case"PointLight":e={position:new W,color:new Dt,distance:0,decay:0};break;case"HemisphereLight":e={direction:new W,skyColor:new Dt,groundColor:new Dt};break;case"RectAreaLight":e={color:new Dt,position:new W,halfWidth:new W,halfHeight:new W};break}return i[t.id]=e,e}}}function nm(){const i={};return{get:function(t){if(i[t.id]!==void 0)return i[t.id];let e;switch(t.type){case"DirectionalLight":e={shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new wt};break;case"SpotLight":e={shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new wt};break;case"PointLight":e={shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new wt,shadowCameraNear:1,shadowCameraFar:1e3};break}return i[t.id]=e,e}}}let im=0;function rm(i,t){return(t.castShadow?2:0)-(i.castShadow?2:0)+(t.map?1:0)-(i.map?1:0)}function sm(i,t){const e=new em,n=nm(),r={version:0,hash:{directionalLength:-1,pointLength:-1,spotLength:-1,rectAreaLength:-1,hemiLength:-1,numDirectionalShadows:-1,numPointShadows:-1,numSpotShadows:-1,numSpotMaps:-1,numLightProbes:-1},ambient:[0,0,0],probe:[],directional:[],directionalShadow:[],directionalShadowMap:[],directionalShadowMatrix:[],spot:[],spotLightMap:[],spotShadow:[],spotShadowMap:[],spotLightMatrix:[],rectArea:[],rectAreaLTC1:null,rectAreaLTC2:null,point:[],pointShadow:[],pointShadowMap:[],pointShadowMatrix:[],hemi:[],numSpotLightShadowsWithMaps:0,numLightProbes:0};for(let u=0;u<9;u++)r.probe.push(new W);const s=new W,o=new ie,a=new ie;function l(u,f){let m=0,p=0,v=0;for(let O=0;O<9;O++)r.probe[O].set(0,0,0);let x=0,d=0,h=0,y=0,_=0,w=0,D=0,P=0,I=0,F=0,M=0;u.sort(rm);const A=f===!0?Math.PI:1;for(let O=0,z=u.length;O<z;O++){const S=u[O],E=S.color,g=S.intensity,T=S.distance,L=S.shadow&&S.shadow.map?S.shadow.map.texture:null;if(S.isAmbientLight)m+=E.r*g*A,p+=E.g*g*A,v+=E.b*g*A;else if(S.isLightProbe){for(let N=0;N<9;N++)r.probe[N].addScaledVector(S.sh.coefficients[N],g);M++}else if(S.isDirectionalLight){const N=e.get(S);if(N.color.copy(S.color).multiplyScalar(S.intensity*A),S.castShadow){const C=S.shadow,U=n.get(S);U.shadowBias=C.bias,U.shadowNormalBias=C.normalBias,U.shadowRadius=C.radius,U.shadowMapSize=C.mapSize,r.directionalShadow[x]=U,r.directionalShadowMap[x]=L,r.directionalShadowMatrix[x]=S.shadow.matrix,w++}r.directional[x]=N,x++}else if(S.isSpotLight){const N=e.get(S);N.position.setFromMatrixPosition(S.matrixWorld),N.color.copy(E).multiplyScalar(g*A),N.distance=T,N.coneCos=Math.cos(S.angle),N.penumbraCos=Math.cos(S.angle*(1-S.penumbra)),N.decay=S.decay,r.spot[h]=N;const C=S.shadow;if(S.map&&(r.spotLightMap[I]=S.map,I++,C.updateMatrices(S),S.castShadow&&F++),r.spotLightMatrix[h]=C.matrix,S.castShadow){const U=n.get(S);U.shadowBias=C.bias,U.shadowNormalBias=C.normalBias,U.shadowRadius=C.radius,U.shadowMapSize=C.mapSize,r.spotShadow[h]=U,r.spotShadowMap[h]=L,P++}h++}else if(S.isRectAreaLight){const N=e.get(S);N.color.copy(E).multiplyScalar(g),N.halfWidth.set(S.width*.5,0,0),N.halfHeight.set(0,S.height*.5,0),r.rectArea[y]=N,y++}else if(S.isPointLight){const N=e.get(S);if(N.color.copy(S.color).multiplyScalar(S.intensity*A),N.distance=S.distance,N.decay=S.decay,S.castShadow){const C=S.shadow,U=n.get(S);U.shadowBias=C.bias,U.shadowNormalBias=C.normalBias,U.shadowRadius=C.radius,U.shadowMapSize=C.mapSize,U.shadowCameraNear=C.camera.near,U.shadowCameraFar=C.camera.far,r.pointShadow[d]=U,r.pointShadowMap[d]=L,r.pointShadowMatrix[d]=S.shadow.matrix,D++}r.point[d]=N,d++}else if(S.isHemisphereLight){const N=e.get(S);N.skyColor.copy(S.color).multiplyScalar(g*A),N.groundColor.copy(S.groundColor).multiplyScalar(g*A),r.hemi[_]=N,_++}}y>0&&(t.isWebGL2?i.has("OES_texture_float_linear")===!0?(r.rectAreaLTC1=Ct.LTC_FLOAT_1,r.rectAreaLTC2=Ct.LTC_FLOAT_2):(r.rectAreaLTC1=Ct.LTC_HALF_1,r.rectAreaLTC2=Ct.LTC_HALF_2):i.has("OES_texture_float_linear")===!0?(r.rectAreaLTC1=Ct.LTC_FLOAT_1,r.rectAreaLTC2=Ct.LTC_FLOAT_2):i.has("OES_texture_half_float_linear")===!0?(r.rectAreaLTC1=Ct.LTC_HALF_1,r.rectAreaLTC2=Ct.LTC_HALF_2):console.error("THREE.WebGLRenderer: Unable to use RectAreaLight. Missing WebGL extensions.")),r.ambient[0]=m,r.ambient[1]=p,r.ambient[2]=v;const K=r.hash;(K.directionalLength!==x||K.pointLength!==d||K.spotLength!==h||K.rectAreaLength!==y||K.hemiLength!==_||K.numDirectionalShadows!==w||K.numPointShadows!==D||K.numSpotShadows!==P||K.numSpotMaps!==I||K.numLightProbes!==M)&&(r.directional.length=x,r.spot.length=h,r.rectArea.length=y,r.point.length=d,r.hemi.length=_,r.directionalShadow.length=w,r.directionalShadowMap.length=w,r.pointShadow.length=D,r.pointShadowMap.length=D,r.spotShadow.length=P,r.spotShadowMap.length=P,r.directionalShadowMatrix.length=w,r.pointShadowMatrix.length=D,r.spotLightMatrix.length=P+I-F,r.spotLightMap.length=I,r.numSpotLightShadowsWithMaps=F,r.numLightProbes=M,K.directionalLength=x,K.pointLength=d,K.spotLength=h,K.rectAreaLength=y,K.hemiLength=_,K.numDirectionalShadows=w,K.numPointShadows=D,K.numSpotShadows=P,K.numSpotMaps=I,K.numLightProbes=M,r.version=im++)}function c(u,f){let m=0,p=0,v=0,x=0,d=0;const h=f.matrixWorldInverse;for(let y=0,_=u.length;y<_;y++){const w=u[y];if(w.isDirectionalLight){const D=r.directional[m];D.direction.setFromMatrixPosition(w.matrixWorld),s.setFromMatrixPosition(w.target.matrixWorld),D.direction.sub(s),D.direction.transformDirection(h),m++}else if(w.isSpotLight){const D=r.spot[v];D.position.setFromMatrixPosition(w.matrixWorld),D.position.applyMatrix4(h),D.direction.setFromMatrixPosition(w.matrixWorld),s.setFromMatrixPosition(w.target.matrixWorld),D.direction.sub(s),D.direction.transformDirection(h),v++}else if(w.isRectAreaLight){const D=r.rectArea[x];D.position.setFromMatrixPosition(w.matrixWorld),D.position.applyMatrix4(h),a.identity(),o.copy(w.matrixWorld),o.premultiply(h),a.extractRotation(o),D.halfWidth.set(w.width*.5,0,0),D.halfHeight.set(0,w.height*.5,0),D.halfWidth.applyMatrix4(a),D.halfHeight.applyMatrix4(a),x++}else if(w.isPointLight){const D=r.point[p];D.position.setFromMatrixPosition(w.matrixWorld),D.position.applyMatrix4(h),p++}else if(w.isHemisphereLight){const D=r.hemi[d];D.direction.setFromMatrixPosition(w.matrixWorld),D.direction.transformDirection(h),d++}}}return{setup:l,setupView:c,state:r}}function Oa(i,t){const e=new sm(i,t),n=[],r=[];function s(){n.length=0,r.length=0}function o(f){n.push(f)}function a(f){r.push(f)}function l(f){e.setup(n,f)}function c(f){e.setupView(n,f)}return{init:s,state:{lightsArray:n,shadowsArray:r,lights:e},setupLights:l,setupLightsView:c,pushLight:o,pushShadow:a}}function om(i,t){let e=new WeakMap;function n(s,o=0){const a=e.get(s);let l;return a===void 0?(l=new Oa(i,t),e.set(s,[l])):o>=a.length?(l=new Oa(i,t),a.push(l)):l=a[o],l}function r(){e=new WeakMap}return{get:n,dispose:r}}class am extends Rn{constructor(t){super(),this.isMeshDepthMaterial=!0,this.type="MeshDepthMaterial",this.depthPacking=Xc,this.map=null,this.alphaMap=null,this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.wireframe=!1,this.wireframeLinewidth=1,this.setValues(t)}copy(t){return super.copy(t),this.depthPacking=t.depthPacking,this.map=t.map,this.alphaMap=t.alphaMap,this.displacementMap=t.displacementMap,this.displacementScale=t.displacementScale,this.displacementBias=t.displacementBias,this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this}}class lm extends Rn{constructor(t){super(),this.isMeshDistanceMaterial=!0,this.type="MeshDistanceMaterial",this.map=null,this.alphaMap=null,this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.setValues(t)}copy(t){return super.copy(t),this.map=t.map,this.alphaMap=t.alphaMap,this.displacementMap=t.displacementMap,this.displacementScale=t.displacementScale,this.displacementBias=t.displacementBias,this}}const cm=`void main() {
	gl_Position = vec4( position, 1.0 );
}`,um=`uniform sampler2D shadow_pass;
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
}`;function hm(i,t,e){let n=new eo;const r=new wt,s=new wt,o=new oe,a=new am({depthPacking:qc}),l=new lm,c={},u=e.maxTextureSize,f={[wn]:Te,[Te]:wn,[be]:be},m=new Ee({defines:{VSM_SAMPLES:8},uniforms:{shadow_pass:{value:null},resolution:{value:new wt},radius:{value:4}},vertexShader:cm,fragmentShader:um}),p=m.clone();p.defines.HORIZONTAL_PASS=1;const v=new Jt;v.setAttribute("position",new fe(new Float32Array([-1,-1,.5,3,-1,.5,-1,3,.5]),3));const x=new Ft(v,m),d=this;this.enabled=!1,this.autoUpdate=!0,this.needsUpdate=!1,this.type=ll;let h=this.type;this.render=function(P,I,F){if(d.enabled===!1||d.autoUpdate===!1&&d.needsUpdate===!1||P.length===0)return;const M=i.getRenderTarget(),A=i.getActiveCubeFace(),K=i.getActiveMipmapLevel(),O=i.state;O.setBlending(hn),O.buffers.color.setClear(1,1,1,1),O.buffers.depth.setTest(!0),O.setScissorTest(!1);const z=h!==cn&&this.type===cn,S=h===cn&&this.type!==cn;for(let E=0,g=P.length;E<g;E++){const T=P[E],L=T.shadow;if(L===void 0){console.warn("THREE.WebGLShadowMap:",T,"has no shadow.");continue}if(L.autoUpdate===!1&&L.needsUpdate===!1)continue;r.copy(L.mapSize);const N=L.getFrameExtents();if(r.multiply(N),s.copy(L.mapSize),(r.x>u||r.y>u)&&(r.x>u&&(s.x=Math.floor(u/N.x),r.x=s.x*N.x,L.mapSize.x=s.x),r.y>u&&(s.y=Math.floor(u/N.y),r.y=s.y*N.y,L.mapSize.y=s.y)),L.map===null||z===!0||S===!0){const U=this.type!==cn?{minFilter:Le,magFilter:Le}:{};L.map!==null&&L.map.dispose(),L.map=new Ke(r.x,r.y,U),L.map.texture.name=T.name+".shadowMap",L.camera.updateProjectionMatrix()}i.setRenderTarget(L.map),i.clear();const C=L.getViewportCount();for(let U=0;U<C;U++){const q=L.getViewport(U);o.set(s.x*q.x,s.y*q.y,s.x*q.z,s.y*q.w),O.viewport(o),L.updateMatrices(T,U),n=L.getFrustum(),w(I,F,L.camera,T,this.type)}L.isPointLightShadow!==!0&&this.type===cn&&y(L,F),L.needsUpdate=!1}h=this.type,d.needsUpdate=!1,i.setRenderTarget(M,A,K)};function y(P,I){const F=t.update(x);m.defines.VSM_SAMPLES!==P.blurSamples&&(m.defines.VSM_SAMPLES=P.blurSamples,p.defines.VSM_SAMPLES=P.blurSamples,m.needsUpdate=!0,p.needsUpdate=!0),P.mapPass===null&&(P.mapPass=new Ke(r.x,r.y)),m.uniforms.shadow_pass.value=P.map.texture,m.uniforms.resolution.value=P.mapSize,m.uniforms.radius.value=P.radius,i.setRenderTarget(P.mapPass),i.clear(),i.renderBufferDirect(I,null,F,m,x,null),p.uniforms.shadow_pass.value=P.mapPass.texture,p.uniforms.resolution.value=P.mapSize,p.uniforms.radius.value=P.radius,i.setRenderTarget(P.map),i.clear(),i.renderBufferDirect(I,null,F,p,x,null)}function _(P,I,F,M){let A=null;const K=F.isPointLight===!0?P.customDistanceMaterial:P.customDepthMaterial;if(K!==void 0)A=K;else if(A=F.isPointLight===!0?l:a,i.localClippingEnabled&&I.clipShadows===!0&&Array.isArray(I.clippingPlanes)&&I.clippingPlanes.length!==0||I.displacementMap&&I.displacementScale!==0||I.alphaMap&&I.alphaTest>0||I.map&&I.alphaTest>0){const O=A.uuid,z=I.uuid;let S=c[O];S===void 0&&(S={},c[O]=S);let E=S[z];E===void 0&&(E=A.clone(),S[z]=E,I.addEventListener("dispose",D)),A=E}if(A.visible=I.visible,A.wireframe=I.wireframe,M===cn?A.side=I.shadowSide!==null?I.shadowSide:I.side:A.side=I.shadowSide!==null?I.shadowSide:f[I.side],A.alphaMap=I.alphaMap,A.alphaTest=I.alphaTest,A.map=I.map,A.clipShadows=I.clipShadows,A.clippingPlanes=I.clippingPlanes,A.clipIntersection=I.clipIntersection,A.displacementMap=I.displacementMap,A.displacementScale=I.displacementScale,A.displacementBias=I.displacementBias,A.wireframeLinewidth=I.wireframeLinewidth,A.linewidth=I.linewidth,F.isPointLight===!0&&A.isMeshDistanceMaterial===!0){const O=i.properties.get(A);O.light=F}return A}function w(P,I,F,M,A){if(P.visible===!1)return;if(P.layers.test(I.layers)&&(P.isMesh||P.isLine||P.isPoints)&&(P.castShadow||P.receiveShadow&&A===cn)&&(!P.frustumCulled||n.intersectsObject(P))){P.modelViewMatrix.multiplyMatrices(F.matrixWorldInverse,P.matrixWorld);const z=t.update(P),S=P.material;if(Array.isArray(S)){const E=z.groups;for(let g=0,T=E.length;g<T;g++){const L=E[g],N=S[L.materialIndex];if(N&&N.visible){const C=_(P,N,M,A);P.onBeforeShadow(i,P,I,F,z,C,L),i.renderBufferDirect(F,null,z,C,P,L),P.onAfterShadow(i,P,I,F,z,C,L)}}}else if(S.visible){const E=_(P,S,M,A);P.onBeforeShadow(i,P,I,F,z,E,null),i.renderBufferDirect(F,null,z,E,P,null),P.onAfterShadow(i,P,I,F,z,E,null)}}const O=P.children;for(let z=0,S=O.length;z<S;z++)w(O[z],I,F,M,A)}function D(P){P.target.removeEventListener("dispose",D);for(const F in c){const M=c[F],A=P.target.uuid;A in M&&(M[A].dispose(),delete M[A])}}}function dm(i,t,e){const n=e.isWebGL2;function r(){let $=!1;const vt=new oe;let bt=null;const Ut=new oe(0,0,0,0);return{setMask:function(It){bt!==It&&!$&&(i.colorMask(It,It,It,It),bt=It)},setLocked:function(It){$=It},setClear:function(It,Wt,Zt,he,Ae){Ae===!0&&(It*=he,Wt*=he,Zt*=he),vt.set(It,Wt,Zt,he),Ut.equals(vt)===!1&&(i.clearColor(It,Wt,Zt,he),Ut.copy(vt))},reset:function(){$=!1,bt=null,Ut.set(-1,0,0,0)}}}function s(){let $=!1,vt=null,bt=null,Ut=null;return{setTest:function(It){It?lt(i.DEPTH_TEST):ct(i.DEPTH_TEST)},setMask:function(It){vt!==It&&!$&&(i.depthMask(It),vt=It)},setFunc:function(It){if(bt!==It){switch(It){case wc:i.depthFunc(i.NEVER);break;case Ac:i.depthFunc(i.ALWAYS);break;case Rc:i.depthFunc(i.LESS);break;case Lr:i.depthFunc(i.LEQUAL);break;case Cc:i.depthFunc(i.EQUAL);break;case Pc:i.depthFunc(i.GEQUAL);break;case Lc:i.depthFunc(i.GREATER);break;case Dc:i.depthFunc(i.NOTEQUAL);break;default:i.depthFunc(i.LEQUAL)}bt=It}},setLocked:function(It){$=It},setClear:function(It){Ut!==It&&(i.clearDepth(It),Ut=It)},reset:function(){$=!1,vt=null,bt=null,Ut=null}}}function o(){let $=!1,vt=null,bt=null,Ut=null,It=null,Wt=null,Zt=null,he=null,Ae=null;return{setTest:function(re){$||(re?lt(i.STENCIL_TEST):ct(i.STENCIL_TEST))},setMask:function(re){vt!==re&&!$&&(i.stencilMask(re),vt=re)},setFunc:function(re,Re,Je){(bt!==re||Ut!==Re||It!==Je)&&(i.stencilFunc(re,Re,Je),bt=re,Ut=Re,It=Je)},setOp:function(re,Re,Je){(Wt!==re||Zt!==Re||he!==Je)&&(i.stencilOp(re,Re,Je),Wt=re,Zt=Re,he=Je)},setLocked:function(re){$=re},setClear:function(re){Ae!==re&&(i.clearStencil(re),Ae=re)},reset:function(){$=!1,vt=null,bt=null,Ut=null,It=null,Wt=null,Zt=null,he=null,Ae=null}}}const a=new r,l=new s,c=new o,u=new WeakMap,f=new WeakMap;let m={},p={},v=new WeakMap,x=[],d=null,h=!1,y=null,_=null,w=null,D=null,P=null,I=null,F=null,M=new Dt(0,0,0),A=0,K=!1,O=null,z=null,S=null,E=null,g=null;const T=i.getParameter(i.MAX_COMBINED_TEXTURE_IMAGE_UNITS);let L=!1,N=0;const C=i.getParameter(i.VERSION);C.indexOf("WebGL")!==-1?(N=parseFloat(/^WebGL (\d)/.exec(C)[1]),L=N>=1):C.indexOf("OpenGL ES")!==-1&&(N=parseFloat(/^OpenGL ES (\d)/.exec(C)[1]),L=N>=2);let U=null,q={};const Z=i.getParameter(i.SCISSOR_BOX),it=i.getParameter(i.VIEWPORT),ut=new oe().fromArray(Z),gt=new oe().fromArray(it);function xt($,vt,bt,Ut){const It=new Uint8Array(4),Wt=i.createTexture();i.bindTexture($,Wt),i.texParameteri($,i.TEXTURE_MIN_FILTER,i.NEAREST),i.texParameteri($,i.TEXTURE_MAG_FILTER,i.NEAREST);for(let Zt=0;Zt<bt;Zt++)n&&($===i.TEXTURE_3D||$===i.TEXTURE_2D_ARRAY)?i.texImage3D(vt,0,i.RGBA,1,1,Ut,0,i.RGBA,i.UNSIGNED_BYTE,It):i.texImage2D(vt+Zt,0,i.RGBA,1,1,0,i.RGBA,i.UNSIGNED_BYTE,It);return Wt}const Et={};Et[i.TEXTURE_2D]=xt(i.TEXTURE_2D,i.TEXTURE_2D,1),Et[i.TEXTURE_CUBE_MAP]=xt(i.TEXTURE_CUBE_MAP,i.TEXTURE_CUBE_MAP_POSITIVE_X,6),n&&(Et[i.TEXTURE_2D_ARRAY]=xt(i.TEXTURE_2D_ARRAY,i.TEXTURE_2D_ARRAY,1,1),Et[i.TEXTURE_3D]=xt(i.TEXTURE_3D,i.TEXTURE_3D,1,1)),a.setClear(0,0,0,1),l.setClear(1),c.setClear(0),lt(i.DEPTH_TEST),l.setFunc(Lr),rt(!1),R(Mo),lt(i.CULL_FACE),V(hn);function lt($){m[$]!==!0&&(i.enable($),m[$]=!0)}function ct($){m[$]!==!1&&(i.disable($),m[$]=!1)}function Mt($,vt){return p[$]!==vt?(i.bindFramebuffer($,vt),p[$]=vt,n&&($===i.DRAW_FRAMEBUFFER&&(p[i.FRAMEBUFFER]=vt),$===i.FRAMEBUFFER&&(p[i.DRAW_FRAMEBUFFER]=vt)),!0):!1}function k($,vt){let bt=x,Ut=!1;if($)if(bt=v.get(vt),bt===void 0&&(bt=[],v.set(vt,bt)),$.isWebGLMultipleRenderTargets){const It=$.texture;if(bt.length!==It.length||bt[0]!==i.COLOR_ATTACHMENT0){for(let Wt=0,Zt=It.length;Wt<Zt;Wt++)bt[Wt]=i.COLOR_ATTACHMENT0+Wt;bt.length=It.length,Ut=!0}}else bt[0]!==i.COLOR_ATTACHMENT0&&(bt[0]=i.COLOR_ATTACHMENT0,Ut=!0);else bt[0]!==i.BACK&&(bt[0]=i.BACK,Ut=!0);Ut&&(e.isWebGL2?i.drawBuffers(bt):t.get("WEBGL_draw_buffers").drawBuffersWEBGL(bt))}function tt($){return d!==$?(i.useProgram($),d=$,!0):!1}const G={[On]:i.FUNC_ADD,[hc]:i.FUNC_SUBTRACT,[dc]:i.FUNC_REVERSE_SUBTRACT};if(n)G[bo]=i.MIN,G[Eo]=i.MAX;else{const $=t.get("EXT_blend_minmax");$!==null&&(G[bo]=$.MIN_EXT,G[Eo]=$.MAX_EXT)}const H={[fc]:i.ZERO,[pc]:i.ONE,[mc]:i.SRC_COLOR,[Os]:i.SRC_ALPHA,[yc]:i.SRC_ALPHA_SATURATE,[xc]:i.DST_COLOR,[_c]:i.DST_ALPHA,[gc]:i.ONE_MINUS_SRC_COLOR,[Fs]:i.ONE_MINUS_SRC_ALPHA,[Mc]:i.ONE_MINUS_DST_COLOR,[vc]:i.ONE_MINUS_DST_ALPHA,[Sc]:i.CONSTANT_COLOR,[bc]:i.ONE_MINUS_CONSTANT_COLOR,[Ec]:i.CONSTANT_ALPHA,[Tc]:i.ONE_MINUS_CONSTANT_ALPHA};function V($,vt,bt,Ut,It,Wt,Zt,he,Ae,re){if($===hn){h===!0&&(ct(i.BLEND),h=!1);return}if(h===!1&&(lt(i.BLEND),h=!0),$!==uc){if($!==y||re!==K){if((_!==On||P!==On)&&(i.blendEquation(i.FUNC_ADD),_=On,P=On),re)switch($){case _i:i.blendFuncSeparate(i.ONE,i.ONE_MINUS_SRC_ALPHA,i.ONE,i.ONE_MINUS_SRC_ALPHA);break;case Ns:i.blendFunc(i.ONE,i.ONE);break;case yo:i.blendFuncSeparate(i.ZERO,i.ONE_MINUS_SRC_COLOR,i.ZERO,i.ONE);break;case So:i.blendFuncSeparate(i.ZERO,i.SRC_COLOR,i.ZERO,i.SRC_ALPHA);break;default:console.error("THREE.WebGLState: Invalid blending: ",$);break}else switch($){case _i:i.blendFuncSeparate(i.SRC_ALPHA,i.ONE_MINUS_SRC_ALPHA,i.ONE,i.ONE_MINUS_SRC_ALPHA);break;case Ns:i.blendFunc(i.SRC_ALPHA,i.ONE);break;case yo:i.blendFuncSeparate(i.ZERO,i.ONE_MINUS_SRC_COLOR,i.ZERO,i.ONE);break;case So:i.blendFunc(i.ZERO,i.SRC_COLOR);break;default:console.error("THREE.WebGLState: Invalid blending: ",$);break}w=null,D=null,I=null,F=null,M.set(0,0,0),A=0,y=$,K=re}return}It=It||vt,Wt=Wt||bt,Zt=Zt||Ut,(vt!==_||It!==P)&&(i.blendEquationSeparate(G[vt],G[It]),_=vt,P=It),(bt!==w||Ut!==D||Wt!==I||Zt!==F)&&(i.blendFuncSeparate(H[bt],H[Ut],H[Wt],H[Zt]),w=bt,D=Ut,I=Wt,F=Zt),(he.equals(M)===!1||Ae!==A)&&(i.blendColor(he.r,he.g,he.b,Ae),M.copy(he),A=Ae),y=$,K=!1}function et($,vt){$.side===be?ct(i.CULL_FACE):lt(i.CULL_FACE);let bt=$.side===Te;vt&&(bt=!bt),rt(bt),$.blending===_i&&$.transparent===!1?V(hn):V($.blending,$.blendEquation,$.blendSrc,$.blendDst,$.blendEquationAlpha,$.blendSrcAlpha,$.blendDstAlpha,$.blendColor,$.blendAlpha,$.premultipliedAlpha),l.setFunc($.depthFunc),l.setTest($.depthTest),l.setMask($.depthWrite),a.setMask($.colorWrite);const Ut=$.stencilWrite;c.setTest(Ut),Ut&&(c.setMask($.stencilWriteMask),c.setFunc($.stencilFunc,$.stencilRef,$.stencilFuncMask),c.setOp($.stencilFail,$.stencilZFail,$.stencilZPass)),Y($.polygonOffset,$.polygonOffsetFactor,$.polygonOffsetUnits),$.alphaToCoverage===!0?lt(i.SAMPLE_ALPHA_TO_COVERAGE):ct(i.SAMPLE_ALPHA_TO_COVERAGE)}function rt($){O!==$&&($?i.frontFace(i.CW):i.frontFace(i.CCW),O=$)}function R($){$!==lc?(lt(i.CULL_FACE),$!==z&&($===Mo?i.cullFace(i.BACK):$===cc?i.cullFace(i.FRONT):i.cullFace(i.FRONT_AND_BACK))):ct(i.CULL_FACE),z=$}function b($){$!==S&&(L&&i.lineWidth($),S=$)}function Y($,vt,bt){$?(lt(i.POLYGON_OFFSET_FILL),(E!==vt||g!==bt)&&(i.polygonOffset(vt,bt),E=vt,g=bt)):ct(i.POLYGON_OFFSET_FILL)}function j($){$?lt(i.SCISSOR_TEST):ct(i.SCISSOR_TEST)}function Q($){$===void 0&&($=i.TEXTURE0+T-1),U!==$&&(i.activeTexture($),U=$)}function J($,vt,bt){bt===void 0&&(U===null?bt=i.TEXTURE0+T-1:bt=U);let Ut=q[bt];Ut===void 0&&(Ut={type:void 0,texture:void 0},q[bt]=Ut),(Ut.type!==$||Ut.texture!==vt)&&(U!==bt&&(i.activeTexture(bt),U=bt),i.bindTexture($,vt||Et[$]),Ut.type=$,Ut.texture=vt)}function nt(){const $=q[U];$!==void 0&&$.type!==void 0&&(i.bindTexture($.type,null),$.type=void 0,$.texture=void 0)}function st(){try{i.compressedTexImage2D.apply(i,arguments)}catch($){console.error("THREE.WebGLState:",$)}}function ft(){try{i.compressedTexImage3D.apply(i,arguments)}catch($){console.error("THREE.WebGLState:",$)}}function yt(){try{i.texSubImage2D.apply(i,arguments)}catch($){console.error("THREE.WebGLState:",$)}}function At(){try{i.texSubImage3D.apply(i,arguments)}catch($){console.error("THREE.WebGLState:",$)}}function at(){try{i.compressedTexSubImage2D.apply(i,arguments)}catch($){console.error("THREE.WebGLState:",$)}}function Rt(){try{i.compressedTexSubImage3D.apply(i,arguments)}catch($){console.error("THREE.WebGLState:",$)}}function X(){try{i.texStorage2D.apply(i,arguments)}catch($){console.error("THREE.WebGLState:",$)}}function mt(){try{i.texStorage3D.apply(i,arguments)}catch($){console.error("THREE.WebGLState:",$)}}function Tt(){try{i.texImage2D.apply(i,arguments)}catch($){console.error("THREE.WebGLState:",$)}}function St(){try{i.texImage3D.apply(i,arguments)}catch($){console.error("THREE.WebGLState:",$)}}function Pt($){ut.equals($)===!1&&(i.scissor($.x,$.y,$.z,$.w),ut.copy($))}function zt($){gt.equals($)===!1&&(i.viewport($.x,$.y,$.z,$.w),gt.copy($))}function kt($,vt){let bt=f.get(vt);bt===void 0&&(bt=new WeakMap,f.set(vt,bt));let Ut=bt.get($);Ut===void 0&&(Ut=i.getUniformBlockIndex(vt,$.name),bt.set($,Ut))}function Ht($,vt){const Ut=f.get(vt).get($);u.get(vt)!==Ut&&(i.uniformBlockBinding(vt,Ut,$.__bindingPointIndex),u.set(vt,Ut))}function _t(){i.disable(i.BLEND),i.disable(i.CULL_FACE),i.disable(i.DEPTH_TEST),i.disable(i.POLYGON_OFFSET_FILL),i.disable(i.SCISSOR_TEST),i.disable(i.STENCIL_TEST),i.disable(i.SAMPLE_ALPHA_TO_COVERAGE),i.blendEquation(i.FUNC_ADD),i.blendFunc(i.ONE,i.ZERO),i.blendFuncSeparate(i.ONE,i.ZERO,i.ONE,i.ZERO),i.blendColor(0,0,0,0),i.colorMask(!0,!0,!0,!0),i.clearColor(0,0,0,0),i.depthMask(!0),i.depthFunc(i.LESS),i.clearDepth(1),i.stencilMask(4294967295),i.stencilFunc(i.ALWAYS,0,4294967295),i.stencilOp(i.KEEP,i.KEEP,i.KEEP),i.clearStencil(0),i.cullFace(i.BACK),i.frontFace(i.CCW),i.polygonOffset(0,0),i.activeTexture(i.TEXTURE0),i.bindFramebuffer(i.FRAMEBUFFER,null),n===!0&&(i.bindFramebuffer(i.DRAW_FRAMEBUFFER,null),i.bindFramebuffer(i.READ_FRAMEBUFFER,null)),i.useProgram(null),i.lineWidth(1),i.scissor(0,0,i.canvas.width,i.canvas.height),i.viewport(0,0,i.canvas.width,i.canvas.height),m={},U=null,q={},p={},v=new WeakMap,x=[],d=null,h=!1,y=null,_=null,w=null,D=null,P=null,I=null,F=null,M=new Dt(0,0,0),A=0,K=!1,O=null,z=null,S=null,E=null,g=null,ut.set(0,0,i.canvas.width,i.canvas.height),gt.set(0,0,i.canvas.width,i.canvas.height),a.reset(),l.reset(),c.reset()}return{buffers:{color:a,depth:l,stencil:c},enable:lt,disable:ct,bindFramebuffer:Mt,drawBuffers:k,useProgram:tt,setBlending:V,setMaterial:et,setFlipSided:rt,setCullFace:R,setLineWidth:b,setPolygonOffset:Y,setScissorTest:j,activeTexture:Q,bindTexture:J,unbindTexture:nt,compressedTexImage2D:st,compressedTexImage3D:ft,texImage2D:Tt,texImage3D:St,updateUBOMapping:kt,uniformBlockBinding:Ht,texStorage2D:X,texStorage3D:mt,texSubImage2D:yt,texSubImage3D:At,compressedTexSubImage2D:at,compressedTexSubImage3D:Rt,scissor:Pt,viewport:zt,reset:_t}}function fm(i,t,e,n,r,s,o){const a=r.isWebGL2,l=t.has("WEBGL_multisampled_render_to_texture")?t.get("WEBGL_multisampled_render_to_texture"):null,c=typeof navigator>"u"?!1:/OculusBrowser/g.test(navigator.userAgent),u=new WeakMap;let f;const m=new WeakMap;let p=!1;try{p=typeof OffscreenCanvas<"u"&&new OffscreenCanvas(1,1).getContext("2d")!==null}catch{}function v(R,b){return p?new OffscreenCanvas(R,b):Fr("canvas")}function x(R,b,Y,j){let Q=1;if((R.width>j||R.height>j)&&(Q=j/Math.max(R.width,R.height)),Q<1||b===!0)if(typeof HTMLImageElement<"u"&&R instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&R instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&R instanceof ImageBitmap){const J=b?Or:Math.floor,nt=J(Q*R.width),st=J(Q*R.height);f===void 0&&(f=v(nt,st));const ft=Y?v(nt,st):f;return ft.width=nt,ft.height=st,ft.getContext("2d").drawImage(R,0,0,nt,st),console.warn("THREE.WebGLRenderer: Texture has been resized from ("+R.width+"x"+R.height+") to ("+nt+"x"+st+")."),ft}else return"data"in R&&console.warn("THREE.WebGLRenderer: Image in DataTexture is too big ("+R.width+"x"+R.height+")."),R;return R}function d(R){return Vs(R.width)&&Vs(R.height)}function h(R){return a?!1:R.wrapS!==Ve||R.wrapT!==Ve||R.minFilter!==Le&&R.minFilter!==ke}function y(R,b){return R.generateMipmaps&&b&&R.minFilter!==Le&&R.minFilter!==ke}function _(R){i.generateMipmap(R)}function w(R,b,Y,j,Q=!1){if(a===!1)return b;if(R!==null){if(i[R]!==void 0)return i[R];console.warn("THREE.WebGLRenderer: Attempt to use non-existing WebGL internal format '"+R+"'")}let J=b;if(b===i.RED&&(Y===i.FLOAT&&(J=i.R32F),Y===i.HALF_FLOAT&&(J=i.R16F),Y===i.UNSIGNED_BYTE&&(J=i.R8)),b===i.RED_INTEGER&&(Y===i.UNSIGNED_BYTE&&(J=i.R8UI),Y===i.UNSIGNED_SHORT&&(J=i.R16UI),Y===i.UNSIGNED_INT&&(J=i.R32UI),Y===i.BYTE&&(J=i.R8I),Y===i.SHORT&&(J=i.R16I),Y===i.INT&&(J=i.R32I)),b===i.RG&&(Y===i.FLOAT&&(J=i.RG32F),Y===i.HALF_FLOAT&&(J=i.RG16F),Y===i.UNSIGNED_BYTE&&(J=i.RG8)),b===i.RGBA){const nt=Q?Dr:te.getTransfer(j);Y===i.FLOAT&&(J=i.RGBA32F),Y===i.HALF_FLOAT&&(J=i.RGBA16F),Y===i.UNSIGNED_BYTE&&(J=nt===se?i.SRGB8_ALPHA8:i.RGBA8),Y===i.UNSIGNED_SHORT_4_4_4_4&&(J=i.RGBA4),Y===i.UNSIGNED_SHORT_5_5_5_1&&(J=i.RGB5_A1)}return(J===i.R16F||J===i.R32F||J===i.RG16F||J===i.RG32F||J===i.RGBA16F||J===i.RGBA32F)&&t.get("EXT_color_buffer_float"),J}function D(R,b,Y){return y(R,Y)===!0||R.isFramebufferTexture&&R.minFilter!==Le&&R.minFilter!==ke?Math.log2(Math.max(b.width,b.height))+1:R.mipmaps!==void 0&&R.mipmaps.length>0?R.mipmaps.length:R.isCompressedTexture&&Array.isArray(R.image)?b.mipmaps.length:1}function P(R){return R===Le||R===To||R===Zr?i.NEAREST:i.LINEAR}function I(R){const b=R.target;b.removeEventListener("dispose",I),M(b),b.isVideoTexture&&u.delete(b)}function F(R){const b=R.target;b.removeEventListener("dispose",F),K(b)}function M(R){const b=n.get(R);if(b.__webglInit===void 0)return;const Y=R.source,j=m.get(Y);if(j){const Q=j[b.__cacheKey];Q.usedTimes--,Q.usedTimes===0&&A(R),Object.keys(j).length===0&&m.delete(Y)}n.remove(R)}function A(R){const b=n.get(R);i.deleteTexture(b.__webglTexture);const Y=R.source,j=m.get(Y);delete j[b.__cacheKey],o.memory.textures--}function K(R){const b=R.texture,Y=n.get(R),j=n.get(b);if(j.__webglTexture!==void 0&&(i.deleteTexture(j.__webglTexture),o.memory.textures--),R.depthTexture&&R.depthTexture.dispose(),R.isWebGLCubeRenderTarget)for(let Q=0;Q<6;Q++){if(Array.isArray(Y.__webglFramebuffer[Q]))for(let J=0;J<Y.__webglFramebuffer[Q].length;J++)i.deleteFramebuffer(Y.__webglFramebuffer[Q][J]);else i.deleteFramebuffer(Y.__webglFramebuffer[Q]);Y.__webglDepthbuffer&&i.deleteRenderbuffer(Y.__webglDepthbuffer[Q])}else{if(Array.isArray(Y.__webglFramebuffer))for(let Q=0;Q<Y.__webglFramebuffer.length;Q++)i.deleteFramebuffer(Y.__webglFramebuffer[Q]);else i.deleteFramebuffer(Y.__webglFramebuffer);if(Y.__webglDepthbuffer&&i.deleteRenderbuffer(Y.__webglDepthbuffer),Y.__webglMultisampledFramebuffer&&i.deleteFramebuffer(Y.__webglMultisampledFramebuffer),Y.__webglColorRenderbuffer)for(let Q=0;Q<Y.__webglColorRenderbuffer.length;Q++)Y.__webglColorRenderbuffer[Q]&&i.deleteRenderbuffer(Y.__webglColorRenderbuffer[Q]);Y.__webglDepthRenderbuffer&&i.deleteRenderbuffer(Y.__webglDepthRenderbuffer)}if(R.isWebGLMultipleRenderTargets)for(let Q=0,J=b.length;Q<J;Q++){const nt=n.get(b[Q]);nt.__webglTexture&&(i.deleteTexture(nt.__webglTexture),o.memory.textures--),n.remove(b[Q])}n.remove(b),n.remove(R)}let O=0;function z(){O=0}function S(){const R=O;return R>=r.maxTextures&&console.warn("THREE.WebGLTextures: Trying to use "+R+" texture units while this GPU supports only "+r.maxTextures),O+=1,R}function E(R){const b=[];return b.push(R.wrapS),b.push(R.wrapT),b.push(R.wrapR||0),b.push(R.magFilter),b.push(R.minFilter),b.push(R.anisotropy),b.push(R.internalFormat),b.push(R.format),b.push(R.type),b.push(R.generateMipmaps),b.push(R.premultiplyAlpha),b.push(R.flipY),b.push(R.unpackAlignment),b.push(R.colorSpace),b.join()}function g(R,b){const Y=n.get(R);if(R.isVideoTexture&&et(R),R.isRenderTargetTexture===!1&&R.version>0&&Y.__version!==R.version){const j=R.image;if(j===null)console.warn("THREE.WebGLRenderer: Texture marked for update but no image data found.");else if(j.complete===!1)console.warn("THREE.WebGLRenderer: Texture marked for update but image is incomplete");else{ut(Y,R,b);return}}e.bindTexture(i.TEXTURE_2D,Y.__webglTexture,i.TEXTURE0+b)}function T(R,b){const Y=n.get(R);if(R.version>0&&Y.__version!==R.version){ut(Y,R,b);return}e.bindTexture(i.TEXTURE_2D_ARRAY,Y.__webglTexture,i.TEXTURE0+b)}function L(R,b){const Y=n.get(R);if(R.version>0&&Y.__version!==R.version){ut(Y,R,b);return}e.bindTexture(i.TEXTURE_3D,Y.__webglTexture,i.TEXTURE0+b)}function N(R,b){const Y=n.get(R);if(R.version>0&&Y.__version!==R.version){gt(Y,R,b);return}e.bindTexture(i.TEXTURE_CUBE_MAP,Y.__webglTexture,i.TEXTURE0+b)}const C={[yi]:i.REPEAT,[Ve]:i.CLAMP_TO_EDGE,[Gs]:i.MIRRORED_REPEAT},U={[Le]:i.NEAREST,[To]:i.NEAREST_MIPMAP_NEAREST,[Zr]:i.NEAREST_MIPMAP_LINEAR,[ke]:i.LINEAR,[Oc]:i.LINEAR_MIPMAP_NEAREST,[Wi]:i.LINEAR_MIPMAP_LINEAR},q={[jc]:i.NEVER,[tu]:i.ALWAYS,[$c]:i.LESS,[Tl]:i.LEQUAL,[Kc]:i.EQUAL,[Qc]:i.GEQUAL,[Zc]:i.GREATER,[Jc]:i.NOTEQUAL};function Z(R,b,Y){if(Y?(i.texParameteri(R,i.TEXTURE_WRAP_S,C[b.wrapS]),i.texParameteri(R,i.TEXTURE_WRAP_T,C[b.wrapT]),(R===i.TEXTURE_3D||R===i.TEXTURE_2D_ARRAY)&&i.texParameteri(R,i.TEXTURE_WRAP_R,C[b.wrapR]),i.texParameteri(R,i.TEXTURE_MAG_FILTER,U[b.magFilter]),i.texParameteri(R,i.TEXTURE_MIN_FILTER,U[b.minFilter])):(i.texParameteri(R,i.TEXTURE_WRAP_S,i.CLAMP_TO_EDGE),i.texParameteri(R,i.TEXTURE_WRAP_T,i.CLAMP_TO_EDGE),(R===i.TEXTURE_3D||R===i.TEXTURE_2D_ARRAY)&&i.texParameteri(R,i.TEXTURE_WRAP_R,i.CLAMP_TO_EDGE),(b.wrapS!==Ve||b.wrapT!==Ve)&&console.warn("THREE.WebGLRenderer: Texture is not power of two. Texture.wrapS and Texture.wrapT should be set to THREE.ClampToEdgeWrapping."),i.texParameteri(R,i.TEXTURE_MAG_FILTER,P(b.magFilter)),i.texParameteri(R,i.TEXTURE_MIN_FILTER,P(b.minFilter)),b.minFilter!==Le&&b.minFilter!==ke&&console.warn("THREE.WebGLRenderer: Texture is not power of two. Texture.minFilter should be set to THREE.NearestFilter or THREE.LinearFilter.")),b.compareFunction&&(i.texParameteri(R,i.TEXTURE_COMPARE_MODE,i.COMPARE_REF_TO_TEXTURE),i.texParameteri(R,i.TEXTURE_COMPARE_FUNC,q[b.compareFunction])),t.has("EXT_texture_filter_anisotropic")===!0){const j=t.get("EXT_texture_filter_anisotropic");if(b.magFilter===Le||b.minFilter!==Zr&&b.minFilter!==Wi||b.type===bn&&t.has("OES_texture_float_linear")===!1||a===!1&&b.type===dn&&t.has("OES_texture_half_float_linear")===!1)return;(b.anisotropy>1||n.get(b).__currentAnisotropy)&&(i.texParameterf(R,j.TEXTURE_MAX_ANISOTROPY_EXT,Math.min(b.anisotropy,r.getMaxAnisotropy())),n.get(b).__currentAnisotropy=b.anisotropy)}}function it(R,b){let Y=!1;R.__webglInit===void 0&&(R.__webglInit=!0,b.addEventListener("dispose",I));const j=b.source;let Q=m.get(j);Q===void 0&&(Q={},m.set(j,Q));const J=E(b);if(J!==R.__cacheKey){Q[J]===void 0&&(Q[J]={texture:i.createTexture(),usedTimes:0},o.memory.textures++,Y=!0),Q[J].usedTimes++;const nt=Q[R.__cacheKey];nt!==void 0&&(Q[R.__cacheKey].usedTimes--,nt.usedTimes===0&&A(b)),R.__cacheKey=J,R.__webglTexture=Q[J].texture}return Y}function ut(R,b,Y){let j=i.TEXTURE_2D;(b.isDataArrayTexture||b.isCompressedArrayTexture)&&(j=i.TEXTURE_2D_ARRAY),b.isData3DTexture&&(j=i.TEXTURE_3D);const Q=it(R,b),J=b.source;e.bindTexture(j,R.__webglTexture,i.TEXTURE0+Y);const nt=n.get(J);if(J.version!==nt.__version||Q===!0){e.activeTexture(i.TEXTURE0+Y);const st=te.getPrimaries(te.workingColorSpace),ft=b.colorSpace===We?null:te.getPrimaries(b.colorSpace),yt=b.colorSpace===We||st===ft?i.NONE:i.BROWSER_DEFAULT_WEBGL;i.pixelStorei(i.UNPACK_FLIP_Y_WEBGL,b.flipY),i.pixelStorei(i.UNPACK_PREMULTIPLY_ALPHA_WEBGL,b.premultiplyAlpha),i.pixelStorei(i.UNPACK_ALIGNMENT,b.unpackAlignment),i.pixelStorei(i.UNPACK_COLORSPACE_CONVERSION_WEBGL,yt);const At=h(b)&&d(b.image)===!1;let at=x(b.image,At,!1,r.maxTextureSize);at=rt(b,at);const Rt=d(at)||a,X=s.convert(b.format,b.colorSpace);let mt=s.convert(b.type),Tt=w(b.internalFormat,X,mt,b.colorSpace,b.isVideoTexture);Z(j,b,Rt);let St;const Pt=b.mipmaps,zt=a&&b.isVideoTexture!==!0&&Tt!==Sl,kt=nt.__version===void 0||Q===!0,Ht=D(b,at,Rt);if(b.isDepthTexture)Tt=i.DEPTH_COMPONENT,a?b.type===bn?Tt=i.DEPTH_COMPONENT32F:b.type===Sn?Tt=i.DEPTH_COMPONENT24:b.type===Bn?Tt=i.DEPTH24_STENCIL8:Tt=i.DEPTH_COMPONENT16:b.type===bn&&console.error("WebGLRenderer: Floating point depth texture requires WebGL2."),b.format===zn&&Tt===i.DEPTH_COMPONENT&&b.type!==Zs&&b.type!==Sn&&(console.warn("THREE.WebGLRenderer: Use UnsignedShortType or UnsignedIntType for DepthFormat DepthTexture."),b.type=Sn,mt=s.convert(b.type)),b.format===Si&&Tt===i.DEPTH_COMPONENT&&(Tt=i.DEPTH_STENCIL,b.type!==Bn&&(console.warn("THREE.WebGLRenderer: Use UnsignedInt248Type for DepthStencilFormat DepthTexture."),b.type=Bn,mt=s.convert(b.type))),kt&&(zt?e.texStorage2D(i.TEXTURE_2D,1,Tt,at.width,at.height):e.texImage2D(i.TEXTURE_2D,0,Tt,at.width,at.height,0,X,mt,null));else if(b.isDataTexture)if(Pt.length>0&&Rt){zt&&kt&&e.texStorage2D(i.TEXTURE_2D,Ht,Tt,Pt[0].width,Pt[0].height);for(let _t=0,$=Pt.length;_t<$;_t++)St=Pt[_t],zt?e.texSubImage2D(i.TEXTURE_2D,_t,0,0,St.width,St.height,X,mt,St.data):e.texImage2D(i.TEXTURE_2D,_t,Tt,St.width,St.height,0,X,mt,St.data);b.generateMipmaps=!1}else zt?(kt&&e.texStorage2D(i.TEXTURE_2D,Ht,Tt,at.width,at.height),e.texSubImage2D(i.TEXTURE_2D,0,0,0,at.width,at.height,X,mt,at.data)):e.texImage2D(i.TEXTURE_2D,0,Tt,at.width,at.height,0,X,mt,at.data);else if(b.isCompressedTexture)if(b.isCompressedArrayTexture){zt&&kt&&e.texStorage3D(i.TEXTURE_2D_ARRAY,Ht,Tt,Pt[0].width,Pt[0].height,at.depth);for(let _t=0,$=Pt.length;_t<$;_t++)St=Pt[_t],b.format!==je?X!==null?zt?e.compressedTexSubImage3D(i.TEXTURE_2D_ARRAY,_t,0,0,0,St.width,St.height,at.depth,X,St.data,0,0):e.compressedTexImage3D(i.TEXTURE_2D_ARRAY,_t,Tt,St.width,St.height,at.depth,0,St.data,0,0):console.warn("THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()"):zt?e.texSubImage3D(i.TEXTURE_2D_ARRAY,_t,0,0,0,St.width,St.height,at.depth,X,mt,St.data):e.texImage3D(i.TEXTURE_2D_ARRAY,_t,Tt,St.width,St.height,at.depth,0,X,mt,St.data)}else{zt&&kt&&e.texStorage2D(i.TEXTURE_2D,Ht,Tt,Pt[0].width,Pt[0].height);for(let _t=0,$=Pt.length;_t<$;_t++)St=Pt[_t],b.format!==je?X!==null?zt?e.compressedTexSubImage2D(i.TEXTURE_2D,_t,0,0,St.width,St.height,X,St.data):e.compressedTexImage2D(i.TEXTURE_2D,_t,Tt,St.width,St.height,0,St.data):console.warn("THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()"):zt?e.texSubImage2D(i.TEXTURE_2D,_t,0,0,St.width,St.height,X,mt,St.data):e.texImage2D(i.TEXTURE_2D,_t,Tt,St.width,St.height,0,X,mt,St.data)}else if(b.isDataArrayTexture)zt?(kt&&e.texStorage3D(i.TEXTURE_2D_ARRAY,Ht,Tt,at.width,at.height,at.depth),e.texSubImage3D(i.TEXTURE_2D_ARRAY,0,0,0,0,at.width,at.height,at.depth,X,mt,at.data)):e.texImage3D(i.TEXTURE_2D_ARRAY,0,Tt,at.width,at.height,at.depth,0,X,mt,at.data);else if(b.isData3DTexture)zt?(kt&&e.texStorage3D(i.TEXTURE_3D,Ht,Tt,at.width,at.height,at.depth),e.texSubImage3D(i.TEXTURE_3D,0,0,0,0,at.width,at.height,at.depth,X,mt,at.data)):e.texImage3D(i.TEXTURE_3D,0,Tt,at.width,at.height,at.depth,0,X,mt,at.data);else if(b.isFramebufferTexture){if(kt)if(zt)e.texStorage2D(i.TEXTURE_2D,Ht,Tt,at.width,at.height);else{let _t=at.width,$=at.height;for(let vt=0;vt<Ht;vt++)e.texImage2D(i.TEXTURE_2D,vt,Tt,_t,$,0,X,mt,null),_t>>=1,$>>=1}}else if(Pt.length>0&&Rt){zt&&kt&&e.texStorage2D(i.TEXTURE_2D,Ht,Tt,Pt[0].width,Pt[0].height);for(let _t=0,$=Pt.length;_t<$;_t++)St=Pt[_t],zt?e.texSubImage2D(i.TEXTURE_2D,_t,0,0,X,mt,St):e.texImage2D(i.TEXTURE_2D,_t,Tt,X,mt,St);b.generateMipmaps=!1}else zt?(kt&&e.texStorage2D(i.TEXTURE_2D,Ht,Tt,at.width,at.height),e.texSubImage2D(i.TEXTURE_2D,0,0,0,X,mt,at)):e.texImage2D(i.TEXTURE_2D,0,Tt,X,mt,at);y(b,Rt)&&_(j),nt.__version=J.version,b.onUpdate&&b.onUpdate(b)}R.__version=b.version}function gt(R,b,Y){if(b.image.length!==6)return;const j=it(R,b),Q=b.source;e.bindTexture(i.TEXTURE_CUBE_MAP,R.__webglTexture,i.TEXTURE0+Y);const J=n.get(Q);if(Q.version!==J.__version||j===!0){e.activeTexture(i.TEXTURE0+Y);const nt=te.getPrimaries(te.workingColorSpace),st=b.colorSpace===We?null:te.getPrimaries(b.colorSpace),ft=b.colorSpace===We||nt===st?i.NONE:i.BROWSER_DEFAULT_WEBGL;i.pixelStorei(i.UNPACK_FLIP_Y_WEBGL,b.flipY),i.pixelStorei(i.UNPACK_PREMULTIPLY_ALPHA_WEBGL,b.premultiplyAlpha),i.pixelStorei(i.UNPACK_ALIGNMENT,b.unpackAlignment),i.pixelStorei(i.UNPACK_COLORSPACE_CONVERSION_WEBGL,ft);const yt=b.isCompressedTexture||b.image[0].isCompressedTexture,At=b.image[0]&&b.image[0].isDataTexture,at=[];for(let _t=0;_t<6;_t++)!yt&&!At?at[_t]=x(b.image[_t],!1,!0,r.maxCubemapSize):at[_t]=At?b.image[_t].image:b.image[_t],at[_t]=rt(b,at[_t]);const Rt=at[0],X=d(Rt)||a,mt=s.convert(b.format,b.colorSpace),Tt=s.convert(b.type),St=w(b.internalFormat,mt,Tt,b.colorSpace),Pt=a&&b.isVideoTexture!==!0,zt=J.__version===void 0||j===!0;let kt=D(b,Rt,X);Z(i.TEXTURE_CUBE_MAP,b,X);let Ht;if(yt){Pt&&zt&&e.texStorage2D(i.TEXTURE_CUBE_MAP,kt,St,Rt.width,Rt.height);for(let _t=0;_t<6;_t++){Ht=at[_t].mipmaps;for(let $=0;$<Ht.length;$++){const vt=Ht[$];b.format!==je?mt!==null?Pt?e.compressedTexSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,$,0,0,vt.width,vt.height,mt,vt.data):e.compressedTexImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,$,St,vt.width,vt.height,0,vt.data):console.warn("THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .setTextureCube()"):Pt?e.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,$,0,0,vt.width,vt.height,mt,Tt,vt.data):e.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,$,St,vt.width,vt.height,0,mt,Tt,vt.data)}}}else{Ht=b.mipmaps,Pt&&zt&&(Ht.length>0&&kt++,e.texStorage2D(i.TEXTURE_CUBE_MAP,kt,St,at[0].width,at[0].height));for(let _t=0;_t<6;_t++)if(At){Pt?e.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,0,0,0,at[_t].width,at[_t].height,mt,Tt,at[_t].data):e.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,0,St,at[_t].width,at[_t].height,0,mt,Tt,at[_t].data);for(let $=0;$<Ht.length;$++){const bt=Ht[$].image[_t].image;Pt?e.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,$+1,0,0,bt.width,bt.height,mt,Tt,bt.data):e.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,$+1,St,bt.width,bt.height,0,mt,Tt,bt.data)}}else{Pt?e.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,0,0,0,mt,Tt,at[_t]):e.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,0,St,mt,Tt,at[_t]);for(let $=0;$<Ht.length;$++){const vt=Ht[$];Pt?e.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,$+1,0,0,mt,Tt,vt.image[_t]):e.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+_t,$+1,St,mt,Tt,vt.image[_t])}}}y(b,X)&&_(i.TEXTURE_CUBE_MAP),J.__version=Q.version,b.onUpdate&&b.onUpdate(b)}R.__version=b.version}function xt(R,b,Y,j,Q,J){const nt=s.convert(Y.format,Y.colorSpace),st=s.convert(Y.type),ft=w(Y.internalFormat,nt,st,Y.colorSpace);if(!n.get(b).__hasExternalTextures){const At=Math.max(1,b.width>>J),at=Math.max(1,b.height>>J);Q===i.TEXTURE_3D||Q===i.TEXTURE_2D_ARRAY?e.texImage3D(Q,J,ft,At,at,b.depth,0,nt,st,null):e.texImage2D(Q,J,ft,At,at,0,nt,st,null)}e.bindFramebuffer(i.FRAMEBUFFER,R),V(b)?l.framebufferTexture2DMultisampleEXT(i.FRAMEBUFFER,j,Q,n.get(Y).__webglTexture,0,H(b)):(Q===i.TEXTURE_2D||Q>=i.TEXTURE_CUBE_MAP_POSITIVE_X&&Q<=i.TEXTURE_CUBE_MAP_NEGATIVE_Z)&&i.framebufferTexture2D(i.FRAMEBUFFER,j,Q,n.get(Y).__webglTexture,J),e.bindFramebuffer(i.FRAMEBUFFER,null)}function Et(R,b,Y){if(i.bindRenderbuffer(i.RENDERBUFFER,R),b.depthBuffer&&!b.stencilBuffer){let j=a===!0?i.DEPTH_COMPONENT24:i.DEPTH_COMPONENT16;if(Y||V(b)){const Q=b.depthTexture;Q&&Q.isDepthTexture&&(Q.type===bn?j=i.DEPTH_COMPONENT32F:Q.type===Sn&&(j=i.DEPTH_COMPONENT24));const J=H(b);V(b)?l.renderbufferStorageMultisampleEXT(i.RENDERBUFFER,J,j,b.width,b.height):i.renderbufferStorageMultisample(i.RENDERBUFFER,J,j,b.width,b.height)}else i.renderbufferStorage(i.RENDERBUFFER,j,b.width,b.height);i.framebufferRenderbuffer(i.FRAMEBUFFER,i.DEPTH_ATTACHMENT,i.RENDERBUFFER,R)}else if(b.depthBuffer&&b.stencilBuffer){const j=H(b);Y&&V(b)===!1?i.renderbufferStorageMultisample(i.RENDERBUFFER,j,i.DEPTH24_STENCIL8,b.width,b.height):V(b)?l.renderbufferStorageMultisampleEXT(i.RENDERBUFFER,j,i.DEPTH24_STENCIL8,b.width,b.height):i.renderbufferStorage(i.RENDERBUFFER,i.DEPTH_STENCIL,b.width,b.height),i.framebufferRenderbuffer(i.FRAMEBUFFER,i.DEPTH_STENCIL_ATTACHMENT,i.RENDERBUFFER,R)}else{const j=b.isWebGLMultipleRenderTargets===!0?b.texture:[b.texture];for(let Q=0;Q<j.length;Q++){const J=j[Q],nt=s.convert(J.format,J.colorSpace),st=s.convert(J.type),ft=w(J.internalFormat,nt,st,J.colorSpace),yt=H(b);Y&&V(b)===!1?i.renderbufferStorageMultisample(i.RENDERBUFFER,yt,ft,b.width,b.height):V(b)?l.renderbufferStorageMultisampleEXT(i.RENDERBUFFER,yt,ft,b.width,b.height):i.renderbufferStorage(i.RENDERBUFFER,ft,b.width,b.height)}}i.bindRenderbuffer(i.RENDERBUFFER,null)}function lt(R,b){if(b&&b.isWebGLCubeRenderTarget)throw new Error("Depth Texture with cube render targets is not supported");if(e.bindFramebuffer(i.FRAMEBUFFER,R),!(b.depthTexture&&b.depthTexture.isDepthTexture))throw new Error("renderTarget.depthTexture must be an instance of THREE.DepthTexture");(!n.get(b.depthTexture).__webglTexture||b.depthTexture.image.width!==b.width||b.depthTexture.image.height!==b.height)&&(b.depthTexture.image.width=b.width,b.depthTexture.image.height=b.height,b.depthTexture.needsUpdate=!0),g(b.depthTexture,0);const j=n.get(b.depthTexture).__webglTexture,Q=H(b);if(b.depthTexture.format===zn)V(b)?l.framebufferTexture2DMultisampleEXT(i.FRAMEBUFFER,i.DEPTH_ATTACHMENT,i.TEXTURE_2D,j,0,Q):i.framebufferTexture2D(i.FRAMEBUFFER,i.DEPTH_ATTACHMENT,i.TEXTURE_2D,j,0);else if(b.depthTexture.format===Si)V(b)?l.framebufferTexture2DMultisampleEXT(i.FRAMEBUFFER,i.DEPTH_STENCIL_ATTACHMENT,i.TEXTURE_2D,j,0,Q):i.framebufferTexture2D(i.FRAMEBUFFER,i.DEPTH_STENCIL_ATTACHMENT,i.TEXTURE_2D,j,0);else throw new Error("Unknown depthTexture format")}function ct(R){const b=n.get(R),Y=R.isWebGLCubeRenderTarget===!0;if(R.depthTexture&&!b.__autoAllocateDepthBuffer){if(Y)throw new Error("target.depthTexture not supported in Cube render targets");lt(b.__webglFramebuffer,R)}else if(Y){b.__webglDepthbuffer=[];for(let j=0;j<6;j++)e.bindFramebuffer(i.FRAMEBUFFER,b.__webglFramebuffer[j]),b.__webglDepthbuffer[j]=i.createRenderbuffer(),Et(b.__webglDepthbuffer[j],R,!1)}else e.bindFramebuffer(i.FRAMEBUFFER,b.__webglFramebuffer),b.__webglDepthbuffer=i.createRenderbuffer(),Et(b.__webglDepthbuffer,R,!1);e.bindFramebuffer(i.FRAMEBUFFER,null)}function Mt(R,b,Y){const j=n.get(R);b!==void 0&&xt(j.__webglFramebuffer,R,R.texture,i.COLOR_ATTACHMENT0,i.TEXTURE_2D,0),Y!==void 0&&ct(R)}function k(R){const b=R.texture,Y=n.get(R),j=n.get(b);R.addEventListener("dispose",F),R.isWebGLMultipleRenderTargets!==!0&&(j.__webglTexture===void 0&&(j.__webglTexture=i.createTexture()),j.__version=b.version,o.memory.textures++);const Q=R.isWebGLCubeRenderTarget===!0,J=R.isWebGLMultipleRenderTargets===!0,nt=d(R)||a;if(Q){Y.__webglFramebuffer=[];for(let st=0;st<6;st++)if(a&&b.mipmaps&&b.mipmaps.length>0){Y.__webglFramebuffer[st]=[];for(let ft=0;ft<b.mipmaps.length;ft++)Y.__webglFramebuffer[st][ft]=i.createFramebuffer()}else Y.__webglFramebuffer[st]=i.createFramebuffer()}else{if(a&&b.mipmaps&&b.mipmaps.length>0){Y.__webglFramebuffer=[];for(let st=0;st<b.mipmaps.length;st++)Y.__webglFramebuffer[st]=i.createFramebuffer()}else Y.__webglFramebuffer=i.createFramebuffer();if(J)if(r.drawBuffers){const st=R.texture;for(let ft=0,yt=st.length;ft<yt;ft++){const At=n.get(st[ft]);At.__webglTexture===void 0&&(At.__webglTexture=i.createTexture(),o.memory.textures++)}}else console.warn("THREE.WebGLRenderer: WebGLMultipleRenderTargets can only be used with WebGL2 or WEBGL_draw_buffers extension.");if(a&&R.samples>0&&V(R)===!1){const st=J?b:[b];Y.__webglMultisampledFramebuffer=i.createFramebuffer(),Y.__webglColorRenderbuffer=[],e.bindFramebuffer(i.FRAMEBUFFER,Y.__webglMultisampledFramebuffer);for(let ft=0;ft<st.length;ft++){const yt=st[ft];Y.__webglColorRenderbuffer[ft]=i.createRenderbuffer(),i.bindRenderbuffer(i.RENDERBUFFER,Y.__webglColorRenderbuffer[ft]);const At=s.convert(yt.format,yt.colorSpace),at=s.convert(yt.type),Rt=w(yt.internalFormat,At,at,yt.colorSpace,R.isXRRenderTarget===!0),X=H(R);i.renderbufferStorageMultisample(i.RENDERBUFFER,X,Rt,R.width,R.height),i.framebufferRenderbuffer(i.FRAMEBUFFER,i.COLOR_ATTACHMENT0+ft,i.RENDERBUFFER,Y.__webglColorRenderbuffer[ft])}i.bindRenderbuffer(i.RENDERBUFFER,null),R.depthBuffer&&(Y.__webglDepthRenderbuffer=i.createRenderbuffer(),Et(Y.__webglDepthRenderbuffer,R,!0)),e.bindFramebuffer(i.FRAMEBUFFER,null)}}if(Q){e.bindTexture(i.TEXTURE_CUBE_MAP,j.__webglTexture),Z(i.TEXTURE_CUBE_MAP,b,nt);for(let st=0;st<6;st++)if(a&&b.mipmaps&&b.mipmaps.length>0)for(let ft=0;ft<b.mipmaps.length;ft++)xt(Y.__webglFramebuffer[st][ft],R,b,i.COLOR_ATTACHMENT0,i.TEXTURE_CUBE_MAP_POSITIVE_X+st,ft);else xt(Y.__webglFramebuffer[st],R,b,i.COLOR_ATTACHMENT0,i.TEXTURE_CUBE_MAP_POSITIVE_X+st,0);y(b,nt)&&_(i.TEXTURE_CUBE_MAP),e.unbindTexture()}else if(J){const st=R.texture;for(let ft=0,yt=st.length;ft<yt;ft++){const At=st[ft],at=n.get(At);e.bindTexture(i.TEXTURE_2D,at.__webglTexture),Z(i.TEXTURE_2D,At,nt),xt(Y.__webglFramebuffer,R,At,i.COLOR_ATTACHMENT0+ft,i.TEXTURE_2D,0),y(At,nt)&&_(i.TEXTURE_2D)}e.unbindTexture()}else{let st=i.TEXTURE_2D;if((R.isWebGL3DRenderTarget||R.isWebGLArrayRenderTarget)&&(a?st=R.isWebGL3DRenderTarget?i.TEXTURE_3D:i.TEXTURE_2D_ARRAY:console.error("THREE.WebGLTextures: THREE.Data3DTexture and THREE.DataArrayTexture only supported with WebGL2.")),e.bindTexture(st,j.__webglTexture),Z(st,b,nt),a&&b.mipmaps&&b.mipmaps.length>0)for(let ft=0;ft<b.mipmaps.length;ft++)xt(Y.__webglFramebuffer[ft],R,b,i.COLOR_ATTACHMENT0,st,ft);else xt(Y.__webglFramebuffer,R,b,i.COLOR_ATTACHMENT0,st,0);y(b,nt)&&_(st),e.unbindTexture()}R.depthBuffer&&ct(R)}function tt(R){const b=d(R)||a,Y=R.isWebGLMultipleRenderTargets===!0?R.texture:[R.texture];for(let j=0,Q=Y.length;j<Q;j++){const J=Y[j];if(y(J,b)){const nt=R.isWebGLCubeRenderTarget?i.TEXTURE_CUBE_MAP:i.TEXTURE_2D,st=n.get(J).__webglTexture;e.bindTexture(nt,st),_(nt),e.unbindTexture()}}}function G(R){if(a&&R.samples>0&&V(R)===!1){const b=R.isWebGLMultipleRenderTargets?R.texture:[R.texture],Y=R.width,j=R.height;let Q=i.COLOR_BUFFER_BIT;const J=[],nt=R.stencilBuffer?i.DEPTH_STENCIL_ATTACHMENT:i.DEPTH_ATTACHMENT,st=n.get(R),ft=R.isWebGLMultipleRenderTargets===!0;if(ft)for(let yt=0;yt<b.length;yt++)e.bindFramebuffer(i.FRAMEBUFFER,st.__webglMultisampledFramebuffer),i.framebufferRenderbuffer(i.FRAMEBUFFER,i.COLOR_ATTACHMENT0+yt,i.RENDERBUFFER,null),e.bindFramebuffer(i.FRAMEBUFFER,st.__webglFramebuffer),i.framebufferTexture2D(i.DRAW_FRAMEBUFFER,i.COLOR_ATTACHMENT0+yt,i.TEXTURE_2D,null,0);e.bindFramebuffer(i.READ_FRAMEBUFFER,st.__webglMultisampledFramebuffer),e.bindFramebuffer(i.DRAW_FRAMEBUFFER,st.__webglFramebuffer);for(let yt=0;yt<b.length;yt++){J.push(i.COLOR_ATTACHMENT0+yt),R.depthBuffer&&J.push(nt);const At=st.__ignoreDepthValues!==void 0?st.__ignoreDepthValues:!1;if(At===!1&&(R.depthBuffer&&(Q|=i.DEPTH_BUFFER_BIT),R.stencilBuffer&&(Q|=i.STENCIL_BUFFER_BIT)),ft&&i.framebufferRenderbuffer(i.READ_FRAMEBUFFER,i.COLOR_ATTACHMENT0,i.RENDERBUFFER,st.__webglColorRenderbuffer[yt]),At===!0&&(i.invalidateFramebuffer(i.READ_FRAMEBUFFER,[nt]),i.invalidateFramebuffer(i.DRAW_FRAMEBUFFER,[nt])),ft){const at=n.get(b[yt]).__webglTexture;i.framebufferTexture2D(i.DRAW_FRAMEBUFFER,i.COLOR_ATTACHMENT0,i.TEXTURE_2D,at,0)}i.blitFramebuffer(0,0,Y,j,0,0,Y,j,Q,i.NEAREST),c&&i.invalidateFramebuffer(i.READ_FRAMEBUFFER,J)}if(e.bindFramebuffer(i.READ_FRAMEBUFFER,null),e.bindFramebuffer(i.DRAW_FRAMEBUFFER,null),ft)for(let yt=0;yt<b.length;yt++){e.bindFramebuffer(i.FRAMEBUFFER,st.__webglMultisampledFramebuffer),i.framebufferRenderbuffer(i.FRAMEBUFFER,i.COLOR_ATTACHMENT0+yt,i.RENDERBUFFER,st.__webglColorRenderbuffer[yt]);const At=n.get(b[yt]).__webglTexture;e.bindFramebuffer(i.FRAMEBUFFER,st.__webglFramebuffer),i.framebufferTexture2D(i.DRAW_FRAMEBUFFER,i.COLOR_ATTACHMENT0+yt,i.TEXTURE_2D,At,0)}e.bindFramebuffer(i.DRAW_FRAMEBUFFER,st.__webglMultisampledFramebuffer)}}function H(R){return Math.min(r.maxSamples,R.samples)}function V(R){const b=n.get(R);return a&&R.samples>0&&t.has("WEBGL_multisampled_render_to_texture")===!0&&b.__useRenderToTexture!==!1}function et(R){const b=o.render.frame;u.get(R)!==b&&(u.set(R,b),R.update())}function rt(R,b){const Y=R.colorSpace,j=R.format,Q=R.type;return R.isCompressedTexture===!0||R.isVideoTexture===!0||R.format===Hs||Y!==pn&&Y!==We&&(te.getTransfer(Y)===se?a===!1?t.has("EXT_sRGB")===!0&&j===je?(R.format=Hs,R.minFilter=ke,R.generateMipmaps=!1):b=Rl.sRGBToLinear(b):(j!==je||Q!==Tn)&&console.warn("THREE.WebGLTextures: sRGB encoded textures have to use RGBAFormat and UnsignedByteType."):console.error("THREE.WebGLTextures: Unsupported texture color space:",Y)),b}this.allocateTextureUnit=S,this.resetTextureUnits=z,this.setTexture2D=g,this.setTexture2DArray=T,this.setTexture3D=L,this.setTextureCube=N,this.rebindTextures=Mt,this.setupRenderTarget=k,this.updateRenderTargetMipmap=tt,this.updateMultisampleRenderTarget=G,this.setupDepthRenderbuffer=ct,this.setupFrameBufferTexture=xt,this.useMultisampledRTT=V}function pm(i,t,e){const n=e.isWebGL2;function r(s,o=We){let a;const l=te.getTransfer(o);if(s===Tn)return i.UNSIGNED_BYTE;if(s===_l)return i.UNSIGNED_SHORT_4_4_4_4;if(s===vl)return i.UNSIGNED_SHORT_5_5_5_1;if(s===Fc)return i.BYTE;if(s===Bc)return i.SHORT;if(s===Zs)return i.UNSIGNED_SHORT;if(s===gl)return i.INT;if(s===Sn)return i.UNSIGNED_INT;if(s===bn)return i.FLOAT;if(s===dn)return n?i.HALF_FLOAT:(a=t.get("OES_texture_half_float"),a!==null?a.HALF_FLOAT_OES:null);if(s===zc)return i.ALPHA;if(s===je)return i.RGBA;if(s===Gc)return i.LUMINANCE;if(s===kc)return i.LUMINANCE_ALPHA;if(s===zn)return i.DEPTH_COMPONENT;if(s===Si)return i.DEPTH_STENCIL;if(s===Hs)return a=t.get("EXT_sRGB"),a!==null?a.SRGB_ALPHA_EXT:null;if(s===Hc)return i.RED;if(s===xl)return i.RED_INTEGER;if(s===Vc)return i.RG;if(s===Ml)return i.RG_INTEGER;if(s===yl)return i.RGBA_INTEGER;if(s===Jr||s===Qr||s===ts||s===es)if(l===se)if(a=t.get("WEBGL_compressed_texture_s3tc_srgb"),a!==null){if(s===Jr)return a.COMPRESSED_SRGB_S3TC_DXT1_EXT;if(s===Qr)return a.COMPRESSED_SRGB_ALPHA_S3TC_DXT1_EXT;if(s===ts)return a.COMPRESSED_SRGB_ALPHA_S3TC_DXT3_EXT;if(s===es)return a.COMPRESSED_SRGB_ALPHA_S3TC_DXT5_EXT}else return null;else if(a=t.get("WEBGL_compressed_texture_s3tc"),a!==null){if(s===Jr)return a.COMPRESSED_RGB_S3TC_DXT1_EXT;if(s===Qr)return a.COMPRESSED_RGBA_S3TC_DXT1_EXT;if(s===ts)return a.COMPRESSED_RGBA_S3TC_DXT3_EXT;if(s===es)return a.COMPRESSED_RGBA_S3TC_DXT5_EXT}else return null;if(s===wo||s===Ao||s===Ro||s===Co)if(a=t.get("WEBGL_compressed_texture_pvrtc"),a!==null){if(s===wo)return a.COMPRESSED_RGB_PVRTC_4BPPV1_IMG;if(s===Ao)return a.COMPRESSED_RGB_PVRTC_2BPPV1_IMG;if(s===Ro)return a.COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;if(s===Co)return a.COMPRESSED_RGBA_PVRTC_2BPPV1_IMG}else return null;if(s===Sl)return a=t.get("WEBGL_compressed_texture_etc1"),a!==null?a.COMPRESSED_RGB_ETC1_WEBGL:null;if(s===Po||s===Lo)if(a=t.get("WEBGL_compressed_texture_etc"),a!==null){if(s===Po)return l===se?a.COMPRESSED_SRGB8_ETC2:a.COMPRESSED_RGB8_ETC2;if(s===Lo)return l===se?a.COMPRESSED_SRGB8_ALPHA8_ETC2_EAC:a.COMPRESSED_RGBA8_ETC2_EAC}else return null;if(s===Do||s===Io||s===Uo||s===No||s===Oo||s===Fo||s===Bo||s===zo||s===Go||s===ko||s===Ho||s===Vo||s===Wo||s===Xo)if(a=t.get("WEBGL_compressed_texture_astc"),a!==null){if(s===Do)return l===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_4x4_KHR:a.COMPRESSED_RGBA_ASTC_4x4_KHR;if(s===Io)return l===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_5x4_KHR:a.COMPRESSED_RGBA_ASTC_5x4_KHR;if(s===Uo)return l===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_5x5_KHR:a.COMPRESSED_RGBA_ASTC_5x5_KHR;if(s===No)return l===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_6x5_KHR:a.COMPRESSED_RGBA_ASTC_6x5_KHR;if(s===Oo)return l===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_6x6_KHR:a.COMPRESSED_RGBA_ASTC_6x6_KHR;if(s===Fo)return l===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_8x5_KHR:a.COMPRESSED_RGBA_ASTC_8x5_KHR;if(s===Bo)return l===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_8x6_KHR:a.COMPRESSED_RGBA_ASTC_8x6_KHR;if(s===zo)return l===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_8x8_KHR:a.COMPRESSED_RGBA_ASTC_8x8_KHR;if(s===Go)return l===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_10x5_KHR:a.COMPRESSED_RGBA_ASTC_10x5_KHR;if(s===ko)return l===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_10x6_KHR:a.COMPRESSED_RGBA_ASTC_10x6_KHR;if(s===Ho)return l===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_10x8_KHR:a.COMPRESSED_RGBA_ASTC_10x8_KHR;if(s===Vo)return l===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_10x10_KHR:a.COMPRESSED_RGBA_ASTC_10x10_KHR;if(s===Wo)return l===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_12x10_KHR:a.COMPRESSED_RGBA_ASTC_12x10_KHR;if(s===Xo)return l===se?a.COMPRESSED_SRGB8_ALPHA8_ASTC_12x12_KHR:a.COMPRESSED_RGBA_ASTC_12x12_KHR}else return null;if(s===ns||s===qo||s===Yo)if(a=t.get("EXT_texture_compression_bptc"),a!==null){if(s===ns)return l===se?a.COMPRESSED_SRGB_ALPHA_BPTC_UNORM_EXT:a.COMPRESSED_RGBA_BPTC_UNORM_EXT;if(s===qo)return a.COMPRESSED_RGB_BPTC_SIGNED_FLOAT_EXT;if(s===Yo)return a.COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT_EXT}else return null;if(s===Wc||s===jo||s===$o||s===Ko)if(a=t.get("EXT_texture_compression_rgtc"),a!==null){if(s===ns)return a.COMPRESSED_RED_RGTC1_EXT;if(s===jo)return a.COMPRESSED_SIGNED_RED_RGTC1_EXT;if(s===$o)return a.COMPRESSED_RED_GREEN_RGTC2_EXT;if(s===Ko)return a.COMPRESSED_SIGNED_RED_GREEN_RGTC2_EXT}else return null;return s===Bn?n?i.UNSIGNED_INT_24_8:(a=t.get("WEBGL_depth_texture"),a!==null?a.UNSIGNED_INT_24_8_WEBGL:null):i[s]!==void 0?i[s]:null}return{convert:r}}class mm extends Oe{constructor(t=[]){super(),this.isArrayCamera=!0,this.cameras=t}}class Qt extends ue{constructor(){super(),this.isGroup=!0,this.type="Group"}}const gm={type:"move"};class Ts{constructor(){this._targetRay=null,this._grip=null,this._hand=null}getHandSpace(){return this._hand===null&&(this._hand=new Qt,this._hand.matrixAutoUpdate=!1,this._hand.visible=!1,this._hand.joints={},this._hand.inputState={pinching:!1}),this._hand}getTargetRaySpace(){return this._targetRay===null&&(this._targetRay=new Qt,this._targetRay.matrixAutoUpdate=!1,this._targetRay.visible=!1,this._targetRay.hasLinearVelocity=!1,this._targetRay.linearVelocity=new W,this._targetRay.hasAngularVelocity=!1,this._targetRay.angularVelocity=new W),this._targetRay}getGripSpace(){return this._grip===null&&(this._grip=new Qt,this._grip.matrixAutoUpdate=!1,this._grip.visible=!1,this._grip.hasLinearVelocity=!1,this._grip.linearVelocity=new W,this._grip.hasAngularVelocity=!1,this._grip.angularVelocity=new W),this._grip}dispatchEvent(t){return this._targetRay!==null&&this._targetRay.dispatchEvent(t),this._grip!==null&&this._grip.dispatchEvent(t),this._hand!==null&&this._hand.dispatchEvent(t),this}connect(t){if(t&&t.hand){const e=this._hand;if(e)for(const n of t.hand.values())this._getHandJoint(e,n)}return this.dispatchEvent({type:"connected",data:t}),this}disconnect(t){return this.dispatchEvent({type:"disconnected",data:t}),this._targetRay!==null&&(this._targetRay.visible=!1),this._grip!==null&&(this._grip.visible=!1),this._hand!==null&&(this._hand.visible=!1),this}update(t,e,n){let r=null,s=null,o=null;const a=this._targetRay,l=this._grip,c=this._hand;if(t&&e.session.visibilityState!=="visible-blurred"){if(c&&t.hand){o=!0;for(const x of t.hand.values()){const d=e.getJointPose(x,n),h=this._getHandJoint(c,x);d!==null&&(h.matrix.fromArray(d.transform.matrix),h.matrix.decompose(h.position,h.rotation,h.scale),h.matrixWorldNeedsUpdate=!0,h.jointRadius=d.radius),h.visible=d!==null}const u=c.joints["index-finger-tip"],f=c.joints["thumb-tip"],m=u.position.distanceTo(f.position),p=.02,v=.005;c.inputState.pinching&&m>p+v?(c.inputState.pinching=!1,this.dispatchEvent({type:"pinchend",handedness:t.handedness,target:this})):!c.inputState.pinching&&m<=p-v&&(c.inputState.pinching=!0,this.dispatchEvent({type:"pinchstart",handedness:t.handedness,target:this}))}else l!==null&&t.gripSpace&&(s=e.getPose(t.gripSpace,n),s!==null&&(l.matrix.fromArray(s.transform.matrix),l.matrix.decompose(l.position,l.rotation,l.scale),l.matrixWorldNeedsUpdate=!0,s.linearVelocity?(l.hasLinearVelocity=!0,l.linearVelocity.copy(s.linearVelocity)):l.hasLinearVelocity=!1,s.angularVelocity?(l.hasAngularVelocity=!0,l.angularVelocity.copy(s.angularVelocity)):l.hasAngularVelocity=!1));a!==null&&(r=e.getPose(t.targetRaySpace,n),r===null&&s!==null&&(r=s),r!==null&&(a.matrix.fromArray(r.transform.matrix),a.matrix.decompose(a.position,a.rotation,a.scale),a.matrixWorldNeedsUpdate=!0,r.linearVelocity?(a.hasLinearVelocity=!0,a.linearVelocity.copy(r.linearVelocity)):a.hasLinearVelocity=!1,r.angularVelocity?(a.hasAngularVelocity=!0,a.angularVelocity.copy(r.angularVelocity)):a.hasAngularVelocity=!1,this.dispatchEvent(gm)))}return a!==null&&(a.visible=r!==null),l!==null&&(l.visible=s!==null),c!==null&&(c.visible=o!==null),this}_getHandJoint(t,e){if(t.joints[e.jointName]===void 0){const n=new Qt;n.matrixAutoUpdate=!1,n.visible=!1,t.joints[e.jointName]=n,t.add(n)}return t.joints[e.jointName]}}class _m extends kn{constructor(t,e){super();const n=this;let r=null,s=1,o=null,a="local-floor",l=1,c=null,u=null,f=null,m=null,p=null,v=null;const x=e.getContextAttributes();let d=null,h=null;const y=[],_=[],w=new wt;let D=null;const P=new Oe;P.layers.enable(1),P.viewport=new oe;const I=new Oe;I.layers.enable(2),I.viewport=new oe;const F=[P,I],M=new mm;M.layers.enable(1),M.layers.enable(2);let A=null,K=null;this.cameraAutoUpdate=!0,this.enabled=!1,this.isPresenting=!1,this.getController=function(Z){let it=y[Z];return it===void 0&&(it=new Ts,y[Z]=it),it.getTargetRaySpace()},this.getControllerGrip=function(Z){let it=y[Z];return it===void 0&&(it=new Ts,y[Z]=it),it.getGripSpace()},this.getHand=function(Z){let it=y[Z];return it===void 0&&(it=new Ts,y[Z]=it),it.getHandSpace()};function O(Z){const it=_.indexOf(Z.inputSource);if(it===-1)return;const ut=y[it];ut!==void 0&&(ut.update(Z.inputSource,Z.frame,c||o),ut.dispatchEvent({type:Z.type,data:Z.inputSource}))}function z(){r.removeEventListener("select",O),r.removeEventListener("selectstart",O),r.removeEventListener("selectend",O),r.removeEventListener("squeeze",O),r.removeEventListener("squeezestart",O),r.removeEventListener("squeezeend",O),r.removeEventListener("end",z),r.removeEventListener("inputsourceschange",S);for(let Z=0;Z<y.length;Z++){const it=_[Z];it!==null&&(_[Z]=null,y[Z].disconnect(it))}A=null,K=null,t.setRenderTarget(d),p=null,m=null,f=null,r=null,h=null,q.stop(),n.isPresenting=!1,t.setPixelRatio(D),t.setSize(w.width,w.height,!1),n.dispatchEvent({type:"sessionend"})}this.setFramebufferScaleFactor=function(Z){s=Z,n.isPresenting===!0&&console.warn("THREE.WebXRManager: Cannot change framebuffer scale while presenting.")},this.setReferenceSpaceType=function(Z){a=Z,n.isPresenting===!0&&console.warn("THREE.WebXRManager: Cannot change reference space type while presenting.")},this.getReferenceSpace=function(){return c||o},this.setReferenceSpace=function(Z){c=Z},this.getBaseLayer=function(){return m!==null?m:p},this.getBinding=function(){return f},this.getFrame=function(){return v},this.getSession=function(){return r},this.setSession=async function(Z){if(r=Z,r!==null){if(d=t.getRenderTarget(),r.addEventListener("select",O),r.addEventListener("selectstart",O),r.addEventListener("selectend",O),r.addEventListener("squeeze",O),r.addEventListener("squeezestart",O),r.addEventListener("squeezeend",O),r.addEventListener("end",z),r.addEventListener("inputsourceschange",S),x.xrCompatible!==!0&&await e.makeXRCompatible(),D=t.getPixelRatio(),t.getSize(w),r.renderState.layers===void 0||t.capabilities.isWebGL2===!1){const it={antialias:r.renderState.layers===void 0?x.antialias:!0,alpha:!0,depth:x.depth,stencil:x.stencil,framebufferScaleFactor:s};p=new XRWebGLLayer(r,e,it),r.updateRenderState({baseLayer:p}),t.setPixelRatio(1),t.setSize(p.framebufferWidth,p.framebufferHeight,!1),h=new Ke(p.framebufferWidth,p.framebufferHeight,{format:je,type:Tn,colorSpace:t.outputColorSpace,stencilBuffer:x.stencil})}else{let it=null,ut=null,gt=null;x.depth&&(gt=x.stencil?e.DEPTH24_STENCIL8:e.DEPTH_COMPONENT24,it=x.stencil?Si:zn,ut=x.stencil?Bn:Sn);const xt={colorFormat:e.RGBA8,depthFormat:gt,scaleFactor:s};f=new XRWebGLBinding(r,e),m=f.createProjectionLayer(xt),r.updateRenderState({layers:[m]}),t.setPixelRatio(1),t.setSize(m.textureWidth,m.textureHeight,!1),h=new Ke(m.textureWidth,m.textureHeight,{format:je,type:Tn,depthTexture:new Bl(m.textureWidth,m.textureHeight,ut,void 0,void 0,void 0,void 0,void 0,void 0,it),stencilBuffer:x.stencil,colorSpace:t.outputColorSpace,samples:x.antialias?4:0});const Et=t.properties.get(h);Et.__ignoreDepthValues=m.ignoreDepthValues}h.isXRRenderTarget=!0,this.setFoveation(l),c=null,o=await r.requestReferenceSpace(a),q.setContext(r),q.start(),n.isPresenting=!0,n.dispatchEvent({type:"sessionstart"})}},this.getEnvironmentBlendMode=function(){if(r!==null)return r.environmentBlendMode};function S(Z){for(let it=0;it<Z.removed.length;it++){const ut=Z.removed[it],gt=_.indexOf(ut);gt>=0&&(_[gt]=null,y[gt].disconnect(ut))}for(let it=0;it<Z.added.length;it++){const ut=Z.added[it];let gt=_.indexOf(ut);if(gt===-1){for(let Et=0;Et<y.length;Et++)if(Et>=_.length){_.push(ut),gt=Et;break}else if(_[Et]===null){_[Et]=ut,gt=Et;break}if(gt===-1)break}const xt=y[gt];xt&&xt.connect(ut)}}const E=new W,g=new W;function T(Z,it,ut){E.setFromMatrixPosition(it.matrixWorld),g.setFromMatrixPosition(ut.matrixWorld);const gt=E.distanceTo(g),xt=it.projectionMatrix.elements,Et=ut.projectionMatrix.elements,lt=xt[14]/(xt[10]-1),ct=xt[14]/(xt[10]+1),Mt=(xt[9]+1)/xt[5],k=(xt[9]-1)/xt[5],tt=(xt[8]-1)/xt[0],G=(Et[8]+1)/Et[0],H=lt*tt,V=lt*G,et=gt/(-tt+G),rt=et*-tt;it.matrixWorld.decompose(Z.position,Z.quaternion,Z.scale),Z.translateX(rt),Z.translateZ(et),Z.matrixWorld.compose(Z.position,Z.quaternion,Z.scale),Z.matrixWorldInverse.copy(Z.matrixWorld).invert();const R=lt+et,b=ct+et,Y=H-rt,j=V+(gt-rt),Q=Mt*ct/b*R,J=k*ct/b*R;Z.projectionMatrix.makePerspective(Y,j,Q,J,R,b),Z.projectionMatrixInverse.copy(Z.projectionMatrix).invert()}function L(Z,it){it===null?Z.matrixWorld.copy(Z.matrix):Z.matrixWorld.multiplyMatrices(it.matrixWorld,Z.matrix),Z.matrixWorldInverse.copy(Z.matrixWorld).invert()}this.updateCamera=function(Z){if(r===null)return;M.near=I.near=P.near=Z.near,M.far=I.far=P.far=Z.far,(A!==M.near||K!==M.far)&&(r.updateRenderState({depthNear:M.near,depthFar:M.far}),A=M.near,K=M.far);const it=Z.parent,ut=M.cameras;L(M,it);for(let gt=0;gt<ut.length;gt++)L(ut[gt],it);ut.length===2?T(M,P,I):M.projectionMatrix.copy(P.projectionMatrix),N(Z,M,it)};function N(Z,it,ut){ut===null?Z.matrix.copy(it.matrixWorld):(Z.matrix.copy(ut.matrixWorld),Z.matrix.invert(),Z.matrix.multiply(it.matrixWorld)),Z.matrix.decompose(Z.position,Z.quaternion,Z.scale),Z.updateMatrixWorld(!0),Z.projectionMatrix.copy(it.projectionMatrix),Z.projectionMatrixInverse.copy(it.projectionMatrixInverse),Z.isPerspectiveCamera&&(Z.fov=Xi*2*Math.atan(1/Z.projectionMatrix.elements[5]),Z.zoom=1)}this.getCamera=function(){return M},this.getFoveation=function(){if(!(m===null&&p===null))return l},this.setFoveation=function(Z){l=Z,m!==null&&(m.fixedFoveation=Z),p!==null&&p.fixedFoveation!==void 0&&(p.fixedFoveation=Z)};let C=null;function U(Z,it){if(u=it.getViewerPose(c||o),v=it,u!==null){const ut=u.views;p!==null&&(t.setRenderTargetFramebuffer(h,p.framebuffer),t.setRenderTarget(h));let gt=!1;ut.length!==M.cameras.length&&(M.cameras.length=0,gt=!0);for(let xt=0;xt<ut.length;xt++){const Et=ut[xt];let lt=null;if(p!==null)lt=p.getViewport(Et);else{const Mt=f.getViewSubImage(m,Et);lt=Mt.viewport,xt===0&&(t.setRenderTargetTextures(h,Mt.colorTexture,m.ignoreDepthValues?void 0:Mt.depthStencilTexture),t.setRenderTarget(h))}let ct=F[xt];ct===void 0&&(ct=new Oe,ct.layers.enable(xt),ct.viewport=new oe,F[xt]=ct),ct.matrix.fromArray(Et.transform.matrix),ct.matrix.decompose(ct.position,ct.quaternion,ct.scale),ct.projectionMatrix.fromArray(Et.projectionMatrix),ct.projectionMatrixInverse.copy(ct.projectionMatrix).invert(),ct.viewport.set(lt.x,lt.y,lt.width,lt.height),xt===0&&(M.matrix.copy(ct.matrix),M.matrix.decompose(M.position,M.quaternion,M.scale)),gt===!0&&M.cameras.push(ct)}}for(let ut=0;ut<y.length;ut++){const gt=_[ut],xt=y[ut];gt!==null&&xt!==void 0&&xt.update(gt,it,c||o)}C&&C(Z,it),it.detectedPlanes&&n.dispatchEvent({type:"planesdetected",data:it}),v=null}const q=new Fl;q.setAnimationLoop(U),this.setAnimationLoop=function(Z){C=Z},this.dispose=function(){}}}function vm(i,t){function e(d,h){d.matrixAutoUpdate===!0&&d.updateMatrix(),h.value.copy(d.matrix)}function n(d,h){h.color.getRGB(d.fogColor.value,Ul(i)),h.isFog?(d.fogNear.value=h.near,d.fogFar.value=h.far):h.isFogExp2&&(d.fogDensity.value=h.density)}function r(d,h,y,_,w){h.isMeshBasicMaterial||h.isMeshLambertMaterial?s(d,h):h.isMeshToonMaterial?(s(d,h),f(d,h)):h.isMeshPhongMaterial?(s(d,h),u(d,h)):h.isMeshStandardMaterial?(s(d,h),m(d,h),h.isMeshPhysicalMaterial&&p(d,h,w)):h.isMeshMatcapMaterial?(s(d,h),v(d,h)):h.isMeshDepthMaterial?s(d,h):h.isMeshDistanceMaterial?(s(d,h),x(d,h)):h.isMeshNormalMaterial?s(d,h):h.isLineBasicMaterial?(o(d,h),h.isLineDashedMaterial&&a(d,h)):h.isPointsMaterial?l(d,h,y,_):h.isSpriteMaterial?c(d,h):h.isShadowMaterial?(d.color.value.copy(h.color),d.opacity.value=h.opacity):h.isShaderMaterial&&(h.uniformsNeedUpdate=!1)}function s(d,h){d.opacity.value=h.opacity,h.color&&d.diffuse.value.copy(h.color),h.emissive&&d.emissive.value.copy(h.emissive).multiplyScalar(h.emissiveIntensity),h.map&&(d.map.value=h.map,e(h.map,d.mapTransform)),h.alphaMap&&(d.alphaMap.value=h.alphaMap,e(h.alphaMap,d.alphaMapTransform)),h.bumpMap&&(d.bumpMap.value=h.bumpMap,e(h.bumpMap,d.bumpMapTransform),d.bumpScale.value=h.bumpScale,h.side===Te&&(d.bumpScale.value*=-1)),h.normalMap&&(d.normalMap.value=h.normalMap,e(h.normalMap,d.normalMapTransform),d.normalScale.value.copy(h.normalScale),h.side===Te&&d.normalScale.value.negate()),h.displacementMap&&(d.displacementMap.value=h.displacementMap,e(h.displacementMap,d.displacementMapTransform),d.displacementScale.value=h.displacementScale,d.displacementBias.value=h.displacementBias),h.emissiveMap&&(d.emissiveMap.value=h.emissiveMap,e(h.emissiveMap,d.emissiveMapTransform)),h.specularMap&&(d.specularMap.value=h.specularMap,e(h.specularMap,d.specularMapTransform)),h.alphaTest>0&&(d.alphaTest.value=h.alphaTest);const y=t.get(h).envMap;if(y&&(d.envMap.value=y,d.flipEnvMap.value=y.isCubeTexture&&y.isRenderTargetTexture===!1?-1:1,d.reflectivity.value=h.reflectivity,d.ior.value=h.ior,d.refractionRatio.value=h.refractionRatio),h.lightMap){d.lightMap.value=h.lightMap;const _=i._useLegacyLights===!0?Math.PI:1;d.lightMapIntensity.value=h.lightMapIntensity*_,e(h.lightMap,d.lightMapTransform)}h.aoMap&&(d.aoMap.value=h.aoMap,d.aoMapIntensity.value=h.aoMapIntensity,e(h.aoMap,d.aoMapTransform))}function o(d,h){d.diffuse.value.copy(h.color),d.opacity.value=h.opacity,h.map&&(d.map.value=h.map,e(h.map,d.mapTransform))}function a(d,h){d.dashSize.value=h.dashSize,d.totalSize.value=h.dashSize+h.gapSize,d.scale.value=h.scale}function l(d,h,y,_){d.diffuse.value.copy(h.color),d.opacity.value=h.opacity,d.size.value=h.size*y,d.scale.value=_*.5,h.map&&(d.map.value=h.map,e(h.map,d.uvTransform)),h.alphaMap&&(d.alphaMap.value=h.alphaMap,e(h.alphaMap,d.alphaMapTransform)),h.alphaTest>0&&(d.alphaTest.value=h.alphaTest)}function c(d,h){d.diffuse.value.copy(h.color),d.opacity.value=h.opacity,d.rotation.value=h.rotation,h.map&&(d.map.value=h.map,e(h.map,d.mapTransform)),h.alphaMap&&(d.alphaMap.value=h.alphaMap,e(h.alphaMap,d.alphaMapTransform)),h.alphaTest>0&&(d.alphaTest.value=h.alphaTest)}function u(d,h){d.specular.value.copy(h.specular),d.shininess.value=Math.max(h.shininess,1e-4)}function f(d,h){h.gradientMap&&(d.gradientMap.value=h.gradientMap)}function m(d,h){d.metalness.value=h.metalness,h.metalnessMap&&(d.metalnessMap.value=h.metalnessMap,e(h.metalnessMap,d.metalnessMapTransform)),d.roughness.value=h.roughness,h.roughnessMap&&(d.roughnessMap.value=h.roughnessMap,e(h.roughnessMap,d.roughnessMapTransform)),t.get(h).envMap&&(d.envMapIntensity.value=h.envMapIntensity)}function p(d,h,y){d.ior.value=h.ior,h.sheen>0&&(d.sheenColor.value.copy(h.sheenColor).multiplyScalar(h.sheen),d.sheenRoughness.value=h.sheenRoughness,h.sheenColorMap&&(d.sheenColorMap.value=h.sheenColorMap,e(h.sheenColorMap,d.sheenColorMapTransform)),h.sheenRoughnessMap&&(d.sheenRoughnessMap.value=h.sheenRoughnessMap,e(h.sheenRoughnessMap,d.sheenRoughnessMapTransform))),h.clearcoat>0&&(d.clearcoat.value=h.clearcoat,d.clearcoatRoughness.value=h.clearcoatRoughness,h.clearcoatMap&&(d.clearcoatMap.value=h.clearcoatMap,e(h.clearcoatMap,d.clearcoatMapTransform)),h.clearcoatRoughnessMap&&(d.clearcoatRoughnessMap.value=h.clearcoatRoughnessMap,e(h.clearcoatRoughnessMap,d.clearcoatRoughnessMapTransform)),h.clearcoatNormalMap&&(d.clearcoatNormalMap.value=h.clearcoatNormalMap,e(h.clearcoatNormalMap,d.clearcoatNormalMapTransform),d.clearcoatNormalScale.value.copy(h.clearcoatNormalScale),h.side===Te&&d.clearcoatNormalScale.value.negate())),h.iridescence>0&&(d.iridescence.value=h.iridescence,d.iridescenceIOR.value=h.iridescenceIOR,d.iridescenceThicknessMinimum.value=h.iridescenceThicknessRange[0],d.iridescenceThicknessMaximum.value=h.iridescenceThicknessRange[1],h.iridescenceMap&&(d.iridescenceMap.value=h.iridescenceMap,e(h.iridescenceMap,d.iridescenceMapTransform)),h.iridescenceThicknessMap&&(d.iridescenceThicknessMap.value=h.iridescenceThicknessMap,e(h.iridescenceThicknessMap,d.iridescenceThicknessMapTransform))),h.transmission>0&&(d.transmission.value=h.transmission,d.transmissionSamplerMap.value=y.texture,d.transmissionSamplerSize.value.set(y.width,y.height),h.transmissionMap&&(d.transmissionMap.value=h.transmissionMap,e(h.transmissionMap,d.transmissionMapTransform)),d.thickness.value=h.thickness,h.thicknessMap&&(d.thicknessMap.value=h.thicknessMap,e(h.thicknessMap,d.thicknessMapTransform)),d.attenuationDistance.value=h.attenuationDistance,d.attenuationColor.value.copy(h.attenuationColor)),h.anisotropy>0&&(d.anisotropyVector.value.set(h.anisotropy*Math.cos(h.anisotropyRotation),h.anisotropy*Math.sin(h.anisotropyRotation)),h.anisotropyMap&&(d.anisotropyMap.value=h.anisotropyMap,e(h.anisotropyMap,d.anisotropyMapTransform))),d.specularIntensity.value=h.specularIntensity,d.specularColor.value.copy(h.specularColor),h.specularColorMap&&(d.specularColorMap.value=h.specularColorMap,e(h.specularColorMap,d.specularColorMapTransform)),h.specularIntensityMap&&(d.specularIntensityMap.value=h.specularIntensityMap,e(h.specularIntensityMap,d.specularIntensityMapTransform))}function v(d,h){h.matcap&&(d.matcap.value=h.matcap)}function x(d,h){const y=t.get(h).light;d.referencePosition.value.setFromMatrixPosition(y.matrixWorld),d.nearDistance.value=y.shadow.camera.near,d.farDistance.value=y.shadow.camera.far}return{refreshFogUniforms:n,refreshMaterialUniforms:r}}function xm(i,t,e,n){let r={},s={},o=[];const a=e.isWebGL2?i.getParameter(i.MAX_UNIFORM_BUFFER_BINDINGS):0;function l(y,_){const w=_.program;n.uniformBlockBinding(y,w)}function c(y,_){let w=r[y.id];w===void 0&&(v(y),w=u(y),r[y.id]=w,y.addEventListener("dispose",d));const D=_.program;n.updateUBOMapping(y,D);const P=t.render.frame;s[y.id]!==P&&(m(y),s[y.id]=P)}function u(y){const _=f();y.__bindingPointIndex=_;const w=i.createBuffer(),D=y.__size,P=y.usage;return i.bindBuffer(i.UNIFORM_BUFFER,w),i.bufferData(i.UNIFORM_BUFFER,D,P),i.bindBuffer(i.UNIFORM_BUFFER,null),i.bindBufferBase(i.UNIFORM_BUFFER,_,w),w}function f(){for(let y=0;y<a;y++)if(o.indexOf(y)===-1)return o.push(y),y;return console.error("THREE.WebGLRenderer: Maximum number of simultaneously usable uniforms groups reached."),0}function m(y){const _=r[y.id],w=y.uniforms,D=y.__cache;i.bindBuffer(i.UNIFORM_BUFFER,_);for(let P=0,I=w.length;P<I;P++){const F=Array.isArray(w[P])?w[P]:[w[P]];for(let M=0,A=F.length;M<A;M++){const K=F[M];if(p(K,P,M,D)===!0){const O=K.__offset,z=Array.isArray(K.value)?K.value:[K.value];let S=0;for(let E=0;E<z.length;E++){const g=z[E],T=x(g);typeof g=="number"||typeof g=="boolean"?(K.__data[0]=g,i.bufferSubData(i.UNIFORM_BUFFER,O+S,K.__data)):g.isMatrix3?(K.__data[0]=g.elements[0],K.__data[1]=g.elements[1],K.__data[2]=g.elements[2],K.__data[3]=0,K.__data[4]=g.elements[3],K.__data[5]=g.elements[4],K.__data[6]=g.elements[5],K.__data[7]=0,K.__data[8]=g.elements[6],K.__data[9]=g.elements[7],K.__data[10]=g.elements[8],K.__data[11]=0):(g.toArray(K.__data,S),S+=T.storage/Float32Array.BYTES_PER_ELEMENT)}i.bufferSubData(i.UNIFORM_BUFFER,O,K.__data)}}}i.bindBuffer(i.UNIFORM_BUFFER,null)}function p(y,_,w,D){const P=y.value,I=_+"_"+w;if(D[I]===void 0)return typeof P=="number"||typeof P=="boolean"?D[I]=P:D[I]=P.clone(),!0;{const F=D[I];if(typeof P=="number"||typeof P=="boolean"){if(F!==P)return D[I]=P,!0}else if(F.equals(P)===!1)return F.copy(P),!0}return!1}function v(y){const _=y.uniforms;let w=0;const D=16;for(let I=0,F=_.length;I<F;I++){const M=Array.isArray(_[I])?_[I]:[_[I]];for(let A=0,K=M.length;A<K;A++){const O=M[A],z=Array.isArray(O.value)?O.value:[O.value];for(let S=0,E=z.length;S<E;S++){const g=z[S],T=x(g),L=w%D;L!==0&&D-L<T.boundary&&(w+=D-L),O.__data=new Float32Array(T.storage/Float32Array.BYTES_PER_ELEMENT),O.__offset=w,w+=T.storage}}}const P=w%D;return P>0&&(w+=D-P),y.__size=w,y.__cache={},this}function x(y){const _={boundary:0,storage:0};return typeof y=="number"||typeof y=="boolean"?(_.boundary=4,_.storage=4):y.isVector2?(_.boundary=8,_.storage=8):y.isVector3||y.isColor?(_.boundary=16,_.storage=12):y.isVector4?(_.boundary=16,_.storage=16):y.isMatrix3?(_.boundary=48,_.storage=48):y.isMatrix4?(_.boundary=64,_.storage=64):y.isTexture?console.warn("THREE.WebGLRenderer: Texture samplers can not be part of an uniforms group."):console.warn("THREE.WebGLRenderer: Unsupported uniform value type.",y),_}function d(y){const _=y.target;_.removeEventListener("dispose",d);const w=o.indexOf(_.__bindingPointIndex);o.splice(w,1),i.deleteBuffer(r[_.id]),delete r[_.id],delete s[_.id]}function h(){for(const y in r)i.deleteBuffer(r[y]);o=[],r={},s={}}return{bind:l,update:c,dispose:h}}class Wl{constructor(t={}){const{canvas:e=mu(),context:n=null,depth:r=!0,stencil:s=!0,alpha:o=!1,antialias:a=!1,premultipliedAlpha:l=!0,preserveDrawingBuffer:c=!1,powerPreference:u="default",failIfMajorPerformanceCaveat:f=!1}=t;this.isWebGLRenderer=!0;let m;n!==null?m=n.getContextAttributes().alpha:m=o;const p=new Uint32Array(4),v=new Int32Array(4);let x=null,d=null;const h=[],y=[];this.domElement=e,this.debug={checkShaderErrors:!0,onShaderError:null},this.autoClear=!0,this.autoClearColor=!0,this.autoClearDepth=!0,this.autoClearStencil=!0,this.sortObjects=!0,this.clippingPlanes=[],this.localClippingEnabled=!1,this._outputColorSpace=ce,this._useLegacyLights=!1,this.toneMapping=En,this.toneMappingExposure=1;const _=this;let w=!1,D=0,P=0,I=null,F=-1,M=null;const A=new oe,K=new oe;let O=null;const z=new Dt(0);let S=0,E=e.width,g=e.height,T=1,L=null,N=null;const C=new oe(0,0,E,g),U=new oe(0,0,E,g);let q=!1;const Z=new eo;let it=!1,ut=!1,gt=null;const xt=new ie,Et=new wt,lt=new W,ct={background:null,fog:null,environment:null,overrideMaterial:null,isScene:!0};function Mt(){return I===null?T:1}let k=n;function tt(B,ot){for(let dt=0;dt<B.length;dt++){const pt=B[dt],ht=e.getContext(pt,ot);if(ht!==null)return ht}return null}try{const B={alpha:!0,depth:r,stencil:s,antialias:a,premultipliedAlpha:l,preserveDrawingBuffer:c,powerPreference:u,failIfMajorPerformanceCaveat:f};if("setAttribute"in e&&e.setAttribute("data-engine",`three.js r${$s}`),e.addEventListener("webglcontextlost",_t,!1),e.addEventListener("webglcontextrestored",$,!1),e.addEventListener("webglcontextcreationerror",vt,!1),k===null){const ot=["webgl2","webgl","experimental-webgl"];if(_.isWebGL1Renderer===!0&&ot.shift(),k=tt(ot,B),k===null)throw tt(ot)?new Error("Error creating WebGL context with your selected attributes."):new Error("Error creating WebGL context.")}typeof WebGLRenderingContext<"u"&&k instanceof WebGLRenderingContext&&console.warn("THREE.WebGLRenderer: WebGL 1 support was deprecated in r153 and will be removed in r163."),k.getShaderPrecisionFormat===void 0&&(k.getShaderPrecisionFormat=function(){return{rangeMin:1,rangeMax:1,precision:1}})}catch(B){throw console.error("THREE.WebGLRenderer: "+B.message),B}let G,H,V,et,rt,R,b,Y,j,Q,J,nt,st,ft,yt,At,at,Rt,X,mt,Tt,St,Pt,zt;function kt(){G=new Cf(k),H=new bf(k,G,t),G.init(H),St=new pm(k,G,H),V=new dm(k,G,H),et=new Df(k),rt=new Jp,R=new fm(k,G,V,rt,H,St,et),b=new Tf(_),Y=new Rf(_),j=new zu(k,H),Pt=new yf(k,G,j,H),Q=new Pf(k,j,et,Pt),J=new Of(k,Q,j,et),X=new Nf(k,H,R),At=new Ef(rt),nt=new Zp(_,b,Y,G,H,Pt,At),st=new vm(_,rt),ft=new tm,yt=new om(G,H),Rt=new Mf(_,b,Y,V,J,m,l),at=new hm(_,J,H),zt=new xm(k,et,H,V),mt=new Sf(k,G,et,H),Tt=new Lf(k,G,et,H),et.programs=nt.programs,_.capabilities=H,_.extensions=G,_.properties=rt,_.renderLists=ft,_.shadowMap=at,_.state=V,_.info=et}kt();const Ht=new _m(_,k);this.xr=Ht,this.getContext=function(){return k},this.getContextAttributes=function(){return k.getContextAttributes()},this.forceContextLoss=function(){const B=G.get("WEBGL_lose_context");B&&B.loseContext()},this.forceContextRestore=function(){const B=G.get("WEBGL_lose_context");B&&B.restoreContext()},this.getPixelRatio=function(){return T},this.setPixelRatio=function(B){B!==void 0&&(T=B,this.setSize(E,g,!1))},this.getSize=function(B){return B.set(E,g)},this.setSize=function(B,ot,dt=!0){if(Ht.isPresenting){console.warn("THREE.WebGLRenderer: Can't change size while VR device is presenting.");return}E=B,g=ot,e.width=Math.floor(B*T),e.height=Math.floor(ot*T),dt===!0&&(e.style.width=B+"px",e.style.height=ot+"px"),this.setViewport(0,0,B,ot)},this.getDrawingBufferSize=function(B){return B.set(E*T,g*T).floor()},this.setDrawingBufferSize=function(B,ot,dt){E=B,g=ot,T=dt,e.width=Math.floor(B*dt),e.height=Math.floor(ot*dt),this.setViewport(0,0,B,ot)},this.getCurrentViewport=function(B){return B.copy(A)},this.getViewport=function(B){return B.copy(C)},this.setViewport=function(B,ot,dt,pt){B.isVector4?C.set(B.x,B.y,B.z,B.w):C.set(B,ot,dt,pt),V.viewport(A.copy(C).multiplyScalar(T).floor())},this.getScissor=function(B){return B.copy(U)},this.setScissor=function(B,ot,dt,pt){B.isVector4?U.set(B.x,B.y,B.z,B.w):U.set(B,ot,dt,pt),V.scissor(K.copy(U).multiplyScalar(T).floor())},this.getScissorTest=function(){return q},this.setScissorTest=function(B){V.setScissorTest(q=B)},this.setOpaqueSort=function(B){L=B},this.setTransparentSort=function(B){N=B},this.getClearColor=function(B){return B.copy(Rt.getClearColor())},this.setClearColor=function(){Rt.setClearColor.apply(Rt,arguments)},this.getClearAlpha=function(){return Rt.getClearAlpha()},this.setClearAlpha=function(){Rt.setClearAlpha.apply(Rt,arguments)},this.clear=function(B=!0,ot=!0,dt=!0){let pt=0;if(B){let ht=!1;if(I!==null){const Lt=I.texture.format;ht=Lt===yl||Lt===Ml||Lt===xl}if(ht){const Lt=I.texture.type,Ot=Lt===Tn||Lt===Sn||Lt===Zs||Lt===Bn||Lt===_l||Lt===vl,Bt=Rt.getClearColor(),Gt=Rt.getClearAlpha(),jt=Bt.r,Vt=Bt.g,Xt=Bt.b;Ot?(p[0]=jt,p[1]=Vt,p[2]=Xt,p[3]=Gt,k.clearBufferuiv(k.COLOR,0,p)):(v[0]=jt,v[1]=Vt,v[2]=Xt,v[3]=Gt,k.clearBufferiv(k.COLOR,0,v))}else pt|=k.COLOR_BUFFER_BIT}ot&&(pt|=k.DEPTH_BUFFER_BIT),dt&&(pt|=k.STENCIL_BUFFER_BIT,this.state.buffers.stencil.setMask(4294967295)),k.clear(pt)},this.clearColor=function(){this.clear(!0,!1,!1)},this.clearDepth=function(){this.clear(!1,!0,!1)},this.clearStencil=function(){this.clear(!1,!1,!0)},this.dispose=function(){e.removeEventListener("webglcontextlost",_t,!1),e.removeEventListener("webglcontextrestored",$,!1),e.removeEventListener("webglcontextcreationerror",vt,!1),ft.dispose(),yt.dispose(),rt.dispose(),b.dispose(),Y.dispose(),J.dispose(),Pt.dispose(),zt.dispose(),nt.dispose(),Ht.dispose(),Ht.removeEventListener("sessionstart",Ae),Ht.removeEventListener("sessionend",re),gt&&(gt.dispose(),gt=null),Re.stop()};function _t(B){B.preventDefault(),console.log("THREE.WebGLRenderer: Context Lost."),w=!0}function $(){console.log("THREE.WebGLRenderer: Context Restored."),w=!1;const B=et.autoReset,ot=at.enabled,dt=at.autoUpdate,pt=at.needsUpdate,ht=at.type;kt(),et.autoReset=B,at.enabled=ot,at.autoUpdate=dt,at.needsUpdate=pt,at.type=ht}function vt(B){console.error("THREE.WebGLRenderer: A WebGL context could not be created. Reason: ",B.statusMessage)}function bt(B){const ot=B.target;ot.removeEventListener("dispose",bt),Ut(ot)}function Ut(B){It(B),rt.remove(B)}function It(B){const ot=rt.get(B).programs;ot!==void 0&&(ot.forEach(function(dt){nt.releaseProgram(dt)}),B.isShaderMaterial&&nt.releaseShaderCache(B))}this.renderBufferDirect=function(B,ot,dt,pt,ht,Lt){ot===null&&(ot=ct);const Ot=ht.isMesh&&ht.matrixWorld.determinant()<0,Bt=nc(B,ot,dt,pt,ht);V.setMaterial(pt,Ot);let Gt=dt.index,jt=1;if(pt.wireframe===!0){if(Gt=Q.getWireframeAttribute(dt),Gt===void 0)return;jt=2}const Vt=dt.drawRange,Xt=dt.attributes.position;let de=Vt.start*jt,Ie=(Vt.start+Vt.count)*jt;Lt!==null&&(de=Math.max(de,Lt.start*jt),Ie=Math.min(Ie,(Lt.start+Lt.count)*jt)),Gt!==null?(de=Math.max(de,0),Ie=Math.min(Ie,Gt.count)):Xt!=null&&(de=Math.max(de,0),Ie=Math.min(Ie,Xt.count));const _e=Ie-de;if(_e<0||_e===1/0)return;Pt.setup(ht,pt,Bt,dt,Gt);let nn,ae=mt;if(Gt!==null&&(nn=j.get(Gt),ae=Tt,ae.setIndex(nn)),ht.isMesh)pt.wireframe===!0?(V.setLineWidth(pt.wireframeLinewidth*Mt()),ae.setMode(k.LINES)):ae.setMode(k.TRIANGLES);else if(ht.isLine){let $t=pt.linewidth;$t===void 0&&($t=1),V.setLineWidth($t*Mt()),ht.isLineSegments?ae.setMode(k.LINES):ht.isLineLoop?ae.setMode(k.LINE_LOOP):ae.setMode(k.LINE_STRIP)}else ht.isPoints?ae.setMode(k.POINTS):ht.isSprite&&ae.setMode(k.TRIANGLES);if(ht.isBatchedMesh)ae.renderMultiDraw(ht._multiDrawStarts,ht._multiDrawCounts,ht._multiDrawCount);else if(ht.isInstancedMesh)ae.renderInstances(de,_e,ht.count);else if(dt.isInstancedBufferGeometry){const $t=dt._maxInstanceCount!==void 0?dt._maxInstanceCount:1/0,Yr=Math.min(dt.instanceCount,$t);ae.renderInstances(de,_e,Yr)}else ae.render(de,_e)};function Wt(B,ot,dt){B.transparent===!0&&B.side===be&&B.forceSinglePass===!1?(B.side=Te,B.needsUpdate=!0,Ji(B,ot,dt),B.side=wn,B.needsUpdate=!0,Ji(B,ot,dt),B.side=be):Ji(B,ot,dt)}this.compile=function(B,ot,dt=null){dt===null&&(dt=B),d=yt.get(dt),d.init(),y.push(d),dt.traverseVisible(function(ht){ht.isLight&&ht.layers.test(ot.layers)&&(d.pushLight(ht),ht.castShadow&&d.pushShadow(ht))}),B!==dt&&B.traverseVisible(function(ht){ht.isLight&&ht.layers.test(ot.layers)&&(d.pushLight(ht),ht.castShadow&&d.pushShadow(ht))}),d.setupLights(_._useLegacyLights);const pt=new Set;return B.traverse(function(ht){const Lt=ht.material;if(Lt)if(Array.isArray(Lt))for(let Ot=0;Ot<Lt.length;Ot++){const Bt=Lt[Ot];Wt(Bt,dt,ht),pt.add(Bt)}else Wt(Lt,dt,ht),pt.add(Lt)}),y.pop(),d=null,pt},this.compileAsync=function(B,ot,dt=null){const pt=this.compile(B,ot,dt);return new Promise(ht=>{function Lt(){if(pt.forEach(function(Ot){rt.get(Ot).currentProgram.isReady()&&pt.delete(Ot)}),pt.size===0){ht(B);return}setTimeout(Lt,10)}G.get("KHR_parallel_shader_compile")!==null?Lt():setTimeout(Lt,10)})};let Zt=null;function he(B){Zt&&Zt(B)}function Ae(){Re.stop()}function re(){Re.start()}const Re=new Fl;Re.setAnimationLoop(he),typeof self<"u"&&Re.setContext(self),this.setAnimationLoop=function(B){Zt=B,Ht.setAnimationLoop(B),B===null?Re.stop():Re.start()},Ht.addEventListener("sessionstart",Ae),Ht.addEventListener("sessionend",re),this.render=function(B,ot){if(ot!==void 0&&ot.isCamera!==!0){console.error("THREE.WebGLRenderer.render: camera is not an instance of THREE.Camera.");return}if(w===!0)return;B.matrixWorldAutoUpdate===!0&&B.updateMatrixWorld(),ot.parent===null&&ot.matrixWorldAutoUpdate===!0&&ot.updateMatrixWorld(),Ht.enabled===!0&&Ht.isPresenting===!0&&(Ht.cameraAutoUpdate===!0&&Ht.updateCamera(ot),ot=Ht.getCamera()),B.isScene===!0&&B.onBeforeRender(_,B,ot,I),d=yt.get(B,y.length),d.init(),y.push(d),xt.multiplyMatrices(ot.projectionMatrix,ot.matrixWorldInverse),Z.setFromProjectionMatrix(xt),ut=this.localClippingEnabled,it=At.init(this.clippingPlanes,ut),x=ft.get(B,h.length),x.init(),h.push(x),Je(B,ot,0,_.sortObjects),x.finish(),_.sortObjects===!0&&x.sort(L,N),this.info.render.frame++,it===!0&&At.beginShadows();const dt=d.state.shadowsArray;if(at.render(dt,B,ot),it===!0&&At.endShadows(),this.info.autoReset===!0&&this.info.reset(),Rt.render(x,B),d.setupLights(_._useLegacyLights),ot.isArrayCamera){const pt=ot.cameras;for(let ht=0,Lt=pt.length;ht<Lt;ht++){const Ot=pt[ht];fo(x,B,Ot,Ot.viewport)}}else fo(x,B,ot);I!==null&&(R.updateMultisampleRenderTarget(I),R.updateRenderTargetMipmap(I)),B.isScene===!0&&B.onAfterRender(_,B,ot),Pt.resetDefaultState(),F=-1,M=null,y.pop(),y.length>0?d=y[y.length-1]:d=null,h.pop(),h.length>0?x=h[h.length-1]:x=null};function Je(B,ot,dt,pt){if(B.visible===!1)return;if(B.layers.test(ot.layers)){if(B.isGroup)dt=B.renderOrder;else if(B.isLOD)B.autoUpdate===!0&&B.update(ot);else if(B.isLight)d.pushLight(B),B.castShadow&&d.pushShadow(B);else if(B.isSprite){if(!B.frustumCulled||Z.intersectsSprite(B)){pt&&lt.setFromMatrixPosition(B.matrixWorld).applyMatrix4(xt);const Ot=J.update(B),Bt=B.material;Bt.visible&&x.push(B,Ot,Bt,dt,lt.z,null)}}else if((B.isMesh||B.isLine||B.isPoints)&&(!B.frustumCulled||Z.intersectsObject(B))){const Ot=J.update(B),Bt=B.material;if(pt&&(B.boundingSphere!==void 0?(B.boundingSphere===null&&B.computeBoundingSphere(),lt.copy(B.boundingSphere.center)):(Ot.boundingSphere===null&&Ot.computeBoundingSphere(),lt.copy(Ot.boundingSphere.center)),lt.applyMatrix4(B.matrixWorld).applyMatrix4(xt)),Array.isArray(Bt)){const Gt=Ot.groups;for(let jt=0,Vt=Gt.length;jt<Vt;jt++){const Xt=Gt[jt],de=Bt[Xt.materialIndex];de&&de.visible&&x.push(B,Ot,de,dt,lt.z,Xt)}}else Bt.visible&&x.push(B,Ot,Bt,dt,lt.z,null)}}const Lt=B.children;for(let Ot=0,Bt=Lt.length;Ot<Bt;Ot++)Je(Lt[Ot],ot,dt,pt)}function fo(B,ot,dt,pt){const ht=B.opaque,Lt=B.transmissive,Ot=B.transparent;d.setupLightsView(dt),it===!0&&At.setGlobalState(_.clippingPlanes,dt),Lt.length>0&&ec(ht,Lt,ot,dt),pt&&V.viewport(A.copy(pt)),ht.length>0&&Zi(ht,ot,dt),Lt.length>0&&Zi(Lt,ot,dt),Ot.length>0&&Zi(Ot,ot,dt),V.buffers.depth.setTest(!0),V.buffers.depth.setMask(!0),V.buffers.color.setMask(!0),V.setPolygonOffset(!1)}function ec(B,ot,dt,pt){if((dt.isScene===!0?dt.overrideMaterial:null)!==null)return;const Lt=H.isWebGL2;gt===null&&(gt=new Ke(1,1,{generateMipmaps:!0,type:G.has("EXT_color_buffer_half_float")?dn:Tn,minFilter:Wi,samples:Lt?4:0})),_.getDrawingBufferSize(Et),Lt?gt.setSize(Et.x,Et.y):gt.setSize(Or(Et.x),Or(Et.y));const Ot=_.getRenderTarget();_.setRenderTarget(gt),_.getClearColor(z),S=_.getClearAlpha(),S<1&&_.setClearColor(16777215,.5),_.clear();const Bt=_.toneMapping;_.toneMapping=En,Zi(B,dt,pt),R.updateMultisampleRenderTarget(gt),R.updateRenderTargetMipmap(gt);let Gt=!1;for(let jt=0,Vt=ot.length;jt<Vt;jt++){const Xt=ot[jt],de=Xt.object,Ie=Xt.geometry,_e=Xt.material,nn=Xt.group;if(_e.side===be&&de.layers.test(pt.layers)){const ae=_e.side;_e.side=Te,_e.needsUpdate=!0,po(de,dt,pt,Ie,_e,nn),_e.side=ae,_e.needsUpdate=!0,Gt=!0}}Gt===!0&&(R.updateMultisampleRenderTarget(gt),R.updateRenderTargetMipmap(gt)),_.setRenderTarget(Ot),_.setClearColor(z,S),_.toneMapping=Bt}function Zi(B,ot,dt){const pt=ot.isScene===!0?ot.overrideMaterial:null;for(let ht=0,Lt=B.length;ht<Lt;ht++){const Ot=B[ht],Bt=Ot.object,Gt=Ot.geometry,jt=pt===null?Ot.material:pt,Vt=Ot.group;Bt.layers.test(dt.layers)&&po(Bt,ot,dt,Gt,jt,Vt)}}function po(B,ot,dt,pt,ht,Lt){B.onBeforeRender(_,ot,dt,pt,ht,Lt),B.modelViewMatrix.multiplyMatrices(dt.matrixWorldInverse,B.matrixWorld),B.normalMatrix.getNormalMatrix(B.modelViewMatrix),ht.onBeforeRender(_,ot,dt,pt,B,Lt),ht.transparent===!0&&ht.side===be&&ht.forceSinglePass===!1?(ht.side=Te,ht.needsUpdate=!0,_.renderBufferDirect(dt,ot,pt,ht,B,Lt),ht.side=wn,ht.needsUpdate=!0,_.renderBufferDirect(dt,ot,pt,ht,B,Lt),ht.side=be):_.renderBufferDirect(dt,ot,pt,ht,B,Lt),B.onAfterRender(_,ot,dt,pt,ht,Lt)}function Ji(B,ot,dt){ot.isScene!==!0&&(ot=ct);const pt=rt.get(B),ht=d.state.lights,Lt=d.state.shadowsArray,Ot=ht.state.version,Bt=nt.getParameters(B,ht.state,Lt,ot,dt),Gt=nt.getProgramCacheKey(Bt);let jt=pt.programs;pt.environment=B.isMeshStandardMaterial?ot.environment:null,pt.fog=ot.fog,pt.envMap=(B.isMeshStandardMaterial?Y:b).get(B.envMap||pt.environment),jt===void 0&&(B.addEventListener("dispose",bt),jt=new Map,pt.programs=jt);let Vt=jt.get(Gt);if(Vt!==void 0){if(pt.currentProgram===Vt&&pt.lightsStateVersion===Ot)return go(B,Bt),Vt}else Bt.uniforms=nt.getUniforms(B),B.onBuild(dt,Bt,_),B.onBeforeCompile(Bt,_),Vt=nt.acquireProgram(Bt,Gt),jt.set(Gt,Vt),pt.uniforms=Bt.uniforms;const Xt=pt.uniforms;return(!B.isShaderMaterial&&!B.isRawShaderMaterial||B.clipping===!0)&&(Xt.clippingPlanes=At.uniform),go(B,Bt),pt.needsLights=rc(B),pt.lightsStateVersion=Ot,pt.needsLights&&(Xt.ambientLightColor.value=ht.state.ambient,Xt.lightProbe.value=ht.state.probe,Xt.directionalLights.value=ht.state.directional,Xt.directionalLightShadows.value=ht.state.directionalShadow,Xt.spotLights.value=ht.state.spot,Xt.spotLightShadows.value=ht.state.spotShadow,Xt.rectAreaLights.value=ht.state.rectArea,Xt.ltc_1.value=ht.state.rectAreaLTC1,Xt.ltc_2.value=ht.state.rectAreaLTC2,Xt.pointLights.value=ht.state.point,Xt.pointLightShadows.value=ht.state.pointShadow,Xt.hemisphereLights.value=ht.state.hemi,Xt.directionalShadowMap.value=ht.state.directionalShadowMap,Xt.directionalShadowMatrix.value=ht.state.directionalShadowMatrix,Xt.spotShadowMap.value=ht.state.spotShadowMap,Xt.spotLightMatrix.value=ht.state.spotLightMatrix,Xt.spotLightMap.value=ht.state.spotLightMap,Xt.pointShadowMap.value=ht.state.pointShadowMap,Xt.pointShadowMatrix.value=ht.state.pointShadowMatrix),pt.currentProgram=Vt,pt.uniformsList=null,Vt}function mo(B){if(B.uniformsList===null){const ot=B.currentProgram.getUniforms();B.uniformsList=Pr.seqWithValue(ot.seq,B.uniforms)}return B.uniformsList}function go(B,ot){const dt=rt.get(B);dt.outputColorSpace=ot.outputColorSpace,dt.batching=ot.batching,dt.instancing=ot.instancing,dt.instancingColor=ot.instancingColor,dt.skinning=ot.skinning,dt.morphTargets=ot.morphTargets,dt.morphNormals=ot.morphNormals,dt.morphColors=ot.morphColors,dt.morphTargetsCount=ot.morphTargetsCount,dt.numClippingPlanes=ot.numClippingPlanes,dt.numIntersection=ot.numClipIntersection,dt.vertexAlphas=ot.vertexAlphas,dt.vertexTangents=ot.vertexTangents,dt.toneMapping=ot.toneMapping}function nc(B,ot,dt,pt,ht){ot.isScene!==!0&&(ot=ct),R.resetTextureUnits();const Lt=ot.fog,Ot=pt.isMeshStandardMaterial?ot.environment:null,Bt=I===null?_.outputColorSpace:I.isXRRenderTarget===!0?I.texture.colorSpace:pn,Gt=(pt.isMeshStandardMaterial?Y:b).get(pt.envMap||Ot),jt=pt.vertexColors===!0&&!!dt.attributes.color&&dt.attributes.color.itemSize===4,Vt=!!dt.attributes.tangent&&(!!pt.normalMap||pt.anisotropy>0),Xt=!!dt.morphAttributes.position,de=!!dt.morphAttributes.normal,Ie=!!dt.morphAttributes.color;let _e=En;pt.toneMapped&&(I===null||I.isXRRenderTarget===!0)&&(_e=_.toneMapping);const nn=dt.morphAttributes.position||dt.morphAttributes.normal||dt.morphAttributes.color,ae=nn!==void 0?nn.length:0,$t=rt.get(pt),Yr=d.state.lights;if(it===!0&&(ut===!0||B!==M)){const ze=B===M&&pt.id===F;At.setState(pt,B,ze)}let le=!1;pt.version===$t.__version?($t.needsLights&&$t.lightsStateVersion!==Yr.state.version||$t.outputColorSpace!==Bt||ht.isBatchedMesh&&$t.batching===!1||!ht.isBatchedMesh&&$t.batching===!0||ht.isInstancedMesh&&$t.instancing===!1||!ht.isInstancedMesh&&$t.instancing===!0||ht.isSkinnedMesh&&$t.skinning===!1||!ht.isSkinnedMesh&&$t.skinning===!0||ht.isInstancedMesh&&$t.instancingColor===!0&&ht.instanceColor===null||ht.isInstancedMesh&&$t.instancingColor===!1&&ht.instanceColor!==null||$t.envMap!==Gt||pt.fog===!0&&$t.fog!==Lt||$t.numClippingPlanes!==void 0&&($t.numClippingPlanes!==At.numPlanes||$t.numIntersection!==At.numIntersection)||$t.vertexAlphas!==jt||$t.vertexTangents!==Vt||$t.morphTargets!==Xt||$t.morphNormals!==de||$t.morphColors!==Ie||$t.toneMapping!==_e||H.isWebGL2===!0&&$t.morphTargetsCount!==ae)&&(le=!0):(le=!0,$t.__version=pt.version);let Cn=$t.currentProgram;le===!0&&(Cn=Ji(pt,ot,ht));let _o=!1,Ri=!1,jr=!1;const Me=Cn.getUniforms(),Pn=$t.uniforms;if(V.useProgram(Cn.program)&&(_o=!0,Ri=!0,jr=!0),pt.id!==F&&(F=pt.id,Ri=!0),_o||M!==B){Me.setValue(k,"projectionMatrix",B.projectionMatrix),Me.setValue(k,"viewMatrix",B.matrixWorldInverse);const ze=Me.map.cameraPosition;ze!==void 0&&ze.setValue(k,lt.setFromMatrixPosition(B.matrixWorld)),H.logarithmicDepthBuffer&&Me.setValue(k,"logDepthBufFC",2/(Math.log(B.far+1)/Math.LN2)),(pt.isMeshPhongMaterial||pt.isMeshToonMaterial||pt.isMeshLambertMaterial||pt.isMeshBasicMaterial||pt.isMeshStandardMaterial||pt.isShaderMaterial)&&Me.setValue(k,"isOrthographic",B.isOrthographicCamera===!0),M!==B&&(M=B,Ri=!0,jr=!0)}if(ht.isSkinnedMesh){Me.setOptional(k,ht,"bindMatrix"),Me.setOptional(k,ht,"bindMatrixInverse");const ze=ht.skeleton;ze&&(H.floatVertexTextures?(ze.boneTexture===null&&ze.computeBoneTexture(),Me.setValue(k,"boneTexture",ze.boneTexture,R)):console.warn("THREE.WebGLRenderer: SkinnedMesh can only be used with WebGL 2. With WebGL 1 OES_texture_float and vertex textures support is required."))}ht.isBatchedMesh&&(Me.setOptional(k,ht,"batchingTexture"),Me.setValue(k,"batchingTexture",ht._matricesTexture,R));const $r=dt.morphAttributes;if(($r.position!==void 0||$r.normal!==void 0||$r.color!==void 0&&H.isWebGL2===!0)&&X.update(ht,dt,Cn),(Ri||$t.receiveShadow!==ht.receiveShadow)&&($t.receiveShadow=ht.receiveShadow,Me.setValue(k,"receiveShadow",ht.receiveShadow)),pt.isMeshGouraudMaterial&&pt.envMap!==null&&(Pn.envMap.value=Gt,Pn.flipEnvMap.value=Gt.isCubeTexture&&Gt.isRenderTargetTexture===!1?-1:1),Ri&&(Me.setValue(k,"toneMappingExposure",_.toneMappingExposure),$t.needsLights&&ic(Pn,jr),Lt&&pt.fog===!0&&st.refreshFogUniforms(Pn,Lt),st.refreshMaterialUniforms(Pn,pt,T,g,gt),Pr.upload(k,mo($t),Pn,R)),pt.isShaderMaterial&&pt.uniformsNeedUpdate===!0&&(Pr.upload(k,mo($t),Pn,R),pt.uniformsNeedUpdate=!1),pt.isSpriteMaterial&&Me.setValue(k,"center",ht.center),Me.setValue(k,"modelViewMatrix",ht.modelViewMatrix),Me.setValue(k,"normalMatrix",ht.normalMatrix),Me.setValue(k,"modelMatrix",ht.matrixWorld),pt.isShaderMaterial||pt.isRawShaderMaterial){const ze=pt.uniformsGroups;for(let Kr=0,sc=ze.length;Kr<sc;Kr++)if(H.isWebGL2){const vo=ze[Kr];zt.update(vo,Cn),zt.bind(vo,Cn)}else console.warn("THREE.WebGLRenderer: Uniform Buffer Objects can only be used with WebGL 2.")}return Cn}function ic(B,ot){B.ambientLightColor.needsUpdate=ot,B.lightProbe.needsUpdate=ot,B.directionalLights.needsUpdate=ot,B.directionalLightShadows.needsUpdate=ot,B.pointLights.needsUpdate=ot,B.pointLightShadows.needsUpdate=ot,B.spotLights.needsUpdate=ot,B.spotLightShadows.needsUpdate=ot,B.rectAreaLights.needsUpdate=ot,B.hemisphereLights.needsUpdate=ot}function rc(B){return B.isMeshLambertMaterial||B.isMeshToonMaterial||B.isMeshPhongMaterial||B.isMeshStandardMaterial||B.isShadowMaterial||B.isShaderMaterial&&B.lights===!0}this.getActiveCubeFace=function(){return D},this.getActiveMipmapLevel=function(){return P},this.getRenderTarget=function(){return I},this.setRenderTargetTextures=function(B,ot,dt){rt.get(B.texture).__webglTexture=ot,rt.get(B.depthTexture).__webglTexture=dt;const pt=rt.get(B);pt.__hasExternalTextures=!0,pt.__hasExternalTextures&&(pt.__autoAllocateDepthBuffer=dt===void 0,pt.__autoAllocateDepthBuffer||G.has("WEBGL_multisampled_render_to_texture")===!0&&(console.warn("THREE.WebGLRenderer: Render-to-texture extension was disabled because an external texture was provided"),pt.__useRenderToTexture=!1))},this.setRenderTargetFramebuffer=function(B,ot){const dt=rt.get(B);dt.__webglFramebuffer=ot,dt.__useDefaultFramebuffer=ot===void 0},this.setRenderTarget=function(B,ot=0,dt=0){I=B,D=ot,P=dt;let pt=!0,ht=null,Lt=!1,Ot=!1;if(B){const Gt=rt.get(B);Gt.__useDefaultFramebuffer!==void 0?(V.bindFramebuffer(k.FRAMEBUFFER,null),pt=!1):Gt.__webglFramebuffer===void 0?R.setupRenderTarget(B):Gt.__hasExternalTextures&&R.rebindTextures(B,rt.get(B.texture).__webglTexture,rt.get(B.depthTexture).__webglTexture);const jt=B.texture;(jt.isData3DTexture||jt.isDataArrayTexture||jt.isCompressedArrayTexture)&&(Ot=!0);const Vt=rt.get(B).__webglFramebuffer;B.isWebGLCubeRenderTarget?(Array.isArray(Vt[ot])?ht=Vt[ot][dt]:ht=Vt[ot],Lt=!0):H.isWebGL2&&B.samples>0&&R.useMultisampledRTT(B)===!1?ht=rt.get(B).__webglMultisampledFramebuffer:Array.isArray(Vt)?ht=Vt[dt]:ht=Vt,A.copy(B.viewport),K.copy(B.scissor),O=B.scissorTest}else A.copy(C).multiplyScalar(T).floor(),K.copy(U).multiplyScalar(T).floor(),O=q;if(V.bindFramebuffer(k.FRAMEBUFFER,ht)&&H.drawBuffers&&pt&&V.drawBuffers(B,ht),V.viewport(A),V.scissor(K),V.setScissorTest(O),Lt){const Gt=rt.get(B.texture);k.framebufferTexture2D(k.FRAMEBUFFER,k.COLOR_ATTACHMENT0,k.TEXTURE_CUBE_MAP_POSITIVE_X+ot,Gt.__webglTexture,dt)}else if(Ot){const Gt=rt.get(B.texture),jt=ot||0;k.framebufferTextureLayer(k.FRAMEBUFFER,k.COLOR_ATTACHMENT0,Gt.__webglTexture,dt||0,jt)}F=-1},this.readRenderTargetPixels=function(B,ot,dt,pt,ht,Lt,Ot){if(!(B&&B.isWebGLRenderTarget)){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not THREE.WebGLRenderTarget.");return}let Bt=rt.get(B).__webglFramebuffer;if(B.isWebGLCubeRenderTarget&&Ot!==void 0&&(Bt=Bt[Ot]),Bt){V.bindFramebuffer(k.FRAMEBUFFER,Bt);try{const Gt=B.texture,jt=Gt.format,Vt=Gt.type;if(jt!==je&&St.convert(jt)!==k.getParameter(k.IMPLEMENTATION_COLOR_READ_FORMAT)){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not in RGBA or implementation defined format.");return}const Xt=Vt===dn&&(G.has("EXT_color_buffer_half_float")||H.isWebGL2&&G.has("EXT_color_buffer_float"));if(Vt!==Tn&&St.convert(Vt)!==k.getParameter(k.IMPLEMENTATION_COLOR_READ_TYPE)&&!(Vt===bn&&(H.isWebGL2||G.has("OES_texture_float")||G.has("WEBGL_color_buffer_float")))&&!Xt){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not in UnsignedByteType or implementation defined type.");return}ot>=0&&ot<=B.width-pt&&dt>=0&&dt<=B.height-ht&&k.readPixels(ot,dt,pt,ht,St.convert(jt),St.convert(Vt),Lt)}finally{const Gt=I!==null?rt.get(I).__webglFramebuffer:null;V.bindFramebuffer(k.FRAMEBUFFER,Gt)}}},this.copyFramebufferToTexture=function(B,ot,dt=0){const pt=Math.pow(2,-dt),ht=Math.floor(ot.image.width*pt),Lt=Math.floor(ot.image.height*pt);R.setTexture2D(ot,0),k.copyTexSubImage2D(k.TEXTURE_2D,dt,0,0,B.x,B.y,ht,Lt),V.unbindTexture()},this.copyTextureToTexture=function(B,ot,dt,pt=0){const ht=ot.image.width,Lt=ot.image.height,Ot=St.convert(dt.format),Bt=St.convert(dt.type);R.setTexture2D(dt,0),k.pixelStorei(k.UNPACK_FLIP_Y_WEBGL,dt.flipY),k.pixelStorei(k.UNPACK_PREMULTIPLY_ALPHA_WEBGL,dt.premultiplyAlpha),k.pixelStorei(k.UNPACK_ALIGNMENT,dt.unpackAlignment),ot.isDataTexture?k.texSubImage2D(k.TEXTURE_2D,pt,B.x,B.y,ht,Lt,Ot,Bt,ot.image.data):ot.isCompressedTexture?k.compressedTexSubImage2D(k.TEXTURE_2D,pt,B.x,B.y,ot.mipmaps[0].width,ot.mipmaps[0].height,Ot,ot.mipmaps[0].data):k.texSubImage2D(k.TEXTURE_2D,pt,B.x,B.y,Ot,Bt,ot.image),pt===0&&dt.generateMipmaps&&k.generateMipmap(k.TEXTURE_2D),V.unbindTexture()},this.copyTextureToTexture3D=function(B,ot,dt,pt,ht=0){if(_.isWebGL1Renderer){console.warn("THREE.WebGLRenderer.copyTextureToTexture3D: can only be used with WebGL2.");return}const Lt=B.max.x-B.min.x+1,Ot=B.max.y-B.min.y+1,Bt=B.max.z-B.min.z+1,Gt=St.convert(pt.format),jt=St.convert(pt.type);let Vt;if(pt.isData3DTexture)R.setTexture3D(pt,0),Vt=k.TEXTURE_3D;else if(pt.isDataArrayTexture||pt.isCompressedArrayTexture)R.setTexture2DArray(pt,0),Vt=k.TEXTURE_2D_ARRAY;else{console.warn("THREE.WebGLRenderer.copyTextureToTexture3D: only supports THREE.DataTexture3D and THREE.DataTexture2DArray.");return}k.pixelStorei(k.UNPACK_FLIP_Y_WEBGL,pt.flipY),k.pixelStorei(k.UNPACK_PREMULTIPLY_ALPHA_WEBGL,pt.premultiplyAlpha),k.pixelStorei(k.UNPACK_ALIGNMENT,pt.unpackAlignment);const Xt=k.getParameter(k.UNPACK_ROW_LENGTH),de=k.getParameter(k.UNPACK_IMAGE_HEIGHT),Ie=k.getParameter(k.UNPACK_SKIP_PIXELS),_e=k.getParameter(k.UNPACK_SKIP_ROWS),nn=k.getParameter(k.UNPACK_SKIP_IMAGES),ae=dt.isCompressedTexture?dt.mipmaps[ht]:dt.image;k.pixelStorei(k.UNPACK_ROW_LENGTH,ae.width),k.pixelStorei(k.UNPACK_IMAGE_HEIGHT,ae.height),k.pixelStorei(k.UNPACK_SKIP_PIXELS,B.min.x),k.pixelStorei(k.UNPACK_SKIP_ROWS,B.min.y),k.pixelStorei(k.UNPACK_SKIP_IMAGES,B.min.z),dt.isDataTexture||dt.isData3DTexture?k.texSubImage3D(Vt,ht,ot.x,ot.y,ot.z,Lt,Ot,Bt,Gt,jt,ae.data):dt.isCompressedArrayTexture?(console.warn("THREE.WebGLRenderer.copyTextureToTexture3D: untested support for compressed srcTexture."),k.compressedTexSubImage3D(Vt,ht,ot.x,ot.y,ot.z,Lt,Ot,Bt,Gt,ae.data)):k.texSubImage3D(Vt,ht,ot.x,ot.y,ot.z,Lt,Ot,Bt,Gt,jt,ae),k.pixelStorei(k.UNPACK_ROW_LENGTH,Xt),k.pixelStorei(k.UNPACK_IMAGE_HEIGHT,de),k.pixelStorei(k.UNPACK_SKIP_PIXELS,Ie),k.pixelStorei(k.UNPACK_SKIP_ROWS,_e),k.pixelStorei(k.UNPACK_SKIP_IMAGES,nn),ht===0&&pt.generateMipmaps&&k.generateMipmap(Vt),V.unbindTexture()},this.initTexture=function(B){B.isCubeTexture?R.setTextureCube(B,0):B.isData3DTexture?R.setTexture3D(B,0):B.isDataArrayTexture||B.isCompressedArrayTexture?R.setTexture2DArray(B,0):R.setTexture2D(B,0),V.unbindTexture()},this.resetState=function(){D=0,P=0,I=null,V.reset(),Pt.reset()},typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("observe",{detail:this}))}get coordinateSystem(){return un}get outputColorSpace(){return this._outputColorSpace}set outputColorSpace(t){this._outputColorSpace=t;const e=this.getContext();e.drawingBufferColorSpace=t===Js?"display-p3":"srgb",e.unpackColorSpace=te.workingColorSpace===Hr?"display-p3":"srgb"}get outputEncoding(){return console.warn("THREE.WebGLRenderer: Property .outputEncoding has been removed. Use .outputColorSpace instead."),this.outputColorSpace===ce?Gn:bl}set outputEncoding(t){console.warn("THREE.WebGLRenderer: Property .outputEncoding has been removed. Use .outputColorSpace instead."),this.outputColorSpace=t===Gn?ce:pn}get useLegacyLights(){return console.warn("THREE.WebGLRenderer: The property .useLegacyLights has been deprecated. Migrate your lighting according to the following guide: https://discourse.threejs.org/t/updates-to-lighting-in-three-js-r155/53733."),this._useLegacyLights}set useLegacyLights(t){console.warn("THREE.WebGLRenderer: The property .useLegacyLights has been deprecated. Migrate your lighting according to the following guide: https://discourse.threejs.org/t/updates-to-lighting-in-three-js-r155/53733."),this._useLegacyLights=t}}class Mm extends Wl{}Mm.prototype.isWebGL1Renderer=!0;class ro{constructor(t,e=1,n=1e3){this.isFog=!0,this.name="",this.color=new Dt(t),this.near=e,this.far=n}clone(){return new ro(this.color,this.near,this.far)}toJSON(){return{type:"Fog",name:this.name,color:this.color.getHex(),near:this.near,far:this.far}}}class Xl extends ue{constructor(){super(),this.isScene=!0,this.type="Scene",this.background=null,this.environment=null,this.fog=null,this.backgroundBlurriness=0,this.backgroundIntensity=1,this.overrideMaterial=null,typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("observe",{detail:this}))}copy(t,e){return super.copy(t,e),t.background!==null&&(this.background=t.background.clone()),t.environment!==null&&(this.environment=t.environment.clone()),t.fog!==null&&(this.fog=t.fog.clone()),this.backgroundBlurriness=t.backgroundBlurriness,this.backgroundIntensity=t.backgroundIntensity,t.overrideMaterial!==null&&(this.overrideMaterial=t.overrideMaterial.clone()),this.matrixAutoUpdate=t.matrixAutoUpdate,this}toJSON(t){const e=super.toJSON(t);return this.fog!==null&&(e.object.fog=this.fog.toJSON()),this.backgroundBlurriness>0&&(e.object.backgroundBlurriness=this.backgroundBlurriness),this.backgroundIntensity!==1&&(e.object.backgroundIntensity=this.backgroundIntensity),e}}class ym{constructor(t,e){this.isInterleavedBuffer=!0,this.array=t,this.stride=e,this.count=t!==void 0?t.length/e:0,this.usage=ks,this._updateRange={offset:0,count:-1},this.updateRanges=[],this.version=0,this.uuid=fn()}onUploadCallback(){}set needsUpdate(t){t===!0&&this.version++}get updateRange(){return console.warn("THREE.InterleavedBuffer: updateRange() is deprecated and will be removed in r169. Use addUpdateRange() instead."),this._updateRange}setUsage(t){return this.usage=t,this}addUpdateRange(t,e){this.updateRanges.push({start:t,count:e})}clearUpdateRanges(){this.updateRanges.length=0}copy(t){return this.array=new t.array.constructor(t.array),this.count=t.count,this.stride=t.stride,this.usage=t.usage,this}copyAt(t,e,n){t*=this.stride,n*=e.stride;for(let r=0,s=this.stride;r<s;r++)this.array[t+r]=e.array[n+r];return this}set(t,e=0){return this.array.set(t,e),this}clone(t){t.arrayBuffers===void 0&&(t.arrayBuffers={}),this.array.buffer._uuid===void 0&&(this.array.buffer._uuid=fn()),t.arrayBuffers[this.array.buffer._uuid]===void 0&&(t.arrayBuffers[this.array.buffer._uuid]=this.array.slice(0).buffer);const e=new this.array.constructor(t.arrayBuffers[this.array.buffer._uuid]),n=new this.constructor(e,this.stride);return n.setUsage(this.usage),n}onUpload(t){return this.onUploadCallback=t,this}toJSON(t){return t.arrayBuffers===void 0&&(t.arrayBuffers={}),this.array.buffer._uuid===void 0&&(this.array.buffer._uuid=fn()),t.arrayBuffers[this.array.buffer._uuid]===void 0&&(t.arrayBuffers[this.array.buffer._uuid]=Array.from(new Uint32Array(this.array.buffer))),{uuid:this.uuid,buffer:this.array.buffer._uuid,type:this.array.constructor.name,stride:this.stride}}}const Ce=new W;class Br{constructor(t,e,n,r=!1){this.isInterleavedBufferAttribute=!0,this.name="",this.data=t,this.itemSize=e,this.offset=n,this.normalized=r}get count(){return this.data.count}get array(){return this.data.array}set needsUpdate(t){this.data.needsUpdate=t}applyMatrix4(t){for(let e=0,n=this.data.count;e<n;e++)Ce.fromBufferAttribute(this,e),Ce.applyMatrix4(t),this.setXYZ(e,Ce.x,Ce.y,Ce.z);return this}applyNormalMatrix(t){for(let e=0,n=this.count;e<n;e++)Ce.fromBufferAttribute(this,e),Ce.applyNormalMatrix(t),this.setXYZ(e,Ce.x,Ce.y,Ce.z);return this}transformDirection(t){for(let e=0,n=this.count;e<n;e++)Ce.fromBufferAttribute(this,e),Ce.transformDirection(t),this.setXYZ(e,Ce.x,Ce.y,Ce.z);return this}setX(t,e){return this.normalized&&(e=ee(e,this.array)),this.data.array[t*this.data.stride+this.offset]=e,this}setY(t,e){return this.normalized&&(e=ee(e,this.array)),this.data.array[t*this.data.stride+this.offset+1]=e,this}setZ(t,e){return this.normalized&&(e=ee(e,this.array)),this.data.array[t*this.data.stride+this.offset+2]=e,this}setW(t,e){return this.normalized&&(e=ee(e,this.array)),this.data.array[t*this.data.stride+this.offset+3]=e,this}getX(t){let e=this.data.array[t*this.data.stride+this.offset];return this.normalized&&(e=tn(e,this.array)),e}getY(t){let e=this.data.array[t*this.data.stride+this.offset+1];return this.normalized&&(e=tn(e,this.array)),e}getZ(t){let e=this.data.array[t*this.data.stride+this.offset+2];return this.normalized&&(e=tn(e,this.array)),e}getW(t){let e=this.data.array[t*this.data.stride+this.offset+3];return this.normalized&&(e=tn(e,this.array)),e}setXY(t,e,n){return t=t*this.data.stride+this.offset,this.normalized&&(e=ee(e,this.array),n=ee(n,this.array)),this.data.array[t+0]=e,this.data.array[t+1]=n,this}setXYZ(t,e,n,r){return t=t*this.data.stride+this.offset,this.normalized&&(e=ee(e,this.array),n=ee(n,this.array),r=ee(r,this.array)),this.data.array[t+0]=e,this.data.array[t+1]=n,this.data.array[t+2]=r,this}setXYZW(t,e,n,r,s){return t=t*this.data.stride+this.offset,this.normalized&&(e=ee(e,this.array),n=ee(n,this.array),r=ee(r,this.array),s=ee(s,this.array)),this.data.array[t+0]=e,this.data.array[t+1]=n,this.data.array[t+2]=r,this.data.array[t+3]=s,this}clone(t){if(t===void 0){console.log("THREE.InterleavedBufferAttribute.clone(): Cloning an interleaved buffer attribute will de-interleave buffer data.");const e=[];for(let n=0;n<this.count;n++){const r=n*this.data.stride+this.offset;for(let s=0;s<this.itemSize;s++)e.push(this.data.array[r+s])}return new fe(new this.array.constructor(e),this.itemSize,this.normalized)}else return t.interleavedBuffers===void 0&&(t.interleavedBuffers={}),t.interleavedBuffers[this.data.uuid]===void 0&&(t.interleavedBuffers[this.data.uuid]=this.data.clone(t)),new Br(t.interleavedBuffers[this.data.uuid],this.itemSize,this.offset,this.normalized)}toJSON(t){if(t===void 0){console.log("THREE.InterleavedBufferAttribute.toJSON(): Serializing an interleaved buffer attribute will de-interleave buffer data.");const e=[];for(let n=0;n<this.count;n++){const r=n*this.data.stride+this.offset;for(let s=0;s<this.itemSize;s++)e.push(this.data.array[r+s])}return{itemSize:this.itemSize,type:this.array.constructor.name,array:e,normalized:this.normalized}}else return t.interleavedBuffers===void 0&&(t.interleavedBuffers={}),t.interleavedBuffers[this.data.uuid]===void 0&&(t.interleavedBuffers[this.data.uuid]=this.data.toJSON(t)),{isInterleavedBufferAttribute:!0,itemSize:this.itemSize,data:this.data.uuid,offset:this.offset,normalized:this.normalized}}}class Yi extends Rn{constructor(t){super(),this.isSpriteMaterial=!0,this.type="SpriteMaterial",this.color=new Dt(16777215),this.map=null,this.alphaMap=null,this.rotation=0,this.sizeAttenuation=!0,this.transparent=!0,this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.color.copy(t.color),this.map=t.map,this.alphaMap=t.alphaMap,this.rotation=t.rotation,this.sizeAttenuation=t.sizeAttenuation,this.fog=t.fog,this}}let ci;const Ii=new W,ui=new W,hi=new W,di=new wt,Ui=new wt,ql=new ie,yr=new W,Ni=new W,Sr=new W,Fa=new wt,ws=new wt,Ba=new wt;class zr extends ue{constructor(t=new Yi){if(super(),this.isSprite=!0,this.type="Sprite",ci===void 0){ci=new Jt;const e=new Float32Array([-.5,-.5,0,0,0,.5,-.5,0,1,0,.5,.5,0,1,1,-.5,.5,0,0,1]),n=new ym(e,5);ci.setIndex([0,1,2,0,2,3]),ci.setAttribute("position",new Br(n,3,0,!1)),ci.setAttribute("uv",new Br(n,2,3,!1))}this.geometry=ci,this.material=t,this.center=new wt(.5,.5)}raycast(t,e){t.camera===null&&console.error('THREE.Sprite: "Raycaster.camera" needs to be set in order to raycast against sprites.'),ui.setFromMatrixScale(this.matrixWorld),ql.copy(t.camera.matrixWorld),this.modelViewMatrix.multiplyMatrices(t.camera.matrixWorldInverse,this.matrixWorld),hi.setFromMatrixPosition(this.modelViewMatrix),t.camera.isPerspectiveCamera&&this.material.sizeAttenuation===!1&&ui.multiplyScalar(-hi.z);const n=this.material.rotation;let r,s;n!==0&&(s=Math.cos(n),r=Math.sin(n));const o=this.center;br(yr.set(-.5,-.5,0),hi,o,ui,r,s),br(Ni.set(.5,-.5,0),hi,o,ui,r,s),br(Sr.set(.5,.5,0),hi,o,ui,r,s),Fa.set(0,0),ws.set(1,0),Ba.set(1,1);let a=t.ray.intersectTriangle(yr,Ni,Sr,!1,Ii);if(a===null&&(br(Ni.set(-.5,.5,0),hi,o,ui,r,s),ws.set(0,1),a=t.ray.intersectTriangle(yr,Sr,Ni,!1,Ii),a===null))return;const l=t.ray.origin.distanceTo(Ii);l<t.near||l>t.far||e.push({distance:l,point:Ii.clone(),uv:He.getInterpolation(Ii,yr,Ni,Sr,Fa,ws,Ba,new wt),face:null,object:this})}copy(t,e){return super.copy(t,e),t.center!==void 0&&this.center.copy(t.center),this.material=t.material,this}}function br(i,t,e,n,r,s){di.subVectors(i,e).addScalar(.5).multiply(n),r!==void 0?(Ui.x=s*di.x-r*di.y,Ui.y=r*di.x+s*di.y):Ui.copy(di),i.copy(t),i.x+=Ui.x,i.y+=Ui.y,i.applyMatrix4(ql)}class za extends fe{constructor(t,e,n,r=1){super(t,e,n),this.isInstancedBufferAttribute=!0,this.meshPerAttribute=r}copy(t){return super.copy(t),this.meshPerAttribute=t.meshPerAttribute,this}toJSON(){const t=super.toJSON();return t.meshPerAttribute=this.meshPerAttribute,t.isInstancedBufferAttribute=!0,t}}const fi=new ie,Ga=new ie,Er=[],ka=new Hn,Sm=new ie,Oi=new Ft,Fi=new Vn;class bm extends Ft{constructor(t,e,n){super(t,e),this.isInstancedMesh=!0,this.instanceMatrix=new za(new Float32Array(n*16),16),this.instanceColor=null,this.count=n,this.boundingBox=null,this.boundingSphere=null;for(let r=0;r<n;r++)this.setMatrixAt(r,Sm)}computeBoundingBox(){const t=this.geometry,e=this.count;this.boundingBox===null&&(this.boundingBox=new Hn),t.boundingBox===null&&t.computeBoundingBox(),this.boundingBox.makeEmpty();for(let n=0;n<e;n++)this.getMatrixAt(n,fi),ka.copy(t.boundingBox).applyMatrix4(fi),this.boundingBox.union(ka)}computeBoundingSphere(){const t=this.geometry,e=this.count;this.boundingSphere===null&&(this.boundingSphere=new Vn),t.boundingSphere===null&&t.computeBoundingSphere(),this.boundingSphere.makeEmpty();for(let n=0;n<e;n++)this.getMatrixAt(n,fi),Fi.copy(t.boundingSphere).applyMatrix4(fi),this.boundingSphere.union(Fi)}copy(t,e){return super.copy(t,e),this.instanceMatrix.copy(t.instanceMatrix),t.instanceColor!==null&&(this.instanceColor=t.instanceColor.clone()),this.count=t.count,t.boundingBox!==null&&(this.boundingBox=t.boundingBox.clone()),t.boundingSphere!==null&&(this.boundingSphere=t.boundingSphere.clone()),this}getColorAt(t,e){e.fromArray(this.instanceColor.array,t*3)}getMatrixAt(t,e){e.fromArray(this.instanceMatrix.array,t*16)}raycast(t,e){const n=this.matrixWorld,r=this.count;if(Oi.geometry=this.geometry,Oi.material=this.material,Oi.material!==void 0&&(this.boundingSphere===null&&this.computeBoundingSphere(),Fi.copy(this.boundingSphere),Fi.applyMatrix4(n),t.ray.intersectsSphere(Fi)!==!1))for(let s=0;s<r;s++){this.getMatrixAt(s,fi),Ga.multiplyMatrices(n,fi),Oi.matrixWorld=Ga,Oi.raycast(t,Er);for(let o=0,a=Er.length;o<a;o++){const l=Er[o];l.instanceId=s,l.object=this,e.push(l)}Er.length=0}}setColorAt(t,e){this.instanceColor===null&&(this.instanceColor=new za(new Float32Array(this.instanceMatrix.count*3),3)),e.toArray(this.instanceColor.array,t*3)}setMatrixAt(t,e){e.toArray(this.instanceMatrix.array,t*16)}updateMorphTargets(){}dispose(){this.dispatchEvent({type:"dispose"})}}class Yl extends Rn{constructor(t){super(),this.isLineBasicMaterial=!0,this.type="LineBasicMaterial",this.color=new Dt(16777215),this.map=null,this.linewidth=1,this.linecap="round",this.linejoin="round",this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.color.copy(t.color),this.map=t.map,this.linewidth=t.linewidth,this.linecap=t.linecap,this.linejoin=t.linejoin,this.fog=t.fog,this}}const Ha=new W,Va=new W,Wa=new ie,As=new $i,Tr=new Vn;class Em extends ue{constructor(t=new Jt,e=new Yl){super(),this.isLine=!0,this.type="Line",this.geometry=t,this.material=e,this.updateMorphTargets()}copy(t,e){return super.copy(t,e),this.material=Array.isArray(t.material)?t.material.slice():t.material,this.geometry=t.geometry,this}computeLineDistances(){const t=this.geometry;if(t.index===null){const e=t.attributes.position,n=[0];for(let r=1,s=e.count;r<s;r++)Ha.fromBufferAttribute(e,r-1),Va.fromBufferAttribute(e,r),n[r]=n[r-1],n[r]+=Ha.distanceTo(Va);t.setAttribute("lineDistance",new Nt(n,1))}else console.warn("THREE.Line.computeLineDistances(): Computation only possible with non-indexed BufferGeometry.");return this}raycast(t,e){const n=this.geometry,r=this.matrixWorld,s=t.params.Line.threshold,o=n.drawRange;if(n.boundingSphere===null&&n.computeBoundingSphere(),Tr.copy(n.boundingSphere),Tr.applyMatrix4(r),Tr.radius+=s,t.ray.intersectsSphere(Tr)===!1)return;Wa.copy(r).invert(),As.copy(t.ray).applyMatrix4(Wa);const a=s/((this.scale.x+this.scale.y+this.scale.z)/3),l=a*a,c=new W,u=new W,f=new W,m=new W,p=this.isLineSegments?2:1,v=n.index,d=n.attributes.position;if(v!==null){const h=Math.max(0,o.start),y=Math.min(v.count,o.start+o.count);for(let _=h,w=y-1;_<w;_+=p){const D=v.getX(_),P=v.getX(_+1);if(c.fromBufferAttribute(d,D),u.fromBufferAttribute(d,P),As.distanceSqToSegment(c,u,m,f)>l)continue;m.applyMatrix4(this.matrixWorld);const F=t.ray.origin.distanceTo(m);F<t.near||F>t.far||e.push({distance:F,point:f.clone().applyMatrix4(this.matrixWorld),index:_,face:null,faceIndex:null,object:this})}}else{const h=Math.max(0,o.start),y=Math.min(d.count,o.start+o.count);for(let _=h,w=y-1;_<w;_+=p){if(c.fromBufferAttribute(d,_),u.fromBufferAttribute(d,_+1),As.distanceSqToSegment(c,u,m,f)>l)continue;m.applyMatrix4(this.matrixWorld);const P=t.ray.origin.distanceTo(m);P<t.near||P>t.far||e.push({distance:P,point:f.clone().applyMatrix4(this.matrixWorld),index:_,face:null,faceIndex:null,object:this})}}}updateMorphTargets(){const e=this.geometry.morphAttributes,n=Object.keys(e);if(n.length>0){const r=e[n[0]];if(r!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let s=0,o=r.length;s<o;s++){const a=r[s].name||String(s);this.morphTargetInfluences.push(0),this.morphTargetDictionary[a]=s}}}}}const Xa=new W,qa=new W;class Tm extends Em{constructor(t,e){super(t,e),this.isLineSegments=!0,this.type="LineSegments"}computeLineDistances(){const t=this.geometry;if(t.index===null){const e=t.attributes.position,n=[];for(let r=0,s=e.count;r<s;r+=2)Xa.fromBufferAttribute(e,r),qa.fromBufferAttribute(e,r+1),n[r]=r===0?0:n[r-1],n[r+1]=n[r]+Xa.distanceTo(qa);t.setAttribute("lineDistance",new Nt(n,1))}else console.warn("THREE.LineSegments.computeLineDistances(): Computation only possible with non-indexed BufferGeometry.");return this}}class Wr extends Rn{constructor(t){super(),this.isPointsMaterial=!0,this.type="PointsMaterial",this.color=new Dt(16777215),this.map=null,this.alphaMap=null,this.size=1,this.sizeAttenuation=!0,this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.color.copy(t.color),this.map=t.map,this.alphaMap=t.alphaMap,this.size=t.size,this.sizeAttenuation=t.sizeAttenuation,this.fog=t.fog,this}}const Ya=new ie,qs=new $i,wr=new Vn,Ar=new W;class so extends ue{constructor(t=new Jt,e=new Wr){super(),this.isPoints=!0,this.type="Points",this.geometry=t,this.material=e,this.updateMorphTargets()}copy(t,e){return super.copy(t,e),this.material=Array.isArray(t.material)?t.material.slice():t.material,this.geometry=t.geometry,this}raycast(t,e){const n=this.geometry,r=this.matrixWorld,s=t.params.Points.threshold,o=n.drawRange;if(n.boundingSphere===null&&n.computeBoundingSphere(),wr.copy(n.boundingSphere),wr.applyMatrix4(r),wr.radius+=s,t.ray.intersectsSphere(wr)===!1)return;Ya.copy(r).invert(),qs.copy(t.ray).applyMatrix4(Ya);const a=s/((this.scale.x+this.scale.y+this.scale.z)/3),l=a*a,c=n.index,f=n.attributes.position;if(c!==null){const m=Math.max(0,o.start),p=Math.min(c.count,o.start+o.count);for(let v=m,x=p;v<x;v++){const d=c.getX(v);Ar.fromBufferAttribute(f,d),ja(Ar,d,l,r,t,e,this)}}else{const m=Math.max(0,o.start),p=Math.min(f.count,o.start+o.count);for(let v=m,x=p;v<x;v++)Ar.fromBufferAttribute(f,v),ja(Ar,v,l,r,t,e,this)}}updateMorphTargets(){const e=this.geometry.morphAttributes,n=Object.keys(e);if(n.length>0){const r=e[n[0]];if(r!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let s=0,o=r.length;s<o;s++){const a=r[s].name||String(s);this.morphTargetInfluences.push(0),this.morphTargetDictionary[a]=s}}}}}function ja(i,t,e,n,r,s,o){const a=qs.distanceSqToPoint(i);if(a<e){const l=new W;qs.closestPointToPoint(i,l),l.applyMatrix4(n);const c=r.ray.origin.distanceTo(l);if(c<r.near||c>r.far)return;s.push({distance:c,distanceToRay:Math.sqrt(a),point:l,index:t,face:null,object:o})}}class Ze extends we{constructor(t,e,n,r,s,o,a,l,c){super(t,e,n,r,s,o,a,l,c),this.isCanvasTexture=!0,this.needsUpdate=!0}}class mn{constructor(){this.type="Curve",this.arcLengthDivisions=200}getPoint(){return console.warn("THREE.Curve: .getPoint() not implemented."),null}getPointAt(t,e){const n=this.getUtoTmapping(t);return this.getPoint(n,e)}getPoints(t=5){const e=[];for(let n=0;n<=t;n++)e.push(this.getPoint(n/t));return e}getSpacedPoints(t=5){const e=[];for(let n=0;n<=t;n++)e.push(this.getPointAt(n/t));return e}getLength(){const t=this.getLengths();return t[t.length-1]}getLengths(t=this.arcLengthDivisions){if(this.cacheArcLengths&&this.cacheArcLengths.length===t+1&&!this.needsUpdate)return this.cacheArcLengths;this.needsUpdate=!1;const e=[];let n,r=this.getPoint(0),s=0;e.push(0);for(let o=1;o<=t;o++)n=this.getPoint(o/t),s+=n.distanceTo(r),e.push(s),r=n;return this.cacheArcLengths=e,e}updateArcLengths(){this.needsUpdate=!0,this.getLengths()}getUtoTmapping(t,e){const n=this.getLengths();let r=0;const s=n.length;let o;e?o=e:o=t*n[s-1];let a=0,l=s-1,c;for(;a<=l;)if(r=Math.floor(a+(l-a)/2),c=n[r]-o,c<0)a=r+1;else if(c>0)l=r-1;else{l=r;break}if(r=l,n[r]===o)return r/(s-1);const u=n[r],m=n[r+1]-u,p=(o-u)/m;return(r+p)/(s-1)}getTangent(t,e){let r=t-1e-4,s=t+1e-4;r<0&&(r=0),s>1&&(s=1);const o=this.getPoint(r),a=this.getPoint(s),l=e||(o.isVector2?new wt:new W);return l.copy(a).sub(o).normalize(),l}getTangentAt(t,e){const n=this.getUtoTmapping(t);return this.getTangent(n,e)}computeFrenetFrames(t,e){const n=new W,r=[],s=[],o=[],a=new W,l=new ie;for(let p=0;p<=t;p++){const v=p/t;r[p]=this.getTangentAt(v,new W)}s[0]=new W,o[0]=new W;let c=Number.MAX_VALUE;const u=Math.abs(r[0].x),f=Math.abs(r[0].y),m=Math.abs(r[0].z);u<=c&&(c=u,n.set(1,0,0)),f<=c&&(c=f,n.set(0,1,0)),m<=c&&n.set(0,0,1),a.crossVectors(r[0],n).normalize(),s[0].crossVectors(r[0],a),o[0].crossVectors(r[0],s[0]);for(let p=1;p<=t;p++){if(s[p]=s[p-1].clone(),o[p]=o[p-1].clone(),a.crossVectors(r[p-1],r[p]),a.length()>Number.EPSILON){a.normalize();const v=Math.acos(xe(r[p-1].dot(r[p]),-1,1));s[p].applyMatrix4(l.makeRotationAxis(a,v))}o[p].crossVectors(r[p],s[p])}if(e===!0){let p=Math.acos(xe(s[0].dot(s[t]),-1,1));p/=t,r[0].dot(a.crossVectors(s[0],s[t]))>0&&(p=-p);for(let v=1;v<=t;v++)s[v].applyMatrix4(l.makeRotationAxis(r[v],p*v)),o[v].crossVectors(r[v],s[v])}return{tangents:r,normals:s,binormals:o}}clone(){return new this.constructor().copy(this)}copy(t){return this.arcLengthDivisions=t.arcLengthDivisions,this}toJSON(){const t={metadata:{version:4.6,type:"Curve",generator:"Curve.toJSON"}};return t.arcLengthDivisions=this.arcLengthDivisions,t.type=this.type,t}fromJSON(t){return this.arcLengthDivisions=t.arcLengthDivisions,this}}class jl extends mn{constructor(t=0,e=0,n=1,r=1,s=0,o=Math.PI*2,a=!1,l=0){super(),this.isEllipseCurve=!0,this.type="EllipseCurve",this.aX=t,this.aY=e,this.xRadius=n,this.yRadius=r,this.aStartAngle=s,this.aEndAngle=o,this.aClockwise=a,this.aRotation=l}getPoint(t,e){const n=e||new wt,r=Math.PI*2;let s=this.aEndAngle-this.aStartAngle;const o=Math.abs(s)<Number.EPSILON;for(;s<0;)s+=r;for(;s>r;)s-=r;s<Number.EPSILON&&(o?s=0:s=r),this.aClockwise===!0&&!o&&(s===r?s=-r:s=s-r);const a=this.aStartAngle+t*s;let l=this.aX+this.xRadius*Math.cos(a),c=this.aY+this.yRadius*Math.sin(a);if(this.aRotation!==0){const u=Math.cos(this.aRotation),f=Math.sin(this.aRotation),m=l-this.aX,p=c-this.aY;l=m*u-p*f+this.aX,c=m*f+p*u+this.aY}return n.set(l,c)}copy(t){return super.copy(t),this.aX=t.aX,this.aY=t.aY,this.xRadius=t.xRadius,this.yRadius=t.yRadius,this.aStartAngle=t.aStartAngle,this.aEndAngle=t.aEndAngle,this.aClockwise=t.aClockwise,this.aRotation=t.aRotation,this}toJSON(){const t=super.toJSON();return t.aX=this.aX,t.aY=this.aY,t.xRadius=this.xRadius,t.yRadius=this.yRadius,t.aStartAngle=this.aStartAngle,t.aEndAngle=this.aEndAngle,t.aClockwise=this.aClockwise,t.aRotation=this.aRotation,t}fromJSON(t){return super.fromJSON(t),this.aX=t.aX,this.aY=t.aY,this.xRadius=t.xRadius,this.yRadius=t.yRadius,this.aStartAngle=t.aStartAngle,this.aEndAngle=t.aEndAngle,this.aClockwise=t.aClockwise,this.aRotation=t.aRotation,this}}class wm extends jl{constructor(t,e,n,r,s,o){super(t,e,n,n,r,s,o),this.isArcCurve=!0,this.type="ArcCurve"}}function oo(){let i=0,t=0,e=0,n=0;function r(s,o,a,l){i=s,t=a,e=-3*s+3*o-2*a-l,n=2*s-2*o+a+l}return{initCatmullRom:function(s,o,a,l,c){r(o,a,c*(a-s),c*(l-o))},initNonuniformCatmullRom:function(s,o,a,l,c,u,f){let m=(o-s)/c-(a-s)/(c+u)+(a-o)/u,p=(a-o)/u-(l-o)/(u+f)+(l-a)/f;m*=u,p*=u,r(o,a,m,p)},calc:function(s){const o=s*s,a=o*s;return i+t*s+e*o+n*a}}}const Rr=new W,Rs=new oo,Cs=new oo,Ps=new oo;class en extends mn{constructor(t=[],e=!1,n="centripetal",r=.5){super(),this.isCatmullRomCurve3=!0,this.type="CatmullRomCurve3",this.points=t,this.closed=e,this.curveType=n,this.tension=r}getPoint(t,e=new W){const n=e,r=this.points,s=r.length,o=(s-(this.closed?0:1))*t;let a=Math.floor(o),l=o-a;this.closed?a+=a>0?0:(Math.floor(Math.abs(a)/s)+1)*s:l===0&&a===s-1&&(a=s-2,l=1);let c,u;this.closed||a>0?c=r[(a-1)%s]:(Rr.subVectors(r[0],r[1]).add(r[0]),c=Rr);const f=r[a%s],m=r[(a+1)%s];if(this.closed||a+2<s?u=r[(a+2)%s]:(Rr.subVectors(r[s-1],r[s-2]).add(r[s-1]),u=Rr),this.curveType==="centripetal"||this.curveType==="chordal"){const p=this.curveType==="chordal"?.5:.25;let v=Math.pow(c.distanceToSquared(f),p),x=Math.pow(f.distanceToSquared(m),p),d=Math.pow(m.distanceToSquared(u),p);x<1e-4&&(x=1),v<1e-4&&(v=x),d<1e-4&&(d=x),Rs.initNonuniformCatmullRom(c.x,f.x,m.x,u.x,v,x,d),Cs.initNonuniformCatmullRom(c.y,f.y,m.y,u.y,v,x,d),Ps.initNonuniformCatmullRom(c.z,f.z,m.z,u.z,v,x,d)}else this.curveType==="catmullrom"&&(Rs.initCatmullRom(c.x,f.x,m.x,u.x,this.tension),Cs.initCatmullRom(c.y,f.y,m.y,u.y,this.tension),Ps.initCatmullRom(c.z,f.z,m.z,u.z,this.tension));return n.set(Rs.calc(l),Cs.calc(l),Ps.calc(l)),n}copy(t){super.copy(t),this.points=[];for(let e=0,n=t.points.length;e<n;e++){const r=t.points[e];this.points.push(r.clone())}return this.closed=t.closed,this.curveType=t.curveType,this.tension=t.tension,this}toJSON(){const t=super.toJSON();t.points=[];for(let e=0,n=this.points.length;e<n;e++){const r=this.points[e];t.points.push(r.toArray())}return t.closed=this.closed,t.curveType=this.curveType,t.tension=this.tension,t}fromJSON(t){super.fromJSON(t),this.points=[];for(let e=0,n=t.points.length;e<n;e++){const r=t.points[e];this.points.push(new W().fromArray(r))}return this.closed=t.closed,this.curveType=t.curveType,this.tension=t.tension,this}}function $a(i,t,e,n,r){const s=(n-t)*.5,o=(r-e)*.5,a=i*i,l=i*a;return(2*e-2*n+s+o)*l+(-3*e+3*n-2*s-o)*a+s*i+e}function Am(i,t){const e=1-i;return e*e*t}function Rm(i,t){return 2*(1-i)*i*t}function Cm(i,t){return i*i*t}function Hi(i,t,e,n){return Am(i,t)+Rm(i,e)+Cm(i,n)}function Pm(i,t){const e=1-i;return e*e*e*t}function Lm(i,t){const e=1-i;return 3*e*e*i*t}function Dm(i,t){return 3*(1-i)*i*i*t}function Im(i,t){return i*i*i*t}function Vi(i,t,e,n,r){return Pm(i,t)+Lm(i,e)+Dm(i,n)+Im(i,r)}class Um extends mn{constructor(t=new wt,e=new wt,n=new wt,r=new wt){super(),this.isCubicBezierCurve=!0,this.type="CubicBezierCurve",this.v0=t,this.v1=e,this.v2=n,this.v3=r}getPoint(t,e=new wt){const n=e,r=this.v0,s=this.v1,o=this.v2,a=this.v3;return n.set(Vi(t,r.x,s.x,o.x,a.x),Vi(t,r.y,s.y,o.y,a.y)),n}copy(t){return super.copy(t),this.v0.copy(t.v0),this.v1.copy(t.v1),this.v2.copy(t.v2),this.v3.copy(t.v3),this}toJSON(){const t=super.toJSON();return t.v0=this.v0.toArray(),t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t.v3=this.v3.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v0.fromArray(t.v0),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this.v3.fromArray(t.v3),this}}class Nm extends mn{constructor(t=new W,e=new W,n=new W,r=new W){super(),this.isCubicBezierCurve3=!0,this.type="CubicBezierCurve3",this.v0=t,this.v1=e,this.v2=n,this.v3=r}getPoint(t,e=new W){const n=e,r=this.v0,s=this.v1,o=this.v2,a=this.v3;return n.set(Vi(t,r.x,s.x,o.x,a.x),Vi(t,r.y,s.y,o.y,a.y),Vi(t,r.z,s.z,o.z,a.z)),n}copy(t){return super.copy(t),this.v0.copy(t.v0),this.v1.copy(t.v1),this.v2.copy(t.v2),this.v3.copy(t.v3),this}toJSON(){const t=super.toJSON();return t.v0=this.v0.toArray(),t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t.v3=this.v3.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v0.fromArray(t.v0),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this.v3.fromArray(t.v3),this}}class Om extends mn{constructor(t=new wt,e=new wt){super(),this.isLineCurve=!0,this.type="LineCurve",this.v1=t,this.v2=e}getPoint(t,e=new wt){const n=e;return t===1?n.copy(this.v2):(n.copy(this.v2).sub(this.v1),n.multiplyScalar(t).add(this.v1)),n}getPointAt(t,e){return this.getPoint(t,e)}getTangent(t,e=new wt){return e.subVectors(this.v2,this.v1).normalize()}getTangentAt(t,e){return this.getTangent(t,e)}copy(t){return super.copy(t),this.v1.copy(t.v1),this.v2.copy(t.v2),this}toJSON(){const t=super.toJSON();return t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this}}class Fm extends mn{constructor(t=new W,e=new W){super(),this.isLineCurve3=!0,this.type="LineCurve3",this.v1=t,this.v2=e}getPoint(t,e=new W){const n=e;return t===1?n.copy(this.v2):(n.copy(this.v2).sub(this.v1),n.multiplyScalar(t).add(this.v1)),n}getPointAt(t,e){return this.getPoint(t,e)}getTangent(t,e=new W){return e.subVectors(this.v2,this.v1).normalize()}getTangentAt(t,e){return this.getTangent(t,e)}copy(t){return super.copy(t),this.v1.copy(t.v1),this.v2.copy(t.v2),this}toJSON(){const t=super.toJSON();return t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this}}class $l extends mn{constructor(t=new wt,e=new wt,n=new wt){super(),this.isQuadraticBezierCurve=!0,this.type="QuadraticBezierCurve",this.v0=t,this.v1=e,this.v2=n}getPoint(t,e=new wt){const n=e,r=this.v0,s=this.v1,o=this.v2;return n.set(Hi(t,r.x,s.x,o.x),Hi(t,r.y,s.y,o.y)),n}copy(t){return super.copy(t),this.v0.copy(t.v0),this.v1.copy(t.v1),this.v2.copy(t.v2),this}toJSON(){const t=super.toJSON();return t.v0=this.v0.toArray(),t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v0.fromArray(t.v0),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this}}class Kl extends mn{constructor(t=new W,e=new W,n=new W){super(),this.isQuadraticBezierCurve3=!0,this.type="QuadraticBezierCurve3",this.v0=t,this.v1=e,this.v2=n}getPoint(t,e=new W){const n=e,r=this.v0,s=this.v1,o=this.v2;return n.set(Hi(t,r.x,s.x,o.x),Hi(t,r.y,s.y,o.y),Hi(t,r.z,s.z,o.z)),n}copy(t){return super.copy(t),this.v0.copy(t.v0),this.v1.copy(t.v1),this.v2.copy(t.v2),this}toJSON(){const t=super.toJSON();return t.v0=this.v0.toArray(),t.v1=this.v1.toArray(),t.v2=this.v2.toArray(),t}fromJSON(t){return super.fromJSON(t),this.v0.fromArray(t.v0),this.v1.fromArray(t.v1),this.v2.fromArray(t.v2),this}}class Bm extends mn{constructor(t=[]){super(),this.isSplineCurve=!0,this.type="SplineCurve",this.points=t}getPoint(t,e=new wt){const n=e,r=this.points,s=(r.length-1)*t,o=Math.floor(s),a=s-o,l=r[o===0?o:o-1],c=r[o],u=r[o>r.length-2?r.length-1:o+1],f=r[o>r.length-3?r.length-1:o+2];return n.set($a(a,l.x,c.x,u.x,f.x),$a(a,l.y,c.y,u.y,f.y)),n}copy(t){super.copy(t),this.points=[];for(let e=0,n=t.points.length;e<n;e++){const r=t.points[e];this.points.push(r.clone())}return this}toJSON(){const t=super.toJSON();t.points=[];for(let e=0,n=this.points.length;e<n;e++){const r=this.points[e];t.points.push(r.toArray())}return t}fromJSON(t){super.fromJSON(t),this.points=[];for(let e=0,n=t.points.length;e<n;e++){const r=t.points[e];this.points.push(new wt().fromArray(r))}return this}}var zm=Object.freeze({__proto__:null,ArcCurve:wm,CatmullRomCurve3:en,CubicBezierCurve:Um,CubicBezierCurve3:Nm,EllipseCurve:jl,LineCurve:Om,LineCurve3:Fm,QuadraticBezierCurve:$l,QuadraticBezierCurve3:Kl,SplineCurve:Bm});class Xr extends Jt{constructor(t=1,e=32,n=0,r=Math.PI*2){super(),this.type="CircleGeometry",this.parameters={radius:t,segments:e,thetaStart:n,thetaLength:r},e=Math.max(3,e);const s=[],o=[],a=[],l=[],c=new W,u=new wt;o.push(0,0,0),a.push(0,0,1),l.push(.5,.5);for(let f=0,m=3;f<=e;f++,m+=3){const p=n+f/e*r;c.x=t*Math.cos(p),c.y=t*Math.sin(p),o.push(c.x,c.y,c.z),a.push(0,0,1),u.x=(o[m]/t+1)/2,u.y=(o[m+1]/t+1)/2,l.push(u.x,u.y)}for(let f=1;f<=e;f++)s.push(f,f+1,0);this.setIndex(s),this.setAttribute("position",new Nt(o,3)),this.setAttribute("normal",new Nt(a,3)),this.setAttribute("uv",new Nt(l,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new Xr(t.radius,t.segments,t.thetaStart,t.thetaLength)}}class qt extends Jt{constructor(t=1,e=1,n=1,r=32,s=1,o=!1,a=0,l=Math.PI*2){super(),this.type="CylinderGeometry",this.parameters={radiusTop:t,radiusBottom:e,height:n,radialSegments:r,heightSegments:s,openEnded:o,thetaStart:a,thetaLength:l};const c=this;r=Math.floor(r),s=Math.floor(s);const u=[],f=[],m=[],p=[];let v=0;const x=[],d=n/2;let h=0;y(),o===!1&&(t>0&&_(!0),e>0&&_(!1)),this.setIndex(u),this.setAttribute("position",new Nt(f,3)),this.setAttribute("normal",new Nt(m,3)),this.setAttribute("uv",new Nt(p,2));function y(){const w=new W,D=new W;let P=0;const I=(e-t)/n;for(let F=0;F<=s;F++){const M=[],A=F/s,K=A*(e-t)+t;for(let O=0;O<=r;O++){const z=O/r,S=z*l+a,E=Math.sin(S),g=Math.cos(S);D.x=K*E,D.y=-A*n+d,D.z=K*g,f.push(D.x,D.y,D.z),w.set(E,I,g).normalize(),m.push(w.x,w.y,w.z),p.push(z,1-A),M.push(v++)}x.push(M)}for(let F=0;F<r;F++)for(let M=0;M<s;M++){const A=x[M][F],K=x[M+1][F],O=x[M+1][F+1],z=x[M][F+1];u.push(A,K,z),u.push(K,O,z),P+=6}c.addGroup(h,P,0),h+=P}function _(w){const D=v,P=new wt,I=new W;let F=0;const M=w===!0?t:e,A=w===!0?1:-1;for(let O=1;O<=r;O++)f.push(0,d*A,0),m.push(0,A,0),p.push(.5,.5),v++;const K=v;for(let O=0;O<=r;O++){const S=O/r*l+a,E=Math.cos(S),g=Math.sin(S);I.x=M*g,I.y=d*A,I.z=M*E,f.push(I.x,I.y,I.z),m.push(0,A,0),P.x=E*.5+.5,P.y=g*.5*A+.5,p.push(P.x,P.y),v++}for(let O=0;O<r;O++){const z=D+O,S=K+O;w===!0?u.push(S,S+1,z):u.push(S+1,S,z),F+=3}c.addGroup(h,F,w===!0?1:2),h+=F}}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new qt(t.radiusTop,t.radiusBottom,t.height,t.radialSegments,t.heightSegments,t.openEnded,t.thetaStart,t.thetaLength)}}class Fe extends qt{constructor(t=1,e=1,n=32,r=1,s=!1,o=0,a=Math.PI*2){super(0,t,e,n,r,s,o,a),this.type="ConeGeometry",this.parameters={radius:t,height:e,radialSegments:n,heightSegments:r,openEnded:s,thetaStart:o,thetaLength:a}}static fromJSON(t){return new Fe(t.radius,t.height,t.radialSegments,t.heightSegments,t.openEnded,t.thetaStart,t.thetaLength)}}class qr extends Jt{constructor(t=[],e=[],n=1,r=0){super(),this.type="PolyhedronGeometry",this.parameters={vertices:t,indices:e,radius:n,detail:r};const s=[],o=[];a(r),c(n),u(),this.setAttribute("position",new Nt(s,3)),this.setAttribute("normal",new Nt(s.slice(),3)),this.setAttribute("uv",new Nt(o,2)),r===0?this.computeVertexNormals():this.normalizeNormals();function a(y){const _=new W,w=new W,D=new W;for(let P=0;P<e.length;P+=3)p(e[P+0],_),p(e[P+1],w),p(e[P+2],D),l(_,w,D,y)}function l(y,_,w,D){const P=D+1,I=[];for(let F=0;F<=P;F++){I[F]=[];const M=y.clone().lerp(w,F/P),A=_.clone().lerp(w,F/P),K=P-F;for(let O=0;O<=K;O++)O===0&&F===P?I[F][O]=M:I[F][O]=M.clone().lerp(A,O/K)}for(let F=0;F<P;F++)for(let M=0;M<2*(P-F)-1;M++){const A=Math.floor(M/2);M%2===0?(m(I[F][A+1]),m(I[F+1][A]),m(I[F][A])):(m(I[F][A+1]),m(I[F+1][A+1]),m(I[F+1][A]))}}function c(y){const _=new W;for(let w=0;w<s.length;w+=3)_.x=s[w+0],_.y=s[w+1],_.z=s[w+2],_.normalize().multiplyScalar(y),s[w+0]=_.x,s[w+1]=_.y,s[w+2]=_.z}function u(){const y=new W;for(let _=0;_<s.length;_+=3){y.x=s[_+0],y.y=s[_+1],y.z=s[_+2];const w=d(y)/2/Math.PI+.5,D=h(y)/Math.PI+.5;o.push(w,1-D)}v(),f()}function f(){for(let y=0;y<o.length;y+=6){const _=o[y+0],w=o[y+2],D=o[y+4],P=Math.max(_,w,D),I=Math.min(_,w,D);P>.9&&I<.1&&(_<.2&&(o[y+0]+=1),w<.2&&(o[y+2]+=1),D<.2&&(o[y+4]+=1))}}function m(y){s.push(y.x,y.y,y.z)}function p(y,_){const w=y*3;_.x=t[w+0],_.y=t[w+1],_.z=t[w+2]}function v(){const y=new W,_=new W,w=new W,D=new W,P=new wt,I=new wt,F=new wt;for(let M=0,A=0;M<s.length;M+=9,A+=6){y.set(s[M+0],s[M+1],s[M+2]),_.set(s[M+3],s[M+4],s[M+5]),w.set(s[M+6],s[M+7],s[M+8]),P.set(o[A+0],o[A+1]),I.set(o[A+2],o[A+3]),F.set(o[A+4],o[A+5]),D.copy(y).add(_).add(w).divideScalar(3);const K=d(D);x(P,A+0,y,K),x(I,A+2,_,K),x(F,A+4,w,K)}}function x(y,_,w,D){D<0&&y.x===1&&(o[_]=y.x-1),w.x===0&&w.z===0&&(o[_]=D/2/Math.PI+.5)}function d(y){return Math.atan2(y.z,-y.x)}function h(y){return Math.atan2(-y.y,Math.sqrt(y.x*y.x+y.z*y.z))}}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new qr(t.vertices,t.indices,t.radius,t.details)}}class ao extends qr{constructor(t=1,e=0){const n=(1+Math.sqrt(5))/2,r=1/n,s=[-1,-1,-1,-1,-1,1,-1,1,-1,-1,1,1,1,-1,-1,1,-1,1,1,1,-1,1,1,1,0,-r,-n,0,-r,n,0,r,-n,0,r,n,-r,-n,0,-r,n,0,r,-n,0,r,n,0,-n,0,-r,n,0,-r,-n,0,r,n,0,r],o=[3,11,7,3,7,15,3,15,13,7,19,17,7,17,6,7,6,15,17,4,8,17,8,10,17,10,6,8,0,16,8,16,2,8,2,10,0,12,1,0,1,18,0,18,16,6,10,2,6,2,13,6,13,15,2,16,18,2,18,3,2,3,13,18,1,9,18,9,11,18,11,3,4,14,12,4,12,0,4,0,8,11,9,5,11,5,19,11,19,7,19,5,14,19,14,4,19,4,17,1,12,14,1,14,5,1,5,9];super(s,o,t,e),this.type="DodecahedronGeometry",this.parameters={radius:t,detail:e}}static fromJSON(t){return new ao(t.radius,t.detail)}}class lo extends qr{constructor(t=1,e=0){const n=(1+Math.sqrt(5))/2,r=[-1,n,0,1,n,0,-1,-n,0,1,-n,0,0,-1,n,0,1,n,0,-1,-n,0,1,-n,n,0,-1,n,0,1,-n,0,-1,-n,0,1],s=[0,11,5,0,5,1,0,1,7,0,7,10,0,10,11,1,5,9,5,11,4,11,10,2,10,7,6,7,1,8,3,9,4,3,4,2,3,2,6,3,6,8,3,8,9,4,9,5,2,4,11,6,2,10,8,6,7,9,8,1];super(r,s,t,e),this.type="IcosahedronGeometry",this.parameters={radius:t,detail:e}}static fromJSON(t){return new lo(t.radius,t.detail)}}class ji extends Jt{constructor(t=.5,e=1,n=32,r=1,s=0,o=Math.PI*2){super(),this.type="RingGeometry",this.parameters={innerRadius:t,outerRadius:e,thetaSegments:n,phiSegments:r,thetaStart:s,thetaLength:o},n=Math.max(3,n),r=Math.max(1,r);const a=[],l=[],c=[],u=[];let f=t;const m=(e-t)/r,p=new W,v=new wt;for(let x=0;x<=r;x++){for(let d=0;d<=n;d++){const h=s+d/n*o;p.x=f*Math.cos(h),p.y=f*Math.sin(h),l.push(p.x,p.y,p.z),c.push(0,0,1),v.x=(p.x/e+1)/2,v.y=(p.y/e+1)/2,u.push(v.x,v.y)}f+=m}for(let x=0;x<r;x++){const d=x*(n+1);for(let h=0;h<n;h++){const y=h+d,_=y,w=y+n+1,D=y+n+2,P=y+1;a.push(_,w,P),a.push(w,D,P)}}this.setIndex(a),this.setAttribute("position",new Nt(l,3)),this.setAttribute("normal",new Nt(c,3)),this.setAttribute("uv",new Nt(u,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new ji(t.innerRadius,t.outerRadius,t.thetaSegments,t.phiSegments,t.thetaStart,t.thetaLength)}}class ne extends Jt{constructor(t=1,e=32,n=16,r=0,s=Math.PI*2,o=0,a=Math.PI){super(),this.type="SphereGeometry",this.parameters={radius:t,widthSegments:e,heightSegments:n,phiStart:r,phiLength:s,thetaStart:o,thetaLength:a},e=Math.max(3,Math.floor(e)),n=Math.max(2,Math.floor(n));const l=Math.min(o+a,Math.PI);let c=0;const u=[],f=new W,m=new W,p=[],v=[],x=[],d=[];for(let h=0;h<=n;h++){const y=[],_=h/n;let w=0;h===0&&o===0?w=.5/e:h===n&&l===Math.PI&&(w=-.5/e);for(let D=0;D<=e;D++){const P=D/e;f.x=-t*Math.cos(r+P*s)*Math.sin(o+_*a),f.y=t*Math.cos(o+_*a),f.z=t*Math.sin(r+P*s)*Math.sin(o+_*a),v.push(f.x,f.y,f.z),m.copy(f).normalize(),x.push(m.x,m.y,m.z),d.push(P+w,1-_),y.push(c++)}u.push(y)}for(let h=0;h<n;h++)for(let y=0;y<e;y++){const _=u[h][y+1],w=u[h][y],D=u[h+1][y],P=u[h+1][y+1];(h!==0||o>0)&&p.push(_,w,P),(h!==n-1||l<Math.PI)&&p.push(w,D,P)}this.setIndex(p),this.setAttribute("position",new Nt(v,3)),this.setAttribute("normal",new Nt(x,3)),this.setAttribute("uv",new Nt(d,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new ne(t.radius,t.widthSegments,t.heightSegments,t.phiStart,t.phiLength,t.thetaStart,t.thetaLength)}}class Ei extends Jt{constructor(t=1,e=.4,n=12,r=48,s=Math.PI*2){super(),this.type="TorusGeometry",this.parameters={radius:t,tube:e,radialSegments:n,tubularSegments:r,arc:s},n=Math.floor(n),r=Math.floor(r);const o=[],a=[],l=[],c=[],u=new W,f=new W,m=new W;for(let p=0;p<=n;p++)for(let v=0;v<=r;v++){const x=v/r*s,d=p/n*Math.PI*2;f.x=(t+e*Math.cos(d))*Math.cos(x),f.y=(t+e*Math.cos(d))*Math.sin(x),f.z=e*Math.sin(d),a.push(f.x,f.y,f.z),u.x=t*Math.cos(x),u.y=t*Math.sin(x),m.subVectors(f,u).normalize(),l.push(m.x,m.y,m.z),c.push(v/r),c.push(p/n)}for(let p=1;p<=n;p++)for(let v=1;v<=r;v++){const x=(r+1)*p+v-1,d=(r+1)*(p-1)+v-1,h=(r+1)*(p-1)+v,y=(r+1)*p+v;o.push(x,d,y),o.push(d,h,y)}this.setIndex(o),this.setAttribute("position",new Nt(a,3)),this.setAttribute("normal",new Nt(l,3)),this.setAttribute("uv",new Nt(c,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new Ei(t.radius,t.tube,t.radialSegments,t.tubularSegments,t.arc)}}class gi extends Jt{constructor(t=new Kl(new W(-1,-1,0),new W(-1,1,0),new W(1,1,0)),e=64,n=1,r=8,s=!1){super(),this.type="TubeGeometry",this.parameters={path:t,tubularSegments:e,radius:n,radialSegments:r,closed:s};const o=t.computeFrenetFrames(e,s);this.tangents=o.tangents,this.normals=o.normals,this.binormals=o.binormals;const a=new W,l=new W,c=new wt;let u=new W;const f=[],m=[],p=[],v=[];x(),this.setIndex(v),this.setAttribute("position",new Nt(f,3)),this.setAttribute("normal",new Nt(m,3)),this.setAttribute("uv",new Nt(p,2));function x(){for(let _=0;_<e;_++)d(_);d(s===!1?e:0),y(),h()}function d(_){u=t.getPointAt(_/e,u);const w=o.normals[_],D=o.binormals[_];for(let P=0;P<=r;P++){const I=P/r*Math.PI*2,F=Math.sin(I),M=-Math.cos(I);l.x=M*w.x+F*D.x,l.y=M*w.y+F*D.y,l.z=M*w.z+F*D.z,l.normalize(),m.push(l.x,l.y,l.z),a.x=u.x+n*l.x,a.y=u.y+n*l.y,a.z=u.z+n*l.z,f.push(a.x,a.y,a.z)}}function h(){for(let _=1;_<=e;_++)for(let w=1;w<=r;w++){const D=(r+1)*(_-1)+(w-1),P=(r+1)*_+(w-1),I=(r+1)*_+w,F=(r+1)*(_-1)+w;v.push(D,P,F),v.push(P,I,F)}}function y(){for(let _=0;_<=e;_++)for(let w=0;w<=r;w++)c.x=_/e,c.y=w/r,p.push(c.x,c.y)}}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}toJSON(){const t=super.toJSON();return t.path=this.parameters.path.toJSON(),t}static fromJSON(t){return new gi(new zm[t.path.type]().fromJSON(t.path),t.tubularSegments,t.radius,t.radialSegments,t.closed)}}class Gm extends Ee{constructor(t){super(t),this.isRawShaderMaterial=!0,this.type="RawShaderMaterial"}}class Be extends Rn{constructor(t){super(),this.isMeshStandardMaterial=!0,this.defines={STANDARD:""},this.type="MeshStandardMaterial",this.color=new Dt(16777215),this.roughness=1,this.metalness=0,this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.emissive=new Dt(0),this.emissiveIntensity=1,this.emissiveMap=null,this.bumpMap=null,this.bumpScale=1,this.normalMap=null,this.normalMapType=El,this.normalScale=new wt(1,1),this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.roughnessMap=null,this.metalnessMap=null,this.alphaMap=null,this.envMap=null,this.envMapIntensity=1,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.flatShading=!1,this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.defines={STANDARD:""},this.color.copy(t.color),this.roughness=t.roughness,this.metalness=t.metalness,this.map=t.map,this.lightMap=t.lightMap,this.lightMapIntensity=t.lightMapIntensity,this.aoMap=t.aoMap,this.aoMapIntensity=t.aoMapIntensity,this.emissive.copy(t.emissive),this.emissiveMap=t.emissiveMap,this.emissiveIntensity=t.emissiveIntensity,this.bumpMap=t.bumpMap,this.bumpScale=t.bumpScale,this.normalMap=t.normalMap,this.normalMapType=t.normalMapType,this.normalScale.copy(t.normalScale),this.displacementMap=t.displacementMap,this.displacementScale=t.displacementScale,this.displacementBias=t.displacementBias,this.roughnessMap=t.roughnessMap,this.metalnessMap=t.metalnessMap,this.alphaMap=t.alphaMap,this.envMap=t.envMap,this.envMapIntensity=t.envMapIntensity,this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this.wireframeLinecap=t.wireframeLinecap,this.wireframeLinejoin=t.wireframeLinejoin,this.flatShading=t.flatShading,this.fog=t.fog,this}}class co extends ue{constructor(t,e=1){super(),this.isLight=!0,this.type="Light",this.color=new Dt(t),this.intensity=e}dispose(){}copy(t,e){return super.copy(t,e),this.color.copy(t.color),this.intensity=t.intensity,this}toJSON(t){const e=super.toJSON(t);return e.object.color=this.color.getHex(),e.object.intensity=this.intensity,this.groundColor!==void 0&&(e.object.groundColor=this.groundColor.getHex()),this.distance!==void 0&&(e.object.distance=this.distance),this.angle!==void 0&&(e.object.angle=this.angle),this.decay!==void 0&&(e.object.decay=this.decay),this.penumbra!==void 0&&(e.object.penumbra=this.penumbra),this.shadow!==void 0&&(e.object.shadow=this.shadow.toJSON()),e}}class km extends co{constructor(t,e,n){super(t,n),this.isHemisphereLight=!0,this.type="HemisphereLight",this.position.copy(ue.DEFAULT_UP),this.updateMatrix(),this.groundColor=new Dt(e)}copy(t,e){return super.copy(t,e),this.groundColor.copy(t.groundColor),this}}const Ls=new ie,Ka=new W,Za=new W;class Zl{constructor(t){this.camera=t,this.bias=0,this.normalBias=0,this.radius=1,this.blurSamples=8,this.mapSize=new wt(512,512),this.map=null,this.mapPass=null,this.matrix=new ie,this.autoUpdate=!0,this.needsUpdate=!1,this._frustum=new eo,this._frameExtents=new wt(1,1),this._viewportCount=1,this._viewports=[new oe(0,0,1,1)]}getViewportCount(){return this._viewportCount}getFrustum(){return this._frustum}updateMatrices(t){const e=this.camera,n=this.matrix;Ka.setFromMatrixPosition(t.matrixWorld),e.position.copy(Ka),Za.setFromMatrixPosition(t.target.matrixWorld),e.lookAt(Za),e.updateMatrixWorld(),Ls.multiplyMatrices(e.projectionMatrix,e.matrixWorldInverse),this._frustum.setFromProjectionMatrix(Ls),n.set(.5,0,0,.5,0,.5,0,.5,0,0,.5,.5,0,0,0,1),n.multiply(Ls)}getViewport(t){return this._viewports[t]}getFrameExtents(){return this._frameExtents}dispose(){this.map&&this.map.dispose(),this.mapPass&&this.mapPass.dispose()}copy(t){return this.camera=t.camera.clone(),this.bias=t.bias,this.radius=t.radius,this.mapSize.copy(t.mapSize),this}clone(){return new this.constructor().copy(this)}toJSON(){const t={};return this.bias!==0&&(t.bias=this.bias),this.normalBias!==0&&(t.normalBias=this.normalBias),this.radius!==1&&(t.radius=this.radius),(this.mapSize.x!==512||this.mapSize.y!==512)&&(t.mapSize=this.mapSize.toArray()),t.camera=this.camera.toJSON(!1).object,delete t.camera.matrix,t}}const Ja=new ie,Bi=new W,Ds=new W;class Hm extends Zl{constructor(){super(new Oe(90,1,.5,500)),this.isPointLightShadow=!0,this._frameExtents=new wt(4,2),this._viewportCount=6,this._viewports=[new oe(2,1,1,1),new oe(0,1,1,1),new oe(3,1,1,1),new oe(1,1,1,1),new oe(3,0,1,1),new oe(1,0,1,1)],this._cubeDirections=[new W(1,0,0),new W(-1,0,0),new W(0,0,1),new W(0,0,-1),new W(0,1,0),new W(0,-1,0)],this._cubeUps=[new W(0,1,0),new W(0,1,0),new W(0,1,0),new W(0,1,0),new W(0,0,1),new W(0,0,-1)]}updateMatrices(t,e=0){const n=this.camera,r=this.matrix,s=t.distance||n.far;s!==n.far&&(n.far=s,n.updateProjectionMatrix()),Bi.setFromMatrixPosition(t.matrixWorld),n.position.copy(Bi),Ds.copy(n.position),Ds.add(this._cubeDirections[e]),n.up.copy(this._cubeUps[e]),n.lookAt(Ds),n.updateMatrixWorld(),r.makeTranslation(-Bi.x,-Bi.y,-Bi.z),Ja.multiplyMatrices(n.projectionMatrix,n.matrixWorldInverse),this._frustum.setFromProjectionMatrix(Ja)}}class Vm extends co{constructor(t,e,n=0,r=2){super(t,e),this.isPointLight=!0,this.type="PointLight",this.distance=n,this.decay=r,this.shadow=new Hm}get power(){return this.intensity*4*Math.PI}set power(t){this.intensity=t/(4*Math.PI)}dispose(){this.shadow.dispose()}copy(t,e){return super.copy(t,e),this.distance=t.distance,this.decay=t.decay,this.shadow=t.shadow.clone(),this}}class Wm extends Zl{constructor(){super(new no(-5,5,5,-5,.5,500)),this.isDirectionalLightShadow=!0}}class Xm extends co{constructor(t,e){super(t,e),this.isDirectionalLight=!0,this.type="DirectionalLight",this.position.copy(ue.DEFAULT_UP),this.updateMatrix(),this.target=new ue,this.shadow=new Wm}dispose(){this.shadow.dispose()}copy(t){return super.copy(t),this.target=t.target.clone(),this.shadow=t.shadow.clone(),this}}class Jl{constructor(t=!0){this.autoStart=t,this.startTime=0,this.oldTime=0,this.elapsedTime=0,this.running=!1}start(){this.startTime=Qa(),this.oldTime=this.startTime,this.elapsedTime=0,this.running=!0}stop(){this.getElapsedTime(),this.running=!1,this.autoStart=!1}getElapsedTime(){return this.getDelta(),this.elapsedTime}getDelta(){let t=0;if(this.autoStart&&!this.running)return this.start(),0;if(this.running){const e=Qa();t=(e-this.oldTime)/1e3,this.oldTime=e,this.elapsedTime+=t}return t}}function Qa(){return(typeof performance>"u"?Date:performance).now()}class Gr{constructor(t,e,n=0,r=1/0){this.ray=new $i(t,e),this.near=n,this.far=r,this.camera=null,this.layers=new to,this.params={Mesh:{},Line:{threshold:1},LOD:{},Points:{threshold:1},Sprite:{}}}set(t,e){this.ray.set(t,e)}setFromCamera(t,e){e.isPerspectiveCamera?(this.ray.origin.setFromMatrixPosition(e.matrixWorld),this.ray.direction.set(t.x,t.y,.5).unproject(e).sub(this.ray.origin).normalize(),this.camera=e):e.isOrthographicCamera?(this.ray.origin.set(t.x,t.y,(e.near+e.far)/(e.near-e.far)).unproject(e),this.ray.direction.set(0,0,-1).transformDirection(e.matrixWorld),this.camera=e):console.error("THREE.Raycaster: Unsupported camera type: "+e.type)}intersectObject(t,e=!0,n=[]){return Ys(t,this,n,e),n.sort(tl),n}intersectObjects(t,e=!0,n=[]){for(let r=0,s=t.length;r<s;r++)Ys(t[r],this,n,e);return n.sort(tl),n}}function tl(i,t){return i.distance-t.distance}function Ys(i,t,e,n){if(i.layers.test(t.layers)&&i.raycast(t,e),n===!0){const r=i.children;for(let s=0,o=r.length;s<o;s++)Ys(r[s],t,e,!0)}}class el{constructor(t=1,e=0,n=0){return this.radius=t,this.phi=e,this.theta=n,this}set(t,e,n){return this.radius=t,this.phi=e,this.theta=n,this}copy(t){return this.radius=t.radius,this.phi=t.phi,this.theta=t.theta,this}makeSafe(){return this.phi=Math.max(1e-6,Math.min(Math.PI-1e-6,this.phi)),this}setFromVector3(t){return this.setFromCartesianCoords(t.x,t.y,t.z)}setFromCartesianCoords(t,e,n){return this.radius=Math.sqrt(t*t+e*e+n*n),this.radius===0?(this.theta=0,this.phi=0):(this.theta=Math.atan2(t,n),this.phi=Math.acos(xe(e/this.radius,-1,1))),this}clone(){return new this.constructor().copy(this)}}typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("register",{detail:{revision:$s}}));typeof window<"u"&&(window.__THREE__?console.warn("WARNING: Multiple instances of Three.js being imported."):window.__THREE__=$s);function qm(i){const t={sinhLuc:{label:"Sinh lực",v:74,decay:.07,src:"Giấc ngủ, vận động",tower:"center"},nganKho:{label:"Ngân khố",v:58,decay:.03,src:"Ngân sách tháng còn lại",tower:"nghisu"},triThuc:{label:"Tri thức",v:41,decay:.05,src:"Kế hoạch đọc năm",tower:"tangkinh"},kyNang:{label:"Kỹ năng",v:66,decay:.05,src:"Tiếng Anh ở Trà Đình",tower:"tradinh"},heThong:{label:"Hệ thống",v:96,decay:0,src:"Pi 5, amber-brain, webhook",tower:"kieulau"}};i.STATS=t;const e=25;i.CRIT=e;const n=i.opts.lite;i.LITE=n;const r={kieulau:{name:"Kiều Lâu",role:"Nhà trên cầu nối Âm–Dương · trung tâm thông báo · tin RSS tạm",pos:[0,0,0],acts:[["Kiểm tra hệ thống",{heThong:40},"Đã kiểm tra: mọi dịch vụ ổn"],["Đánh dấu đã đọc",null,null,"readAll"]]},tangkinh:{name:"Tàng Kinh Các",role:"Sách, kế hoạch đọc năm, tài liệu cá nhân",pos:[-2.2,0,-6.6],acts:[["Đọc 20 trang",{triThuc:9},"Đã ghi 20 trang vào nhật ký đọc"],["Lưu ghi chú",{triThuc:3},"Đã lưu ghi chú mới"]]},tradinh:{name:"Trà Đình",role:"Gia sư tiếng Anh · theo dõi kỹ năng",pos:[5.2,0,4.6],acts:[["Học 1 bài",{kyNang:10},"Hoàn thành 1 bài học"],["Luyện nói 5 phút",{kyNang:5},"Đã luyện nói 5 phút"]]},nghisu:{name:"Nghị Sự Đường",role:"Thu chi · việc cần quyết (tạm gán)",pos:[-6.4,0,-2.6],acts:[["Ghi thu nhập",{nganKho:15},"Đã ghi một khoản thu"],["Ghi chi tiêu",{nganKho:-5},"Đã ghi một khoản chi"]]},center:{name:"Amber",role:"Tâm điểm · trạng thái tổng",pos:[0,0,0],acts:[["Nghỉ ngơi",{sinhLuc:20},"Đã nạp lại sinh lực"],["Đổi Âm/Dương",null,null,"toggle"]]}};i.TOWERS=r;const s=[{from:"tangkinh",lvl:"info",text:"Còn 3 cuốn trong kế hoạch đọc quý này"},{from:"kieulau",lvl:"info",text:"Nhật Báo Các: 12 tin RSS mới"},{from:"tradinh",lvl:"ok",text:"Chuỗi học 6 ngày, giữ phong độ nhé",effect:{kyNang:2}},{from:"nghisu",lvl:"warn",text:"Chi Ăn uống tuần này vượt 20%",effect:{nganKho:-6}},{from:"center",lvl:"warn",text:"Webhook: amber-brain phản hồi chậm (2.4s)",effect:{heThong:-14}},{from:"center",lvl:"bad",text:"Webhook: Pi 5 nhiệt độ 78°C",effect:{heThong:-30}},{from:"tangkinh",lvl:"ok",text:"Đã đồng bộ 4 tài liệu mới"}];i.RANDOM_EVENTS=s;const o={info:"#8ab4ff",ok:"#7fd4a0",warn:"#ffcf5c",bad:"#ff6b6b"};i.LVL=o}const Ql={name:"CopyShader",uniforms:{tDiffuse:{value:null},opacity:{value:1}},vertexShader:`

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


		}`};class Ai{constructor(){this.isPass=!0,this.enabled=!0,this.needsSwap=!0,this.clear=!1,this.renderToScreen=!1}setSize(){}render(){console.error("THREE.Pass: .render() must be implemented in derived pass.")}dispose(){}}const Ym=new no(-1,1,1,-1,0,1);class jm extends Jt{constructor(){super(),this.setAttribute("position",new Nt([-1,3,0,-1,-1,0,3,-1,0],3)),this.setAttribute("uv",new Nt([0,2,0,0,2,0],2))}}const $m=new jm;class uo{constructor(t){this._mesh=new Ft($m,t)}dispose(){this._mesh.geometry.dispose()}render(t){t.render(this._mesh,Ym)}get material(){return this._mesh.material}set material(t){this._mesh.material=t}}class Km extends Ai{constructor(t,e){super(),this.textureID=e!==void 0?e:"tDiffuse",t instanceof Ee?(this.uniforms=t.uniforms,this.material=t):t&&(this.uniforms=qi.clone(t.uniforms),this.material=new Ee({name:t.name!==void 0?t.name:"unspecified",defines:Object.assign({},t.defines),uniforms:this.uniforms,vertexShader:t.vertexShader,fragmentShader:t.fragmentShader})),this.fsQuad=new uo(this.material)}render(t,e,n){this.uniforms[this.textureID]&&(this.uniforms[this.textureID].value=n.texture),this.fsQuad.material=this.material,this.renderToScreen?(t.setRenderTarget(null),this.fsQuad.render(t)):(t.setRenderTarget(e),this.clear&&t.clear(t.autoClearColor,t.autoClearDepth,t.autoClearStencil),this.fsQuad.render(t))}dispose(){this.material.dispose(),this.fsQuad.dispose()}}class nl extends Ai{constructor(t,e){super(),this.scene=t,this.camera=e,this.clear=!0,this.needsSwap=!1,this.inverse=!1}render(t,e,n){const r=t.getContext(),s=t.state;s.buffers.color.setMask(!1),s.buffers.depth.setMask(!1),s.buffers.color.setLocked(!0),s.buffers.depth.setLocked(!0);let o,a;this.inverse?(o=0,a=1):(o=1,a=0),s.buffers.stencil.setTest(!0),s.buffers.stencil.setOp(r.REPLACE,r.REPLACE,r.REPLACE),s.buffers.stencil.setFunc(r.ALWAYS,o,4294967295),s.buffers.stencil.setClear(a),s.buffers.stencil.setLocked(!0),t.setRenderTarget(n),this.clear&&t.clear(),t.render(this.scene,this.camera),t.setRenderTarget(e),this.clear&&t.clear(),t.render(this.scene,this.camera),s.buffers.color.setLocked(!1),s.buffers.depth.setLocked(!1),s.buffers.color.setMask(!0),s.buffers.depth.setMask(!0),s.buffers.stencil.setLocked(!1),s.buffers.stencil.setFunc(r.EQUAL,1,4294967295),s.buffers.stencil.setOp(r.KEEP,r.KEEP,r.KEEP),s.buffers.stencil.setLocked(!0)}}class Zm extends Ai{constructor(){super(),this.needsSwap=!1}render(t){t.state.buffers.stencil.setLocked(!1),t.state.buffers.stencil.setTest(!1)}}class Jm{constructor(t,e){if(this.renderer=t,this._pixelRatio=t.getPixelRatio(),e===void 0){const n=t.getSize(new wt);this._width=n.width,this._height=n.height,e=new Ke(this._width*this._pixelRatio,this._height*this._pixelRatio,{type:dn}),e.texture.name="EffectComposer.rt1"}else this._width=e.width,this._height=e.height;this.renderTarget1=e,this.renderTarget2=e.clone(),this.renderTarget2.texture.name="EffectComposer.rt2",this.writeBuffer=this.renderTarget1,this.readBuffer=this.renderTarget2,this.renderToScreen=!0,this.passes=[],this.copyPass=new Km(Ql),this.copyPass.material.blending=hn,this.clock=new Jl}swapBuffers(){const t=this.readBuffer;this.readBuffer=this.writeBuffer,this.writeBuffer=t}addPass(t){this.passes.push(t),t.setSize(this._width*this._pixelRatio,this._height*this._pixelRatio)}insertPass(t,e){this.passes.splice(e,0,t),t.setSize(this._width*this._pixelRatio,this._height*this._pixelRatio)}removePass(t){const e=this.passes.indexOf(t);e!==-1&&this.passes.splice(e,1)}isLastEnabledPass(t){for(let e=t+1;e<this.passes.length;e++)if(this.passes[e].enabled)return!1;return!0}render(t){t===void 0&&(t=this.clock.getDelta());const e=this.renderer.getRenderTarget();let n=!1;for(let r=0,s=this.passes.length;r<s;r++){const o=this.passes[r];if(o.enabled!==!1){if(o.renderToScreen=this.renderToScreen&&this.isLastEnabledPass(r),o.render(this.renderer,this.writeBuffer,this.readBuffer,t,n),o.needsSwap){if(n){const a=this.renderer.getContext(),l=this.renderer.state.buffers.stencil;l.setFunc(a.NOTEQUAL,1,4294967295),this.copyPass.render(this.renderer,this.writeBuffer,this.readBuffer,t),l.setFunc(a.EQUAL,1,4294967295)}this.swapBuffers()}nl!==void 0&&(o instanceof nl?n=!0:o instanceof Zm&&(n=!1))}}this.renderer.setRenderTarget(e)}reset(t){if(t===void 0){const e=this.renderer.getSize(new wt);this._pixelRatio=this.renderer.getPixelRatio(),this._width=e.width,this._height=e.height,t=this.renderTarget1.clone(),t.setSize(this._width*this._pixelRatio,this._height*this._pixelRatio)}this.renderTarget1.dispose(),this.renderTarget2.dispose(),this.renderTarget1=t,this.renderTarget2=t.clone(),this.writeBuffer=this.renderTarget1,this.readBuffer=this.renderTarget2}setSize(t,e){this._width=t,this._height=e;const n=this._width*this._pixelRatio,r=this._height*this._pixelRatio;this.renderTarget1.setSize(n,r),this.renderTarget2.setSize(n,r);for(let s=0;s<this.passes.length;s++)this.passes[s].setSize(n,r)}setPixelRatio(t){this._pixelRatio=t,this.setSize(this._width,this._height)}dispose(){this.renderTarget1.dispose(),this.renderTarget2.dispose(),this.copyPass.dispose()}}const il={type:"change"},Is={type:"start"},rl={type:"end"},Cr=new $i,sl=new yn,Qm=Math.cos(70*wl.DEG2RAD);class t0 extends kn{constructor(t,e){super(),this.object=t,this.domElement=e,this.domElement.style.touchAction="none",this.enabled=!0,this.target=new W,this.cursor=new W,this.minDistance=0,this.maxDistance=1/0,this.minZoom=0,this.maxZoom=1/0,this.minTargetRadius=0,this.maxTargetRadius=1/0,this.minPolarAngle=0,this.maxPolarAngle=Math.PI,this.minAzimuthAngle=-1/0,this.maxAzimuthAngle=1/0,this.enableDamping=!1,this.dampingFactor=.05,this.enableZoom=!0,this.zoomSpeed=1,this.enableRotate=!0,this.rotateSpeed=1,this.enablePan=!0,this.panSpeed=1,this.screenSpacePanning=!0,this.keyPanSpeed=7,this.zoomToCursor=!1,this.autoRotate=!1,this.autoRotateSpeed=2,this.keys={LEFT:"ArrowLeft",UP:"ArrowUp",RIGHT:"ArrowRight",BOTTOM:"ArrowDown"},this.mouseButtons={LEFT:Xn.ROTATE,MIDDLE:Xn.DOLLY,RIGHT:Xn.PAN},this.touches={ONE:qn.ROTATE,TWO:qn.DOLLY_PAN},this.target0=this.target.clone(),this.position0=this.object.position.clone(),this.zoom0=this.object.zoom,this._domElementKeyEvents=null,this.getPolarAngle=function(){return a.phi},this.getAzimuthalAngle=function(){return a.theta},this.getDistance=function(){return this.object.position.distanceTo(this.target)},this.listenToKeyEvents=function(X){X.addEventListener("keydown",J),this._domElementKeyEvents=X},this.stopListenToKeyEvents=function(){this._domElementKeyEvents.removeEventListener("keydown",J),this._domElementKeyEvents=null},this.saveState=function(){n.target0.copy(n.target),n.position0.copy(n.object.position),n.zoom0=n.object.zoom},this.reset=function(){n.target.copy(n.target0),n.object.position.copy(n.position0),n.object.zoom=n.zoom0,n.object.updateProjectionMatrix(),n.dispatchEvent(il),n.update(),s=r.NONE},this.update=function(){const X=new W,mt=new An().setFromUnitVectors(t.up,new W(0,1,0)),Tt=mt.clone().invert(),St=new W,Pt=new An,zt=new W,kt=2*Math.PI;return function(_t=null){const $=n.object.position;X.copy($).sub(n.target),X.applyQuaternion(mt),a.setFromVector3(X),n.autoRotate&&s===r.NONE&&K(M(_t)),n.enableDamping?(a.theta+=l.theta*n.dampingFactor,a.phi+=l.phi*n.dampingFactor):(a.theta+=l.theta,a.phi+=l.phi);let vt=n.minAzimuthAngle,bt=n.maxAzimuthAngle;isFinite(vt)&&isFinite(bt)&&(vt<-Math.PI?vt+=kt:vt>Math.PI&&(vt-=kt),bt<-Math.PI?bt+=kt:bt>Math.PI&&(bt-=kt),vt<=bt?a.theta=Math.max(vt,Math.min(bt,a.theta)):a.theta=a.theta>(vt+bt)/2?Math.max(vt,a.theta):Math.min(bt,a.theta)),a.phi=Math.max(n.minPolarAngle,Math.min(n.maxPolarAngle,a.phi)),a.makeSafe(),n.enableDamping===!0?n.target.addScaledVector(u,n.dampingFactor):n.target.add(u),n.target.sub(n.cursor),n.target.clampLength(n.minTargetRadius,n.maxTargetRadius),n.target.add(n.cursor),n.zoomToCursor&&P||n.object.isOrthographicCamera?a.radius=N(a.radius):a.radius=N(a.radius*c),X.setFromSpherical(a),X.applyQuaternion(Tt),$.copy(n.target).add(X),n.object.lookAt(n.target),n.enableDamping===!0?(l.theta*=1-n.dampingFactor,l.phi*=1-n.dampingFactor,u.multiplyScalar(1-n.dampingFactor)):(l.set(0,0,0),u.set(0,0,0));let Ut=!1;if(n.zoomToCursor&&P){let It=null;if(n.object.isPerspectiveCamera){const Wt=X.length();It=N(Wt*c);const Zt=Wt-It;n.object.position.addScaledVector(w,Zt),n.object.updateMatrixWorld()}else if(n.object.isOrthographicCamera){const Wt=new W(D.x,D.y,0);Wt.unproject(n.object),n.object.zoom=Math.max(n.minZoom,Math.min(n.maxZoom,n.object.zoom/c)),n.object.updateProjectionMatrix(),Ut=!0;const Zt=new W(D.x,D.y,0);Zt.unproject(n.object),n.object.position.sub(Zt).add(Wt),n.object.updateMatrixWorld(),It=X.length()}else console.warn("WARNING: OrbitControls.js encountered an unknown camera type - zoom to cursor disabled."),n.zoomToCursor=!1;It!==null&&(this.screenSpacePanning?n.target.set(0,0,-1).transformDirection(n.object.matrix).multiplyScalar(It).add(n.object.position):(Cr.origin.copy(n.object.position),Cr.direction.set(0,0,-1).transformDirection(n.object.matrix),Math.abs(n.object.up.dot(Cr.direction))<Qm?t.lookAt(n.target):(sl.setFromNormalAndCoplanarPoint(n.object.up,n.target),Cr.intersectPlane(sl,n.target))))}else n.object.isOrthographicCamera&&(n.object.zoom=Math.max(n.minZoom,Math.min(n.maxZoom,n.object.zoom/c)),n.object.updateProjectionMatrix(),Ut=!0);return c=1,P=!1,Ut||St.distanceToSquared(n.object.position)>o||8*(1-Pt.dot(n.object.quaternion))>o||zt.distanceToSquared(n.target)>0?(n.dispatchEvent(il),St.copy(n.object.position),Pt.copy(n.object.quaternion),zt.copy(n.target),!0):!1}}(),this.dispose=function(){n.domElement.removeEventListener("contextmenu",ft),n.domElement.removeEventListener("pointerdown",rt),n.domElement.removeEventListener("pointercancel",b),n.domElement.removeEventListener("wheel",Q),n.domElement.removeEventListener("pointermove",R),n.domElement.removeEventListener("pointerup",b),n._domElementKeyEvents!==null&&(n._domElementKeyEvents.removeEventListener("keydown",J),n._domElementKeyEvents=null)};const n=this,r={NONE:-1,ROTATE:0,DOLLY:1,PAN:2,TOUCH_ROTATE:3,TOUCH_PAN:4,TOUCH_DOLLY_PAN:5,TOUCH_DOLLY_ROTATE:6};let s=r.NONE;const o=1e-6,a=new el,l=new el;let c=1;const u=new W,f=new wt,m=new wt,p=new wt,v=new wt,x=new wt,d=new wt,h=new wt,y=new wt,_=new wt,w=new W,D=new wt;let P=!1;const I=[],F={};function M(X){return X!==null?2*Math.PI/60*n.autoRotateSpeed*X:2*Math.PI/60/60*n.autoRotateSpeed}function A(X){const mt=Math.abs(X)/(100*(window.devicePixelRatio|0));return Math.pow(.95,n.zoomSpeed*mt)}function K(X){l.theta-=X}function O(X){l.phi-=X}const z=function(){const X=new W;return function(Tt,St){X.setFromMatrixColumn(St,0),X.multiplyScalar(-Tt),u.add(X)}}(),S=function(){const X=new W;return function(Tt,St){n.screenSpacePanning===!0?X.setFromMatrixColumn(St,1):(X.setFromMatrixColumn(St,0),X.crossVectors(n.object.up,X)),X.multiplyScalar(Tt),u.add(X)}}(),E=function(){const X=new W;return function(Tt,St){const Pt=n.domElement;if(n.object.isPerspectiveCamera){const zt=n.object.position;X.copy(zt).sub(n.target);let kt=X.length();kt*=Math.tan(n.object.fov/2*Math.PI/180),z(2*Tt*kt/Pt.clientHeight,n.object.matrix),S(2*St*kt/Pt.clientHeight,n.object.matrix)}else n.object.isOrthographicCamera?(z(Tt*(n.object.right-n.object.left)/n.object.zoom/Pt.clientWidth,n.object.matrix),S(St*(n.object.top-n.object.bottom)/n.object.zoom/Pt.clientHeight,n.object.matrix)):(console.warn("WARNING: OrbitControls.js encountered an unknown camera type - pan disabled."),n.enablePan=!1)}}();function g(X){n.object.isPerspectiveCamera||n.object.isOrthographicCamera?c/=X:(console.warn("WARNING: OrbitControls.js encountered an unknown camera type - dolly/zoom disabled."),n.enableZoom=!1)}function T(X){n.object.isPerspectiveCamera||n.object.isOrthographicCamera?c*=X:(console.warn("WARNING: OrbitControls.js encountered an unknown camera type - dolly/zoom disabled."),n.enableZoom=!1)}function L(X,mt){if(!n.zoomToCursor)return;P=!0;const Tt=n.domElement.getBoundingClientRect(),St=X-Tt.left,Pt=mt-Tt.top,zt=Tt.width,kt=Tt.height;D.x=St/zt*2-1,D.y=-(Pt/kt)*2+1,w.set(D.x,D.y,1).unproject(n.object).sub(n.object.position).normalize()}function N(X){return Math.max(n.minDistance,Math.min(n.maxDistance,X))}function C(X){f.set(X.clientX,X.clientY)}function U(X){L(X.clientX,X.clientX),h.set(X.clientX,X.clientY)}function q(X){v.set(X.clientX,X.clientY)}function Z(X){m.set(X.clientX,X.clientY),p.subVectors(m,f).multiplyScalar(n.rotateSpeed);const mt=n.domElement;K(2*Math.PI*p.x/mt.clientHeight),O(2*Math.PI*p.y/mt.clientHeight),f.copy(m),n.update()}function it(X){y.set(X.clientX,X.clientY),_.subVectors(y,h),_.y>0?g(A(_.y)):_.y<0&&T(A(_.y)),h.copy(y),n.update()}function ut(X){x.set(X.clientX,X.clientY),d.subVectors(x,v).multiplyScalar(n.panSpeed),E(d.x,d.y),v.copy(x),n.update()}function gt(X){L(X.clientX,X.clientY),X.deltaY<0?T(A(X.deltaY)):X.deltaY>0&&g(A(X.deltaY)),n.update()}function xt(X){let mt=!1;switch(X.code){case n.keys.UP:X.ctrlKey||X.metaKey||X.shiftKey?O(2*Math.PI*n.rotateSpeed/n.domElement.clientHeight):E(0,n.keyPanSpeed),mt=!0;break;case n.keys.BOTTOM:X.ctrlKey||X.metaKey||X.shiftKey?O(-2*Math.PI*n.rotateSpeed/n.domElement.clientHeight):E(0,-n.keyPanSpeed),mt=!0;break;case n.keys.LEFT:X.ctrlKey||X.metaKey||X.shiftKey?K(2*Math.PI*n.rotateSpeed/n.domElement.clientHeight):E(n.keyPanSpeed,0),mt=!0;break;case n.keys.RIGHT:X.ctrlKey||X.metaKey||X.shiftKey?K(-2*Math.PI*n.rotateSpeed/n.domElement.clientHeight):E(-n.keyPanSpeed,0),mt=!0;break}mt&&(X.preventDefault(),n.update())}function Et(X){if(I.length===1)f.set(X.pageX,X.pageY);else{const mt=Rt(X),Tt=.5*(X.pageX+mt.x),St=.5*(X.pageY+mt.y);f.set(Tt,St)}}function lt(X){if(I.length===1)v.set(X.pageX,X.pageY);else{const mt=Rt(X),Tt=.5*(X.pageX+mt.x),St=.5*(X.pageY+mt.y);v.set(Tt,St)}}function ct(X){const mt=Rt(X),Tt=X.pageX-mt.x,St=X.pageY-mt.y,Pt=Math.sqrt(Tt*Tt+St*St);h.set(0,Pt)}function Mt(X){n.enableZoom&&ct(X),n.enablePan&&lt(X)}function k(X){n.enableZoom&&ct(X),n.enableRotate&&Et(X)}function tt(X){if(I.length==1)m.set(X.pageX,X.pageY);else{const Tt=Rt(X),St=.5*(X.pageX+Tt.x),Pt=.5*(X.pageY+Tt.y);m.set(St,Pt)}p.subVectors(m,f).multiplyScalar(n.rotateSpeed);const mt=n.domElement;K(2*Math.PI*p.x/mt.clientHeight),O(2*Math.PI*p.y/mt.clientHeight),f.copy(m)}function G(X){if(I.length===1)x.set(X.pageX,X.pageY);else{const mt=Rt(X),Tt=.5*(X.pageX+mt.x),St=.5*(X.pageY+mt.y);x.set(Tt,St)}d.subVectors(x,v).multiplyScalar(n.panSpeed),E(d.x,d.y),v.copy(x)}function H(X){const mt=Rt(X),Tt=X.pageX-mt.x,St=X.pageY-mt.y,Pt=Math.sqrt(Tt*Tt+St*St);y.set(0,Pt),_.set(0,Math.pow(y.y/h.y,n.zoomSpeed)),g(_.y),h.copy(y);const zt=(X.pageX+mt.x)*.5,kt=(X.pageY+mt.y)*.5;L(zt,kt)}function V(X){n.enableZoom&&H(X),n.enablePan&&G(X)}function et(X){n.enableZoom&&H(X),n.enableRotate&&tt(X)}function rt(X){n.enabled!==!1&&(I.length===0&&(n.domElement.setPointerCapture(X.pointerId),n.domElement.addEventListener("pointermove",R),n.domElement.addEventListener("pointerup",b)),yt(X),X.pointerType==="touch"?nt(X):Y(X))}function R(X){n.enabled!==!1&&(X.pointerType==="touch"?st(X):j(X))}function b(X){At(X),I.length===0&&(n.domElement.releasePointerCapture(X.pointerId),n.domElement.removeEventListener("pointermove",R),n.domElement.removeEventListener("pointerup",b)),n.dispatchEvent(rl),s=r.NONE}function Y(X){let mt;switch(X.button){case 0:mt=n.mouseButtons.LEFT;break;case 1:mt=n.mouseButtons.MIDDLE;break;case 2:mt=n.mouseButtons.RIGHT;break;default:mt=-1}switch(mt){case Xn.DOLLY:if(n.enableZoom===!1)return;U(X),s=r.DOLLY;break;case Xn.ROTATE:if(X.ctrlKey||X.metaKey||X.shiftKey){if(n.enablePan===!1)return;q(X),s=r.PAN}else{if(n.enableRotate===!1)return;C(X),s=r.ROTATE}break;case Xn.PAN:if(X.ctrlKey||X.metaKey||X.shiftKey){if(n.enableRotate===!1)return;C(X),s=r.ROTATE}else{if(n.enablePan===!1)return;q(X),s=r.PAN}break;default:s=r.NONE}s!==r.NONE&&n.dispatchEvent(Is)}function j(X){switch(s){case r.ROTATE:if(n.enableRotate===!1)return;Z(X);break;case r.DOLLY:if(n.enableZoom===!1)return;it(X);break;case r.PAN:if(n.enablePan===!1)return;ut(X);break}}function Q(X){n.enabled===!1||n.enableZoom===!1||s!==r.NONE||(X.preventDefault(),n.dispatchEvent(Is),gt(X),n.dispatchEvent(rl))}function J(X){n.enabled===!1||n.enablePan===!1||xt(X)}function nt(X){switch(at(X),I.length){case 1:switch(n.touches.ONE){case qn.ROTATE:if(n.enableRotate===!1)return;Et(X),s=r.TOUCH_ROTATE;break;case qn.PAN:if(n.enablePan===!1)return;lt(X),s=r.TOUCH_PAN;break;default:s=r.NONE}break;case 2:switch(n.touches.TWO){case qn.DOLLY_PAN:if(n.enableZoom===!1&&n.enablePan===!1)return;Mt(X),s=r.TOUCH_DOLLY_PAN;break;case qn.DOLLY_ROTATE:if(n.enableZoom===!1&&n.enableRotate===!1)return;k(X),s=r.TOUCH_DOLLY_ROTATE;break;default:s=r.NONE}break;default:s=r.NONE}s!==r.NONE&&n.dispatchEvent(Is)}function st(X){switch(at(X),s){case r.TOUCH_ROTATE:if(n.enableRotate===!1)return;tt(X),n.update();break;case r.TOUCH_PAN:if(n.enablePan===!1)return;G(X),n.update();break;case r.TOUCH_DOLLY_PAN:if(n.enableZoom===!1&&n.enablePan===!1)return;V(X),n.update();break;case r.TOUCH_DOLLY_ROTATE:if(n.enableZoom===!1&&n.enableRotate===!1)return;et(X),n.update();break;default:s=r.NONE}}function ft(X){n.enabled!==!1&&X.preventDefault()}function yt(X){I.push(X.pointerId)}function At(X){delete F[X.pointerId];for(let mt=0;mt<I.length;mt++)if(I[mt]==X.pointerId){I.splice(mt,1);return}}function at(X){let mt=F[X.pointerId];mt===void 0&&(mt=new wt,F[X.pointerId]=mt),mt.set(X.pageX,X.pageY)}function Rt(X){const mt=X.pointerId===I[0]?I[1]:I[0];return F[mt]}n.domElement.addEventListener("contextmenu",ft),n.domElement.addEventListener("pointerdown",rt),n.domElement.addEventListener("pointercancel",b),n.domElement.addEventListener("wheel",Q,{passive:!1}),this.update()}}const e0={name:"OutputShader",uniforms:{tDiffuse:{value:null},toneMappingExposure:{value:1}},vertexShader:`
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

		}`};class n0 extends Ai{constructor(){super();const t=e0;this.uniforms=qi.clone(t.uniforms),this.material=new Gm({name:t.name,uniforms:this.uniforms,vertexShader:t.vertexShader,fragmentShader:t.fragmentShader}),this.fsQuad=new uo(this.material),this._outputColorSpace=null,this._toneMapping=null}render(t,e,n){this.uniforms.tDiffuse.value=n.texture,this.uniforms.toneMappingExposure.value=t.toneMappingExposure,(this._outputColorSpace!==t.outputColorSpace||this._toneMapping!==t.toneMapping)&&(this._outputColorSpace=t.outputColorSpace,this._toneMapping=t.toneMapping,this.material.defines={},te.getTransfer(this._outputColorSpace)===se&&(this.material.defines.SRGB_TRANSFER=""),this._toneMapping===hl?this.material.defines.LINEAR_TONE_MAPPING="":this._toneMapping===dl?this.material.defines.REINHARD_TONE_MAPPING="":this._toneMapping===fl?this.material.defines.CINEON_TONE_MAPPING="":this._toneMapping===Ks?this.material.defines.ACES_FILMIC_TONE_MAPPING="":this._toneMapping===pl&&(this.material.defines.AGX_TONE_MAPPING=""),this.material.needsUpdate=!0),this.renderToScreen===!0?(t.setRenderTarget(null),this.fsQuad.render(t)):(t.setRenderTarget(e),this.clear&&t.clear(t.autoClearColor,t.autoClearDepth,t.autoClearStencil),this.fsQuad.render(t))}dispose(){this.material.dispose(),this.fsQuad.dispose()}}class i0 extends Ai{constructor(t,e,n=null,r=null,s=null){super(),this.scene=t,this.camera=e,this.overrideMaterial=n,this.clearColor=r,this.clearAlpha=s,this.clear=!0,this.clearDepth=!1,this.needsSwap=!1,this._oldClearColor=new Dt}render(t,e,n){const r=t.autoClear;t.autoClear=!1;let s,o;this.overrideMaterial!==null&&(o=this.scene.overrideMaterial,this.scene.overrideMaterial=this.overrideMaterial),this.clearColor!==null&&(t.getClearColor(this._oldClearColor),t.setClearColor(this.clearColor)),this.clearAlpha!==null&&(s=t.getClearAlpha(),t.setClearAlpha(this.clearAlpha)),this.clearDepth==!0&&t.clearDepth(),t.setRenderTarget(this.renderToScreen?null:n),this.clear===!0&&t.clear(t.autoClearColor,t.autoClearDepth,t.autoClearStencil),t.render(this.scene,this.camera),this.clearColor!==null&&t.setClearColor(this._oldClearColor),this.clearAlpha!==null&&t.setClearAlpha(s),this.overrideMaterial!==null&&(this.scene.overrideMaterial=o),t.autoClear=r}}const r0={uniforms:{tDiffuse:{value:null},luminosityThreshold:{value:1},smoothWidth:{value:1},defaultColor:{value:new Dt(0)},defaultOpacity:{value:0}},vertexShader:`

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

		}`};class Ti extends Ai{constructor(t,e,n,r){super(),this.strength=e!==void 0?e:1,this.radius=n,this.threshold=r,this.resolution=t!==void 0?new wt(t.x,t.y):new wt(256,256),this.clearColor=new Dt(0,0,0),this.renderTargetsHorizontal=[],this.renderTargetsVertical=[],this.nMips=5;let s=Math.round(this.resolution.x/2),o=Math.round(this.resolution.y/2);this.renderTargetBright=new Ke(s,o,{type:dn}),this.renderTargetBright.texture.name="UnrealBloomPass.bright",this.renderTargetBright.texture.generateMipmaps=!1;for(let f=0;f<this.nMips;f++){const m=new Ke(s,o,{type:dn});m.texture.name="UnrealBloomPass.h"+f,m.texture.generateMipmaps=!1,this.renderTargetsHorizontal.push(m);const p=new Ke(s,o,{type:dn});p.texture.name="UnrealBloomPass.v"+f,p.texture.generateMipmaps=!1,this.renderTargetsVertical.push(p),s=Math.round(s/2),o=Math.round(o/2)}const a=r0;this.highPassUniforms=qi.clone(a.uniforms),this.highPassUniforms.luminosityThreshold.value=r,this.highPassUniforms.smoothWidth.value=.01,this.materialHighPassFilter=new Ee({uniforms:this.highPassUniforms,vertexShader:a.vertexShader,fragmentShader:a.fragmentShader}),this.separableBlurMaterials=[];const l=[3,5,7,9,11];s=Math.round(this.resolution.x/2),o=Math.round(this.resolution.y/2);for(let f=0;f<this.nMips;f++)this.separableBlurMaterials.push(this.getSeperableBlurMaterial(l[f])),this.separableBlurMaterials[f].uniforms.invSize.value=new wt(1/s,1/o),s=Math.round(s/2),o=Math.round(o/2);this.compositeMaterial=this.getCompositeMaterial(this.nMips),this.compositeMaterial.uniforms.blurTexture1.value=this.renderTargetsVertical[0].texture,this.compositeMaterial.uniforms.blurTexture2.value=this.renderTargetsVertical[1].texture,this.compositeMaterial.uniforms.blurTexture3.value=this.renderTargetsVertical[2].texture,this.compositeMaterial.uniforms.blurTexture4.value=this.renderTargetsVertical[3].texture,this.compositeMaterial.uniforms.blurTexture5.value=this.renderTargetsVertical[4].texture,this.compositeMaterial.uniforms.bloomStrength.value=e,this.compositeMaterial.uniforms.bloomRadius.value=.1;const c=[1,.8,.6,.4,.2];this.compositeMaterial.uniforms.bloomFactors.value=c,this.bloomTintColors=[new W(1,1,1),new W(1,1,1),new W(1,1,1),new W(1,1,1),new W(1,1,1)],this.compositeMaterial.uniforms.bloomTintColors.value=this.bloomTintColors;const u=Ql;this.copyUniforms=qi.clone(u.uniforms),this.blendMaterial=new Ee({uniforms:this.copyUniforms,vertexShader:u.vertexShader,fragmentShader:u.fragmentShader,blending:Ns,depthTest:!1,depthWrite:!1,transparent:!0}),this.enabled=!0,this.needsSwap=!1,this._oldClearColor=new Dt,this.oldClearAlpha=1,this.basic=new De,this.fsQuad=new uo(null)}dispose(){for(let t=0;t<this.renderTargetsHorizontal.length;t++)this.renderTargetsHorizontal[t].dispose();for(let t=0;t<this.renderTargetsVertical.length;t++)this.renderTargetsVertical[t].dispose();this.renderTargetBright.dispose();for(let t=0;t<this.separableBlurMaterials.length;t++)this.separableBlurMaterials[t].dispose();this.compositeMaterial.dispose(),this.blendMaterial.dispose(),this.basic.dispose(),this.fsQuad.dispose()}setSize(t,e){let n=Math.round(t/2),r=Math.round(e/2);this.renderTargetBright.setSize(n,r);for(let s=0;s<this.nMips;s++)this.renderTargetsHorizontal[s].setSize(n,r),this.renderTargetsVertical[s].setSize(n,r),this.separableBlurMaterials[s].uniforms.invSize.value=new wt(1/n,1/r),n=Math.round(n/2),r=Math.round(r/2)}render(t,e,n,r,s){t.getClearColor(this._oldClearColor),this.oldClearAlpha=t.getClearAlpha();const o=t.autoClear;t.autoClear=!1,t.setClearColor(this.clearColor,0),s&&t.state.buffers.stencil.setTest(!1),this.renderToScreen&&(this.fsQuad.material=this.basic,this.basic.map=n.texture,t.setRenderTarget(null),t.clear(),this.fsQuad.render(t)),this.highPassUniforms.tDiffuse.value=n.texture,this.highPassUniforms.luminosityThreshold.value=this.threshold,this.fsQuad.material=this.materialHighPassFilter,t.setRenderTarget(this.renderTargetBright),t.clear(),this.fsQuad.render(t);let a=this.renderTargetBright;for(let l=0;l<this.nMips;l++)this.fsQuad.material=this.separableBlurMaterials[l],this.separableBlurMaterials[l].uniforms.colorTexture.value=a.texture,this.separableBlurMaterials[l].uniforms.direction.value=Ti.BlurDirectionX,t.setRenderTarget(this.renderTargetsHorizontal[l]),t.clear(),this.fsQuad.render(t),this.separableBlurMaterials[l].uniforms.colorTexture.value=this.renderTargetsHorizontal[l].texture,this.separableBlurMaterials[l].uniforms.direction.value=Ti.BlurDirectionY,t.setRenderTarget(this.renderTargetsVertical[l]),t.clear(),this.fsQuad.render(t),a=this.renderTargetsVertical[l];this.fsQuad.material=this.compositeMaterial,this.compositeMaterial.uniforms.bloomStrength.value=this.strength,this.compositeMaterial.uniforms.bloomRadius.value=this.radius,this.compositeMaterial.uniforms.bloomTintColors.value=this.bloomTintColors,t.setRenderTarget(this.renderTargetsHorizontal[0]),t.clear(),this.fsQuad.render(t),this.fsQuad.material=this.blendMaterial,this.copyUniforms.tDiffuse.value=this.renderTargetsHorizontal[0].texture,s&&t.state.buffers.stencil.setTest(!0),this.renderToScreen?(t.setRenderTarget(null),this.fsQuad.render(t)):(t.setRenderTarget(n),this.fsQuad.render(t)),t.setClearColor(this._oldClearColor,this.oldClearAlpha),t.autoClear=o}getSeperableBlurMaterial(t){const e=[];for(let n=0;n<t;n++)e.push(.39894*Math.exp(-.5*n*n/(t*t))/t);return new Ee({defines:{KERNEL_RADIUS:t},uniforms:{colorTexture:{value:null},invSize:{value:new wt(.5,.5)},direction:{value:new wt(.5,.5)},gaussianCoefficients:{value:e}},vertexShader:`varying vec2 vUv;
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
				}`})}getCompositeMaterial(t){return new Ee({defines:{NUM_MIPS:t},uniforms:{blurTexture1:{value:null},blurTexture2:{value:null},blurTexture3:{value:null},blurTexture4:{value:null},blurTexture5:{value:null},bloomStrength:{value:1},bloomFactors:{value:null},bloomTintColors:{value:null},bloomRadius:{value:0}},vertexShader:`varying vec2 vUv;
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
				}`})}}Ti.BlurDirectionX=new wt(1,0);Ti.BlurDirectionY=new wt(0,1);function s0(i){const{LITE:t}=i,e=new Wl({antialias:!0});i.renderer=e,e.setPixelRatio(Math.min(devicePixelRatio,t?1.25:2)),e.setSize(innerWidth,innerHeight),e.shadowMap.enabled=!0,e.shadowMap.type=cl,e.outputColorSpace=ce,e.toneMapping=Ks,e.toneMappingExposure=1.1,i.root.prepend(e.domElement);const n=new Xl;i.scene=n,n.fog=new ro(10471398,50,120);const r=new Oe(45,innerWidth/innerHeight,.1,200);i.camera=r;const s=new t0(r,e.domElement);i.controls=s,s.enableDamping=!0,s.dampingFactor=.08,s.minDistance=7,s.maxDistance=75,s.maxPolarAngle=1.38,s.enablePan=!1;const o=new Jm(e);i.composer=o,o.setPixelRatio(Math.min(devicePixelRatio,t?1.25:2)),o.setSize(innerWidth,innerHeight),o.addPass(new i0(n,r));const a=new Ti(new wt(innerWidth/2,innerHeight/2),.4,.55,.85);i.bloom=a,o.addPass(a),o.addPass(new n0)}function o0(i){const{LITE:t,renderer:e,scene:n}=i,r={gain:{value:1},cloud:{value:0},storm:{value:0},flash:{value:0},top:{value:new Dt},hor:{value:new Dt},sunDir:{value:new W(12,20,8).normalize()},night:{value:0},time:{value:0}};i.skyU=r;const s=new Ft(new ne(95,48,24),new Ee({side:Te,depthWrite:!1,fog:!1,uniforms:r,vertexShader:"varying vec3 vDir; void main(){ vDir = normalize(position); gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.); }",fragmentShader:`uniform vec3 top, hor, sunDir; uniform float night, time, cloud, flash, storm, gain; varying vec3 vDir;
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
    }`}));s.renderOrder=-1,n.add(s);const o=new Xl;i.envScene=o,o.add(new Ft(s.geometry,s.material));const a=new Ws(e);i.pmrem=a,i.envRT=null,i.envKey="",i.envAcc=9;const l=new km(14412031,4866100,.4);i.hemi=l,n.add(l);const c=new Xm(16773590,1.6);i.sun=c,c.position.set(12,20,8),c.castShadow=!0,c.shadow.mapSize.set(t?1024:2048,t?1024:2048),c.shadow.bias=-5e-4,c.shadow.normalBias=.035,Object.assign(c.shadow.camera,{left:-13,right:13,top:13,bottom:-13,near:1,far:60}),n.add(c)}function a0(i){i.fbm3=r,i.detail=l,i.smooth=m,i.streak=F;const t=(M,A,K)=>{const O=Math.min(1,Math.max(0,(K-M)/(A-M)));return O*O*(3-2*O)};i.sst=t;const e=(M,A,K)=>{const O=Math.sin(M*127.1+A*311.7+K*74.7)*43758.5453;return O-Math.floor(O)};function n(M,A,K){const O=Math.floor(M),z=Math.floor(A),S=Math.floor(K),E=M-O,g=A-z,T=K-S,L=E*E*(3-2*E),N=g*g*(3-2*g),C=T*T*(3-2*T),U=(q,Z,it)=>q+(Z-q)*it;return U(U(U(e(O,z,S),e(O+1,z,S),L),U(e(O,z+1,S),e(O+1,z+1,S),L),N),U(U(e(O,z,S+1),e(O+1,z,S+1),L),U(e(O,z+1,S+1),e(O+1,z+1,S+1),L),N),C)}function r(M,A,K,O=4){let z=.5,S=0,E=0;for(let g=0;g<O;g++)S+=z*n(M,A,K),E+=z,M=M*2.03+1.7,A=A*2.03+4.1,K=K*2.03+2.9,z*=.5;return S/E}const s=`
  float dh(vec3 p){ return fract(sin(dot(p, vec3(127.1,311.7,74.7))) * 43758.5453); }
  float dn(vec3 p){ vec3 i = floor(p), f = fract(p); f = f*f*(3. - 2.*f);
    return mix(mix(mix(dh(i), dh(i+vec3(1.,0.,0.)), f.x), mix(dh(i+vec3(0.,1.,0.)), dh(i+vec3(1.,1.,0.)), f.x), f.y),
               mix(mix(dh(i+vec3(0.,0.,1.)), dh(i+vec3(1.,0.,1.)), f.x), mix(dh(i+vec3(0.,1.,1.)), dh(i+vec3(1.,1.,1.)), f.x), f.y), f.z); }
  float dfbm(vec3 p){ return dn(p)*.55 + dn(p*2.3 + 7.1)*.3 + dn(p*5.1 + 3.3)*.15; }`,o=new WeakMap,a=new WeakMap;function l(M,A={}){const{s:K=[6,6,6],bump:O=.012,vary:z=.16,rock:S=!1}=A,E=g=>g.toFixed(4);return M.onBeforeCompile=g=>{g.vertexShader=g.vertexShader.replace("#include <common>",`#include <common>
varying vec3 vDP, vWN, vWPd;`).replace("#include <begin_vertex>",`#include <begin_vertex>
vDP = position;`+(S?" vWN = normalize(mat3(modelMatrix) * objectNormal); vWPd = (modelMatrix * vec4(position, 1.)).xyz;":"")),g.fragmentShader=g.fragmentShader.replace("#include <common>",`#include <common>
varying vec3 vDP, vWN, vWPd;`+s).replace("#include <color_fragment>",`#include <color_fragment>
        vec3 dP = vDP * vec3(${K.map(E).join(",")});
        float dFade = clamp(1.3 - length(fwidth(dP))*1.1, 0., 1.);            // xa thì tắt vân → không nhấp nháy
        float dH = mix(.5, dfbm(dP), dFade);
        diffuseColor.rgb *= 1. + (dH - .5) * ${E(z*2)};
        float rWet = 0.;
        ${S?`float rS = dn(vec3(vDP.y*9. + dn(vDP*1.3)*5., 3., 7.));                       // thớ đá nằm ngang
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
          normal = normalize(abs(det)*normal - ${E(O)}*grad); }`)},M.customProgramCacheKey=()=>"detail"+K+"|"+O+"|"+z+S,o.set(M,A),M}const c=[];i.unlit=c;const u=M=>(c.push([M,M.color.clone()]),M);i.U=u;const f=(M,A={})=>{const{d:K,...O}=A,z=new Be({color:M,roughness:.85,flatShading:!0,...O});return K===!1?z:l(z,K)};i.M=f;function m(M){if(!M.flatShading)return M;let A=a.get(M);return A||(A=M.clone(),A.flatShading=!1,o.has(M)&&l(A,o.get(M)),a.set(M,A)),A}const p=M=>{const A=M.parameters??{};return/Sphere|Torus|Tube/.test(M.type)||/Cylinder|Cone/.test(M.type)&&A.radialSegments>=8||M.type==="IcosahedronGeometry"&&A.detail>=1},v=(M,A)=>A.isMaterial&&A.flatShading&&p(M)?m(A):A;i.fit=v;const x={stone:f(11774098,{roughness:.92,d:{s:[5,5,5],bump:.022,vary:.22}}),wood:f(9383716,{roughness:.55,d:{s:[16,5,16],bump:.004,vary:.14}}),gold:f(14263361,{metalness:.85,roughness:.32,d:!1}),rock:f(5984071,{roughness:.95,d:{s:[3.5,3.5,3.5],bump:.04,vary:.3}}),trunk:f(4863014,{roughness:.95,d:{s:[14,3,14],bump:.02,vary:.35}}),paper:f(15327176,{roughness:.9,d:{s:[7,7,7],bump:.003,vary:.07}})};i.MAT=x;const d=l(new Be({vertexColors:!0,roughness:.95}),{s:[7,7,7],bump:.07,vary:.3,rock:!0});i.rockMat=d;const h=[];i.lanternMats=h;const y=[],_=[],w=[];i.trees=y,i.reeds=_,i.blossomSpots=w;const D=()=>{const M=f(16742973,{emissive:16734751,emissiveIntensity:.4,flatShading:!1,d:!1});return h.push(M),M};i.lanternMat=D;const P=(M,A,K=0,O=0,z=0)=>{const S=new Ft(M,v(M,A));return S.position.set(K,O,z),S.castShadow=S.receiveShadow=!0,S};i.mesh=P;const I=(M,A,K,O,z,S,E)=>P(new $e(M,A,K),O,z,S,E);i.box=I;function F(M,A,K,O,z,S){const E=M.createLinearGradient(0,K,0,K+z);E.addColorStop(0,"rgba(255,255,255,0)"),E.addColorStop(.5,`rgba(255,255,255,${S})`),E.addColorStop(1,"rgba(255,255,255,0)"),M.fillStyle=E,M.fillRect(A,K,O,z)}}function l0(i){const{TOWERS:t,detail:e,fbm3:n,rockMat:r,scene:s,sst:o,trees:a}=i;i.frontXZ=_,i.riverDist=D,i.freeGround=A;const l=10,c=.6,u=1.7,f=7.2;i.R=l,i.TOP=c,i.AMBER_Y=f;const m=[7.25,-1.85],p=1.25;i.POOL=m,i.POOL_R=p;const v=(()=>{const S=l*440/512/2,E=[],g=1,T=new wt(S+S*Math.cos(g),-S*Math.sin(g)),L=new wt(-Math.sin(g),-Math.cos(g)),N=new $l(new wt(m[0],m[1]),T.clone().addScaledVector(L,-.9),T);for(let C=0;C<8;C++)E.push(N.getPoint(C/8));for(let C=0;C<=30;C++){const U=g+C/30*(Math.PI-g);E.push(new wt(S+S*Math.cos(U),-S*Math.sin(U)))}for(let C=1;C<=40;C++){const U=C/40*Math.PI;E.push(new wt(-S+S*Math.cos(U),S*Math.sin(U)))}return E.push(new wt(-l-.06,0)),E})();i.RIVER=v;const x=(()=>{let S=0;return v.map((E,g)=>{const T=v[Math.max(0,g-1)],N=v[Math.min(v.length-1,g+1)].clone().sub(T).normalize(),C=new wt(-N.y,N.x);return g&&(S+=E.distanceTo(v[g-1])),{p:E,n:C,d:S,w:u/2*(1+.17*Math.sin(S*1.15+1)+.09*Math.sin(S*2.7+.4))}})})();i.RIVER_EDGES=x;const d={nghisu:{d:2.4,side:-1},tangkinh:{d:3,side:-1},tradinh:{d:3.2,side:1}};i.PATHS=d;const h=3.7,y=3.05;i.PLAZA_X=h,i.BRIDGE_END=y;function _(S){const[E,,g]=t[S].pos,T=Math.hypot(E,g),L=d[S].d;return[E-E/T*L,g-g/T*L]}const w=c-.08;i.WY=w;function D(S,E){let g=1e9;for(let T=0;T<x.length-1;T++){const L=x[T],N=x[T+1],C=N.p.x-L.p.x,U=N.p.y-L.p.y,q=Math.max(0,Math.min(1,((S-L.p.x)*C+(E-L.p.y)*U)/(C*C+U*U))),Z=Math.hypot(S-L.p.x-C*q,E-L.p.y-U*q)-(L.w+(N.w-L.w)*q);Z<g&&(g=Z)}return Math.min(g,Math.hypot(S-m[0],E-m[1])-p)}const P=(S,E)=>c-.42*o(.3,-.45,D(S,E));i.groundY=P;const I=(S,E)=>{const g=l*440/512/2;return Math.hypot(S-g,E)<g||E>0&&Math.hypot(S+g,E)>g};i.isYin=I;const F=(S,E,g,T,L,N)=>{const C=L-g,U=N-T,q=Math.max(0,Math.min(1,((S-g)*C+(E-T)*U)/(C*C+U*U)));return Math.hypot(S-g-C*q,E-T-U*q)},M=Object.keys(d).flatMap(S=>{const[E,g]=_(S),T=d[S].side;return[[E,g,T*h,0],[T*h,0,T*y,0]]});function A(S,E,g=!1){if(Math.hypot(S,E)>(g?9.6:8.9))return!1;for(const[T,L]of Object.entries(t)){if(T==="center")continue;if(T==="kieulau"&&g){if(Math.abs(S)<3.7&&Math.abs(E)<1.15)return!1;continue}const N=g?T==="nghisu"?3.25:T==="tangkinh"?2.85:2.35:T==="nghisu"?3.6:T==="kieulau"?3.4:2.7;if(Math.hypot(S-L.pos[0],E-L.pos[2])<N)return!1}if(Math.hypot(S-7.2,E-1)<(g?2.55:3.1)||D(S,E)<(g?.1:.45))return!1;for(const T of M)if(F(S,E,...T)<(g?.6:.75))return!1;for(const T of[-1,1])if(Math.hypot(S-T*h,E)<(g?1.33:1.5))return!1;if(!g){for(const T of a)if(Math.hypot(S-T.g.position.x,E-T.g.position.z)<.9)return!1}return!0}function K(){const E=document.createElement("canvas");E.width=E.height=2048;const g=E.getContext("2d"),T=2048/2/l,L=(tt,G)=>[2048/2+G*T,2048/2-tt*T],N=l*440/512/2,C=i.rng;g.fillStyle="#7f9a52",g.fillRect(0,0,2048,2048),g.fillStyle="#3d5843",g.fillRect(2048/2,0,2048/2,2048);let[U,q]=L(-N,0);g.fillStyle="#7f9a52",g.beginPath(),g.arc(U,q,N*T,0,7),g.fill(),[U,q]=L(N,0),g.fillStyle="#3d5843",g.beginPath(),g.arc(U,q,N*T,0,7),g.fill();const Z=["#93ab58","#6e8f44","#a3b266","#b0a86a","#86a44f","#5f8440"],it=["#324d3a","#4a6549","#2a4034","#56704e","#4f5d4c","#3a5a52"];for(let tt=0;tt<7500;tt++){const G=C()*7,H=Math.sqrt(C())*l,V=Math.cos(G)*H,et=Math.sin(G)*H,[rt,R]=L(V,et),b=8+C()*46,Y=I(V,et)?it:Z,j=Y[Math.floor(C()*Y.length)],Q=g.createRadialGradient(rt,R,0,rt,R,b);Q.addColorStop(0,j),Q.addColorStop(1,j+"00"),g.globalAlpha=.12+C()*.3,g.fillStyle=Q,g.fillRect(rt-b,R-b,b*2,b*2)}g.globalAlpha=1;for(const[tt,G]of Object.entries(t)){if(tt==="center"||tt==="kieulau")continue;const[H,V]=L(G.pos[0],G.pos[2]),et=(tt==="nghisu"?4:3.1)*T,rt=g.createRadialGradient(H,V,et*.55,H,V,et);rt.addColorStop(0,"rgba(128,118,96,.75)"),rt.addColorStop(1,"rgba(128,118,96,0)"),g.fillStyle=rt,g.fillRect(H-et,V-et,2*et,2*et)}{const[tt,G]=L(7.2,1),H=3.8*T,V=g.createRadialGradient(tt,G,H*.5,tt,G,H);V.addColorStop(0,"rgba(96,90,80,.9)"),V.addColorStop(1,"rgba(96,90,80,0)"),g.fillStyle=V,g.fillRect(tt-H,G-H,2*H,2*H);for(let et=0;et<260;et++){const rt=C()*7,R=1.9+C()*1.9,[b,Y]=L(7.2+Math.cos(rt)*R,1+Math.sin(rt)*R),j=90+C()*80|0;g.fillStyle=`rgba(${j},${j-4},${j-12},${.4+C()*.5})`,g.beginPath(),g.ellipse(b,Y,2+C()*7,2+C()*5,C()*3,0,7),g.fill()}}g.lineCap=g.lineJoin="round";const ut=tt=>{g.beginPath(),x.forEach(({p:G,n:H,w:V},et)=>{const[rt,R]=L(G.x+H.x*(V+tt),G.y+H.y*(V+tt));et?g.lineTo(rt,R):g.moveTo(rt,R)});for(let G=x.length-1;G>=0;G--){const{p:H,n:V,w:et}=x[G],[rt,R]=L(H.x-V.x*(et+tt),H.y-V.y*(et+tt));g.lineTo(rt,R)}g.closePath()},gt=L(m[0],m[1]);for(const[tt,G]of[["rgba(104,94,72,.22)",.7],["rgba(112,100,76,.4)",.5],["rgba(124,112,88,.7)",.32],["#6d6452",.16],["#3c4a42",0],["#243636",-.3]])g.fillStyle=tt,ut(G),g.fill(),g.beginPath(),g.arc(gt[0],gt[1],Math.max(0,p+G)*T,0,7),g.fill();x.forEach(({p:tt,n:G,w:H})=>{for(let V=0;V<16;V++){const et=(H+(C()-.62)*.6)*(C()<.5?-1:1),[rt,R]=L(tt.x+G.x*et+(C()-.5)*.3,tt.y+G.y*et+(C()-.5)*.3),b=105+C()*95|0;g.fillStyle=`rgba(${b},${b-6},${b-18},${.45+C()*.4})`,g.beginPath(),g.ellipse(rt,R,2+C()*5,1.5+C()*3.5,C()*3,0,7),g.fill()}});const xt=Object.keys(d).map(tt=>{const[G,H]=_(tt),V=d[tt].side;return[[G,H],[V*h,0],[V*y,0]]}),Et=(tt,G,H)=>{g.strokeStyle=H,g.lineWidth=G*T,g.beginPath(),tt.forEach(([V,et],rt)=>{const[R,b]=L(V,et);rt?g.lineTo(R,b):g.moveTo(R,b)}),g.stroke()};xt.forEach(tt=>{Et(tt,1.45,"rgba(98,90,70,.3)"),Et(tt,1.15,"rgba(92,84,66,.6)"),Et(tt,.95,"#5f594b")});const lt=(tt,G=24)=>{const H=(C()-.5)*G;return`rgb(${tt[0]+H|0},${tt[1]+H|0},${tt[2]+H*.8|0})`},ct=(tt,G,H,V,et,rt)=>{const[R,b]=L(tt,G);g.save(),g.translate(R,b),g.rotate(H+(C()-.5)*.08),g.fillStyle=rt,g.beginPath(),g.roundRect?g.roundRect(-V*T/2,-et*T/2,V*T,et*T,4):g.rect(-V*T/2,-et*T/2,V*T,et*T),g.fill(),g.restore()};xt.forEach(tt=>{for(let G=0;G<tt.length-1;G++){const[H,V]=tt[G],[et,rt]=tt[G+1],R=Math.hypot(et-H,rt-V),b=(et-H)/R,Y=(rt-V)/R,j=Math.atan2(-b,Y);for(let Q=.12,J=0;Q<R;Q+=.3,J++){const nt=J%2?2:3;for(let st=0;st<nt;st++){const ft=(st-(nt-1)/2)*(.86/nt);ct(H+b*Q-Y*ft,V+Y*Q+b*ft,j,.26,.86/nt-.04,lt([176,168,150]))}}}});for(const tt of[-1,1]){const G=tt<0?[74,76,84]:[214,206,188],[H,V]=L(tt*h,0);g.fillStyle=tt<0?"#33353b":"#8f8672",g.beginPath(),g.arc(H,V,1.28*T,0,7),g.fill(),g.fillStyle=lt(G),g.beginPath(),g.arc(H,V,.2*T,0,7),g.fill();for(let et=.24;et<1.2;et+=.24){const rt=Math.round(2*Math.PI*(et+.12)/.3),R=C()*7;for(let b=0;b<rt;b++){const Y=R+b/rt*2*Math.PI,j=Y+2*Math.PI/rt-.035/(et+.12);g.fillStyle=lt(G),g.beginPath(),g.arc(H,V,(et+.02)*T,Y,j),g.arc(H,V,(et+.22)*T,j,Y,!0),g.closePath(),g.fill()}}}const Mt=g.createRadialGradient(2048/2,2048/2,l*T*.93,2048/2,2048/2,l*T);Mt.addColorStop(0,"rgba(70,60,48,0)"),Mt.addColorStop(1,"rgba(70,60,48,.6)"),g.fillStyle=Mt,g.fillRect(0,0,2048,2048);const k=new Ze(E);return k.colorSpace=ce,k.anisotropy=8,k}const O=new Dt,z=(S,E,g,T)=>(S.setHSL(.075+T*.02,.11,.19+T*.16+.03*Math.sin(E*7+T*9)),S.lerp(O.setHSL(.24+T*.04,.3,.15+T*.09),o(.5,.85,g)*o(.12,.5,E)*o(.3,.55,T)*.85));i.rockTint=z,(()=>{const g=[],T=[],L=[];for(let Et=0;Et<=64;Et++){const lt=l*Et/64;for(let ct=0;ct<300;ct++){const Mt=ct/300*Math.PI*2,k=Math.cos(Mt)*lt,tt=Math.sin(Mt)*lt;g.push(k,P(k,tt),tt),T.push(.5+tt/l/2,.5+k/l/2)}}for(let Et=0;Et<64;Et++)for(let lt=0;lt<300;lt++){const ct=Et*300+lt,Mt=Et*300+(lt+1)%300,k=ct+300,tt=Mt+300;L.push(ct,Mt,k,k,Mt,tt)}const N=new Jt;N.setAttribute("position",new Nt(g,3)),N.setAttribute("uv",new Nt(T,2)),N.setIndex(L),N.computeVertexNormals();const C=new Ft(N,e(new Be({map:K(),roughness:1}),{s:[11,11,11],bump:.018,vary:.3}));C.receiveShadow=!0,s.add(C);const U=36,q=[],Z=[],it=[],ut=new Dt;for(let Et=0;Et<=U;Et++){const lt=Et/U;for(let ct=0;ct<300;ct++){const Mt=ct/300*Math.PI*2,k=Math.cos(Mt),tt=Math.sin(Mt),G=P(k*l,tt*l);let H,V;if(lt<.14){const b=lt/.14;H=l*(1-.07*b),V=G+(-.7-G)*b}else{const b=(lt-.14)/.86;H=l*.93*Math.pow(1-b,.6),V=-.7-7.4*Math.pow(b,1.1)}const et=n(k*H*.32+3,V*.5,tt*H*.32+9,4),rt=n(k*H*1.3,V*1.6+5,tt*H*1.3,3),R=o(0,.08,lt);H*=1+R*((et-.5)*.55+(rt-.5)*.16),V+=R*(rt-.5)*.5-(lt>.14?R*Math.max(0,n(k*H*.55+20,1,tt*H*.55+4,3)-.5)*5.5:0),q.push(k*H,V,tt*H),z(ut,0,0,et*.6+rt*.4),lt<.05&&ut.lerp(O.setRGB(.2,.17,.12),1-lt/.05),ut.multiplyScalar(1-.35*o(.1,.9,lt)),Z.push(ut.r,ut.g,ut.b)}}for(let Et=0;Et<U;Et++)for(let lt=0;lt<300;lt++){const ct=Et*300+lt,Mt=Et*300+(lt+1)%300,k=ct+300,tt=Mt+300;it.push(ct,Mt,k,k,Mt,tt)}const gt=new Jt;gt.setAttribute("position",new Nt(q,3)),gt.setAttribute("color",new Nt(Z,3)),gt.setIndex(it),gt.computeVertexNormals();const xt=new Ft(gt,r);return xt.receiveShadow=!0,s.add(xt),C})()}function c0(i){const{POOL:t,POOL_R:e,R:n,RIVER_EDGES:r,U:s,WY:o,scene:a,streak:l}=i;i.animateRiver=I;function c(O,z,S,E="rgba(255,255,255,0)"){const g=document.createElement("canvas");g.width=O,g.height=z;const T=g.getContext("2d");T.fillStyle=E,T.fillRect(0,0,O,z);for(let N=0;N<S;N++)l(T,i.rng()*O,i.rng()*z,1+i.rng()*2.5,16+i.rng()*50,.15+i.rng()*.35);const L=new Ze(g);return L.wrapS=L.wrapT=yi,L}const u=c(64,256,70,"#c6c6c6");i.waterTex=u;const f={uTime:{value:0},uImpact:{value:new wt(7.2,-1.2)},uIn:{value:new wt(6.4,1.1)},uOut:{value:new wt(7.2,0)}};i.waterU=f;function m(O,z){O.onBeforeCompile=S=>{S.uniforms.uTime=f.uTime,S.uniforms.uImpact=f.uImpact,S.uniforms.uIn=f.uIn,S.uniforms.uOut=f.uOut,S.vertexShader=S.vertexShader.replace("#include <common>",`#include <common>
attribute float aEdge; varying float vEdge; varying vec3 vWPos;`).replace("#include <project_vertex>",`#include <project_vertex>
vWPos = (modelMatrix * vec4(transformed, 1.)).xyz; vEdge = aEdge;`),S.fragmentShader=S.fragmentShader.replace("#include <common>",`#include <common>
varying vec3 vWPos; varying float vEdge; uniform float uTime; uniform vec2 uImpact, uIn, uOut;`).replace("#include <color_fragment>",`#include <color_fragment>
        float wFoam = 0.;
        ${z==="lake"?`float dIn = distance(vWPos.xz, uIn);                                // hồ trên núi
        float lf = sin(vWPos.x*21. + uTime*3.3) * sin(vWPos.z*23. - uTime*2.9);
        wFoam = smoothstep(.42, .08, dIn + lf*.08) * .9;                                    // bọt sủi chỗ dòng nguồn rơi xuống
        float sO = smoothstep(.85, .1, distance(vWPos.xz, uOut));                           // gần cửa tràn: nước tăng tốc, nổi vệt trắng dần
        float stN = sin(vWPos.x*40. + sin(vWPos.z*7. + uTime*5.)*1.6)*.5 + .5;
        wFoam = max(wFoam, sO*sO*(.15 + .6*stN));
        diffuseColor.rgb = mix(diffuseColor.rgb, vec3(1.), wFoam*.7);
        diffuseColor.rgb = mix(vec3(.5, .82, .76), diffuseColor.rgb, .3 + .7*smoothstep(0., .22, vEdge)); // ven bờ nông, nước nhạt màu`:z?`float edge = min(vMapUv.x, 1. - vMapUv.x);
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
        ${z==="lake"?"float dL = distance(wp, uIn); pn.xz += normalize(wp - uIn + 1e-4) * sin(dL*22. - uTime*8.) * .24 * exp(-dL*2.);":z?"":"float dR = distance(wp, uImpact); pn.xz += normalize(wp - uImpact + 1e-4) * sin(dR*15. - uTime*7.) * .3 * exp(-dR*1.1);  // sóng vòng lan từ chân thác"}
        normal = normalize(normal + (viewMatrix * vec4(pn, 0.)).xyz);
        float wFr = pow(1. - clamp(dot(normalize(vViewPosition), normal), 0., 1.), 3.);
        diffuseColor.a = max(wFoam*.75, mix(.62, .96, wFr));
        ${z==="lake"?"diffuseColor.a *= smoothstep(0., .1, vEdge);   // mép hồ tan dần vào đá":""}`)},O.customProgramCacheKey=()=>"water"+z}const p={color:2784392,map:u,transparent:!0,opacity:.9,roughness:.06,metalness:.3,emissive:734544,emissiveIntensity:.08,depthWrite:!1,envMapIntensity:2.4},v=new Be(p);i.waterMat=v,m(v,!0);const x=new Be(p);i.poolMat=x,m(x,!1);const d=new Be(p);i.lakeMat=d,m(d,"lake");const h={value:1};i.fallLum=h;const y=(O,z,S=0,E=0)=>new Ee({transparent:!0,depthWrite:!1,side:be,uniforms:{uTime:f.uTime,uLum:h,uSpeed:{value:O},uSy:{value:z},uW:{value:S},uFade:{value:E}},vertexShader:"attribute float aWhite; varying vec2 vUv; varying float vW; void main(){ vUv = uv; vW = aWhite; gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.); }",fragmentShader:`uniform float uTime, uLum, uSpeed, uSy, uW, uFade; varying vec2 vUv; varying float vW;
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
    }`});i.fallMaterial=y;const _=(()=>{const O=document.createElement("canvas");O.width=O.height=128;const z=O.getContext("2d");for(let S=0;S<7;S++){const E=40+i.rng()*48,g=44+i.rng()*40,T=20+i.rng()*22,L=z.createRadialGradient(E,g,0,E,g,T);L.addColorStop(0,"rgba(255,255,255,.45)"),L.addColorStop(1,"rgba(255,255,255,0)"),z.fillStyle=L,z.fillRect(0,0,128,128)}return new Ze(O)})();i.mistTex=_;const w=6,D=new Jt,P=[];{const O=[],z=[],S=[];r.forEach(({p:T,n:L,w:N,d:C},U)=>{for(let q=0;q<=w;q++){const Z=q/w,it=(N+.1)*(1-2*Z);O.push(T.x+L.x*it,o,T.y+L.y*it),z.push(Z,C/2.5),P.push(C,Z)}if(U){const q=(U-1)*(w+1),Z=U*(w+1);for(let it=0;it<w;it++)S.push(q+it,Z+it,q+it+1,q+it+1,Z+it,Z+it+1)}}),D.setAttribute("position",new Nt(O,3)),D.setAttribute("uv",new Nt(z,2)),D.setIndex(S),D.computeVertexNormals();const E=new Ft(D,v);E.receiveShadow=!0,E.renderOrder=1,a.add(E);const g=new Ft(new Xr(e,32),x);g.rotation.x=-Math.PI/2,g.position.set(t[0],o-.005,t[1]),g.renderOrder=1,a.add(g)}function I(O){const z=D.attributes.position;for(let S=0;S<z.count;S++){const E=P[S*2],g=P[S*2+1],T=Math.sin(g*Math.PI),L=1+2.5*Math.exp(-E*.8);z.setY(S,o+.005+T*L*(.03*Math.sin(E*2.3-O*2.6+g*2.5)+.018*Math.sin(E*5.7+O*3.3-g*4))+T*i.cur.r*.022*Math.sin(E*13+O*9+g*11))}z.needsUpdate=!0,D.computeVertexNormals()}const F=c(64,256,120,"rgba(170,220,242,.45)");i.fallTex=F,F.repeat.set(1,2);const M=y(-1,4.5,.35),A=new Ft(new Wn(r.at(-1).w*2,7.5),M);A.rotation.y=-Math.PI/2,A.position.set(-n-.08,o-3.75,0),a.add(A);const K=new Qt;i.mist=K,a.add(K);for(let O=0;O<7;O++)K.add(new zr(s(new Yi({map:_,color:16777215,transparent:!0,opacity:.35,depthWrite:!1}))))}function u0(i,t=!1){const e=i[0].index!==null,n=new Set(Object.keys(i[0].attributes)),r=new Set(Object.keys(i[0].morphAttributes)),s={},o={},a=i[0].morphTargetsRelative,l=new Jt;let c=0;for(let u=0;u<i.length;++u){const f=i[u];let m=0;if(e!==(f.index!==null))return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+u+". All geometries must have compatible attributes; make sure index attribute exists among all geometries, or in none of them."),null;for(const p in f.attributes){if(!n.has(p))return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+u+'. All geometries must have compatible attributes; make sure "'+p+'" attribute exists among all geometries, or in none of them.'),null;s[p]===void 0&&(s[p]=[]),s[p].push(f.attributes[p]),m++}if(m!==n.size)return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+u+". Make sure all geometries have the same number of attributes."),null;if(a!==f.morphTargetsRelative)return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+u+". .morphTargetsRelative must be consistent throughout all geometries."),null;for(const p in f.morphAttributes){if(!r.has(p))return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+u+".  .morphAttributes must be consistent throughout all geometries."),null;o[p]===void 0&&(o[p]=[]),o[p].push(f.morphAttributes[p])}if(t){let p;if(e)p=f.index.count;else if(f.attributes.position!==void 0)p=f.attributes.position.count;else return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed with geometry at index "+u+". The geometry must have either an index or a position attribute"),null;l.addGroup(c,p,u),c+=p}}if(e){let u=0;const f=[];for(let m=0;m<i.length;++m){const p=i[m].index;for(let v=0;v<p.count;++v)f.push(p.getX(v)+u);u+=i[m].attributes.position.count}l.setIndex(f)}for(const u in s){const f=ol(s[u]);if(!f)return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed while trying to merge the "+u+" attribute."),null;l.setAttribute(u,f)}for(const u in o){const f=o[u][0].length;if(f===0)break;l.morphAttributes=l.morphAttributes||{},l.morphAttributes[u]=[];for(let m=0;m<f;++m){const p=[];for(let x=0;x<o[u].length;++x)p.push(o[u][x][m]);const v=ol(p);if(!v)return console.error("THREE.BufferGeometryUtils: .mergeGeometries() failed while trying to merge the "+u+" morphAttribute."),null;l.morphAttributes[u].push(v)}}return l}function ol(i){let t,e,n,r=-1,s=0;for(let c=0;c<i.length;++c){const u=i[c];if(u.isInterleavedBufferAttribute)return console.error("THREE.BufferGeometryUtils: .mergeAttributes() failed. InterleavedBufferAttributes are not supported."),null;if(t===void 0&&(t=u.array.constructor),t!==u.array.constructor)return console.error("THREE.BufferGeometryUtils: .mergeAttributes() failed. BufferAttribute.array must be of consistent array types across matching attributes."),null;if(e===void 0&&(e=u.itemSize),e!==u.itemSize)return console.error("THREE.BufferGeometryUtils: .mergeAttributes() failed. BufferAttribute.itemSize must be consistent across matching attributes."),null;if(n===void 0&&(n=u.normalized),n!==u.normalized)return console.error("THREE.BufferGeometryUtils: .mergeAttributes() failed. BufferAttribute.normalized must be consistent across matching attributes."),null;if(r===-1&&(r=u.gpuType),r!==u.gpuType)return console.error("THREE.BufferGeometryUtils: .mergeAttributes() failed. BufferAttribute.gpuType must be consistent across matching attributes."),null;s+=u.array.length}const o=new t(s);let a=0;for(let c=0;c<i.length;++c)o.set(i[c].array,a),a+=i[c].array.length;const l=new fe(o,e,n);return r!==void 0&&(l.gpuType=r),l}function h0(i,t=1e-4){t=Math.max(t,Number.EPSILON);const e={},n=i.getIndex(),r=i.getAttribute("position"),s=n?n.count:r.count;let o=0;const a=Object.keys(i.attributes),l={},c={},u=[],f=["getX","getY","getZ","getW"],m=["setX","setY","setZ","setW"];for(let y=0,_=a.length;y<_;y++){const w=a[y],D=i.attributes[w];l[w]=new fe(new D.array.constructor(D.count*D.itemSize),D.itemSize,D.normalized);const P=i.morphAttributes[w];P&&(c[w]=new fe(new P.array.constructor(P.count*P.itemSize),P.itemSize,P.normalized))}const p=t*.5,v=Math.log10(1/t),x=Math.pow(10,v),d=p*x;for(let y=0;y<s;y++){const _=n?n.getX(y):y;let w="";for(let D=0,P=a.length;D<P;D++){const I=a[D],F=i.getAttribute(I),M=F.itemSize;for(let A=0;A<M;A++)w+=`${~~(F[f[A]](_)*x+d)},`}if(w in e)u.push(e[w]);else{for(let D=0,P=a.length;D<P;D++){const I=a[D],F=i.getAttribute(I),M=i.morphAttributes[I],A=F.itemSize,K=l[I],O=c[I];for(let z=0;z<A;z++){const S=f[z],E=m[z];if(K[E](o,F[S](_)),M)for(let g=0,T=M.length;g<T;g++)O[g][E](o,M[g][S](_))}}e[w]=o,u.push(o),o++}}const h=i.clone();for(const y in i.attributes){const _=l[y];if(h.setAttribute(y,new fe(_.array.slice(0,o*_.itemSize),_.itemSize,_.normalized)),y in c)for(let w=0;w<c[y].length;w++){const D=c[y][w];h.morphAttributes[y][w]=new fe(D.array.slice(0,o*D.itemSize),D.itemSize,D.normalized)}}return h.setIndex(u),h}function d0(i){const{M:t,POOL:e,POOL_R:n,TOP:r,U:s,WY:o,fallMaterial:a,fbm3:l,lakeMat:c,mesh:u,mistTex:f,poolMat:m,riverDist:p,rockMat:v,rockTint:x,scene:d,sst:h,streak:y,waterU:_}=i;i.boulder=g,i.animateSplash=Mt;function w(k,tt){let G=new lo(1,k);G.deleteAttribute("normal"),G.deleteAttribute("uv"),G=h0(G,1e-4);const H=G.attributes.position,V=new W,et=[];for(let rt=0;rt<H.count;rt++)V.fromBufferAttribute(H,rt),et.push(tt(V)??1),H.setXYZ(rt,V.x,V.y,V.z);return G.computeVertexNormals(),G.userData.ao=et,G}function D(k,tt){const G=k.attributes.position,H=[],V=new Dt,et=k.userData.ao;for(let rt=0;rt<G.count;rt++)x(V,G.getY(rt),0,l(G.getX(rt)*2.2+tt,G.getY(rt)*2.2,G.getZ(rt)*2.2,3)).multiplyScalar(et[rt]),H.push(V.r,V.g,V.b);return k.setAttribute("color",new Nt(H,3)),k}function P(k,tt,G){const H=w(18,et=>{const rt=et.x,R=et.y,b=et.z,Y=(R+1)/2,j=1-Math.pow(Y,1.3)*.75,Q=l(rt*1.5+G*7.3,R*1.2,b*1.5+G*3.1,4),J=l(rt*6+G,R*1.2,b*6,3),nt=l(rt*14,R*9+G,b*14,2),st=Math.pow(1-Math.abs(2*J-1),4),ft=(Y*tt*1.9+Q*2.2)%1,yt=ft<.78?ft/.78:(1-ft)/.22,At=(.6+Q*.7+(J-.5)*.4+(nt-.5)*.1-st*.14+(yt-.5)*.1*(1-Y*.5))*j;return et.set(rt*k*At+(J-.5)*.2*k,Math.max(Y*tt*(.82+Q*.36),0),b*k*At+(Q-.5)*.2*k),1-st*.4-(ft>.78?.22:0)}),V=new Ft(D(H,G),v);return V.castShadow=V.receiveShadow=!0,V}const I=new Qt;I.position.y=r-.35,d.add(I);const F={x:7.2,z:1.05,r:.9,y:r+3.62};i.LAKE=F;function M(k,tt){const G=F.y-(r-.35)+.13,H=w(22,et=>{const rt=et.x,R=et.y,b=et.z,Y=(R+1)/2,j=l(rt*1.5+tt*7.3,R*1.2,b*1.5+tt*3.1,4),Q=l(rt*6+tt,R*1.2,b*6,3),J=l(rt*11,R*11+tt,b*11,2),nt=Math.pow(1-Math.abs(2*Q-1),4),st=(Y*G*1.9+j*2.2)%1,ft=st<.78?st/.78:(1-st)/.22,yt=(1+(j-.5)*.4+(Q-.5)*.25-nt*.1+(ft-.5)*.08)*(1-Y*Y*.12),At=rt*k*yt,at=b*k*yt,Rt=Math.hypot(At,at)/F.r;let X=Math.pow(Y,.75)*G*1.25,mt=1-nt*.4-(st>.78?.22:0);return X>=G&&(X=G+(J-.5)*.14-.55*(1-h(.78,1.02,Rt)),mt=.75+.25*h(.5,1,Rt),at<-.45&&Math.abs(At)<.36&&(X=Math.min(X,G-.2))),et.set(At,Math.max(X,0),at),mt}),V=new Ft(D(H,tt),v);return V.castShadow=V.receiveShadow=!0,V}{const k=M(1.3,11);k.position.set(F.x,0,F.z),I.add(k)}for(const[k,tt,G,H,V]of[[5.7,.95,1.05,6,1],[8.75,.7,.9,5.2,2],[6.05,-.25,.6,4.6,3],[6.4,2.35,.7,4.3,4],[8,2.45,.65,4.1,5],[7.2,2.8,.55,3.6,6],[8.9,-.35,.45,2.4,7],[6.1,-1.75,.38,.7,8]]){const et=P(G,H,V);et.position.set(k,0,tt),et.rotation.y=V*1.7,I.add(et)}const A=[[5.7,.95,.42],[8.75,.7,.36],[6.05,-.25,.3],[6.4,2.35,.3],[8,2.45,.3],[7.2,2.8,.28],[8.9,-.35,.26]];i.BONSAI=A;for(let k=0;k<22;k++){const tt=i.rng()*Math.PI*2,G=2.3+i.rng()*1.2,H=7.2+Math.cos(tt)*G,V=1+Math.sin(tt)*G*.95,et=.1+i.rng()*.22;if(Math.hypot(H,V)>9.5||p(H,V)<.25)continue;const rt=g(et*1.2,et*.75,et,40+k);rt.position.set(H,r+et*.2,V),rt.rotation.y=tt*3,d.add(rt)}for(const[k,tt]of[[155,.3],[185,.24],[212,.2],[20,.3],[-12,.34],[-40,.26],[-62,.2],[48,.22]]){const G=k*Math.PI/180,H=g(tt*1.25,tt*.8,tt,70+k);H.position.set(e[0]+Math.cos(G)*(n+.12),r-.02+tt*.2,e[1]+Math.sin(G)*(n+.12)),H.rotation.y=k,d.add(H)}function K(k,tt,G=[10,40]){const H=document.createElement("canvas");H.width=128,H.height=256;const V=H.getContext("2d");V.fillStyle=`rgba(255,255,255,${tt})`,V.fillRect(0,0,128,256);for(let R=0;R<k;R++)y(V,i.rng()*128,i.rng()*256,1+i.rng()*3,(G[0]+i.rng()*G[1])*1.8,.3+i.rng()*.6);V.globalCompositeOperation="destination-in";const et=V.createLinearGradient(0,0,128,0);et.addColorStop(0,"rgba(0,0,0,0)"),et.addColorStop(.2,"rgba(0,0,0,1)"),et.addColorStop(.8,"rgba(0,0,0,1)"),et.addColorStop(1,"rgba(0,0,0,0)"),V.fillStyle=et,V.fillRect(0,0,128,256);const rt=new Ze(H);return rt.wrapS=Ve,rt.wrapT=yi,rt}const O=K(70,.55,[6,24]),z=K(110,0,[20,60]);i.fallBaseTex=O,i.fallHiTex=z;const S=new De({map:O,vertexColors:!0,transparent:!0,side:be,depthWrite:!1}),E=new De({map:z,color:16777215,transparent:!0,opacity:.85,side:be,depthWrite:!1});s(S),s(E);function g(k,tt,G,H){const V=w(8,rt=>{const R=.72+l(rt.x*1.4+H*5.1,rt.y*1.4+H,rt.z*1.4,3)*.55+(l(rt.x*4+H,rt.y*4,rt.z*4,2)-.5)*.12;rt.set(rt.x*R*k,rt.y*R*tt,rt.z*R*G)}),et=new Ft(D(V,H),v);return et.castShadow=et.receiveShadow=!0,et}for(const[k,tt,G,H,V,et,rt]of[[7.2,2.4,-.1,1,.9,.9,21],[7.05,2.25,-.1,1.1,.85,.95,22],[7.35,1.5,-.6,1.15,.85,1,23],[7.1,.75,-1.05,1.3,.8,1,24],[7.4,.12,-1.45,1.15,.5,.8,25],[6.45,1.3,-.45,.8,1.15,.8,26],[7.95,1.6,-.3,.8,1.2,.8,27]]){const R=g(H,V,et,rt);R.position.set(k,tt+.35,G),R.rotation.y=rt*.9,I.add(R)}const T=I.children.slice();i.rockMeshes=T;function L({x:k,w0:tt,w1:G,yTop:H,rows:V=30,cols:et=8,seed:rt=0}){d.updateMatrixWorld(!0);const R=new Gr,b=new W(0,0,1),Y=[];for(let _t=0;_t<=V;_t++){const $=_t/V,vt=r+H+(o-r+.03-H)*$,bt=tt+(G-tt)*Math.pow($,.8),Ut=[];for(let It=0;It<=et;It++){const Wt=It/et,Zt=k+(Wt-.5)*bt+Math.sin($*6+rt)*.07*$;R.set(new W(Zt,vt,-6),b);const he=R.intersectObjects(T,!1)[0];Ut.push(he?new W(Zt,vt,he.point.z-.07):new W(Zt,vt,NaN))}Y.push(Ut)}for(let _t=0;_t<=V;_t++)for(let $=0;$<=et;$++)if(isNaN(Y[_t][$].z)){let vt=NaN;for(let bt=1;bt<=et&&isNaN(vt);bt++)for(const Ut of[$-bt,$+bt])if(Y[_t][Ut]&&!isNaN(Y[_t][Ut].z)){vt=Y[_t][Ut].z;break}isNaN(vt)&&_t&&(vt=Y[_t-1][$].z),Y[_t][$].z=isNaN(vt)?0:vt}const j=Y.map(_t=>_t.map($=>$.z));for(let _t=0;_t<7;_t++){const $=Y.map(vt=>vt.map(bt=>bt.z));for(let vt=1;vt<V;vt++)for(let bt=0;bt<=et;bt++){const Ut=[$[vt-1][bt],$[vt+1][bt],$[vt][Math.max(0,bt-1)],$[vt][Math.min(et,bt+1)],$[vt][bt]*2];Y[vt][bt].z=Math.min(Ut.reduce((It,Wt)=>It+Wt,0)/6,j[vt][bt])}}Y.push(Y[V].map(_t=>new W(_t.x+(_t.x-k)*.3,o+.005,_t.z-.35)));const Q=[],J=[],nt=[],st=[],ft=new Dt(8178154),yt=new Dt(16055295),At=new Dt,at=new Array(et+1).fill(0),Rt=[];Y.forEach((_t,$)=>_t.forEach((vt,bt)=>{if($){const Zt=Y[$-1][bt];at[bt]+=vt.distanceTo(Zt)}const Ut=Y[Math.max(0,$-1)][bt],It=Y[Math.min(Y.length-1,$+1)][bt],Wt=Math.min(1,Math.abs(It.y-Ut.y)/(It.distanceTo(Ut)+1e-4));At.copy(ft).lerp(yt,Math.pow(Wt,1.5)*.85+($===Y.length-1?.5:0)),Q.push(vt.x,vt.y,vt.z-Wt*Wt*.12),J.push(bt/et,at[bt]/1.4),nt.push(At.r,At.g,At.b),Rt.push(Math.pow(Wt,1.5)+($===Y.length-1?.6:0))}));const X=et+1;for(let _t=0;_t<Y.length-1;_t++)for(let $=0;$<et;$++){const vt=_t*X+$;st.push(vt,vt+X,vt+1,vt+1,vt+X,vt+X+1)}const mt=new Jt;mt.setAttribute("position",new Nt(Q,3)),mt.setAttribute("uv",new Nt(J,2)),mt.setAttribute("aWhite",new Nt(Rt,1)),mt.setIndex(st);const Tt=new Ft(mt,a(1,1));Tt.renderOrder=2,d.add(Tt);const St=et>>1,Pt=_t=>{const $=Y[Math.max(0,_t-2)][St],vt=Y[Math.min(Y.length-1,_t+2)][St];return Math.abs(vt.y-$.y)/(vt.distanceTo($)+1e-4)},zt=[];for(let _t=4;_t<V-5;_t++)Pt(_t-2)>.8&&Pt(_t+2)<.64&&(!zt.length||_t-zt.at(-1).r>6)&&zt.push({r:_t,x:Y[_t][St].x,y:Y[_t][St].y,z:Y[_t][St].z-.12});const kt=Y[V],Ht=Y[0];return{bx:k,bz:kt.reduce((_t,$)=>_t+$.z,0)/kt.length,tz:Ht.reduce((_t,$)=>_t+$.z,0)/Ht.length,ledges:zt}}const C=L({x:7.2,w0:.7,w1:1.5,yTop:3.6-.22,rows:48,cols:10,seed:1});i.mainFall=C;const U=new Ft(new Wn(.7,.9),m);U.rotation.x=-Math.PI/2,U.position.set(7.2,F.y,C.tz+.5),_.uImpact.value.set(C.bx,C.bz-.3);{const k=C.tz,tt=F.r+.05,G=Math.asin(.42/tt),H=48,V=[F.x,F.y,F.z],et=[1],rt=[],R=[];for(let at=0;at<=H;at++){const Rt=-Math.PI/2+G+(2*Math.PI-2*G)*at/H;R.push([F.x+Math.cos(Rt)*tt,F.z+Math.sin(Rt)*tt,0])}R.push([7.2-.4,k+.34,0],[7.2-.35,k+.1,.45],[7.2+.35,k+.1,.45],[7.2+.4,k+.34,0]),R.forEach(([at,Rt,X],mt)=>{V.push(at,F.y,Rt),et.push(X),rt.push(0,1+(mt+1)%R.length,1+mt)});const b=new Jt;b.setAttribute("position",new Nt(V,3)),b.setAttribute("aEdge",new Nt(et,1)),b.setAttribute("uv",new Nt(V.filter((at,Rt)=>Rt%3!==1).map(at=>at*.5),2)),b.setIndex(rt),b.computeVertexNormals();const Y=new Ft(b,c);Y.renderOrder=1,d.add(Y),_.uOut.value.set(7.2,k+.1);const j=[[k+.34,0,.39,0],[k+.18,-.006,.365,.1],[k+.06,-.035,.35,.3],[k-.03,-.11,.345,.55],[k-.07,-.2,.35,.75],[k-.085,-.31,.36,.85]],Q=[],J=[],nt=[],st=[];let ft=0;j.forEach(([at,Rt,X,mt],Tt)=>{Tt&&(ft+=Math.hypot(at-j[Tt-1][0],Rt-j[Tt-1][1]));for(const St of[0,1])Q.push(7.2+(St-.5)*2*X,F.y+Rt+.006,at),J.push(St,ft/1),nt.push(mt);Tt&&st.push((Tt-1)*2,Tt*2,(Tt-1)*2+1,(Tt-1)*2+1,Tt*2,Tt*2+1)});const yt=new Jt;yt.setAttribute("position",new Nt(Q,3)),yt.setAttribute("uv",new Nt(J,2)),yt.setAttribute("aWhite",new Nt(nt,1)),yt.setIndex(st);const At=new Ft(yt,a(1,1,0,.22));At.renderOrder=3,d.add(At);for(const[at,Rt,X,mt,Tt,St]of[[-.52,.12,.24,.3,.26,101],[.5,.1,.22,.34,.24,102],[-.5,.42,.16,.16,.2,103],[.52,.4,.17,.2,.18,104],[-.2,.02,.07,.05,.08,105]]){const Pt=g(X,mt,Tt,St);Pt.position.set(7.2+at,F.y+(St===105?-.06:0),k+Rt),Pt.rotation.y=St,d.add(Pt)}for(const[at,Rt,X]of[[2.4,.5,.1],[4.1,.62,.07],[.6,.66,.08]]){const mt=g(X*1.3,X,X*1.1,90+at*10);mt.position.set(F.x+Math.cos(at)*Rt,F.y-.02,F.z+Math.sin(at)*Rt),d.add(mt)}for(const[at,Rt]of[[1.2,.45],[3.3,.3],[5.2,.5]]){const X=u(new qt(.11,.11,.012,9),t(5212746),F.x+Math.cos(at)*Rt,F.y+.012,F.z+Math.sin(at)*Rt);X.castShadow=!1,d.add(X)}}const q=(()=>{d.updateMatrixWorld(!0);const k=new Gr,tt=new W(-1,0,0),G=14,H=[],V=[],et=[],rt=[];let R=F.x-F.r,b=0,Y=null,j=null;for(let nt=0;nt<=G;nt++){const st=F.y+1.75*(1-nt/G);k.set(new W(F.x,st,F.z+.1),tt);const ft=k.intersectObjects(T,!1)[0];if(!ft&&!Y)continue;const yt=Math.min(ft?ft.point.x+.06:R,Y?Y[0]+.25:99),At=H.length/6;R=yt,Y&&(b+=Math.hypot(yt-Y[0],st-Y[1])),Y=[yt,st],j||(j=[yt,st]);for(const at of[0,1])H.push(yt,st,F.z+.1+(at-.5)*(.1+.26*nt/G)),V.push(at,b/1.1),et.push(At?nt>=G-1?.85:.3:.9);At&&rt.push((At-1)*2,(At-1)*2+1,At*2,(At-1)*2+1,At*2+1,At*2)}const Q=new Jt;Q.setAttribute("position",new Nt(H,3)),Q.setAttribute("uv",new Nt(V,2)),Q.setAttribute("aWhite",new Nt(et,1)),Q.setIndex(rt);const J=new Ft(Q,a(1,1));if(J.renderOrder=2,d.add(J),j){const[nt,st]=j,ft=F.z+.1,yt=new Ft(new ne(.15,14,10),new De({color:461321}));yt.scale.set(.55,.9,1.05),yt.position.set(nt-.04,st+.03,ft),d.add(yt);for(const[At,at,Rt,X,mt,Tt,St]of[[0,.2,0,.2,.12,.26,111],[.02,-.02,.19,.11,.17,.11,112],[.02,-.03,-.19,.11,.16,.12,113],[.08,-.2,.02,.16,.07,.2,114]]){const Pt=g(X,mt,Tt,St);Pt.position.set(nt+At,st+at,ft+Rt),Pt.rotation.y=St,d.add(Pt)}}{const nt=Y?Y[0]:R,st=F.z+.1;_.uIn.value.set(nt+.12,st);for(const[ft,yt,At]of[[.27,.09,121],[-.26,.08,122]]){const at=g(yt*1.2,yt*.9,yt,At);at.position.set(nt+.08,F.y,st+ft),d.add(at)}}return{x:(Y?Y[0]:R)+.14,y:F.y+.02,z:F.z+.1,src:j&&{x:j[0],y:j[1],z:F.z+.1}}})();i.feeder=q;const Z=new Qt;i.foam=Z,d.add(Z);for(const k of[{x:C.bx,y:o+.03,z:C.bz-.3,s:1,n:22},...C.ledges.map(tt=>({...tt,s:.5,n:5})),{...q,s:.42,n:9},{x:7.2,y:F.y-.24,z:C.tz-.14,s:.38,n:6},...q.src?[{x:q.src.x+.1,y:q.src.y-.12,z:q.src.z,s:.2,n:3}]:[]])for(let tt=0;tt<k.n;tt++){const G=new zr(s(new Yi({map:f,color:16777215,transparent:!0,opacity:.5,depthWrite:!1})));G.userData={ph:i.rng(),x:k.x+(i.rng()-.5)*1.2*k.s,y:k.y,z:k.z+(i.rng()-.5)*.35,s:k.s*(.7+i.rng()*.6)},G.renderOrder=4,Z.add(G)}const it=160,ut=new Float32Array(it*3),gt=[];for(let k=0;k<it;k++){const tt=1.1+i.rng()*1.9;gt.push({ph:i.rng(),a:i.rng()*Math.PI*2,sp:.3+i.rng()*.9,up:tt,life:tt/4.5,ox:(i.rng()-.5)*1.1})}const xt=new Jt;xt.setAttribute("position",new fe(ut,3));const Et=(()=>{const k=document.createElement("canvas");k.width=k.height=32;const tt=k.getContext("2d"),G=tt.createRadialGradient(16,16,0,16,16,16);return G.addColorStop(0,"rgba(255,255,255,1)"),G.addColorStop(1,"rgba(255,255,255,0)"),tt.fillStyle=G,tt.fillRect(0,0,32,32),new Ze(k)})(),lt=new so(xt,s(new Wr({map:Et,size:.055,color:16777215,transparent:!0,opacity:.6,depthWrite:!1})));lt.frustumCulled=!1,lt.renderOrder=4,d.add(lt);const ct=[[5.9,5,.9],[8.6,4.3,.8],[7.2,3.9,1.2],[6.2,2.6,2.4],[8.4,2.6,2.5],[7.3,4.3,2.2]].map(([k,tt,G],H)=>{const V=new zr(s(new Yi({map:f,color:16777215,transparent:!0,opacity:.3,depthWrite:!1})));return V.userData={x:k,y:r+tt,z:G,ph:H*1.7},V.scale.set(3.4,1.5,1),d.add(V),V});function Mt(k){for(let tt=0;tt<it;tt++){const G=gt[tt],H=(k/G.life*.6+G.ph)%1*G.life;ut[tt*3]=C.bx+G.ox+Math.cos(G.a)*G.sp*H,ut[tt*3+1]=o+.04+G.up*H-4.5*H*H,ut[tt*3+2]=C.bz-.3+Math.sin(G.a)*G.sp*H*.6-H*.5}xt.attributes.position.needsUpdate=!0;for(const tt of ct){const G=tt.userData;tt.position.set(G.x+Math.sin(k*.06+G.ph)*1.3,G.y+Math.sin(k*.11+G.ph*2)*.2,G.z+Math.cos(k*.05+G.ph)*.9),tt.material.opacity=.2+.12*Math.sin(k*.09+G.ph*3)}}}function f0(i){const{M:t,MAT:e,R:n,RIVER:r,RIVER_EDGES:s,TOP:o,WY:a,boulder:l,mesh:c,scene:u}=i;{const d=new en(r.map(h=>new W(h.x,0,h.y)));for(const[h,y,_]of[[.15,.55,.16],[.26,-.6,.12],[.42,.5,.14],[.73,-.55,.15],[.86,.4,.12]]){const w=d.getPointAt(h),D=d.getTangentAt(h),P=l(_*1.25,_*.85,_*1.25,h*37);P.position.set(w.x-D.z*y,a+.01,w.z+D.x*y),P.rotation.y=h*20,u.add(P)}}{const d=s.at(-1).w,h=-n;for(const _ of[-1,1])for(const[w,D,P,I,F,M]of[[.26,o+.1,d+.3,.36,.25,.32],[.2,o+.38,d+.34,.25,.18,.23],[.25,o+.61,d+.3,.15,.12,.15],[.1,o-.1,d+.03,.21,.2,.2],[.55,o+.02,d+.26,.21,.14,.23],[.32,o+.06,d+.78,.19,.13,.21],[.62,o+.22,d+.3,.13,.1,.13],[-.04,o-.48,d+.14,.23,.3,.22],[0,o-1,d-.04,.19,.24,.2]]){const A=l(I,F,M,130+w*40+D*7+_*3);A.position.set(h+w,D,_*P),A.rotation.y=(w+D)*9*_,u.add(A)}const y=(_,w,D,P,I,F)=>{for(let M=0;M<_;M++){const A=_>1?M/(_-1):.5,K=(A*2-1)*I+Math.sin(M*2.3+F)*.05,O=P*(.85+.3*Math.abs(Math.sin(M*1.7+F))),z=l(O*1.15,O*.8,O*1.05,F+M);z.position.set(h+w+Math.sin(M*3.1+F)*.05,D+(O-P)*.4,K),z.rotation.y=M*1.9+F,u.add(z)}};y(6,.14,a+.02,.25,d-.08,150),y(5,.2,a+.27,.2,d-.28,160),y(3,.17,a+.46,.15,d-.62,170),y(4,.46,a-.02,.13,d-.2,180)}const f=new en(r.map(d=>new W(d.x,o+.02,d.y)));i.riverCurve=f;const m=t(5212746),p=t(16033472),v=[];i.lotus=v;for(const[d,h]of[[.12,.5],[.2,-.55],[.34,.45],[.47,-.5],[.6,.55],[.68,-.45],[.8,.5]]){const y=f.getPointAt(d),_=f.getTangentAt(d),w=new W(-_.z,0,_.x).multiplyScalar(h),D=c(new qt(.24,.24,.02,9),m,y.x+w.x,a+.03,y.z+w.z);if(u.add(D),v.push(D),d*10%2<1){const P=new Qt;P.position.set(y.x+w.x,a+.05,y.z+w.z);for(let I=0;I<11;I++){const F=I>=7,M=I/(F?4:7)*Math.PI*2+(F?.4:0),A=new Qt;A.rotation.y=M;const K=c(new ne(.05,8,6),p,F?.025:.05,F?.06:.04,0);K.scale.set(.55,1.15,.32),K.rotation.z=F?-.25:-.75,A.add(K),P.add(A)}P.add(c(new ne(.022,8,6),e.gold,0,.05,0)),u.add(P),v.push(P)}}const x=[16742959,16777215,16731453,16763210,3354670].map((d,h)=>{const y=new Qt;y.add(new Ft(new ne(.1,14,10),t(d,{emissive:d,emissiveIntensity:.05,flatShading:!1,roughness:.35,d:{s:[30,30,30],bump:0,vary:.2}})).translateZ(0)),y.children[0].scale.set(1,.6,2.6);const _=new Ft(new Fe(.08,.2,4),t(d));return _.rotation.x=Math.PI/2,_.position.z=-.32,y.add(_),y.userData={u:h/5,side:(h-2)*.2,speed:.011+h%3*.003,tail:_,jt:-1},u.add(y),y});i.koi=x}function p0(i){const{M:t,MAT:e,box:n,fit:r,lanternMat:s,mesh:o}=i;i.curvedRoof=v,i.dougong=y,i.hexRoof=_,i.column=w,i.lattice=D,i.door=P,i.plaque=F,i.steps=M,i.railing=A,i.hangLantern=K,i.windBell=O,i.stoneLantern=z,i.urn=S,i.spire=E,Object.assign(e,{woodDark:t(5710619,{roughness:.6,d:{s:[16,5,16],bump:.004,vary:.14}}),stoneDark:t(8616553,{roughness:.92,d:{s:[5,5,5],bump:.025,vary:.22}}),tileTrim:t(2046518,{roughness:.5}),leather:t(14732704,{roughness:.7}),cushion:t(10828328,{roughness:.95}),jade:t(4165483,{roughness:.25}),bronze:t(8018992,{metalness:.8,roughness:.4}),bamboo:t(12755029,{roughness:.6,d:{s:[.5,55,.5],bump:.006,vary:.3}}),ceramic:t(14937320,{roughness:.18,d:!1}),flag:new Be({color:14723374,side:be,roughness:.9})});const a=[];i.windowMats=a;const l=()=>{const g=t(16115396,{emissive:16757069,emissiveIntensity:.1,d:!1});return a.push(g),g},c=(g,T,L=0,N=0,C=0)=>{const U=new Ft(g,r(g,T));return U.position.set(L,N,C),U};i.dm=c;const u=(g,T,L,N,C,U,q)=>c(new $e(g,T,L),N,C,U,q);i.dbox=u;const[f,m]=(()=>{const g=()=>{const it=document.createElement("canvas");return it.width=it.height=256,[it,it.getContext("2d")]},[T,L]=g(),[N,C]=g(),U=32,q=64;for(let it=0;it<4;it++)for(let ut=0;ut<8;ut++){const gt=ut*U,xt=it*q,Et=(i.rng()-.5)*14,lt=tt=>`rgb(${38+Et+tt*30|0},${78+Et+tt*42|0},${72+Et+tt*38|0})`,ct=L.createLinearGradient(gt,0,gt+U,0);ct.addColorStop(0,lt(-.75)),ct.addColorStop(.22,lt(0)),ct.addColorStop(.5,lt(.55)),ct.addColorStop(.78,lt(0)),ct.addColorStop(1,lt(-.75)),L.fillStyle=ct,L.fillRect(gt,xt,U,q),L.fillStyle="rgba(0,0,0,.28)",L.fillRect(gt,xt,U,3),L.fillStyle="rgba(255,255,255,.08)",L.fillRect(gt+6,xt+3,U-12,2);const Mt=C.createLinearGradient(gt,0,gt+U,0);Mt.addColorStop(0,"#000"),Mt.addColorStop(.5,"#fff"),Mt.addColorStop(1,"#000"),C.fillStyle=Mt,C.fillRect(gt,xt,U,q),C.fillStyle="rgba(0,0,0,.5)",C.fillRect(gt,xt,U,4);const k=C.createLinearGradient(0,xt,0,xt+q);k.addColorStop(0,"rgba(0,0,0,.25)"),k.addColorStop(1,"rgba(0,0,0,0)"),C.fillStyle=k,C.fillRect(gt,xt,U,q)}for(let it=0;it<260;it++)L.fillStyle=`rgba(${i.rng()<.5?"20,30,24":"120,140,110"},${i.rng()*.12})`,L.fillRect(i.rng()*256,i.rng()*256,2+i.rng()*10,6+i.rng()*40);const Z=(it,ut)=>{const gt=new Ze(it);return gt.wrapS=gt.wrapT=yi,ut&&(gt.colorSpace=ce),gt.anisotropy=8,gt};return[Z(T,!0),Z(N,!1)]})(),p=(g,T)=>{const L=f.clone(),N=m.clone();return L.needsUpdate=N.needsUpdate=!0,L.repeat.set(g,T),N.repeat.set(g,T),new Be({map:L,bumpMap:N,bumpScale:1.6,roughness:.5,side:be})};function v(g,T,L,N=.3,C=22){const U=new Wn(g*2,T*2,C,C);U.rotateX(-Math.PI/2);const q=U.attributes.position,Z=Math.max(g-T,0),it=(tt,G)=>{const H=Math.min(1,Math.max(Math.max(Math.abs(tt)-Z,0)/T,Math.abs(G)/T)),V=Math.abs(tt)/g,et=Math.abs(G)/T;return L*Math.pow(1-H,1.6)+N*Math.pow(V*et,5)+N*.25*Math.pow(H,5)};for(let tt=0;tt<q.count;tt++)q.setY(tt,it(q.getX(tt),q.getZ(tt)));U.computeVertexNormals();const ut=new Qt,gt=new Ft(U,p(g*1.4,T*1.4));gt.castShadow=gt.receiveShadow=!0,ut.add(gt);for(const[tt,G]of[[1,1],[1,-1],[-1,1],[-1,-1]]){const H=[];for(let V=0;V<=14;V++){const et=V/14,rt=tt*(g+(Z-g)*et),R=G*T*(1-et);H.push(new W(rt,it(rt*.999,R*.999)+.035,R))}ut.add(c(new gi(new en(H),16,.035,5),e.tileTrim))}const xt=[],Et=10;for(const[tt,G,H,V]of[[g,T,-g,T],[-g,T,-g,-T],[-g,-T,g,-T],[g,-T,g,T]])for(let et=0;et<Et;et++){const rt=et/Et,R=(tt+(H-tt)*rt)*.995,b=(G+(V-G)*rt)*.995;xt.push(new W(R,it(R,b)-.01,b))}if(ut.add(c(new gi(new en(xt,!0),80,.028,4,!0),e.woodDark)),Z>.05){ut.add(u(Z*2+.25,.09,.11,e.tileTrim,0,L+.03,0));for(const tt of[-1,1]){const G=c(new Fe(.05,.22,5),e.tileTrim,tt*(Z+.14),L+.13,0);G.rotation.z=-tt*.5,ut.add(G)}}for(const[tt,G]of[[1,1],[1,-1],[-1,1],[-1,-1]]){const H=c(new Fe(.05,.3,5),e.tileTrim,tt*g,N*1.25+.08,G*T);H.rotation.set(G*.6,0,-tt*.6),ut.add(H)}ut.userData.corners=[[g,T],[g,-T],[-g,T],[-g,-T]].map(([tt,G])=>[tt,N*1.25,G]);const lt=new Ft(U,h);lt.position.y=-.03,ut.add(lt);const ct=new d,Mt=new d,k=(tt,G,H)=>new W(tt,it(tt,G)+H,G);for(const[tt,G,H,V,et,rt]of[[-g,T,g,T,0,1],[g,T,g,-T,1,0],[g,-T,-g,-T,0,-1],[-g,-T,-g,T,-1,0]]){const R=Math.hypot(H-tt,V-G),b=Math.round(R/.17),Y=Math.min(g,T)*.5,j=Math.round(R/.1);for(let Q=1;Q<b;Q++){const J=Q/b,nt=(tt+(H-tt)*J)*.97,st=(G+(V-G)*J)*.97;for(const[ft,yt]of[[1,.62],[.62,.3],[.3,0]])ct.beam(k(nt-et*Y*ft,st-rt*Y*ft,-.06),k(nt-et*Y*yt,st-rt*Y*yt,-.06),.035,.045)}for(let Q=0;Q<j;Q++){const J=Q/j,nt=tt+(H-tt)*J,st=G+(V-G)*J;Mt.put(new qt(.032,.032,.03,8),nt,it(nt*.995,st*.995)+.012,st,Math.atan2(et,rt),Math.PI/2)}}return ut.add(ct.mesh(e.woodDark,!1),Mt.mesh(e.tileTrim,!1)),ut}const x=new ue;class d{constructor(){xo(this,"list");this.list=[]}put(T,L,N,C,U=0,q=0){return x.position.set(L,N,C),x.rotation.set(q,U,0,"YXZ"),x.updateMatrix(),T.applyMatrix4(x.matrix),this.list.push(T),this}box(T,L,N,C,U,q,Z=0){return this.put(new $e(T,L,N),C,U,q,Z)}beam(T,L,N,C){const U=new $e(N,C,T.distanceTo(L));return x.position.copy(T).add(L).multiplyScalar(.5),x.lookAt(L),x.updateMatrix(),U.applyMatrix4(x.matrix),this.list.push(U),this}mesh(T,L=!0){if(!this.list.length)return new Qt;const N=new Ft(u0(this.list),T);return N.castShadow=L,N.receiveShadow=!0,N}}i.Batch=d;const h=t(5907484,{side:Te,flatShading:!1,roughness:.7});function y(g,T,L,N,C,U,q=1){const Z=Math.cos(U),it=Math.sin(U),ut=(gt,xt,Et,lt,ct,Mt,k)=>gt.box(xt*q,Et*q,lt*q,L+(ct*Z+k*it)*q,N+Mt*q,C+(-ct*it+k*Z)*q,U);ut(T,.1,.05,.1,0,.025,.02),ut(g,.3,.045,.055,0,.072,.02),ut(g,.055,.045,.3,0,.072,.1);for(const gt of[-.125,.125])ut(T,.06,.035,.06,gt,.112,.02);ut(T,.06,.035,.06,0,.112,.22),ut(g,.4,.04,.05,0,.15,.22),ut(g,.05,.04,.36,0,.15,.12)}function _(g,T,L=.35,N=10,C=48){const U=[],q=[],Z=[],it=Math.cos(Math.PI/6),ut=Math.PI/3;for(let H=0;H<=N;H++){const V=H/N;for(let et=0;et<=C;et++){const rt=et/C*Math.PI*2,R=it/Math.cos((rt%ut+ut)%ut-ut/2),b=Math.pow((R-it)/(1-it),3);U.push(Math.cos(rt)*V*g*R,T*Math.pow(1-V,1.6)+L*Math.pow(V,4)*b+L*.2*Math.pow(V,5),Math.sin(rt)*V*g*R),q.push(et/C*10,V*3)}}for(let H=0;H<N;H++)for(let V=0;V<C;V++){const et=H*(C+1)+V,rt=et+C+1;Z.push(et,rt,et+1,rt,rt+1,et+1)}const gt=new Jt;gt.setAttribute("position",new Nt(U,3)),gt.setAttribute("uv",new Nt(q,2)),gt.setIndex(Z),gt.computeVertexNormals();const xt=new Qt,Et=new Ft(gt,p(1,1));Et.castShadow=!0,xt.add(Et);const lt=H=>T*Math.pow(1-H,1.6)+L*Math.pow(H,4)+L*.2*Math.pow(H,5);for(let H=0;H<6;H++){const V=H*ut,et=[];for(let rt=0;rt<=12;rt++){const R=1-rt/12;et.push(new W(Math.cos(V)*R*g,lt(R)+.035,Math.sin(V)*R*g))}xt.add(c(new gi(new en(et),14,.035,5),e.tileTrim))}const ct=[];for(let H=0;H<C;H++){const V=(N+0)*(C+1)+H;ct.push(new W(U[V*3]*.995,U[V*3+1]-.01,U[V*3+2]*.995))}xt.add(c(new gi(new en(ct,!0),96,.028,4,!0),e.woodDark));const Mt=(H,V,et)=>{const rt=it/Math.cos((H%ut+ut)%ut-ut/2),R=Math.pow((rt-it)/(1-it),3);return new W(Math.cos(H)*V*g*rt,T*Math.pow(1-V,1.6)+L*Math.pow(V,4)*R+L*.2*Math.pow(V,5)+et,Math.sin(H)*V*g*rt)},k=new d,tt=new d;for(let H=0;H<42;H++){const V=(H+.5)/42*Math.PI*2;for(const[et,rt]of[[.55,.72],[.72,.86],[.86,.97]])k.beam(Mt(V,et,-.06),Mt(V,rt,-.06),.035,.045)}for(let H=0;H<110;H++){const V=H/110*Math.PI*2,et=Mt(V,1,.012);tt.put(new qt(.032,.032,.03,8),et.x,et.y,et.z,Math.atan2(et.x,et.z),Math.PI/2)}const G=new Ft(gt,h);G.position.y=-.03,xt.add(G,k.mesh(e.woodDark,!1),tt.mesh(e.tileTrim,!1)),xt.userData.corners=[];for(let H=0;H<6;H++){const V=H*ut,et=new Qt;et.position.set(Math.cos(V)*g,L*1.2+.06,Math.sin(V)*g),et.rotation.y=-V;const rt=c(new Fe(.05,.3,5),e.tileTrim);rt.rotation.z=-.6,et.add(rt),xt.add(et),xt.userData.corners.push([Math.cos(V)*g,L*1.2,Math.sin(V)*g])}return xt}function w(g,T,L,N,C=0,U=.08){g.add(c(new qt(U*1.9,U*2.2,.1,8),e.stoneDark,T,C+.05,L)),g.add(o(new qt(U,U*1.1,N,8),e.wood,T,C+.1+N/2,L)),g.add(u(U*2.6,.07,U*2.6,e.woodDark,T,C+.07+N,L))}function D(g,T){const L=new Qt;L.add(u(g,T,.03,l(),0,0,0)),L.add(u(g+.08,.05,.06,e.woodDark,0,T/2,0),u(g+.08,.05,.06,e.woodDark,0,-T/2,0),u(.05,T,.06,e.woodDark,g/2,0,0),u(.05,T,.06,e.woodDark,-g/2,0,0));for(let N=1;N<4;N++)L.add(u(.022,T,.045,e.woodDark,-g/2+g*N/4,0,0));for(let N=1;N<3;N++)L.add(u(g,.022,.045,e.woodDark,0,-T/2+T*N/3,0));return L}function P(g,T){const L=new Qt;L.add(u(g+.12,T+.1,.04,e.woodDark,0,0,0));for(const N of[-1,1])L.add(u(g/2-.02,T,.05,e.wood,N*g/4,0,.015)),L.add(u(g/2-.14,T*.32,.02,e.woodDark,N*g/4,T*.2,.045),u(g/2-.14,T*.32,.02,e.woodDark,N*g/4,-T*.2,.045)),L.add(c(new ne(.025,6,4),e.gold,N*.05,0,.055));return L}const I=[];function F(g,T=1.1){const L=document.createElement("canvas");L.width=512,L.height=128;const N=()=>{const q=L.getContext("2d");q.fillStyle="#7a1d16",q.fillRect(0,0,512,128),q.strokeStyle="#d9a441",q.lineWidth=10,q.strokeRect(8,8,496,112),q.lineWidth=3,q.strokeRect(22,22,468,84),q.fillStyle="#f1c45c",q.font='700 50px "Gelasio", Georgia, serif',q.textAlign="center",q.textBaseline="middle",q.fillText(g,256,68)};N();const C=new Ze(L);C.colorSpace=ce,I.push([N,C]);const U=e.woodDark;return new Ft(new $e(T,T/4,.04),[U,U,U,U,new Be({map:C,roughness:.6}),U])}document.fonts?.load('700 50px "Gelasio"',"ĐƯỜNGÀỊ").then(()=>I.forEach(([g,T])=>{g(),T.needsUpdate=!0}));function M(g,T,L,N,C,U,q=e.stone){for(let Z=0;Z<L;Z++)g.add(n(T,N*(L-Z),C,q,0,N*(L-Z)/2,U+Z*C+C/2))}function A(g,T,L,N,C,U,q=.3,Z=4){const it=Math.hypot(N-T,C-L),ut=Math.atan2(N-T,C-L),gt=(T+N)/2,xt=(L+C)/2;for(const[Et,lt]of[[q,.05],[q*.45,.03]]){const ct=u(lt,lt,it,e.woodDark,gt,U+Et,xt);ct.rotation.y=ut,g.add(ct)}for(let Et=0;Et<=Z;Et++){const lt=Et/Z;g.add(u(.055,q,.055,e.woodDark,T+(N-T)*lt,U+q/2,L+(C-L)*lt))}}function K(g,T,L,N,C=1){g.add(c(new qt(.006,.006,.14*C,3),e.trunk,T,L-.07*C,N));const U=c(new ne(.1*C,10,8),s(),T,L-.24*C,N);U.scale.y=1.25,g.add(U),g.add(c(new qt(.05*C,.05*C,.03,8),e.gold,T,L-.12*C,N),c(new qt(.05*C,.05*C,.03,8),e.gold,T,L-.37*C,N)),g.add(c(new qt(.008,.008,.12*C,3),e.cushion,T,L-.44*C,N))}function O(g,T,L,N){g.add(c(new qt(.005,.005,.12,3),e.trunk,T,L-.06,N),c(new qt(.025,.05,.08,8),e.gold,T,L-.15,N))}function z(g,T,L,N=1){const C=new Qt;C.position.set(T,0,L),C.scale.setScalar(N);const U=c(new Fe(.24,.18,4),e.stone,0,.86,0);U.rotation.y=Math.PI/4,C.add(c(new qt(.18,.22,.1,6),e.stoneDark,0,.05,0),c(new qt(.06,.07,.45,6),e.stone,0,.32,0),u(.26,.06,.26,e.stone,0,.57,0),u(.16,.16,.16,s(),0,.68,0),U,c(new ne(.04,6,4),e.stone,0,.97,0)),C.children.forEach(q=>q.castShadow=!0),g.add(C)}function S(g,T,L){const N=new Qt;N.position.set(T,0,L),N.add(c(new qt(.22,.16,.22,10),e.bronze,0,.28,0),c(new Ei(.22,.02,5,14),e.bronze,0,.39,0),c(new qt(.12,.19,.12,10),e.bronze,0,.46,0),c(new ne(.05,6,4),e.gold,0,.55,0)),N.children[1].rotation.x=Math.PI/2;for(let C=0;C<3;C++){const U=C/3*Math.PI*2;N.add(c(new qt(.025,.02,.2,5),e.bronze,Math.cos(U)*.13,.1,Math.sin(U)*.13))}for(const C of[-1,1]){const U=c(new Ei(.05,.015,4,8,Math.PI),e.bronze,C*.24,.38,0);U.rotation.y=Math.PI/2,N.add(U)}g.add(N)}function E(g,T){g.add(c(new qt(.05,.07,.22,8),e.gold,0,T+.11,0));for(let L=0;L<3;L++)g.add(c(new qt(.15-L*.035,.15-L*.035,.035,12),e.gold,0,T+.28+L*.13,0));return g.add(c(new ne(.07,10,8),e.gold,0,T+.7,0),c(new Fe(.03,.14,6),e.gold,0,T+.82,0)),T+.9}}function m0(i){const{Batch:t,MAT:e,box:n,column:r,curvedRoof:s,dbox:o,dm:a,door:l,dougong:c,hangLantern:u,lattice:f,mesh:m,plaque:p,stoneLantern:v}=i;i.kieuLau=x;function x(){const d=new Qt,h=5.8,y=1,_=1.4,w=16,D=E=>y*(1-(2*E/h)**2);for(let E=0;E<w;E++){const g=-h/2+E*h/w,T=g+h/w,L=(g+T)/2,N=D(g),C=D(T),U=Math.hypot(T-g,C-N),q=Math.atan2(C-N,T-g),Z=n(_,.14,U+.02,e.wood,0,(N+C)/2,L);Z.rotation.x=-q,d.add(Z);for(const it of[-1,1]){if(Math.abs(L)>1.05)for(const[ut,gt]of[[.5,.07],[.25,.04]]){const xt=o(gt,gt,U+.02,e.woodDark,it*(_/2-.04),(N+C)/2+ut,L);xt.rotation.x=-q,d.add(xt)}d.add(o(.08,.55,.08,e.woodDark,it*(_/2-.04),N+.28,g)),d.add(a(new ne(.05,6,4),e.gold,it*(_/2-.04),N+.58,g))}}for(const E of[-1,1]){d.add(n(_+.5,.35,.9,e.stone,0,.17,E*(h/2+.2)));for(const g of[-1,1])v(d,g*1.3,E*(h/2+.3),.85)}for(const E of[-1,1])for(let g=0;g<w;g++){const T=-h/2+g*h/w,L=T+h/w,N=D(T)-.2,C=D(L)-.2,U=n(.12,.14,Math.hypot(L-T,C-N)+.02,e.trunk,E*(_/2-.1),(N+C)/2,(T+L)/2);U.rotation.x=-Math.atan2(C-N,L-T),d.add(U)}const P=y+.07;d.add(n(_+.35,.1,2.2,e.woodDark,0,P,0));for(const[E,g]of[[-.8,-1.02],[.8,-1.02],[-.8,1.02],[.8,1.02]])r(d,E,g,1.05,P,.065);d.add(n(1.4,1,1.8,e.paper,0,P+.55,0)),d.add(o(1.44,.1,1.84,e.wood,0,P+.1,0),o(1.75,.09,2.2,e.wood,0,P+1.1,0));for(const E of[-1,1])for(const g of[-.45,.45]){const T=f(.55,.42);T.position.set(E*.715,P+.55,g),T.rotation.y=E*Math.PI/2,d.add(T)}for(const E of[-1,1]){const g=l(.62,.78);g.position.set(0,P+.5,E*.915),g.rotation.y=E>0?0:Math.PI,d.add(g)}const I=p("KIỀU LÂU",.85);I.position.set(.74,P+.92,0),I.rotation.y=Math.PI/2,d.add(I);const F=new t,M=new t,A=new t,K=P+1.27;d.add(n(1.5,.13,1.9,e.woodDark,0,P+1.2,0));for(let E=0;E<4;E++)for(const g of[-1,1])c(F,M,g*.82,P+1.15,-1.02+E*.68,g*Math.PI/2,.7);for(let E=0;E<3;E++)for(const g of[-1,1])c(F,M,-.8+E*.8,P+1.15,g*1.04,g>0?0:Math.PI,.7);const O=s(1.05,1.35,.55,.3);O.position.y=K,d.add(O),d.add(n(.9,.24,1.15,e.woodDark,0,K+.32,0)),A.box(1,.06,1.25,0,K+.26,0),d.add(n(.7,.28,.95,e.woodDark,0,K+.54,0));for(const E of[-1,1]){const g=f(.4,.16);g.position.set(E*.355,K+.54,0),g.rotation.y=E*Math.PI/2,d.add(g);for(const T of[-1,1])F.box(.06,.3,.06,E*.33,K+.54,T*.45)}d.add(n(.68,.08,.93,e.woodDark,0,K+.72,0));for(const E of[-.4,0,.4])for(const g of[-1,1])c(F,M,g*.35,K+.67,E,g*Math.PI/2,.5);for(const E of[-.25,.25])for(const g of[-1,1])c(F,M,E,K+.67,g*.475,g>0?0:Math.PI,.5);const z=s(.58,.75,.4,.22);z.position.y=K+.76,d.add(z),d.add(a(new ne(.08,8,6),e.gold,0,K+1.23,0),a(new ne(.055,8,6),e.gold,0,K+1.35,0));for(const[E,,g]of O.userData.corners)u(d,E*.92,K+.3,g*.92,.9);d.add(F.mesh(e.wood),M.mesh(e.woodDark),A.mesh(e.tileTrim));const S=new Qt;return S.position.set(1,K+.04,.55),S.add(a(new qt(.008,.008,.3,4),e.trunk,0,-.15,0)),S.add(m(new qt(.07,.14,.22,10),e.gold,0,-.4,0),a(new ne(.03,6,4),e.bronze,0,-.53,0)),d.add(S),d.userData={bell:S,top:P+2.75},d}}function g0(i){const{Batch:t,MAT:e,box:n,column:r,curvedRoof:s,dbox:o,door:a,dougong:l,lattice:c,plaque:u,spire:f,steps:m,stoneLantern:p,urn:v,windBell:x}=i;i.tangKinh=d;function d(){const h=new Qt,y=new t,_=new t,w=new t,D=new t,P=.14;h.add(n(3.6,.3,3.6,e.stoneDark,0,.15,0),n(3,.3,3,e.stone,0,.45,0)),w.box(3.7,.06,3.7,0,.29,0).box(3.1,.06,3.1,0,.59,0),m(h,1,3,.2,.22,1.5);for(const z of[-1,1])h.add(n(.16,.5,.7,e.stoneDark,z*.58,.25,1.85)),p(h,z*1.35,2.15,.9);v(h,0,2.75);const I=(z,S,E,g,T,L,N,C)=>{const U=S*Math.PI/2,q=Math.cos(U),Z=Math.sin(U);z.box(E,g,T,L*q+C*Z,N,-L*Z+C*q,U)},F=(z,S,E,g)=>{for(let T=0;T<4;T++){const L=T*Math.PI/2,N=Math.cos(L),C=Math.sin(L);for(let U=0;U<E;U++){const q=-S+2*S*U/(E-1);l(y,_,q*N+S*C,z,-q*C+S*N,L,g)}}},M=(z,S)=>{for(let E=0;E<4;E++){I(_,E,S*2,.04,.05,0,z+.25,S),I(_,E,S*2,.03,.035,0,z+.14,S),I(_,E,S*2,.03,.035,0,z+.035,S),I(y,E,S*2-.04,.09,.014,0,z+.088,S);for(let g=0;g<=4;g++){const T=-S+2*S*g/4;I(_,E,.06,.3,.06,T,z+.15,S),I(_,E,.08,.03,.08,T,z+.31,S)}}};let A=.6;const K=[2.2,1.7,1.25],O=[1,.82,.7];return K.forEach((z,S)=>{const E=O[S],g=z*.46;h.add(n(z*.92,E,z*.92,e.paper,0,A+E/2,0));for(const[N,C]of[[1,1],[1,-1],[-1,1],[-1,-1]])r(h,N*g,C*g,E-.12,A,.06);h.add(o(z*.98,.09,z*.98,e.wood,0,A+E-.04,0),o(z*.96,.07,z*.96,e.wood,0,A+.04,0));for(let N=0;N<4;N++){const C=N*Math.PI/2,U=S===0&&N===0,q=U?a(.62,.62):c(z*.4,E*.48);q.position.set(Math.sin(C)*(g+.01),A+(U?.4:E*.52),Math.cos(C)*(g+.01)),q.rotation.y=C,h.add(q);for(const Z of[-1,1])I(y,N,.05,E-.1,.03,Z*z*.29,A+E/2,g+.005);U||I(y,N,z*.9,.04,.03,0,A+E*.2,g+.005),I(_,N,z*.9,.04,.03,0,A+E*.84,g+.005)}if(S===0){const N=u("TÀNG KINH CÁC",1.15);N.position.set(0,A+.86,g+.06),h.add(N)}A+=E,h.add(n(z*.9,P,z*.9,e.woodDark,0,A+P/2,0)),F(A+.005,g,S===0?5:4,.8),A+=P;const T=z*.5+.42,L=s(T,T,.5,.28);L.position.y=A,h.add(L);for(const[N,C,U]of L.userData.corners)x(h,N*.97,A+C+.02,U*.97);if(A+=.42,S<2){const N=K[S+1],C=N*.6,U=A-.42;D.box(N*1.14,.07,N*1.14,0,U+.12,0),h.add(n(N*1.04,.34,N*1.04,e.woodDark,0,U+.22,0));for(let q=0;q<4;q++)for(const Z of[-.3,0,.3])I(y,q,N*.24,.15,.02,Z*N,U+.25,N*.52+.004);F(A-.125,N*.52,4,.55),h.add(n(C*2+.12,.05,C*2+.12,e.woodDark,0,A+.01,0)),M(A+.035,C)}}),h.add(y.mesh(e.wood),_.mesh(e.woodDark),w.mesh(e.stone),D.mesh(e.tileTrim)),h.userData={top:f(h,A)+.1},h}}function _0(i){const{Batch:t,M:e,MAT:n,column:r,dbox:s,dm:o,dougong:a,hangLantern:l,hexRoof:c,mesh:u,railing:f,steps:m,windBell:p}=i;i.traDinh=v;function v(){const x=new Qt,d=1.6,h=.4,y=1.45,_=Math.cos(Math.PI/6),w=u(new qt(d+.3,d+.4,.2,6),n.stoneDark,0,.1,0),D=u(new qt(d,d+.1,.2,6),n.stone,0,.3,0);w.rotation.y=D.rotation.y=Math.PI/6,x.add(w,D),m(x,.8,2,.2,.24,d*_);const P=[];for(let S=0;S<6;S++){const E=Math.PI/6+S*Math.PI/3;P.push([Math.sin(E)*(d-.15),Math.cos(E)*(d-.15)])}P.forEach(([S,E])=>r(x,S,E,y,h,.07));for(let S=0;S<6;S++){const[E,g]=P[S],[T,L]=P[(S+1)%6],N=Math.hypot(T-E,L-g),C=Math.atan2(T-E,L-g),U=(E+T)/2,q=(g+L)/2,Z=s(.09,.12,N,n.wood,U,h+y+.02,q);Z.rotation.y=C,x.add(Z);const it=s(.03,.12,N*.85,n.woodDark,U,h+y-.14,q);if(it.rotation.y=C,x.add(it),S!==5&&(f(x,E,g,T,L,h,.32,3),S>=1&&S<=3)){const ut=o(new qt(.04,.04,N*.88,6),n.bamboo,U,h+y-.25,q);if(ut.rotation.order="YXZ",ut.rotation.set(Math.PI/2,C,0),x.add(ut),S===2){const gt=s(.02,.5,N*.85,n.bamboo,U,h+y-.52,q);gt.rotation.y=C,x.add(gt)}}}const I=h+y+.2,F=new t,M=new t;P.forEach(([S,E],g)=>{const T=Math.PI/6+g*Math.PI/3,[L,N]=P[(g+1)%6];a(F,M,S,h+y+.09,E,T,.8),a(F,M,(S+L)/2,h+y+.09,(E+N)/2,T+Math.PI/6,.7)}),x.add(F.mesh(n.wood),M.mesh(n.woodDark));const A=c(d+.55,.95,.35);A.position.y=I,x.add(A);for(const[S,E,g]of A.userData.corners)p(x,S*.96,I+E+.02,g*.96);const K=I+.95;x.add(o(new ne(.12,10,8),n.gold,0,K+.08,0),o(new ne(.08,10,8),n.gold,0,K+.25,0),o(new Fe(.03,.14,6),n.gold,0,K+.37,0)),l(x,0,h+y+.05,0,1.1),x.add(u(new qt(.45,.45,.06,12),n.wood,0,h+.36,0),o(new qt(.07,.1,.33,8),n.woodDark,0,h+.17,0)),x.add(o(new ne(.08,10,8),n.ceramic,0,h+.46,0),o(new ne(.03,6,4),n.ceramic,0,h+.54,0));const O=o(new qt(.012,.02,.1,5),n.ceramic,.09,h+.47,0);O.rotation.z=-.9,x.add(O);for(let S=0;S<3;S++){const E=S/3*Math.PI*2+.5;x.add(o(new qt(.03,.022,.04,8),n.ceramic,Math.cos(E)*.24,h+.41,Math.sin(E)*.24))}for(const S of[Math.PI/2,-Math.PI/2,Math.PI])x.add(o(new qt(.2,.2,.07,10),n.cushion,Math.sin(S)*.8,h+.04,Math.cos(S)*.8));const z=e(16738858,{emissive:16730640,emissiveIntensity:1.2});x.add(u(new qt(.16,.2,.3,8),n.stoneDark,1.75,.15,-1),o(new qt(.11,.11,.03,8),z,1.75,.31,-1));for(let S=0;S<4;S++){const E=o(new ao(.26,0),n.stone,S%2?.15:-.15,.02,d*_+.7+S*.5);E.scale.y=.2,x.add(E)}return x.userData={top:K+.5},x}}function v0(i){const{Batch:t,M:e,MAT:n,box:r,column:s,curvedRoof:o,dbox:a,dm:l,door:c,dougong:u,hangLantern:f,lattice:m,mesh:p,plaque:v,smooth:x,steps:d,stoneLantern:h}=i;i.nghiSu=y;function y(){const _=new Qt,w=new t,D=new t,P=new t,I=new t,F=.55,M=1.35,A=.14,K=F+M+A;_.add(r(5.2,.25,3.6,n.stoneDark,0,.125,0),r(4.8,.3,3.2,n.stone,0,.4,0)),P.box(5.3,.05,3.7,0,.245,0).box(4.9,.05,3.3,0,.545,0),d(_,1.6,3,.18,.2,1.6);for(const U of[-1,1])_.add(r(.14,.45,.62,n.stoneDark,U*.87,.25,1.9)),h(_,U*1.35,2.1,.9);_.add(r(4,M,1.9,n.paper,0,F+M/2,-.45)),_.add(a(4.04,.1,1.94,n.wood,0,F+.05,-.45),a(4.04,.1,1.94,n.wood,0,F+M-.05,-.45));for(let U=0;U<6;U++)s(_,-1.9+U*.76,.85,M-.08,F,.075);for(const U of[-1,1])s(_,U*1.9,-1.35,M-.08,F,.075);_.add(a(4.3,.13,.13,n.wood,0,F+M-.03,.85));for(let U=0;U<5;U++){const q=a(.03,.18,.36,n.woodDark,-1.52+U*.76,F+M-.18,.68);_.add(q)}for(const U of[-.9,0,.9]){const q=c(.62,.92);q.position.set(U,F+.52,.53),_.add(q)}for(const U of[-1.6,1.6]){const q=m(.48,.5);q.position.set(U,F+.72,.52),_.add(q)}for(const U of[-1,1])for(const q of[-.85,-.05]){const Z=m(.5,.45);Z.position.set(U*2.01,F+.72,q),Z.rotation.y=U*Math.PI/2,_.add(Z)}for(const U of[-1.3,-.45,.45,1.3])w.box(.06,M-.1,.04,U,F+M/2,.51),w.box(.06,M-.1,.04,U,F+M/2,-1.41);w.box(3.95,.04,.03,0,F+M*.25,-1.41);for(const U of[-1,1])w.box(.04,M-.1,.06,U*2.005,F+M/2,-.45),w.box(.03,.04,1.85,U*2.005,F+M*.25,-.45);const O=v("NGHỊ SỰ ĐƯỜNG",1.45);O.position.set(0,F+1.17,.56),_.add(O),_.add(r(4,A,1.9,n.woodDark,0,F+M+A/2,-.45)),D.box(4.3,.19,.08,0,F+M+.2,.8);for(let U=0;U<6;U++)u(w,D,-1.9+U*.76,F+M+.03,.85,0,.8),u(w,D,-1.9+U*.76,F+M+.005,-1.4,Math.PI,.8);for(let U=0;U<4;U++)for(const q of[-1,1])u(w,D,q*2,F+M+.005,-1.35+U*.73,q*Math.PI/2,.8);const z=o(2.8,1.9,.55,.32);z.position.set(0,K,-.1),_.add(z);for(const[U,,q]of z.userData.corners)f(_,U*.94,K+.3,q*.94-.1,1);_.add(r(3.25,.28,1.6,n.woodDark,0,K+.34,-.1)),I.box(3.4,.07,1.75,0,K+.27,-.1),_.add(r(3,.32,1.35,n.woodDark,0,K+.6,-.1));for(const U of[-.9,0,.9])for(const q of[-1,1]){const Z=m(.5,.18);Z.position.set(U,K+.6,-.1+q*.68),q<0&&(Z.rotation.y=Math.PI),_.add(Z)}for(const U of[-1,1]){const q=m(.6,.18);q.position.set(U*1.505,K+.6,-.1),q.rotation.y=U*Math.PI/2,_.add(q)}for(const U of[-1.47,-.45,.45,1.47])for(const q of[-1,1])w.box(.07,.34,.07,U,K+.6,-.1+q*.66);const S=K+.76,E=.11;_.add(r(2.96,E,1.31,n.woodDark,0,S+E/2,-.1));for(let U=0;U<6;U++)for(const q of[-1,1])u(w,D,-1.5+U*.6,S-.02,-.1+q*.675,q>0?0:Math.PI,.65);for(let U=0;U<3;U++)for(const q of[-1,1])u(w,D,q*1.5,S-.02,-.775+U*.675,q*Math.PI/2,.65);const g=o(2,1.15,.6,.3);g.position.set(0,S+E,-.1),_.add(g);const T=S+E+.6;_.add(l(new ne(.1,10,8),n.gold,0,T+.18,-.1));const L=l(new Fe(.05,.16,6),e(16747069,{emissive:16734751,emissiveIntensity:.8}),0,T+.33,-.1);_.add(L);for(const U of[-1,1]){const q=l(new Ei(.2,.04,6,14,Math.PI),n.jade,U*.42,T+.05,-.1);_.add(q);const Z=l(new Fe(.06,.16,5),n.jade,U*.2,T+.12,-.1);Z.rotation.z=U*1.2,_.add(Z);const it=l(new Fe(.04,.22,5),n.jade,U*.68,T+.14,-.1);it.rotation.z=-U*.5,_.add(it)}const N=new Ft(new qt(.22,.22,.3,14),[x(n.wood),n.leather,n.leather]);N.rotation.z=Math.PI/2,N.position.set(-2.05,F+.62,1.3),N.castShadow=!0,_.add(N);for(const U of[-1,1])_.add(a(.05,.85,.05,n.woodDark,-2.05+U*.21,F+.42,1.3));_.add(a(.5,.05,.06,n.woodDark,-2.05,F+.86,1.3));const C=[];for(const U of[-1,1]){_.add(p(new qt(.03,.04,2.6,6),n.woodDark,U*2.4,1.3,1.75),l(new ne(.05,6,4),n.gold,U*2.4,2.63,1.75));const q=new Ft(new Wn(.6,.4,8,1),n.flag);q.position.set(U*2.4-U*.32,2.3,1.75),q.rotation.y=U>0?Math.PI:0,_.add(q),C.push(q)}return _.add(w.mesh(n.wood),D.mesh(n.woodDark),P.mesh(n.stone),I.mesh(n.tileTrim)),_.userData={top:T+.45,flags:C},_}}function x0(i){const{AMBER_Y:t,TOP:e,TOWERS:n,kieuLau:r,nghiSu:s,scene:o,tangKinh:a,traDinh:l}=i,c={kieulau:r,tangkinh:a,tradinh:l,nghisu:s},u=[];i.hitTargets=u;for(const[f,m]of Object.entries(n)){const p=new W(...m.pos).setY(e);if(m.vec=p,f==="center"){m.top=t-e;continue}const v=c[f]();v.position.copy(p),f==="kieulau"?v.rotation.y=Math.PI/2:v.lookAt(0,e,0),o.add(v),m.group=v,m.top=v.userData.top;const x=new Ft(f==="kieulau"?new ji(3.1,3.4,56):new ji(2.3,2.6,56),new De({color:16757575,transparent:!0,opacity:.35,depthWrite:!1}));x.rotation.x=-Math.PI/2,x.position.set(p.x,e+.02,p.z),o.add(x),m.aura=x;const d=f==="kieulau"?3:2.2,h=new Ft(new qt(d,d,m.top,8),new De({visible:!1}));h.position.set(p.x,e+m.top/2,p.z),h.userData.id=f,o.add(h),u.push(h)}}function M0(i){const{AMBER_Y:t,hitTargets:e,scene:n}=i,r=new Qt;i.amber=r,r.position.set(0,t,0),n.add(r);const s=new Be({color:16762219,emissive:16751918,emissiveIntensity:1.4,roughness:.3});i.coreMat=s,r.add(new Ft(new ne(.5,32,20),s));const o=new Ft(new ne(.82,40,24),new Be({color:16753978,transparent:!0,opacity:.3,roughness:.04,metalness:.1,depthWrite:!1,envMapIntensity:1.6}));i.shell=o,r.add(o);const a=new Be({color:14856794,metalness:.9,roughness:.25,emissive:9067024,emissiveIntensity:.5}),l=[0,1].map(f=>{const m=new Ft(new Ei(1.25+f*.3,.022,8,96),a);return r.add(m),m});i.halos=l;const c=new Vm(16754240,10,11,1.6);i.amberLight=c,r.add(c);const u=new Ft(new ne(1.6,8,6),new De({visible:!1}));u.userData.id="center",r.add(u),e.push(u)}function y0(i){const{BONSAI:t,LAKE:e,MAT:n,TOP:r,blossomSpots:s,feeder:o,mainFall:a,mesh:l,rockMeshes:c,scene:u,trees:f}=i;i.leafTexture=m,i.leafCloud=D;function m(O){const z=document.createElement("canvas");z.width=z.height=128,O(z.getContext("2d"));const S=new Ze(z);return S.colorSpace=ce,S}const p=(O,z)=>O+i.rng()*(z-O);i.rr=p;const v=m(O=>{O.lineCap="round";for(let z=0;z<46;z++){const S=p(12,116),E=p(12,116),g=p(0,7);for(let T=0;T<15;T++){const L=g+T/15*Math.PI*1.5,N=p(9,19);O.strokeStyle=`hsl(${p(112,150)},${p(30,48)}%,${p(22,44)}%)`,O.lineWidth=2.6,O.beginPath(),O.moveTo(S,E),O.lineTo(S+Math.cos(L)*N,E+Math.sin(L)*N),O.stroke()}}}),x=m(O=>{for(let z=0;z<14;z++)O.fillStyle=`hsl(${p(85,115)},${p(30,45)}%,${p(28,40)}%)`,O.beginPath(),O.ellipse(p(14,114),p(14,114),p(6,10),p(3,5),p(0,3),0,7),O.fill();for(let z=0;z<64;z++){const S=p(12,116),E=p(12,116),g=p(4,7),T=p(332,352),L=p(74,92);for(let N=0;N<5;N++){const C=N/5*Math.PI*2+z;O.fillStyle=`hsl(${T},${p(70,92)}%,${L}%)`,O.beginPath(),O.arc(S+Math.cos(C)*g*.75,E+Math.sin(C)*g*.75,g*.72,0,7),O.fill()}O.fillStyle=`hsl(${T-6},70%,${L-26}%)`,O.beginPath(),O.arc(S,E,g*.3,0,7),O.fill()}}),d=m(O=>{for(let z=0;z<90;z++)O.fillStyle=`hsl(${p(88,128)},${p(32,52)}%,${p(20,42)}%)`,O.beginPath(),O.ellipse(p(12,116),p(12,116),p(7,12),p(3.5,6),p(0,3.2),0,7),O.fill()}),h=(O,z)=>{const S=new Be({map:O,color:z,alphaTest:.3,side:be,roughness:.9});return S.onBeforeCompile=E=>{E.fragmentShader=E.fragmentShader.replace("#include <normal_fragment_begin>",`#include <normal_fragment_begin>
#ifdef DOUBLE_SIDED
  normal *= faceDirection;
#endif`)},S.customProgramCacheKey=()=>"leaf",S};i.leafMat=h;const y=[16777215,14478296,12900548].map(O=>h(v,O)),_=[16777215,16770798,16766690].map(O=>h(x,O)),w=[16777215,14674120,13163712].map(O=>h(d,O));i.bushLeaf=w;function D(O,z,S,E,g=!1){const T=[],L=[],N=[],C=[],U=new An,q=new Ki,Z=new W,it=new W,ut=[[-1,-1,0,0],[1,-1,1,0],[1,1,1,1],[-1,1,0,1]];for(const[Et,lt,ct,Mt,k=Mt]of O)for(let tt=0;tt<z;tt++){const G=p(0,Math.PI*2),H=p(-1,1),V=Math.sqrt(1-H*H),et=p(.5,1),rt=Math.cos(G)*V,R=Math.sin(G)*V;g?q.set(-Math.PI/2+p(-.5,.5),p(-.5,.5),p(0,6.3)):q.set(p(0,6.3),p(0,6.3),p(0,6.3)),U.setFromEuler(q),it.set(rt,H+.4,R).normalize();const b=S*p(.7,1.3),Y=T.length/3;for(const[j,Q,J,nt]of ut)Z.set(j*b/2,Q*b/2,0).applyQuaternion(U),T.push(Et+rt*Mt*et+Z.x,lt+H*k*et+Z.y,ct+R*Mt*et+Z.z),L.push(it.x,it.y,it.z),N.push(J,nt);C.push(Y,Y+1,Y+2,Y,Y+2,Y+3)}const gt=new Jt;gt.setAttribute("position",new Nt(T,3)),gt.setAttribute("normal",new Nt(L,3)),gt.setAttribute("uv",new Nt(N,2)),gt.setIndex(C);const xt=new Ft(gt,E);return xt.castShadow=!0,xt}const P=(O,z,S)=>new W(O,z,S),I=P(0,1,0);function F(O,z,S,E,g){const T=S.clone().sub(z),L=T.length(),N=l(new qt(g,E,L,8),n.trunk);N.position.copy(z).addScaledVector(T,.5),N.quaternion.setFromUnitVectors(I,T.normalize()),O.add(N)}function M(){const O=new Qt,z=p(-.5,.5),S=p(0,6.3),E=[P(0,0,0),P(z*.25,.6,.05),P(z*.1,1.2,-.05),P(z*.5,1.8,.05),P(z*.35,2.3,0)];for(let L=0;L<4;L++)F(O,E[L],E[L+1],.13-L*.026,.13-(L+1)*.026);const g=new en(E),T=[];return[[.8,.85,.62],[1.25,.7,.55],[1.7,.55,.46],[2.08,.42,.36]].forEach(([L,N,C],U)=>{const q=S+U*2.3,Z=g.getPoint(L/2.3),it=P(Z.x+Math.cos(q)*N*.6,L+.08,Z.z+Math.sin(q)*N*.6);F(O,Z,it,.035,.014),T.push([it.x,it.y+.06,it.z,C,C*.3])}),T.push([E[4].x,2.42,0,.38,.2]),O.add(D(T,18,.5,y[Math.floor(p(0,3))],!0)),O}function A(O,z,S=1){const E=M();E.position.set(O,r,z),E.scale.setScalar(S),u.add(E),f.push({g:E,ph:p(0,6),amp:.02})}function K(O,z,S=1){const E=new Qt,g=P(0,0,0),T=P(.07,.55,.03),L=P(-.04,1,-.02);F(E,g,T,.13,.1),F(E,T,L,.1,.075);const N=[P(.5,1.45,.15),P(-.48,1.5,-.12),P(.12,1.5,-.5),P(-.1,1.85,.22),P(.28,1.8,-.2),P(0,1.6,.45)];N.forEach(U=>F(E,L,U,.05,.014));const C=N.map((U,q)=>[U.x,U.y+.08,U.z,.4+q%3*.06,.3]);C.push([0,1.75,0,.48,.34]),E.add(D(C,13,.42,_[Math.floor(p(0,3))])),E.position.set(O,r,z),E.scale.setScalar(S),E.rotation.y=p(0,6.3),u.add(E),f.push({g:E,ph:p(0,6),amp:.03}),s.push(new W(O,r+1.5*S,z))}[[2.2,5.8],[.8,8.4],[3.2,8.2],[-1.5,6.2],[-4,8]].forEach(([O,z],S)=>A(O,z,.9+S%3*.15)),[[-5,1],[-5.6,-6.4],[.6,-8.6],[1.8,-6.6],[.4,-4.4],[7.2,-6]].forEach(([O,z],S)=>K(O,z,.85+S%3*.15));{u.updateMatrixWorld(!0);const O=new Gr,z=P(0,-1,0);for(const[E,g,T]of t){O.set(P(E,20,g),z);const L=O.intersectObjects(c,!1)[0];if(!L)continue;const N=M();N.position.set(E,L.point.y-.04,g),N.scale.setScalar(T*.75),u.add(N),f.push({g:N,ph:p(0,6),amp:.012})}for(let E=0,g=0;E<20&&g<500;g++){const T=p(4.9,9.5),L=p(-1.6,3.4);if(Math.abs(T-7.2)<.75&&L<.3||Math.hypot(T-e.x,L-e.z)<e.r+.05)continue;O.set(P(T,20,L),z);const N=O.intersectObjects(c,!1)[0];if(!N||N.face.normal.y<.72||N.point.y<r+.45)continue;const C=p(.7,1.5),U=D([[0,.1*C,0,.2*C,.12*C],[p(-.15,.15)*C,.08*C,p(-.15,.15)*C,.14*C,.09*C]],8,.2*C,w[E%3]);U.position.copy(N.point),U.position.y-=.02,u.add(U),E++}const S=(E,g,T,L)=>{const N=D([[0,.07*L,0,.16*L,.09*L]],7,.2*L,w[Math.floor(p(0,3))]);N.position.set(E,g,T),u.add(N)};if(o.src){const{x:E,y:g,z:T}=o.src;S(E+.02,g+.3,T+.08,1.1),S(E+.04,g+.02,T+.3,.8),S(E+.04,g,T-.3,.9),S(E+.12,g-.18,T+.2,.6)}S(7.2-.62,e.y+.22,a.tz+.2,1),S(7.2+.6,e.y+.26,a.tz+.18,.9),S(7.2-.6,e.y+.12,a.tz+.55,.7),S(7.2+.62,e.y+.14,a.tz+.5,.7)}}function S0(i){const{LITE:t,M:e,PLAZA_X:n,RIVER_EDGES:r,TOP:s,U:o,WY:a,blossomSpots:l,bushLeaf:c,dm:u,freeGround:f,groundY:m,isYin:p,leafCloud:v,leafMat:x,leafTexture:d,lotus:h,mesh:y,reeds:_,riverCurve:w,rr:D,scene:P,stoneLantern:I,trees:F,waterU:M}=i;i.ripple=it,i.animateNature=Et;const A=e(7311162),K=e(8823370),O=e(7029541);r.forEach(({p:lt,n:ct,w:Mt},k)=>{if(!(k%3))for(const tt of[-1,1]){if(i.rng()<.35)continue;const G=lt.x+ct.x*(Mt+.12)*tt,H=lt.y+ct.y*(Mt+.12)*tt;if(Math.hypot(G,H)>9.2||Math.abs(G)<1.9&&Math.abs(H)<1.6||Math.hypot(Math.abs(G)-n,H)<1.5||G<-8.6||Math.hypot(G-7.2,H+.5)<1.3)continue;const V=new Qt;V.position.set(G,m(G,H),H);for(let et=0,rt=3+Math.floor(i.rng()*3);et<rt;et++){const R=.35+i.rng()*.35,b=y(new Fe(.018,R,4),et%2?A:K,(i.rng()-.5)*.18,R/2,(i.rng()-.5)*.18);b.rotation.set((i.rng()-.5)*.3,0,(i.rng()-.5)*.3),V.add(b),et===0&&i.rng()<.5&&V.add(y(new qt(.025,.025,.1,5),O,b.position.x,R+.03,b.position.z))}P.add(V),_.push({g:V,ph:i.rng()*6})}});{const lt=[16777215,16765773,15221594,12160240,16751444].map(ct=>e(ct,{emissive:ct,emissiveIntensity:.06,flatShading:!1,d:!1}));for(let ct=0,Mt=0;ct<34&&Mt<700;Mt++){const k=i.rng()*Math.PI*2,tt=2+i.rng()*7,G=Math.cos(k)*tt,H=Math.sin(k)*tt;if(!f(G,H))continue;const V=new Qt;if(V.position.set(G,m(G,H),H),ct%3===0)V.add(v([[0,.17,0,.27,.17],[D(-.2,.2),.13,D(-.2,.2),.19,.13]],10,.24,c[ct%3+Math.floor(D(0,3))]??c[0]));else{const et=lt[Math.floor(i.rng()*lt.length)];for(let rt=0;rt<9;rt++){const R=(i.rng()-.5)*.45,b=(i.rng()-.5)*.45,Y=.08+i.rng()*.1;V.add(u(new qt(.008,.008,Y,3),A,R,Y/2,b),u(new ne(.026,8,6),et,R,Y+.015,b))}}P.add(V),_.push({g:V,ph:i.rng()*6,small:!0}),ct++}}const z={value:1};{const lt=d(j=>{j.lineCap="round";for(let Q=0;Q<36;Q++){const J=D(8,120),nt=D(-24,24),st=D(50,122);j.strokeStyle=`hsl(${D(76,108)},${D(36,56)}%,${D(50,80)}%)`,j.lineWidth=D(2.5,5),j.beginPath(),j.moveTo(J,128),j.quadraticCurveTo(J,128-st*.6,J+nt,128-st),j.stroke()}}),ct=[],Mt=[],k=[],tt=[];for(const j of[0,Math.PI/2]){const Q=Math.cos(j)*.13,J=Math.sin(j)*.13,nt=ct.length/3;ct.push(-Q,0,-J,Q,0,J,Q,.13,J,-Q,.13,-J),Mt.push(0,1,0,0,1,0,0,1,0,0,1,0),k.push(0,0,1,0,1,1,0,1),tt.push(nt,nt+1,nt+2,nt,nt+2,nt+3)}const G=new Jt;G.setAttribute("position",new Nt(ct,3)),G.setAttribute("normal",new Nt(Mt,3)),G.setAttribute("uv",new Nt(k,2)),G.setIndex(tt);const H=x(lt,16777215),V=H.onBeforeCompile;H.alphaTest=.35,H.onBeforeCompile=j=>{V(j),j.uniforms.uTime=M.uTime,j.uniforms.uWind=z,j.vertexShader=j.vertexShader.replace("#include <common>",`#include <common>
uniform float uTime, uWind;`).replace("#include <begin_vertex>",`#include <begin_vertex>
        #ifdef USE_INSTANCING
          float gph = instanceMatrix[3].x*1.7 + instanceMatrix[3].z*1.3;
          transformed.x += sin(uTime*1.9 + gph) * .022 * uWind * uv.y; transformed.z += cos(uTime*1.4 + gph*1.3) * .015 * uWind * uv.y;
        #endif`)},H.customProgramCacheKey=()=>"grass";const et=t?5e3:13e3,rt=new bm(G,H,et),R=new ue,b=new Dt;let Y=0;for(let j=0;Y<et&&j<et*4;j++){const Q=D(0,Math.PI*2),J=Math.sqrt(i.rng())*9.6,nt=Math.cos(Q)*J,st=Math.sin(Q)*J;f(nt,st,!0)&&(R.position.set(nt,m(nt,st)-.01,st),R.rotation.y=D(0,6.3),R.scale.set(D(.7,1.5),D(.55,1.5),D(.7,1.5)),R.updateMatrix(),rt.setMatrixAt(Y,R.matrix),p(nt,st)?b.setHSL(D(.33,.4),.32,D(.15,.25)):i.rng()<.12?b.setHSL(D(.12,.16),.42,D(.4,.5)):b.setHSL(D(.21,.28),.46,D(.3,.44)),rt.setColorAt(Y++,b))}rt.count=Y,rt.receiveShadow=!0,rt.frustumCulled=!1,P.add(rt)}const S=(()=>{const lt=document.createElement("canvas");lt.width=lt.height=32;const ct=lt.getContext("2d"),Mt=ct.createRadialGradient(16,16,2,16,16,15);return Mt.addColorStop(0,"rgba(255,255,255,1)"),Mt.addColorStop(1,"rgba(255,255,255,0)"),ct.fillStyle=Mt,ct.beginPath(),ct.ellipse(16,16,14,8,.5,0,Math.PI*2),ct.fill(),new Ze(lt)})(),E=140,g=new Float32Array(E*3),T=[];function L(lt,ct){const Mt=l[Math.floor(i.rng()*l.length)];g[lt*3]=Mt.x+(i.rng()-.5)*1.2,g[lt*3+2]=Mt.z+(i.rng()-.5)*1.2,g[lt*3+1]=ct?s+i.rng()*(Mt.y-s+.4):Mt.y+(i.rng()-.3)*.5,T[lt]={vy:.22+i.rng()*.25,ph:i.rng()*6}}for(let lt=0;lt<E;lt++)L(lt,!0);const N=new Jt;N.setAttribute("position",new fe(g,3));const C=new Wr({map:S,color:16233414,size:.13,transparent:!0,depthWrite:!1});o(C),P.add(new so(N,C));const U=o(new De({color:16367823,side:be})),q=[];for(let lt=0;lt<26;lt++){const ct=new Ft(new Xr(.05,6),U);ct.rotation.x=-Math.PI/2,ct.userData={u:i.rng()*.97,side:(i.rng()-.5)*1.1,sp:.005+i.rng()*.006,ph:i.rng()*6},P.add(ct),q.push(ct)}const Z=[];for(let lt=0;lt<22;lt++){const ct=new Ft(new ji(.06,.085,24),o(new De({color:16777215,transparent:!0,opacity:0,depthWrite:!1})));ct.rotation.x=-Math.PI/2,ct.userData.life=-1,P.add(ct),Z.push(ct)}function it(lt,ct){const Mt=Z.find(k=>k.userData.life<0);Mt&&(Mt.position.set(lt,a+.03,ct),Mt.userData.life=0)}let ut=0;i.nextJump=7;const gt=[];for(let lt=0;lt<3;lt++){const ct=new Qt,Mt=u(new qt(.012,.008,.22,5),e(3127208,{emissive:1006162,emissiveIntensity:.4}));Mt.rotation.x=Math.PI/2,ct.add(Mt);const k=new De({color:15267583,transparent:!0,opacity:.55,depthWrite:!1}),tt=[];for(const G of[-1,1])for(const H of[.035,-.015]){const V=u(new $e(.17,.003,.035),k,G*.085,.01,H);ct.add(V),tt.push([V,G])}ct.userData={wings:tt,target:new W,timer:0},ct.position.copy(w.getPointAt(.2+lt*.25)).setY(s+.6),P.add(ct),gt.push(ct)}const xt=new W;function Et(lt,ct){const Mt=.6+i.ENV.wind/12+i.cur.storm*1.6;z.value=Mt;for(const G of F)G.g.rotation.z=Math.sin(ct*1.3+G.ph)*G.amp*Mt,G.g.rotation.x=Math.cos(ct*1.05+G.ph*1.3)*G.amp*.6*Mt;for(const G of _)G.g.rotation.z=Math.sin(ct*2.1+G.ph)*(G.small?.04:.1)*Mt,G.g.rotation.x=Math.cos(ct*1.7+G.ph)*.04*Mt;C.opacity=.95-.45*i.modeT;const k=i.ENV.wind*.02+i.cur.storm*.5;for(let G=0;G<E;G++){const H=T[G],V=G*3;g[V+1]-=H.vy*lt*(1+i.cur.r*2.5),g[V]+=(Math.sin(ct*1.5+H.ph)*.25+k)*lt,g[V+2]+=Math.cos(ct*1.2+H.ph)*.2*lt,g[V+1]<s+.03&&L(G,!1)}N.attributes.position.needsUpdate=!0;for(const G of q){const H=G.userData;H.u=(H.u+lt*H.sp*(1+i.cur.r))%.97;const V=w.getPointAt(H.u),et=w.getTangentAt(H.u);G.position.set(V.x-et.z*H.side,a+.025+Math.sin(ct*2+H.ph)*.008,V.z+et.x*H.side),G.rotation.z+=lt*.3}for(h.forEach((G,H)=>{var V;(V=G.userData).y0??(V.y0=G.position.y),G.position.y=G.userData.y0+Math.sin(ct*1.3+H)*.012,G.rotation.y+=lt*.05*(H%2?1:-1)}),ut+=lt*(.9+i.cur.r*14);ut>1;){ut--;const G=.03+i.rng()*.94,H=w.getPointAt(G),V=w.getTangentAt(G),et=(i.rng()-.5)*1.1;it(H.x-V.z*et,H.z+V.x*et)}for(const G of Z){const H=G.userData;if(!(H.life<0)){if(H.life+=lt/1.6,H.life>=1){H.life=-1,G.material.opacity=0;continue}G.scale.setScalar(1+H.life*6),G.material.opacity=.45*(1-H.life)}}const tt=i.modeT<.5&&i.cur.r<.15;for(const G of gt){if(G.visible=tt,!tt)continue;const H=G.userData;if(H.timer-=lt,H.timer<0){const V=w.getPointAt(.05+i.rng()*.9);H.target.set(V.x+(i.rng()-.5)*1.5,s+.35+i.rng()*.6,V.z+(i.rng()-.5)*1.5),H.timer=1.2+i.rng()*2.5}xt.copy(G.position),G.position.lerp(H.target,Math.min(1,lt*2.2)),G.position.y+=Math.sin(ct*7+H.timer)*.002,G.position.distanceToSquared(xt)>1e-7&&G.lookAt(G.position.x*2-xt.x,G.position.y,G.position.z*2-xt.z);for(const[V,et]of H.wings)V.rotation.z=et*Math.sin(ct*55+et)*.45}}for(let lt=0;lt<12;lt++){const ct=lt/12*Math.PI*2+.26,Mt=Math.cos(ct)*9.1,k=Math.sin(ct)*9.1;if(Math.abs(k)<1.7||Mt>7&&Math.abs(k)<3.4)continue;const tt=new Qt;tt.position.y=s,P.add(tt),I(tt,Mt,k,.95)}}function b0(i){const{scene:t}=i,e=new Qt;i.clouds=e,t.add(e);const n=(()=>{const f=document.createElement("canvas");f.width=f.height=128;const m=f.getContext("2d");for(let p=0;p<8;p++){const v=36+i.rng()*56,x=46+i.rng()*36,d=20+i.rng()*24,h=m.createRadialGradient(v,x,0,v,x,d);h.addColorStop(0,"rgba(255,255,255,.5)"),h.addColorStop(1,"rgba(255,255,255,0)"),m.fillStyle=h,m.fillRect(0,0,128,128)}return new Ze(f)})(),r=new Yi({map:n,color:16777215,transparent:!0,opacity:.8,depthWrite:!1});i.cloudMat=r;for(let f=0;f<80;f++){const m=f<14,p=i.rng()*Math.PI*2,v=m?i.rng()*12:13+Math.pow(i.rng(),.8)*30,x=8+i.rng()*10,d=new zr(r);d.scale.set(x*1.8,x*.6,1),d.position.set(Math.cos(p)*v,(m?-15:-7)-i.rng()*5,Math.sin(p)*v),e.add(d)}const s=180,o=new Float32Array(s*3),a=[];i.N=s,i.fp=o,i.seeds=a;for(let f=0;f<s;f++){const m=i.rng()*Math.PI*2,p=i.rng()*11;a.push([Math.cos(m)*p,1+i.rng()*5,Math.sin(m)*p,i.rng()*10])}const l=new Jt;i.fGeo=l,l.setAttribute("position",new fe(o,3));const c=(()=>{const f=document.createElement("canvas");f.width=f.height=32;const m=f.getContext("2d"),p=m.createRadialGradient(16,16,0,16,16,16);return p.addColorStop(0,"rgba(255,255,255,1)"),p.addColorStop(.35,"rgba(255,255,255,.7)"),p.addColorStop(1,"rgba(255,255,255,0)"),m.fillStyle=p,m.fillRect(0,0,32,32),new Ze(f)})(),u=new Wr({map:c,size:.16,color:16769440,transparent:!0,opacity:.8,depthWrite:!1});i.fMat=u,t.add(new so(l,u))}function E0(i){const{bloom:t,cloudMat:e,envScene:n,fMat:r,fallLum:s,hemi:o,lanternMats:a,pmrem:l,renderer:c,scene:u,skyU:f,sun:m,unlit:p,windowMats:v}=i;i.phaseName=O,i.updateEnv=N;const x={nang:{name:"Nắng",icon:"☀",c:0,r:0,f:0,storm:0},itmay:{name:"Có mây",icon:"⛅",c:.45,r:0,f:0,storm:0},amu:{name:"Âm u",icon:"☁",c:.9,r:0,f:.15,storm:0},muaphun:{name:"Mưa phùn",icon:"🌦",c:.8,r:.3,f:.2,storm:0},mua:{name:"Mưa",icon:"🌧",c:.95,r:.75,f:.25,storm:0},giong:{name:"Giông",icon:"⛈",c:1,r:1,f:.3,storm:1},suong:{name:"Sương mù",icon:"🌫",c:.5,r:0,f:1,storm:0}};i.WEATHER=x;const d=C=>C===0?"nang":C<=2?"itmay":C===3?"amu":C===45||C===48?"suong":C>=51&&C<=57?"muaphun":C>=95?"giong":C>=61&&C<=67||C>=80&&C<=82?"mua":"amu";i.wmoToWeather=d;const h={weather:"nang",temp:31,source:"Giả lập",sunrise:5.75,sunset:17.75,hourOverride:null,wind:8};i.ENV=h;const y={c:0,r:0,f:0,storm:0};i.cur=y;let _=0,w=6;i.mode="duong",i.modeT=0;const D={dayTop:new Dt(3111116),dayHor:new Dt(8830182),nightTop:new Dt(395800),nightHor:new Dt(1779527),goldTop:new Dt(4610191),goldHor:new Dt(15768158),grayDay:new Dt(9148067),grayNight:new Dt(1448742),fog:new Dt(13226714),sunLow:new Dt(16753242),sunHigh:new Dt(16773590),moon:new Dt(11123942)},P=new Dt,I=new W,F=()=>{const C=new Date;return C.getHours()+C.getMinutes()/60},M=()=>h.hourOverride??F();i.hourNow=M;const A=C=>`${String(Math.floor(C)%24).padStart(2,"0")}:${String(Math.round(C%1*60)%60).padStart(2,"0")}`;i.fmtH=A;function K(C){const U=h.sunrise,q=h.sunset,Z=(C-U)/(q-U);if(Z>=0&&Z<=1)return{e:Math.sin(Math.PI*Z),f:Z,day:!0};const it=((C<U?C+24:C)-q)/(24-(q-U));return{e:-Math.sin(Math.PI*it),f:it,day:!1}}function O(C){const U=h.sunrise,q=h.sunset;return Math.abs(C-U)<.6?"Bình minh":Math.abs(C-q)<.6?"Hoàng hôn":C>U&&C<10.5?"Buổi sáng":C>=10.5&&C<13.5?"Buổi trưa":C>=13.5&&C<q?"Buổi chiều":C>=q&&C<22?"Buổi tối":"Đêm khuya"}const z=(C,U,q)=>{const Z=Math.min(1,Math.max(0,(q-C)/(U-C)));return Z*Z*(3-2*Z)},S=1600,E=new Float32Array(S*6),g=new Float32Array(S);for(let C=0;C<S;C++){const U=i.rng()*Math.PI*2,q=Math.sqrt(i.rng())*14,Z=i.rng()*20-2;E.set([Math.cos(U)*q,Z,Math.sin(U)*q,Math.cos(U)*q+.06,Z+.55,Math.sin(U)*q],C*6),g[C]=15+i.rng()*6}const T=new Jt;T.setAttribute("position",new fe(E,3));const L=new Tm(T,new Yl({color:12375788,transparent:!0,opacity:.5,depthWrite:!1}));L.frustumCulled=!1,u.add(L);function N(C,U){const q=x[h.weather],Z=M(),{e:it,f:ut,day:gt}=K(Z);for(const V of["c","r","f","storm"])y[V]+=(q[V]-y[V])*Math.min(1,C*.8);const xt=z(-.05,.3,it),Et=1-xt,lt=Math.exp(-Math.pow((it-.04)/.13,2))*(1-y.c*.8);i.modeT=Et;const ct=Et>.5?"am":"duong";ct!==i.mode&&(i.mode=ct),f.top.value.copy(D.nightTop).lerp(D.dayTop,xt).lerp(D.goldTop,lt*.5).lerp(P.copy(D.grayNight).lerp(D.grayDay,xt),y.c*.75),f.hor.value.copy(D.nightHor).lerp(D.dayHor,xt).lerp(D.goldHor,lt*.85).lerp(P.copy(D.grayNight).lerp(D.grayDay,xt),y.c*.7),f.night.value=Et,f.cloud.value=y.c,f.time.value=U,f.flash.value=_,f.storm.value=y.storm,gt?I.set(Math.cos(Math.PI*ut)*.9,Math.max(it,.05),.35):I.set(Math.cos(Math.PI*ut)*.9,Math.max(-it,.12),-.3),I.normalize(),f.sunDir.value.copy(I),m.position.set(I.x,Math.max(I.y,.32),I.z).normalize().multiplyScalar(30);const Mt=z(-.14,.2,it);gt?(m.color.copy(D.sunLow).lerp(D.sunHigh,z(.05,.45,it)),m.intensity=3*(.45+.55*z(0,.5,it))*Mt*(1-y.c*.7)):(m.color.copy(D.moon),m.intensity=.5*(1-y.c*.8)),o.intensity=(.32+.68*Mt)*(1-y.c*.2)*.5+lt*.5+_*2.2,o.color.set(14412031).lerp(D.goldHor,lt*.45);const k=Math.max(y.f,y.r*.5);u.fog.near=50-44*k,u.fog.far=120-82*k,u.fog.color.copy(f.hor.value).lerp(P.copy(D.fog).multiplyScalar(.2+.8*xt),y.f*.6);const tt=Math.max(Et,y.c*.55);a.forEach(V=>V.emissiveIntensity=.35+2.05*tt),v.forEach(V=>V.emissiveIntensity=.08+1.02*tt),t.strength=.18+.72*Et,c.toneMappingExposure=(.88+.1*Et)*(1-.1*y.c),r.opacity=(.04+.86*Et)*(1-y.r),r.color.setRGB(1,1-.18*Et,1-.52*Et),e.color.setScalar((1-.9*Et)*(1-.3*y.c)).lerp(f.hor.value,.3);const G=(.2+.8*xt)*(1-.25*y.c)+_;s.value=G;for(const[V,et]of p)V.color.copy(et).multiplyScalar(G);i.envAcc+=C;const H=[xt,lt,y.c,y.storm,ut].map(V=>Math.round(V*16)).join();if(H!==i.envKey&&i.envAcc>.5){i.envKey=H,i.envAcc=0,f.gain.value=.5+.45*lt+.2*Et;const V=l.fromScene(n,0,.1,200);f.gain.value=1,u.environment=V.texture,i.envRT?.dispose(),i.envRT=V}if(L.visible=y.r>.02,L.material.opacity=.25+.4*y.r,L.visible){const V=Math.floor(S*y.r);T.setDrawRange(0,V*2);for(let et=0;et<V;et++){const rt=et*6,R=g[et]*C*(1+y.storm*.4);E[rt+1]-=R,E[rt+4]-=R,E[rt+1]<-3&&(E[rt+1]+=21,E[rt+4]+=21)}T.attributes.position.needsUpdate=!0}_*=Math.pow(.004,C),y.storm>.5&&(w-=C,w<0&&(_=1,i.setTimeout(()=>_=.7,120),w=5+i.rng()*9,i.Sound.thunder(.4+i.rng()*1.5)))}}function T0(i){const{ENV:t,WEATHER:e,fmtH:n,hourNow:r,phaseName:s,renderer:o,wmoToWeather:a}=i;i.renderWx=f,i.setMode=m,i.setWeather=p;const l=document.getElementById("wxBtn"),c=document.getElementById("wxPanel"),u=document.getElementById("wxHour");function f(){const v=e[t.weather],x=r();l.textContent=`${v.icon} ${t.temp!=null?Math.round(t.temp)+"°":""} · ${s(x)}`,document.getElementById("wxIcon").textContent=v.icon,document.getElementById("wxTitle").textContent=`${v.name}${t.temp!=null?" · "+Math.round(t.temp)+"°C":""}`,document.getElementById("wxSub").textContent=`${s(x)} · ${n(x)} · nguồn: ${t.source}`,document.getElementById("wxHourLbl").textContent=n(x),document.activeElement!==u&&(u.value=x),document.getElementById("wxTime").innerHTML=[["real","Theo giờ thực"],[t.sunrise,"Bình minh"],[12,"Trưa"],[t.sunset,"Hoàng hôn"],[21,"Tối"],[2,"Khuya"]].map(([d,h])=>`<button class="wx-chip ${(d==="real"?t.hourOverride==null:t.hourOverride===d)?"on":""}" data-h="${d}">${h}</button>`).join(""),document.getElementById("wxChips").innerHTML=Object.entries(e).map(([d,h])=>`<button class="wx-chip ${d===t.weather?"on":""}" data-w="${d}">${h.icon} ${h.name}</button>`).join(""),document.getElementById("wxNote").textContent=`Bình minh ${n(t.sunrise)} · Hoàng hôn ${n(t.sunset)}. Bản thật lấy thời tiết từ Open-Meteo qua server; prototype đang giả lập.`,c.querySelectorAll("[data-h]").forEach(d=>d.onclick=()=>{t.hourOverride=d.dataset.h==="real"?null:+d.dataset.h,f()}),c.querySelectorAll("[data-w]").forEach(d=>d.onclick=()=>{t.weather=d.dataset.w,t.source="Xem thử",f()})}u.oninput=()=>{t.hourOverride=+u.value,f()},l.onclick=v=>{v.stopPropagation(),document.getElementById("musicPanel").classList.remove("on"),c.classList.toggle("on")},c.addEventListener("pointerdown",v=>v.stopPropagation()),o.domElement.addEventListener("pointerdown",()=>c.classList.remove("on")),i.setInterval(f,2e4);function m(v){t.hourOverride=v==="am"?21:10,f()}function p(v={}){v.code!=null&&(t.weather=a(v.code)),v.weather&&e[v.weather]&&(t.weather=v.weather),v.temp!=null&&(t.temp=v.temp),v.wind!=null&&(t.wind=v.wind);const x=d=>typeof d=="number"?d:(h=>h.getHours()+h.getMinutes()/60)(new Date(d));v.sunrise&&(t.sunrise=x(v.sunrise)),v.sunset&&(t.sunset=x(v.sunset)),t.source=v.source??"Open-Meteo",f()}}function w0(i){const{CRIT:t,LVL:e,STATS:n,TOWERS:r}=i;i.renderStats=a,i.checkCrit=c,i.push=x;const s=document.getElementById("stats");for(const[d,h]of Object.entries(n)){const y=document.createElement("div");y.className="stat glass",y.innerHTML=`<div class="row">${h.label}<b>0</b></div><div class="bar"><i></i></div>`,y.onclick=()=>i.select(h.tower),s.appendChild(y),h.el=y,h.wasCrit=!1}const o=d=>d<t?"var(--bad)":d<50?"var(--warn)":"var(--ok)";i.statColor=o;function a(){for(const d of Object.values(n)){const h=Math.round(d.v);d.el.querySelector("b").textContent=String(h);const y=d.el.querySelector("i");y.style.width=h+"%",y.style.background=o(h),d.el.classList.toggle("crit",d.v<t)}}function l(d){if(d){for(const[h,y]of Object.entries(d))n[h]&&(n[h].v=wl.clamp(n[h].v+y,0,100));c(),a(),i.current&&i.renderSheet(i.current)}}function c(){for(const d of Object.values(n)){const h=d.v<t;h&&!d.wasCrit&&x({from:d.tower,lvl:"bad",text:`${d.label} xuống thấp (${Math.round(d.v)}). Cần xử lý.`}),d.wasCrit=h}}const u=d=>Object.values(n).some(h=>h.tower===d&&h.v<t);i.towerCrit=u;const f=[];i.notifs=f;let m=0;const p=document.getElementById("toasts");function v(d){const h=document.createElement("div");for(h.className="toast glass",h.innerHTML=`<span class="dot" style="background:${e[d.lvl]}"></span><div>${d.text}<small>${r[d.from]?.name??"Hệ thống"} · vừa xong</small></div>`,h.onclick=()=>i.select("kieulau"),p.prepend(h);p.children.length>2;)p.lastChild.remove();i.setTimeout(()=>{h.classList.add("out"),i.setTimeout(()=>h.remove(),350)},3600)}function x(d){const h={id:++m,from:d.from??"center",lvl:d.lvl??"info",text:d.text,time:new Date,read:!1};l(d.effect),v(h);const y=()=>{i.Sound.chime(h.lvl),f.unshift(h),f.length>60&&f.pop(),i.bellKick=1,i.updateLabels(),i.current&&i.renderSheet(i.current)};h.from==="kieulau"?y():i.fly(h.from,y,e[h.lvl])}}function A0(i){const{AMBER_Y:t,BRIDGE_END:e,PATHS:n,PLAZA_X:r,TOP:s,amber:o,frontXZ:a,scene:l,stoneLantern:c}=i;i.fly=p;const u=[];i.flights=u;const f=(v,x,d)=>new W(v,s+x,d);function m(v){if(!n[v])return new en([o.position.clone(),f(.8,t-s-1.6,.4),f(0,3,0)]);const[x,d]=a(v),h=n[v].side;return new en([f(x,.35,d),f(h*r,.35,0),f(h*e,.5,0),f(h*1.5,1.2,0),f(0,2.1,0)])}function p(v,x,d){const h=new Ft(new ne(.16,10,8),new De({color:d})),y=new Ft(new ne(.32,10,8),new De({color:d,transparent:!0,opacity:.25,depthWrite:!1}));h.add(y),l.add(h);const _=m(v);u.push({m:h,curve:_,t:0,speed:4.2/_.getLength(),done:x})}for(const v of Object.keys(n)){const[x,d]=a(v),h=n[v].side,y=(x+h*r)/2,_=d/2,w=Math.hypot(h*r-x,-d),D=d/w*.75,P=(h*r-x)/w*.75,I=new Qt;I.position.y=s,l.add(I),c(I,y+D,_-P,.6)}}function R0(i){const{TOP:t,TOWERS:e,amber:n,camera:r,notifs:s,towerCrit:o}=i;i.updateLabels=l,i.placeLabels=u;const a={};for(const[f,m]of Object.entries(e)){const p=document.createElement("div");p.className="lbl glass",p.innerHTML=`<span class="w"></span>${m.name}<span class="b"></span>`,p.onclick=()=>i.select(f),i.root.appendChild(p),a[f]=p}function l(){const f=s.filter(p=>!p.read).length,m=a.kieulau.querySelector(".b");m.textContent=f>99?"99+":f,m.classList.toggle("on",f>0);for(const p in a)a[p].classList.toggle("crit",o(p))}const c=new W;function u(){for(const[f,m]of Object.entries(e)){c.copy(m.vec),c.y=f==="center"?n.position.y+1.7:t+m.top+.35,c.project(r);const p=a[f];if(c.z>1){p.style.display="none";continue}p.style.display="flex",p.style.transform=`translate(${(c.x*.5+.5)*innerWidth}px, ${(-c.y*.5+.5)*innerHeight}px) translate(-50%,-100%)`}}}function C0(i){const{LVL:t,STATS:e,TOP:n,TOWERS:r,amber:s,camera:o,controls:a,hitTargets:l,notifs:c,push:u,renderer:f,setMode:m,statColor:p,updateLabels:v}=i;i.renderSheet=y,i.select=_,i.home=w;const x=document.getElementById("sheet"),d=document.getElementById("sheetBody");i.current=null,i.camGoal=null;const h=F=>F.toLocaleTimeString("vi-VN",{hour:"2-digit",minute:"2-digit"});function y(F){const M=r[F],A=Object.entries(e).filter(([,z])=>z.tower===F);let K=`<h2>${M.name}</h2><div class="role">${M.role}</div>`;for(const[,z]of A)K+=`<div class="kv"><span>${z.label} · ${z.src}</span><b style="color:${p(z.v)}">${Math.round(z.v)}/100</b></div>`;if(F==="center"){const z=Object.values(e).reduce((S,E)=>S.v<E.v?S:E);K+=`<div class="kv"><span>Chỉ số thấp nhất</span><b style="color:${p(z.v)}">${z.label} ${Math.round(z.v)}</b></div>`,K+=`<div class="kv"><span>Chế độ</span><b>${i.mode==="duong"?"Dương (ngày)":"Âm (đêm)"}</b></div>`}K+=`<div class="acts">${M.acts.map((z,S)=>`<button class="btn" data-i="${S}">${z[0]}</button>`).join("")}</div>`;const O=F==="kieulau"?c:c.filter(z=>z.from===F);K+=`<div class="sec">${F==="kieulau"?"Thông báo":"Hoạt động gần đây"}</div>`,K+=O.length?O.slice(0,20).map(z=>`<div class="item ${z.read?"read":""}"><span class="dot" style="background:${t[z.lvl]}"></span><div>${z.text}<small>${r[z.from]?.name} · ${h(z.time)}</small></div></div>`).join(""):'<div class="empty">Chưa có gì.</div>',d.innerHTML=K,d.querySelectorAll(".btn").forEach(z=>z.onclick=()=>{const[S,E,g,T]=M.acts[+z.dataset.i];if(T==="readAll"){c.forEach(L=>L.read=!0),v(),y(F);return}if(T==="toggle"){m(i.mode==="duong"?"am":"duong"),y(F);return}u({from:F,lvl:"ok",text:g,effect:E})})}function _(F){if(!r[F])return;i.current=F,y(F),x.classList.add("on"),i.hint.style.opacity=0;const M=r[F],A=F==="center"?s.position.clone():M.vec.clone().setY(n+M.top*.45),K=F==="center"?new W(0,0,1):F==="kieulau"?new W(.45,0,-1).normalize():M.vec.clone().setY(0).normalize().negate().applyAxisAngle(new W(0,1,0),F==="nghisu"?-.85:.85),O=(innerWidth<innerHeight?13:9)*(F==="nghisu"?.95:1);i.camGoal={pos:A.clone().add(K.multiplyScalar(O)).add(new W(0,O*.4,0)),target:A.clone().add(new W(0,innerWidth<innerHeight?-1.8:0,0))}}function w(){const F=innerWidth<innerHeight?1.8:1;i.camGoal={pos:new W(14,15,20).multiplyScalar(F),target:new W(0,innerWidth<innerHeight?-.5:1,0)}}document.getElementById("close").onclick=()=>{x.classList.remove("on"),i.current=null,w()},a.addEventListener("start",()=>i.camGoal=null);const D=new Gr,P=new wt;let I=null;f.domElement.addEventListener("pointerdown",F=>I=[F.clientX,F.clientY]),f.domElement.addEventListener("pointerup",F=>{if(!I||Math.hypot(F.clientX-I[0],F.clientY-I[1])>8)return;P.set(F.clientX/innerWidth*2-1,-(F.clientY/innerHeight)*2+1),D.setFromCamera(P,o);const M=D.intersectObjects(l,!1)[0];M&&_(M.object.userData.id)})}function P0(i){const{AMBER_Y:t,CRIT:e,ENV:n,N:r,R:s,RANDOM_EVENTS:o,STATS:a,TOP:l,TOWERS:c,WY:u,amber:f,amberLight:m,animateNature:p,animateRiver:v,animateSplash:x,camera:d,checkCrit:h,clouds:y,composer:_,controls:w,coreMat:D,fGeo:P,fallBaseTex:I,fallHiTex:F,fallTex:M,flights:A,foam:K,fp:O,halos:z,home:S,koi:E,mist:g,placeLabels:T,poolMat:L,push:N,renderStats:C,renderer:U,ripple:q,riverCurve:Z,scene:it,seeds:ut,shell:gt,towerCrit:xt,updateEnv:Et,waterMat:lt,waterTex:ct,waterU:Mt}=i;i.loop=b;const k=new Jl;let tt=0,G=4;i.bellKick=0;const H=document.getElementById("clock"),V=document.getElementById("hint");i.hint=V;const et=new Dt,rt=new Dt(16757575),R=new Dt(16731469);S(),d.position.copy(i.camGoal.pos),w.target.copy(i.camGoal.target),d.position.multiplyScalar(1.25);function b(){const Y=Math.min(k.getDelta(),.05),j=k.elapsedTime;if(Et(Y,j),tt+=Y,tt>1){tt=0;for(const J of Object.values(a))J.v=Math.max(0,J.v-J.decay);h(),C()}G-=Y,G<0&&(G=7+i.rng()*6,N(o[Math.floor(i.rng()*o.length)]));const Q=Object.values(a).some(J=>J.v<e);f.position.y=t+Math.sin(j*1.4)*.18,gt.rotation.y+=Y*.4,gt.rotation.x+=Y*.2,z[0].rotation.set(Math.PI/2+Math.sin(j*.7)*.3,j*.5,0),z[1].rotation.set(Math.PI/2.4,-j*.35,Math.cos(j*.6)*.3),D.emissive.copy(Q?R:new Dt(16751918)),D.emissiveIntensity=1.2+Math.sin(j*(Q?6:2))*.35,m.color.copy(D.emissive);for(const[J,nt]of Object.entries(c)){if(!nt.aura)continue;const st=xt(J),ft=i.current===J;et.copy(st?R:rt),nt.aura.material.color.lerp(et,.1),nt.aura.material.opacity=(ft?.7:.28)+Math.sin(j*(st?6:1.5))*(st?.25:.08)}i.bellKick*=.985,c.kieulau.group.userData.bell.rotation.z=Math.sin(j*9)*.45*i.bellKick;for(let J=A.length-1;J>=0;J--){const nt=A[J];nt.t+=Y*nt.speed,nt.m.position.copy(nt.curve.getPoint(Math.min(nt.t,1))),nt.m.scale.setScalar(1+Math.sin(nt.t*Math.PI)*.6),nt.t>=1&&(it.remove(nt.m),nt.m.geometry.dispose(),A.splice(J,1),nt.done())}for(let J=0;J<r;J++){const nt=ut[J];O[J*3]=nt[0]+Math.sin(j*.3+nt[3])*.6,O[J*3+1]=nt[1]+Math.sin(j*.8+nt[3]*2)*.4,O[J*3+2]=nt[2]+Math.cos(j*.25+nt[3])*.6}if(P.attributes.position.needsUpdate=!0,y.rotation.y+=Y*.01,ct.offset.y-=Y*.35,M.offset.y+=Y*1.4,I.offset.y-=Y*.9,F.offset.y-=Y*1.9,v(j),x(j),K.children.forEach(J=>{const nt=J.userData,st=(j*.7+nt.ph)%1,ft=nt.s*(.35+st*1);J.position.set(nt.x,nt.y+st*.55*nt.s,nt.z-st*.3),J.scale.set(ft,ft*.75,1),J.material.opacity=.55*(1-st)*(1-st)}),g.children.forEach((J,nt)=>{const st=(j*.25+nt/7)%1;J.position.set(-s-.4-st*1.2,l-7.2+st*.8,Math.sin(nt*2.1)*.8),J.material.opacity=.4*(1-st),J.scale.set(2+st*3,1.4+st*2,1)}),i.nextJump-=Y,i.nextJump<0){const J=E[Math.floor(i.rng()*E.length)];J.userData.jt<0&&(J.userData.jt=0,q(J.position.x,J.position.z)),i.nextJump=8+i.rng()*10}for(const J of E){const nt=J.userData;nt.u=(nt.u+Y*nt.speed)%.97;const st=Z.getPointAt(nt.u),ft=Z.getTangentAt(nt.u),yt=Math.sin(j*3+nt.side*9)*.12;if(J.position.set(st.x-ft.z*(nt.side+yt),u-.1,st.z+ft.x*(nt.side+yt)),J.lookAt(J.position.x+ft.x,J.position.y,J.position.z+ft.z),nt.tail.rotation.y=Math.sin(j*8+nt.side*5)*.5,nt.jt>=0){nt.jt+=Y*1.4;const At=Math.min(nt.jt,1);if(J.position.y=u-.1+Math.sin(Math.PI*At)*.6,J.rotateX(-Math.cos(Math.PI*At)*.9),nt.jt>=1){nt.jt=-1;for(let at=0;at<3;at++)q(J.position.x+(i.rng()-.5)*.2,J.position.z+(i.rng()-.5)*.2)}}}p(Y,j),Mt.uTime.value=j,lt.emissiveIntensity=L.emissiveIntensity=.05+i.modeT*.2;for(const J of c.nghisu.group.userData.flags){const nt=J.geometry.attributes.position;for(let st=0;st<nt.count;st++){const ft=nt.getX(st)+.3;nt.setZ(st,Math.sin(j*(2.5+n.wind*.2)-ft*7)*(.03+n.wind*.005)*ft)}nt.needsUpdate=!0}i.camGoal&&(d.position.lerp(i.camGoal.pos,.06),w.target.lerp(i.camGoal.target,.06),d.position.distanceTo(i.camGoal.pos)<.05&&(i.camGoal=null)),w.update(),_.render(),T(),H.textContent="Amber · "+new Date().toLocaleTimeString("vi-VN",{hour:"2-digit",minute:"2-digit"}),i.disposed||(i.raf=requestAnimationFrame(b))}i.listen(window,"resize",()=>{d.aspect=innerWidth/innerHeight,d.updateProjectionMatrix(),U.setSize(innerWidth,innerHeight),_.setSize(innerWidth,innerHeight),i.current||S()})}function L0(i){const{ENV:t,camera:e,cur:n,renderer:r}=i,s=(()=>{let o=null,a,l,c,u,f,m,p,v,x,d=null,h=null,y=null,_=!1,w=0,D=0,P=5,I=8,F=0,M=0,A=null;const K={duong:{steps:[0,2,5,7,9],root:293.66,beat:.42},am:{steps:[0,3,5,7,10],root:261.63,beat:.62}},O=[{name:"Đàn tranh",sub:"Tự sinh theo Âm/Dương",type:"gen",style:"tranh"},{name:"Sáo trúc",sub:"Tự sinh theo Âm/Dương",type:"gen",style:"sao"},{name:"Chỉ thiên nhiên",sub:"Thác, gió, chim, dế",type:"none"}],z=(()=>{try{return JSON.parse(localStorage.getItem("amber-music")||"{}")}catch{return{}}})(),S=()=>{try{localStorage.setItem("amber-music",JSON.stringify({vol:L.value,nat:N.value,chime:C.checked,idx:O[w]?.type==="file"?0:w}))}catch{}},E=j=>document.getElementById(j),g=E("musicPanel"),T=E("musicBtn"),L=E("mpVol"),N=E("mpNat"),C=E("mpChime"),U=E("mpList");z.vol!=null&&(L.value=z.vol),z.nat!=null&&(N.value=z.nat),z.chime!=null&&(C.checked=z.chime),z.idx&&(w=z.idx);function q(){if(o)return;o=new(window.AudioContext||window.webkitAudioContext),a=o.createGain(),a.connect(o.destination),c=o.createGain(),u=o.createGain(),f=o.createGain(),f.gain.value=.5,[c,u,f].forEach(Pt=>Pt.connect(a)),l=o.createGain(),l.connect(c);const j=o.createBuffer(2,o.sampleRate*3,o.sampleRate);for(let Pt=0;Pt<2;Pt++){const zt=j.getChannelData(Pt);for(let kt=0;kt<zt.length;kt++)zt[kt]=(Math.random()*2-1)*Math.pow(1-kt/zt.length,3)}const Q=o.createConvolver();Q.buffer=j;const J=o.createGain();J.gain.value=.38,l.connect(Q),Q.connect(J),J.connect(c),f.connect(Q),x=o.createBuffer(1,o.sampleRate*2,o.sampleRate);const nt=x.getChannelData(0);for(let Pt=0;Pt<nt.length;Pt++)nt[Pt]=Math.random()*2-1;const st=Z(),ft=o.createBiquadFilter(),yt=o.createBiquadFilter();ft.type="lowpass",ft.frequency.value=1400,yt.type="highpass",yt.frequency.value=180,m=o.createGain(),st.connect(yt),yt.connect(ft),ft.connect(m),m.connect(u);const At=Z(),at=o.createBiquadFilter();at.type="bandpass",at.frequency.value=420,at.Q.value=.6,p=o.createGain(),p.gain.value=.12;const Rt=o.createOscillator(),X=o.createGain();Rt.frequency.value=.07,X.gain.value=.1,Rt.connect(X),X.connect(p.gain),Rt.start(),At.connect(at),at.connect(p),p.connect(u);const mt=Z(),Tt=o.createBiquadFilter(),St=o.createBiquadFilter();Tt.type="highpass",Tt.frequency.value=900,St.type="lowpass",St.frequency.value=7e3,v=o.createGain(),v.gain.value=0,mt.connect(Tt),Tt.connect(St),St.connect(v),v.connect(u),y||(y=new Audio,y.crossOrigin="anonymous",y.onended=()=>rt()),o.createMediaElementSource(y).connect(c),it(),i.setInterval(ut,250)}function Z(){const j=o.createBufferSource();return j.buffer=x,j.loop=!0,j.start(),j}function it(){if(!o)return;const j=o.currentTime;c.gain.setTargetAtTime((+L.value/100)**2*.9,j,.1),u.gain.setTargetAtTime((+N.value/100)**2,j,.1)}function ut(){const j=e.position.distanceTo(new W(7.2,2,-1));m.gain.setTargetAtTime(.05+.55*Math.max(0,1-j/38)**2,o.currentTime,.3),v.gain.setTargetAtTime(n.r*.55,o.currentTime,.8),p.gain.setTargetAtTime(.1+t.wind*.006+n.storm*.12,o.currentTime,1)}const gt=(j,Q)=>j.root*Math.pow(2,(j.steps[(Q%5+5)%5]+12*Math.floor(Q/5)-12)/12);function xt(j,Q,J=.32,nt=!1){const st=o.createOscillator(),ft=o.createOscillator(),yt=o.createGain(),At=o.createGain(),at=o.createBiquadFilter(),Rt=o.createOscillator(),X=o.createGain();st.type="triangle",ft.type="sine",ft.frequency.value=j*2,At.gain.value=.22,st.frequency.setValueAtTime(nt?j*1.06:j,Q),nt&&st.frequency.exponentialRampToValueAtTime(j,Q+.22),Rt.frequency.value=5.2,X.gain.setValueAtTime(0,Q),X.gain.linearRampToValueAtTime(j*.012,Q+.8),Rt.connect(X),X.connect(st.frequency),at.type="lowpass",at.frequency.setValueAtTime(j*9,Q),at.frequency.exponentialRampToValueAtTime(j*1.6,Q+1.4),yt.gain.setValueAtTime(0,Q),yt.gain.linearRampToValueAtTime(J,Q+.006),yt.gain.exponentialRampToValueAtTime(8e-4,Q+2.8),st.connect(at),ft.connect(At),At.connect(at),at.connect(yt),yt.connect(l);for(const mt of[st,ft,Rt])mt.start(Q),mt.stop(Q+2.9)}function Et(j,Q,J,nt=.13){const st=o.createOscillator(),ft=o.createGain(),yt=o.createOscillator(),At=o.createGain();st.type="sine",st.frequency.setValueAtTime(j*.985,Q),st.frequency.linearRampToValueAtTime(j,Q+.12),yt.frequency.value=4.8,At.gain.setValueAtTime(0,Q),At.gain.linearRampToValueAtTime(j*.009,Q+Math.min(.5,J*.6)),yt.connect(At),At.connect(st.frequency),ft.gain.setValueAtTime(0,Q),ft.gain.linearRampToValueAtTime(nt,Q+.18),ft.gain.setValueAtTime(nt,Q+J-.1),ft.gain.exponentialRampToValueAtTime(8e-4,Q+J+.5);const at=o.createBufferSource(),Rt=o.createBiquadFilter(),X=o.createGain();at.buffer=x,Rt.type="bandpass",Rt.frequency.value=j*2,Rt.Q.value=4,X.gain.setValueAtTime(0,Q),X.gain.linearRampToValueAtTime(nt*.25,Q+.1),X.gain.exponentialRampToValueAtTime(5e-4,Q+J+.3),at.connect(Rt),Rt.connect(X),X.connect(l),st.connect(ft),ft.connect(l);for(const mt of[st,yt,at])mt.start(Q),mt.stop(Q+J+.6)}function lt(j){if(!o)return;const Q=o.currentTime;if(j&&!d){const J=K[i.mode];d=[1,1.5].map((nt,st)=>{const ft=o.createOscillator(),yt=o.createGain();return ft.type="sine",ft.frequency.value=J.root/2*nt,yt.gain.setValueAtTime(0,Q),yt.gain.linearRampToValueAtTime(st?.025:.05,Q+3),ft.connect(yt),yt.connect(l),ft.start(),{o:ft,g:yt,m:nt}})}!j&&d&&(d.forEach(({o:J,g:nt})=>{nt.gain.setTargetAtTime(0,Q,.5),J.stop(Q+3)}),d=null)}function ct(j){const Q=o.createOscillator(),J=o.createGain(),nt=2+Math.floor(Math.random()*3),st=2400+Math.random()*900;Q.type="sine",J.gain.value=0;for(let ft=0;ft<nt;ft++){const yt=j+ft*.11;Q.frequency.setValueAtTime(st,yt),Q.frequency.exponentialRampToValueAtTime(st*1.5,yt+.07),J.gain.setValueAtTime(0,yt),J.gain.linearRampToValueAtTime(.05,yt+.01),J.gain.linearRampToValueAtTime(0,yt+.08)}Q.connect(J),J.connect(u),Q.start(j),Q.stop(j+nt*.11+.1)}function Mt(j){const Q=o.createOscillator(),J=o.createGain();Q.frequency.value=4300+Math.random()*300,J.gain.value=0;for(let nt=0;nt<4;nt++){const st=j+nt*.045;J.gain.setValueAtTime(0,st),J.gain.linearRampToValueAtTime(.022,st+.008),J.gain.linearRampToValueAtTime(0,st+.03)}Q.connect(J),J.connect(u),Q.start(j),Q.stop(j+.25)}function k(j){const Q=O[w],J=K[i.mode];if(Math.random()<(i.mode==="duong"?.05:0)&&ct(j+Math.random()*.3),Math.random()<(i.mode==="am"?.22:0)&&Mt(j+Math.random()*.3),Q.type==="gen"){if(F>0){F--;return}if(I<=0){I=6+Math.floor(Math.random()*6),F=2+Math.floor(Math.random()*4),P=Math.random()<.5?5:7;return}if(P=Math.max(2,Math.min(11,P+[-2,-1,-1,0,1,1,2][Math.floor(Math.random()*7)])),Q.style==="tranh")Math.random()<.78&&(xt(gt(J,P),j,.26+Math.random()*.1,Math.random()<.25),I--),Math.random()<.14&&xt(gt(J,P-5),j+.02,.14);else{if(M>0){M--;return}const nt=[1,2,2,3][Math.floor(Math.random()*4)];M=nt-1,Et(gt(J,P+2),j,nt*J.beat*.95),I--,Math.random()<.3&&xt(gt(J,P-5),j,.12)}}}function tt(){if(A!==i.mode&&d){const j=K[i.mode];d.forEach(Q=>Q.o.frequency.setTargetAtTime(j.root/2*Q.m,o.currentTime,1.5))}for(A=i.mode;D<o.currentTime+.3;)k(D),D+=K[i.mode].beat}function G(){const j=O[w];y.pause(),lt(j.type==="gen"),j.type==="file"&&(y.src=j.url,y.play().catch(()=>{})),D=o.currentTime+.1,I=4,F=0,b()}async function H(){q(),await o.resume(),_=!0,a.gain.cancelScheduledValues(o.currentTime),a.gain.setTargetAtTime(1,o.currentTime,.3),G(),clearInterval(h),h=i.setInterval(tt,90)}function V(){_=!1,clearInterval(h),y?.pause(),lt(!1),o&&(a.gain.setTargetAtTime(0,o.currentTime,.2),i.setTimeout(()=>!_&&o.suspend(),900)),b()}function et(j){w=(j+O.length)%O.length,S(),_?G():b()}const rt=()=>et(w+1);function R(j){if(!o||!_||!C.checked)return;const Q=o.currentTime+.02,J=j==="bad"?587:j==="warn"?698:880,nt=j==="bad"?2:1;for(let st=0;st<nt;st++)[[1,1],[2.76,.45],[5.4,.22],[8.93,.1]].forEach(([ft,yt])=>{const At=o.createOscillator(),at=o.createGain(),Rt=Q+st*.35;At.frequency.value=J*ft,at.gain.setValueAtTime(0,Rt),at.gain.linearRampToValueAtTime(.16*yt,Rt+.004),at.gain.exponentialRampToValueAtTime(5e-4,Rt+2.4/ft**.3),At.connect(at),at.connect(f),At.start(Rt),At.stop(Rt+2.6)})}function b(){const j=O[w];E("mpTitle").textContent=j.name,E("mpSub").textContent=j.sub,E("mpPlayIcon").setAttribute("d",_?"M7 5h4v14H7zM13 5h4v14h-4z":"M8 5v14l11-7z"),T.classList.toggle("playing",_),U.innerHTML=O.map((Q,J)=>`<div class="mp-item ${J===w?"on":""}" data-i="${J}">${J===w&&_?"♫":"·"} ${Q.name}<small>${Q.type==="file"?"File":Q.type==="gen"?"Tự sinh":"Môi trường"}</small></div>`).join(""),U.querySelectorAll(".mp-item").forEach(Q=>Q.onclick=()=>{et(+Q.dataset.i),_||H()})}T.onclick=j=>{j.stopPropagation(),document.getElementById("wxPanel").classList.remove("on"),g.classList.toggle("on")},g.addEventListener("pointerdown",j=>j.stopPropagation()),r.domElement.addEventListener("pointerdown",()=>g.classList.remove("on")),E("mpPlay").onclick=()=>_?V():H(),E("mpNext").onclick=rt,E("mpPrev").onclick=()=>et(w-1),L.oninput=()=>{it(),S()},N.oninput=()=>{it(),S()},C.onchange=S,E("mpFile").onchange=j=>{const Q=O.length;for(const J of j.target.files)O.push({name:J.name.replace(/\.[^.]+$/,""),sub:"Nhạc của bạn",type:"file",url:URL.createObjectURL(J)});j.target.value="",O.length>Q&&(et(Q),_||H())},b();function Y(j){if(!o||!_)return;const Q=o.currentTime+j,J=o.createBufferSource(),nt=o.createBiquadFilter(),st=o.createGain();J.buffer=x,J.loop=!0,nt.type="lowpass",nt.frequency.setValueAtTime(900,Q),nt.frequency.exponentialRampToValueAtTime(120,Q+2.5),st.gain.setValueAtTime(0,Q),st.gain.linearRampToValueAtTime(.9,Q+.05),st.gain.exponentialRampToValueAtTime(.3,Q+.6),st.gain.exponentialRampToValueAtTime(.001,Q+3.5),J.connect(nt),nt.connect(st),st.connect(u),J.start(Q),J.stop(Q+3.6)}return i.disposeAudio=()=>{_=!1,clearInterval(h),y&&(y.pause(),y.removeAttribute("src")),O.forEach(j=>j.type==="file"&&URL.revokeObjectURL(j.url)),o?.close()},{chime:R,play:H,pause:V,go:et,thunder:Y}})();i.Sound=s}function D0(i){const{STATS:t,Sound:e,checkCrit:n,loop:r,push:s,renderStats:o,renderWx:a,select:l,setMode:c,setWeather:u,updateLabels:f}=i;i.api={push:s,setStat:(m,p)=>{t[m]&&(t[m].v=p,n(),o())},select:l,setMode:c,setWeather:u,music:e},o(),f(),a(),r(),i.setTimeout(()=>s({from:"kieulau",lvl:"info",text:"Chào mừng về Âm Dương Giới"}),1200)}const I0=[["config",qm],["core/scene",s0],["sky",o0],["materials",a0],["terrain",l0],["water",c0],["mountain",d0],["river-life",f0],["buildings/common",p0],["buildings/kieu-lau",m0],["buildings/tang-kinh",g0],["buildings/tra-dinh",_0],["buildings/nghi-su",v0],["buildings/index",x0],["amber",M0],["flora/trees",y0],["flora/nature",S0],["flora/atmosphere",b0],["weather",E0],["ui/weather-panel",T0],["state",w0],["flights",A0],["ui/labels",R0],["ui/sheet",C0],["loop",P0],["audio",L0],["api",D0]];function U0(i){let t=i>>>0;return()=>{t=t+1831565813>>>0;let e=t;return e=Math.imul(e^e>>>15,e|1),e^=e+Math.imul(e^e>>>7,e|61),((e^e>>>14)>>>0)/4294967296}}const N0=20261115;function O0(i,t={}){const e=new Set,n=new Set,r=[],s={lite:t.lite??!1,seed:t.seed??N0},o={root:i,opts:s,rng:U0(s.seed),disposed:!1,raf:0,setTimeout(a,l){const c=window.setTimeout(()=>{e.delete(c),o.disposed||a()},l);return e.add(c),c},setInterval(a,l){const c=window.setInterval(()=>{o.disposed||a()},l);return n.add(c),c},listen(a,l,c,u){a.addEventListener(l,c,u),r.push([a,l,c,u])},_clearTimers(){e.forEach(a=>clearTimeout(a)),n.forEach(a=>clearInterval(a)),e.clear(),n.clear();for(const[a,l,c,u]of r)a.removeEventListener(l,c,u);r.length=0}};return o}const F0=`
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
  <div class="wx-note" id="wxNote"></div>
</div>
<div id="sheet" class="glass"><button id="close">×</button><div id="sheetBody"></div></div>
<div id="hint" class="glass">Chạm vào toà nhà · kéo để xoay · chụm để zoom</div>
`;function tc(i,t={}){i.innerHTML=F0;const e=O0(i,t);for(const[,l]of I0)l(e);let n=e.api;const r=l=>(...c)=>n?.[l]?.(...c),s=l=>(...c)=>n?.music[l]?.(...c),a={api:{push:r("push"),setStat:r("setStat"),select:r("select"),setMode:r("setMode"),setWeather:r("setWeather"),music:{play:s("play"),pause:s("pause"),go:s("go"),chime:s("chime"),thunder:s("thunder")}},dispose:()=>{n=null,B0(e),a.ctx=null},ctx:e};return a}function js(i,t){if(t.has(i))return;t.add(i);for(const n of Object.values(i))n instanceof we&&!t.has(n)&&(t.add(n),n.dispose());const e=i.uniforms;if(e)for(const n of Object.values(e))n?.value instanceof we&&!t.has(n.value)&&(t.add(n.value),n.value.dispose());i.dispose()}function al(i,t){i.traverse(e=>{const n=e;n.geometry&&!t.has(n.geometry)&&(t.add(n.geometry),n.geometry.dispose());const r=n.material;Array.isArray(r)?r.forEach(s=>js(s,t)):r&&js(r,t),e.isInstancedMesh&&e.dispose(),e.isLight&&e.dispose()})}function B0(i){if(i.disposed)return;i.disposed=!0,cancelAnimationFrame(i.raf),i._clearTimers(),i.disposeAudio?.(),i.controls?.dispose();const t=new Set;i.scene&&(al(i.scene,t),i.scene.environment=null),i.envScene&&al(i.envScene,t);for(const e of Object.values(i.MAT??{}))js(e,t);if(i.envRT?.dispose(),i.pmrem?.dispose(),i.bloom?.dispose(),i.composer?.dispose(),i.renderer){const e=i.renderer;e.dispose(),e.forceContextLoss(),e.domElement.remove()}i.root.innerHTML="";for(const e of Object.keys(i))e!=="disposed"&&e!=="root"&&delete i[e]}function z0(i){if(window.parent===window)return()=>{};const t=location.origin,e=a=>window.parent.postMessage({source:"amber-world",...a},t),n=a=>{if(a.origin!==t||a.source!==window.parent)return;const l=a.data;if(!l||l.source!=="amber-flutter"||l.type!=="call"||typeof l.method!="string")return;const c=Array.isArray(l.args)?l.args:[],[u,f]=l.method.split("."),p=(f?i.api[u]:i.api)?.[f??u];typeof p=="function"&&p(...c)};window.addEventListener("message",n);const r=document.getElementById("sheet");let s=!1;const o=new MutationObserver(()=>{const a=!!r?.classList.contains("on");a!==s&&(s=a,e({type:"sheet",open:a,id:a?i.ctx?.current??null:null}))});return r&&o.observe(r,{attributes:!0,attributeFilter:["class"]}),e({type:"ready"}),()=>{o.disconnect(),window.removeEventListener("message",n)}}const Us=new URLSearchParams(location.search),ho=tc(document.getElementById("world"),{lite:Us.has("lite"),seed:Us.has("seed")?Number(Us.get("seed")):void 0});window.AmberWorld=ho.api;window.__world=ho;z0(ho);window.__createWorld=tc;
