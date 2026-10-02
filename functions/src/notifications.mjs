import {createHash} from 'node:crypto';
export const notificationId = (eventId, uid, key) => createHash('sha256').update(JSON.stringify([eventId,uid,key])).digest('hex');
export function restoredSizes(before, after) {
  if (!before || !after) return [];
  return (after.sizes ?? []).filter(size => (before.sizes ?? []).includes(size)
    && (before.outOfStockSizes ?? []).includes(size) && !(after.outOfStockSizes ?? []).includes(size));
}
export function matchesSubscription(subscription, productId, after, sizes) {
  return subscription.productId === productId && sizes.includes(subscription.size)
    && (after.colors ?? []).includes(subscription.color);
}
export const terminalTokenErrors = new Set(['messaging/registration-token-not-registered','messaging/invalid-registration-token']);
// Delivery is at least once: a crash after FCM accepts a message can repeat it.
// The durable queue, progress and per-device collapse ID bound repeated delivery.
export async function deliverNotification({queue, devices, send, now = Date.now}) {
  const job = await queue.claim(now());
  if (!job) return;
  try {
    const enabled = await devices.enabled(job.uid);
    const registrations = enabled ? await devices.list(job.uid) : [];
    for (const device of registrations) {
      if ((job.completed ?? []).includes(device.id)) continue;
      // Recheck registration immediately before sending after an account change.
      if (!await devices.exists(job.uid, device.id, device.token)) continue;
      try {
        await send({token:device.token, notification:{title:job.title,body:job.message},
          data:{ownerUid:job.uid,...(job.productId ? {productId:job.productId} : {})},
          android:{collapseKey:job.id},apns:{headers:{'apns-collapse-id':job.id}}});
      } catch (error) {
        if (!terminalTokenErrors.has(error.code)) throw error;
        await devices.remove(job.uid, device.id, device.token);
      }
      await queue.completed(device.id);
    }
    await queue.finish();
  } catch (error) {
    await queue.release();
    throw error;
  }
}
