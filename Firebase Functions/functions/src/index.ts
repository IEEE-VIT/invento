import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();
const db = admin.firestore();
const fcm = admin.messaging();


export const sendToDevice1 = functions.firestore.document('returns/{returnsId}').onCreate(async snapshot =>{

    const returns = snapshot.data();

    const querySnapshot = await db.collection('users').doc(returns?.uid).collection('tokens').get();

    const tokens = querySnapshot.docs.map(snap =>snap.id);

    const payload: admin.messaging.MessagingPayload={
        notification:{
            title:('Request to return '+returns?.component),
            body:'Please go to your Profile Section to return the component',
            clickAction:'FLUTTER_NOTIFICATION_CLICK'
        }
    };
    return fcm.sendToDevice(tokens,payload);
});

export const sendToDevice2 = functions.firestore.document('returnRequest/{returnRequestId}').onDelete(async snapshot =>{

    const returnRequest = snapshot.data();

    const querySnapshot = await db.collection('users').doc(returnRequest?.userUid).collection('tokens').get();

    const tokens = querySnapshot.docs.map(snap =>snap.id);

    const payload: admin.messaging.MessagingPayload={
        notification:{
            title:('Return Request Approved!'),
            body:('You have successfully returned '+returnRequest?.componentName),
            clickAction:'FLUTTER_NOTIFICATION_CLICK'
        }
    };
    return fcm.sendToDevice(tokens,payload);
});