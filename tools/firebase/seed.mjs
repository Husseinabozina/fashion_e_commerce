import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { Firestore } from '@google-cloud/firestore';
import { OAuth2Client } from 'google-auth-library';

// Uses the existing Firebase CLI login in memory; never exports account tokens.
const require = createRequire(import.meta.url);
const cliAuth = require('firebase-tools/lib/auth');
const account = cliAuth.getProjectDefaultAccount(new URL('../../',import.meta.url).pathname);
if (!account) throw new Error('Sign in with firebase login before seeding.');
cliAuth.setActiveAccount({}, account);
const token = await cliAuth.getAccessToken(account.tokens.refresh_token,['https://www.googleapis.com/auth/cloud-platform']);
const authClient = new OAuth2Client();
authClient.setCredentials({access_token:token.access_token,expiry_date:token.expires_at});
const db = new Firestore({projectId:'nova-fashion-hussein',databaseId:'nova-app',authClient});
const docs=JSON.parse(readFileSync(new URL('./catalog-seed.json',import.meta.url)));
const batch=db.batch();
for(const [path,data] of Object.entries(docs)) batch.set(db.doc(path),data);
await batch.commit();
console.log(`Seeded ${Object.keys(docs).length} public catalog documents in nova-fashion-hussein/nova-app.`);
await db.terminate();
