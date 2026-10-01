import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';
import { initializeApp, deleteApp } from 'firebase/app';
import { getAuth, signInAnonymously, deleteUser } from 'firebase/auth';
import { getFirestore, doc, collection, getDocsFromServer, getDocFromServer, setDoc, deleteDoc, terminate } from 'firebase/firestore';
const options=JSON.parse(readFileSync(new URL('./web-config.json', import.meta.url)));
const appA=initializeApp(options,'live-smoke-a');const appB=initializeApp(options,'live-smoke-b');
const authA=getAuth(appA),authB=getAuth(appB);
const dbA=getFirestore(appA,'nova-app'),dbB=getFirestore(appB,'nova-app');
let path;
try {
 const a=(await signInAnonymously(authA)).user;const b=(await signInAnonymously(authB)).user;
 assert.notEqual(a.uid,b.uid);
 const products=await getDocsFromServer(collection(dbA,'products'));assert.equal(products.size,6);
 path=`users/${a.uid}/wishlist/nb-9060`;
 await setDoc(doc(dbA,path),{productId:'nb-9060'});
 assert.equal((await getDocFromServer(doc(dbA,path))).exists(),true);
 await assert.rejects(getDocFromServer(doc(dbB,path)),e=>e.code==='permission-denied');
 await assert.rejects(setDoc(doc(dbB,path),{productId:'nb-9060'}),e=>e.code==='permission-denied');
 await deleteDoc(doc(dbA,path));
 console.log('LIVE PASS: anonymous Auth, named database nova-app, six catalog products, own persistence and cross-UID denial.');
} finally {
 if(path && authA.currentUser) await deleteDoc(doc(dbA,path)).catch(()=>{});
 await Promise.all([authA.currentUser&&deleteUser(authA.currentUser),authB.currentUser&&deleteUser(authB.currentUser)]);
 await Promise.all([terminate(dbA),terminate(dbB)]);await Promise.all([deleteApp(appA),deleteApp(appB)]);
}
