import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();
const db = admin.firestore();
const fcm = admin.messaging();


export const sendToDevice = functions.firestore.document('returns/{returnsId}').onCreate(async snapshot =>{

    const returns = snapshot.data();

    const querySnapshot = await db.collection('users').doc(returns?.uid).collection('tokens').get();

    const tokens = querySnapshot.docs.map(snap =>snap.id);

    const payload: admin.messaging.MessagingPayload={
        notification:{
            title:'New Noti',
            body:'something',
            clickAction:'FLUTTER_NOTIFICATION_CLICK'
        }
    };
    return fcm.sendToDevice(tokens,payload);
});