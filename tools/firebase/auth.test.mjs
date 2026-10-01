import assert from 'node:assert/strict';
import {initializeApp,deleteApp} from 'firebase/app';
import {getAuth,connectAuthEmulator,signInAnonymously,linkWithCredential,EmailAuthProvider,updateProfile,signOut,signInWithEmailAndPassword,sendPasswordResetEmail,deleteUser} from 'firebase/auth';
import {getFirestore,connectFirestoreEmulator,doc,setDoc,getDocFromServer,deleteDoc,terminate} from 'firebase/firestore';
export async function authFlow() {
 const app=initializeApp({apiKey:'demo-key',projectId:'demo-nova'},'auth-flow');
 const auth=getAuth(app);connectAuthEmulator(auth,'http://127.0.0.1:9099',{disableWarnings:true});
 const db=getFirestore(app);connectFirestoreEmulator(db,'127.0.0.1',8080);
 const email=`nova-${Date.now()}@example.com`,password='test-only-pass-123';
 let path;
 try {
  const guest=(await signInAnonymously(auth)).user;
  path=`users/${guest.uid}/wishlist/nb-9060`;
  await setDoc(doc(db,path),{productId:'nb-9060'});
  const registered=(await linkWithCredential(guest,EmailAuthProvider.credential(email,password))).user;
  await updateProfile(registered,{displayName:'Test Member'});
  await registered.getIdToken(true);
  assert.equal(registered.uid,guest.uid);assert.equal(registered.isAnonymous,false);
  assert.equal((await getDocFromServer(doc(db,path))).exists(),true);
  await sendPasswordResetEmail(auth,email);
  await signOut(auth);const newGuest=(await signInAnonymously(auth)).user;
  assert.notEqual(newGuest.uid,guest.uid);
  await assert.rejects(getDocFromServer(doc(db,path)),e=>e.code==='permission-denied');
  await assert.rejects(signInWithEmailAndPassword(auth,email,'wrong-password'));
  assert.equal(auth.currentUser.uid,newGuest.uid);
  await deleteUser(newGuest);
  await assert.rejects(signInWithEmailAndPassword(auth,'unknown@example.com',password));
  assert.equal(auth.currentUser,null);
  await signInWithEmailAndPassword(auth,email,password);
  assert.equal(auth.currentUser.uid,guest.uid);
  assert.equal(auth.currentUser.displayName,'Test Member');
  assert.equal((await getDocFromServer(doc(db,path))).exists(),true);
  await deleteDoc(doc(db,path));
 } finally {
  if(auth.currentUser)await deleteUser(auth.currentUser);
  await terminate(db);await deleteApp(app);
 }
}
