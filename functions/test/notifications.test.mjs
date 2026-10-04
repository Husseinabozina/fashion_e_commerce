import {test} from 'node:test';
import assert from 'node:assert/strict';
import {notificationId,restoredSizes,matchesSubscription,deliverNotification} from '../src/notifications.mjs';
test('stock alerts require an existing size changing from unavailable to available',()=>{
 const before={sizes:['S','M'],outOfStockSizes:['M']},after={sizes:['S','M','L'],outOfStockSizes:[],colors:['Black']};
 assert.deepEqual(restoredSizes(before,after),['M']);
 assert.deepEqual(restoredSizes(null,after),[]);
 assert.equal(matchesSubscription({productId:'p',size:'M',color:'Black'},'p',after,['M']),true);
 assert.equal(matchesSubscription({productId:'p',size:'M',color:'Red'},'p',after,['M']),false);
 assert.equal(matchesSubscription({productId:'x',size:'M',color:'Black'},'p',after,['M']),false);
});
test('duplicate events share one ID but different accounts/events do not',()=>{
 assert.equal(notificationId('e','u','p'),notificationId('e','u','p'));
 assert.notEqual(notificationId('e','u','p'),notificationId('e','v','p'));
 assert.notEqual(notificationId('e','u','p'),notificationId('f','u','p'));
});
function fixture() {
 const job={id:'q',uid:'alice',title:'NOVA',message:'Update',productId:'p',completed:[]};
 const state={sent:[],removed:[],finished:false,released:false,enabled:true,exists:true};
 const queue={claim:async()=>job,completed:async id=>job.completed.push(id),finish:async()=>{state.finished=true},release:async()=>{state.released=true}};
 const devices={enabled:async()=>state.enabled,list:async()=>[{id:'a',token:'A'},{id:'b',token:'B'}],exists:async()=>state.exists,remove:async(_,id)=>state.removed.push(id)};
 return {job,state,queue,devices,send:async message=>state.sent.push(message)};
}
test('delivery skips completed devices, has scoped data and finishes',async()=>{
 const f=fixture(); f.job.completed=['a']; await deliverNotification(f);
 assert.equal(f.state.sent.length,1);assert.equal(f.state.sent[0].token,'B');
 assert.deepEqual(f.state.sent[0].data,{ownerUid:'alice',productId:'p'});assert.equal(f.state.finished,true);
});
test('revoked registrations and disabled push never send',async()=>{
 for(const key of ['exists','enabled']) {const f=fixture();f.state[key]=false;await deliverNotification(f);assert.equal(f.state.sent.length,0);assert.equal(f.state.finished,true);}
});
test('invalid tokens removed, transient errors release and preserve progress for retry',async()=>{
 const f=fixture(); f.send=async m=>{if(m.token==='A')throw Object.assign(new Error(),{code:'messaging/registration-token-not-registered'});throw Object.assign(new Error(),{code:'messaging/server-unavailable'});};
 await assert.rejects(deliverNotification(f));assert.deepEqual(f.state.removed,['a']);assert.deepEqual(f.job.completed,['a']);assert.equal(f.state.released,true);assert.equal(f.state.finished,false);
 f.send=async m=>f.state.sent.push(m);await deliverNotification(f);assert.equal(f.state.sent.length,1);assert.equal(f.state.finished,true);
});
