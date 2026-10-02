import {initializeApp} from 'firebase-admin/app';
import {getFirestore,FieldValue} from 'firebase-admin/firestore';
import {getMessaging} from 'firebase-admin/messaging';
import {onDocumentUpdated,onDocumentCreated} from 'firebase-functions/v2/firestore';
import {notificationId,restoredSizes,matchesSubscription,deliverNotification} from './notifications.mjs';
initializeApp();
const db=getFirestore('nova-app');
const options={database:'nova-app',region:'europe-west3',retry:true};
async function enqueue(eventId,uid,key,notification) {
  const id=notificationId(eventId,uid,key), outbox=db.collection('notificationOutbox').doc(id);
  await db.runTransaction(async tx=>{
    if ((await tx.get(outbox)).exists) return;
    tx.create(outbox,{...notification,uid,id,completed:[],state:'pending',leaseUntil:0,createdAt:FieldValue.serverTimestamp()});
    tx.create(db.doc(`users/${uid}/notifications/${id}`),{...notification,createdAt:FieldValue.serverTimestamp(),isRead:false});
  });
}
export const stockNotifications=onDocumentUpdated({...options,document:'products/{productId}'},async event=>{
  const before=event.data.before.data(),after=event.data.after.data(),sizes=restoredSizes(before,after);
  if (!sizes.length) return;
  const subscriptions=await db.collectionGroup('subscriptions').where('productId','==',event.params.productId).get();
  for(const doc of subscriptions.docs) {
    if (doc.ref.parent.parent?.parent.id !== 'users') continue;
    if (matchesSubscription(doc.data(),event.params.productId,after,sizes)) {
      const uid=doc.ref.parent.parent.id;
      await enqueue(event.id,uid,`stock:${event.params.productId}`,{title:'NOVA',message:'An item you follow is back in stock.',type:'backInStock',productId:event.params.productId});
    }
  }
});
// Only server-owned real orders; demoOrders never trigger shipment/payment claims.
export const orderNotifications=onDocumentUpdated({...options,document:'users/{uid}/orders/{orderId}'},async event=>{
  const before=event.data.before.data(),after=event.data.after.data();
  if (!before || !after || before.status===after.status || after.isDemo===true) return;
  await enqueue(event.id,event.params.uid,`order:${event.params.orderId}`,{title:'NOVA',message:'There is an update to your order.',type:'order',productId:null});
});
export const sendNotification=onDocumentCreated({...options,document:'notificationOutbox/{id}'},async event=>{
  const ref=event.data.ref;
  const queue={
    claim: now=>db.runTransaction(async tx=>{
      const job=(await tx.get(ref)).data();
      if (!job || job.state==='sent') return null;
      if (job.leaseUntil>now) throw new Error('Notification delivery lease is busy.');
      tx.update(ref,{state:'sending',leaseUntil:now+120000}); return job;
    }),
    completed:id=>ref.update({completed:FieldValue.arrayUnion(id)}),
    finish:()=>ref.update({state:'sent',leaseUntil:0,sentAt:FieldValue.serverTimestamp()}),
    release:()=>ref.update({state:'pending',leaseUntil:0})
  };
  const deviceRef=(uid,id)=>db.doc(`users/${uid}/devices/${id}`);
  const devices={
    enabled:async uid=>(await db.doc(`users/${uid}/settings/push`).get()).data()?.enabled===true,
    list:async uid=>(await db.collection(`users/${uid}/devices`).get()).docs.map(doc=>({id:doc.id,...doc.data()})),
    exists:async(uid,id,token)=>{
      const [device,binding]=await Promise.all([deviceRef(uid,id).get(),db.doc(`deviceBindings/${id}`).get()]);
      return device.data()?.token===token && binding.data()?.ownerUid===uid;
    },
    remove:(uid,id,token)=>db.runTransaction(async tx=>{
      const ref=deviceRef(uid,id),bindingRef=db.doc(`deviceBindings/${id}`);
      const [device,binding]=await Promise.all([tx.get(ref),tx.get(bindingRef)]);
      if(device.data()?.token===token) tx.delete(ref);
      if(binding.data()?.ownerUid===uid) tx.delete(bindingRef);
    })
  };
  await deliverNotification({queue,devices,send:message=>getMessaging().send(message)});
});
