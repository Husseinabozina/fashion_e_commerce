import { readFileSync } from 'node:fs';
import { test, before, after } from 'node:test';
import { initializeTestEnvironment, assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, collection, getDoc, getDocs, setDoc, updateDoc, deleteDoc, writeBatch, serverTimestamp, Timestamp } from 'firebase/firestore';

let env, alice, bob, guest, anonymous;
const catalog = JSON.parse(readFileSync(new URL('./catalog-seed.json', import.meta.url)));
const product = catalog['products/nb-9060'];
const cart = {productId: 'nb-9060', color:'Black', size:'42', quantity:1};
const address = {label:'Home',fullName:'Test User',phone:'01012345678',city:'Cairo',area:'Nasr City',street:'Test',building:'1',notes:''};
const item = {productId:'nb-9060',brand:product.brand,name:product.name,category:product.category,price:product.price,imageUrl:product.imageUrl,color:'Black',size:'42',quantity:1};
const order = () => ({isDemo:true,items:[item],total:3499,createdAt:serverTimestamp(),deliveryEta:'3–5 days',shippingAddressLabel:'Cairo',deliveryTitle:'Standard Delivery',paymentTitle:'Card',status:'placed',returnRequestId:null});
const review = () => ({authorUid:'alice',authorName:'Test User',rating:5,comment:'Good fit',fit:'trueToSize',createdAt:serverTimestamp(),updatedAt:serverTimestamp(),verifiedPurchase:false});
before(async () => {
  env = await initializeTestEnvironment({ projectId:'demo-nova', firestore:{rules:readFileSync(new URL('../../firestore.rules',import.meta.url),'utf8')} });
  alice = env.authenticatedContext('alice',{name:'Test User',firebase:{sign_in_provider:'password'}}).firestore();
  bob = env.authenticatedContext('bob',{name:'Other User',firebase:{sign_in_provider:'password'}}).firestore();
  guest = env.authenticatedContext('guest',{firebase:{sign_in_provider:'anonymous'}}).firestore();
  anonymous = env.unauthenticatedContext().firestore();
  await env.withSecurityRulesDisabled(async ctx => {
    const db=ctx.firestore();
    for (const [path,data] of Object.entries(catalog)) await setDoc(doc(db,path),data);
    await setDoc(doc(db,'users/alice/notifications/n1'),{title:'Update',message:'Ready',type:'order',productId:null,isRead:false,createdAt:Timestamp.now()});
    await setDoc(doc(db,'users/alice/demoOrders/delivered'),{...order(),createdAt:Timestamp.now(),status:'delivered'});
  });
});
after(async () => { await env?.cleanup(); });

test('sandbox invoice pointers are own, immutable, bounded and test-only',async()=>{
 const key='a'.repeat(64), path=`users/alice/sandboxPayments/${key}`;
 const data=()=>({isDemo:true,reference:'NOVA-'+ 'a'.repeat(32),invoiceId:123,
 checkoutUrl:'https://demo.myfatoorah.com/Ar/KWT/PayInvoice/Checkout?invoiceKey=test',
 orderTotalEgp:1000,amount:1,currency:'KWD',createdAt:serverTimestamp()});
 await assertSucceeds(setDoc(doc(alice,path),data()));
 await assertSucceeds(getDoc(doc(alice,path)));
 await assertFails(getDoc(doc(bob,path)));
 await assertFails(getDocs(collection(bob,'users/alice/sandboxPayments')));
 await assertFails(updateDoc(doc(alice,path),{invoiceId:999}));
 await assertFails(deleteDoc(doc(bob,path)));
 for(const patch of [{isDemo:false},{amount:1000},{currency:'EGP'},{invoiceId:'123'},
 {checkoutUrl:'https://portal.myfatoorah.com/pay'},{checkoutUrl:'https://demo.myfatoorah.com.evil.test/pay'},
 {createdAt:Timestamp.fromMillis(1)},{reference:'x'.repeat(1000)},{ownerUid:'alice'},{orderTotalEgp:-1}]) {
   await assertFails(setDoc(doc(alice,'users/alice/sandboxPayments/'+ 'b'.repeat(64)),{...data(),...patch}));
 }
 await assertFails(setDoc(doc(bob,'users/alice/sandboxPayments/'+ 'c'.repeat(64)),data()));
 await assertFails(setDoc(doc(anonymous,'users/alice/sandboxPayments/'+ 'd'.repeat(64)),data()));
 await assertSucceeds(deleteDoc(doc(alice,path)));
});
test('demo receipt metadata is constrained and cannot become real payment evidence',async()=>{
 const receipt={provider:'MyFatoorah',invoiceId:123,amount:1,currency:'KWD'};
 await assertSucceeds(setDoc(doc(alice,'users/alice/demoOrders/sandbox'),{...order(),sandboxPayment:receipt}));
 await assertFails(updateDoc(doc(alice,'users/alice/demoOrders/sandbox'),{'sandboxPayment.invoiceId':999}));
 for(const patch of [{amount:200},{provider:'Stripe'},{currency:'EGP'},{invoiceId:-1},{isLive:true}]) {
   await assertFails(setDoc(doc(alice,'users/alice/demoOrders/sandbox-bad'),{...order(),sandboxPayment:{...receipt,...patch}}));
 }
 await assertFails(setDoc(doc(alice,'users/alice/demoOrders/sandbox-cod'),{...order(),paymentTitle:'Cash on Delivery',sandboxPayment:receipt}));
 await assertFails(setDoc(doc(alice,'payments/real'),{...receipt,status:'paid'}));
 await assertFails(setDoc(doc(alice,'users/alice/orders/real'),{...order(),isDemo:false}));
});

test('catalog requires authentication, includes guests', async()=>{
 await assertFails(getDoc(doc(anonymous,'products/nb-9060')));
 await assertSucceeds(getDocs(collection(guest,'products')));
});
test('catalog, price and promotion writes denied to clients',async()=>{
 await assertFails(updateDoc(doc(alice,'products/nb-9060'),{price:1}));
 await assertFails(setDoc(doc(alice,'promotions/EVIL'),{value:100}));
});
test('owner cart valid write and query permitted',async()=>{
 await assertSucceeds(setDoc(doc(alice,'users/alice/cart/item'),cart));
 await assertSucceeds(getDocs(collection(alice,'users/alice/cart')));
});
test('cross-account get, list, create, update and delete denied',async()=>{
 const ref=doc(bob,'users/alice/cart/item');
 await assertFails(getDoc(ref)); await assertFails(getDocs(collection(bob,'users/alice/cart')));
 await assertFails(setDoc(doc(bob,'users/alice/cart/intrusion'),cart));
 await assertFails(updateDoc(ref,{quantity:2})); await assertFails(deleteDoc(ref));
});
test('malformed cart, quantities, stock and invented variants denied',async()=>{
 for(const patch of [{quantity:0},{quantity:100},{quantity:1.5},{price:1},{size:'44'},{size:'FAKE'},{color:'FAKE'},{productId:'missing'}]) {
  await assertFails(setDoc(doc(alice,'users/alice/cart/bad'),{...cart,...patch}));
 }
});
test('wishlist owner and canonical product references only',async()=>{
 await assertSucceeds(setDoc(doc(guest,'users/guest/wishlist/nb-9060'),{productId:'nb-9060'}));
 await assertFails(setDoc(doc(guest,'users/guest/wishlist/fake'),{productId:'nb-9060'}));
 await assertFails(setDoc(doc(guest,'users/guest/wishlist/nb-9060'),{productId:'nb-9060',ownerUid:'alice'}));
});
test('private address and batch default selection allowed',async()=>{
 const batch=writeBatch(alice);batch.set(doc(alice,'users/alice/addresses/home'),address);batch.set(doc(alice,'users/alice/settings/defaultAddress'),{addressId:'home'});
 await assertSucceeds(batch.commit());
 await assertFails(getDoc(doc(bob,'users/alice/addresses/home')));
 await assertFails(setDoc(doc(alice,'users/alice/addresses/bad'),{...address,isAdmin:true}));
 await assertFails(setDoc(doc(alice,'users/alice/settings/defaultAddress'),{addressId:'missing'}));
});
test('settings only bounded supported interests, no role escalation',async()=>{
 await assertSucceeds(setDoc(doc(alice,'users/alice/settings/shopping'),{hasCompletedOnboarding:true,interests:['Sneakers']}));
 for(const patch of [{interests:[42]},{interests:['unknown']},{hasCompletedOnboarding:'true'},{role:'admin'}]) await assertFails(setDoc(doc(alice,'users/alice/settings/shopping'),{hasCompletedOnboarding:true,interests:[],...patch}));
 await assertFails(setDoc(doc(alice,'users/alice'),{role:'admin'}));
});
test('recent timestamp cannot be forged and brand id must exist',async()=>{
 await assertSucceeds(setDoc(doc(alice,'users/alice/recentlyViewed/nb-9060'),{productId:'nb-9060',viewedAt:serverTimestamp()}));
 await assertFails(setDoc(doc(alice,'users/alice/recentlyViewed/nb-9060'),{productId:'nb-9060',viewedAt:Timestamp.fromMillis(1)}));
 await assertSucceeds(setDoc(doc(alice,'users/alice/following/nike'),{brandId:'nike'}));
 await assertFails(setDoc(doc(alice,'users/alice/following/evil'),{brandId:'evil'}));
});
test('back-in-stock accepts catalog variants, never arbitrary payload',async()=>{
 await assertSucceeds(setDoc(doc(guest,'users/guest/subscriptions/wait'),{productId:'nb-9060',color:'Black',size:'44'}));
 await assertFails(setDoc(doc(guest,'users/guest/subscriptions/bad'),{productId:'nb-9060',color:'Black',size:'44',email:'victim@example.com'}));
});
test('notifications can only be marked read by owner',async()=>{
 await assertSucceeds(updateDoc(doc(alice,'users/alice/notifications/n1'),{isRead:true}));
 await assertFails(updateDoc(doc(alice,'users/alice/notifications/n1'),{message:'forged',isRead:true}));
 await assertFails(updateDoc(doc(bob,'users/alice/notifications/n1'),{isRead:true}));
 await assertFails(setDoc(doc(alice,'users/alice/notifications/spam'),{}));
});
test('review ownership, name, rating and verified status enforced',async()=>{
 await assertSucceeds(setDoc(doc(alice,'products/nb-9060/reviews/alice'),review()));
 for(const patch of [{authorName:'Someone Else'},{rating:6},{rating:0},{rating:2.5},{comment:''},{verifiedPurchase:true},{role:'admin'}]) await assertFails(setDoc(doc(alice,'products/nb-9060/reviews/alice'),{...review(),...patch}));
 await assertFails(setDoc(doc(bob,'products/nb-9060/reviews/alice'),review()));
 await assertFails(setDoc(doc(guest,'products/nb-9060/reviews/guest'),{...review(),authorUid:'guest'}));
});
test('review original creation time remains immutable',async()=>{
 await assertSucceeds(updateDoc(doc(alice,'products/nb-9060/reviews/alice'),{comment:'Updated',updatedAt:serverTimestamp()}));
 await assertFails(updateDoc(doc(alice,'products/nb-9060/reviews/alice'),{createdAt:serverTimestamp(),updatedAt:serverTimestamp()}));
});
test('demo receipt creation allowed, real/paid/delivered creation denied',async()=>{
 await assertSucceeds(setDoc(doc(alice,'users/alice/demoOrders/order1'),order()));
 for(const patch of [{isDemo:false},{status:'paid'},{status:'delivered'},{total:-1},{items:[]},{items:[{...item,price:-1}]},{items:[{...item,quantity:100}]},{items:[{...item,imageUrl:'javascript:bad'}]},{role:'admin'}]) await assertFails(setDoc(doc(alice,'users/alice/demoOrders/bad'),{...order(),...patch}));
 await assertFails(setDoc(doc(alice,'users/alice/orders/real'),order()));
});
test('receipt price, total, status, timestamps and ownership immutable',async()=>{
 const ref=doc(alice,'users/alice/demoOrders/order1');
 for(const patch of [{total:1},{items:[{...item,price:1}]},{status:'delivered'},{createdAt:serverTimestamp()},{ownerUid:'bob'}]) await assertFails(updateDoc(ref,patch));
 await assertFails(deleteDoc(ref));await assertFails(getDoc(doc(bob,'users/alice/demoOrders/order1')));
});
test('return must accompany delivered order transition atomically',async()=>{
 const data={orderId:'delivered',itemKey:'nb-9060::Black::42',itemIndex:0,type:'returnItem',reason:'Wrong size',requestedSize:null,status:'submitted',createdAt:serverTimestamp()};
 // A standalone request cannot transition the order; both writes are required.
 await assertFails(setDoc(doc(alice,'users/alice/returnRequests/forged'),data));
 const valid={...data,itemKey:'nb-9060::Black::42'};
 const batch=writeBatch(alice);batch.set(doc(alice,'users/alice/returnRequests/return1'),valid);batch.update(doc(alice,'users/alice/demoOrders/delivered'),{status:'returnRequested',returnRequestId:'return1'});
 await assertSucceeds(batch.commit());
 await assertFails(setDoc(doc(alice,'users/alice/returnRequests/replay'),valid));
});

const {authFlow}=await import('./auth.test.mjs');
test('guest upgrade preserves UID and saved data; failed sign-in never creates a user; new guest isolation and registered sign-in restore',authFlow);

test('device tokens and push preferences are private, bounded and cannot create messages',async()=>{
 const data={token:'valid-token-12345678901234567890',platform:'android',updatedAt:serverTimestamp()};
 const ref=doc(alice,'users/alice/devices/device');
 await assertSucceeds(setDoc(ref,data));
 await assertFails(getDoc(doc(bob,'users/alice/devices/device')));
 await assertFails(deleteDoc(doc(bob,'users/alice/devices/device')));
 for(const patch of [{token:'x'},{token:'x'.repeat(2049)},{platform:'web'},{ownerUid:'bob'},{updatedAt:Timestamp.fromMillis(1)}]) await assertFails(setDoc(ref,{...data,...patch}));
 await assertSucceeds(setDoc(doc(alice,'users/alice/settings/push'),{enabled:true}));
 await assertFails(setDoc(doc(bob,'users/alice/settings/push'),{enabled:false}));
 await assertFails(setDoc(doc(alice,'users/alice/settings/push'),{enabled:true,role:'admin'}));
 await assertFails(setDoc(doc(alice,'notificationOutbox/fake'),{uid:'alice',token:data.token}));
 await assertSucceeds(deleteDoc(ref));
 await assertSucceeds(deleteDoc(doc(alice,'deviceBindings/already-removed')));
});

test('one device binding transfers ownership without exposing the previous account',async()=>{
 const token='unique-installation-token-1234567890';
 const data={token,platform:'android',updatedAt:serverTimestamp()};
 const bind={ownerUid:'alice',updatedAt:serverTimestamp()};
 let batch=writeBatch(alice);batch.set(doc(alice,'users/alice/devices/install'),data);batch.set(doc(alice,'deviceBindings/install'),bind);await assertSucceeds(batch.commit());
 await assertFails(getDoc(doc(bob,'deviceBindings/install')));
 await assertFails(setDoc(doc(bob,'deviceBindings/install'),{ownerUid:'bob',updatedAt:serverTimestamp()}));
 batch=writeBatch(bob);batch.set(doc(bob,'users/bob/devices/install'),data);batch.set(doc(bob,'deviceBindings/install'),{ownerUid:'bob',updatedAt:serverTimestamp()});await assertSucceeds(batch.commit());
 await assertFails(getDoc(doc(alice,'deviceBindings/install')));
 await assertFails(deleteDoc(doc(alice,'deviceBindings/install')));
 await assertSucceeds(getDoc(doc(bob,'deviceBindings/install')));
 await assertFails(setDoc(doc(bob,'deviceBindings/install'),{ownerUid:'alice',updatedAt:serverTimestamp()}));
});
